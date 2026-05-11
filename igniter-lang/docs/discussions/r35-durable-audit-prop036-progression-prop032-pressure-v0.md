# Discussion: R35 Durable Audit B-D, PROP-036 Acceptance, PROP-037 Assignment, and PROP-032 Phase 4 Pressure

Card: S3-R35-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: r35-durable-audit-prop036-progression-prop032-pressure-v0
Date: 2026-05-11

---

## Context

Five R35 items reviewed.

| Track / Gate | Card | Role | Status |
|---|---|---|---|
| `durable-audit-post-implementation-regression-matrix-v0` | S3-R35-C1-P | Implementation Agent | done |
| `stage3-round35-status-curation-v0` | S3-R35-C2-S | Meta Expert (Status Curator) | done |
| `prop036-compiler-profile-id-acceptance-decision-v0` (gate) | S3-R35-C3-A | Architect Supervisor | accepted-proposal-only |
| `progression-prop-number-assignment-decision-v0` (gate) | S3-R35-C4-A | Architect Supervisor | approved-numbering-only |
| `prop032-assumptions-phase4-parser-proof-v0` | S3-R35-C5-P | Compiler/Grammar Expert | done |

---

## Scope Item Review

| Item | Scope check | Result | Notes |
|------|-------------|--------|-------|
| Ledger / Phase 2 | C1-P excluded-surface regression: all closed; "Ledger adapter/writes/replay/compact/subscribe: ABSENT", "Phase 2: ABSENT" | PASS | |
| BiHistory | C1-P non-auth list explicit; not present in any R35 card | PASS | |
| Stream / OLAP production executor | C1-P non-auth: "stream/OLAP production executor ABSENT"; C3-A non-auth; C4-A non-auth | PASS | |
| Production cache | C1-P: "production cache ABSENT"; all other tracks confirm | PASS | |
| Concrete HSM / KMS | C1-P: "concrete HSM/KMS onboarding ABSENT"; C1-P excluded-surface regression confirms | PASS | |
| RuntimeMachine binding | C1-P non-auth; C3-A non-auth: "RuntimeMachine binding / execution authority"; C4-A non-auth; C5-P non-auth (no runtime receipt) | PASS | |
| `.igapp` manifest migration | C3-A non-auth: "creating or editing .igapp manifest output"; C4-A non-auth: "assembler or .igapp changes"; C5-P non-auth | PASS | |
| Production deployment | C1-P: "This card does not open production deployment … production deployment ABSENT"; C3-A non-auth | PASS | |
| B-D truly covers all durable audit proofs | C1-P ran 9 commands: all four post-implementation durable audit scripts + compliance posture + signer validation + bounded impl + volatile lint + startup freshness; 97/97 durable audit proof cases PASS | PASS | B-D scope is durable-audit-only, not a full language pipeline regression — correct given its title |
| P-43 remains enforced in regression context | C1-P Surface 3 confirmation table: all 5 P-43 cases confirmed PASS; `audit.writer.rebuild_not_clean` remains the required refusal code | PASS | |
| B-E not opened prematurely | C1-P: "Recommendation: ready for B-E Architect deployment review … This is not deployment authorization"; C2-S: "B-E is review-ready, not approved" | PASS | |
| PROP-036 acceptance did not authorize implementation | C3-A acceptance: 12-item acceptance criteria PASS; "accepted-proposal-only" status; 16-item non-authorization list; 7-item implementation blocker list before any code card | PASS | |
| PROP-037 assignment did not authorize parser / runtime / fragment class | C4-A: 14-item non-authorization list explicit: "No parser syntax, No TypeChecker/SemanticIR/assembler/.igapp, No RuntimeMachine scheduler, No new PROGRESSION fragment class" | PASS | |
| PROP-032 Phase 4 did not absorb PROP-033 evidence-list validation | C5-P: "[X] No PROP-033 evidence-list validation"; evidence `[...]` parsed passively, not validated; "[R] Do not bundle PROP-033 or runtime receipt work into the experiment-pass decision" | PASS | |
| Status curation did not mask open blockers | C2-S correctly identified B-D closed, B-E not approved, and all excluded surfaces closed. However C2-S was completed before C3-A and C4-A landed | **NB** | C2-S stale on PROP-036 and PROP-037 status — see Risk R-1 |
| C4-A follow-up docs sync | C4-A requires proposals/README.md update: add PROP-037, remove PROP-037+ placeholder, move managed recursion to PROP-038+; no R35 card applied these because C2-S ran before C4-A | **NB** | See Risk R-2 |

