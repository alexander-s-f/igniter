# Discussion: R33 Rebuild, PROP-032 Phase 2, Profile PROP, and Progression Pressure

Card: S3-R33-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: r33-rebuild-prop032-profile-and-progression-pressure-v0
Date: 2026-05-11

---

## Context

Five R33 items reviewed. Two shadow tracks also read.

| Track | Card | Role | Status |
|-------|------|------|--------|
| `durable-audit-restart-rebuild-proof-v0` | S3-R33-C1-P | Implementation Agent | done |
| `prop032-assumptions-phase2-typechecker-v0` | S3-R33-C2-P | Compiler/Grammar Expert | done |
| `compiler-profile-manifest-prop-number-decision-v0` | S3-R33-C3-A | Architect Supervisor | approved-numbering-only |
| `compiler-profile-shadow-chain-dependency-index-v0` | S3-R33-C4-S | Meta Expert | done |
| `external-progression-semantics-decision-prep-v0` | S3-R33-C5-P | Research Agent #2 | done |
| `progression-pack-shadow-boundary-v0` | background-foundation | Research Agent | done |
| `compiler-profile-manifest-prop-architect-routing-v0` | background-foundation | Research Agent | done |

---

## Scope Item Review

| Item | Scope check | Result | Notes |
|------|-------------|--------|-------|
| Production deployment | Not present in any R33 card | PASS | All tracks confirmed proof-local or decision-only |
| Ledger / Phase 2 | C1-P excluded-surface guards #18/#19 PASS; not present elsewhere | PASS | |
| BiHistory | Not mentioned in any R33 track | PASS | |
| Stream/OLAP production executor | C5-P explicitly defers "unified stream executor" | PASS | |
| Production cache | Not present | PASS | |
| Concrete HSM/KMS | C1-P excluded-surface guard #20 PASS | PASS | |
| RuntimeMachine binding | C3-A explicitly non-authorized; C5-P defers "production RuntimeMachine scheduler" | PASS | |
| `.igapp` manifest migration | C3-A non-authorizations explicit; all compiler profile implementation cards remain blocked | PASS | |
| Progression vs stream separation | C5-P: "Streams are data sources/windows; progressions are execution/event lifecycle" | PASS | Clear conceptual boundary held |
| Progression vs managed loops separation | C5-P: "Finite/structural/fuel/convergent loops: remain managed local repetition classes" | PASS | |
| Progression vs service loop separation | C5-P: "service loop is the surface; progression is the semantic substrate" — service loop refactors onto progression, does not replace finite loops | PASS | |
| B-A scope (proof-local only) | C1-P: no lib/ changes; all engine code inside proof script; 5/5 excluded-surface guards | PASS | |
| Phase 2 TypeChecker scope | C2-P: no parser, SemanticIR, runtime, evidence-list validation changes | PASS | |
| PROP-036 numbering scope | C3-A: numbering-only; no `.igapp`, assembler, loader, runtime, or implementation | PASS | |
| Phase 1 golden stability | C2-P adjusted `assumption_basic` fixture; `classifier_pass_proof --check-golden` PASS; `assumptions_proof --check-golden` PASS | PASS | Minor fixture drift; see Risk R-2 |
| `PROP-036+` placeholder collision | PROP-036 now assigned to `compiler_profile_id` manifest; Covenant + heat map + spec-extension-gap-analysis still use `PROP-036+` for managed recursion / loop classes | **NB** | See Risk R-1 — governance sync gap |
| B-A production append guard | Q1 from C1-P: proof-local store does NOT gate appends on clean rebuild status; explicit [R] note only | **NB** | See Risk R-3 |

---

## Risk Table

| # | Risk | Severity | Owner |
|---|------|----------|-------|
| R-1 | `PROP-036+` now collides: Covenant postulate 14, P14, OQ-P28-3, heat map Domain 3, and spec-extension-gap-analysis all use `PROP-036+` as a placeholder for managed recursion / loop classes. Now that PROP-036 is officially assigned to `compiler_profile_id` manifest identity (C3-A), any reader of those docs will conflate the two features. These references need to become `PROP-037+` (or whichever next-free ID is confirmed). C3-A follow-up list item 3 only mentions adding compiler profile identity to the heat map — it does not call out the loop-class renaming. | Medium | Meta Expert + Architect |
| R-2 | Phase 1 `assumption_basic` fixture was altered in C2-P (changed from unsupported `similarity(...) * ...` expression to `homophily.strength`). This is described as "adjusted where needed for TypeChecker proofability." The Phase 1 classified golden was presumably regenerated to match (`assumptions_proof --check-golden` PASS). However there is no explicit co-sign from the Phase 1 track (S3-R32-C3-P) that this adjustment was anticipated. The change is minor and all proofs pass, but the Phase 1 golden baseline has silently shifted. | Low | Compiler/Grammar Expert |
| R-3 | C1-P Q1 (open): the proof-local `RestartRebuildEngine` does not gate new appends on clean rebuild status. The track [R] states "a production store MUST refuse new appends if rebuild is not clean" and marks this as a production implementation requirement, not a proof gap. This is correctly deferred but should be explicitly closed before deployment authorization (B-D / follow-up Architect review). | Low | Implementation Agent |
| R-4 | Progression fragment class ownership is unresolved. C5-P defers the question: "Does progression get a dedicated fragment class, or remain an escape/runtime capability with manifest metadata?" progression-pack-shadow-boundary-v0 also leaves it open. Any future progression classifier work will need this resolved first. If R34 opens a progression PROP draft, this should be AC-2 material or explicitly out-of-scope in the draft. | Low | Compiler/Grammar Expert |
| R-5 | The "service loop is the surface; progression is the semantic substrate" relationship is a Research Agent [D] only. It is not yet anchored in the Covenant or any accepted PROP. Until a formal PROP accepts this framing, the relationship is advisory. C5-P correctly routes to a PROP draft; the risk is that an overeager R34 card might act on this framing without waiting for formal acceptance. | Low | Architect / Compiler/Grammar Expert |

