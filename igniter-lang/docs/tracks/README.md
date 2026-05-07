# Igniter-Lang Tracks

Status: active index
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-07

---

## Purpose

Track documents are slice evidence, not the global project log.

Use this directory when a role needs to prove, pressure-test, or map a bounded
question. Completed tracks remain as evidence, but new agents should start from
`docs/README.md`, `docs/operating-model.md`, `docs/current-status.md`, and the
assigned track only.

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

## Stage 2 Round 2 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `stage2-map-refresh-v0.md` | done | Stage 2 map refresh; current-status compacted to 80 lines |
| `parser-oof-hardening-stage2-proof-v0.md` | done | PROP-026 parser OOF hardening PASS |
| `production-compiler-cli-wrapper-v0.md` | done | CLI `bin/igniter-lang compile` proof PASS (9 checks) |
| `production-compiler-module-extraction-map-v0.md` | done | Extraction map for production compiler; no code moved yet |
| `history-type-proof-planning-v0.md` | done | Planning for History[T] proof path |
| `canonical-stdlib-registry-runtime-v0.md` | done | Runtime-visible stdlib registry direction |
| `sparkcrm-history-pressure-v0.md` | done | Pressure map for Spark CRM bitemporal scenarios |
| `sparkcrm-bihistory-fixture-pressure-v0.md` | done | Pressure spec for BiHistory fixture |
| `temporal-option-and-bihistory-shape-v0.md` | done | Option[T] + BiHistory canonical shape spec |
| `sparkcrm-bihistory-fixture-v0.md` | done | BiHistory fixture PASS (OOF-BT1..4 + correction proof) |
| `stage2-round2-map-refresh-v0.md` | done | R2 map sync — this track |

---

## Suggested Next Track Shapes

| Candidate | Purpose | Role |
|-----------|---------|------|
| `option-encoding-normalization-v0` | Normalize Option[T] to `{kind:"some"/"none"}` in history proofs | Research Agent |
| `bihistory-parser-typechecker-axes-v0` | Parser/typechecker for BiHistory temporal axes | Compiler/Grammar Expert |
| `extract-canonical-json-diagnostics-v0` | Extract `CanonicalJSON`, `DiagnosticEntry`, `CompilationReport` into shared modules | Research Agent |
| `invariant-severity-proof-v0` | First proof for PROP-025 severity levels | Research Agent |

---

## Handoff Template

```text
[Role]
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

Keep the handoff compact. The track body may contain detailed evidence; the
handoff should tell the supervisor what changed and what to do next.
