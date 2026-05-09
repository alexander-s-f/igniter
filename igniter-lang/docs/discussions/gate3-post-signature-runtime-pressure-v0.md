# Discussion: Gate 3 Post-Signature Runtime Pressure v0

Card: S3-R20-X1-S
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: `gate3-post-signature-runtime-pressure-v0`
Status: complete — PROCEED
Date: 2026-05-09

Context: public-github-only
Write access: none
Canon authority: none

---

## Question

Did the Architect signature (S3-R20-C1-A) widen scope beyond the draft
authorization target, and does the post-signature fixture (S3-R20-C2-P) confirm
that the first caller-visible change is policy-only with no behavior drift?

---

## Context

- `docs/gates/gate3-live-read-decision-addendum-v0.md` (S3-R20-C1-A):
  status changed from `draft-not-signed` to
  `signed-approved-restricted-phase1-live-read`; all six pre-signature blockers
  closed in §Signature Closure; exclusions table unchanged (14 rows); evidence
  cites S3-R19-C1-P 15/15 PASS and S3-R19-X1-S PROCEED
- `docs/tracks/gate3-first-post-signature-fixture-v0.md` (S3-R20-C2-P):
  proof fixture 10/10 PASS; `executor.guard_order_unchanged: ok`;
  `excluded_surfaces.no_live_paths: ok`; `dangerous_backend.blocked_before_read: ok`

---

## Scope-Item Check

| Scope item | Evidence | Status |
|---|---|---|
| Signature did not widen scope | C1-A exclusions table: 14 rows unchanged from draft; authorized surface identical to draft authorization target; safe status phrase names all remaining closed surfaces | ✅ scope unchanged |
| First caller-visible change is policy-only | C2-P: `executor.guard_order_unchanged: ok`; C1-A §Signature Decision: "executor behavior is not changed by this signature"; no runtime code changed per C2-P non-authorization block | ✅ policy-only |
| No hidden Ledger path | C1-A exclusions table: Ledger adapter, Ledger package read both closed; C2-P: `dangerous_backend.blocked_before_read: ok`; `excluded_surfaces.no_live_paths: ok` | ✅ no path |
| No hidden BiHistory path | C1-A exclusions table: BiHistory closed; C2-P fixture: `excluded_surfaces.no_live_paths: ok`; backend identity requires `supports_bihistory: false` | ✅ no path |
| No hidden stream / OLAP path | C1-A exclusions table: stream and OLAP executors closed; C2-P: `excluded_surfaces.no_live_paths: ok` | ✅ no path |
| No hidden production cache path | C1-A exclusions table: Production RuntimeMachine cache closed; no cache surface in Phase1 class | ✅ no path |
| No hidden write / replay / compact / subscribe path | C1-A exclusions table: write/replay/compact/subscribe/changefeed all closed; backend identity requires all negative capability flags | ✅ no path |
| `gate3_authorized` caller-controlled and documented | C1-A §2: "Phase1 class does not self-authorize"; C2-P: caller policy step modelled separately; `before_signed_reference.caller_must_not_pass_true: ok` | ✅ caller-controlled |
| Post-signature fixture proves no behavior drift | C2-P: 10/10 PASS; `executor.guard_order_unchanged: ok`; `memory_backend.executes_when_all_checks_pass: ok`; backend identity guard rerun: PASS | ✅ no drift |

---

## [Agree]

**A-1: The signature is correctly scoped. No authorization surface was widened.**
The signed addendum's §Signed Authorization Target is word-for-word identical
to the draft's §Draft Authorization Target. The safe status phrase was
strengthened: instead of "Phase 1 non-proof reads remain blocked" it now reads
"authorized only within this addendum scope" — and then explicitly re-closes
every excluded surface by name. The exclusions table was not narrowed or
selectively amended.

**A-2: All six pre-signature blockers are explicitly closed in §Signature
Closure with named card citations.**
Blockers 1–5 cite S3-R18-C2/C3/C4-P, S3-R19-C1-P, and S3-R19-X1-S
respectively. Blocker 6 cites S3-R20-C1-A (the signature card itself). The
closure chain is internally consistent and traceable.

**A-3: The post-signature fixture cleanly separates caller policy from executor
behavior.**
C2-P models the caller policy step explicitly:
- `before_signed_reference.caller_must_not_pass_true: ok` — absence of signed
  reference correctly blocks the gate
- `before_signed_reference.executor_blocks_at_gate_state: ok` — executor
  enforces the gate independently of caller intent
- `after_signed_reference.caller_may_pass_true: ok` — signed reference is the
  policy unlock; executor still runs all guards

This is precisely the right model: the signature changes what a compliant caller
is permitted to do; the executor's guard chain is unchanged.

