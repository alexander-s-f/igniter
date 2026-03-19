# frozen_string_literal: true

module Igniter
  class Error < StandardError
    attr_reader :context

    def initialize(message = nil, context: {})
      @context = context.compact.freeze
      super(format_message(message, @context))
    end

    def graph
      context[:graph]
    end

    def node_id
      context[:node_id]
    end

    def node_name
      context[:node_name]
    end

    def node_path
      context[:node_path]
    end

    def source_location
      context[:source_location]
    end

    private

    def format_message(message, context)
      details = []
      details << "graph=#{context[:graph]}" if context[:graph]
      details << "node=#{context[:node_name]}" if context[:node_name]
      details << "path=#{context[:node_path]}" if context[:node_path]
      details << "location=#{context[:source_location]}" if context[:source_location]

      return message if details.empty?

      "#{message} [#{details.join(', ')}]"
    end
  end

  class CompileError < Error; end
  class ValidationError < CompileError; end
  class CycleError < ValidationError; end
  class InputError < Error; end
  class ResolutionError < Error; end
  class CompositionError < Error; end
  class BranchSelectionError < Error; end
  class PendingDependencyError < Error
    attr_reader :deferred_result

    def initialize(deferred_result, message = "Dependency is pending", context: {})
      @deferred_result = deferred_result
      super(message, context: context)
    end
  end
end
