Card: S3-R27-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: durable-audit-authorization-and-prop031-pressure-v0

Question:
Does C1-A correctly hold — not grant — production audit implementation
authorization, with all four pressure-derived blockers carried forward? Does C2-P
close the lint and artifact survey blockers without leaving a validator gap that
masks real nondeterminism? Does PROP-031 (C3) stay within its declared
language-lane scope — backward-compatible, pure-default, OOF-M1 only, no
accidental Effect Surface or service-loop implementation? Is C4-P a plan and
nothing more?

Context:
- S3-R27-C1-A: `phase1-production-durable-audit-implementation-authorization-review-v0.md`
  — Architect HOLD; 8 blockers named; implementation remains closed; no surfaces widened
- S3-R27-C2-P: `volatile-fields-lint-and-artifact-stability-survey-v0.md`
  — Lint validator shipped; 4 artifacts checked, 0 violations; two-consecutive-run
    diff survey for all committed proof summaries; three scripts annotated Tier 2
- S3-R27-C3: `PROP-031-contract-modifiers-v0.md`
  — Compiler/Grammar Expert proposal; optional modifier prefix; 5 modifiers;
    backward compatible; pure default; OOF-M1 only TypeChecker change;
    Effect Surface / profiles / service loops all explicitly deferred
- S3-R27-C4-P: `contract-modifiers-proof-fixture-plan-v0.md`
  — Research Agent fixture plan; plan only; no PASS claims; fixtures not yet created
- Context: public-github-only
- Write access: none
- Canon authority: none

---

## Scope-Item Review

### C1/C2 — Production Audit Authorization Safety

| Scope item | Source | Finding | Severity |
|------------|--------|---------|----------|
| C1-A is a HOLD, not a premature authorization | C1-A §Decision | Status is `hold-before-implementation-authorization`. Safe status phrase is explicit. Non-authorization list covers 13 surfaces. Implementation gate remains closed. | Pass |
| Signer validation blocker carried forward | C1-A §2 (Blocker 2) | Required closure signal documented: production signer config rejects nil/no-op/stub/local-test signers and requires trusted signing_key_id, signing_key_version, signing_authority_ref, verification metadata. Not yet closed. | Pass (carried) |
| Compliance_posture binding blocker carried forward | C1-A §1 (Blocker 1) | Required closure signal documented: production_durable_audit: true derived from approved production audit store identity and verification, not caller assertion. Proof-local stores cannot emit true; production stores cannot accept false for successful production append. Not yet closed. | Pass (carried) |
| Freshness staleness bound blocker carried forward | C1-A §3 (Blocker 3) | Required closure signal documented: startup_time freshness has max staleness bound and fails closed when index is older than bound or lacks valid immutable anchor. Per-invocation online lookup not authorized. Not yet closed. | Pass (carried) |
| `_volatile_fields` lint closes C1-A Blocker 4 | C1-A §4 + C2-P §Proof Results | Validator ships in `experiments/volatile_fields_lint/volatile_fields_lint.rb`. PASS (4 artifacts, 0 violations). Protected fields: status, verdict, checks. Required closure signal matches. **Blocker 4 closed by C2-P.** | Pass |
| Full artifact stability survey closes C1-A Blocker 5 | C2-P §Artifact Stability Table | All 11 artifact categories covered. Three regenerating artifacts now annotated Tier 2. `release_gate.json` correctly identified as static (timestamp frozen at authoring). `phase1_tamper_evident_store.jsonl` byte-stable. ~33 other summary JSONs stable by construction. Two-consecutive-run diff survey IDENTICAL for all non-static artifacts. **Blocker 5 closed by C2-P.** | Pass |
| Excluded surfaces remain closed | C1-A §Non-Authorization | Ledger, BiHistory, stream/OLAP, production cache, writes/replay/compact/subscribe, Phase 2, production signing execution, key management, concrete HSM/KMS onboarding, registry implementation, RuntimeMachine binding — all in non-authorization list. | Pass |

### C3/C4 — PROP-031 Language-Lane Safety

