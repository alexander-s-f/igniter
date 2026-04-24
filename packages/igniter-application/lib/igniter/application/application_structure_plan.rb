# frozen_string_literal: true

require "fileutils"

module Igniter
  module Application
    class ApplicationStructurePlan
      FILE_GROUPS = %i[config].freeze
      DEFAULT_FILE_CONTENT = {
        config: "# frozen_string_literal: true\n\n"
      }.freeze

      attr_reader :blueprint, :root, :layout, :entries, :metadata

      def self.inspect(blueprint:, metadata: {})
        entries = blueprint.layout.paths.map do |group, path|
          absolute_path = blueprint.layout.absolute_path(group)
          kind = FILE_GROUPS.include?(group.to_sym) ? :file : :directory
          status = path_present?(absolute_path, kind) ? :present : :missing
          ApplicationStructureEntry.new(
            group: group,
            path: path,
            absolute_path: absolute_path,
            kind: kind,
            status: status,
            action: action_for(kind, status),
            metadata: entry_metadata(group)
          )
        end

        new(
          blueprint: blueprint,
          root: blueprint.root,
          layout: blueprint.layout,
          entries: entries,
          metadata: metadata
        )
      end

      def self.path_present?(absolute_path, kind)
        kind == :file ? File.file?(absolute_path) : File.directory?(absolute_path)
      end

      def self.action_for(kind, status)
        return :keep if status == :present

        kind == :file ? :write_file : :create_directory
      end

      def self.entry_metadata(group)
        content = DEFAULT_FILE_CONTENT[group.to_sym]
        content.nil? ? {} : { default_content: content }
      end

      def initialize(blueprint:, root:, layout:, entries:, metadata: {})
        @blueprint = blueprint
        @root = File.expand_path(root.to_s)
        @layout = layout
        @entries = Array(entries).freeze
        @metadata = metadata.dup.freeze
        freeze
      end

      def present_entries
        entries.select(&:present?)
      end

      def missing_entries
        entries.select(&:missing?)
      end

      def planned_entries
        entries.reject { |entry| entry.action == :keep }
      end

      def present_groups
        present_entries.map(&:group).uniq.sort
      end

      def missing_groups
        missing_entries.map(&:group).uniq.sort
      end

      def apply!
        applied = planned_entries.select(&:apply!)

        {
          root: root,
          applied_count: applied.length,
          applied_groups: applied.map(&:group).sort,
          entries: applied.map(&:to_h)
        }
      end

      def to_h
        {
          root: root,
          blueprint: blueprint.name,
          entry_count: entries.length,
          present_count: present_entries.length,
          missing_count: missing_entries.length,
          present_groups: present_groups,
          missing_groups: missing_groups,
          entries: entries.map(&:to_h),
          metadata: metadata.dup
        }
      end
    end
  end
end
