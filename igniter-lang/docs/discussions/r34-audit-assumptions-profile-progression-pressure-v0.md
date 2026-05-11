# Discussion: R34 Audit Reader/Appender, PROP-032 Phase 3, PROP-036, and Progression Scope Pressure

Card: S3-R34-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: r34-audit-assumptions-profile-progression-pressure-v0
Date: 2026-05-11

---

## Context

Six R34 tracks reviewed.

| Track | Card | Role | Status |
|-------|------|------|--------|
| `durable-audit-reader-traversal-proof-v0` | S3-R34-C1-P | Implementation Agent | done |
| `durable-audit-append-reader-role-boundary-proof-v0` | S3-R34-C2-P | Implementation Agent | done |
| `prop036-placeholder-governance-sync-v0` | S3-R34-C3-S | Meta Expert | done |
| `prop032-assumptions-phase3-semanticir-v0` | S3-R34-C4-P | Compiler/Grammar Expert | done |
| `prop036-compiler-profile-id-manifest-proposal-v0` | S3-R34-C5-P | Compiler/Grammar Expert | done |
| `external-progression-prop-scope-draft-v0` | S3-R34-C6-P | Research Agent #2 | done |

---

## Scope Item Review

| Item | Scope check | Result | Notes |
|------|-------------|--------|-------|
| Ledger / Phase 2 | C1-P BB-S6-C3 PASS (no Ledger methods); C2-P Surface 6 excluded.no_ledger_access + no_phase2_or_hsm_kms PASS | PASS | |
| BiHistory | Not present in any R34 card | PASS | |
| Stream/OLAP production executor | C6-P explicitly defers RuntimeMachine scheduler; C4-P non-auth list | PASS | |
| Production cache | Not present | PASS | |
| Concrete HSM/KMS | C2-P excluded.no_hsm_kms PASS; C1-P non-auth list explicit | PASS | |
| RuntimeMachine binding | C1-P BB-S6-C4 PASS; C2-P non-auth; C4-P non-auth; C5-P non-auth; C6-P explicit non-auth | PASS | |
| `.igapp` manifest migration | C5-P ".igapp manifest mutation" non-authorized; C3-S non-auth; C6-P ".igapp/.ilk format migration" non-auth | PASS | |
| Production deployment | C2-P "Production deployment ABSENT"; all tracks | PASS | |
| Durable audit reader — not production storage | C1-P proof-local only; no lib/ changes; production_durable_audit: false always (BB-S6-C1); excluded surfaces in non-auth list | PASS | |
| P-43 append guard not lost | C2-P Surface 3 (4/4 PASS): p43.appender_failed_rebuild_refused, p43.appender_recovery_after_rebuild, deterministic code; P-43 explicitly closed | PASS | P-43 fully resolved |
| P-44 PROP-036+ drift | C3-S applied all 7 file updates; before/after table is complete; PROP-037+ is the confirmed new placeholder | PASS | P-44 fully resolved |
| PROP-032 Phase 3 absorbed PROP-033 scope | C4-P non-auth: "No output evidence-list validation"; OOF-A1/TASSUMP-1 remain in CompilationReport only; no evidence-list enforcement in SemanticIR | PASS | |
| PROP-036 proposal authorized implementation | C5-P is docs-only; implementation blockers section requires acceptance + separate Architect authorization per card before any code; no `.igapp`, assembler, loader, or runtime changes | PASS | |
| Progression draft chose parser/runtime authority | C6-P explicit non-auth: "No parser syntax, No TypeChecker implementation, No SemanticIR implementation, No RuntimeMachine scheduler, No durable queue…"; no PROP number claimed | PASS | |
| Progression stays separate from stream | C6-P: "Stream[T] remains data flow. Progression is execution/event lifecycle."; fold_stream inside progression step is permitted only if bounded; stream may feed a progression source but is not the same | PASS | |
| Progression stays separate from managed loops | C6-P: FiniteLoop, StructuralRecursion, FuelBoundedRecursion, ConvergentLoop unchanged; ServiceLoop becomes a surface over progression | PASS | |
| Fragment class resolution for progression | C6-P: "current PROP scope: no new PROGRESSION fragment class" — first PROP targets runtime capability / manifest metadata only | PASS | R33 open question answered |
| C2-P same-round B-B ordering miss | C2-P Open Blockers table lists B-B as still open, but C1-P (B-B) completed in the same round | **NB** | Parallel execution artifact; cumulative state is correct |
| Dual proposals/README.md edits | C3-S and C5-P both updated proposals/README.md; C3-S adds PROP-036 note + PROP-037+ row; C5-P moves PROP-036 to authored and notes PROP-037+ | **NB** | Edits are compatible; cumulative result consistent if C3-S applied before C5-P |

