# frozen_string_literal: true

module Igniter
  module Application
    class ApplicationLayout
      DEFAULT_PATHS = {
        contracts: "app/contracts",
        providers: "app/providers",
        services: "app/services",
        effects: "app/effects",
        packs: "app/packs",
        executors: "app/executors",
        tools: "app/tools",
        agents: "app/agents",
        skills: "app/skills",
        config: "config/igniter.rb",
        spec: "spec/igniter"
      }.freeze

      attr_reader :root, :paths, :metadata

      def initialize(root:, paths: {}, metadata: {})
        @root = File.expand_path(root.to_s)
        @paths = DEFAULT_PATHS.merge(symbolize_hash(paths)).freeze
        @metadata = metadata.dup.freeze
        freeze
      end

      def path(name)
        paths.fetch(name.to_sym)
      end

      def absolute_path(name)
        File.expand_path(path(name), root)
      end

      def code_paths
        paths.reject { |name, _path| %i[config spec].include?(name) }
      end

      def to_h
        {
          root: root,
          paths: paths.dup,
          absolute_paths: paths.transform_values { |path| File.expand_path(path, root) },
          metadata: metadata.dup
        }
      end

      private

      def symbolize_hash(value)
        value.each_with_object({}) do |(key, entry), memo|
          memo[key.to_sym] = Array(entry).first.to_s
        end
      end
    end
  end
end
