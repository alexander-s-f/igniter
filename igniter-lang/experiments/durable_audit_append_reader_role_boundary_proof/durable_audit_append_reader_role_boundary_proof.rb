#!/usr/bin/env ruby
# frozen_string_literal: true

# Phase 1 production durable audit — appender / reader role boundary proof.
#
# Card:  S3-R34-C2-P
# Track: durable-audit-append-reader-role-boundary-proof-v0
# Auth:  S3-R30-C1-A (architect-supervisor://igniter-lang/gates/
#          phase1-production-durable-audit/bounded-implementation-v0/2026-05-10)
# Design amendment: S3-R32-C1-P (durable-audit-hash-and-posture-design-amendment-v0)
#
# This proof covers B-C (surface 7 of S3-R30-C1-A):
#   - phase1_audit_appender role: may append valid records; denied reader ops
#   - phase1_audit_reader role: may traverse/verify; denied append
#   - Rebuild failure state gates new appends (P-43 answer [D1])
#   - Unknown/nil role produces deterministic refusal diagnostics
#   - Role violations emit audit.writer.unauthorized / audit.reader.unauthorized
#
# [D1] P-43 ANSWER:
#   Production append MUST gate on clean rebuild status.
#   The RoleGatedStore models this: rebuild_status must equal "clean" for any
#   append to proceed. A failed rebuild state emits:
#     audit.writer.rebuild_not_clean
#   This is the required production implementation guard. The proof-local
#   RestartRebuildEngine (C1-P) deliberately did not gate appends; this card
#   proves the gate model explicitly. A production store MUST implement this
#   gate before deployment authorization opens (B-D / P-43).
#
# Shared infrastructure required from the R31 bounded implementation proof.
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
#   ruby igniter-lang/experiments/durable_audit_append_reader_role_boundary_proof/
#         durable_audit_append_reader_role_boundary_proof.rb
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

# Require the R33 restart rebuild proof for regression check.
# Guarded by __FILE__ so it will not re-run its proof cases on require.
require_relative "../durable_audit_restart_rebuild_proof/" \
                 "durable_audit_restart_rebuild_proof"

