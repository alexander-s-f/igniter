module Igniter.DocumentContextizer

# Architect disposition:
#   active pressure specimen
#   non-canonical
#   not parser authority
#   not runtime authority
#   not production deployment authority
# Routing:
#   docs/tracks/contextizer-pressure-specimen-routing-v0.md
#
# Note:
#   Any "production-ready" wording below is external pressure-agent language,
#   not Igniter-Lang project authority.

# =============================================================================
# Igniter Document Contextizer ("Contextizer")
# High-level agent for turning large documents into compact, actionable context
#
# Purpose:
#   Part of the agent swarm pipeline. Takes big documents (laws, contracts,
#   court cases, reports) and produces dense, high-fidelity context that
#   other agents can consume efficiently.
#
# Key features:
#   • Ledger-backed (BiHistory[ContextSnapshot])
#   • Uses Igniter.TextEngine under the hood
#   • LLM integration via unified connector (escape capability)
#   • Immutable, observable, reproducible
#   • Supports "actualization" — updating context when source changes
#   • Outputs structured context with evidence links (receipts)
#
# Version: 0.1.0 (Narrative Contracts v2)
# External claim: production-ready
# Project status: active pressure specimen only
# =============================================================================

# =============================================================================
# Core Types
# =============================================================================

type ContextSnapshot {
  id:              String
  source_buffer_id: String
  version:         Integer
  compact_context: String
  key_points:      Array[KeyPoint]
  evidence_links:  Array[FactReceipt]
  metadata:        Map[String, Any]     # jurisdiction, document_type, confidence, etc.
  created_at:      DateTime
  valid_until:     DateTime?
}

type KeyPoint {
  id:        String
  text:      String
  importance: Float          # 0.0–1.0
  category:  String          # "legal_fact", "obligation", "risk", "definition"...
  range_ref: Range?
}

type ContextizationParams {
  max_tokens:       Integer?   # target compactness
  focus_areas:      Array[String]
  style:            String     # "legal_concise", "executive", "technical"...
  include_evidence: Bool
  llm_temperature:  Float?
}

type ContextizationResult {
  snapshot: ContextSnapshot
  quality_score: Float
  compression_ratio: Float
}

# =============================================================================
# Helper (pure)
# =============================================================================

def generate_snapshot_id(buffer_id: String) -> String {
  "ctx_" ++ buffer_id ++ "_" ++ now.to_iso8601
}

# =============================================================================
# 10 Core Contracts — Contextizer Agent API
# =============================================================================

contract LoadDocumentForContext for source: TextSource, buffer_id: String? {

  given buffer := LoadTextBuffer(source: source, buffer_id: buffer_id)

  emit document_loaded_for_context(buffer.id)

  output buffer: TextBuffer
  output receipt: FactReceipt
}

contract ExtractKeySections for buffer: TextBuffer, params: ContextizationParams {

  phase extraction {
    sections := if params.focus_areas.is_empty {
      buffer.extract_all_semantic_sections()
    } else {
      params.focus_areas.map(area -> ExtractSection(buffer: buffer, selector: {kind: area}))
    }
  }

  emit key_sections_extracted(sections.count)

  output sections: Array[String]
  output receipt: FactReceipt
}

contract GenerateCompactContext for buffer: TextBuffer, params: ContextizationParams {

  given llm_connector: LLMConnector   # unified escape capability (already registered)

  phase research {
    key_sections := ExtractKeySections(buffer: buffer, params: params)
    raw_summary  := SummarizeWithContext(buffer: buffer, focus: {topic: params.focus_areas.join(", ")})
  }

  phase llm_refinement {
    prompt := build_context_prompt(raw_summary, key_sections, params.style)
    refined_context := llm_connector.call(
      model: "contextizer-v1",
      prompt: prompt,
      temperature: params.llm_temperature || 0.3,
      max_tokens: params.max_tokens || 4000
    )
  }

  phase build_snapshot {
    snapshot := ContextSnapshot.new(
      id: generate_snapshot_id(buffer.id),
      source_buffer_id: buffer.id,
      version: buffer.version,
      compact_context: refined_context,
      key_points: extract_key_points(refined_context),
      evidence_links: raw_summary.evidence_links,
      metadata: {
        compression_ratio: buffer.content.length.to_float / refined_context.length.to_float,
        confidence: 0.92,
        style: params.style
      },
      created_at: now
    )
  }

  emit compact_context_generated(snapshot.id, snapshot.metadata.compression_ratio)

  output snapshot: ContextSnapshot
  output receipt: FactReceipt
}

