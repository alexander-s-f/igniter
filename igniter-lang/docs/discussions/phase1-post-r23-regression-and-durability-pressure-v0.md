# Discussion: Phase 1 Post-R23 Regression and Durability Pressure v0

Card: S3-R24-X1-S
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: `phase1-post-r23-regression-and-durability-pressure-v0`
Status: complete — PROCEED (non-blockers only)
Date: 2026-05-10

Context: public-github-only
Write access: none
Canon authority: none

---

## Question

Does the R24 regression rerun (C1-P) honestly cover the full post-R23 proof
chain without masking failures? Do the durable registry storage semantics (C2-P)
imply production signing or key management? Does the tamper-evidence shape
(C3-P) imply production durable audit or Ledger? Are all excluded surfaces still
closed?

---

## Context

- `docs/tracks/phase1-post-r23-regression-rerun-v0.md` (S3-R24-C1-P): 23/23
  PASS; all commands individually listed; no batch aggregation; non-authorization
  explicit
- `docs/tracks/phase1-durable-registry-storage-semantics-v0.md` (S3-R24-C2-P):
  durable registry storage semantics proof-local; `query_by_authority_ref`;
  effective-time status lookup; receipt chain verification; 10/10 PASS;
  `no_case_uses_signing_or_ledger: ok`; `no_case_calls_executor: ok`;
  `direct_active_to_superseded.blocked: ok`
- `docs/tracks/phase1-observation-tamper-evidence-shape-v0.md` (S3-R24-C3-P):
  tamper-evidence block added to `phase1_observation_persistence_record`;
  5 fields (`sequence`, `previous_record_hash`, `record_hash`, `storage_identity`,
  `created_at`); SHA256 canonical JSON hash chain; 23/23 PASS;
  `caveat.not_production_audit: ok`; all exclusions preserved

---

## Scope-Item Check

| Scope item | Evidence | Status |
|---|---|---|
| Regression rerun complete; no masked failures | 23 commands individually listed and run; no aggregate; explicit non-authorization block; "Commands run: 23, Passed: 23, Failed: 0" | ✅ complete |
| Durable registry semantics do not imply production signing / key management | `no_case_uses_signing_or_ledger: ok`; receipt fields `production_signing: false, production_key_management: false, ledger_binding: false`; storage identity `production_signing: false`; 15-item outside-Phase-1 list names production signing, key management, trust store explicitly | ✅ no implication |
| Tamper-evidence shape does not imply production durable audit or Ledger | `caveat.not_production_audit: ok`; caveat block `production_durable_audit: false, production_compliance_claim: false, ledger: false` preserved from S3-R23-C1-P; §Not Proved names cryptographic authorization, production durable audit, production signing, compliance as all out of scope | ✅ no implication |
| Ledger path closed | C1-P regression: scope exclusion fixture PASS; C2-P: `no_case_uses_signing_or_ledger: ok`; C3-P: `excluded.ledger_blocked: ok` | ✅ closed |
| BiHistory / stream / OLAP path closed | C1-P: temporal scope exclusion fixture PASS; C2-P production blockers list: BiHistory, transaction-time, stream, OLAP explicitly excluded | ✅ closed |
| Production cache / write / replay / compact / subscribe closed | C3-P: `excluded.write_blocked: ok`, `excluded.replay_blocked: ok`, `excluded.compact_blocked: ok`, `excluded.subscribe_blocked: ok`; C2-P production blockers: same four named | ✅ closed |

---

## [Agree]

**A-1: C1-P is the most complete regression record to date and is honestly
structured.**
The 23-command matrix lists every fixture individually, names the surface each
covers, and records the result explicitly. There is no aggregate or summary
substituting for a command result. The "Production-facing design tracks: ready
to proceed / Production implementation authorization: not granted" distinction in
the result block is the correct framing — it separates design readiness from
implementation authorization. The non-authorization block covers the full
excluded surface list consistently with prior rounds.

**A-2: C2-P resolves the S3-R23-X1-S M-3 open question on `active → superseded`
directly.**
M-3 asked whether production supersession should allow a direct `active →
superseded` path. C2-P §State Machine answers definitively:

```text
draft -> active -> revoked -> superseded
```

Direct `active → superseded` is blocked (`direct_active_to_superseded.blocked: ok`).
The rationale — "revocation has a distinct effective time and refusal reason;
supersession should point to a prior revocation receipt" — is technically
correct. A future production registry may add an atomic operation only with
paired receipt emission in a single transaction. This closes M-3.

