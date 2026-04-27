# frozen_string_literal: true

require "fileutils"
require "json"
require "time"

module Igniter
  module Application
    class FileBackedInstalledCapsuleRegistry
      attr_reader :root

      def self.build(root:)
        new(root: root)
      end

      def initialize(root:)
        @root = File.expand_path(root.to_s)
        freeze
      end

      def record(name, receipt:, source: nil, version: nil, metadata: {})
        entry = InstalledCapsuleEntry.new(
          name: name,
          receipt: receipt,
          source: source,
          version: version,
          metadata: metadata,
          installed_at: Time.now.utc.iso8601
        )
        FileUtils.mkdir_p(registry_dir)
        File.write(entry_path(name), "#{JSON.pretty_generate(entry.to_h)}\n")
        entry
      end

      def entries
        Dir.glob(File.join(registry_dir, "*.json")).sort.map do |path|
          payload = JSON.parse(File.read(path), symbolize_names: true)
          InstalledCapsuleEntry.new(
            name: payload.fetch(:name),
            receipt: payload.fetch(:receipt),
            source: payload[:source],
            version: payload[:version],
            metadata: payload.fetch(:metadata, {}),
            installed_at: payload[:installed_at]
          )
        end.freeze
      end

      def fetch(name)
        entries.find { |entry| entry.name == name.to_sym } || raise(KeyError, "unknown installed capsule #{name.inspect}")
      end

      def installed?(name)
        fetch(name).installed?
      rescue KeyError
        false
      end

      def to_h
        {
          root: root,
          entries: entries.map(&:to_h)
        }
      end

      private

      def registry_dir
        File.join(root, "installed-capsules")
      end

      def entry_path(name)
        File.join(registry_dir, "#{safe_key(name)}.json")
      end

      def safe_key(value)
        value.to_s.gsub(/[^a-zA-Z0-9_.-]/, "_")
      end
    end
  end
end
