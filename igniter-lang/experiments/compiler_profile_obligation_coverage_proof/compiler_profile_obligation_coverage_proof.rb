# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "set"

ROOT = File.expand_path("../../..", __dir__)
OUT_DIR = File.join(__dir__, "out")
SUMMARY_PATH = File.join(OUT_DIR, "compiler_profile_obligation_coverage_summary.json")

PROFILE_SOURCE_PATH = File.join(
  ROOT,
  "igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json"
)

ARTIFACTS = [
  {
    id: "core_add_compute",
    path: "igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/out/core_add_compute.igapp/semantic_ir_program.json",
    note: "CORE Add SemanticIR"
  },
  {
    id: "contract_modifier_observed",
    path: "igniter-lang/experiments/contract_modifiers_proof/golden/observed_contract_basic.semantic_ir.json",
    note: "PROP-031 observed contract modifier SemanticIR"
  },
  {
    id: "history_single_axis",
    path: "igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/out/history_single_axis.igapp/semantic_ir_program.json",
    note: "PROP-028 History[T] temporal access SemanticIR"
  },
  {
    id: "stream_fold",
    path: "igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/out/stream_fold.igapp/semantic_ir_program.json",
    note: "Stage 2 stream/fold_stream SemanticIR"
  },
  {
    id: "olap_point",
    path: "igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/out/olap_point.igapp/semantic_ir_program.json",
    note: "Stage 2 OLAPPoint SemanticIR"
  },
  {
    id: "invariant_severity",
    path: "igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/out/invariant_severity.igapp/semantic_ir_program.json",
    note: "Stage 2 invariant severity SemanticIR"
  },
  {
    id: "assumption_basic",
    path: "igniter-lang/experiments/assumptions_proof/golden/assumption_basic.semantic_ir.json",
    note: "PROP-032 assumptions SemanticIR"
  },
  {
    id: "progression_descriptor_shape",
    path: "igniter-lang/experiments/prop037_progression_descriptor_shape_proof/prop037_progression_descriptor_shape_proof_summary.json",
    note: "PROP-037 progression descriptor proof summary; v0 maps to pipeline slot"
  }
].freeze

SURFACE_SLOTS = {
  "core" => %w[core oof_registry fragment_registry pipeline],
  "escape_boundary" => %w[escape_boundary fragment_registry oof_registry],
  "contract_modifiers" => %w[contract_modifiers oof_registry fragment_registry escape_boundary],
  "temporal" => %w[temporal fragment_registry escape_boundary oof_registry pipeline],
  "stream" => %w[stream fragment_registry escape_boundary oof_registry],
  "olap" => %w[olap fragment_registry oof_registry],
  "invariant" => %w[invariant oof_registry evidence_observation],
  "assumptions" => %w[assumptions fragment_registry oof_registry evidence_observation pipeline],
  "progression_descriptor" => %w[pipeline stream evidence_observation oof_registry]
}.freeze

KNOWN_NODE_KINDS = Set.new(%w[
  compute
  temporal_input_node
  temporal_access_node
  stream_input_node
  window_decl_node
  fold_stream_node
  olap_access_node
  invariant_node
  assumption_ref_node
]).freeze

def read_json(path)
  JSON.parse(File.read(path))
end

def rel_to_abs(path)
  File.join(ROOT, path)
end

def digest_file(path)
  Digest::SHA256.file(path).hexdigest
end

def deep_nodes(value)
  case value
  when Hash
    values = value.values.flat_map { |child| deep_nodes(child) }
    value.key?("kind") ? [value] + values : values
  when Array
    value.flat_map { |child| deep_nodes(child) }
  else
    []
  end
end

