#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"

module OsintFractalTraceabilityFixture
  AS_OF = "2026-05-06T09:40:00Z"
  SCENARIO_REF = "scenario/synthetic-public-source-station-status@1"
  SUBJECT_REF = "station/fixture-east-17"
  CITATION_POLICY = "citation_policy/synthetic-public-summary@1"
  REDACTION_POLICY = "redaction_policy/no-sensitive-fields@1"
  ANALYST_REF = "analyst/fixture-001"
  SESSION_ID = "session/osint-fractal-traceability-fixture-v0"
  RUNTIME_REF = "runtime/synthetic-fixture"

  SRC_001 = "source_obs/synthetic-bulletin-a/20260506T0900Z"
  SRC_002 = "source_obs/synthetic-social-repeat/20260506T0910Z"
  SRC_003 = "source_obs/synthetic-bulletin-b/20260506T0920Z"

  CLAIM_001 = "claim/station-fixture-east-17/status-online/src-001"
  CLAIM_002 = "claim/station-fixture-east-17/status-online/src-002-repeat"
  CLAIM_003 = "claim/station-fixture-east-17/status-offline/src-003"
  CLAIM_004 = "claim/station-fixture-east-17/status-online/inference-initial"
  CLAIM_005 = "claim/station-fixture-east-17/status-conflicted/inference-corrected"

  EV_001 = "evidence_link/ev-001"
  EV_002 = "evidence_link/ev-002"
  EV_003 = "evidence_link/ev-003"
  EV_004 = "evidence_link/ev-004"
  EV_005 = "evidence_link/ev-005"

  CONTRADICTION_ID = "contradiction/station-fixture-east-17/status-online-vs-offline"
  CONF_001 = "confidence/station-fixture-east-17/initial-online"
  CONF_002 = "confidence/station-fixture-east-17/corrected-conflicted"
  CORRECTION_ID = "correction/station-fixture-east-17/online-to-conflicted"
  SNAPSHOT_ID = "factcheck/station-fixture-east-17/asof-20260506T093500Z"
  DECISION_ID = "analyst_decision/station-fixture-east-17/report-conflicted"
  REPORT_ID = "report/station-fixture-east-17/status-asof-20260506T094000Z"

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
      @source_packets = {}
      @claim_packets = {}
      @evidence_packets = {}
    end

    def self.positive
      new.positive
    end

    def self.claim_without_source
      new.claim_without_source
    end

    def self.repetition_as_independent
      new.repetition_as_independent
    end

    def self.contradiction_omitted
      new.contradiction_omitted
    end

    def self.correction_missing_links
      new.correction_missing_links
    end

    def self.missing_citation_redaction
      new.missing_citation_redaction
    end

    def positive
      sources = source_observations.map { |source| emit_source(source) }
      claims = claim_chain.map { |claim| emit_claim(claim) }
      links = evidence_links.map { |evidence| emit_evidence_link(evidence) }
      initial_confidence = confidence_assessment(initial_confidence_payload)
      contradiction = contradiction_report
      corrected_confidence = confidence_assessment(corrected_confidence_payload)
      correction = correction_receipt
      snapshot = fact_check_snapshot
      decision = analyst_decision(snapshot)
      report = report_output(snapshot, decision)

      result("positive").merge(
        "source_observations" => sources.map { |packet| packet.fetch("payload") },
        "claims" => claims.map { |packet| packet.fetch("payload") },
        "evidence_links" => links.map { |packet| packet.fetch("payload") },
        "initial_confidence_assessment" => initial_confidence,
        "contradiction_report" => contradiction,
        "corrected_confidence_assessment" => corrected_confidence,
        "correction_receipt" => correction,
        "fact_check_snapshot" => snapshot,
        "analyst_decision" => decision,
        "report" => report
      )
    end

    def claim_without_source
      failure(
        "claim.source_observation_missing",
        "source_claim requires at least one linked SourceObservation",
        claim_kind: "source_claim",
        source_links: []
      )
      result("claim_without_source")
    end

    def repetition_as_independent
      failure(
        "evidence.repetition_not_independent_corroboration",
        "derivative repetition cannot satisfy independent corroboration",
        evidence_refs: [EV_001, EV_002],
        repeated_evidence_ref: EV_002,
        attempted_confidence_label: "high",
        reason: "two sources agree"
      )
      result("repetition_as_independent")
    end

    def contradiction_omitted
      failure(
        "report.open_contradiction_not_disclosed",
        "report must include known open contradiction and correction links",
        report_claim: "station online",
        known_contradiction_ref: CONTRADICTION_ID,
        correction_refs: []
      )
      result("contradiction_omitted")
    end

    def correction_missing_links
      failure(
        "correction.old_new_cause_links_missing",
        "CorrectionReceipt requires corrected, replacement, and cause refs",
        corrected_claim_ref: nil,
        replacement_claim_ref: CLAIM_005,
        caused_by_ref: nil
      )
      result("correction_missing_links")
    end

    def missing_citation_redaction
      failure(
        "citation_redaction.policy_missing",
        "FactCheckSnapshot and report require citation and redaction policies",
        factcheck_snapshot_ref: "factcheck/missing-citation-redaction-policy",
        citation_policy_ref: nil,
        redaction_policy_ref: nil
      )
      result("missing_citation_redaction")
    end

    private

    def source_observations
      [
        {
          "kind" => "SourceObservation",
          "source_obs_id" => SRC_001,
          "source_kind" => "synthetic_public_bulletin",
          "source_ref" => "source/synthetic-bulletin-a",
          "captured_at" => "2026-05-06T09:05:00Z",
          "observed_time" => "2026-05-06T09:00:00Z",
          "payload_summary" => "station fixture-east-17 status online",
          "citation_policy_ref" => CITATION_POLICY,
          "redaction_policy_ref" => REDACTION_POLICY,
          "provenance_status" => "direct_synthetic_source"
        },
        {
          "kind" => "SourceObservation",
          "source_obs_id" => SRC_002,
          "source_kind" => "synthetic_derivative_post",
          "source_ref" => "source/synthetic-social-repeat",
          "captured_at" => "2026-05-06T09:12:00Z",
          "observed_time" => "2026-05-06T09:10:00Z",
          "payload_summary" => "repeats station fixture-east-17 online",
          "citation_policy_ref" => CITATION_POLICY,
          "redaction_policy_ref" => REDACTION_POLICY,
          "provenance_status" => "derivative_repetition"
        },
        {
          "kind" => "SourceObservation",
          "source_obs_id" => SRC_003,
          "source_kind" => "synthetic_public_bulletin",
          "source_ref" => "source/synthetic-bulletin-b",
          "captured_at" => "2026-05-06T09:25:00Z",
          "observed_time" => "2026-05-06T09:20:00Z",
          "payload_summary" => "station fixture-east-17 status offline",
          "citation_policy_ref" => CITATION_POLICY,
          "redaction_policy_ref" => REDACTION_POLICY,
          "provenance_status" => "direct_synthetic_source"
        }
      ]
    end

    def claim_chain
      [
        claim(CLAIM_001, "status", "online", "2026-05-06T09:05:00Z", "2026-05-06T09:00:00Z", "asserted", "source_claim", [SRC_001]),
        claim(CLAIM_002, "status", "online", "2026-05-06T09:12:00Z", "2026-05-06T09:10:00Z", "asserted", "repeated_claim", [SRC_002]),
        claim(CLAIM_003, "status", "offline", "2026-05-06T09:25:00Z", "2026-05-06T09:20:00Z", "asserted", "source_claim", [SRC_003]),
        claim(CLAIM_004, "inferred_status", "online", "2026-05-06T09:15:00Z", "2026-05-06T09:00:00Z..2026-05-06T09:15:00Z", "inferred", "analyst_inference", [CLAIM_001]),
        claim(CLAIM_005, "assessed_status", "conflicted", "2026-05-06T09:35:00Z", "2026-05-06T09:00:00Z..2026-05-06T09:35:00Z", "corrected", "analyst_assessment", [CLAIM_001, CLAIM_003])
      ]
    end

    def claim(claim_id, predicate, object_value, asserted_at, valid_time, claim_status, claim_kind, source_links)
      {
        "kind" => "Claim",
        "claim_id" => claim_id,
        "subject_ref" => SUBJECT_REF,
        "predicate" => predicate,
        "object_value" => object_value,
        "asserted_at" => asserted_at,
        "valid_time" => valid_time,
        "claim_status" => claim_status,
        "claim_kind" => claim_kind,
        "source_links" => source_links,
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY
      }
    end

    def evidence_links
      [
        evidence(EV_001, SRC_001, CLAIM_001, "supports", "direct", "same_observed_time"),
        evidence(EV_002, SRC_002, CLAIM_002, "repeats", "derivative", "later_repetition"),
        evidence(EV_003, SRC_003, CLAIM_003, "supports", "direct", "same_observed_time"),
        evidence(EV_004, CLAIM_001, CLAIM_004, "supports_inference", "single_direct_source", "within_analysis_window"),
        evidence(EV_005, CLAIM_003, CONTRADICTION_ID, "contradicts", "direct_conflict", "overlapping_window")
      ]
    end

    def evidence(link_id, source_ref, target_ref, relation, strength, temporal_alignment)
      {
        "kind" => "EvidenceLink",
        "link_id" => link_id,
        "source_ref" => source_ref,
        "target_ref" => target_ref,
        "relation" => relation,
        "strength" => strength,
        "temporal_alignment" => temporal_alignment,
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY
      }
    end

    def initial_confidence_payload
      {
        "kind" => "ConfidenceAssessment",
        "assessment_id" => CONF_001,
        "target_ref" => CLAIM_004,
        "method_ref" => "confidence_method/synthetic-source-corroboration@1",
        "evidence_refs" => [EV_001, EV_002],
        "independent_direct_evidence_refs" => [EV_001],
        "derivative_evidence_refs" => [EV_002],
        "confidence_label" => "low_to_medium",
        "caveats" => ["one direct source", "one derivative repetition", "no independent corroboration"],
        "assessed_at" => "2026-05-06T09:15:00Z"
      }
    end

    def corrected_confidence_payload
      {
        "kind" => "ConfidenceAssessment",
        "assessment_id" => CONF_002,
        "target_ref" => CLAIM_005,
        "method_ref" => "confidence_method/synthetic-conflict-detection@1",
        "evidence_refs" => [EV_001, EV_003, EV_005],
        "independent_direct_evidence_refs" => [EV_001, EV_003],
        "derivative_evidence_refs" => [],
        "confidence_label" => "high_conflict_detected",
        "caveats" => ["direct sources disagree", "status cannot be resolved without newer independent evidence"],
        "assessed_at" => "2026-05-06T09:35:00Z"
      }
    end

    def contradiction_report
      payload = {
        "kind" => "ContradictionReport",
        "contradiction_id" => CONTRADICTION_ID,
        "claim_refs" => [CLAIM_001, CLAIM_003],
        "contradiction_kind" => "mutually_exclusive_status",
        "conflicting_fields" => ["object_value"],
        "temporal_overlap" => "2026-05-06T09:00:00Z..2026-05-06T09:35:00Z",
        "status" => "open"
      }
      packet = obs(
        kind: "report_observation",
        subject: CONTRADICTION_ID,
        payload: payload,
        lifecycle: "session",
        links: [link("compares", @claim_packets.fetch(CLAIM_001).fetch("id")), link("compares", @claim_packets.fetch(CLAIM_003).fetch("id"))]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def correction_receipt
      payload = {
        "kind" => "CorrectionReceipt",
        "receipt_id" => CORRECTION_ID,
        "corrected_claim_ref" => CLAIM_004,
        "replacement_claim_ref" => CLAIM_005,
        "caused_by_ref" => CONTRADICTION_ID,
        "correction_reason" => "direct_source_contradiction",
        "corrected_at" => "2026-05-06T09:35:00Z",
        "status" => "corrected"
      }
      packet = obs(
        kind: "receipt_observation",
        subject: CORRECTION_ID,
        payload: payload,
        lifecycle: "audit",
        links: [link("corrects", CLAIM_004), link("replaces_with", CLAIM_005), link("caused_by", CONTRADICTION_ID)]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def fact_check_snapshot
      payload = {
        "kind" => "FactCheckSnapshot",
        "snapshot_id" => SNAPSHOT_ID,
        "scope_ref" => SUBJECT_REF,
        "as_of" => "2026-05-06T09:35:00Z",
        "included_claim_refs" => [CLAIM_001, CLAIM_002, CLAIM_003, CLAIM_005],
        "included_source_refs" => [SRC_001, SRC_002, SRC_003],
        "included_evidence_refs" => [EV_001, EV_002, EV_003, EV_004, EV_005],
        "included_contradiction_refs" => [CONTRADICTION_ID],
        "confidence_refs" => [CONF_002],
        "correction_refs" => [CORRECTION_ID],
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY,
        "status" => "reproducible_snapshot"
      }
      packet = obs(
        kind: "snapshot_observation",
        subject: SNAPSHOT_ID,
        payload: payload,
        lifecycle: "durable",
        links: payload.fetch("included_claim_refs").map { |ref| link("contains_claim", ref) } +
          payload.fetch("included_source_refs").map { |ref| link("contains_source", ref) } +
          [link("contains_contradiction", CONTRADICTION_ID), link("contains_correction", CORRECTION_ID)]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def analyst_decision(snapshot)
      payload = {
        "kind" => "AnalystDecision",
        "decision_id" => DECISION_ID,
        "analyst_ref" => ANALYST_REF,
        "snapshot_ref" => SNAPSHOT_ID,
        "decision" => "report_conflicted_not_resolved",
        "rationale_refs" => [CONTRADICTION_ID, CONF_002],
        "decided_at" => "2026-05-06T09:40:00Z",
        "status" => "recorded"
      }
      packet = obs(
        kind: "decision_observation",
        subject: DECISION_ID,
        payload: payload,
        lifecycle: "audit",
        links: [link("based_on", snapshot.fetch("obs_id")), link("rationale", CONTRADICTION_ID), link("rationale", CONF_002)]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def report_output(snapshot, decision)
      payload = {
        "kind" => "Report",
        "report_id" => REPORT_ID,
        "headline_claim_ref" => CLAIM_005,
        "snapshot_ref" => SNAPSHOT_ID,
        "analyst_decision_ref" => DECISION_ID,
        "public_summary" => "Synthetic sources conflict on station status as of 09:35 UTC.",
        "contradiction_refs" => [CONTRADICTION_ID],
        "correction_refs" => [CORRECTION_ID],
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY,
        "status" => "published_synthetic_fixture"
      }
      packet = obs(
        kind: "report_observation",
        subject: REPORT_ID,
        payload: payload,
        lifecycle: "audit",
        links: [link("summarizes", snapshot.fetch("obs_id")), link("authorized_by", decision.fetch("obs_id"))]
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def emit_source(payload)
      packet = obs(
        kind: "source_observation",
        subject: payload.fetch("source_obs_id"),
        payload: payload,
        lifecycle: "durable",
        links: [link("scoped_to", SCENARIO_REF), link("produced_in", SESSION_ID)]
      )
      @source_packets[payload.fetch("source_obs_id")] = packet
      packet
    end

    def emit_claim(payload)
      source_links = payload.fetch("source_links")
      linked_packets = source_links.filter_map do |ref|
        @source_packets[ref] || @claim_packets[ref]
      end
      packet = obs(
        kind: "claim_observation",
        subject: payload.fetch("claim_id"),
        payload: payload,
        lifecycle: "session",
        links: linked_packets.map { |source| link("derived_from", source.fetch("id")) }
      )
      @claim_packets[payload.fetch("claim_id")] = packet
      packet
    end

    def emit_evidence_link(payload)
      packet = obs(
        kind: "evidence_link_observation",
        subject: payload.fetch("link_id"),
        payload: payload,
        lifecycle: "session",
        links: [link("source", payload.fetch("source_ref")), link("target", payload.fetch("target_ref"))]
      )
      @evidence_packets[payload.fetch("link_id")] = packet
      packet
    end

    def confidence_assessment(payload)
      packet = obs(
        kind: "confidence_assessment_observation",
        subject: payload.fetch("assessment_id"),
        payload: payload,
        lifecycle: "session",
        links: payload.fetch("evidence_refs").map { |ref| link("assesses_with", ref) }
      )
      payload.merge("obs_id" => packet.fetch("id"))
    end

    def failure(diagnostic, message, context = {})
      obs(
        kind: "failure_observation",
        subject: "osint_failure/#{diagnostic}",
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
        "temporal" => { "as_of" => AS_OF, "lifecycle" => lifecycle },
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
        "claim_without_source" => Proof.claim_without_source,
        "repetition_as_independent" => Proof.repetition_as_independent,
        "contradiction_omitted" => Proof.contradiction_omitted,
        "correction_missing_links" => Proof.correction_missing_links,
        "missing_citation_redaction" => Proof.missing_citation_redaction
      }
      checks = [
        check("positive.source_observations", source_observations?(results.fetch("positive"))),
        check("positive.claim_chain", claim_chain?(results.fetch("positive"))),
        check("positive.source_claims_link_sources", source_claims_link_sources?(results.fetch("positive"))),
        check("positive.repetition_not_independent", repetition_not_independent?(results.fetch("positive"))),
        check("positive.initial_confidence_caveated", initial_confidence_caveated?(results.fetch("positive"))),
        check("positive.contradiction_report", contradiction_report?(results.fetch("positive"))),
        check("positive.corrected_claim_and_confidence", corrected_claim_and_confidence?(results.fetch("positive"))),
        check("positive.correction_links_old_new_cause", correction_links?(results.fetch("positive"))),
        check("positive.snapshot_reproducible", snapshot_reproducible?(results.fetch("positive"))),
        check("positive.report_discloses_contradiction", report_discloses_contradiction?(results.fetch("positive"))),
        check("negative.claim_without_source_blocked", failure?(results.fetch("claim_without_source"), "claim.source_observation_missing")),
        check("negative.repetition_independence_blocked", failure?(results.fetch("repetition_as_independent"), "evidence.repetition_not_independent_corroboration")),
        check("negative.contradiction_omitted_blocked", failure?(results.fetch("contradiction_omitted"), "report.open_contradiction_not_disclosed")),
        check("negative.correction_links_missing_blocked", failure?(results.fetch("correction_missing_links"), "correction.old_new_cause_links_missing")),
        check("negative.citation_redaction_missing_blocked", failure?(results.fetch("missing_citation_redaction"), "citation_redaction.policy_missing")),
        check("safety.synthetic_only", synthetic_only?(results))
      ]
      { "checks" => checks, "results" => results }
    end

    def source_observations?(result)
      sources = result.fetch("source_observations")
      sources.length == 3 &&
        sources.count { |source| source.fetch("provenance_status") == "direct_synthetic_source" } == 2 &&
        sources.count { |source| source.fetch("provenance_status") == "derivative_repetition" } == 1 &&
        sources.all? { |source| policies_present?(source) }
    end

    def claim_chain?(result)
      claims = result.fetch("claims")
      claims.map { |claim| claim.fetch("claim_id") }.sort == [CLAIM_001, CLAIM_002, CLAIM_003, CLAIM_004, CLAIM_005].sort &&
        claims.all? { |claim| claim.fetch("valid_time") && policies_present?(claim) }
    end

    def source_claims_link_sources?(result)
      source_ids = result.fetch("source_observations").map { |source| source.fetch("source_obs_id") }
      result.fetch("claims").select { |claim| %w[source_claim repeated_claim].include?(claim.fetch("claim_kind")) }.all? do |claim|
        claim.fetch("source_links").any? && claim.fetch("source_links").all? { |ref| source_ids.include?(ref) }
      end
    end

    def repetition_not_independent?(result)
      ev002 = result.fetch("evidence_links").find { |evidence| evidence.fetch("link_id") == EV_002 }
      confidence = result.fetch("initial_confidence_assessment")
      ev002.fetch("relation") == "repeats" &&
        ev002.fetch("strength") == "derivative" &&
        confidence.fetch("independent_direct_evidence_refs") == [EV_001] &&
        confidence.fetch("derivative_evidence_refs") == [EV_002]
    end

    def initial_confidence_caveated?(result)
      confidence = result.fetch("initial_confidence_assessment")
      confidence.fetch("confidence_label") == "low_to_medium" &&
        confidence.fetch("caveats").include?("no independent corroboration")
    end

    def contradiction_report?(result)
      contradiction = result.fetch("contradiction_report")
      contradiction.fetch("claim_refs").sort == [CLAIM_001, CLAIM_003].sort &&
        contradiction.fetch("conflicting_fields") == ["object_value"] &&
        contradiction.fetch("status") == "open"
    end

    def corrected_claim_and_confidence?(result)
      corrected = result.fetch("claims").find { |claim| claim.fetch("claim_id") == CLAIM_005 }
      confidence = result.fetch("corrected_confidence_assessment")
      corrected.fetch("object_value") == "conflicted" &&
        corrected.fetch("claim_status") == "corrected" &&
        confidence.fetch("target_ref") == CLAIM_005 &&
        confidence.fetch("confidence_label") == "high_conflict_detected"
    end

    def correction_links?(result)
      correction = result.fetch("correction_receipt")
      correction.fetch("corrected_claim_ref") == CLAIM_004 &&
        correction.fetch("replacement_claim_ref") == CLAIM_005 &&
        correction.fetch("caused_by_ref") == CONTRADICTION_ID &&
        correction.fetch("status") == "corrected"
    end

    def snapshot_reproducible?(result)
      snapshot = result.fetch("fact_check_snapshot")
      snapshot.fetch("included_claim_refs").sort == [CLAIM_001, CLAIM_002, CLAIM_003, CLAIM_005].sort &&
        snapshot.fetch("included_source_refs").sort == [SRC_001, SRC_002, SRC_003].sort &&
        snapshot.fetch("included_contradiction_refs") == [CONTRADICTION_ID] &&
        snapshot.fetch("correction_refs") == [CORRECTION_ID] &&
        snapshot.fetch("status") == "reproducible_snapshot" &&
        policies_present?(snapshot)
    end

    def report_discloses_contradiction?(result)
      report = result.fetch("report")
      report.fetch("headline_claim_ref") == CLAIM_005 &&
        report.fetch("contradiction_refs") == [CONTRADICTION_ID] &&
        report.fetch("correction_refs") == [CORRECTION_ID] &&
        policies_present?(report)
    end

    def policies_present?(payload)
      payload.fetch("citation_policy_ref", nil) == CITATION_POLICY &&
        payload.fetch("redaction_policy_ref", nil) == REDACTION_POLICY
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
        credential
        private_source
        operational_instruction
        real_person
        real_org
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
      puts "#{ok ? "PASS" : "FAIL"} osint_fractal_traceability_fixture"
      result.fetch("checks").each do |check|
        puts "#{check.fetch("name")}: #{check.fetch("ok") ? "ok" : "fail"}"
      end
      positive = result.fetch("results").fetch("positive")
      initial = positive.fetch("initial_confidence_assessment")
      corrected = positive.fetch("corrected_confidence_assessment")
      report = positive.fetch("report")
      puts "sources: direct=#{positive.fetch("source_observations").count { |source| source.fetch("provenance_status") == "direct_synthetic_source" }} derivative=#{positive.fetch("source_observations").count { |source| source.fetch("provenance_status") == "derivative_repetition" }}"
      puts "initial_confidence: #{initial.fetch("confidence_label")} independent=#{initial.fetch("independent_direct_evidence_refs").length} derivative=#{initial.fetch("derivative_evidence_refs").length}"
      puts "corrected_confidence: #{corrected.fetch("confidence_label")} claim=#{corrected.fetch("target_ref")}"
      puts "report: headline=#{report.fetch("headline_claim_ref")} contradictions=#{report.fetch("contradiction_refs").length} corrections=#{report.fetch("correction_refs").length}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = OsintFractalTraceabilityFixture::CLI.run(ARGV)
  exit(success ? 0 : 1)
end
