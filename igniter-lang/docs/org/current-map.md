# Org Sidecar Current Map

Status: active
Owner: [Org Architect Supervisor]
Initialized: 2026-05-17
Source card: `S3-R62-C0-O`
Scope: documentation/orchestration sidecar only

---

## Current Position

The Org Architect Supervisor is a sidecar lane. It supports the main
Architect Supervisor by keeping process memory compact, path-indexed, and
separate from active compiler/profile/runtime authority.

Current main-lane anchor:

```text
Stage 3 open.
R61 accepted PROP-038 as proposal-only.
R62 is open for PROP-038 implementation scope survey and authorization prep.
C0-O runs in parallel as an org sidecar and must not take over C1-C4.
```

Protected surfaces remain closed unless the main Architect Supervisor issues a
separate authority decision:

```text
implementation, parser, TypeChecker, SemanticIR, assembler/.igapp changes,
CLI/API widening, profile discovery/defaulting/finalization, loader/report,
CompatibilityReport, receipts, signing, dispatch migration, RuntimeMachine,
Gate 3 widening, Ledger/TBackend, BiHistory, stream/OLAP, cache, production.
```

---

## Trusted Inputs

Initial read set:

```text
igniter-lang/AGENTS.md
igniter-lang/roles/architect-supervisor.md
igniter-lang/roles/history-curator.md
igniter-lang/roles/archive-form-expert.md
igniter-lang/roles/line-up-summarizer.md
igniter-lang/docs/cards/README.md
igniter-lang/docs/cards/S3/S3.md
igniter-lang/docs/current-status.md
igniter-lang/docs/agent-context.md
```

Current sidecar files:

```text
igniter-lang/docs/org/README.md
igniter-lang/docs/org/current-map.md
igniter-lang/docs/org/reports/
igniter-lang/docs/org/memory-contracts/
igniter-lang/docs/org/indexes/
```

---

## Implementation Code Orientation

Igniter-Lang compiler package:

```text
igniter-lang/lib/igniter_lang/parser.rb
igniter-lang/lib/igniter_lang/classifier.rb
igniter-lang/lib/igniter_lang/typechecker.rb
igniter-lang/lib/igniter_lang/semanticir_emitter.rb
igniter-lang/lib/igniter_lang/assembler.rb
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/temporal_executor.rb
igniter-lang/lib/igniter_lang/temporal_access_runtime.rb
```

Adjacent platform packages visible to org mapping, not sidecar write targets:

```text
packages/igniter-contracts/
packages/igniter-extensions/
packages/igniter-ledger/
packages/igniter-mcp-adapter/
packages/igniter-agents/
packages/igniter-ai/
packages/igniter-application/
```

Rule: the org sidecar may map these for orientation only. It must not edit
platform package code or open bridge work without explicit approval.

---

## Experiment Orientation

Observed experiment families:

```text
compiler_profile_*        PROP-036/038 profile identity and contract proofs
prop036_*                 bounded compiler profile source and CLI proof chain
prop037_*                 progression descriptor/readiness proof chain
temporal_*                temporal fragment, assembler, runtime, executor proofs
runtime_*                 smoke, compatibility, cache, report enforcement proofs
phase1_*                 Gate 3 Phase 1 live-read/audit/registry shapes
production_durable_*      bounded durable audit proof and deployment prep
contract_modifiers_*      PROP-031 modifiers proofs
assumptions_proof/        PROP-032 assumptions proof chain
pressure-specimens/       language pressure fixtures and external specimens
stage1_close_candidate/   Stage 1 close evidence
stage2_close_candidate/   Stage 2 close evidence
```

Proof/golden output patterns:

```text
*/out/*_summary.json
*/summary.json
*/golden/*.json
*/out/*.igapp/
*/out/*compilation_report.json
```

Org rule: do not rerun broad proof chains by default. Point agents to the named
summary/golden path from the active card or current-status map.

---

## Documentation Orientation

Observed 2026-05-17 docs density:

```text
docs/tracks/        400+ files, evidence layer
docs/discussions/   60+ files, pressure/review layer
docs/gates/         30+ files, authority decision layer
docs/proposals/     PROP documents and accepted archive
docs/cards/S3/      dispatch layer from R44 onward
docs/lineups/       compact summary layer
docs/archive/       cold history and snapshots
docs/dev/           governance, semantic maps, compiler direction
roles/              role profile authority
```

Layer rule:

```text
cards      -> what was planned
tracks     -> what was done/proved/discovered
gates      -> what is authorized or held
discussions-> pressure, not canon
lineups    -> compact memory handles
archive    -> cold history, read only when assigned
org        -> process/memory maps, not authority
```

---

## Return Report Rules

Return to the main Architect Supervisor only with:

```text
[Authority Risk]       active gate/proposal/status drift
[Context Risk]         agents forced into broad rereads or stale maps
[Process Insight]      reusable orchestration pattern worth adopting
[Decision Needed]      work requiring main Architect approval
[Stage Report]         compact periodic status of org-sidecar findings
```

