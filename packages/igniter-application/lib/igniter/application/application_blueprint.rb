# frozen_string_literal: true

module Igniter
  module Application
    class ApplicationBlueprint
      FILE_GROUPS = %i[config].freeze

      attr_reader :name, :root, :env, :layout_profile, :layout, :groups, :packs,
                  :contracts, :providers, :services, :interfaces, :effects,
                  :web_surfaces, :exports, :imports, :config, :metadata

      def initialize(name:, root:, env: :development, layout: nil, layout_profile: :standalone, paths: {},
                     groups: [], packs: [], contracts: [], providers: [], services: [], interfaces: [],
                     effects: [], web_surfaces: [], exports: [], imports: [],
                     config: {}, metadata: {})
        @name = name.to_sym
        @root = File.expand_path(root.to_s)
        @env = env.to_sym
        @layout_profile = layout&.profile || layout_profile.to_sym
        @layout = layout || ApplicationLayout.new(root: @root, profile: @layout_profile, paths: paths, metadata: metadata)
        @groups = Array(groups).map(&:to_sym).uniq.sort.freeze
        @packs = Array(packs).map(&:to_s).freeze
        @contracts = Array(contracts).map(&:to_s).freeze
        @providers = Array(providers).map(&:to_sym).freeze
        @services = Array(services).map(&:to_sym).freeze
        @interfaces = Array(interfaces).map(&:to_sym).freeze
        @effects = Array(effects).map(&:to_sym).freeze
        @web_surfaces = Array(web_surfaces).map(&:to_sym).freeze
        @exports = normalize_exports(exports).freeze
        @imports = normalize_imports(imports).freeze
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

      def active_groups
        (
          %i[config spec] +
          groups +
          implied_groups
        ).uniq.select { |group| layout.paths.key?(group) }.sort.freeze
      end

      def known_groups
        layout.paths.keys.sort.freeze
      end

      def structure_plan(mode: :sparse, metadata: {})
        ApplicationStructurePlan.inspect(blueprint: self, mode: mode, metadata: metadata)
      end

      def materialize_structure!(mode: :sparse, metadata: {})
        structure_plan(mode: mode, metadata: metadata).apply!
      end

      def apply_to(kernel)
        kernel.manifest(name, root: root, env: env, layout: layout, metadata: manifest_metadata)
        active_groups.each do |group|
          kernel.add_path(group, layout.path(group))
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
          layout_profile: layout_profile,
          layout: layout.to_h,
          groups: groups.dup,
          active_groups: active_groups,
          known_groups: known_groups,
          planned_paths: planned_paths,
          packs: packs.dup,
          contracts: contracts.dup,
          providers: providers.dup,
          services: services.dup,
          interfaces: interfaces.dup,
          effects: effects.dup,
          web_surfaces: web_surfaces.dup,
          exports: exports.map(&:to_h),
          imports: imports.map(&:to_h),
          config: config.dup,
          metadata: metadata.dup
        }
      end

      private

      def manifest_metadata
        metadata.merge(
          blueprint: true,
          layout_profile: layout_profile,
          groups: active_groups,
          exports: exports.map(&:to_h),
          imports: imports.map(&:to_h),
          effects: effects,
          web_surfaces: web_surfaces
        )
      end

      def implied_groups
        [].tap do |result|
          result << :contracts unless contracts.empty?
          result << :providers unless providers.empty?
          result << :services unless services.empty? && interfaces.empty?
          result << :effects unless effects.empty?
          result << :packs unless packs.empty?
          result << :web unless web_surfaces.empty?
        end
      end

      def normalize_exports(entries)
        Array(entries).map do |entry|
          case entry
          when CapsuleExport
            entry
          when Hash
            CapsuleExport.new(
              name: entry.fetch(:name),
              kind: entry.fetch(:kind, entry.fetch(:as, :service)),
              target: entry[:target],
              metadata: entry.fetch(:metadata, {})
            )
          else
            CapsuleExport.new(name: entry)
          end
        end
      end

      def normalize_imports(entries)
        Array(entries).map do |entry|
          case entry
          when CapsuleImport
            entry
          when Hash
            CapsuleImport.new(
              name: entry.fetch(:name),
              kind: entry.fetch(:kind, :service),
              from: entry[:from],
              optional: entry.fetch(:optional, false),
              capabilities: entry.fetch(:capabilities, []),
              metadata: entry.fetch(:metadata, {})
            )
          else
            CapsuleImport.new(name: entry)
          end
        end
      end
    end
  end
end
