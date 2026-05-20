#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../../..", __dir__))
OUT_DIR = ROOT.join("igniter-lang/experiments/oof_fragment_registry_shadow_proof/out")
SOURCE_SUMMARY = ROOT.join(
  "igniter-lang/experiments/compiler_pack_shadow_profile_proof_v1/out/compiler_pack_shadow_profile_proof_v1_summary.json"
)

TRACK = "oof-fragment-registry-shadow-proof-v0"

def descriptor(code, family:, owner:, stage:, layer:, severity:, status_class:, stability:,
               message_stability: "stable_family_message", aliases: [], deprecated: false,
               deprecated_by: nil, replacement_code: nil, refs: [], current_status: "current",
               notes: "")
  {
    "code" => code,
    "family" => family,
    "owner_pack_or_boundary" => owner,
    "source_stage" => stage,
    "compiler_layer" => layer,
    "severity" => severity,
    "status_class" => status_class,
    "public_code_stability" => stability,
    "message_stability" => message_stability,
    "aliases" => aliases,
    "deprecated" => deprecated,
    "deprecated_by" => deprecated_by,
    "replacement_code" => replacement_code,
    "source_refs" => refs,
    "current_status" => current_status,
    "non_authority_notes" => notes
  }
end

def alias_descriptor(code, replacement_code:, family:, owner:, stage:, refs:)
  descriptor(
    code,
    family: family,
    owner: owner,
    stage: stage,
    layer: "typechecker",
    severity: "error",
    status_class: "compatibility_alias",
    stability: "stable_compatibility_alias",
    deprecated: true,
    deprecated_by: replacement_code,
    replacement_code: replacement_code,
    refs: refs,
    current_status: "compatibility_alias",
    notes: "Compatibility alias retained for public diagnostic stability; canonical descriptor remains #{replacement_code}."
  )
end

def current_refs(*paths)
  paths
end

