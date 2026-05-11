#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerProfileDescriptorErrorTaxonomySharpening
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compiler_profile_descriptor_error_taxonomy_sharpening/out"
  TAXONOMY_PATH = OUT_DIR / "compiler_profile_descriptor_error_taxonomy.json"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_descriptor_error_taxonomy_sharpening_summary.json"

  DESCRIPTOR_RUNNER = LANG_ROOT / "experiments/compiler_profile_descriptor_schema/compiler_profile_descriptor_schema.rb"
  SLOTS_RUNNER = LANG_ROOT / "experiments/compiler_profile_slots_model/compiler_profile_slots_model.rb"
  ORDERED_RULE_RUNNER = LANG_ROOT / "experiments/compiler_kernel_ordered_rule_precedence/compiler_kernel_ordered_rule_precedence.rb"

  DESCRIPTOR_SUMMARY = LANG_ROOT / "experiments/compiler_profile_descriptor_schema/out/compiler_profile_descriptor_schema_summary.json"
  SLOTS_SUMMARY = LANG_ROOT / "experiments/compiler_profile_slots_model/out/compiler_profile_slots_model_summary.json"
  ORDERED_RULE_SUMMARY = LANG_ROOT / "experiments/compiler_kernel_ordered_rule_precedence/out/compiler_kernel_ordered_rule_precedence_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-descriptor-error-taxonomy-sharpening-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    upstream_runs = run_upstream
    descriptor_summary = read_json(DESCRIPTOR_SUMMARY)
    slots_summary = read_json(SLOTS_SUMMARY)
    ordered_rule_summary = read_json(ORDERED_RULE_SUMMARY)
    taxonomy = build_taxonomy(descriptor_summary, slots_summary, ordered_rule_summary)
    checks = build_checks(taxonomy, upstream_runs, descriptor_summary, slots_summary, ordered_rule_summary)
    summary = {
      "kind" => "compiler_profile_descriptor_error_taxonomy_sharpening_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "taxonomy_path" => TAXONOMY_PATH.relative_path_from(ROOT).to_s,
      "checks" => checks,
      "non_goals" => [
        "No production validator implementation.",
        "No descriptor schema mutation.",
        "No compiler dispatch change.",
        "No .igapp/.ilk change.",
        "No runtime execution authority."
      ]
    }

    write_json(TAXONOMY_PATH, taxonomy)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_upstream
    [DESCRIPTOR_RUNNER, SLOTS_RUNNER, ORDERED_RULE_RUNNER].to_h do |runner|
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

  def build_taxonomy(descriptor_summary, slots_summary, ordered_rule_summary)
    {
      "kind" => "compiler_profile_descriptor_error_taxonomy",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => "sharpened_candidate",
      "diagnostic_precedence" => [
        {
          "phase" => "descriptor_shape",
          "wins_before" => ["slot_assignment", "pack_semantics", "registry_ordering"],
          "codes" => %w[
            schema.missing_field
            schema.wrong_kind
            schema.full_language_source_out_of_scope
          ]
        },
        {
          "phase" => "slot_assignment",
          "wins_before" => ["pack_semantics", "registry_ordering"],
          "codes" => %w[
            schema.unknown_slot
            schema.duplicate_slot
            schema.missing_required_slot
          ],
          "rule" => "A pack cannot be judged semantically until its slot is known, unique, and required slots are present."
        },
        {
          "phase" => "pack_semantics",
          "wins_before" => ["registry_ordering"],
          "codes" => %w[
            schema.missing_dependency_slot
            schema.helper_only_pack_rejected
            schema.rule_owner_mismatch
          ],
          "rule" => "Dependencies are checked before helper-only and ownership checks; helper-only is emitted only for a known non-conflicting slot."
        },
        {
          "phase" => "registry_ordering",
          "wins_before" => [],
          "codes" => %w[
            registry.duplicate_ordered_rule
            registry.duplicate_strict_key
            registry.missing_rule_reference
            registry.rule_cycle
          ],
          "rule" => "Rule graph errors apply after descriptor identity and pack ownership are valid."
        }
      ],
      "scenario_matrix" => [
        {
          "scenario" => "helper pack asks for an unknown slot",
          "expected_code" => "schema.unknown_slot",
          "reason" => "unknown slot is resolved before helper-only ownership"
        },
        {
          "scenario" => "helper pack collides with an occupied slot",
          "expected_code" => "schema.duplicate_slot",
          "observed_code" => descriptor_summary.dig("negative_results", "helper_only_pack", "code"),
          "reason" => "duplicate slot is more local and wins before helper-only ownership"
        },
        {
          "scenario" => "helper pack is in a known available slot but owns no capability",
          "expected_code" => "schema.helper_only_pack_rejected",
          "reason" => "slot is known and non-conflicting, so semantic capability ownership is now the failing layer"
        },
        {
          "scenario" => "assumptions pack appears without contract_modifiers",
          "expected_code" => "schema.missing_dependency_slot",
          "observed_class" => slots_summary.dig("negative_results", "assumptions_without_modifiers", "class"),
          "reason" => "dependency failure wins before rule ownership or registry ordering"
        },
        {
          "scenario" => "temporal pack registers a core-prefixed rule",
          "expected_code" => "schema.rule_owner_mismatch",
          "observed_code" => descriptor_summary.dig("negative_results", "rule_owner_mismatch", "code"),
          "reason" => "slot/dependency/capability checks passed, but registry entry belongs to another semantic owner"
        },
        {
          "scenario" => "ordered rule references a missing rule",
          "expected_code" => "registry.missing_rule_reference",
          "observed_class" => ordered_rule_summary.dig("negative_results", "missing_before_reference", "class"),
          "reason" => "ordered registry graph validation catches missing references"
        },
        {
          "scenario" => "ordered rule graph cycles",
          "expected_code" => "registry.rule_cycle",
          "observed_class" => ordered_rule_summary.dig("negative_results", "cycle_rejected", "class"),
          "reason" => "cycle is a graph-ordering error after references exist"
        }
      ],
      "implementation_guidance" => {
        "first_failure_wins" => true,
        "do_not_collapse_slot_errors_into_helper_errors" => true,
        "do_not_run_registry_ordering_before_slot_validation" => true,
        "helper_only_specific_error_requires_known_non_conflicting_slot" => true,
        "future_validator_should_emit_machine_code_and_human_message" => true
      },
      "upstream_refs" => {
        "descriptor_schema_summary" => DESCRIPTOR_SUMMARY.relative_path_from(ROOT).to_s,
        "slots_summary" => SLOTS_SUMMARY.relative_path_from(ROOT).to_s,
        "ordered_rule_summary" => ORDERED_RULE_SUMMARY.relative_path_from(ROOT).to_s
      }
    }
  end

  def build_checks(taxonomy, upstream_runs, descriptor_summary, slots_summary, ordered_rule_summary)
    phases = taxonomy.fetch("diagnostic_precedence").map { |phase| phase.fetch("phase") }
    matrix = taxonomy.fetch("scenario_matrix")
    {
      "input.descriptor_schema_passed" => upstream_runs.fetch("compiler_profile_descriptor_schema").fetch("exit_status").zero? &&
        descriptor_summary.fetch("status") == "PASS",
      "input.slots_model_passed" => upstream_runs.fetch("compiler_profile_slots_model").fetch("exit_status").zero? &&
        slots_summary.fetch("status") == "PASS",
      "input.ordered_rule_precedence_passed" => upstream_runs.fetch("compiler_kernel_ordered_rule_precedence").fetch("exit_status").zero? &&
        ordered_rule_summary.fetch("status") == "PASS",
      "precedence.shape_before_slots_before_semantics_before_registry" => phases == %w[
        descriptor_shape slot_assignment pack_semantics registry_ordering
      ],
      "precedence.duplicate_slot_wins_over_helper_collision" => matrix.any? do |row|
        row.fetch("scenario") == "helper pack collides with an occupied slot" &&
          row.fetch("expected_code") == "schema.duplicate_slot" &&
          row.fetch("observed_code") == "schema.duplicate_slot"
      end,
      "precedence.helper_only_specific_case_documented" => matrix.any? do |row|
        row.fetch("scenario") == "helper pack is in a known available slot but owns no capability" &&
          row.fetch("expected_code") == "schema.helper_only_pack_rejected"
      end,
      "precedence.dependency_before_registry" => matrix.any? do |row|
        row.fetch("scenario") == "assumptions pack appears without contract_modifiers" &&
          row.fetch("observed_class") == "MissingSlotDependencyError"
      end,
      "precedence.rule_owner_mismatch_after_slot_checks" => matrix.any? do |row|
        row.fetch("scenario") == "temporal pack registers a core-prefixed rule" &&
          row.fetch("observed_code") == "schema.rule_owner_mismatch"
      end,
      "registry.missing_reference_and_cycle_documented" => matrix.any? do |row|
        row.fetch("expected_code") == "registry.missing_rule_reference" &&
          row.fetch("observed_class") == "MissingRuleReferenceError"
      end && matrix.any? do |row|
        row.fetch("expected_code") == "registry.rule_cycle" &&
          row.fetch("observed_class") == "RuleCycleError"
      end,
      "guidance.first_failure_wins" => taxonomy.dig("implementation_guidance", "first_failure_wins") == true,
      "scope.no_runtime_authority" => true
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_descriptor_error_taxonomy_sharpening"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "taxonomy: #{summary.fetch("taxonomy_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileDescriptorErrorTaxonomySharpening.run
exit(success ? 0 : 1)