contract ActualizeContext for snapshot_id: String, new_buffer: TextBuffer {

  given old_snapshot: History[ContextSnapshot] from "contexts/{snapshot_id}"

  phase diff {
    delta := VersionDiff(buffer: new_buffer, old_version: old_snapshot.latest.created_at)
  }

  phase actualize {
    updated_snapshot := GenerateCompactContext(
      buffer: new_buffer,
      params: { focus_areas: old_snapshot.latest.metadata.focus_areas || [] }
    )
  }

  emit context_actualized(snapshot_id, delta.changes)

  output updated_snapshot: ContextSnapshot
  output receipt: FactReceipt
}

contract DetectContextDrift for snapshot: ContextSnapshot, current_buffer: TextBuffer {

  phase check {
    drift_score := current_buffer.semantic_drift_score(snapshot.compact_context)
  }

  validate { drift_score < 0.15   severity: warn   label: "CONTEXT-DRIFT" }

  emit context_drift_detected(snapshot.id, drift_score)

  output drift_score: Float
  output needs_actualization: Bool = drift_score >= 0.15
  output receipt: FactReceipt
}

contract ValidateContextQuality for snapshot: ContextSnapshot {

  phase validation {
    quality_score := evaluate_context_quality(
      context: snapshot.compact_context,
      evidence_count: snapshot.evidence_links.count
    )
  }

  validate { quality_score >= 0.85   severity: error   label: "LOW-QUALITY-CONTEXT" }

  emit context_quality_validated(snapshot.id, quality_score)

  output quality_score: Float
  output receipt: FactReceipt
}

contract PublishContextForSwarm for snapshot: ContextSnapshot, swarm_id: String? {

  phase publish {
    partition := if swarm_id { "swarm_contexts/{swarm_id}" } else { "global_contexts" }
    # fact is automatically written to ledger via ContractableReceiptSink
  }

  emit context_published_for_swarm(snapshot.id, swarm_id || "global")

  output published_ref: String
  output receipt: FactReceipt
}

contract RunFullContextizationPipeline for source: TextSource, params: ContextizationParams, swarm_id: String? {

  phase 1_load {
    buffer := LoadDocumentForContext(source: source)
  }

  phase 2_context {
    snapshot := GenerateCompactContext(buffer: buffer, params: params)
  }

  phase 3_validate {
    _ := ValidateContextQuality(snapshot: snapshot)
  }

  phase 4_publish {
    _ := PublishContextForSwarm(snapshot: snapshot, swarm_id: swarm_id)
  }

  emit full_contextization_completed(snapshot.id, snapshot.metadata.compression_ratio)

  output snapshot: ContextSnapshot
  output receipt: FactReceipt
}

contract CreateContextRecipe for name: String, default_params: ContextizationParams {

  phase save {
    recipe_id := "ctx_recipe_" ++ name.to_lower.replace(" ", "_")
    # stored in ledger as TextRecipe with Contextizer steps
  }

  emit context_recipe_created(recipe_id)

  output recipe_id: String
  output receipt: FactReceipt
}

# =============================================================================
# Public Facade — recommended way for other agents to use Contextizer
# =============================================================================

contract Contextizer {

  # Main entry point for the agent swarm pipeline

  output load: ContractRef[LoadDocumentForContext]
  output extract_key: ContractRef[ExtractKeySections]
  output generate: ContractRef[GenerateCompactContext]
  output actualize: ContractRef[ActualizeContext]
  output detect_drift: ContractRef[DetectContextDrift]
  output validate: ContractRef[ValidateContextQuality]
  output publish: ContractRef[PublishContextForSwarm]
  output run_pipeline: ContractRef[RunFullContextizationPipeline]
  output create_recipe: ContractRef[CreateContextRecipe]

  # Example usage by another agent:
  #   ctx := Contextizer()
  #   snapshot := ctx.run_pipeline(source: doc, params: {style: "legal_concise"})
}

# =============================================================================
# End of Igniter.DocumentContextizer
# External suggested package path, not authorized by this specimen:
#   packages/igniter-document-contextizer/contracts/igniter-document-contextizer.ig
#
# Dependencies (already satisfied in current Igniter-Lang):
#   • Igniter.TextEngine (ExtractSection, SummarizeWithContext, VersionDiff…)
#   • LLMConnector escape capability (unified LLM API)
#   • igniter-ledger (BiHistory[ContextSnapshot])
#
# External suggested next steps, not authorized:
#   1. Compile this file
#   2. Register "contextizer" capability in LedgerMesh / AgentRuntime
#   3. Create Ruby wrapper LegalAgent#contextizer or SwarmAgent#contextizer
# =============================================================================
