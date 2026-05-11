#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module ProgressionPackShadowBoundary
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/progression_pack_shadow_boundary/out"
  PACK_MODEL_PATH = OUT_DIR / "progression_pack_shadow_boundary_model.json"
  SUMMARY_PATH = OUT_DIR / "progression_pack_shadow_boundary_summary.json"

  PROGRESSION_RUNNER = LANG_ROOT / "experiments/external_progression_runtime_model/external_progression_runtime_model.rb"
  PROGRESSION_SUMMARY = LANG_ROOT / "experiments/external_progression_runtime_model/external_progression_runtime_model_summary.json"
  SHADOW_PROFILE = LANG_ROOT / "experiments/compiler_pack_shadow_profile_proof/out/compiler_pack_shadow_profile_proof_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "progression-pack-shadow-boundary-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    progression_run = run_progression
    progression_summary = read_json(PROGRESSION_SUMMARY)
    shadow_profile = read_json(SHADOW_PROFILE)
    model = build_model(progression_summary, shadow_profile)
    checks = build_checks(model, progression_run, progression_summary)
    summary = {
      "kind" => "progression_pack_shadow_boundary_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "model_path" => PACK_MODEL_PATH.relative_path_from(ROOT).to_s,
      "checks" => checks,
      "non_goals" => [
        "No parser syntax.",
        "No typechecker or SemanticIR implementation.",
        "No RuntimeMachine production integration.",
        "No durable scheduler.",
        "No .igapp/.ilk format change.",
        "No CompilerKernel dispatch change."
      ]
    }

    write_json(PACK_MODEL_PATH, model)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_progression
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, PROGRESSION_RUNNER.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{PROGRESSION_RUNNER.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def build_model(progression_summary, shadow_profile)
    pack = progression_pack_descriptor(progression_summary)
    extended_profile = extend_shadow_profile(shadow_profile.fetch("profile"), pack)
    {
      "kind" => "progression_pack_shadow_boundary_model",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "verdict" => {
        "fits_new_compiler_as" => "ProgressionPack",
        "capability_boundary" => "external_event_progression_and_bounded_materialization",
        "not_a_rename_of_loop" => true,
        "not_core_pack" => true,
        "not_temporal_pack" => true,
        "not_stream_pack" => true,
        "not_pipeline_pack" => true
      },
      "relationship_to_existing_packs" => {
        "CoreLanguagePack" => "required baseline for handler contracts and core expressions",
        "EscapeBoundaryPack" => "required because progression sources are external runtime boundaries",
        "StreamPack" => "sibling; stream handles data ingress/fold, progression handles event potential/materialization",
        "TemporalPack" => "sibling; temporal reads history, progression schedules/materializes future/external events",
        "PipelinePack" => "optional future integration for step orchestration, not ownership",
        "EvidenceObservationPack" => "optional future integration for receipt/audit observations"
      },
      "pack_descriptor" => pack,
      "extended_shadow_profile" => extended_profile,
      "compiler_surface_mapping" => compiler_surface_mapping,
      "runtime_contract_mapping" => runtime_contract_mapping(progression_summary),
      "open_design_questions" => [
        "Is ProgressionPack service-contract-only, or can ordinary contracts declare progressions?",
        "Does progression get a dedicated fragment class, or remain an escape/runtime capability with manifest metadata?",
        "Should progression step receipts flow through CompilationReceipt, RuntimeMachine receipts, or a separate ProgressionReceiptSink?",
        "Which source kinds are canonical first: clock.every, work_queue, or both?",
        "Should checkpoint/replay be manifest metadata, runtime policy, or both?"
      ],
      "non_authorizations" => [
        "This does not authorize progression syntax.",
        "This does not authorize SemanticIR progression nodes.",
        "This does not authorize production RuntimeMachine materialization.",
        "This does not authorize durable scheduler or Ledger integration.",
        "This does not change compiler dispatch.",
        "This does not change .igapp/.ilk format."
      ]
    }
  end

  def progression_pack_descriptor(progression_summary)
    {
      "name" => "ProgressionPack",
      "implementation_id" => "progression.proof_runtime_model_shadow.v0",
      "status" => "proposed_shadow_only",
      "requires_packs" => [
        "CoreLanguagePack",
        "EscapeBoundaryPack",
        "OOFRegistry",
        "FragmentRegistry"
      ],
      "provides_capabilities" => [
        "external_progression",
        "progression_source",
        "bounded_materialization",
        "progression_step_receipt",
        "progression_checkpoint_resume",
        "progression_backpressure",
        "progression_cancellation"
      ],
      "parser_rules" => [
        "progression_decl_deferred",
        "clock_every_source_deferred",
        "work_queue_source_deferred",
        "progression_handler_ref_deferred"
      ],
      "classifier_rules" => [
        "progression_source_classification_deferred",
        "progression_external_boundary_classification_deferred",
        "progression_handler_linking_deferred"
      ],
      "type_rules" => [
        "progression_event_payload_type_deferred",
        "progression_handler_signature_deferred",
        "progression_receipt_shape_deferred"
      ],
      "semanticir_handlers" => [
        "progression_source_node_deferred",
        "progression_materialization_policy_node_deferred",
        "progression_handler_ref_node_deferred"
      ],
      "assembler_hooks" => [
        "progression_sources_manifest_deferred",
        "progression_requirements_deferred",
        "progression_receipt_schema_deferred"
      ],
      "fragment_classes" => [
        "progression_candidate"
      ],
      "oof_codes" => [
        "OOF-PR1",
        "OOF-PR2",
        "OOF-PR3",
        "OOF-PR4"
      ],
      "runtime_evidence_ref" => PROGRESSION_SUMMARY.relative_path_from(ROOT).to_s,
      "runtime_capabilities_proven" => progression_summary.fetch("new_capabilities")
    }
  end

  def extend_shadow_profile(profile, pack)
    packs = profile.fetch("packs") + [pack]
    extended = {
      "kind" => "compiler_profile_shadow_with_progression_pack",
      "format_version" => FORMAT_VERSION,
      "dispatch_mode" => "shadow_no_dispatch",
      "base_profile_track" => profile.fetch("track"),
      "igapp_manifest_changes" => [],
      "compiler_profile_id_in_igapp" => "deferred_until_manifest_prop",
      "packs" => packs,
      "pack_count" => packs.length
    }
    extended.merge("profile_id" => profile_id(extended))
  end

  def compiler_surface_mapping
    {
      "parser" => "future progression declarations only; no parser work now",
      "classifier" => "classify progression sources as external progression capability, not eager loops",
      "typechecker" => "event payload, handler signature, receipt/checkpoint shape",
      "semanticir" => "candidate progression_source/materialization/handler-ref nodes; not authorized here",
      "assembler" => "candidate progression_sources and requirements sections; .igapp format change blocked",
      "diagnostics" => "OOF-PR* candidates for invalid source, handler mismatch, unbounded materialization, illegal authority claim"
    }
  end

  def runtime_contract_mapping(progression_summary)
    {
      "source_to_runtime_lifecycle" => "ProgressionSource -> EventMaterializer -> EventQueue -> StepExecutor -> ReceiptSink",
      "event_kind" => "progression_event",
      "receipt_kind" => "progression_step_receipt",
      "materialization_kind" => "progression_materialization",
      "checkpoint_kind" => "progression_checkpoint",
      "lazy_not_eager" => progression_summary.dig("checks", "clock_progression_lazy_not_eager"),
      "receipts_structured" => progression_summary.dig("checks", "step_receipts_are_structured"),
      "backpressure_structured" => progression_summary.dig("checks", "backpressure_is_structured"),
      "cancellation_structured" => progression_summary.dig("checks", "cancellation_blocks_future_materialization")
    }
  end

  def build_checks(model, progression_run, progression_summary)
    pack = model.fetch("pack_descriptor")
    relationship = model.fetch("relationship_to_existing_packs")
    {
      "input.external_progression_passed" => progression_run.fetch("exit_status").zero? && progression_summary.fetch("status") == "PASS",
      "verdict.progression_pack_not_loop_rename" => model.dig("verdict", "not_a_rename_of_loop") == true &&
        model.dig("verdict", "fits_new_compiler_as") == "ProgressionPack",
      "boundary.not_core_temporal_stream_or_pipeline" => %w[
        not_core_pack
        not_temporal_pack
        not_stream_pack
        not_pipeline_pack
      ].all? { |key| model.dig("verdict", key) == true },
      "pack.has_semantic_capability_ownership" => pack.fetch("provides_capabilities").include?("external_progression") &&
        pack.fetch("provides_capabilities").include?("bounded_materialization"),
      "pack.depends_on_core_escape_oof_fragment" => pack.fetch("requires_packs") == [
        "CoreLanguagePack",
        "EscapeBoundaryPack",
        "OOFRegistry",
        "FragmentRegistry"
      ],
      "pack.has_receipt_checkpoint_backpressure_cancellation" => %w[
        progression_step_receipt
        progression_checkpoint_resume
        progression_backpressure
        progression_cancellation
      ].all? { |capability| pack.fetch("provides_capabilities").include?(capability) },
      "relationship.stream_temporal_pipeline_are_siblings" => relationship.fetch("StreamPack").start_with?("sibling") &&
        relationship.fetch("TemporalPack").start_with?("sibling") &&
        relationship.fetch("PipelinePack").start_with?("optional future integration"),
      "runtime.lifecycle_maps_to_pack" => model.dig(
        "runtime_contract_mapping", "source_to_runtime_lifecycle"
      ) == "ProgressionSource -> EventMaterializer -> EventQueue -> StepExecutor -> ReceiptSink",
      "profile.shadow_no_dispatch_no_igapp_change" => model.dig("extended_shadow_profile", "dispatch_mode") == "shadow_no_dispatch" &&
        model.dig("extended_shadow_profile", "igapp_manifest_changes").empty?,
      "scope.no_syntax_semanticir_runtime_authority" => model.fetch("non_authorizations").include?("This does not authorize progression syntax.") &&
        model.fetch("non_authorizations").include?("This does not authorize SemanticIR progression nodes.") &&
        model.fetch("non_authorizations").include?("This does not authorize production RuntimeMachine materialization.")
    }
  end

  def profile_id(profile)
    stable = profile.reject { |key, _value| key == "profile_id" }
    "compiler_profile_progression_shadow/sha256:#{Digest::SHA256.hexdigest(JSON.generate(sort_value(stable)))[0, 24]}"
  end

  def sort_value(value)
    case value
    when Hash
      value.keys.sort.each_with_object({}) { |key, result| result[key] = sort_value(value.fetch(key)) }
    when Array
      value.map { |item| sort_value(item) }
    else
      value
    end
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} progression_pack_shadow_boundary"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "model: #{summary.fetch("model_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ProgressionPackShadowBoundary.run
exit(success ? 0 : 1)
