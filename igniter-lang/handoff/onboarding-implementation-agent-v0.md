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
  Phase 1 production durable audit              bounded implementation authorized by S3-R30-C1-A
  startup_time freshness override validator     proof-local validator needed
  PROP-031 observed+temporal golden             proof/golden follow-up needed
  P28 unnamed-block enforcement gap table        Compiler/Grammar-owned, not implementation by default
  PROP-032 assumptions                          draft/proof planning next; no parser implementation yet
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

Status: `proposal` — Gate 3 prerequisite, not broad authorization.
S3-R10 already landed report-only token validation and proof-local guarded
runtime enforcement. R20 signed restricted Phase 1 live-read scope; S3-R30-C1-A
authorizes only bounded durable audit implementation work. Do not broaden token
or runtime authority surfaces from this onboarding card alone.

What may be needed later, after approval:
- production `ExecutorApprovalToken` struct/class in `lib/`
- production token validation in RuntimeMachine guard path
- production authority/revocation/signature integration
- proof that valid token still cannot bypass a closed or out-of-scope gate

Gate: Gate 3 Phase 1 is restricted and signed; Phase 2/Ledger/BiHistory/cache
remain closed. Do not implement production token validation beyond an explicitly
assigned bounded track.

### Phase 1 Production Durable Audit — Bounded Implementation

File:
`igniter-lang/docs/gates/phase1-production-durable-audit-implementation-authorization-decision-v0.md`

Status: `approved-bounded-implementation` — implementation track authorized,
deployment closed.

Authorized implementation surfaces:
- audit record schema validation
- signer abstraction contract proof
- append-only audit store interface proof
- restart rebuild proof
- startup freshness policy validator
- format_version enforcement proof
- audit traversal/reader proof
- appender/reader role boundary proof
- excluded-surface regression proof
- post-implementation regression matrix

Still closed:
- production deployment
- concrete HSM/KMS onboarding
- production signing execution/key management
- production authority registry implementation
- broad RuntimeMachine binding
- Ledger adapter / Phase 2
- BiHistory
- stream/OLAP production executor
- production cache
- general write/replay/compact/subscribe

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

## Entry State (as of 2026-05-10)

```text
Stage 1:         CLOSED ✅
Stage 2:         CLOSED ✅ (5 deferred gaps carried to Stage 3)
Stage 3:         OPEN  ⏳
Gate 3 Phase 1:  SIGNED-APPROVED-RESTRICTED LIVE READ ✅
Durable audit:   BOUNDED IMPLEMENTATION AUTHORIZED ✅ (deployment closed)
emit_typed path: SWITCHED ✅ production
TEMPORAL eval:   restricted Phase 1 only; Phase 2/Ledger/BiHistory closed
TBackend Gate 2: RATIFIED ✅ (metadata-only, no live binding)
Release gate:    PASS ✅ (publish not attempted)
```

---

## Recommended First Slice

**Card candidate:** `S3-R30-C2-P`

```text
Track: startup-time-freshness-override-validator-v0
Agent: [Igniter-Lang Implementation Agent]
Role:  implementation-agent

Goal:
  - Read startup-time-freshness-override-interface-v0 and S3-R30-C1-A
  - Implement proof-local validator for signed freshness policies
  - Cover default 24h, valid tighter/looser policy, hash/signature/authority/expiry/range failures
  - Decide whether all non-default policies require expires_at and document it

Acceptance:
  - proof script runs without error
  - refusal codes match R29 design
  - no production registry, online lookup, Ledger, or HSM/KMS integration
  - full relevant regression matrix routed after implementation
```

Alternatively, if durable audit core implementation is assigned:

```text
Track: production-durable-audit-bounded-implementation-v0
Goal:
  - Implement only surfaces authorized by S3-R30-C1-A
  - Produce schema/signer/store/rebuild/reader/role/excluded-surface proofs
  - Keep deployment, Ledger, Phase 2, concrete HSM/KMS, and broad RuntimeMachine binding closed
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
