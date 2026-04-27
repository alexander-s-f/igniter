# frozen_string_literal: true

module Dispatch
  module Services
    module RunbookParser
      module_function

      def parse(path)
        content = File.read(path)
        header, body = split_header(content)
        metadata = parse_metadata(header)
        metadata.merge(
          source_path: path,
          body: body.strip
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
        return value.split(",").map(&:strip).reject(&:empty?).freeze if key == :keywords

        value
      end
    end
  end
end
