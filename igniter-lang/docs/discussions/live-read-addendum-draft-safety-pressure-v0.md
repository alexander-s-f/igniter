# Discussion: Live-Read Addendum Draft Safety Pressure v0

Card: S3-R18-X1-S
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: `live-read-addendum-draft-safety-pressure-v0`
Status: complete — proceed; two pre-signing conditions
Date: 2026-05-09

Context: public-github-only
Write access: none
Canon authority: none

---

## Question

Did the R18 cleanup tracks (C1-A addendum draft, C2-P docstrings, C3-P reason
alias, C4-P backend identity guard) leave any hidden paths from "addendum
drafted" to live-read enablement?

---

## Context

- `docs/gates/gate3-live-read-decision-addendum-v0.md` (S3-R18-C1-A): draft
  addendum, status `draft-not-signed`
- `docs/tracks/temporal-executor-proof-local-docstring-amendment-v0.md`
  (S3-R18-C2-P): three code comments + reason-code aliasing to
  `runtime.temporal_scope_exclusion`
- `docs/tracks/runtime-temporal-scope-exclusion-reason-alias-v0.md`
  (S3-R18-C3-P): canonical reason code consolidation, Ch7 alias table update
- `docs/tracks/phase1-backend-identity-guard-v0.md` (S3-R18-C4-P): backend
  identity guard added to `lib/igniter_lang/temporal_executor.rb`; proof
  fixture 9/9 PASS

Scope items per card:

1. Addendum draft-only; Architect signature required for activation
2. No Ledger / BiHistory / production cache / stream / OLAP / write path
3. Backend identity guard closes proxy/wrapper loophole
4. authority_ref proof-local until production signing/registry
5. Observations not mistaken for durable audit

---

## Scope-Item Closure Table

| # | Scope item | Evidence | Status |
|---|---|---|---|
| 1 | Addendum draft-only; Architect signature required | C1-A status: `draft-not-signed`; explicit safe-status phrase; 6 blockers listed; non-authorization table | ✅ closed |
| 2a | No Ledger path | C1-A exclusions table: Ledger adapter, Ledger package read, write/append/replay/compact/subscribe/changefeed all closed | ✅ closed |
| 2b | No BiHistory path | C1-A exclusions table: `BiHistory[T]`, `bihistory_at`, `at(vt:,tt:)` all closed; separate gate required | ✅ closed |
| 2c | No production cache | C1-A exclusions table: `Production RuntimeMachine memoization/cache` closed; `durable observation persistence` closed | ✅ closed |
| 2d | No stream / OLAP | C1-A exclusions table: stream executor closed, OLAP executor closed | ✅ closed |
| 2e | No write path | C1-A exclusions table: Ledger write/append/replay/compact/subscribe closed | ✅ closed |
| 3 | Backend identity guard closes proxy/wrapper loophole | C4-P: unmarked objects, Ledger-backed adapters, Ledger-invoking wrappers, and malformed identity all blocked; `ledger_proxy_wrapper.blocked: ok`; `no_live_operations: ok` | ✅ closed |
| 4 | authority_ref proof-local until production signing | C1-A §3: "source-code-parity check, not production cryptographic authorization"; C2-P docstring: "not cryptographic authorization. Any token carrying this exact string passes AT-9; issuer identity is not verified. Replace with production signing (R2)" | ✅ documented |
| 5 | Observations not mistaken for durable audit | C1-A §4: "in-memory only. It is not durable, not an audit receipt"; C2-P docstring: "In-memory, not durable. Not an audit receipt." | ✅ documented |

---

## [Agree]

**A-1: Addendum is firmly draft-only.**
C1-A's `draft-not-signed` status, explicit safe-status phrase, 6-blocker list,
non-authorization table, and per-surface exclusion table form an unusually
strong fence. The document cannot be misread as opening live reads. Blocker 6
requires an explicit Architect signature or status-field change — no amount of
downstream track completion can self-activate the addendum.

**A-2: C4-P closes the proxy/wrapper loophole raised in S3-R17-X1-S C-1.**
The proof fixture blocks all four dangerous backend classes (unmarked duck-type,
Ledger-backed, Ledger-invoking proxy, malformed identity) at construction, with
zero live-operation flags asserted across all blocked cases. The `BACKEND_BLOCKED`
refusal fires before scope, cache-key, or backend `read_as_of`, which is the
correct earliest-safe position.

**A-3: C2-P closes both S3-R17-X1-S docstring amendments (C-3, C-4) cleanly.**
`GATE3_AUTHORITY_REF` now explicitly warns that it is source-code-parity only
and instructs callers to replace it with production signing before non-proof
deployment. The `observations` reader now explicitly states it is not a durable
audit receipt. The `initialize` docstring names the honor-system property so
callers cannot silently pass `gate3_authorized: true` without reading a warning.

