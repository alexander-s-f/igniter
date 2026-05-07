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

## lib/igniter_lang/ — Current State (7 libs)

```text
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5/R7) — parser + stream + olap_point/dims_record
temporal_access_runtime.rb (R5/R6/R7) — MemoryBackend + RuntimeMachineHook (wired R7)
classifier.rb             (R6/R7) — ParsedProgram→ClassifiedProgram; OOF-S2
typechecker.rb            (R7) — TypedProgram boundary
```

---

## Suggested Next Track Shapes

| Candidate | Purpose | Role |
|-----------|---------|------|
| `extract-semanticir-emitter-module-v0` | Move SemanticIR emitter to lib/igniter_lang/semanticir_emitter.rb | Research Agent |
| `olap-point-typechecker-semanticir-v0` | OOF-O2..O5 + olap_access_node lowering into SemanticIR | Compiler/Grammar Expert |
| `stream-oof-s3-typechecker-v0` | OOF-S3 ESCAPE-in-fold-fn TypeChecker rule | Compiler/Grammar Expert |
| `production-runtime-machine-temporal-access-integration-v0` | Wire RuntimeMachineHook into production RM; TBackend adapter | Research Agent |

---

## Handoff Template

```text
[Role]
Track:
Card:
Status:

[D] Decisions
[S] Shipped / Signals
[T] Tests / Proofs
[R] Risks / Recommendations
[Next] Suggested next slice
```
