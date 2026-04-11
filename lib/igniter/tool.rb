# frozen_string_literal: true

module Igniter
  # Base class for AI-callable tools.
  #
  # Extends Igniter::Executor with declarative metadata for LLM function-calling
  # APIs (Anthropic, OpenAI) and capability-based access guards.
  #
  # == Defining a tool
  #
  #   class SearchWeb < Igniter::Tool
  #     description "Search the internet for current information"
  #
  #     param :query,       type: :string,  required: true,  desc: "The search query"
  #     param :max_results, type: :integer, default: 5,      desc: "Max results to return"
  #
  #     requires_capability :web_access
  #
  #     def call(query:, max_results: 5)
  #       [{ title: "...", url: "...", snippet: "..." }]
  #     end
  #   end
  #
  # == Schema generation
  #
  #   SearchWeb.tool_name          # => "search_web"
  #   SearchWeb.to_schema          # => { name:, description:, parameters: { ... } }
  #   SearchWeb.to_schema(:anthropic) # => { name:, description:, input_schema: { ... } }
  #   SearchWeb.to_schema(:openai)    # => { type: "function", function: { ... } }
  #
  # == Compatibility
  #
  # Tool inherits Igniter::Executor — it can be used as a compute node in any
  # Igniter::Contract graph alongside other executors.
  class Tool < Executor
    # Raised when a tool requires a capability the calling agent does not have.
    class CapabilityError < Igniter::Error; end

    # ── Type mappings ──────────────────────────────────────────────────────────

    JSON_TYPES = {
      string: "string", str: "string",
      integer: "integer", int: "integer",
      float: "number", number: "number",
      boolean: "boolean", bool: "boolean",
      array: "array",
      object: "object",
    }.freeze

    class << self
      # ── DSL ─────────────────────────────────────────────────────────────────

      # Describe what the tool does. Sent to the LLM as part of the tool schema.
      def description(text = nil)
        text ? (@tool_description = text.freeze) : @tool_description
      end

      # Declare an input parameter.
      #
      # @param name     [Symbol]  parameter name (used as keyword arg in #call)
      # @param type     [Symbol]  :string, :integer, :float, :boolean, :array, :object
      # @param required [Boolean] whether the LLM must supply this parameter
      # @param default  [Object]  default value (informational — not enforced at call time)
      # @param desc     [String]  parameter description for the LLM
      def param(name, type:, required: false, default: nil, desc: nil)
        tool_params << {
          name:     name.to_sym,
          type:     type.to_sym,
          required: required,
          default:  default,
          desc:     desc.to_s,
        }.freeze
      end

      # Declare capabilities required to call this tool.
      # The LLM executor's +declared_capabilities+ must include all listed caps;
      # otherwise +CapabilityError+ is raised before #call is invoked.
      def requires_capability(*caps)
        @required_capabilities = caps.flatten.map(&:to_sym).freeze
      end

      # Read-only accessors ──────────────────────────────────────────────────

      def tool_params
        @tool_params ||= []
      end

      def required_capabilities
        @required_capabilities || [].freeze
      end

      # Snake-case tool name derived from the class name.
      # Used as the +name+ field in LLM tool schemas.
      #
      #   class SearchWebTool < Igniter::Tool  →  "search_web_tool"
      def tool_name
        n = name.to_s.split("::").last
        n.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
         .downcase
      end

      # Generate a tool schema for the given provider.
      # With no argument returns the provider-agnostic intermediate format used
      # internally by Igniter (processed by each provider's +normalize_tools+).
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
          # Intermediate format — passed through normalize_tools in each provider
          { name: tool_name, description: description.to_s, parameters: json_schema }
        end
      end

      # ── Inheritance ──────────────────────────────────────────────────────────

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@tool_params, [])
        subclass.instance_variable_set(:@required_capabilities, [].freeze)
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

    # Verify capabilities, then call the tool.
    # Called by LLM::Executor during the tool-use loop.
    #
    # @param allowed_capabilities [Array<Symbol>]
    # @raise [CapabilityError] if a required capability is missing
    def call_with_capability_check!(allowed_capabilities:, **kwargs)
      required = self.class.required_capabilities
      unless required.empty?
        allowed = allowed_capabilities.map(&:to_sym)
        missing = required.reject { |c| allowed.include?(c) }
        unless missing.empty?
          raise CapabilityError,
                "Tool #{self.class.tool_name.inspect} requires capabilities " \
                "#{missing.inspect} but agent only has #{allowed.inspect}"
        end
      end
      call(**kwargs)
    end
  end
end
