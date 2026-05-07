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

## Stage 2 Round 5 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `extract-parser-module-v0.md` | done | lib/igniter_lang/parser.rb extracted; 61 specs PASS; CLI PASS |
| `stream-parser-classifier-boundary-v0.md` | done | stream/fold_stream keywords in parser.rb; stream_t_proof PASS; classifier SC-1..3 next |
| `production-runtime-temporal-access-integration-v0.md` | done | lib/igniter_lang/temporal_access_runtime.rb extracted; capability helper; history+bihistory PASS |
| `olap-point-proof-v0.md` | done | olap_point_proof PASS: point access + rollup + OOF-O1..3 |
| `stage2-round5-map-refresh-v0.md` | done | R5 map sync — this track |

## Stage 2 Round 4 Evidence (summary)

| Track | Status | Notes |
|-------|--------|-------|
| `runtime-temporal-access-node-loader-v0.md` | done | temporal_access_node evaluated via TemporalAccessRuntime |
| `compiler-result-report-boundary-v0.md` | done | compiler_result.rb + compilation_report.rb extracted |
| `invariant-severity-parser-and-typechecker-ownership-v0.md` | done | Parser/TC spec authored; proof PASS |
| `stream-t-proof-v0.md` | done | stream_t_proof PASS: fold_stream bounded window → CORE |

---

## lib/igniter_lang/ — Current State

```text
diagnostics.rb           (R3) — CompilationReport diagnostics helpers
compiler_result.rb       (R4) — CompilerResult status/stages
compilation_report.rb    (R4) — CompilationReport ref/path helpers
parser.rb                (R5) — Full parser + stream/fold_stream keywords
temporal_access_runtime.rb (R5) — TemporalAccessRuntime::MemoryBackend + capability helper
```

---

## Suggested Next Track Shapes

| Candidate | Purpose | Role |
|-----------|---------|------|
| `extract-classifier-module-v0` | Move classifier to lib/igniter_lang/classifier.rb | Research Agent |
| `stream-classifier-escape-propagation-v0` | SC-1..3 ESCAPE rules for stream T | Compiler/Grammar Expert |
| `olap-point-parser-typechecker-boundary-v0` | Grammar surface + TypeChecker OOF-O for OLAPPoint | Compiler/Grammar Expert |
| `runtime-machine-temporal-access-hook-v0` | Resolver hook in RuntimeMachine; TBackend capability checks | Research Agent |

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
