# Discussion: R37 Deployment, PROP-037, Regression, and Profile Pressure v0

Card: S3-R37-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Track: r37-deployment-prop037-regression-profile-pressure-v0

Question:

Did R37 close all P-50/P-51/P-52 follow-ups without authorizing excluded
surfaces? Does PROP-037 acceptance stay bounded away from parser, runtime, and
fragment class? Does the Stage 3 regression matrix honestly cover the required
surfaces? Does the PROP-036 hash ordering proof stay synthetic with no real
artifact mutation?

Context:
- C1-P (Meta Expert): PROP-032 Ch2 grammar + Heat Map Domain 2 sync; temporal
  audit specimen disposition → P-50 + P-52 closed
- C2-I (Implementation Agent): Durable audit restricted deployment
  implementation; all 7 C1-A follow-ups in proof-local form; 30/30 PASS,
  5/5 invariants, 9/9 regression → P-51 closed (proof-local)
- C3-A (Architect): PROP-037 accepted proposal-only; v0 source_kind vocabulary
  closed; OOF-PR5 is error by default; 5 authorized follow-up design/proof cards
- C4-P (Compiler/Grammar Expert): Full Stage 3 language regression matrix
  19/19 PASS
- C5-P (Compiler/Grammar Expert): PROP-036 artifact hash ordering proof PASS;
  expanded blocker list to 12 items; synthetic material only

---

[Agree]

1. **C1-P scope is clean.** The bounded PROP-032 grammar additions to Ch2
   (top-level `assumptions {}`, named `assumption NAME {}`, `uses assumptions
   NAME`, parsed-only `output ... evidence [...]`) are correctly scoped to
   experiment-pass. PROP-033 validation is explicitly excluded; the evidence
   list remains "present but unvalidated." Heat Map Domain 2 correctly records
   compiler experiment-pass for Parse/Class/TC/SIR with `impl/gov` debt for
   runtime. The temporal audit specimen disposition README correctly marks the
   bundle as non-canonical and not implementation evidence.

2. **C2-I correctly closes P-51 in proof-local form.** All 7 C1-A follow-ups
   (storage identity config, signer abstraction config, startup rebuild
   verification, appender/reader role wiring, refusal code export,
   rollback/disable procedure, post-deployment smoke proof) are delivered as
   proof cases: 30/30 PASS, 5/5 invariants. All surface outputs carry
   `production_durable_audit: false`, `gate3_authorized: false`,
   `ledger: false`. The signer key_id pattern refusal (`noop`/`no-op`/`stub`/
   `local`/`test`) operates without any concrete HSM/KMS binding.
   `FailingRebuildStub` avoids store internal-state manipulation. The 9/9
   regression matrix passes unchanged. The handoff correctly states that
   operational deployment requires separate Architect authorization.

3. **C3-A PROP-037 acceptance is correctly bounded.** The v0 `source_kind`
   closed vocabulary (`clock.every`, `queue`, `external_event`) closes the
   right door: no silently minted new source kinds. `external_event` as the
   descriptor-level extension point correctly permits profile/runtime
   specialization without requiring a new PROP, while a new top-level
   `source_kind` requires a future PROP, errata, or accepted profile-extension
   decision. OOF-PR5 as error by default (service or infinite progression
   without bounded step policy such as `max_step_latency`) is a sound default.
   The 5 authorized follow-up cards are all appropriately design/proof-only.
   No parser, TypeChecker, SemanticIR, RuntimeMachine scheduler,
   Ledger/TBackend, durable queue/checkpoint, receipt sink, production cache,
   production execution, ProgressionPack migration, or new `PROGRESSION`
   fragment class is authorized.

4. **C4-P regression matrix 19/19 PASS is consistent and honest.** The
   coverage map correctly distributes commands across Parser/source, Classifier,
   TypeChecker, SemanticIR, TEMPORAL, STREAM, Contract modifiers, Assumptions,
   Assembler/load guard, and Stage 1/2 baselines. PROP-032 assumptions remain
   green through the full pipeline (Parser → Classifier → TypeChecker →
   SemanticIR). PROP-031 contract modifiers and Stream T remain unaffected by
   PROP-032 experiment-pass. The regenerated proof-owned output artifacts (OLAP
   carrying empty `assumptions: []`, temporal assembler output hash churn,
   Stage 2 timestamp refresh) are correctly characterized as proof-output churn,
   not new semantics.