| Scope item | Source | Finding | Severity |
|------------|--------|---------|----------|
| Backward compatibility guarantee | PROP-031 §2.2 | "A `contract` declaration without a modifier is equivalent to `pure contract`. The parser normalises both to the same AST node. All existing fixtures parse without modification." Acceptance criterion 6: "All existing Stage 1–2 regression fixtures PASS without modification." Explicit and verifiable. | Pass |
| Pure default | PROP-031 §2.2, §3.5 Stage 1 | "When the source has no modifier keyword the parser normalises to `"pure"`." Modifier field always present after parsing. Missing → `"pure"` normalization also present defensively in SemanticIR emitter (§6.1). | Pass |
| OOF-M1 clarity | PROP-031 §5.1 | Code `OOF-M1`, severity `error`, message template exact: `"pure contract '#{name}' cannot declare escape capabilities; use 'observed' for read-only external access"`. Trigger condition unambiguous. **Challenge: stage ambiguity — see C-3 below.** | Partial |
| No accidental profiles | PROP-031 §1 non-goals, §12 | "`via profile` binding — deferred to PROP-032." PROP-032 dependency section explicitly states "must not re-define `contract-modifier?`" and "must not touch OOF-M1 code". No profile compiler pass, no profile declaration parser, no profile authority resolution in PROP-031. | Pass |
| No accidental Effect Surface | PROP-031 §1 non-goals, §3 | "No Effect Surface validation (deferred to PROP-035)." OOF-M2 and OOF-M3 reserved but deferred to PROP-035. `effect`, `privileged`, `irreversible` modifiers accepted syntactically; no Effect Surface field validation in PROP-031 scope. | Pass |
| No accidental service-loop implementation | META-EXPERT-013 §III Phase 3, PROP-031 scope | Service loops are Phase 3 (Stage 4 deferred). Not referenced in PROP-031, not in modifier set, not in C4-P fixture plan. | Pass |
| C4-P is plan only, no PASS claims | C4-P §Status | "This plan is not executable yet and no PASS result is claimed." Experiment directory not yet created. Fixtures are sketches. Command matrix described as future expected commands "after implementation". | Pass |

---

## Excluded Surfaces Check (All R27 Cards)

| Surface | C1-A | C2-P | PROP-031 (C3) | C4-P |
|---------|------|------|----------------|------|
| Ledger | ✅ non-auth list | ✅ not referenced | ✅ not referenced | ✅ not referenced |
| BiHistory | ✅ non-auth list | ✅ not referenced | ✅ not referenced | ✅ not referenced |
| Stream / OLAP | ✅ non-auth list | ✅ not referenced | ✅ not referenced | ✅ not referenced |
| Production cache | ✅ non-auth list | ✅ not referenced | ✅ not referenced | ✅ not referenced |
| Writes / compact / subscribe | ✅ non-auth list | ✅ not referenced | ✅ not referenced | ✅ not referenced |
| Phase 2 | ✅ non-auth list | ✅ not referenced | ✅ "runtime enforcement — Phase 2" | ✅ not referenced |
| Production signing execution | ✅ non-auth list | ✅ not referenced | ✅ not referenced | ✅ not referenced |
| Effect Surface (PROP-035) | ✅ not referenced | ✅ not referenced | ✅ deferred PROP-035 | ✅ not referenced |
| Service loops | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ not referenced |
| Profiles / authority | ✅ not referenced | ✅ not referenced | ✅ deferred PROP-032/034 | ✅ not referenced |

All excluded surfaces remain closed across all four R27 cards.

---

## Pre-Production Checklist (cumulative through R27)

| Item | Description | Status |
|------|-------------|--------|
| P-1 | Phase 1 live-read addendum signed by Architect | ✅ closed S3-R19/R20 |
| P-2 | Gate3 guard order: `approval_token → gate_state → backend_identity → scope → cache_key → executor_backend` | ✅ closed S3-R20 |
| P-3 | `gate3_authorized: false` default enforced; caller honor-system documented | ✅ closed S3-R20/R21 |
| P-4 | `signed_addendum_ref` content-addressed (not mutable file path) | ✅ closed S3-R22-C1-P |
| P-5 | Registry → executor → audit composition proven end-to-end | ✅ closed S3-R22-C2-P |
| P-6 | `LEGACY_ALIASES` deprecated; `runtime.temporal_scope_exclusion` canonical | ✅ closed S3-R23-C3-P |
| P-7 | Phase 2 Ledger adapter addendum drafted and authorized | ⏳ not yet started |
| P-8 | Full regression matrix rerun passes with no worktree patches | ✅ closed S3-R25-C1-P (26/26); **post-R27 rerun pending (C1-A Blocker 6)** |
| P-9 | Tamper-evidence shape proof committed (SHA256 chain, `storage_identity`, `sequence`) | ✅ closed S3-R24-C3-P |
| P-10 | Production durable audit record schema designed (design only; 10 design blockers) | ✅ design closed S3-R26-C1-P; implementation HOLD confirmed S3-R27-C1-A |
| P-11 | Production signing model designed (HSM/KMS-backed, injectable, asymmetric) | ✅ design defined S3-R26-C1-P; implementation HOLD confirmed; signer-validation proof required before authorization |
| P-12 | Registry ownership decided: gate document store as source of truth | ✅ closed S3-R26-C2-A |
| P-13 | Architect scope decision: production durable audit is design-only | ✅ closed S3-R25-C2-A |
| P-14 | Nondeterministic regression artifact policy defined and implemented | ✅ closed S3-R26-C3-P |
| P-15 | `_volatile_fields` lint script in regression matrix | ⏳ script shipped S3-R27-C2-P; matrix integration recommended but not yet committed |
| P-16 | Full artifact stability survey complete (two-consecutive-run diff, all committed artifacts) | ✅ closed S3-R27-C2-P |
| P-17 | `compliance_posture.production_durable_audit` bound to store identity + verification (C1-A Blocker 1) | ⏳ design amendment + proof required |
| P-18 | Production signer injection rejects nil/no-op/stub signers (C1-A Blocker 2) | ⏳ design amendment + proof required |
| P-19 | `startup_time` registry freshness has max staleness bound + fail-closed (C1-A Blocker 3) | ⏳ design amendment required |
| P-20 | Post-R27 full regression matrix rerun (including volatile_fields_lint as first step) | ⏳ not yet run |
| P-21 | Design amendment to `phase1-production-durable-audit-v0` recording P-17/P-18/P-19 requirements | ⏳ not yet drafted |

