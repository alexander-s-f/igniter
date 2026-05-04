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
      # closure/compaction receipts to the store.
      #
      # Additional store layout:
      #   :ledger_boundaries         — key: boundary_key
      #   :ledger_boundary_receipts  — key: boundary_key
      #   :ledger_cleanup_receipts   — key: boundary_key
      #   :late_fact_receipts        — key: "late/<boundary_key>/<token>"
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

        # Compact a closed boundary: marks detail_status :purged, writes cleanup receipt.
        # Returns the compaction receipt fact.
        def compact_boundary(boundary_key)
          boundary = @boundaries[boundary_key]
          raise ArgumentError, "boundary not found: #{boundary_key}" unless boundary
          raise ArgumentError, "boundary must be closed before compaction" unless boundary.status == :closed

          compaction_receipt = @store.write(
            store:    :ledger_cleanup_receipts,
            key:      boundary_key,
            value:    {
              "boundary_key"        => boundary_key,
              "output_fact_id"      => boundary.output_fact_id,
              "result_hash"         => boundary.result_hash,
              "source_fact_ids"     => boundary.source_fact_ids,
              "detail_status_after" => "purged",
              "compacted_at"        => Time.now.iso8601(3)
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
        # :blocked — one or more open boundaries cover facts before +before+
        # :ready   — all required boundaries are closed; receipts listed for retention
        def cleanup_plan(store:, before:, fidelity: :boundary)
          blocking = @boundaries.values.select { |b| b.open? && boundary_date_before?(b, before) }

          if blocking.empty?
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
            {
              status:                     :blocked,
              store:                      store,
              before:                     before.iso8601,
              blocking_boundaries:        blocking.map(&:boundary_key),
              required_boundary_policies: [LedgerBoundary::POLICY_NAME.to_sym]
            }
          end
        end

        # Records a late fact for a closed boundary without mutating the original.
        # The original result_hash remains unchanged.
        # Returns the late-fact receipt.
        def write_late_fact(boundary_key:, fact_value:, fact_type:)
          boundary = @boundaries[boundary_key]
          raise ArgumentError, "boundary not found: #{boundary_key}" unless boundary
          raise ArgumentError, "boundary is not closed" unless boundary.closed?

          @store.write(
            store:    :late_fact_receipts,
            key:      "late/#{boundary_key}/#{SecureRandom.hex(8)}",
            value:    {
              "boundary_key"         => boundary_key,
              "fact_type"            => fact_type.to_s,
              "fact_value"           => fact_value,
              "original_result_hash" => boundary.result_hash,
              "recorded_at"          => Time.now.iso8601(3),
              "disposition"          => "correction_boundary"
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
