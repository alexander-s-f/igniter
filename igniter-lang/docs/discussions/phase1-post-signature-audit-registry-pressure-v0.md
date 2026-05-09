# Discussion: Phase 1 Post-Signature Audit / Registry Pressure v0

Card: S3-R21-X1-S
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: `phase1-post-signature-audit-registry-pressure-v0`
Status: complete — PROCEED
Date: 2026-05-09

Context: public-github-only
Write access: none
Canon authority: none

---

## Question

Do C1 (`compatibility-report-persistence-audit-v0`) or C2
(`gate3-authority-registry-shape-v0`) accidentally imply that durable audit or
production signing exists for Phase 1, and is the boundary between proof-local
and production sufficiently explicit?

---

## Context

- `docs/tracks/compatibility-report-persistence-audit-v0.md` (S3-R21-C1-P):
  defines and proves a proof-local audit-ready envelope for Phase 1;
  explicit export only; 10/10 PASS; `no_production_storage_or_ledger: ok`
- `docs/tracks/gate3-authority-registry-shape-v0.md` (S3-R21-C2-P):
  defines proof-local authority registry shape for Gate 3;
  8 registry policy cases proven; no executor calls; no signing/keys;
  11/11 PASS; `no_case_uses_signing_or_keys: ok`; `no_case_calls_executor: ok`

Depends on: Gate 3 signed addendum (S3-R20-C1-A), post-signature fixture
(S3-R20-C2-P), post-signature pressure review (S3-R20-X1-S).

---

## Scope-Item Check

| Scope item | Evidence | Status |
|---|---|---|
| C1 does not imply durable audit exists | Envelope field `audit_state: "audit_ready_not_persisted"`; `storage.automatic_persistence: false`, `durable_persistence: false`, `production_storage: false`; `export.explicit_not_automatic: ok`; `no_production_storage_or_ledger: ok`; non-authorization: no production storage, no durable audit | ✅ no durable audit implied |
| C2 does not imply production signing exists | Non-authorization: "No cryptographic signing"; `no_case_uses_signing_or_keys: ok`; "No cryptographic signing is introduced by this track"; "The current authority URI behavior remains source-code-parity"; production signing identified as a separate future track | ✅ no production signing implied |
| Phase 1 remains caller-policy + proof-local registry shape | C2-P: registry check composes before caller passes `gate3_authorized: true`; `no_case_calls_executor: ok`; executor code unchanged; C1-P: export is an explicit caller step; both tracks non-authorizing | ✅ caller-policy + proof-local only |
| No hidden Ledger path | C1-P: `no_production_storage_or_ledger: ok`; C2-P non-authorization: no Ledger adapter, no Ledger package binding; registry shape does not name any Ledger adapter family | ✅ no path |
| No hidden BiHistory / stream / OLAP path | C2-P non-authorization: no BiHistory, stream, OLAP, writes, replay, compact, subscribe; C1-P non-authorization: no Phase 2; registry `allowed_scope.operation: "history_valid_time_read"` restricts scope | ✅ no path |
| No hidden production cache / write path | C1-P: no Ledger write, no production storage; C2-P: no Ledger adapter; registry `backend_family: "memory_or_explicit_non_ledger"` only | ✅ no path |
| Pre-production checklist identified | C1-P: production durable audit remains open; C2-P: production registry and production signing recommended as separate future tracks (`gate3-authority-registry-v1`, `gate3-production-signing-v1`) | ✅ identified |

---

## [Agree]

**A-1: C1-P correctly defines the proof-local/production boundary for audit.**
The `audit_state: "audit_ready_not_persisted"` status and the explicit `storage`
block with four `false` fields together make it structurally impossible to
misread the envelope as durable. `export_mode: "explicit"` and
`export.explicit_not_automatic: ok` confirm the envelope is opt-in, not
an automatic side-effect of an authorized read. The non-authorization block
closes every production direction (Ledger, production storage, durable audit,
authority registry, Phase 2).

