# Discussion: R41 PROP-037, Gate 3 Line Up, No-Zombie Plan, and Context Capture Pressure v0

Card: S3-R41-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure + documentation-pressure
Mode: discussion
Initiator: user
Track: r41-prop037-gate3-context-capture-pressure-v0

Question:

Does the PROP-037 CompatibilityReport readiness proof correctly keep runtime
readiness refusal separate from OOF without accidentally authorizing scheduler
behavior? Does the Gate 3 Line Up hardening and no-zombie plan hold movement
gates at the right level? Does the Contextizer / Context Capture shadow-boundary
track avoid letting candidate pack labels, CLI vocabulary, or specimen shapes
become de-facto canon?

Context:
- C1-P1 (Research Agent): PROP-037 CompatibilityReport readiness proof — 10
  checks PASS; `report_mode: report_only`; `separate_from_compiler_oof: true`;
  10 live-call invariants all false; open ownership question on `progression_sources`
- C2-P1 (Line Up Summarizer): Gate 3 R13-R22 Line Up historical blockers
  hardening — renames section; adds current-state pointer; optional hardening
  from R40 NB-4 now applied
- C3-P1 (History Curator): Gate 3 discussion index no-zombie plan — movement/
  link plan only; 6 authority checks pass; 15 files that must remain directly
  linked; 10-item no-zombie checklist; Architect approval still required before
  execution
- C4-A (Architect): Context Capture Pack shadow-boundary routing decision —
  design/research-only authorized; 8 required guardrails; CLI class names
  explicitly "external utility vocabulary, not accepted Igniter-Lang names"
- C5-P2 (Research Agent): Context Capture Pack shadow boundary — 8 candidate
  boundaries; all labeled "candidate labels only"; CLI vocabulary table with
  "external utility signal" labels; pressure-only snapshot shape; 10 risk
  boundaries; 7 candidate future routes

---

[Agree]

1. **C1-P1 proves OOF/readiness separation explicitly and adds two new proof
   mechanisms.** The `"separate_from_compiler_oof": true` field in the runtime
   readiness section and the `runtime_refusal_separate_from_compiler_oof: ok`
   proof check directly validate the key architectural boundary from C3-P1 (R38):
   a valid descriptor with closed runtime produces a readiness refusal, not a
   compiler diagnostic. The `"report_mode": "report_only"` field in the
   CompatibilityReport output closes a subtle gateway — without this field, a
   future implementation reading the report could interpret "descriptor present"
   as implying execution readiness. The live-call invariant list expands to 10,
   adding explicit `durable_queue_call_attempted` and
   `checkpoint_persistence_call_attempted` — closing durability execution paths
   not named in the R40 proof.

2. **C2-P1 applies the R40 NB-4 optional hardening cleanly.** Renaming the
   section to "Historical R22 Remaining Blockers" and adding the
   `current-status.md` / `gates/README.md` pointer directly addresses the
   concern that a scanning reader could treat the R22 blocker table as current
   rollout state. The QA anchor and source paths are preserved. The hardening is
   scoped correctly: documentation-only, no current-authority change.

3. **C3-P1 keeps movement authority gates correctly layered.** The no-zombie
   PLAN is the right deliverable for this stage — it establishes the checklist,
   candidate redirect wording, 15 directly-linked-files requirement, and 10-item
   no-zombie checklist without executing any redirect or link rewrite. The two-
   pass approach (additive grouping first, then broad row collapsing only after
   `rg` no-zombie checks pass) is sound. The R20-R22 post-signature candidate
   wording explicitly adds "current rollout state in gates/status" — preventing
   the audit-ready/registry/content-address language from implying production
   durable audit or production signing. The requirement for separate Architect
   approval before any execution is correctly placed.

4. **C4-A directly resolves R40 NB-2.** The gate decision names the exact
   concern: "treat legacy Contextizer CLI class names such as `Analyzer`,
   `Provider`, `Renderer`, `Collector`, and `Configuration` as external utility
   vocabulary, not accepted Igniter-Lang names." This is an explicit Architect
   guardrail on the authorized card, not just an advisory NB. The 8 required
   guardrails include prohibitions on Ledger/BiHistory, ambient time, and
   production claims, and explicitly mark `/Users/alex/dev/projects/contextizer`
   as read-only evidence.

5. **C5-P2 correctly handles the naming-gravity risk from R40 NB-3.** The
   statement "All labels above are candidate labels only" appears before the
   shadow-boundary matrix. The external utility vocabulary table labels every CLI
   term as "external utility signal." The explicit statement "no candidate pack
   or profile is accepted by being named here" is the correct anti-canonization
   anchor. The `ContextSnapshot` pressure sketch uses `"captured_at":
   "explicit-input-required"` — addressing the ambient-time risk proactively.
   The Ledger/BiHistory boundary rule states "Context history persistence needs
   its own proposal/gate; existing durable-audit authority cannot be borrowed."
   This is the right guardrail: the durable-audit authorization lane must not
   be borrowed for a new context-history use case.

---

[Challenge]

1. **C1-P1 leaves `progression_sources` artifact ownership unresolved, and
   this is the primary remaining ambiguity for any future implementation
   (runtime-pressure lens).** The handoff open question asks "Which artifact
   owns `progression_sources`: manifest-only, CompatibilityReport-only, or
   both?" Until this is answered, a future implementation card could place
   progression metadata in a manifest field that participates in artifact hash
   computation (per PROP-036 ordering rules), and separately in a
   CompatibilityReport field that is consumed at load time. If those two
   placements have different ownership or different `present_verified`
   semantics, the result is a consistency gap. The `progression_profile_status:
   "present"` in the report represents descriptor presence in the proof-local
   context, but a production manifest consumer might infer from "present" that
   a scheduler can be initialized before checking runtime readiness. The
   `report_mode: "report_only"` guard is correct; it should also appear in the
   recommended schema contract card to prevent the report-only mode from being
   dropped during implementation. Non-blocker for this proof; the ownership
   question should be the explicit scope of the next recommended card. NB.

