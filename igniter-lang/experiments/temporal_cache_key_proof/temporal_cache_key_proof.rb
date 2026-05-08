#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"
require "time"

module TemporalCacheKeyProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/temporal_cache_key_proof"
  SUMMARY_PATH = OUT_DIR / "temporal_cache_key_proof.json"

  CACHE_KEY_VERSION = "temporal-cache-key-proof-v0"

  module Canonical
    module_function

    def normalize(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) do |key, out|
          out[key.to_s] = normalize(value.fetch(key))
        end
      when Array
        value.map { |entry| normalize(entry) }
      when Symbol
        value.to_s
      else
        value
      end
    end

    def json(value)
      JSON.generate(normalize(value))
    end

    def hash(value)
      "sha256:#{Digest::SHA256.hexdigest(json(value))}"
    end

    def short_hash(value)
      hash(value).delete_prefix("sha256:")[0, 16]
    end
  end

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    summary = build_summary
    write_summary(summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_summary
    examples = {
      "core" => core_examples,
      "history" => history_examples,
      "bihistory" => bihistory_examples
    }
    checks = build_checks(examples)
    {
      "kind" => "temporal_cache_key_proof",
      "format_version" => "0.1.0",
      "track" => "temporal-cache-key-proof-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "verdict" => checks.values.all? ? "temporal_key_required" : "blocked",
      "timestamp" => Time.now.utc.iso8601,
      "cache_key_version" => CACHE_KEY_VERSION,
      "semantics" => semantics,
      "examples" => examples,
      "checks" => checks,
      "recommendation" => runtime_cache_recommendation
    }
  end

  def semantics
    {
      "core" => {
        "fragment" => "CORE",
        "formula" => "hash(contract_ref, inputs)",
        "meaning" => "Pure CORE evaluation is deterministic over compiled contract identity and explicit non-temporal inputs."
      },
      "temporal" => {
        "fragment" => "TEMPORAL",
        "formula" => "hash(contract_ref, inputs, temporal_coordinates)",
        "history_formula" => "hash(contract_ref, inputs, as_of)",
        "bihistory_formula" => "hash(contract_ref, inputs, vt, tt)",
        "meaning" => "Temporal evaluation is deterministic only under explicit temporal coordinates."
      }
    }
  end

  def core_examples
    contract_ref = "contract/Add/sha256:stage1-add"
    first = { "a" => 20, "b" => 22 }
    same = { "b" => 22, "a" => 20 }
    changed = { "a" => 20, "b" => 23 }
    {
      "contract_ref" => contract_ref,
      "inputs" => {
        "first" => first,
        "same_reordered" => same,
        "changed" => changed
      },
      "keys" => {
        "first" => core_key(contract_ref: contract_ref, inputs: first),
        "same_reordered" => core_key(contract_ref: contract_ref, inputs: same),
        "changed" => core_key(contract_ref: contract_ref, inputs: changed)
      },
      "outputs" => {
        "first" => { "sum" => 42 },
        "changed" => { "sum" => 43 }
      }
    }
  end

  def history_examples
    contract_ref = "contract/TechnicianJobCountAt/sha256:history-point"
    inputs = { "technician_id" => "tech-synthetic-1" }
    early = {
      "as_of" => "2026-05-03T10:00:00Z",
      "output" => { "current_count" => { "kind" => "some", "value" => 7 } }
    }
    late = {
      "as_of" => "2026-05-06T10:00:00Z",
      "output" => { "current_count" => { "kind" => "some", "value" => 9 } }
    }
    core_key_value = core_key(contract_ref: contract_ref, inputs: inputs)
    early_temporal_key = temporal_key(contract_ref: contract_ref, inputs: inputs, as_of: early.fetch("as_of"))
    late_temporal_key = temporal_key(contract_ref: contract_ref, inputs: inputs, as_of: late.fetch("as_of"))
    stale_lookup = stale_lookup(
      stored_key: core_key_value,
      requested_key: core_key_value,
      stored_output: early.fetch("output"),
      expected_output: late.fetch("output")
    )
    {
      "contract_ref" => contract_ref,
      "capability" => "history_read",
      "inputs" => inputs,
      "evaluations" => {
        "early" => early.merge(
          "core_key" => core_key_value,
          "temporal_key" => early_temporal_key
        ),
        "late" => late.merge(
          "core_key" => core_key_value,
          "temporal_key" => late_temporal_key
        )
      },
      "stale_collision_if_core_key_used" => stale_lookup
    }
  end

  def bihistory_examples
    contract_ref = "contract/SparkCRMBiHistoryAvailabilityCorrection/sha256:bihistory"
    inputs = {
      "company_ref" => "company-fixture-acme",
      "technician_ref" => "tech-t-17",
      "slot_local" => "10:00"
    }
    vt = "2026-05-07T14:00:00Z"
    decision = {
      "vt" => vt,
      "tt" => "2026-05-07T13:30:00Z",
      "output" => { "requested_window" => { "result" => "blocked", "reason" => "busy" } }
    }
    corrected = {
      "vt" => vt,
      "tt" => "2026-05-07T15:20:00Z",
      "output" => { "requested_window" => { "result" => "available", "reason" => "available" } }
    }
    core_key_value = core_key(contract_ref: contract_ref, inputs: inputs)
    decision_key = bihistory_key(contract_ref: contract_ref, inputs: inputs, vt: decision.fetch("vt"), tt: decision.fetch("tt"))
    corrected_key = bihistory_key(contract_ref: contract_ref, inputs: inputs, vt: corrected.fetch("vt"), tt: corrected.fetch("tt"))
    stale_lookup = stale_lookup(
      stored_key: core_key_value,
      requested_key: core_key_value,
      stored_output: decision.fetch("output"),
      expected_output: corrected.fetch("output")
    )
    {
      "contract_ref" => contract_ref,
      "capability" => "bihistory_read",
      "inputs" => inputs,
      "evaluations" => {
        "decision_time" => decision.merge(
          "core_key" => core_key_value,
          "bihistory_key" => decision_key
        ),
        "corrected_time" => corrected.merge(
          "core_key" => core_key_value,
          "bihistory_key" => corrected_key
        )
      },
      "stale_collision_if_core_key_used" => stale_lookup
    }
  end

  def build_checks(examples)
    core = examples.fetch("core")
    history = examples.fetch("history")
    bihistory = examples.fetch("bihistory")
    {
      "core.same_inputs_same_key" => core.dig("keys", "first") == core.dig("keys", "same_reordered"),
      "core.different_inputs_different_key" => core.dig("keys", "first") != core.dig("keys", "changed"),
      "history.same_inputs_different_as_of_distinct_temporal_keys" =>
        history.dig("evaluations", "early", "temporal_key") != history.dig("evaluations", "late", "temporal_key"),
      "history.core_key_collides_across_as_of" =>
        history.dig("evaluations", "early", "core_key") == history.dig("evaluations", "late", "core_key"),
      "history.core_key_collision_would_be_stale" =>
        history.dig("stale_collision_if_core_key_used", "status") == "stale_collision",
      "bihistory.same_inputs_same_vt_different_tt_distinct_keys" =>
        bihistory.dig("evaluations", "decision_time", "bihistory_key") !=
          bihistory.dig("evaluations", "corrected_time", "bihistory_key"),
      "bihistory.core_key_collides_across_tt" =>
        bihistory.dig("evaluations", "decision_time", "core_key") ==
          bihistory.dig("evaluations", "corrected_time", "core_key"),
      "bihistory.core_key_collision_would_be_stale" =>
        bihistory.dig("stale_collision_if_core_key_used", "status") == "stale_collision"
    }
  end

  def core_key(contract_ref:, inputs:)
    key_for(
      "kind" => "runtime_cache_key",
      "version" => CACHE_KEY_VERSION,
      "fragment" => "CORE",
      "contract_ref" => contract_ref,
      "inputs" => inputs
    )
  end

  def temporal_key(contract_ref:, inputs:, as_of:)
    key_for(
      "kind" => "runtime_cache_key",
      "version" => CACHE_KEY_VERSION,
      "fragment" => "TEMPORAL",
      "axis" => "valid_time",
      "contract_ref" => contract_ref,
      "inputs" => inputs,
      "temporal_coordinates" => {
        "as_of" => as_of
      }
    )
  end

  def bihistory_key(contract_ref:, inputs:, vt:, tt:)
    key_for(
      "kind" => "runtime_cache_key",
      "version" => CACHE_KEY_VERSION,
      "fragment" => "TEMPORAL",
      "axis" => "bitemporal",
      "contract_ref" => contract_ref,
      "inputs" => inputs,
      "temporal_coordinates" => {
        "valid_time" => vt,
        "transaction_time" => tt
      }
    )
  end

  def key_for(material)
    {
      "key" => "cache/#{Canonical.short_hash(material)}",
      "hash" => Canonical.hash(material),
      "material" => Canonical.normalize(material)
    }
  end

  def stale_lookup(stored_key:, requested_key:, stored_output:, expected_output:)
    hit = stored_key.fetch("hash") == requested_key.fetch("hash")
    stale = hit && Canonical.normalize(stored_output) != Canonical.normalize(expected_output)
    {
      "status" => stale ? "stale_collision" : "ok",
      "cache_hit" => hit,
      "returned_output" => stored_output,
      "expected_output" => expected_output,
      "summary" => stale ? "CORE key reuses an earlier temporal output for a different temporal coordinate." : "No stale collision."
    }
  end

  def runtime_cache_recommendation
    {
      "runtime_machine_contract" => [
        "Runtime cache keys must include fragment class.",
        "CORE cache keys may use contract_ref + canonical non-temporal inputs.",
        "TEMPORAL cache keys must include contract_ref + canonical non-temporal inputs + canonical temporal_coordinates.",
        "History reads must include as_of or equivalent valid-time coordinate.",
        "BiHistory reads must include both valid_time and transaction_time.",
        "Cache hit observations should record key material hash, fragment, temporal axis, and whether the hit was fresh/provisional/stale/unknown."
      ],
      "non_goal" => "This proof does not implement RuntimeMachine memoization."
    }
  end

  def write_summary(summary)
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} temporal_cache_key_proof"
    puts "verdict: #{summary.fetch("verdict")}"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = TemporalCacheKeyProof.run
exit(success ? 0 : 1)
