# frozen_string_literal: true

module Companion
  module Main
    module Support
      module AssistantArtifacts
        module_function

        KNOWN_KINDS = %i[note url file log].freeze

        def normalize(raw: nil, text: nil)
          entries =
            if raw.is_a?(Array)
              raw
            else
              parse_text(text || raw)
            end

          Array(entries).filter_map do |entry|
            normalize_entry(entry)
          end
        end

        def summary(artifacts)
          normalized = normalize(raw: artifacts)
          return nil if normalized.empty?

          counts = normalized.group_by { |entry| entry[:kind] }.transform_values(&:size)
          {
            total: normalized.size,
            by_kind: counts
          }
        end

        def prompt_lines(artifacts)
          normalize(raw: artifacts).map do |entry|
            "#{entry.fetch(:kind).to_s.upcase}: #{entry.fetch(:value)}"
          end
        end

        private

        def parse_text(text)
          text.to_s.each_line.map(&:strip).reject(&:empty?).map do |line|
            if (match = line.match(/\A([a-z_]+)\s*:\s*(.+)\z/i))
              {
                kind: match[1],
                value: match[2]
              }
            else
              {
                kind: infer_kind(line),
                value: line
              }
            end
          end
        end

        def normalize_entry(entry)
          case entry
          when Hash
            value = entry[:value] || entry["value"]
            return nil if value.to_s.strip.empty?

            kind = normalize_kind(entry[:kind] || entry["kind"] || infer_kind(value))
            label = entry[:label] || entry["label"]

            {
              kind: kind,
              label: label.to_s.strip.empty? ? default_label(kind) : label.to_s.strip,
              value: value.to_s.strip
            }
          else
            value = entry.to_s.strip
            return nil if value.empty?

            kind = normalize_kind(infer_kind(value))
            {
              kind: kind,
              label: default_label(kind),
              value: value
            }
          end
        end

        def normalize_kind(kind)
          normalized = kind.to_s.strip.downcase.tr(" ", "_").to_sym
          return normalized if KNOWN_KINDS.include?(normalized)

          :note
        end

        def infer_kind(value)
          text = value.to_s.strip
          return :url if text.match?(%r{\Ahttps?://}i)
          return :file if text.start_with?("/", "./", "../", "~/")
          return :log if text.match?(/\A(log|event|trace)\b/i)

          :note
        end

        def default_label(kind)
          case kind
          when :url then "Source URL"
          when :file then "File"
          when :log then "Log"
          else "Note"
          end
        end

        module_function :parse_text, :normalize_entry, :normalize_kind, :infer_kind, :default_label
      end
    end
  end
end
