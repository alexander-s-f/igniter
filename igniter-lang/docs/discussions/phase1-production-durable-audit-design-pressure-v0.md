Card: S3-R26-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: phase1-production-durable-audit-design-pressure-v0

Question:
Does the R26 durable audit design stay design-only with no implementation
leakage? Is the signing model recommendation clearly not signing execution
authorization? Is "audit traversal" correctly distinguished from Ledger replay,
stream replay, and OLAP? Does the registry ownership decision prohibit
package/runtime self-authorization? Does the deterministic artifact policy
correctly scope proof fixes without masking real proof failures?

Context:
- S3-R26-C1-P: `phase1-production-durable-audit-v0.md` — production audit
  record schema, signing model, restart rebuild, format version enforcement,
  audit traversal definition, 22 refusal codes, 10 implementation blockers;
  status "Ready for implementation authorization review"
- S3-R26-C2-A: `phase1-production-registry-ownership-decision-v0.md` — gate
  document store as source of truth; generated content-addressed index as query
  artifact; package/runtime prohibited as authority source; 10 blockers before
  registry implementation authorization; status `approved-design-source-of-truth`
- S3-R26-C3-P: `deterministic-regression-artifact-policy-v0.md` — two-tier
  policy (Tier 1 deterministic-by-construction, Tier 2 `_volatile_fields`);
  `SecureRandom.uuid` → `PROOF_STORAGE_IDENTITY` constant in tamper-evidence
  proof; `"_volatile_fields": ["timestamp"]` added to stage2 summary; 23/23
  PASS; P-14 closed
- Context: public-github-only
- Write access: none
- Canon authority: none

---

## Scope-Item Review

| Scope item | Source | Finding | Severity |
|------------|--------|---------|----------|
| Durable audit design stays design-only | C1-P §Status, §Non-Authorization, §10 implementation blockers | Status is "Ready for implementation authorization review" — not an authorization. Implementation blocked by 10 explicit blockers. Non-authorization list covers HSM/KMS execution, external service deployment, Ledger binding, Phase 2, writes/compact/subscribe. Clean. | Pass |
| Signing recommendation is not signing execution authorization | C1-P §Signing Model | Recommends HSM/KMS-backed signer abstraction with injectable interface. Does not name a provider. Does not authorize key generation, key storage, or signing key deployment. Explicitly deferred. No key management instructions present. | Pass |
| "Audit traversal" is not Ledger replay / stream replay / OLAP | C1-P §Audit Traversal definition, §Refusal Codes | Document explicitly states audit traversal is "ordered verification and export of persisted audit records" and is "NOT Ledger replay, runtime replay, write path, compact, subscribe, or cache warming." Twenty-two refusal codes include `audit.ledger_replay_refused` and `audit.stream_replay_refused`. Adopted from S3-R25-X1-S C-2 recommendation. | Pass |
| Registry decision prohibits package/runtime self-authorization | C2-A §Q6, §Non-Authorization | Q6 explicitly prohibits package/runtime from being authority source. Allowed roles: read-only validator, read-only cache, schema checker, local query accelerator. Must not self-issue `gate3_authorized: true`. Must not mutate authority state. Must not own production signing keys by default. | Pass |
| Determinism policy does not mask proof failures | C3-P §Decisions, §Rule 3, §Proof Results | Fix 1 eliminates runtime entropy (`SecureRandom.uuid` → `PROOF_STORAGE_IDENTITY`); hashes remain semantically equivalent — SHA256 over the same proof-data fields. Fix 2 adds `_volatile_fields` annotation; `status`, `checks`, `verdict`, and all boolean check fields remain comparable and must not appear in `_volatile_fields`. 23/23 PASS confirmed. Stability verified by diff of two consecutive runs. | Pass |

---

## Excluded Surfaces Check