---

## Risk Table

| # | Risk | Severity | Owner |
|---|------|----------|-------|
| R-1 | C2-S same-round ordering miss: the R35 status curation completed before C3-A (PROP-036 acceptance) and C4-A (PROP-037 assignment) landed. C2-S records PROP-036 as "authored-pending-review" and progression as "unassigned at PROP-037+ placeholder" — both of which are now superseded by R35 Architect decisions. C2-S's R36 recommendation lists "PROP-036 acceptance" and "PROP-037+ assignment" as R36 items when both landed in R35. This is the first round where the curation card itself carries stale forward-looking recommendations. A fresh agent reading only C2-S before R36 will believe two decisions are pending when both are done. | Medium | Meta Expert (R36 curation sync) |
| R-2 | C4-A follow-up docs not applied: C4-A requires three doc syncs — proposals/README.md (add PROP-037, remove PROP-037+ row, move managed recursion to PROP-038+ placeholder), tracks/README.md, and current-status.md. None were applied in R35 because C2-S predated C4-A. Current proposals/README.md and current-status.md still reflect pre-C4-A state. These are doc-only gaps, but they create a misleading PROP queue state for any agent reading docs cold. | Medium | Meta Expert (R36 curation sync) |
| R-3 | B-D scope note needed: C1-P is titled "durable audit post-implementation regression matrix" and covers 9 proof scripts, all durable-audit-scoped. This is the correct scope. However, there is no separate full-language regression matrix for the Stage 3 pipeline (parser, classifier, typechecker, semanticir, assembler regressions combined). C1-P is a closed sub-regression, not a general Stage 3 health check. Future planners should not treat B-D PASS as evidence that the full language pipeline is regression-clean after PROP-032 Phase 4 landed. | Low | Meta Expert |
| R-4 | PROP-032 experiment-pass recommendation is from Compiler/Grammar Expert only. C5-P says "PROP-032 is ready for experiment-pass review." This is a recommendation, not a decision — correct posture. But there is no R35 card from Architect or Meta Expert accepting this recommendation. The experiment-pass governance decision (CSM/heat-map updates, proposal lifecycle promotion, status update) has no owner yet. Without routing, the recommendation will float the same way the manifest PROP floated before P-41. | Low | Architect / Meta Expert |
| R-5 | C3-A "authorized next design/proof cards" list is in a gate doc that also contains the non-authorization list. If a future card cites C3-A acceptance as its authorization without going through the 7-item implementation blocker list, the gate's acceptance could be misread as opening implementation. The blocker list is clear but requires the referencing card to re-enumerate it. | Low | Compiler/Grammar Expert (authoring any C3-A follow-up card) |

---

## Pre-Production Checklist Update

| Item | Status | Closed by |
|------|--------|-----------|
| P-43: Production store append must gate on clean rebuild status | ✅ closed | S3-R34-C2-P |
| P-44: PROP-036+ → PROP-037+ renaming for managed recursion | ✅ closed | S3-R34-C3-S |
| P-45: PROP-036 acceptance gate | ✅ **closed** | S3-R35-C3-A — accepted-proposal-only; 7-item blocker list before implementation |
| P-46: PROP-037+ formal assignment | ✅ **closed** | S3-R35-C4-A — PROP-037 assigned to External Progression and Service Liveness Semantics |
| P-47 (NEW): PROP-032 experiment-pass governance decision — Architect/Meta Expert formal status decision + CSM/heat-map/proposal lifecycle updates needed | 🔲 open | Compiler/Grammar Expert evidence ready (C5-P); Architect/Meta Expert decision pending |
| P-48 (NEW): C4-A follow-up doc sync — proposals/README.md, current-status.md, tracks/README.md not yet updated with PROP-037 assignment; managed recursion placeholder not yet moved to PROP-038+ | 🔲 open | Meta Expert; required before any agent reads the PROP queue cold in R36 |
| P-49 (NEW): C2-S curation stale on PROP-036/PROP-037 status — current-status.md and gates/README.md reflect pre-C3-A/C4-A state | 🔲 open | Meta Expert (R36 curation sync) |

---

## [Agree]

- **C1-P B-D is correctly scoped and thorough within its mandate.** 9/9 commands PASS, 97/97 durable audit proof cases. P-43 is confirmed still enforced with the deterministic `audit.writer.rebuild_not_clean` code across 5 cases. B-B and B-C cumulative state is correctly confirmed as closed. No excluded surface widened. The recommendation "ready for B-E Architect deployment review" is correctly phrased — it identifies readiness without claiming authorization.

