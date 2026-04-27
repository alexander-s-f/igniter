# frozen_string_literal: true

require "json"

require_relative "source_parser"

module Scout
  module Services
    class SourceLibrary
      attr_reader :root, :index_path

      def initialize(root:)
        @root = File.expand_path(root)
        @index_path = File.join(@root, "source_index.json")
      end

      def all
        @all ||= Dir.glob(File.join(root, "sources", "*.md")).sort.map do |path|
          normalize(SourceParser.parse(path))
        end.freeze
      end

      def default_source_ids
        index.fetch("default_sources")
      end

      def default_topic
        index.fetch("default_topic")
      end

      def find(id)
        all.find { |source| source.fetch(:id) == id.to_s }
      end

      def fetch_many(ids)
        ids.map { |id| find(id) }.compact
      end

      private

      def index
        @index ||= JSON.parse(File.read(index_path))
      end

      def normalize(source)
        source.merge(
          type: :source,
          id: source.fetch(:id),
          title: source.fetch(:title),
          source_type: source.fetch(:type),
          tags: Array(source.fetch(:tags)).freeze,
          claims: Array(source.fetch(:claims)).freeze
        ).freeze
      end
    end
  end
end
