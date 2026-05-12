# Discussion: R38 Durable Audit, PROP-037, PROP-036, and Docs Pressure v0

Card: S3-R38-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure + documentation-pressure
Mode: discussion
Initiator: user
Track: r38-durable-audit-prop037-prop036-docs-pressure-v0

Question:

Did R38 confirm proof-local closure for P-53 without widening operational
deployment? Do the PROP-037 descriptor and OOF-PR design cards stay cleanly in
design/proof territory without hidden runtime execution claims? Does the PROP-036
assembler field plan correctly defer implementation without leaking field emission
or golden migration? Do the Line Up second-batch summaries avoid hoisting stale
pre-decision framing as current authority?

Context:
- C1-A (Architect): P-53 confirmation review — proof-local closure confirmed;
  design-only rollout readiness plan authorized; operational rollout closed
- C2-P1 (Research Agent): PROP-037 descriptor shape proof — 10 checks PASS;
  3 source_kind fixtures; queue carries explicit `durable_queue: false`,
  `durable_checkpoint: false`, `production_execution: false`
- C3-P1 (Compiler/Grammar Expert): PROP-037 OOF-PR diagnostic design —
  9 rules designed; three-layer separation (descriptor validation / compiler OOF /
  runtime readiness refusals); Ch11 namespace collision flagged
- C4-P1 (Compiler/Grammar Expert): PROP-036 assembler field design plan —
  field placement, hash ordering, rollout policy, 4-surface split; design-only;
  14-item blocker list
- C5-P1 (Line Up Summarizer): Stage 1/2 second batch — 3 new Line Ups created;
  documentation-only; R13-R22 Gate 3 discussions batch deferred

---

[Agree]

1. **C1-A correctly resolves the P-53 framing question.** The prior pressure
   review asked whether P-53 was a confirmation review or a second-gate
   evaluation. C1-A answers clearly: P-53 is a confirmation review plus
   boundary check, not operational rollout authorization. The follow-up
   satisfaction matrix confirms all 7 B-E requirements are met in proof-local
   form. The 9 operational blockers before rollout are new, comprehensive, and
   well-specified: they require an explicit non-Ledger storage identity, signer
   deployment contract, startup/rebuild operational sequence, role mapping,
   refusal-code export plan, disable/rollback runbook, smoke checklist, proof-
   local flag absence, and a fresh pressure review confirming no Ledger/cache/
   RuntimeMachine/HSM/Phase 2 widening. The authorized next card
   (`phase1-durable-audit-operational-rollout-readiness-plan-v0`) is design-only
   with a tightly bounded scope. The full exclusion list remains intact.

2. **C2-P1 descriptor shape proof is proof-local throughout.** The `queue`
   fixture explicitly carries `durable_queue: false`, `durable_checkpoint: false`,
   `production_execution: false` — the right pattern for a proof-local queue
   descriptor. The `external_event` fixture correctly demonstrates descriptor-
   level specialization without authorizing a runtime HTTP listener. The eight
   negative cases include the two highest-risk widening attempts — unsupported
   top-level `source_kind` → `OOF-PR9` and attempted `fragment_class: PROGRESSION`
   → `PROP-037-NONAUTH`. Runtime authority remains closed. The layer-by-layer
   remaining gaps table is carried forward correctly.

