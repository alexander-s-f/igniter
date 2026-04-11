# frozen_string_literal: true

module Igniter
  class Tool
    # Shared discovery DSL included by both +Igniter::Tool+ and +Igniter::Skill+.
    #
    # Provides: +description+, +param+, +requires_capability+, +tool_name+,
    # +to_schema+, and the instance-side +call_with_capability_check!+.
    #
    # Classes that include this module must call +copy_discoverable_state_to(subclass)+
    # inside their own +inherited+ hook so the metadata propagates to subclasses.
    module Discoverable
      # Ruby type → JSON Schema type string
      JSON_TYPES = {
        string: "string", str: "string",
        integer: "integer", int: "integer",
        float: "number", number: "number",
        boolean: "boolean", bool: "boolean",
        array: "array",
        object: "object",
      }.freeze

      def self.included(base)
        base.extend(ClassMethods)
        base.instance_variable_set(:@tool_params, [])
        base.instance_variable_set(:@required_capabilities, [].freeze)
      end

      # ── Class-level DSL ────────────────────────────────────────────────────
      module ClassMethods
        # Describe what the tool/skill does. Sent to the LLM as part of its schema.
        def description(text = nil)
          text ? (@tool_description = text.freeze) : @tool_description
        end

        # Declare an LLM-visible input parameter.
        #
        # @param name     [Symbol]  parameter name (keyword arg in #call)
        # @param type     [Symbol]  :string, :integer, :float, :boolean, :array, :object
        # @param required [Boolean] whether the LLM must supply this value
        # @param default  [Object]  informational default (not enforced at call-time)
        # @param desc     [String]  short description for the LLM
        def param(name, type:, required: false, default: nil, desc: nil)
          tool_params << {
            name:     name.to_sym,
            type:     type.to_sym,
            required: required,
            default:  default,
            desc:     desc.to_s,
          }.freeze
        end

        # Declare capabilities the calling agent must have before this tool/skill
        # is allowed to run. +CapabilityError+ is raised before +#call+ if any
        # required capability is missing from the agent's +declared_capabilities+.
        def requires_capability(*caps)
          @required_capabilities = caps.flatten.map(&:to_sym).freeze
        end

        # ── Read-only accessors ──────────────────────────────────────────────

        def tool_params
          @tool_params ||= []
        end

        def required_capabilities
          @required_capabilities || [].freeze
        end

        # Snake-case name derived from the class name (last namespace component).
        #
        #   class SearchWebTool < Igniter::Tool  →  "search_web_tool"
        #   class ResearchSkill < Igniter::Skill →  "research_skill"
        def tool_name
          n = name.to_s.split("::").last
          return "anonymous" if n.nil? || n.empty?

          n.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .downcase
        end

        # Generate a tool schema for the given provider.
        # With no argument returns the provider-agnostic intermediate format
        # (used internally and processed by each provider's +normalize_tools+).
        #
        # @param provider [Symbol, nil] :anthropic, :openai, or nil for intermediate
        # @return [Hash]
        def to_schema(provider = nil)
          case provider&.to_sym
          when :anthropic
            { name: tool_name, description: description.to_s, input_schema: json_schema }
          when :openai
            {
              type: "function",
              function: { name: tool_name, description: description.to_s, parameters: json_schema },
            }
          else
            { name: tool_name, description: description.to_s, parameters: json_schema }
          end
        end

        # Call this in +inherited+ to propagate discoverable metadata to subclasses.
        # Each class using this module is responsible for calling this in its own
        # +inherited+ hook (alongside any chain-specific super calls).
        def copy_discoverable_state_to(subclass)
          subclass.instance_variable_set(:@tool_params, @tool_params&.dup || [])
          subclass.instance_variable_set(:@required_capabilities, @required_capabilities&.dup || [].freeze)
          subclass.instance_variable_set(:@tool_description, @tool_description)
        end

        private

        def json_schema
          required_names = tool_params.select { |p| p[:required] }.map { |p| p[:name].to_s }
          properties = tool_params.each_with_object({}) do |p, h|
            prop = { "type" => JSON_TYPES.fetch(p[:type], "string") }
            prop["description"] = p[:desc] unless p[:desc].empty?
            prop["default"] = p[:default] unless p[:default].nil?
            h[p[:name].to_s] = prop
          end

          schema = { "type" => "object", "properties" => properties }
          schema["required"] = required_names unless required_names.empty?
          schema
        end
      end

      # ── Instance — capability-guarded call ──────────────────────────────────

      # Verify the agent has all required capabilities, then invoke +#call+.
      # Called by +LLM::Executor+ during the tool-use loop for every tool/skill invocation.
      #
      # @param allowed_capabilities [Array<Symbol>] capabilities the calling agent has
      # @raise [Igniter::Tool::CapabilityError] if a required capability is missing
      def call_with_capability_check!(allowed_capabilities:, **kwargs)
        required = self.class.required_capabilities
        unless required.empty?
          allowed = allowed_capabilities.map(&:to_sym)
          missing = required.reject { |c| allowed.include?(c) }
          unless missing.empty?
            raise Igniter::Tool::CapabilityError,
                  "Tool #{self.class.tool_name.inspect} requires capabilities " \
                  "#{missing.inspect} but agent only has #{allowed.inspect}"
          end
        end
        call(**kwargs)
      end
    end
  end
end
