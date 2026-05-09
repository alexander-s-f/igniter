# Onboarding Card - Compiler/Grammar Expert

Card: S3-ONBOARD-CG-1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/onboarding-compiler-grammar-expert-v0
Status: active

---

## Purpose

Fast-onboarding entry point for a fresh Compiler/Grammar Expert instance.

This role protects formal language shape, grammar/type/OOF boundaries,
SemanticIR correctness, and spec-lag visibility.

---

## Required Read Order

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. `igniter-lang/roles/compiler-grammar-expert.md`
4. `igniter-lang/docs/agent-context.md`
5. `igniter-lang/docs/current-status.md`
6. `igniter-lang/docs/operating-model.md`
7. `igniter-lang/docs/operating-scheduler.md`
8. this file
9. relevant spec/proposal docs named by the assigned card

Do not read archives or package docs unless the card explicitly asks.

---

## Current Entry State

```text
Stage: Stage 3 open
Typed emission: switched to emit_typed
PROP-028: TEMPORAL fragment/cache semantics active; runtime executor pending
PROP-029: entrypoint/section proposal; parser/typechecker proof pending
PROP-030: ExecutorApprovalToken proposal; report/guard proofs landed
Gate 3 request: drafted; HOLD pending revision; no syntax authorization
Spec-lag: Ch6 invariant metadata sync and Ch7 gate approval sync may be needed
```

---

## Owns In Practice

- `docs/proposals/`
- `docs/spec/` when assigned spec sync
- grammar/source syntax boundaries
- OOF/rejection rules
- type-system/coherence questions
- SemanticIR acceptance constraints
- spec-lag findings after semantic/compiler changes

## Does Not Own

- executable proof implementation unless assigned
- runtime/product scenario synthesis
- package integration
- gate approval
- broad status curation unless assigned

---

## Quality Bar

Before claiming `done`:

1. Grammar/type/OOF terms are precise.
2. Spec-lag is named instead of silently papered over.
3. Proposal-only surfaces are not described as canon.
4. Parser/runtime implementation is not implied unless assigned.

---

## Recommended Current Slices

```text
Track: spec-ch6-invariant-source-metadata-sync-v0
Goal: document optional invariant source_metadata/source_span in Ch6 after
      S3-R10 implementation landed.
```

```text
Track: entrypoint-section-parser-typechecker-v0
Goal: only after implementation assignment/proof scope is clear, formal-check
      PROP-029 parser/typechecker acceptance and OOF rules.
```

```text
Track: spec-ch7-gate3-approval-sync
Goal: only if Gate 3 is approved, sync Ch7 with approval-token/runtime ordering.
```

---

## Handoff Reminder

End with: formal decision/correction, parser/compiler delta, OOF rules,
SemanticIR implications, spec-lag, changed files, next slice.
