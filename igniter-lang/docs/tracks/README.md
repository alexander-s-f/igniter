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

## Stage 2 Round 3 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `option-encoding-normalization-v0.md` | done | Option[T] → `{kind,value}` canonical shape; history_type_proof PASS |
| `history-type-parser-acceptance-v0.md` | done | Parser structured TypeRef for generic types; History[T] parser PASS |
| `bihistory-parser-typechecker-axes-v0.md` | done | TypeChecker BiHistory axis checks (4 classified cases); typechecker_proof PASS |
| `history-temporal-access-runtime-extraction-v0.md` | done | TemporalAccessRuntime::MemoryBackend shared; history+bihistory PASS |
| `production-compiler-diagnostics-implementation-v0.md` | done | ProductionCompilerCLI::Diagnostics module added; CLI proof PASS |
| `production-compiler-diagnostics-extraction-v0.md` | done | Diagnostics isolated from CLI orchestration; CLI proof PASS |
| `compiler-diagnostics-library-boundary-v0.md` | done | lib/igniter_lang/diagnostics.rb extracted; library_require ok |
| `invariant-severity-proof-v0.md` | done | invariant_severity_proof PASS; parser/TC ownership deferred |
| `stage2-round3-map-refresh-v0.md` | done | R3 map sync — this track |

## Stage 2 Round 2 Evidence (summary)

| Track | Status | Notes |
|-------|--------|-------|
| `stage2-map-refresh-v0.md` | done | Stage 2 map refresh; current-status compacted |
| `parser-oof-hardening-stage2-proof-v0.md` | done | PROP-026 parser OOF hardening PASS |
| `production-compiler-cli-wrapper-v0.md` | done | CLI `bin/igniter-lang compile` proof PASS |
| `production-compiler-module-extraction-map-v0.md` | done | Extraction map; no code moved yet |
| `sparkcrm-bihistory-fixture-v0.md` | done | BiHistory fixture PASS (OOF-BT1..4) |
| `temporal-option-and-bihistory-shape-v0.md` | done | Option[T] + BiHistory canonical shape spec |

---

## Suggested Next Track Shapes

| Candidate | Purpose | Role |
|-----------|---------|------|
| `runtime-temporal-access-node-loader-v0` | Map SemanticIR temporal_access_node onto TemporalAccessRuntime API | Research Agent |
| `compiler-result-report-boundary-v0` | Extract CompilerResult + CompilationReport helpers into lib/ | Research Agent |
| `invariant-severity-parser-and-typechecker-ownership-v0` | Parser syntax + TypeChecker OOF codes for severity levels | Compiler/Grammar Expert |
| `stream-t-proof-v0` | First proof for PROP-023 stream T | Research Agent |

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
