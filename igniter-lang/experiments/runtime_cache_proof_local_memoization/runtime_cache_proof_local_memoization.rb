#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/assembler"

module RuntimeCacheProofLocalMemoization
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/runtime_cache_proof_local_memoization"
  ASSEMBLED_DIR = OUT_DIR / "assembled"
  SUMMARY_PATH = OUT_DIR / "runtime_cache_proof_local_memoization_summary.json"
  TEMPORAL_GOLDEN_DIR = ROOT / "igniter-lang/experiments/temporal_semanticir_access_node/golden"

  CACHE_KEY_SCHEMA = "runtime-cache-key-v1"
  CACHE_ENTRY_SCHEMA = "runtime-cache-entry-v1"
  CACHE_OBSERVATION_SCHEMA = "runtime-cache-observation-v1"
  PROOF_TIME = "2026-05-08T00:00:00Z"

  module Canonical
    module_function

    def normalize(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) do |key, out|
          out[key.to_s] = normalize(value.fetch(key))
        end
      when Array
        value.map { |item| normalize(item) }
      when Symbol
        value.to_s
      else
        value
      end
    end

    def json(value)
      JSON.generate(normalize(value))
    end

    def pretty(value)
      "#{JSON.pretty_generate(normalize(value))}\n"
    end

    def hash(value)
      "sha256:#{Digest::SHA256.hexdigest(json(value))}"
    end

    def short_hash(value)
      hash(value).delete_prefix("sha256:")[0, 16]
    end
  end

  class ProofCacheStore
    def initialize
      @entries = {}
      @observations = []
    end

    attr_reader :observations

    def put(entry)
      @entries[entry.fetch("cache_key").fetch("key")] = entry
    end

    def evaluate(metadata:, inputs:, requested_key: nil)
      expected_key = RuntimeCacheProofLocalMemoization.cache_key(metadata: metadata, inputs: inputs)
      requested_key ||= expected_key
      rejection = validate_requested_key(metadata: metadata, expected_key: expected_key, requested_key: requested_key)
      return emit_observation(rejection) if rejection

      entry = @entries[requested_key.fetch("key")]
      return emit_observation(cache_reject(metadata, requested_key, "unknown", "cache.unknown_rejected")) unless entry

      case entry.fetch("freshness")
      when "fresh"
        emit_observation(cache_hit(metadata, entry, requested_key, "cache.fresh_hit", "returned"))
      when "provisional"
        downgrade = downgrade_observation(metadata, entry, requested_key)
        result = cache_hit(metadata, entry, requested_key, "cache.provisional_hit", "returned_provisional")
        result["downgrade_observation"] = downgrade
        emit_observation(result)
      when "stale"
        emit_observation(cache_reject(metadata, requested_key, "stale", "cache.stale_rejected", entry: entry))
      when "unknown"
        emit_observation(cache_reject(metadata, requested_key, "unknown", "cache.unknown_rejected", entry: entry))
      else
        emit_observation(cache_reject(metadata, requested_key, "unknown", "cache.unknown_rejected", entry: entry))
      end
    end

    private

    def validate_requested_key(metadata:, expected_key:, requested_key:)
      material = requested_key.fetch("material")
      expected_material = expected_key.fetch("material")
      if material.fetch("fragment") != expected_material.fetch("fragment")
        return cache_reject(metadata, requested_key, "unknown", "cache.key_schema_mismatch",
                            detail: "requested #{material.fetch("fragment")} key for #{expected_material.fetch("fragment")} metadata")
      end
      return nil unless expected_material.fetch("fragment") == "TEMPORAL"

      return nil if material.fetch("temporal_coordinates") == expected_material.fetch("temporal_coordinates")

      cache_reject(metadata, requested_key, "unknown", "cache.temporal_coordinate_mismatch")
    end

    def cache_hit(metadata, entry, requested_key, reason, policy)
      {
        "kind" => "runtime_cache_hit_observation",
        "version" => CACHE_OBSERVATION_SCHEMA,
        "runtime_session_ref" => "runtime-session/cache-proof-local",
        "contract_ref" => metadata.fetch("contract_ref"),
        "program_id" => metadata.fetch("program_id"),
        "cache_key_hash" => requested_key.fetch("hash"),
        "cache_entry_ref" => entry.fetch("cache_key").fetch("key"),
        "fragment" => metadata.fetch("fragment"),
        "axis" => metadata.fetch("axis"),
        "freshness" => entry.fetch("freshness"),
        "temporal_coordinates" => requested_key.fetch("material").fetch("temporal_coordinates"),
        "value_hash" => entry.fetch("value_hash"),
        "result_policy" => policy,
        "reason" => reason,
        "evidence_links" => [
          {
            "rel" => "selected_cache_entry",
            "from" => observation_ref(requested_key, reason),
            "to" => entry.fetch("cache_key").fetch("key")
          }
        ]
      }
    end

    def cache_reject(metadata, requested_key, freshness, reason, entry: nil, detail: nil)
      observation = {
        "kind" => "runtime_cache_reject_observation",
        "version" => CACHE_OBSERVATION_SCHEMA,
        "runtime_session_ref" => "runtime-session/cache-proof-local",
        "contract_ref" => metadata.fetch("contract_ref"),
        "program_id" => metadata.fetch("program_id"),
        "cache_key_hash" => requested_key.fetch("hash"),
        "cache_entry_ref" => entry&.fetch("cache_key")&.fetch("key"),
        "fragment" => metadata.fetch("fragment"),
        "axis" => metadata.fetch("axis"),
        "freshness" => freshness,
        "temporal_coordinates" => requested_key.fetch("material").fetch("temporal_coordinates"),
        "value_hash" => entry&.fetch("value_hash"),
        "result_policy" => "rejected",
        "reason" => reason,
        "evidence_links" => []
      }
      observation["detail"] = detail if detail
      observation
    end

    def downgrade_observation(metadata, entry, requested_key)
      {
        "kind" => "runtime_cache_downgrade_observation",
        "version" => CACHE_OBSERVATION_SCHEMA,
        "runtime_session_ref" => "runtime-session/cache-proof-local",
        "contract_ref" => metadata.fetch("contract_ref"),
        "cache_entry_ref" => entry.fetch("cache_key").fetch("key"),
        "cache_key_hash" => requested_key.fetch("hash"),
        "reason" => "cache.provisional_hit",
        "trust" => "provisional",
        "message" => "Cached value returned with downgraded trust because freshness is provisional."
      }
    end

    def observation_ref(requested_key, reason)
      "obs/cache/#{reason}/#{requested_key.fetch("hash").delete_prefix("sha256:")[0, 16]}"
    end

    def emit_observation(observation)
      @observations << observation
      observation
    end
  end

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    metadata = metadata_fixture
    examples = run_examples(metadata)
    checks = build_checks(examples)
    summary = {
      "kind" => "runtime_cache_proof_local_memoization",
      "format_version" => "0.1.0",
      "track" => "runtime-cache-proof-local-memoization-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "scope" => {
        "cache_store" => "proof-local MemoryCacheStore",
        "production_runtime_cache" => false,
        "durable_cache_adapter" => false,
        "ledger_binding" => false
      },
      "metadata_required_from_assembler_manifest" => metadata_requirements,
      "metadata_fixture" => metadata,
      "examples" => examples,
      "checks" => checks
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def metadata_fixture
    assemble_temporal_artifacts
    {
      "core_add" => {
        "program_id" => "semanticir/e9664d5446df4e46",
        "contract_id" => "Add",
        "contract_ref" => "contract/Add/sha256:7379226c21b2cdcd69464bb7",
        "fragment" => "CORE",
        "axis" => nil,
        "coordinate_names" => [],
        "required_caps" => []
      },
      "history_valid" => temporal_metadata("history_valid", "history_axes_test.json"),
      "bihistory_valid" => temporal_metadata("bihistory_valid", "bi_history_axes_test.json")
    }
  end

  def assemble_temporal_artifacts
    assembler = IgniterLang::Assembler.new(golden_dir: TEMPORAL_GOLDEN_DIR, out_dir: ASSEMBLED_DIR)
    assembler.assemble_case("history_valid")
    assembler.assemble_case("bihistory_valid")
  end

  def temporal_metadata(case_id, contract_file)
    igapp_dir = ASSEMBLED_DIR / "#{case_id}.igapp"
    manifest = read_json(igapp_dir / "manifest.json")
    requirements = read_json(igapp_dir / "requirements.json")
    contract = read_json(igapp_dir / "contracts/#{contract_file}")
    access_node = contract.fetch("temporal_nodes").find { |node| node.fetch("kind") == "temporal_access_node" }
    coordinate_refs = access_node.fetch("coordinate_refs")
    {
      "program_id" => manifest.fetch("program_id"),
      "contract_id" => contract.fetch("contract_id"),
      "contract_ref" => contract.fetch("source_contract_ref"),
      "fragment" => "TEMPORAL",
      "axis" => access_node.fetch("axis"),
      "coordinate_refs" => coordinate_refs,
      "coordinate_names" => coordinate_refs.values,
      "required_caps" => requirements.dig("capabilities", "required_caps"),
      "metadata_sources" => {
        "manifest" => (igapp_dir / "manifest.json").relative_path_from(ROOT).to_s,
        "contract" => (igapp_dir / "contracts/#{contract_file}").relative_path_from(ROOT).to_s,
        "requirements" => (igapp_dir / "requirements.json").relative_path_from(ROOT).to_s
      }
    }
  end

  def run_examples(metadata)
    store = ProofCacheStore.new
    core = metadata.fetch("core_add")
    history = metadata.fetch("history_valid")
    bihistory = metadata.fetch("bihistory_valid")

    core_inputs = { "a" => 19, "b" => 23 }
    core_entry = cache_entry(metadata: core, inputs: core_inputs, value: { "sum" => 42 }, freshness: "fresh")
    store.put(core_entry)
    core_hit = store.evaluate(metadata: core, inputs: core_inputs)

    history_inputs = { "sku" => "sku-001", "as_of" => "2026-05-06T10:00:00Z" }
    history_fresh = cache_entry(
      metadata: history,
      inputs: history_inputs,
      value: { "price_at" => { "kind" => "some", "value" => "USD 9.00" } },
      freshness: "fresh"
    )
    store.put(history_fresh)
    history_hit = store.evaluate(metadata: history, inputs: history_inputs)
    core_shaped_temporal_key = cache_key(metadata: history, inputs: history_inputs, fragment_override: "CORE")
    core_shape_reject = store.evaluate(metadata: history, inputs: history_inputs, requested_key: core_shaped_temporal_key)

    stale_inputs = history_inputs.merge("as_of" => "2026-05-07T10:00:00Z")
    stale_entry = cache_entry(
      metadata: history,
      inputs: stale_inputs,
      value: { "price_at" => { "kind" => "some", "value" => "USD 7.00" } },
      freshness: "stale"
    )
    store.put(stale_entry)
    stale_reject = store.evaluate(metadata: history, inputs: stale_inputs)

    unknown_inputs = history_inputs.merge("as_of" => "2026-05-08T10:00:00Z")
    unknown_entry = cache_entry(
      metadata: history,
      inputs: unknown_inputs,
      value: { "price_at" => { "kind" => "some", "value" => "USD 8.00" } },
      freshness: "unknown"
    )
    store.put(unknown_entry)
    unknown_reject = store.evaluate(metadata: history, inputs: unknown_inputs)

    provisional_inputs = history_inputs.merge("as_of" => "2026-05-09T10:00:00Z")
    provisional_entry = cache_entry(
      metadata: history,
      inputs: provisional_inputs,
      value: { "price_at" => { "kind" => "some", "value" => "USD 10.00" } },
      freshness: "provisional"
    )
    store.put(provisional_entry)
    provisional_hit = store.evaluate(metadata: history, inputs: provisional_inputs)

    bihistory_inputs = {
      "technician_id" => "tech-001",
      "valid_time" => "2026-05-07T14:00:00Z",
      "transaction_time" => "2026-05-07T15:20:00Z"
    }
    bihistory_entry = cache_entry(
      metadata: bihistory,
      inputs: bihistory_inputs,
      value: { "avail_at" => { "kind" => "some", "value" => "available" } },
      freshness: "fresh"
    )
    store.put(bihistory_entry)
    bihistory_hit = store.evaluate(metadata: bihistory, inputs: bihistory_inputs)

    {
      "core_fresh_hit" => core_hit,
      "history_fresh_hit" => history_hit,
      "history_core_shaped_key_rejected" => core_shape_reject,
      "history_stale_rejected" => stale_reject,
      "history_unknown_rejected" => unknown_reject,
      "history_provisional_returned_with_downgrade" => provisional_hit,
      "bihistory_fresh_hit" => bihistory_hit,
      "cache_observations" => store.observations
    }
  end

  def cache_entry(metadata:, inputs:, value:, freshness:)
    key = cache_key(metadata: metadata, inputs: inputs)
    {
      "kind" => "runtime_cache_entry",
      "version" => CACHE_ENTRY_SCHEMA,
      "cache_key" => {
        "key" => key.fetch("key"),
        "hash" => key.fetch("hash"),
        "schema" => CACHE_KEY_SCHEMA
      },
      "fragment" => metadata.fetch("fragment"),
      "axis" => metadata.fetch("axis"),
      "contract_ref" => metadata.fetch("contract_ref"),
      "program_id" => metadata.fetch("program_id"),
      "value_hash" => Canonical.hash(value),
      "value_ref" => "runtime-value/#{Canonical.short_hash(value)}",
      "value" => value,
      "freshness" => freshness,
      "created_at" => PROOF_TIME,
      "validated_at" => freshness == "unknown" ? nil : PROOF_TIME,
      "expires_at" => nil,
      "dependency_refs" => [],
      "temporal_coordinates" => key.fetch("material").fetch("temporal_coordinates"),
      "evidence_links" => []
    }
  end

  def cache_key(metadata:, inputs:, fragment_override: nil)
    fragment = fragment_override || metadata.fetch("fragment")
    temporal_coordinates = fragment == "TEMPORAL" ? temporal_coordinates(metadata, inputs) : nil
    material = {
      "kind" => "runtime_cache_key",
      "version" => CACHE_KEY_SCHEMA,
      "fragment" => fragment,
      "axis" => fragment == "TEMPORAL" ? metadata.fetch("axis") : nil,
      "contract_ref" => metadata.fetch("contract_ref"),
      "input_hash" => Canonical.hash(non_temporal_inputs(metadata, inputs)),
      "temporal_coordinates" => temporal_coordinates
    }
    {
      "key" => "cache/#{Canonical.short_hash(material)}",
      "hash" => Canonical.hash(material),
      "schema" => CACHE_KEY_SCHEMA,
      "material" => Canonical.normalize(material)
    }
  end

  def non_temporal_inputs(metadata, inputs)
    coordinates = metadata.fetch("coordinate_names", [])
    inputs.reject { |key, _value| coordinates.include?(key.to_s) }
  end

  def temporal_coordinates(metadata, inputs)
    return nil if metadata.fetch("coordinate_names", []).empty?

    metadata.fetch("coordinate_refs").to_h do |axis_name, input_name|
      [axis_name, inputs.fetch(input_name)]
    end
  end

  def build_checks(examples)
    observations = examples.fetch("cache_observations")
    {
      "core.fresh_hit_returned" => returned?(examples.fetch("core_fresh_hit"), "cache.fresh_hit"),
      "temporal.history_fresh_hit_returned" => returned?(examples.fetch("history_fresh_hit"), "cache.fresh_hit"),
      "temporal.bihistory_key_uses_both_coordinates" =>
        examples.dig("bihistory_fresh_hit", "temporal_coordinates").keys.sort == %w[transaction_time valid_time],
      "negative.core_shaped_key_for_temporal_rejected" =>
        rejected?(examples.fetch("history_core_shaped_key_rejected"), "cache.key_schema_mismatch"),
      "negative.stale_rejected" => rejected?(examples.fetch("history_stale_rejected"), "cache.stale_rejected"),
      "negative.unknown_rejected" => rejected?(examples.fetch("history_unknown_rejected"), "cache.unknown_rejected"),
      "provisional.returned_with_downgrade_observation" =>
        examples.fetch("history_provisional_returned_with_downgrade").fetch("result_policy") == "returned_provisional" &&
          examples.fetch("history_provisional_returned_with_downgrade").fetch("downgrade_observation").fetch("trust") == "provisional",
      "observations.hit_and_reject_emitted" =>
        observations.any? { |obs| obs.fetch("kind") == "runtime_cache_hit_observation" } &&
          observations.any? { |obs| obs.fetch("kind") == "runtime_cache_reject_observation" },
      "observations.no_raw_input_payloads" => !JSON.generate(observations).include?("\"inputs\"")
    }
  end

  def returned?(observation, reason)
    observation.fetch("kind") == "runtime_cache_hit_observation" &&
      observation.fetch("reason") == reason &&
      %w[returned returned_provisional].include?(observation.fetch("result_policy"))
  end

  def rejected?(observation, reason)
    observation.fetch("kind") == "runtime_cache_reject_observation" &&
      observation.fetch("reason") == reason &&
      observation.fetch("result_policy") == "rejected"
  end

  def metadata_requirements
    {
      "current_assembler_inputs_used_by_proof" => [
        "manifest.program_id",
        "manifest.fragment_class",
        "contract.source_contract_ref",
        "contract.fragment_class",
        "contract.temporal_nodes[].kind",
        "contract.temporal_nodes[].axis",
        "contract.temporal_nodes[].coordinate_refs",
        "contract.temporal_nodes[].required_caps",
        "requirements.temporal.axes",
        "requirements.temporal.coordinate_refs",
        "requirements.capabilities.required_caps"
      ],
      "manifest_or_spec_fields_needed_before_production_runtime_cache" => [
        "manifest.contract_index[].fragment_class",
        "manifest.contract_index[].contract_path",
        "manifest.contract_index[].temporal.axes",
        "manifest.contract_index[].temporal.required_capabilities",
        "manifest.contract_index[].temporal.cache_key_schema_hint.schema",
        "manifest.contract_index[].temporal.cache_key_schema_hint.fragment",
        "manifest.contract_index[].temporal.cache_key_schema_hint.coordinate_names"
      ],
      "cache_policy_required_before_runtime_enablement" => {
        "cache_policy" => "memoized",
        "key_schema" => CACHE_KEY_SCHEMA,
        "entry_schema" => CACHE_ENTRY_SCHEMA,
        "observation_schema" => CACHE_OBSERVATION_SCHEMA,
        "default_unknown_policy" => "reject",
        "default_stale_policy" => "reject",
        "provisional_policy" => "return_with_downgrade"
      }
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    path.dirname.mkpath
    File.write(path, Canonical.pretty(value))
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} runtime_cache_proof_local_memoization"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = RuntimeCacheProofLocalMemoization.run
exit(success ? 0 : 1)
