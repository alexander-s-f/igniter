# frozen_string_literal: true

require "json"

module Igniter
  module Server
    module Handlers
      class Base
        def initialize(registry, store)
          @registry = registry
          @store    = store
        end

        def call(params:, body:)
          handle(params: params, body: body)
        rescue Igniter::Server::Registry::RegistryError => e
          json_error(e.message, status: 404)
        rescue Igniter::Error => e
          json_error(e.message, status: 422)
        rescue StandardError => e
          json_error("Internal server error: #{e.message}", status: 500)
        end

        private

        def handle(params:, body:)
          raise NotImplementedError, "#{self.class}#handle must be implemented"
        end

        def json_ok(data)
          { status: 200, body: JSON.generate(data), headers: json_ct }
        end

        def json_error(message, status: 422)
          { status: status, body: JSON.generate({ error: message }), headers: json_ct }
        end

        def json_ct
          { "Content-Type" => "application/json" }
        end

        # Serialize a contract execution result into the standard API response hash.
        # Reads the cache directly to avoid calling contract.pending?/failed? which
        # internally re-invoke resolve_all and would re-raise on failed nodes.
        def serialize_execution(contract, contract_class) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          execution_id = contract.execution.events.execution_id
          cache_values = contract.execution.cache.values

          if cache_values.any?(&:pending?)
            pending_nodes = cache_values.select(&:pending?)
            waiting_for   = pending_nodes.filter_map { |s| s.value.payload[:event]&.to_s }
            { execution_id: execution_id, status: "pending", waiting_for: waiting_for }
          elsif cache_values.any?(&:failed?)
            error_state = cache_values.find(&:failed?)
            { execution_id: execution_id, status: "failed",
              error: serialize_error(error_state&.error) }
          else
            outputs = serialize_outputs(contract, contract_class)
            { execution_id: execution_id, status: "succeeded", outputs: outputs }
          end
        end

        def serialize_outputs(contract, contract_class)
          contract_class.compiled_graph.outputs.each_with_object({}) do |output, memo|
            memo[output.name] = to_json_value(contract.result.public_send(output.name))
          rescue StandardError
            nil
          end
        end

        def serialize_error(error)
          return { message: "Unknown error" } unless error

          {
            type: error.class.name,
            message: error.message,
            node: error.context[:node_name]
          }
        end

        # Recursively convert a value into JSON-safe primitives.
        def to_json_value(value) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
          case value
          when Hash
            value.each_with_object({}) { |(k, v), h| h[k.to_s] = to_json_value(v) }
          when Array
            value.map { |v| to_json_value(v) }
          when String, Integer, Float, TrueClass, FalseClass, NilClass
            value
          when Symbol
            value.to_s
          else
            value.respond_to?(:to_h) ? to_json_value(value.to_h) : value.to_s
          end
        end

        def symbolize_inputs(hash)
          return {} unless hash.is_a?(Hash)

          hash.each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v }
        end
      end
    end
  end
end