| Surface | C1-P closed? | C2-A closed? | C3-P closed? |
|---------|-------------|-------------|-------------|
| Ledger | ✅ non-auth list | ✅ non-auth list | ✅ not referenced |
| BiHistory | ✅ non-auth list | ✅ non-auth list | ✅ not referenced |
| Stream / OLAP | ✅ non-auth + `audit.stream_replay_refused` | ✅ non-auth list | ✅ not referenced |
| Production cache | ✅ non-auth list | ✅ non-auth list | ✅ not referenced |
| Writes / compact / subscribe | ✅ non-auth list + refusal codes | ✅ non-auth list | ✅ not referenced |
| Phase 2 | ✅ non-auth list | ✅ non-auth list | ✅ not referenced |
| Production signing execution | ✅ non-auth list | ✅ non-auth list | ✅ not referenced |
| Production key management | ✅ non-auth list | ✅ non-auth list | ✅ not referenced |

All eight excluded surfaces remain closed across all three R26 cards.

---

## Pre-Production Checklist (cumulative through R26)

| Item | Description | Status |
|------|-------------|--------|
| P-1 | Phase 1 live-read addendum signed by Architect | ✅ closed S3-R19/R20 |
| P-2 | Gate3 guard order: `approval_token → gate_state → backend_identity → scope → cache_key → executor_backend` | ✅ closed S3-R20 |
| P-3 | `gate3_authorized: false` default enforced; caller honor-system documented | ✅ closed S3-R20/R21 |
| P-4 | `signed_addendum_ref` content-addressed (not mutable file path) | ✅ closed S3-R22-C1-P |
| P-5 | Registry → executor → audit composition proven end-to-end | ✅ closed S3-R22-C2-P |
| P-6 | `LEGACY_ALIASES` deprecated; `runtime.temporal_scope_exclusion` canonical | ✅ closed S3-R23-C3-P |
| P-7 | Phase 2 Ledger adapter addendum drafted and authorized | ⏳ not yet started |
| P-8 | Full regression matrix rerun (26-command) passes with no worktree patches | ✅ closed S3-R25-C1-P (26/26) |
| P-9 | Tamper-evidence shape proof committed (SHA256 chain, `storage_identity`, `sequence`) | ✅ closed S3-R24-C3-P |
| P-10 | Production durable audit record schema designed (kind, format_version, excluded_surfaces, chain, signature, retention, compliance_posture) | ✅ closed S3-R26-C1-P (design only; implementation blocked by 10 blockers) |
| P-11 | Production signing model designed (HSM/KMS-backed, injectable, asymmetric, private keys never persisted by audit system) | ✅ design defined S3-R26-C1-P; implementation not yet authorized |
| P-12 | Registry ownership decided: gate document store as source of truth; generated content-addressed index as query artifact | ✅ closed S3-R26-C2-A |
| P-13 | Architect scope decision: production durable audit is design-only, not implementation authorization | ✅ closed S3-R25-C2-A |
| P-14 | Nondeterministic regression artifact policy defined and implemented | ✅ closed S3-R26-C3-P |

---

[Agree]

- C1-P is correctly scoped as design-only. The "Ready for implementation
  authorization review" status is a gate signal, not a grant. The 10
  implementation blockers include schema, signing proof, chain verification,
  traversal proof, freshness-mode statement, and retention model — none of which
  are present as executed proofs, only as design specification. Implementation
  cannot begin without a separate authorization decision.

- The signing model recommendation (HSM/KMS-backed, injectable signer
  abstraction, asymmetric keys, private keys never persisted by audit system) is
  a design requirement, not an execution authorization. No provider is named.
  No key generation is authorized. The injected signer interface means the audit
  system never touches key material directly — a sound boundary for Phase 1
  design.

- "Audit traversal" is correctly defined and correctly fenced. The explicit
  "NOT Ledger replay, runtime replay, write path, compact, subscribe, or cache
  warming" clause and the two explicit refusal codes (`audit.ledger_replay_refused`,
  `audit.stream_replay_refused`) make the boundary machine-checkable. Adopting
  this term from S3-R25-X1-S C-2 is the right move.

- Q6 in C2-A is the strongest registry authority prohibition seen across all R26
  cards. "Package/runtime code must not self-issue `gate3_authorized: true`" and
  "must not own production signing keys by default" are explicit prohibitions,
  not mere recommendations.

