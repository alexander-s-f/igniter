# Discussion: R40 PROP-037 Proof, Line Up Closures, and Contextizer Pressure v0

Card: S3-R40-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure + documentation-pressure
Mode: discussion
Initiator: user
Track: r40-prop037-lineup-contextizer-pressure-v0

Question:

Does the PROP-037 OOF-PR proof stay descriptor-only without becoming compiler
implementation? Does it correctly prove that runtime readiness refusal is not
OOF? Do the Line Up closures (P-55, P-56) resolve the authority and wording
gaps without enabling movement prematurely? Does the Contextizer bridge analysis
correctly hold the specimen as pressure without authorizing a package, LLM
connector, Ledger/BiHistory binding, ambient time, or production claim?

Context:
- C1-P1 (Compiler/Grammar Expert): PROP-037 descriptor OOF-PR proof — 13 checks
  PASS; PR1/2/3/4/5/7/9 proved; runtime readiness refusal is not OOF proved;
  live-call invariants all false including ledger/tbackend; external_event uses
  proof-local source ref
- C2-P1 (Archive/Form Expert): Gate 3 R13-R22 Line Up authority verification —
  P-55 closed; 8 checks PASS; no required edits; optional hardening suggested
- C3-P1 (Line Up Summarizer): Pre-Gate-3 Line Up RQ-1/RQ-2 revision — P-56
  closed; RQ-1/2/3 applied; History[T]/BiHistory[T] speculation marked
  historical pressure; QA anchor added
- C4-P1 (Research Agent): Contextizer Line Up bridge analysis — three distinct
  surfaces analysed; LLM/Ledger/BiHistory/ambient time/production all refused;
  7 candidate future routes (route-candidates only); source privacy risk flagged

---

[Agree]

1. **C1-P1 OOF-PR proof correctly stays descriptor-only.** The proof validates
   7 OOF-PR codes against descriptor fixtures without touching parser, Classifier,
   TypeChecker, SemanticIR, assembler, RuntimeMachine, Ledger, TBackend, durable
   queues, receipt sinks, ProgressionPack, or production execution. OOF-PR6 and
   OOF-PR8 are correctly deferred — they require a compiler-owned AST/typed
   fragment boundary that does not yet exist. The deferral is named, not silent.

2. **C1-P1 proves the OOF / readiness-refusal split explicitly.** The proof
   check `runtime_readiness_refusal_is_not_oof` validates that a valid descriptor
   produces `progression.runtime_execution_not_authorized` metadata rather than a
   compiler diagnostic. The inverse is also proved: invalid descriptors produce
   OOF codes, not readiness metadata. This is the key architectural boundary from
   C3-P1 (R38), now backed by a passing proof rather than just a design rule.

3. **C1-P1 live-call invariant list is correctly expanded.** Beyond the
   scheduler/materializer/receipt/checkpoint invariants from C2-P1 (R38), this
   proof adds explicit `ledger_call_attempted` and `tbackend_call_attempted`
   invariants — both false. This closes the gap where Ledger or TBackend calls
   could be attempted through a progression pathway not covered by the earlier
   invariant set.

4. **C1-P1 addresses the R39 NB-1 external_event naming concern.** The proof
   uses `"source_ref": "proof_local/external_event/http_shape_only"` instead of
   the production-like `http_listener/on_request` name flagged in the R39 review.
   The fixture is now self-describing as proof-local, removing the documentation
   path that could be read as a concrete HTTP binding reference.

5. **C2-P1 Gate 3 Line Up verification is thorough and correctly scoped.** The
   8-check verification table covers all authority-hoist vectors: stale Gate 3
   authority, R22 blocker table scoping, authority pointer correctness, source
   authority anchor, production durable audit, production registry/signing,
   Ledger/BiHistory/stream/OLAP, and movement authority. All pass. The optional
   hardening suggestion — renaming "Remaining Blockers" to "Historical R22
   Remaining Blockers" and adding a pointer to current-status.md — directly
   addresses the R39 NB-4 concern. It is correctly labeled optional since the
   existing wording is already technically scoped; the hardening is a readability
   improvement if the Line Up becomes a redirect landing page. P-55 is closed.

