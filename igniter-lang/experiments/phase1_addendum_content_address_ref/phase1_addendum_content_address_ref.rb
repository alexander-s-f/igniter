#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_executor"

module Phase1AddendumContentAddressRefProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  ADDENDUM_PATH = LANG_ROOT / "docs/gates/gate3-live-read-decision-addendum-v0.md"
  DOCUMENT_PATH = "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md"
  OUT_DIR = LANG_ROOT / "experiments/phase1_addendum_content_address_ref/out"
  SUMMARY_PATH = OUT_DIR / "phase1_addendum_content_address_ref_summary.json"

  EXPECTED_STATUS = "signed-approved-restricted-phase1-live-read"
  EXPECTED_SIGNED_ON = "2026-05-09"
  EXPECTED_AUTHORITY_REF = IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    reference = build_reference
    cases = {
      "valid_content_address_ref" => verify_envelope(envelope(reference)),
      "path_exists_hash_mismatch" => verify_envelope(
        envelope(reference.merge("content_sha256" => "sha256:#{'0' * 64}"))
      ),
      "status_not_signed_approved" => verify_envelope(
        envelope(reference.merge("status" => "draft-not-signed"))
      ),
      "authority_ref_mismatch" => verify_envelope(
        envelope(reference.merge("authority_ref" => "architect-supervisor://wrong"))
      ),
      "human_path_and_content_identity_present" => verify_envelope(envelope(reference))
    }
    checks = build_checks(cases)
    summary = {
      "kind" => "phase1_addendum_content_address_ref_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R22-C2-P",
      "track" => "phase1-addendum-content-address-ref-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "reference_shape" => reference_shape,
      "actual_reference" => reference,
      "cases" => cases,
      "checks" => checks,
      "non_authorization" => {
        "production_registry_required" => false,
        "production_signing_required" => false,
        "signed_addendum_mutated" => false,
        "phase2_ledger_adapter" => false
      }
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def reference_shape
    {
      "document_path" => "human-readable path",
      "git_commit" => "git commit containing/reading the evidence",
      "content_sha256" => "sha256:<document bytes>",
      "status" => EXPECTED_STATUS,
      "signed_on" => EXPECTED_SIGNED_ON,
      "authority_ref" => EXPECTED_AUTHORITY_REF
    }
  end

  def build_reference
    {
      "document_path" => DOCUMENT_PATH,
      "git_commit" => git_commit,
      "content_sha256" => content_sha256(ADDENDUM_PATH),
      "status" => parsed_status,
      "signed_on" => parsed_signed_on,
      "authority_ref" => parsed_authority_ref
    }
  end

  def envelope(reference)
    {
      "kind" => "phase1_signed_addendum_invocation_evidence",
      "format_version" => "0.1.0",
      "human_reference" => {
        "document_path" => reference.fetch("document_path")
      },
      "content_addressed_identity" => reference,
      "requested_gate3_authorized" => true
    }
  end

  def verify_envelope(value)
    human_path = value.dig("human_reference", "document_path")
    identity = value["content_addressed_identity"] || {}
    return blocked("addendum_ref.path_missing") unless human_path == DOCUMENT_PATH
    return blocked("addendum_ref.identity_missing") unless identity.is_a?(Hash)
    return blocked("addendum_ref.document_path_mismatch") unless identity["document_path"] == human_path
    return blocked("addendum_ref.git_commit_missing") unless present?(identity["git_commit"])

    actual_hash = content_sha256(ADDENDUM_PATH)
    return blocked("addendum_ref.content_hash_mismatch", "expected" => actual_hash, "got" => identity["content_sha256"]) unless identity["content_sha256"] == actual_hash
    return blocked("addendum_ref.status_not_signed_approved", "got" => identity["status"]) unless identity["status"] == EXPECTED_STATUS
    return blocked("addendum_ref.signed_on_mismatch", "got" => identity["signed_on"]) unless identity["signed_on"] == EXPECTED_SIGNED_ON
    return blocked("addendum_ref.authority_ref_mismatch", "got" => identity["authority_ref"]) unless identity["authority_ref"] == EXPECTED_AUTHORITY_REF

    {
      "status" => "ok",
      "caller_may_reference_signed_addendum" => true,
      "human_path_present" => true,
      "content_addressed_identity_present" => true,
      "document_path" => human_path,
      "git_commit" => identity.fetch("git_commit"),
      "content_sha256" => identity.fetch("content_sha256"),
      "authority_ref" => identity.fetch("authority_ref"),
      "production_registry_required" => false,
      "production_signing_required" => false
    }
  end

  def blocked(reason_code, extra = {})
    {
      "status" => "blocked",
      "caller_may_reference_signed_addendum" => false,
      "reason_code" => reason_code,
      "production_registry_required" => false,
      "production_signing_required" => false
    }.merge(extra)
  end

  def build_checks(cases)
    {
      "valid_reference.ok" =>
        cases.dig("valid_content_address_ref", "status") == "ok",
      "valid_reference.carries_human_path" =>
        cases.dig("valid_content_address_ref", "human_path_present") == true,
      "valid_reference.carries_content_identity" =>
        cases.dig("valid_content_address_ref", "content_addressed_identity_present") == true,
      "hash_mismatch.blocks" =>
        cases.dig("path_exists_hash_mismatch", "reason_code") == "addendum_ref.content_hash_mismatch",
      "status_not_signed.blocks" =>
        cases.dig("status_not_signed_approved", "reason_code") == "addendum_ref.status_not_signed_approved",
      "authority_ref_mismatch.blocks" =>
        cases.dig("authority_ref_mismatch", "reason_code") == "addendum_ref.authority_ref_mismatch",
      "human_and_content_case.ok" =>
        cases.dig("human_path_and_content_identity_present", "status") == "ok",
      "no_case_requires_production_registry" =>
        cases.values.all? { |result| result["production_registry_required"] == false },
      "no_case_requires_production_signing" =>
        cases.values.all? { |result| result["production_signing_required"] == false }
    }
  end

  def parsed_status
    addendum_text[/^Status:\s*(.+)$/, 1].to_s.strip
  end

  def parsed_signed_on
    addendum_text[/^Signed on:\s*`([^`]+)`$/, 1].to_s.strip
  end

  def parsed_authority_ref
    addendum_text[/architect-supervisor:\/\/igniter-lang\/gates\/gate3\/runtime-temporal-executor\/restricted-history-valid-time-v0\/2026-05-09/, 0]
  end

  def addendum_text
    @addendum_text ||= ADDENDUM_PATH.read
  end

  def content_sha256(path)
    "sha256:#{Digest::SHA256.file(path).hexdigest}"
  end

  def git_commit
    ENV.fetch("GIT_COMMIT", "workspace-current")
  end

  def present?(value)
    !value.nil? && value != ""
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} phase1_addendum_content_address_ref"
    summary.fetch("checks").each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = Phase1AddendumContentAddressRefProof.run
  exit(success ? 0 : 1)
end
