# Discussion: Gate 3 Live-Read Addendum Pre-Signature Pressure v0

Card: S3-R19-X1-S
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: `gate3-live-read-addendum-pre-signature-pressure-v0`
Status: complete — PROCEED to Architect signature review
Date: 2026-05-09

Context: public-github-only
Write access: none
Canon authority: none

---

## Question

After the guard-order amendment to the addendum and the R19 post-R18 regression
rerun, is the addendum ready to move to `[Architect Supervisor / Codex]`
signature review, or does any blocker remain?

---

## Context

- `docs/gates/gate3-live-read-decision-addendum-v0.md` (S3-R18-C1-A, amended):
  guard order updated to `approval_token -> gate_state -> backend_identity ->
  scope -> cache_key -> executor_backend`; status still `draft-not-signed`
- `docs/tracks/phase1-r18-cleanup-regression-rerun-v0.md` (S3-R19-C1-P):
  full 14-proof R17 baseline + R18 backend identity guard proof; result 15/15
  PASS; `observation.backend_identity_emitted: ok` added
- Prior closed tracks: C2-P (docstrings), C3-P (reason alias), C4-P (backend
  identity guard), S3-R18-X1-S (safety pressure: PROCEED, two pre-signing
  conditions)

---

## Blocker Closure Matrix

Six blockers were named in C1-A. This table records their current state.

| # | Addendum blocker | Closed by | Status |
|---|---|---|---|
| 1 | `phase1-backend-identity-guard-v0` proves arbitrary `read_as_of` objects cannot become authorized backends | S3-R18-C4-P: 9/9 PASS; Ledger-backed, proxy, unmarked, and malformed all blocked | ✅ closed |
| 2 | `runtime-temporal-scope-exclusion-reason-alias-v0` proves canonical operator-facing reason codes | S3-R18-C3-P: consolidated to `runtime.temporal_scope_exclusion`; Ch7 alias table updated | ✅ closed |
| 3 | Proof-local docstrings for `GATE3_AUTHORITY_REF` and `observations` | S3-R18-C2-P: source-code-parity warning + in-memory-not-audit warning + honor-system warning | ✅ closed |
| 4 | Post-cleanup regression rerun records current proof chain PASS | S3-R19-C1-P: 15/15 PASS (14-proof R17 baseline + R18 backend identity guard) | ✅ closed |
| 5 | Safety-pressure review returns `PROCEED` or only non-blocking amendments | S3-R18-X1-S: PROCEED; two pre-signing conditions raised (PS-1 regression rerun, PS-2 guard-order amendment) — both now closed | ✅ closed |
| 6 | `[Architect Supervisor / Codex]` issues explicit signed addendum or updates status | Not yet done — this is the remaining required action | ⏳ open (action: Architect) |

**Five of six blockers are closed. Blocker 6 is purely an Architect action.**

---

## Scope-Item Check

| Scope item | Evidence | Status |
|---|---|---|
| Hidden path to Ledger | C4-P blocks `ledger_backed: true` backends; C1-A exclusions table closed; C1-A §1 identity fields `ledger_package: false`, `invokes_ledger_package: false` | ✅ no path |
| Hidden path to BiHistory | C4-P identity field `supports_bihistory: false` required; C1-A exclusion row `BiHistory[T]` closed; no kernel path past guard | ✅ no path |
| Hidden path to stream / OLAP | C4-P identity field `supports_stream: false` required; C1-A exclusion rows closed; scope stage blocks non-TEMPORAL fragment | ✅ no path |
| Hidden path to production cache | C1-A exclusion row `Production RuntimeMachine memoization/cache` closed; no cache surface in Phase1 class | ✅ no path |
| Hidden path to writes / replay / compact / subscribe | C4-P identity fields `supports_writes/replay/compact/subscribe: false` required; C1-A exclusion rows closed | ✅ no path |
| `gate3_authorized` non-self-authorizing | C2-P `initialize` comment: "Pass true only when a valid Architect decision authorizes non-proof live reads"; C1-A §2: "Phase1 class does not self-authorize"; status `draft-not-signed` still enforces the block at the documentation boundary | ✅ non-self-authorizing |
| Backend identity guard Phase 1 only | C4-P guard applies only to the Phase1 class; Phase 2 Ledger adapter requires a separate Architect addendum; C1-A §1 states: "Any other backend identity must be named explicitly in a follow-up amendment before use" | ✅ Phase 1 scoped |

---

## [Agree]

**A-1: All five evidence-track blockers are fully closed.**
Blockers 1–4 each have a named completed track with explicit PASS signals.
Blocker 5 (S3-R18-X1-S) returned PROCEED with two pre-signing conditions:
PS-1 (regression rerun) is now S3-R19-C1-P (15/15 PASS) and PS-2 (guard-order
amendment) is visible in the addendum file. Both are closed.