**A-3: C2-P's storage identity block is the first proof-local component that
explicitly carries durability model as a data field.**
The storage identity shape:

```json
{
  "durability_model": "proof_local_file_backed_fixture",
  "production_signing": false,
  "ledger_binding": false
}
```

makes it impossible for a reader to confuse a proof-local registry store with a
production registry service at the data level. Any production registry must emit
a different `durability_model` string; a caller that receives `proof_local_file_backed_fixture`
from a registry identity query is receiving explicit proof-local scoping.

**A-4: C2-P's effective-time status lookup (`query_revoked_after_effective_time`
and `query_superseded_after_effective_time`) closes the S3-R21-X1-S sharper
question.**
The sharper question in S3-R21-X1-S asked whether an operator could reconstruct
the full authorization chain from a persisted record. Step 2 required the registry
to be "durable and queryable." C2-P proves queries return the correct status as
of a supplied timestamp, with revocation and supersession effective times
controlling results. The missing piece — durable storage persisting these queries
across process restarts — is named as a future production implementation, not an
active gap.

**A-5: C3-P's tamper-evidence hash chain uses canonical JSON (recursively sorted
keys) for determinism.**
`record_hash = SHA256(JSON.generate(canonical_sort(record_body_with_record_hash_nil)))`.
Sorting removes Ruby Hash insertion-order variance, which would otherwise make
the hash non-reproducible across different runtime execution paths. `integrity.r1_hash_verifiable: ok`
and `integrity.r2_hash_verifiable: ok` prove this: independently re-computed
hashes match stored hashes. The proof-local hash chain is internally consistent
and verifiable.

**A-6: C3-P names the production gap with precision in §Recommendation.**
The requirement table — HSM/KMS signing, retention policy, replay semantics,
infrastructure storage identity, compliance language, separate audit reader role,
off-process persistence, and gap/reorder alerting — is the correct minimum
production audit addition list. Each item is identified as a distinct requirement
with a distinct rationale. This is a clear production readiness checklist, not
aspirational language.

**A-7: C3-P's "stale" pre-conditions are correctly annotated as informational.**
C3-P §Recommendation names three pre-conditions for `phase1-production-durable-audit-v0`:
(1) gate3-live-read-decision-addendum-v0 issued — already done (S3-R20-C1-A);
(2) phase1-backend-identity-guard-v0 closed — already done (S3-R18-C4-P);
(3) AT-10 persistence gap resolved — addressed by S3-R23-C1-P and S3-R24-C3-P.
All three are now closed. C3-P's handoff was written without access to the
complete round history; the pre-conditions are stale, not incorrect. The
implication: `phase1-production-durable-audit-v0` has no pre-condition blockers
remaining from the listed items. The only remaining gate is Architect scope.

---

## [Challenge]

**C-1 (Low — clearly documented): C3-P's `record_hash` is SHA256 over
source-readable canonical JSON — content integrity, not a cryptographic
commitment.**
C3-P §Not Proved: "any caller who reads the source can construct a token that
passes." For proof-local use, this is explicitly scoped and correctly documented.
For any production audit context, the hash chain provides gap and reorder
detection but not unforgeability. Production requires HSM/KMS signing per record
(named in C3-P §Recommendation). The gap is documented, not hidden.

Non-blocking; named clearly in C3-P.

---

**C-2 (Low — clearly documented): C3-P's chain state is in-memory only; a
store restart would produce a sequence/genesis collision with existing JSONL
records.**
`@sequence` and `@last_record_hash` are not rebuilt from the JSONL file on
restart. A new store instance starts from `sequence=0, previous_record_hash="genesis"`
regardless of prior records. C3-P documents this and names the production fix:
"rebuild chain state from the persisted log on startup." For proof-local use,
the store is constructed once per test run. Non-blocking; the production rebuild
algorithm is not yet defined.

Non-blocking for proof-local use. Pre-production track required.

---

**C-3 (Low): C1-P regression matrix does not include C2-P and C3-P fixtures
because the rerun predated them in R24.**
The rerun is the first card in R24; C2-P and C3-P land in the same round.
The matrix covers 23 commands (through R23). Two new fixtures are now outside
the canonical matrix:

| Fixture | Round |
|---|---|
| `phase1_durable_registry_storage_semantics` | R24-C2-P |
| `phase1_observation_tamper_evidence_shape` | R24-C3-P |

The next regression rerun should expand the matrix to 25 commands. This is a
sequencing limitation, not a coverage failure.

Non-blocking; addressed by next regression rerun.

---

