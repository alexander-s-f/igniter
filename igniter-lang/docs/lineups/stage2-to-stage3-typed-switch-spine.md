# Line Up: Stage 2 To Stage 3 Typed Switch Spine

Status: active memory card
Source:
- `igniter-lang/docs/tracks/typed-emission-main-path-parity-v0.md`
- `igniter-lang/docs/tracks/typed-emission-canonical-shape-v0.md`
- `igniter-lang/docs/tracks/typed-emission-stage2-source-lowering-parity-v0.md`
- `igniter-lang/docs/tracks/temporal-cache-key-proof-v0.md`
- `igniter-lang/docs/tracks/orchestrator-emit-typed-switch-v0.md`
- `igniter-lang/docs/tracks/proposal-lifecycle-index-sync-v0.md`
- `igniter-lang/docs/tracks/parity-track-stale-header-sweep-v0.md`
- `igniter-lang/docs/tracks/spec-ch6-semanticir-temporal-sync-v0.md`
- `igniter-lang/docs/tracks/spec-ch4-temporal-fragment-sync-v0.md`
- `igniter-lang/docs/tracks/spec-ch7-runtime-temporal-cache-sync-v0.md`
- `igniter-lang/docs/tracks/spec-ch5-emit-typed-sync-v0.md`
Prepared by: `[Igniter-Lang Line Up Summarizer]`
Date: 2026-05-12
Disposition input: `active_reference for switch/spec sync; public_archive for stale parity blockers`
Current route: Line Up complete; keep as active reference until typed-switch
history no longer appears in current Stage 3 planning.

## One-Line Claim

The Stage 2 to Stage 3 switch story moved from blocked parsed-vs-typed parity
measurements to `emit_typed(typed)` as the production compiler path, with stale
headers and spec syncs preventing old blocker states from being read as current.

## Why It Matters

This cluster is high hallucination risk: early tracks say "blocked" while later
tracks correctly switch the production path. Current agents need the final route
without rereading the whole parity debate. In short: source remains authoritative for exact proof logs.

## Key Signals

| Step | Signal |
| --- | --- |
| Initial parity | `typed-emission-main-path-parity` runner passed but verdict was `blocked` with 9 blockers. It is explicitly stale. |
| Canonical shape | Source-hash public identity and normalized typed compute JSON made Add parity pass; blockers dropped but switch still held. |
| Stage 2 source lowering | Typed source blockers dropped to 0 for prioritized Stage 2 surfaces; remaining deltas were legacy parsed-path limitations. |
| Cache-key pressure | TEMPORAL cache keys must include temporal coordinates; CORE-shaped keys for TEMPORAL are semantic bugs. Production cache remained closed. |
| Switch | `orchestrator-emit-typed-switch-v0` changed production compile to `Parser -> Classifier -> TypeChecker -> SemanticIREmitter.emit_typed(typed) -> Assembler`. |
| Stale protection | `parity-track-stale-header-sweep-v0` marked old parity/cache blocker tracks as stale/superseded or stale/absorbed. |
| Spec sync | Ch4, Ch5, Ch6, and Ch7 were synced for TEMPORAL fragment class, `emit_typed`, temporal nodes, manifest/cache, and no live executor/cache/Ledger caveats. |

## Canon / History / Research / Value

- Canon/current truth: `emit_typed(typed)` is the production compiler path.
- Historical value: why strict parsed-vs-typed parity stayed blocked by design.
- Active reference: spec sync tracks and `orchestrator-emit-typed-switch-v0`.
- Public archive candidates: early parity/cache tracks with stale headers.
- Not promoted here: production temporal executor, production cache, Ledger
  binding, parser coordinate syntax beyond accepted current spec/proposals.

## Current Home

All source tracks remain in `igniter-lang/docs/tracks/`. No broad links were
rewritten.

## Links To Keep

- `igniter-lang/docs/tracks/orchestrator-emit-typed-switch-v0.md`
- `igniter-lang/docs/tracks/parity-track-stale-header-sweep-v0.md`
- `igniter-lang/docs/spec/ch5-compiler-pipeline.md`
- `igniter-lang/docs/spec/ch4-fragment-classification.md`
- `igniter-lang/docs/spec/ch6-semanticir.md`
- `igniter-lang/docs/spec/ch7-runtime.md`

## Safe To Archive?

Recommended disposition: `active_reference` for switch/spec sync, `public_archive`
for stale parity/cache measurement tracks after History Curator redirect checks.

Public/private risk: no private material observed in the assigned source
documents. Some proof paths mention synthetic SparkCRM/BiHistory examples; keep
as public proof context unless a later Archive/Form pass says otherwise.

## Open Questions

- Should stale parity tracks be grouped under this Line Up in `tracks/README.md`
  once no active card cites them directly?
- Should current docs add a single "typed switch history" pointer to prevent
  future agents from rereading stale parity blockers?

## Next Route

- Archive/Form Expert: verify stale labels and no canon promotion.
- History Curator: plan redirect/index grouping for stale parity tracks only
  after incoming references are checked.
