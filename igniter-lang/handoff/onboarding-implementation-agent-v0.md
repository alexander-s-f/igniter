# Onboarding Card — Implementation Agent

Card: S3-ONBOARD-IMPL-1
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/onboarding-implementation-agent-v0
Status: active

---

## Purpose

This card is the fast-onboarding entry point for a new `[Igniter-Lang
Implementation Agent]` instance. Read it after completing the required read
order and before writing any code.

It captures the current implementation horizon, active work candidates, quality
bar reminders, and the first recommended slice.

---

## Required Read Order (compact)

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. `igniter-lang/roles/implementation-agent.md`
4. `igniter-lang/docs/agent-context.md`
5. `igniter-lang/docs/current-status.md`
6. `igniter-lang/docs/operating-model.md`
7. this file
8. assigned proposal/track docs only

Stop here. Do not read archives, old tracks, or package docs unless the card
names them.

---

## Current Implementation Horizon

```text
lib/igniter_lang/
  parser.rb               ✅ Stage 2 closed; OOF hardening done
  classifier.rb           ✅ Stage 2 closed; CORE/ESCAPE/OOF + SC + stream
  typechecker.rb          ✅ Stage 2 closed; BiHistory + OLAP + invariant
  semanticir_emitter.rb   ✅ production path = emit_typed(typed)
  assembler.rb            ✅ manifest.fragment_summary + contract_index + requirements
  compiler_orchestrator.rb ✅ wired to emit_typed; Stage 1 legacy path retained
  temporal_access_runtime.rb ✅ load-guard + CompatibilityReport split
  runtime_smoke.rb        ✅ six-surface post-switch smoke PASS
  diagnostics.rb          ✅ report shape
  compiler_result.rb      ✅
  compilation_report.rb   ✅
  cli.rb                  ✅ igc CLI + igc-server
  version.rb              VersionBump: 0.1.0.pre.stage2

Open surfaces (implementation work):
  PROP-029  entrypoint/section parser surface   proposal; parser proof OPEN
  PROP-030  executor approval token             proposal; Gate 3 prerequisite; proof OPEN
  Gate 3 request revision                       two edits needed before Arch review
  invariant_persistence                         Stage 2 deferred gap; no production impl
```

---

## Active Proposals for Implementation

### PROP-029 — Entrypoint / Section Surface

File: `igniter-lang/docs/proposals/PROP-029-entrypoint-section-surface-v0.md`

Status: `proposal` — parser/typechecker proof pending before canon.

What is needed:
- Parser accepts `entrypoint` and `section` syntax in `.ig` source
- TypeChecker validates entrypoint uniqueness and section membership
- SemanticIREmitter emits entrypoint/section nodes
- Golden fixture in `fixtures/` updated or created
- Proof script in `experiments/`

Gate: proposal-only until proof PASS. Do not update spec without proof.

### PROP-030 — Executor Approval Token

File: `igniter-lang/docs/proposals/PROP-030-executor-approval-token-contract-v0.md`

Status: `proposal` — Gate 3 prerequisite, not authorization.

What is needed:
- `ExecutorApprovalToken` struct/class in `lib/`
- Token validation in RuntimeMachine guard path
- Proof script showing guard refuses missing/invalid token (Gate 3 closed)
- Report matrix showing valid token still blocked by closed gate

Gate: Gate 3 remains closed. Token implementation is prerequisite work only.

---

## Quality Bar (always active)

Before any handoff claims `done`:

1. proof script or CLI path runs without error
2. golden fixtures match (or `[D]` decision in handoff if updating)
3. Stage 1 + Stage 2 close candidates still PASS
4. only files named by the card are touched
5. no under-specified behavior is guessed — surface as `[Q]` or `[R]`

Run to verify Stage 1/Stage 2 regression:

```bash
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
```

Run production compiler smoke:

```bash
ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb
```

---

## Entry State (as of 2026-05-09)

```text
Stage 1:         CLOSED ✅
Stage 2:         CLOSED ✅ (5 deferred gaps carried to Stage 3)
Stage 3:         OPEN  ⏳
Gate 3:          CLOSED 🚫 (request drafted, HOLD for two edits)
emit_typed path: SWITCHED ✅ production
TEMPORAL load:   PROOF-LOCAL ✅
TEMPORAL eval:   REFUSED 🚫
TBackend Gate 2: RATIFIED ✅ (metadata-only, no live binding)
Release gate:    PASS ✅ (publish not attempted)
```

---

## Recommended First Slice

**Card candidate:** `S3-R12-C1-P`

```text
Track: prop-029-entrypoint-section-parser-proof-v0
Agent: [Igniter-Lang Implementation Agent]
Role:  implementation-agent

Goal:
  - Read PROP-029
  - Write parser proof in experiments/prop029_entrypoint_section_proof/
  - Confirm source/polymorphic_add.ig parse path still PASS as regression
  - Return: proof PASS/FAIL + golden delta + any proposal gaps as [Q]

Acceptance:
  - proof script runs without error
  - entrypoint/section nodes appear in ParsedProgram output
  - golden fixture created or existing fixture updated with [D]
  - Stage 1/2 close candidates still PASS
```

Alternatively, if Gate 3 revision is assigned first:

```text
Track: gate3-request-revision-authority-ref-v0
Goal:
  - Add authority_ref to Gate 3 request decision record
  - Make audit observation non-optional
  - Return: revised doc + no other file changes
```

---

## Handoff Format (use this at end of every slice)

```text
Card: <card-id>
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/<track-name>
Status: done | partial | blocked

[D] Decisions
- ...

[S] Shipped
- ...

[T] Tests / Proofs
- command: ruby experiments/...
- result: PASS / FAIL

[R] Risks / Recommendations
- ...

[Q] Open questions
- ...

[Next] Suggested next slice
- ...
```
