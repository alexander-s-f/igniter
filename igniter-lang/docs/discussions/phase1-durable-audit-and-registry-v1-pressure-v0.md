# Discussion: Phase 1 Durable Audit and Registry v1 Pressure v0

Card: S3-R23-X1-S
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: `phase1-durable-audit-and-registry-v1-pressure-v0`
Status: complete — PROCEED (non-blockers only)
Date: 2026-05-10

Context: public-github-only
Write access: none
Canon authority: none

---

## Question

Do C1 (`phase1-durable-observation-persistence-shape-v0`), C2
(`gate3-authority-registry-v1-receipts-shape-v0`), or C3
(`phase1-reason-code-legacy-aliases-deprecation-signal-v0`) widen Phase 1 scope,
imply production audit or production signing, or alter authorization semantics
after Gate 3 signing?

---

## Context

- `docs/tracks/phase1-durable-observation-persistence-shape-v0.md` (S3-R23-C1-P):
  proof-local file-backed JSONL persistence shape for Phase 1 observations;
  required caveat `production_durable_audit: false, production_compliance_claim: false,
  ledger: false`; 9/9 PASS; `negative_cases.did_not_append: ok`
- `docs/tracks/gate3-authority-registry-v1-receipts-shape-v0.md` (S3-R23-C2-P):
  registry v1 shape with transition receipts (issuance → revocation →
  supersession); linked receipt chain; 11/11 PASS;
  `no_case_uses_production_signing_or_keys: ok`; `no_case_calls_executor: ok`
- `docs/tracks/phase1-reason-code-legacy-aliases-deprecation-signal-v0.md`
  (S3-R23-C3-P): deprecation comment added to `LEGACY_ALIASES`; 21/21 PASS;
  sealed proof artifacts protected; lib-prep regression 17/17 PASS

---

## Scope-Item Check

| Scope item | Evidence | Status |
|---|---|---|
| C1 does not imply Ledger or production audit | Required caveat: `production_durable_audit: false, production_compliance_claim: false, ledger: false`; `ledger_adapter.excluded: ok`; `write/replay/compact/subscribe.excluded: ok`; `negative_cases.did_not_append: ok`; non-authorization explicit | ✅ no implication |
| C2 registry v1 receipts do not imply production signing / key management | `no_case_uses_production_signing_or_keys: ok`; receipt schema fields `production_signing: false, production_key_management: false`; non-authorization: no production signing, key management, trust store, or durable registry service | ✅ no implication |
| C3 reason-code cleanup does not change authorization semantics | Comment-only addition to lib/; aliases already pointed to `SCOPE_EXCLUSION` since S3-R18-C2/C3-P; `executor.non_temporal/bihistory/core_scope.no_legacy_string: ok` (new explicit coverage); lib-prep regression 17/17 PASS; sealed proof artifacts not modified | ✅ semantics unchanged |
| Fail-fast order preserved | C1-P: excluded operations do not append (`negative_cases.did_not_append: ok`); C2-P: issuance without content-addressed ref blocks; revocation from missing entry blocks; supersession without decision ref blocks; C3-P: canonical code emitted at correct guard stages | ✅ fail-fast intact |
| Excluded surfaces remain closed | C1-P: Ledger/write/replay/compact/subscribe excluded at persistence layer; C2-P non-authorization lists 15 outside-Phase-1 surfaces explicitly; C3-P: no executor code changes | ✅ all closed |

---

## [Agree]

**A-1: C1-P correctly places the `audit_ready / production_durable_audit` split
in both the record shape and the proof output.**
The required caveat block —

```json
{
  "audit_ready": true,
  "production_durable_audit": false,
  "production_compliance_claim": false,
  "ledger": false
}
```

— must appear in every `phase1_observation_persistence_record`. The proof then
checks this directly with `record.audit_ready_not_production_audit: ok`. An
operator reading any persisted record can see, in the record itself, that it is
not a production audit claim. This is the correct design: the boundary is in
the data, not only in the docs.

**A-2: C1-P enforces the exclusion at the persistence layer, not only at the
executor layer.**
`negative_cases.did_not_append: ok` proves that Ledger, write, replay, compact,
and subscribe paths do not produce any `phase1_observation_persistence_record`
entry. This means even if an excluded surface somehow reached the persistence
step (e.g. a broken caller), the persistence guard would block the append. The
two-layer exclusion (executor refuses + persistence refuses) is the correct
defense-in-depth model.

