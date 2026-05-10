#!/usr/bin/env ruby
# frozen_string_literal: true

# Bounded proof for C1-A Blocker 1 (S3-R28-C1-P):
#   compliance_posture.production_durable_audit is derived from approved store
#   identity and verification results only — not from caller assertion.
#
# Proves:
#   - Proof-local storage kinds cannot emit production_durable_audit: true
#   - Unknown/test storage kinds cannot emit production_durable_audit: true
#   - ledger_binding: true blocks production_durable_audit: true
#   - chain_verified: false blocks production_durable_audit: true
#   - signature_verified: false blocks production_durable_audit: true
#   - Only a valid production storage kind + chain_verified + signature_verified
#     combination may emit production_durable_audit: true
#   - Caller-supplied value is ignored; the evaluator is the sole source

require "json"
require "fileutils"
require "pathname"

module ProductionDurableAuditCompliancePostureProof
  ROOT         = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR      = ROOT / "igniter-lang/experiments/production_durable_audit_compliance_posture_proof/out"
  SUMMARY_PATH = OUT_DIR / "production_durable_audit_compliance_posture_proof_summary.json"
  PROOF_AS_OF  = "2026-05-10T00:00:00Z"

  # ---------------------------------------------------------------------------
  # CompliancePostureEvaluator
  #
  # Sole source of truth for production_durable_audit boolean.
  # Caller-provided values are not accepted.
  # ---------------------------------------------------------------------------
  module CompliancePostureEvaluator
    ACCEPTED_PRODUCTION_KINDS = %w[phase1_production_audit_store].freeze
    PROOF_LOCAL_KINDS         = %w[proof_local_file proof_local_jsonl proof_local_memory].freeze

    module_function

    def evaluate(storage_identity:, chain_verified:, signature_verified:)
      return false if storage_identity.nil?

      kind = storage_identity["kind"].to_s
      return false if PROOF_LOCAL_KINDS.include?(kind)
      return false unless ACCEPTED_PRODUCTION_KINDS.include?(kind)
      return false if storage_identity["ledger_binding"] == true
      return false unless chain_verified == true
      return false unless signature_verified == true

      true
    end

    def build_compliance_posture(storage_identity:, chain_verified:, signature_verified:,
                                 caller_claim: nil)
      # caller_claim is deliberately ignored; production_durable_audit is always derived
      {
        "audit_ready"                 => true,
        "production_durable_audit"    => evaluate(
          storage_identity:   storage_identity,
          chain_verified:     chain_verified,
          signature_verified: signature_verified
        ),
        "production_compliance_claim" => false,
        "compliance_regimes"          => []
      }
    end
  end

  # ---------------------------------------------------------------------------
  # Fixtures
  # ---------------------------------------------------------------------------

  PROOF_LOCAL_FILE_STORAGE = {
    "kind"           => "proof_local_file",
    "storage_id"     => "proof-local/file",
    "ledger_binding" => false
  }.freeze

  PROOF_LOCAL_JSONL_STORAGE = {
    "kind"           => "proof_local_jsonl",
    "storage_id"     => "proof-local/jsonl",
    "ledger_binding" => false
  }.freeze

  PROOF_LOCAL_MEMORY_STORAGE = {
    "kind"           => "proof_local_memory",
    "storage_id"     => "proof-local/memory",
    "ledger_binding" => false
  }.freeze

  UNKNOWN_KIND_STORAGE = {
    "kind"           => "custom_audit_backend",
    "storage_id"     => "custom/v1",
    "ledger_binding" => false
  }.freeze

  TEST_STORE_STORAGE = {
    "kind"           => "test_audit_store",
    "storage_id"     => "test/v1",
    "ledger_binding" => false
  }.freeze

  LEDGER_BOUND_STORAGE = {
    "kind"           => "phase1_production_audit_store",
    "storage_id"     => "audit/gate3/phase1/prod/us-east-1/shard-1",
    "provider"       => "managed_append_only_store",
    "environment"    => "production",
    "ledger_binding" => true
  }.freeze

  VALID_PRODUCTION_STORAGE = {
    "kind"           => "phase1_production_audit_store",
    "storage_id"     => "audit/gate3/phase1/production/us-east-1/shard-1",
    "provider"       => "managed_append_only_store",
    "environment"    => "production",
    "ledger_binding" => false
  }.freeze

  module_function

  # ---------------------------------------------------------------------------
  # Checks
  # ---------------------------------------------------------------------------

  def check_proof_local_file_kind_blocked
    !CompliancePostureEvaluator.evaluate(
      storage_identity:   PROOF_LOCAL_FILE_STORAGE,
      chain_verified:     true,
      signature_verified: true
    )
  end

  def check_proof_local_jsonl_kind_blocked
    !CompliancePostureEvaluator.evaluate(
      storage_identity:   PROOF_LOCAL_JSONL_STORAGE,
      chain_verified:     true,
      signature_verified: true
    )
  end

  def check_proof_local_memory_kind_blocked
    !CompliancePostureEvaluator.evaluate(
      storage_identity:   PROOF_LOCAL_MEMORY_STORAGE,
      chain_verified:     true,
      signature_verified: true
    )
  end

  def check_nil_storage_identity_blocked
    !CompliancePostureEvaluator.evaluate(
      storage_identity:   nil,
      chain_verified:     true,
      signature_verified: true
    )
  end

  def check_unknown_kind_blocked
    !CompliancePostureEvaluator.evaluate(
      storage_identity:   UNKNOWN_KIND_STORAGE,
      chain_verified:     true,
      signature_verified: true
    )
  end

  def check_test_store_kind_blocked
    !CompliancePostureEvaluator.evaluate(
      storage_identity:   TEST_STORE_STORAGE,
      chain_verified:     true,
      signature_verified: true
    )
  end

  def check_ledger_binding_true_blocked
    !CompliancePostureEvaluator.evaluate(
      storage_identity:   LEDGER_BOUND_STORAGE,
      chain_verified:     true,
      signature_verified: true
    )
  end

  def check_chain_unverified_blocked
    !CompliancePostureEvaluator.evaluate(
      storage_identity:   VALID_PRODUCTION_STORAGE,
      chain_verified:     false,
      signature_verified: true
    )
  end

  def check_signature_unverified_blocked
    !CompliancePostureEvaluator.evaluate(
      storage_identity:   VALID_PRODUCTION_STORAGE,
      chain_verified:     true,
      signature_verified: false
    )
  end

  def check_both_verifications_failed_blocked
    !CompliancePostureEvaluator.evaluate(
      storage_identity:   VALID_PRODUCTION_STORAGE,
      chain_verified:     false,
      signature_verified: false
    )
  end

  def check_production_kind_all_verified_emits_true
    CompliancePostureEvaluator.evaluate(
      storage_identity:   VALID_PRODUCTION_STORAGE,
      chain_verified:     true,
      signature_verified: true
    ) == true
  end

  def check_caller_true_claim_ignored_for_proof_local
    posture = CompliancePostureEvaluator.build_compliance_posture(
      storage_identity:   PROOF_LOCAL_FILE_STORAGE,
      chain_verified:     true,
      signature_verified: true,
      caller_claim:       true
    )
    posture["production_durable_audit"] == false
  end

  def check_caller_false_claim_ignored_for_verified_production
    posture = CompliancePostureEvaluator.build_compliance_posture(
      storage_identity:   VALID_PRODUCTION_STORAGE,
      chain_verified:     true,
      signature_verified: true,
      caller_claim:       false
    )
    posture["production_durable_audit"] == true
  end

  def check_successful_production_append_cannot_emit_false
    # A successful production append = production kind + chain verified + signature verified.
    # The evaluator MUST return true; false here would be a policy violation.
    CompliancePostureEvaluator.evaluate(
      storage_identity:   VALID_PRODUCTION_STORAGE,
      chain_verified:     true,
      signature_verified: true
    ) == true
  end

  CHECKS = %i[
    check_proof_local_file_kind_blocked
    check_proof_local_jsonl_kind_blocked
    check_proof_local_memory_kind_blocked
    check_nil_storage_identity_blocked
    check_unknown_kind_blocked
    check_test_store_kind_blocked
    check_ledger_binding_true_blocked
    check_chain_unverified_blocked
    check_signature_unverified_blocked
    check_both_verifications_failed_blocked
    check_production_kind_all_verified_emits_true
    check_caller_true_claim_ignored_for_proof_local
    check_caller_false_claim_ignored_for_verified_production
    check_successful_production_append_cannot_emit_false
  ].freeze

  def run
    FileUtils.mkdir_p(OUT_DIR)
    results = CHECKS.map { |check| [check, public_send(check)] }
    all_pass = results.all? { |_, pass| pass }
    status = all_pass ? "PASS" : "FAIL"
    summary = build_summary(results, status)
    write_summary(summary)
    print_summary(results, status)
    all_pass
  end

  def build_summary(results, status)
    {
      "kind"            => "production_durable_audit_compliance_posture_proof",
      "format_version"  => "0.1.0",
      "track"           => "production-durable-audit-blocker-amendment-and-validation-proofs-v0",
      "status"          => status,
      "verdict"         => status == "PASS" ? "compliance_posture_store_binding_proven" : "blocked",
      "proof_as_of"     => PROOF_AS_OF,
      "blocker_closed"  => "C1-A-Blocker-1",
      "blocker_signal"  => "compliance_posture.production_durable_audit is derived from approved store identity and verification only; caller assertion is not accepted",
      "evaluator_constants" => {
        "accepted_production_kinds" => CompliancePostureEvaluator::ACCEPTED_PRODUCTION_KINDS,
        "proof_local_kinds"         => CompliancePostureEvaluator::PROOF_LOCAL_KINDS
      },
      "checks" => results.map { |name, pass|
        { "name" => name.to_s.delete_prefix("check_").prepend("posture."), "status" => pass ? "PASS" : "FAIL" }
      },
      "caveat" => {
        "proof_local_only"          => true,
        "production_durable_audit"  => false,
        "implementation_authorized" => false
      }
    }
  end

  def write_summary(summary)
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
  end

  def print_summary(results, status)
    puts "#{status} production_durable_audit_compliance_posture_proof"
    results.each do |name, pass|
      label = name.to_s.delete_prefix("check_").prepend("posture.")
      puts "  #{label}: #{pass ? "ok" : "FAIL"}"
    end
    pass_count = results.count { |_, p| p }
    puts "#{pass_count}/#{results.size} PASS"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ProductionDurableAuditCompliancePostureProof.run
exit(success ? 0 : 1)