**A-2: C2-P correctly scopes the registry as proof-local policy metadata.**
The registry shape definition explicitly names seven things it is *not*:
signature, signing-key registry, revocation service, production authority
service, Ledger adapter descriptor, runtime self-authorization. The proof
fixture enforces this with `no_case_uses_signing_or_keys: ok` and
`no_case_calls_executor: ok`. Source-code-parity authority URI behavior is
explicitly preserved unchanged.

**A-3: The registry composition model is correct.**
C2-P places the registry check in the caller invocation evidence layer, before
`gate3_authorized: true` is passed. The executor's own guard chain
(`approval_token → gate_state → backend_identity → scope → cache_key`) is
not changed. This maintains the non-self-authorizing property established in
S3-R20-C1-A and proven in S3-R20-C2-P, and adds a proof-local caller-side
policy gate as a pre-executor check.

**A-4: C2-P's production split recommendation is architecturally sound.**
Separating revocation/durable registry (`gate3-authority-registry-v1`) from
signing and key management (`gate3-production-signing-v1`) avoids conflating
two distinct concerns. Proof-local source-code-parity authority URI comparison
is the correct Phase 1 mechanism; neither future track is implied to exist
yet by the current shape proof.

**A-5: The `missing_signed_addendum_evidence.blocks: ok` case in C2-P and
`missing_signed_addendum_ref.non_compliant: ok` case in C1-P close the
unsigned-addendum loophole.**
Both tracks independently verify that absent invocation evidence for the signed
addendum is treated as non-compliant or blocked. This is consistent with the
signed addendum's §2 requirement that callers must "directly reference this
signed addendum and record the signed document path or authority event."

---

## [Challenge]

**C-1 (Low — production readiness): `signed_addendum_ref` is a mutable file
path, not a content-addressed reference.**
C1-P's audit envelope carries:

```json
"signed_addendum_ref": "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md"
```

A file path is mutable — the document at that path could be edited, superseded,
or overwritten. A production-grade audit envelope should reference a content
hash or commit-pinned identifier, not just a path. For proof-local Phase 1 this
is tolerable (the git history preserves the signed state), but any production
audit or compliance consumer would need a stronger reference.

This is not a blocker for Phase 1 but must be addressed before the audit
envelope is used outside of proof-local contexts.

---

**C-2 (Low — composition gap): Registry and executor remain separate proof
fixtures without a composed end-to-end invocation proof.**
C2-P proves registry policy decisions without calling the executor.
C1-P proves the audit envelope for an authorized read without composing the
registry check. The full Phase 1 invocation path —

```text
authority registry check
  → caller passes gate3_authorized: true
  → Phase1 executor guard chain
  → audit-ready envelope exported
```

— is not proven as a single end-to-end fixture. Each layer is proven in
isolation. For Phase 1 proof-local use, isolation proofs are sufficient. For
any production path, an integrated end-to-end fixture would be needed.

Non-blocking; the correct shape is described in C2-P §Composition Point.

---

**C-3 (Low — naming): `audit_ready_not_persisted` could be misread as
"one step away from production audit readiness."**
The `audit_state` field is unambiguous in context and the `storage` block
makes persistence false explicit. However, a caller who only reads the field
name might infer that calling an export function produces a production-ready
audit artifact. A name like `proof_local_export_not_persisted` would leave no
ambiguity.

Non-blocking for Phase 1; a naming amendment before any production handoff
would be prudent.

---

**C-4 (Low — forward-looking): Production registry (`gate3-authority-registry-v1`)
and production signing (`gate3-production-signing-v1`) are recommended but have
no named owner, gate, or ordering constraint relative to each other.**
C2-P correctly recommends the split and explains why, but recommendations without
an ordering constraint could allow one to proceed without the other. A production
deployment needs both: a revoked authority should fail even when a token passes
the source-code-parity URI check.