- The determinism policy (C3-P) correctly distinguishes between entropy sources
  that affect proof semantics (Fix 1 — replaced with proof-time constants) and
  runtime values that carry informational value (Fix 2 — retained with
  `_volatile_fields` annotation). Rule 4 preserves production semantics at the
  class level — `TamperEvidentObservationStore` still uses runtime UUIDs in
  production; the constant is proof-fixture-local only. The policy does not mask
  failures: 23/23 PASS with identical chain hashes confirms the proof data is
  still exercised correctly.

- Restart rebuild algorithm (11 steps, fail-closed) correctly refuses to
  auto-truncate, auto-compact, or auto-repair. "Fail closed" at step 5 (hash
  mismatch → `audit.restart_rebuild_hash_mismatch`) and step 8 (chain gap →
  `audit.restart_rebuild_chain_gap`) prevents silent corruption.

- Format version enforcement is strict: accepts `1.0.0`; rejects `0.1.0`,
  `0.2.0`, missing, unknown, mixed-version. No implicit migration path exists —
  `audit.format_version_unsupported` terminates the request. Correct.

- C2-A Q4 requiring both git commit SHA and release artifact digest (minimum:
  one of the two; `workspace-current` not acceptable) closes the immutable anchor
  ambiguity identified in earlier rounds. This is stronger than prior rounds
  where only `content_sha256` + `document_path` were named.

[Challenge]

- C-1 (Low) `compliance_posture.production_durable_audit` field transition risk.
  C1-P defines `compliance_posture.production_durable_audit: true` as the value
  for production records, while proof-local records use `false`. The design does
  not describe a validation rule that prevents a mis-configured caller from
  writing `production_durable_audit: true` into a proof-local store, or
  `false` into a production store. The field is informational in the design, not
  enforced by the audit writer. A caller that sets this incorrectly will produce
  misleading compliance signals. Recommendation: the implementation authorization
  review should require a validation proof that the compliance_posture field is
  set and checked by store identity, not by caller assertion alone.

- C-2 (Low) Injectable signer abstraction may delay HSM/KMS in practice.
  The signer is described as an injected interface — the audit system never
  touches key material directly. While this is correct security design, it means
  the audit system's correctness depends entirely on the injected signer being
  production-grade. In proof-local and staging environments, a no-op or
  stub signer could be injected without anyone noticing. The 10 implementation
  blockers do not include a requirement to proof a non-stub signer. Before
  production authorization, the blocker list should include a proof that the
  signer injection point cannot be silently substituted with a no-op in
  production configuration.

- C-3 (Low) "Startup-time" freshness wording ambiguity. C2-A Q2 allows
  "startup-time: runtime/process reads the bundled/generated index at startup."
  This wording does not specify whether "startup" refers to process startup,
  request-handler initialization, or lazy first-use. In a long-running server
  process that restarts rarely, "startup-time" could mean the index is many hours
  or days stale. The freshness SLA is described as "release-time by default" with
  "startup-time" as an explicit variant, but no maximum staleness bound is given
  for the startup-time mode. For Phase 1 design this is acceptable, but the
  implementation authorization review should require a staleness bound.

- C-4 (Low) `_volatile_fields` convention is not lint-enforced. C3-P Q1
  (open question) asks whether `_volatile_fields` should be validated by a lint
  script. Currently it is a convention: regression tooling must skip fields
  listed in `_volatile_fields`, but there is no script that verifies `status`,
  `checks`, and `verdict` are never listed there. A malicious or mistaken proof
  that lists `status` in `_volatile_fields` would make the PASS/FAIL result
  non-comparable across runs — effectively masking a regression. The policy is
  correct in principle but incomplete in enforcement.

[Missing]

- M-1 A `_volatile_fields` lint script (or minimal validator) that confirms
  `status`, `checks`, `verdict`, and all boolean check fields never appear in
  `_volatile_fields` for any committed artifact. Without this, Rule 2 of C3-P is
  a policy commitment with no enforcement path. C3-P Q1 names this gap; it
  remains open.