**A-3: C2-P's linked receipt chain (`caused_by_ref` linkage) is a structural
improvement over the v0 registry shape.**
The v0 registry entry in S3-R21-C2-P carried `receipt_refs` as opaque IDs.
The v1 receipt schema adds `caused_by_ref` that links each receipt to its
predecessor:

```text
issuance receipt   (nil → active)
  ↓ caused_by issuance
revocation receipt (active → revoked)
  ↓ caused_by revocation
supersession receipt (revoked → superseded)
```

`revocation.receipt_links_issuance: ok` and
`supersession.receipt_links_revocation: ok` prove the chain is verifiable from
any receipt node. This is the minimum structure needed for a production authority
lifecycle audit without requiring a full registry service.

**A-4: C2-P mandates content-addressed decision refs in registry v1.**
`issuance_without_content_ref.blocks: ok` and
`supersession_without_decision_ref.blocks: ok` confirm that content-addressing
(from S3-R22-C2-P) is now a hard issuance/supersession requirement, not
advisory. Path-only references cannot produce valid registry entries in v1.
This closes the `git_commit: workspace-current` tolerance as a design principle
for the registry layer itself, even though the proof fixture still defaults to
`workspace-current` in absence of a real commit SHA.

**A-5: C3-P correctly identifies and protects three sealed proof artifacts.**
The sealed fixtures (S3-R14-C2-P, S3-R15-C2-P, and the load guard experiment)
hardcode old reason strings because they used inline executor classes that
predate the lib/ class. C3-P names them, explains why they must not be updated,
and adds the first explicit proof that the lib/ executor emits *only* the
canonical `runtime.temporal_scope_exclusion` for all three scope scenarios:

```text
executor.non_temporal.no_legacy_string: ok
executor.bihistory.no_legacy_string: ok
executor.core_scope.no_legacy_string: ok
```

Prior proofs checked the blocked status and canonical code; none had previously
confirmed the absence of the old strings. C3-P adds that coverage.

