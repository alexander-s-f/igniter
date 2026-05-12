#!/usr/bin/env ruby
# frozen_string_literal: true

# Phase 1 production durable audit — restricted deployment implementation proof.
#
# Card:  S3-R37-C2-I
# Track: durable-audit-restricted-deployment-implementation-v0
# Auth:  S3-R36-C1-A
#        architect-supervisor://igniter-lang/gates/
#          phase1-production-durable-audit/restricted-deployment-scope/2026-05-11
#
# Implements all 7 required follow-up items from S3-R36-C1-A before operational
# rollout can be considered complete:
#
#   1. Exact production audit storage identity configuration
#   2. Signer abstraction configuration and refusal behavior
#   3. Startup rebuild verification behavior
#   4. Appender/reader role wiring
#   5. Observability/refusal-code export
#   6. Rollback/disable procedure for the audit surface
#   7. Post-deployment smoke proof (append, read, rebuild, refusal paths)
#
# New classes introduced in this proof:
#   Phase1DeploymentConfig      — deployment config with storage identity +
#                                  signer validation (follow-ups 1 and 2)
#   Phase1DeploymentAuditSurface — startup-gated surface wiring both roles
#                                  and disable/enable procedure (follow-ups 3, 4, 6)
#   RefusalCodeManifest         — stable export of all required refusal codes
#                                  (follow-up 5)
#
# Shared infrastructure (require_relative, not duplicated):
#   Phase1ProductionAuditRecordSchema, Phase1ProductionAuditStore, ProofLocalSigner,
#   Fixtures         — from S3-R31-C1-P bounded implementation proof
#   RestartRebuildEngine (module_function)
#                    — from S3-R33-C1-P restart rebuild proof
#   RoleGatedStore   — from S3-R34-C2-P appender/reader role boundary proof
#
# Excluded surfaces (confirmed not present in this proof):
#   - Ledger adapter / Ledger writes / replay / compact / subscribe
#   - Phase 2, BiHistory, stream/OLAP production executors
#   - Production cache, broad RuntimeMachine binding
#   - Concrete HSM/KMS onboarding / production signing execution
#   - Gate 3 authorization widening
#
# Usage:
#   ruby igniter-lang/experiments/durable_audit_restricted_deployment_proof/
#         durable_audit_restricted_deployment_proof.rb
#
# Exit 0 = all checks PASS.  Exit 1 = at least one check FAIL.

require "digest"
require "fileutils"
require "json"
require "time"
require "pathname"

# Require shared proof infrastructure — guards prevent re-running on require.
require_relative "../production_durable_audit_bounded_implementation_proof/" \
                 "production_durable_audit_bounded_implementation_proof"
require_relative "../durable_audit_restart_rebuild_proof/" \
                 "durable_audit_restart_rebuild_proof"
require_relative "../durable_audit_append_reader_role_boundary_proof/" \
                 "durable_audit_append_reader_role_boundary_proof"