---

## Pre-Production Checklist Update

| Item | Status | Closed by |
|------|--------|-----------|
| P-37: Canonical hash excluded fields documented | ✅ closed | S3-R32-C1-P |
| P-38: compliance_posture storage model | ✅ closed | S3-R32-C1-P |
| P-39: Governance sync C2-A follow-ups | ✅ closed | S3-R32-C2-S |
| P-40: Compiler profile authority boundary proof | ✅ closed | S3-R32-C4-S (R31-SHADOW) |
| P-41: Compiler profile manifest PROP number assignment | ✅ **closed** | S3-R33-C3-A (PROP-036 assigned) |
| P-42: PROP-032 Phase 2 TypeChecker OOF-A1 propagation | ✅ **closed** | S3-R33-C2-P |
| P-43 (NEW): Production store append must gate on clean rebuild status | 🔲 open | Require before deployment authorization (B-D / follow-up Architect review) |
| P-44 (NEW): Update `PROP-036+` → `PROP-037+` for managed recursion / loop classes in Covenant, heat map, spec-extension-gap-analysis | 🔲 open | Meta Expert governance sync before next loop-class-adjacent card |

---

## [Agree]

- **C1-P B-A proof is correctly scoped.** 21/21 cases PASS; 6/6 invariant checks PASS. D1 (cursor stops at first_failure_at; full scan continues; stored records never modified) directly answers the R32 [Sharper Question]. D2 and D3 implement R32 design amendment requirements without overreach. No lib/ changes, no production signing, no Ledger. Excluded-surface guards are explicit and all pass.

- **C2-P Phase 2 TypeChecker scope is tight.** OOF-A1 propagation reuses the existing oof_log → type_errors path correctly. TASSUMP-1 is the appropriate boundary for strength validation at the TypeChecker layer. Phase 3 SemanticIR is correctly unblocked without forcing it now. PROP-032 is not promoted to experiment-pass.

- **C3-A PROP-036 assignment is correctly bounded.** Numbering-only; implementation cards remain blocked; non-authorization list is explicit and comprehensive. The rationale for assigning now (removes floating design assumption) is sound.

- **C4-S dependency index is curation-correct.** Regeneration order is sound. Archive conditions are conservative (wait for consolidation, not just PASS). Shadow/pre-POC boundary table is comprehensive. No new semantics introduced.

- **C5-P progression decision brief holds the boundary correctly.** Finite/structural/fuel/convergent loops are explicitly preserved as managed local loop classes. Stream/fold_stream is clearly separated as data-flow / bounded window semantics. The "service loop is the surface; progression is the semantic substrate" framing is productive and routes to a formal PROP rather than claiming implementation authority. The ten acceptance criteria (AC-1 through AC-10) are concrete enough for a real PROP gate.

- **Progression stays separate from stream and managed loops.** All three tracks that touch progression (C5-P, progression-pack-shadow-boundary-v0, external-progression-runtime-model-v0) hold the boundary. No widening into stream executor, OLAP, or eager loop classes.

---

## [Challenge]

- **C3-A follow-up list has a gap on the PROP-036+ renaming.** The follow-up list item 3 says to update `docs/dev/semantic-governance-heat-map.md` to mark compiler profile identity as a queued proposal. But the heat map Domain 3 uses `PROP-036+` as a placeholder for managed recursion / loop classes across four rows. The Covenant uses `PROP-036+` in postulate 14, P14, and OQ-P28-3 for the same meaning. The spec-extension-gap-analysis uses it at line 157. Now that PROP-036 is specifically assigned to `compiler_profile_id` manifest identity, all these references read as if managed recursion will be PROP-036 — but that slot is taken. The C3-A follow-up list does not mention this renaming requirement. This is a live governance ambiguity, not a dormant one: the next time a reviewer reads Domain 3 of the heat map and sees `PROP-036+`, they will think of the wrong feature.

