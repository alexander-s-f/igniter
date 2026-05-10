Card: S3-R28-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: r28-durable-audit-and-prop031-pressure-v0

Question:
Did R28 close the durable audit blockers without accidentally authorizing
production durable audit implementation? Did PROP-031 implementation stay within
proposal scope and avoid Effect Surface/profile/service-loop/runtime enforcement
creep? Does the regression matrix prove the new state, or does it reveal a new
blocking gap?

Context:
- S3-R28-C1-P: `production-durable-audit-blocker-amendment-and-validation-proofs-v0.md`
  — Design amendment + bounded proof harnesses for C1-A Blockers 1, 2, 3, 7;
    `production_durable_audit_compliance_posture_proof` 14/14 PASS;
    `production_durable_audit_signer_validation_proof` 18/18 PASS;
    startup freshness 24h bound + fail-closed rule defined by amendment only;
    Blockers 6 and 8 remain open
- S3-R28-C2 (PROP-031 implementation): Parser/Classifier/TypeChecker/SemanticIR
  emitter updated; `contract_modifiers_proof.rb` runner and golden files committed;
  19/19 checks PASS per C3 discovery; golden files use `"contract_name"` throughout;
  OOF-M1 confirmed firing at Classifier stage (oof_log + fragment_class: "oof")
  and propagated by TypeChecker (type_errors + status: "blocked")
- S3-R28-C3-P: `post-r27-regression-matrix-with-volatile-lint-v0.md`
  — 29-command matrix; 26/29 PASS; 3 FAIL:
    `executor_boundary_cache_key_contract`,
    `executor_approval_token_report_proof`,
    `runtime_smoke_post_switch_full_coverage`;
    root cause: implicit-pure Stage 3 legacy source fixtures containing escape
    declarations now blocked by OOF-M1; C1-A Blocker 6 NOT YET CLOSED
- Context: public-github-only
- Write access: none
- Canon authority: none

---

## Scope-Item Review

### C1 — Durable Audit Amendment and Proofs

| Scope item | Source | Finding | Severity |
|------------|--------|---------|----------|
| compliance_posture cannot be caller-asserted | C1-P §Blocker 1 Amendment + proof `posture.caller_true_claim_ignored_for_proof_local: ok`, `posture.caller_false_claim_ignored_for_verified_production: ok` | Evaluator is the sole source of the boolean. Caller-supplied value ignored. Two explicit checks prove the non-interference in both directions. 14/14 PASS. **Blocker 1 CLOSED.** | Pass |
| No-op/stub signer rejected in production config | C1-P §Blocker 2 Amendment + proof `signer.nil_signer_rejected: ok` through `signer.rejection_carries_reason_code: ok` | Blocked key_id patterns (exact + prefix): local, test, stub, noop, no-op, dev; blocked authority_ref patterns; blocked `public_key_source` substrings (stub, local, test). Valid KMS-ARN signer accepted. 18/18 PASS. **Blocker 2 CLOSED.** | Pass |
| startup_time freshness has bounded staleness + fail-closed | C1-P §Blocker 3 Amendment | 24h maximum staleness bound defined. Fail-closed rule: refuse production gate authority + emit `audit.registry.startup_time_staleness_exceeded` + non-zero exit. Missing/invalid anchor → `audit.registry.startup_time_anchor_invalid`. Per-invocation online lookup explicitly not authorized. Design amendment only — no proof fixture expected. **Blocker 3 CLOSED.** | Pass |
| Production implementation NOT authorized | C1-P §What It Does Not Prove + §Non-Authorization | Evaluator and validator are proof-local interface contracts only. No production audit storage implemented. No production signing key issued or used. No HSM/KMS provider selected. No production deployment authorized. Gate 3 addendum unchanged. | Pass |
| Excluded surfaces remain closed | C1-P §Non-Authorization | Ledger, BiHistory, stream/OLAP, production cache, writes/compact/subscribe, Phase 2, production signing execution, key management, concrete HSM/KMS onboarding, registry implementation, RuntimeMachine binding — all in non-authorization list. | Pass |