6. **C3-P1 applies all three required changes to the pre-Gate-3 spine.** RQ-1
   tightens the route so History Curator may plan but not execute redirects until
   R13-R22 Line Up lands and no-zombie checks pass. RQ-2 replaces the generic
   `meta-proposals` pointer with exact `docs/gates/`, `current-status.md`, and
   `agent-context.md` pointers. RQ-3 replaces "runtime enforcement" with
   "guarded approval-enforcement proof tracks, without granting runtime authority."
   The additional marking of early `History[T]` / `BiHistory[T]` speculation as
   historical pressure only is a sound bonus that addresses the pre-Gate-3
   period when temporal features were not yet accepted. P-56 is closed.

7. **C4-P1 correctly separates three adjacent but distinct surfaces.** The core
   finding — Line Ups are documentation metabolism, the legacy CLI is a practical
   extraction utility, and the DocumentContextizer specimen is non-canonical
   product pressure — is architecturally sound. None of the three is collapsed
   into another. All four high-risk vectors (LLM connector, Ledger/BiHistory,
   ambient time, production claims) are explicitly refused with named decisions.
   The source privacy risk for remote Git intake (private source or secrets
   packaged into context artifacts) is a genuine new signal that internal agents
   may have underweighted; naming it here is valuable.

---

[Challenge]

1. **C4-P1 reads external gem source files for vocabulary extraction; the
   vocabulary table may be treated as a pre-accepted naming convention
   (documentation-pressure lens).** The card reads `[GEM]/contextizer/lib/
   contextizer/context.rb`, `collector.rb`, `analyzer.rb`, `cli.rb`,
   `configuration.rb`, and `renderers/markdown.rb` — internal class names from an
   external utility. The resulting "Practical vocabulary from the CLI that is
   lower risk" table includes `Analyzer`, `Collector`, `Provider`, `Renderer`,
   `Configuration`. These are the gem's internal implementation class names, not
   formal Igniter-Lang vocabulary. A future card inheriting this table as a
   starting point — especially `context-capture-pack-shadow-boundary-v0` — could
   treat the gem's class names as pre-decided Igniter-Lang pack vocabulary without
   a proposal. The card does not explicitly warn against this. Non-blocker for
   C4-P1 itself; the risk arises in downstream cards that inherit the vocabulary
   table without repeating the "external utility" caution. NB.

2. **C4-P1 recommends `context-capture-pack-shadow-boundary-v0` as the next
   route without naming what Architect authorization it would require
   (runtime-pressure lens).** The card says the shadow-boundary card "can use the
   practical CLI vocabulary while staying descriptor-only" and "avoids parser
   work, runtime work, LLM calls, Ledger/BiHistory, and production claims." This
   framing is correct for a research track. But the card's 7-candidate table also
   includes items that depend on shape decisions not yet made: `ContextSnapshotPack`
   depends on "type vocabulary, receipt policy"; `LLMRefinementEscapePack` depends
   on "escape surface, runtime guard, privacy policy." The recommended first route
   is the safest of the seven, but the table as a whole could be read as a roadmap
   that pre-decisions the existence of all seven packs. The card correctly labels
   each entry as "not authorized now," but a reader scanning the table for what
   exists will see seven named candidate packs rather than seven named research
   pressure signals. Non-blocker; NB.

