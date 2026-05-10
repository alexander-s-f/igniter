Card: S3-R29-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: r29-authorization-and-canon-pressure-v0

Question:
Did the Architect authorization decision land in R29, and if not, did the absence
produce any unauthorized implementation? Did the startup freshness override design
avoid ambient runtime policy leaks? Did the PROP-031 compatibility addendum and
Covenant/CSM additions clarify canon without inventing unapproved semantics?

Context:
- S3-R29-C1 (Architect durable audit implementation authorization): NOT FOUND in
  gates/; deferred. R28-C5-S status curation confirms: "Production durable audit
  implementation remains not authorized and not landed."
- S3-R29-C2-P: `startup-time-freshness-override-interface-v0.md` — Design-only;
  authority-signed policy model; constant default + deployment manifest pointer;
  allowed range 1h–72h; >24h needs signed reason + expiry; >72h needs governance;
  fail-closed on every invalid input; no per-invocation online lookup; no proof yet
- S3-R29-C3-P: `prop031-compatibility-addendum-r29-v0.md` — §14 added to PROP-031;
  resolves C-1 and C-4 from S3-R28; documents Stage 3 migration; locks OOF-M1
  Classifier-detection + TypeChecker-propagation ownership; temporal precedence rule
  (V-3) formally documented in §4.1 and §14.4; 7 errata corrected; doc-only
- S3-R29-C4-P: `covenant-accountability-postulates-r29-v0.md` — Core Axioms
  expanded to two (Honesty + Accountability); Postulate 27 (Accountability as
  Architecture) + Postulate 28 (No Unnamed Block); PROP Governance Filter (V-2)
  as top-level Covenant section; 3 open questions (OQ-1/2/3); doc-only
- S3-R29-C5-P: `canonical-semantic-model-bootstrap-r29-v0.md` — CSM entity index
  created at `docs/dev/canonical-semantic-model.md`; all implemented entities have
  golden anchors; spec_candidates correctly carry no anchor; 8 missing anchors
  logged; OOF codes: 6 active (anchored), 3 deferred (no anchor); doc-only
- Also read: `agent-d-cross-review-values-and-meta-cards-r28-v0.md` (R28-C4-P) —
  confirmed B-1 (fixture migration) and B-2 (29/29 matrix) from S3-R28-X1-S closed;
  temporal precedence fix landed in classifier.rb; full post-R28 proofs PASS;
  and `stage3-round28-status-curation-v0.md` (R28-C5-S) — confirms 29/29 PASS
- Context: public-github-only
- Write access: none
- Canon authority: none

---

## Pre-Review: R28 Open Items Resolution

From S3-R28-X1-S, two blockers remained:

| Blocker | Resolution | Evidence |
|---------|-----------|----------|
| B-1: Stage 3 legacy fixture modifier migration (4 contracts) | CLOSED — R28-C4-P added `observed` modifier to `IntegerWindowSum` (×2 locations), `TechnicianJobCountAt`, `SparkCRMBiHistorySourceParity`; classifier fix for V-3 temporal precedence also landed | R28-C4-P §R28 Regression Fix Record |
| B-2: Post-migration 29/29 regression matrix rerun | CLOSED — R28-C4-P full matrix 10/10 key surfaces PASS; R28-C5-S confirms "Final sequential rerun PASS 29/29 with volatile lint first" | R28-C5-S §Discovery + §Status Separation |

C1-A Blockers 1-7 are now confirmed closed. C1-A Blocker 8 (updated pressure review confirming blocker package closed and scope non-Ledger) is what this discussion partly satisfies — but the Architect implementation authorization (C1) did not land in R29. See §C1 finding below.

---

## Scope-Item Review

### C1 — Architect Durable Audit Implementation Authorization

