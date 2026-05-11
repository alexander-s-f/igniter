#!/usr/bin/env ruby
# frozen_string_literal: true

# Phase 1 production durable audit — restart rebuild proof.
#
# Card:  S3-R33-C1-P
# Track: durable-audit-restart-rebuild-proof-v0
# Auth:  S3-R30-C1-A (architect-supervisor://igniter-lang/gates/
#          phase1-production-durable-audit/bounded-implementation-v0/2026-05-10)
# Design amendment: S3-R32-C1-P (durable-audit-hash-and-posture-design-amendment-v0)
#
# This proof covers B-A (surface 4 of S3-R30-C1-A):
#   - Restart rebuild from stored records
#   - Canonical record_hash chain verification
#   - compliance_posture mismatch detection (R32 D2/D3)
#   - Missing, duplicated, and out-of-order records
#   - Storage identity consistency
#   - Format/kind enforcement
#   - Cursor behavior: stops at first failure, full scan continues
#
# [D1] Sharper question answered: when rebuild detects a mismatch, the CURSOR
#   stops at the failed record (no new appends may proceed past it). The full
#   scan continues reading all records to produce a complete error report. The
#   cursor = first_failure_at, not the end of the record list.
#
# Shared infrastructure is required from the R31 bounded implementation proof.
# All schema, signer, and store classes are defined there and reused here.
#
# Excluded surfaces — confirmed not present in this proof:
#   - Ledger adapter / Ledger writes / replay / compact / subscribe
#   - Phase 2, BiHistory, stream/OLAP production executors
#   - Production cache, broad RuntimeMachine binding
#   - Concrete HSM/KMS onboarding / production signing execution
#   - Broader gate3_authorized surface
#
# Usage:
#   ruby igniter-lang/experiments/durable_audit_restart_rebuild_proof/
#         durable_audit_restart_rebuild_proof.rb
#
# Exit 0 = all checks PASS.  Exit 1 = at least one check FAIL.

require "digest"
require "fileutils"
require "json"
require "time"
require "pathname"

# Require the R31 bounded implementation proof for shared infrastructure.
# The proof runs only under __FILE__ guard so requiring it is safe.
require_relative "../production_durable_audit_bounded_implementation_proof/" \
                 "production_durable_audit_bounded_implementation_proof"

