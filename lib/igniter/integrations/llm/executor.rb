# frozen_string_literal: true

require "json"

module Igniter
  module LLM
    # Raised when the tool-use loop exceeds max_tool_iterations.
    class ToolLoopError < Error; end

    # Base class for LLM-powered compute nodes.
    #
    # Subclass and override #call(**inputs) to build prompts and get completions.
    # Use the #complete and #chat helper methods inside #call.
    #
    # == Simple usage (no tools)
    #
    #   class DocumentSummarizer < Igniter::LLM::Executor
    #     provider :ollama
    #     model "llama3.2"
    #     system_prompt "You are a concise technical writer."
    #
    #     def call(document:)
    #       complete("Summarize this in 3 bullet points:\n\n#{document}")
    #     end
    #   end
    #
    # == With Igniter::Tool classes (auto tool-use loop)
    #
    #   class ResearchAgent < Igniter::LLM::Executor
    #     provider :anthropic
    #     model "claude-sonnet-4-6"
    #     system_prompt "You are a research assistant. Use tools when needed."
    #
    #     tools SearchWeb, WriteFile     # Igniter::Tool subclasses
    #     capabilities :web_access, :filesystem_write
    #     max_tool_iterations 10
    #
    #     def call(question:)
    #       complete(question)
    #       # Auto-loop: LLM → tool_use → capability check → Tool#call → result → LLM
    #     end
    #   end
    class Executor < Igniter::Executor
      class << self
        def provider(name = nil)
          return @provider || Igniter::LLM.config.default_provider if name.nil?

          @provider = name.to_sym
        end

        def model(name = nil)
          return @model || provider_config.default_model if name.nil?

          @model = name
        end

        def system_prompt(text = nil)
          return @system_prompt if text.nil?

          @system_prompt = text
        end

        def temperature(val = nil)
          return @temperature if val.nil?

          @temperature = val
        end

        # Register tools. Accepts Igniter::Tool subclasses (enables auto tool-use
        # loop in #complete) or raw Hash definitions (backward-compatible with
        # the deferred #complete_with_tools pattern).
        def tools(*tool_definitions)
          return @tools || [] if tool_definitions.empty?

          @tools = tool_definitions.flatten
        end

        # Maximum number of tool-use iterations in the auto-loop.
        # Prevents infinite loops when the LLM keeps requesting tools.
        # Ignored when no Tool classes are registered. Default: 10.
        def max_tool_iterations(n = nil)
          n ? (@max_tool_iterations = n.to_i) : (@max_tool_iterations || 10)
        end

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@provider, @provider)
          subclass.instance_variable_set(:@model, @model)
          subclass.instance_variable_set(:@system_prompt, @system_prompt)
          subclass.instance_variable_set(:@temperature, @temperature)
          subclass.instance_variable_set(:@tools, @tools&.dup)
          subclass.instance_variable_set(:@max_tool_iterations, @max_tool_iterations)
        end

        private

        def provider_config
          Igniter::LLM.provider_instance(provider).instance_of?(Class) ? nil : Igniter::LLM.config.provider_config(provider)
        rescue StandardError
          Igniter::LLM.config.ollama
        end
      end

      attr_reader :last_usage, :last_context

      # Subclasses override this method. Use #complete or #chat inside.
      def call(**_inputs)
        raise NotImplementedError, "#{self.class.name}#call must be implemented"
      end

      protected

      # Single-turn completion, or auto tool-use loop when Igniter::Tool subclasses
      # are registered via the +tools+ DSL.
      #
      # Tool-use loop (activated when tools DSL contains Tool subclasses):
      # 1. Send message + tool schemas to LLM API
      # 2. If response has tool_use blocks → check capabilities → execute → append results → repeat
      # 3. When response contains text and no tool_use → return the text
      #
      # @param prompt  [String]
      # @param context [Context, nil]
      # @return [String] final LLM text response
      def complete(prompt, context: nil)
        # Accept both Igniter::Tool and Igniter::Skill subclasses (duck-type check).
        # Using respond_to? avoids a circular require: skill.rb requires this file,
        # so we can't safely reference Igniter::Skill or Igniter::Tool::Discoverable here.
        tool_classes = self.class.tools.select { |t|
          t.is_a?(Class) && t.respond_to?(:tool_name) && t.respond_to?(:to_schema)
        }

        if tool_classes.any?
          run_tool_loop(prompt: prompt, context: context, tool_classes: tool_classes)
        else
          messages = build_messages(prompt: prompt, context: context)
          response = provider_instance.chat(
            messages: messages,
            model: self.class.model,
            **completion_options
          )
          @last_usage = provider_instance.last_usage
          @last_context = track_context(context, prompt, response[:content])
          response[:content]
        end
      end

      # Multi-turn chat with a Context object or raw messages array.
      def chat(context:)
        messages = context.is_a?(Context) ? context.to_a : Array(context)
        response = provider_instance.chat(
          messages: messages,
          model: self.class.model,
          **completion_options
        )
        @last_usage = provider_instance.last_usage
        response[:content]
      end

      # Tool-use call for the distributed/deferred pattern.
      # Returns DeferredResult if the LLM requests a tool call.
      # For automatic tool execution, use #complete with Igniter::Tool classes.
      def complete_with_tools(prompt, context: nil) # rubocop:disable Metrics/MethodLength
        messages = build_messages(prompt: prompt, context: context)
        response = provider_instance.chat(
          messages: messages,
          model: self.class.model,
          tools: self.class.tools,
          **completion_options
        )
        @last_usage = provider_instance.last_usage

        if response[:tool_calls].any?
          defer(payload: { tool_calls: response[:tool_calls], messages: messages })
        else
          response[:content]
        end
      end

      private

      # Execute the tool-use loop until the LLM produces a plain-text response.
      def run_tool_loop(prompt:, context:, tool_classes:) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        messages     = build_messages(prompt: prompt, context: context)
        schemas      = tool_classes.map(&:to_schema)
        allowed_caps = self.class.declared_capabilities
        max_iters    = self.class.max_tool_iterations
        iters        = 0

        loop do
          response = provider_instance.chat(
            messages: messages,
            model:    self.class.model,
            tools:    schemas,
            **completion_options
          )
          @last_usage = provider_instance.last_usage

          return response[:content] if response[:tool_calls].empty?

          iters += 1
          if iters > max_iters
            raise ToolLoopError,
                  "Tool loop exceeded max_tool_iterations (#{max_iters}) for #{self.class.name}"
          end

          # Append assistant's tool-use turn (preserves tool_call ids for Anthropic/OpenAI)
          messages << {
            role:       "assistant",
            content:    response[:content],
            tool_calls: response[:tool_calls],
          }

          # Execute each requested tool and collect results
          results = response[:tool_calls].map do |tc|
            klass   = tool_classes.find { |k| k.tool_name == tc[:name].to_s }
            content = dispatch_tool(klass, tc, allowed_caps)
            { id: tc[:id].to_s, name: tc[:name].to_s, content: content }
          end

          # All results for this iteration go into a single :tool_results message.
          # Each provider's normalize_messages converts this to its native format.
          messages << { role: :tool_results, results: results }
        end
      end

      def dispatch_tool(klass, tool_call, allowed_caps)
        return "Unknown tool: #{tool_call[:name]}" unless klass

        result = klass.new.call_with_capability_check!(
          allowed_capabilities: allowed_caps,
          **tool_call[:arguments]
        )
        result.is_a?(String) ? result : JSON.generate(result)
      rescue Igniter::Tool::CapabilityError
        raise
      rescue StandardError => e
        "Error: #{e.class}: #{e.message}"
      end

      def provider_instance
        @provider_instance ||= Igniter::LLM.provider_instance(self.class.provider)
      end

      def build_messages(prompt:, context: nil)
        base = []
        base << { role: "system", content: self.class.system_prompt } if self.class.system_prompt

        if context.is_a?(Context)
          base + context.to_a + [{ role: "user", content: prompt }]
        else
          base + [{ role: "user", content: prompt }]
        end
      end

      def completion_options
        opts = {}
        opts[:temperature] = self.class.temperature if self.class.temperature
        opts
      end

      def track_context(existing, user_prompt, assistant_reply)
        ctx = existing.is_a?(Context) ? existing : Context.empty(system: self.class.system_prompt)
        ctx.append_user(user_prompt).append_assistant(assistant_reply)
      end
    end
  end
end
