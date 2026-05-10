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

## Swarm / Refresh Discipline

- Re-read this onboarding card at least once per stage, after role-profile
  updates, and after proposal/spec/gate shifts that affect formal language work.
- Multiple Compiler/Grammar instances may work asynchronously. Do not assume
  exclusive ownership of proposals, specs, or golden families unless assigned.
- Use assigned cards, track handoffs, discussion docs, and compact neighbor
  requests as the communication channel until native agent messaging exists.

---

## Current Entry State

```text
Stage: Stage 3 open
Typed emission: switched to emit_typed
PROP-031: contract modifiers implemented/proven; §14 compatibility addendum landed
Gate 3 Phase 1: signed-approved-restricted live read (R20)
Phase 1 production durable audit: bounded implementation authorized (S3-R30-C1-A)
Language lane focus: one active PROP vector at a time; next likely Gap-H assumptions (PROP-032)
CSM rule: implemented/experiment-pass entities need golden anchors
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
Track: observed-temporal-precedence-golden-v0
Goal: add a dedicated golden proving `observed` + temporal body keeps
      fragment_class: "temporal".
```

```text
Track: p28-unnamed-block-enforcement-gap-table-v0
Goal: list which unnamed semantic blocks are currently enforced vs Covenant
      commitment only.
```

```text
Track: prop032-assumptions-draft-v0
Goal: draft assumptions {} as the single active Language Lane PROP; do not open
      forms/loops/constraints/effect surface in parallel.
```

---

## Handoff Reminder

End with: formal decision/correction, parser/compiler delta, OOF rules,
SemanticIR implications, spec-lag, changed files, next slice.
