# Igniter-Lang Tracks

Status: active index
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-07

---

## Purpose

Track documents are slice evidence, not the global project log.

New agents should start from `docs/README.md`, `docs/operating-model.md`,
`docs/current-status.md`, and the assigned track only.

---

## Current Navigation

| Need | Start here |
|------|------------|
| Current language state | `../current-status.md` |
| Process / handoff rules | `../operating-model.md` |
| Canonical spec | `../spec/` |
| Proposal queue | `../proposals/README.md` |
| Historical archaeology | `../archive/` or git history |

---

## Stage 2 Round 10 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `compiler-orchestrator-v0.md` | done | lib/igniter_lang/compiler_orchestrator.rb extracted |
| `stream-semanticir-surface-lowering-v0.md` | done | stream SemanticIR lowering PASS; stream_t_proof PASS |
| `production-tbackend-adapter-fixture-v0.md` | done | proof-local AdapterRegistry + CompatibilityReport persistence |
| `invariant-severity-parser-impl-v0.md` | done | PINV-1..4 + TINV-1..3 PASS; +3 typechecker cases |
| `stage2-round10-map-and-role-profile-refresh-v0.md` | done | R10 map sync — this track |

## Stage 2 Round 9 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `extract-assembler-module-v0.md` | done | lib/igniter_lang/assembler.rb extracted; Stage 1 goldens PASS; CLI PASS |
| `production-tbackend-adapter-shape-v0.md` | done | Docs-only: TBackend adapter shape spec; no code changes |
| `semanticir-stage2-surface-lowering-v0.md` | done | OLAP SemanticIR lowering in emitter; olap_point_proof PASS; stage1 PASS |
| `stage2-round9-map-refresh-v0.md` | done | R9 map sync — this track |

## Stage 2 Round 8 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `extract-semanticir-emitter-module-v0.md` | done | `lib/igniter_lang/semanticir_emitter.rb` extracted; source→SemanticIR golden PASS |
| `olap-point-typechecker-semanticir-v0.md` | done | OOF-O2..O5; `olap_access_node`; explicit `dims_record`; OLAP proof PASS |
| `stream-oof-s3-typechecker-v0.md` | done | ESCAPE-in-fold TypeChecker rule; stream OOF-S1..S5 all proven |
| `production-runtime-machine-temporal-access-integration-v0.md` | done | RuntimeMachine load/evaluate proof-local hook integration; TBackend adapter still future |

## Stage 2 Round 7 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `extract-typechecker-module-v0.md` | done | lib/igniter_lang/typechecker.rb extracted; typechecker_proof + CLI PASS |
| `stream-oof-s2-classifier-v0.md` | done | OOF-S2 missing-window classifier rule; golden PASS; semanticir golden PASS |
| `runtime-machine-temporal-access-hook-proof-v0.md` | done | RuntimeMachineHook wired in history+bihistory proofs; both PASS |
| `olap-point-parser-implementation-v0.md` | done | revenue_point.ig parses live; olap_points[]; dims_record; parser spec 61 PASS |
| `stage2-round7-map-refresh-v0.md` | done | R7 map sync — this track |

## Stage 2 Round 6 Evidence (summary)

| Track | Status | Notes |
|-------|--------|-------|
| `extract-classifier-module-v0.md` | done | lib/igniter_lang/classifier.rb extracted |
| `stream-classifier-escape-propagation-v0.md` | done | SC-1/2/3 ESCAPE propagation; semanticir goldens 6→9 |
| `runtime-machine-temporal-access-hook-v0.md` | done | RuntimeMachineHook spec + smoke |
| `olap-point-parser-typechecker-boundary-v0.md` | done | Grammar spec: dims_record, OOF-O1..5; olap_point_proof 21 PASS |

---

## lib/igniter_lang/ — Current State (10 libs)

```text
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5/R7/R10) — parser + stream + olap_point + invariant
temporal_access_runtime.rb (R5–R7) — MemoryBackend + RuntimeMachineHook
classifier.rb             (R6/R7) — ParsedProgram→ClassifiedProgram; OOF-S1/2
typechecker.rb            (R7/R8/R10) — TypedProgram boundary; stream OOF-S3; OLAP OOF-O2..O5; TINV-1..3
semanticir_emitter.rb     (R8/R9/R10) — SemanticIR emitter; OLAP/stream lowering added
assembler.rb              (R9) — .igapp/ assembler boundary
compiler_orchestrator.rb  (R10) — NEW; compiler pass orchestration spine
```

---

## Suggested Next Track Shapes

| Candidate | Purpose | Role |
|-----------|---------|------|
| `packageable-compiler-api-v0` | Wire stable Ruby API over CompilerOrchestrator | Research Agent |
| `invariant-severity-semanticir-lowering-v0` | invariant_node / invariant_violation_node emission | Compiler/Grammar Expert |

---

## Handoff Template

```text
Card:
Agent: [Igniter-Lang <Agent Name>]
Role: <role-profile-id>
Track:
Status:

[D] Decisions
- ...

[S] Shipped / Signals
- ...

[T] Tests / Proofs
- ...

[R] Risks / Recommendations
- ...

[Next] Suggested next slice
- ...
```
