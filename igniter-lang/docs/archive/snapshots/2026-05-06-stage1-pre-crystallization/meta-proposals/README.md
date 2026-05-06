# Igniter-Lang Meta Proposals

Status: active index
Role: `[Igniter-Lang Meta Expert]`
Supervisor: `[Architect Supervisor / Codex]`

## Purpose

Meta-proposals are strategic documents that guide the language development by:

- identifying gaps and blind spots in the current specification
- prioritizing next work across all operational roles
- resolving cross-cutting design questions
- analyzing competitive positioning and paradigm claims
- producing actionable requests for PROP-* formalization, proofs, and bridges

Meta-proposals do not replace `docs/proposals/` (formal PROP-* documents owned
by `[Igniter-Lang Compiler/Grammar Expert]`). They inform and direct them.

## Relationship to Other Document Types

```text
meta-proposals/   → strategic: what to build, why, in what order
proposals/        → formal: how to build it (grammar, types, semantics)
tracks/           → practical: proof that it works (fixtures, experiments)
bridge/           → integration: carry it to platform packages
```

## Active Meta Proposals

| Document | Status | Purpose |
|----------|--------|---------|
| [META-EXPERT-001-strategic-analysis-report.md](META-EXPERT-001-strategic-analysis-report.md) | done | Full specification analysis: paradigm positioning, gap analysis, 5-domain coverage, top-10 recommendations |
| [META-EXPERT-002-compiler-frontier-prioritization-v0.md](META-EXPERT-002-compiler-frontier-prioritization-v0.md) | done | Compiler frontier: Stage 1 milestone, P-1..P-5 priorities, deferral list, PROP-018/019 requests |
| [META-EXPERT-003-stage1-implementation-governance-v0.md](META-EXPERT-003-stage1-implementation-governance-v0.md) | done | Stage 1 scoreboard, agent routing policy, done criteria per pass, next 3 slices |
| [META-EXPERT-004-stage1-scoreboard-reconciliation-v0.md](META-EXPERT-004-stage1-scoreboard-reconciliation-v0.md) | done | Reconciles PROP-019.1 errata: oof_log removed, golden file migration gate, assembler unblock path |
| [META-EXPERT-005-project-history-archaeology.md](META-EXPERT-005-project-history-archaeology.md) | done | Full project archaeology: origin story, legacy packages, 12 buried ideas, theoretical foundations (5 formal identities), domain validation (science/robotics/space/medicine), stage map |
| [META-EXPERT-006-language-model-revision-v0.md](META-EXPERT-006-language-model-revision-v0.md) | proposal | Clean-slate language model revision: History[T]/BiHistory/OLAPPoint/stream T/invariant severity/unit types/deadline contracts; validates all 12 buried ideas; 5 open questions |

## Write Rules

- Only `[Igniter-Lang Meta Expert]` or `[Architect Supervisor / Codex]` may
  author documents here.
- Each document should identify affected neighbors and requested follow-up
  actions.
- Meta-proposals do not create formal language rules — they request them from
  `[Igniter-Lang Compiler/Grammar Expert]`.