3. **C4-P1 same-round ordering with C1-P1 is not flagged, but C1-P1's worktree
   note shows it observed C2-P1/C3-P1 dirty files.** C1-P1 notes "Unrelated dirty
   files observed during this slice and not touched" including `pre-gate3-lineup-
   rq1-rq2-revision-v0.md` and `gate3-r13-r22-lineup-authority-verification-v0.md`
   — meaning C2-P1 and C3-P1 were in progress when C1-P1 ran. C4-P1 does not
   appear in C1-P1's dirty-file list, suggesting C4-P1 may have landed after
   C1-P1. This is the recurring same-round ordering pattern. It is non-blocking
   since none of C1-P1 through C4-P1 have cross-card dependencies (the OOF-PR
   proof, Line Up closures, and Contextizer analysis are independent). NB only.

---

[Missing]

1. **Optional hardening for Gate 3 Line Up "Remaining Blockers" section is not
   yet applied.** C2-P1 recommends renaming the section header and adding a
   current-status pointer before the Line Up becomes a primary redirect landing
   page. This is labeled optional and is not required before movement planning.
   If History Curator planning proceeds toward R13-R22 redirects, this hardening
   should be applied before the Line Up becomes the redirect target.

2. **OOF-PR6 and OOF-PR8 remain unproved.** Both need a compiler-owned
   progression AST/typed surface. No card opens that surface in R40. This is
   expected and correctly deferred. The gap is named in the remaining-gaps table.

3. **The CompatibilityReport readiness consumption proof (next recommended by
   C1-P1) has not been opened.** C1-P1 recommends routing it as the next safe
   PROP-037 proof after OOF-PR descriptor validation. Not yet assigned.

4. **`context-capture-pack-shadow-boundary-v0` is a route candidate only, not
   yet assigned or authorized.** C4-P1 recommends it as the first safe follow-up.
   No Architect authorization or track was opened in R40.

---

[Sharper Question]

C4-P1 reads the external contextizer gem source files and the DocumentContextizer
pressure specimen side by side, then extracts shared vocabulary to propose future
Igniter-Lang pack/profile descriptors. If the gem and the specimen share the same
author ecosystem, does reading the gem's internal class names as vocabulary
evidence create a de-facto design constraint on future Igniter-Lang pack naming —
one that has not gone through the pressure → proposal → proof path? Or is this
equivalent to any other external vocabulary extraction done by a Research Agent?

---

[Route]

PROCEED (non-blockers only).

Checklist:
- P-55: CLOSED by C2-P1 (Gate 3 R13-R22 Line Up authority verification; all
  8 checks PASS; no required edits; movement planning unblocked subject to
  History Curator no-zombie checks)
- P-56: CLOSED by C3-P1 (RQ-1/2/3 applied to pre-Gate-3 spine; History[T]/
  BiHistory[T] speculation marked historical; QA anchor added; redirects still
  require History Curator no-zombie checks)

Non-blockers (NB):
- NB-1 (R39): RESOLVED — C1-P1 uses `proof_local/external_event/http_shape_only`
  in the external_event fixture
- NB-4 (R39): ADDRESSED as optional — C2-P1 suggests "Historical R22 Remaining
  Blockers" hardening before the Line Up becomes a primary redirect page
- NB-2 (R40): C4-P1 external gem class names (Analyzer, Collector, Provider,
  Renderer) may be misread as pre-accepted Igniter-Lang vocabulary; downstream
  cards inheriting the vocabulary table should repeat the "external utility" caution
- NB-3 (R40): C4-P1 seven-pack candidate table could be read as a pre-decided
  roadmap; each entry is correctly labeled "not authorized now" but the table
  creates naming gravity; recommended first route is correctly the safest option
- NB-4 (R40): same-round ordering: C1-P1 observed C2-P1/C3-P1 as dirty when it
  ran; C4-P1 appears to have landed after all three; no cross-card dependency
  existed so this is not a planning hazard

Next recommended cards:
1. Apply optional Gate 3 Line Up "Historical R22 Remaining Blockers" hardening
   before redirect use (C2-P1 optional suggestion)
2. PROP-037 CompatibilityReport readiness consumption proof (C1-P1 recommended
   next)
3. `context-capture-pack-shadow-boundary-v0` — requires Architect routing first
