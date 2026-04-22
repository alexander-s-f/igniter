# frozen_string_literal: true

module Igniter
  module Contracts
    class Builder
      def self.compile(profile:, &block)
        builder = new(profile: profile)
        builder.instance_eval(&block)
        builder.compile
      end

      attr_reader :profile, :operations

      def initialize(profile:)
        @profile = profile
        @operations = []
      end

      def add_operation(kind:, name:, **attributes)
        normalized_kind = kind.to_sym
        raise UnknownNodeKindError, "unknown node kind #{normalized_kind}" unless profile.supports_node_kind?(normalized_kind)

        operations << { kind: normalized_kind, name: name.to_sym, attributes: attributes.freeze }.freeze
      end

      def compile
        CompiledGraph.new(operations: operations, profile_fingerprint: profile.fingerprint)
      end

      def method_missing(name, *args, **kwargs, &block)
        keyword = profile.dsl_keyword(name)
        keyword.call(*args, builder: self, **kwargs, &block)
      rescue KeyError
        raise UnknownDslKeywordError, "unknown DSL keyword #{name}"
      end

      def respond_to_missing?(name, include_private = false)
        profile.dsl_keywords.key?(name.to_sym) || super
      end
    end
  end
end
