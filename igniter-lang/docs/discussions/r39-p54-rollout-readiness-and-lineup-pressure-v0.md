# Discussion: R39 P-54, Rollout Readiness, and Line Up Pressure v0

Card: S3-R39-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure + documentation-pressure
Mode: discussion
Initiator: user
Track: r39-p54-rollout-readiness-and-lineup-pressure-v0

Question:

Did R39 close P-54 cleanly without residual OOF-PR* ambiguity? Does the
Phase 1 durable audit operational rollout readiness plan stay strictly
design-only with no implementation or deployment content leaking through?
Does the Line Up authority-hoist review correctly hold movement gates? Does
the Gate 3 R13-R22 discussions Line Up separate historical pressure from
current authority without letting stale Gate 3 language appear as live
authorization?

Context:
- C1-P1 (Compiler/Grammar Expert): Ch11 profile OOF namespace sync — renames
  OOF-PR1..3 to OOF-PROF1..3; closes P-54
- C2-P1 (Research Agent): Phase 1 durable audit operational rollout readiness
  plan — design-only; 10-area matrix; 8+11 blocker lists; operational rollout
  remains closed
- C3-P1 (Archive/Form Expert): Line Up authority-hoist risk review — covers
  R38 three-batch Line Ups; identifies RQ-1 and RQ-2 required before movement;
  movement recommendation revise-light
- C4-P1 (Line Up Summarizer): Gate 3 R13-R22 discussions Line Up — creates
  `gate3-r13-r22-discussions-spine.md`; high-risk surface; defers Archive/Form
  verification

---

[Agree]

1. **C1-P1 namespace sync is clean and minimal.** The rename of `OOF-PR1..3`
   to `OOF-PROF1..3` in `ch11-profile-system.md` is targeted: three renames, one
   namespace note, and a date update. No PROP-037 progression diagnostics are
   touched. No compiler behavior is changed. The path forward for both profile
   and progression diagnostic namespaces is now unambiguous in current spec text.
   P-54 is correctly closed.