- **C3-A PROP-036 acceptance is tight and correctly structured.** The 12-item acceptance criteria review is explicit. The 16-item non-authorization list is comprehensive. Most importantly, the 7-item implementation blocker list correctly gates all four named implementation cards (assembler, loader, golden migration, receipt link) behind acceptance + separate Architect authorization. The four "authorized next design/proof cards" are well-scoped: loader status report as proof-local states only, artifact hash ordering via synthetic material only, assembler field as design-only, receipt link as design-only. No `.igapp`, no production loader, no real golden mutation.

- **C4-A PROP-037 assignment is correctly narrow.** Numbering and routing only. The required boundaries section explicitly preserves all four Chapter 13 managed loop classes. The fragment class prohibition is explicit: "must not introduce a new PROGRESSION fragment class unless a later accepted proposal proves capability/manifest metadata is insufficient." The `external_event` open-vocabulary question is correctly named as a follow-up requirement for the authoring card. C4-A does not author the proposal, which is the right gate ordering.

- **C5-P Phase 4 stays cleanly within PROP-032 scope.** Evidence list round-trips through the parser passively — no PROP-033 validation. OOF-P28 fires at the parser boundary for unnamed assumptions (before the classifier path). The source-to-SemanticIR fixture uses the typed pipeline, not a shortcut. The spec-lag note (Ch2 source grammar sync needed) is correctly flagged as a deferred governance/status promotion task rather than something claimed now. The experiment-pass recommendation routes to Architect/Meta Expert rather than self-authorizing.

- **C2-S correctly identified the same-round B-B drift from R34 and fixed it.** The curation note on C2-P's Open Blockers table was the right repair. P-43 and P-44 closure and the dual proposals/README.md consistency check were done. The curation correctly did not edit proposals/README.md or gates/README.md for decisions it hadn't seen.

---

## [Challenge]

- **C2-S is now the stale map for PROP-036 and PROP-037 — and it's the primary planning document.** The curation records PROP-036 as "authored-pending-review" and progression as "unassigned at PROP-037+ placeholder." Both are factually wrong as of R35: PROP-036 was accepted (C3-A) and PROP-037 was assigned (C4-A) in the same round. C2-S's R36 recommendation repeats these as pending actions when both are done. An agent entering R36 from C2-S alone will incorrectly schedule two decisions that are already closed. This is a medium-severity planning hazard, not a language or scope hazard — but it is the highest-impact same-round ordering miss in this X1-S series because it affects the primary forward-planning document rather than an implementation card's blocker table.

- **C4-A follow-up items are unowned in R35.** Three doc syncs are explicitly required by C4-A: proposals/README.md (add PROP-037, remove PROP-037+ row, move managed recursion to PROP-038+), and current-status.md/tracks/README.md acknowledgement. None were applied because C2-S ran before C4-A. This is a named follow-up gap with no R35 owner — P-48 adds it to the checklist but without a named R36 card it will recur.

- **PROP-032 experiment-pass recommendation has no route.** C5-P recommends experiment-pass review but does not route to a specific card or agent. The R35 curation (C2-S) does not mention PROP-032 experiment-pass in its R36 recommendation (because C2-S predated C5-P). So neither the curation track nor the governance routing lists this as a concrete R36 item. Without a named acceptance card, PROP-032 will remain at "Phase 4 done" status indefinitely.

---

## [Missing]

- **No B-D-owned summary artifact was produced.** C1-P decision [D2] explicitly deferred to existing proof-owned summaries. This is a reasonable design choice — B-D is a command-matrix closure, not a new proof surface. But it means there is no single artifact that names "B-D closed" with a date and case count. Any future agent looking for a B-D closure artifact will find only the track doc, not a JSON summary artifact. This is a low-risk gap but should be noted in the next status curation.

- **Full language pipeline regression (PROP-032 Phase 4 + existing regressions together) was not explicitly run.** C1-P ran 9 durable-audit-scoped commands. C5-P ran 10 commands focused on assumptions proof. Neither ran a combined check across durable audit, temporal, stream, classifier, assumptions together. `stage1_close_candidate` PASS in C5-P is the closest signal, but its scope is Stage 1 specifically. If the full Stage 3 pipeline is not explicitly green-lit after Phase 4 parser changes, there is no proof that parser.rb assumptions changes did not disturb existing non-assumption parse paths.

