#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"

module HumanAgentReadableContractsFixture
  REVIEW_TIME = "2026-05-06T14:00:00Z"
  AGENT_REF = "agent/fixture-codex-001"
  HUMAN_REF = "human/fixture-operator-001"
  COMPANY_REF = "company/fixture-acme"
  SCHEDULE_REF = "schedule/fixture-s-200"
  ORDER_REF = "order/fixture-o-200"
  DOMAIN = "synthetic_spark_like_operation_action"
  DRAFT_ID = "idea/appointment-cancel-action/draft-001"
  CONTRACT_V0 = "intent_contract/appointment-cancel/v0"
  CONTRACT_V1 = "intent_contract/appointment-cancel/v1"
  REVIEW_V0 = "review/appointment-cancel/v0"
  REVIEW_V1 = "review/appointment-cancel/v1"
  MEANING_DIFF_ID = "meaning_diff/appointment-cancel/v0-v1"
  VERIFICATION_ID = "runtime_verification/appointment-cancel/v1"
  ACCEPTANCE_ID = "acceptance/appointment-cancel/v1"
  SESSION_ID = "session/human-agent-readable-contracts-fixture-v0"
  RUNTIME_REF = "runtime/synthetic-fixture"

  module Canonical
    module_function

    def normalize(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) { |key, out| out[key.to_s] = normalize(value[key]) }
      when Array
        value.map { |item| normalize(item) }
      when Symbol
        value.to_s
      else
        value
      end
    end

    def json(value)
      JSON.generate(normalize(value))
    end

    def hash(value)
      "sha256:#{Digest::SHA256.hexdigest(json(value))}"
    end

    def short_hash(value)
      hash(value).split(":").last[0, 16]
    end
  end

  class Proof
    def initialize
      @observations = []
    end

    def self.positive
      new.positive
    end

    def self.prose_without_contract
      new.prose_without_contract
    end

    def self.acceptance_without_verification
      new.acceptance_without_verification
    end

    def self.effect_right_change_without_diff
      new.effect_right_change_without_diff
    end

    def self.stale_review_projection_acceptance
      new.stale_review_projection_acceptance
    end

    def self.escape_without_capability
      new.escape_without_capability
    end

    def positive
      draft_packet = emit_artifact("idea_draft", DRAFT_ID, idea_draft)
      v0_packet = emit_artifact("intent_contract", CONTRACT_V0, intent_contract_v0)
      proposal = agent_proposal_observation(draft_packet, v0_packet)
      review_v0 = review_projection(intent_contract_v0, REVIEW_V0)
      v1_packet = emit_artifact("intent_contract", CONTRACT_V1, intent_contract_v1)
      review_v1 = review_projection(intent_contract_v1, REVIEW_V1)
      diff = meaning_diff(v0_packet, v1_packet)
      correction = human_correction_receipt(diff, v0_packet, v1_packet)
      verification = runtime_verification_receipt(v1_packet)
      acceptance = acceptance_receipt(v1_packet, review_v1, verification)

      result("positive").merge(
        "idea_draft" => idea_draft,
        "intent_contract_v0" => intent_contract_v0.merge("artifact_hash" => v0_packet.fetch("payload_hash")),
        "agent_proposal_observation" => proposal,
        "review_projection_v0" => review_v0,
        "intent_contract_v1" => intent_contract_v1.merge("artifact_hash" => v1_packet.fetch("payload_hash")),
        "review_projection_v1" => review_v1,
        "meaning_diff" => diff,
        "human_correction_receipt" => correction,
        "runtime_verification_receipt" => verification,
        "acceptance_receipt" => acceptance
      )
    end

    def prose_without_contract
      failure(
        "human_agent.prose_not_artifact_of_record",
        "Agent prose cannot be accepted without a contract artifact",
        source: "agent prose",
        accepted_contract_ref: nil
      )
      result("prose_without_contract")
    end

    def acceptance_without_verification
      failure(
        "human_agent.acceptance_requires_runtime_verification",
        "AcceptanceReceipt requires runtime verification evidence",
        accepted_contract_ref: CONTRACT_V1,
        runtime_verification_ref: nil
      )
      result("acceptance_without_verification")
    end

    def effect_right_change_without_diff
      failure(
        "meaning_diff.required_for_effect_right_change",
        "Effect-right changes require MeaningDiff evidence",
        text_diff: "changed action_kind field",
        meaning_diff_ref: nil,
        effect_rights_changed: true
      )
      result("effect_right_change_without_diff")
    end

    def stale_review_projection_acceptance
      failure(
        "review_projection.contract_ref_mismatch",
        "Acceptance must link to current ReviewProjection for accepted contract",
        review_projection_ref: REVIEW_V0,
        review_projection_contract_ref: CONTRACT_V0,
        accepted_contract_ref: CONTRACT_V1
      )
      result("stale_review_projection_acceptance")
    end

    def escape_without_capability
      failure(
        "effect_right.escape_capability_missing",
        "New ESCAPE effect right requires explicit capability requirement",
        meaning_diff_ref: "meaning_diff/grants-bridge-effect",
        added_effect_rights: ["create_external_bridge_record"],
        capability_requirement: nil
      )
      result("escape_without_capability")
    end

    private

    def idea_draft
      {
        "kind" => "IdeaDraft",
        "draft_id" => DRAFT_ID,
        "author_ref" => AGENT_REF,
        "created_at" => "2026-05-06T13:50:00Z",
        "prose_summary" => "Let technicians cancel appointments from the action menu.",
        "target_domain" => DOMAIN,
        "known_gaps" => [
          "request_vs_execution_not_confirmed",
          "bridge_capability_not_confirmed",
          "schedule_mutation_policy_not_confirmed"
        ],
        "artifact_status" => "not_record"
      }
    end

    def intent_contract_v0
      {
        "kind" => "IntentContract",
        "contract_id" => CONTRACT_V0,
        "contract_schema_version" => "intent_contract@0.1.0",
        "contract_kind" => "operation_action",
        "action" => "appointment_cancel_request",
        "action_kind" => "execution",
        "subject_scope" => {
          "company_ref" => COMPANY_REF,
          "subject_kind" => "schedule",
          "schedule_ref" => SCHEDULE_REF,
          "order_ref" => ORDER_REF
        },
        "effect_rights" => [
          "create_operation_request",
          "mutate_schedule_status",
          "create_external_bridge_record"
        ],
        "capability_requirements" => [],
        "assumptions" => [
          "technician can manage own appointment",
          "cancel request should mark schedule canceled"
        ],
        "evidence_requirements" => [
          "ActorObservation",
          "ScheduleStateObservation",
          "ActionPolicyProjection"
        ],
        "expected_receipts" => ["OperationExecutionReceipt"],
        "risk_declarations" => ["may affect appointment lifecycle"],
        "artifact_status" => "proposed"
      }
    end

    def intent_contract_v1
      {
        "kind" => "IntentContract",
        "contract_id" => CONTRACT_V1,
        "contract_schema_version" => "intent_contract@0.1.0",
        "contract_kind" => "operation_action",
        "action" => "appointment_cancel_request",
        "action_kind" => "request",
        "subject_scope" => {
          "company_ref" => COMPANY_REF,
          "subject_kind" => "schedule",
          "schedule_ref" => SCHEDULE_REF,
          "order_ref" => ORDER_REF
        },
        "effect_rights" => ["create_operation_request"],
        "denied_effect_rights" => [
          "mutate_schedule_status",
          "create_external_bridge_record_without_capability"
        ],
        "capability_requirements" => [
          {
            "effect_right" => "create_external_bridge_record",
            "required_when" => "optional_external_bridge_receipt_requested",
            "capability_ref" => "capability/external_bridge_create@fixture"
          }
        ],
        "assumptions" => [
          "technician can request cancellation for own manageable appointment",
          "request creates pending review workflow",
          "request does not cancel the schedule"
        ],
        "evidence_requirements" => [
          "ActorObservation",
          "ScheduleStateObservation",
          "ActionPolicyProjection",
          "duplicate_pending_request_check"
        ],
        "expected_receipts" => [
          "OperationRequestReceipt",
          "optional ExternalBridgeReceipt only when capability-gated"
        ],
        "risk_declarations" => [
          "duplicate pending request must be suppressed",
          "schedule mutation requires separate execution contract"
        ],
        "artifact_status" => "corrected"
      }
    end

    def agent_proposal_observation(draft_packet, contract_packet)
      payload = {
        "kind" => "AgentProposalObservation",
        "agent_ref" => AGENT_REF,
        "idea_draft_ref" => DRAFT_ID,
        "idea_draft_hash" => draft_packet.fetch("payload_hash"),
        "proposed_contract_ref" => CONTRACT_V0,
        "proposed_contract_hash" => contract_packet.fetch("payload_hash"),
        "proposed_at" => "2026-05-06T13:51:00Z",
        "status" => "proposal"
      }
      packet = obs(
        kind: "proposal_observation",
        subject: "obs/agent-proposal/appointment-cancel/v0",
        payload: payload,
        lifecycle: "session",
        links: [link("derived_from", draft_packet.fetch("id")), link("proposes", contract_packet.fetch("id"))]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def review_projection(contract, projection_id)
      v0 = contract.fetch("contract_id") == CONTRACT_V0
      risks = if v0
                [
                  "request action is granting mutation rights",
                  "bridge effect has no capability gate",
                  "expected receipt kind is execution, not request"
                ]
              else
                [
                  "request action cannot mutate schedule",
                  "optional bridge effect is capability-gated",
                  "duplicate pending request requires suppression"
                ]
              end
      payload = {
        "kind" => "ReviewProjection",
        "projection_id" => projection_id,
        "contract_ref" => contract.fetch("contract_id"),
        "contract_hash" => Canonical.hash(contract),
        "intent" => {
          "action" => contract.fetch("action"),
          "claimed_kind" => contract.fetch("action_kind"),
          "human_summary" => "Technician cancel action"
        },
        "effect_rights" => effect_right_review(contract),
        "assumptions" => contract.fetch("assumptions"),
        "evidence_requirements" => contract.fetch("evidence_requirements"),
        "expected_receipts" => contract.fetch("expected_receipts"),
        "risks" => risks,
        "generated_at" => REVIEW_TIME
      }
      packet = obs(
        kind: "projection_observation",
        subject: projection_id,
        payload: payload,
        lifecycle: "session",
        links: [link("projects", contract.fetch("contract_id"))]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def effect_right_review(contract)
      rights = contract.fetch("effect_rights").each_with_object({}) { |right, out| out[right] = "requested" }
      contract.fetch("denied_effect_rights", []).each { |right| rights[right] = "denied" }
      rights
    end

    def meaning_diff(v0_packet, v1_packet)
      payload = {
        "kind" => "MeaningDiff",
        "diff_id" => MEANING_DIFF_ID,
        "before_contract_ref" => CONTRACT_V0,
        "before_contract_hash" => v0_packet.fetch("payload_hash"),
        "after_contract_ref" => CONTRACT_V1,
        "after_contract_hash" => v1_packet.fetch("payload_hash"),
        "changed_intent" => { "action_kind" => ["execution", "request"] },
        "changed_effect_rights" => {
          "removed" => ["mutate_schedule_status", "create_external_bridge_record"],
          "added_denials" => ["create_external_bridge_record_without_capability"]
        },
        "changed_assumptions" => {
          "removed" => ["cancel request should mark schedule canceled"],
          "added" => ["request creates pending review workflow", "request does not cancel the schedule"]
        },
        "changed_evidence_requirements" => { "added" => ["duplicate_pending_request_check"] },
        "changed_expected_receipts" => {
          "removed" => ["OperationExecutionReceipt"],
          "added" => ["OperationRequestReceipt", "optional ExternalBridgeReceipt only when capability-gated"]
        },
        "risk_delta" => {
          "schedule_mutation_risk" => "reduced",
          "bridge_escape_risk" => "gated"
        },
        "requires_reverification" => true
      }
      packet = obs(
        kind: "diff_observation",
        subject: MEANING_DIFF_ID,
        payload: payload,
        lifecycle: "session",
        links: [link("before", v0_packet.fetch("id")), link("after", v1_packet.fetch("id"))]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def human_correction_receipt(diff, v0_packet, v1_packet)
      payload = {
        "kind" => "HumanCorrectionReceipt",
        "receipt_id" => "human_correction/appointment-cancel/v0-v1",
        "reviewer_ref" => HUMAN_REF,
        "before_contract_ref" => CONTRACT_V0,
        "before_contract_hash" => v0_packet.fetch("payload_hash"),
        "after_contract_ref" => CONTRACT_V1,
        "after_contract_hash" => v1_packet.fetch("payload_hash"),
        "meaning_diff_ref" => diff.fetch("diff_id"),
        "correction_reason" => "request_action_must_not_mutate_schedule",
        "corrected_at" => "2026-05-06T14:05:00Z",
        "status" => "corrected"
      }
      packet = obs(
        kind: "receipt_observation",
        subject: payload.fetch("receipt_id"),
        payload: payload,
        lifecycle: "audit",
        links: [link("materializes", diff.fetch("obs_id"))]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def runtime_verification_receipt(v1_packet)
      payload = {
        "kind" => "RuntimeVerificationReceipt",
        "receipt_id" => VERIFICATION_ID,
        "verified_contract_ref" => CONTRACT_V1,
        "verified_contract_hash" => v1_packet.fetch("payload_hash"),
        "checks" => {
          "parsed_program" => "ok",
          "classified_program" => "ok",
          "typed_program" => "ok",
          "semantic_ir_no_unresolved_effects" => "ok",
          "request_execution_boundary" => "ok",
          "denied_effect_rights_enforced" => "ok",
          "bridge_capability_requirement" => "ok"
        },
        "status" => "verified"
      }
      packet = obs(
        kind: "receipt_observation",
        subject: VERIFICATION_ID,
        payload: payload,
        lifecycle: "audit",
        links: [link("verifies", v1_packet.fetch("id")), link("observed_under", RUNTIME_REF)]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def acceptance_receipt(v1_packet, review_v1, verification)
      payload = {
        "kind" => "AcceptanceReceipt",
        "receipt_id" => ACCEPTANCE_ID,
        "reviewer_ref" => HUMAN_REF,
        "accepted_contract_ref" => CONTRACT_V1,
        "accepted_contract_hash" => v1_packet.fetch("payload_hash"),
        "review_projection_ref" => REVIEW_V1,
        "review_projection_contract_ref" => review_v1.fetch("contract_ref"),
        "review_projection_contract_hash" => review_v1.fetch("contract_hash"),
        "runtime_verification_ref" => VERIFICATION_ID,
        "runtime_verification_status" => verification.fetch("status"),
        "accepted_at" => "2026-05-06T14:10:00Z",
        "accepted_scope" => {
          "domain" => DOMAIN,
          "production_effects_allowed" => false
        },
        "status" => "accepted_for_fixture"
      }
      packet = obs(
        kind: "receipt_observation",
        subject: ACCEPTANCE_ID,
        payload: payload,
        lifecycle: "audit",
        links: [link("accepts", v1_packet.fetch("id")), link("reviewed_as", review_v1.fetch("obs_id")), link("verified_by", verification.fetch("obs_id"))]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def emit_artifact(kind, subject, payload)
      obs(
        kind: "#{kind}_artifact",
        subject: subject,
        payload: payload,
        lifecycle: "durable",
        links: [link("produced_in", SESSION_ID)]
      )
    end

    def failure(diagnostic, message, context = {})
      obs(
        kind: "failure_observation",
        subject: "human_agent_failure/#{diagnostic}",
        payload: {
          "status" => "blocked",
          "diagnostic" => diagnostic,
          "message" => message,
          "context" => context
        },
        lifecycle: "session",
        links: [link("observed_under", RUNTIME_REF)]
      )
    end

    def result(case_name)
      { "case" => case_name, "observations" => Canonical.normalize(@observations) }
    end

    def obs(kind:, subject:, payload:, lifecycle:, links:)
      packet = {
        "id" => nil,
        "kind" => kind,
        "subject" => subject,
        "payload" => Canonical.normalize(payload),
        "payload_hash" => Canonical.hash(payload),
        "temporal" => { "as_of" => REVIEW_TIME, "lifecycle" => lifecycle },
        "links" => Canonical.normalize(links)
      }
      packet["id"] = "obs/#{Canonical.short_hash(packet.reject { |key, _| key == "id" })}"
      @observations << packet
      packet
    end

    def link(rel, ref)
      { "rel" => rel, "ref" => ref, "required" => true }
    end
  end

  module Checker
    module_function

    def call
      results = {
        "positive" => Proof.positive,
        "prose_without_contract" => Proof.prose_without_contract,
        "acceptance_without_verification" => Proof.acceptance_without_verification,
        "effect_right_change_without_diff" => Proof.effect_right_change_without_diff,
        "stale_review_projection_acceptance" => Proof.stale_review_projection_acceptance,
        "escape_without_capability" => Proof.escape_without_capability
      }
      checks = [
        check("positive.v0_proposed_not_accepted", v0_proposed_not_accepted?(results.fetch("positive"))),
        check("positive.v1_corrected_request_only", v1_corrected_request_only?(results.fetch("positive"))),
        check("positive.meaning_diff_complete", meaning_diff_complete?(results.fetch("positive"))),
        check("positive.correction_links_diff", correction_links_diff?(results.fetch("positive"))),
        check("positive.runtime_verification", runtime_verification?(results.fetch("positive"))),
        check("positive.acceptance_links_current_review_and_verification", acceptance_links?(results.fetch("positive"))),
        check("negative.prose_without_contract_blocked", failure?(results.fetch("prose_without_contract"), "human_agent.prose_not_artifact_of_record")),
        check("negative.acceptance_without_verification_blocked", failure?(results.fetch("acceptance_without_verification"), "human_agent.acceptance_requires_runtime_verification")),
        check("negative.effect_right_change_requires_diff", failure?(results.fetch("effect_right_change_without_diff"), "meaning_diff.required_for_effect_right_change")),
        check("negative.stale_review_projection_blocked", failure?(results.fetch("stale_review_projection_acceptance"), "review_projection.contract_ref_mismatch")),
        check("negative.escape_without_capability_blocked", failure?(results.fetch("escape_without_capability"), "effect_right.escape_capability_missing")),
        check("safety.synthetic_only", synthetic_only?(results))
      ]
      { "checks" => checks, "results" => results }
    end

    def v0_proposed_not_accepted?(result)
      proposal = result.fetch("agent_proposal_observation")
      v0 = result.fetch("intent_contract_v0")
      acceptance = result.fetch("acceptance_receipt")
      proposal.fetch("status") == "proposal" &&
        v0.fetch("artifact_status") == "proposed" &&
        acceptance.fetch("accepted_contract_ref") != CONTRACT_V0
    end

    def v1_corrected_request_only?(result)
      v1 = result.fetch("intent_contract_v1")
      v1.fetch("action_kind") == "request" &&
        v1.fetch("effect_rights") == ["create_operation_request"] &&
        v1.fetch("denied_effect_rights").include?("mutate_schedule_status") &&
        v1.fetch("capability_requirements").any? { |req| req.fetch("effect_right") == "create_external_bridge_record" }
    end

    def meaning_diff_complete?(result)
      diff = result.fetch("meaning_diff")
      diff.fetch("changed_intent").fetch("action_kind") == ["execution", "request"] &&
        diff.fetch("changed_effect_rights").fetch("removed").include?("mutate_schedule_status") &&
        diff.fetch("changed_assumptions").fetch("added").include?("request does not cancel the schedule") &&
        diff.fetch("changed_evidence_requirements").fetch("added").include?("duplicate_pending_request_check") &&
        diff.fetch("changed_expected_receipts").fetch("added").include?("OperationRequestReceipt") &&
        diff.fetch("risk_delta").fetch("bridge_escape_risk") == "gated" &&
        diff.fetch("requires_reverification") == true
    end

    def correction_links_diff?(result)
      correction = result.fetch("human_correction_receipt")
      correction.fetch("meaning_diff_ref") == MEANING_DIFF_ID &&
        correction.fetch("before_contract_ref") == CONTRACT_V0 &&
        correction.fetch("after_contract_ref") == CONTRACT_V1 &&
        correction.fetch("status") == "corrected"
    end

    def runtime_verification?(result)
      verification = result.fetch("runtime_verification_receipt")
      verification.fetch("status") == "verified" &&
        verification.fetch("checks").values.all? { |status| status == "ok" } &&
        verification.fetch("verified_contract_ref") == CONTRACT_V1
    end

    def acceptance_links?(result)
      acceptance = result.fetch("acceptance_receipt")
      review = result.fetch("review_projection_v1")
      verification = result.fetch("runtime_verification_receipt")
      acceptance.fetch("status") == "accepted_for_fixture" &&
        acceptance.fetch("accepted_contract_ref") == CONTRACT_V1 &&
        acceptance.fetch("review_projection_ref") == REVIEW_V1 &&
        acceptance.fetch("review_projection_contract_ref") == CONTRACT_V1 &&
        acceptance.fetch("review_projection_contract_hash") == review.fetch("contract_hash") &&
        acceptance.fetch("runtime_verification_ref") == VERIFICATION_ID &&
        verification.fetch("status") == "verified" &&
        acceptance.fetch("accepted_scope").fetch("production_effects_allowed") == false
    end

    def failure?(result, diagnostic)
      result.fetch("observations").any? do |obs|
        obs.fetch("kind") == "failure_observation" &&
          obs.fetch("payload").fetch("diagnostic") == diagnostic &&
          obs.fetch("payload").fetch("status") == "blocked"
      end
    end

    def synthetic_only?(results)
      text = JSON.generate(results)
      forbidden = %w[
        http://
        https://
        token
        secret
        password
        endpoint
        raw_provider_payload
        provider_config
        customer
        phone
        email
        infrastructure
      ]
      forbidden.none? { |item| text.include?(item) }
    end

    def check(name, ok)
      { "name" => name, "ok" => ok }
    end
  end

  module CLI
    module_function

    def run(argv)
      result = Checker.call
      if argv.delete("--dump")
        puts JSON.pretty_generate(Canonical.normalize(result.fetch("results")))
        return true
      end
      print_result(result)
      result.fetch("checks").all? { |check| check.fetch("ok") }
    end

    def print_result(result)
      ok = result.fetch("checks").all? { |check| check.fetch("ok") }
      puts "#{ok ? "PASS" : "FAIL"} human_agent_readable_contracts_fixture"
      result.fetch("checks").each do |check|
        puts "#{check.fetch("name")}: #{check.fetch("ok") ? "ok" : "fail"}"
      end
      positive = result.fetch("results").fetch("positive")
      diff = positive.fetch("meaning_diff")
      acceptance = positive.fetch("acceptance_receipt")
      puts "v0: #{positive.fetch("intent_contract_v0").fetch("action_kind")} rights=#{positive.fetch("intent_contract_v0").fetch("effect_rights").join(",")}"
      puts "v1: #{positive.fetch("intent_contract_v1").fetch("action_kind")} rights=#{positive.fetch("intent_contract_v1").fetch("effect_rights").join(",")}"
      puts "meaning_diff: action_kind=#{diff.fetch("changed_intent").fetch("action_kind").join("->")} requires_reverification=#{diff.fetch("requires_reverification")}"
      puts "acceptance: #{acceptance.fetch("status")} verified_by=#{acceptance.fetch("runtime_verification_ref")}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = HumanAgentReadableContractsFixture::CLI.run(ARGV)
  exit(success ? 0 : 1)
end
