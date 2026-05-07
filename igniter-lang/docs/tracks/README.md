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
| `extract-canonical-json-diagnostics-v0` | Move CLI diagnostics into reusable compiler package code |
| `extract-parser-module-v0` | Create production parser module without changing semantics |
| `history-type-proof-v0` | Turn planning for `History[T]` into executable proof |
| `stage2-map-refresh-v0` | Refresh current-status/spec coverage after a major agent cycle |

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