### C2 — PROP-031 Implementation

| Scope item | Source | Finding | Severity |
|------------|--------|---------|----------|
| OOF-M1 stage is unambiguous | Golden `oof_m1_pure_with_escape.classified.json` + `oof_m1_pure_with_escape.typed.json`; `contract_modifiers_proof.rb` `oof_m1_fires?` helper checks Classifier output | **S3-R27-X1-S C-3 resolved.** OOF-M1 fires in two stages: (1) Classifier appends to `oof_log` and sets `fragment_class: "oof"` in classified output; (2) TypeChecker propagates as `type_errors` entry with `status: "blocked"` in typed output. Both stages carry the rule code and message. No SemanticIR emitted. Consistent and machine-verifiable at each stage. | Pass |
| SemanticIR uses `contract_name` | Golden `pure_contract_implicit.semantic_ir.json` + `observed_contract_basic.semantic_ir.json`; `contract_modifiers_proof.rb` uses `contract.fetch("modifier")` via standard hash contract | **S3-R27-X1-S C-2 resolved.** All SemanticIR goldens use `"contract_name"` (not `"name"`). C4-P sketch discrepancy was corrected by the implementation. | Pass |
| Backward compatibility: Stage 1-2 PASS | C3-P matrix rows 14 + 15 | Stage 1 close candidate: PASS. Stage 2 close candidate: PASS. PROP-031 acceptance criterion 6 ("All existing Stage 1–2 regression fixtures PASS without modification") is met. | Pass |
| No accidental Effect Surface / profiles / service-loop | PROP-031 non-goals; runner checks bounded to parser/classifier/typechecker/semanticir; no profile-binding tests; no Effect Surface field validation; no service-loop detection | OOF-M2 and OOF-M3 reserved but not implemented. `via profile` not in parser. Effect Surface fields not validated. Runtime enforcement not present. C3 matrix row 29 (`contract_modifiers_proof: PASS`) exercises no profile/Effect Surface path. | Pass |
| No Ledger/Phase2/BiHistory/stream-exec/write/replay | PROP-031 §1 non-goals; runner scope; C3 matrix | PROP-031 is a grammar/compiler change only. No runtime enforcement in Phase 1. The runner calls parser → classifier → typechecker → semanticir — no runtime execution path touched. | Pass |

### C3 — Regression Matrix

| Scope item | Source | Finding | Severity |
|------------|--------|---------|----------|
| Matrix PASS/FAIL summary | C3-P §Command Matrix | 26/29 PASS. **3 FAIL.** C1-A Blocker 6 NOT CLOSED. | **BLOCKER** |
| Nature of failures — scope widening? | C3-P §C1/C2 Discovery + failure diagnostics | Failures are fixture migration regressions, not scope widening. Root cause: `IntegerWindowSum` (stream_fold), `TechnicianJobCountAt` (history_integer_point_access), `SparkCRMBiHistorySourceParity` (sparkcrm_bihistory_source) are implicit-pure Stage 3 source contracts that contain `escape` or `stream` declarations. OOF-M1 correctly blocks them after PROP-031 is implemented. No new surfaces opened. | BLOCKER (migration gap) |
| C1 bounded proof steps in matrix | C3-P rows 27 + 28 | `production_durable_audit_compliance_posture_proof`: PASS. `production_durable_audit_signer_validation_proof`: PASS. New bounded proof surfaces verified within the matrix. | Pass |
| Volatile fields lint as first step | C3-P row 1 | `volatile_fields_lint: PASS`. Lint-first policy respected. | Pass |
| Stage 2 timestamp churn | C3-P §Volatile Artifact Note | Timestamp changed; `_volatile_fields` classification applied; checked-in value restored. Expected behavior, not a regression. | Pass |

---

## Failure Root Cause Analysis

The three regression failures have a single root cause: PROP-031's OOF-M1 rule
correctly detects contracts that are implicitly pure (no modifier keyword) but
contain escape-category declarations. These three Stage 3 fixture source files
predate PROP-031 and were authored without modifiers at a time when no modifier
syntax existed:

| Fixture file | Contract | Escape evidence | Correct modifier |
|--------------|----------|-----------------|-----------------|
| `runtime_smoke_post_switch_full_coverage/inputs/stream_fold.ig` | `IntegerWindowSum` | `stream readings: Integer` (stream = escape-class body) | `observed` |
| `history_type_proof/history_integer_point_access.ig` | `TechnicianJobCountAt` | `escape history_read` (explicit) | `observed` |
| `typed_emission_main_path_parity/sparkcrm_bihistory_source.ig` | `SparkCRMBiHistorySourceParity` | `escape bihistory_read` (explicit) | `observed` |

These are NOT backward compatibility violations of PROP-031 as written — PROP-031
§2.2 and acceptance criterion 6 guarantee Stage 1-2 fixture compatibility, and both
Stage 1 and Stage 2 close candidates pass. These three contracts are Stage 3
integration fixtures and were excluded from the PROP-031 acceptance criterion scope.

However, they ARE in the regression matrix. The matrix cannot pass until the
fixture source files are updated with the correct modifier (or an explicit Architect
or Meta Expert decision designates a different resolution path).

The failures cascade:
1. `stream_fold.ig` blocked by OOF-M1 → `.igapp/manifest.json` not assembled →
   `executor_boundary_cache_key_contract` and `executor_approval_token_report_proof`
   fail reading temporal manifest.
2. `history_integer_point_access.ig` and `sparkcrm_bihistory_source.ig` blocked →
   `runtime_smoke_post_switch_full_coverage` fails on stream/History/BiHistory surfaces.

The fix is three one-line modifier additions. The Compiler/Grammar Expert or
Implementation Agent should add `observed` before `contract` in each of the three
source files, rerun the matrix, and close C1-A Blocker 6.

---

## Pre-Production Checklist (cumulative through R28)

| Item | Description | Status |
|------|-------------|--------|
| P-1 | Phase 1 live-read addendum signed by Architect | ✅ closed S3-R19/R20 |
| P-2 | Gate3 guard order correct | ✅ closed S3-R20 |
| P-3 | `gate3_authorized: false` default enforced | ✅ closed S3-R20/R21 |
| P-4 | `signed_addendum_ref` content-addressed | ✅ closed S3-R22-C1-P |
| P-5 | Registry → executor → audit E2E proven | ✅ closed S3-R22-C2-P |
| P-6 | `LEGACY_ALIASES` deprecated; canonical reason code | ✅ closed S3-R23-C3-P |
| P-7 | Phase 2 Ledger adapter addendum | ⏳ not yet started |
| P-8 | Full regression matrix rerun (no worktree patches) | ⏳ 26/29 in R28 (3 failures — P-22 blocks close) |
| P-9 | Tamper-evidence shape proof committed | ✅ closed S3-R24-C3-P |
| P-10 | Production durable audit schema designed | ✅ design closed S3-R26-C1-P; HOLD confirmed S3-R27-C1-A |
| P-11 | Signing model designed; implementation HOLD | ✅ design defined; signer-validation proof PASS S3-R28-C1-P |
| P-12 | Registry ownership decided | ✅ closed S3-R26-C2-A |
| P-13 | Audit scope decision: design-only | ✅ closed S3-R25-C2-A |
| P-14 | Nondeterministic artifact policy | ✅ closed S3-R26-C3-P |
| P-15 | `_volatile_fields` lint in regression matrix | ✅ lint runs as step 1 in R28 matrix (C3-P row 1 PASS) |
| P-16 | Full artifact stability survey | ✅ closed S3-R27-C2-P |
| P-17 | `compliance_posture` store-bound + verification-bound | ✅ closed S3-R28-C1-P (14/14 PASS) |
| P-18 | Production signer rejects nil/no-op/stub | ✅ closed S3-R28-C1-P (18/18 PASS) |
| P-19 | `startup_time` freshness staleness bound (24h + fail-closed) | ✅ closed S3-R28-C1-P (design amendment) |
| P-20 | Post-R27/R28 regression matrix rerun with volatile lint first | ⏳ 26/29 PASS — blocked by P-22 |
| P-21 | Design amendment to `phase1-production-durable-audit-v0` | ✅ closed S3-R28-C1-P |
| P-22 | Stage 3 legacy fixture modifier migration (3 contracts) | ⏳ not yet done — **blocking P-20** |
| P-23 | PROP-031 regression fixture proof: 19/19 PASS, goldens committed | ✅ closed S3-R28-C2 |

