#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang"

module ExecutorBoundaryCacheKeyContractProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/executor_boundary_cache_key_contract/out"
  SUMMARY_PATH = OUT_DIR / "executor_boundary_cache_key_contract_summary.json"

  ADD_SOURCE = LANG_ROOT / "experiments/source_to_semanticir_fixture/add.ig"
  HISTORY_SOURCE = LANG_ROOT / "experiments/history_type_proof/history_integer_point_access.ig"
  BIHISTORY_SOURCE = LANG_ROOT / "experiments/typed_emission_main_path_parity/sparkcrm_bihistory_source.ig"

  CACHE_KEY_SCHEMA = "runtime-cache-key-v1"

  module Canonical
    module_function

    def normalize(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) { |key, out| out[key.to_s] = normalize(value.fetch(key)) }
      when Array
        value.map { |item| normalize(item) }
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

  class BoundaryCacheKeyBuilder
    def expected_key(metadata:, inputs:)
      case metadata.fetch("fragment")
      when "core"
        cache_key(fragment: "CORE", contract_ref: metadata.fetch("contract_ref"), inputs: inputs)
      when "temporal"
        cache_key(
          fragment: "TEMPORAL",
          contract_ref: metadata.fetch("contract_ref"),
          inputs: non_temporal_inputs(metadata, inputs),
          temporal_coordinates: temporal_coordinates(metadata, inputs),
          axis: metadata.fetch("cache_key_schema_hint").fetch("axis")
        )
      else
        fault(metadata, nil, "L-T5", "unsupported fragment for executor cache-key boundary")
      end
    end

    def core_shaped_key(metadata:, inputs:)
      cache_key(
        fragment: "CORE",
        contract_ref: metadata.fetch("contract_ref"),
        inputs: non_temporal_inputs(metadata, inputs)
      )
    end

    def validate_requested_key(metadata:, requested_key:, inputs:)
      expected = expected_key(metadata: metadata, inputs: inputs)
      return expected if expected.fetch("kind") == "cache_key_fault"

      material = requested_key.fetch("material")
      expected_material = expected.fetch("material")
      if material.fetch("fragment") != expected_material.fetch("fragment")
        return fault(
          metadata,
          requested_key,
          "L-T5",
          "executor boundary rejected #{material.fetch("fragment")} cache key for #{expected_material.fetch("fragment")} contract"
        )
      end

      if expected_material.fetch("fragment") == "TEMPORAL"
        missing = missing_temporal_coordinates(expected_material, material)
        unless missing.empty?
          return fault(
            metadata,
            requested_key,
            "L-T5",
            "executor boundary rejected TEMPORAL cache key missing coordinates: #{missing.join(", ")}"
          )
        end
      end

      {
        "kind" => "cache_key_validation",
        "status" => "accepted",
        "expected_key_hash" => expected.fetch("hash"),
        "requested_key_hash" => requested_key.fetch("hash"),
        "cache_key" => requested_key
      }
    end

    private

    def non_temporal_inputs(metadata, inputs)
      coordinate_names = metadata.fetch("coordinate_names", [])
      inputs.reject { |name, _value| coordinate_names.include?(name.to_s) }
    end

    def temporal_coordinates(metadata, inputs)
      metadata.fetch("coordinates", []).map do |coordinate|
        input_name = coordinate.fetch("name")
        {
          "axis" => coordinate.fetch("axis"),
          "name" => input_name,
          "value" => inputs.fetch(input_name) { inputs.fetch(input_name.to_sym) }
        }
      end
    end

    def missing_temporal_coordinates(expected_material, requested_material)
      expected = Array(expected_material.fetch("temporal_coordinates", [])).map { |coord| coord.fetch("axis") }.sort
      actual = Array(requested_material.fetch("temporal_coordinates", [])).map { |coord| coord.fetch("axis") }.sort
      expected - actual
    end

    def cache_key(fragment:, contract_ref:, inputs:, temporal_coordinates: nil, axis: nil)
      material = {
        "kind" => "runtime_cache_key",
        "schema" => CACHE_KEY_SCHEMA,
        "fragment" => fragment,
        "contract_ref" => contract_ref,
        "inputs" => inputs
      }
      material["axis"] = axis if axis
      material["temporal_coordinates"] = temporal_coordinates if temporal_coordinates
      normalized = Canonical.normalize(material)
      {
        "kind" => "runtime_cache_key",
        "key" => "cache/#{Canonical.short_hash(normalized)}",
        "hash" => Canonical.hash(normalized),
        "material" => normalized
      }
    end

    def fault(metadata, requested_key, gate, message)
      {
        "kind" => "cache_key_fault",
        "status" => "refused",
        "gate" => gate,
        "reason_code" => "executor.cache_key_schema_mismatch",
        "message" => message,
        "contract_id" => metadata.fetch("contract_id"),
        "contract_ref" => metadata.fetch("contract_ref"),
        "requested_key" => requested_key,
        "prevents" => "PROP-028 silent staleness bug: TEMPORAL result cached or reused under CORE key"
      }
    end
  end

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    artifacts = compile_artifacts
    metadata = artifacts.transform_values do |artifact|
      metadata_from_manifest(ROOT / artifact.fetch("igapp_path"))
    end
    examples = build_examples(metadata)
    checks = build_checks(examples)
    summary = {
      "kind" => "executor_boundary_cache_key_contract_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R9-C3-P",
      "track" => "executor-boundary-cache-key-contract-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "scope" => {
        "live_executor" => false,
        "live_tbackend" => false,
        "production_cache" => false,
        "ledger_binding" => false
      },
      "prop_028_link" => "TEMPORAL cache key = hash(contract, inputs, temporal coordinates); CORE-shaped key for TEMPORAL is a silent staleness bug.",
      "artifacts" => artifacts,
      "manifest_metadata" => metadata,
      "examples" => examples,
      "checks" => checks
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def compile_artifacts
    {
      "core_add" => compile_case(
        id: "core_add",
        source_path: ADD_SOURCE,
        sample_input: { "a" => 19, "b" => 23 }
      ),
      "history_single_axis" => compile_case(
        id: "history_single_axis",
        source_path: HISTORY_SOURCE,
        sample_input: { "technician_id" => "tech-1", "as_of" => "2026-05-03T10:00:00Z" }
      ),
      "bihistory_bitemporal" => compile_case(
        id: "bihistory_bitemporal",
        source_path: BIHISTORY_SOURCE,
        sample_input: {
          "technician_id" => "tech-17",
          "valid_time" => "2026-05-07T10:00:00Z",
          "transaction_time" => "2026-05-08T09:15:00Z"
        }
      )
    }
  end

  def compile_case(id:, source_path:, sample_input:)
    igapp_path = OUT_DIR / "#{id}.igapp"
    result = IgniterLang.compile(source_path: source_path, out_path: igapp_path, sample_input: sample_input)
    {
      "source_path" => source_path.relative_path_from(ROOT).to_s,
      "igapp_path" => igapp_path.relative_path_from(ROOT).to_s,
      "compile_status" => result.fetch("status"),
      "pass_result" => result.fetch("compilation_report").fetch("pass_result"),
      "diagnostics" => result.fetch("compilation_report").fetch("diagnostics", [])
    }
  end

  def metadata_from_manifest(igapp_path)
    manifest = read_json(igapp_path / "manifest.json")
    contract_id = manifest.fetch("contracts").first
    entry = manifest.fetch("contract_index").fetch(contract_id)
    temporal = entry.fetch("temporal", nil)
    cache_hint = temporal&.fetch("cache_key_schema_hint", nil)
    {
      "program_id" => manifest.fetch("program_id"),
      "contract_id" => contract_id,
      "contract_ref" => entry.fetch("contract_ref"),
      "fragment" => entry.fetch("fragment_class"),
      "manifest_fragment_class" => manifest.fetch("fragment_class"),
      "cache_key_schema_hint" => cache_hint || {
        "schema" => CACHE_KEY_SCHEMA,
        "fragment" => "CORE",
        "axis" => nil,
        "coordinate_names" => []
      },
      "coordinate_names" => cache_hint ? cache_hint.fetch("coordinate_names") : [],
      "coordinates" => temporal ? temporal.fetch("coordinates") : [],
      "metadata_sources" => {
        "preferred" => "manifest.contract_index",
        "manifest" => (igapp_path / "manifest.json").relative_path_from(ROOT).to_s
      }
    }
  end

  def build_examples(metadata)
    builder = BoundaryCacheKeyBuilder.new
    core_inputs = { "a" => 19, "b" => 23 }
    history_inputs_early = { "technician_id" => "tech-1", "as_of" => "2026-05-03T10:00:00Z" }
    history_inputs_late = history_inputs_early.merge("as_of" => "2026-05-06T10:00:00Z")
    bihistory_inputs_decision = {
      "technician_id" => "tech-17",
      "valid_time" => "2026-05-07T10:00:00Z",
      "transaction_time" => "2026-05-08T09:15:00Z"
    }
    bihistory_inputs_later_tt = bihistory_inputs_decision.merge("transaction_time" => "2026-05-08T12:30:00Z")

    core = metadata.fetch("core_add")
    history = metadata.fetch("history_single_axis")
    bihistory = metadata.fetch("bihistory_bitemporal")

    {
      "core_add" => core_example(builder, core, core_inputs),
      "history_single_axis" => temporal_example(builder, history, history_inputs_early, history_inputs_late),
      "bihistory_bitemporal" => temporal_example(builder, bihistory, bihistory_inputs_decision, bihistory_inputs_later_tt)
    }
  end

  def core_example(builder, metadata, inputs)
    key = builder.expected_key(metadata: metadata, inputs: inputs)
    validation = builder.validate_requested_key(metadata: metadata, requested_key: key, inputs: inputs)
    {
      "expected_shape" => "CORE = contract + inputs",
      "inputs" => inputs,
      "cache_key" => key,
      "validation" => validation
    }
  end

  def temporal_example(builder, metadata, first_inputs, second_inputs)
    temporal_key = builder.expected_key(metadata: metadata, inputs: first_inputs)
    second_temporal_key = builder.expected_key(metadata: metadata, inputs: second_inputs)
    core_shaped_key = builder.core_shaped_key(metadata: metadata, inputs: first_inputs)
    accepted = builder.validate_requested_key(metadata: metadata, requested_key: temporal_key, inputs: first_inputs)
    rejected = builder.validate_requested_key(metadata: metadata, requested_key: core_shaped_key, inputs: first_inputs)
    silent_staleness_collision = {
      "core_shaped_hash_reused_across_time" =>
        core_shaped_key.fetch("hash") == builder.core_shaped_key(metadata: metadata, inputs: second_inputs).fetch("hash"),
      "temporal_hash_changes_across_time" => temporal_key.fetch("hash") != second_temporal_key.fetch("hash"),
      "meaning" => "CORE-shaped key ignores temporal coordinates; TEMPORAL-shaped key separates evaluations by as_of/Tt."
    }
    {
      "expected_shape" => "TEMPORAL = contract + non-temporal inputs + temporal coordinates",
      "first_inputs" => first_inputs,
      "second_inputs" => second_inputs,
      "cache_key_schema_hint" => metadata.fetch("cache_key_schema_hint"),
      "temporal_key" => temporal_key,
      "second_temporal_key" => second_temporal_key,
      "core_shaped_key_attempt" => core_shaped_key,
      "accepted_temporal_key" => accepted,
      "rejected_core_shaped_key" => rejected,
      "silent_staleness_prevention" => silent_staleness_collision
    }
  end

  def build_checks(examples)
    core = examples.fetch("core_add")
    history = examples.fetch("history_single_axis")
    bihistory = examples.fetch("bihistory_bitemporal")
    {
      "core.key_shape_contract_plus_inputs" =>
        core.dig("cache_key", "material", "fragment") == "CORE" &&
          !core.dig("cache_key", "material").key?("temporal_coordinates"),
      "core.requested_core_key_accepted" => core.dig("validation", "status") == "accepted",
      "history.temporal_key_uses_manifest_hint" =>
        history.dig("temporal_key", "material", "fragment") == "TEMPORAL" &&
          history.dig("cache_key_schema_hint", "fragment") == "TEMPORAL",
      "history.temporal_key_includes_valid_time" =>
        temporal_axes(history.dig("temporal_key", "material")) == ["valid_time"],
      "history.core_shaped_key_refused_l_t5" =>
        history.dig("rejected_core_shaped_key", "status") == "refused" &&
          history.dig("rejected_core_shaped_key", "gate") == "L-T5",
      "history.silent_staleness_prevented" =>
        history.dig("silent_staleness_prevention", "core_shaped_hash_reused_across_time") == true &&
          history.dig("silent_staleness_prevention", "temporal_hash_changes_across_time") == true,
      "bihistory.temporal_key_uses_manifest_hint" =>
        bihistory.dig("temporal_key", "material", "fragment") == "TEMPORAL" &&
          bihistory.dig("cache_key_schema_hint", "axis") == "bitemporal",
      "bihistory.temporal_key_includes_vt_and_tt" =>
        temporal_axes(bihistory.dig("temporal_key", "material")) == %w[transaction_time valid_time],
      "bihistory.core_shaped_key_refused_l_t5" =>
        bihistory.dig("rejected_core_shaped_key", "status") == "refused" &&
          bihistory.dig("rejected_core_shaped_key", "gate") == "L-T5",
      "bihistory.silent_staleness_prevented" =>
        bihistory.dig("silent_staleness_prevention", "core_shaped_hash_reused_across_time") == true &&
          bihistory.dig("silent_staleness_prevention", "temporal_hash_changes_across_time") == true
    }
  end

  def temporal_axes(material)
    Array(material.fetch("temporal_coordinates", [])).map { |coord| coord.fetch("axis") }.sort
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} executor_boundary_cache_key_contract"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ExecutorBoundaryCacheKeyContractProof.run
exit(success ? 0 : 1)