Do not return every observation. Keep the sidecar quiet unless the finding can
change a main-lane decision or improve future agent throughput.

---

## Next Org Slices

Recommended follow-up order:

```text
1. operational-contract memory pilot for one role instance       done: Line Up Summarizer pilot
2. operational-contract memory pilot for second role instance    done: History Curator pilot
3. docs/code/experiment orientation index refinement             next
4. stage-level docs metabolism schedule review                   later
5. Line Up / History Curator / Archive/Form handoff boundary map later
```

Recommendation: continue, but stay narrow until the main lane asks for a
specific process or documentation decision.

Latest local sidecar signals:

```text
line-up-summarizer memory pilot:
  useful for preserving QA anchor, movement boundary, and return-report rules
  without changing role authority.

Line Up QA drift candidates:
  docs/lineups/stage2-compiler-package-spine.md
  docs/lineups/stage2-to-stage3-typed-switch-spine.md

No fix applied by org sidecar. Route to Line Up Summarizer cleanup if needed.

history-curator memory pilot:
  useful for preserving bounded source-set discipline, no-move/no-delete
  default, classification taxonomy, and movement/link preconditions.

operational memory adoption:
  two non-authority role pilots are now complete, but standardization still
  needs stale-memory behavior and a later standardization approval.

architect handoff:
  docs/org/reports/operational-memory-pilot-proposal-to-architect-v0.md
  proposes a bounded two-role pilot for Line Up Summarizer and History Curator.

prop038 implementation watch map:
  docs/org/indexes/prop038-implementation-surface-watch-map-v0.md
  captures the bounded validator extraction surface, prohibited compiler/report/
  runtime/public surfaces, proof parity obligations, and diagnostic/digest
  deferrals. Orientation only; authority remains in the R64 gate decision.

prop038 report integration boundary map:
  docs/org/indexes/prop038-report-integration-boundary-map-v0.md
  captures the dangerous boundary between accepted internal validation results
  and any future report-only compiler integration. Orientation only; report
  integration, compile refusal, and public API/CLI widening remain unauthorized.

prop038 report-only leakage watch:
  docs/org/indexes/prop038-report-only-leakage-watch-v0.md
  captures R67-specific checks for public-output leakage, refusal creep,
  persisted/golden mutation, provider exception semantics, and the
  `compiler_integrated=false` interpretation. Orientation only.

prop038 contract digest policy map:
  docs/org/indexes/prop038-contract-digest-policy-map-v0.md
  separates descriptor digest, finalization payload digest, contract digest,
  shape validation, recomputation, mismatch validation, canonicalization, and
  authority effects. Orientation only; digest authority remains closed unless
  later opened by Architect decision.

prop038 contract digest shape proof boundary:
  docs/org/indexes/prop038-contract-digest-shape-proof-boundary-map-v0.md
  captures R69 proof-local shape-policy boundaries: allowed proof outputs,
  forbidden live-code surfaces, shape-only vs recompute-match distinction,
  report-only/refusal boundaries, and candidate diagnostics. Orientation only.

prop038 contract digest recompute proof boundary:
  docs/org/indexes/prop038-contract-digest-recompute-proof-boundary-map-v0.md
  captures R70 proof-local canonicalization/recompute boundaries: candidate
  input material, excluded fields, forbidden ambient inputs, order-sensitive vs
  order-insensitive material, mismatch diagnostics, and non-authority surfaces.
  Orientation only.

prop038 contract digest report-only integration boundary:
  docs/org/indexes/prop038-contract-digest-report-only-integration-boundary-map-v0.md
  captures R71 proof-local report-only boundaries for the full
  `contract_digest_*` candidate vocabulary, including compiler outcome
  invariants, public/persisted leakage checks, and required
  `non_authorizations_preserved` traceability. Orientation only.

prop038 contract digest errata canon-sync boundary:
  docs/org/indexes/prop038-contract-digest-errata-canon-sync-boundary-map-v0.md
  captures R72 boundaries for PROP-038 errata/design authoring: accepted proof
  chain for design purposes, exact digest vocabulary, canonicalization and
  report-only text limits, still-closed surfaces, and C1/C2 review hazards.
  Orientation only.

architect decision:
  docs/org/reports/operational-memory-pilot-architect-approval-v0.md
  approves bounded pilot delegation to Org Architect Supervisor. Standardization
  across all roles remains unapproved.

pilot result:
  docs/org/reports/operational-contract-memory-two-role-pilot-result-v0.md
  two role-instance checks completed; verdict iterate / keep optional.

pilot dispatch:
  docs/org/indexes/operational-memory-live-pilot-cards-s3-r63-v0.md
  defines ORG-R63 = [C1-P1, C2-P1] -> C3-S for live role-shaped memory checks.

compiler blueprint:
  docs/org/indexes/compiler-code-and-experiment-map-v0.md
  maps production compiler code, profile proof families, runtime/audit proof
  families, proof outputs, and authority/evidence boundaries.
```