**A-6: C3-P's LEGACY_ALIASES comment provides the correct Phase 2 migration
script.**
The deprecation comment names: (a) what the aliases are for; (b) why the sealed
fixtures must not be updated; (c) the grep audit command for finding live callers;
(d) the three-step migration steps; (e) the timing constraint ("after
gate3-live-read-decision-addendum-v0, before production deployment"). A Phase 2
implementer can follow this from the comment alone.

---

## [Challenge]

**C-1 (Low): `phase1_observation_persistence_record` is stored in
`out/phase1_observation_store.jsonl` with no tamper evidence, storage identity,
or retention policy.**
C1-P §Signed Follow-Up Recommendation explicitly names the gap: "A production
durable audit follow-up should be a separate track with storage identity,
retention, tamper evidence, replay semantics, and compliance language." The
proof-local JSONL file proves the record shape and the exclusion behavior, but
it is a flat append-only file with no hash chain, no storage identity, and no
read-back verification. Any production deployment that wants to use persisted
Phase 1 observation records as audit evidence needs all four named properties.

Non-blocking for Phase 1 proof-local use. Required before any production
compliance claim.

---

**C-2 (Low — inherited): C2-P's `decision_ref` `git_commit` field still
defaults to `workspace-current` when `GIT_COMMIT` is unset.**
This is the S3-R22-X1-S C-1 concern carried into registry v1. C2-P correctly
mandates a content-addressed `decision_ref` for issuance
(`issuance_without_content_ref.blocks: ok`), but the proof fixture can still
produce a valid issuance receipt with `git_commit: workspace-current`. A
production issuance must supply an actual commit SHA. The v1 receipt schema and
the compliance rule both require a real commit; the fixture's env-var default
is the only remaining gap.

Non-blocking for Phase 1 proof-local use.

---

**C-3 (Low): The LEGACY_ALIASES grep audit command is defined in C3-P but not
run as part of any automated regression.**
C3-P provides the exact grep command to detect non-experiment callers using old
reason code strings:

```bash
grep -r "runtime\.non_temporal_not_covered\|runtime\.temporal_executor_bihistory_excluded\|runtime\.temporal_executor_core_refusal" igniter-lang/
```

This is currently a manual migration precondition, not a CI-enforced gate. If
a new experiment or non-experiment file were added that hardcodes an old string,
no automated check would catch it before Phase 2 operator tooling is built.

Non-blocking for Phase 1. A CI hook running this grep (expecting matches only
in the three named sealed fixtures) would close the gap.

---

**C-4 (Low — wording): C1-P §Signed Follow-Up Recommendation introduces the
concept of a "signed follow-up" for proof-local/file-backed persistence without
naming the required process.**
The phrase "can become a signed follow-up" suggests a future Architect decision
would be needed, but the path (which gate document, which addendum) is left
implicit. For Phase 1 proof-local use, the persistence shape alone is sufficient.
Before any production claim, the process should mirror the Gate 3 signing flow:
safety pressure → Architect addendum → explicit signature. The recommendation
does not create any unauthorized commitment, but a clearer routing statement
would reduce ambiguity.

Non-blocking.

---

## [Missing]

**M-1: No post-R23 regression rerun consolidating all post-R19 fixtures.**
P-8 from S3-R22-X1-S (post-R22 regression matrix rerun) is still open after
R23. C1-P re-ran `phase1_end_to_end_invocation_fixture` and
`compatibility_report_persistence_audit` as related checks; C3-P re-ran lib-prep.
No single track ran the full 15+ chain against the current combined state. This
should be the next dedicated regression track.

**M-2: Tamper evidence / hash chain for `phase1_observation_store.jsonl`
not defined.**
See C-1. A production audit trail needs at minimum an append receipt that hashes
the previous record. The proof-local JSONL store has no such mechanism.

**M-3: Active → superseded direct transition not covered in C2-P.**
C2-P's receipt chain forces `active → revoked → superseded`. The open question
in C2-P §Handoff asks whether production supersession should allow a direct
`active → superseded` path. This matters for key rotation scenarios where an
authority is superseded by a newer one without being revoked first. Not a blocker
for Phase 1 proof-local use; must be resolved in `gate3-authority-registry-v1`
durable storage design.

---

## [Sharper Question]

> If an operator finds a `phase1_observation_persistence_record` in the JSONL
> store and needs to independently verify the authorization chain, can they do
> so from the record alone?

The record must contain `signed_addendum_ref` with a content-addressed identity
(from S3-R22-C2-P), `authority_ref`, and `backend_identity`. The operator can:
1. Look up `signed_addendum_ref.document_path` and verify `content_sha256` matches.
2. Look up `authority_ref` in the registry v1 entry to verify `status: active` at
   time of read.
3. Confirm `backend_identity` matches the Phase 1 allowed backend list.

Step 2 requires the registry to be durable and queryable — which P-2
(`gate3-authority-registry-v1` durable storage) has not yet built. Until P-2 is
done, the authorization chain is only partially verifiable from the persisted
record. This is the key remaining gap between "proof-local audit-ready" and
"independently verifiable production audit."

---

## [Route]

**PROCEED — non-blockers only.**

All three tracks are correctly scoped, proof-local, non-authorizing for
production behavior, and non-altering of authorization semantics. All high risks
are closed. The pre-production checklist is updated below.

Four low-severity non-blocking observations, three of which are carried:

| # | Item | Type |
|---|---|---|
| C-1 | JSONL store has no tamper evidence / storage identity | pre-production track required |
| C-2 | `git_commit: workspace-current` placeholder inherited into v1 registry receipts | pre-production compliance gap (carried) |
| C-3 | Legacy alias grep audit not automated | pre-production CI hook recommended |
| C-4 | "Signed follow-up" for persistence lacks explicit process routing | wording clarification before signing |

Updated pre-production checklist:

| # | Item | Status after R23 | Note |
|---|---|---|---|
| P-1 | Durable observation persistence | shape defined (proof-local); production storage still future | C1-P closes shape; production durable audit track still needed |
| P-2 | Production authority registry — durable storage, revocation, receipts | shape + receipts defined (S3-R21-C2-P + S3-R23-C2-P); durable storage still future | `active → superseded` direct path open question |
| P-3 | Production signing | open — after P-2 | S3-R23-C2-P confirms still future |
| P-4 | `signed_addendum_ref` content-addressed | ✅ CLOSED (S3-R22-C2-P) | Content-addressed identity now required in registry v1 |
| P-5 | End-to-end invocation fixture | ✅ CLOSED (S3-R22-C1-P) | |
| P-6 | `LEGACY_ALIASES` deprecation signal | ✅ CLOSED (S3-R23-C3-P) | Removal deferred to Phase 2; grep audit command defined |
| P-7 | Phase 2 Ledger adapter addendum | open — separate Architect decision | |
| P-8 | Full regression matrix rerun (post-R19 fixtures) | open | `phase1-post-r23-regression-rerun-v0` |
| P-9 | Tamper evidence / storage identity for persisted observations | open | new — C-1 above; pre-production audit track |

**Recommendation for R24:** run the full post-R19 regression rerun (P-8) before
opening any new scope widening tracks. The post-R22/R23 fixture set has not been
consolidated into a single rerun record since S3-R19-C1-P.

---

## Risk Table

| # | Item | Severity | Status |
|---|---|---|---|
| R-1 | C1 implies production durable audit or Ledger | High | ✅ closed — `production_durable_audit: false`; non-authorization explicit; `ledger_adapter.excluded: ok` |
| R-2 | C2 implies production signing or key management | High | ✅ closed — `no_case_uses_production_signing_or_keys: ok`; receipt fields `production_signing: false` |
| R-3 | C3 changes authorization semantics | High | ✅ closed — comment-only; lib-prep 17/17 PASS; sealed fixtures protected |
| R-4 | Excluded surfaces reachable after persistence | High | ✅ closed — C1-P `negative_cases.did_not_append: ok`; C2-P blocks un-addressed issuance/revocation/supersession |
| R-5 | Fail-fast order changed by any R23 track | High | ✅ closed — no executor code changed; C3-P aliases pre-existing; C2-P registry is pre-executor layer |
| R-6 | Ledger path appears in persistence or registry | High | ✅ closed — C1-P + C2-P non-authorization explicit |
| R-7 | BiHistory / stream / OLAP path widens | High | ✅ closed — no new surfaces; C2-P `allowed_scope.operation: history_valid_time_read` restricted |
| R-8 | Legacy alias removal retroactively alters sealed proof evidence | High | ✅ closed — sealed fixtures explicitly identified and protected by C3-P |
| R-9 | JSONL store has no tamper evidence; production audit misuse | Low | open — C-1 above; `production_durable_audit: false` caveat present; pre-production track P-9 needed |
| R-10 | `git_commit: workspace-current` in v1 registry receipts | Low | open (inherited) — C-2 above; v1 requires real SHA for production |
| R-11 | Legacy alias grep audit not automated | Low | open — C-3 above; CI hook needed before Phase 2 |
| R-12 | "Signed follow-up" for persistence lacks process routing | Low | open — C-4 above; wording note |
| R-13 | Post-R22/R23 regression matrix not consolidated | Low | open — P-8; `phase1-post-r23-regression-rerun-v0` needed |
| R-14 | `active → superseded` direct transition not covered | Low | open — M-3 above; production registry design question |
| R-15 | `audit_ready_not_persisted` naming ambiguity | Low | open (carried) — pre-production naming amendment |
| R-16 | `gate3_authorized` honor-system | Low | open (inherent) — Phase 1 structural limitation |
| R-17 | Phase 2 Ledger adapter addendum | — | open — separate Architect gate decision |

**All eight high risks closed. Nine low-severity items: five inherited, two new
from C-1/C-3, one R23-specific open question (M-3), and one carried naming note.**

---

## Handoff

```text
Card: S3-R23-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: phase1-durable-audit-and-registry-v1-pressure-v0
Status: complete — PROCEED (non-blockers only)

[D] Decisions
- C1-P does not imply production audit: required caveat in record shape;
  persistence layer also enforces exclusions; two-layer defense confirmed.
- C2-P does not imply production signing: receipt fields enforce
  production_signing: false; no executor calls; linked receipt chain is correct.
- C3-P does not change authorization semantics: comment-only; sealed
  proof artifacts protected; lib-prep regression unaffected.
- Fail-fast order intact across all three tracks.
- Pre-production checklist: P-4, P-5, P-6 now closed (9 items total).

[Agree]
- All three tracks proof-local and non-authorizing.
- C1-P defense-in-depth: exclusion enforced at both executor and persistence.
- C2-P linked receipt chain is a structural improvement enabling lifecycle audit.
- C2-P mandates content-addressed decision refs in registry v1.
- C3-P protects sealed proof artifacts correctly.

[Challenge]
- C-1 (Low): JSONL store no tamper evidence / storage identity.
- C-2 (Low): git_commit workspace-current inherited into v1 receipts.
- C-3 (Low): legacy alias grep audit not automated.
- C-4 (Low): "signed follow-up" for persistence lacks explicit process routing.

[Route]
- PROCEED — non-blockers only.
- Updated pre-production checklist P-1..P-9.

[Next] Recommendation for R24
- phase1-post-r23-regression-rerun-v0 (P-8): consolidate post-R19 fixtures
  into a single rerun record before any new scope widening tracks.
- After P-8: decide P-1 production durable audit path vs P-2 durable registry
  storage as the next production-facing track.
```
