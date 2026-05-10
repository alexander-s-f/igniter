#!/usr/bin/env ruby
# frozen_string_literal: true

# Bounded proof for C1-A Blocker 2 (S3-R28-C1-P):
#   Production signer configuration rejects nil/no-op/stub/local-test signers
#   and requires signing_key_id, signing_key_version, signing_authority_ref,
#   and non-stub verification_metadata.
#
# Proves the ProductionSignerValidator contract:
#   - nil signer → rejected
#   - nil/empty signing_key_id → rejected
#   - blocked key_id patterns (local-test, stub-, test-, no-op, noop) → rejected
#   - nil/empty signing_key_version → rejected
#   - nil/empty signing_authority_ref → rejected
#   - blocked authority_ref patterns (test-, stub-, local-) → rejected
#   - nil/empty verification_metadata → rejected
#   - stub/local public_key_source in verification_metadata → rejected
#   - Valid production signer with all required fields → accepted
#   - All rejections carry a machine-readable reason code

require "json"
require "fileutils"
require "pathname"

module ProductionDurableAuditSignerValidationProof
  ROOT         = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR      = ROOT / "igniter-lang/experiments/production_durable_audit_signer_validation_proof/out"
  SUMMARY_PATH = OUT_DIR / "production_durable_audit_signer_validation_proof_summary.json"
  PROOF_AS_OF  = "2026-05-10T00:00:00Z"

  # ---------------------------------------------------------------------------
  # ProductionSignerValidator
  #
  # Validates that a signer configuration is suitable for production use.
  # Production signers must carry real key identity and trusted verification
  # metadata. Nil, empty, stub, local-test, and no-op configurations are
  # explicitly rejected.
  # ---------------------------------------------------------------------------
  module ProductionSignerValidator
    BLOCKED_KEY_ID_EXACT   = %w[local test stub noop no-op dev development].freeze
    BLOCKED_KEY_ID_PREFIX  = %w[local-test stub- test- noop- no-op- dev-].freeze
    BLOCKED_AUTHORITY_EXACT  = %w[test stub local].freeze
    BLOCKED_AUTHORITY_PREFIX = %w[test- stub- local-].freeze
    BLOCKED_PUBLIC_KEY_SOURCE_CONTAINS = %w[stub local test].freeze

    module_function

    def validate(signer_config)
      return fail_r("audit.signer.nil_signer") if signer_config.nil?

      key_id = signer_config[:signing_key_id]
      return fail_r("audit.signer.missing_key_id") if key_id.nil?
      return fail_r("audit.signer.empty_key_id") if key_id.empty?
      if (blocked = blocked_key_id(key_id))
        return fail_r("audit.signer.untrusted_key_id:#{blocked}")
      end

      key_version = signer_config[:signing_key_version]
      return fail_r("audit.signer.missing_key_version") if key_version.nil?
      return fail_r("audit.signer.empty_key_version") if key_version.empty?

      authority_ref = signer_config[:signing_authority_ref]
      return fail_r("audit.signer.missing_authority_ref") if authority_ref.nil?
      return fail_r("audit.signer.empty_authority_ref") if authority_ref.empty?
      if (blocked = blocked_authority(authority_ref))
        return fail_r("audit.signer.untrusted_authority_ref:#{blocked}")
      end

      vm = signer_config[:verification_metadata]
      return fail_r("audit.signer.missing_verification_metadata") if vm.nil?
      return fail_r("audit.signer.empty_verification_metadata") if vm.empty?
      if (blocked = blocked_public_key_source(vm))
        return fail_r("audit.signer.untrusted_public_key_source:#{blocked}")
      end

      { valid: true, reason: nil }
    end

    def fail_r(reason)
      { valid: false, reason: reason }
    end

    def blocked_key_id(key_id)
      downcased = key_id.downcase
      return "exact:#{downcased}" if BLOCKED_KEY_ID_EXACT.include?(downcased)
      BLOCKED_KEY_ID_PREFIX.each { |p| return "prefix:#{p}" if downcased.start_with?(p) }
      nil
    end

    def blocked_authority(ref)
      downcased = ref.downcase
      return "exact:#{downcased}" if BLOCKED_AUTHORITY_EXACT.include?(downcased)
      BLOCKED_AUTHORITY_PREFIX.each { |p| return "prefix:#{p}" if downcased.start_with?(p) }
      nil
    end

    def blocked_public_key_source(vm)
      source = vm[:public_key_source].to_s.downcase
      BLOCKED_PUBLIC_KEY_SOURCE_CONTAINS.each { |b| return b if source.include?(b) }
      nil
    end
  end

  # ---------------------------------------------------------------------------
  # Fixtures
  # ---------------------------------------------------------------------------

  VALID_PRODUCTION_SIGNER = {
    signing_key_id:        "arn:aws:kms:us-east-1:123456789012:key/phase1-audit-signing-v1",
    signing_key_version:   "1",
    signing_authority_ref: "authority/signing/gate3/phase1/audit",
    verification_metadata: {
      public_key_source:       "kms:us-east-1:123456789012:key/phase1-audit-signing-v1",
      public_key_algorithm:    "RSASSA_PKCS1_V1_5_SHA_256",
      key_rotation_policy_ref: "policy/key-rotation/phase1-audit-v1"
    }
  }.freeze

  module_function

  # ---------------------------------------------------------------------------
  # Checks
  # ---------------------------------------------------------------------------

  def check_nil_signer_rejected
    r = ProductionSignerValidator.validate(nil)
    !r[:valid] && r[:reason] == "audit.signer.nil_signer"
  end

  def check_nil_signing_key_id_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_key_id: nil))
    !r[:valid] && r[:reason] == "audit.signer.missing_key_id"
  end

  def check_empty_signing_key_id_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_key_id: ""))
    !r[:valid] && r[:reason] == "audit.signer.empty_key_id"
  end

  def check_local_test_key_id_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_key_id: "local-test-hsm-key"))
    !r[:valid] && r[:reason].start_with?("audit.signer.untrusted_key_id")
  end

  def check_stub_key_id_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_key_id: "stub-signing-key"))
    !r[:valid] && r[:reason].start_with?("audit.signer.untrusted_key_id")
  end

  def check_test_prefix_key_id_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_key_id: "test-kms-key"))
    !r[:valid] && r[:reason].start_with?("audit.signer.untrusted_key_id")
  end

  def check_no_op_key_id_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_key_id: "no-op"))
    !r[:valid] && r[:reason].start_with?("audit.signer.untrusted_key_id")
  end

  def check_nil_signing_key_version_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_key_version: nil))
    !r[:valid] && r[:reason] == "audit.signer.missing_key_version"
  end

  def check_empty_signing_key_version_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_key_version: ""))
    !r[:valid] && r[:reason] == "audit.signer.empty_key_version"
  end

  def check_nil_signing_authority_ref_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_authority_ref: nil))
    !r[:valid] && r[:reason] == "audit.signer.missing_authority_ref"
  end

  def check_test_signing_authority_ref_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_authority_ref: "test-signing-authority"))
    !r[:valid] && r[:reason].start_with?("audit.signer.untrusted_authority_ref")
  end

  def check_local_signing_authority_ref_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_authority_ref: "local-signing"))
    !r[:valid] && r[:reason].start_with?("audit.signer.untrusted_authority_ref")
  end

  def check_nil_verification_metadata_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(verification_metadata: nil))
    !r[:valid] && r[:reason] == "audit.signer.missing_verification_metadata"
  end

  def check_empty_verification_metadata_rejected
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(verification_metadata: {}))
    !r[:valid] && r[:reason] == "audit.signer.empty_verification_metadata"
  end

  def check_stub_public_key_source_rejected
    vm = VALID_PRODUCTION_SIGNER[:verification_metadata].merge(public_key_source: "stub-kms-endpoint")
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(verification_metadata: vm))
    !r[:valid] && r[:reason].start_with?("audit.signer.untrusted_public_key_source")
  end

  def check_local_public_key_source_rejected
    vm = VALID_PRODUCTION_SIGNER[:verification_metadata].merge(public_key_source: "local-key-file.pem")
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(verification_metadata: vm))
    !r[:valid] && r[:reason].start_with?("audit.signer.untrusted_public_key_source")
  end

  def check_valid_production_signer_accepted
    r = ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER)
    r[:valid] == true && r[:reason].nil?
  end

  def check_rejection_carries_reason_code
    rejections = [
      ProductionSignerValidator.validate(nil),
      ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_key_id: "stub")),
      ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_key_version: nil)),
      ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(signing_authority_ref: "test")),
      ProductionSignerValidator.validate(VALID_PRODUCTION_SIGNER.merge(verification_metadata: nil))
    ]
    rejections.all? { |r| !r[:valid] && r[:reason].is_a?(String) && !r[:reason].empty? }
  end

  CHECKS = %i[
    check_nil_signer_rejected
    check_nil_signing_key_id_rejected
    check_empty_signing_key_id_rejected
    check_local_test_key_id_rejected
    check_stub_key_id_rejected
    check_test_prefix_key_id_rejected
    check_no_op_key_id_rejected
    check_nil_signing_key_version_rejected
    check_empty_signing_key_version_rejected
    check_nil_signing_authority_ref_rejected
    check_test_signing_authority_ref_rejected
    check_local_signing_authority_ref_rejected
    check_nil_verification_metadata_rejected
    check_empty_verification_metadata_rejected
    check_stub_public_key_source_rejected
    check_local_public_key_source_rejected
    check_valid_production_signer_accepted
    check_rejection_carries_reason_code
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
      "kind"            => "production_durable_audit_signer_validation_proof",
      "format_version"  => "0.1.0",
      "track"           => "production-durable-audit-blocker-amendment-and-validation-proofs-v0",
      "status"          => status,
      "verdict"         => status == "PASS" ? "signer_no_op_rejection_proven" : "blocked",
      "proof_as_of"     => PROOF_AS_OF,
      "blocker_closed"  => "C1-A-Blocker-2",
      "blocker_signal"  => "production signer configuration rejects nil/no-op/stub/local-test signers and requires trusted signing_key_id, signing_key_version, signing_authority_ref, and verification metadata",
      "validator_constants" => {
        "blocked_key_id_exact"               => ProductionSignerValidator::BLOCKED_KEY_ID_EXACT,
        "blocked_key_id_prefix"              => ProductionSignerValidator::BLOCKED_KEY_ID_PREFIX,
        "blocked_authority_exact"            => ProductionSignerValidator::BLOCKED_AUTHORITY_EXACT,
        "blocked_authority_prefix"           => ProductionSignerValidator::BLOCKED_AUTHORITY_PREFIX,
        "blocked_public_key_source_contains" => ProductionSignerValidator::BLOCKED_PUBLIC_KEY_SOURCE_CONTAINS
      },
      "checks" => results.map { |name, pass|
        { "name" => name.to_s.delete_prefix("check_").prepend("signer."), "status" => pass ? "PASS" : "FAIL" }
      },
      "caveat" => {
        "proof_local_only"          => true,
        "production_durable_audit"  => false,
        "implementation_authorized" => false,
        "signing_key_not_issued"    => true,
        "no_production_hsm_kms"     => true
      }
    }
  end

  def write_summary(summary)
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
  end

  def print_summary(results, status)
    puts "#{status} production_durable_audit_signer_validation_proof"
    results.each do |name, pass|
      label = name.to_s.delete_prefix("check_").prepend("signer.")
      puts "  #{label}: #{pass ? "ok" : "FAIL"}"
    end
    pass_count = results.count { |_, p| p }
    puts "#{pass_count}/#{results.size} PASS"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ProductionDurableAuditSignerValidationProof.run
exit(success ? 0 : 1)