module DurableAuditRestartRebuildProof
  ROOT      = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR   = ROOT / "igniter-lang/experiments/durable_audit_restart_rebuild_proof/out"
  SUMMARY_PATH = OUT_DIR / "durable_audit_restart_rebuild_proof_summary.json"

  PROOF_TIMESTAMP   = "2026-05-10T12:00:00Z"
  AUTHORIZATION_REF =
    "architect-supervisor://igniter-lang/gates/" \
    "phase1-production-durable-audit/bounded-implementation-v0/2026-05-10"

  # Pull shared infrastructure from the R31 bounded implementation proof.
  Impl     = ProductionDurableAuditBoundedImplementationProof
  Schema   = Impl::Phase1ProductionAuditRecordSchema
  Store    = Impl::Phase1ProductionAuditStore
  Fixtures = Impl::Fixtures

  # -------------------------------------------------------------------------
  # RestartRebuildEngine
  #
  # Implements the restart rebuild algorithm from:
  #   - phase1-production-durable-audit-v0.md (R26 + R32 amendment)
  #   - durable-audit-hash-and-posture-design-amendment-v0.md (R32 D2/D3)
  #
  # Algorithm:
  #   1. Format version and kind validation
  #   2. Sequence continuity (gap, duplicate, out-of-order detection)
  #   3. Storage identity consistency
  #   4. Previous-record-hash chain verification
  #   5. Canonical record_hash recomputation
  #   6. compliance_posture mismatch check (R32)
  #
  # [D1] Cursor behavior:
  #   - CURSOR stops at the FIRST failure (no new appends may proceed past it).
  #   - Full scan continues to collect ALL errors.
  #   - cursor = first_failure_at (not end of list).
  #   - Never auto-truncate, auto-compact, or auto-repair the audit log.
  # -------------------------------------------------------------------------
  module RestartRebuildEngine
    module_function

    # Rebuild from a list of records in storage order.
    #
    # records:              Array<Hash> — records from the audit store
    # expected_storage_id:  String|nil  — if given, all records must match
    #
    # Returns:
    #   {
    #     success:          true | false,
    #     rebuild_status:   "clean" | "failed",
    #     cursor:           Integer,        # next safe append sequence
    #     verified_count:   Integer,        # records verified before first failure
    #     total_scanned:    Integer,
    #     errors:           Array<Hash>,    # all errors found (full scan)
    #     first_failure_at: Integer | nil,  # sequence of first error
    #     production_durable_audit: false,  # proof-local: always false
    #     ledger:           false,
    #     gate3_authorized: false
    #   }
    def rebuild(records, expected_storage_id: nil)
      return clean_result(cursor: 1, verified_count: 0, scanned: 0) if records.empty?

      errors         = []
      first_failure  = nil
      verified_up_to = 0
      prior_record   = nil
      first_storage_id = nil

      records.each_with_index do |record, idx|
        expected_seq = idx + 1

        # 1. Format version and kind
        fv = record.dig("format_version").to_s
        unless Schema::RECOGNIZED_FORMAT_VERSIONS.include?(fv)
          code = fv.empty? ? "audit.record.format_version_missing"
                           : "audit.record.format_version_unrecognized"
          err = { "sequence" => record.dig("chain", "sequence") || expected_seq,
                  "code"     => code,
                  "detail"   => "format_version: #{fv.inspect}" }
          errors << err
          first_failure ||= err["sequence"]
          prior_record = record
          next
        end

        kind = record.dig("kind").to_s
        unless Schema::RECOGNIZED_KINDS.include?(kind)
          err = { "sequence" => record.dig("chain", "sequence") || expected_seq,
                  "code"     => "audit.record.kind_unrecognized",
                  "detail"   => "kind: #{kind.inspect}" }
          errors << err
          first_failure ||= err["sequence"]
          prior_record = record
          next
        end

        # 2. Sequence continuity
        actual_seq = record.dig("chain", "sequence")
        unless actual_seq == expected_seq
          err = { "sequence"        => expected_seq,
                  "code"            => "audit.chain.sequence_gap",
                  "detail"          => "expected seq #{expected_seq}, got #{actual_seq.inspect}",
                  "actual_sequence" => actual_seq }
          errors << err
          first_failure ||= expected_seq
          prior_record = record
          next
        end

        # 3. Storage identity consistency
        sid = record["storage_identity"]
        if sid.is_a?(Hash)
          storage_id_val = sid["storage_id"].to_s
          if first_storage_id.nil?
            first_storage_id = storage_id_val
          elsif storage_id_val != first_storage_id
            err = { "sequence" => actual_seq,
                    "code"     => "audit.record.storage_identity_mismatch",
                    "detail"   => "expected storage_id #{first_storage_id.inspect}, " \
                                  "got #{storage_id_val.inspect}" }
            errors << err
            first_failure ||= actual_seq
            prior_record = record
            next
          end

          # Check against caller-provided expectation
          if expected_storage_id && storage_id_val != expected_storage_id
            err = { "sequence" => actual_seq,
                    "code"     => "audit.record.storage_identity_mismatch",
                    "detail"   => "expected_storage_id #{expected_storage_id.inspect}, " \
                                  "got #{storage_id_val.inspect}" }
            errors << err
            first_failure ||= actual_seq
            prior_record = record
            next
          end
        end

        # 4. Previous-record-hash
        expected_prev = idx.zero? ? "genesis"
                                  : prior_record.dig("chain", "record_hash").to_s
        actual_prev   = record.dig("chain", "previous_record_hash").to_s

        unless actual_prev == expected_prev
          err = { "sequence" => actual_seq,
                  "code"     => "audit.chain.previous_hash_mismatch",
                  "detail"   => "expected #{expected_prev.inspect}, got #{actual_prev.inspect}" }
          errors << err
          first_failure ||= actual_seq
          prior_record = record
          next
        end

        # 5. Canonical record_hash recomputation
        recomputed_hash = Schema.compute_record_hash(record)
        stored_hash     = record.dig("chain", "record_hash").to_s

        unless stored_hash == recomputed_hash
          err = { "sequence" => actual_seq,
                  "code"     => "audit.chain.record_hash_mismatch",
                  "detail"   => "recomputed #{recomputed_hash.inspect} != stored #{stored_hash.inspect}" }
          errors << err
          first_failure ||= actual_seq
          prior_record = record
          next
        end

        # 6. compliance_posture mismatch check (R32 D2/D3)
        stored_posture  = record["compliance_posture"]
        sig_field       = record["signature"] || {}
        derived_posture = Schema.derive_compliance_posture(
          storage_identity:  sid || {},
          signature:         sig_field,
          chain_seq:         actual_seq,
          authorization_ref: AUTHORIZATION_REF
        )

        unless stored_posture == derived_posture
          err = { "sequence" => actual_seq,
                  "code"     => "audit.record.compliance_posture_mismatch",
                  "detail"   => "stored != derived posture",
                  "stored"   => stored_posture,
                  "derived"  => derived_posture }
          errors << err
          first_failure ||= actual_seq
          prior_record = record
          next
        end

        # Record passed all checks
        verified_up_to = actual_seq
        prior_record = record
      end

      # [D1] Cursor is the FIRST failure sequence (not end of list).
      # If no failures, cursor = last verified + 1.
      cursor = first_failure || (verified_up_to + 1)

      if errors.empty?
        clean_result(cursor: cursor, verified_count: verified_up_to, scanned: records.size)
      else
        # verified_count = number of records before the first failure
        verified_count = first_failure.nil? ? verified_up_to : (first_failure - 1)
        {
          success:          false,
          rebuild_status:   "failed",
          cursor:           cursor,
          verified_count:   verified_count,
          total_scanned:    records.size,
          errors:           errors,
          first_failure_at: first_failure,
          production_durable_audit: false,   # proof-local: always false
          ledger:           false,
          gate3_authorized: false
        }
      end
    end

    def clean_result(cursor:, verified_count:, scanned:)
      {
        success:          true,
        rebuild_status:   "clean",
        cursor:           cursor,
        verified_count:   verified_count,
        total_scanned:    scanned,
        errors:           [],
        first_failure_at: nil,
        production_durable_audit: false,   # proof-local: always false
        ledger:           false,
        gate3_authorized: false
      }
    end
  end

  # -------------------------------------------------------------------------
  # Helpers
  # -------------------------------------------------------------------------
  module_function

  def build_chain(n, signer: nil, store: nil)
    signer ||= Fixtures.valid_signer
    store  ||= Store.new
    (1..n).map do |i|
      result = store.append(
        audit_subject: Fixtures.audit_subject(seq: i),
        signer:        signer,
        appended_at:   PROOF_TIMESTAMP
      )
      raise "build_chain failed at seq #{i}: #{result.inspect}" unless result[:appended]
      result[:record]
    end
  end

  # Return a mutable (unfrozen) deep copy of a record.
  def mutable_copy(record)
    JSON.parse(JSON.generate(record))
  end

  # =========================================================================
  # Proof Cases — 16 cases across 6 surfaces
  # =========================================================================

  # ---------------------------------------------------------------------------
  # Surface 1: Clean rebuild (4 cases)
  # ---------------------------------------------------------------------------
  def surface_1_clean_rebuild
    results = {}

    # 1a. empty store
    r = RestartRebuildEngine.rebuild([])
    results["rebuild.empty_store"] = {
      "pass" => r[:success] == true && r[:cursor] == 1 && r[:verified_count] == 0,
      "cursor" => r[:cursor], "verified" => r[:verified_count]
    }

    # 1b. single record
    records = build_chain(1)
    r = RestartRebuildEngine.rebuild(records)
    results["rebuild.single_record"] = {
      "pass" => r[:success] == true && r[:cursor] == 2 && r[:verified_count] == 1,
      "cursor" => r[:cursor], "verified" => r[:verified_count]
    }

    # 1c. two records
    records = build_chain(2)
    r = RestartRebuildEngine.rebuild(records)
    results["rebuild.two_records"] = {
      "pass" => r[:success] == true && r[:cursor] == 3 && r[:verified_count] == 2,
      "cursor" => r[:cursor], "verified" => r[:verified_count]
    }

    # 1d. five records
    records = build_chain(5)
    r = RestartRebuildEngine.rebuild(records)
    results["rebuild.five_records"] = {
      "pass" => r[:success] == true && r[:cursor] == 6 && r[:verified_count] == 5,
      "cursor" => r[:cursor], "verified" => r[:verified_count]
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 2: Hash chain integrity failures (4 cases)
  # ---------------------------------------------------------------------------
  def surface_2_chain_integrity
    results = {}
    signer  = Fixtures.valid_signer

    # 2a. tampered record_hash — record 2 hash changed to a wrong value.
    # rebuild detects recomputed != stored for seq=2.
    records = build_chain(3, signer: signer)
    tampered = mutable_copy(records[1])
    tampered["chain"]["record_hash"] = "sha256:#{"0" * 64}"
    r = RestartRebuildEngine.rebuild([records[0], tampered, records[2]])
    results["rebuild.tampered_record_hash"] = {
      "pass" => r[:success] == false &&
                r[:first_failure_at] == 2 &&
                r[:errors].any? { |e| e["code"] == "audit.chain.record_hash_mismatch" },
      "first_failure_at" => r[:first_failure_at],
      "error_code" => r[:errors]&.first&.dig("code")
    }

    # 2b. tampered previous_hash — record 2 previous_hash set to a wrong value.
    records = build_chain(2, signer: signer)
    tampered = mutable_copy(records[1])
    tampered["chain"]["previous_record_hash"] = "sha256:#{"a" * 64}"
    r = RestartRebuildEngine.rebuild([records[0], tampered])
    results["rebuild.tampered_previous_hash"] = {
      "pass" => r[:success] == false &&
                r[:first_failure_at] == 2 &&
                r[:errors].any? { |e| e["code"] == "audit.chain.previous_hash_mismatch" },
      "first_failure_at" => r[:first_failure_at],
      "error_code" => r[:errors]&.first&.dig("code")
    }

    # 2c. sequence gap — pass [r1, r3] (r2 missing).
    records = build_chain(3, signer: signer)
    r = RestartRebuildEngine.rebuild([records[0], records[2]])
    results["rebuild.sequence_gap"] = {
      "pass" => r[:success] == false &&
                r[:first_failure_at] == 2 &&
                r[:errors].any? { |e| e["code"] == "audit.chain.sequence_gap" },
      "first_failure_at" => r[:first_failure_at],
      "error_code" => r[:errors]&.first&.dig("code")
    }

    # 2d. out-of-order — pass [r2, r1].
    records = build_chain(2, signer: signer)
    r = RestartRebuildEngine.rebuild([records[1], records[0]])
    results["rebuild.out_of_order"] = {
      "pass" => r[:success] == false &&
                r[:first_failure_at] == 1 &&
                r[:errors].any? { |e| e["code"] == "audit.chain.sequence_gap" },
      "first_failure_at" => r[:first_failure_at],
      "error_code" => r[:errors]&.first&.dig("code")
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 3: compliance_posture mismatch (R32 D2/D3) (3 cases)
  # ---------------------------------------------------------------------------
  def surface_3_posture_mismatch
    results = {}
    signer = Fixtures.valid_signer

    # 3a. Single posture mismatch at seq=2.
    # Tamper r2's stored compliance_posture (set production_durable_audit: true).
    # Hash is unaffected (compliance_posture excluded from hash).
    # Rebuild detects stored != derived.
    records = build_chain(3, signer: signer)
    tampered = mutable_copy(records[1])
    tampered["compliance_posture"]["production_durable_audit"] = true  # wrong!
    r = RestartRebuildEngine.rebuild([records[0], tampered, records[2]])
    results["rebuild.compliance_posture_mismatch"] = {
      "pass" => r[:success] == false &&
                r[:first_failure_at] == 2 &&
                r[:errors].any? { |e| e["code"] == "audit.record.compliance_posture_mismatch" },
      "first_failure_at" => r[:first_failure_at],
      "error_code" => r[:errors]&.first&.dig("code")
    }

    # 3b. Cursor stops at first posture mismatch; full scan continues.
    # 4 records, r2 posture tampered, r4 posture tampered.
    # Both independent (compliance_posture not in hash, chain continues).
    records = build_chain(4, signer: signer)
    r2_bad = mutable_copy(records[1])
    r2_bad["compliance_posture"]["production_durable_audit"] = true
    r4_bad = mutable_copy(records[3])
    r4_bad["compliance_posture"]["signature_verified"] = false  # also wrong
    r = RestartRebuildEngine.rebuild([records[0], r2_bad, records[2], r4_bad])
    results["rebuild.full_scan_reports_multiple_posture_errors"] = {
      "pass" => r[:success] == false &&
                r[:first_failure_at] == 2 &&       # cursor at first failure
                r[:errors].size == 2 &&             # full scan found both
                r[:verified_count] == 1 &&          # only seq=1 verified
                r[:errors].all? { |e|
                  e["code"] == "audit.record.compliance_posture_mismatch"
                },
      "first_failure_at" => r[:first_failure_at],
      "error_count" => r[:errors]&.size,
      "verified_count" => r[:verified_count]
    }

    # 3c. Cursor stops — verified_count == first_failure_at - 1.
    # [D1] Verifies the sharper question: cursor = first_failure_at, not list end.
    records = build_chain(5, signer: signer)
    r3_bad  = mutable_copy(records[2])
    r3_bad["compliance_posture"]["production_durable_audit"] = true
    rebuilt = RestartRebuildEngine.rebuild([records[0], records[1], r3_bad,
                                            records[3], records[4]])
    results["rebuild.cursor_stops_at_first_failure"] = {
      "pass" => rebuilt[:success] == false &&
                rebuilt[:first_failure_at] == 3 &&
                rebuilt[:cursor] == 3 &&            # [D1]: cursor at failure point
                rebuilt[:verified_count] == 2 &&    # seq 1+2 verified
                rebuilt[:total_scanned] == 5,       # full scan: all 5 records read
      "cursor" => rebuilt[:cursor],
      "verified_count" => rebuilt[:verified_count],
      "total_scanned" => rebuilt[:total_scanned],
      "first_failure_at" => rebuilt[:first_failure_at]
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 4: Schema / format failures (3 cases)
  # ---------------------------------------------------------------------------
  def surface_4_schema_failures
    results = {}
    signer  = Fixtures.valid_signer

    # 4a. Wrong format_version in chain position.
    records = build_chain(2, signer: signer)
    bad_fv = mutable_copy(records[1])
    bad_fv["format_version"] = "0.1.0"  # proof-local startup freshness format — rejected
    r = RestartRebuildEngine.rebuild([records[0], bad_fv])
    results["rebuild.wrong_format_version"] = {
      "pass" => r[:success] == false &&
                r[:first_failure_at] == 2 &&
                r[:errors].any? { |e| e["code"] == "audit.record.format_version_unrecognized" },
      "first_failure_at" => r[:first_failure_at],
      "error_code" => r[:errors]&.first&.dig("code")
    }

    # 4b. Wrong kind in chain position.
    records = build_chain(2, signer: signer)
    bad_kind = mutable_copy(records[1])
    bad_kind["kind"] = "phase2_audit_record"  # wrong kind — rejected
    r = RestartRebuildEngine.rebuild([records[0], bad_kind])
    results["rebuild.wrong_kind"] = {
      "pass" => r[:success] == false &&
                r[:first_failure_at] == 2 &&
                r[:errors].any? { |e| e["code"] == "audit.record.kind_unrecognized" },
      "first_failure_at" => r[:first_failure_at],
      "error_code" => r[:errors]&.first&.dig("code")
    }

    # 4c. Storage identity mismatch — r2's storage_identity.storage_id tampered.
    # The record is a mutable copy of a valid r2, but with storage_id changed.
    # The storage_identity check (step 3) fires before the hash check (step 5),
    # so mismatch is detected even though the hash would also fail.
    records = build_chain(2, signer: signer)
    r2_sid_bad = mutable_copy(records[1])
    r2_sid_bad["storage_identity"]["storage_id"] = "audit/gate3/phase1/proof-local/different-chain"
    r = RestartRebuildEngine.rebuild([records[0], r2_sid_bad])
    results["rebuild.storage_identity_mismatch"] = {
      "pass" => r[:success] == false &&
                r[:first_failure_at] == 2 &&
                r[:errors].any? { |e| e["code"] == "audit.record.storage_identity_mismatch" },
      "first_failure_at" => r[:first_failure_at],
      "error_code" => r[:errors]&.first&.dig("code")
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 5: Chain edge cases (2 cases)
  # ---------------------------------------------------------------------------
  def surface_5_edge_cases
    results = {}
    signer = Fixtures.valid_signer

    # 5a. First record must have previous_record_hash = "genesis".
    # Tamper the first record's previous_record_hash.
    records = build_chain(1, signer: signer)
    r1_bad  = mutable_copy(records[0])
    r1_bad["chain"]["previous_record_hash"] = "sha256:#{"b" * 64}"  # not genesis
    r = RestartRebuildEngine.rebuild([r1_bad])
    results["rebuild.first_record_wrong_prev_hash"] = {
      "pass" => r[:success] == false &&
                r[:first_failure_at] == 1 &&
                r[:errors].any? { |e| e["code"] == "audit.chain.previous_hash_mismatch" },
      "first_failure_at" => r[:first_failure_at],
      "error_code" => r[:errors]&.first&.dig("code")
    }

    # 5b. signed_payload_hash consistent with record_hash in clean rebuild.
    # verify that for each clean record: signed_payload_hash == record_hash.
    records = build_chain(3, signer: signer)
    consistent = records.all? do |rec|
      rec.dig("signature", "signed_payload_hash") == rec.dig("chain", "record_hash")
    end
    r = RestartRebuildEngine.rebuild(records)
    results["rebuild.signed_payload_hash_consistent"] = {
      "pass" => r[:success] == true && consistent,
      "consistent" => consistent,
      "rebuild_success" => r[:success]
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 6: Non-authorization / excluded-surface guards (5 checks)
  # ---------------------------------------------------------------------------
  def surface_6_excluded_surfaces(all_rebuild_results)
    results = {}

    # 6a. No production_durable_audit claim in any proof-local rebuild result.
    all_prod_false = all_rebuild_results.all? do |r|
      r[:production_durable_audit] == false
    end
    results["excluded.no_production_durable_audit_in_proof_local"] = {
      "pass" => all_prod_false,
      "count" => all_rebuild_results.size
    }

    # 6b. No Ledger constant or adapter referenced.
    results["excluded.no_ledger_access"] = {
      "pass" => !defined?(ProductionDurableAuditBoundedImplementationProof::LedgerAdapter) &&
                !defined?(DurableAuditRestartRebuildProof::LedgerAdapter)
    }

    # 6c. No Phase 2 reference.
    results["excluded.no_phase2_access"] = {
      "pass" => !defined?(DurableAuditRestartRebuildProof::Phase2)
    }

    # 6d. No concrete HSM/KMS onboarding.
    results["excluded.no_hsm_kms"] = {
      "pass" => !defined?(DurableAuditRestartRebuildProof::HSMProvider) &&
                !defined?(DurableAuditRestartRebuildProof::KMSClient)
    }

    # 6e. gate3_authorized not widened — all rebuild results carry false.
    all_gate3_false = all_rebuild_results.all? do |r|
      r[:gate3_authorized] == false
    end
    results["excluded.gate3_authorized_not_widened"] = {
      "pass" => all_gate3_false
    }

    results
  end

  # =========================================================================
  # Runner
  # =========================================================================
  def run
    FileUtils.mkdir_p(OUT_DIR)

    surfaces = {}
    all_rebuild_results = []

    # Surface 1
    s1 = surface_1_clean_rebuild
    surfaces["surface_1_clean_rebuild"] = s1.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    # Surface 2
    s2 = surface_2_chain_integrity
    surfaces["surface_2_chain_integrity"] = s2.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    # Surface 3
    s3 = surface_3_posture_mismatch
    surfaces["surface_3_posture_mismatch"] = s3.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    # Surface 4
    s4 = surface_4_schema_failures
    surfaces["surface_4_schema_failures"] = s4.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    # Surface 5
    s5 = surface_5_edge_cases
    surfaces["surface_5_edge_cases"] = s5.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    # Collect all rebuild results for invariant checks
    [s1, s2, s3, s4, s5].each do |surface_results|
      # We need the raw rebuild results; re-run to collect them
    end
    all_rebuild_results = collect_all_rebuild_results

    # Surface 6: excluded-surface guards
    s6 = surface_6_excluded_surfaces(all_rebuild_results)
    surfaces["surface_6_excluded_surfaces"] = s6.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    all_cases = s1.merge(s2).merge(s3).merge(s4).merge(s5).merge(s6)
    total     = all_cases.size
    passed    = all_cases.count { |_, v| v["pass"] }
    failed    = total - passed

    # Invariant checks (cross-cutting)
    checks = {}
    checks["invariant.no_production_durable_audit_in_proof_local"] =
      all_rebuild_results.all? { |r| r[:production_durable_audit] == false }
    checks["invariant.no_ledger_access"] =
      !defined?(ProductionDurableAuditBoundedImplementationProof::LedgerAdapter)
    checks["invariant.no_phase2_access"] =
      !defined?(DurableAuditRestartRebuildProof::Phase2)
    checks["invariant.no_hsm_kms"] =
      !defined?(DurableAuditRestartRebuildProof::HSMProvider)
    checks["invariant.cursor_never_past_first_failure"] =
      all_rebuild_results.select { |r| r[:success] == false }.all? do |r|
        r[:cursor] == r[:first_failure_at]
      end
    checks["invariant.mismatch_code_used_for_posture_errors"] =
      s3.any? { |_, v| v["error_code"] == "audit.record.compliance_posture_mismatch" }

    checks_pass = checks.count { |_, v| v }
    checks_fail = checks.size - checks_pass

    # Output
    puts "Surfaces:"
    surfaces.each { |k, v| puts "  #{k}: #{v}" }
    puts
    puts "Cases:"
    all_cases.each do |k, v|
      ok = v["pass"]
      detail = if !ok
                 code = v["error_code"] || v["code"]
                 " — #{code || "see detail"}"
               elsif v["error_code"]
                 " — #{v["error_code"]}"
               else
                 ""
               end
      puts "  #{k}: #{ok ? "ok" : "FAIL"}#{detail}"
    end
    puts
    puts "Invariant checks:"
    checks.each { |k, v| puts "  #{k}: #{v ? "ok" : "FAIL"}" }
    puts
    puts "Remaining blockers before audit traversal/reader:"

    blockers = remaining_blockers
    blockers.each { |b| puts "  [#{b[:blocker]}] #{b[:description]}" }

    summary = {
      "kind"             => "durable_audit_restart_rebuild_proof_summary",
      "format_version"   => "0.1.0",
      "card"             => "S3-R33-C1-P",
      "track"            => "durable-audit-restart-rebuild-proof-v0",
      "authorization_ref" => AUTHORIZATION_REF,
      "design_amendment" => "durable-audit-hash-and-posture-design-amendment-v0 (S3-R32-C1-P)",
      "proof_timestamp"  => PROOF_TIMESTAMP,
      "status"           => failed.zero? && checks_fail.zero? ? "PASS" : "FAIL",
      "total_cases"      => total,
      "cases_pass"       => passed,
      "cases_fail"       => failed,
      "invariant_checks_pass" => checks_pass,
      "invariant_checks_fail" => checks_fail,
      "surfaces"         => surfaces,
      "cases"            => all_cases,
      "invariant_checks" => checks,
      "sharper_question_d1" => {
        "question" => "On mismatch, does rebuild stop at cursor or abort full scan?",
        "answer"   => "Cursor stops at first_failure_at. Full scan continues. " \
                      "cursor = first_failure_at. Never auto-repair or overwrite stored records."
      },
      "non_authorization" => {
        "production_deployment"       => false,
        "ledger_adapter"              => false,
        "phase2"                      => false,
        "bihistory"                   => false,
        "stream_olap"                 => false,
        "production_cache"            => false,
        "hsm_kms_onboarding"          => false,
        "broad_runtimemachine_binding" => false,
        "gate3_authorized"            => false
      },
      "remaining_blockers" => blockers
      # No _volatile_fields — proof uses only fixed constants (PROOF_TIMESTAMP, AUTHORIZATION_REF).
      # All outputs are deterministic. Omit key per volatile_fields_lint rules.
    }

    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
    puts "\nsummary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
    puts

    overall_pass = failed.zero? && checks_fail.zero?
    if overall_pass
      puts "PASS durable_audit_restart_rebuild_proof (#{passed}/#{total} cases)"
    else
      puts "FAIL durable_audit_restart_rebuild_proof (#{passed}/#{total} cases)"
    end

    abort "FAIL durable_audit_restart_rebuild_proof" unless overall_pass
  end

  def collect_all_rebuild_results
    signer   = Fixtures.valid_signer
    results  = []

    # Clean rebuilds
    results << RestartRebuildEngine.rebuild([])
    results << RestartRebuildEngine.rebuild(build_chain(1, signer: signer))
    results << RestartRebuildEngine.rebuild(build_chain(2, signer: signer))
    results << RestartRebuildEngine.rebuild(build_chain(5, signer: signer))

    # Tampered hash
    records  = build_chain(3, signer: signer)
    tampered = mutable_copy(records[1])
    tampered["chain"]["record_hash"] = "sha256:#{"0" * 64}"
    results << RestartRebuildEngine.rebuild([records[0], tampered, records[2]])

    # Tampered prev hash
    records  = build_chain(2, signer: signer)
    tampered = mutable_copy(records[1])
    tampered["chain"]["previous_record_hash"] = "sha256:#{"a" * 64}"
    results << RestartRebuildEngine.rebuild([records[0], tampered])

    # Sequence gap
    records = build_chain(3, signer: signer)
    results << RestartRebuildEngine.rebuild([records[0], records[2]])

    # Out-of-order
    records = build_chain(2, signer: signer)
    results << RestartRebuildEngine.rebuild([records[1], records[0]])

    # Posture mismatch — single
    records  = build_chain(3, signer: signer)
    tampered = mutable_copy(records[1])
    tampered["compliance_posture"]["production_durable_audit"] = true
    results << RestartRebuildEngine.rebuild([records[0], tampered, records[2]])

    # Posture mismatch — multiple
    records = build_chain(4, signer: signer)
    r2_bad  = mutable_copy(records[1])
    r2_bad["compliance_posture"]["production_durable_audit"] = true
    r4_bad  = mutable_copy(records[3])
    r4_bad["compliance_posture"]["signature_verified"] = false
    results << RestartRebuildEngine.rebuild([records[0], r2_bad, records[2], r4_bad])

    # Cursor stops case
    records = build_chain(5, signer: signer)
    r3_bad  = mutable_copy(records[2])
    r3_bad["compliance_posture"]["production_durable_audit"] = true
    results << RestartRebuildEngine.rebuild([records[0], records[1], r3_bad,
                                             records[3], records[4]])

    # Wrong format_version
    records = build_chain(2, signer: signer)
    bad_fv  = mutable_copy(records[1])
    bad_fv["format_version"] = "0.1.0"
    results << RestartRebuildEngine.rebuild([records[0], bad_fv])

    # Wrong kind
    records   = build_chain(2, signer: signer)
    bad_kind  = mutable_copy(records[1])
    bad_kind["kind"] = "phase2_audit_record"
    results << RestartRebuildEngine.rebuild([records[0], bad_kind])

    # Storage identity mismatch — r2's storage_id tampered
    records_sid = build_chain(2, signer: signer)
    r2_sid_bad  = mutable_copy(records_sid[1])
    r2_sid_bad["storage_identity"]["storage_id"] = "audit/gate3/phase1/proof-local/different"
    results << RestartRebuildEngine.rebuild([records_sid[0], r2_sid_bad])

    # First record wrong prev hash
    records = build_chain(1, signer: signer)
    r1_bad  = mutable_copy(records[0])
    r1_bad["chain"]["previous_record_hash"] = "sha256:#{"b" * 64}"
    results << RestartRebuildEngine.rebuild([r1_bad])

    # Signed payload hash consistent
    results << RestartRebuildEngine.rebuild(build_chain(3, signer: signer))

    results
  end

  def remaining_blockers
    [
      { blocker: "B-B",
        description: "Audit traversal / reader proof not yet implemented (surface 6 of S3-R30-C1-A)",
        surface: "audit traversal",
        required_before: "deployment authorization" },
      { blocker: "B-C",
        description: "Appender / reader role boundary proof not yet implemented (surface 7 of S3-R30-C1-A)",
        surface: "role boundary",
        required_before: "deployment authorization" },
      { blocker: "B-D",
        description: "Post-implementation full regression matrix not yet run (S3-R30-C1-A surface 9 requires all new proofs + existing proofs PASS)",
        surface: "regression",
        required_before: "deployment authorization" },
      { blocker: "B-E",
        description: "Production deployment, HSM/KMS onboarding, and production signing remain closed until S3-R30-C1-A follow-up Architect review",
        surface: "non-authorization",
        required_before: "any production deployment" }
    ]
  end

  def deep_dup(obj)
    case obj
    when Hash  then obj.transform_values { |v| deep_dup(v) }
    when Array then obj.map { |v| deep_dup(v) }
    else            obj
    end
  end
end

if $PROGRAM_NAME == __FILE__
  DurableAuditRestartRebuildProof.run
end
