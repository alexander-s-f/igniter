# Track: Stage 3 Round 23 Status Curation v0

Card: S3-R23-C4-S
Agent: `[Igniter-Lang Status Curator]`
Role: status-curator
Track: `stage3-round23-status-curation-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Implementation Agent]`,
`[Igniter-Lang External Pressure Reviewer]`

---

## Goal

Update Stage 3 maps after R23 landed.

This is status curation only. No new semantics were created.

---

## Discovery

Per card scope, only landed R23 tracks and discussions were read.

Commands / reads:

```bash
git log --oneline -20 -- igniter-lang/docs/tracks igniter-lang/docs/discussions igniter-lang/docs/current-status.md
ls -lt igniter-lang/docs/tracks | head -80
rg -n "Card: S3-R23|S3-R23|R23|post-r22|regression|durable|persistence|registry|signing|Gate 3|Phase 1" igniter-lang/docs/tracks igniter-lang/docs/discussions
sed -n '1,320p' igniter-lang/docs/tracks/phase1-durable-observation-persistence-shape-v0.md
sed -n '1,340p' igniter-lang/docs/tracks/gate3-authority-registry-v1-receipts-shape-v0.md
sed -n '1,360p' igniter-lang/docs/tracks/phase1-reason-code-legacy-aliases-deprecation-signal-v0.md
sed -n '1,420p' igniter-lang/docs/discussions/phase1-durable-audit-and-registry-v1-pressure-v0.md
```

R23 evidence:

| Evidence | Status | Signal |
|----------|--------|--------|
| `phase1-durable-observation-persistence-shape-v0.md` | done | PASS 9/9; proof-local JSONL persistence shape only |
| `gate3-authority-registry-v1-receipts-shape-v0.md` | done | PASS 11/11; issuance -> revocation -> supersession receipts |
| `phase1-reason-code-legacy-aliases-deprecation-signal-v0.md` | done | PASS 21/21; lib-prep regression 17/17 unaffected |
| `../discussions/phase1-durable-audit-and-registry-v1-pressure-v0.md` | complete — PROCEED (non-blockers only) | No scope widening; P-8/P-9 routed |

---

## Status Decisions

[D] Gate 3 signed Phase 1 status remains exact:

```text
signed-approved-restricted-phase1-live-read
History[T] valid_time only
explicit as_of
MemoryBackend or explicit non-Ledger Phase 1 backend
```

[D] R23 C1 is proof-local/file-backed persistence shape only:
`proof_local_file`, JSONL, `production_durable_audit: false`,
`production_compliance_claim: false`, `ledger: false`.

[D] R23 C2 is registry v1 receipt shape only. It does not add production
signing, key management, production trust store, durable registry service,
package binding, Ledger adapter, or TemporalExecutor calls.

[D] R23 C3 closes the `LEGACY_ALIASES` deprecation signal. Alias removal remains
Phase 2 housekeeping.

[D] Phase 2, Ledger, BiHistory, stream, OLAP, production cache, writes, replay,
compact, subscribe, production signing/registry service, and production durable
audit remain closed.

---

## Map Updates

Updated:

- `../current-status.md`
- `README.md`

Recorded:

- R23 tracks in current status and track index.
- Proof-local persistence shape as done, not production audit.
- Registry v1 receipt shape as done, not production registry/signing.
- Legacy alias deprecation signal as done, removal deferred.
- R24 route: post-R23 regression rerun before scope widening.

---

## R23 Summary

```text
S3-R23-C1-P: durable observation persistence shape ✅ PASS 9/9
  proof_local_file JSONL only
  production_durable_audit: false
  production_compliance_claim: false
  ledger: false

S3-R23-C2-P: registry v1 receipts shape ✅ PASS 11/11
  issuance -> revocation -> supersession
  linked receipts via caused_by_ref
  content-addressed decision refs required
  no signing/keys/executor calls

S3-R23-C3-P: legacy alias deprecation signal ✅ PASS 21/21
  lib/ emits canonical runtime.temporal_scope_exclusion
  sealed old fixtures preserved
  lib-prep regression unchanged: PASS 17/17

S3-R23-X1-S: pressure review ✅ PROCEED (non-blockers only)
  all high risks closed
  P-8 post-R23 regression rerun remains open
  P-9 tamper evidence / storage identity opened
```

---

## R24 Recommendation

1. `phase1-post-r23-regression-rerun-v0` — consolidate post-R19 fixtures into
   a single current regression record before any new scope widening.
2. After P-8, choose either production durable audit design or durable registry
   storage semantics as the next production-facing track.
3. Keep production signing after durable registry ordering.
4. Keep Phase 2 Ledger adapter behind a separate Architect decision.

---

## Handoff

```text
Card: S3-R23-C4-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round23-status-curation-v0
Status: done

[D] Decisions
- R23 C1 is proof-local JSONL persistence shape, not production audit.
- R23 C2 is proof-local registry v1 receipts shape, not production signing or
  durable registry service.
- R23 C3 closes LEGACY_ALIASES deprecation signal; removal remains Phase 2.
- Gate 3 signed Phase 1 scope is unchanged and excluded surfaces remain closed.

[S] Shipped / Signals
- Updated current-status.md and tracks/README.md.
- Added R23 status-curation track.
- Routed R24 to post-R23 regression rerun before new scope widening.

[T] Tests / Proofs
- Pending self-check: git diff --check.
- Evidence consumed: S3-R23-C1-P PASS 9/9, S3-R23-C2-P PASS 11/11,
  S3-R23-C3-P PASS 21/21 + lib-prep 17/17, S3-R23-X1-S PROCEED.

[R] Risks / Recommendations
- Production durable audit still needs tamper evidence, storage identity,
  retention, replay semantics, and compliance language.
- Durable registry service still needs storage/query semantics and
  active -> superseded decision.
- Post-R23 regression matrix rerun remains the recommended R24 first slice.

[Next] Suggested next slice
- phase1-post-r23-regression-rerun-v0
```
