# frozen_string_literal: true

require_relative "tool"

module Igniter
  # Global registry for Igniter::Tool classes.
  #
  # Provides tool discovery and LLM schema generation, with optional
  # capability-based filtering so different agents see only the tools
  # they are authorized to call.
  #
  # == Registration
  #
  #   Igniter::ToolRegistry.register(SearchWeb, WriteFile, RunTests)
  #
  # == Discovery
  #
  #   Igniter::ToolRegistry.all
  #   # => [SearchWeb, WriteFile, RunTests]
  #
  #   Igniter::ToolRegistry.tools_for(capabilities: [:web_access])
  #   # => [SearchWeb]  (WriteFile needs :filesystem_write, RunTests needs :code_execution)
  #
  # == Schema generation
  #
  #   Igniter::ToolRegistry.schemas(:anthropic)
  #   Igniter::ToolRegistry.schemas(:openai, capabilities: [:web_access])
  module ToolRegistry
    @tools = {}

    class << self
      # Register one or more Tool subclasses.
      # Each class must be an Igniter::Tool subclass.
      #
      # @param tool_classes [Array<Class>]
      # @raise [ArgumentError] if a class is not an Igniter::Tool subclass
      def register(*tool_classes)
        tool_classes.flatten.each do |klass|
          unless klass.is_a?(Class) && klass < Igniter::Tool
            raise ArgumentError, "#{klass.inspect} must be an Igniter::Tool subclass"
          end
          @tools[klass.tool_name] = klass
        end
        self
      end

      # Look up a tool by its snake_case name.
      # @param name [String, Symbol]
      # @return [Class, nil]
      def find(name)
        @tools[name.to_s]
      end

      # All registered tool classes.
      # @return [Array<Class>]
      def all
        @tools.values
      end

      # Tool classes whose required capabilities are fully covered by +capabilities+.
      # Tools with no required capabilities are always included.
      #
      # @param capabilities [Array<Symbol>]
      # @return [Array<Class>]
      def tools_for(capabilities: [])
        allowed = capabilities.map(&:to_sym).to_set
        @tools.values.select do |klass|
          klass.required_capabilities.all? { |c| allowed.include?(c) }
        end
      end

      # Generate tool schemas for the given provider.
      # Optionally filter by capabilities (only returns tools the agent may call).
      #
      # @param provider      [Symbol]       :anthropic, :openai, or nil for intermediate
      # @param capabilities  [Array<Symbol>] optional capability filter
      # @return [Array<Hash>]
      def schemas(provider = nil, capabilities: nil)
        list = capabilities ? tools_for(capabilities: capabilities) : all
        list.map { |klass| klass.to_schema(provider) }
      end

      # Number of registered tools.
      def size
        @tools.size
      end

      # True if no tools are registered.
      def empty?
        @tools.empty?
      end

      # Remove all registrations (primarily for tests).
      def clear!
        @tools = {}
        self
      end
    end
  end
end