| Scope item | Source | Finding | Severity |
|------------|--------|---------|----------|
| Authorization decision landed | Gates directory inspection | **C1 did NOT land in R29.** No new gate document in `docs/gates/` from R29. The only durable-audit gate remains `phase1-production-durable-audit-implementation-authorization-review-v0.md` (S3-R27-C1-A, `hold-before-implementation-authorization`). | Finding (not a blocker) |
| Unauthorized implementation attempted | R28-C5-S §Status Separation | No. "Production durable audit implementation remains not authorized and not landed." All R29 tracks (C2-C5) are design/governance/documentation only. No proof harnesses added for production audit writer, signer execution, or storage — only for the override interface design (C2) which has no proof script in R29. | Pass |
| Startup freshness override design presented as implementation | C2-P §Purpose, handoff, R30 section | C2-P is explicitly "Design-only." No proof script added in R29. R30 implementation recommendation provided. The design was written to address S3-R28-X1-S C-2 before Architect decides whether to authorize the full system. Correct sequencing. | Pass |
| Excluded surfaces remain closed | R28-C5-S §Status Separation; C2-C5 non-authorization lists | All excluded surfaces remain closed: Ledger, Phase 2, BiHistory, stream/OLAP, production cache, writes/compact/subscribe, production signing execution, key management, HSM/KMS onboarding, registry implementation, RuntimeMachine binding. Gate 3 signed Phase 1 scope unchanged. | Pass |

### C2 — Startup_time Override Model

| Scope item | Source | Finding | Severity |
|------------|--------|---------|----------|
| No hidden mutable runtime policy source | C2-P §Decision, §Rejected Alternatives | Direct env-var, local config field, and plain deployment manifest seconds values are all rejected. Override authority is the signed policy document, not the operator shell or process. Env var may only specify manifest path, never the bound value. The fail-closed behavior (missing policy → refuse, hash mismatch → refuse, invalid sig → refuse, expired → refuse) prevents any fallback to a looser bound. | Pass |
| No per-invocation online lookup | C2-P §No Online Lookup Compatibility | Policy bytes must be bundled or mounted before startup. Manifest carries a content hash. Authority validation uses local verification metadata available at startup. Check runs once at startup. This fully preserves the R28 no-online-lookup invariant. | Pass |
| Allowed range is bounded and governed | C2-P §Allowed Override Range | 1h–72h with signed policy; >72h requires new Architect decision; <1h refused; >72h refused. Default 24h requires no policy. Rational bounds with governance trigger at 72h. | Pass |
| Override doesn't bypass signer-validation | C2-P §Authorization Model | Step 3 requires format_version recognition; step 6 requires signature verification against trusted metadata; step 7 requires policy not expired. The same stub/local/test blocking pattern from the signer validation proof (R28-C1-P) applies to policy authorities. | Pass |

### C3 — PROP-031 Compatibility Addendum

| Scope item | Source | Finding | Severity |
|------------|--------|---------|----------|
| S3-R28 C-1 (Stage 3 compat scope) closed | C3-P §14.1 + §14.2 | §14.1 confirms Stage 1/2 PASS with no fixture changes. §14.2 documents Stage 3 migration: three contracts + source locations required `observed` modifier; rationale documented. **C-1 closed.** | Pass |
| S3-R28 C-4 (stream triggers OOF-M1 via ESCAPE) closed | C3-P §14.3 | Explicitly documents that `stream` input body-level ESCAPE classification triggers OOF-M1 under PROP-031. Migration pattern provided. **C-4 closed.** | Pass |
| S3-R28 C-3 (OOF-M1 stage ambiguity) formally locked | C3-P §14.5, §5.1 renamed, §13 corrected | `Classifier detects (modifier=="pure" + ESCAPE body → oof_log + fragment_class:"oof"); TypeChecker propagates (oof_log → type_errors + status:"blocked"); SemanticIR nil`. Unambiguous three-stage ownership documented in both §14.5 and corrected implementation notes §13. | Pass |
| Temporal precedence (V-3) formally documented | C3-P §14.4, §4.1 corrected | `observed + temporal body → fragment_class: "temporal"; observed + escape body → fragment_class: "escape"`. Correction in §4.1 removes the erroneous "regardless of body content" clause. §14.4 anchors this to the R28 classifier.rb fix. | Pass |
| No new grammar or code changes | C3-P §Scope Boundaries | "This card makes no code changes. No grammar was modified. No new OOF codes were introduced." §10.1/§10.2/§10.4 corrections apply to PROP document specimens only; actual proof fixtures already use valid syntax. | Pass |