def detect_semantic_ir_surfaces(document)
  surfaces = Set.new
  unsupported = Set.new

  contracts = Array(document["contracts"])
  surfaces << "core" unless contracts.empty?
  surfaces << "olap" if Array(document["olap_points"]).any?
  surfaces << "invariant" if Array(document["invariants"]).any?
  surfaces << "assumptions" if Array(document["assumption_registry"]).any?

  contracts.each do |contract|
    modifier = contract["modifier"]
    surfaces << "contract_modifiers" if modifier
    surfaces << "escape_boundary" if contract["fragment_class"] == "escape" || Array(contract["escape_boundaries"]).any?
    surfaces << "temporal" if contract["fragment_class"] == "temporal"
    surfaces << "assumptions" if Array(contract["assumption_refs"]).any?

    Array(contract["nodes"]).each do |node|
      kind = node["kind"]
      unsupported << kind if kind && !KNOWN_NODE_KINDS.include?(kind)
      case kind
      when "temporal_input_node", "temporal_access_node"
        surfaces << "temporal"
      when "stream_input_node", "window_decl_node", "fold_stream_node"
        surfaces << "stream"
        surfaces << "escape_boundary"
      when "olap_access_node"
        surfaces << "olap"
      when "invariant_node"
        surfaces << "invariant"
      when "assumption_ref_node"
        surfaces << "assumptions"
      end
    end
  end

  {
    "surfaces" => surfaces.to_a.sort,
    "unsupported_surfaces" => unsupported.map { |kind| "unsupported_node_kind:#{kind}" }.sort
  }
end

def detect_progression_surfaces(document)
  descriptors = document["descriptors"]
  return nil unless document["kind"].to_s.include?("prop037") || descriptors.is_a?(Hash)

  {
    "surfaces" => ["progression_descriptor"],
    "unsupported_surfaces" => []
  }
end

def detect_surfaces(document)
  detect_progression_surfaces(document) || detect_semantic_ir_surfaces(document)
end

def required_slots_for(surfaces)
  surfaces.flat_map { |surface| SURFACE_SLOTS.fetch(surface, []) }.uniq.sort
end

def coverage_status(profile_source, required_slots, unsupported_surfaces)
  return "unsupported_surface" unless unsupported_surfaces.empty?
  return "profile_not_supplied" unless profile_source

  slot_order = Array(profile_source["slot_order"])
  assignments = profile_source["slot_assignments"] || {}
  missing = required_slots.reject { |slot| slot_order.include?(slot) && assignments.key?(slot) }
  missing.empty? ? "covered" : "missing_slot"
end

def coverage_entry(artifact_id:, artifact_path:, note:, document:, profile_source:)
  detected = detect_surfaces(document)
  surfaces = detected.fetch("surfaces")
  unsupported = detected.fetch("unsupported_surfaces")
  slots = required_slots_for(surfaces)
  slot_order = profile_source ? Array(profile_source["slot_order"]) : []
  assignments = profile_source ? (profile_source["slot_assignments"] || {}) : {}
  missing = slots.reject { |slot| slot_order.include?(slot) && assignments.key?(slot) }
  status = coverage_status(profile_source, slots, unsupported)

  {
    "artifact_id" => artifact_id,
    "artifact_path" => artifact_path,
    "note" => note,
    "detected_surfaces" => surfaces,
    "unsupported_surfaces" => unsupported,
    "required_slots" => slots,
    "missing_slots" => missing,
    "coverage_status" => status
  }
end

