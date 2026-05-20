# frozen_string_literal: true

require "digest"

class AvailabilitySlotMapPrimary
  def self.call(company_ref:, service_area_ref:, trade_ref:, window_ref:, request_ref: nil, **)
    seed = [company_ref, service_area_ref, trade_ref, window_ref].join(":")
    reason_counts = reason_counts_for(seed)
    available_count = 6 - reason_counts.values.sum

    {
      request_ref: request_ref,
      company_ref: company_ref,
      service_area_ref: service_area_ref,
      trade_ref: trade_ref,
      window_ref: window_ref,
      available_count: available_count,
      unavailable_count: reason_counts.values.sum,
      reason_counts: reason_counts,
      input_digest: Digest::SHA256.hexdigest(seed)
    }
  end

  def self.reason_counts_for(seed)
    digest = Digest::SHA256.hexdigest(seed).hex
    {
      outside_hours: digest % 2,
      capacity_held: (digest / 2) % 2,
      no_matching_trade: (digest / 4) % 2
    }.reject { |_reason, count| count.zero? }
  end
end
