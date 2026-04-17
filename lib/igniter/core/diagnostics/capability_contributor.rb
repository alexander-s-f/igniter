# frozen_string_literal: true

module Igniter
  module Diagnostics
    module CapabilityContributor
      class << self
        def augment(report:, execution:)
          entries = capability_entries(execution)
          return report if entries.empty?

          unique_capabilities = entries.flat_map { |entry| entry[:capabilities] }.uniq.sort
          report[:capabilities] = {
            total_nodes: entries.size,
            pure_nodes: entries.count { |entry| entry[:pure] },
            impure_nodes: entries.count { |entry| !entry[:pure] },
            unique_capabilities: unique_capabilities,
            by_capability: unique_capabilities.each_with_object({}) do |capability, memo|
              memo[capability] = entries.count { |entry| entry[:capabilities].include?(capability) }
            end,
            nodes: entries
          }
          report
        end

        def append_text(report:, lines:)
          capabilities = report[:capabilities]
          return unless capabilities

          lines << "Capabilities: #{summary(capabilities)}"
        end

        def append_markdown_summary(report:, lines:)
          capabilities = report[:capabilities]
          return unless capabilities

          lines << "- Capabilities: #{summary(capabilities)}"
        end

        def append_markdown_sections(report:, lines:)
          capabilities = report[:capabilities]
          return unless capabilities

          lines << ""
          lines << "## Capabilities"
          lines << "- Summary: nodes=#{capabilities[:total_nodes]}, pure=#{capabilities[:pure_nodes]}, impure=#{capabilities[:impure_nodes]}, unique=#{list_or_none(capabilities[:unique_capabilities])}"
          capabilities[:nodes].each do |entry|
            lines << "- `#{entry[:node_name]}` executor=`#{entry[:executor_class] || "anonymous"}` capabilities=#{entry[:capabilities].join(", ")} pure=#{entry[:pure]}"
          end
        end

        private

        def capability_entries(execution)
          compiled_graph = execution.compiled_graph
          nodes = compiled_graph.nodes + compiled_graph.outputs

          nodes.each_with_object([]) do |node, memo|
            executor_class = executor_for(node)
            next unless executor_class

            capabilities = Array(executor_class.declared_capabilities).map(&:to_sym).uniq.sort
            next if capabilities.empty?

            memo << {
              node_name: node.name,
              executor_class: executor_class.name,
              capabilities: capabilities,
              pure: executor_class.pure?
            }
          end
        end

        def executor_for(node)
          callable = node.respond_to?(:callable) ? node.callable : nil
          callable ||= node.respond_to?(:adapter_class) ? node.adapter_class : nil
          return nil unless callable.is_a?(Class) && callable <= Igniter::Executor

          callable
        end

        def summary(capabilities)
          [
            "nodes=#{capabilities[:total_nodes]}",
            "pure=#{capabilities[:pure_nodes]}",
            "impure=#{capabilities[:impure_nodes]}",
            "unique=#{list_or_none(capabilities[:unique_capabilities])}"
          ].join(", ")
        end

        def list_or_none(values)
          array = Array(values)
          return "none" if array.empty?

          array.join("|")
        end
      end
    end
  end
end