2. **C2-P1 two-tier blocker structure is correct design for a staged gate.**
   Having separate 8-item and 11-item blocker lists — one for any operational
   implementation card and one for operational rollout authorization — is the
   right shape. The distinction prevents a future card from misreading "Architect
   approves implementation card" as "rollout is authorized." The 11th rollout
   blocker ("Architect issues a separate rollout authorization decision") makes
   the final gate explicit. The safe status phrase ("Operational rollout remains
   closed. This plan identifies the evidence required before a later Architect
   review can consider rollout authorization.") correctly scopes the entire
   document.

3. **C2-P1 excluded-surface discipline is comprehensive.** The smoke checklist
   explicitly names "Excluded Ledger/Phase2/BiHistory/stream/OLAP/cache/
   RuntimeMachine paths | unreachable / refused" as a required smoke path. The
   Reader "must not" list correctly excludes Gate 3 authorization, Ledger/runtime
   store queries, and broad OLAP/analytics/subscription surface. The owner table
   explicitly states "No owner may use this plan to bind Ledger, broad
   RuntimeMachine, Phase 2, BiHistory, stream/OLAP, production cache, concrete
   HSM/KMS onboarding, or TBackend surfaces." The disable/rollback rule ("Rollback
   means disabling the audit surface and preserving records as-is") closes the
   most dangerous rollback confusion path — repair/compact/replay masquerading as
   rollback.

4. **C3-P1 authority-hoist review correctly holds movement gates.** The
   revise-light-before-movement recommendation is sound: the package/gem spine
   and typed-switch spine can proceed to movement planning, but discussion-index
   redirects for R2-R12 are correctly blocked until RQ-1/RQ-2 are applied and
   the R13-R22 Line Up lands. The RQ-2 fix (authority pointer from `meta-
   proposals/` to `docs/gates/`, `current-status.md`, `agent-context.md`) is the
   more important of the two: sending future agents to a stale authority path is a
   higher-risk error than a permissive route phrasing.

5. **C4-P1 Gate 3 Line Up has strong anti-hoist structure.** The document
   contains the key guardrail phrase from R20: "Signing changes caller policy, not
   executor behavior." The "Current Authority" section correctly points to
   `agent-context.md`, `current-status.md`, `docs/gates/README.md`, and the signed
   addendum, not to `meta-proposals/` (avoiding the RQ-2 pattern that C3-P1 found
   in the pre-Gate-3 spine). The "Superseded Route" section explicitly says
   "Proof-local registry/audit shapes do not supersede production registry,
   production signing, durable audit, or Phase 2 Ledger requirements." The "Canon
   / History / Research / Value" section closes with "Not promoted here: production
   durable audit, production registry, production signing, Ledger adapter, Phase 2,
   BiHistory, stream/OLAP, cache, writes, or broad RuntimeMachine binding."

---

[Challenge]

1. **C1-P1 does not audit for stale OOF-PR* references in other documents
   (documentation-pressure lens).** The rename touches only `ch11-profile-
   system.md`. Any other document that previously cited the Ch11 profile
   diagnostics by their old names (OOF-PR1, OOF-PR2, OOF-PR3) now refers to
   non-existent codes. The C1-P1 track does not list whether other docs or tracks
   cite the old Ch11 names. At the design stage this is acceptable — the old codes
   were proposed-only — but any future PROP-034 or profile-system proof card that
   relied on the old names will silently reference the wrong namespace until those
   docs are updated. The C1-P1 recommendation for future PROP-034/profile work is
   correct but passive. Non-blocker; NB.

2. **C2-P1 introduces `kind: phase1_audit_storage` that does not appear in the
   R37-C2-I proof-local validation logic (runtime-pressure lens).** The R37-C2-I
   proof-local `Phase1DeploymentConfig` validates storage kind by refusing
   `ledger`, `local`, `stub`, and `test` patterns. The design plan now names a
   specific intended kind `phase1_audit_storage`. This kind name must pass the
   positive acceptance branch of the existing storage kind validation, not just
   avoid the refusal patterns. A future implementation card that inherits this
   design plan and the proof-local config could find a subtle gap if the kind
   name evolves or if the validation logic is acceptance-list-based rather than
   refusal-list-based. Non-blocker for the design plan; the kind-name consistency
   check belongs in the implementation card. NB only — but it should be an
   explicit named requirement in the implementation card's scope.

3. **C2-P1 uses `concrete_provider: not_selected_in_this_plan` as a YAML field
   placeholder (documentation-pressure lens).** In the signer abstraction
   descriptor sample, `concrete_provider: not_selected_in_this_plan` is a field
   whose value declares the absence of a decision. This is clear in intent, but
   the field name (`concrete_provider`) embedded in design material could be
   picked up as a required field name by a future implementation card. If an
   implementation agent reads this as a descriptor contract, `concrete_provider`
   might get implemented as a literal field — even though it is only meant to
   document the design boundary. Safer to state this boundary in prose: "Concrete
   HSM/KMS provider selection is out of scope for this plan." Non-blocker; NB.

4. **C4-P1 Gate 3 Line Up `Remaining Blockers` table reflects R22 state but
   has no explicit row-level timestamp (documentation-pressure lens).** The table
   header says "Still closed or open as of the R22 compressed state," which is the
   correct scoping label. However, `durable audit / production storage` is listed
   as "Open future work; proof-local envelope only." As of R39, durable audit has
   a B-E deployment decision, a proof-local restricted deployment package
   (R37-C2-I), an Architect proof-local confirmation (R38-C1-A), and an
   operational rollout readiness plan (R39-C2-P1). A reader who does not catch the
   "as of the R22 compressed state" header will see this row and conclude durable
   audit is still at the R22 state. The table header is correct, but the risk of
   misreading is real given that this Line Up is intended for public archive where
   readers may scan rows without reading headers. Non-blocker; NB.

5. **C4-P1 Archive/Form verification has not been performed (documentation-
   pressure lens).** C3-P1 reviewed the three R38 Line Ups (compiler/package
   spine, Stage 2→3 typed switch spine, old pre-Gate-3 spine). C4-P1 was created
   in the same R39 round, after C3-P1 landed. The C4-P1 handoff correctly says
   "Archive/Form should verify no production authority leaked into the summary,"
   but no Archive/Form card covers C4-P1 in R39. The Gate 3 R13-R22 Line Up is
   the highest-risk summary batch (it covers the Gate 3 decision, signed addendum,
   and post-signature scope). Leaving it with only a deferred Archive/Form note
   creates a gap that mirrors the RQ-1/RQ-2 gap from C3-P1 — acceptable for now,
   but must be a named follow-up before movement or discussion-index redirects.
   → **P-55 (new).**

6. **RQ-1 and RQ-2 from C3-P1 are outstanding and block discussion-index
   redirects for R2-R12 (documentation-pressure lens).** C3-P1 explicitly says
   these edits are "required before discussion-index redirects or movement." No
   R39 card applies them. This is expected — C3-P1 routes them to the "Line Up
   Summarizer or assigned docs agent" — but they have no tracking item yet. Without
   a tracking item they could be missed in a future round's status curation before
   someone attempts R2-R12 redirects. → **P-56 (new).**

---

[Missing]

1. **`prop037-descriptor-oof-pr-proof-v0` is not yet opened.** C1-P1 closes the
   namespace blocker. The proof is now unblocked from a namespace standpoint but
   was not opened in R39. This is expected given that P-54 was resolved in the
   same round.

2. **No Archive/Form card is assigned for C4-P1 in R39.** The Gate 3 R13-R22
   Line Up was created by C4-P1, the authority-hoist review (C3-P1) preceded it,
   and Archive/Form verification is deferred. The gap is correctly named in the
   C4-P1 handoff but carries no tracking item. → P-55.

3. **RQ-1 and RQ-2 edits to `old-discussions-pre-gate3-spine.md` are not
   applied.** Required before discussion-index redirects per C3-P1. Routed to
   docs agent with no tracking item. → P-56.

---

[Sharper Question]

C2-P1 introduces `kind: phase1_audit_storage` as the intended production storage
kind. The R37-C2-I proof validates storage kind against a refusal list (ledger/
local/stub/test patterns). If the production implementation uses an acceptance-
list check instead of (or in addition to) the refusal-list check, would
`phase1_audit_storage` need to appear in that acceptance list — and if so, where
is that acceptance-list decision made: in this design plan, in the implementation
card, or in a future Architect authorization?

---

[Route]

PROCEED (non-blockers only).

Checklist:
- P-54: CLOSED by C1-P1 (OOF-PROF1..3 established in Ch11; OOF-PR* reserved
  for PROP-037 progression diagnostics; namespace unambiguous)
- P-55: NEW — Archive/Form verification of Gate 3 R13-R22 discussions Line Up
  before movement or discussion-index redirects (C4-P1 not covered by C3-P1)
- P-56: NEW — Apply RQ-1 and RQ-2 to `old-discussions-pre-gate3-spine.md`
  before any R2-R12 discussion-index redirects or movement

Non-blockers (NB):
- NB-1: C1-P1 does not audit other docs for stale OOF-PR1..3 references; any
  future PROP-034/profile-system card must check and update old citations
- NB-2: `kind: phase1_audit_storage` in C2-P1 is not present in R37-C2-I
  validation logic; implementation card must explicitly confirm kind-name
  consistency with existing storage identity acceptance/refusal logic
- NB-3: `concrete_provider: not_selected_in_this_plan` in C2-P1 signer
  descriptor sample is a placeholder-as-field pattern; clearer as prose to
  avoid accidental implementation as a literal field name
- NB-4: `durable audit / production storage` row in Gate 3 Line Up reflects R22
  state and is stale relative to R37-R39 progress; correctly labeled "as of the
  R22 compressed state" but could be misread by a scanning reader

Next recommended cards:
1. Apply RQ-1 and RQ-2 to `old-discussions-pre-gate3-spine.md` (P-56)
2. Archive/Form verification of Gate 3 R13-R22 Line Up (P-55)
3. `prop037-descriptor-oof-pr-proof-v0` — now unblocked from namespace
   standpoint; namespace check PASS; runtime/implementation exclusions preserved