### C4 — Covenant Accountability Postulates

| Scope item | Source | Finding | Severity |
|------------|--------|---------|----------|
| No unapproved semantics introduced | C4-P §Scope Boundaries | No compiler semantics created or modified. No new grammar. No PROP-032 authored. V-3 correctly stays in PROP-031 §14.4, not promoted to a Covenant postulate. V-5 (`form`) appears in P27 table as spec-candidate classification, not authorization. | Pass |
| Governance Filter does not bypass PROP lifecycle | C4-P §PROP Governance Filter (V-2) | The filter is an acceptance criterion (audit-legibility test) applied at PROP review time. It constrains what PROPs may do; it does not authorize any new surface itself. Future PROPs still require the same Compiler/Grammar Expert → Research Agent → Architect pathway. | Pass |
| P27 primitive table confined to classification | C4-P §Postulate 27 | Table entries are "accountability role" classifications of existing primitives, not new capabilities. `form` constructors appear as spec-candidate and are noted as "classification, not authorization." | Pass |
| P28 enforcement gap correctly disclosed | C4-P §OQ-1 | The card explicitly acknowledges that unnamed-block enforcement is not yet wired for all constructs. P28 is a governing commitment, not a current enforcement claim. Compiler/Grammar Expert assigned the gap verification. | Pass |

### C5 — Canonical Semantic Model (CSM)

| Scope item | Source | Finding | Severity |
|------------|--------|---------|----------|
| No entity marked `implemented` without golden anchor | C5-P §Golden anchor status + §Entities without anchors | All implemented entities have verified golden paths (checked against disk). Spec_candidate entities have no anchor. OOF-I1/I3/I5 are deferred with no anchor (correctly labeled). Receipt is `implemented` for FFI shape only; production shape is correctly labeled PROP-035 scope. | Pass |
| No proposal lifecycle bypass | C5-P §R30 Recommendations | OOF-I deferred codes recommendation: "No new PROP needed — add an addendum to PROP-025." This is a correct lifecycle path (addendum to existing PROP, not bypass). PROP-032 (assumptions) is correctly "route to Compiler/Grammar Expert for PROP draft." | Pass |
| CSM maintenance rule in document | C5-P §R30 Recommendations | "If you add a new entity to the compiler, add a row here. If the row has no golden anchor, the status is spec_candidate." Cited as a rule the Compiler/Grammar Expert should consult before adding new parser nodes or fragment classes. | Pass |

---

## Excluded Surfaces Check (All R29 Cards)

| Surface | C1 (absent) | C2 | C3 | C4 | C5 |
|---------|-------------|----|----|----|----|
| Ledger | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ not referenced |
| Phase 2 | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ not referenced |
| BiHistory (production) | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ spec_candidate only |
| Stream/OLAP (production) | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ spec_candidate only |
| Production cache | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ not referenced |
| Production signing execution | ✅ not referenced | ✅ design-only | ✅ not referenced | ✅ not referenced | ✅ not referenced |
| Effect Surface (PROP-035) | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ spec_candidate in P27 | ✅ spec_candidate in CSM |
| Profiles (PROP-032/034) | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ not referenced | ✅ spec_candidate only |

All excluded surfaces remain closed. Effect Surface and Profile System appear in governance/CSM contexts only as spec_candidate, not as authorized or implemented.

---

## Pre-Production Checklist (cumulative through R29)