Non-blocking for Phase 1 proof-local work. The correct sequencing constraint is:
production authority registry must exist and return an active status before
production signing produces usable tokens, not after.

---

## [Missing]

**M-1: No end-to-end Phase 1 invocation fixture composing registry → executor
→ audit envelope.**
Each of the three layers (registry, executor, audit) has its own proof. A future
`phase1-end-to-end-invocation-fixture-v0` would prove the composition and close
C-2.

**M-2: `signed_addendum_ref` content-addressing strategy not defined.**
C1-P defines the field but leaves the content-addressing mechanism as future
work. A follow-up track should decide: git commit SHA, content hash, or a
registry-minted version identifier.

**M-3: `LEGACY_ALIASES` deprecation signal still absent from `lib/`.**
Carried from S3-R18-X1-S C-4 and S3-R20-X1-S. Neither R21 track touches the
alias table. This is pre-Phase-2 only but should appear in the production
deployment checklist.

---

## [Sharper Question]

> If a caller correctly runs the Phase 1 registry check, passes
> `gate3_authorized: true`, and the executor produces an observation, then
> calls the C1-P explicit exporter — is the resulting `audit_ready` envelope
> sufficient for a human operator to reconstruct the full authorization chain
> independently?

The envelope contains: `temporal_live_read_observation`, `compatibility_report_ref`,
`authority_ref`, `signed_addendum_ref`, `backend_identity`, `result.status`,
`result.reason_code`. The operator would need to:
1. look up the `signed_addendum_ref` path to find the signed addendum;
2. look up the `authority_ref` URI to find the Gate 3 decision record;
3. correlate `backend_identity` with the allowed backend list in the addendum.

Steps 1–3 depend on file-system availability. For proof-local Phase 1 this is
fine. For any out-of-process or cross-team audit, file-system availability cannot
be assumed. The `signed_addendum_ref` content-addressing gap (C-1) is the
limiting factor.

---

## [Route]

**PROCEED.**

Both C1-P and C2-P are correctly scoped to proof-local Phase 1. Neither implies
durable audit nor production signing. Phase 1 remains caller-policy plus
proof-local shape only. No hidden Ledger, BiHistory, cache, stream, or write
path appears in either track. The pre-production deployment checklist is clearly
named.

Four low-severity non-blocking observations:

| # | Item | Type |
|---|---|---|
| C-1 | `signed_addendum_ref` is a mutable file path, not content-addressed | pre-production track needed |
| C-2 | Registry and executor are separate proof fixtures; no composed end-to-end fixture | pre-production track needed |
| C-3 | `audit_ready_not_persisted` state name could be misread | naming amendment before production handoff |
| C-4 | Production registry and signing have no sequencing constraint relative to each other | architecture note; registry must precede signing in production |

**Pre-production deployment checklist (cumulative, all rounds):**

| # | Item | Source |
|---|---|---|
| P-1 | Production durable observation persistence — `durable-observation-persistence-v0` | C1-P recommendation; AT-10 / R3 |
| P-2 | Production authority registry with durable storage, revocation, status transitions — `gate3-authority-registry-v1` | C2-P recommendation; R6 |
| P-3 | Production signing with key rotation, signature algorithm, verification policy — `gate3-production-signing-v1` | C2-P recommendation; R2/R6; must sequence after P-2 |
| P-4 | `signed_addendum_ref` content-addressed — not a mutable file path | C-1 above |
| P-5 | End-to-end Phase 1 invocation fixture composing registry → executor → audit | C-2 above |
| P-6 | `LEGACY_ALIASES` deprecation signal in `lib/` before Phase 2 operator-facing tooling | S3-R18-X1-S C-4 (carried) |
| P-7 | Phase 2 Ledger adapter addendum — separate gate, separate Architect decision | all prior rounds |

---

## Risk Table

