# frozen_string_literal: true

require_relative "tool"
require_relative "skill"

module Igniter
  # Global registry for Igniter::Tool and Igniter::Skill classes.
  #
  # Both Tools (atomic operations) and Skills (agentic sub-processes) share the
  # same discovery interface and are registered the same way. The registry does
  # not distinguish between them — from a caller's perspective both are callable
  # units described by name, description, and a parameter schema.
  #
  # == Registration
  #
  #   Igniter::ToolRegistry.register(SearchWeb, WriteFile, ResearchSkill)
  #
  # == Discovery
  #
  #   Igniter::ToolRegistry.all
  #   # => [SearchWeb, WriteFile, ResearchSkill]
  #
  #   Igniter::ToolRegistry.tools_for(capabilities: [:web_access])
  #   # => [SearchWeb, ResearchSkill]
  #
  # == Schema generation
  #
  #   Igniter::ToolRegistry.schemas(:anthropic)
  #   Igniter::ToolRegistry.schemas(:openai, capabilities: [:web_access])
  module ToolRegistry
    @tools = {}

    class << self
      # Register one or more Tool or Skill subclasses.
      #
      # @param tool_classes [Array<Class>] Tool or Skill subclasses
      # @raise [ArgumentError] if a class is not discoverable
      def register(*tool_classes)
        tool_classes.flatten.each do |klass|
          unless discoverable?(klass)
            raise ArgumentError,
                  "#{klass.inspect} must be an Igniter::Tool or Igniter::Skill subclass"
          end
          @tools[klass.tool_name] = klass
        end
        self
      end

      # Look up a tool or skill by its snake_case name.
      # @param name [String, Symbol]
      # @return [Class, nil]
      def find(name)
        @tools[name.to_s]
      end

      # All registered classes.
      # @return [Array<Class>]
      def all
        @tools.values
      end

      # Classes whose required capabilities are fully covered by +capabilities+.
      # Tools/skills with no required capabilities are always included.
      #
      # @param capabilities [Array<Symbol>]
      # @return [Array<Class>]
      def tools_for(capabilities: [])
        allowed = capabilities.map(&:to_sym).to_set
        @tools.values.select do |klass|
          klass.required_capabilities.all? { |c| allowed.include?(c) }
        end
      end

      # Generate schemas for the given provider.
      # Optionally filter by capabilities.
      #
      # @param provider      [Symbol]        :anthropic, :openai, or nil for intermediate
      # @param capabilities  [Array<Symbol>] optional capability filter
      # @return [Array<Hash>]
      def schemas(provider = nil, capabilities: nil)
        list = capabilities ? tools_for(capabilities: capabilities) : all
        list.map { |klass| klass.to_schema(provider) }
      end

      # Number of registered classes.
      def size = @tools.size

      # True if nothing is registered.
      def empty? = @tools.empty?

      # Remove all registrations (primarily for tests).
      def clear!
        @tools = {}
        self
      end

      private

      # A class is discoverable if it is a Tool or Skill (includes Tool::Discoverable).
      def discoverable?(klass)
        klass.is_a?(Class) &&
          (klass < Igniter::Tool || klass < Igniter::Skill)
      end
    end
  end
end
