# Track: Progression Pack Shadow Boundary v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `progression-pack-shadow-boundary-v0`
Status: done
Date: 2026-05-11

---

## Goal

Evaluate `external-progression-runtime-model-v0` against the new
profile-assembled compiler architecture and prove whether it belongs as a
capability-owned compiler pack.

This track does not authorize progression syntax, SemanticIR nodes,
RuntimeMachine production integration, durable scheduler work, compiler dispatch
changes, or `.igapp`/`.ilk` format changes.

---

## Evaluation

[D] External progression is a strong idea and should not be treated as a naming
change for loops.

The useful conceptual move is:

```text
loop = eager repeated body execution
progression = declared event potential + bounded runtime materialization
```

That makes progression a real language/runtime boundary because it owns
capabilities that neither `StreamPack`, `TemporalPack`, nor `PipelinePack` own
cleanly:

```text
external event potential
bounded materialization
step receipts
checkpoint/resume
structured backpressure
structured cancellation
```

---

## Where It Fits

[D] In the future profile-assembled compiler, progression belongs as:

```text
ProgressionPack
```

It should be a proposed/shadow-only pack for now.

It is not:

```text
CoreLanguagePack
TemporalPack
StreamPack
PipelinePack
```

Relationship:

| Pack | Relationship |
|---|---|
| `CoreLanguagePack` | Required baseline for handler contracts and core expressions. |
| `EscapeBoundaryPack` | Required because progression sources are external runtime boundaries. |
| `StreamPack` | Sibling; stream handles data ingress/fold, progression handles event potential/materialization. |
| `TemporalPack` | Sibling; temporal reads history, progression schedules/materializes future/external events. |
| `PipelinePack` | Optional future integration for step orchestration, not ownership. |
| `EvidenceObservationPack` | Optional future integration for receipt/audit observations. |

---

## Added Proof

Added:

```text
igniter-lang/experiments/progression_pack_shadow_boundary/progression_pack_shadow_boundary.rb
igniter-lang/experiments/progression_pack_shadow_boundary/out/progression_pack_shadow_boundary_model.json
igniter-lang/experiments/progression_pack_shadow_boundary/out/progression_pack_shadow_boundary_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/progression_pack_shadow_boundary/progression_pack_shadow_boundary.rb
```

Result:

```text
PASS progression_pack_shadow_boundary
```

The runner refreshes:

```text
external_progression_runtime_model
```

and appends a proposed `ProgressionPack` to the shadow compiler profile without
dispatch or `.igapp` changes.

---

## Pack Descriptor

```text
name: ProgressionPack
implementation_id: progression.proof_runtime_model_shadow.v0
status: proposed_shadow_only
```

Dependencies:

```text
CoreLanguagePack
EscapeBoundaryPack
OOFRegistry
FragmentRegistry
```

Provided capabilities:

```text
external_progression
progression_source
bounded_materialization
progression_step_receipt
progression_checkpoint_resume
progression_backpressure
progression_cancellation
```

---

## Compiler Surface Mapping

| Surface | Proposed ownership |
|---|---|
| parser | Future progression declarations only; no parser work now. |
| classifier | Classify progression sources as external progression capability, not eager loops. |
| typechecker | Event payload, handler signature, receipt/checkpoint shape. |
| SemanticIR | Candidate `progression_source` / materialization / handler-ref nodes; not authorized here. |
| assembler | Candidate progression sources and requirements sections; `.igapp` format change blocked. |
| diagnostics | `OOF-PR*` candidates for invalid source, handler mismatch, unbounded materialization, illegal authority claim. |

---

## Runtime Contract Mapping

The pack maps to the proven runtime lifecycle:

```text
ProgressionSource
  -> EventMaterializer
  -> EventQueue
  -> StepExecutor
  -> ReceiptSink
```

Runtime proof shapes:

```text
progression_event
progression_materialization
progression_step_receipt
progression_checkpoint
```

---

## Open Questions

```text
Is ProgressionPack service-contract-only, or can ordinary contracts declare progressions?
Does progression get a dedicated fragment class, or remain an escape/runtime capability with manifest metadata?
Should progression step receipts flow through CompilationReceipt, RuntimeMachine receipts, or a separate ProgressionReceiptSink?
Which source kinds are canonical first: clock.every, work_queue, or both?
Should checkpoint/replay be manifest metadata, runtime policy, or both?
```

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.external_progression_passed` | Upstream runtime model proof passed. |
| `verdict.progression_pack_not_loop_rename` | Progression is a semantic pack candidate, not loop naming. |
| `boundary.not_core_temporal_stream_or_pipeline` | It does not belong inside existing packs. |
| `pack.has_semantic_capability_ownership` | Pack owns real capabilities. |
| `pack.depends_on_core_escape_oof_fragment` | Dependencies are explicit. |
| `pack.has_receipt_checkpoint_backpressure_cancellation` | Runtime lifecycle capabilities are represented. |
| `relationship.stream_temporal_pipeline_are_siblings` | Existing packs are siblings/integration points, not owners. |
| `runtime.lifecycle_maps_to_pack` | Runtime lifecycle maps to pack descriptor. |
| `profile.shadow_no_dispatch_no_igapp_change` | Shadow profile only; no dispatch or artifact changes. |
| `scope.no_syntax_semanticir_runtime_authority` | No syntax, SemanticIR, or production runtime authority. |

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: progression-pack-shadow-boundary-v0
Status: done

[D] Decisions:
- External progression fits the new compiler architecture as ProgressionPack.
- It is sibling to StreamPack, TemporalPack, and PipelinePack, not owned by them.
- It remains proposed_shadow_only.
- No syntax, SemanticIR node, RuntimeMachine production integration, durable scheduler, or .igapp change is authorized.

[S] Signals:
- Runtime proof capabilities map cleanly to compiler pack capabilities.
- The lifecycle ProgressionSource -> EventMaterializer -> EventQueue -> StepExecutor -> ReceiptSink is compiler-visible enough to deserve a pack.
- Progression is stronger than loop semantics because materialization, receipts, checkpoint, backpressure, and cancellation are first-class.

[T] Tests:
- ruby igniter-lang/experiments/progression_pack_shadow_boundary/progression_pack_shadow_boundary.rb -> PASS

[R] Risks:
- Fragment-class ownership is open.
- Service-contract-only vs ordinary-contract surface is open.
- Receipt sink ownership needs Compiler/Runtime/Architect decision.

[Next]
- Add this proof to the compiler profile closure index.
- If Architect wants language adoption, open a formal progression semantics proposal.
```