def report_for(case_name:, profile_source:, artifacts:)
  entries = artifacts.map do |artifact|
    coverage_entry(
      artifact_id: artifact.fetch(:id),
      artifact_path: artifact.fetch(:path),
      note: artifact.fetch(:note),
      document: artifact.fetch(:document),
      profile_source: profile_source
    )
  end

  statuses = entries.map { |entry| entry.fetch("coverage_status") }.uniq
  report_status = if statuses.include?("unsupported_surface")
                    "unsupported_surface"
                  elsif statuses.include?("profile_not_supplied")
                    "profile_not_supplied"
                  elsif statuses.include?("missing_slot")
                    "missing_slot"
                  else
                    "covered"
                  end

  {
    "kind" => "compiler_profile_obligation_report",
    "format_version" => "0.1.0",
    "case" => case_name,
    "status" => report_status,
    "profile_ref" => profile_source && profile_source["compiler_profile_id"],
    "profile_authority" => {
      "compiler_understanding_only" => true,
      "runtime_authority_granted" => profile_source ? profile_source["runtime_authority_granted"] : false,
      "dispatch_migration_authorized" => profile_source ? profile_source["dispatch_migration_authorized"] : false
    },
    "artifacts" => entries,
    "output_only" => {
      "gates_igapp_emission" => false,
      "changes_cli_exit_status" => false,
      "changes_assembler_output" => false,
      "touches_loader_report" => false,
      "touches_compatibility_report" => false,
      "touches_dispatch" => false,
      "touches_runtime_machine" => false,
      "touches_production_behavior" => false
    }
  }
end

def assert(name, condition, checks)
  checks << { "name" => name, "pass" => !!condition }
end

FileUtils.mkdir_p(OUT_DIR)

profile_source = read_json(PROFILE_SOURCE_PATH)
artifact_inputs = ARTIFACTS.map do |artifact|
  path = rel_to_abs(artifact.fetch(:path))
  artifact.merge(document: read_json(path), abs_path: path, before_digest: digest_file(path))
end

covered_report = report_for(
  case_name: "covered.full_finalized_source",
  profile_source: profile_source,
  artifacts: artifact_inputs
)

missing_temporal_profile = Marshal.load(Marshal.dump(profile_source))
missing_temporal_profile["slot_order"] = missing_temporal_profile.fetch("slot_order").reject { |slot| slot == "temporal" }
missing_temporal_profile["slot_assignments"].delete("temporal")
history_artifact = artifact_inputs.find { |artifact| artifact.fetch(:id) == "history_single_axis" }
missing_slot_report = report_for(
  case_name: "missing_slot.temporal_removed",
  profile_source: missing_temporal_profile,
  artifacts: [history_artifact]
)

profile_not_supplied_report = report_for(
  case_name: "profile_not_supplied.core_add",
  profile_source: nil,
  artifacts: [artifact_inputs.first]
)

unsupported_document = {
  "kind" => "semantic_ir_program",
  "format_version" => "0.1.0",
  "contracts" => [
    {
      "kind" => "contract_ir",
      "contract_name" => "FutureUnsupportedSurface",
      "modifier" => "pure",
      "fragment_class" => "core",
      "nodes" => [
        {
          "kind" => "future_surface_node",
          "name" => "future_value"
        }
      ]
    }
  ]
}
unsupported_report = report_for(
  case_name: "unsupported_surface.synthetic_unknown_node",
  profile_source: profile_source,
  artifacts: [
    {
      id: "synthetic_unknown_node",
      path: "synthetic://future_surface_node",
      note: "Synthetic guard for an unknown future SemanticIR node kind; not a new language surface",
      document: unsupported_document
    }
  ]
)