- M-2 A full artifact stability survey across all `experiments/*/out/*.json` and
  `experiments/*/out/*.jsonl` files not checked in C3-P. The "Remaining Artifact
  Survey" table in C3-P marks several artifacts as "likely stable" without a
  verified diff. Before the next major regression rerun, each committed artifact
  should be verified by the two-consecutive-run `diff` method from C3-P
  Recommendation 1.

- M-3 A validation proof (or design requirement) that `compliance_posture.
  production_durable_audit` is bound to store identity by the audit system, not
  asserted freely by callers. This gap (C-1 above) is not closed by the current
  design.

- M-4 An explicit maximum staleness bound for "startup-time" freshness mode in
  C2-A Q2. The absence of a bound leaves a potential compliance surface undefined
  for long-lived server processes.

[Sharper Question]

Can the durable audit design track's signing model recommendation — HSM/KMS-backed,
injectable signer abstraction, asymmetric keys, private keys never persisted by
audit system — be treated as authorization to select a specific HSM/KMS provider
for a production deployment?

No. The design track describes the interface contract for the injected signer, not
the selection or configuration of a specific provider. Provider selection,
key provisioning, and HSM/KMS onboarding are outside the scope of
`phase1-production-durable-audit-v0` and remain closed until the implementation
authorization review explicitly names a provider or defers that choice to the
deployment team. The injectable interface is precisely what separates design from
execution here.

[Route]

PROCEED (non-blockers only)

All five scope items pass. All eight excluded surfaces are closed. C1-P is
correctly positioned as a design document awaiting implementation authorization.
C2-A is an approved design decision with a complete set of implementation
blockers. C3-P closes P-14 with a verified, policy-conformant fix.

The four challenges (C-1 through C-4) are non-blockers for R26 but should be
addressed before implementation authorization is granted for C1-P.

---

## Compact Risk Table

| Risk | Source | Severity | Blocker? | Mitigation path |
|------|--------|----------|----------|-----------------|
| C-1: `compliance_posture.production_durable_audit` field free-asserted by caller | C1-P §compliance_posture | Low | No | Implementation blocker: bind field to store identity, not caller assertion |
| C-2: Injectable signer admits no-op in production configuration | C1-P §Signing Model | Low | No | Add signer-validation proof to implementation blocker list |
| C-3: "Startup-time" freshness mode lacks maximum staleness bound | C2-A §Q2 | Low | No | Add staleness bound to implementation authorization review |
| C-4: `_volatile_fields` convention not lint-enforced | C3-P Q1 | Low | No | Write `_volatile_fields` lint script; add to regression matrix |

---

## R27 Recommendation

1. **Implementation authorization review for `phase1-production-durable-audit-v0`**:
   Route C1-P to the Architect for an explicit implementation authorization
   decision. The 10 blockers listed in C1-P define the minimum evidence package.
   Add C-1 (compliance_posture store-binding) and C-2 (signer-validation proof)
   from this review to the blocker list before authorization.

2. **`_volatile_fields` lint script**: Implement a small validator (C3-P Q1)
   that reads committed `experiments/*/out/*.json` files and asserts that
   `status`, `checks`, `verdict`, and all boolean check fields are absent from
   `_volatile_fields`. Add it to the regression matrix as a pre-commit or
   CI step.

3. **Full artifact stability survey**: Run the two-consecutive-run `diff`
   method from C3-P Recommendation 1 across all committed artifacts not verified
   in C3-P. Document results in a track or regression matrix entry.

4. **Post-R26 full regression matrix rerun** (27-command or more if new proofs
   added in R26) to confirm no new nondeterminism introduced by C3-P fixes and
   that all 26 prior commands still pass.

5. **Registry implementation planning**: With C2-A `approved-design-source-of-
   truth`, the first registry implementation blocker (generated index schema) can
   be drafted. Route as a new design track under the Architect's registry
   implementation authorization gate (10 blockers in C2-A).
