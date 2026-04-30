# frozen_string_literal: true

module Igniter
  module Store
    class SchemaGraph
      def initialize
        @paths = Hash.new { |hash, key| hash[key] = [] }
      end

      def register(path)
        @paths[path.store] << path
        self
      end

      def paths_for(store)
        @paths[store].dup
      end

      def consumers_for(store)
        @paths[store].flat_map { |path| path.consumers.to_a }.uniq
      end

      def path_for(store:, scope:)
        @paths[store].find { |path| path.scope == scope }
      end
    end
  end
end