**A-4: C3-P closes the reason-code alias gap raised in S3-R17-X1-S C-2.**
`NON_TEMPORAL`, `BIHISTORY_EXCLUDED`, and `CORE_REFUSAL` now emit
`runtime.temporal_scope_exclusion` as their canonical value.
`LEGACY_ALIASES` preserves backward compatibility for existing callers. Cache
mismatch, approval-token, and gate-closed families remain separate.

**A-5: `gate3_authorized` honor-system documented with sufficient explicitness.**
C1-A §2 names the pattern: the `Phase1` class cannot verify the addendum exists;
the caller owns the policy decision. C2-P mirrors this in code. For Phase 1
proof-local use the honor-system is acceptable; it is correctly named as a
pre-production risk rather than hidden.

**A-6: authority_ref remains a Phase 1 source-code-parity check.**
C1-A §3 closes production cryptographic authorization, key rotation, and
runtime authority registry at this stage. C2-P makes this explicit in the
constant comment. No upgrade path from source-code parity to cryptographic
verification is opened by any R18 track.

---

## [Challenge]

**C-1 (BLOCKER — pre-signing): Post-R18 full regression chain not yet
documented.**

C1-A §6 (Regression Requirements) names blocker 4:

> A post-cleanup regression rerun records the current proof chain PASS.

The minimum bar from that section is the R17 signal: 14/14 PASS. R18 code
changes landed across three tracks:

- C2-P: reason-code aliasing changed emitted strings in `ReasonCode` constants
- C3-P: updated same constants and Ch7 spec
- C4-P: added `check_backend_identity` guard to `lib/igniter_lang/temporal_executor.rb`

Each track ran its own local regressions:

- C4-P: ran `temporal_executor_lib_prep` only → PASS (17/17)
- C3-P: ran `temporal_executor_lib_prep` + `temporal_scope_exclusion_runtime_fixture` → PASS
- C2-P: ran `temporal_executor_lib_prep` only → PASS (17/17)

No track re-ran the full 14-proof chain from
`phase1-lib-prep-regression-chain-rerun-v0` against the state of the code after
all three R18 code changes together. Until that full rerun is recorded and
returns 14/14 PASS, addendum blocker 4 is open.

This is a required pre-signing condition, not a blocker on the cleanup tracks
themselves or on routing this discussion PROCEED.

---

**C-2 (AMEND — pre-signing): Addendum §Draft Authorization Target guard order
is inconsistent with C4-P implementation.**

C1-A §Draft Authorization Target states the authorized runtime shape as:

```text
approval_token -> gate_state -> scope -> cache_key -> backend_identity -> executor_backend
```

C4-P §Backend Identity Rule states:

> The guard runs after `approval_token` and `gate_state`, and before scope,
> cache-key, execution kernel, or backend `read_as_of`.

C4-P places `backend_identity` BEFORE scope and cache-key; C1-A places it
AFTER cache-key. The C4-P position is stricter (fails earlier for Ledger-typed
backends), so there is no safety regression, but the signed addendum should
accurately describe what the code actually enforces. If the addendum is signed
as written, its authorized shape description does not match the implementation.

Required action before signing: amend C1-A §Draft Authorization Target guard
order to match C4-P:

```text
approval_token -> gate_state -> backend_identity -> scope -> cache_key -> executor_backend
```

---

**C-3 (Low — non-blocking): Observation `backend_identity` field not yet proven
in fixture.**

C1-A §4 names `backend_identity` as a required field in the minimum observation
shape:

```text
backend_identity
result: allowed | refused
reason
generated_at
```

The existing `temporal_live_read_observation` fixture proofs (S3-R13, S3-R15)
predate the C4-P backend guard. No R18 proof checks that `backend_identity` is
populated in the emitted observation. For the draft this is non-blocking, but a
future post-cleanup regression rerun should include at least one assertion on the
observation shape.

---

**C-4 (Low — non-blocking): `LEGACY_ALIASES` in lib/ creates a
production-path naming surface.**

C2-P and C3-P added `ReasonCode::LEGACY_ALIASES` mapping narrow proof-local
reason code strings to `runtime.temporal_scope_exclusion`. This is correct for
proof-local callers with existing fixture assertions, but the presence of
`LEGACY_ALIASES` in the lib/ constant surface means a Phase 2 caller can
reference the old reason code strings by name without any deprecation signal.
C3-P's remaining-gaps note acknowledges this. Non-blocking for Phase 1;
should be addressed before Phase 2 operator-facing tooling.

---

## [Missing]

**M-1: Post-R18 full regression rerun track.**
A dedicated track re-running the 14-proof chain after C2-P + C3-P + C4-P code
changes is absent. This is addendum blocker 4 and should be completed before the
next safety-pressure circuit or Architect signature review.

**M-2: Observation shape proof after C4-P.**
No fixture assertion verifies that `Phase1#observations` emits `backend_identity`
as required by C1-A §4. The current observation proofs predate the backend guard.

**M-3: Addendum guard order amendment.**
C1-A §Draft Authorization Target needs a one-line amendment to place
`backend_identity` before `scope` and `cache_key`. Without this, the signed
document would describe an authorization shape that does not match the code.

---

## [Sharper Question]

