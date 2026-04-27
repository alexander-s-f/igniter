# frozen_string_literal: true

require_relative "markdown_record_parser"

module Chronicle
  module Services
    class ProposalStore
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
        all.find { |proposal| proposal.fetch(:id) == id.to_s }
      end

      private

      def normalize(record)
        record.merge(
          type: :proposal,
          id: record.fetch(:id),
          title: record.fetch(:title),
          author: record.fetch(:author, "unknown"),
          tags: Array(record[:tags]).freeze,
          requires_signoff: Array(record[:requires_signoff]).freeze
        ).freeze
      end
    end
  end
end
