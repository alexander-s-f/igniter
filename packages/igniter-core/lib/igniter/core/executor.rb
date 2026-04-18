# frozen_string_literal: true

module Igniter
  class Executor
    class << self
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@executor_inputs, executor_inputs.transform_values(&:dup))
        subclass.instance_variable_set(:@executor_metadata, executor_metadata.dup)
        # capabilities and fingerprint are NOT inherited — each subclass declares its own
      end

      def input(name, required: true, type: nil, **metadata)
        executor_inputs[name.to_sym] = metadata.merge(required: required, type: type).compact
      end

      def executor_inputs
        @executor_inputs ||= {}
      end

      def executor_metadata
        @executor_metadata ||= {}
      end

      def executor_key(value = nil)
        metadata_value(:key, value)
      end

      def label(value = nil)
        metadata_value(:label, value)
      end

      def category(value = nil)
        metadata_value(:category, value)
      end

      def summary(value = nil)
        metadata_value(:summary, value)
      end

      def tags(*values)
        return Array(executor_metadata[:tags]).freeze if values.empty?

        executor_metadata[:tags] = values.flatten.compact.map(&:to_sym).freeze
      end

      def output_schema(value = nil)
        metadata_value(:output_schema, value)
      end

      def call(**dependencies)
        new.call(**dependencies)
      end

      # ─── Capabilities DSL ────────────────────────────────────────────────────
      #
      # Declare what this executor is allowed to do. Capabilities are purely
      # declarative — enforcement requires Igniter::Capabilities::Policy.
      #
      # Known capabilities:
      #   :pure         — deterministic, no side effects; enables content-addressed caching
      #   :network      — makes outbound HTTP/TCP connections
      #   :database     — reads or writes a database
      #   :filesystem   — reads or writes files
      #   :external_api — calls a third-party API
      #   :messaging    — publishes to a message queue or broker
      #   :cache        — reads or writes an external cache
      #
      # Example:
      #   class PaymentExecutor < Igniter::Executor
      #     capabilities :network, :external_api
      #   end
      def capabilities(*caps)
        if caps.empty?
          @declared_capabilities ||= []
        else
          existing = @declared_capabilities || []
          @declared_capabilities = (existing + caps.flatten.map(&:to_sym)).uniq.freeze
        end
      end

      def declared_capabilities
        @declared_capabilities || []
      end

      # Shorthand for `capabilities :pure`.
      # A pure executor is fully deterministic: same inputs → same output, always.
      # Pure executors participate in content-addressed cross-execution caching.
      def pure
        capabilities(:pure)
      end

      def pure?
        declared_capabilities.include?(:pure)
      end

      # ─── Content-addressing fingerprint ──────────────────────────────────────
      #
      # Optional explicit version string used as part of the content-addressing key.
      # Set a new value to invalidate the content cache after changing executor logic
      # while keeping the class name stable.
      #
      #   fingerprint "tax_calculator_v2"
      def fingerprint(value = nil)
        return @content_fingerprint || name || "anonymous_executor" if value.nil?

        @content_fingerprint = value.to_s.freeze
      end

      def content_fingerprint
        @content_fingerprint || name || "anonymous_executor"
      end

      private

      def metadata_value(key, value)
        return executor_metadata[key] if value.nil?

        executor_metadata[key] = value
      end
    end

    attr_reader :execution, :contract

    def initialize(execution: nil, contract: nil)
      @execution = execution
      @contract = contract
    end

    def defer(token: nil, payload: {})
      Runtime::DeferredResult.build(token: token, payload: payload)
    end
  end
end