- **proposals/README.md PROP-037 assignment not yet applied.** C4-A's first follow-up item requires updating proposals/README.md. This is explicitly not done in R35.

---

## [Sharper Question]

- **For C1-P:** B-D reran 9 proof scripts. The `volatile_fields_lint` and `startup_freshness_override_proof` scripts are not durable-audit proofs — they were in the R31 regression matrix as general language health checks. Were they included in B-D because they were in the R31 regression matrix, or because they are necessary for the deployment review? If B-E (Architect deployment review) depends on B-D as its readiness evidence, the B-E reviewer should understand which proofs are durable-audit-specific and which are general language health guards.

- **For C5-P:** The parser now parses `output evidence [name, ...]` passively and round-trips it without validation. Does the parser emit the evidence list in the `ParsedProgram` output? If yes, future agents reading the parsed AST may see evidence list entries and assume they are validated. The distinction between "present in AST" and "validated by compiler" needs to be visible in the ParsedProgram output — e.g., a flag `evidence_validation: "deferred_prop033"` — to prevent a future SemanticIR or assembler card from accidentally treating parsed evidence as accepted.

- **For C3-A:** The four authorized design/proof cards are named. Is any of them unblocked in parallel, or must they run in sequence? Specifically, does `prop036-artifact-hash-ordering-proof-v0` require `prop036-loader-status-report-proof-v0` to complete first (because hash participation changes what the loader status vocabulary applies to), or can they run in parallel?

---

## [Route]

**R36 recommendation (priority order):**

1. **[Meta Expert] R36 status sync (P-48 + P-49)**: Apply C4-A follow-up items to proposals/README.md (add PROP-037, remove PROP-037+ row, move managed recursion to PROP-038+ or unnumbered placeholder). Update current-status.md and gates/README.md to reflect PROP-036 accepted + PROP-037 assigned. Correct C2-S stale descriptions. Run before any other R36 card so agents start from an accurate planning baseline.

2. **[Architect] B-E production deployment review**: B-D is the readiness evidence. All excluded surfaces remain closed. B-E is a separate Architect authorization decision — it should explicitly name whether any of the excluded surfaces (production signing, HSM/KMS, production storage) are opened, conditionally opened, or remain closed after B-E.

3. **[Meta Expert + Architect] PROP-032 experiment-pass governance decision (P-47)**: All Phases 1-4 passed. The evidence is complete: parser grammar, OOF-P28, classifier (OOF-A1), TypeChecker (OOF-A1 propagation, TASSUMP-1), SemanticIR lowering, CompilationReport. Governance actions: proposal lifecycle promotion, CSM/heat-map/proposals README update, Ch2 source grammar sync (C5-P spec-lag note). Do NOT include PROP-033 evidence-list validation.

4. **[Compiler/Grammar Expert] PROP-036 proof card (C3-A-authorized)**: Either `prop036-loader-status-report-proof-v0` or `prop036-artifact-hash-ordering-proof-v0` as the first design/proof card. Must cite C3-A as authorization and enumerate all 7 implementation blockers to confirm they remain blocked. Must not edit real `.igapp` goldens or production artifact output.

5. **[Compiler/Grammar Expert] PROP-037 authoring card**: Number assigned; scope defined. Author formal PROP-037 text. Must explicitly answer whether `external_event` is a closed initial vocabulary item or an open extension point (C4-A follow-up requirement). Must not claim parser, TypeChecker, SemanticIR, RuntimeMachine, or fragment class authority.

---

## Verdict

**PROCEED — non-blockers only.**

R35 closed B-D (97/97 proof cases PASS), accepted PROP-036 (proposal-only, implementation blocked behind 7-item list), assigned PROP-037 (numbering-only), and completed PROP-032 Phase 4 (full parser path through SemanticIR). No excluded surface was widened. B-E is correctly positioned as review-ready but not authorized. PROP-032 Phase 4 did not absorb PROP-033 validation. PROP-036 acceptance did not open implementation. PROP-037 assignment did not authorize parser or runtime work.

One medium-risk non-blocker: C2-S (the primary R36 planning document) is stale on PROP-036 and PROP-037 because it completed before C3-A and C4-A landed in the same round. This requires a R36 status sync before any agent acts on C2-S's R36 recommendation. P-48 and P-49 track the two doc sets that need updating.

Production deployment remains closed. PROP-032 experiment-pass governance remains pending (P-47).
