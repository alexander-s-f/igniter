# frozen_string_literal: true

module Igniter
  module Differential
    # Executes two contract classes with identical inputs and builds a Report.
    #
    # Uses Thread.current[:igniter_skip_shadow] to prevent recursive shadow
    # execution when a contract with shadow_with is run inside the runner.
    class Runner
      def initialize(primary_class, candidate_class, tolerance: nil)
        @primary_class = primary_class
        @candidate_class = candidate_class
        @tolerance = tolerance
      end

      # Execute both contracts fresh from +inputs+ and compare outputs.
      def run(inputs)
        primary_exec, primary_error = execute(@primary_class, inputs)
        candidate_exec, candidate_error = execute(@candidate_class, inputs)

        primary_outputs = primary_exec ? extract_outputs(primary_exec) : {}
        candidate_outputs = candidate_exec ? extract_outputs(candidate_exec) : {}

        build_report(primary_outputs, candidate_outputs, inputs, primary_error, candidate_error)
      end

      # Compare using an already-resolved primary execution (avoids re-running
      # the primary contract and its side effects a second time).
      def run_with_primary_execution(primary_execution, inputs)
        primary_outputs = extract_outputs(primary_execution)
        candidate_exec, candidate_error = execute(@candidate_class, inputs)
        candidate_outputs = candidate_exec ? extract_outputs(candidate_exec) : {}

        build_report(primary_outputs, candidate_outputs, inputs, nil, candidate_error)
      end

      private

      # Execute +klass+ with +inputs+, suppressing shadow execution to prevent
      # recursive comparisons.  Returns [execution, nil] on success or
      # [nil, error] if the contract raises.
      def execute(klass, inputs)
        Thread.current[:igniter_skip_shadow] = true
        contract = klass.new(inputs)
        contract.resolve_all
        [contract.execution, nil]
      rescue Igniter::Error => e
        [nil, e]
      ensure
        Thread.current[:igniter_skip_shadow] = nil
      end

      # Read all output values from a resolved execution's cache.
      # Output nodes live in graph.outputs (not graph.nodes).
      # Each output node's source_root (Symbol) names the computation node in cache.
      def extract_outputs(execution)
        graph = execution.compiled_graph
        cache = execution.cache

        graph.outputs.each_with_object({}) do |node, acc|
          state = cache.fetch(node.source_root)
          acc[node.name] = normalize_value(state&.value)
        end
      end

      # Flatten Runtime wrapper objects to plain Ruby values so that structural
      # equality works across independently-resolved executions.
      def normalize_value(val)
        case val
        when Runtime::Result           then val.to_h
        when Runtime::CollectionResult then val.summary
        when Runtime::DeferredResult   then { pending: true, event: val.waiting_on }
        else val
        end
      end

      def build_report(primary_outputs, candidate_outputs, inputs, primary_error, candidate_error) # rubocop:disable Metrics/MethodLength
        common = primary_outputs.keys & candidate_outputs.keys
        divergences = compare_common(primary_outputs, candidate_outputs, common)
        primary_only = slice_missing(primary_outputs, candidate_outputs)
        candidate_only = slice_missing(candidate_outputs, primary_outputs)

        Report.new(
          primary_class: @primary_class,
          candidate_class: @candidate_class,
          inputs: inputs,
          divergences: divergences,
          primary_only: primary_only,
          candidate_only: candidate_only,
          primary_error: primary_error,
          candidate_error: candidate_error
        )
      end

      # Build Divergence objects for keys present in both hashes but with
      # differing values.
      def compare_common(primary, candidate, keys) # rubocop:disable Metrics/MethodLength
        keys.filter_map do |key|
          pval = primary[key]
          cval = candidate[key]
          next if values_match?(pval, cval)

          Divergence.new(
            output_name: key,
            primary_value: pval,
            candidate_value: cval,
            kind: divergence_kind(pval, cval)
          )
        end
      end

      # Returns a hash of keys that exist in +source+ but are absent in +other+.
      def slice_missing(source, other)
        (source.keys - other.keys).each_with_object({}) { |k, h| h[k] = source[k] }
      end

      def values_match?(lhs, rhs)
        return true if lhs == rhs
        return false unless @tolerance
        return false unless lhs.is_a?(Numeric) && rhs.is_a?(Numeric)

        (lhs - rhs).abs <= @tolerance
      end

      def divergence_kind(lhs, rhs)
        lhs.instance_of?(rhs.class) ? :value_mismatch : :type_mismatch
      end
    end
  end
end
