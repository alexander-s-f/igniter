# frozen_string_literal: true

module Chronicle
  module Services
    module MarkdownRecordParser
      module_function

      def parse(path)
        content = File.read(path)
        header, body = split_header(content)
        sections = parse_sections(body)
        metadata = parse_metadata(header)
        metadata.merge(
          source_path: path,
          body: body.strip,
          sections: sections
        ).freeze
      end

      def split_header(content)
        lines = content.lines
        header_lines = []
        body_start = 0

        lines.each_with_index do |line, index|
          if line.start_with?("## ")
            body_start = index
            break
          end

          header_lines << line
          body_start = index + 1
        end

        [header_lines.join, lines[body_start..].join]
      end

      def parse_metadata(header)
        header.lines.each_with_object({}) do |line, data|
          key, value = line.split(":", 2)
          next unless key && value

          data[key.strip.tr("-", "_").to_sym] = normalize_value(key.strip, value.strip)
        end
      end

      def normalize_value(key, value)
        return [] if value.empty? && list_key?(key)
        return value.split(",").map(&:strip).reject(&:empty?).freeze if list_key?(key)

        value
      end

      def list_key?(key)
        %w[tags owners signoffs supersedes related requires_signoff].include?(key)
      end

      def parse_sections(body)
        sections = {}
        current = nil
        buffer = []

        body.lines.each do |line|
          if line.start_with?("## ")
            sections[section_key(current)] = buffer.join.strip if current
            current = line.delete_prefix("## ").strip
            buffer = []
          else
            buffer << line
          end
        end

        sections[section_key(current)] = buffer.join.strip if current
        sections.freeze
      end

      def section_key(title)
        title.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "").to_sym
      end
    end
  end
end
