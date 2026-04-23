# frozen_string_literal: true

require_relative "../capabilities"

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
            nodes: entries,
            policy: policy_summary(entries)
          }
          report
        end

        def append_text(report:, lines:)
          capabilities = report[:capabilities]
          return unless capabilities

          lines << "Capabilities: #{summary(capabilities)}"
          lines << "Capability Policy: #{policy_text_summary(capabilities[:policy])}"
        end

        def append_markdown_summary(report:, lines:)
          capabilities = report[:capabilities]
          return unless capabilities

          lines << "- Capabilities: #{summary(capabilities)}"
          lines << "- Capability Policy: #{policy_text_summary(capabilities[:policy])}"
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
          lines << ""
          lines << "## Capability Policy"
          lines << "- Summary: #{policy_text_summary(capabilities[:policy])}"
          return unless capabilities[:policy][:configured]

          capabilities[:policy][:nodes].each do |entry|
            lines << "- `#{entry[:node_name]}` status=#{entry[:status]} allowed=#{list_or_none(entry[:allowed_capabilities])} denied=#{list_or_none(entry[:denied_capabilities])} risky=#{list_or_none(entry[:risky_capabilities])}"
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

        def policy_summary(entries)
          policy = Igniter::Capabilities.policy
          return { configured: false } unless policy

          nodes = entries.map { |entry| classify_entry(entry, policy) }
          {
            configured: true,
            denied_capabilities: Array(policy.denied).map(&:to_sym).sort,
            on_unknown: policy.on_unknown.to_sym,
            allowed_nodes: nodes.count { |entry| entry[:status] == :allowed },
            denied_nodes: nodes.count { |entry| entry[:status] == :denied },
            risky_nodes: nodes.count { |entry| entry[:status] == :risky },
            nodes: nodes
          }
        end

        def classify_entry(entry, policy)
          denied_capabilities = entry[:capabilities] & Array(policy.denied).map(&:to_sym)
          unknown_capabilities = entry[:capabilities] - Igniter::Capabilities::KNOWN
          risky_capabilities = policy.on_unknown.to_sym == :warn ? unknown_capabilities : []
          allowed_capabilities = entry[:capabilities] - denied_capabilities - risky_capabilities
          status = if denied_capabilities.any?
                     :denied
                   elsif risky_capabilities.any?
                     :risky
                   else
                     :allowed
                   end

          {
            node_name: entry[:node_name],
            status: status,
            allowed_capabilities: allowed_capabilities.sort,
            denied_capabilities: denied_capabilities.sort,
            risky_capabilities: risky_capabilities.sort
          }
        end

        def summary(capabilities)
          [
            "nodes=#{capabilities[:total_nodes]}",
            "pure=#{capabilities[:pure_nodes]}",
            "impure=#{capabilities[:impure_nodes]}",
            "unique=#{list_or_none(capabilities[:unique_capabilities])}"
          ].join(", ")
        end

        def policy_text_summary(policy)
          return "configured=false" unless policy[:configured]

          [
            "configured=true",
            "allowed=#{policy[:allowed_nodes]}",
            "denied=#{policy[:denied_nodes]}",
            "risky=#{policy[:risky_nodes]}",
            "on_unknown=#{policy[:on_unknown]}"
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
