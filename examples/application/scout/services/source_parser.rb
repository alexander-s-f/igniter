# frozen_string_literal: true

module Scout
  module Services
    module SourceParser
      module_function

      def parse(path)
        content = File.read(path)
        header, body = split_header(content)
        metadata = parse_metadata(header)
        sections = parse_sections(body)
        metadata.merge(
          source_path: path,
          body: body.strip,
          sections: sections,
          claims: parse_claims(sections.fetch(:claims, ""))
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

          normalized_key = key.strip.tr("-", "_").to_sym
          data[normalized_key] = normalize_value(normalized_key, value.strip)
        end
      end

      def normalize_value(key, value)
        return value.split(",").map(&:strip).reject(&:empty?).freeze if key == :tags

        value
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
        title.to_s.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "").to_sym
      end

      def parse_claims(text)
        text.lines.filter_map.with_index do |line, index|
          next unless line.strip.start_with?("- ")

          statement = line.strip.delete_prefix("- ").strip
          anchor = statement[/\[(.+?)\]\z/, 1] || "p#{index + 1}"
          {
            anchor: anchor,
            statement: statement.sub(/\s*\[.+?\]\z/, "")
          }.freeze
        end.freeze
      end
    end
  end
end
