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
            routing_plans: routing[:plan_count],
            pending_admissions: admission_snapshot.size,
            workload_peers: workload_snapshot.size
          },
          notes: notes.first(8),
          current_node: CapabilityProfile.discovery_snapshot,
          routing: routing,
          discovered_peers: CapabilityProfile.discovered_peers,
          workload: workload_snapshot,
          governance: governance_snapshot,
          pending_admissions: admission_snapshot,
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
        trail = Igniter::Cluster::Mesh.config.governance_trail.snapshot(limit: 20)
        events = Array(trail[:events]).reverse
        latest_tick          = events.find { |e| e[:type] == :routing_self_heal_tick }
        latest_workload_tick = events.find { |e| e[:type] == :workload_self_heal_tick }

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
          },
          latest_workload_tick: latest_workload_tick && {
            type: latest_workload_tick[:type],
            timestamp: latest_workload_tick[:timestamp],
            payload: latest_workload_tick[:payload]
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
          latest_self_heal_tick: nil,
          latest_workload_tick: nil
        }
      end

      def workload_snapshot
        tracker = Igniter::Cluster::Mesh.config.workload_tracker
        return [] unless tracker

        tracker.all_reports.map do |peer_name, report|
          {
            peer_name:    peer_name,
            total:        report.total,
            failure_rate: report.failure_rate.round(3),
            avg_ms:       report.avg_duration_ms&.round(1),
            degraded:     report.degraded?,
            overloaded:   report.overloaded?,
            healthy:      report.healthy?
          }
        end.sort_by { |r| [-r[:failure_rate].to_f, r[:peer_name]] }
      rescue StandardError
        []
      end

      def governance_snapshot
        trail = Igniter::Cluster::Mesh.config.governance_trail
        snap  = trail.snapshot(limit: 20)
        store = Igniter::Cluster::Mesh.config.checkpoint_store
        cp    = store&.load

        {
          total:         snap[:total],
          by_type:       snap[:by_type] || {},
          recent_events: Array(snap[:events]).last(8).reverse.map do |ev|
            { type: ev[:type], source: ev[:source], timestamp: ev[:timestamp] }
          end,
          checkpoint: cp && {
            peer_name:       cp.peer_name,
            crest_digest:    cp.crest_digest,
            checkpointed_at: cp.checkpointed_at,
            chained:         cp.chained?
          }
        }
      rescue StandardError
        { total: 0, by_type: {}, recent_events: [], checkpoint: nil }
      end

      def admission_snapshot
        queue = Igniter::Cluster::Mesh.config.admission_queue
        return [] unless queue

        queue.pending.map do |req|
          {
            request_id:   req.request_id,
            peer_name:    req.peer_name,
            node_id:      req.node_id,
            capabilities: Array(req.capabilities),
            requested_at: req.requested_at,
            routable:     req.routable?
          }
        end
      rescue StandardError
        []
      end
    end
  end
end
