#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

module TemporalReadObservationProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/temporal_read_observation_proof/out"
  SUMMARY_PATH = OUT_DIR / "temporal_read_observation_proof_summary.json"

  RESULT_STATUSES = %w[selected none refused error].freeze

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    positive = {
      "selected_read" => selected_read_observation,
      "none_read" => none_read_observation
    }
    negative = negative_cases(selected_read_observation)
    validation = validate_cases(positive, negative)

    summary = {
      "kind" => "temporal_read_observation_proof_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R13-C3-P",
      "track" => "prop-005-temporal-read-observation-v0",
      "status" => validation.fetch("checks").values.all? ? "PASS" : "FAIL",
      "scope" => {
        "proof_local" => true,
        "live_tbackend_eval" => false,
        "ledger_binding" => false,
        "production_persistence" => false,
        "history_only" => true,
        "bihistory" => false
      },
      "minimum_required_paths" => required_paths,
      "positive_observations" => positive,
      "negative_cases" => validation.fetch("negative_results"),
      "checks" => validation.fetch("checks"),
      "remaining_runtime_audit_gaps" => remaining_runtime_audit_gaps
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def selected_read_observation
    base_observation.merge(
      "observation_id" => "obs/history-read/2026-05-03/tech-1/selected",
      "temporal" => {
        "axis" => "valid_time",
        "as_of" => "2026-05-03T00:00:00Z",
        "valid_time" => "2026-05-03T00:00:00Z"
      },
      "result" => {
        "status" => "selected",
        "value" => {
          "kind" => "some",
          "value" => 7
        },
        "value_type" => "Integer",
        "selected_observation_ref" => "append/history/jobs-count/tech-1/2026-05-01"
      }
    )
  end

  def none_read_observation
    base_observation.merge(
      "observation_id" => "obs/history-read/2026-04-29/tech-1/none",
      "temporal" => {
        "axis" => "valid_time",
        "as_of" => "2026-04-29T00:00:00Z",
        "valid_time" => "2026-04-29T00:00:00Z"
      },
      "result" => {
        "status" => "none",
        "value" => {
          "kind" => "none"
        },
        "value_type" => "Integer",
        "selected_observation_ref" => nil
      }
    )
  end

  def base_observation
    {
      "kind" => "temporal_read_observation",
      "format_version" => "0.1.0",
      "emitted_at" => "2026-05-09T12:00:00Z",
      "operation" => "history_read_as_of",
      "fragment_class" => "TEMPORAL",
      "contract" => {
        "contract_id" => "TechnicianJobCountAt",
        "contract_ref" => "contract/TechnicianJobCountAt/sha256:8fe50f919712a4313c3c0572"
      },
      "store" => {
        "store_ref" => "tbackend/memory-history/proof-local",
        "store_kind" => "MemoryHistoryBackend",
        "descriptor_ref" => "descriptor/tbackend/history-read/proof-local"
      },
      "authorization" => {
        "approval_ref" => "approval/2026-05-09/gate3/history-phase1/proof-001",
        "gate_ref" => "gate3-decision-record-v0#phase1-history-valid-time",
        "authority_ref" => "architect-supervisor/proof-authority"
      },
      "evidence" => {
        "compatibility_report_ref" => "compatibility-report/history-phase1/proof-001",
        "executor_approval_token_ref" => "approval/2026-05-09/gate3/history-phase1/proof-001",
        "cache_key_ref" => "cache-key/temporal/history-valid-time/proof-001"
      },
      "persistence" => {
        "mode" => "proof_local",
        "persisted" => false,
        "audit_receipt_ref" => nil
      },
      "non_authorization" => {
        "live_tbackend_eval_in_this_proof" => false,
        "ledger_call_attempted" => false,
        "production_persistence" => false
      }
    }
  end

  def negative_cases(template)
    {
      "missing_kind" => without_path(template, %w[kind]),
      "missing_contract_ref" => without_path(template, %w[contract contract_ref]),
      "missing_store_ref" => without_path(template, %w[store store_ref]),
      "missing_as_of" => without_path(template, %w[temporal as_of]),
      "wrong_axis" => replace_path(template, %w[temporal axis], "bitemporal"),
      "missing_approval_ref" => without_path(template, %w[authorization approval_ref]),
      "missing_gate_ref" => without_path(template, %w[authorization gate_ref]),
      "missing_token_ref" => without_path(template, %w[evidence executor_approval_token_ref]),
      "missing_result_status" => without_path(template, %w[result status]),
      "bad_result_status" => replace_path(template, %w[result status], "maybe"),
      "noncanonical_some" => replace_path(template, %w[result value], { "some" => 7 })
    }
  end

  def validate_cases(positive, negative)
    positive_results = positive.transform_values { |observation| validate(observation) }
    negative_results = negative.transform_values { |observation| validate(observation) }
    {
      "negative_results" => negative_results,
      "checks" => {
        "positive.selected_read_observation_valid" => positive_results.fetch("selected_read").fetch("valid"),
        "positive.none_read_observation_valid" => positive_results.fetch("none_read").fetch("valid"),
        "positive.option_encoding_canonical" => canonical_option?(positive.fetch("selected_read").dig("result", "value")) &&
          canonical_option?(positive.fetch("none_read").dig("result", "value")),
        "positive.persistence_is_proof_local" => positive.values.all? { |observation| observation.dig("persistence", "mode") == "proof_local" },
        "positive.no_live_tbackend_eval" => positive.values.all? do |observation|
          observation.dig("non_authorization", "live_tbackend_eval_in_this_proof") == false
        end,
        "negative.required_fields_rejected" => negative_results.values.all? { |result| result.fetch("valid") == false }
      }
    }
  end

  def validate(observation)
    errors = []
    errors << "kind must be temporal_read_observation" unless observation["kind"] == "temporal_read_observation"
    errors << "format_version missing" unless present?(observation["format_version"])
    errors << "observation_id missing" unless present?(observation["observation_id"])
    errors << "contract.contract_ref missing" unless present?(observation.dig("contract", "contract_ref"))
    errors << "contract.contract_id missing" unless present?(observation.dig("contract", "contract_id"))
    errors << "store.store_ref missing" unless present?(observation.dig("store", "store_ref"))
    errors << "temporal.axis must be valid_time" unless observation.dig("temporal", "axis") == "valid_time"
    errors << "temporal.as_of missing" unless present?(observation.dig("temporal", "as_of"))
    errors << "temporal.valid_time missing" unless present?(observation.dig("temporal", "valid_time"))
    errors << "authorization.approval_ref missing" unless present?(observation.dig("authorization", "approval_ref"))
    errors << "authorization.gate_ref missing" unless present?(observation.dig("authorization", "gate_ref"))
    errors << "evidence.executor_approval_token_ref missing" unless present?(observation.dig("evidence", "executor_approval_token_ref"))
    errors << "result.status invalid" unless RESULT_STATUSES.include?(observation.dig("result", "status"))
    errors << "result.value must use canonical Option encoding" unless canonical_option?(observation.dig("result", "value"))

    {
      "valid" => errors.empty?,
      "errors" => errors
    }
  end

  def required_paths
    [
      "kind",
      "format_version",
      "observation_id",
      "contract.contract_id",
      "contract.contract_ref",
      "store.store_ref",
      "temporal.axis",
      "temporal.as_of",
      "temporal.valid_time",
      "authorization.approval_ref",
      "authorization.gate_ref",
      "evidence.executor_approval_token_ref",
      "result.status",
      "result.value"
    ]
  end

  def canonical_option?(value)
    return false unless value.is_a?(Hash)

    case value["kind"]
    when "some"
      value.key?("value") && value.keys.sort == %w[kind value]
    when "none"
      value.keys == ["kind"]
    else
      false
    end
  end

  def present?(value)
    !value.nil? && value != ""
  end

  def without_path(value, path)
    copy = deep_copy(value)
    parent = path[0...-1].reduce(copy) { |memo, key| memo.fetch(key) }
    parent.delete(path.last)
    copy
  end

  def replace_path(value, path, replacement)
    copy = deep_copy(value)
    parent = path[0...-1].reduce(copy) { |memo, key| memo.fetch(key) }
    parent[path.last] = replacement
    copy
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end

  def remaining_runtime_audit_gaps
    [
      "Production RuntimeMachine must emit this envelope before/around every authorized live History[T] read.",
      "The envelope must be connected to composed CompatibilityReport and ExecutorApprovalToken validation.",
      "Production persistence and audit receipts remain separate from emission and are not solved here.",
      "A live TBackend adapter must attach the actual store/descriptor reference and selected append observation.",
      "BiHistory, Ledger replay, writes, streams, OLAP, and invariant persistence remain out of scope."
    ]
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} temporal_read_observation_proof"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = TemporalReadObservationProof.run
exit(success ? 0 : 1)
