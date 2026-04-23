# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Cluster::MemoryIncidentRegistry do
  def build_report(status:, resolution:)
    incident = Igniter::Cluster::ClusterIncident.new(
      kind: :degraded_health,
      status: status,
      severity: :high,
      targets: ["order-42"],
      source_names: [:fallback_node],
      destination_names: [:pricing_node]
    )

    recovery_timeline = Igniter::Cluster::RecoveryTimeline.new(
      kind: :degraded_health,
      status: status,
      event_log: Igniter::Cluster::ClusterEventLog.new(
        events: [
          Igniter::Cluster::ClusterEvent.new(kind: :incident_detected, status: status),
          Igniter::Cluster::ClusterEvent.new(kind: :recovery_outcome, status: resolution)
        ]
      )
    )

    Igniter::Cluster::PlanExecutionReport.new(
      plan_kind: :failover,
      status: status,
      plan: Igniter::Cluster::FailoverPlan.new(
        mode: :failover,
        steps: [],
        metadata: {}
      ),
      action_results: [],
      incident: incident,
      recovery_timeline: recovery_timeline
    )
  end

  it "keeps durable incident history while exposing only latest unresolved incidents as active" do
    registry = described_class.new

    registry.record(build_report(status: :failed, resolution: :unresolved))
    registry.record(build_report(status: :completed, resolution: :recovered))

    expect(registry.entries.map(&:to_h)).to contain_exactly(
      include(
        id: "degraded_health/1",
        sequence: 1,
        active: true,
        resolution: :unresolved,
        incident: include(kind: :degraded_health, targets: ["order-42"])
      ),
      include(
        id: "degraded_health/2",
        sequence: 2,
        active: false,
        resolution: :recovered,
        incident: include(kind: :degraded_health, targets: ["order-42"])
      )
    )
    expect(registry.active_set).to be_empty
    expect(registry.active_set.to_h).to include(
      count: 0,
      incident_keys: []
    )
  end
end