after_digests = artifact_inputs.to_h { |artifact| [artifact.fetch(:path), digest_file(artifact.fetch(:abs_path))] }
checks = []
assert("covered.case_status", covered_report.fetch("status") == "covered", checks)
assert("covered.includes_core", covered_report.fetch("artifacts").any? { |entry| entry.fetch("detected_surfaces").include?("core") }, checks)
assert("covered.includes_contract_modifiers", covered_report.fetch("artifacts").any? { |entry| entry.fetch("detected_surfaces").include?("contract_modifiers") }, checks)
assert("covered.includes_temporal", covered_report.fetch("artifacts").any? { |entry| entry.fetch("detected_surfaces").include?("temporal") }, checks)
assert("covered.includes_stream", covered_report.fetch("artifacts").any? { |entry| entry.fetch("detected_surfaces").include?("stream") }, checks)
assert("covered.includes_olap", covered_report.fetch("artifacts").any? { |entry| entry.fetch("detected_surfaces").include?("olap") }, checks)
assert("covered.includes_invariant", covered_report.fetch("artifacts").any? { |entry| entry.fetch("detected_surfaces").include?("invariant") }, checks)
assert("covered.includes_assumptions", covered_report.fetch("artifacts").any? { |entry| entry.fetch("detected_surfaces").include?("assumptions") }, checks)
assert("covered.includes_progression_descriptor", covered_report.fetch("artifacts").any? { |entry| entry.fetch("detected_surfaces").include?("progression_descriptor") }, checks)
assert("missing_slot.case_status", missing_slot_report.fetch("status") == "missing_slot", checks)
assert("missing_slot.names_temporal", missing_slot_report.fetch("artifacts").first.fetch("missing_slots").include?("temporal"), checks)
assert("profile_not_supplied.case_status", profile_not_supplied_report.fetch("status") == "profile_not_supplied", checks)
assert("unsupported_surface.case_status", unsupported_report.fetch("status") == "unsupported_surface", checks)
assert("unsupported_surface.names_node_kind", unsupported_report.fetch("artifacts").first.fetch("unsupported_surfaces").include?("unsupported_node_kind:future_surface_node"), checks)
assert("output_only.no_runtime_authority", covered_report.dig("profile_authority", "runtime_authority_granted") == false, checks)
assert("output_only.no_dispatch_migration", covered_report.dig("profile_authority", "dispatch_migration_authorized") == false, checks)
assert("output_only.flags_all_false", covered_report.fetch("output_only").values.all?(false), checks)
assert(
  "output_only.selected_artifact_digests_unchanged",
  artifact_inputs.all? { |artifact| artifact.fetch(:before_digest) == after_digests.fetch(artifact.fetch(:path)) },
  checks
)

reports = [
  covered_report,
  missing_slot_report,
  profile_not_supplied_report,
  unsupported_report
]

summary = {
  "kind" => "compiler_profile_obligation_coverage_proof_summary",
  "format_version" => "0.1.0",
  "track" => "compiler-profile-obligation-coverage-proof-v0",
  "status" => checks.all? { |check| check.fetch("pass") } ? "PASS" : "FAIL",
  "profile_source_path" => "igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json",
  "report_statuses" => reports.to_h { |report| [report.fetch("case"), report.fetch("status")] },
  "surface_to_required_slots" => SURFACE_SLOTS,
  "reports" => reports,
  "checks" => checks,
  "evidence_table" => covered_report.fetch("artifacts").map do |entry|
    {
      "fixture_or_artifact" => entry.fetch("artifact_path"),
      "detected_surfaces" => entry.fetch("detected_surfaces"),
      "required_slots" => entry.fetch("required_slots"),
      "coverage_status" => entry.fetch("coverage_status")
    }
  end,
  "remaining_blockers_before_implementation_authorization" => [
    "pressure review of report shape and status vocabulary",
    "formal owner decision for whether obligation coverage belongs before compile, after emit, or before assembly",
    "stable diagnostic namespace for compiler_profile_obligation.* distinct from compiler_profile_source.* and loader/report statuses",
    "decision on whether progression remains under pipeline or gets a future explicit progression slot",
    "separate Architect implementation authorization with exact write scope"
  ],
  "non_authorizations_preserved" => {
    "gates_igapp_emission" => false,
    "changes_cli_exit_status" => false,
    "changes_assembler_output" => false,
    "loader_report_implementation" => false,
    "compatibility_report_section" => false,
    "compiler_dispatch_migration" => false,
    "runtime_machine_behavior" => false,
    "production_behavior" => false
  }
}

File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

if summary.fetch("status") == "PASS"
  puts "PASS compiler_profile_obligation_coverage_proof"
else
  warn JSON.pretty_generate(checks.reject { |check| check.fetch("pass") })
  exit 1
end
