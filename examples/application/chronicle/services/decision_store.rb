# frozen_string_literal: true

require_relative "markdown_record_parser"

module Chronicle
  module Services
    class DecisionStore
      attr_reader :root

      def initialize(root:)
        @root = File.expand_path(root)
      end

      def all
        @all ||= Dir.glob(File.join(root, "*.md")).sort.map do |path|
          normalize(MarkdownRecordParser.parse(path))
        end.freeze
      end

      def find(id)
        all.find { |decision| decision.fetch(:id) == id.to_s }
      end

      private

      def normalize(record)
        record.merge(
          type: :decision,
          id: record.fetch(:id),
          title: record.fetch(:title),
          status: record.fetch(:status, "unknown"),
          tags: Array(record[:tags]).freeze,
          owners: Array(record[:owners]).freeze,
          signoffs: Array(record[:signoffs]).freeze,
          supersedes: Array(record[:supersedes]).freeze,
          related: Array(record[:related]).freeze
        ).freeze
      end
    end
  end
end