- **Phase 1 assumption_basic fixture change was not explicitly co-signed.** C2-P states the fixture was adjusted "where needed for TypeChecker proofability." This is reasonable, but the Phase 1 classified golden for `assumption_basic` is the canonical output of S3-R32-C3-P. Altering that fixture in a Phase 2 card is a retroactive Phase 1 change. All --check-golden proofs pass, so the change is self-consistent. But the Phase 1 track record does not acknowledge this revision. A co-sign note in the Phase 1 track handoff, or a brief amendment record, would preserve the audit trail cleanly.

---

## [Missing]

- **PROP-036+ renaming follow-up is absent from C3-A, C4-S, and R33 curation.** No card in R33 addresses the need to update `PROP-036+` → `PROP-037+` (or confirmed next placeholder) in Covenant, heat map, and spec-extension-gap-analysis for the managed recursion / loop class feature. This should be a P-44 item for R34 governance sync.

- **Q1 from C1-P needs a formal closure path.** The proof-local store does not gate appends on clean rebuild status. C1-P's [R] note correctly identifies the production requirement. But there is no pre-production checklist item, no B-D sub-requirement, and no explicit gate that forces this before deployment authorization. Without P-43 or an equivalent, this requirement could be overlooked when the deployment review opens.

- **Progression fragment class is unresolved.** Neither C5-P, progression-pack-shadow-boundary-v0, nor any other R33 card specifies whether progression gets a new fragment class. Both explicitly leave it open. Before any progression PROP draft opens, this question should be stated as AC material or explicitly out of scope for the first PROP revision. Leaving it entirely open risks the PROP draft making a silent choice.

---

## [Sharper Question]

- **For C3-A:** The follow-up list mentions updating the heat map for compiler profile identity, but does any R33 or R34 card own the `PROP-036+` → `PROP-037+` renaming in Covenant and heat map for loop classes? If not, this will create governance drift the first time a loop-class card opens.

- **For C2-P:** The `assumption_basic` fixture change altered the Phase 1 golden baseline. Is this change visible in the git history as an intentional amendment, or is it buried inside the Phase 2 commit? If a future Phase 3 card re-reads the Phase 1 golden for reference, will it see the amended fixture or the original?

- **For C5-P:** "Service loop should lower to progression obligations rather than imply eager looping." Chapter 13 defines `alive_by_liveness` as a loop class. Does refactoring service loop semantics retroactively modify Chapter 13, or does a future progression PROP coexist with Chapter 13 and only replace the runtime model? This matters for whether the progression PROP draft must open a Ch13 amendment or can proceed independently.

---

## [Route]

**R34 recommendation (priority order):**

1. **[Implementation Agent] B-B**: Audit traversal / reader proof (surface 6 of S3-R30-C1-A). Must re-derive `compliance_posture` for every returned record per R32 D3. Confirm reader-only role boundary.

2. **[Implementation Agent] B-C**: Appender / reader role boundary proof (surface 7 of S3-R30-C1-A). May run in parallel with B-B.

3. **[Meta Expert] P-44 governance sync**: Update `PROP-036+` → `PROP-037+` (or confirmed next placeholder) in Covenant postulate 14, P14, OQ-P28-3, heat map Domain 3 (4 loop-class rows), and spec-extension-gap-analysis. Also complete C3-A follow-up list items 2 and 3 (current-status P-41 closure + heat map compiler profile entry). Required before any loop-class-adjacent card opens, to avoid PROP number confusion.

4. **[Compiler/Grammar Expert] PROP-032 Phase 3**: SemanticIR lowering for typed assumptions surface only (assumption_registry, assumption_refs, typed uses_assumptions declarations; no output evidence-list validation; no constraints/form/ESM/runtime).

5. **[Compiler/Grammar Expert] PROP-036 authoring card**: Now that C3-A assigns the number, the proposal file can be authored. Must not mutate `.igapp` fixtures, loader, assembler, or implementation. Must use C3-A as numbering authority.

6. **[Compiler/Grammar Expert] External progression semantics PROP draft**: C5-P routes this explicitly with ten concrete acceptance criteria. Keep parser syntax, SemanticIR impl, RuntimeMachine scheduler, Ledger/TBackend, durable queues, and ProgressionPack migration deferred per C5-P. Progression fragment class ownership must be stated as AC material or explicitly deferred in the draft.

7. **[Implementation Agent] B-D**: Post-implementation full regression matrix (surface 9 of S3-R30-C1-A). Must include P-43 confirmation (production append gating) before follow-up Architect production deployment review opens.

---

## Verdict

**PROCEED — non-blockers only.**

R33 held scope correctly on all five primary items. B-A answers R32's [Sharper Question] with a sound D1 decision. PROP-032 Phase 2 closes the TypeChecker boundary. PROP-036 numbering removes the floating design assumption. The shadow dependency index is navigable without introducing new semantics. Progression semantics are clearly separated from streams and managed loops. No excluded surface was widened.

Two non-blocker gaps remain: the `PROP-036+` → `PROP-037+` renaming for loop classes (P-44), and the production append guard confirmation path (P-43). Both are routed to R34.

B-B, B-C, and B-D remain open. Deployment authorization remains blocked by all of B-B, B-C, B-D, and P-43.