**A-2: S3-R19-C1-P closes the post-R18 regression gap with an expanded chain.**
The rerun goes beyond the R17 14/14 bar: it adds the R18 backend identity guard
proof as proof #15 and asserts `observation.backend_identity_emitted: ok`. This
simultaneously closes S3-R18-X1-S M-1 (missing regression rerun) and M-2
(observation `backend_identity` field unproven). Both missing items are now
covered.

**A-3: Guard order amendment is confirmed in the addendum file.**
The addendum §Draft Authorization Target now reads:

```text
approval_token -> gate_state -> backend_identity -> scope -> cache_key -> executor_backend
```

This matches C4-P §Backend Identity Rule exactly. S3-R18-X1-S C-2 (inconsistent
guard order) is closed.

**A-4: Backend identity guard is correctly scoped to Phase 1.**
C4-P allows only `MemoryBackend` or an explicitly named non-Ledger identity
with all seven negative capability flags. The guard does not accidentally narrow
or widen Phase 2: the addendum §1 explicitly says any Phase 2 backend must be
named in a follow-up amendment. No automatic promotion path exists.

**A-5: `gate3_authorized` honor-system is sufficiently documented for Phase 1.**
For proof-local use, caller-side responsibility is the correct pattern. The
`Phase1` class cannot cryptographically verify the addendum's signing state; the
documentation boundary (C2-P comments + C1-A §2) is the correct enforcement
surface for Phase 1. This was already agreed in S3-R18-X1-S A-5.

**A-6: All excluded surfaces are multiply fenced.**
Each high-risk surface (Ledger, BiHistory, stream, OLAP, cache, writes) is
closed by at least two independent controls: C1-A exclusions table, C4-P
identity field requirement, and the Phase1 class's absence of any execution
path into those surfaces. No single-point bypass exists at the proof-local level.

---

## [Challenge]

**C-1 (Low — citation note for Architect):** Addendum §6 cites 14/14 PASS as
the minimum bar, but S3-R19-C1-P recorded 15/15 PASS. The signing record
should cite the current evidence level. If the Architect signs using the §6
language, the cited bar is stale by one proof. Not a blocker — the addendum
text will naturally be superseded by the signing record — but the signing
record should explicitly note R19-C1-P's 15/15 PASS rather than the §6 minimum.

---

**C-2 (Low — traceability gap):** The guard-order amendment to the addendum
(PS-2 from S3-R18-X1-S) was applied to the file without a named card in the
commit or track record. S3-R19-C1-P notes it found the addendum "already had
an unrelated modification" but does not record the amendment author or commit.
The git history shows a single commit for the addendum (`S3-R18-C1-A` draft).
This creates a minor traceability gap: the guard order change is visible in the
file but not attributed to a card.

For signature purposes this is acceptable — the content is correct and both
S3-R18-X1-S (which required the amendment) and S3-R19-C1-P (which confirmed
the corrected order) are in the record. However, the signing record should
acknowledge that the guard order amendment was made per S3-R18-X1-S PS-2.

---

**C-3 (Low — Phase 1 CompatibilityReport gap):** Addendum §5 requires the
composed CompatibilityReport to include "backend identity validation result."
The existing `temporal_executor_lib_prep` proof checks `report_composed` and
`report_runtime_enforced` but does not assert a `backend_identity_validation`
field in the report. This gap is tolerated at Phase 1 proof-local level by the
addendum's own language ("The report may be proof-local/minimal for Phase 1"),
but it means the Phase 1 report shape is not yet the full addendum-described
shape. Non-blocking for signature — the addendum tolerates minimal for Phase 1.

---

## [Missing]

**M-1:** There is no track record attributing the guard-order amendment (PS-2).
The signing record should note "guard order amended per S3-R18-X1-S PS-2" to
complete the traceability chain.

**M-2:** Addendum §6 Regression Requirements was not updated to reflect the
raised bar. After signing, a wording amendment should update §6 to cite
S3-R19-C1-P: 15/15 PASS as the current minimum regression bar.

---

## [Sharper Question]

> Once `[Architect Supervisor / Codex]` signs the addendum, what is the
> *first* caller-visible change?

The answer: a caller may now pass `gate3_authorized: true` and reference the
signed document in their invocation evidence. The `Phase1` class behavior does
not change; only the authorization policy boundary changes. Verification that
no behavior leak accompanies a signing action is the minimal check for the first
post-signature fixture.

---

## [Route]

**PROCEED to Architect signature review.**

No track work remains outstanding. The addendum can move to
`[Architect Supervisor / Codex]` for the blocker-6 action (explicit status
change from `draft-not-signed` to signed/approved).

