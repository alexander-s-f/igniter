# frozen_string_literal: true

require "securerandom"
require "time"
require_relative "availability_ledger"
require_relative "ledger_boundary"

module Igniter
  module Store
    module IntelligentLedger
      # Extends AvailabilityLedger with LedgerBoundary lifecycle management.
      #
      # Tracks boundaries in-memory (keyed by boundary_key) and persists
      # closure/settlement/compaction receipts to the store.
      #
      # Additional store layout:
      #   :ledger_boundaries          — key: boundary_key
      #   :ledger_boundary_receipts   — key: boundary_key
      #   :ledger_boundary_summaries  — key: boundary_key  (settlement output)
      #   :ledger_boundary_metrics    — key: boundary_key  (settlement output)
      #   :ledger_settlement_receipts — key: boundary_key  (settlement output)
      #   :ledger_cleanup_receipts    — key: boundary_key
      #   :late_fact_receipts         — key: "late/<boundary_key>/<token>"
      class AvailabilityBoundaryLedger
        PRODUCER = {
          "system"  => "availability_boundary_ledger",
          "version" => LedgerBoundary::RULE_VERSION
        }.freeze

        def initialize(store:)
          @store      = store
          @ledger     = AvailabilityLedger.new(store: store)
          @boundaries = {}
        end

        # Delegate base fact writes to the underlying ledger.
        def write_template(...)    = @ledger.write_template(...)
        def write_override(...)    = @ledger.write_override(...)
        def write_order_event(...) = @ledger.write_order_event(...)

        # Opens a new boundary for a technician day (status: :open).
        def open_boundary(company_id:, technician_id:, date:)
          subject  = build_subject(company_id, technician_id, date)
          boundary = LedgerBoundary.new(subject: subject)
          @boundaries[boundary.boundary_key] = boundary
          boundary
        end

        # Returns the in-memory boundary for a given key, or nil.
        def find_boundary(boundary_key)
          @boundaries[boundary_key]
        end

        # Closes the boundary: derives snapshot, persists boundary records + receipts,
        # transitions boundary to :closed.
        #
        # Returns:
        #   { boundary:, snapshot_fact:, receipt_fact:, boundary_fact:, closure_receipt_fact: }
        def close_boundary(company_id:, technician_id:, date:, horizon_days: 1)
          boundary = find_or_open_boundary(company_id: company_id, technician_id: technician_id, date: date)

          result        = @ledger.compute_snapshot(
            technician_id: technician_id,
            horizon_start: coerce_date(date),
            horizon_days:  horizon_days
          )
          snapshot_fact = result[:snapshot_fact]
          receipt_fact  = result[:receipt_fact]
          source_ids    = snapshot_fact.value[:derived_from_fact_ids] || []

          boundary.close!(output_fact: snapshot_fact, receipt_fact: receipt_fact, source_fact_ids: source_ids)

          boundary_fact = @store.write(
            store:    :ledger_boundaries,
            key:      boundary.boundary_key,
            value:    boundary_record_value(boundary),
            producer: PRODUCER
          )

          closure_receipt = @store.write(
            store:    :ledger_boundary_receipts,
            key:      boundary.boundary_key,
            value:    {
              "boundary_key"    => boundary.boundary_key,
              "output_fact_id"  => boundary.output_fact_id,
              "receipt_fact_id" => boundary.receipt_fact_id,
              "result_hash"     => boundary.result_hash,
              "source_fact_ids" => boundary.source_fact_ids,
              "detail_status"   => boundary.detail_status.to_s,
              "closed_at"       => boundary.closed_at.iso8601(3)
            },
            producer: PRODUCER
          )

          { boundary: boundary, snapshot_fact: snapshot_fact, receipt_fact: receipt_fact,
            boundary_fact: boundary_fact, closure_receipt_fact: closure_receipt }
        end

        # Settle a closed boundary: runs pre-compaction transforms (summary, metrics),
        # persists settlement receipt, transitions settlement_status to :settled.
        #
        # Settlement transforms:
        #   "availability_summary" — compact summary of the snapshot output
        #   "availability_metrics" — derived capacity metrics
        #
        # Returns:
        #   { boundary:, summary_fact:, metrics_fact:, settlement_receipt: }
        def settle_boundary(boundary_key)
          boundary = @boundaries[boundary_key]
          raise ArgumentError, "boundary not found: #{boundary_key}"         unless boundary
          raise ArgumentError, "boundary must be closed before settlement"   unless boundary.status == :closed
          raise ArgumentError, "boundary already settled"                    if boundary.settled?

          output       = boundary.output_value
          slots        = output[:available_slots] || []
          blocked      = output[:blocked_intervals] || []
          avail_secs   = output[:available_seconds].to_f
          blocked_secs = blocked.sum { |b| b[:end].to_f - b[:start].to_f }

          # Transform 1: availability summary
          summary_fact = @store.write(
            store:    :ledger_boundary_summaries,
            key:      boundary_key,
            value:    {
              "boundary_key"           => boundary_key,
              "summary_type"           => "availability",
              "available_seconds"      => avail_secs.to_i,
              "available_slot_count"   => slots.size,
              "blocked_interval_count" => blocked.size,
              "source_fact_count"      => boundary.source_fact_ids.size,
              "result_hash"            => boundary.result_hash
            },
            producer: PRODUCER
          )

          # Transform 2: capacity metrics (capacity_percent uses full 24h day as denominator)
          metrics_fact = @store.write(
            store:    :ledger_boundary_metrics,
            key:      boundary_key,
            value:    {
              "boundary_key"     => boundary_key,
              "capacity_percent" => (avail_secs / (24 * 3600.0) * 100).round(2),
              "available_hours"  => (avail_secs / 3600.0).round(4),
              "blocked_hours"    => (blocked_secs / 3600.0).round(4)
            },
            producer: PRODUCER
          )

          # Per-transform receipts (embedded in settlement receipt)
          transforms = [
            {
              "transform_name"     => "availability_summary",
              "transform_version"  => "1.0",
              "input_boundary_key" => boundary_key,
              "input_result_hash"  => boundary.result_hash,
              "output_fact_id"     => summary_fact.id,
              "status"             => "ok"
            },
            {
              "transform_name"     => "availability_metrics",
              "transform_version"  => "1.0",
              "input_boundary_key" => boundary_key,
              "input_result_hash"  => boundary.result_hash,
              "output_fact_id"     => metrics_fact.id,
              "status"             => "ok"
            }
          ]

          settlement_receipt = @store.write(
            store:    :ledger_settlement_receipts,
            key:      boundary_key,
            value:    {
              "boundary_key"      => boundary_key,
              "settlement_status" => "settled",
              "transform_names"   => transforms.map { |t| t["transform_name"] },
              "output_fact_ids"   => {
                "availability_summary" => summary_fact.id,
                "availability_metrics" => metrics_fact.id
              },
              "result_hash"       => boundary.result_hash,
              "transforms"        => transforms,
              "settled_at"        => Time.now.iso8601(3)
            },
            producer: PRODUCER
          )

          boundary.settle!(settlement_receipt_id: settlement_receipt.id)

          { boundary: boundary, summary_fact: summary_fact,
            metrics_fact: metrics_fact, settlement_receipt: settlement_receipt }
        end

        # Compact a settled boundary: marks detail_status :purged, writes cleanup receipt.
        # Settlement is required before compaction.
        # Returns the compaction receipt fact.
        def compact_boundary(boundary_key)
          boundary = @boundaries[boundary_key]
          raise ArgumentError, "boundary not found: #{boundary_key}"        unless boundary
          raise ArgumentError, "boundary must be closed before compaction"  unless boundary.status == :closed
          raise ArgumentError, "boundary must be settled before compaction" unless boundary.settled?

          compaction_receipt = @store.write(
            store:    :ledger_cleanup_receipts,
            key:      boundary_key,
            value:    {
              "boundary_key"          => boundary_key,
              "output_fact_id"        => boundary.output_fact_id,
              "result_hash"           => boundary.result_hash,
              "source_fact_ids"       => boundary.source_fact_ids,
              "settlement_receipt_id" => boundary.settlement_receipt_id,
              "detail_status_after"   => "purged",
              "compacted_at"          => Time.now.iso8601(3)
            },
            producer: PRODUCER
          )

          boundary.compact!(compaction_receipt_id: compaction_receipt.id)
          compaction_receipt
        end

        # Boundary replay: returns closed output without scanning source facts.
        # Works regardless of detail_status (even after compaction).
        #
        # Returns:
        #   { status: :ok, fidelity: :boundary, output:, boundary_id:, result_hash:, detail_status: }
        #   { status: :open,      boundary_key: }  — if boundary is still open
        #   { status: :not_found, boundary_key: }  — if boundary unknown
        def replay(boundary_key)
          boundary = @boundaries[boundary_key]
          return { status: :not_found, boundary_key: boundary_key } unless boundary
          return { status: :open,      boundary_key: boundary_key } unless boundary.closed?

          {
            status:        :ok,
            fidelity:      :boundary,
            output:        boundary.output_value,
            boundary_id:   boundary_key,
            result_hash:   boundary.result_hash,
            detail_status: boundary.detail_status
          }
        end

        # Full replay: uses all internal source facts.
        # After compaction returns :detail_unavailable.
        #
        # Returns:
        #   { status: :ok, fidelity: :full, output:, boundary_id:, detail_status: }
        #   { status: :detail_unavailable, boundary_id:, detail_status: :purged, boundary_receipt_id: }
        def full_replay(company_id:, technician_id:, date:, horizon_days: 1)
          boundary_key = LedgerBoundary.key_for(
            company_id:    company_id.to_s,
            technician_id: technician_id.to_s,
            date:          date.to_s
          )
          boundary = @boundaries[boundary_key]

          if boundary&.compacted?
            receipt_fact = @store.history(store: :ledger_boundary_receipts, key: boundary_key).last
            return {
              status:              :detail_unavailable,
              boundary_id:         boundary_key,
              detail_status:       :purged,
              boundary_receipt_id: receipt_fact&.id
            }
          end

          result = @ledger.compute_snapshot(
            technician_id: technician_id,
            horizon_start: coerce_date(date),
            horizon_days:  horizon_days
          )
          {
            status:        :ok,
            fidelity:      :full,
            output:        result[:snapshot_fact].value,
            boundary_id:   boundary_key,
            detail_status: boundary&.detail_status || :full
          }
        end

        # Returns a cleanup plan for a given store and time cutoff.
        #
        # :blocked — open boundaries, or closed-but-unsettled boundaries, in the window
        # :ready   — all required boundaries are settled; receipts listed for retention
        #
        # blocking_reasons maps each blocking boundary_key to its reason:
        #   :open                — boundary is still open
        #   :settlement_required — boundary is closed but not yet settled
        def cleanup_plan(store:, before:, fidelity: :boundary)
          in_window         = @boundaries.values.select { |b| boundary_date_before?(b, before) }
          open_blocking     = in_window.select(&:open?)
          unsettled_blocking = in_window.select { |b| b.status == :closed && !b.settled? }
          all_blocking      = open_blocking + unsettled_blocking

          if all_blocking.empty?
            receipts = @boundaries.values.filter_map do |b|
              next unless b.closed?
              @store.history(store: :ledger_boundary_receipts, key: b.boundary_key).last&.id
            end
            {
              status:                     :ready,
              store:                      store,
              before:                     before.iso8601,
              blocking_boundaries:        [],
              required_boundary_policies: [LedgerBoundary::POLICY_NAME.to_sym],
              receipts_to_keep:           receipts,
              expected_detail_status:     fidelity == :boundary ? :purged : :full
            }
          else
            blocking_reasons = {}
            open_blocking.each     { |b| blocking_reasons[b.boundary_key] = :open }
            unsettled_blocking.each { |b| blocking_reasons[b.boundary_key] = :settlement_required }
            {
              status:                     :blocked,
              store:                      store,
              before:                     before.iso8601,
              blocking_boundaries:        all_blocking.map(&:boundary_key),
              blocking_reasons:           blocking_reasons,
              required_boundary_policies: [LedgerBoundary::POLICY_NAME.to_sym]
            }
          end
        end

        # Rebuilds the in-memory boundary registry from persisted store facts.
        #
        # Reads :ledger_boundaries, :ledger_boundary_receipts,
        # :ledger_settlement_receipts, and :ledger_cleanup_receipts to restore
        # boundary state. Recovers output_value by scanning :availability_snapshots
        # for the fact referenced by output_fact_id (linear scan — acceptable for proof).
        #
        # Idempotent: boundaries already in the registry are skipped.
        # Incomplete records (missing closure receipt) are skipped with a warning.
        #
        # Returns:
        #   { status: :ok, hydrated_count:, skipped_count:, warnings: [] }
        def hydrate_boundaries
          hydrated = 0
          skipped  = 0
          warnings = []

          @store.history(store: :ledger_boundaries)
            .group_by(&:key)
            .each do |bk, facts|
              next if @boundaries.key?(bk)

              br = facts.max_by(&:transaction_time).value

              closure_facts = @store.history(store: :ledger_boundary_receipts, key: bk)
              if closure_facts.empty?
                skipped  += 1
                warnings << "boundary #{bk}: closure receipt missing, skipped"
                next
              end

              settlement_facts      = @store.history(store: :ledger_settlement_receipts, key: bk)
              settlement_receipt_id = settlement_facts.empty? ? nil : settlement_facts.last.id

              cleanup_facts         = @store.history(store: :ledger_cleanup_receipts, key: bk)
              cleanup_receipt       = cleanup_facts.last
              compaction_receipt_id = cleanup_receipt&.id
              compacted_at          = cleanup_receipt \
                ? safe_parse_time(cleanup_receipt.value[:compacted_at]) : nil

              output_value = find_snapshot_value(br[:output_fact_id])

              boundary = LedgerBoundary.from_persisted(
                boundary_record:       br,
                output_value:          output_value,
                settlement_receipt_id: settlement_receipt_id,
                compaction_receipt_id: compaction_receipt_id,
                compacted_at:          compacted_at
              )

              @boundaries[bk] = boundary
              hydrated += 1
            end

          { status: :ok, hydrated_count: hydrated, skipped_count: skipped, warnings: warnings }
        end

        # Records a late fact for a closed boundary without mutating the original.
        # The original result_hash and settlement outputs remain unchanged.
        # Records boundary_status_at_arrival and settlement_status_at_arrival so
        # callers can see whether the boundary was settled or compacted at the time.
        # Returns the late-fact receipt.
        def write_late_fact(boundary_key:, fact_value:, fact_type:)
          boundary = @boundaries[boundary_key]
          raise ArgumentError, "boundary not found: #{boundary_key}" unless boundary
          raise ArgumentError, "boundary is not closed" unless boundary.closed?

          @store.write(
            store:    :late_fact_receipts,
            key:      "late/#{boundary_key}/#{SecureRandom.hex(8)}",
            value:    {
              "boundary_key"                  => boundary_key,
              "fact_type"                     => fact_type.to_s,
              "fact_value"                    => fact_value,
              "original_result_hash"          => boundary.result_hash,
              "boundary_status_at_arrival"    => boundary.status.to_s,
              "settlement_status_at_arrival"  => boundary.settlement_status.to_s,
              "recorded_at"                   => Time.now.iso8601(3),
              "disposition"                   => "correction_boundary"
            },
            producer: PRODUCER
          )
        end

        private

        def find_or_open_boundary(company_id:, technician_id:, date:)
          key = LedgerBoundary.key_for(
            company_id:    company_id.to_s,
            technician_id: technician_id.to_s,
            date:          date.to_s
          )
          @boundaries[key] || open_boundary(company_id: company_id, technician_id: technician_id, date: date)
        end

        def build_subject(company_id, technician_id, date)
          { company_id: company_id.to_s, technician_id: technician_id.to_s, date: date.to_s }
        end

        def coerce_date(date)
          date.is_a?(Date) ? date : Date.parse(date.to_s)
        end

        def boundary_date_before?(boundary, before)
          d = Date.parse(boundary.subject[:date].to_s)
          Time.utc(d.year, d.month, d.day) < before
        rescue ArgumentError
          false
        end

        # Scans :availability_snapshots for a fact whose id matches +fact_id+.
        # Returns the fact's value (symbol-keyed hash) or nil if not found.
        def find_snapshot_value(fact_id)
          return nil unless fact_id
          @store.history(store: :availability_snapshots).find { |f| f.id == fact_id }&.value
        end

        def safe_parse_time(val)
          val ? Time.parse(val.to_s) : nil
        rescue ArgumentError, TypeError
          nil
        end

        def boundary_record_value(boundary)
          {
            "boundary_key"    => boundary.boundary_key,
            "policy_name"     => LedgerBoundary::POLICY_NAME,
            "subject"         => boundary.subject.transform_keys(&:to_s),
            "status"          => boundary.status.to_s,
            "output_fact_id"  => boundary.output_fact_id,
            "receipt_fact_id" => boundary.receipt_fact_id,
            "result_hash"     => boundary.result_hash,
            "source_fact_ids" => boundary.source_fact_ids,
            "detail_status"   => boundary.detail_status.to_s,
            "closed_at"       => boundary.closed_at&.iso8601(3),
            "rule_version"    => LedgerBoundary::RULE_VERSION
          }
        end
      end
    end
  end
end
