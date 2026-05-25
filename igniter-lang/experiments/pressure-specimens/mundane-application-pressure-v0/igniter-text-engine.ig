module Igniter.TextEngine

# =============================================================================
# DISPOSITION: external pressure specimen / non-canonical
#   Not parser authority. Not runtime authority.
#   Not production deployment authority. Not public demo/release evidence.
#   This file is an active pressure specimen used for bounded compiler testing.
# =============================================================================

# =============================================================================
# Igniter TextEngine — "Vim for Agents"
# High-level, observable, ledger-backed text manipulation library
#
# Purpose:
#   Provide agents with powerful, declarative, immutable text operations
#   that integrate natively with igniter-ledger (BiHistory[TextVersion]).
#   Every edit, extraction, annotation, or simulation becomes an immutable
#   fact with full audit trail, time-travel, and receipts.
#
# Key abstractions:
#   - TextBuffer   : immutable ledger-backed text container + full history
#   - Range        : semantic-aware selection (section, paragraph, article…)
#   - Patch        : declarative change description
#   - Recipe       : reusable macro of operations
#   - TextEngine   : agent-facing facade (used via contracts)
#
# All operations are:
#   • Immutable (new buffer is returned)
#   • Observable (emit + observe → ledger facts)
#   • Reproducible (as_of / simulation support)
#   • Composable (contracts call other contracts)
#
# Version: 0.1.0 (Narrative Contracts v2)
# Status:  external pressure specimen / non-canonical / not production-ready
# =============================================================================

# =============================================================================
# Core Types (structural, Stage 1 + Stage 2)
# =============================================================================

type TextBuffer {
  id:           String
  content:      String
  version:      Integer
  last_modified: DateTime
  metadata:     Map[String, Any]          # e.g. jurisdiction, document_type
  history_ref:  String                    # ledger partition "text_buffers/{id}"
}

type Range {
  start:        Integer
  end:          Integer
  semantic_type: String?                  # "article", "section", "paragraph", "definition"…
  label:        String?                   # e.g. "Art. 15.1"
}

type Patch {
  kind:         String                    # "replace", "insert", "delete", "annotate"
  range:        Range
  new_content:  String?
  annotations:  Array[Annotation]?
}

type Annotation {
  kind:         String                    # "highlight", "comment", "citation", "collision"
  range:        Range
  payload:      Map[String, Any]
}

type TextRecipe {
  id:           String
  name:         String
  steps:        Array[OperationStep]
}

type OperationStep {
  contract_ref: String                    # e.g. "Igniter.TextEngine.ApplyPatch"
  params:       Map[String, Any]
}

type TextDelta {
  changes:      Integer
  hunks:        Array[Map[String, Any]]
}

type TextCollision {
  range:        Range
  rule_id:      String
  severity:     String                    # error | warn | soft
  message:      String
}

type SemanticPattern {
  kind:         String                    # "regex", "keyword", "legal_term", "structure"
  query:        String
  confidence_threshold: Float
}

# =============================================================================
# Helper functions (pure, inlined by compiler)
# =============================================================================

def generate_buffer_id(source_hash: String) -> String {
  "buf_" ++ source_hash.take(16)
}

def generate_recipe_id(name: String) -> String {
  "recipe_" ++ name.to_lower.replace(" ", "_")
}

# =============================================================================
# 12 Core Contracts — High-level TextEngine API
# =============================================================================

contract LoadTextBuffer for source: TextSource, buffer_id: String? {

  given existing_history: History[TextVersion] from "text_buffers/{buffer_id || generate_buffer_id(source.hash)}"

  phase load {
    buffer := if existing_history.exists {
      existing_history.latest_snapshot.as_text_buffer
    } else {
      TextBuffer.new(
        id: generate_buffer_id(source.hash),
        content: source.content,
        version: 0,
        last_modified: now,
        metadata: source.metadata,
        history_ref: "text_buffers/{buffer_id}"
      )
    }
  }

  validate {
    source.content.length > 0   severity: error   label: "EMPTY-SOURCE"
  }

  emit buffer_loaded(buffer.id, buffer.version)

  output buffer: TextBuffer
  output receipt: FactReceipt
}

contract ExtractSection for buffer: TextBuffer, selector: SectionSelector {

  phase extraction {
    range   := buffer.find_semantic_section(selector)   # calls internal semantic parser
    content := buffer.extract_range(range)
  }

  emit section_extracted(selector.kind, content.length)

  output extracted_text: String
  output range: Range
  output receipt: FactReceipt
}

contract ApplyPatch for buffer: TextBuffer, patch: Patch {

  phase validation {
    conflicts := buffer.detect_patch_conflicts(patch)
  }

  phase apply {
    new_buffer := buffer.apply_patch(patch)   # immutable, returns new version
    observe patch_applied(patch.kind, patch.range)
  }

  validate { conflicts.count == 0   severity: warn   label: "PATCH-CONFLICT" }

  emit text_patched(patch.kind, new_buffer.version)

  output new_buffer: TextBuffer
  output receipt: FactReceipt
}

