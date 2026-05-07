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

## Stage 2 Round 6 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `extract-classifier-module-v0.md` | done | lib/igniter_lang/classifier.rb extracted; classifier+golden PASS; CLI PASS |
| `stream-classifier-escape-propagation-v0.md` | done | SC-1/2/3 ESCAPE in classifier; source_to_semanticir goldens 6→9 |
| `runtime-machine-temporal-access-hook-v0.md` | done | RuntimeMachineHook spec + smoke in TAR lib; history+bihistory PASS |
| `olap-point-parser-typechecker-boundary-v0.md` | done | Grammar spec: dims_record, OOF-O1..5 ownership; olap_point_proof 12+9=21 PASS; impl deferred |
| `stage2-round6-map-refresh-v0.md` | done | R6 map sync — this track |

## Stage 2 Round 5 Evidence (summary)

| Track | Status | Notes |
|-------|--------|-------|
| `extract-parser-module-v0.md` | done | lib/igniter_lang/parser.rb + stream keywords |
| `stream-parser-classifier-boundary-v0.md` | done | stream/fold_stream in parser.rb; stream_t_proof PASS |
| `production-runtime-temporal-access-integration-v0.md` | done | temporal_access_runtime.rb extracted |
| `olap-point-proof-v0.md` | done | olap_point_proof PASS |

---

## lib/igniter_lang/ — Current State (6 libs)

```text
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5) — parser + stream/fold_stream keywords
temporal_access_runtime.rb (R5/R6) — MemoryBackend + capability helper + RuntimeMachineHook spec
classifier.rb             (R6) — ParsedProgram → ClassifiedProgram boundary
```

---

## Suggested Next Track Shapes

| Candidate | Purpose | Role |
|-----------|---------|------|
| `extract-typechecker-module-v0` | Move TypeChecker to lib/igniter_lang/typechecker.rb | Research Agent |
| `olap-point-parser-implementation-v0` | Add olap_point keyword + dims_record to parser.rb | Research Agent |
| `stream-oof-s2-classifier-v0` | OOF-S2 missing-window classifier rule | Compiler/Grammar Expert |
| `runtime-machine-temporal-access-hook-proof-v0` | Wire RuntimeMachineHook into HistoryRuntimeMachine proof | Research Agent |

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