| # | Item | Severity | Status |
|---|---|---|---|
| R-1 | C1 implies durable audit exists | High | ✅ closed — `audit_ready_not_persisted`; `durable_persistence: false`; `no_production_storage_or_ledger: ok` |
| R-2 | C2 implies production signing exists | High | ✅ closed — `no_case_uses_signing_or_keys: ok`; source-code-parity preserved; non-authorization explicit |
| R-3 | Phase 1 becomes production-authorized by C1/C2 | High | ✅ closed — both tracks are proof-local; executor code unchanged; non-authorization blocks present |
| R-4 | Hidden Ledger path | High | ✅ closed — C1-P + C2-P non-authorization; registry `backend_family` restricts to non-Ledger |
| R-5 | Hidden BiHistory / stream / OLAP path | High | ✅ closed — C2-P non-authorization; registry `operation: history_valid_time_read` |
| R-6 | Hidden production cache / write path | High | ✅ closed — C1-P + C2-P non-authorization |
| R-7 | Registry check bypassed; unsigned evidence accepted | High | ✅ closed — `missing_signed_addendum_evidence.blocks: ok`; `missing_signed_addendum_ref.non_compliant: ok` |
| R-8 | Phase 1 executor accidentally self-authorizes via registry | High | ✅ closed — `no_case_calls_executor: ok`; registry composes before, not inside, executor |
| R-9 | `signed_addendum_ref` is mutable file path | Low | open — C-1 above; pre-production track P-4 |
| R-10 | Registry + executor + audit not composed in single proof | Low | open — C-2 above; pre-production track P-5 |
| R-11 | `audit_ready_not_persisted` naming ambiguity | Low | open — C-3 above; naming amendment before production handoff |
| R-12 | Production registry / signing have no sequencing constraint | Low | open — C-4 above; architecture note |
| R-13 | `LEGACY_ALIASES` no deprecation signal | Low | open (carried) — pre-Phase-2 only |
| R-14 | CompatibilityReport backend_identity field not asserted in lib-prep fixture | Low | open (carried) — tolerated by C1-A §5 |
| R-15 | `gate3_authorized` honor-system | Low | open (inherent, documented) — Phase 1 structural limitation |

**All high risks closed. Six low-severity items, all pre-production or inherent
Phase 1 structural limitations.**

---

## Handoff

```text
Card: S3-R21-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: phase1-post-signature-audit-registry-pressure-v0
Status: complete — PROCEED

[D] Decisions
- C1-P does not imply durable audit: envelope is proof-local, not persisted,
  explicit export only.
- C2-P does not imply production signing: registry is proof-local policy
  metadata; source-code-parity URI unchanged; no signing/keys introduced.
- Phase 1 remains caller-policy + proof-local only after C1/C2.
- No hidden Ledger/BiHistory/cache/stream/write path in either track.
- Pre-production deployment checklist consolidated: P-1 through P-7.

[Agree]
- Both tracks correctly define proof-local/production boundary.
- Audit-ready envelope is structurally non-durable.
- Registry composition model is correct (pre-executor, non-self-authorizing).
- Production split recommendation (registry vs signing) is architecturally sound.
- Unsigned evidence blocked independently in both tracks.

[Challenge]
- C-1 (Low): signed_addendum_ref is a mutable file path.
- C-2 (Low): Registry + executor + audit not composed end-to-end.
- C-3 (Low): audit_ready_not_persisted naming ambiguity.
- C-4 (Low): Production registry / signing lack sequencing constraint.

[Route]
- PROCEED.
- Pre-production checklist P-1..P-7 documented.

[Next] Pre-production tracks
- durable-observation-persistence-v0 (P-1)
- gate3-authority-registry-v1 (P-2)
- gate3-production-signing-v1 (P-3, after P-2)
- phase1-end-to-end-invocation-fixture-v0 (P-5, composes registry + executor + audit)
- Phase 2 Ledger adapter addendum (P-7, separate Architect decision)
```
