# Line Up: Stage 2 Proof Surface Spine

Status: active memory card
Source:
- `igniter-lang/docs/tracks/history-type-proof-v0.md`
- `igniter-lang/docs/tracks/stream-t-proof-v0.md`
- `igniter-lang/docs/tracks/olap-point-proof-v0.md`
- `igniter-lang/docs/tracks/invariant-severity-proof-v0.md`
- `igniter-lang/docs/tracks/parser-oof-hardening-stage2-proof-v0.md`
- `igniter-lang/docs/tracks/semanticir-stage2-surface-lowering-v0.md`
- `igniter-lang/docs/tracks/runtime-machine-temporal-access-hook-proof-v0.md`
Prepared by: `[Igniter-Lang Line Up Summarizer]`
Date: 2026-05-12
Disposition input: `active_reference`

## One-Line Claim

The Stage 2 proof-spine tracks established proof-local coverage for temporal,
stream, OLAP, invariant, parser OOF, SemanticIR lowering, and runtime temporal
hook surfaces that Stage 3 later builds on.

## Why It Matters

Future agents should not need seven old proof docs by default. This Line Up
preserves the evidence map and routes exact proof inspection back to the source
tracks, which remain authoritative for exact proof logs.

## Key Signals

| Surface | Proof signal |
| --- | --- |
| `History[T]` | `History[Integer]` point access with explicit `as_of`; missing `as_of` routes to `OOF-H1` |
| `stream T` | bounded count window, `fold_stream`, finite replay output, open-live waits; negatives include `OOF-S1`, `OOF-S2`, `OOF-S4` |
| `OLAPPoint[T,Dims]` | typed dimensions, deterministic point access, local rollup; negatives include `OOF-O-T1`, `OOF-O-T2`, `OOF-O3` |
| Invariant severity | `error`, `warn`, `soft`, and `metric` proof-local runtime/report outcomes |
| Parser OOF hardening | syntax-owned `OOF-P2`, `OOF-DM3`, `OOF-PG1`, `OOF-PG2`, `OOF-PG3`, `OOF-PG5`; semantic OOF stays later-pass owned |
| SemanticIR lowering | `emit_typed(typed_program)` boundary and OLAP `olap_access_node` lowering; parsed emitter kept stable |
| Runtime temporal hook | valid-time `history_read` and bitemporal `bihistory_read` paths via `RuntimeMachineHook`; production RuntimeMachine integration remained future work |

## Canon / History / Research / Value

- Canon source: current spec, CSM, accepted proposals, and current-status.
- Active reference: exact proof tracks when debugging provenance.
- Historical value: proof progression from hand-authored fixtures toward
  extracted compiler/runtime boundaries.
- Research/proof-local: several fixtures intentionally did not authorize parser
  syntax, production runtime binding, production stream adapters, or distributed
  OLAP execution.

## Current Home

All source tracks remain in `igniter-lang/docs/tracks/`. No source file moved or
deleted.

## Links To Keep

- `igniter-lang/experiments/history_type_proof/history_type_proof_summary.json`
- `igniter-lang/experiments/stream_t_proof/summary.json`
- `igniter-lang/experiments/olap_point_proof/summary.json`
- `igniter-lang/experiments/invariant_severity_proof/summary.json`
- `igniter-lang/experiments/parser_oof_hardening_stage2_proof/parser_oof_hardening_stage2_proof.json`
- `igniter-lang/docs/tracks/runtime-machine-temporal-access-hook-proof-v0.md`

## Safe To Archive?

Recommended disposition: `active_reference` now, `public_archive` candidate
after Archive/Form verification and History Curator link planning.

Public/private risk: no private secrets observed. Some examples use synthetic
clinical and CRM-style domains; keep summaries public and route exact sensitive
domain interpretation to source review if needed.

## Open Questions

- Should exact Stage 2 proof rows remain in `docs/tracks/README.md`, or be
  grouped under this Line Up after redirect verification?
- Should this Line Up split later into separate temporal, stream/OLAP, and
  invariant cards if agents still need narrower handles?

## Next Route

- Archive/Form Expert: verify no proof-local claim is promoted to canon.
- History Curator: plan grouped track-index redirects only after current agents
  no longer need exact rows by default.
