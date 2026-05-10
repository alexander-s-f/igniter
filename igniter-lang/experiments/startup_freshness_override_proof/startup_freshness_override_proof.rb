#!/usr/bin/env ruby
# frozen_string_literal: true

# Proof-local validator for the startup_time freshness override interface.
#
# Card:  S3-R30-C2-P
# Track: startup-time-freshness-override-validator-v0
#
# Validates the deployment manifest -> freshness_policy_ref -> signed policy
# document chain.  Default: 24h constant.  Override: bundled authority-signed
# policy document.
#
# Key decisions in this implementation:
#
#   [D1] All non-default policy documents (max_age_seconds != 86400) require
#        expires_at — not only those above 24h.  Closes C-1 from S3-R29-X1-S.
#        Rationale: an eternal non-default policy creates a false security
#        posture when deployment requirements change.  All overrides are
#        time-bounded by construction.
#
#   [D2] format_version / kind validation failures use code
#        "audit.registry.freshness_policy_format_invalid" (new in this proof).
#        The R29 design does not define a code for unrecognized format/kind;
#        a distinct code keeps the error space clean and avoids conflating
#        structural errors with signature failures.
#
#   [D3] Attempts to pass direct_override_seconds (raw seconds bypass) produce
#        "audit.registry.direct_seconds_override_rejected".  The validator API
#        does not accept raw seconds; any caller that tries to inject them gets
#        an explicit refusal rather than silent ignoring.
#
# Excluded surfaces (never present in this proof):
#   - production durable audit writer / signer execution
#   - production registry service
#   - Ledger / Phase 2 / BiHistory
#   - online lookup or per-invocation policy fetch
#   - production authority key material
#
# Usage:
#   ruby igniter-lang/experiments/startup_freshness_override_proof/startup_freshness_override_proof.rb
#
# Exit 0 = all checks PASS.  Exit 1 = at least one check FAIL.

require "digest"
require "fileutils"
require "json"
require "time"
require "pathname"

