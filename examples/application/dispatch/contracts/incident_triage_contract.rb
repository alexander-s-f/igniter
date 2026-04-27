# frozen_string_literal: true

require "igniter/contracts"

module Dispatch
  module Contracts
    class IncidentTriageContract
      SEVERITY_RANK = {
        "low" => 1,
        "medium" => 2,
        "high" => 3,
        "critical" => 4
      }.freeze

      def self.evaluate(incident:, events:, runbooks:, teams:, checkpoint: nil)
        new(
          incident: incident,
          events: events,
          runbooks: runbooks,
          teams: teams,
          checkpoint: checkpoint
        ).evaluate
      end

      def initialize(incident:, events:, runbooks:, teams:, checkpoint: nil)
        @incident = incident
        @events = events
        @runbooks = runbooks
        @teams = teams
        @checkpoint = checkpoint || {}
      end

      def evaluate
        result = Igniter::Contracts.with.run(inputs: contract_inputs) do
          input :incident
          input :events
          input :runbooks
          input :teams
          input :checkpoint

          compute :event_facts, depends_on: [:events] do |events:|
            IncidentTriageContract.event_facts(events)
          end

          compute :severity, depends_on: [:event_facts] do |event_facts:|
            IncidentTriageContract.severity(event_facts)
          end

          compute :suspected_cause, depends_on: %i[event_facts runbooks] do |event_facts:, runbooks:|
            IncidentTriageContract.suspected_cause(event_facts, runbooks)
          end

          compute :routing_options, depends_on: %i[incident event_facts runbooks teams] do |incident:, event_facts:, runbooks:, teams:|
            IncidentTriageContract.routing_options(incident, event_facts, runbooks, teams)
          end

          compute :assignment_readiness, depends_on: %i[event_facts routing_options checkpoint] do |event_facts:, routing_options:, checkpoint:|
            IncidentTriageContract.assignment_readiness(event_facts, routing_options, checkpoint)
          end

          compute :handoff_readiness, depends_on: %i[assignment_readiness checkpoint] do |assignment_readiness:, checkpoint:|
            IncidentTriageContract.handoff_readiness(assignment_readiness, checkpoint)
          end

          compute :incident_receipt_payload, depends_on: %i[incident event_facts severity suspected_cause routing_options assignment_readiness handoff_readiness checkpoint] do |incident:, event_facts:, severity:, suspected_cause:, routing_options:, assignment_readiness:, handoff_readiness:, checkpoint:|
            IncidentTriageContract.receipt_payload(
              incident,
              event_facts,
              severity,
              suspected_cause,
              routing_options,
              assignment_readiness,
              handoff_readiness,
              checkpoint
            )
          end

          output :event_facts
          output :severity
          output :suspected_cause
          output :routing_options
          output :assignment_readiness
          output :handoff_readiness
          output :incident_receipt_payload
        end

        {
          incident: incident,
          events: events,
          runbooks: runbooks,
          teams: teams,
          event_facts: result.output(:event_facts),
          severity: result.output(:severity),
          suspected_cause: result.output(:suspected_cause),
          routing_options: result.output(:routing_options),
          assignment_readiness: result.output(:assignment_readiness),
          handoff_readiness: result.output(:handoff_readiness),
          incident_receipt_payload: result.output(:incident_receipt_payload)
        }.freeze
      end

      def self.event_facts(events)
        events.map do |event|
          {
            id: event.fetch(:id),
            kind: event.fetch(:kind),
            service: event.fetch(:service),
            signal: event.fetch(:signal),
            summary: event_summary(event),
            severity_hint: event.fetch(:severity_hint, "medium"),
            citation: event.fetch(:citation),
            source_path: event.fetch(:source_path)
          }.freeze
        end.freeze
      end

      def self.severity(facts)
        facts.map { |fact| fact.fetch(:severity_hint) }.max_by { |hint| SEVERITY_RANK.fetch(hint, 0) } || "medium"
      end

      def self.suspected_cause(facts, runbooks)
        text = [facts, runbooks].flatten.map(&:values).join(" ").downcase
        return "migration" if text.include?("undefined") || text.include?("migration")
        return "deploy" if text.include?("deploy")
        return "capacity" if text.include?("threshold")

        "unknown"
      end

      def self.routing_options(incident, facts, runbooks, teams)
        ids = [incident.fetch(:default_route)]
        ids.concat(runbooks.map { |runbook| runbook.fetch(:owner) })
        ids.concat(runbooks.map { |runbook| runbook.fetch(:escalation) }) if escalation_signal?(facts, runbooks)
        ids &= teams.map { |team| team.fetch(:id) }
        ids.uniq.map do |id|
          team = teams.find { |entry| entry.fetch(:id) == id }
          {
            team: id,
            role: team.fetch(:role),
            rationale: route_rationale(id, incident, runbooks)
          }.freeze
        end.freeze
      end

      def self.assignment_readiness(facts, options, checkpoint)
        team = checkpoint.fetch(:team, nil)
        type = checkpoint.fetch(:type, nil)
        reason = checkpoint.fetch(:reason, nil).to_s.strip
        option = options.find { |entry| entry.fetch(:team) == team }
        ready = facts.any? && option && %i[assignment escalation].include?(type)
        ready &&= !reason.empty? if type == :escalation
        {
          ready: !!ready,
          type: ready ? type : nil,
          team: ready ? team : nil,
          missing: readiness_missing_reason(facts, option, type, reason)
        }.freeze
      end

      def self.handoff_readiness(assignment_readiness, checkpoint)
        {
          ready: assignment_readiness.fetch(:ready),
          checkpoint: assignment_readiness.fetch(:ready) ? checkpoint : {},
          missing: assignment_readiness.fetch(:missing)
        }.freeze
      end

      def self.receipt_payload(incident, facts, severity, cause, options, assignment_readiness, handoff_readiness, checkpoint)
        {
          incident: {
            id: incident.fetch(:id),
            title: incident.fetch(:title),
            service: incident.fetch(:service),
            started_at: incident.fetch(:started_at)
          },
          severity: severity,
          suspected_cause: cause,
          routing: {
            options: options,
            checkpoint: checkpoint,
            assignment_ready: assignment_readiness.fetch(:ready),
            handoff_ready: handoff_readiness.fetch(:ready)
          },
          evidence_refs: facts.map do |fact|
            {
              event_id: fact.fetch(:id),
              citation: fact.fetch(:citation),
              source_path: fact.fetch(:source_path),
              summary: fact.fetch(:summary)
            }.freeze
          end.freeze,
          provenance: {
            contract: "dispatch_incident_triage:v1",
            source_paths: facts.map { |fact| fact.fetch(:source_path) }.sort
          },
          deferred: [
            { code: :no_live_monitoring, reason: "Dispatch reads seeded incident fixtures only." },
            { code: :no_queue_runtime, reason: "No timers, queues, schedulers, or background workers run." },
            { code: :no_connectors, reason: "PagerDuty, Slack, log, metric, and deploy connectors remain out of scope." },
            { code: :no_remediation_execution, reason: "No shell command or production remediation is executed." },
            { code: :no_llm_triage, reason: "Severity, cause, and routing are deterministic fixture-derived outputs." },
            { code: :no_cluster_placement, reason: "The POC is one-process and app-local." }
          ].freeze,
          valid: handoff_readiness.fetch(:ready)
        }.freeze
      end

      def self.event_summary(event)
        case event.fetch(:kind)
        when "metric"
          "#{event.fetch(:signal)}=#{event.fetch(:value)} threshold=#{event.fetch(:threshold)}"
        when "deploy"
          "#{event.fetch(:service)} #{event.fetch(:version)} deployed at #{event.fetch(:deployed_at)}"
        when "log"
          event.fetch(:message)
        when "runbook"
          "runbook #{event.fetch(:runbook_id)} matched #{event.fetch(:match)}"
        else
          event.fetch(:signal)
        end
      end

      def self.escalation_signal?(facts, runbooks)
        text = [facts, runbooks].flatten.map(&:values).join(" ").downcase
        text.include?("undefined") || text.include?("critical") || text.include?("rollback-risk")
      end

      def self.route_rationale(team_id, incident, runbooks)
        runbook = runbooks.find { |entry| [entry.fetch(:owner), entry.fetch(:escalation)].include?(team_id) }
        return "default route for #{incident.fetch(:service)}" unless runbook
        return "runbook owner for #{runbook.fetch(:service)}" if runbook.fetch(:owner) == team_id

        "runbook escalation for #{runbook.fetch(:service)}"
      end

      def self.readiness_missing_reason(facts, option, type, reason)
        return :no_events if facts.empty?
        return :invalid_checkpoint unless %i[assignment escalation].include?(type)
        return :unknown_team unless option
        return :blank_escalation_reason if type == :escalation && reason.empty?

        nil
      end

      private

      attr_reader :incident, :events, :runbooks, :teams, :checkpoint

      def contract_inputs
        {
          incident: incident,
          events: events,
          runbooks: runbooks,
          teams: teams,
          checkpoint: checkpoint
        }
      end
    end
  end
end