| Item | Description | Status |
|------|-------------|--------|
| P-1 through P-16 | (closed prior rounds) | ✅ all closed |
| P-17 | `compliance_posture` store-binding | ✅ closed R28-C1-P |
| P-18 | Signer no-op rejection | ✅ closed R28-C1-P |
| P-19 | startup_time 24h bound + fail-closed | ✅ closed R28-C1-P (amendment) |
| P-20 | Post-regression matrix 29/29 PASS | ✅ closed R28-C4-P + R28-C5-S |
| P-21 | Design amendment to durable audit track | ✅ closed R28-C1-P |
| P-22 | Stage 3 fixture modifier migration (4 contracts) | ✅ closed R28-C4-P |
| P-23 | PROP-031 proof: 19/19 PASS, goldens committed | ✅ closed R28 |
| P-24 | startup_time override interface designed (policy-ref model) | ✅ design closed R29-C2-P; proof pending R30 |
| P-25 | PROP-031 compatibility addendum (Stage 3 migration + OOF-M1 stage + V-3) | ✅ closed R29-C3-P |
| P-26 | Covenant Postulates 27-28 + PROP Governance Filter | ✅ closed R29-C4-P |
| P-27 | CSM entity index with golden anchors | ✅ closed R29-C5-P |
| P-28 | Architect production durable audit implementation authorization decision | ⏳ deferred — C1 did not land in R29 |
| P-29 | startup_time override proof-local validator (policy-ref model) | ⏳ R30 — C2-P proof matrix defined |
| P-30 | V-3 temporal+observed proof golden in contract_modifiers_proof | ⏳ R30 — no dedicated golden yet |
| P-31 | META-EXPERT-013 §VI reconciliation with PROP Governance Filter | ⏳ R30 or later |
| P-32 | PROP-032 (assumptions block) draft | ⏳ R30 — Gap-H HIGH priority |

---

[Agree]

- C1 deferral is safe. The R29 tracks (C2-C5) contain zero implementation
  work. All are design, documentation, or governance. The absence of an Architect
  authorization decision does not create a gap — it is the correct sequencing
  posture. The startup freshness override design (C2) was completed in R29 to give
  the Architect a fuller picture before authorizing the implementation. Deferring C1
  until C2 is designed is more rigorous than authorizing implementation with an
  underspecified override model.

- C2's authority-signed policy model is the correct design response to S3-R28-X1-S
  C-2. The key insight is that operator-observable values (the freshness seconds
  bound) must not be caller-mutable without an authority chain. Placing the bound in
  a content-addressed, authority-signed policy document — with a deployment manifest
  pointer and content hash — closes the ambient env-var leak. The env-var being
  allowed only as a manifest path pointer (never as the bound value itself) is the
  precise boundary that prevents policy-as-env-variable anti-pattern.

- C2's fail-closed table is exhaustive: every invalid override path produces a
  machine-readable refusal code and prevents production gate authority from being
  enabled. The "never silently falls back to a looser bound" invariant is
  explicitly stated and each failure case carries a distinct code. The observation
  shape (both accepted and refused) is fully specified, making the design auditable.

- C3 cleanly resolves all three S3-R28-X1-S pressure items (C-1, C-4, M-3).
  The §14 addendum is self-contained and does not alter any previously proven
  behavior. The errata corrections to §10 fixture specimens are harmless because
  the actual proof fixtures already use valid syntax — these were PROP document
  presentation errors, not implementation defects.

- C4's distinction between Axiom 1 (Honesty) and Axiom 2 (Accountability) is
  philosophically sharp: a program can be honest about what it does without the
  audit infrastructure being able to reference, trace, or replay it. Both must hold.
  Postulate 27's primitive-accountability table is the right anchor for evaluating
  future feature proposals: does this primitive make execution reality more legible,
  or less? Postulate 28's unnamed-block prohibition follows directly from P27: if
  something has semantic consequence but no name, it cannot appear in a receipt.