Two notes for the signing record (neither blocks the review):

| # | Note | Type |
|---|---|---|
| N-1 | Signing record should cite S3-R19-C1-P (15/15 PASS), not §6's 14/14 minimum | citation note |
| N-2 | Signing record should attribute guard-order amendment to S3-R18-X1-S PS-2 | traceability note |

Post-signature suggested next slices:

| # | Track | Purpose |
|---|---|---|
| Next-1 | First post-signature fixture: verify no behavior change accompanies signing | Proof the honor-system boundary is clean |
| Next-2 | `compatibility-report-persistence-audit-v0` | R3 / AT-10 observation persistence gap |
| Next-3 | Phase 2 Ledger adapter addendum (separate gate) | Only after explicit Phase 2 Architect decision |

---

## Risk Table

| # | Item | Severity | Status |
|---|---|---|---|
| R-1 | Hidden Ledger path | High | ✅ closed — C4-P + C1-A exclusions |
| R-2 | Hidden BiHistory path | High | ✅ closed — C4-P identity field + C1-A exclusions |
| R-3 | Hidden stream / OLAP path | High | ✅ closed — C4-P identity field + C1-A exclusions |
| R-4 | Hidden production cache path | High | ✅ closed — C1-A exclusion + no Phase1 cache surface |
| R-5 | Hidden write / replay / compact / subscribe path | High | ✅ closed — C4-P identity fields + C1-A exclusions |
| R-6 | gate3_authorized self-authorization | High | ✅ non-self-authorizing — C2-P comment + C1-A §2 |
| R-7 | Backend guard scope bleeds into Phase 2 | Medium | ✅ Phase 1 scoped — C1-A §1 requires explicit amendment for Phase 2 |
| R-8 | Unmarked duck-type backend bypass | Medium | ✅ closed — C4-P blocks objects without `phase1_backend_identity` |
| R-9 | authority_ref mistaken for cryptographic authorization | Medium | ✅ documented — C2-P source-code-parity warning |
| R-10 | Observations mistaken for durable audit | Medium | ✅ documented — C2-P in-memory-not-audit comment |
| R-11 | Post-R18 regression chain not recorded | Medium | ✅ closed — S3-R19-C1-P: 15/15 PASS |
| R-12 | Guard order inconsistent between addendum and code | Medium | ✅ closed — addendum amended; matches C4-P exactly |
| R-13 | Observation backend_identity field unproven | Low | ✅ closed — S3-R19-C1-P: `observation.backend_identity_emitted: ok` |
| R-14 | Signing record cites stale regression bar (14/14 vs 15/15) | Low | open — citation note N-1; not a blocker |
| R-15 | Guard-order amendment traceability gap | Low | open — traceability note N-2; content is correct |
| R-16 | CompatibilityReport backend_identity field not yet asserted | Low | open — tolerated by C1-A §5 "proof-local/minimal" clause |
| R-17 | `LEGACY_ALIASES` no deprecation signal | Low | open — pre-Phase-2 only; unchanged from S3-R18-X1-S |

**All high and medium risks are closed. Three low-severity open items are
non-blocking citation/traceability notes and a known Phase 1 shape gap.**

---

## Handoff

```text
Card: S3-R19-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: gate3-live-read-addendum-pre-signature-pressure-v0
Status: complete — PROCEED to Architect signature review

[D] Decisions
- All five evidence-track blockers (1–5) are closed.
- Blocker 6 (Architect signature) is the only remaining action.
- No hidden Ledger, BiHistory, stream/OLAP, cache, or write path found.
- guard3_authorized is non-self-authorizing at proof-local and documentation levels.
- Backend identity guard is Phase 1 scoped; Phase 2 requires a separate addendum.

[Agree]
- Blockers 1–5 all closed with named tracks and PASS signals.
- S3-R19-C1-P closes M-1 and M-2 from S3-R18-X1-S.
- Guard order amendment confirmed in addendum file.
- All excluded surfaces multiply fenced.

[Challenge]
- C-1 (Low): Signing record should cite 15/15, not §6's 14/14 minimum.
- C-2 (Low): Guard-order amendment traceability gap.
- C-3 (Low): CompatibilityReport backend_identity field not yet asserted.

[Route]
- PROCEED to Architect signature review.
- Two notes for signing record (non-blocking): cite R19-C1-P 15/15 PASS;
  attribute guard-order amendment to S3-R18-X1-S PS-2.

[Next] Post-signature slices
- First post-signature fixture (proof honor-system boundary)
- compatibility-report-persistence-audit-v0 (R3 / AT-10 persistence gap)
- Phase 2 Ledger adapter addendum (separate gate; separate Architect decision)
```
