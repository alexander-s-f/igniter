# frozen_string_literal: true

module Igniter
  module Application
    class ApplicationBlueprint
      FILE_GROUPS = %i[config].freeze

      attr_reader :name, :root, :env, :layout, :packs, :contracts, :providers,
                  :services, :interfaces, :effects, :web_surfaces, :config, :metadata

      def initialize(name:, root:, env: :development, layout: nil, paths: {}, packs: [], contracts: [],
                     providers: [], services: [], interfaces: [], effects: [], web_surfaces: [],
                     config: {}, metadata: {})
        @name = name.to_sym
        @root = File.expand_path(root.to_s)
        @env = env.to_sym
        @layout = layout || ApplicationLayout.new(root: @root, paths: paths, metadata: metadata)
        @packs = Array(packs).map(&:to_s).freeze
        @contracts = Array(contracts).map(&:to_s).freeze
        @providers = Array(providers).map(&:to_sym).freeze
        @services = Array(services).map(&:to_sym).freeze
        @interfaces = Array(interfaces).map(&:to_sym).freeze
        @effects = Array(effects).map(&:to_sym).freeze
        @web_surfaces = Array(web_surfaces).map(&:to_sym).freeze
        @config = config.dup.freeze
        @metadata = metadata.dup.freeze
        freeze
      end

      def planned_paths
        layout.paths.map do |group, path|
          {
            group: group,
            path: path,
            absolute_path: layout.absolute_path(group),
            kind: FILE_GROUPS.include?(group) ? :file : :directory
          }
        end.freeze
      end

      def to_manifest
        ApplicationManifest.new(
          name: name,
          root: root,
          env: env,
          layout: layout,
          packs: packs,
          contracts: contracts,
          providers: providers,
          services: services,
          interfaces: interfaces,
          config: config,
          metadata: manifest_metadata
        )
      end

      def structure_plan(metadata: {})
        ApplicationStructurePlan.inspect(blueprint: self, metadata: metadata)
      end

      def materialize_structure!(metadata: {})
        structure_plan(metadata: metadata).apply!
      end

      def apply_to(kernel)
        kernel.manifest(name, root: root, env: env, layout: layout, metadata: manifest_metadata)
        layout.paths.each do |group, path|
          kernel.add_path(group, path)
        end
        config.each do |key, value|
          kernel.set(key, value: value)
        end
        kernel
      end

      def to_h
        {
          name: name,
          root: root,
          env: env,
          layout: layout.to_h,
          planned_paths: planned_paths,
          packs: packs.dup,
          contracts: contracts.dup,
          providers: providers.dup,
          services: services.dup,
          interfaces: interfaces.dup,
          effects: effects.dup,
          web_surfaces: web_surfaces.dup,
          config: config.dup,
          metadata: metadata.dup
        }
      end

      private

      def manifest_metadata
        metadata.merge(
          blueprint: true,
          effects: effects,
          web_surfaces: web_surfaces
        )
      end
    end
  end
end