3. **C3-P1 three-layer separation is architecturally sound.** Separating
   descriptor validation, compiler OOF diagnostics, and runtime readiness
   refusals is the right design. The rule of thumb ("Invalid progression shape →
   descriptor validation or compiler OOF; Valid shape but unavailable runtime →
   runtime readiness refusal") prevents OOF codes from being misread as runtime
   execution claims. The no-live-call invariant
   (`progression_scheduler_call_attempted == false`, etc.) is the correct runtime
   boundary anchor. OOF-PR5 as error by default is reconfirmed. OOF-PR6 and
   OOF-PR8 are correctly deferred to a compiler-owned progression AST/typed
   surface (they need fragment-boundary context that doesn't exist yet).

4. **C4-P1 assembler field design plan correctly defers all implementation.**
   The 4-surface split (assembler field emission, golden migration, loader/report,
   receipt link) prevents a future card from combining field emission with broad
   golden churn — a failure mode that has historically caused uncontrolled artifact
   drift. The required ordering (compiler_profile_id before artifact_hash
   computation) and the forbidden ordering (post-hash annotation) are clearly
   stated. The `legacy_optional` rollout is preserved. No `.igapp` artifacts are
   touched. The 14-item blocker list for any future implementation card is the
   most comprehensive yet and closes all known escape paths. Each of the four
   deferred implementation surfaces correctly requires separate authorization.

5. **C5-P1 documentation discipline is sound.** No source files were moved,
   deleted, or had broad link rewrites. Each of the three Line Ups states that
   source remains authoritative for exact proof logs. The compiler/package spine
   and Stage 2→3 typed-switch spine are correctly tagged as evidence documents,
   not release-readiness claims.

---

[Challenge]

1. **Ch11 OOF-PR* namespace collision needs a tracking item, not just a design
   note (runtime-pressure lens).** C3-P1 correctly identifies that `ch11-profile-
   system.md` currently uses `OOF-PR1`, `OOF-PR2`, and `OOF-PR3` for proposed
   profile-system violations, now colliding with PROP-037 progression diagnostics.
   C3-P1 says this is "not a blocker for this design track, but a blocker for any
   proof card that would emit both profile and progression diagnostics." That
   scoping is correct as far as it goes, but understates the documentation
   integrity risk: any developer, agent, or tool reading the spec today will
   encounter contradictory OOF-PR semantics depending on which document they
   consult. The collision creates an ambiguous source of truth before the first
   proof card ever runs. Resolution — renaming Ch11 profile diagnostics to
   `OOF-PROF*` or `OOF-PF*` — needs a spec-sync card before `prop037-descriptor-
   oof-pr-proof-v0` can safely proceed. → **P-54 (new).**

2. **`external_event` fixture naming is documentation-leaky (documentation-
   pressure lens).** C2-P1's `external_event_http_request` fixture uses
   `"source_ref": "http_listener/on_request"`. The proof correctly states this
   does not authorize an HTTP listener, but the `source_ref` value `http_listener/
   on_request` reads as a concrete production endpoint name. Anyone reading the
   descriptor shape without the surrounding non-authorization text could reasonably
   infer this is a real or near-real binding. A safer proof-local naming
   convention — e.g., `"source_ref": "proof_local/external_event/http_shape_only"`
   — would prevent confusion for downstream design cards that inherit this fixture.
   Non-blocker for the current proof; NB for future `external_event` descriptor
   documentation.

3. **Line Up second-batch pre-Gate-3 discussions spine has a latent authority-
   hoist risk (documentation-pressure lens).** C5-P1 creates
   `old-discussions-pre-gate3-spine.md` summarizing completed R2-R12 discussion
   pressure. The card correctly flags: "Archive/Form should verify no
   release/runtime/Gate 3 authority leaked into summaries." This risk is not
   hypothetical: pre-Gate-3 discussion cards contain candidate routes, open
   questions, and conditional language that was live at the time but has since
   been superseded by accepted decisions, rejections, or Gate 3. A summary that
   abbreviates the original routing verdict without preserving the "complete —
   routed to X" status could make stale-open questions look current. The
   recommendation to involve Archive/Form is correct; it should be a named
   follow-up, not just a handoff comment. Non-blocker for the documentation
   batch; tracked as NB.

4. **PROP-036 design plan depends on Architect authorization for each of its
   four implementation surfaces, but no authorization path is named.** C4-P1
   lists `assembler-compiler-profile-id-field-v0`, `artifact-hash-profile-id-
   golden-migration-v0`, `loader-compiler-profile-status-report-v0`, and
   `compilation-receipt-manifest-link-v0` as future implementation cards each
   requiring "separate Architect/supervisor implementation authorization" (blocker
   item 2). No authorization track is opened or named in R38. This is expected
   — the design plan precedes implementation authorization. But if these four
   surfaces are left without an authorization route, the PROP-036 implementation
   blockers will age and potentially be missed in a future round's status
   curation. Non-blocker for R38; flag for status curation.

---

[Missing]

1. **`prop037-descriptor-oof-pr-proof-v0` is not yet opened.** C3-P1 explicitly
   recommends it as the next proof card, with an 11-fixture set. The proof is
   blocked until the Ch11 OOF-PR* namespace collision is resolved (P-54). No
   card was opened in R38. This is expected given that the design card landed
   in the same round; the proof card is a natural R39 item once P-54 is resolved.

2. **R13-R22 Gate 3 discussions Line Up batch is not yet started.** C5-P1 defers
   this to `gate3-r13-r22-discussions-lineup-v0`, linked to History-S7. Given
   that the R13-R22 chain contains the Gate 3 decision record and post-Gate-3
   scope expansions, the summary is a higher-risk surface than the pre-Gate-3
   batch. Archive/Form review should be explicitly assigned, not assumed.

3. **Operational rollout readiness plan card
   (`phase1-durable-audit-operational-rollout-readiness-plan-v0`) is authorized
   by C1-A but not yet opened.** This is the only implementation-path artifact
   next step for durable audit. Its absence in R38 is expected; the authorization
   was just issued.

---

[Sharper Question]

The Ch11 OOF-PR* collision (P-54) is currently scoped as "blocker only for
joint-emission proof cards." But if `prop037-descriptor-oof-pr-proof-v0` runs
and validates OOF-PR codes against PROP-037 progression semantics while Ch11 is
still live with conflicting semantics, does the proof inadvertently canonize the
PROP-037 meaning of OOF-PR1..3 over Ch11's profile-system meaning — even without
a spec-sync card? Or does proof-local scope keep the conflict dormant until an
explicit spec-sync decision is made?

---

[Route]

PROCEED (non-blockers only).

Checklist:
- P-53: CLOSED by C1-A (confirmation review + boundary check; operational
  rollout design-only card authorized; all excluded surfaces still closed)
- P-54: NEW — resolve Ch11 OOF-PR* namespace collision before running
  `prop037-descriptor-oof-pr-proof-v0` or any card emitting both profile
  and progression OOF diagnostics

Non-blockers (NB):
- NB-1: `external_event` fixture `source_ref: "http_listener/on_request"` is
  documentation-leaky; consider proof-local naming convention in future
  `external_event` descriptor fixtures
- NB-2: Archive/Form verification of pre-Gate-3 discussions Line Up for
  authority-hoist risk should be a named follow-up, not a handoff comment only
- NB-3: PROP-036 four implementation surfaces have no named authorization route
  yet; flag for status curation before they age out of visibility
- NB-4: R13-R22 Gate 3 discussions Line Up batch (`gate3-r13-r22-discussions-
  lineup-v0`) remains pending; higher authority-hoist risk than the pre-Gate-3
  batch; Archive/Form review should be explicitly assigned

Next recommended card: spec-sync card to rename Ch11 profile OOF codes from
`OOF-PR*` to `OOF-PROF*` or `OOF-PF*` (P-54), unblocking
`prop037-descriptor-oof-pr-proof-v0`.
