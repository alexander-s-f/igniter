# frozen_string_literal: true

module Companion
  module Shared
    module RoutingDemo
      module_function

      def run!(scenario: "governance_gate")
        report = build_report(scenario.to_s)
        Igniter::Cluster::Mesh.config.record_routing_report!(report)
        result = Igniter::Cluster::Mesh.repair_loop.heal_once

        {
          scenario: scenario.to_s,
          report: report,
          result: result.to_h,
          trail: Igniter::Cluster::Mesh.config.governance_trail.snapshot(limit: 8)
        }
      end

      def build_report(scenario)
        case scenario
        when "peer_unreachable"
          {
            routing: {
              total: 1,
              pending: 1,
              failed: 0,
              plans: [
                {
                  action: :refresh_peer_health,
                  scope: :mesh_health,
                  automated: true,
                  requires_approval: false,
                  params: {
                    peer_name: "edge-node",
                    selected_url: "http://127.0.0.1:4668"
                  },
                  sources: [
                    {
                      node_name: :voice_sync,
                      status: :pending,
                      incident: :peer_unreachable,
                      hint_code: :restore_peer_connectivity
                    }
                  ]
                }
              ],
              facets: {
                by_incident: { peer_unreachable: 1 },
                by_plan_action: { refresh_peer_health: 1 }
              },
              entries: [
                {
                  node_name: :voice_sync,
                  status: :pending,
                  routing_trace_summary: "mode=capability eligible=0 selected=none reasons=unreachable"
                }
              ]
            }
          }
        else
          {
            routing: {
              total: 1,
              pending: 1,
              failed: 0,
              plans: [
                {
                  action: :refresh_governance_checkpoint,
                  scope: :mesh_governance,
                  automated: true,
                  requires_approval: false,
                  params: {
                    governance_keys: %i[trust latest_type blocked_events],
                    peer_candidates: ["analyst-node"]
                  },
                  sources: [
                    {
                      node_name: :analysis_result,
                      status: :pending,
                      incident: :governance_gate,
                      hint_code: :wait_for_governance_crest
                    }
                  ]
                },
                {
                  action: :relax_governance_requirements,
                  scope: :routing_governance,
                  automated: false,
                  requires_approval: true,
                  params: {
                    governance_keys: %i[trust latest_type blocked_events],
                    peer_candidates: ["analyst-node"]
                  },
                  sources: [
                    {
                      node_name: :analysis_result,
                      status: :pending,
                      incident: :governance_gate,
                      hint_code: :relax_governance_requirements
                    }
                  ]
                }
              ],
              facets: {
                by_incident: { governance_gate: 1 },
                by_plan_action: {
                  refresh_governance_checkpoint: 1,
                  relax_governance_requirements: 1
                }
              },
              entries: [
                {
                  node_name: :analysis_result,
                  status: :pending,
                  routing_trace_summary: "mode=capability eligible=0 selected=none reasons=query_mismatch"
                }
              ]
            }
          }
        end
      end
    end
  end
end
