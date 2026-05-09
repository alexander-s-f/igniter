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

## Current Entry State

```text
Stage: Stage 3 open
Production compiler path: Parser -> Classifier -> TypeChecker -> emit_typed -> Assembler
TEMPORAL load: proof-local allowed
TEMPORAL evaluate: closed
Gate 3 request: drafted; HOLD pending revision
Gate 3 live ops: closed
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
- Gate 3 approval

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
Track: runtime-report-enforcement-preflight-v0
Goal: prove production RuntimeMachine must consult composed CompatibilityReport
      before executor/cache/TBackend entry, without opening Gate 3.
```

```text
Track: compatibility-report-composition-shape-v0
Goal: compose the separate proof-local report dimensions into one proposed
      production report shape, still report/proof-only.
```

---

## Handoff Reminder

End with: compact claim, proof result, what became more certain, what remains
pressure-only, changed files, risks, next slice.
