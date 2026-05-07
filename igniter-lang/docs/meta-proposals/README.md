# Meta-Proposals Index

Maintained by: `[Igniter-Lang Meta Expert]`
Status: active governance index
Last updated: 2026-05-07

---

## Active Governance (Stage 2)

Documents that govern active Stage 2 work. New agents should read the docs map
and operating model first, then use this index for governance context.

| Document | Status | Purpose |
|----------|--------|---------|
| [META-EXPERT-008](META-EXPERT-008-stage2-implementation-governance-v0.md) | **active** | Stage 2 governance: scoreboard, dependency order, done criteria, agent routing, close criteria |
| [META-EXPERT-008.1](META-EXPERT-008.1-prop-numbering-audit-v0.md) | decision | PROP numbering audit: no file moves needed; canonical map PROP-026=parser OOF hardening, PROP-027=production compiler diagnostics; new Stage 2 authors start from PROP-028 |
| [META-EXPERT-008.2](META-EXPERT-008.2-fresh-language-model-report-v0.md) | proposal | Fresh language model report: LanguageContract/RuntimeContract composition, general-purpose profiles, OSINT traceability, mesh, FFI, modeling, and next-slice priorities |
| [META-EXPERT-008.3](META-EXPERT-008.3-project-archaeology-slice-index-v0.md) | proposal | Project archaeology slice index: maps Igniter/Igniter-Lang history into bounded A00..A17 consolidation slices |
| [META-EXPERT-008.4](META-EXPERT-008.4-origin-temporal-concordance-v0.md) | proposal | Origin-to-current-canon concordance for A01/A05: formal identities, SIR, grammar discipline, temporal/History/BiHistory/OLAP/Stream signals |
| [META-EXPERT-008.5](META-EXPERT-008.5-runtime-ledger-mesh-concordance-v0.md) | proposal | Runtime/ledger/mesh concordance for A04/A11/A12: RuntimeMachine, TBackend, Ledger, Durable Model, MCP, cluster, mesh signals |
| [META-EXPERT-007](META-EXPERT-007-stage1-close-governance-v0.md) | decision | Stage 1 close governance: verdict CLOSE WITH DEFERRED GAP; close criteria formally satisfied; 3 deferred gaps; post-close action list |
| [META-EXPERT-007.1](META-EXPERT-007.1-stage1-close-snapshot-plan-v0.md) | done | Post-close doc transition: snapshot, PROP freeze list, naming collision fix, file moves |
| [META-EXPERT-003](META-EXPERT-003-stage1-implementation-governance-v0.md) | done | Stage 1 scoreboard, agent routing policy, done criteria per pass, next 3 slices |
| [META-EXPERT-004](META-EXPERT-004-stage1-scoreboard-reconciliation-v0.md) | done | Reconciles PROP-019.1 errata: oof_log removed, golden file migration gate, assembler unblock path |

---

## Language Model (completed decisions)

Documents that codified the language model revision. Read before authoring new PROPs.

| Document | Status | Purpose |
|----------|--------|---------|
| [META-EXPERT-006](META-EXPERT-006-language-model-revision-v0.md) | decision | Clean-slate language model revision: Stage 2 type system (History[T]/BiHistory/OLAPPoint/stream T/invariant severity/unit types); validates all 12 buried ideas; 5 Q&A decisions recorded |
| [META-EXPERT-005](META-EXPERT-005-project-history-archaeology.md) | done | Full project archaeology: origin story, 12 buried ideas, 5 formal identities, domain validation (science/robotics/space/medicine) |

---

## Strategic Foundation (historical)

Documents that established the overall direction. Do not modify.

| Document | Status | Purpose |
|----------|--------|---------|
| [META-EXPERT-001](META-EXPERT-001-strategic-analysis-report.md) | done | Strategic analysis, domain insights, OSINT/agents/science/ERP directions |
| [META-EXPERT-002](META-EXPERT-002-compiler-frontier-prioritization-v0.md) | done | Compiler frontier: Stage 1 milestone, P-1..P-5 priorities, deferral list |

---

## Write Rules (Stage 1 governance)

```text
[Meta Expert]    → writes to this directory only
                 → updates current-status.md scoreboard
                 → does not start new PROP work during Stage 1

[Research Agent] → reports to current-status.md (not new track docs)
                 → routes to Meta Expert for blocked decisions

[Compiler Expert]→ writes to proposals/ only
                 → scope: Stage 1 pipeline PROPs (020, 021 refinement)
                 → Stage 2 PROPs (022..025) authored, not expanded

Do not:
  ❌ Start new theoretical research tracks
  ❌ Expand Stage 2 PROPs before Stage 1 closes
  ❌ Create new meta-proposals unless a major governance decision is required
```

---

## Stage 2 PROP Reference (authored, not yet active)

| PROP | Status | Summary |
|------|--------|---------|
| PROP-022 | authored | History[T]/BiHistory[T] type constructors |
| PROP-023 | authored | stream T surface form + fold_stream |
| PROP-024 | authored | OLAPPoint[T, Dims] primitive |
| PROP-025 | authored | Invariant severity levels |

Implementation of these PROPs begins **after Stage 1 closes**.

---

## Snapshot Reference

Full pre-crystallization state (all tracks, bridge notes, full current-status):
→ `docs/archive/snapshots/2026-05-06-stage1-pre-crystallization/meta-proposals/`
