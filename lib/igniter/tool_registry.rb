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
  # == Scopes
  #
  # Every entry belongs to one of three scopes:
  #   :bundled   — shipped with the core library
  #   :managed   — installed from an external registry or package manager
  #   :workspace — local, app-specific (default)
  #
  # Scope does not affect capability filtering or schema generation unless you
  # pass +scope:+ explicitly. All existing calls without +scope:+ continue to
  # work exactly as before.
  #
  # == Registration
  #
  #   Igniter::ToolRegistry.register(SearchWeb, WriteFile, ResearchSkill)
  #   Igniter::ToolRegistry.register(WeatherTool, scope: :bundled)
  #
  # == Discovery
  #
  #   Igniter::ToolRegistry.all
  #   # => [SearchWeb, WriteFile, ResearchSkill, WeatherTool]
  #
  #   Igniter::ToolRegistry.all(scope: :bundled)
  #   # => [WeatherTool]
  #
  #   Igniter::ToolRegistry.tools_for(capabilities: [:web_access])
  #   Igniter::ToolRegistry.tools_for(capabilities: [:web_access], scope: :workspace)
  #
  # == Schema generation
  #
  #   Igniter::ToolRegistry.schemas(:anthropic)
  #   Igniter::ToolRegistry.schemas(:openai, capabilities: [:web_access], scope: :managed)
  module ToolRegistry
    # Valid scope identifiers, ordered from least to most specific.
    SCOPES = %i[bundled managed workspace].freeze

    # Internal store: { tool_name_string => { klass: Class, scope: Symbol } }
    @tools = {}

    class << self
      # Register one or more Tool or Skill subclasses.
      #
      # @param tool_classes [Array<Class>] Tool or Skill subclasses
      # @param scope        [Symbol]       :bundled, :managed, or :workspace (default)
      # @raise [ArgumentError] if a class is not discoverable or scope is invalid
      def register(*tool_classes, scope: :workspace) # rubocop:disable Metrics/MethodLength
        unless SCOPES.include?(scope)
          raise ArgumentError, "Invalid scope #{scope.inspect}. Must be one of #{SCOPES.inspect}"
        end

        tool_classes.flatten.each do |klass|
          unless discoverable?(klass)
            raise ArgumentError,
                  "#{klass.inspect} must be an Igniter::Tool or Igniter::Skill subclass"
          end

          @tools[klass.tool_name] = { klass: klass, scope: scope }
        end
        self
      end

      # Look up a tool or skill by its snake_case name.
      # @param name [String, Symbol]
      # @return [Class, nil]
      def find(name)
        @tools[name.to_s]&.fetch(:klass)
      end

      # All registered classes, optionally filtered by scope.
      #
      # @param scope [Symbol, nil] :bundled, :managed, :workspace, or nil for all
      # @return [Array<Class>]
      def all(scope: nil)
        entries_for(scope).map { |e| e[:klass] }
      end

      # Classes whose required capabilities are fully covered by +capabilities+.
      # Tools/skills with no required capabilities are always included.
      #
      # @param capabilities [Array<Symbol>]
      # @param scope        [Symbol, nil]
      # @return [Array<Class>]
      def tools_for(capabilities: [], scope: nil)
        allowed  = capabilities.map(&:to_sym).to_set
        matching = entries_for(scope).select do |e|
          e[:klass].required_capabilities.all? { |c| allowed.include?(c) }
        end
        matching.map { |e| e[:klass] }
      end

      # Generate schemas for the given provider.
      # Optionally filter by capabilities and/or scope.
      #
      # @param provider      [Symbol]        :anthropic, :openai, or nil for intermediate
      # @param capabilities  [Array<Symbol>] optional capability filter
      # @param scope         [Symbol, nil]   optional scope filter
      # @return [Array<Hash>]
      def schemas(provider = nil, capabilities: nil, scope: nil)
        list = if capabilities
                 tools_for(capabilities: capabilities, scope: scope)
               else
                 all(scope: scope)
               end
        list.map { |klass| klass.to_schema(provider) }
      end

      # Number of registered classes (across all scopes).
      def size = @tools.size

      # True if nothing is registered.
      def empty? = @tools.empty?

      # Remove all registrations (primarily for tests).
      def clear!
        @tools = {}
        self
      end

      private

      def entries_for(scope)
        scope ? @tools.values.select { |e| e[:scope] == scope } : @tools.values
      end

      # A class is discoverable if it is a Tool or Skill (includes Tool::Discoverable).
      def discoverable?(klass)
        klass.is_a?(Class) &&
          (klass < Igniter::Tool || klass < Igniter::Skill)
      end
    end
  end
end