---

[Agree]

- C1-P correctly closes C1-A Blockers 1, 2, 3, and 7 without authorizing
  production durable audit implementation. The proof harnesses demonstrate the
  required interface contracts: evaluator is sole source of `production_durable_audit`
  (caller injection disabled in both directions), signer validator rejects the full
  set of stub/test/local patterns with machine-readable reason codes, and the
  startup freshness policy has a concrete bound and a concrete fail-closed rule. The
  "What This Proves / What It Does Not Prove" section is explicit and complete.

- The compliance posture check `posture.caller_false_claim_ignored_for_verified_production: ok`
  is the most important check in C1-P: it proves that a production store with passing
  chain and signature verification cannot be downgraded to `production_durable_audit: false`
  by a caller. Without this check, a misconfigured caller could silently suppress
  the production compliance signal. The check passes.

- S3-R27-X1-S C-3 (OOF-M1 stage ambiguity) is cleanly resolved by the golden
  artifacts. Classifier sets `fragment_class: "oof"` and appends to `oof_log`
  when a pure contract body contains escape declarations. TypeChecker propagates
  the result as `type_errors` and `status: "blocked"`. The two stages are
  complementary, not contradictory: Classifier is the detection stage, TypeChecker
  is the blocking stage. This two-stage pattern is consistent with the existing
  pipeline architecture.

- S3-R27-X1-S C-2 (`"name"` vs `"contract_name"` field) is resolved. All
  SemanticIR goldens use `"contract_name"`. The implementation matches PROP-031
  §6.1. No golden mismatch is present.

- PROP-031 implementation stays within its declared scope. Effect Surface
  validation (OOF-M2, OOF-M3) not present. Profile binding not present. Service
  loops not present. Runtime enforcement not present. Stage 1 and Stage 2 close
  candidates pass unchanged.

- C3-P correctly classifies the three failures as fixture migration regressions,
  not environment issues or probe errors. The "NOT ready for full R28 Architect
  review" verdict is accurate. The recommendation — add correct modifiers to three
  source files — is the right resolution path.

- P-15 is now fully closed: volatile fields lint runs as step 1 in the 29-command
  matrix (C3-P row 1: PASS). The partial close noted in S3-R27 is now complete.

[Challenge]

- C-1 (Low) PROP-031 §2.2 backward compatibility scope needs explicit Stage 3
  disclosure. The proposal guarantees "All existing fixtures parse without
  modification" and acceptance criterion 6 covers Stage 1-2. The three failing
  Stage 3 fixture contracts (`IntegerWindowSum`, `TechnicianJobCountAt`,
  `SparkCRMBiHistorySourceParity`) predate PROP-031 and were valid before OOF-M1
  existed. They are not covered by the Stage 1-2 backward compat guarantee, but a
  reader of PROP-031 might reasonably expect the regression matrix to pass
  end-to-end. The PROP-031 track or an addendum should explicitly note:
  "Stage 3 integration fixture source files with implicit-pure contracts containing
  escape declarations required one-line modifier migration." This is a documentation
  gap, not an implementation defect.

- C-2 (Low) `startup_time` 24h freshness bound is a design-level default. The
  amendment states "24 hours (86,400 seconds)" without specifying how an operator
  or deployment team signals a different bound. If a production deployment requires
  a tighter bound (e.g., 6h for compliance) or a looser bound (e.g., 48h for
  air-gapped environments), the override mechanism is undefined. The amendment
  notes this risk ("may require adjustment in the implementation track"), but the
  override interface is not designed. Before implementation authorization, the
  design should specify whether the bound is a compile-time constant, a
  configuration parameter, or an environment variable — and whether override
  requires a design amendment.

