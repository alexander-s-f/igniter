# Discussion: PROP-036 B7/B8 Docs And Criteria Pressure v0

Card: S3-R47-C4-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure
Mode: discussion
Initiator: user
Track: prop036-b7-b8-docs-and-criteria-pressure-v0

Depends on: S3-R47-C3-A delivered

Question:

Are the `docs/ruby-api.md` public docs genuinely caller-facing and linked? Do
they imply CLI path loading or runtime authority? Is transport-only wording
present? Is the B8-C source-comment deferral by proper authority? Are the three
R46 precision NB items (B1 validation chain, B6 scanner self-test, B8-C deferral
authority) closed in the binding gate or safely deferred? Does implementation
remain closed?

Context:
- C1-P1 (Compiler/Grammar Expert): Created `docs/ruby-api.md` and updated
  `docs/README.md`; full B7/B8 content; recommends B7/B8 closed; records B8-C
  deferral as "deferral path: docs/tracks/prop036-cli-b7-b8-ruby-api-docs-v0.md"
- C2-P1 (Research Agent): Proposed exact wording for minor precision addendum
  covering B1 validation chain, B6 scanner self-test, and B8-C deferral
  authority; recommended addendum before implementation authorization
- C3-A (Architect): Closed B7 and B8; adopted all three precision amendments
  (B1/B6/B8-C) into the governing gate; Architect-level B8-C deferral with gate
  document as the named deferral path; implementation remains held
- R46 C4/C5: C4-A established closure criteria for B1/B3/B6/B7/B8; C5-X found
  three precision NB items now resolved by C3-A

---

[Agree]

1. **B7 closure is mechanically verified.** All seven B7 sub-criteria (B7-A
   through B7-G) pass. Verified directly:

   - `docs/ruby-api.md` exists at the named path ✓
   - `docs/README.md` line 17: "Ruby API facade → ruby-api.md" ✓
   - `docs/ruby-api.md` line 23: `compiler_profile_source: nil` in the signature ✓
   - Supported shapes stated: "nil" and "already-finalized
     compiler_profile_id_source Hash-like object" ✓
   - Required finalized source fields enumerated ✓
   - Nil `legacy_optional` behavior stated ✓
   - Invalid caller assumptions explicitly listed: file path, raw JSON string, raw
     `compiler_profile_id` string, unfinalized descriptor, runtime-authority
     object, dispatch-migration object ✓
   - Non-authorized surfaces listed with full enumeration from CLI flags through
     production behavior ✓

   Track docs alone did not close B7 — the public API doc landing did.

2. **The docs do not imply CLI path loading or runtime authority.** The opening
   paragraph of `ruby-api.md` explicitly states: "The Ruby facade is not the CLI.
   CLI profile-source flags, path loading, inline JSON parsing, profile discovery,
   and profile defaulting remain closed unless a later gate authorizes them." The
   non-authorized surfaces section lists path loading, inline JSON parsing, profile
   discovery/defaulting/finalization, and all runtime authority surfaces by name.
   No positive caller instruction mentions file paths in an accepted-input
   context.

3. **Transport-only wording is present and complete.** The "Transport-Only
   Facade" section satisfies B8-A and B8-B in full:
   - "treats `compiler_profile_source:` as transport-only" ✓
   - "forwards the value unchanged to `CompilerOrchestrator#compile`" ✓
   - "does not validate, finalize, discover, infer, load, parse, normalize, or
     default compiler profile sources" ✓
   - "A future card that widens orchestrator/assembler validation must explicitly
     review whether the Ruby facade should expose that widened shape to callers" ✓
   - "Future orchestrator/assembler validation widening does not automatically
     close the facade/API review requirement" ✓

4. **B8-C source-comment deferral is by explicit Architect authority.** C3-A
   states: "This Architect decision explicitly defers source-level comment
   visibility for this phase." The named deferral path is
   `igniter-lang/docs/gates/prop036-b7-b8-docs-and-criteria-precision-review-v0.md`
   — the gate itself, not a track. C3-A Amendment 3 (imported from C2-P1)
   requires: "Source-level visibility may be deferred only by an explicit
   Architect decision or gate document." C3-A is that Architect decision. The
   rule and its application coexist in the same gate, which is legitimate: the
   Architect has authority to both define the deferral standard and exercise it
   in the same decision.

