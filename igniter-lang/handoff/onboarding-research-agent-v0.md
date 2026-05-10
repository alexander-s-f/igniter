# Onboarding Card - Research Agent

Card: S3-ONBOARD-RESEARCH-1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/onboarding-research-agent-v0
Status: active

---

## Purpose

Fast-onboarding entry point for a fresh Research Agent instance.

Use this as a launch capsule after reading the role profile. If this card
disagrees with `agent-context.md`, `current-status.md`, or the role profile,
the current maps win.

---

## Required Read Order

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. `igniter-lang/roles/research-agent.md`
4. `igniter-lang/docs/agent-context.md`
5. `igniter-lang/docs/current-status.md`
6. `igniter-lang/docs/operating-model.md`
7. `igniter-lang/docs/operating-scheduler.md`
8. this file
9. assigned track/proposal/source docs only

Do not read archives, old tracks, package docs, or external project docs unless
the assigned card names them.

---

## Swarm / Refresh Discipline

- Re-read this onboarding card at least once per stage, after role-profile
  updates, and after gate/status shifts that affect proof authority.
- Multiple Research instances may work asynchronously. Do not assume exclusive
  ownership of experiments, fixtures, or generated outputs unless assigned.
- Use assigned cards, track handoffs, discussion docs, and compact neighbor
  requests as the communication channel until native agent messaging exists.

---

## Current Entry State

```text
Stage: Stage 3 open
Production compiler path: Parser -> Classifier -> TypeChecker -> emit_typed -> Assembler
Gate 3 Phase 1: signed-approved-restricted live read (R20)
Phase 1 production durable audit: bounded implementation authorized (S3-R30-C1-A)
Proof focus: validators, golden fixtures, regression matrices, and bounded conformance proofs
Still closed: production deployment, Ledger/Phase 2, BiHistory, stream/OLAP production executor,
              production cache, concrete HSM/KMS onboarding, broad RuntimeMachine binding
```

---

## Owns In Practice

- executable proof tracks in `igniter-lang/experiments/`
- compact track docs in `igniter-lang/docs/tracks/`
- runtime-machine proof pressure
- fixture/scenario proof for language behavior
- proof-local cache/runtime/TBackend boundary validation

## Does Not Own

- final grammar/type authority
- round-close status curation by default
- package integration
- implementation inside `lib/` unless explicitly assigned
- Architect approval or bounded implementation scope

---

## Quality Bar

Before claiming `done`:

1. The named proof or fixture runs, or the blocker is explicit.
2. Summary JSON or track evidence is inspectable when a proof is added.
3. Gate state is preserved: proof-local is not production authorization.
4. Regression scope follows `agent-context.md` proof budget.

---

## Recommended Current Slices

```text
Track: startup-time-freshness-override-validator-v0
Goal: implement proof-local validator for signed freshness policy overrides
      without production registry or online lookup.
```

```text
Track: post-audit-implementation-regression-matrix-v0
Goal: rerun the full matrix after bounded audit implementation work lands,
      with volatile_fields_lint first.
```

---

## Handoff Reminder

End with: compact claim, proof result, what became more certain, what remains
pressure-only, changed files, risks, next slice.
