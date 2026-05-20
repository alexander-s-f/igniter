# Igniter-Lang Inbox

Status: active intake queue
Owner: [Architect Supervisor / Codex]
Last updated: 2026-05-10

---

## Purpose

`docs/inbox/` is a temporary landing area for useful incoming material:

- external agent reports
- cross-package analysis
- user-requested research
- raw review signals
- architecture observations that are not yet routed

Inbox documents are **not canon**. They become useful only after triage.

No inbox document may remain without a disposition.

---

## Lifecycle

```text
incoming document
  -> triage
  -> one disposition:
       promote to track
       promote to proposal
       promote to meta-proposal
       promote to gate
       promote to dev/spec doc
       route to discussion/review
       archive as source material
       reject / supersede
  -> link the destination
  -> remove from active inbox at the next cleanup point if no longer needed
```

---

## Disposition Statuses

| Status | Meaning |
|--------|---------|
| `new` | Landed but not triaged yet. Should not survive a round close. |
| `triaged` | Read and classified; destination chosen, not yet acted on. |
| `promoted-track` | Converted into a track or assigned as source for a track. |
| `promoted-proposal` | Converted into or feeding a formal PROP. |
| `promoted-meta` | Converted into governance/meta proposal material. |
| `promoted-gate` | Converted into a gate request/decision input. |
| `promoted-dev-doc` | Crystallized into `docs/dev/`, `docs/spec/`, or another living doc. |
| `discussion` | Routed to `docs/discussions/` or `docs/reviews/` for pressure/debate. |
| `archived` | Preserved as archaeology/source material; no active work. |
| `rejected` | Explicitly not adopted; keep only if useful as negative evidence. |
| `superseded` | Replaced by a newer document; link the replacement. |

---

## Routing Rules

| Incoming material | Route |
|-------------------|-------|
| Language semantics / syntax / type-system change | `docs/proposals/PROP-*` after governance approval |
| Governance / process / stage policy | `docs/meta-proposals/` or `docs/gates/` |
| Architecture direction / implementation shape | `docs/dev/` plus a track record |
| Debate / pressure / external critique | `docs/discussions/` or `docs/reviews/` |
| Evidence from implementation or proof | `docs/tracks/` with command/result references |
| Historical but valuable material | `docs/archive/history/` or a stage snapshot |
| Duplicate or stale material | mark `superseded` or `rejected` with reason |

---

## Active Inbox Index

| File | Status | Owner | Destination / Next Action |
|------|--------|-------|---------------------------|
| [profile-baseline-pack-pattern-analysis.md](profile-baseline-pack-pattern-analysis.md) | `promoted-dev-doc` + `promoted-track` | Architect Supervisor | Direction crystallized in `docs/dev/compiler-profile-architecture-direction.md`; track record in `docs/tracks/compiler-profile-architecture-direction-v0.md`; next no-code research card: `compiler-pack-boundary-report-v0` |
| [runtime-loop-semantics-exploration.md](runtime-loop-semantics-exploration.md) | `promoted-track` | [Igniter-Lang Research Agent] | Proof-backed track record in `docs/tracks/external-progression-runtime-model-v0.md`; proof in `experiments/external_progression_runtime_model/`; next action: Architect decision on formal progression semantics proposal |
| [sparkcrm-ledger-igniter-applicability-analysis-2026-05-20.md](sparkcrm-ledger-igniter-applicability-analysis-2026-05-20.md) | `promoted-track` / active applied-pressure source | [Igniter-Lang Bridge Agent] | Routed by [r86-spec-sync-and-spark-applicability-routing-decision-v0](../gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md); next owner/route: `sparkcrm-contractable-shadowing-pilot-scope-v0`; not canon, not implementation authority, not Spark CRM production authority |

---

## Cleanup Rule

At round close or stage close:

1. Every `new` item must be triaged.
2. Every processed item must have a destination link.
3. If the source is no longer needed in active context, move or copy it into
   archive/history and remove it from active inbox.
4. If the source remains useful for an active card, keep it in inbox but mark
   the exact card/track that owns the next action.
