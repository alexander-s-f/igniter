# Stage 3 Round 52 Status Curation v0

Card: S3-R52-C3-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round52-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-15

---

## Scope

Close/map R52 and update the living PROP-036 CLI release-readiness state from
landed evidence only.

Read:

- `igniter-lang/docs/cards/S3/S3-R52.md`
- `igniter-lang/docs/gates/prop036-cli-release-readiness-decision-v0.md`
- `igniter-lang/docs/discussions/prop036-cli-release-readiness-pressure-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/README.md`
- `igniter-lang/docs/gates/README.md`
- `igniter-lang/docs/discussions/README.md`

---

## Evidence

S3-R52-C1-A landed:

```text
Track: prop036-cli-release-readiness-decision-v0
Status: conditional-release-readiness-doc-sync-required
Decision: conditionally approves package-surface release-readiness
Surface: igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
Condition: caller-facing docs sync required before readiness is complete
```

S3-R52-C2-X landed:

```text
Track: prop036-cli-release-readiness-pressure-v0
Verdict: proceed
Scope checks: 6/6 PASS
Blockers: none
NB-1: release-readiness terminology orientation only
Recommendation: R53 dedicated docs card, then pressure or curation verification
```

Evidence chain accepted by R52:

```text
R50 implementation/proof: 12/12 cases PASS, 4/4 command matrix PASS
R50 forbidden exact-token scan: 0 hits
R50 scanner self-tests: true / true
R50 pressure: proceed
R51 blocker package closure: approved-remaining-cli-blockers-formally-closed
R51 pressure: proceed
```

---

## Release-Readiness State

The bounded CLI transport is conditionally release-ready only in this exact
package surface:

```text
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

Current state:

```text
blocker package closure: closed
code/proof sufficiency: accepted for exact bounded transport
release-readiness: conditional
remaining condition: caller-facing docs sync
production/runtime authority: not granted
```

The condition is not satisfied in R52. It remains open until a docs sync lands
and a later pressure or status-curation card verifies the eight named content
requirements from C1-A.

---

## Required Docs Sync For R53

R53 should update `igniter-lang/docs/ruby-api.md` or create/link a small
caller-facing CLI doc that names:

- `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`;
- `PATH.json` as an already-finalized `compiler_profile_id_source` object;
- no-flag legacy behavior;
- CLI preflight refusal behavior;
- semantic compiler-profile-source refusal behavior;
- transport-only semantics;
- no discovery/defaulting/finalization;
- all excluded surfaces that remain closed.

The docs sync must remove or qualify the outdated blanket statement that CLI
profile-source flags/path loading remain closed, replacing it with the R52
bounded exception.

---

## Map Updates

Updated:

- `igniter-lang/docs/cards/S3/S3-R52.md`
  - marked R52 closed;
  - appended Round Receipt;
  - recorded conditional release-readiness and R53 docs route.
- `igniter-lang/docs/cards/S3/S3.md`
  - active snapshot now records conditional package-surface release-readiness;
  - R52 round index marked closed.
- `igniter-lang/docs/current-status.md`
  - Compiler Internals lane now records conditional release-readiness pending
    docs sync;
  - Round 52 landed block added;
  - S3-R52 result added;
  - Spec Freshness / PROP-036 rows updated to R52;
  - DOC-DEBT-72 added;
  - PROP canonical map updated.
- `igniter-lang/docs/tracks/README.md`
  - Stage 3 Round 52 Evidence section added;
  - next recommendations updated from readiness gate to docs-only condition
    sync.

No gate or discussion index edits were required: the R52 gate and discussion
rows were already present in their indexes.

---

## Non-Authorizations Preserved

R52 does not authorize:

- new implementation;
- widening beyond `--compiler-profile-source PATH.json`;
- inline JSON CLI input;
- named/generated profile lookup;
- environment/config/sidecar profile lookup;
- profile source discovery/defaulting/finalization in CLI/API;
- loader/report status implementation beyond existing compiler refusal behavior;
- CompatibilityReport compiler-profile section;
- existing `.igapp` golden migration;
- `.ilk`;
- CompilationReceipt links;
- signing;
- compiler dispatch migration;
- RuntimeMachine binding;
- Gate 3 widening;
- Ledger/TBackend;
- BiHistory;
- stream/OLAP;
- cache;
- production behavior or deployment authority.

---

## Compact R52 Summary

R52 conditionally approves package-surface release-readiness for the already
landed bounded PROP-036 CLI transport
`--compiler-profile-source PATH.json`. The proof and blocker chain are
sufficient for that exact surface, and pressure says proceed. Readiness remains
conditional because caller-facing docs still need to reflect the newly
authorized bounded CLI surface.

Production/runtime authority remains closed.

---

## R53 Recommendation

Run a dedicated docs card for the R52 condition. The card should update
`docs/ruby-api.md` or create/link a small CLI doc with all eight required
content items, then a pressure or status-curation card should verify the
condition before marking the bounded transport fully release-ready in scope.

Do not bundle implementation work into R53 unless a separate Architect decision
explicitly authorizes it.