2. **C5-P2 introduces an informal `source_kind` vocabulary in the capture
   source descriptor sketch that has not been through the closed-vocabulary
   process used for PROP-037 (documentation-pressure lens).** The candidate
   descriptor uses `"source_kind": "local_project | public_git_repository |
   line_up_source | pressure_specimen"`. Unlike the PROP-037 v0 `source_kind`
   vocabulary (`clock.every`, `queue`, `external_event`), which was explicitly
   closed by the C3-A acceptance decision, this Context Capture `source_kind`
   list is a design sketch in a shadow-boundary track. A future card inheriting
   this descriptor shape might treat these values as accepted source kinds without
   a formal closure decision. The C5-P2 card correctly labels the entire
   descriptor as `"version": "context-capture-source-shadow-v0"` and the track
   as design-only, which mitigates the risk. But the source kind values
   themselves carry no "candidate only" label comparable to the pack names. NB
   for any future descriptor proof card.

3. **C3-P1 no-zombie execution card has no tracking item yet.** The plan
   correctly states "A separate index-rewrite card should be assigned before
   editing `docs/discussions/README.md`" and requires Architect approval. That
   card does not yet exist. Without a tracking item, the first-pass additive
   grouping could be deferred indefinitely or assigned informally in a future
   round without the required approval gate being explicitly re-invoked. → **P-57
   (new).**

4. **C3-P1 conditions movement on "while current-status still uses these
   discussions as route archaeology," which is an open-ended condition
   (documentation-pressure lens).** If current-status references the Gate 3
   discussions as route context for years, the "no cold/archive movement while
   current-status uses them" condition becomes an indefinite deferral. The
   condition is sensible now, but a future status curation round that stops
   referencing the discussions directly should be the trigger for re-evaluating
   movement readiness. This is not currently tracked. Non-blocker; NB.

---

[Missing]

1. **`progression_sources` manifest/CompatibilityReport schema contract card
   is not yet opened.** C1-P1 recommends it as the next slice. Not yet assigned.
   The ownership question must be decided before any progression metadata enters
   real `.igapp` manifests or real CompatibilityReport code paths.

2. **OOF-PR6 and OOF-PR8 remain deferred** pending a compiler-owned progression
   AST/typed fragment boundary. No card opens that boundary in R41. Expected.

3. **No Archive/Form verification of the C5-P2 shadow-boundary track has been
   assigned.** C5-P2 is a documentation-only research track with a large number
   of candidate labels. It carries its own non-authorization list, but the
   pattern established in R39-R40 calls for a separate Archive/Form or pressure
   review to confirm candidate labels haven't been hoisted as accepted vocabulary.
   The R41 pressure review here partially fulfills that role, but a formal
   Archive/Form check is not required at this stage given that C5-P2 is
   design-only with correct guardrails throughout. Non-blocker; noted.

---

[Sharper Question]

C1-P1 proves that `progression_profile_status: "present"` in a `report_only`
CompatibilityReport does not authorize execution. But if a future manifest schema
card places `progression_sources` in `.igapp/manifest.json` (the PROP-036 field
ordering path), does the combination of `progression_sources: [...]` in the
manifest plus `progression_profile_status: present` in the CompatibilityReport
create a "present + loadable" signal that could be misread as a weaker form of
execution authorization — even with `ready: false` and `runtime_execution_not_authorized`
in the report? Or does `report_only` fully firewall this regardless of what is
in the manifest?

---

[Route]

PROCEED (non-blockers only).

Checklist:
- P-57: NEW — Assign discussion-index additive grouping card for
  `docs/discussions/README.md` after supervisor approval (per C3-P1 no-zombie
  plan; first-pass additive rewrite only, direct rows preserved)

Non-blockers (NB):
- NB-2 (R40): RESOLVED — C4-A Architect guardrail and C5-P2 vocabulary table
  both explicitly mark Contextizer CLI class names as "external utility
  vocabulary, not accepted Igniter-Lang names"
- NB-3 (R40): ADDRESSED — C5-P2 states "no candidate pack or profile is
  accepted by being named here"; naming gravity risk reduced but monitored
- NB-4 (R40): APPLIED — C2-P1 applied the "Historical R22 Remaining Blockers"
  hardening and added current-state pointer
- NB-1 (R41): `progression_profile_status: "present"` in C1-P1 report is clear
  in proof-local context; ownership of `progression_sources` must be resolved
  in the schema contract card before any manifest implementation; `report_only`
  mode must be carried forward explicitly
- NB-2 (R41): C5-P2 candidate `source_kind` vocabulary in the descriptor sketch
  is a design sketch without formal closed-vocabulary status; downstream
  descriptor proof cards must not treat these values as accepted source kinds
- NB-3 (R41): C3-P1 movement condition tied to "while current-status uses these
  discussions as route archaeology" is open-ended; a future status curation round
  dropping direct discussion references should re-evaluate movement readiness

Next recommended cards:
1. Assign discussion-index additive grouping card (P-57) after supervisor approval
2. PROP-037 manifest/CompatibilityReport schema contract for `progression_sources`
   (C1-P1 recommended next; runtime readiness still closed)
3. `context-capture-descriptor-proof-v0` — first safe proof step for Context
   Capture Pack, following the PROP-037 descriptor-proof pattern