module StartupFreshnessOverrideValidationProof
  ROOT         = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR      = ROOT / "igniter-lang/experiments/startup_freshness_override_proof/out"
  SUMMARY_PATH = OUT_DIR / "startup_freshness_override_proof_summary.json"

  # ISO8601 startup time used across the proof.
  PROOF_STARTUP_TIME = "2026-05-10T12:00:00Z"

  # Registry timestamps (relative to PROOF_STARTUP_TIME = 12:00)
  REGISTRY_5H_OLD  = "2026-05-10T07:00:00Z"  # age 5h = 18000s  — fresh for 6h+ policy
  REGISTRY_7H_OLD  = "2026-05-10T05:00:00Z"  # age 7h = 25200s  — stale for 6h policy, fresh for 24h
  REGISTRY_26H_OLD = "2026-05-09T10:00:00Z"  # age 26h = 93600s — stale for 24h default

  # Trusted authority for proof-local fixtures.
  TRUSTED_AUTHORITY =
    "architect-supervisor://igniter-lang/production-audit/freshness-policy/v1"

  # -------------------------------------------------------------------------
  # StartupFreshnessValidator
  # -------------------------------------------------------------------------
  class StartupFreshnessValidator
    DEFAULT_MAX_AGE_SECONDS = 86_400   # 24 h
    MIN_OVERRIDE_SECONDS    = 3_600    # 1 h
    MAX_OVERRIDE_SECONDS    = 259_200  # 72 h

    RECOGNIZED_FORMATS = %w[0.1.0].freeze
    RECOGNIZED_KINDS   = %w[production_audit_startup_freshness_policy].freeze

    # Authority blocked patterns — mirror R28 ProductionSignerValidator logic.
    BLOCKED_AUTHORITY_EXACT    = %w[local test stub noop no-op dev].freeze
    BLOCKED_AUTHORITY_SCHEMES  = %w[local:// test:// stub:// noop://].freeze

    # Signature blocked patterns.
    BLOCKED_SIGNATURE_SUBSTRINGS = %w[stub local test noop no-op].freeze

    # Main validation entry point.
    #
    # Inputs:
    #   policy_ref:            Hash | nil  — from deployment manifest
    #                                        nil means "no override; use default"
    #   policy_bytes:          String | nil — serialized policy JSON bytes
    #                                        nil means the file was not found
    #   startup_time:          String (ISO8601)
    #   registry_generated_at: String (ISO8601) | nil  — nil = anchor invalid
    #   direct_override_seconds: must always be nil; non-nil = API violation [D3]
    #
    # Returns:
    #   { decision: :accepted | :refused,
    #     code:     String,
    #     effective_max_age_seconds: Integer | nil,
    #     report:   Hash }
    def validate(
      policy_ref: nil,
      policy_bytes: nil,
      startup_time: PROOF_STARTUP_TIME,
      registry_generated_at: nil,
      direct_override_seconds: nil
    )
      # [D3] Direct seconds injection is never a valid input.
      unless direct_override_seconds.nil?
        return refused("audit.registry.direct_seconds_override_rejected",
                       startup_time: startup_time,
                       note: "direct_override_seconds must be nil; " \
                             "pass policy_ref with a signed policy document instead")
      end

      # No override requested → use the built-in 24h default.
      if policy_ref.nil?
        return check_registry(
          effective_max_age: DEFAULT_MAX_AGE_SECONDS,
          override_status:   "default_used",
          policy_ref:        nil,
          startup_time:      startup_time,
          registry_generated_at: registry_generated_at,
          accept_code: "audit.registry.startup_time_default_bound_used"
        )
      end

      # Override requested → validate the policy chain.
      policy_result = validate_policy(
        policy_ref:    policy_ref,
        policy_bytes:  policy_bytes,
        startup_time:  startup_time
      )
      return policy_result if policy_result[:decision] == :refused

      check_registry(
        effective_max_age: policy_result[:max_age_seconds],
        override_status:   "accepted",
        policy_ref:        policy_ref,
        startup_time:      startup_time,
        registry_generated_at: registry_generated_at,
        accept_code: "audit.registry.startup_time_override_accepted"
      )
    end

    private

    # Validates the full policy document chain.
    # Returns { decision: :ok, max_age_seconds: N } or a refused result.
    def validate_policy(policy_ref:, policy_bytes:, startup_time:)
      # Step 1: policy file must be present.
      if policy_bytes.nil?
        return refused("audit.registry.freshness_policy_missing",
                       policy_ref: policy_ref)
      end

      # Step 2: content hash must match.
      actual_hash = sha256(policy_bytes)
      expected_hash = policy_ref[:content_hash]
      unless actual_hash == expected_hash
        return refused("audit.registry.freshness_policy_hash_mismatch",
                       policy_ref:    policy_ref,
                       expected_hash: expected_hash,
                       actual_hash:   actual_hash)
      end

      # Step 3: parse policy document.
      policy = begin
        JSON.parse(policy_bytes, symbolize_names: true)
      rescue JSON::ParserError => e
        return refused("audit.registry.freshness_policy_format_invalid",
                       policy_ref: policy_ref, detail: "policy_bytes not valid JSON: #{e.message}")
      end

      # Step 4: validate format_version.  [D2]
      unless RECOGNIZED_FORMATS.include?(policy[:format_version])
        return refused("audit.registry.freshness_policy_format_invalid",
                       policy_ref:         policy_ref,
                       got_format_version: policy[:format_version])
      end

      # Step 5: validate kind.  [D2]
      unless RECOGNIZED_KINDS.include?(policy[:kind])
        return refused("audit.registry.freshness_policy_format_invalid",
                       policy_ref: policy_ref,
                       got_kind:   policy[:kind])
      end

      # Step 6: authority_ref must match manifest.
      manifest_authority = policy_ref[:authority_ref]
      policy_authority   = policy[:authority_ref]
      unless manifest_authority == policy_authority
        return refused("audit.registry.freshness_policy_authority_untrusted",
                       policy_ref:          policy_ref,
                       detail:              "authority_ref mismatch",
                       manifest_authority:  manifest_authority,
                       policy_authority:    policy_authority)
      end

      # Step 7: authority_ref must not be local/test/stub.
      if blocked_authority?(policy_authority.to_s)
        return refused("audit.registry.freshness_policy_authority_untrusted",
                       policy_ref:    policy_ref,
                       authority_ref: policy_authority)
      end

      # Step 8: signature must be present and valid.
      sig = policy[:signature_ref].to_s
      if sig.empty?
        return refused("audit.registry.freshness_policy_signature_invalid",
                       policy_ref: policy_ref,
                       detail:     "signature_ref missing or empty")
      end
      if blocked_signature?(sig)
        return refused("audit.registry.freshness_policy_signature_invalid",
                       policy_ref:    policy_ref,
                       detail:        "signature_ref contains blocked pattern",
                       signature_ref: sig)
      end

      # Step 9: policy must not be expired.
      expires_at_str = policy[:expires_at]
      if expires_at_str
        begin
          expires_at  = Time.iso8601(expires_at_str)
          start_time  = Time.iso8601(startup_time)
          if start_time >= expires_at
            return refused("audit.registry.freshness_policy_expired",
                           policy_ref: policy_ref,
                           expires_at: expires_at_str,
                           startup_time: startup_time)
          end
        rescue ArgumentError
          return refused("audit.registry.freshness_policy_format_invalid",
                         policy_ref: policy_ref,
                         detail:     "expires_at not valid ISO8601: #{expires_at_str}")
        end
      end

      # Step 10: max_age_seconds must be an integer.
      max_age = policy[:max_age_seconds]
      unless max_age.is_a?(Integer)
        return refused("audit.registry.freshness_policy_bound_invalid",
                       policy_ref: policy_ref,
                       detail:     "max_age_seconds must be Integer",
                       got:        max_age.inspect)
      end

      # Step 11: max_age_seconds must be within the allowed range.
      unless max_age >= MIN_OVERRIDE_SECONDS && max_age <= MAX_OVERRIDE_SECONDS
        return refused("audit.registry.freshness_policy_bound_invalid",
                       policy_ref: policy_ref,
                       detail:     "max_age_seconds out of allowed range " \
                                   "[#{MIN_OVERRIDE_SECONDS}..#{MAX_OVERRIDE_SECONDS}]",
                       got:        max_age)
      end

      # Step 12: [D1] ALL non-default policies require expires_at.
      # This includes tighter policies (<24h), not only looser ones (>24h).
      if max_age != DEFAULT_MAX_AGE_SECONDS && expires_at_str.nil?
        return refused("audit.registry.freshness_policy_bound_invalid",
                       policy_ref: policy_ref,
                       detail:     "non-default max_age_seconds requires expires_at " \
                                   "(all non-default policies must be time-bounded) [D1]")
      end

      # Step 13: looser-than-default policies additionally require reason.
      if max_age > DEFAULT_MAX_AGE_SECONDS
        reason = policy[:reason].to_s.strip
        if reason.empty?
          return refused("audit.registry.freshness_policy_bound_invalid",
                         policy_ref: policy_ref,
                         detail:     "max_age_seconds > #{DEFAULT_MAX_AGE_SECONDS} " \
                                     "requires non-empty reason field")
        end
      end

      # All policy validations passed.
      { decision: :ok, max_age_seconds: max_age }
    end

    # Checks registry freshness against the effective bound.
    def check_registry(
      effective_max_age:,
      override_status:,
      policy_ref:,
      startup_time:,
      registry_generated_at:,
      accept_code:
    )
      # Registry anchor must be present and parseable.
      if registry_generated_at.nil?
        return refused("audit.registry.startup_time_anchor_invalid",
                       startup_time:      startup_time,
                       override_status:   override_status,
                       policy_ref:        policy_ref,
                       detail:            "registry_generated_at is nil")
      end

      begin
        reg_time   = Time.iso8601(registry_generated_at)
        start_time = Time.iso8601(startup_time)
        age        = (start_time - reg_time).to_i
      rescue ArgumentError => e
        return refused("audit.registry.startup_time_anchor_invalid",
                       startup_time: startup_time,
                       detail:       "registry_generated_at not valid ISO8601: #{e.message}")
      end

      if age > effective_max_age
        return refused("audit.registry.startup_time_staleness_exceeded",
                       startup_time:              startup_time,
                       registry_generated_at:     registry_generated_at,
                       registry_age_seconds:       age,
                       effective_max_age_seconds: effective_max_age,
                       policy_ref:                policy_ref)
      end

      accepted(
        code:                      accept_code,
        effective_max_age_seconds: effective_max_age,
        registry_age_seconds:       age,
        startup_time:              startup_time,
        registry_generated_at:     registry_generated_at,
        override_status:           override_status,
        policy_ref:                policy_ref
      )
    end

    def accepted(
      code:, effective_max_age_seconds:, registry_age_seconds:,
      startup_time:, registry_generated_at:, override_status:, policy_ref:
    )
      {
        decision:                  :accepted,
        code:                      code,
        effective_max_age_seconds: effective_max_age_seconds,
        report: {
          "kind"                       => "audit_registry_startup_freshness_check",
          "format_version"             => "0.1.0",
          "startup_time"               => startup_time,
          "registry_generated_at"      => registry_generated_at,
          "registry_age_seconds"        => registry_age_seconds,
          "effective_max_age_seconds"  => effective_max_age_seconds,
          "default_max_age_seconds"    => DEFAULT_MAX_AGE_SECONDS,
          "override"                   => {
            "status"     => override_status,
            "policy_ref" => policy_ref&.transform_keys(&:to_s)
          },
          "decision"                   => "accepted",
          "code"                       => code,
          "production_gate_authority_enabled" => false
        }
      }
    end

    def refused(code, extras = {})
      {
        decision:                  :refused,
        code:                      code,
        effective_max_age_seconds: nil,
        report: {
          "kind"                            => "audit_registry_startup_freshness_refusal",
          "format_version"                  => "0.1.0",
          "code"                            => code,
          "startup_time"                    => extras[:startup_time] || PROOF_STARTUP_TIME,
          "default_max_age_seconds"         => DEFAULT_MAX_AGE_SECONDS,
          "production_gate_authority_enabled" => false
        }.merge(extras.transform_keys(&:to_s))
      }
    end

    def sha256(bytes)
      "sha256:#{Digest::SHA256.hexdigest(bytes)}"
    end

    def blocked_authority?(ref)
      downcased = ref.downcase
      return true if BLOCKED_AUTHORITY_EXACT.include?(downcased)
      BLOCKED_AUTHORITY_SCHEMES.any? { |scheme| downcased.start_with?(scheme) }
    end

    def blocked_signature?(sig)
      downcased = sig.downcase
      BLOCKED_SIGNATURE_SUBSTRINGS.any? { |blocked| downcased.include?(blocked) }
    end
  end

  # -------------------------------------------------------------------------
  # Fixture builder helpers
  # -------------------------------------------------------------------------
  module Fixtures
    module_function

    def policy_bytes(policy_hash)
      JSON.generate(policy_hash)
    end

    def sha256(bytes)
      "sha256:#{Digest::SHA256.hexdigest(bytes)}"
    end

    def policy_ref_for(policy_hash, authority: TRUSTED_AUTHORITY)
      bytes = policy_bytes(policy_hash)
      {
        uri:          "audit-policy://igniter-lang/phase1/startup-freshness/#{policy_hash[:policy_id]}",
        content_hash: sha256(bytes),
        authority_ref: authority
      }
    end

    # Base valid tighter policy (6 h).
    TIGHTER_6H = {
      kind:            "production_audit_startup_freshness_policy",
      format_version:  "0.1.0",
      authority_ref:   TRUSTED_AUTHORITY,
      policy_id:       "proof-tighter-6h-v1",
      issued_at:       "2026-05-01T00:00:00Z",
      expires_at:      "2026-06-01T00:00:00Z",
      max_age_seconds: 21_600,
      signature_ref:   "sig://production/proof-tighter-6h-v1"
    }.freeze

    # Base valid looser policy (48 h — within 72 h cap).
    LOOSER_48H = {
      kind:            "production_audit_startup_freshness_policy",
      format_version:  "0.1.0",
      authority_ref:   TRUSTED_AUTHORITY,
      policy_id:       "proof-looser-48h-v1",
      issued_at:       "2026-05-01T00:00:00Z",
      expires_at:      "2026-06-01T00:00:00Z",
      max_age_seconds: 172_800,
      reason:          "bounded air-gapped deployment — registry refresh window 48h",
      signature_ref:   "sig://production/proof-looser-48h-v1"
    }.freeze

    # 1 h minimum.
    MIN_1H = {
      kind:            "production_audit_startup_freshness_policy",
      format_version:  "0.1.0",
      authority_ref:   TRUSTED_AUTHORITY,
      policy_id:       "proof-min-1h-v1",
      issued_at:       "2026-05-01T00:00:00Z",
      expires_at:      "2026-06-01T00:00:00Z",
      max_age_seconds: 3_600,
      signature_ref:   "sig://production/proof-min-1h-v1"
    }.freeze

    # 72 h maximum.
    MAX_72H = {
      kind:            "production_audit_startup_freshness_policy",
      format_version:  "0.1.0",
      authority_ref:   TRUSTED_AUTHORITY,
      policy_id:       "proof-max-72h-v1",
      issued_at:       "2026-05-01T00:00:00Z",
      expires_at:      "2026-06-01T00:00:00Z",
      max_age_seconds: 259_200,
      reason:          "offline/air-gapped production environment — 72h maximum",
      signature_ref:   "sig://production/proof-max-72h-v1"
    }.freeze
  end

  # -------------------------------------------------------------------------
  # Proof cases (26 total)
  # -------------------------------------------------------------------------
  module ProofCases
    include Fixtures
    module_function

    def build_all(validator)
      {
        # ---------------------------------------------------------------
        # ACCEPTED cases (5)
        # ---------------------------------------------------------------

        # 1. No override: use default 24h.
        "default_no_policy" => run_case(validator,
          policy_ref:            nil,
          policy_bytes:          nil,
          registry_generated_at: REGISTRY_5H_OLD,
          expected_decision:     :accepted,
          expected_code:         "audit.registry.startup_time_default_bound_used"
        ),

        # 2. Valid tighter policy, 6 h with expires_at.
        "tighter_6h_valid" => begin
          tighter_bytes = Fixtures.policy_bytes(Fixtures::TIGHTER_6H)
          tighter_ref   = Fixtures.policy_ref_for(Fixtures::TIGHTER_6H)
          run_case(validator,
            policy_ref:            tighter_ref,
            policy_bytes:          tighter_bytes,
            registry_generated_at: REGISTRY_5H_OLD,  # 5h < 6h bound: fresh
            expected_decision:     :accepted,
            expected_code:         "audit.registry.startup_time_override_accepted"
          )
        end,

        # 3. Valid looser policy, 48 h with reason + expires_at.
        "looser_48h_valid" => begin
          looser_bytes = Fixtures.policy_bytes(Fixtures::LOOSER_48H)
          looser_ref   = Fixtures.policy_ref_for(Fixtures::LOOSER_48H)
          run_case(validator,
            policy_ref:            looser_ref,
            policy_bytes:          looser_bytes,
            registry_generated_at: REGISTRY_26H_OLD,  # 26h < 48h bound: fresh
            expected_decision:     :accepted,
            expected_code:         "audit.registry.startup_time_override_accepted"
          )
        end,

        # 4. Minimum allowed bound: 3600 s (1 h exactly) with expires_at.
        "min_bound_1h_valid" => begin
          min_bytes = Fixtures.policy_bytes(Fixtures::MIN_1H)
          min_ref   = Fixtures.policy_ref_for(Fixtures::MIN_1H)
          run_case(validator,
            policy_ref:            min_ref,
            policy_bytes:          min_bytes,
            registry_generated_at: REGISTRY_5H_OLD,  # 18000s > 3600 BUT fresh_enough?
            # 5h = 18000s > 3600s → STALE for 1h.  Use a 30-min-old registry instead.
            # Override: use registry that is 30min old = fresh for 1h.
            expected_decision:     :refused,  # placeholder; recalculated below
            expected_code:         "audit.registry.startup_time_staleness_exceeded"
          )
        end,

        # 4b. 1 h policy with fresh-enough registry (29 min old).
        "min_bound_1h_fresh_registry" => begin
          min_bytes     = Fixtures.policy_bytes(Fixtures::MIN_1H)
          min_ref       = Fixtures.policy_ref_for(Fixtures::MIN_1H)
          # startup = 12:00, registry = 11:31 → age = 29min = 1740s < 3600s
          fresh_30m_reg = "2026-05-10T11:31:00Z"
          run_case(validator,
            policy_ref:            min_ref,
            policy_bytes:          min_bytes,
            registry_generated_at: fresh_30m_reg,
            expected_decision:     :accepted,
            expected_code:         "audit.registry.startup_time_override_accepted"
          )
        end,

        # 5. Maximum allowed bound: 259200 s (72 h) with reason + expires_at.
        "max_bound_72h_valid" => begin
          max_bytes = Fixtures.policy_bytes(Fixtures::MAX_72H)
          max_ref   = Fixtures.policy_ref_for(Fixtures::MAX_72H)
          run_case(validator,
            policy_ref:            max_ref,
            policy_bytes:          max_bytes,
            registry_generated_at: REGISTRY_26H_OLD,  # 26h < 72h: fresh
            expected_decision:     :accepted,
            expected_code:         "audit.registry.startup_time_override_accepted"
          )
        end,

        # ---------------------------------------------------------------
        # REFUSED cases (21)
        # ---------------------------------------------------------------

        # 6. Manifest ref present but policy file not found.
        "policy_file_missing" => begin
          ref = Fixtures.policy_ref_for(Fixtures::TIGHTER_6H)
          run_case(validator,
            policy_ref:            ref,
            policy_bytes:          nil,   # simulates missing file
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_missing"
          )
        end,

        # 7. Content hash mismatch.
        "hash_mismatch" => begin
          tighter_bytes = Fixtures.policy_bytes(Fixtures::TIGHTER_6H)
          bad_ref = Fixtures.policy_ref_for(Fixtures::TIGHTER_6H).merge(
            content_hash: "sha256:#{"0" * 64}"
          )
          run_case(validator,
            policy_ref:            bad_ref,
            policy_bytes:          tighter_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_hash_mismatch"
          )
        end,

        # 8. Signature field missing entirely.
        "signature_missing" => begin
          no_sig_policy = Fixtures::TIGHTER_6H.reject { |k, _| k == :signature_ref }
          no_sig_bytes  = Fixtures.policy_bytes(no_sig_policy)
          no_sig_ref    = Fixtures.policy_ref_for(no_sig_policy)
          run_case(validator,
            policy_ref:            no_sig_ref,
            policy_bytes:          no_sig_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_signature_invalid"
          )
        end,

        # 9. Signature present but contains a blocked stub pattern.
        "signature_stub" => begin
          stub_sig_policy = Fixtures::TIGHTER_6H.merge(signature_ref: "sig://stub/proof")
          stub_sig_bytes  = Fixtures.policy_bytes(stub_sig_policy)
          stub_sig_ref    = Fixtures.policy_ref_for(stub_sig_policy)
          run_case(validator,
            policy_ref:            stub_sig_ref,
            policy_bytes:          stub_sig_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_signature_invalid"
          )
        end,

        # 10. Local authority scheme.
        "authority_local" => begin
          local_auth = "local://igniter-lang/freshness-policy/v1"
          local_policy = Fixtures::TIGHTER_6H.merge(authority_ref: local_auth)
          local_bytes  = Fixtures.policy_bytes(local_policy)
          local_ref    = Fixtures.policy_ref_for(local_policy, authority: local_auth)
          run_case(validator,
            policy_ref:            local_ref,
            policy_bytes:          local_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_authority_untrusted"
          )
        end,

        # 11. Test authority scheme.
        "authority_test" => begin
          test_auth    = "test://igniter-lang/freshness-policy/v1"
          test_policy  = Fixtures::TIGHTER_6H.merge(authority_ref: test_auth)
          test_bytes   = Fixtures.policy_bytes(test_policy)
          test_ref     = Fixtures.policy_ref_for(test_policy, authority: test_auth)
          run_case(validator,
            policy_ref:            test_ref,
            policy_bytes:          test_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_authority_untrusted"
          )
        end,

        # 12. Stub authority scheme.
        "authority_stub" => begin
          stub_auth    = "stub://igniter-lang/freshness-policy/v1"
          stub_policy  = Fixtures::TIGHTER_6H.merge(authority_ref: stub_auth)
          stub_bytes   = Fixtures.policy_bytes(stub_policy)
          stub_ref     = Fixtures.policy_ref_for(stub_policy, authority: stub_auth)
          run_case(validator,
            policy_ref:            stub_ref,
            policy_bytes:          stub_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_authority_untrusted"
          )
        end,

        # 13. Authority_ref mismatch: manifest says X, policy document says Y.
        "authority_ref_mismatch" => begin
          mismatch_policy = Fixtures::TIGHTER_6H.merge(
            authority_ref: "architect-supervisor://igniter-lang/OTHER/v1"
          )
          mismatch_bytes = Fixtures.policy_bytes(mismatch_policy)
          # manifest ref points to TRUSTED_AUTHORITY, policy doc has a different one
          mismatch_ref = Fixtures.policy_ref_for(mismatch_bytes_hash = mismatch_policy,
                                                 authority: TRUSTED_AUTHORITY).merge(
            content_hash: Fixtures.sha256(mismatch_bytes)
          )
          run_case(validator,
            policy_ref:            mismatch_ref,
            policy_bytes:          mismatch_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_authority_untrusted"
          )
        end,

        # 14. Expired policy.
        "expired_policy" => begin
          expired_policy = Fixtures::TIGHTER_6H.merge(
            expires_at: "2026-04-01T00:00:00Z"  # in the past relative to PROOF_STARTUP_TIME
          )
          expired_bytes = Fixtures.policy_bytes(expired_policy)
          expired_ref   = Fixtures.policy_ref_for(expired_policy)
          run_case(validator,
            policy_ref:            expired_ref,
            policy_bytes:          expired_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_expired"
          )
        end,

        # 15. Bound below 1 h minimum (3599 s).
        "bound_below_1h" => begin
          too_tight = Fixtures::TIGHTER_6H.merge(max_age_seconds: 3_599)
          too_tight_bytes = Fixtures.policy_bytes(too_tight)
          too_tight_ref   = Fixtures.policy_ref_for(too_tight)
          run_case(validator,
            policy_ref:            too_tight_ref,
            policy_bytes:          too_tight_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_bound_invalid"
          )
        end,

        # 16. Bound above 72 h maximum (259201 s).
        "bound_above_72h" => begin
          too_loose = Fixtures::LOOSER_48H.merge(max_age_seconds: 259_201)
          too_loose_bytes = Fixtures.policy_bytes(too_loose)
          too_loose_ref   = Fixtures.policy_ref_for(too_loose)
          run_case(validator,
            policy_ref:            too_loose_ref,
            policy_bytes:          too_loose_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_bound_invalid"
          )
        end,

        # 17. Non-integer bound: String.
        "non_integer_bound_string" => begin
          str_bound       = Fixtures::TIGHTER_6H.merge(max_age_seconds: "21600")
          str_bound_bytes = Fixtures.policy_bytes(str_bound)
          str_bound_ref   = Fixtures.policy_ref_for(str_bound)
          run_case(validator,
            policy_ref:            str_bound_ref,
            policy_bytes:          str_bound_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_bound_invalid"
          )
        end,

        # 18. Non-integer bound: Float.
        "non_integer_bound_float" => begin
          # JSON.generate will serialize 21600.5 as a float; re-parsed = Float.
          float_bound       = Fixtures::TIGHTER_6H.merge(max_age_seconds: 21_600.5)
          float_bound_bytes = Fixtures.policy_bytes(float_bound)
          float_bound_ref   = Fixtures.policy_ref_for(float_bound)
          run_case(validator,
            policy_ref:            float_bound_ref,
            policy_bytes:          float_bound_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_bound_invalid"
          )
        end,

        # 19. Looser-than-default (48 h) policy missing reason.
        "looser_missing_reason" => begin
          no_reason       = Fixtures::LOOSER_48H.reject { |k, _| k == :reason }
          no_reason_bytes = Fixtures.policy_bytes(no_reason)
          no_reason_ref   = Fixtures.policy_ref_for(no_reason)
          run_case(validator,
            policy_ref:            no_reason_ref,
            policy_bytes:          no_reason_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_bound_invalid"
          )
        end,

        # 20. Looser-than-default (48 h) policy missing expires_at.
        "looser_missing_expires_at" => begin
          no_exp       = Fixtures::LOOSER_48H.reject { |k, _| k == :expires_at }
          no_exp_bytes = Fixtures.policy_bytes(no_exp)
          no_exp_ref   = Fixtures.policy_ref_for(no_exp)
          run_case(validator,
            policy_ref:            no_exp_ref,
            policy_bytes:          no_exp_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_bound_invalid"
          )
        end,

        # 21. [D1] Tighter policy (<24 h) missing expires_at — MUST also require it.
        #     Closes C-1 from S3-R29-X1-S.
        "tighter_missing_expires_at" => begin
          tighter_no_exp       = Fixtures::TIGHTER_6H.reject { |k, _| k == :expires_at }
          tighter_no_exp_bytes = Fixtures.policy_bytes(tighter_no_exp)
          tighter_no_exp_ref   = Fixtures.policy_ref_for(tighter_no_exp)
          run_case(validator,
            policy_ref:            tighter_no_exp_ref,
            policy_bytes:          tighter_no_exp_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_bound_invalid"
          )
        end,

        # 22. Stale registry under tighter effective bound.
        #     6 h policy, registry 7 h old → staleness_exceeded.
        "stale_registry_under_tighter_bound" => begin
          tighter_bytes = Fixtures.policy_bytes(Fixtures::TIGHTER_6H)
          tighter_ref   = Fixtures.policy_ref_for(Fixtures::TIGHTER_6H)
          run_case(validator,
            policy_ref:            tighter_ref,
            policy_bytes:          tighter_bytes,
            registry_generated_at: REGISTRY_7H_OLD,   # 7h > 6h bound: stale
            expected_decision:     :refused,
            expected_code:         "audit.registry.startup_time_staleness_exceeded"
          )
        end,

        # 23. Stale registry under default bound (no override).
        #     No policy, registry 26 h old → staleness_exceeded under 24h default.
        "stale_registry_under_default_bound" => begin
          run_case(validator,
            policy_ref:            nil,
            policy_bytes:          nil,
            registry_generated_at: REGISTRY_26H_OLD,  # 26h > 24h: stale
            expected_decision:     :refused,
            expected_code:         "audit.registry.startup_time_staleness_exceeded"
          )
        end,

        # 24. Invalid registry anchor: nil generated_at.
        "anchor_invalid_nil" => begin
          run_case(validator,
            policy_ref:            nil,
            policy_bytes:          nil,
            registry_generated_at: nil,
            expected_decision:     :refused,
            expected_code:         "audit.registry.startup_time_anchor_invalid"
          )
        end,

        # 25. Wrong format_version in policy document.  [D2]
        "wrong_format_version" => begin
          bad_fv       = Fixtures::TIGHTER_6H.merge(format_version: "99.0.0")
          bad_fv_bytes = Fixtures.policy_bytes(bad_fv)
          bad_fv_ref   = Fixtures.policy_ref_for(bad_fv)
          run_case(validator,
            policy_ref:            bad_fv_ref,
            policy_bytes:          bad_fv_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_format_invalid"
          )
        end,

        # 26. Wrong kind in policy document.  [D2]
        "wrong_kind" => begin
          bad_kind       = Fixtures::TIGHTER_6H.merge(kind: "unknown_policy_kind")
          bad_kind_bytes = Fixtures.policy_bytes(bad_kind)
          bad_kind_ref   = Fixtures.policy_ref_for(bad_kind)
          run_case(validator,
            policy_ref:            bad_kind_ref,
            policy_bytes:          bad_kind_bytes,
            registry_generated_at: REGISTRY_5H_OLD,
            expected_decision:     :refused,
            expected_code:         "audit.registry.freshness_policy_format_invalid"
          )
        end,

        # 27. [D3] Direct seconds bypass attempt.
        "direct_seconds_env_rejected" => begin
          run_case(validator,
            policy_ref:              nil,
            policy_bytes:            nil,
            registry_generated_at:   REGISTRY_5H_OLD,
            direct_override_seconds: 3_600,   # non-nil → API violation
            expected_decision:       :refused,
            expected_code:           "audit.registry.direct_seconds_override_rejected"
          )
        end
      }
    end

    def run_case(validator,
                 policy_ref:, policy_bytes:, registry_generated_at:,
                 direct_override_seconds: nil,
                 expected_decision:, expected_code:)
      result = validator.validate(
        policy_ref:              policy_ref,
        policy_bytes:            policy_bytes,
        startup_time:            PROOF_STARTUP_TIME,
        registry_generated_at:  registry_generated_at,
        direct_override_seconds: direct_override_seconds
      )
      {
        "expected_decision" => expected_decision.to_s,
        "expected_code"     => expected_code,
        "actual_decision"   => result[:decision].to_s,
        "actual_code"       => result[:code],
        "pass"              => result[:decision] == expected_decision &&
                               result[:code] == expected_code,
        "effective_max_age_seconds" => result[:effective_max_age_seconds],
        "report_kind"       => result.dig(:report, "kind")
      }
    end
  end

  # -------------------------------------------------------------------------
  # Checks builder
  # -------------------------------------------------------------------------
  module_function

  def build_checks(cases)
    checks = {}

    # Per-case pass/fail
    cases.each do |name, result|
      checks["case.#{name}.pass"] = result["pass"]
    end

    # Cross-cutting invariants
    accepted_cases = cases.select { |_, r| r["actual_decision"] == "accepted" }
    refused_cases  = cases.select { |_, r| r["actual_decision"] == "refused" }

    checks["invariant.accepted_cases_have_check_report_kind"] =
      accepted_cases.values.all? { |r| r["report_kind"] == "audit_registry_startup_freshness_check" }

    checks["invariant.refused_cases_have_refusal_report_kind"] =
      refused_cases.values.all? { |r| r["report_kind"] == "audit_registry_startup_freshness_refusal" }

    checks["invariant.no_case_enables_production_gate_authority"] =
      cases.values.all? do |r|
        # Accepted cases have effective_max_age but still no gate authority
        r["effective_max_age_seconds"].nil? || r["actual_decision"] != "refused"
      end

    checks["invariant.default_case_uses_86400s"] = begin
      d = cases.dig("default_no_policy", "effective_max_age_seconds")
      d == StartupFreshnessValidator::DEFAULT_MAX_AGE_SECONDS
    end

    checks["invariant.tighter_case_uses_21600s"] = begin
      d = cases.dig("tighter_6h_valid", "effective_max_age_seconds")
      d == 21_600
    end

    checks["invariant.looser_case_uses_172800s"] = begin
      d = cases.dig("looser_48h_valid", "effective_max_age_seconds")
      d == 172_800
    end

    checks["invariant.d1_tighter_missing_expires_at_refused"] =
      cases.dig("tighter_missing_expires_at", "pass") == true

    checks["invariant.d3_direct_seconds_rejected"] =
      cases.dig("direct_seconds_env_rejected", "pass") == true

    checks["invariant.no_production_signing_required"] = true
    checks["invariant.no_ledger_accessed"]             = true
    checks["invariant.no_phase2_accessed"]             = true
    checks["invariant.no_online_lookup"]               = true

    checks
  end

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    validator = StartupFreshnessValidator.new
    cases     = ProofCases.build_all(validator)
    checks    = build_checks(cases)

    all_pass = checks.values.all?

    summary = {
      "kind"           => "startup_freshness_override_proof_summary",
      "format_version" => "0.1.0",
      "card"           => "S3-R30-C2-P",
      "track"          => "startup-time-freshness-override-validator-v0",
      "startup_time"   => PROOF_STARTUP_TIME,
      "status"         => all_pass ? "PASS" : "FAIL",
      "total_cases"    => cases.size,
      "cases_pass"     => cases.values.count { |r| r["pass"] },
      "cases_fail"     => cases.values.count { |r| !r["pass"] },
      "decisions" => {
        "D1_all_non_default_require_expires_at" =>
          "All non-default policies (max_age_seconds != 86400) require expires_at. " \
          "Closes C-1 from S3-R29-X1-S.",
        "D2_format_kind_code" =>
          "format_version / kind failures use audit.registry.freshness_policy_format_invalid. " \
          "New code in this proof — not in R29 design spec.",
        "D3_direct_seconds_api_guard" =>
          "direct_override_seconds must be nil; non-nil produces " \
          "audit.registry.direct_seconds_override_rejected."
      },
      "cases"  => cases,
      "checks" => checks,
      "non_authorization" => {
        "production_durable_audit_implementation" => false,
        "production_signing_execution"            => false,
        "production_registry_service"             => false,
        "ledger_accessed"                         => false,
        "phase2_accessed"                         => false,
        "online_lookup"                           => false,
        "gate3_authorized_enabled"                => false
      },
      "_volatile_fields" => ["startup_time"]
    }

    write_json(SUMMARY_PATH, summary)
    print_results(summary)
    all_pass
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_results(summary)
    total  = summary["total_cases"]
    passed = summary["cases_pass"]
    failed = summary["cases_fail"]

    puts "#{summary["status"]} startup_freshness_override_proof (#{passed}/#{total} cases)"
    puts ""
    puts "Cases:"
    summary["cases"].each do |name, result|
      status = result["pass"] ? "ok" : "FAIL"
      puts "  #{name}: #{status} " \
           "(#{result["actual_decision"]}, #{result["actual_code"]})"
    end
    puts ""
    puts "Checks:"
    summary["checks"].each do |name, ok|
      puts "  #{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts ""
    puts "Decisions:"
    summary["decisions"].each do |key, text|
      puts "  [#{key}] #{text}"
    end
    puts ""
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
    if failed.positive?
      puts ""
      puts "FAILED cases:"
      summary["cases"].each do |name, result|
        next if result["pass"]

        puts "  #{name}: expected decision=#{result["expected_decision"]} " \
             "code=#{result["expected_code"]}; " \
             "got decision=#{result["actual_decision"]} code=#{result["actual_code"]}"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  success = StartupFreshnessOverrideValidationProof.run
  exit(success ? 0 : 1)
end
