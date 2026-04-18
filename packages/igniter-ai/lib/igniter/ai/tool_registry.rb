# frozen_string_literal: true

require "set"

require "igniter/core/errors"
require "igniter/core/tool"
require_relative "skill"

module Igniter
  module AI
    module ToolRegistry
      SCOPES = %i[bundled managed workspace].freeze

      @tools = {}

      class << self
        def register(*tool_classes, scope: :workspace) # rubocop:disable Metrics/MethodLength
          unless SCOPES.include?(scope)
            raise ArgumentError, "Invalid scope #{scope.inspect}. Must be one of #{SCOPES.inspect}"
          end

          tool_classes.flatten.each do |klass|
            unless discoverable?(klass)
              raise ArgumentError,
                    "#{klass.inspect} must be an Igniter::Tool or Igniter::AI::Skill subclass"
            end

            @tools[klass.tool_name] = { klass: klass, scope: scope }
          end
          self
        end

        def find(name)
          @tools[name.to_s]&.fetch(:klass)
        end

        def all(scope: nil)
          entries_for(scope).map { |e| e[:klass] }
        end

        def tools_for(capabilities: [], scope: nil)
          allowed  = capabilities.map(&:to_sym).to_set
          matching = entries_for(scope).select do |e|
            e[:klass].required_capabilities.all? { |c| allowed.include?(c) }
          end
          matching.map { |e| e[:klass] }
        end

        def schemas(provider = nil, capabilities: nil, scope: nil)
          list = if capabilities
                   tools_for(capabilities: capabilities, scope: scope)
                 else
                   all(scope: scope)
                 end
          list.map { |klass| klass.to_schema(provider) }
        end

        def size = @tools.size
        def empty? = @tools.empty?

        def clear!
          @tools = {}
          self
        end

        private

        def entries_for(scope)
          scope ? @tools.values.select { |e| e[:scope] == scope } : @tools.values
        end

        def discoverable?(klass)
          klass.is_a?(Class) &&
            (klass < Igniter::Tool || klass < Igniter::AI::Skill)
        end
      end
    end
  end
end