- C-3 (Low) C1-A Blocker 6 (regression matrix rerun) is not yet closed. The
  matrix runs at 26/29. This means C1-A Blocker 8 (updated pressure review
  confirming all 7 design blockers closed) cannot fully close from this discussion.
  This discussion confirms no scope widening and no premature authorization in C1
  and C2. But the full "blocker package is closed" signal requires P-22 (fixture
  migration) and P-20 (29/29 rerun). Until those close, the implementation
  authorization request to the Architect must wait.

- C-4 (Low) The `stream` input on `IntegerWindowSum` triggers OOF-M1 through
  body-level ESCAPE classification, not through an explicit `escape` keyword. This
  means PROP-031 OOF-M1 also fires when a pure contract contains `stream` inputs
  (which are classified as ESCAPE by PROP-023 body-analysis). The C3 diagnostic
  confirms this (`OOF-M1 pure contract 'IntegerWindowSum' cannot declare escape
  capabilities`). The correct modifier for `IntegerWindowSum` is `observed` (or
  potentially a future `stream` modifier when PROP-032+ lands). This is correct
  behavior, but the PROP-031 documentation does not explicitly describe that
  body-level ESCAPE signals from PROP-023 stream inputs also trigger OOF-M1.
  A single documentation note in PROP-031 §5.1 or §4.1 would clarify the
  composition of PROP-023 + PROP-031 enforcement.

[Missing]

- M-1 Three one-line modifier additions to Stage 3 legacy fixture source files
  (`stream_fold.ig`, `history_integer_point_access.ig`,
  `sparkcrm_bihistory_source.ig`). Adding `observed` before `contract` in each
  file is the minimal correct fix. No other changes required for the three fixtures.

- M-2 A post-migration 29/29 regression matrix rerun confirming all surfaces
  pass including the three previously failing executor/smoke proofs.

- M-3 An explicit backward compatibility addendum note in PROP-031 documenting
  that Stage 3 integration fixtures with implicit-pure + escape bodies required
  modifier migration (C-1). This prevents confusion for future agents reading
  PROP-031 and expecting full matrix compatibility without migration.

- M-4 A startup_time override interface design (C-2). Before implementation
  authorization, the durable audit design should specify the mechanism for
  varying the 24h bound in production deployments.

[Sharper Question]

After the three one-line fixture modifier additions and a 29/29 regression matrix
rerun, does any remaining open item prevent routing a production durable audit
implementation authorization request to the Architect?

