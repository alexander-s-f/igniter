# frozen_string_literal: true

require "time"
require_relative "note_store"
require_relative "../../../apps/main/support/assistant_api"

module Companion
  module Shared
    module StackOverview
      GRAPH_NODE_LIMIT = 6

      module_function

      def build
        deployment = Companion::Stack.deployment_snapshot
        notes = Companion::Shared::NoteStore.all
        assistant = Companion::Main::Support::AssistantAPI.overview
        nodes = deployment.fetch("nodes").transform_values do |config|
          {
            role: config["role"],
            public: config["public"],
            port: config["port"],
            host: config["host"],
            command: config["command"],
            mounts: config.fetch("mounts", {})
          }
        end

        overview = {
          generated_at: Time.now.utc.iso8601,
          stack: {
            name: Companion::Stack.stack_settings.dig("stack", "name"),
            root_app: deployment.dig("stack", "root_app"),
            default_node: deployment.dig("stack", "default_node"),
            mounts: deployment.dig("stack", "mounts"),
            apps: Companion::Stack.app_names.map(&:to_s)
          },
          counts: {
            apps: Companion::Stack.app_names.size,
            nodes: nodes.size,
            notes: notes.size,
            assistant_requests: assistant.dig(:summary, :total_requests),
            assistant_followups: assistant.dig(:summary, :actionable_followups)
          },
          notes: notes.first(8),
          assistant: assistant,
          nodes: nodes,
          apps: deployment.fetch("apps").transform_values do |config|
            {
              path: config["path"],
              class_name: config["class_name"],
              default: config["default"]
            }
          end
        }

        overview[:visualization] = build_visualization(overview)
        overview
      end

      def build_visualization(overview)
        assistant = overview.fetch(:assistant, {})
        summary = assistant.fetch(:summary, {})
        runtime = assistant.fetch(:runtime, {})
        nodes = overview.fetch(:nodes, {})

        {
          summary: {
            stack_name: overview.dig(:stack, :name),
            root_app: overview.dig(:stack, :root_app),
            default_node: overview.dig(:stack, :default_node),
            node_count: overview.dig(:counts, :nodes).to_i,
            public_nodes: nodes.values.count { |service| service.fetch(:public, false) },
            app_count: overview.dig(:counts, :apps).to_i,
            note_count: overview.dig(:counts, :notes).to_i,
            active_requests: summary.fetch(:pending_requests, 0).to_i,
            completed_requests: summary.fetch(:completed_requests, 0).to_i,
            actionable_followups: summary.fetch(:actionable_followups, 0).to_i,
            runtime_state: runtime.dig(:status, :state) || :manual
          },
          graph: build_graph(overview),
          timeline_entry: {
            captured_at: overview.fetch(:generated_at),
            label: "cluster snapshot",
            summary: timeline_summary(overview),
            active_requests: summary.fetch(:pending_requests, 0).to_i,
            actionable_followups: summary.fetch(:actionable_followups, 0).to_i,
            completed_requests: summary.fetch(:completed_requests, 0).to_i,
            prep_model: runtime.dig(:routing, :prep_channel, :model) || runtime.dig(:config, :model),
            runtime_state: runtime.dig(:status, :state) || :manual
          }
        }
      end

      def build_graph(overview)
        stack = overview.fetch(:stack, {})
        nodes = overview.fetch(:nodes, {})
        apps = overview.fetch(:apps, {})
        assistant = overview.fetch(:assistant, {})
        requests = Array(assistant[:requests]).first(GRAPH_NODE_LIMIT)
        followups = Array(assistant[:followups]).first(GRAPH_NODE_LIMIT)
        runtime = assistant.fetch(:runtime, {})

        graph_nodes = []
        graph_edges = []
        app_ids = {}

        stack_id = "stack:#{normalize_token(stack.fetch(:name, "companion"))}"
        graph_nodes << graph_node(
          id: stack_id,
          kind: :stack,
          label: stack.fetch(:name, "Companion"),
          status: overview.dig(:counts, :nodes).to_i.positive? ? :ready : :warming,
          detail: "root=#{stack.fetch(:root_app, "--")} · default=#{stack.fetch(:default_node, "--")}",
          emphasis: :primary
        )

        nodes.each do |name, service|
          node_id = "node:#{normalize_token(name)}"
          graph_nodes << graph_node(
            id: node_id,
            kind: :runtime_node,
            label: name,
            status: service.fetch(:public, false) ? :public : :private,
            detail: "#{service.fetch(:role)} · #{service.fetch(:host)}:#{service.fetch(:port)}",
            emphasis: stack.fetch(:default_node).to_s == name.to_s ? :primary : :normal
          )
          graph_edges << graph_edge(
            source: stack_id,
            target: node_id,
            kind: :cluster_link,
            label: service.fetch(:role),
            status: :active
          )

          service.fetch(:mounts, {}).each do |app_name, mount|
            app_id = app_ids[app_name.to_s] ||= "app:#{normalize_token(app_name)}"
            graph_edges << graph_edge(
              source: node_id,
              target: app_id,
              kind: :mount,
              label: mount,
              status: :mounted
            )
          end
        end

        apps.each do |name, config|
          app_id = app_ids[name.to_s] ||= "app:#{normalize_token(name)}"
          graph_nodes << graph_node(
            id: app_id,
            kind: :app,
            label: name,
            status: config.fetch(:default, false) ? :default : :mounted,
            detail: config.fetch(:path, "--"),
            emphasis: config.fetch(:default, false) ? :primary : :normal
          )
        end

        assistant_id = "assistant:lane"
        graph_nodes << graph_node(
          id: assistant_id,
          kind: :assistant_lane,
          label: "assistant lane",
          status: runtime.dig(:status, :state) || :manual,
          detail: assistant_lane_detail(runtime),
          emphasis: :primary
        )

        if app_ids.key?("dashboard")
          graph_edges << graph_edge(
            source: app_ids.fetch("dashboard"),
            target: assistant_id,
            kind: :surface,
            label: "/dashboard/assistant",
            status: :active
          )
        end

        if app_ids.key?("main")
          graph_edges << graph_edge(
            source: app_ids.fetch("main"),
            target: assistant_id,
            kind: :runtime,
            label: "/v1/assistant/requests",
            status: :active
          )
        end

        request_ids = {}
        requests.each do |record|
          request_id = "request:#{normalize_token(record.fetch(:id))}"
          request_ids[record.fetch(:id)] = request_id
          graph_nodes << graph_node(
            id: request_id,
            kind: :assistant_request,
            label: record.dig(:scenario, :label) || record[:scenario_label] || record.fetch(:requester, "request"),
            status: record.fetch(:status, :unknown),
            detail: truncate_text(record.fetch(:request, ""), length: 80),
            emphasis: actionable_request?(record) ? :primary : :normal
          )
          graph_edges << graph_edge(
            source: assistant_id,
            target: request_id,
            kind: :workflow,
            label: record[:runtime_model] || record[:runtime_mode] || record[:lane] || record[:status],
            status: record.fetch(:status, :unknown)
          )
        end

        followups.each do |record|
          followup_id = "followup:#{normalize_token(record.fetch(:id))}"
          graph_nodes << graph_node(
            id: followup_id,
            kind: :followup,
            label: "#{record.fetch(:node, "--")} · #{record.fetch(:action, "--")}",
            status: record.fetch(:status, :unknown),
            detail: truncate_text("#{record.fetch(:queue, "--")} · #{record.fetch(:channel, "--")}", length: 80),
            emphasis: %i[pending open acknowledged].include?(record.fetch(:status, nil)) ? :primary : :normal
          )

          parent_request = requests.find do |entry|
            Array(entry[:followup_ids]).include?(record.fetch(:id))
          end

          graph_edges << graph_edge(
            source: parent_request ? request_ids.fetch(parent_request.fetch(:id)) : assistant_id,
            target: followup_id,
            kind: :followup,
            label: record.dig(:policy, :name) || record.fetch(:queue, "--"),
            status: record.fetch(:status, :unknown)
          )
        end

        {
          nodes: graph_nodes,
          edges: graph_edges,
          legend: graph_legend
        }
      end

      def graph_node(id:, kind:, label:, status:, detail:, emphasis:)
        {
          id: id,
          kind: kind,
          label: label.to_s,
          status: status.to_s,
          detail: detail.to_s,
          emphasis: emphasis.to_s
        }
      end

      def graph_edge(source:, target:, kind:, label:, status:)
        {
          source: source,
          target: target,
          kind: kind.to_s,
          label: label.to_s,
          status: status.to_s
        }
      end

      def graph_legend
        [
          { kind: :stack, label: "Stack", description: "cluster root and default runtime entry" },
          { kind: :runtime_node, label: "Runtime Node", description: "local node replica or target host" },
          { kind: :app, label: "App", description: "mounted app surface on the node" },
          { kind: :assistant_lane, label: "Assistant Lane", description: "assistant runtime and routing state" },
          { kind: :assistant_request, label: "Assistant Request", description: "captured assistant workflow request" },
          { kind: :followup, label: "Follow-up", description: "manual orchestration action for the operator" }
        ]
      end

      def timeline_summary(overview)
        summary = overview.fetch(:assistant, {}).fetch(:summary, {})
        prep_model = overview.dig(:assistant, :runtime, :routing, :prep_channel, :model) || overview.dig(:assistant, :runtime, :config, :model)

        [
          "#{overview.dig(:counts, :nodes).to_i} nodes",
          "#{summary.fetch(:pending_requests, 0).to_i} active requests",
          "#{summary.fetch(:actionable_followups, 0).to_i} follow-ups",
          ("prep=#{prep_model}" if prep_model)
        ].compact.join(" · ")
      end

      def assistant_lane_detail(runtime)
        [
          runtime.dig(:config, :mode),
          runtime.dig(:routing, :prep_channel, :label) || runtime.dig(:config, :provider),
          runtime.dig(:routing, :prep_channel, :model) || runtime.dig(:config, :model)
        ].compact.join(" · ")
      end

      def actionable_request?(record)
        %i[pending open acknowledged].include?(record.fetch(:status, nil))
      end

      def normalize_token(value)
        value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
      end

      def truncate_text(value, length:)
        text = value.to_s.strip
        return text if text.length <= length

        "#{text[0, length - 1]}…"
      end
    end
  end
end