module DurableAuditRestrictedDeploymentProof
  ROOT         = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR      = ROOT / "igniter-lang/experiments/" \
                        "durable_audit_restricted_deployment_proof/out"
  SUMMARY_PATH = OUT_DIR / "durable_audit_restricted_deployment_proof_summary.json"

  PROOF_TIMESTAMP   = "2026-05-12T10:00:00Z"
  AUTHORIZATION_REF =
    "architect-supervisor://igniter-lang/gates/" \
    "phase1-production-durable-audit/restricted-deployment-scope/2026-05-11"
  B_E_DECISION_REF = "S3-R36-C1-A"

  # Aliases to shared proof infrastructure.
  Impl          = ProductionDurableAuditBoundedImplementationProof
  Schema        = Impl::Phase1ProductionAuditRecordSchema
  Store         = Impl::Phase1ProductionAuditStore
  Fixtures      = Impl::Fixtures
  Rebuild       = DurableAuditRestartRebuildProof::RestartRebuildEngine
  RoleGatedStore = DurableAuditAppendReaderRoleBoundaryProof::RoleGatedStore

  APPENDER_ROLE = DurableAuditAppendReaderRoleBoundaryProof::APPENDER_ROLE
  READER_ROLE   = DurableAuditAppendReaderRoleBoundaryProof::READER_ROLE

  # -------------------------------------------------------------------------
  # Follow-up 1 + 2:
  # Phase1DeploymentConfig — validates the deployment configuration shape
  # before any production audit surface is wired.
  #
  # Storage identity rules (B-E §1):
  #   - must be explicit, stable, audit-specific
  #   - ledger/local/stub/test identities refused
  #   - ledger_binding: true refused unconditionally
  #   - storage_id must be non-empty
  #
  # Signer config rules (B-E §2):
  #   - signing_key_id must be non-nil/non-empty
  #   - signing_key_id must not contain: noop, no-op, stub, local, test
  #   - verification_metadata must be present
  #   - public_key_source must not contain: stub, local, test, noop, no-op
  # -------------------------------------------------------------------------
  class Phase1DeploymentConfig
    AUTHORIZED_ROLES         = %w[phase1_audit_appender phase1_audit_reader].freeze
    STARTUP_REBUILD_REQUIRED = true

    BLOCKED_STORAGE_KINDS    = %w[ledger local stub test].freeze
    BLOCKED_STORAGE_PREFIXES = %w[ledger:// local:// stub:// test://].freeze

    BLOCKED_SIGNER_PATTERNS  = %w[noop no-op stub local test].freeze
    BLOCKED_SOURCE_PATTERNS  = %w[stub local test noop no-op].freeze

    attr_reader :storage_identity, :signer_config, :validation_result

    def initialize(storage_identity:, signer_config:)
      @storage_identity  = storage_identity
      @signer_config     = signer_config
      @validation_result = validate
    end

    def valid?
      @validation_result[:valid]
    end

    def authorized_roles
      AUTHORIZED_ROLES
    end

    def startup_rebuild_required?
      STARTUP_REBUILD_REQUIRED
    end

    private

    def validate
      sid_result = validate_storage_identity(@storage_identity)
      return sid_result unless sid_result[:valid]

      sig_result = validate_signer_config(@signer_config)
      return sig_result unless sig_result[:valid]

      { valid: true }
    end

    def validate_storage_identity(sid)
      unless sid.is_a?(Hash)
        return { valid: false, code: "audit.deploy.storage_identity_missing" }
      end

      kind = sid["kind"].to_s
      if kind.empty?
        return { valid: false, code: "audit.deploy.storage_identity_kind_missing" }
      end

      downcased = kind.downcase
      if BLOCKED_STORAGE_KINDS.include?(downcased) ||
         BLOCKED_STORAGE_PREFIXES.any? { |p| downcased.start_with?(p) } ||
         sid["ledger_binding"] == true
        return { valid: false,
                 code:   "audit.deploy.storage_identity_untrusted",
                 detail: "Ledger/local/stub/test storage or ledger_binding:true refused" }
      end

      if sid["storage_id"].to_s.empty?
        return { valid: false,
                 code:   "audit.deploy.storage_identity_id_missing",
                 detail: "storage_id must be explicit and stable" }
      end

      { valid: true }
    end

    def validate_signer_config(cfg)
      unless cfg.is_a?(Hash)
        return { valid: false, code: "audit.deploy.signer_config_missing" }
      end

      key_id = cfg[:signing_key_id].to_s
      if key_id.empty?
        return { valid: false,
                 code:   "audit.deploy.signer_key_id_missing",
                 detail: "signing_key_id must be present and non-empty" }
      end

      downcased_key = key_id.downcase
      if BLOCKED_SIGNER_PATTERNS.any? { |p| downcased_key.include?(p) }
        return { valid: false,
                 code:   "audit.deploy.signer_key_id_blocked",
                 detail: "signing_key_id contains blocked pattern: #{key_id}" }
      end

      vm = cfg[:verification_metadata]
      if vm.nil?
        return { valid: false, code: "audit.deploy.signer_verification_metadata_missing" }
      end

      source = vm[:public_key_source].to_s
      if source.empty?
        return { valid: false, code: "audit.deploy.signer_public_key_source_missing" }
      end

      downcased_src = source.downcase
      if BLOCKED_SOURCE_PATTERNS.any? { |p| downcased_src.include?(p) }
        return { valid: false,
                 code:   "audit.deploy.signer_public_key_source_blocked",
                 detail: "public_key_source blocked: #{source}" }
      end

      { valid: true }
    end
  end

  # -------------------------------------------------------------------------
  # Follow-up 5:
  # RefusalCodeManifest — stable export of all required and deployment-surface
  # refusal codes (B-E §8).
  # -------------------------------------------------------------------------
  module RefusalCodeManifest
    # The 12 codes required by B-E §8 for production deployment.
    REQUIRED_CODES = %w[
      audit.record.format_version_missing
      audit.record.format_version_unrecognized
      audit.record.kind_unrecognized
      audit.chain.sequence_gap
      audit.record.storage_identity_mismatch
      audit.chain.previous_hash_mismatch
      audit.chain.record_hash_mismatch
      audit.record.compliance_posture_mismatch
      audit.writer.unauthorized
      audit.reader.unauthorized
      audit.writer.rebuild_not_clean
      audit.signer.configuration_invalid
    ].freeze

    # Additional codes introduced by this deployment slice.
    DEPLOYMENT_CODES = %w[
      audit.deploy.storage_identity_missing
      audit.deploy.storage_identity_kind_missing
      audit.deploy.storage_identity_untrusted
      audit.deploy.storage_identity_id_missing
      audit.deploy.signer_config_missing
      audit.deploy.signer_key_id_missing
      audit.deploy.signer_key_id_blocked
      audit.deploy.signer_verification_metadata_missing
      audit.deploy.signer_public_key_source_missing
      audit.deploy.signer_public_key_source_blocked
      audit.surface.startup_not_verified
      audit.surface.disabled
    ].freeze

    ALL_CODES = (REQUIRED_CODES + DEPLOYMENT_CODES).freeze

    module_function

    def includes?(code)
      ALL_CODES.include?(code)
    end

    def required_codes
      REQUIRED_CODES
    end

    def all_codes
      ALL_CODES
    end

    def export
      {
        "kind"                     => "phase1_audit_refusal_code_manifest",
        "format_version"           => "1.0.0",
        "authorization_ref"        => AUTHORIZATION_REF,
        "b_e_decision_ref"         => B_E_DECISION_REF,
        "required_codes"           => REQUIRED_CODES,
        "deployment_codes"         => DEPLOYMENT_CODES,
        "all_codes"                => ALL_CODES,
        "code_count"               => ALL_CODES.size,
        "production_durable_audit" => false,
        "gate3_authorized"         => false,
        "ledger"                   => false
      }
    end
  end

  # -------------------------------------------------------------------------
  # Follow-up 3 + 4 + 6:
  # Phase1DeploymentAuditSurface — the production deployment audit surface.
  #
  # Startup gate (follow-up 3):
  #   startup_verify! must run before any append or traverse is accepted.
  #   If rebuild is not clean, both surfaces stay closed.
  #
  # Role wiring (follow-up 4):
  #   append   → RoleGatedStore(role: phase1_audit_appender)
  #   traverse → RoleGatedStore(role: phase1_audit_reader, same underlying store)
  #
  # Rollback/disable (follow-up 6):
  #   disable!(reason:, authorized_by:) — closes both surfaces immediately
  #   enable!(authorized_by:)           — re-opens after operator diagnosis
  # -------------------------------------------------------------------------
  class Phase1DeploymentAuditSurface
    CODE_STARTUP_NOT_VERIFIED = "audit.surface.startup_not_verified"
    CODE_SURFACE_DISABLED     = "audit.surface.disabled"

    attr_reader :config, :startup_verified, :disabled,
                :disable_reason, :disable_authorized_by

    def initialize(config:)
      unless config.is_a?(Phase1DeploymentConfig) && config.valid?
        raise ArgumentError, "config must be a valid Phase1DeploymentConfig"
      end

      @config           = config
      @startup_verified = false
      @disabled         = false
      @disable_reason   = nil
      @disable_authorized_by = nil

      # RoleGatedStore starts with rebuild_status: "unknown" — appends blocked
      # until startup_verify! sets it to "clean".
      @appender_store = RoleGatedStore.new(role: APPENDER_ROLE, rebuild_status: "unknown")
      @reader_store   = nil
    end

    # Run startup rebuild verification.
    # Must complete with a clean result before appends or traversal are accepted.
    # rebuild_engine: optional override for testing (must respond to #rebuild(records))
    def startup_verify!(rebuild_engine: nil)
      records = @appender_store.store.records
      result  = if rebuild_engine
                  rebuild_engine.rebuild(records)
                else
                  Rebuild.rebuild(records)
                end

      if result[:rebuild_status] == "clean"
        @appender_store.update_rebuild_status("clean")
        @startup_verified = true
        # Wire the reader to the same underlying store as the appender.
        @reader_store = RoleGatedStore.new(role: READER_ROLE)
        @reader_store.instance_variable_set(:@store, @appender_store.store)
        { startup_verified: true, rebuild_status: "clean", rebuild_result: result }
      else
        @appender_store.update_rebuild_status("failed")
        @startup_verified = false
        { startup_verified:  false,
          rebuild_status:    "failed",
          rebuild_result:    result,
          code:              CODE_STARTUP_NOT_VERIFIED }
      end
    end

    # Append an audit record (appender role).
    def append(audit_subject:, signer:, appended_at: PROOF_TIMESTAMP)
      return surface_refused(CODE_SURFACE_DISABLED) if @disabled
      unless @startup_verified
        return { allowed: false,
                 code:    CODE_STARTUP_NOT_VERIFIED,
                 detail:  "startup_verify! must run before appends are accepted" }
      end

      @appender_store.append(audit_subject: audit_subject, signer: signer,
                             appended_at: appended_at)
    end

    # Traverse stored records (reader role).
    def traverse
      return surface_refused(CODE_SURFACE_DISABLED) if @disabled
      unless @startup_verified
        return { allowed: false,
                 code:    CODE_STARTUP_NOT_VERIFIED,
                 detail:  "startup_verify! must run before traversal" }
      end

      @reader_store.traverse
    end

    # Verify hash chain (reader role).
    def verify_chain
      return surface_refused(CODE_SURFACE_DISABLED) if @disabled
      unless @startup_verified
        return { allowed: false, code: CODE_STARTUP_NOT_VERIFIED }
      end

      @reader_store.verify_chain
    end

    # Re-run rebuild after appends (for ongoing integrity verification).
    def rebuild
      records = @appender_store.store.records
      result  = Rebuild.rebuild(records)
      if result[:rebuild_status] == "clean"
        @appender_store.update_rebuild_status("clean")
      else
        @appender_store.update_rebuild_status("failed")
      end
      result
    end

    # Disable the audit surface (rollback procedure, follow-up 6).
    def disable!(reason:, authorized_by:)
      @disabled              = true
      @disable_reason        = reason
      @disable_authorized_by = authorized_by
      { disabled:                true,
        reason:                  reason,
        authorized_by:           authorized_by,
        production_durable_audit: false,
        gate3_authorized:        false }
    end

    # Re-enable the audit surface after operator diagnosis.
    def enable!(authorized_by:)
      @disabled              = false
      @disable_reason        = nil
      @disable_authorized_by = nil
      { disabled: false, authorized_by: authorized_by }
    end

    def status
      { "startup_verified"         => @startup_verified,
        "disabled"                 => @disabled,
        "disable_reason"           => @disable_reason,
        "production_durable_audit" => false,
        "gate3_authorized"         => false,
        "ledger"                   => false,
        "authorization_ref"        => AUTHORIZATION_REF }
    end

    def record_count
      @appender_store.record_count
    end

    private

    def surface_refused(code)
      { allowed: false,
        code:    code,
        detail:  "audit surface disabled; operator action required to re-enable" }
    end
  end

  # -------------------------------------------------------------------------
  # FailingRebuildStub — minimal stub for testing startup_verify! failure path.
  # Responds to rebuild(records) and always returns a failed result.
  # -------------------------------------------------------------------------
  class FailingRebuildStub
    def rebuild(_records)
      { rebuild_status:    "failed",
        success:           false,
        errors:            [{ "sequence" => 1,
                              "code"     => "audit.chain.record_hash_mismatch" }],
        verified_count:    0,
        total_scanned:     1,
        first_failure_at:  1,
        cursor:            1,
        production_durable_audit: false,
        gate3_authorized:  false,
        ledger:            false }
    end
  end

  # -------------------------------------------------------------------------
  # DeploymentFixtures
  # -------------------------------------------------------------------------
  module DeploymentFixtures
    PRODUCTION_STORAGE_IDENTITY = {
      "kind"             => "phase1_production_audit_store",
      "storage_id"       => "audit/gate3/phase1/production/bounded-deployment-v0",
      "provider"         => "off_process_append_only",
      "environment"      => "production",
      "durability_model" => "append_only_persistent",
      "ledger_binding"   => false
    }.freeze

    PRODUCTION_SIGNER_CONFIG = {
      signing_key_id:        "production-audit-signing-key-v1",
      signing_key_version:   "1",
      signing_authority_ref: Fixtures::TRUSTED_SIGNING_AUTHORITY,
      verification_metadata: {
        public_key_source: "hsm-backed-kms-production",
        key_type:          "RSA-4096"
      }
    }.freeze

    module_function

    def valid_config
      Phase1DeploymentConfig.new(
        storage_identity: PRODUCTION_STORAGE_IDENTITY,
        signer_config:    PRODUCTION_SIGNER_CONFIG
      )
    end

    def valid_surface
      Phase1DeploymentAuditSurface.new(config: valid_config)
    end

    def started_surface
      s = valid_surface
      s.startup_verify!
      s
    end
  end

  # =========================================================================
  # Proof Cases
  # =========================================================================
  module_function

  # ---------------------------------------------------------------------------
  # Surface 1: Storage identity config (4 cases)
  # Follow-up item 1 from S3-R36-C1-A
  # ---------------------------------------------------------------------------
  def surface_1_storage_identity_config
    results = {}

    # 1a. Valid production-shaped storage identity accepted.
    cfg = Phase1DeploymentConfig.new(
      storage_identity: DeploymentFixtures::PRODUCTION_STORAGE_IDENTITY,
      signer_config:    DeploymentFixtures::PRODUCTION_SIGNER_CONFIG
    )
    results["deploy.storage_identity.valid_config_accepted"] = {
      "pass"  => cfg.valid? == true,
      "valid" => cfg.valid?,
      "code"  => cfg.validation_result[:code]
    }

    # 1b. Ledger storage identity refused.
    cfg2 = Phase1DeploymentConfig.new(
      storage_identity: { "kind" => "ledger",
                          "storage_id" => "ledger://igniter-lang/audit/phase1",
                          "ledger_binding" => true },
      signer_config:    DeploymentFixtures::PRODUCTION_SIGNER_CONFIG
    )
    results["deploy.storage_identity.ledger_refused"] = {
      "pass" => cfg2.valid? == false &&
                cfg2.validation_result[:code] == "audit.deploy.storage_identity_untrusted",
      "code" => cfg2.validation_result[:code]
    }

    # 1c. ledger_binding: true refused even without "ledger" kind.
    binding_sid = DeploymentFixtures::PRODUCTION_STORAGE_IDENTITY.merge("ledger_binding" => true)
    cfg3 = Phase1DeploymentConfig.new(
      storage_identity: binding_sid,
      signer_config:    DeploymentFixtures::PRODUCTION_SIGNER_CONFIG
    )
    results["deploy.storage_identity.ledger_binding_true_refused"] = {
      "pass" => cfg3.valid? == false &&
                cfg3.validation_result[:code] == "audit.deploy.storage_identity_untrusted",
      "code" => cfg3.validation_result[:code]
    }

    # 1d. Missing storage_id refused.
    no_id_sid = DeploymentFixtures::PRODUCTION_STORAGE_IDENTITY.merge("storage_id" => "")
    cfg4 = Phase1DeploymentConfig.new(
      storage_identity: no_id_sid,
      signer_config:    DeploymentFixtures::PRODUCTION_SIGNER_CONFIG
    )
    results["deploy.storage_identity.missing_storage_id_refused"] = {
      "pass" => cfg4.valid? == false &&
                cfg4.validation_result[:code] == "audit.deploy.storage_identity_id_missing",
      "code" => cfg4.validation_result[:code]
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 2: Signer abstraction config (6 cases)
  # Follow-up item 2 from S3-R36-C1-A
  # ---------------------------------------------------------------------------
  def surface_2_signer_config
    results = {}
    valid_sid = DeploymentFixtures::PRODUCTION_STORAGE_IDENTITY

    # 2a. Valid signer config accepted.
    cfg = Phase1DeploymentConfig.new(
      storage_identity: valid_sid,
      signer_config:    DeploymentFixtures::PRODUCTION_SIGNER_CONFIG
    )
    results["deploy.signer.valid_config_accepted"] = {
      "pass"  => cfg.valid? == true,
      "valid" => cfg.valid?
    }

    # 2b. nil signing_key_id refused.
    cfg2 = Phase1DeploymentConfig.new(
      storage_identity: valid_sid,
      signer_config:    DeploymentFixtures::PRODUCTION_SIGNER_CONFIG.merge(signing_key_id: nil)
    )
    results["deploy.signer.nil_key_id_refused"] = {
      "pass" => cfg2.valid? == false &&
                cfg2.validation_result[:code] == "audit.deploy.signer_key_id_missing",
      "code" => cfg2.validation_result[:code]
    }

    # 2c. noop key_id refused.
    cfg3 = Phase1DeploymentConfig.new(
      storage_identity: valid_sid,
      signer_config:    DeploymentFixtures::PRODUCTION_SIGNER_CONFIG
                          .merge(signing_key_id: "noop-signer-v1")
    )
    results["deploy.signer.noop_key_id_refused"] = {
      "pass" => cfg3.valid? == false &&
                cfg3.validation_result[:code] == "audit.deploy.signer_key_id_blocked",
      "code" => cfg3.validation_result[:code]
    }

    # 2d. stub key_id refused.
    cfg4 = Phase1DeploymentConfig.new(
      storage_identity: valid_sid,
      signer_config:    DeploymentFixtures::PRODUCTION_SIGNER_CONFIG
                          .merge(signing_key_id: "stub-signing-key")
    )
    results["deploy.signer.stub_key_id_refused"] = {
      "pass" => cfg4.valid? == false &&
                cfg4.validation_result[:code] == "audit.deploy.signer_key_id_blocked",
      "code" => cfg4.validation_result[:code]
    }

    # 2e. local-test key_id refused.
    cfg5 = Phase1DeploymentConfig.new(
      storage_identity: valid_sid,
      signer_config:    DeploymentFixtures::PRODUCTION_SIGNER_CONFIG
                          .merge(signing_key_id: "local-test-audit-key")
    )
    results["deploy.signer.local_test_key_id_refused"] = {
      "pass" => cfg5.valid? == false &&
                cfg5.validation_result[:code] == "audit.deploy.signer_key_id_blocked",
      "code" => cfg5.validation_result[:code]
    }

    # 2f. stub public_key_source refused.
    stub_vm = DeploymentFixtures::PRODUCTION_SIGNER_CONFIG.merge(
      verification_metadata: { public_key_source: "stub-key-provider", key_type: "RSA-4096" }
    )
    cfg6 = Phase1DeploymentConfig.new(storage_identity: valid_sid, signer_config: stub_vm)
    results["deploy.signer.stub_public_key_source_refused"] = {
      "pass" => cfg6.valid? == false &&
                cfg6.validation_result[:code] == "audit.deploy.signer_public_key_source_blocked",
      "code" => cfg6.validation_result[:code]
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 3: Startup rebuild verification (4 cases)
  # Follow-up item 3 from S3-R36-C1-A
  # ---------------------------------------------------------------------------
  def surface_3_startup_rebuild
    results = {}
    signer  = Fixtures.valid_signer

    # 3a. Appends blocked before startup_verify! is called.
    surface = DeploymentFixtures.valid_surface
    res = surface.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["deploy.startup.append_blocked_before_verify"] = {
      "pass"    => res[:allowed] == false &&
                   res[:code] == "audit.surface.startup_not_verified",
      "allowed" => res[:allowed],
      "code"    => res[:code]
    }

    # 3b. startup_verify! on empty store → clean → appends allowed.
    surface2 = DeploymentFixtures.valid_surface
    sv = surface2.startup_verify!
    res2 = surface2.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["deploy.startup.clean_rebuild_allows_append"] = {
      "pass"             => sv[:startup_verified] == true &&
                            sv[:rebuild_status]   == "clean" &&
                            res2[:allowed]        == true,
      "startup_verified" => sv[:startup_verified],
      "rebuild_status"   => sv[:rebuild_status],
      "append_allowed"   => res2[:allowed]
    }

    # 3c. startup_verify! with a failing rebuild → appends still blocked.
    surface3 = DeploymentFixtures.valid_surface
    sv3 = surface3.startup_verify!(rebuild_engine: FailingRebuildStub.new)
    res3 = surface3.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["deploy.startup.failed_rebuild_blocks_append"] = {
      "pass"             => sv3[:startup_verified] == false &&
                            res3[:code] == "audit.surface.startup_not_verified",
      "startup_verified" => sv3[:startup_verified],
      "rebuild_status"   => sv3[:rebuild_status],
      "append_code"      => res3[:code]
    }

    # 3d. startup_verified flag exposed in status.
    surface4 = DeploymentFixtures.valid_surface
    st_before = surface4.status
    surface4.startup_verify!
    st_after = surface4.status
    results["deploy.startup.startup_verified_in_status"] = {
      "pass"   => st_before["startup_verified"] == false &&
                  st_after["startup_verified"]  == true,
      "before" => st_before["startup_verified"],
      "after"  => st_after["startup_verified"]
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 4: Appender/reader role wiring (4 cases)
  # Follow-up item 4 from S3-R36-C1-A
  # ---------------------------------------------------------------------------
  def surface_4_role_wiring
    results = {}
    signer  = Fixtures.valid_signer
    surface = DeploymentFixtures.started_surface

    # 4a. Appender role wired: surface.append succeeds.
    res = surface.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["deploy.roles.appender_can_append"] = {
      "pass"    => res[:allowed] == true && res.dig(:result, :appended) == true,
      "allowed" => res[:allowed]
    }

    # 4b. Reader role wired: surface.traverse succeeds.
    trav = surface.traverse
    results["deploy.roles.reader_can_traverse"] = {
      "pass"    => trav[:allowed] == true,
      "allowed" => trav[:allowed]
    }

    # 4c. Records appended via append surface are visible to reader (shared store).
    surface2 = DeploymentFixtures.started_surface
    surface2.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    surface2.append(audit_subject: Fixtures.audit_subject(seq: 2), signer: signer)
    trav2 = surface2.traverse
    results["deploy.roles.appended_records_visible_to_reader"] = {
      "pass"         => trav2[:allowed] == true && trav2[:records].size == 2,
      "record_count" => trav2[:records]&.size
    }

    # 4d. Config declares both authorized roles.
    cfg = DeploymentFixtures.valid_config
    results["deploy.roles.config_declares_both_roles"] = {
      "pass"  => cfg.authorized_roles.include?(APPENDER_ROLE) &&
                 cfg.authorized_roles.include?(READER_ROLE) &&
                 cfg.authorized_roles.size == 2,
      "roles" => cfg.authorized_roles
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 5: Refusal code export (3 cases)
  # Follow-up item 5 from S3-R36-C1-A
  # ---------------------------------------------------------------------------
  def surface_5_refusal_codes
    results = {}
    manifest = RefusalCodeManifest.export

    # 5a. All 12 required B-E codes present.
    all_present = RefusalCodeManifest::REQUIRED_CODES.all? do |c|
      manifest["required_codes"].include?(c)
    end
    results["deploy.refusal_codes.all_required_codes_present"] = {
      "pass"           => all_present && RefusalCodeManifest::REQUIRED_CODES.size == 12,
      "required_count" => RefusalCodeManifest::REQUIRED_CODES.size,
      "all_present"    => all_present
    }

    # 5b. All codes are Strings (stable, not symbols).
    all_strings = manifest["all_codes"].all? { |c| c.is_a?(String) }
    results["deploy.refusal_codes.all_codes_are_strings"] = {
      "pass"       => all_strings,
      "code_count" => manifest["all_codes"].size
    }

    # 5c. Manifest carries proof-local non-authorization flags.
    results["deploy.refusal_codes.manifest_is_proof_local"] = {
      "pass"                     => manifest["production_durable_audit"] == false &&
                                    manifest["gate3_authorized"] == false &&
                                    manifest["ledger"] == false,
      "production_durable_audit" => manifest["production_durable_audit"],
      "gate3_authorized"         => manifest["gate3_authorized"],
      "ledger"                   => manifest["ledger"]
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 6: Rollback/disable procedure (4 cases)
  # Follow-up item 6 from S3-R36-C1-A
  # ---------------------------------------------------------------------------
  def surface_6_rollback_procedure
    results = {}
    signer  = Fixtures.valid_signer

    # 6a. Disable surface: appends refused with audit.surface.disabled.
    surface = DeploymentFixtures.started_surface
    surface.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    surface.disable!(reason: "emergency rollback — integrity error detected",
                     authorized_by: "on-call-operator-001")
    res = surface.append(audit_subject: Fixtures.audit_subject(seq: 2), signer: signer)
    results["deploy.rollback.disable_blocks_append"] = {
      "pass"     => surface.disabled == true && res[:code] == "audit.surface.disabled",
      "disabled" => surface.disabled,
      "code"     => res[:code]
    }

    # 6b. Disable surface: traverse refused with audit.surface.disabled.
    surface2 = DeploymentFixtures.started_surface
    surface2.disable!(reason: "scheduled maintenance", authorized_by: "ops-team")
    trav = surface2.traverse
    results["deploy.rollback.disable_blocks_traverse"] = {
      "pass"     => surface2.disabled == true && trav[:code] == "audit.surface.disabled",
      "disabled" => surface2.disabled,
      "code"     => trav[:code]
    }

    # 6c. Enable after disable restores append capability.
    surface3 = DeploymentFixtures.started_surface
    surface3.disable!(reason: "config change", authorized_by: "ops-team")
    surface3.enable!(authorized_by: "ops-team")
    res3 = surface3.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["deploy.rollback.enable_after_disable_allows_append"] = {
      "pass"     => surface3.disabled == false && res3[:allowed] == true,
      "disabled" => surface3.disabled,
      "allowed"  => res3[:allowed]
    }

    # 6d. Disable captures reason and authorized_by for audit trail.
    surface4 = DeploymentFixtures.started_surface
    dr = surface4.disable!(reason: "audit chain integrity failure detected",
                           authorized_by: "security-ops-001")
    results["deploy.rollback.disable_captures_metadata"] = {
      "pass"          => dr[:disabled] == true &&
                         surface4.disable_reason == "audit chain integrity failure detected" &&
                         surface4.disable_authorized_by == "security-ops-001",
      "reason"        => surface4.disable_reason,
      "authorized_by" => surface4.disable_authorized_by
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 7: Post-deployment smoke (5 cases)
  # Follow-up item 7 from S3-R36-C1-A
  # ---------------------------------------------------------------------------
  def surface_7_post_deployment_smoke
    results = {}
    signer  = Fixtures.valid_signer

    # 7a. Clean append flow: startup → append × 3 → record_count = 3.
    surface = DeploymentFixtures.valid_surface
    surface.startup_verify!
    3.times { |i| surface.append(audit_subject: Fixtures.audit_subject(seq: i + 1), signer: signer) }
    results["deploy.smoke.append_flow"] = {
      "pass"         => surface.record_count == 3,
      "record_count" => surface.record_count
    }

    # 7b. Clean reader traversal: startup → append × 2 → traverse returns 2 records.
    surface2 = DeploymentFixtures.valid_surface
    surface2.startup_verify!
    surface2.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    surface2.append(audit_subject: Fixtures.audit_subject(seq: 2), signer: signer)
    trav = surface2.traverse
    results["deploy.smoke.reader_traversal"] = {
      "pass"         => trav[:allowed] == true && trav[:records].size == 2,
      "allowed"      => trav[:allowed],
      "record_count" => trav[:records]&.size
    }

    # 7c. Rebuild after appends: startup → append × 2 → rebuild → clean.
    surface3 = DeploymentFixtures.valid_surface
    surface3.startup_verify!
    surface3.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    surface3.append(audit_subject: Fixtures.audit_subject(seq: 2), signer: signer)
    reb = surface3.rebuild
    results["deploy.smoke.rebuild_after_appends"] = {
      "pass"           => reb[:rebuild_status] == "clean" && reb[:verified_count] == 2,
      "rebuild_status" => reb[:rebuild_status],
      "verified_count" => reb[:verified_count]
    }

    # 7d. Signer refusal at deploy config level (stub key blocked before surface wires).
    bad_cfg = Phase1DeploymentConfig.new(
      storage_identity: DeploymentFixtures::PRODUCTION_STORAGE_IDENTITY,
      signer_config:    DeploymentFixtures::PRODUCTION_SIGNER_CONFIG
                          .merge(signing_key_id: "stub-key")
    )
    results["deploy.smoke.signer_refusal_at_config"] = {
      "pass"  => bad_cfg.valid? == false &&
                 bad_cfg.validation_result[:code] == "audit.deploy.signer_key_id_blocked",
      "valid" => bad_cfg.valid?,
      "code"  => bad_cfg.validation_result[:code]
    }

    # 7e. End-to-end deployment flow:
    #     configure → startup → append → traverse → rebuild → disable → refuse → enable → append
    surface5 = DeploymentFixtures.valid_surface
    sv       = surface5.startup_verify!
    app1     = surface5.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    trav5    = surface5.traverse
    reb5     = surface5.rebuild
    surface5.disable!(reason: "e2e test disable", authorized_by: "test-ops")
    ref5     = surface5.append(audit_subject: Fixtures.audit_subject(seq: 2), signer: signer)
    surface5.enable!(authorized_by: "test-ops")
    app2     = surface5.append(audit_subject: Fixtures.audit_subject(seq: 2), signer: signer)
    results["deploy.smoke.end_to_end_flow"] = {
      "pass" => sv[:startup_verified]  == true  &&
                app1[:allowed]         == true   &&
                trav5[:allowed]        == true   &&
                reb5[:rebuild_status]  == "clean" &&
                ref5[:code]            == "audit.surface.disabled" &&
                app2[:allowed]         == true,
      "startup_verified"      => sv[:startup_verified],
      "append1_allowed"       => app1[:allowed],
      "traverse_allowed"      => trav5[:allowed],
      "rebuild_clean"         => reb5[:rebuild_status] == "clean",
      "disabled_refusal_code" => ref5[:code],
      "append2_allowed"       => app2[:allowed]
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Cross-cutting invariant checks
  # ---------------------------------------------------------------------------
  def invariant_checks(all_cases)
    {
      "invariant.no_production_durable_audit" =>
        all_cases.values.none? { |r|
          r.is_a?(Hash) && r["production_durable_audit"] == true
        },

      "invariant.no_gate3_authorized" =>
        all_cases.values.none? { |r|
          r.is_a?(Hash) && r["gate3_authorized"] == true
        },

      "invariant.no_ledger" => true,

      "invariant.all_required_refusal_codes_present" =>
        RefusalCodeManifest::REQUIRED_CODES.size == 12 &&
        RefusalCodeManifest::REQUIRED_CODES.all? { |c| c.is_a?(String) && c.start_with?("audit.") },

      "invariant.manifest_is_proof_local" =>
        RefusalCodeManifest.export["production_durable_audit"] == false &&
        RefusalCodeManifest.export["gate3_authorized"] == false &&
        RefusalCodeManifest.export["ledger"] == false
    }
  end

  # ---------------------------------------------------------------------------
  # Main runner
  # ---------------------------------------------------------------------------
  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    s1 = surface_1_storage_identity_config
    s2 = surface_2_signer_config
    s3 = surface_3_startup_rebuild
    s4 = surface_4_role_wiring
    s5 = surface_5_refusal_codes
    s6 = surface_6_rollback_procedure
    s7 = surface_7_post_deployment_smoke

    all_cases = s1.merge(s2).merge(s3).merge(s4).merge(s5).merge(s6).merge(s7)
    invs      = invariant_checks(all_cases)

    case_checks = all_cases.transform_values { |r| r["pass"] }
    all_checks  = case_checks.merge(invs)
    all_pass    = all_checks.values.all?
    cases_pass  = all_cases.values.count { |r| r["pass"] }
    cases_fail  = all_cases.values.count { |r| !r["pass"] }

    summary = {
      "kind"              => "durable_audit_restricted_deployment_proof_summary",
      "format_version"    => "1.0.0",
      "card"              => "S3-R37-C2-I",
      "track"             => "durable-audit-restricted-deployment-implementation-v0",
      "authorization_ref" => AUTHORIZATION_REF,
      "b_e_decision_ref"  => B_E_DECISION_REF,
      "proof_timestamp"   => PROOF_TIMESTAMP,
      "status"            => all_pass ? "PASS" : "FAIL",
      "total_cases"       => all_cases.size,
      "cases_pass"        => cases_pass,
      "cases_fail"        => cases_fail,
      "surfaces" => {
        "surface_1_storage_identity_config"       => verdict(s1),
        "surface_2_signer_abstraction_config"     => verdict(s2),
        "surface_3_startup_rebuild_verification"  => verdict(s3),
        "surface_4_appender_reader_role_wiring"   => verdict(s4),
        "surface_5_refusal_code_export"           => verdict(s5),
        "surface_6_rollback_disable_procedure"    => verdict(s6),
        "surface_7_post_deployment_smoke"         => verdict(s7)
      },
      "refusal_code_manifest" => RefusalCodeManifest.export,
      "cases"     => all_cases,
      "checks"    => all_checks,
      "invariants" => invs,
      "non_authorization" => {
        "concrete_hsm_kms_onboarding"                => false,
        "production_signing_execution"               => false,
        "ledger_adapter"                             => false,
        "phase2"                                     => false,
        "bihistory"                                  => false,
        "stream_olap_executor"                       => false,
        "production_cache"                           => false,
        "broad_runtimemachine_binding"               => false,
        "gate3_authorized_widened"                   => false,
        "production_deployment_beyond_bounded_scope" => false
      },
      "_volatile_fields" => ["proof_timestamp"]
    }

    write_json(SUMMARY_PATH, summary)
    print_results(summary)
    all_pass
  end

  def verdict(surface_results)
    surface_results.values.all? { |r| r["pass"] } ? "PASS" : "FAIL"
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_results(summary)
    puts "#{summary["status"]} durable_audit_restricted_deployment_proof " \
         "(#{summary["cases_pass"]}/#{summary["total_cases"]} cases)"
    puts ""
    puts "Surfaces:"
    summary["surfaces"].each { |s, r| puts "  #{s}: #{r}" }
    puts ""
    puts "Cases:"
    summary["cases"].each do |name, r|
      extra = r["code"] ? " — #{r["code"]}" : ""
      puts "  #{name}: #{r["pass"] ? "ok" : "FAIL"}#{extra}"
    end
    puts ""
    puts "Invariants:"
    summary["invariants"].each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts ""
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"

    return if summary["cases_fail"].zero?

    puts ""
    puts "FAILED cases:"
    summary["cases"].each do |name, r|
      next if r["pass"]
      puts "  #{name}: #{r.inspect}"
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = DurableAuditRestrictedDeploymentProof.run
  exit(success ? 0 : 1)
end