---

## Risk Table

| # | Risk | Severity | Owner |
|---|------|----------|-------|
| R-1 | C2-P Open Blockers table lists B-B as still open while C1-P (B-B) completed in the same round. This is a same-round parallel-execution ordering artifact (same pattern as R31-C3-S / R32-C2-S). Cumulative state is correct: B-B PASS, B-C PASS, B-D still open. A reader relying only on C2-P's Open Blockers table would incorrectly believe B-B is pending. | Low | Meta Expert (status curation) |
| R-2 | C3-S and C5-P both updated `docs/proposals/README.md`. If applied in the wrong order (C5-P before C3-S), C3-S's PROP-037+ placeholder row might overwrite or conflict with C5-P's authored-proposal update. The handoff text in C5-P says "Managed recursion/service loops remain PROP-037+ placeholder only" suggesting awareness of C3-S, but the authoring order is not explicitly stated. The git history would resolve this, but the track docs alone don't confirm it. | Low | Meta Expert (verify git history on next curation pass) |
| R-3 | C4-P updated `docs/spec/ch6-semanticir.md` with a PROP-032 SemanticIR assumptions shape. Ch6 is a canonical spec document. The Compiler/Grammar Expert is the appropriate author for active-PROP SemanticIR sections, and the PROP-032 implementation was gate-authorized. However the track does not mention explicit Architect co-sign for this spec amendment, following the precedent of D-level decisions in implementation cards. If Ch6 amendments require the same co-sign path as PROP proposals, this should be flagged for the next curation pass. | Low | Architect / Meta Expert |
| R-4 | PROP-036 proposal is now authored but has no acceptance gate yet. The proposal explicitly blocks all implementation cards until acceptance. However there is no card in R34 that schedules or routes the acceptance decision. Without a named R35 acceptance card, PROP-036 could sit as an authored-but-unreviewed proposal indefinitely while future rounds open implementation-adjacent work. | Low | Architect |
| R-5 | Progression PROP scope draft (C6-P) is review-ready for PROP number assignment, but no card in R34 routes it to Architect for that decision. The next numbered slot after PROP-036 is PROP-037+. If an R35 card assumes PROP-037 belongs to progression without a formal Architect assignment, it will create the same floating-design-assumption problem that C3-A was meant to resolve for PROP-036. | Low | Architect |

---

## Pre-Production Checklist Update

| Item | Status | Closed by |
|------|--------|-----------|
| P-41: Compiler profile manifest PROP number assignment | ✅ closed | S3-R33-C3-A |
| P-42: PROP-032 Phase 2 TypeChecker OOF-A1 propagation | ✅ closed | S3-R33-C2-P |
| P-43: Production store append must gate on clean rebuild status | ✅ **closed** | S3-R34-C2-P — [D1] + Surface 3 (4/4 PASS); code: `audit.writer.rebuild_not_clean` |
| P-44: Update `PROP-036+` → `PROP-037+` for managed recursion in Covenant, heat map, and related docs | ✅ **closed** | S3-R34-C3-S — 7 files updated; before/after governance table confirms |
| P-45 (NEW): PROP-036 acceptance gate — governance review/decision required before any implementation card may open | 🔲 open | Architect/Meta Expert; author: C5-P |
| P-46 (NEW): PROP-037+ formal assignment — progression PROP is scope-ready; Architect must assign number before formal PROP authoring begins | 🔲 open | Architect |

---

## [Agree]

- **C1-P B-B is correctly scoped and thorough.** 26/26 PASS, 4/4 invariants. The key design choice is correct: total_scanned always equals the full store size regardless of output filters (D1 / INV-3). This means `compliant_export` and the failure counts reflect the entire audit chain, not just the requested window — a reader cannot craft a filter to hide failures. D4 (posture mismatch excludes record from verified_records but does not break chain continuity) is also correct: subsequent records should still be checkable, and the error surface should not cascade beyond the mismatched record.