---

[Agree]

- C1-A HOLD is the correct decision. "Ready for implementation authorization
  review" means review is complete; it does not mean authorization is granted.
  The Architect correctly differentiates between accepting the design as a
  strong candidate and authorizing implementation. The 8 blockers are concrete,
  verifiable, and non-trivially closed — they cannot be satisfied by a single
  design card alone.

- C2-P closes two of the eight C1-A blockers precisely: Blocker 4
  (`_volatile_fields` lint, validator runs with 0 violations, protected fields
  enforced) and Blocker 5 (artifact stability survey, all 11 artifact categories
  documented, two-consecutive-run diff IDENTICAL for all non-static artifacts).
  The validator scope decision — only files with both `status` and
  `_volatile_fields` — is correctly permissive: it avoids false positives from
  golden/fixture files while enforcing the annotation policy for all proof
  summaries that have adopted it.

- C2-P's treatment of `release_gate/release_gate.json` is correct. The file is
  a manually-committed release decision document with a timestamp frozen at
  authoring time (2026-05-08T11:16:25Z). It is not regenerated by any proof
  script. No annotation is needed; the rationale is documented.

- PROP-031 is a genuinely additive, backward-compatible grammar extension. The
  optional modifier prefix before `contract` does not affect any existing
  production. The parser normalizes missing modifier to `"pure"` — this is the
  correct default for backward compatibility and for proof that `contract Foo`
  and `pure contract Foo` produce identical ASTs. Acceptance criterion 6
  (Stage 1–2 regression fixtures PASS unchanged) makes this machine-verifiable.

- The PROP-031 non-goals list is complete and specific. Effect Surface
  validation (OOF-M2, OOF-M3, Effect Surface fields) is deferred to PROP-035.
  Profile binding is deferred to PROP-032. Authority resolution is deferred to
  PROP-034+035. Runtime enforcement of modifier semantics is Phase 2. The
  PROP-032/033 dependency section (§12) explicitly lists what each downstream
  PROP must NOT touch, preventing OOF-M1 modification or modifier production
  redefinition. This is the correct boundary mechanism for sequential PROP
  authorship.

- C4-P is correctly scoped as a planning artifact. It makes no PASS claims,
  creates no files, and defers all implementation to the next card. The fixture
  sketches accurately reflect PROP-031's acceptance criteria. The open question
  (Stage 1-2 golden migration policy for `modifier: "pure"` field addition) is
  correctly identified and explicitly deferred to the implementation card.

- META-EXPERT-013's three-phase ordering (Phase 1: PROP-031/032/033 additive
  grammar; Phase 2: PROP-034/035 new lane with Architect decision; Phase 3:
  service loops deferred) prevents scope creep by requiring Architect
  authorization before any new compiler pass (policy-gate enforcement for
  profile declarations, Effect Surface validation).

[Challenge]

- C-1 (Low) C2-P validator does not detect unannotated `Time.now` fields. The
  validator only enforces annotation correctness for files that already declare
  `_volatile_fields`. A new proof script that calls `Time.now` and writes a
  `timestamp` field without adding `"_volatile_fields" => ["timestamp"]` will
  not be caught. The validator PASS does not signal that the coverage is complete
  — only that what exists is valid. C2-P §Recommendation 4 names this gap and
  provides the correct mitigation: `grep -rn "Time\.now" igniter-lang/experiments/
  --include="*.rb"`. This grep audit must be performed manually before any new
  proof script is committed, or automated as a pre-commit hook. Until then, the
  `_volatile_fields` policy remains convention-enforced for new additions, not
  fully machine-enforced.

