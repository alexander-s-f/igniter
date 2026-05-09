# Discussion: Phase 1 E2E and Content-Address Pressure v0

Card: S3-R22-X1-S
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: `phase1-e2e-and-content-address-pressure-v0`
Status: complete — PROCEED
Date: 2026-05-09

Context: public-github-only
Write access: none
Canon authority: none

---

## Question

Do C1 (`phase1-end-to-end-invocation-fixture-v0`) or C2
(`phase1-addendum-content-address-ref-v0`) accidentally introduce production
behavior, leave the mutable-reference gap open, or widen Phase 1 scope —
and what remains before durable audit or production authority work can begin?

---

## Context

- `docs/tracks/phase1-end-to-end-invocation-fixture-v0.md` (S3-R22-C1-P):
  end-to-end Phase 1 invocation proof composing authority registry check →
  caller authorization → Phase1 executor → audit-ready envelope export;
  9/9 PASS; `no_case_uses_production_signing: ok`;
  `no_case_uses_production_storage_or_ledger: ok`
- `docs/tracks/phase1-addendum-content-address-ref-v0.md` (S3-R22-C2-P):
  proof-local content-addressed signed addendum reference shape; requires
  `document_path` + `content_sha256` + `git_commit` + `status` + `authority_ref`;
  path-only evidence ruled non-compliant; 9/9 PASS;
  `no_case_requires_production_registry: ok`;
  `no_case_requires_production_signing: ok`

Depends on: S3-R21-C1-P (audit envelope), S3-R21-C2-P (registry shape),
S3-R20-C1-A (signed addendum), S3-R20-X1-S, S3-R21-X1-S.

---

## Scope-Item Check

| Scope item | Evidence | Status |
|---|---|---|
| C1 proves composition without production behavior | C1-P: "end-to-end path is still proof-local"; `no_case_uses_production_signing: ok`; `no_case_uses_production_storage_or_ledger: ok`; non-authorization: no Ledger, no production storage/signing/cache, no durable audit, no Phase 2 | ✅ proof-local only |
| C2 closes or clearly scopes the mutable `signed_addendum_ref` risk | C2-P: path-only evidence ruled non-compliant; compliance requires `content_sha256` matching live document bytes; `hash_mismatch.blocks: ok`; `status_not_signed.blocks: ok`; `authority_ref_mismatch.blocks: ok`; non-authorization: no addendum mutation | ✅ risk scoped; content-addressed shape defined |
| No hidden Ledger / BiHistory / cache / stream / write path | C1-P: `no_case_uses_production_storage_or_ledger: ok`; non-authorization names all surfaces; C2-P: non-authorization: no Ledger adapter, no Ledger package binding, no executor/lib changes | ✅ no paths |
| Production signing still a future track | C1-P: "Production durable registry, production signing, and durable audit remain separate future tracks"; C2-P: `no_case_requires_production_signing: ok`; production signing named in §Production Registry Recommendation as a separate future track with no content present | ✅ future track only |
| Production registry still a future track | C2-P: `no_case_requires_production_registry: ok`; §Production Registry Recommendation describes future requirements without implementing them; C1-P non-authorization: no production cache | ✅ future track only |
| Pre-production checklist blockers identified | C2-P closes P-4 (mutable-reference gap); C1-P closes P-5 (composition gap); P-1/P-2/P-3/P-6/P-7 remain open | ✅ identified |

---

## [Agree]

**A-1: C1-P closes S3-R21-X1-S gap P-5 cleanly and without production coupling.**
The composition proof —

```text
active registry → caller authorized → Phase1 executor → observation emitted
                                                       → audit envelope exported
```

— is proven with `memory_backend.end_to_end_allowed: ok` and
`non_ledger_backend.end_to_end_allowed: ok`. The two negative entry points
(`revoked_registry.blocks_before_executor: ok` and
`missing_signed_addendum.blocks_before_executor: ok`) confirm the registry check
is a real pre-executor gate, not ceremonial. `ledger_like_backend.blocks_before_read: ok`
and `missing_audit_export.non_compliant_not_persisted: ok` cover the exclusion and
audit-export enforcement from inside the composition. No production surface appears.

**A-2: C2-P closes S3-R21-X1-S gap P-4 with three independent negative proofs.**
The three blocked cases —

| Case | Reason code |
|---|---|
| `hash_mismatch.blocks: ok` | `addendum_ref.content_hash_mismatch` |
| `status_not_signed.blocks: ok` | `addendum_ref.status_not_signed_approved` |
| `authority_ref_mismatch.blocks: ok` | `addendum_ref.authority_ref_mismatch` |

— independently verify that content drift, status regression, and authority
mismatch each independently block the caller from passing `gate3_authorized: true`.
`human_and_content_case.ok: ok` confirms the positive envelope carries both the
human path and the content identity. Path-only thinking is structurally
non-compliant.