- **C2-P B-C is correctly scoped, and P-43 is formally closed.** 21/21 PASS, 6/6 invariants. The RoleGatedStore model layers role check before rebuild check — this ordering ensures that role errors are always deterministically code `audit.writer.unauthorized`, and rebuild-gate errors are only visible to legitimate appenders. The `p43.appender_recovery_after_rebuild` case (4 in Surface 3) correctly proves the gate is two-way: after a failed rebuild is resolved to clean, appends are allowed again. Without this case the gate would be a one-way lock, which is not the intent.

- **C3-S P-44 governance sync is complete and thorough.** Seven files updated; before/after governance summary is explicit. The new PROP-037+ placeholder is correctly positioned as "next-safe placeholder for managed recursion / service loops until formal assignment" — it does not claim a number, just removes the collision. GI-6 in the heat map closes the collision formally.

- **C4-P Phase 3 SemanticIR is correctly bounded.** Only typed programs lowered. assumption_ref_node is a descriptive provenance node, not a runtime injection. OOF-A1 and TASSUMP-1 remain in CompilationReport with nil SemanticIR — the existing report-only path is preserved. Existing no-assumption goldens unchanged. Ch6 updated with a scoped PROP-032 section. Phase 4 (parser grammar + P28) correctly deferred.

- **C5-P PROP-036 proposal has explicit and comprehensive non-authorizations.** The implementation blockers list is detailed and correctly sequenced: acceptance first, then separate Architect authorization per card, proof of artifact hash change before assembler/golden migration. The firewall (`present_verified` does not imply `runtime_evaluation_readiness.ready`) is preserved from the shadow chain evidence. The `CompilerProfile` vs `CompilationReceipt` separation is explicit in the proposal shape. Docs-only with sanity checks is appropriate for a non-code proposal card.

- **C6-P progression PROP scope draft holds all key boundaries.** Fragment class question from R33 is now answered: no new PROGRESSION fragment class in the first PROP. Runtime capability / manifest metadata first is the right conservative entry point. The `progression_runtime_readiness.ready: false` firewall mirrors the compiler profile authority pattern. Nine OOF-PR* categories are well-defined. The `PROP-TBD` / `PROP-037+` candidate label correctly avoids claiming the number. Stream-progression-loop separation is maintained across the scope draft with explicit relationship table.

---

## [Challenge]

- **C2-P same-round B-B status miss creates a misleading Open Blockers table.** The B-C track (C2-P) lists B-B as still open in its "Open Blockers After This Card" section, but C1-P (B-B) completed in the same round. A future reader consulting only C2-P's Open Blockers table will see B-B as pending when it has in fact passed (26/26). This is the fourth consecutive round where a parallel or curation card has a same-round ordering miss. The pattern is known, but each instance creates a live misleading document. The next status curation pass must correct C2-P's Open Blockers table or add a cross-reference.

- **Two cards updated `proposals/README.md` in the same round without explicit ordering.** C3-S added the PROP-036 numbering note and PROP-037+ row; C5-P moved PROP-036 to "authored Stage 3 proposal." If these were applied in the wrong order, C3-S's changes could appear to conflict with or precede C5-P's changes. The cumulative result appears consistent, but the authoring order is implicit (C3-S appears to run before C5-P based on card numbers). A note in one of the tracks acknowledging the dependency would prevent future confusion.

- **PROP-036 is authored but has no routed acceptance card.** C5-P closes by saying "Governance review/acceptance decision for PROP-036, then a narrowly scoped report-only loader status proof or assembler field proof if authorized." This is the right sequence, but no R34 card opens a review-acceptance card for PROP-036. Without a named acceptance card on the R35 schedule, PROP-036 could remain in `authored` limbo while implementation-adjacent work accumulates around it. P-45 is added here to track this gap.

---

## [Missing]

- **B-D (post-implementation full regression matrix) has no R34 card.** Both B-B and B-C are now complete, so B-D is unblocked. No card in R34 opens B-D. B-D is the prerequisite for B-E (Architect production deployment review), so this gap directly delays the deployment authorization path.

- **PROP-032 Phase 4 (parser grammar + P28 unnamed-assumption fixture) has no R34 card.** C4-P states Phase 4 is the remaining gate for experiment-pass. Without it, PROP-032 stays at partial pipeline coverage (Classifier + TypeChecker + SemanticIR, but no real source syntax path). Not urgent, but the gap should be tracked.

