# frozen_string_literal: true

module Igniter
  module SchemaRendering
    class SubmissionProcessor
      class << self
        def call(schema:, action_id:, submission:)
          new(schema: schema, action_id: action_id, submission: submission).call
        end
      end

      def initialize(schema:, action_id:, submission:)
        @schema = schema.is_a?(Schema) ? schema : Schema.load(schema)
        @action_id = action_id.to_s
        @submission = submission
      end

      def call
        action = schema.action(action_id)
        raise ArgumentError, "unknown schema action: #{action_id}" unless action.is_a?(Hash)

        case action["type"].to_s
        when "", "store_submission"
          { "ok" => true, "type" => "store_submission" }
        when "contract"
          execute_contract(action)
        else
          raise ArgumentError, "unsupported schema action type: #{action["type"]}"
        end
      end

      private

      attr_reader :schema, :action_id, :submission

      def execute_contract(action)
        contract_class = Object.const_get(action.fetch("target"))
        inputs = build_inputs(action.fetch("input_mapping", {}))
        contract = contract_class.new(inputs).resolve

        {
          "ok" => contract.success?,
          "type" => "contract",
          "target" => action.fetch("target"),
          "outputs" => present_outputs(contract)
        }
      end

      def build_inputs(mapping)
        mapping.each_with_object({}) do |(target_path, source_ref), memo|
          assign_path!(memo, target_path.to_s, resolve_source(source_ref))
        end
      end

      def resolve_source(source_ref)
        ref = source_ref.to_s
        case ref
        when "$view.id"
          schema.id
        when "$view.version"
          schema.version
        when "$submission.id"
          submission.fetch("id")
        when "$submission.action_id"
          submission.fetch("action_id")
        else
          submission.fetch("normalized_payload").fetch(ref, nil)
        end
      end

      def assign_path!(memo, path, value)
        keys = path.split(".")
        leaf = keys.pop
        cursor = memo
        keys.each do |key|
          cursor[key] ||= {}
          cursor = cursor[key]
        end
        cursor[leaf] = value
      end

      def present_outputs(contract)
        result = contract.result
        outputs = contract.class.compiled_graph.outputs.map(&:name)
        outputs.each_with_object({}) do |output_name, memo|
          memo[output_name.to_s] = result.public_send(output_name)
        end
      end
    end
  end
end