Only one: C1-A Blocker 8 ("updated pressure review confirming the blocker package
is closed and implementation scope remains non-Ledger, non-Phase-2, etc."). This
discussion partially satisfies Blocker 8 for C1 and C2 scope — it confirms that
C1-P closes Blockers 1-3 and 7 cleanly, that C2 stays within PROP-031 scope, and
that no new surfaces are opened. The remaining gap is that Blocker 6 (regression
matrix 29/29) is not yet confirmed. Once P-22 and P-20 are closed, this discussion
plus a short confirmatory note from the Architect or Meta Expert closes Blocker 8
and the implementation authorization request can be drafted.

[Route]

PROCEED — with two blockers

C1 (durable audit blockers 1-3 and 7): PROCEED. Correctly closed without
implementation authorization. No scope widening.

C2 (PROP-031 implementation): PROCEED. Within declared scope. OOF-M1 unambiguous.
SemanticIR field names correct. Stage 1-2 backward compat proven. No Effect Surface,
no profiles, no service loops, no runtime enforcement.

C3 (regression matrix): BLOCKED by P-22. Two items must close before C1-A Blocker 6
and Blocker 8 can close:

- **B-1 (Blocker):** Add `observed` modifier to three Stage 3 legacy fixture
  contracts (`IntegerWindowSum`, `TechnicianJobCountAt`,
  `SparkCRMBiHistorySourceParity`). These are one-line changes in three source
  files. No compiler or runtime changes needed.

- **B-2 (Blocker):** Post-migration full regression matrix rerun achieving 29/29
  PASS (with volatile_fields_lint as step 1). This closes C1-A Blocker 6.

All four challenges (C-1 through C-4) are non-blockers but should be addressed
before implementation authorization is signed.

---

## Compact Risk Table

| Risk | Source | Severity | Blocker? | Mitigation |
|------|--------|----------|----------|------------|
| B-1: 3/29 regression failures — legacy fixture OOF-M1 migration gap | C3-P §Failure Classification | Medium | **YES** | Add `observed` modifier to 3 legacy contracts; rerun matrix |
| B-2: C1-A Blocker 6 not closed (regression rerun incomplete) | C3-P verdict | Medium | **YES** | After B-1: 29/29 rerun → Blocker 6 closes |
| C-1: PROP-031 Stage 3 backward compat scope not documented | PROP-031 §2.2 vs C3-P failures | Low | No | PROP-031 addendum noting Stage 3 migration required |
| C-2: startup_time 24h bound lacks override interface design | C1-P §Blocker 3 Amendment | Low | No | Specify override mechanism in design amendment before impl authorization |
| C-3: Blocker 8 (pressure review) not fully closeable until 29/29 | C1-A §Blocker 8 | Low | No | After B-1 + B-2: this discussion + confirmatory note closes Blocker 8 |
| C-4: PROP-023 stream inputs trigger OOF-M1 via body ESCAPE; not documented in PROP-031 | C3-P OOF diagnostic + PROP-031 §4.1 | Low | No | Single documentation note in PROP-031 §5.1 or §4.1 |

---

## R29 Recommendation

1. **Stage 3 fixture migration card** (closes B-1 / P-22): Add `observed` before
   `contract` in each of the three failing source files:
   - `experiments/runtime_smoke_post_switch_full_coverage/inputs/stream_fold.ig`
     → `observed contract IntegerWindowSum`
   - `experiments/history_type_proof/history_integer_point_access.ig`
     → `observed contract TechnicianJobCountAt`
   - `experiments/typed_emission_main_path_parity/sparkcrm_bihistory_source.ig`
     → `observed contract SparkCRMBiHistorySourceParity`
   Rerun matrix immediately in the same card, targeting 29/29 PASS.
   This closes C1-A Blocker 6 and P-20.

2. **Implementation authorization request to Architect** (closes C1-A Blocker 8):
   After R29 Stage 3 fixture migration + 29/29 rerun, route the implementation
   authorization request under C1-A §Held Implementation Scope. The bounded
   surface: audit record schema validation, signer abstraction contract proof,
   append-only store interface proof, restart rebuild proof, format-version
   enforcement proof, audit traversal proof, reader/appender role boundary proof,
   excluded-surface regression proof, regression matrix rerun. This discussion
   serves as the updated pressure review input for Blocker 8.

3. **startup_time override interface design** (closes C-2 / M-4): Before the
   implementation authorization is granted, add a short §3a to the Blocker 3
   amendment specifying how operators specify a non-default freshness bound
   (e.g., environment variable, configuration field, or deployment manifest entry).
   This prevents implementation uncertainty about the 24h constant.

4. **PROP-031 backward compat addendum** (closes C-1 / M-3): Add a one-paragraph
   note to PROP-031 §2.2 or §9 stating that Stage 3 integration fixture source
   files with implicit-pure + escape bodies required one-line modifier migration;
   Stage 1-2 guarantee is met; Stage 3 fixtures are explicitly outside the §2.2
   scope.

5. **PROP-032 planning** (`via profile` binding): With PROP-031 implementation
   complete and Stage 1-2 regression proven, PROP-032 can begin. The
   META-EXPERT-013 Phase 1 sequence is: PROP-031 → PROP-032 → PROP-033. PROP-032
   must not redefine `contract-modifier?` or touch OOF-M1 (per PROP-031 §12).