**C-4 (Low): `format_version` 0.2.0 is informational only — not enforced by
the store guard.**
C3-P §Open Questions: "Should format_version 0.2.0 be enforced by the store
guard (reject 0.1.0 records)? Currently not enforced; versioning is informational
only." A store that accepts records with `format_version: "0.1.0"` alongside
`format_version: "0.2.0"` cannot guarantee that the tamper-evidence block is
present in all stored records. For proof-local use, all records are created by
the same store class, so version mixing cannot occur. For any production store
that might receive externally sourced records, the version guard should be
enforced.

Non-blocking for proof-local use. Should be addressed before production store
integration.

---

## [Missing]

**M-1: Production `record_hash` chain rebuild algorithm on restart not defined.**
C3-P names the requirement ("rebuild chain state from the persisted log on
startup") but provides no algorithm. A future production store needs:
1. Read all records from the JSONL in order.
2. Verify the chain from genesis by re-computing and comparing each `record_hash`.
3. Report any gap or hash mismatch as a tamper signal.
4. After successful verification, set `@sequence` to last record's `sequence + 1`
   and `@last_record_hash` to last record's `record_hash`.

**M-2: No defined ownership for production registry storage (package, gate
document store, or external authority service).**
C2-P §Open Questions: "Which future component owns production registry storage?"
This is the design question that must precede any production implementation of
`gate3-authority-registry-v1`. The answer determines storage identity format,
query API surface, and deployment dependency graph.

---

## [Sharper Question]

> Given that C3-P's `record_hash` chain is source-readable and not an
> unforgeable commitment, what is the minimum addition to the tamper-evidence
> shape that would make a persisted record independently verifiable by an
> off-process auditor without access to the source code?

The current shape requires the auditor to re-run the same canonical JSON +
SHA256 algorithm from the source. Adding an HMAC (keyed hash) with a shared
audit key would allow off-process verification without a signing key. Adding an
HSM/KMS signature (C3-P recommendation) would make verification key-only with
no source dependency. The HMAC is the smallest step; the KMS signature is the
production requirement. Neither is implemented in R24.

---

## [Route]

**PROCEED — non-blockers only.**

All three tracks correctly scope proof-local work without widening Phase 1
authorization. The 23/23 regression rerun is complete and honestly structured.
Durable registry semantics and tamper-evidence shape each carry explicit data
fields that prevent confusion with production audit or production signing. All
excluded surfaces confirmed closed across all three tracks.

Four low-severity non-blocking observations:

| # | Item | Type |
|---|---|---|
| C-1 | `record_hash` is SHA256-only; not unforgeable | clearly documented; HSM/KMS required for production |
| C-2 | Chain state in-memory; no restart rebuild | clearly documented; production rebuild algorithm needed |
| C-3 | C1-P matrix excludes C2-P + C3-P fixtures (same-round sequencing) | next regression rerun adds 2 commands |
| C-4 | `format_version` 0.2.0 not enforced by store guard | version guard needed before production store integration |

Updated pre-production checklist:

| # | Item | Status after R24 | Note |
|---|---|---|---|
| P-1 | Durable observation persistence | shape + tamper-evidence defined; production storage, HSM, rebuild still future | C3-P closes tamper-evidence; production durable audit pre-conditions all met |
| P-2 | Production authority registry — durable storage, revocation, receipts | storage semantics defined (C2-P); production registry ownership open | `phase1-production-durable-audit-v0` pre-conditions met |
| P-3 | Production signing | open — after P-2 and registry ownership decision | |
| P-4 | `signed_addendum_ref` content-addressed | ✅ CLOSED (S3-R22-C2-P) | |
| P-5 | End-to-end invocation fixture | ✅ CLOSED (S3-R22-C1-P) | |
| P-6 | `LEGACY_ALIASES` deprecation signal | ✅ CLOSED (S3-R23-C3-P) | |
| P-7 | Phase 2 Ledger adapter addendum | open — separate Architect decision | |
| P-8 | Full regression matrix rerun (post-R19 fixtures) | ✅ CLOSED — 23/23 PASS (S3-R24-C1-P) | Next rerun: 25 commands |
| P-9 | Tamper evidence / storage identity for persisted observations | ✅ CLOSED (S3-R24-C3-P) | Production HSM/KMS signing and rebuild still needed |
| P-10 | Production registry ownership decision | open — M-2 above; Architect scope | Which component owns the registry |
| P-11 | `format_version` enforcement in store guard | open — C-4 above; pre-production integration | |
| P-12 | Restart rebuild algorithm for tamper-evident chain | open — M-1 above; production durable audit track | |

**R25 recommendation:**

| Priority | Track | Rationale |
|---|---|---|
| High | `phase1-production-durable-audit-v0` | All named pre-conditions now met; shape proven; requires Architect scope decision before routing |
| Medium | Regression rerun expanding to 25 commands | Adds C2-P + C3-P fixtures; closes C-3 |
| Low | `phase1-format-version-enforcement-v0` | Closes C-4 before production store integration |
| Deferred | Production registry ownership decision | Requires Architect and possibly Meta Expert before routing |

---

## Risk Table

| # | Item | Severity | Status |
|---|---|---|---|
| R-1 | Regression rerun masks failures | High | ✅ closed — 23 commands individually listed; no aggregation |
| R-2 | Durable registry semantics imply production signing | High | ✅ closed — `no_case_uses_signing_or_ledger: ok`; receipt fields `production_signing: false` |
| R-3 | Tamper-evidence implies production durable audit | High | ✅ closed — `caveat.not_production_audit: ok`; SHA256 chain explicitly not a cryptographic commitment |
| R-4 | Tamper-evidence implies Ledger | High | ✅ closed — `excluded.ledger_blocked: ok`; caveat `ledger: false`; C2-P `ledger_binding: false` |
| R-5 | BiHistory / stream / OLAP path reopened | High | ✅ closed — C1-P scope exclusion PASS; C2-P production blockers explicit |
| R-6 | Write / replay / compact / subscribe surface opened | High | ✅ closed — C3-P `excluded.*_blocked: ok` (4 checks); C2-P production blockers |
| R-7 | Production cache surface opened | High | ✅ closed — C2-P production blockers; no cache surface in any R24 track |
| R-8 | Phase 2 scope widening | High | ✅ closed — C1-P non-authorization; C2-P non-authorization: no Phase 2 Ledger-backed adapter |
| R-9 | `record_hash` unforgeable by proof-local source read | Low | open — C-1 above; correctly documented; HSM/KMS required for production |
| R-10 | Chain state restart collision | Low | open — C-2 above; correctly documented; rebuild algorithm needed |
| R-11 | C1-P regression matrix excludes R24 fixtures | Low | open — C-3 above; next rerun adds 2 commands |
| R-12 | `format_version` not enforced by store guard | Low | open — C-4 above; pre-production integration |
| R-13 | Production registry ownership undefined | Low | open — M-2 above; Architect scope decision |
| R-14 | `audit_ready_not_persisted` naming ambiguity | Low | open (carried) — pre-production naming amendment |
| R-15 | `gate3_authorized` honor-system | Low | open (inherent) — Phase 1 structural limitation |
| R-16 | `git_commit: workspace-current` placeholder | Low | open (carried) — CI must supply real SHA |

**All eight high risks closed. Eight low-severity items: four new (C-1..C-4) and four carried.**

---

## Handoff

```text
Card: S3-R24-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: phase1-post-r23-regression-and-durability-pressure-v0
Status: complete — PROCEED (non-blockers only)

[D] Decisions
- C1-P 23/23 PASS: most complete regression record to date; honestly structured.
- C2-P closes S3-R23-X1-S M-3: direct active -> superseded blocked; rationale correct.
- C2-P storage identity carries durability_model as data field; cannot be confused with production.
- C3-P tamper-evidence is SHA256 canonical chain — content integrity, not cryptographic commitment.
- C3-P production pre-conditions (gate3-live-read-decision-addendum, backend guard, AT-10)
  are all now closed; only Architect scope remains before routing production durable audit track.
- P-8 and P-9 closed; P-10 through P-12 added to checklist.

[Agree]
- All three tracks proof-local and non-authorizing.
- Durable registry semantics production-signing-clean.
- Tamper-evidence explicitly not production durable audit.
- All excluded surfaces confirmed closed across all three tracks.
- S3-R21-X1-S sharper question resolved by C2-P effective-time status lookup.

[Challenge]
- C-1 (Low): record_hash SHA256-only; source-readable.
- C-2 (Low): chain state in-memory; no restart rebuild.
- C-3 (Low): C1-P matrix excludes C2-P + C3-P same-round fixtures.
- C-4 (Low): format_version 0.2.0 not enforced by store guard.

[Route]
- PROCEED — non-blockers only.
- Pre-production checklist updated P-1..P-12.

[R25 recommendation]
- phase1-production-durable-audit-v0: all pre-conditions met; requires Architect scope decision.
- Regression rerun expanding to 25 commands.
- Production registry ownership decision (Architect + Meta Expert).
```