- C5's golden-anchor constraint is the most important CSM design decision: an
  entity is at most `spec_candidate` until it has a golden file on disk. This
  prevents the CSM from becoming a waterfall design document that accumulates
  aspirational rows without implementation evidence. The 8-item missing-anchor log
  is explicit about what doesn't yet exist. The OOF code registry separation —
  6 active (anchored) vs 3 deferred (no anchor) — correctly shows the policy
  coverage boundary.

- R28-C4-P's B-1 fix (four contract modifier additions + classifier.rb temporal
  precedence fix) and R28-C5-S's 29/29 PASS confirmation close all remaining S3-
  R28-X1-S blockers. The regression matrix is now clean through R28 evidence.

[Challenge]

- C-1 (Low) C2 tighter policy documents (< 24h) do not require `expires_at`. The
  Allowed Override Range table only requires "non-empty reason and expires_at" when
  `max_age_seconds > 86400`. An operator could issue a 1-hour policy document with
  no expiry — meaning that tighter policy remains valid indefinitely until manually
  revoked. For production deployments where tighter policies are issued to enforce
  compliance windows (e.g., "registry must be refreshed within 6h during trading
  hours"), an eternal tight policy creates a false security posture if the deployment
  moves to a longer-refresh period without updating the policy. The design should
  consider requiring `expires_at` for all non-default policy documents, not just
  those above 24h.

- C-2 (Low) C2's authority_ref string
  (`architect-supervisor://igniter-lang/production-audit/freshness-policy/v1`)
  implies a production Architect signing authority that does not yet exist as a
  concrete key or registry entry. For proof-local validation (the R30 target), a
  test authority fixture would substitute — but the R30 proof matrix note
  ("no production authority registry implementation beyond proof-local trusted
  authority fixtures") is the only guidance. The R30 implementation card should
  explicitly specify which test authority fixture patterns are acceptable and which
  must be rejected (applying the same blocked-pattern logic as the R28 signer
  validation proof). Without this specification, the R30 proof card may use
  permissive test authorities that would be invalid in production.

- C-3 (Low) C4 Postulate 28 enforcement gap (OQ-1) creates a Covenant commitment
  that exceeds current compiler capability. The risk is not that P28 is wrong —
  it is the correct long-term commitment — but that future agents reading the
  Covenant may treat P28 as currently enforced for all listed constructs (escape,
  loop classes, assumptions, constraints). Only unnamed `invariant` blocks are
  currently enforced at parse time. The Compiler/Grammar Expert response to OQ-1
  should produce a gap table committed somewhere accessible (not just acknowledged),
  and it should be tracked. Leaving OQ-1 as an open question without a tracked
  deliverable risks it becoming permanent background noise.

- C-4 (Low) C4 PROP Governance Filter (OQ-2) and META-EXPERT-013 §VI coexist
  without reconciliation. A Compiler/Grammar Expert writing a PROP looks at
  META-EXPERT-013 §VI for acceptance criteria and at the Covenant for governing
  principles, but these are currently two separate documents with no normative
  cross-reference. The first time the filter blocks or reframes a PROP, the source
  of authority will be contested. Scheduling the reconciliation as a concrete R30
  deliverable (not just a recommendation) would prevent that confusion.

- C-5 (Low) C3 §14.4 documents the V-3 temporal precedence rule as
  "implementation behavior" derived from the R28 classifier.rb fix. The handoff
  correctly notes it should become a formal Classifier spec rule in a PROP-028
  addendum or PROP-031 revision. However, the contract_modifiers_proof golden set
  contains no fixture for an `observed contract with temporal reads →
  fragment_class: "temporal"`. The only `observed` golden (`observed_contract_basic`)
  uses a plain `escape` declaration and correctly produces `fragment_class: "escape"`.
  The V-3 path (observed + temporal → temporal) is exercised by the runtime smoke
  tests (History/BiHistory contracts with `observed` modifier now pass), but these
  are integration-level proofs, not isolated golden fixtures for the classifier rule
  itself. An `observed contract ReadHistory { escape history_read; history[T] ... }
  → fragment_class: "temporal"` golden in contract_modifiers_proof would close the
  CSM's "Temporal Read" entry's interaction with PROP-031 modifiers and give V-3 an
  independently verifiable anchor.

- C-6 (Low) C5 CSM entry for "Loop class" (spec_candidate, Stage 3 Language Lane)
  does not note that loop classes require an Architect Lane authorization per
  META-EXPERT-013 §III Phase 2. A reader of the CSM might assume loop classes are
  simply the next PROP-03x after PROP-031/032/033, when they actually require a
  new Architect-authorized lane before any implementation begins. A parenthetical
  "(requires new Architect Lane authorization, META-EXPERT-013 §III Phase 2)" in
  the CSM loop class rows would prevent premature implementation attempts.

[Missing]

- M-1 A proof-local validator for the startup freshness override interface (C2-P
  R30 proof matrix). The R30 card should implement and run all 15+ cases from the
  proof matrix before the Architect considers this surface ready for production
  deployment. No proof exists yet — design only.

- M-2 An `observed contract with temporal reads → fragment_class: "temporal"` golden
  fixture in `contract_modifiers_proof/` to anchor V-3 independently of integration-
  level smoke tests (C-5 above). This closes the CSM "Temporal Read + PROP-031
  modifier interaction" gap and provides a machine-verifiable proof that V-3 holds
  after any future classifier changes.

- M-3 The Compiler/Grammar Expert OQ-1 response: a gap table for P28 enforcement
  (currently enforced vs. governing commitment) committed to a document that can be
  tracked — either as an addendum to C4-P or as a standalone Q1 track. An open
  question without a tracked deliverable is likely to remain open indefinitely.

- M-4 A concrete Architect implementation authorization decision (C1). The full
  R28-R29 evidence package is now assembled: 29/29 PASS, compliance posture proof
  (14/14), signer validation proof (18/18), startup freshness design (C2-P),
  pressure review (this discussion). The Architect has all inputs needed to either
  authorize or explicitly decline a bounded implementation track.

[Sharper Question]

Is there any remaining design or proof gap that would justify further deferral of
the Architect production durable audit implementation authorization decision beyond
R30?

The startup freshness override design (C2-P) is complete as a design. The R30 proof
validator (M-1) is specified and scoped. The proof can run in R30 independent of the
authorization decision — it validates the override interface, not the full durable
audit implementation. If the Architect authorizes a bounded implementation track in
R30, the override proof can be part of the bounded implementation scope. There is no
remaining design gap that requires resolution before authorization: all C1-A blockers
are closed (Blockers 1-7), the full regression matrix passes 29/29, and the pressure
review (this discussion) confirms no scope widening. Deferring authorization beyond
R30 would require explicitly naming a new blocking condition. No such condition is
visible in the R29 evidence.

[Route]

PROCEED (non-blockers only)

C1 (absent): safe deferral. No unauthorized implementation. All R29 tracks are
design/governance/documentation only. Excluded surfaces confirmed closed.

C2 (startup freshness override): PROCEED. Sound authority-signed policy model.
No ambient env-var leak. No online lookup. Fail-closed on all invalid inputs.
Four challenges (C-1 through C-4 below) are non-blockers for R29.

C3 (PROP-031 compat addendum): PROCEED. All S3-R28-X1-S pressure items resolved.
OOF-M1 stage locked. Temporal precedence formally documented. No code changes.

C4 (Covenant): PROCEED. Governance framework correctly layered. Three open
questions (OQ-1 to OQ-3) are non-blockers but should become tracked deliverables
in R30.

C5 (CSM): PROCEED. All implemented entities have golden anchors. Spec_candidates
correctly labeled. CSM maintenance rule in document. No proposal lifecycle bypass.

---

## Compact Risk Table

| Risk | Source | Severity | Blocker? | Mitigation |
|------|--------|----------|----------|------------|
| C-1: Tighter freshness policy (<24h) has no required `expires_at` | C2-P §Allowed Override Range | Low | No | Require `expires_at` for all non-default (non-24h) policy documents |
| C-2: Proof-local authority fixture for freshness policy ref not yet specified | C2-P §R30 proof matrix | Low | No | R30 implementation card must define accepted vs. rejected test authority patterns |
| C-3: P28 enforcement gap (OQ-1) untracked; risks becoming permanent debt | C4-P §OQ-1 | Low | No | Compiler/Grammar Expert gap table as tracked R30 deliverable |
| C-4: PROP Governance Filter and META-EXPERT-013 §VI not reconciled (OQ-2) | C4-P §OQ-2 | Low | No | Schedule META-EXPERT reconciliation as concrete R30 deliverable, not recommendation |
| C-5: V-3 temporal+observed case has no dedicated proof golden | C3-P §14.4 + C5-P CSM; golden inspection | Low | No | Add `observed + temporal body → fragment_class: "temporal"` fixture to contract_modifiers_proof |
| C-6: CSM loop class entry lacks Lane authorization requirement note | C5-P CSM entity table | Low | No | Add "(requires Architect Lane authorization, META-EXPERT-013 §III Phase 2)" note to loop class rows |

---

## R30 Recommendation

1. **Architect production durable audit implementation authorization decision** (closes P-28):
   The full evidence package is complete. The R28 design/proof/regression package
   (29/29 PASS, 14/14 compliance posture, 18/18 signer validation, startup freshness
   design, pressure reviews) and R29 governance work (Covenant, CSM, PROP-031
   addendum) give the Architect all inputs. The authorization should specify a bounded
   implementation track scoped to: audit record schema validation, signer abstraction
   contract proof, append-only store interface proof, restart rebuild proof, format-
   version enforcement proof, audit traversal proof, reader/appender role boundary
   proof, excluded-surface regression proof, and post-implementation regression rerun.

2. **startup_time override proof-local validator** (closes P-29):
   Implement the C2-P R30 proof matrix (15+ cases). Specify accepted vs. rejected
   test authority patterns before starting (closing C-2). Whether or not the
   Architect authorizes the full durable audit implementation in R30, this validator
   should land as a standalone proof card to close the override interface design loop.

3. **V-3 temporal+observed proof golden** (closes P-30):
   Add `observed contract ReadHistory { escape history_read; ... } → fragment_class:
   "temporal"` fixture to `contract_modifiers_proof/golden/`. This gives V-3 an
   independently machine-verifiable anchor and closes the CSM gap for PROP-031 +
   History[T] modifier interaction.

4. **P28 enforcement gap table** (tracks C-3):
   Compiler/Grammar Expert documents which constructs have P28 currently enforced
   (invariant names: yes; escape declaration naming: verify; loop classes: N/A, not
   implemented; assumptions: N/A, not implemented; constraints: N/A, not implemented).
   Committed as a doc-appendix to C4-P or a standalone note in the Covenant.

5. **META-EXPERT-013 §VI + PROP Governance Filter reconciliation** (closes P-31):
   A targeted META-EXPERT addendum or a new §VI note in META-EXPERT-013 that cites
   the Covenant PROP Governance Filter as normative. This ensures PROP authors
   consult the filter without needing to cross-reference two independent governance
   documents.

6. **PROP-032 (assumptions block) draft** (closes P-32):
   Gap-H is HIGH priority. The R29-C4-P Meta Expert agenda and R28-C4-P both flag
   PROP-032 as the next PROP. The Research Agent fixture exploration should begin
   alongside the PROP draft — minimum fixture: one positive (named assumption used
   in contract body) and one OOF case (undeclared assumption used in contract body).
