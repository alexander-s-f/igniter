# frozen_string_literal: true

module Igniter
  module Provenance
    # Renders a NodeTrace tree as a human-readable ASCII tree.
    #
    # Example output:
    #
    #   grand_total = 229.95  [compute]
    #   ├─ subtotal = 199.96  [compute]
    #   │  ├─ unit_price = 99.98  [compute]
    #   │  │  └─ base_price = 100.0  [input]
    #   │  └─ quantity = 2  [input]
    #   └─ shipping_cost = 29.99  [compute]
    #      └─ destination = "US"  [input]
    #
    module TextFormatter
      VALUE_MAX_LENGTH = 60

      def self.format(trace)
        lines = []
        render(trace, lines, prefix: "", is_root: true, is_last: true)
        lines.join("\n")
      end

      # ── private helpers ──────────────────────────────────────────────────────

      def self.render(trace, lines, prefix:, is_root:, is_last:) # rubocop:disable Metrics/MethodLength
        if is_root
          connector = ""
          child_pad = ""
        elsif is_last
          connector = "└─ "
          child_pad = "   "
        else
          connector = "├─ "
          child_pad = "│  "
        end
        child_prefix = prefix + child_pad

        lines << "#{prefix}#{connector}#{trace.name} = #{format_value(trace.value)}  [#{trace.kind}]"

        deps = trace.contributing.values
        deps.each_with_index do |dep, idx|
          render(dep, lines,
                 prefix: child_prefix,
                 is_root: false,
                 is_last: idx == deps.size - 1)
        end
      end
      private_class_method :render

      def self.format_value(value) # rubocop:disable Metrics/CyclomaticComplexity
        str = case value
              when nil    then "nil"
              when String then value.inspect
              when Symbol then value.inspect
              when Hash   then "{#{value.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")}}"
              when Array  then "[#{value.map(&:inspect).join(", ")}]"
              else             value.inspect
              end

        return str if str.length <= VALUE_MAX_LENGTH

        "#{str[0, VALUE_MAX_LENGTH - 3]}..."
      end
      private_class_method :format_value
    end
  end
end
