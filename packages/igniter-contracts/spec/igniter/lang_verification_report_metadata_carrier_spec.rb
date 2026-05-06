# frozen_string_literal: true

require_relative "../spec_helper"
require "igniter/lang"

RSpec.describe Igniter::Lang::VerificationReport do
  def build_report(metadata)
    described_class.new(
      profile_fingerprint: "profile:fingerprint",
      operations: [],
      metadata: metadata
    )
  end

  it "keeps ordinary metadata small and unchanged" do
    report = build_report(source: :compiled_artifact)

    expect(report.metadata).to eq(source: :compiled_artifact)
    expect(report.metadata).to be_frozen
  end

  it "carries opaque diagnostic and receipt metadata sections with report-only semantics" do
    report = build_report(
      diagnostics: [
        {
          profile: "projection_diagnostic_v0",
          status: "blocked",
          payload: {
            projection_ref: "projection/fixture/availability",
            failure_kind: "tenant_scope_mismatch"
          }
        }
      ],
      receipts: [
        {
          profile: "operation_request_receipt_v0",
          receipt_id: "operation_request/fixture/req-001",
          payload: {
            request_status: "pending",
            side_effects_performed: false
          }
        }
      ]
    )

    expect(report).to be_ok
    expect(report.metadata.fetch(:diagnostics).first.fetch(:payload)).to include(
      projection_ref: "projection/fixture/availability"
    )
    expect(report.metadata.fetch(:receipts).first.fetch(:payload)).to include(
      side_effects_performed: false
    )
    expect(report.metadata.fetch(:semantics)).to include(
      report_only: true,
      runtime_enforced: false,
      execution_authorized: false,
      provider_call_authorized: false,
      readiness_enforced: false,
      ledger_core: false
    )
  end

  it "carries future model, scenario, and review report sections without public classes" do
    report = build_report(
      model_validity_reports: [
        {
          profile: "model_validity_report_v0",
          model_ref: "model/fixture/availability-score",
          status: "review_only"
        }
      ],
      scenario_comparison_reports: [
        {
          profile: "scenario_comparison_report_v0",
          baseline_ref: "scenario/fixture/baseline",
          candidate_ref: "scenario/fixture/candidate",
          decision: "review"
        }
      ],
      review_receipts: [
        {
          profile: "review_receipt_v0",
          reviewer_ref: "redacted:reviewer:agent",
          decision: "accepted_for_research"
        }
      ]
    )

    serialized_metadata = report.to_h.fetch(:metadata)

    expect(serialized_metadata.fetch(:model_validity_reports).first).to include(
      model_ref: "model/fixture/availability-score"
    )
    expect(serialized_metadata.fetch(:scenario_comparison_reports).first).to include(
      candidate_ref: "scenario/fixture/candidate"
    )
    expect(serialized_metadata.fetch(:review_receipts).first).to include(
      reviewer_ref: "redacted:reviewer:agent"
    )
  end

  it "adds default redaction policy when carrier sections are present" do
    report = build_report(diagnostics: [])

    expect(report.metadata.fetch(:redaction_policy)).to eq(
      raw_ref_export: false,
      hash_source_refs: true,
      redacted_ref_kinds: []
    )
  end

  it "normalizes supplied redaction policy while keeping raw ref export disabled" do
    report = build_report(
      diagnostics: [],
      redaction_policy: {
        profile: "public_metadata_v0",
        redacted_ref_kinds: %i[actor provider customer],
        raw_ref_export: false,
        hash_source_refs: true
      }
    )

    expect(report.metadata.fetch(:redaction_policy)).to include(
      profile: "public_metadata_v0",
      redacted_ref_kinds: %w[actor provider customer],
      raw_ref_export: false,
      hash_source_refs: true
    )
  end

  it "rejects raw ref export for metadata carrier sections" do
    expect do
      build_report(
        diagnostics: [],
        redaction_policy: {
          raw_ref_export: true
        }
      )
    end.to raise_error(ArgumentError, /raw_ref_export true/)
  end

  it "rejects raw refs inside opaque carrier payloads" do
    expect do
      build_report(
        diagnostics: [
          {
            profile: "pipeline_diagnostic_v0",
            payload: {
              actor_ref: "raw:actor:tech-17"
            }
          }
        ]
      )
    end.to raise_error(ArgumentError, /raw refs/)

    expect do
      build_report(
        receipts: [
          {
            profile: "operation_request_receipt_v0",
            raw_source_ref: "provider/session/001"
          }
        ]
      )
    end.to raise_error(ArgumentError, /raw refs/)
  end
end
