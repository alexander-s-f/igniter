# frozen_string_literal: true

module Igniter
  module Differential
    # Renders a Differential::Report as a human-readable text block.
    #
    # Example:
    #
    #   Primary:    PricingV1
    #   Candidate:  PricingV2
    #   Match:      NO
    #
    #   DIVERGENCES (1):
    #     :tax
    #       primary:   15.0
    #       candidate: 22.5
    #       delta:     +7.5
    #
    #   CANDIDATE ONLY (1):
    #     :discount = 10.0
    #
    module Formatter
      VALUE_MAX = 60

      class << self
        def format(report) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          lines = []
          lines << "Primary:    #{report.primary_class.name}"
          lines << "Candidate:  #{report.candidate_class.name}"
          lines << "Match:      #{report.match? ? "YES" : "NO"}"

          if report.primary_error
            lines << ""
            lines << "PRIMARY ERROR: #{report.primary_error.message}"
            return lines.join("\n")
          end

          if report.candidate_error
            lines << ""
            lines << "CANDIDATE ERROR: #{report.candidate_error.message}"
          end

          lines << ""

          if report.divergences.empty? && report.primary_only.empty? && report.candidate_only.empty?
            lines << "All shared outputs match."
          else
            append_divergences(report, lines)
            append_only_section("CANDIDATE ONLY", report.candidate_only, lines)
            append_only_section("PRIMARY ONLY", report.primary_only, lines)
          end

          lines.join("\n")
        end

        private

        def append_divergences(report, lines) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          return if report.divergences.empty?

          lines << "DIVERGENCES (#{report.divergences.size}):"
          report.divergences.each do |div|
            lines << "  :#{div.output_name}"
            lines << "    primary:   #{fmt(div.primary_value)}"
            lines << "    candidate: #{fmt(div.candidate_value)}"
            next unless div.delta

            d = div.delta
            lines << "    delta:     #{d >= 0 ? "+#{d}" : d}"
          end
          lines << ""
        end

        def append_only_section(label, hash, lines)
          return if hash.empty?

          lines << "#{label} (#{hash.size}):"
          hash.each { |name, val| lines << "  :#{name} = #{fmt(val)}" }
          lines << ""
        end

        def fmt(value) # rubocop:disable Metrics/CyclomaticComplexity
          str = case value
                when nil    then "nil"
                when String then value.inspect
                when Symbol then value.inspect
                when Hash   then "{#{value.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")}}"
                when Array  then "[#{value.map(&:inspect).join(", ")}]"
                else             value.inspect
                end
          str.length > VALUE_MAX ? "#{str[0, VALUE_MAX - 3]}..." : str
        end
      end
    end
  end
end
