# frozen_string_literal: true

require "digest"
require "json"

class AvailabilitySlotMapNormalizer
  def self.call(result)
    summary = {
      available_count: result.fetch(:available_count),
      unavailable_count: result.fetch(:unavailable_count),
      reason_codes: result.fetch(:reason_counts).keys.sort,
      reason_counts: result.fetch(:reason_counts),
      window_summary: { window_ref: result.fetch(:window_ref) },
      scope_refs: {
        company_ref: result.fetch(:company_ref),
        service_area_ref: result.fetch(:service_area_ref),
        trade_ref: result.fetch(:trade_ref)
      },
      input_digest: result.fetch(:input_digest)
    }

    {
      status: :ok,
      outputs: summary.merge(output_digest: Digest::SHA256.hexdigest(JSON.generate(summary))),
      metadata: { normalizer: :availability_slot_map_v0 }
    }
  end
end