5. **C5-P PROP-036 hash ordering proof correctly uses synthetic material only.**
   The required ordering (compiler_profile_id present before hash; synthetic
   signature payload covers both artifact_hash and compiler_profile_id) is
   proved. The forbidden ordering (post-sign annotation) is shown to change the
   recomputed hash and fail. The `legacy_optional` policy is preserved. The
   expanded 12-item blocker list is stricter than the previous 7-item list,
   closing additional gaps around real `.igapp` mutation, assembler field
   migration, artifact golden migration, and RuntimeMachine binding.

---

[Challenge]

1. **C2-I handoff staleness on P-43 and P-44.** The C2-I handoff states "Open
   items from prior rounds (P-43 production store rebuild gate, P-44
   PROP-036+ → PROP-037+ updates) remain open and are not addressed by this
   card." Both were closed in S3-R34: P-43 by C2-P (B-D confirmed enforcement),
   P-44 by C3-S (governance sync across 7 files). The C2-I card is reading
   stale planning state at card time. This does not affect proof correctness, but
   creates noise in the checklist. Non-blocker; NB only.

2. **C4-P coverage has a known gap: mundane OOF fixtures.** The regression
   matrix does not include OOF-MA1 (ambient context in pure), OOF-MA2
   (pure-with-escape), and OOF-MA3 (filesystem metadata as pure), extracted by
   R36-C6-P as pressure signals. The recommended follow-up `mundane-oof-
   fixture-plan-v0` was not opened in R37. This is consistent with the
   non-authorization in R36-C6-P; signal extraction is not proof coverage. The
   matrix is not obligated to cover these yet. Non-blocker; follow-up gap.

3. **C3-A authorizes 5 PROP-037 design/proof cards not yet assigned.** None of
   the authorized follow-up cards (descriptor-shape proof, CompatibilityReport
   readiness proof, OOF-PR diagnostic design/proof, profile descriptor
   specialization proof, ProgressionPack boundary plan) were opened in R37. This
   is expected — the acceptance decision precedes card assignment. Non-blocker;
   no P number required at this stage.

---

[Missing]

1. **Architect review of C2-I 7 proof-local outputs.** The C1-A gate explicitly
   required "Architect review of the 7 follow-up outputs before any operational
   rollout authorization is issued." No R37 card provides that Architect review.
   The C2-I handoff correctly names this as the next required step. Opening
   operational deployment from proof-local to production requires a separate
   Architect decision. → **P-53 (new).**

2. **Stage 3 regression coverage for progression (PROP-037).** C4-P runs
   existing proofs only; since PROP-037 was accepted this round, no progression
   proof commands exist yet. The matrix is honest about this limitation. Coverage
   will grow as the 5 authorized PROP-037 follow-up cards are completed.

---

[Sharper Question]

Does the C2-I proof-local form for the 7 C1-A follow-ups satisfy the C1-A §7
requirement, or is the next Architect review intended to also evaluate whether
the bounded scope (no Ledger, no Phase 2, no HSM/KMS, no broad RuntimeMachine)
was preserved — i.e., is P-53 a confirmation review or a second-gate evaluation?

---

[Route]

PROCEED (non-blockers only).

Checklist:
- P-50: CLOSED by C1-P (Ch2 bounded PROP-032 grammar + Heat Map Domain 2 sync;
  PROP-033 excluded)
- P-51: CLOSED proof-local by C2-I (30/30 PASS, 5/5 invariants, 9/9 regression;
  operational deployment still requires separate Architect authorization)
- P-52: CLOSED by C1-P (temporal audit specimen disposition README)
- P-53: NEW — Architect review of C2-I 7 proof-local follow-up outputs before
  operational rollout authorization (per C1-A §7)

Non-blockers (NB):
- NB-1: C2-I handoff lists P-43/P-44 as open; both closed in R34; stale
  tracking artifact only, no proof impact
- NB-2: Mundane OOF fixture plan (OOF-MA1/MA2/MA3) not yet opened; follow-up
  from R36-C6-P remains pending; not a current regression requirement
- NB-3: 5 PROP-037 authorized design/proof cards not yet assigned; authorized
  direction, not a blocker

Next recommended card: Architect review of C2-I 7 proof-local outputs (P-53),
which is the explicit prerequisite for any operational rollout authorization
decision.