5. **All three R46 precision NB items are now binding in the gate.** C3-A
   incorporates all three amendments from C2-P1:

   - Amendment 1 (B1 validation chain): `standalone_artifact_valid: true` must
     mean validation by "the same compiler-profile-source validation path used by
     the finalization proof and assembler source contract" — not JSON
     well-formedness or field presence alone. Proof summary must record
     `standalone_artifact_validation_path`. ✓ binding in C3-A.

   - Amendment 2 (B6 scanner self-test): B6 proof must include an adversarial
     fixture injecting a bare forbidden token (e.g. `present_verified`) that the
     scanner must report FAIL. Proof summary must record
     `scanner_self_test_bare_forbidden_token_fails: true` and
     `scanner_self_test_qualified_source_validation_allowed: true`. ✓ binding in
     C3-A. B6 status is "open" with this new requirement explicitly stated.

   - Amendment 3 (B8-C deferral authority): track recommendation alone does not
     close B8-C; only Architect gate/decision may authorize deferral. ✓ binding
     in C3-A.

6. **`runtime_authority_granted: false` in the example JSON is not a vocabulary
   leak.** The field appears in the example source object at lines 67 and 102 of
   `docs/ruby-api.md`. The exact forbidden token is `runtime_authority` as a
   standalone JSON key or scalar value. `runtime_authority_granted` is a
   different compound field name — not an exact token match. The B6 scan applies
   to JSON artifacts, not Markdown documentation. Additionally, the field value
   is `false`, and the distinction between this source-object authority flag and
   the loader-status/runtime-readiness vocabulary was established and documented
   in R44/C4-P2. No vocabulary leak.

7. **Implementation remains closed.** C3-A's non-authorization list is identical
   in scope to C2-A (the original exposure authorization), C3-A (the CLI design
   route decision), and C4-A (the closure-criteria addendum). CLI flags, path
   loading, JSON parsing, profile finalization/discovery/defaulting, loader/report,
   CompatibilityReport, and all downstream surfaces are explicitly excluded.

---

[Challenge]

1. **C1-P1's B8-C deferral claim cites a track, not a gate (documentation
   precision lens).** C1-P1 records: "deferral path:
   docs/tracks/prop036-cli-b7-b8-ruby-api-docs-v0.md." Under C3-A Amendment 3,
   a track recommendation alone cannot close B8-C. C1-P1 was written before
   C3-A adopted that standard, so the track's self-assertion was made under the
   prior (ambiguous) wording. C3-A supersedes it with Architect-level deferral
   and records the correct gate path. Functionally the deferral is proper. But
   a future reviewer reading C1-P1 in isolation could take the track-level
   deferral claim at face value and cite C1-P1 as B8-C closure authority rather
   than C3-A. Non-blocker; NB.

---

[Missing]

1. **C1-P1's deferral path claim.** The track-level self-assertion for B8-C in
   C1-P1 could confuse future readers. C3-A is the authoritative record of B8-C
   deferral. Any future card closing B8 should cite C3-A's gate path, not
   C1-P1's track path. A brief correction note in C1-P1's handoff section, or a
   clear statement in C3-A that C1-P1's deferral claim is superseded by
   Architect authority here, would eliminate the ambiguity. This is a
   documentation hygiene item, not a safety gap.

---

[Sharper Question]

B8-C is now closed by Architect-level deferral in C3-A. C1-P1 independently
claims the same closure by track self-assertion. Should the C1-P1 track record
be annotated to state that its B8-C deferral claim is superseded by C3-A's
Architect decision, or is C3-A's authoritative record sufficient to prevent
future misattribution without annotation?

---

[Route]

**Verdict: proceed.**

All six scope check items pass. B7 and B8 are properly closed with mechanically
verified evidence. The three R46 precision NB items (B1 validation chain, B6
scanner self-test, B8-C deferral authority) are now in the binding gate (C3-A).
No vocabulary leaks, no CLI implication, no runtime authority suggestion in the
public docs. Implementation remains firmly held.

Blockers: none.

Non-blockers (NB):
- NB-1: C1-P1 records a track-level self-assertion as the B8-C deferral path;
  C3-A supersedes it with Architect authority and records the correct gate path;
  future B8 closure evidence must cite C3-A, not C1-P1; a documentation
  annotation would eliminate residual ambiguity

Next recommended surface (single bounded slice):
- B1 closure proof: emit and validate `compiler_profile_source.stage3_proof.json`
  under the updated C3-A Amendment 1 standard (full source-validation-chain
  evidence, not JSON-only well-formedness)
- B3/B4/B5 proof matrix: requires implementation readiness; may be combined with
  B6 adversarial scanner self-test in a single CLI implementation proof card after
  all other blockers close
- B9 (pressure review) will occur automatically once an implementation card is
  proposed