- C-2 (Low) C4-P fixture plan uses `"name"` in its SemanticIR expected JSON
  shapes while PROP-031 §3.5 Stage 4 and §6.1 Note use `"contract_name"`.
  Specifically, C4-P's "SemanticIR Modifier Field Shape" section shows:

  ```json
  { "kind": "contract_ir", "name": "ReadSensor", "modifier": "observed", ... }
  ```

  while PROP-031 §3.5 Stage 4 shows:

  ```json
  { "kind": "contract_ir", "contract_name": "ScoreRisk", "modifier": "pure", ... }
  ```

  and §6.1 Note explicitly states: "`contract_name` is the correct field name
  in the actual SemanticIR emitter (not `'name'`)." If the implementation card
  follows PROP-031's field name and C4-P's golden fixtures use the wrong name,
  the golden check will fail. The implementation card or C4-P amendment must
  align field names before goldens are locked.

- C-3 (Low-Medium) OOF-M1 fires at an ambiguous pipeline stage in PROP-031.

  PROP-031 §3.5 Stage 2 (Classifier output) describes:

  > "OOF-M1 fires here when `modifier == "pure"` and body contains `escape` —
  > the `oof_log` entry is appended and `fragment_class` becomes `"oof"`."

  PROP-031 §5 is titled "TypeChecker Changes" and §5.1 describes OOF-M1 as
  a TypeChecker rule. The implementation notes at §13 say:

  > "TypeChecker change: after body analysis, if `modifier == "pure"` and any
  > node is ESCAPE, emit OOF-M1."

  C4-P's command matrix also implies TypeChecker stage:

  > "`--typecheck` → PASS: positives typed, `oof_m1_pure_with_escape` rejected
  > with OOF-M1"

  The inconsistency: §3.5 Stage 2 places `oof_log` and `fragment_class: "oof"`
  in Classifier output; §5.1 and §13 place OOF-M1 detection in the TypeChecker.
  Both cannot be true simultaneously unless the Classifier detects a
  proto-violation and the TypeChecker issues the final OOF-M1 code. If the
  Classifier sets `fragment_class: "oof"` independently, the TypeChecker would
  be redundant for this case. If the TypeChecker is the sole emitter, §3.5
  Stage 2's `oof_log` entry is premature.

  Before golden fixtures are locked, the implementation card must explicitly
  decide: which stage fires OOF-M1 and which stage's output carries `oof_log`?
  If Classifier identifies the pure+escape conflict and TypeChecker formalizes
  it, the boundary (which stage sets `fragment_class: "oof"` and which appends
  to `oof_log`) must be defined. This is a design gap, not an implementation
  detail — it affects golden shape at the Classifier output level.

