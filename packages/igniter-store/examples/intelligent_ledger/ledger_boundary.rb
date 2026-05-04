# frozen_string_literal: true

require "digest"
require "time"

module Igniter
  module Store
    module IntelligentLedger
      # A closed semantic boundary over facts for a technician availability day.
      #
      # Lifecycle: open -> closed -> settled -> compacted
      #
      # Once closed, result_hash and output_fact_id are immutable. Settlement
      # materialises useful long-lived memory (summary, metrics, receipt) before
      # compaction. Compaction requires settlement first, then marks internal
      # detail as purged while preserving output and result_hash.
      class LedgerBoundary
        POLICY_NAME  = "technician_day"
        RULE_VERSION = "1.0"

        attr_reader :boundary_key, :subject, :status, :result_hash,
                    :source_fact_ids, :output_fact_id, :output_value,
                    :receipt_fact_id, :detail_status, :closed_at,
                    :compacted_at, :compaction_receipt_id,
                    :settlement_status, :settlement_receipt_id

        def initialize(subject:, rule_version: RULE_VERSION)
          @subject       = subject.freeze
          @rule_version  = rule_version
          @boundary_key  = build_boundary_key
          @status        = :open
          @detail_status = :full
          @source_fact_ids       = [].freeze
          @output_fact_id        = nil
          @output_value          = nil
          @receipt_fact_id       = nil
          @result_hash           = nil
          @closed_at             = nil
          @compacted_at          = nil
          @compaction_receipt_id = nil
          @settlement_status     = :unsettled
          @settlement_receipt_id = nil
        end

        def id = @boundary_key

        def open?      = @status == :open
        def closed?    = @status == :closed || @status == :compacted
        def compacted? = @status == :compacted
        def settled?   = @settlement_status == :settled

        # Transitions open -> closed.
        # output_fact, receipt_fact, result_hash are immutable after this point.
        def close!(output_fact:, receipt_fact:, source_fact_ids:)
          raise "boundary already closed" unless @status == :open

          @output_fact_id  = output_fact.id
          @output_value    = output_fact.value
          @receipt_fact_id = receipt_fact.id
          @source_fact_ids = source_fact_ids.uniq.freeze
          @result_hash     = compute_result_hash(@output_value, @source_fact_ids)
          @status          = :closed
          @closed_at       = Time.now
        end

        # Transitions settlement_status: :unsettled -> :settled.
        # Boundary must be closed first. settlement_receipt_id is immutable after this.
        def settle!(settlement_receipt_id:)
          raise "boundary must be closed before settlement" unless @status == :closed
          raise "boundary already settled"                  if @settlement_status == :settled

          @settlement_receipt_id = settlement_receipt_id
          @settlement_status     = :settled
        end

        # Transitions closed -> compacted.
        # Requires settlement first. Internal detail is marked purged;
        # output, result_hash, and settlement outputs remain intact.
        def compact!(compaction_receipt_id:)
          raise "boundary must be closed before compaction"   unless @status == :closed
          raise "boundary must be settled before compaction"  unless @settlement_status == :settled

          @compaction_receipt_id = compaction_receipt_id
          @detail_status         = :purged
          @status                = :compacted
          @compacted_at          = Time.now
        end

        # Returns a class-level deterministic key without instantiating a full boundary.
        def self.key_for(company_id:, technician_id:, date:, rule_version: RULE_VERSION)
          "#{POLICY_NAME}/company=#{company_id}/technician=#{technician_id}/date=#{date}/version=#{rule_version}"
        end

        private

        def build_boundary_key
          s = @subject
          self.class.key_for(
            company_id:    s[:company_id],
            technician_id: s[:technician_id],
            date:          s[:date],
            rule_version:  @rule_version
          )
        end

        def compute_result_hash(output_value, source_fact_ids)
          content = output_value.to_s + source_fact_ids.sort.join(",") + @rule_version
          Digest::SHA256.hexdigest(content)
        end
      end
    end
  end
end