OOF_DESCRIPTORS = [
  descriptor("OOF-P0", family: "core_parse_or_emit", owner: "CoreLanguagePack",
             stage: "parser", layer: "parser", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/parser.rb", "lib/igniter_lang/semanticir_emitter.rb"),
             notes: "Generic unsupported parser/emitter construct; public code retained until a later registry design narrows it."),
  descriptor("OOF-P1", family: "core_symbol_resolution", owner: "CoreLanguagePack",
             stage: "classifier", layer: "classifier_typechecker_semanticir", severity: "error",
             status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/classifier.rb", "lib/igniter_lang/typechecker.rb", "lib/igniter_lang/semanticir_emitter.rb")),
  descriptor("OOF-P2", family: "core_parser_contract_shape", owner: "CoreLanguagePack",
             stage: "parser", layer: "parser", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/parser.rb")),
  descriptor("OOF-P28", family: "core_parser_shape", owner: "CoreLanguagePack",
             stage: "parser", layer: "parser", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/parser.rb")),
  descriptor("OOF-TY0", family: "core_type", owner: "CoreLanguagePack",
             stage: "typechecker", layer: "typechecker_semanticir", severity: "error",
             status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/typechecker.rb", "lib/igniter_lang/semanticir_emitter.rb")),
  descriptor("OOF-DM3", family: "decimal_numeric", owner: "CoreLanguagePack",
             stage: "parser", layer: "parser", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/parser.rb"),
             notes: "Owned by core until numeric support grows enough to justify a separate pack."),

  descriptor("OOF-PG1", family: "pipeline_parser", owner: "PipelinePack",
             stage: "parser", layer: "parser", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/parser.rb")),
  descriptor("OOF-PG2", family: "pipeline_parser", owner: "PipelinePack",
             stage: "parser", layer: "parser", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/parser.rb")),
  descriptor("OOF-PG3", family: "pipeline_parser", owner: "PipelinePack",
             stage: "parser", layer: "parser", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/parser.rb")),
  descriptor("OOF-PG5", family: "pipeline_parser", owner: "PipelinePack",
             stage: "parser", layer: "parser", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/parser.rb"),
             notes: "Pipeline remains syntax/descriptor pressure only; no scheduler authority."),

  descriptor("OOF-H1", family: "temporal_history", owner: "TemporalPack",
             stage: "typechecker", layer: "typechecker", severity: "error",
             status_class: "blocking_oof", stability: "stable_current", aliases: ["OOF-TM1"],
             refs: current_refs("lib/igniter_lang/typechecker.rb")),
  descriptor("OOF-H2", family: "temporal_history", owner: "TemporalPack",
             stage: "proof_only", layer: "proof_only", severity: "error",
             status_class: "candidate_oof", stability: "candidate_proof_only",
             refs: current_refs("experiments/history_type_proof"),
             current_status: "candidate",
             notes: "Present in shadow pack profile as temporal family pressure; not promoted as a live emitted code by this proof."),
  descriptor("OOF-H3", family: "temporal_history", owner: "TemporalPack",
             stage: "proof_only", layer: "proof_only", severity: "error",
             status_class: "candidate_oof", stability: "candidate_proof_only",
             refs: current_refs("experiments/history_type_proof"),
             current_status: "candidate"),
  descriptor("OOF-H4", family: "temporal_history", owner: "TemporalPack",
             stage: "proof_only", layer: "proof_only", severity: "error",
             status_class: "candidate_oof", stability: "candidate_proof_only",
             refs: current_refs("experiments/history_type_proof"),
             current_status: "candidate"),
  descriptor("OOF-BT1", family: "temporal_bihistory", owner: "TemporalPack",
             stage: "typechecker", layer: "typechecker", severity: "error",
             status_class: "blocking_oof", stability: "stable_current", aliases: ["OOF-TM3"],
             refs: current_refs("lib/igniter_lang/typechecker.rb")),
  descriptor("OOF-BT2", family: "temporal_bihistory", owner: "TemporalPack",
             stage: "typechecker", layer: "typechecker", severity: "error",
             status_class: "blocking_oof", stability: "stable_current", aliases: ["OOF-TM4"],
             refs: current_refs("lib/igniter_lang/typechecker.rb")),
  descriptor("OOF-BT3", family: "temporal_bihistory", owner: "TemporalPack",
             stage: "typechecker", layer: "typechecker", severity: "error",
             status_class: "blocking_oof", stability: "stable_current", aliases: ["OOF-TM5"],
             refs: current_refs("lib/igniter_lang/typechecker.rb")),
  descriptor("OOF-BT4", family: "temporal_bihistory", owner: "TemporalPack",
             stage: "typechecker", layer: "typechecker", severity: "error",
             status_class: "blocking_oof", stability: "stable_current", aliases: ["OOF-TM6"],
             refs: current_refs("lib/igniter_lang/typechecker.rb")),
  alias_descriptor("OOF-TM1", replacement_code: "OOF-H1", family: "temporal_alias",
                   owner: "TemporalPack", stage: "typechecker", refs: current_refs("lib/igniter_lang/typechecker.rb")),
  alias_descriptor("OOF-TM3", replacement_code: "OOF-BT1", family: "temporal_alias",
                   owner: "TemporalPack", stage: "typechecker", refs: current_refs("lib/igniter_lang/typechecker.rb")),
  alias_descriptor("OOF-TM4", replacement_code: "OOF-BT2", family: "temporal_alias",
                   owner: "TemporalPack", stage: "typechecker", refs: current_refs("lib/igniter_lang/typechecker.rb")),
  alias_descriptor("OOF-TM5", replacement_code: "OOF-BT3", family: "temporal_alias",
                   owner: "TemporalPack", stage: "typechecker", refs: current_refs("lib/igniter_lang/typechecker.rb")),
  alias_descriptor("OOF-TM6", replacement_code: "OOF-BT4", family: "temporal_alias",
                   owner: "TemporalPack", stage: "typechecker", refs: current_refs("lib/igniter_lang/typechecker.rb")),

  descriptor("OOF-S1", family: "stream", owner: "StreamPack", stage: "parser", layer: "parser",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/parser.rb")),
  descriptor("OOF-S2", family: "stream", owner: "StreamPack", stage: "classifier", layer: "classifier",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/classifier.rb")),
  descriptor("OOF-S3", family: "stream", owner: "StreamPack", stage: "typechecker", layer: "typechecker",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/typechecker.rb")),
  descriptor("OOF-S4", family: "stream", owner: "StreamPack", stage: "classifier", layer: "classifier",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/classifier.rb")),
  descriptor("OOF-S5", family: "stream", owner: "StreamPack", stage: "parser", layer: "parser",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/parser.rb")),

  descriptor("OOF-O1", family: "olap", owner: "OLAPPack", stage: "proof_only", layer: "proof_only",
             severity: "error", status_class: "candidate_oof", stability: "candidate_proof_only",
             refs: current_refs("experiments/olap_point_proof"), current_status: "candidate",
             notes: "OLAP is a candidate owner surface, not a fragment class."),
  descriptor("OOF-O2", family: "olap", owner: "OLAPPack", stage: "typechecker", layer: "typechecker",
             severity: "warning", status_class: "warning_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/typechecker.rb")),
  descriptor("OOF-O3", family: "olap", owner: "OLAPPack", stage: "typechecker", layer: "typechecker",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/typechecker.rb")),
  descriptor("OOF-O4", family: "olap", owner: "OLAPPack", stage: "typechecker", layer: "typechecker",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/typechecker.rb")),
  descriptor("OOF-O5", family: "olap", owner: "OLAPPack", stage: "typechecker", layer: "typechecker",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/typechecker.rb")),

  descriptor("OOF-IV1", family: "invariant", owner: "InvariantPack", stage: "parser", layer: "parser",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/parser.rb")),
  descriptor("OOF-IV2", family: "invariant", owner: "InvariantPack", stage: "parser", layer: "parser",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/parser.rb")),
  descriptor("OOF-IV3", family: "invariant", owner: "InvariantPack", stage: "typechecker", layer: "typechecker",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/typechecker.rb")),
  descriptor("OOF-I1", family: "invariant", owner: "InvariantPack", stage: "proof_only", layer: "proof_only",
             severity: "error", status_class: "candidate_oof", stability: "candidate_proof_only",
             refs: current_refs("experiments/invariant_severity_proof"), current_status: "candidate"),
  descriptor("OOF-I2", family: "invariant", owner: "InvariantPack", stage: "proof_only", layer: "proof_only",
             severity: "error", status_class: "candidate_oof", stability: "candidate_proof_only",
             refs: current_refs("experiments/invariant_severity_proof"), current_status: "candidate"),
  descriptor("OOF-I3", family: "invariant", owner: "InvariantPack", stage: "proof_only", layer: "proof_only",
             severity: "error", status_class: "candidate_oof", stability: "candidate_proof_only",
             refs: current_refs("experiments/invariant_severity_proof"), current_status: "candidate"),
  descriptor("OOF-I4", family: "invariant", owner: "InvariantPack", stage: "parser", layer: "parser_typechecker",
             severity: "error", status_class: "blocking_oof", stability: "stable_current",
             refs: current_refs("lib/igniter_lang/parser.rb", "lib/igniter_lang/typechecker.rb")),
  descriptor("OOF-I5", family: "invariant", owner: "InvariantPack", stage: "proof_only", layer: "proof_only",
             severity: "error", status_class: "candidate_oof", stability: "candidate_proof_only",
             refs: current_refs("experiments/invariant_severity_proof"), current_status: "candidate"),
  descriptor("PINV-1", family: "invariant_parser_proof", owner: "InvariantPack", stage: "parser", layer: "parser",
             severity: "proof_marker", status_class: "proof_marker", stability: "proof_only",
             refs: current_refs("lib/igniter_lang/parser.rb"), current_status: "candidate",
             notes: "PINV/TINV are proof/checkpoint markers, not current blocking public OOF codes."),
  descriptor("PINV-2", family: "invariant_parser_proof", owner: "InvariantPack", stage: "parser", layer: "parser",
             severity: "proof_marker", status_class: "proof_marker", stability: "proof_only",
             refs: current_refs("lib/igniter_lang/parser.rb"), current_status: "candidate"),
  descriptor("PINV-3", family: "invariant_parser_proof", owner: "InvariantPack", stage: "parser", layer: "parser",
             severity: "proof_marker", status_class: "proof_marker", stability: "proof_only",
             refs: current_refs("lib/igniter_lang/parser.rb"), current_status: "candidate"),
  descriptor("PINV-4", family: "invariant_parser_proof", owner: "InvariantPack", stage: "parser", layer: "parser",
             severity: "proof_marker", status_class: "proof_marker", stability: "proof_only",
             refs: current_refs("lib/igniter_lang/parser.rb"), current_status: "candidate"),
  descriptor("TINV-1", family: "invariant_type_proof", owner: "InvariantPack", stage: "typechecker", layer: "typechecker",
             severity: "proof_marker", status_class: "proof_marker", stability: "proof_only",
             refs: current_refs("lib/igniter_lang/typechecker.rb"), current_status: "candidate"),
  descriptor("TINV-2", family: "invariant_type_proof", owner: "InvariantPack", stage: "typechecker", layer: "typechecker",
             severity: "proof_marker", status_class: "proof_marker", stability: "proof_only",
             refs: current_refs("lib/igniter_lang/typechecker.rb"), current_status: "candidate"),
  descriptor("TINV-3", family: "invariant_type_proof", owner: "InvariantPack", stage: "typechecker", layer: "typechecker",
             severity: "proof_marker", status_class: "proof_marker", stability: "proof_only",
             refs: current_refs("lib/igniter_lang/typechecker.rb"), current_status: "candidate"),

  descriptor("OOF-M1", family: "contract_modifier", owner: "ContractModifiersPack", stage: "classifier",
             layer: "classifier_typechecker", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/classifier.rb", "lib/igniter_lang/typechecker.rb")),
  descriptor("OOF-A1", family: "assumption", owner: "AssumptionsPack", stage: "classifier",
             layer: "classifier_typechecker", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/classifier.rb")),
  descriptor("TASSUMP-1", family: "assumption", owner: "AssumptionsPack", stage: "typechecker",
             layer: "typechecker", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/typechecker.rb"),
             notes: "Non-OOF-prefix assumption diagnostic remains in the shadow descriptor table because R91 pack data owns it."),

  descriptor("OOF-CE4", family: "evidence_observation", owner: "EvidenceObservationPack", stage: "classifier",
             layer: "classifier_semanticir", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/classifier.rb", "lib/igniter_lang/semanticir_emitter.rb")),
  descriptor("OOF-OS2", family: "evidence_observation", owner: "EvidenceObservationPack", stage: "classifier",
             layer: "classifier_semanticir", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/classifier.rb", "lib/igniter_lang/semanticir_emitter.rb")),
  descriptor("OOF-OS4", family: "evidence_observation", owner: "EvidenceObservationPack", stage: "semanticir",
             layer: "semanticir", severity: "error", status_class: "blocking_oof",
             stability: "stable_current", refs: current_refs("lib/igniter_lang/semanticir_emitter.rb")),

  descriptor("OOF-PR1", family: "progression_descriptor", owner: "PipelinePack",
             stage: "proof_only", layer: "descriptor_proof", severity: "error",
             status_class: "descriptor_only", stability: "candidate_proof_only",
             refs: current_refs("experiments/prop037_descriptor_oof_pr_proof"), current_status: "candidate",
             notes: "Progression remains descriptor/report-only pressure under pipeline; no PROGRESSION fragment class."),
  descriptor("OOF-PR2", family: "progression_descriptor", owner: "PipelinePack",
             stage: "proof_only", layer: "descriptor_proof", severity: "error",
             status_class: "descriptor_only", stability: "candidate_proof_only",
             refs: current_refs("experiments/prop037_descriptor_oof_pr_proof"), current_status: "candidate"),
  descriptor("OOF-PR3", family: "progression_descriptor", owner: "PipelinePack",
             stage: "proof_only", layer: "descriptor_proof", severity: "error",
             status_class: "descriptor_only", stability: "candidate_proof_only",
             refs: current_refs("experiments/prop037_descriptor_oof_pr_proof"), current_status: "candidate"),
  descriptor("OOF-PR4", family: "progression_descriptor", owner: "PipelinePack",
             stage: "proof_only", layer: "descriptor_proof", severity: "error",
             status_class: "descriptor_only", stability: "candidate_proof_only",
             refs: current_refs("experiments/prop037_descriptor_oof_pr_proof"), current_status: "candidate"),
  descriptor("OOF-PR5", family: "progression_descriptor", owner: "PipelinePack",
             stage: "proof_only", layer: "descriptor_proof", severity: "error",
             status_class: "descriptor_only", stability: "candidate_proof_only",
             refs: current_refs("experiments/prop037_descriptor_oof_pr_proof"), current_status: "candidate"),
  descriptor("OOF-PR6", family: "progression_descriptor", owner: "PipelinePack",
             stage: "proof_only", layer: "descriptor_proof", severity: "error",
             status_class: "descriptor_only", stability: "candidate_proof_only",
             refs: current_refs("experiments/prop037_descriptor_oof_pr_proof"), current_status: "candidate"),
  descriptor("OOF-PR7", family: "progression_descriptor", owner: "PipelinePack",
             stage: "proof_only", layer: "descriptor_proof", severity: "error",
             status_class: "descriptor_only", stability: "candidate_proof_only",
             refs: current_refs("experiments/prop037_descriptor_oof_pr_proof"), current_status: "candidate"),
  descriptor("OOF-PR8", family: "progression_descriptor", owner: "PipelinePack",
             stage: "proof_only", layer: "descriptor_proof", severity: "error",
             status_class: "descriptor_only", stability: "candidate_proof_only",
             refs: current_refs("experiments/prop037_descriptor_oof_pr_proof"), current_status: "candidate"),
  descriptor("OOF-PR9", family: "progression_descriptor", owner: "PipelinePack",
             stage: "proof_only", layer: "descriptor_proof", severity: "error",
             status_class: "descriptor_only", stability: "candidate_proof_only",
             refs: current_refs("experiments/prop037_descriptor_oof_pr_proof"), current_status: "candidate")
].freeze

EXCLUDED_DIAGNOSTIC_NAMESPACES = [
  {
    "namespace" => "compiler_profile_contract.*",
    "owner_pack_or_boundary" => "CompilerProfileContractPack",
    "classification" => "excluded_from_oof_namespace",
    "reason" => "Nested report-only validator diagnostics, not language OOF diagnostics."
  },
  {
    "namespace" => "compiler_profile_contract_refusal.*",
    "owner_pack_or_boundary" => "CompilerOrchestratorStrictTerminalBoundary",
    "classification" => "excluded_from_oof_namespace",
    "reason" => "Internal strict-terminal wrapper diagnostics, not language OOF diagnostics."
  },
  {
    "namespace" => "OOF-RUNTIME-SMOKE",
    "owner_pack_or_boundary" => "RuntimeSmoke",
    "classification" => "excluded_runtime_helper",
    "reason" => "Runtime smoke helper diagnostic must not be promoted into the language OOF registry."
  }
].freeze

FRAGMENT_REGISTRY = [
  {
    "name" => "oof",
    "owner_pack_or_boundary" => "OOFRegistryPack",
    "current_or_candidate" => "current_shadow_status_and_fragment_marker",
    "applies_to" => ["contract", "node", "report_status"],
    "classification_kind" => "status_fragment_both_candidate",
    "value_flow_notes" => "OOF blocks SemanticIR/assembly; it may appear in fragment summaries but must not be treated as a capability.",
    "precedence_candidate" => 100,
    "canonical_status" => "non_canon_candidate",
    "non_authority_notes" => "C0 requires evaluating fragment/status/both; live answer remains undecided."
  },
  {
    "name" => "temporal",
    "owner_pack_or_boundary" => "TemporalPack",
    "current_or_candidate" => "current",
    "applies_to" => ["contract", "node"],
    "classification_kind" => "language_fragment",
    "value_flow_notes" => "Temporal read node is TEMPORAL; selected value remains CORE-typed via value_fragment_class.",
    "precedence_candidate" => 90,
    "canonical_status" => "non_canon_candidate"
  },
  {
    "name" => "stream",
    "owner_pack_or_boundary" => "StreamPack",
    "current_or_candidate" => "current_shadow",
    "applies_to" => ["contract", "node"],
    "classification_kind" => "language_fragment",
    "value_flow_notes" => "Stream ingress/fold metadata remains compiler/proof-local; production ingress stays closed.",
    "precedence_candidate" => 80,
    "canonical_status" => "non_canon_candidate"
  },
  {
    "name" => "epistemic",
    "owner_pack_or_boundary" => "AssumptionsPack",
    "current_or_candidate" => "current",
    "applies_to" => ["contract", "node"],
    "classification_kind" => "language_fragment",
    "value_flow_notes" => "Assumptions surface is current compiler evidence; PROP-033 evidence-list validation remains closed.",
    "precedence_candidate" => 70,
    "canonical_status" => "non_canon_candidate"
  },
  {
    "name" => "escape",
    "owner_pack_or_boundary" => "EscapeBoundaryPack",
    "current_or_candidate" => "current",
    "applies_to" => ["contract", "node"],
    "classification_kind" => "trust_boundary_fragment",
    "value_flow_notes" => "External read/effect boundary; runtime authority remains closed.",
    "precedence_candidate" => 60,
    "canonical_status" => "non_canon_candidate"
  },
  {
    "name" => "core",
    "owner_pack_or_boundary" => "CoreLanguagePack",
    "current_or_candidate" => "current",
    "applies_to" => ["contract", "node", "value"],
    "classification_kind" => "language_fragment",
    "value_flow_notes" => "Baseline pure compiler surface.",
    "precedence_candidate" => 10,
    "canonical_status" => "non_canon_candidate"
  },
  {
    "name" => "olap",
    "owner_pack_or_boundary" => "OLAPPack",
    "current_or_candidate" => "excluded_candidate_owner_only",
    "applies_to" => ["owner_surface"],
    "classification_kind" => "not_fragment_class",
    "value_flow_notes" => "OLAP has nodes and diagnostics but is not promoted to fragment class.",
    "precedence_candidate" => nil,
    "canonical_status" => "excluded_non_fragment"
  },
  {
    "name" => "progression",
    "owner_pack_or_boundary" => "PipelinePack",
    "current_or_candidate" => "excluded",
    "applies_to" => ["descriptor_metadata_under_pipeline"],
    "classification_kind" => "not_fragment_class",
    "value_flow_notes" => "PROP-037 progression remains under pipeline metadata; no PROGRESSION fragment class.",
    "precedence_candidate" => nil,
    "canonical_status" => "excluded_non_fragment"
  }
].freeze

OOF_ALTERNATIVES = [
  {
    "model" => "oof_as_fragment",
    "benefit" => "Fits current fragment summaries and assembler refusal checks.",
    "risk" => "May make failure look like a language capability.",
    "proof_recommendation" => "not_preferred_alone"
  },
  {
    "model" => "oof_as_status",
    "benefit" => "Clean diagnostic/status model.",
    "risk" => "Does not fully explain existing fragment_class: oof summaries.",
    "proof_recommendation" => "insufficient_alone"
  },
  {
    "model" => "oof_as_both",
    "benefit" => "Matches current proof/compiler intuition while keeping blocking status explicit.",
    "risk" => "Needs stronger non-authority invariants before canonization.",
    "proof_recommendation" => "preferred_shadow_model"
  }
].freeze

def check(name, details = nil)
  ok = yield
  { "name" => name, "status" => ok ? "PASS" : "FAIL", "details" => details }.compact
end

def unique?(values)
  values.uniq.length == values.length
end

source_summary = JSON.parse(File.read(SOURCE_SUMMARY))
source_packs = source_summary.fetch("profile").fetch("packs")
source_required_oofs = source_packs.flat_map { |pack| pack.fetch("oof_codes", []) }.uniq.sort
descriptor_codes = OOF_DESCRIPTORS.map { |descriptor| descriptor.fetch("code") }
descriptor_by_code = OOF_DESCRIPTORS.to_h { |descriptor| [descriptor.fetch("code"), descriptor] }

required_descriptor_fields = %w[
  code family owner_pack_or_boundary source_stage compiler_layer severity
  status_class public_code_stability message_stability aliases deprecated
  deprecated_by replacement_code source_refs current_status non_authority_notes
]

candidate_precedence = FRAGMENT_REGISTRY
  .select { |fragment| fragment.fetch("precedence_candidate") }
  .sort_by { |fragment| -fragment.fetch("precedence_candidate") }
  .map { |fragment| fragment.fetch("name") }

registry_payload = {
  "kind" => "oof_descriptor_shadow_registry",
  "format_version" => "0.1.0",
  "track" => TRACK,
  "source_profile_id" => source_summary.fetch("profile_id", source_summary.dig("profile", "profile_id")),
  "source_shadow_profile_status" => source_summary.fetch("status"),
  "descriptors" => OOF_DESCRIPTORS,
  "excluded_diagnostic_namespaces" => EXCLUDED_DIAGNOSTIC_NAMESPACES,
  "non_authority" => {
    "registry_implementation_authorized" => false,
    "dispatch_authorized" => false,
    "public_diagnostic_contract_authorized" => false
  }
}

fragment_payload = {
  "kind" => "fragment_shadow_registry",
  "format_version" => "0.1.0",
  "track" => TRACK,
  "fragments" => FRAGMENT_REGISTRY,
  "oof_model_alternatives" => OOF_ALTERNATIVES,
  "candidate_precedence_high_to_low" => candidate_precedence,
  "precedence_status" => "proof_local_non_canon",
  "non_authority" => {
    "fragment_registry_implementation_authorized" => false,
    "compiler_classification_change_authorized" => false,
    "assembler_summary_change_authorized" => false
  }
}

checks = []
checks << check("source_profile_v1.pass_evidence") { source_summary.fetch("status") == "PASS" }
checks << check("source_profile_v1.shadow_no_dispatch") { source_summary.dig("profile", "dispatch_mode") == "shadow_no_dispatch" }
checks << check("descriptor.codes_unique") { unique?(descriptor_codes) }
checks << check("descriptor.required_fields_present") do
  OOF_DESCRIPTORS.all? { |descriptor| required_descriptor_fields.all? { |field| descriptor.key?(field) } }
end
checks << check("descriptor.source_profile_oof_codes_covered") do
  (source_required_oofs - descriptor_codes).empty?
end
checks << check("descriptor.aliases_resolve_to_compatibility_alias_descriptors") do
  OOF_DESCRIPTORS.all? do |descriptor|
    descriptor.fetch("aliases").all? do |alias_code|
      alias_desc = descriptor_by_code[alias_code]
      alias_desc &&
        alias_desc.fetch("current_status") == "compatibility_alias" &&
        alias_desc.fetch("replacement_code") == descriptor.fetch("code")
    end
  end
end
checks << check("descriptor.compatibility_aliases_have_replacements") do
  OOF_DESCRIPTORS
    .select { |descriptor| descriptor.fetch("current_status") == "compatibility_alias" }
    .all? { |descriptor| descriptor.fetch("replacement_code") && descriptor_by_code.key?(descriptor.fetch("replacement_code")) }
end
checks << check("descriptor.current_codes_have_owner_stage_stability") do
  OOF_DESCRIPTORS.all? do |descriptor|
    !descriptor.fetch("owner_pack_or_boundary").empty? &&
      !descriptor.fetch("source_stage").empty? &&
      !descriptor.fetch("public_code_stability").empty?
  end
end
checks << check("descriptor.profile_contract_diagnostics_excluded") do
  excluded = EXCLUDED_DIAGNOSTIC_NAMESPACES.map { |entry| entry.fetch("namespace") }
  excluded.include?("compiler_profile_contract.*") &&
    excluded.include?("compiler_profile_contract_refusal.*") &&
    descriptor_codes.none? { |code| code.start_with?("compiler_profile_contract") }
end
checks << check("descriptor.runtime_smoke_helper_excluded") do
  EXCLUDED_DIAGNOSTIC_NAMESPACES.any? { |entry| entry.fetch("namespace") == "OOF-RUNTIME-SMOKE" } &&
    !descriptor_by_code.key?("OOF-RUNTIME-SMOKE")
end
checks << check("fragment.required_current_names_have_owners") do
  required = %w[core escape temporal stream epistemic oof]
  current = FRAGMENT_REGISTRY.select { |fragment| required.include?(fragment.fetch("name")) }
  current.length == required.length &&
    current.all? { |fragment| !fragment.fetch("owner_pack_or_boundary").empty? }
end
checks << check("fragment.olap_and_progression_not_promoted") do
  %w[olap progression].all? do |name|
    fragment = FRAGMENT_REGISTRY.find { |entry| entry.fetch("name") == name }
    fragment && fragment.fetch("classification_kind") == "not_fragment_class"
  end
end
checks << check("fragment.temporal_node_value_split_representable") do
  temporal = FRAGMENT_REGISTRY.find { |entry| entry.fetch("name") == "temporal" }
  temporal.fetch("value_flow_notes").include?("value_fragment_class")
end
checks << check("fragment.epistemic_current_prop033_closed") do
  epistemic = FRAGMENT_REGISTRY.find { |entry| entry.fetch("name") == "epistemic" }
  epistemic.fetch("current_or_candidate") == "current" &&
    epistemic.fetch("value_flow_notes").include?("PROP-033")
end
checks << check("fragment.candidate_precedence_deterministic_non_canon") do
  candidate_precedence == %w[oof temporal stream epistemic escape core] &&
    fragment_payload.fetch("precedence_status") == "proof_local_non_canon"
end
checks << check("fragment.oof_alternatives_evaluated") do
  OOF_ALTERNATIVES.map { |alternative| alternative.fetch("model") }.sort == %w[oof_as_both oof_as_fragment oof_as_status]
end
checks << check("fragment.oof_preferred_shadow_model_is_both") do
  OOF_ALTERNATIVES.find { |alternative| alternative.fetch("model") == "oof_as_both" }
    .fetch("proof_recommendation") == "preferred_shadow_model"
end
checks << check("closed_surfaces.preserved") do
  registry_payload.fetch("non_authority").values.all?(false) &&
    fragment_payload.fetch("non_authority").values.all?(false)
end

failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
status = failed_checks.empty? ? "PASS" : "FAIL"

registry_id_input = JSON.generate({
  "descriptors" => OOF_DESCRIPTORS,
  "fragments" => FRAGMENT_REGISTRY,
  "excluded" => EXCLUDED_DIAGNOSTIC_NAMESPACES,
  "precedence" => candidate_precedence
})

summary = {
  "kind" => "oof_fragment_registry_shadow_proof_summary",
  "format_version" => "0.1.0",
  "track" => TRACK,
  "status" => status,
  "registry_id" => "oof_fragment_shadow_registry/sha256:#{Digest::SHA256.hexdigest(registry_id_input)[0, 24]}",
  "source_evidence" => {
    "compiler_pack_shadow_profile_proof_v1_summary" => SOURCE_SUMMARY.relative_path_from(ROOT).to_s,
    "compiler_pack_shadow_profile_proof_v1_status" => source_summary.fetch("status"),
    "dispatch_mode" => source_summary.dig("profile", "dispatch_mode")
  },
  "descriptor_count" => OOF_DESCRIPTORS.length,
  "fragment_count" => FRAGMENT_REGISTRY.length,
  "candidate_precedence_high_to_low" => candidate_precedence,
  "oof_recommendation" => "model_oof_as_both_for_shadow_only",
  "checks" => checks,
  "failed_checks" => failed_checks,
  "outputs" => {
    "summary" => "igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/oof_fragment_registry_shadow_proof_summary.json",
    "oof_descriptors" => "igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json",
    "fragments" => "igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json"
  },
  "closed_surfaces" => {
    "compiler_code_changed" => false,
    "specs_or_proposals_changed" => false,
    "registry_implementation_authorized" => false,
    "dispatch_authorized" => false,
    "igapp_or_golden_mutation_authorized" => false,
    "public_api_cli_widening_authorized" => false,
    "loader_report_or_compatibility_report_authorized" => false,
    "runtime_or_production_authorized" => false,
    "spark_fixture_or_production_authorized" => false
  },
  "implementation_authorized" => false
}

FileUtils.mkdir_p(OUT_DIR)
File.write(OUT_DIR.join("oof_descriptors.shadow_registry.json"), "#{JSON.pretty_generate(registry_payload)}\n")
File.write(OUT_DIR.join("fragment_registry.shadow_registry.json"), "#{JSON.pretty_generate(fragment_payload)}\n")
File.write(OUT_DIR.join("oof_fragment_registry_shadow_proof_summary.json"), "#{JSON.pretty_generate(summary)}\n")

if status == "PASS"
  puts "PASS #{TRACK}"
  puts "checks: #{checks.length}/#{checks.length}"
  puts "registry_id: #{summary.fetch("registry_id")}"
else
  warn "FAIL #{TRACK}"
  failed_checks.each { |entry| warn "- #{entry.fetch("name")}" }
  exit 1
end
