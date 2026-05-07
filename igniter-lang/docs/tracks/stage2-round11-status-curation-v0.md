# Stage 2 Round 11 Status Curation

Card: S2-R11-C4-S
Agent: [Igniter-Lang Status Curator]
Role: meta-expert
Track: igniter-lang/stage2-round11-status-curation-v0
Status: done
Date: 2026-05-07

## Scope

Reconcile the active documentation maps after the three neighboring Round 11
tracks landed:

- `packageable-compiler-api-v0`
- `invariant-severity-semanticir-lowering-v0`
- `tbackend-ledger-bridge-conformance-v0`

This slice is docs-only and does not change proof code, proposals, role
profiles, or platform packages.

## Procedural Discovery

[S] Ran the assigned discovery commands:

```bash
git log --oneline -8 -- igniter-lang
ls -lt igniter-lang/docs/tracks | head
rg -n "Card: S2-R11" igniter-lang/docs/tracks
rg --files igniter-lang/lib/igniter_lang | sort
```

[S] Discovered exactly three landed neighboring R11 tracks before this curation
track:

- `packageable-compiler-api-v0.md` — `S2-R11-C1-P`
- `invariant-severity-semanticir-lowering-v0.md` — `S2-R11-C2-P`
- `tbackend-ledger-bridge-conformance-v0.md` — `S2-R11-C3-P`

[S] `rg --files igniter-lang/lib/igniter_lang | sort` returns 10 files under
`lib/igniter_lang/`. The top-level `igniter-lang/lib/igniter_lang.rb` facade is
tracked separately as facade, not counted as an eleventh extracted pass library.

[S] Read the R11 handoff/evidence sections. `packageable-compiler-api-v0.md`
does not have a literal `## Handoff` heading, so its `Decisions`, `Proof
Output`, `Remaining Gaps`, and `Next Delta` sections were used as its handoff
evidence.

## Decisions

[D] Treat `IgniterLang.compile(...)` as the stable Ruby-facing compiler facade,
but not as full distributable package completion. The remaining package work is
load-path, gemspec/bin wiring, and shared CLI/API proof.

[D] Treat compile-time Stage 2 SemanticIR lowering as complete for the current
surfaces: stream, OLAPPoint, and invariant severity. Runtime
`invariant_violation_node` observations remain future runtime work.

[D] Treat Ledger TBackend work as descriptor-first. The next package-side slice
should be metadata-only `LedgerTBackendAdapterDescriptor v0` before any
read/write/replay/RuntimeMachine binding.

[D] Keep Stage 2 open. R11 removes two active "next" items, but production
package boundary and production runtime adapter binding remain open.

## Updated Maps

[S] `docs/current-status.md` now shows:

- R11 Ruby API facade PASS.
- R11 invariant SemanticIR lowering PASS.
- R11 TBackend Ledger conformance docs-only PASS.
- New active priority order:
  `Compiler package boundary -> Runtime smoke extraction -> Ledger adapter descriptor`.

[S] `docs/tracks/README.md` now includes Round 11 evidence and replaces the
completed R11 next-track suggestions with post-R11 candidates.

[S] `docs/spec/README.md` is synced from Stage 2 R9 to Stage 2 R11 coverage and
removes stale "stage2 surface lowering next" references.

[S] `docs/README.md` was also lightly synced because its current-priority block
still pointed to already-landed R10/R11 work.

## Self-Check

[T] R11 track references in `docs/tracks/README.md` all exist:

```text
r11_track_refs=4
missing=none
```

[T] Library count check:

```text
rg --files igniter-lang/lib/igniter_lang | wc -l
=> 10
```

[T] Stale-next check found no references in active maps to landed
`packageable-compiler-api-v0` or `invariant-severity-semanticir-lowering-v0`
as future work.

[T] Handoff template still uses:

```text
Card:
Agent:
Role:
Track:
Status:
```

## Handoff

```text
Card: S2-R11-C4-S
Agent: [Igniter-Lang Status Curator]
Role: meta-expert
Track: igniter-lang/stage2-round11-status-curation-v0
Status: done

[D] Decisions
- Packageable API facade is done, but full distributable compiler package
  boundary remains open.
- Compile-time Stage 2 SemanticIR lowering is done for stream, OLAPPoint, and
  invariant severity.
- Ledger-backed TBackend work should proceed descriptor-first and metadata-only.
- Stage 2 remains open.

[S] Shipped / Signals
- Updated current-status, track index, docs index, and spec coverage README.
- Added Round 11 evidence for packageable compiler API, invariant lowering, and
  TBackend Ledger conformance.
- Replaced stale R10 next priorities with post-R11 candidates.

[T] Tests / Proofs
- Docs-only curation.
- Ran assigned discovery checklist.
- Verified R11 track references exist.
- Verified lib count under `lib/igniter_lang/` is 10.
- Verified handoff template shape still includes Card/Agent/Role/Track/Status.

[R] Risks / Recommendations
- Do not treat IgniterLang.compile as packaging completion until load-path,
  gemspec/bin, and shared CLI/API proof exist.
- Do not bind Ledger reads/writes/runtime paths before descriptor-only adapter
  evidence is approved.
- Runtime invariant violation observations need a separate runtime slice.

[Next] Suggested next slice
- `runtime-smoke-extraction-v0`
- `compiler-package-boundary-v0`
- `ledger-tbackend-adapter-descriptor-v0`
```