**A-4: Excluded surfaces are re-proven after signing.**
`excluded_surfaces.no_live_paths: ok` and `dangerous_backend.blocked_before_read: ok`
confirm that the signing action introduced no execution path into any excluded
surface. The executor cannot be confused into treating the signed status as
broadened authorization.

**A-5: Guard order is confirmed unchanged post-signing.**
`executor.guard_order_unchanged: ok` closes the last behavioral drift risk.
The canonical guard order:

```text
approval_token -> gate_state -> backend_identity -> scope -> cache_key -> executor_backend
```

is intact. Signing a policy document does not and cannot reorder code.

**A-6: Both authorized Phase 1 backend paths are proven in the post-signature
fixture.**
`memory_backend.executes_when_all_checks_pass: ok` and
`non_ledger_backend.executes_when_all_checks_pass: ok` confirm that the two
paths named in C1-A §1 reach the backend `read_as_of` when all guards pass.
No silent third backend path emerged after signing.

**A-7: S3-R19-X1-S N-1 (citation bar) and N-2 (amendment traceability) are
both addressed in C1-A.**
§6 Regression Requirements now cites "S3-R19-C1-P: 15/15 PASS" as the signing
evidence, updating the stale 14/14 minimum. §Signature Closure bullet 5 records
"S3-R18-X1-S PS-2: guard-order amendment applied before signature." Both
non-blocking citation notes from S3-R19-X1-S are resolved.

---

## [Challenge]

**C-1 (Low — traceability): Original draft card S3-R18-C1-A was overwritten by
S3-R20-C1-A in the same file.**
The signed addendum is the same file (`gate3-live-read-decision-addendum-v0.md`)
with the card header changed from S3-R18-C1-A to S3-R20-C1-A and all content
updated to signed form. The draft no longer exists as a standalone artifact in
the file system. For Phase 1 proof-local use this is acceptable — the git
history preserves the prior draft state and the signing action is clean. For any
future audit that needs to compare draft vs signed text independently, git diff
is the only mechanism.

Non-blocking. The git commit history should record the diff between draft and
signed state.

---

**C-2 (Low — citation): Addendum §Reviewed Inputs cites
`stage3-round19-status-curation-v0.md` but that track was not found in the
tracks directory at review time.**
The addendum names it as a reviewed input alongside confirmed tracks
(phase1-lib-prep-regression-chain-rerun-v0, phase1-r18-cleanup-regression-rerun-v0,
gate3-live-read-addendum-pre-signature-pressure-v0). If the status curation
track was created but not yet committed, or if the name differs, the citation
cannot be independently verified by this review.

Non-blocking for the signing decision itself — the substantive evidence
(S3-R19-C1-P and S3-R19-X1-S) is present and verifiable.

---

**C-3 (Low — structural, carried from prior reviews):** `gate3_authorized: true`
remains a caller honor-system with no runtime enforcement of the signed-addendum
reference.
The fixture proves that compliant caller behavior is correct, but a non-compliant
caller could still pass `gate3_authorized: true` without checking the addendum.
This is a structural limitation of Phase 1 documented since S3-R17-X1-S and
re-documented in C2-P. It is the correct trade-off for proof-local scope; it
requires re-examination before any production deployment. Non-blocking.

---

## [Missing]

**M-1: Post-signature full proof chain not re-run.**
S3-R20-C2-P re-ran the backend identity guard proof only. Since the signature
changed no executor code, the 15/15 PASS from S3-R19-C1-P remains the current
evidence. This is acceptable for a policy-only change, but the next code-touching
track should include a full chain rerun.

**M-2: `stage3-round19-status-curation-v0.md` not independently verifiable.**
See C-2. If this track exists, confirming it was read and influenced the signing
decision would close the traceability gap.

---

## [Sharper Question]

> Under this signed addendum, what is the smallest proof that a hypothetical
> Phase 2 Ledger-backed caller *cannot* exploit the signed status to bypass the
> backend identity guard?

The existing answer is C2-P `dangerous_backend.blocked_before_read: ok`. The
sharper variant: does any code path in `Phase1#evaluate_valid_time_node` check
the addendum *status string* itself, or does the guard chain operate
independently of the file system? If the latter (which is architecturally
correct), then a compromised addendum status string has zero runtime effect —
the guards stand alone.

This is not a blocker; it is the right question to confirm Phase 1 is not
accidentally policy-coupled to the addendum document file.

---

## [Route]

**PROCEED.**

The signature was correctly scoped. No authorization surface was widened. The
post-signature fixture proves policy-only change and no behavior drift across all
ten checks. All high and medium risks from the S3-R18-X1-S / S3-R19-X1-S chain
remain closed.

