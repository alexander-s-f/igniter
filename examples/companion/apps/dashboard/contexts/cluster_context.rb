# frozen_string_literal: true

module Companion
  module Dashboard
    module Contexts
      class ClusterContext < HomeContext
        def title
          "Companion Cluster View"
        end

        def description
          "Live cluster and assistant topology with a rewindable local history buffer."
        end

        def shell_subtitle
          "Realtime cluster and agent visualization"
        end

        def current_nav_key
          :cluster
        end

        def summary_metrics
          [
            { label: "Nodes", value: counts.fetch(:nodes, 0), hint: "runtime nodes in the current snapshot" },
            { label: "Apps", value: stack.fetch(:apps).size, hint: "mounted app surfaces across the cluster" },
            {
              label: "Follow-ups",
              value: assistant_summary.fetch(:actionable_followups, 0),
              hint: "open operator actions linked to assistant workflows"
            }
          ]
        end

        def breadcrumbs
          [
            { label: "Companion", href: operator_desk_href },
            { label: "Dashboard", href: operator_desk_href },
            { label: "Cluster View", current: true }
          ]
        end

        def operator_links
          [
            { label: "Operator Desk", href: operator_desk_href },
            { label: "Assistant Lane", href: assistant_href },
            { label: "Overview API", href: cluster_overview_path },
            { label: "Operator API", href: route("/api/operator") }
          ]
        end

        def cluster_overview_path
          route("/api/overview")
        end

        def cluster_poll_interval_seconds
          4
        end

        def cluster_bootstrap_payload
          snapshot
        end

        def cluster_visualization
          snapshot.fetch(:visualization, {})
        end

        def cluster_graph
          cluster_visualization.fetch(:graph, {})
        end

        def cluster_legend_entries
          cluster_graph.fetch(:legend, [])
        end

        def cluster_summary_rows
          summary = cluster_visualization.fetch(:summary, {})

          [
            { label: "Stack", value: summary.fetch(:stack_name, "--"), field: "visualization.summary.stack_name" },
            { label: "Default Node", value: summary.fetch(:default_node, "--"), field: "visualization.summary.default_node" },
            { label: "Nodes", value: summary.fetch(:node_count, 0), field: "visualization.summary.node_count" },
            { label: "Public Nodes", value: summary.fetch(:public_nodes, 0), field: "visualization.summary.public_nodes" },
            { label: "Active Requests", value: summary.fetch(:active_requests, 0), field: "visualization.summary.active_requests" },
            {
              label: "Actionable Follow-ups",
              value: summary.fetch(:actionable_followups, 0),
              field: "visualization.summary.actionable_followups"
            },
            { label: "Runtime State", value: summary.fetch(:runtime_state, "--"), field: "visualization.summary.runtime_state" }
          ]
        end

        def cluster_timeline_rows
          timeline = cluster_visualization.fetch(:timeline_entry, {})

          [
            { label: "Captured", value: timeline.fetch(:captured_at, generated_at), field: "visualization.timeline_entry.captured_at" },
            { label: "Summary", value: timeline.fetch(:summary, "--"), field: "visualization.timeline_entry.summary" },
            { label: "Prep Model", value: timeline.fetch(:prep_model, "--"), field: "visualization.timeline_entry.prep_model" }
          ]
        end

        def cluster_initial_focus
          cluster_graph.fetch(:nodes, []).first || {}
        end

        def cluster_raw_preview
          snapshot.slice(:generated_at, :counts, :visualization)
        end
      end
    end
  end
end
