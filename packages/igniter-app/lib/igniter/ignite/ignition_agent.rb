# frozen_string_literal: true

require "time"
require "igniter/agent"

module Igniter
  module Ignite
    class IgnitionAgent < Igniter::Agent
      on :execute do |payload:, **|
        plan = payload.fetch(:plan)
        runtime_units = normalize_runtime_units(payload[:runtime_units] || {})
        approved = payload[:approved] == true
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
              build_execution_entry(intent, runtime_units, now).tap do |entry|
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
            timestamp: timestamp
          }
        end

        def build_execution_entry(intent, runtime_units, timestamp)
          if intent.local_replica?
            build_local_replica_entry(intent, runtime_units, timestamp)
          else
            build_remote_entry(intent, timestamp)
          end
        end

        def build_local_replica_entry(intent, runtime_units, timestamp)
          runtime_unit = runtime_units[intent.target.id]

          return {
            intent_id: intent.id,
            target_id: intent.target.id,
            kind: intent.target.kind,
            status: :blocked,
            action: :missing_local_runtime_unit,
            capabilities: intent.requested_capabilities,
            timestamp: timestamp
          } unless runtime_unit

          {
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
            timestamp: timestamp
          }
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
            timestamp: timestamp
          }
        end

        def build_summary(entries)
          by_status = entries.each_with_object(Hash.new(0)) do |entry, result|
            result[entry.fetch(:status)] += 1
          end

          {
            total: entries.size,
            by_status: by_status.freeze,
            actionable: entries.count { |entry| %i[prepared awaiting_approval].include?(entry.fetch(:status)) },
            local_replicas: entries.count { |entry| entry.fetch(:kind) == :local_replica },
            remote_targets: entries.count { |entry| entry.fetch(:kind) == :ssh_server }
          }
        end

        def overall_status(plan, summary, approved)
          return :awaiting_approval if plan.approval_required? && !approved
          return :blocked if summary.fetch(:by_status, {}).fetch(:blocked, 0).positive?
          return :pending_remote if summary.fetch(:by_status, {}).fetch(:deferred, 0).positive?

          :prepared
        end

        def normalize_runtime_units(units)
          Hash(units).each_with_object({}) do |(name, unit), result|
            result[name.to_s] = Hash(unit)
          end
        end
      end
    end
  end
end
