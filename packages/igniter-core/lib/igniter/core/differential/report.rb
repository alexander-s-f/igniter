# frozen_string_literal: true

module Igniter
  module Differential
    # Structured result of comparing two contract implementations.
    #
    # Attributes:
    #   primary_class    — the reference contract class
    #   candidate_class  — the contract being validated against the primary
    #   inputs           — Hash of inputs used for both executions
    #   divergences      — Array<Divergence> for outputs that differ in value
    #   primary_only     — Hash{ Symbol => value } outputs absent in candidate
    #   candidate_only   — Hash{ Symbol => value } outputs absent in primary
    #   primary_error    — Igniter::Error raised by primary (usually nil)
    #   candidate_error  — Igniter::Error raised by candidate (nil on success)
    class Report
      attr_reader :primary_class, :candidate_class, :inputs,
                  :divergences, :primary_only, :candidate_only,
                  :primary_error, :candidate_error

      def initialize( # rubocop:disable Metrics/ParameterLists
        primary_class:, candidate_class:, inputs:,
        divergences:, primary_only:, candidate_only:,
        primary_error: nil, candidate_error: nil
      )
        @primary_class = primary_class
        @candidate_class = candidate_class
        @inputs = inputs
        @divergences = divergences.freeze
        @primary_only = primary_only.freeze
        @candidate_only = candidate_only.freeze
        @primary_error = primary_error
        @candidate_error = candidate_error
        freeze
      end

      # True when candidate produces identical outputs with no errors.
      def match?
        divergences.empty? &&
          primary_only.empty? &&
          candidate_only.empty? &&
          primary_error.nil? &&
          candidate_error.nil?
      end

      # One-line summary suitable for logging.
      def summary # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        if match?
          "match"
        else
          parts = []
          parts << "#{divergences.size} value(s) differ" if divergences.any?
          parts << "#{primary_only.size} output(s) only in primary" if primary_only.any?
          parts << "#{candidate_only.size} output(s) only in candidate" if candidate_only.any?
          parts << "candidate error: #{candidate_error.message}" if candidate_error
          parts << "primary error: #{primary_error.message}" if primary_error
          "diverged — #{parts.join(", ")}"
        end
      end

      # Human-readable ASCII report.
      def explain
        Formatter.format(self)
      end

      alias to_s explain

      # Structured (serialisable) representation.
      def to_h # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        {
          primary: primary_class.name,
          candidate: candidate_class.name,
          match: match?,
          divergences: divergences.map do |d|
            { output: d.output_name, primary: d.primary_value, candidate: d.candidate_value,
              kind: d.kind, delta: d.delta }
          end,
          primary_only: primary_only,
          candidate_only: candidate_only,
          primary_error: primary_error&.message,
          candidate_error: candidate_error&.message
        }
      end
    end
  end
end