**A-3: C2-P does not require production registry or production signing to function.**
`no_case_requires_production_registry: ok` and `no_case_requires_production_signing: ok`
confirm that the content-addressed reference shape is self-contained at proof-local
level. The shape is designed to fold into a future `gate3-authority-registry-v1`
(§Production Registry Recommendation) without requiring that registry to exist now.

**A-4: The S3-R21-X1-S C-3 naming concern (`audit_ready_not_persisted`) is
unchanged but tolerable at this scope.**
Neither R22 track amends the audit state name. C1-P re-uses
`missing_audit_export.non_compliant_not_persisted: ok` which correctly frames
the name as a non-persisted-but-enforceable state. The naming concern is carried
forward as pre-production but does not affect correctness.

**A-5: The composition order in C1-P is now proven, not just described.**
S3-R21-X1-S C-2 noted that "registry and executor remain two separate proof
fixtures... not composed." C1-P closes this by proving
`revoked_registry.blocks_before_executor: ok` — a revoked registry entry
prevents the executor from being called at all. The ordering constraint
(registry check must precede executor invocation) is now proven behavior, not
just an architectural note.

---

## [Challenge]

**C-1 (Low — proof-local placeholder): `git_commit` defaults to
`workspace-current` when `GIT_COMMIT` env var is absent.**
C2-P §Reference Shape defines `git_commit` as `"workspace-current|<commit-sha>"`,
and the fixture reads the `GIT_COMMIT` environment variable, defaulting to
`workspace-current` when unset. The proof passes with this placeholder. A
compliant production envelope requires a real commit SHA — `workspace-current`
is not a stable identity and cannot survive document mutations across commits.

For the proof this is acceptable. Before any production use:
- CI must supply the actual commit SHA via `GIT_COMMIT`;
- the compliance check must treat `workspace-current` as non-compliant in
  production mode.

Non-blocking for Phase 1; a pre-production note.

---

**C-2 (Low — performance note): `content_sha256` compliance requires
re-reading and hashing the addendum file on every invocation.**
C2-P's compliance rule says "`content_sha256` matches the current document
bytes." At proof-local scale, re-hashing a small file on every invocation is
negligible. At any production call rate, this becomes a per-call file read and
SHA-256 computation. The future `gate3-authority-registry-v1` (P-2) should cache
the identity, so callers look up a registry entry rather than re-hashing the
document. Non-blocking for Phase 1.

---

**C-3 (Low — regression matrix gap): Post-R21/R22 proof fixtures are not yet
in the canonical regression matrix.**
S3-R19-C1-P defined the current 15-proof regression matrix. Since then, four
new proof fixtures have been added:

| Round | Fixture |
|---|---|
| R20-C2-P | `gate3_first_post_signature_fixture` |
| R21-C1-P | `compatibility_report_persistence_audit` |
| R21-C2-P | `gate3_authority_registry_shape` |
| R22-C1-P | `phase1_end_to_end_invocation_fixture` |
| R22-C2-P | `phase1_addendum_content_address_ref` |

C1-P re-ran three of these as "related proof commands" but not as a full 15+
chain sweep. A follow-up regression rerun track should capture the current full
matrix before production work begins.

---

## [Missing]

**M-1: `workspace-current` `git_commit` placeholder not blocked in the proof.**
The fixture accepts `workspace-current` as a valid `git_commit` value when
`GIT_COMMIT` is unset. A production compliance guard should treat an unresolved
placeholder as non-compliant. This is the one remaining gap in C2-P.

**M-2: No updated full regression matrix after R20–R22.**
The last named full regression run was S3-R19-C1-P (15/15 PASS). Five new
fixtures added in R20–R22 have not been consolidated into a single regression
rerun track. This should be completed before production work begins.

---

## [Sharper Question]

> When `gate3-authority-registry-v1` (P-2) is eventually built with durable
> storage, which field in the C2-P content-addressed reference shape serves as
> the primary lookup key — `authority_ref`, `content_sha256`, or both?

The answer determines whether the production registry is authority-URI-indexed
(one entry per Gate 3 decision authority) or content-indexed (one entry per
document version). The C2-P shape carries both fields. The question is not
answered by R22 and should be decided as part of P-2 design, not deferred to
implementation.

---

## [Route]

**PROCEED.**

Both C1-P and C2-P are correctly scoped to proof-local Phase 1. Neither adds
production behavior. P-4 and P-5 from the S3-R21-X1-S checklist are now closed.
No hidden Ledger, BiHistory, cache, stream, or write path appears.

Updated pre-production checklist:

| # | Item | Status after R22 | Suggested track |
|---|---|---|---|
| P-1 | Durable observation persistence | open | `durable-observation-persistence-v0` |
| P-2 | Production authority registry — durable storage, revocation, status transitions | open (shape ready: S3-R21-C2-P + S3-R22-C2-P) | `gate3-authority-registry-v1` |
| P-3 | Production signing — key rotation, algorithm, verification policy | open (after P-2) | `gate3-production-signing-v1` |
| P-4 | `signed_addendum_ref` content-addressed | **✅ CLOSED** — S3-R22-C2-P | — |
| P-5 | End-to-end invocation fixture composing registry → executor → audit | **✅ CLOSED** — S3-R22-C1-P | — |
| P-6 | `LEGACY_ALIASES` deprecation signal | open | lib amendment before Phase 2 |
| P-7 | Phase 2 Ledger adapter addendum | open | separate Architect gate decision |
| P-8 | Full regression matrix rerun (post-R19 fixtures included) | open | `phase1-post-r22-regression-rerun-v0` |

Three low-severity non-blocking observations:

| # | Item | Type |
|---|---|---|
| C-1 | `git_commit: workspace-current` placeholder accepted in proof | pre-production compliance gap |
| C-2 | `content_sha256` re-computed per invocation; no caching | pre-production performance note |
| C-3 | Post-R21/R22 fixtures not in canonical regression matrix | regression gap — add to next rerun |

---

## Risk Table

| # | Item | Severity | Status |
|---|---|---|---|
| R-1 | C1 adds production behavior | High | ✅ closed — `no_case_uses_production_signing/storage_or_ledger: ok`; non-authorization explicit |
| R-2 | C2 opens mutable `signed_addendum_ref` as sufficient evidence | High | ✅ closed — path-only non-compliant; `hash_mismatch.blocks: ok` |
| R-3 | Ledger / BiHistory / cache / stream / write path appears | High | ✅ closed — both non-authorization blocks explicit; no surfaces in fixture |
| R-4 | Production signing implied by C2 reference shape | High | ✅ closed — `no_case_requires_production_signing: ok`; future track named only |
| R-5 | Production registry implied by C2 reference shape | High | ✅ closed — `no_case_requires_production_registry: ok`; future track named only |
| R-6 | Registry check not proven to precede executor | High | ✅ closed — `revoked_registry.blocks_before_executor: ok` (S3-R22-C1-P) |
| R-7 | Phase 2 expansion from C1 composition path | High | ✅ closed — non-authorization: no Phase 2; no new backend types introduced |
| R-8 | `git_commit: workspace-current` placeholder treated as compliant in production | Low | open — C-1 above; CI must supply real SHA before production use |
| R-9 | `content_sha256` re-hashed per invocation at production scale | Low | open — C-2 above; P-2 registry should cache |
| R-10 | Post-R21/R22 fixtures not in canonical regression matrix | Low | open — C-3 above; add to next rerun |
| R-11 | `audit_ready_not_persisted` naming ambiguity | Low | open (carried) — pre-production naming amendment |
| R-12 | Production registry / signing sequencing constraint not yet recorded | Low | open (carried) — registry must precede signing |
| R-13 | `LEGACY_ALIASES` no deprecation signal | Low | open (carried) — pre-Phase-2 only |
| R-14 | CompatibilityReport backend_identity field not asserted in lib-prep fixture | Low | open (carried) — tolerated by C1-A §5 |
| R-15 | `gate3_authorized` honor-system | Low | open (inherent, documented) — Phase 1 structural limitation |

**All high risks closed. Seven low-severity items, five carried from prior
rounds and two new pre-production notes from R22.**

---

## Handoff

```text
Card: S3-R22-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: phase1-e2e-and-content-address-pressure-v0
Status: complete — PROCEED

[D] Decisions
- C1-P closes P-5: composition proven end-to-end proof-locally without
  production behavior; revoked registry blocks before executor.
- C2-P closes P-4: mutable signed_addendum_ref gap scoped; content-addressed
  reference shape defined; path-only non-compliant.
- Production signing and production registry remain future tracks.
- No hidden Ledger/BiHistory/cache/stream/write path.
- Pre-production checklist updated: P-4 and P-5 closed; P-8 added.

[Agree]
- C1-P and C2-P proof-local and non-authorizing.
- Composition order (registry before executor) now proven behavior.
- Path-only reference structurally non-compliant in three independent cases.
- Production registry/signing not required by either track.

[Challenge]
- C-1 (Low): git_commit placeholder accepted in proof; CI must supply real SHA.
- C-2 (Low): content_sha256 re-computed per invocation; no caching.
- C-3 (Low): Post-R21/R22 fixtures not in canonical regression matrix.

[Route]
- PROCEED.
- Updated pre-production checklist P-1..P-8.

[Next] Pre-production tracks
- durable-observation-persistence-v0 (P-1)
- gate3-authority-registry-v1 (P-2; shape ready from S3-R21-C2-P + S3-R22-C2-P)
- phase1-post-r22-regression-rerun-v0 (P-8; consolidate post-R19 fixtures)
- gate3-production-signing-v1 (P-3; after P-2)
- Phase 2 Ledger adapter addendum (P-7; separate Architect decision)
```
