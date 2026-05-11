#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerProfileValidatorImplementationPlan
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compiler_profile_validator_implementation_plan/out"
  PLAN_PATH = OUT_DIR / "compiler_profile_validator_implementation_plan.json"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_validator_implementation_plan_summary.json"

  SCHEMA_RUNNER = LANG_ROOT / "experiments/compiler_profile_descriptor_schema/compiler_profile_descriptor_schema.rb"
  TAXONOMY_RUNNER = LANG_ROOT / "experiments/compiler_profile_descriptor_error_taxonomy_sharpening/compiler_profile_descriptor_error_taxonomy_sharpening.rb"
  GRAMMAR_BOUNDARY_RUNNER = LANG_ROOT / "experiments/profile_source_syntax_grammar_boundary/profile_source_syntax_grammar_boundary.rb"

  SCHEMA = LANG_ROOT / "experiments/compiler_profile_descriptor_schema/out/compiler_profile_descriptor_schema.json"
  SCHEMA_SUMMARY = LANG_ROOT / "experiments/compiler_profile_descriptor_schema/out/compiler_profile_descriptor_schema_summary.json"
  TAXONOMY = LANG_ROOT / "experiments/compiler_profile_descriptor_error_taxonomy_sharpening/out/compiler_profile_descriptor_error_taxonomy.json"
  TAXONOMY_SUMMARY = LANG_ROOT / "experiments/compiler_profile_descriptor_error_taxonomy_sharpening/out/compiler_profile_descriptor_error_taxonomy_sharpening_summary.json"
  GRAMMAR_BOUNDARY = LANG_ROOT / "experiments/profile_source_syntax_grammar_boundary/out/profile_source_syntax_grammar_boundary_packet.json"
  GRAMMAR_BOUNDARY_SUMMARY = LANG_ROOT / "experiments/profile_source_syntax_grammar_boundary/out/profile_source_syntax_grammar_boundary_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-validator-implementation-plan-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    upstream_runs = run_upstream
    schema = read_json(SCHEMA)
    schema_summary = read_json(SCHEMA_SUMMARY)
    taxonomy = read_json(TAXONOMY)
    taxonomy_summary = read_json(TAXONOMY_SUMMARY)
    grammar_boundary = read_json(GRAMMAR_BOUNDARY)
    grammar_boundary_summary = read_json(GRAMMAR_BOUNDARY_SUMMARY)
    plan = build_plan(schema, taxonomy, grammar_boundary)
    checks = build_checks(plan, upstream_runs, schema_summary, taxonomy_summary, grammar_boundary_summary)
    summary = {
      "kind" => "compiler_profile_validator_implementation_plan_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "plan_path" => PLAN_PATH.relative_path_from(ROOT).to_s,
      "checks" => checks,
      "non_goals" => [
        "No validator implementation.",
        "No lib/ file creation.",
        "No parser syntax.",
        "No compiler dispatch change.",
        "No .igapp/.ilk format change.",
        "No runtime execution authority."
      ]
    }

    write_json(PLAN_PATH, plan)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_upstream
    [SCHEMA_RUNNER, TAXONOMY_RUNNER, GRAMMAR_BOUNDARY_RUNNER].to_h do |runner|
      stdout, stderr, status = Open3.capture3(RbConfig.ruby, runner.to_s, chdir: ROOT.to_s)
      [
        runner.basename(".rb").to_s,
        {
          "command" => "ruby #{runner.relative_path_from(ROOT)}",
          "exit_status" => status.exitstatus,
          "stdout_first_line" => stdout.lines.first.to_s.strip,
          "stderr" => stderr.strip
        }
      ]
    end
  end

  def build_plan(schema, taxonomy, grammar_boundary)
    {
      "kind" => "compiler_profile_validator_implementation_plan",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => "implementation_plan_ready_no_code",
      "inputs" => {
        "schema_ref" => SCHEMA.relative_path_from(ROOT).to_s,
        "taxonomy_ref" => TAXONOMY.relative_path_from(ROOT).to_s,
        "grammar_boundary_ref" => GRAMMAR_BOUNDARY.relative_path_from(ROOT).to_s
      },
      "recommended_future_module" => {
        "path_candidate" => "igniter-lang/lib/igniter_lang/compiler_profile_validator.rb",
        "namespace_candidate" => "IgniterLang::CompilerProfileValidator",
        "owner_role" => "[Igniter-Lang Implementation Agent]",
        "status" => "plan_only_not_created"
      },
      "validator_pipeline" => [
        {
          "step" => "descriptor_shape",
          "input" => "raw descriptor hash",
          "output" => "shape_validated_descriptor_or_diagnostic",
          "codes" => taxonomy_codes(taxonomy, "descriptor_shape"),
          "implementation_notes" => [
            "Check required fields and descriptor kind before touching slots.",
            "Reject full language parser status while profile syntax remains unauthorized."
          ]
        },
        {
          "step" => "slot_assignment",
          "input" => "shape_validated_descriptor",
          "output" => "slot_map_or_diagnostic",
          "codes" => taxonomy_codes(taxonomy, "slot_assignment"),
          "implementation_notes" => [
            "Known slot, duplicate slot, and required slot diagnostics win before helper-only checks.",
            "Canonical order comes from CompilerProfileSpec.slot_order."
          ]
        },
        {
          "step" => "pack_semantics",
          "input" => "slot_map",
          "output" => "semantic_pack_map_or_diagnostic",
          "codes" => taxonomy_codes(taxonomy, "pack_semantics"),
          "implementation_notes" => [
            "Check dependencies before helper-only and rule-owner checks.",
            "helper_only_pack_rejected requires a known non-conflicting slot."
          ]
        },
        {
          "step" => "registry_ordering",
          "input" => "semantic_pack_map",
          "output" => "validated_registry_order_or_diagnostic",
          "codes" => taxonomy_codes(taxonomy, "registry_ordering"),
          "implementation_notes" => [
            "Run missing-reference and cycle checks after pack ownership is valid.",
            "Keep strict registry duplicate diagnostics distinct from ordered-rule duplicates."
          ]
        },
        {
          "step" => "canonicalize_and_fingerprint",
          "input" => "fully validated descriptor",
          "output" => "canonical descriptor with digest",
          "codes" => [],
          "implementation_notes" => [
            "Use schema canonicalization rules.",
            "Do not include runtime authority or evaluation readiness."
          ]
        }
      ],
      "diagnostic_contract" => {
        "machine_code_required" => true,
        "human_message_required" => true,
        "details_required" => true,
        "first_failure_wins" => taxonomy.dig("implementation_guidance", "first_failure_wins"),
        "shape" => {
          "status" => "invalid",
          "code" => "schema.duplicate_slot",
          "message" => "human-readable text",
          "details" => { "slot" => "temporal" }
        }
      },
      "public_api_candidate" => {
        "validate" => {
          "signature" => "validate(descriptor_hash) -> ValidationResult",
          "pure" => true,
          "mutates_input" => false
        },
        "canonicalize" => {
          "signature" => "canonicalize(valid_descriptor_hash) -> canonical_descriptor_hash",
          "requires_valid_descriptor" => true
        },
        "fingerprint" => {
          "signature" => "fingerprint(canonical_descriptor_hash) -> compiler_profile_descriptor/sha256:<digest>",
          "requires_canonical_descriptor" => true
        }
      },
      "implementation_slice_order" => [
        "Add proof-local validator class in experiments mirroring this plan.",
        "Move validator to lib only after Implementation Agent accepts scope.",
        "Wire descriptor schema proof to use validator while preserving outputs.",
        "Only later consider manifest/assembler integration after PROP approval."
      ],
      "blocked_surfaces" => [
        "profile source parser syntax",
        "profile syntax golden fixtures",
        "manifest compiler_profile_id implementation",
        "CompilerKernel dispatch rewrite",
        "runtime profile compatibility enforcement"
      ],
      "grammar_boundary_constraints" => {
        "syntax_accepted_by_this_plan" => false,
        "parser_implementation_authorized" => false,
        "future_syntax_must_lower_into" => grammar_boundary.dig("fixed_research_constraints", "lowering_target"),
        "surface_slot_order_authoritative" => grammar_boundary.dig(
          "fixed_research_constraints", "surface_slot_order_authoritative"
        )
      },
      "non_authorizations" => [
        "No validator code is implemented by this plan.",
        "No lib/ file is created by this plan.",
        "No parser syntax is authorized.",
        "No compiler dispatch is changed.",
        "No .igapp/.ilk format is changed.",
        "No runtime execution authority is introduced."
      ]
    }
  end

  def taxonomy_codes(taxonomy, phase)
    taxonomy.fetch("diagnostic_precedence").find { |entry| entry.fetch("phase") == phase }.fetch("codes")
  end

  def build_checks(plan, upstream_runs, schema_summary, taxonomy_summary, grammar_boundary_summary)
    pipeline_steps = plan.fetch("validator_pipeline").map { |step| step.fetch("step") }
    {
      "input.schema_passed" => upstream_runs.fetch("compiler_profile_descriptor_schema").fetch("exit_status").zero? &&
        schema_summary.fetch("status") == "PASS",
      "input.taxonomy_passed" => upstream_runs.fetch("compiler_profile_descriptor_error_taxonomy_sharpening").fetch("exit_status").zero? &&
        taxonomy_summary.fetch("status") == "PASS",
      "input.grammar_boundary_passed" => upstream_runs.fetch("profile_source_syntax_grammar_boundary").fetch("exit_status").zero? &&
        grammar_boundary_summary.fetch("status") == "PASS",
      "plan.no_code_status" => plan.fetch("status") == "implementation_plan_ready_no_code",
      "module.path_is_candidate_not_created" => plan.dig("recommended_future_module", "status") == "plan_only_not_created",
      "pipeline.order_matches_taxonomy" => pipeline_steps == %w[
        descriptor_shape
        slot_assignment
        pack_semantics
        registry_ordering
        canonicalize_and_fingerprint
      ],
      "diagnostics.machine_code_and_first_failure" => plan.dig("diagnostic_contract", "machine_code_required") == true &&
        plan.dig("diagnostic_contract", "first_failure_wins") == true,
      "api.pure_validate_no_mutation" => plan.dig("public_api_candidate", "validate", "pure") == true &&
        plan.dig("public_api_candidate", "validate", "mutates_input") == false,
      "blocked.manifest_and_parser_remain_blocked" => plan.fetch("blocked_surfaces").include?("profile source parser syntax") &&
        plan.fetch("blocked_surfaces").include?("manifest compiler_profile_id implementation"),
      "grammar_boundary.syntax_not_accepted" => plan.dig("grammar_boundary_constraints", "syntax_accepted_by_this_plan") == false &&
        plan.dig("grammar_boundary_constraints", "parser_implementation_authorized") == false,
      "scope.no_lib_or_runtime_authority" => plan.fetch("non_authorizations").include?("No lib/ file is created by this plan.") &&
        plan.fetch("non_authorizations").include?("No runtime execution authority is introduced.")
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_validator_implementation_plan"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "plan: #{summary.fetch("plan_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileValidatorImplementationPlan.run
exit(success ? 0 : 1)
