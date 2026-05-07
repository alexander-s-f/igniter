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

## Stage 2 Round 4 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `runtime-temporal-access-node-loader-v0.md` | done | temporal_access_node evaluated via TemporalAccessRuntime in history+bihistory proofs |
| `compiler-result-report-boundary-v0.md` | done | lib/igniter_lang/compiler_result.rb + compilation_report.rb extracted; CLI proof PASS |
| `invariant-severity-parser-and-typechecker-ownership-v0.md` | done | Parser/TC spec (PINV-1..4 + TINV-1..3) authored; impl deferred; proof PASS |
| `stream-t-proof-v0.md` | done | stream_t_proof PASS: fold_stream bounded window → CORE fold; OOF-S1..5 |
| `stage2-round4-map-refresh-v0.md` | done | R4 map sync — this track |

## Stage 2 Round 3 Evidence (summary)

| Track | Status | Notes |
|-------|--------|-------|
| `option-encoding-normalization-v0.md` | done | Option[T] → `{kind,value}` canonical |
| `history-type-parser-acceptance-v0.md` | done | History[T] parser structured TypeRef PASS |
| `bihistory-parser-typechecker-axes-v0.md` | done | TypeChecker BiHistory axes PASS |
| `history-temporal-access-runtime-extraction-v0.md` | done | TemporalAccessRuntime::MemoryBackend shared |
| `compiler-diagnostics-library-boundary-v0.md` | done | lib/igniter_lang/diagnostics.rb extracted |
| `invariant-severity-proof-v0.md` | done | invariant_severity_proof PASS |
| `production-compiler-diagnostics-*.md` | done | Diagnostics module + extraction PASS |

---

## Suggested Next Track Shapes

| Candidate | Purpose | Role |
|-----------|---------|------|
| `extract-parser-module-v0` | Move parser to lib/igniter_lang/parser.rb; preserve OOF + stage1 proofs | Research Agent |
| `stream-parser-classifier-boundary-v0` | Parser + classifier for stream T (OOF-S1..S5) | Compiler/Grammar Expert |
| `production-runtime-temporal-access-integration-v0` | TBackend adapters + capability checks for production RuntimeMachine | Research Agent |
| `olap-point-proof-v0` | First proof for PROP-024 OLAPPoint[T,Dims] | Research Agent |

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
