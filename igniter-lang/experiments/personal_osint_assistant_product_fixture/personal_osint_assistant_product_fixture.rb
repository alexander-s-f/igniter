#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"

module PersonalOsintAssistantProductFixture
  AS_OF = "2026-05-06T18:00:00Z"
  OWNER_REF = "user/fixture-owner-001"
  WATCHLIST_ID = "watchlist/personal-osint/fixture-acme-payments@1"
  BRAND_REF = "brand/fixture-acme"
  VENDOR_REF = "vendor/fixture-payments"
  CITATION_POLICY = "citation_policy/synthetic-public-summary@1"
  REDACTION_POLICY = "redaction_policy/no-sensitive-fields@1"
  COLLECTION_POLICY = "collection_policy/lawful-public-synthetic@1"
  ALERT_POLICY = "alert_policy/evidence-linked-human-review@1"
  SAFE_ACTION_POLICY = "safe_action_policy/no-private-intrusion-no-external-action@1"
  SESSION_ID = "session/personal-osint-assistant-product-fixture-v0"
  RUNTIME_REF = "runtime/synthetic-fixture"

  SRC_001 = "source_obs/vendor-changelog/20260506T1000Z"
  SRC_002 = "source_obs/derivative-blog/20260506T1030Z"
  SRC_003 = "source_obs/vendor-status-note/20260506T1200Z"
  SRC_004 = "source_obs/community-repeat/20260506T1230Z"

  CLAIM_001 = "claim/vendor-payments/api-v2-deprecation/2026-07-01"
  CLAIM_002 = "claim/vendor-payments/api-v2-deprecation/2026-06-01-repeat"
  CLAIM_003 = "claim/vendor-payments/payment-latency/2026-05-06"
  CLAIM_004 = "claim/vendor-payments/payment-latency/repeated"
  CLAIM_005 = "claim/vendor-payments/api-v2-deprecation/corrected"

  EV_001 = "evidence_link/product-ev-001"
  EV_002 = "evidence_link/product-ev-002"
  EV_003 = "evidence_link/product-ev-003"
  EV_004 = "evidence_link/product-ev-004"
  EV_005 = "evidence_link/product-ev-005"

  CONTRADICTION_ID = "contradiction/vendor-payments/api-v2-deprecation-date"
  CORRECTION_ID = "correction/vendor-payments/api-v2-deprecation-date"
  SNAPSHOT_ID = "factcheck/vendor-payments/asof-20260506T180000Z"
  BRIEF_ID = "daily_brief/personal-osint/20260506"
  ALERT_ID = "contradiction_alert/vendor-payments/api-v2-deprecation-date"
  DRIFT_ID = "reputation_drift/vendor-payments/reliability/20260506"
  RELIABILITY_ID = "source_reliability/vendor-payments/20260506"
  AUDIT_ID = "audit_ready_report/vendor-payments/20260506"

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

    def self.alert_without_evidence
      new.alert_without_evidence
    end

    def self.derivative_as_corroboration
      new.derivative_as_corroboration
    end

    def self.private_target_intrusion
      new.private_target_intrusion
    end

    def self.drift_without_window
      new.drift_without_window
    end

    def self.report_omits_correction
      new.report_omits_correction
    end

    def positive
      watchlist_packet = emit_record("watchlist_observation", WATCHLIST_ID, watchlist)
      source_packets = source_observations.map { |source| emit_record("source_observation", source.fetch("source_obs_id"), source) }
      claim_packets = claims.map { |claim| emit_record("claim_observation", claim.fetch("claim_id"), claim) }
      evidence_packets = evidence_links.map { |evidence| emit_record("evidence_link_observation", evidence.fetch("link_id"), evidence) }
      reliability = source_reliability_view
      contradiction = contradiction_report
      correction = correction_receipt
      snapshot = fact_check_snapshot
      brief = daily_brief
      alert = contradiction_alert
      drift = reputation_drift_report
      audit = audit_ready_report

      result("positive").merge(
        "watchlist" => watchlist,
        "source_observations" => source_packets.map { |packet| packet.fetch("payload") },
        "claims" => claim_packets.map { |packet| packet.fetch("payload") },
        "evidence_links" => evidence_packets.map { |packet| packet.fetch("payload") },
        "source_reliability_view" => reliability,
        "contradiction_report" => contradiction,
        "correction_receipt" => correction,
        "fact_check_snapshot" => snapshot,
        "daily_brief" => brief,
        "contradiction_alert" => alert,
        "reputation_drift_report" => drift,
        "audit_ready_report" => audit,
        "watchlist_obs_id" => watchlist_packet.fetch("id")
      )
    end

    def alert_without_evidence
      failure(
        "alert.evidence_links_missing",
        "Evidence-linked alerts require at least one EvidenceLink",
        alert_kind: "reputation_risk",
        headline: "Vendor is unreliable",
        evidence_refs: []
      )
      result("alert_without_evidence")
    end

    def derivative_as_corroboration
      failure(
        "source_reliability.derivative_not_independent",
        "Derivative repetitions cannot increase independent corroboration",
        direct_source_count: 1,
        derivative_repetition_count: 3,
        confidence_label: "high_independent_confirmation"
      )
      result("derivative_as_corroboration")
    end

    def private_target_intrusion
      failure(
        "safety.private_target_intrusion_forbidden",
        "Private-target intrusion requests are outside the product boundary",
        requested_action: "collect_private_account_data",
        authorization_ref: nil
      )
      result("private_target_intrusion")
    end

    def drift_without_window
      failure(
        "reputation_drift.temporal_window_missing",
        "ReputationDriftReport requires an explicit temporal window",
        subject_ref: VENDOR_REF,
        window: nil
      )
      result("drift_without_window")
    end

    def report_omits_correction
      failure(
        "report.correction_receipt_omitted",
        "Audit-ready report must include known correction receipt",
        known_correction_ref: CORRECTION_ID,
        report_correction_refs: []
      )
      result("report_omits_correction")
    end

    private

    def watchlist
      {
        "kind" => "Watchlist",
        "watchlist_id" => WATCHLIST_ID,
        "owner_ref" => OWNER_REF,
        "subject_refs" => [BRAND_REF, VENDOR_REF],
        "collection_policy_ref" => COLLECTION_POLICY,
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY,
        "alert_policy_ref" => ALERT_POLICY,
        "safe_action_policy_ref" => SAFE_ACTION_POLICY
      }
    end

    def source_observations
      [
        source(SRC_001, "source/synthetic-vendor-changelog", "synthetic_public_changelog", "2026-05-06T10:05:00Z", "api/v2 deprecation delayed to 2026-07-01", "direct_synthetic_source"),
        source(SRC_002, "source/synthetic-derivative-blog", "synthetic_derivative_blog", "2026-05-06T10:35:00Z", "repeats old api/v2 deprecation date of 2026-06-01", "derivative_repetition"),
        source(SRC_003, "source/synthetic-status-note", "synthetic_public_status_note", "2026-05-06T12:05:00Z", "intermittent payment latency observed on 2026-05-06", "direct_synthetic_source"),
        source(SRC_004, "source/synthetic-community-repeat", "synthetic_derivative_forum", "2026-05-06T12:35:00Z", "repeats latency report without new details", "derivative_repetition")
      ]
    end

    def source(source_obs_id, source_ref, source_kind, captured_at, payload_summary, provenance_status)
      {
        "kind" => "SourceObservation",
        "source_obs_id" => source_obs_id,
        "source_kind" => source_kind,
        "source_ref" => source_ref,
        "watchlist_ref" => WATCHLIST_ID,
        "captured_at" => captured_at,
        "observed_time" => captured_at,
        "payload_summary" => payload_summary,
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY,
        "provenance_status" => provenance_status
      }
    end

    def claims
      [
        claim(CLAIM_001, "api_v2_deprecation_date", "2026-07-01", "source_claim", [SRC_001], "asserted", "2026-05-06T10:05:00Z"),
        claim(CLAIM_002, "api_v2_deprecation_date", "2026-06-01", "repeated_claim", [SRC_002], "asserted", "2026-05-06T10:35:00Z"),
        claim(CLAIM_003, "payment_latency", "intermittent", "source_claim", [SRC_003], "asserted", "2026-05-06T12:05:00Z"),
        claim(CLAIM_004, "payment_latency", "intermittent", "repeated_claim", [SRC_004], "asserted", "2026-05-06T12:35:00Z"),
        claim(CLAIM_005, "api_v2_deprecation_date", "2026-07-01", "corrected_assessment", [CLAIM_001, CONTRADICTION_ID], "corrected", "2026-05-06T17:30:00Z")
      ]
    end

    def claim(claim_id, predicate, object_value, claim_kind, source_links, claim_status, asserted_at)
      {
        "kind" => "Claim",
        "claim_id" => claim_id,
        "subject_ref" => VENDOR_REF,
        "predicate" => predicate,
        "object_value" => object_value,
        "claim_kind" => claim_kind,
        "claim_status" => claim_status,
        "source_links" => source_links,
        "asserted_at" => asserted_at,
        "valid_time" => "2026-05-06T00:00:00Z..2026-05-06T23:59:59Z",
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY
      }
    end

    def evidence_links
      [
        evidence(EV_001, SRC_001, CLAIM_001, "supports", "direct"),
        evidence(EV_002, SRC_002, CLAIM_002, "repeats", "derivative"),
        evidence(EV_003, SRC_003, CLAIM_003, "supports", "direct"),
        evidence(EV_004, SRC_004, CLAIM_004, "repeats", "derivative"),
        evidence(EV_005, CLAIM_001, CONTRADICTION_ID, "contradicts", "direct_conflict")
      ]
    end

    def evidence(link_id, source_ref, target_ref, relation, strength)
      {
        "kind" => "EvidenceLink",
        "link_id" => link_id,
        "source_ref" => source_ref,
        "target_ref" => target_ref,
        "relation" => relation,
        "strength" => strength,
        "temporal_alignment" => "within_product_day",
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY
      }
    end

    def source_reliability_view
      payload = {
        "kind" => "SourceReliabilityView",
        "view_id" => RELIABILITY_ID,
        "source_refs" => [SRC_001, SRC_002, SRC_003, SRC_004],
        "reliability_signals" => {
          "direct_source_count" => 2,
          "derivative_repetition_count" => 2,
          "correction_count" => 1,
          "contradiction_count" => 1,
          "citation_completeness" => "complete"
        },
        "derivative_counts_as_independent" => false,
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY
      }
      emit_record("view_observation", RELIABILITY_ID, payload).fetch("payload")
    end

    def contradiction_report
      payload = {
        "kind" => "ContradictionReport",
        "contradiction_id" => CONTRADICTION_ID,
        "claim_refs" => [CLAIM_001, CLAIM_002],
        "contradiction_kind" => "conflicting_deprecation_date",
        "conflicting_fields" => ["object_value"],
        "temporal_overlap" => "2026-05-06T10:05:00Z..2026-05-06T17:30:00Z",
        "status" => "resolved_by_correction"
      }
      emit_record("report_observation", CONTRADICTION_ID, payload).fetch("payload")
    end

    def correction_receipt
      payload = {
        "kind" => "CorrectionReceipt",
        "receipt_id" => CORRECTION_ID,
        "corrected_claim_ref" => CLAIM_002,
        "replacement_claim_ref" => CLAIM_005,
        "caused_by_ref" => CONTRADICTION_ID,
        "correction_reason" => "direct_source_supersedes_derivative_old_claim",
        "corrected_at" => "2026-05-06T17:30:00Z",
        "status" => "corrected"
      }
      emit_record("receipt_observation", CORRECTION_ID, payload).fetch("payload")
    end

    def fact_check_snapshot
      payload = {
        "kind" => "FactCheckSnapshot",
        "snapshot_id" => SNAPSHOT_ID,
        "watchlist_ref" => WATCHLIST_ID,
        "subject_ref" => VENDOR_REF,
        "as_of" => AS_OF,
        "source_observation_refs" => [SRC_001, SRC_002, SRC_003, SRC_004],
        "claim_refs" => [CLAIM_001, CLAIM_002, CLAIM_003, CLAIM_004, CLAIM_005],
        "evidence_link_refs" => [EV_001, EV_002, EV_003, EV_004, EV_005],
        "contradiction_refs" => [CONTRADICTION_ID],
        "correction_refs" => [CORRECTION_ID],
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY,
        "status" => "reproducible_snapshot"
      }
      emit_record("snapshot_observation", SNAPSHOT_ID, payload).fetch("payload")
    end

    def daily_brief
      payload = {
        "kind" => "DailyBrief",
        "brief_id" => BRIEF_ID,
        "owner_ref" => OWNER_REF,
        "watchlist_refs" => [WATCHLIST_ID],
        "as_of" => AS_OF,
        "sections" => {
          "priority_changes" => [
            {
              "summary" => "Vendor API v2 deprecation date corrected to 2026-07-01",
              "claim_ref" => CLAIM_005,
              "evidence_refs" => [EV_001, EV_005],
              "correction_refs" => [CORRECTION_ID]
            }
          ],
          "contradiction_alerts" => [ALERT_ID],
          "reputation_drift" => [DRIFT_ID],
          "source_reliability_changes" => [RELIABILITY_ID],
          "unresolved_claims" => []
        },
        "snapshot_refs" => [SNAPSHOT_ID],
        "evidence_required" => true,
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY
      }
      emit_record("brief_observation", BRIEF_ID, payload).fetch("payload")
    end

    def contradiction_alert
      payload = {
        "kind" => "ContradictionAlert",
        "alert_id" => ALERT_ID,
        "watchlist_ref" => WATCHLIST_ID,
        "contradiction_ref" => CONTRADICTION_ID,
        "subject_ref" => VENDOR_REF,
        "conflicting_claim_refs" => [CLAIM_001, CLAIM_002],
        "evidence_refs" => [EV_001, EV_002, EV_005],
        "temporal_overlap" => "2026-05-06T10:05:00Z..2026-05-06T17:30:00Z",
        "recommended_safe_action" => "review_sources",
        "confidence_label" => "direct_source_supersedes_derivative_with_caveat",
        "caveats" => ["derivative source repeated old date", "no external action authorized"],
        "safe_action_policy_ref" => SAFE_ACTION_POLICY,
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY,
        "status" => "ready_for_human_review"
      }
      emit_record("alert_observation", ALERT_ID, payload).fetch("payload")
    end

    def reputation_drift_report
      payload = {
        "kind" => "ReputationDriftReport",
        "report_id" => DRIFT_ID,
        "subject_ref" => VENDOR_REF,
        "window" => "2026-05-06T00:00:00Z..2026-05-06T18:00:00Z",
        "baseline_snapshot_ref" => "factcheck/vendor-payments/baseline-previous-day",
        "current_snapshot_ref" => SNAPSHOT_ID,
        "signal_deltas" => [
          {
            "signal_kind" => "service_reliability",
            "polarity" => "mild_negative",
            "claim_refs" => [CLAIM_003, CLAIM_004],
            "evidence_refs" => [EV_003, EV_004],
            "independent_direct_source_count" => 1,
            "derivative_repetition_count" => 1
          }
        ],
        "caveats" => ["evidence-limited", "no escalation without independent confirmation"],
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY,
        "status" => "caveated"
      }
      emit_record("report_observation", DRIFT_ID, payload).fetch("payload")
    end

    def audit_ready_report
      payload = {
        "kind" => "AuditReadyReport",
        "report_id" => AUDIT_ID,
        "snapshot_ref" => SNAPSHOT_ID,
        "source_observation_refs" => [SRC_001, SRC_002, SRC_003, SRC_004],
        "claim_timeline_ref" => "claim_timeline/vendor-payments/20260506",
        "claim_refs_ordered_by_valid_time" => [CLAIM_001, CLAIM_002, CLAIM_003, CLAIM_004, CLAIM_005],
        "evidence_link_refs" => [EV_001, EV_002, EV_003, EV_004, EV_005],
        "contradiction_refs" => [CONTRADICTION_ID],
        "correction_refs" => [CORRECTION_ID],
        "citation_policy_ref" => CITATION_POLICY,
        "redaction_policy_ref" => REDACTION_POLICY,
        "reproducibility_status" => "audit_ready_synthetic"
      }
      emit_record("audit_report_observation", AUDIT_ID, payload).fetch("payload")
    end

    def failure(diagnostic, message, context = {})
      emit_record(
        "failure_observation",
        "personal_osint_failure/#{diagnostic}",
        {
          "status" => "blocked",
          "diagnostic" => diagnostic,
          "message" => message,
          "context" => context
        }
      )
    end

    def emit_record(kind, subject, payload)
      packet = {
        "id" => nil,
        "kind" => kind,
        "subject" => subject,
        "payload" => Canonical.normalize(payload),
        "payload_hash" => Canonical.hash(payload),
        "temporal" => { "as_of" => AS_OF, "lifecycle" => kind == "failure_observation" ? "session" : "durable" },
        "links" => [link("produced_in", SESSION_ID), link("observed_under", RUNTIME_REF)]
      }
      packet["id"] = "obs/#{Canonical.short_hash(packet.reject { |key, _| key == "id" })}"
      @observations << packet
      packet
    end

    def result(case_name)
      { "case" => case_name, "observations" => Canonical.normalize(@observations) }
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
        "alert_without_evidence" => Proof.alert_without_evidence,
        "derivative_as_corroboration" => Proof.derivative_as_corroboration,
        "private_target_intrusion" => Proof.private_target_intrusion,
        "drift_without_window" => Proof.drift_without_window,
        "report_omits_correction" => Proof.report_omits_correction
      }
      checks = [
        check("positive.watchlist", watchlist?(results.fetch("positive"))),
        check("positive.reliability_view", reliability_view?(results.fetch("positive").fetch("source_reliability_view"))),
        check("positive.contradiction_and_correction", contradiction_and_correction?(results.fetch("positive"))),
        check("positive.daily_brief_evidence_linked", daily_brief?(results.fetch("positive").fetch("daily_brief"))),
        check("positive.alert_evidence_linked", alert?(results.fetch("positive").fetch("contradiction_alert"))),
        check("positive.reputation_drift_windowed", drift?(results.fetch("positive").fetch("reputation_drift_report"))),
        check("positive.audit_ready_report", audit_report?(results.fetch("positive").fetch("audit_ready_report"))),
        check("positive.public_outputs_have_policies", public_outputs_have_policies?(results.fetch("positive"))),
        check("negative.alert_without_evidence_blocked", failure?(results.fetch("alert_without_evidence"), "alert.evidence_links_missing")),
        check("negative.derivative_corroboration_blocked", failure?(results.fetch("derivative_as_corroboration"), "source_reliability.derivative_not_independent")),
        check("negative.private_intrusion_blocked", failure?(results.fetch("private_target_intrusion"), "safety.private_target_intrusion_forbidden")),
        check("negative.drift_without_window_blocked", failure?(results.fetch("drift_without_window"), "reputation_drift.temporal_window_missing")),
        check("negative.report_omits_correction_blocked", failure?(results.fetch("report_omits_correction"), "report.correction_receipt_omitted")),
        check("safety.synthetic_only", synthetic_only?(results))
      ]
      { "checks" => checks, "results" => results }
    end

    def watchlist?(result)
      watchlist = result.fetch("watchlist")
      watchlist.fetch("subject_refs").sort == [BRAND_REF, VENDOR_REF].sort &&
        watchlist.fetch("safe_action_policy_ref") == SAFE_ACTION_POLICY &&
        policies_present?(watchlist)
    end

    def reliability_view?(view)
      signals = view.fetch("reliability_signals")
      signals.fetch("direct_source_count") == 2 &&
        signals.fetch("derivative_repetition_count") == 2 &&
        signals.fetch("correction_count") == 1 &&
        signals.fetch("contradiction_count") == 1 &&
        view.fetch("derivative_counts_as_independent") == false &&
        policies_present?(view)
    end

    def contradiction_and_correction?(result)
      contradiction = result.fetch("contradiction_report")
      correction = result.fetch("correction_receipt")
      contradiction.fetch("claim_refs").sort == [CLAIM_001, CLAIM_002].sort &&
        correction.fetch("corrected_claim_ref") == CLAIM_002 &&
        correction.fetch("replacement_claim_ref") == CLAIM_005 &&
        correction.fetch("caused_by_ref") == CONTRADICTION_ID
    end

    def daily_brief?(brief)
      brief.fetch("evidence_required") == true &&
        brief.fetch("sections").fetch("priority_changes").all? { |item| item.fetch("evidence_refs").any? } &&
        brief.fetch("sections").fetch("contradiction_alerts") == [ALERT_ID] &&
        policies_present?(brief)
    end

    def alert?(alert)
      alert.fetch("evidence_refs").sort == [EV_001, EV_002, EV_005].sort &&
        alert.fetch("conflicting_claim_refs").sort == [CLAIM_001, CLAIM_002].sort &&
        alert.fetch("recommended_safe_action") == "review_sources" &&
        alert.fetch("status") == "ready_for_human_review" &&
        policies_present?(alert)
    end

    def drift?(drift)
      drift.fetch("window") == "2026-05-06T00:00:00Z..2026-05-06T18:00:00Z" &&
        drift.fetch("signal_deltas").fetch(0).fetch("polarity") == "mild_negative" &&
        drift.fetch("caveats").include?("evidence-limited") &&
        policies_present?(drift)
    end

    def audit_report?(report)
      report.fetch("snapshot_ref") == SNAPSHOT_ID &&
        report.fetch("correction_refs") == [CORRECTION_ID] &&
        report.fetch("contradiction_refs") == [CONTRADICTION_ID] &&
        report.fetch("evidence_link_refs").sort == [EV_001, EV_002, EV_003, EV_004, EV_005].sort &&
        report.fetch("reproducibility_status") == "audit_ready_synthetic" &&
        policies_present?(report)
    end

    def public_outputs_have_policies?(result)
      %w[
        source_reliability_view
        daily_brief
        contradiction_alert
        reputation_drift_report
        audit_ready_report
        fact_check_snapshot
      ].all? { |key| policies_present?(result.fetch(key)) }
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
        credential_theft
        phishing
        session_hijacking
        doxxing
        deanonymization
        access_bypass
        real_person
        real_org
        real_target
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
      puts "#{ok ? "PASS" : "FAIL"} personal_osint_assistant_product_fixture"
      result.fetch("checks").each do |check|
        puts "#{check.fetch("name")}: #{check.fetch("ok") ? "ok" : "fail"}"
      end
      positive = result.fetch("results").fetch("positive")
      brief = positive.fetch("daily_brief")
      alert = positive.fetch("contradiction_alert")
      drift = positive.fetch("reputation_drift_report")
      reliability = positive.fetch("source_reliability_view").fetch("reliability_signals")
      audit = positive.fetch("audit_ready_report")
      puts "brief: sections=#{brief.fetch("sections").keys.join(",")} evidence_required=#{brief.fetch("evidence_required")}"
      puts "alert: claims=#{alert.fetch("conflicting_claim_refs").length} evidence=#{alert.fetch("evidence_refs").length} action=#{alert.fetch("recommended_safe_action")}"
      puts "drift: window=#{drift.fetch("window")} polarity=#{drift.fetch("signal_deltas").fetch(0).fetch("polarity")}"
      puts "reliability: direct=#{reliability.fetch("direct_source_count")} derivative=#{reliability.fetch("derivative_repetition_count")} corrections=#{reliability.fetch("correction_count")}"
      puts "audit: corrections=#{audit.fetch("correction_refs").length} evidence=#{audit.fetch("evidence_link_refs").length} status=#{audit.fetch("reproducibility_status")}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = PersonalOsintAssistantProductFixture::CLI.run(ARGV)
  exit(success ? 0 : 1)
end
