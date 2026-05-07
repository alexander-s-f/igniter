# Compiler Pipeline Gap Review

Date: 2026-05-07
Source: external agent review relayed by user
Status: review-signal
Owner: `[Architect Supervisor / Codex]`

## Purpose

Capture an external review of the current Igniter-Lang compiler/research
pipeline and its distance from the future language surface explored through
human-agent comprehension fixtures.

This is not a PROP, not canon, and not an implementation track. It records
pressure for Stage 3 planning.

## Positive Assessment

The review validates several core architecture choices:

- Pipeline boundaries are explicit: `ParsedProgram`, `ClassifiedProgram`,
  `TypedProgram`, `SemanticIRProgram`, and `.igapp/` bundle.
- Stage close is proof-driven through executable evidence and JSON verdicts.
- OOF handling is structured and agent-readable rather than exception-driven.
- Human-agent comprehension fixtures are useful design instruments, not just
  examples.
- Temporal access runtime keeps explicit capabilities and avoids hidden
  wall-clock reads.

## Main Gaps

### G1. Working Syntax And Future Syntax Are Diverging

Current compiler syntax handles the proven Stage 1/Stage 2 surface. Future
fixtures such as `field_supply_watch.ig` and `field_supply_watch_v2.ig` explore
syntax that is intentionally not claimed to parse yet:

```text
store
stream
mesh
delegate
await_review
metric
receipt
variant
trait
```

This is acceptable for research, but the gap must stay visible so future syntax
does not silently masquerade as implemented language.

### G2. `sample_input` Is Still A Compiler-Pipeline Crutch

`CompilerOrchestrator` resolves `sample_input`, passes it into `Classifier`, and
keeps it in the compile result. This supports existing proof fixtures, but it
means some classification decisions still depend on example data rather than
types alone.

Stage 3 pressure:

```text
Classifier should classify structure/fragments without sample data.
TypeChecker should own type and capability validation.
Runtime smoke should own sample values.
```

### G3. TypedProgram Is Not The Default Emission Path

`SemanticIREmitter` supports both:

```text
emit(parsed_program, sample_input:)
emit_typed(typed_program)
```

The production `CompilerOrchestrator` currently computes `typed_program` but
still emits through the parsed/sample-input path. This preserves current proof
behavior, but leaves TypedProgram evidence partially parallel to the main
emission path.

Stage 3 pressure:

```text
CompilerOrchestrator should switch to emit_typed once parity is proven.
```

### G4. Temporal Is Not A First-Class Fragment Class Yet

Current fragment classes are effectively:

```text
core
escape
oof
```

`History[T]`, `BiHistory[T]`, and stream-related surfaces are treated through
`escape` paths. The review argues that temporal access deserves its own
classification because it carries explicit `T`/axis/capability requirements,
not merely "outside core" semantics.

Candidate pressure:

```text
core
temporal
stream
escape
oof
```

or a smaller first step:

```text
fragment_class: escape
capability_class: temporal
```

### G5. `.igapp/` Lacks Capability Negotiation

`.igapp/` manifests carry format metadata, but there is no full live mechanism
for declaring and negotiating required runtime capabilities such as
`history_read`, `bihistory_read`, TBackend axes, or Ledger descriptor
compatibility.

This aligns with the current deliberate state: Ledger/TBackend descriptors are
metadata-only evidence, and RuntimeMachine binding remains deferred.

## Suggested Priority Order

1. Prove `emit_typed` parity and make it the main `CompilerOrchestrator` path.
2. Remove or isolate `sample_input` from classification; keep it for runtime
   smoke only.
3. Add temporal capability classification without breaking Stage 2 close.
4. Add `.igapp/` required capability manifest and compatibility report hooks.
5. Route future syntax fixtures into Stage 3 parser experiments only after
   comprehension pressure stabilizes.

## Architect Notes

[D] Treat this review as aligned with the current Stage 2 close posture: Stage 2
can close with deferred gaps because the gaps are visible and bounded.

[D] Do not let future syntax fixtures become implicit canon. They are pressure
fixtures until parser/spec/OOF rules accept them.

[R] Strong first Stage 3 compiler slice:

```text
typed-emission-main-path-parity-v0
```

Acceptance should include same pass/fail outcomes for current close candidate
fixtures plus explicit documentation of any SemanticIR shape deltas.

[R] Strong second Stage 3 compiler slice:

```text
sample-input-isolation-v0
```

Acceptance should remove `sample_input` from classifier responsibility or
document the exact remaining proof-local exception.