After the post-R18 regression rerun and the C1-A guard-order amendment land:

> Does the addendum draft describe the actual code boundary precisely enough
> that `[Architect Supervisor / Codex]` can sign it without needing to re-read
> any track doc?

That precision test — can the addendum stand alone as a signing surface — is the
question that makes the pre-signing conditions real rather than procedural.

---

## [Route]

**PROCEED** for the R18 cleanup tracks themselves. All individual tracks are
correctly scoped, non-authorizing, and regression-green.

**Two pre-signing conditions before `[Architect Supervisor / Codex]` signs the
addendum:**

| # | Condition | Type | Suggested track |
|---|---|---|---|
| PS-1 | Post-R18 full regression rerun: 14-proof chain against code after C2-P + C3-P + C4-P | BLOCKER (addendum blocker 4) | `phase1-r18-cleanup-regression-rerun-v0` |
| PS-2 | Amend C1-A §Draft Authorization Target guard order: `backend_identity` before `scope` and `cache_key` | AMEND (addendum word amendment) | direct edit to `gate3-live-read-decision-addendum-v0.md` |

Non-blocking observations:

| # | Item | Recommended resolution |
|---|---|---|
| C-3 | Observation `backend_identity` field not proven in fixture | Add one assertion in regression rerun fixture (can be combined with PS-1) |
| C-4 | `LEGACY_ALIASES` in lib/ — no deprecation signal | Address before Phase 2 operator-facing tooling |

---

## Risk Table

| # | Item | Severity | Status |
|---|---|---|---|
| R-1 | Addendum draft-only; Architect signature required | — | ✅ closed — `draft-not-signed`, 6 explicit blockers |
| R-2 | Ledger adapter / package path | High | ✅ closed — C1-A exclusions table + C4-P Ledger-backed block |
| R-3 | BiHistory path | High | ✅ closed — C1-A exclusions table + C4-P no BiHistory |
| R-4 | Production cache path | High | ✅ closed — C1-A exclusions table |
| R-5 | Stream / OLAP executor | High | ✅ closed — C1-A exclusions table |
| R-6 | Write / replay / compact path | High | ✅ closed — C1-A exclusions table |
| R-7 | Backend proxy/wrapper loophole | High | ✅ closed — C4-P guard blocks Ledger-invoking wrappers |
| R-8 | Unmarked duck-type backend | Medium | ✅ closed — C4-P blocks objects without `phase1_backend_identity` |
| R-9 | authority_ref mistaken for cryptographic authorization | Medium | ✅ documented — C2-P docstring + C1-A §3 |
| R-10 | Observations mistaken for durable audit | Medium | ✅ documented — C2-P docstring + C1-A §4 |
| R-11 | gate3_authorized honor-system undocumented | Low | ✅ documented — C2-P initialize comment + C1-A §2 |
| R-12 | Post-R18 full regression rerun absent | Medium | ⚠️ open — addendum blocker 4; track `phase1-r18-cleanup-regression-rerun-v0` required |
| R-13 | C1-A guard order inconsistent with C4-P implementation | Medium | ⚠️ open — amend C1-A before signing |
| R-14 | Observation `backend_identity` field unproven in fixture | Low | open — combine with PS-1 rerun fixture |
| R-15 | `LEGACY_ALIASES` no deprecation signal in lib/ | Low | open — pre-Phase-2 only |

---

## Handoff

```text
Card: S3-R18-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: live-read-addendum-draft-safety-pressure-v0
Status: complete — proceed; two pre-signing conditions

[D] Decisions
- All five scope items confirmed closed by R18 tracks.
- No hidden Ledger, BiHistory, cache, stream, OLAP, or write path found.
- Backend proxy/wrapper loophole confirmed closed by C4-P.
- authority_ref documented as source-code-parity-only.
- Observations documented as in-memory non-audit.
- Two pre-signing conditions raised: post-R18 regression rerun and guard order
  amendment to C1-A.

[Agree]
- All scope items closed.
- Draft-only addendum status is firmly enforced.
- C4-P closes the proxy/wrapper loophole.
- C2-P closes both docstring amendments from S3-R17-X1-S.
- C3-P closes the reason-code alias gap.

[Challenge]
- C-1 (BLOCKER pre-signing): Post-R18 full regression chain not documented.
- C-2 (AMEND pre-signing): C1-A guard order inconsistent with C4-P implementation.
- C-3 (Low): observation backend_identity field not proven in fixture.
- C-4 (Low): LEGACY_ALIASES no deprecation signal.

[Route]
- PROCEED for R18 cleanup tracks.
- Two pre-signing conditions:
  PS-1: phase1-r18-cleanup-regression-rerun-v0 track (addendum blocker 4)
  PS-2: amend C1-A guard order to match C4-P before signing

[Next] Suggested next slices
- phase1-r18-cleanup-regression-rerun-v0 (addendum blocker 4)
- direct amend to gate3-live-read-decision-addendum-v0.md §Draft Authorization
  Target guard order
- Architect signature review after PS-1 + PS-2
```