- C-4 (Low) C1-A Blocker 8 ("updated pressure review confirming the blocker
  package is closed and implementation scope remains non-Ledger etc.") is not
  closeable by this discussion alone. This discussion is a status check on R27
  work-in-progress, not a confirmation that Blockers 1-3 are closed. The
  Architect must not interpret this PROCEED as closing Blocker 8. Blocker 8
  requires a subsequent pressure review after P-17/P-18/P-19 are closed and the
  design amendment (P-21) is in place.

[Missing]

- M-1 A grep-based or AST-based pre-commit hook that detects `Time.now`
  (or `Time.now.utc`) usage in `experiments/**/*.rb` and flags any script that
  writes a JSON artifact without a corresponding `_volatile_fields` annotation.
  C2-P Q1 names this; it remains open.

- M-2 An explicit decision on the OOF-M1 pipeline stage (Classifier vs.
  TypeChecker) and the corresponding golden artifact shape at each stage.
  The implementation card cannot lock golden fixtures until this is resolved.
  Required output: one sentence in the implementation card specifying which stage
  appends to `oof_log` and which sets `fragment_class: "oof"`.

- M-3 Alignment of C4-P SemanticIR expected shapes to use `"contract_name"`
  (not `"name"`) per PROP-031 §6.1. The implementation card or a C4-P amendment
  must correct this before golden fixtures are committed.

- M-4 The path to closing C1-A Blockers 1-3 (compliance_posture store-binding,
  signer no-op rejection, startup freshness bound) requires a design amendment
  to `phase1-production-durable-audit-v0` (C1-A Blocker 7 / P-21). This
  amendment is not yet drafted. Without it, Blocker 8 (pressure review) cannot
  close, and implementation authorization cannot be requested.

[Sharper Question]

Do any of C1-A Blockers 1-3 (compliance_posture store-binding, signer no-op
rejection, startup freshness staleness bound) require a new authorized
implementation track before they can be closed, or can they be closed by design
amendment to `phase1-production-durable-audit-v0` alone?

Blocker 3 (startup freshness bound) can be closed by design amendment — it is a
policy statement requiring a maximum staleness value and a fail-closed rule.
Blockers 1 and 2 require proof artifacts (a validation proof that
`production_durable_audit` is store-bound, and a signer-validation proof that
no-op/stub signers are rejected in production configuration). These proofs do
not require implementation of the full durable audit system — they can be closed
by bounded proof fixtures that demonstrate the validation interface contract.
A design amendment that specifies the validation interface plus a companion proof
card that exercises stub/no-op rejection would close both. No new Gate and no
new production implementation track is required — a targeted proof card under
the existing design authorization is sufficient.

[Route]

PROCEED (non-blockers only)

C1-A correctly holds implementation authorization — this is not a premature grant.
C2-P closes two C1-A blockers (lint and artifact survey) cleanly. PROP-031 is
within its declared language-lane scope: backward-compatible, pure-default,
OOF-M1 only, no Effect Surface, no profiles, no service loops. C4-P is a plan
with no PASS claims.

The four challenges (C-1 through C-4) are non-blockers for R27 but must be
resolved before implementation authorization can be requested:
- C-2 and C-3 must be resolved before PROP-031 golden fixtures are locked.
- C-4 must be acknowledged: this discussion does not close C1-A Blocker 8.

---

## Compact Risk Table

| Risk | Source | Severity | Blocker? | Mitigation |
|------|--------|----------|----------|------------|
| C-1: Validator does not catch newly-added unannotated `Time.now` fields | C2-P §Recommendation 4 | Low | No | Grep audit before each new proof script commit; consider pre-commit hook |
| C-2: C4-P SemanticIR shape uses `"name"` vs PROP-031's `"contract_name"` | C4-P §SemanticIR Shape vs PROP-031 §6.1 | Low | No (but golden conflict risk) | Align field names in C4-P amendment or implementation card before goldens locked |
| C-3: OOF-M1 fires in §3.5 Stage 2 (Classifier) AND §5.1 (TypeChecker) — stage ambiguity | PROP-031 §3.5 vs §5.1 vs §13 | Low-Medium | No (but implementation gap) | Implementation card must explicitly decide OOF-M1 stage and golden shape before fixtures committed |
| C-4: C1-A Blocker 8 (pressure review confirming blockers closed) not yet satisfiable | C1-A §Blocker 8 | Low | No | Requires subsequent pressure review after P-17/P-18/P-19 and P-21 are closed |

---

## R28 Recommendation

1. **Design amendment to `phase1-production-durable-audit-v0`** (closes C1-A
   Blocker 7 / P-21): Amend the track to record Blockers 1-3 as explicit
   implementation requirements: compliance_posture store-binding specification,
   signer injection contract (no-op rejection rule), and startup-time freshness
   maximum staleness bound. A companion proof card (bounded fixture) for Blockers
   1-2 can be sequenced immediately after the amendment.

2. **Post-R27 full regression matrix rerun** (closes C1-A Blocker 6 / P-20):
   Add `volatile_fields_lint` as the first step. Include any new proof steps
   added in R27. Target: all prior commands PASS plus lint PASS.

3. **PROP-031 implementation card**: Implement parser/classifier/typechecker/
   semanticir emitter changes. Resolve OOF-M1 stage ambiguity (C-3) and
   `"contract_name"` field name (C-2) before committing golden fixtures. Decide
   Stage 1-2 golden migration policy for `modifier: "pure"` field addition.
   Run Stage 1 and Stage 2 close candidate regressions.

4. **C1-A Blocker 8 pressure review** (after P-17/P-18/P-19 and P-21 close):
   A targeted follow-up pressure review confirming that the design amendment
   correctly closes Blockers 1-3 and that implementation scope remains within
   the bounded surface from C1-A §Held Implementation Scope. This is the final
   gate before an implementation authorization request can be routed to the
   Architect.

5. **`_volatile_fields` grep pre-commit hook** (addresses C-1 / M-1): Implement
   a lightweight hook or CI step that greps `experiments/**/*.rb` for `Time.now`
   and cross-references against committed `_volatile_fields` annotations. Add to
   regression matrix alongside `volatile_fields_lint`.