- **Progression PROP formal number assignment has no R34 card.** C6-P recommends "Architect / Compiler-Expert assigns next available PROP number after PROP-036." This was not done in R34. P-46 tracks this.

---

## [Sharper Question]

- **For C1-P (B-B):** D5 states that `prior_record` is updated to the current record even on failure, so a tampered record's stored hash becomes the expected `prev_hash` for the next record. This means a single tampered record can cascade to make the next record's prev_hash check also fail (since the next record was built against the pre-tamper hash, not the stored post-tamper hash). The test note acknowledges "the test asserts sequence 2 is detected, not that exactly 1 record fails." Should the restart-rebuild proof (C1-P in R33) follow the same cascading-failure semantics for D5, or does the restart engine treat each record failure independently? If there is a mismatch, it could cause different integrity counts between the rebuild proof and the reader traversal proof when analyzing the same tampered chain.

- **For C5-P (PROP-036):** The proposal is docs-only and blocks all implementation with an explicit list. But the track card is `done` status. A future agent reading the tracks index will see PROP-036 as `done`. Should PROP-036's status be `authored-pending-review` or `pending-acceptance` rather than `done`, to prevent premature treatment of the proposal as accepted?

- **For C6-P:** The minimum source descriptor uses `source_kind: "clock.every | queue | external_event"`. Does `external_event` include HTTP request listeners, or does it exclude them pending a separate stdlib definition? The track says "HTTP request listeners can be modeled as external_event first. A specialized http_listener.on_request source can be a later stdlib/profile layer." This is reasonable, but the formal PROP will need to decide whether `external_event` is intentionally open-ended or has a closed initial vocabulary. An open-ended `external_event` could be misread as a general escape hatch for any unbounded external trigger.

---

## [Route]

**R35 recommendation (priority order):**

1. **[Implementation Agent] B-D**: Post-implementation full regression matrix (surface 9 of S3-R30-C1-A). B-B and B-C are now both complete. Must pass before B-E opens. Required proofs: all durable audit proof scripts PASS; no excluded-surface widening; P-43 gate confirmed in regression context.

2. **[Meta Expert] R34 status curation**: Close P-43 and P-44 in current-status.md. Correct C2-P's Open Blockers table (B-B is done). Verify git ordering of dual proposals/README.md edits. Update tracks index Round 34 summary.

3. **[Architect] PROP-036 acceptance gate**: Review authored PROP-036 and issue acceptance / conditional-acceptance / rejection decision. Without this, the four named implementation cards (assembler, loader, golden migration, receipt link) remain blocked and the PROP-036 lifecycle stalls.

4. **[Architect] PROP-037+ formal number assignment**: Progression PROP scope draft (C6-P) is ready. Assign a formal number (PROP-037 or next available) before Compiler/Grammar opens the formal PROP authoring card. Prevents a recurrence of the floating-design-assumption problem.

5. **[Compiler/Grammar Expert] PROP-032 Phase 4**: Parser grammar for `assumptions {}` and `uses assumptions NAME`; P28 unnamed-assumption parse-error fixture; source-to-SemanticIR fixture using real source syntax. Required for PROP-032 to reach experiment-pass.

6. **[Implementation Agent] B-E**: Architect production deployment review (surface 10 of S3-R30-C1-A scope; S3-R30-C1-A authorization surface 9 = B-D, B-E is the follow-up Architect review). Opens only after B-D PASS.

---

## Verdict

**PROCEED — non-blockers only.**

R34 closed B-B, B-C, P-43, and P-44 cleanly. PROP-032 Phase 3 SemanticIR stayed within typed-assumptions scope and did not absorb PROP-033 evidence-list work. PROP-036 proposal is authored and correctly blocks all implementation behind an acceptance gate. The progression PROP scope draft correctly defers fragment class assignment and does not claim a PROP number. No excluded surface was widened across any of the six cards.

Three non-blocker gaps: same-round B-B status miss in C2-P, dual proposals/README.md edits without explicit ordering, and no R34 cards for B-D, Phase 4 PROP-032, or progression PROP number assignment. All routed to R35.

Open deployment-authorization blockers: B-D → B-E → Architect deployment review. Production deployment remains closed.
