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

## Recent Stage 2 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `production-compiler-diagnostics-implementation-v0.md` | done | Canonical CLI diagnostics implemented; `igapp_path`, categories, stages, warnings |
| `history-type-point-access-proof-v0.md` | done | Executable `History[Integer]` point proof; OOF-H1 negative; parser gap explicit |
| `temporal-option-and-bihistory-shape-v0.md` | done | Canonical `Option[T]`, `history_at`, `bihistory_at`, OOF-BT rules |
| `sparkcrm-bihistory-fixture-pressure-v0.md` | done | SparkCRM bitemporal availability correction fixture shape |
| `production-compiler-cli-wrapper-v0.md` | done | CLI wrapper proof for `bin/igniter-lang compile` |
| `production-compiler-module-extraction-map-v0.md` | done | Extraction map for production compiler package |
| `history-type-proof-planning-v0.md` | done | Planning slice for `History[T]` proof path |
| `parser-oof-hardening-stage2-proof-v0.md` | done | Parser OOF hardening evidence |
| `canonical-stdlib-registry-runtime-v0.md` | done | Runtime-visible stdlib registry direction |

---

## Suggested Next Track Shapes

These are short names for future supervisor cards, not active assignments by
themselves.

| Candidate | Purpose |
|-----------|---------|
| `option-encoding-normalization-v0` | Normalize `history_type_proof` goldens to canonical `{ kind, value }` Option shape |
| `history-type-parser-acceptance-v0` | Make parser accept the current `History[T]` fixture instead of hand-authored ParsedProgram |
| `history-type-runtime-node-extraction-v0` | Extract proof-local `temporal_access_node` runtime support toward production RuntimeMachine |
| `sparkcrm-bihistory-fixture-v0` | Executable bitemporal availability correction proof with OOF-BT diagnostics |
| `production-compiler-diagnostics-extraction-v0` | Move `ProductionCompilerCLI::Diagnostics` to a separate reusable file |

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
