# PROP-032 Assumptions Spec Sync and Temporal Specimen Disposition v0

Card: S3-R37-C1-P
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: prop032-assumptions-spec-sync-and-temporal-specimen-disposition-v0
Date: 2026-05-11
Status: done

---

## Goal

Close R36 pressure follow-ups P-50 and P-52 without creating new language
semantics and without authorizing PROP-033 or runtime receipt behavior.

## Inputs Read

- `docs/gates/prop032-assumptions-experiment-pass-decision-v0.md`
- `docs/discussions/r36-deployment-prop032-prop036-prop037-mundane-pressure-v0.md`
- `docs/spec/ch2-source-surface.md`
- `docs/dev/semantic-governance-heat-map.md`
- `experiments/pressure-specimens/temporal-audit-pressure-v0/`
- `docs/current-status.md`

## Changes Applied

| Surface | Change | Boundary |
|---------|--------|----------|
| Ch2 source grammar | Added bounded PROP-032 grammar entries for top-level `assumptions {}`, named `assumption NAME {}`, body-level `uses assumptions NAME`, and parsed-only `output ... evidence [...]` | Compiler experiment-pass only; PROP-033 validation excluded |
| Ch2 ParsedProgram notes | Added PROP-032 parsed deltas: top-level `assumptions`, `uses_assumptions` body nodes, parsed-only `evidence` lists | Runtime receipt propagation excluded |
| Heat Map Domain 2 | Updated assumptions rows from proposal-only to compiler experiment-pass for Parse/Class/TC/SIR with golden anchors | Runtime remains red; debt becomes `impl/gov` |
| Temporal audit specimens | Added root disposition README marking the bundle non-canonical and not implementation evidence | Signals may route to future gated work only |
| Active indexes/status | Updated current status and tracks index so P-50/P-52 no longer appear open | P-51 deployment follow-up remains open |

## P-50 / P-52 Closure Answer

| Follow-up | Result | Why |
|-----------|--------|-----|
| P-50 Ch2 grammar/Heat Map sync | closed | Ch2 now records the bounded PROP-032 source surface, and Heat Map Domain 2 reflects S3-R36-C2-A experiment-pass compiler status |
| P-52 temporal audit specimen disposition | closed | The pressure bundle now has explicit non-canonical/non-evidence disposition, extracted signals, and gated future-routing notes |

## Remaining Doc Debts

- PROP-033 remains the route for evidence-list validation; this card does not
  validate evidence membership or authorize runtime receipts.
- Runtime `assumption_refs`, runtime assumption-value injection, cross-module
  assumptions, constraints/form/effect-surface behavior, and production
  RuntimeMachine behavior remain excluded.
- P-51 restricted durable-audit deployment implementation remains open.
- The full Stage 3 language regression matrix remains a separate recommended
  follow-up.