contract DetectCollisionsInText for buffer: TextBuffer, rules: Array[CollisionRule] {

  phase scan {
    collisions := buffer.scan_for_collisions(rules)   # cross-references with ledger laws/precedents
    annotated  := buffer.annotate_collisions(collisions)
  }

  emit collisions_detected(collisions.count)

  output collisions: Array[TextCollision]
  output annotated_buffer: TextBuffer
  output receipt: FactReceipt
}

contract SummarizeWithContext for buffer: TextBuffer, focus: FocusArea {

  phase summarize {
    summary      := buffer.summarize(focus: focus, style: "legal_concise")
    evidence     := buffer.capture_evidence_links(summary)
  }

  emit summary_generated(focus.topic)

  output summary: String
  output evidence_links: Array[FactReceipt]
  output receipt: FactReceipt
}

contract VersionDiff for buffer: TextBuffer, old_version: DateTime, new_version: DateTime? {

  phase diff {
    delta := buffer.diff_as_of(old_version, new_version || now)
  }

  emit diff_computed(delta.changes)

  output delta: TextDelta
  output receipt: FactReceipt
}

contract AnnotateText for buffer: TextBuffer, annotations: Array[Annotation] {

  phase annotate {
    new_buffer := buffer.add_annotations(annotations)   # immutable
  }

  emit annotations_applied(annotations.count)

  output annotated_buffer: TextBuffer
  output receipt: FactReceipt
}

contract RunRecipe for buffer: TextBuffer, recipe_id: String, params: Map[String, Any] {

  given recipe_history: History[TextRecipe] from "text_recipes/{recipe_id}"

  phase execute {
    recipe := recipe_history.latest
    result := recipe.apply_to(buffer, params)   # executes steps sequentially
  }

  emit recipe_executed(recipe_id, result.version)

  output result_buffer: TextBuffer
  output receipt: FactReceipt
}

contract SimulateEdit for buffer: TextBuffer, proposed_change: Patch, simulation_id: String {

  phase simulate {
    temp_buffer := buffer.fork_for_simulation(simulation_id)   # isolated ledger partition
    result      := temp_buffer.apply_patch(proposed_change)
  }

  emit edit_simulated(simulation_id)

  output simulated_buffer: TextBuffer
  output receipt: FactReceipt
}

contract SearchAndReplaceSemantic for buffer: TextBuffer, pattern: SemanticPattern, replacement: Replacement {

  phase replace {
    matches    := buffer.semantic_search(pattern)
    new_buffer := buffer.replace_all(matches, replacement)
  }

  emit semantic_replace_executed(matches.count)

  output new_buffer: TextBuffer
  output receipt: FactReceipt
}

contract GenerateLegalBriefFromText for buffer: TextBuffer, query: LegalQuery {

  phase research {
    sections := ExtractSection(buffer: buffer, selector: {kind: "article"})   # sub-contract calls
    summary  := SummarizeWithContext(buffer: buffer, focus: query.focus)
    brief    := synthesize_legal_brief(sections, summary, query)
  }

  emit legal_brief_generated(query.topic)

  output brief: LegalBrief
  output sources: Array[FactReceipt]
}

contract CreateTextRecipe for name: String, steps: Array[OperationStep] {

  phase save {
    recipe_id := generate_recipe_id(name)
    recipe    := TextRecipe.new(
      id: recipe_id,
      name: name,
      steps: steps
    )
    observe recipe_created(name)
  }

  emit recipe_saved(recipe_id)

  output recipe_id: String
  output receipt: FactReceipt
}

# =============================================================================
# Public facade contract for agents (recommended entry point)
# =============================================================================

contract TextEngine for buffer_id: String {

  # Convenience contract that exposes all operations as methods on a buffer
  # Used by agents via ContractRef[TextEngine]

  output load: ContractRef[LoadTextBuffer]
  output extract: ContractRef[ExtractSection]
  output patch: ContractRef[ApplyPatch]
  output detect_collisions: ContractRef[DetectCollisionsInText]
  output summarize: ContractRef[SummarizeWithContext]
  output diff: ContractRef[VersionDiff]
  output annotate: ContractRef[AnnotateText]
  output run_recipe: ContractRef[RunRecipe]
  output simulate: ContractRef[SimulateEdit]
  output search_replace: ContractRef[SearchAndReplaceSemantic]
  output generate_brief: ContractRef[GenerateLegalBriefFromText]
  output create_recipe: ContractRef[CreateTextRecipe]

  # Example usage inside another contract:
  #   engine := TextEngine(buffer_id: "buf_abc123")
  #   result := engine.patch(buffer: current_buffer, patch: my_patch)
}

# =============================================================================
# End of Igniter.TextEngine
# Place this file at: packages/igniter-text-engine/contracts/igniter-text-engine.ig
#
# Next steps after placing in repo:
# 1. Run IgniterLang.compile on this file → produces .igapp/
# 2. Register TextEngine as first-class capability in LedgerMesh / JurisLedger
# 3. Agents can now do: agent.text_engine.extract(...) etc.
# =============================================================================