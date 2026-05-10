#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_access_runtime"
require_relative "../../lib/igniter_lang/temporal_executor"

module Phase1DurableObservationPersistenceShape
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  ADDENDUM_PATH = LANG_ROOT / "docs/gates/gate3-live-read-decision-addendum-v0.md"
  OUT_DIR = LANG_ROOT / "experiments/phase1_durable_observation_persistence_shape/out"
  STORE_PATH = OUT_DIR / "phase1_observation_store.jsonl"
  SUMMARY_PATH = OUT_DIR / "phase1_durable_observation_persistence_shape_summary.json"

  AUTHORITY_REF = IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF
  SIGNED_STATUS = "signed-approved-restricted-phase1-live-read"
  DECISION_DOC_REF = ADDENDUM_PATH.relative_path_from(ROOT).to_s
  PROOF_AS_OF = "2026-05-09T12:00:00Z"
  PERSISTED_AT = "2026-05-10T00:00:00Z"

  module_function

  class ProofLocalObservationStore
    ALLOWED_OPERATION = "append_observation_record"

    attr_reader :path

    def initialize(path)
      @path = path
      FileUtils.mkdir_p(path.dirname)
      File.write(path, "")
    end

    def persist(envelope, operation:, adapter_family:)
      return blocked("persistence.ledger_adapter_excluded", operation, adapter_family) if adapter_family == "ledger"
      return blocked("persistence.phase1_operation_excluded", operation, adapter_family) unless operation == ALLOWED_OPERATION

      missing = required_envelope_fields.reject { |field| envelope.key?(field) && !envelope[field].nil? }
      return blocked("persistence.envelope_missing_required_fields", operation, adapter_family, "missing" => missing) unless missing.empty?

      record = persistence_record(envelope)
      File.open(path, "a") { |file| file.write("#{JSON.generate(record)}\n") }
      {
        "status" => "persisted",
        "kind" => "phase1_observation_persistence_receipt",
        "record_id" => record.fetch("record_id"),
        "store_ref" => path.basename.to_s,
        "operation" => operation,
        "adapter_family" => adapter_family,
        "production_durable_audit" => false,
        "ledger_write" => false
      }
    end

    def line_count
      return 0 unless path.exist?

      path.readlines.size
    end

    private

    def required_envelope_fields
      %w[
        temporal_live_read_observation
        compatibility_report_ref
        authority_ref
        signed_addendum_ref
        backend_identity
        result
      ]
    end

    def persistence_record(envelope)
      {
        "kind" => "phase1_observation_persistence_record",
        "format_version" => "0.1.0",
        "record_id" => record_id(envelope),
        "persistence_mode" => "proof_local_file",
        "persisted_at" => PERSISTED_AT,
        "source_envelope_kind" => envelope.fetch("kind"),
        "source_envelope_id" => envelope.fetch("envelope_id"),
        "temporal_live_read_observation" => envelope.fetch("temporal_live_read_observation"),
        "compatibility_report_ref" => envelope.fetch("compatibility_report_ref"),
        "authority_ref" => envelope.fetch("authority_ref"),
        "signed_addendum_ref" => envelope.fetch("signed_addendum_ref"),
        "backend_identity" => envelope.fetch("backend_identity"),
        "result" => envelope.fetch("result"),
        "caveat" => {
          "audit_ready" => true,
          "production_durable_audit" => false,
          "production_compliance_claim" => false,
          "ledger" => false
        }
      }
    end

    def record_id(envelope)
      "phase1/obs/#{Digest::SHA256.hexdigest(JSON.generate(envelope))[0, 20]}"
    end

    def blocked(reason_code, operation, adapter_family, extra = {})
      {
        "status" => "blocked",
        "kind" => "phase1_observation_persistence_refusal",
        "reason_code" => reason_code,
        "operation" => operation,
        "adapter_family" => adapter_family,
        "production_durable_audit" => false,
        "ledger_write" => false
      }.merge(extra)
    end
  end

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    envelope = build_audit_ready_envelope
    store = ProofLocalObservationStore.new(STORE_PATH)
    before_lines = store.line_count
    persisted = store.persist(envelope, operation: "append_observation_record", adapter_family: "proof_local_file")
    after_allowed_lines = store.line_count

    cases = {
      "allowed_observation_persisted" => {
        "receipt" => persisted,
        "line_count_before" => before_lines,
        "line_count_after" => after_allowed_lines,
        "record" => read_first_record
      },
      "ledger_adapter_excluded" => blocked_case(store, envelope, "append_observation_record", "ledger"),
      "write_excluded" => blocked_case(store, envelope, "write", "proof_local_file"),
      "replay_excluded" => blocked_case(store, envelope, "replay", "proof_local_file"),
      "compact_excluded" => blocked_case(store, envelope, "compact", "proof_local_file"),
      "subscribe_excluded" => blocked_case(store, envelope, "subscribe", "proof_local_file")
    }
    checks = build_checks(cases, store.line_count)
    summary = {
      "kind" => "phase1_durable_observation_persistence_shape_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R23-C1-P",
      "track" => "phase1-durable-observation-persistence-shape-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "addendum" => {
        "path" => DECISION_DOC_REF,
        "status" => read_addendum_status,
        "signed" => read_addendum_status == SIGNED_STATUS
      },
      "store" => {
        "path" => STORE_PATH.relative_path_from(ROOT).to_s,
        "mode" => "proof_local_file",
        "production_durable_audit" => false,
        "production_compliance_claim" => false,
        "ledger" => false
      },
      "persistable_shape" => persistable_shape,
      "cases" => cases,
      "checks" => checks
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def blocked_case(store, envelope, operation, adapter_family)
    before = store.line_count
    refusal = store.persist(envelope, operation: operation, adapter_family: adapter_family)
    {
      "refusal" => refusal,
      "line_count_before" => before,
      "line_count_after" => store.line_count
    }
  end

  def build_audit_ready_envelope
    executor = IgniterLang::TemporalExecutor::Phase1.new(backend: memory_backend, gate3_authorized: true)
    evaluation = executor.evaluate(history_contract, token: valid_token, inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF)
    observation = executor.observations.fetch(0)
    {
      "kind" => "audit_ready_temporal_read_envelope",
      "format_version" => "0.1.0",
      "envelope_id" => envelope_id(observation, evaluation),
      "export_mode" => "explicit",
      "audit_state" => "audit_ready_not_persisted",
      "temporal_live_read_observation" => observation,
      "compatibility_report_ref" => evaluation.fetch("compatibility_report_id"),
      "authority_ref" => valid_token.fetch("authority_ref"),
      "signed_addendum_ref" => DECISION_DOC_REF,
      "backend_identity" => observation.fetch("backend_identity"),
      "result" => {
        "status" => "allowed",
        "reason_code" => IgniterLang::TemporalExecutor::ReasonCode::EVALUATION_READY,
        "result_present" => observation.fetch("result_present")
      },
      "storage" => {
        "automatic_persistence" => false,
        "durable_persistence" => false,
        "ledger_write" => false,
        "production_storage" => false
      }
    }
  end

  def persistable_shape
    {
      "kind" => "phase1_observation_persistence_record",
      "persistence_mode" => "proof_local_file",
      "fields" => [
        "temporal_live_read_observation",
        "compatibility_report_ref",
        "authority_ref",
        "signed_addendum_ref",
        "backend_identity",
        "result"
      ],
      "caveat" => {
        "audit_ready" => true,
        "production_durable_audit" => false,
        "production_compliance_claim" => false,
        "ledger" => false
      }
    }
  end

  def build_checks(cases, final_line_count)
    {
      "allowed_observation.persisted_once" =>
        cases.dig("allowed_observation_persisted", "receipt", "status") == "persisted" &&
          cases.dig("allowed_observation_persisted", "line_count_before") == 0 &&
          cases.dig("allowed_observation_persisted", "line_count_after") == 1,
      "record.minimum_shape_present" =>
        persistence_record_has_minimum_shape?(cases.dig("allowed_observation_persisted", "record")),
      "record.audit_ready_not_production_audit" =>
        cases.dig("allowed_observation_persisted", "record", "caveat", "audit_ready") == true &&
          cases.dig("allowed_observation_persisted", "record", "caveat", "production_durable_audit") == false &&
          cases.dig("allowed_observation_persisted", "record", "caveat", "production_compliance_claim") == false,
      "ledger_adapter.excluded" =>
        blocked_without_append?(cases.fetch("ledger_adapter_excluded"), "persistence.ledger_adapter_excluded"),
      "write.excluded" =>
        blocked_without_append?(cases.fetch("write_excluded"), "persistence.phase1_operation_excluded"),
      "replay.excluded" =>
        blocked_without_append?(cases.fetch("replay_excluded"), "persistence.phase1_operation_excluded"),
      "compact.excluded" =>
        blocked_without_append?(cases.fetch("compact_excluded"), "persistence.phase1_operation_excluded"),
      "subscribe.excluded" =>
        blocked_without_append?(cases.fetch("subscribe_excluded"), "persistence.phase1_operation_excluded"),
      "negative_cases.did_not_append" =>
        final_line_count == 1
    }
  end

  def persistence_record_has_minimum_shape?(record)
    %w[
      temporal_live_read_observation
      compatibility_report_ref
      authority_ref
      signed_addendum_ref
      backend_identity
      result
    ].all? { |field| record.key?(field) && !record[field].nil? }
  end

  def blocked_without_append?(entry, reason_code)
    entry.dig("refusal", "status") == "blocked" &&
      entry.dig("refusal", "reason_code") == reason_code &&
      entry.fetch("line_count_after") == entry.fetch("line_count_before")
  end

  def read_first_record
    JSON.parse(STORE_PATH.readlines.first)
  end

  def envelope_id(observation, evaluation)
    Digest::SHA256.hexdigest(JSON.generate([observation, evaluation.fetch("compatibility_report_id")]))[0, 20]
  end

  def valid_token
    {
      "kind" => "executor_approval_token",
      "version" => "executor-approval-token-v1",
      "token_id" => "approval/durable-observation-shape",
      "authority_ref" => AUTHORITY_REF,
      "gate" => "tbackend_gate3"
    }
  end

  def memory_backend
    backend = IgniterLang::TemporalAccessRuntime::MemoryBackend.new
    backend.seed_append_observations([
      { "subject" => "sku/prod-001/price", "valid_from" => "2026-01-01T00:00:00Z",
        "value" => "99.00", "value_type" => "String" }
    ])
    backend
  end

  def history_contract
    {
      "contract_id" => "HistoryAxesTest",
      "fragment_class" => "temporal",
      "temporal_nodes" => [
        { "kind" => "temporal_input_node", "name" => "price_history",
          "store_ref" => "sku/{sku}/price" },
        { "kind" => "temporal_access_node", "name" => "price_at",
          "source_ref" => "price_history", "axis" => "valid_time",
          "as_of_ref" => "as_of" }
      ]
    }
  end

  def read_addendum_status
    line = ADDENDUM_PATH.readlines.find { |candidate| candidate.start_with?("Status:") }
    line.to_s.split(":", 2).last.to_s.strip
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} phase1_durable_observation_persistence_shape"
    summary.fetch("checks").each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = Phase1DurableObservationPersistenceShape.run
  exit(success ? 0 : 1)
end