module DurableAuditAppendReaderRoleBoundaryProof
  ROOT      = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR   = ROOT / "igniter-lang/experiments/durable_audit_append_reader_role_boundary_proof/out"
  SUMMARY_PATH = OUT_DIR / "durable_audit_append_reader_role_boundary_proof_summary.json"

  PROOF_TIMESTAMP   = "2026-05-11T12:00:00Z"
  AUTHORIZATION_REF =
    "architect-supervisor://igniter-lang/gates/" \
    "phase1-production-durable-audit/bounded-implementation-v0/2026-05-10"

  # Pull shared infrastructure from the R31 bounded implementation proof.
  Impl     = ProductionDurableAuditBoundedImplementationProof
  Schema   = Impl::Phase1ProductionAuditRecordSchema
  Store    = Impl::Phase1ProductionAuditStore
  Fixtures = Impl::Fixtures

  # -------------------------------------------------------------------------
  # Role constants
  # -------------------------------------------------------------------------
  APPENDER_ROLE = "phase1_audit_appender"
  READER_ROLE   = "phase1_audit_reader"

  # Refusal codes
  CODE_WRITER_UNAUTHORIZED    = "audit.writer.unauthorized"
  CODE_READER_UNAUTHORIZED    = "audit.reader.unauthorized"
  CODE_REBUILD_NOT_CLEAN      = "audit.writer.rebuild_not_clean"

  # -------------------------------------------------------------------------
  # RoleGatedStore
  #
  # Wraps Phase1ProductionAuditStore with role and rebuild-state enforcement.
  #
  # Roles:
  #   phase1_audit_appender — may call append; denied reader/traversal ops
  #   phase1_audit_reader   — may call traverse; denied append
  #
  # Rebuild gate (P-43) [D1]:
  #   rebuild_status must be "clean" before any append is allowed.
  #   A failed or unknown rebuild state emits audit.writer.rebuild_not_clean.
  #   This is the required production guard; the proof-local RestartRebuildEngine
  #   did not enforce it — this card closes P-43 by modelling it explicitly.
  # -------------------------------------------------------------------------
  class RoleGatedStore
    attr_reader :role, :rebuild_status, :store

    def initialize(role:, rebuild_status: "clean")
      @role           = role.freeze
      @rebuild_status = rebuild_status.freeze
      @store          = Store.new
    end

    # Attempt to append an audit record.
    #
    # Returns:
    #   { allowed: true,  result: <store result> }
    #   { allowed: false, code: <refusal_code>, detail: <string> }
    def append(audit_subject:, signer:, appended_at: PROOF_TIMESTAMP)
      # Role check first — must be appender
      unless role == APPENDER_ROLE
        return refused(CODE_WRITER_UNAUTHORIZED,
                       "role #{role.inspect} is not #{APPENDER_ROLE}")
      end

      # Rebuild gate (P-43) — must be clean
      unless rebuild_status == "clean"
        return refused(CODE_REBUILD_NOT_CLEAN,
                       "rebuild_status is #{rebuild_status.inspect}; " \
                       "append gated until rebuild is clean (P-43 production guard)")
      end

      result = store.append(audit_subject: audit_subject, signer: signer,
                            appended_at: appended_at)
      { allowed: true, result: result }
    end

    # Attempt to traverse stored records.
    #
    # Returns:
    #   { allowed: true,  records: <array> }
    #   { allowed: false, code: <refusal_code>, detail: <string> }
    def traverse
      unless role == READER_ROLE
        return refused(CODE_READER_UNAUTHORIZED,
                       "role #{role.inspect} is not #{READER_ROLE}")
      end

      { allowed: true, records: store.records.dup }
    end

    # Verify hash chain over stored records (reader-only operation).
    #
    # Returns:
    #   { allowed: true,  chain_result: <Hash> }
    #   { allowed: false, code: <refusal_code>, detail: <string> }
    def verify_chain
      unless role == READER_ROLE
        return refused(CODE_READER_UNAUTHORIZED,
                       "role #{role.inspect} is not #{READER_ROLE}")
      end

      { allowed: true, chain_result: store.verify_chain }
    end

    # Update rebuild status to model P-43 recovery flow.
    # (Called by proof to simulate a rebuild completing.)
    def update_rebuild_status(status)
      @rebuild_status = status.freeze
    end

    # How many records are currently in the underlying store.
    def record_count
      store.records.size
    end

    private

    def refused(code, detail)
      { allowed: false, code: code, detail: detail }
    end
  end

  # -------------------------------------------------------------------------
  # Helpers
  # -------------------------------------------------------------------------
  module_function

  def appender_store(rebuild_status: "clean")
    RoleGatedStore.new(role: APPENDER_ROLE, rebuild_status: rebuild_status)
  end

  def reader_store_with_records(count: 3)
    # Populate via an internal appender then expose to a reader-roled store.
    # Shares the underlying Store object so the reader sees the same records.
    appender = RoleGatedStore.new(role: APPENDER_ROLE, rebuild_status: "clean")
    signer   = Fixtures.valid_signer
    count.times do |i|
      res = appender.append(audit_subject: Fixtures.audit_subject(seq: i + 1),
                            signer: signer)
      raise "populate failed at seq #{i + 1}: #{res.inspect}" unless res[:allowed]
    end
    # Build a reader-roled wrapper that shares the SAME underlying store.
    reader = RoleGatedStore.new(role: READER_ROLE)
    reader.instance_variable_set(:@store, appender.store)
    reader
  end

  # =========================================================================
  # Proof Cases — 16 cases + 5 excluded-surface guards = 21 total
  # =========================================================================

  # ---------------------------------------------------------------------------
  # Surface 1: Appender role (3 cases)
  # ---------------------------------------------------------------------------
  def surface_1_appender_role
    results = {}
    signer  = Fixtures.valid_signer

    # 1a. phase1_audit_appender with clean rebuild can append.
    gs = appender_store
    res = gs.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["role.appender_can_append_clean_rebuild"] = {
      "pass"    => res[:allowed] == true && res.dig(:result, :appended) == true,
      "allowed" => res[:allowed],
      "appended" => res.dig(:result, :appended)
    }

    # 1b. phase1_audit_appender calling traverse is refused.
    # Appender role is not phase1_audit_reader → audit.reader.unauthorized.
    gs2 = appender_store
    res2 = gs2.traverse
    results["role.appender_traverse_refused"] = {
      "pass" => res2[:allowed] == false &&
                res2[:code] == CODE_READER_UNAUTHORIZED,
      "allowed" => res2[:allowed],
      "code"    => res2[:code]
    }

    # 1c. Appender appends multiple records successfully.
    gs3 = appender_store
    seq_results = (1..3).map do |i|
      gs3.append(audit_subject: Fixtures.audit_subject(seq: i), signer: signer)
    end
    results["role.appender_multi_append"] = {
      "pass"          => seq_results.all? { |r| r[:allowed] && r.dig(:result, :appended) },
      "record_count"  => gs3.record_count,
      "all_appended"  => seq_results.all? { |r| r[:allowed] }
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 2: Reader role (3 cases)
  # ---------------------------------------------------------------------------
  def surface_2_reader_role
    results = {}
    signer  = Fixtures.valid_signer

    # 2a. phase1_audit_reader can traverse populated store.
    reader = reader_store_with_records(count: 3)
    trav   = reader.traverse
    results["role.reader_can_traverse"] = {
      "pass"         => trav[:allowed] == true && trav[:records].size == 3,
      "allowed"      => trav[:allowed],
      "record_count" => trav[:records]&.size
    }

    # 2b. phase1_audit_reader calling append is refused.
    # Reader role is not phase1_audit_appender → audit.writer.unauthorized.
    reader2 = RoleGatedStore.new(role: READER_ROLE)
    res2 = reader2.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["role.reader_append_refused"] = {
      "pass"    => res2[:allowed] == false &&
                   res2[:code] == CODE_WRITER_UNAUTHORIZED,
      "allowed" => res2[:allowed],
      "code"    => res2[:code]
    }

    # 2c. Reader can verify chain integrity over traversed records.
    reader3 = reader_store_with_records(count: 3)
    vr = reader3.verify_chain
    results["role.reader_can_verify_chain"] = {
      "pass"     => vr[:allowed] == true &&
                    vr.dig(:chain_result, :verified) == true &&
                    vr.dig(:chain_result, :record_count) == 3,
      "allowed"  => vr[:allowed],
      "verified" => vr.dig(:chain_result, :verified),
      "record_count" => vr.dig(:chain_result, :record_count)
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 3: Rebuild gate — P-43 (4 cases)
  # ---------------------------------------------------------------------------
  def surface_3_rebuild_gate
    results = {}
    signer  = Fixtures.valid_signer

    # 3a. Appender + clean rebuild → append allowed.
    gs_clean = appender_store(rebuild_status: "clean")
    res_clean = gs_clean.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["p43.appender_clean_rebuild_allowed"] = {
      "pass"         => res_clean[:allowed] == true,
      "allowed"      => res_clean[:allowed],
      "rebuild_status" => gs_clean.rebuild_status
    }

    # 3b. Appender + failed rebuild → append refused with audit.writer.rebuild_not_clean.
    # [D1] This is the P-43 gate. A production store MUST refuse new appends
    # when rebuild status is not clean.
    gs_failed = appender_store(rebuild_status: "failed")
    res_failed = gs_failed.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["p43.appender_failed_rebuild_refused"] = {
      "pass"           => res_failed[:allowed] == false &&
                          res_failed[:code] == CODE_REBUILD_NOT_CLEAN,
      "allowed"        => res_failed[:allowed],
      "code"           => res_failed[:code],
      "rebuild_status" => gs_failed.rebuild_status
    }

    # 3c. Appender recovers: failed → clean → append allowed again.
    # Models the P-43 recovery flow: after a successful rebuild, the gate clears.
    gs_recover = appender_store(rebuild_status: "failed")
    res_before = gs_recover.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    gs_recover.update_rebuild_status("clean")
    res_after  = gs_recover.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["p43.appender_recovery_after_rebuild"] = {
      "pass"               => res_before[:allowed] == false &&
                              res_before[:code] == CODE_REBUILD_NOT_CLEAN &&
                              res_after[:allowed] == true,
      "before_allowed"     => res_before[:allowed],
      "before_code"        => res_before[:code],
      "after_allowed"      => res_after[:allowed],
      "after_rebuild_status" => gs_recover.rebuild_status
    }

    # 3d. P-43 code is deterministic: exactly "audit.writer.rebuild_not_clean".
    # Multiple calls with failed rebuild all emit the same code.
    gs_det = appender_store(rebuild_status: "failed")
    codes = 3.times.map do
      gs_det.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)[:code]
    end
    results["p43.rebuild_not_clean_code_deterministic"] = {
      "pass"  => codes.uniq == [CODE_REBUILD_NOT_CLEAN],
      "codes" => codes.uniq
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 4: Unknown / nil role (3 cases)
  # ---------------------------------------------------------------------------
  def surface_4_nil_and_unknown_roles
    results = {}
    signer  = Fixtures.valid_signer

    # 4a. nil role → append → audit.writer.unauthorized
    gs_nil = RoleGatedStore.new(role: nil, rebuild_status: "clean")
    res = gs_nil.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["role.nil_role_append_refused"] = {
      "pass"    => res[:allowed] == false && res[:code] == CODE_WRITER_UNAUTHORIZED,
      "allowed" => res[:allowed],
      "code"    => res[:code]
    }

    # 4b. nil role → traverse → audit.reader.unauthorized
    gs_nil2 = RoleGatedStore.new(role: nil, rebuild_status: "clean")
    res2 = gs_nil2.traverse
    results["role.nil_role_traverse_refused"] = {
      "pass"    => res2[:allowed] == false && res2[:code] == CODE_READER_UNAUTHORIZED,
      "allowed" => res2[:allowed],
      "code"    => res2[:code]
    }

    # 4c. Unknown role "phase1_admin" → append → audit.writer.unauthorized
    gs_admin = RoleGatedStore.new(role: "phase1_admin", rebuild_status: "clean")
    res3 = gs_admin.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["role.unknown_role_append_refused"] = {
      "pass"    => res3[:allowed] == false && res3[:code] == CODE_WRITER_UNAUTHORIZED,
      "allowed" => res3[:allowed],
      "code"    => res3[:code]
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 5: Cross-role isolation (3 cases)
  # ---------------------------------------------------------------------------
  def surface_5_cross_role_isolation
    results = {}
    signer  = Fixtures.valid_signer

    # 5a. Reader append refusal emits exactly audit.writer.unauthorized (deterministic).
    reader = RoleGatedStore.new(role: READER_ROLE, rebuild_status: "clean")
    res = reader.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
    results["isolation.reader_append_code_deterministic"] = {
      "pass"    => res[:allowed] == false && res[:code] == CODE_WRITER_UNAUTHORIZED,
      "allowed" => res[:allowed],
      "code"    => res[:code]
    }

    # 5b. Appender traverse refusal emits exactly audit.reader.unauthorized (deterministic).
    appender = appender_store(rebuild_status: "clean")
    res2 = appender.traverse
    results["isolation.appender_traverse_code_deterministic"] = {
      "pass"    => res2[:allowed] == false && res2[:code] == CODE_READER_UNAUTHORIZED,
      "allowed" => res2[:allowed],
      "code"    => res2[:code]
    }

    # 5c. Refused appends do NOT mutate the store.
    # Build a reader-role store and attempt several appends; record count stays 0.
    reader3 = RoleGatedStore.new(role: READER_ROLE, rebuild_status: "clean")
    5.times { reader3.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer) }
    # Rebuild-gated appender also produces no records
    blocked = appender_store(rebuild_status: "failed")
    5.times { blocked.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer) }
    results["isolation.refused_appends_do_not_mutate_store"] = {
      "pass"                => reader3.record_count == 0 && blocked.record_count == 0,
      "reader_record_count" => reader3.record_count,
      "blocked_record_count" => blocked.record_count
    }

    results
  end

  # ---------------------------------------------------------------------------
  # Surface 6: Non-authorization / excluded-surface guards (5 checks)
  # ---------------------------------------------------------------------------
  def surface_6_excluded_surfaces(all_allowed_results, all_refused_results)
    results = {}

    # 6a. No production_durable_audit claim in any proof-local store result.
    all_prod_false = all_allowed_results.all? do |r|
      store_result = r.dig(:result)
      # Appender results: check compliance_posture in the appended record.
      if store_result.is_a?(Hash) && store_result[:record].is_a?(Hash)
        store_result[:record].dig("compliance_posture", "production_durable_audit") == false
      else
        true  # traverse / verify_chain results — no production_durable_audit claim to check
      end
    end
    results["excluded.no_production_durable_audit_in_proof_local"] = {
      "pass"  => all_prod_false,
      "count" => all_allowed_results.size
    }

    # 6b. No Ledger constant or adapter referenced.
    results["excluded.no_ledger_access"] = {
      "pass" => !defined?(ProductionDurableAuditBoundedImplementationProof::LedgerAdapter) &&
                !defined?(DurableAuditAppendReaderRoleBoundaryProof::LedgerAdapter)
    }

    # 6c. No Phase 2 reference.
    results["excluded.no_phase2_access"] = {
      "pass" => !defined?(DurableAuditAppendReaderRoleBoundaryProof::Phase2)
    }

    # 6d. No concrete HSM/KMS onboarding.
    results["excluded.no_hsm_kms"] = {
      "pass" => !defined?(DurableAuditAppendReaderRoleBoundaryProof::HSMProvider) &&
                !defined?(DurableAuditAppendReaderRoleBoundaryProof::KMSClient)
    }

    # 6e. gate3_authorized not widened — no allowed result carries gate3_authorized: true.
    all_gate3_false = all_allowed_results.all? do |r|
      store_result = r.dig(:result)
      if store_result.is_a?(Hash)
        store_result[:gate3_authorized] != true
      else
        true
      end
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

    # Surface 1
    s1 = surface_1_appender_role
    surfaces["surface_1_appender_role"] = s1.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    # Surface 2
    s2 = surface_2_reader_role
    surfaces["surface_2_reader_role"] = s2.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    # Surface 3
    s3 = surface_3_rebuild_gate
    surfaces["surface_3_rebuild_gate_p43"] = s3.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    # Surface 4
    s4 = surface_4_nil_and_unknown_roles
    surfaces["surface_4_nil_unknown_roles"] = s4.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    # Surface 5
    s5 = surface_5_cross_role_isolation
    surfaces["surface_5_cross_role_isolation"] = s5.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    # Collect allowed results for invariant checks
    all_allowed_results = collect_all_allowed_results
    all_refused_results = collect_all_refused_results

    # Surface 6
    s6 = surface_6_excluded_surfaces(all_allowed_results, all_refused_results)
    surfaces["surface_6_excluded_surfaces"] = s6.values.all? { |v| v["pass"] } ? "PASS" : "FAIL"

    all_cases = s1.merge(s2).merge(s3).merge(s4).merge(s5).merge(s6)
    total     = all_cases.size
    passed    = all_cases.count { |_, v| v["pass"] }
    failed    = total - passed

    # Invariant checks
    checks = {}

    # All append refusals carry a deterministic code
    checks["invariant.all_refusals_have_deterministic_code"] =
      all_refused_results.all? { |r| r[:code].is_a?(String) && !r[:code].empty? }

    # Reader append always → audit.writer.unauthorized
    checks["invariant.reader_append_always_writer_unauthorized"] = begin
      signer = Fixtures.valid_signer
      readers = 3.times.map do
        r = RoleGatedStore.new(role: READER_ROLE, rebuild_status: "clean")
        r.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
      end
      readers.all? { |r| r[:code] == CODE_WRITER_UNAUTHORIZED }
    end

    # Appender traverse always → audit.reader.unauthorized
    checks["invariant.appender_traverse_always_reader_unauthorized"] = begin
      appenders = 3.times.map do
        gs = appender_store(rebuild_status: "clean")
        gs.traverse
      end
      appenders.all? { |r| r[:code] == CODE_READER_UNAUTHORIZED }
    end

    # P-43: rebuild_not_clean gate emits exactly CODE_REBUILD_NOT_CLEAN
    checks["invariant.p43_rebuild_gate_code_is_rebuild_not_clean"] = begin
      signer = Fixtures.valid_signer
      gs = appender_store(rebuild_status: "failed")
      res = gs.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
      res[:code] == CODE_REBUILD_NOT_CLEAN
    end

    # No Ledger/Phase2/HSM/KMS defined
    checks["invariant.no_ledger_access"] =
      !defined?(ProductionDurableAuditBoundedImplementationProof::LedgerAdapter) &&
      !defined?(DurableAuditAppendReaderRoleBoundaryProof::LedgerAdapter)

    checks["invariant.no_phase2_or_hsm_kms"] =
      !defined?(DurableAuditAppendReaderRoleBoundaryProof::Phase2) &&
      !defined?(DurableAuditAppendReaderRoleBoundaryProof::HSMProvider)

    checks_pass = checks.count { |_, v| v }
    checks_fail  = checks.size - checks_pass

    # Regression: run prior proofs to confirm no interference
    regression_results = run_regression_checks

    # Output
    puts "Surfaces:"
    surfaces.each { |k, v| puts "  #{k}: #{v}" }
    puts
    puts "Cases:"
    all_cases.each do |k, v|
      ok     = v["pass"]
      detail = if !ok
                 code = v["code"] || v["before_code"] || v["codes"]
                 " — #{code || "see detail"}"
               else
                 ""
               end
      puts "  #{k}: #{ok ? "ok" : "FAIL"}#{detail}"
    end
    puts
    puts "Invariant checks:"
    checks.each { |k, v| puts "  #{k}: #{v ? "ok" : "FAIL"}" }
    puts
    puts "Regression checks:"
    regression_results.each { |k, v| puts "  #{k}: #{v ? "ok" : "FAIL"}" }
    puts

    summary = {
      "kind"             => "durable_audit_append_reader_role_boundary_proof_summary",
      "format_version"   => "0.1.0",
      "card"             => "S3-R34-C2-P",
      "track"            => "durable-audit-append-reader-role-boundary-proof-v0",
      "authorization_ref" => AUTHORIZATION_REF,
      "design_amendment" => "durable-audit-hash-and-posture-design-amendment-v0 (S3-R32-C1-P)",
      "proof_timestamp"  => PROOF_TIMESTAMP,
      "status"           => (failed.zero? && checks_fail.zero?) ? "PASS" : "FAIL",
      "total_cases"      => total,
      "cases_pass"       => passed,
      "cases_fail"       => failed,
      "invariant_checks_pass" => checks_pass,
      "invariant_checks_fail" => checks_fail,
      "surfaces"         => surfaces,
      "cases"            => all_cases,
      "invariant_checks" => checks,
      "p43_decision" => {
        "question" => "Does production append gate on clean rebuild status?",
        "answer"   => "[D1] YES. The RoleGatedStore refuses all appends when " \
                      "rebuild_status != \"clean\". Refusal code: " \
                      "audit.writer.rebuild_not_clean. The proof-local " \
                      "RestartRebuildEngine (C1-P) did not implement this gate; " \
                      "a production store MUST implement it before B-D/deployment " \
                      "authorization (P-43 closed by this card).",
        "code"     => CODE_REBUILD_NOT_CLEAN
      },
      "non_authorization" => {
        "production_deployment"        => false,
        "ledger_adapter"               => false,
        "phase2"                       => false,
        "bihistory"                    => false,
        "stream_olap"                  => false,
        "production_cache"             => false,
        "hsm_kms_onboarding"           => false,
        "broad_runtimemachine_binding" => false,
        "gate3_authorized"             => false
      },
      "regression_checks" => regression_results
      # No _volatile_fields — proof uses only fixed constants (PROOF_TIMESTAMP, AUTHORIZATION_REF).
      # All outputs are deterministic. Omit key per volatile_fields_lint rules.
    }

    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
    puts

    overall_pass = failed.zero? && checks_fail.zero?
    if overall_pass
      puts "PASS durable_audit_append_reader_role_boundary_proof (#{passed}/#{total} cases)"
    else
      puts "FAIL durable_audit_append_reader_role_boundary_proof (#{passed}/#{total} cases)"
    end

    abort "FAIL durable_audit_append_reader_role_boundary_proof" unless overall_pass
  end

  # =========================================================================
  # Helpers for invariant collection
  # =========================================================================
  module_function

  # Collect all "allowed" outcomes for invariant cross-check.
  def collect_all_allowed_results
    signer = Fixtures.valid_signer
    results = []

    # Appender appends
    gs = appender_store
    results << gs.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)

    # Multi-append
    gs2 = appender_store
    3.times { |i| results << gs2.append(audit_subject: Fixtures.audit_subject(seq: i + 1), signer: signer) }

    # Clean rebuild appender
    gs3 = appender_store(rebuild_status: "clean")
    results << gs3.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)

    results
  end

  # Collect all "refused" outcomes for invariant cross-check.
  def collect_all_refused_results
    signer  = Fixtures.valid_signer
    results = []

    # Appender traverse refused
    results << appender_store.traverse

    # Reader append refused
    results << RoleGatedStore.new(role: READER_ROLE).append(
      audit_subject: Fixtures.audit_subject(seq: 1), signer: signer
    )

    # Failed-rebuild appender
    results << appender_store(rebuild_status: "failed").append(
      audit_subject: Fixtures.audit_subject(seq: 1), signer: signer
    )

    # nil role
    results << RoleGatedStore.new(role: nil).append(
      audit_subject: Fixtures.audit_subject(seq: 1), signer: signer
    )
    results << RoleGatedStore.new(role: nil).traverse

    # unknown role
    results << RoleGatedStore.new(role: "phase1_admin").append(
      audit_subject: Fixtures.audit_subject(seq: 1), signer: signer
    )

    results
  end

  # Run the prior proof regressions.
  def run_regression_checks
    checks = {}

    # R31: bounded implementation proof — re-run a single append to confirm shared infra intact.
    begin
      signer = Fixtures.valid_signer
      store  = Store.new
      result = store.append(audit_subject: Fixtures.audit_subject(seq: 1), signer: signer)
      checks["regression.r31_bounded_impl_append_ok"] = result[:appended] == true
    rescue StandardError => e
      checks["regression.r31_bounded_impl_append_ok"] = false
      checks["regression.r31_error"] = e.message
    end

    # R33: restart rebuild proof — confirm a clean 2-record rebuild still passes.
    begin
      s2 = Store.new
      sig = Fixtures.valid_signer
      records = 2.times.map do |i|
        s2.append(audit_subject: Fixtures.audit_subject(seq: i + 1), signer: sig)[:record]
      end
      rb = DurableAuditRestartRebuildProof::RestartRebuildEngine.rebuild(records)
      checks["regression.r33_restart_rebuild_clean_ok"] = rb[:success] == true && rb[:rebuild_status] == "clean"
    rescue StandardError => e
      checks["regression.r33_restart_rebuild_clean_ok"] = false
      checks["regression.r33_error"] = e.message
    end

    checks
  end
end

# ============================================================================
# Run if invoked directly.
# ============================================================================
DurableAuditAppendReaderRoleBoundaryProof.run if $PROGRAM_NAME == __FILE__
