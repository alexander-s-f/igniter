# frozen_string_literal: true

require "time"
require_relative "capability_profile"
require_relative "note_store"

module Companion
  module Shared
    module StackOverview
      module_function

      def build
        deployment = Companion::Stack.deployment_snapshot
        notes = Companion::Shared::NoteStore.all
        nodes = deployment.fetch("nodes", {}).transform_values do |config|
          {
            role: config["role"],
            public: config["public"],
            port: config["port"],
            host: config["host"],
            command: config["command"],
            mounts: config.fetch("mounts", {}),
            environment: config.fetch("environment", {})
          }
        end
        routing = routing_snapshot

        {
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
            discovered_peers: CapabilityProfile.discovered_peers.size,
            trusted_peers: CapabilityProfile.discovered_peers.count { |peer| peer.dig(:trust, :status) == :trusted },
            routing_plans: routing[:plan_count]
          },
          notes: notes.first(8),
          current_node: CapabilityProfile.discovery_snapshot,
          routing: routing,
          discovered_peers: CapabilityProfile.discovered_peers,
          nodes: nodes,
          apps: deployment.fetch("apps").transform_values do |config|
            {
              path: config["path"],
              class_name: config["class_name"],
              default: config["default"]
            }
          end
        }
      end

      def routing_snapshot
        report = Igniter::Cluster::Mesh.config.current_routing_report
        routing = Hash(report&.dig(:routing) || {})
        trail = Igniter::Cluster::Mesh.config.governance_trail.snapshot(limit: 8)
        latest_tick = Array(trail[:events]).reverse.find { |event| event[:type] == :routing_self_heal_tick }

        {
          active: !routing.empty?,
          total: routing.fetch(:total, 0),
          pending: routing.fetch(:pending, 0),
          failed: routing.fetch(:failed, 0),
          plan_count: Array(routing[:plans]).size,
          incidents: Hash(routing.dig(:facets, :by_incident) || {}),
          plan_actions: Hash(routing.dig(:facets, :by_plan_action) || {}),
          entries: Array(routing[:entries]).first(5).map do |entry|
            {
              node_name: entry[:node_name],
              status: entry[:status],
              routing_trace_summary: entry[:routing_trace_summary]
            }
          end,
          latest_self_heal_tick: latest_tick && {
            type: latest_tick[:type],
            timestamp: latest_tick[:timestamp],
            payload: latest_tick[:payload]
          }
        }
      rescue StandardError
        {
          active: false,
          total: 0,
          pending: 0,
          failed: 0,
          plan_count: 0,
          incidents: {},
          plan_actions: {},
          entries: [],
          latest_self_heal_tick: nil
        }
      end
    end
  end
end
