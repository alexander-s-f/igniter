# frozen_string_literal: true

require "time"
require "uri"
require "igniter/agent"

module Igniter
  module Ignite
    class IgnitionAgent < Igniter::Agent
      on :execute do |payload:, **|
        plan = payload.fetch(:plan)
        runtime_units = normalize_runtime_units(payload[:runtime_units] || {})
        approved = payload[:approved] == true
        mesh = payload[:mesh]
        request_admission = payload[:request_admission] == true
        approve_pending_admission = payload[:approve_pending_admission] == true
        now = Time.now.utc.iso8601

        raise ArgumentError, "ignite execution requires an Igniter::Ignite::IgnitionPlan" unless plan.is_a?(IgnitionPlan)

        events = [
          {
            type: :ignition_started,
            plan_id: plan.id,
            intent_count: plan.intents.size,
            timestamp: now
          }
        ]

        entries =
          if plan.approval_required? && !approved
            events << {
              type: :approval_required,
              plan_id: plan.id,
              timestamp: now
            }
            plan.intents.map { |intent| approval_entry(intent, now) }
          else
            plan.intents.flat_map do |intent|
              build_execution_entry(
                intent,
                runtime_units,
                now,
                mesh: mesh,
                request_admission: request_admission,
                approve_pending_admission: approve_pending_admission
              ).tap do |entry|
                events << {
                  type: :"intent_#{entry.fetch(:status)}",
                  plan_id: plan.id,
                  intent_id: entry.fetch(:intent_id),
                  target_id: entry.fetch(:target_id),
                  timestamp: now
                }
              end
            end
          end

        summary = build_summary(entries)
        events << {
          type: :ignition_finished,
          plan_id: plan.id,
          status: overall_status(plan, summary, approved),
          timestamp: now
        }

        IgnitionReport.new(
          plan_id: plan.id,
          status: overall_status(plan, summary, approved),
          strategy: plan.strategy,
          approval_mode: plan.approval_mode,
          entries: entries,
          events: events,
          summary: summary
        )
      end

      on :confirm_join do |payload:, **|
        report = payload.fetch(:report)
        target_id = payload.fetch(:target_id).to_s
        url = normalize_join_url(payload.fetch(:url))
        mesh = payload[:mesh]
        metadata = normalize_metadata(payload[:metadata] || {})
        now = Time.now.utc.iso8601

        raise ArgumentError, "ignite join confirmation requires an Igniter::Ignite::IgnitionReport" unless report.is_a?(IgnitionReport)

        updated_entries = nil

        updated_entries = report.entries.map do |entry|
          next entry unless entry.fetch(:target_id).to_s == target_id

          confirm_join_entry(
            entry,
            report: report,
            url: url,
            mesh: mesh,
            metadata: metadata,
            timestamp: now
          )
        end

        raise KeyError, "Unknown ignition target #{target_id.inspect}" if updated_entries.equal?(nil) || updated_entries.none? { |entry| entry.fetch(:target_id).to_s == target_id }

        summary = build_summary(updated_entries)
        events = report.events + [
          {
            type: :intent_joined,
            plan_id: report.plan_id,
            target_id: target_id,
            url: url,
            timestamp: now
          },
          {
            type: :ignition_reconciled,
            plan_id: report.plan_id,
            status: overall_status_for_summary(summary),
            timestamp: now
          }
        ]

        IgnitionReport.new(
          plan_id: report.plan_id,
          status: overall_status_for_summary(summary),
          strategy: report.strategy,
          approval_mode: report.approval_mode,
          entries: updated_entries,
          events: events,
          summary: summary
        )
      end

      class << self
        private

        def approval_entry(intent, timestamp)
          {
            intent_id: intent.id,
            target_id: intent.target.id,
            kind: intent.target.kind,
            status: :awaiting_approval,
            action: :approve_ignition,
            capabilities: intent.requested_capabilities,
            admission: {
              required: true,
              status: :awaiting_approval
            },
            join: {
              required: true,
              status: :awaiting_approval
            },
            timestamp: timestamp
          }
        end

        def build_execution_entry(intent, runtime_units, timestamp, mesh:, request_admission:, approve_pending_admission:)
          if intent.local_replica?
            build_local_replica_entry(
              intent,
              runtime_units,
              timestamp,
              mesh: mesh,
              request_admission: request_admission,
              approve_pending_admission: approve_pending_admission
            )
          else
            build_remote_entry(intent, timestamp)
          end
        end

        def build_local_replica_entry(intent, runtime_units, timestamp, mesh:, request_admission:, approve_pending_admission:)
          runtime_unit = runtime_units[intent.target.id]

          return {
            intent_id: intent.id,
            target_id: intent.target.id,
            kind: intent.target.kind,
            status: :blocked,
            action: :missing_local_runtime_unit,
            capabilities: intent.requested_capabilities,
            admission: {
              required: true,
              status: :blocked
            },
            join: {
              required: true,
              status: :blocked
            },
            timestamp: timestamp
          } unless runtime_unit

          entry = {
            intent_id: intent.id,
            target_id: intent.target.id,
            kind: intent.target.kind,
            status: :prepared,
            action: :start_local_runtime_unit,
            command: runtime_unit["command"],
            host: runtime_unit["host"],
            port: runtime_unit["port"],
            environment: runtime_unit["environment"] || {},
            capabilities: intent.requested_capabilities,
            admission: {
              required: true,
              status: :pending_bootstrap
            },
            join: {
              required: true,
              status: :pending_bootstrap
            },
            timestamp: timestamp
          }

          return entry unless request_admission && mesh

          apply_admission_handshake!(
            entry,
            intent: intent,
            runtime_unit: runtime_unit,
            mesh: mesh,
            approve_pending_admission: approve_pending_admission
          )
        end

        def build_remote_entry(intent, timestamp)
          {
            intent_id: intent.id,
            target_id: intent.target.id,
            kind: intent.target.kind,
            status: :deferred,
            action: :await_remote_bootstrap,
            locator: intent.target.locator,
            capabilities: intent.requested_capabilities,
            admission: {
              required: true,
              status: :pending_bootstrap
            },
            join: {
              required: true,
              status: :pending_bootstrap
            },
            timestamp: timestamp
          }
        end

        def apply_admission_handshake!(entry, intent:, runtime_unit:, mesh:, approve_pending_admission:)
          decision = mesh.request_admission(
            peer_name: intent.target.id,
            node_id: intent.target.id,
            public_key: synthetic_public_key_for(intent),
            url: nil,
            capabilities: intent.requested_capabilities,
            justification: "ignite:#{intent.id}"
          )

          if decision.pending_approval? && approve_pending_admission
            decision = mesh.approve_admission!(decision.request.request_id)
          end

          entry[:admission] = {
            required: true,
            status: admission_status_for(decision),
            outcome: decision.outcome,
            request_id: decision.request.request_id,
            rationale: decision.rationale
          }
          entry[:join] = {
            required: true,
            status: join_status_for(decision),
            node_id: decision.request.node_id,
            peer_name: decision.request.peer_name
          }
          entry[:admission_request] = decision.request.to_h
          entry[:admission_decision] = decision.to_h
          entry[:status] = entry_status_for(decision)
          entry[:action] = action_for(decision, runtime_unit)
          entry
        rescue StandardError => e
          entry[:status] = :blocked
          entry[:action] = :admission_failed
          entry[:admission] = {
            required: true,
            status: :failed,
            error: "#{e.class}: #{e.message}"
          }
          entry[:join] = {
            required: true,
            status: :blocked
          }
          entry
        end

        def build_summary(entries)
          by_status = entries.each_with_object(Hash.new(0)) do |entry, result|
            result[entry.fetch(:status)] += 1
          end
          by_admission_status = entries.each_with_object(Hash.new(0)) do |entry, result|
            result[entry.dig(:admission, :status)] += 1 if entry.dig(:admission, :status)
          end
          by_join_status = entries.each_with_object(Hash.new(0)) do |entry, result|
            result[entry.dig(:join, :status)] += 1 if entry.dig(:join, :status)
          end

          {
            total: entries.size,
            by_status: by_status.freeze,
            by_admission_status: by_admission_status.freeze,
            by_join_status: by_join_status.freeze,
            actionable: entries.count { |entry| %i[prepared awaiting_approval].include?(entry.fetch(:status)) },
            local_replicas: entries.count { |entry| entry.fetch(:kind) == :local_replica },
            remote_targets: entries.count { |entry| entry.fetch(:kind) == :ssh_server },
            admission_required: entries.count { |entry| entry.dig(:admission, :required) },
            join_required: entries.count { |entry| entry.dig(:join, :required) }
          }
        end

        def overall_status(plan, summary, approved)
          return :awaiting_approval if plan.approval_required? && !approved
          overall_status_for_summary(summary)
        end

        def overall_status_for_summary(summary)
          return :blocked if summary.fetch(:by_status, {}).fetch(:blocked, 0).positive?
          return :awaiting_admission if summary.fetch(:by_status, {}).fetch(:awaiting_admission_approval, 0).positive?
          return :pending_remote if summary.fetch(:by_status, {}).fetch(:deferred, 0).positive?
          return :admitted if summary.fetch(:by_status, {}).fetch(:admitted, 0).positive?
          return :prepared if summary.fetch(:by_status, {}).fetch(:prepared, 0).positive?
          return :joined if summary.fetch(:by_status, {}).fetch(:joined, 0).positive?

          :prepared
        end

        def normalize_runtime_units(units)
          Hash(units).each_with_object({}) do |(name, unit), result|
            result[name.to_s] = Hash(unit)
          end
        end

        def synthetic_public_key_for(intent)
          "ignite-public-key:#{intent.id}"
        end

        def admission_status_for(decision)
          case decision.outcome
          when :admitted, :already_trusted
            :admitted
          when :pending_approval
            :awaiting_approval
          when :rejected
            :rejected
          else
            :unknown
          end
        end

        def join_status_for(decision)
          case decision.outcome
          when :admitted, :already_trusted
            :pending_runtime_boot
          when :pending_approval
            :blocked_by_admission
          when :rejected
            :blocked
          else
            :unknown
          end
        end

        def entry_status_for(decision)
          case decision.outcome
          when :admitted, :already_trusted
            :admitted
          when :pending_approval
            :awaiting_admission_approval
          when :rejected
            :blocked
          else
            :blocked
          end
        end

        def action_for(decision, _runtime_unit)
          case decision.outcome
          when :admitted, :already_trusted
            :start_local_runtime_unit
          when :pending_approval
            :approve_cluster_admission
          when :rejected
            :cluster_admission_rejected
          else
            :admission_failed
          end
        end

        def confirm_join_entry(entry, report:, url:, mesh:, metadata:, timestamp:)
          validate_joinable_entry!(entry, mesh: mesh)

          updated_entry = deep_dup(entry)
          updated_entry[:status] = :joined
          updated_entry[:action] = :runtime_joined
          updated_entry[:joined_at] = timestamp
          updated_entry[:url] = url

          updated_entry[:join] = deep_dup(updated_entry[:join] || {}).merge(
            required: true,
            status: :joined,
            url: url,
            joined_at: timestamp
          )

          if mesh
            register_joined_peer!(
              mesh: mesh,
              report: report,
              entry: updated_entry,
              url: url,
              metadata: metadata,
              timestamp: timestamp
            )
          elsif updated_entry.dig(:admission, :status) != :admitted
            updated_entry[:admission] = deep_dup(updated_entry[:admission] || {}).merge(
              required: false,
              status: :implicit_local
            )
          end

          updated_entry
        end

        def validate_joinable_entry!(entry, mesh:)
          join_status = entry.dig(:join, :status)&.to_sym
          status = entry.fetch(:status).to_sym

          raise ArgumentError, "cannot confirm join for blocked ignition target #{entry.fetch(:target_id).inspect}" if status == :blocked
          raise ArgumentError, "cannot confirm join before admission approval for #{entry.fetch(:target_id).inspect}" if mesh && entry.dig(:admission, :status)&.to_sym != :admitted
          raise ArgumentError, "ignition target #{entry.fetch(:target_id).inspect} is waiting for operator approval" if status == :awaiting_approval
          raise ArgumentError, "ignition target #{entry.fetch(:target_id).inspect} is waiting for admission approval" if status == :awaiting_admission_approval
          raise ArgumentError, "ignition target #{entry.fetch(:target_id).inspect} is not joinable from status #{status.inspect}" unless %i[prepared admitted joined].include?(status) || %i[pending_runtime_boot pending_bootstrap joined].include?(join_status)
        end

        def register_joined_peer!(mesh:, report:, entry:, url:, metadata:, timestamp:)
          node_id = entry.dig(:join, :node_id) || entry.dig(:admission_request, :node_id) || entry.fetch(:target_id).to_s
          peer_name = entry.dig(:join, :peer_name) || entry.fetch(:target_id).to_s
          fingerprint = entry.dig(:admission_request, :fingerprint)

          peer_metadata = metadata.merge(
            mesh_trust: {
              status: "trusted",
              trusted: true
            },
            mesh_identity: {
              node_id: node_id,
              fingerprint: fingerprint
            }.compact,
            mesh_ignite: {
              plan_id: report.plan_id,
              intent_id: entry.fetch(:intent_id),
              target_id: entry.fetch(:target_id),
              kind: entry.fetch(:kind),
              joined_at: timestamp
            }
          )

          peer = Igniter::Cluster::Mesh::Peer.new(
            name: peer_name,
            url: url,
            capabilities: Array(entry[:capabilities]),
            tags: [],
            metadata: Igniter::Cluster::Mesh::PeerMetadata.authoritative(
              peer_metadata,
              origin: mesh.config.peer_name,
              observed_at: Time.iso8601(timestamp)
            )
          )

          mesh.config.peer_registry.register(peer)
          mesh.config.governance_trail&.record(
            :ignite_join_confirmed,
            source: :ignition_agent,
            payload: {
              plan_id: report.plan_id,
              intent_id: entry.fetch(:intent_id),
              target_id: entry.fetch(:target_id),
              node_id: node_id,
              peer_name: peer_name,
              url: url
            }
          )
        end

        def normalize_join_url(url)
          parsed = URI.parse(url.to_s)
          raise ArgumentError, "ignite join url must include scheme and host" unless parsed.scheme && parsed.host

          parsed.to_s.chomp("/")
        rescue URI::InvalidURIError
          raise ArgumentError, "ignite join url must be a valid URI"
        end

        def normalize_metadata(metadata)
          Hash(metadata).each_with_object({}) do |(key, value), result|
            result[key.to_sym] =
              case value
              when Hash
                normalize_metadata(value)
              when Array
                value.map { |item| item.is_a?(Hash) ? normalize_metadata(item) : item }
              else
                value
              end
          end
        end

        def deep_dup(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, nested), result|
              result[key] = deep_dup(nested)
            end
          when Array
            value.map { |item| deep_dup(item) }
          else
            value
          end
        end
      end
    end
  end
end