Three low-severity non-blocking observations:

| # | Item | Type |
|---|---|---|
| C-1 | Draft S3-R18-C1-A overwritten; git history is the only diff surface | traceability note |
| C-2 | `stage3-round19-status-curation-v0.md` citation not independently verifiable | citation gap |
| C-3 | `gate3_authorized` honor-system: inherent Phase 1 limitation, documented | structural note (carried) |

Suggested next slices:

| # | Track | Purpose |
|---|---|---|
| Next-1 | `compatibility-report-persistence-audit-v0` | AT-10 / R3: observation persistence gap |
| Next-2 | `gate3-authority-registry-v0` | R6: authority revocation/rotation mechanism |
| Next-3 | Phase 2 Ledger adapter addendum | Separate gate; separate Architect decision; not enabled by this signing |

---

## Risk Table

| # | Item | Severity | Status |
|---|---|---|---|
| R-1 | Signature widens scope | High | ✅ closed — exclusions table unchanged; safe status phrase re-closes all excluded surfaces |
| R-2 | Ledger path after signing | High | ✅ closed — C2-P `excluded_surfaces.no_live_paths: ok`; `dangerous_backend.blocked_before_read: ok` |
| R-3 | BiHistory path after signing | High | ✅ closed — C2-P excluded surfaces; backend identity `supports_bihistory: false` required |
| R-4 | Stream / OLAP path after signing | High | ✅ closed — C2-P excluded surfaces; C1-A exclusions unchanged |
| R-5 | Production cache path after signing | High | ✅ closed — no cache surface; exclusion unchanged |
| R-6 | Write / replay / compact / subscribe path | High | ✅ closed — backend identity negative flags + C1-A exclusions |
| R-7 | Executor behavior drift after signing | High | ✅ closed — C2-P `executor.guard_order_unchanged: ok`; no code changed |
| R-8 | gate3_authorized self-authorization | High | ✅ non-self-authorizing — caller policy separated from executor; C2-P before/after model |
| R-9 | Unauthorized third backend path emerges | Medium | ✅ closed — C2-P proves only MemoryBackend and explicit non-Ledger pass |
| R-10 | authority_ref mistaken for cryptographic auth | Medium | ✅ documented — C1-A §3 source-code-parity note unchanged |
| R-11 | Observations mistaken for durable audit | Medium | ✅ documented — C1-A §4 in-memory limitation unchanged |
| R-12 | Post-signature full regression chain not re-run | Low | open — acceptable for policy-only change; cite S3-R19-C1-P 15/15 as current bar |
| R-13 | Draft overwritten; git diff only preservation | Low | open — traceability note C-1 |
| R-14 | Stage3-round19 curation citation unverifiable | Low | open — substantive evidence (S3-R19) is verifiable |
| R-15 | gate3_authorized honor-system | Low | open (inherent, documented) — pre-production limitation; not Phase 1 blocker |
| R-16 | LEGACY_ALIASES no deprecation signal | Low | open — pre-Phase-2 only; unchanged |
| R-17 | CompatibilityReport backend_identity field not asserted | Low | open — tolerated by C1-A §5 "proof-local/minimal" clause |

**All high and medium risks are closed. Five low-severity open items are
documentation/traceability notes or known Phase 1 structural limitations.**

---

## Handoff

```text
Card: S3-R20-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: gate3-post-signature-runtime-pressure-v0
Status: complete — PROCEED

[D] Decisions
- Signature did not widen scope; exclusions table and authorization target
  are identical to the draft.
- First caller-visible change confirmed policy-only by C2-P 10/10 PASS.
- All excluded surfaces re-proven after signing: no drift.
- gate3_authorized remains caller-controlled and non-self-authorizing.
- S3-R19-X1-S N-1 and N-2 addressed in C1-A §6 and §Signature Closure.

[Agree]
- Signature correctly scoped; no widening.
- Six blockers explicitly closed in §Signature Closure.
- Post-signature fixture correctly separates caller policy from executor.
- Guard order confirmed unchanged.
- Both authorized Phase 1 backend paths proven.

[Challenge]
- C-1 (Low): Draft overwritten; git history is the diff surface.
- C-2 (Low): Stage3-round19 curation citation not independently verifiable.
- C-3 (Low): gate3_authorized honor-system — inherent Phase 1 limitation.

[Route]
- PROCEED.
- Three non-blocking traceability/structural notes.

[Next] Post-signing slices
- compatibility-report-persistence-audit-v0 (AT-10 persistence gap)
- gate3-authority-registry-v0 (authority revocation/rotation)
- Phase 2 Ledger adapter addendum (separate gate, separate Architect decision)
```
