# frozen_string_literal: true

require "digest"

module Lense
  module Services
    class CodebaseAnalyzer
      DEFAULT_INCLUDE_GLOBS = ["**/*.rb"].freeze

      attr_reader :target_root, :project_label, :include_globs

      def initialize(target_root:, project_label: nil, include_globs: DEFAULT_INCLUDE_GLOBS)
        @target_root = File.expand_path(target_root.to_s)
        @project_label = project_label || File.basename(@target_root)
        @include_globs = include_globs
        freeze
      end

      def scan
        files = ruby_files.map { |path| file_fact(path) }
        duplicate_groups = duplicate_line_groups(files)
        {
          scan_id: scan_id(files, duplicate_groups),
          project_label: project_label,
          target_root: target_root,
          target_root_label: File.basename(target_root),
          ruby_files: files,
          duplicate_groups: duplicate_groups,
          counts: counts(files, duplicate_groups)
        }
      end

      private

      def ruby_files
        paths = include_globs.flat_map do |pattern|
          Dir.glob(File.join(target_root, pattern), File::FNM_DOTMATCH)
        end

        paths.select do |path|
          File.file?(path) && File.extname(path) == ".rb" && inside_target?(path)
        end.sort
      end

      def inside_target?(path)
        File.expand_path(path).start_with?("#{target_root}/")
      end

      def file_fact(path)
        content = File.read(path)
        lines = content.lines
        {
          path: path,
          relative_path: relative_path(path),
          digest: Digest::SHA256.hexdigest(content),
          line_count: lines.length,
          todo_count: lines.count { |line| line.match?(/\b(TODO|FIXME)\b/) },
          method_count: lines.count { |line| line.match?(/^\s*def\s+/) },
          branch_count: lines.count { |line| line.match?(/\b(if|unless|case|when|elsif|rescue)\b/) },
          max_line_length: lines.map(&:length).max || 0,
          fingerprints: fingerprints(lines)
        }
      end

      def relative_path(path)
        File.expand_path(path).delete_prefix("#{target_root}/")
      end

      def fingerprints(lines)
        lines.filter_map do |line|
          normalized = line.strip.gsub(/\s+/, " ")
          next if normalized.empty? || normalized.start_with?("#") || normalized.length < 24

          Digest::SHA256.hexdigest(normalized)[0, 12]
        end
      end

      def duplicate_line_groups(files)
        groups = files.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |file, grouped|
          file.fetch(:fingerprints).each { |fingerprint| grouped[fingerprint] << file.fetch(:relative_path) }
        end

        duplicate_groups = groups.filter_map do |fingerprint, paths|
          unique_paths = paths.uniq.sort
          next unless unique_paths.length > 1

          {
            fingerprint: fingerprint,
            file_count: unique_paths.length,
            paths: unique_paths
          }
        end

        duplicate_groups.sort_by { |group| group.fetch(:fingerprint) }
      end

      def counts(files, duplicate_groups)
        {
          ruby_files: files.length,
          lines: files.sum { |file| file.fetch(:line_count) },
          todos: files.sum { |file| file.fetch(:todo_count) },
          methods: files.sum { |file| file.fetch(:method_count) },
          duplicate_groups: duplicate_groups.length
        }
      end

      def scan_id(files, duplicate_groups)
        payload = {
          files: files.map { |file| [file.fetch(:relative_path), file.fetch(:digest)] },
          duplicate_groups: duplicate_groups.map { |group| group.fetch(:fingerprint) }
        }
        "lense-scan:#{Digest::SHA256.hexdigest(payload.inspect)[0, 16]}"
      end
    end
  end
end
