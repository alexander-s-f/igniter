# Discussion: PROP-036 CLI B1 Standalone Artifact Pressure v0

Card: S3-R48-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: runtime-pressure
Mode: discussion
Initiator: user
Track: prop036-cli-b1-standalone-artifact-pressure-v0

Depends on: S3-R48-C1-I delivered

Question:

Does the B1 standalone artifact proof satisfy every requirement in C4-A and
C3-A Amendment 1? Is the validation-chain evidence real and not JSON-only? Do
the summary fields match the R47 gate requirements? Is the exact forbidden-token
scan independent and meaningful? Does the artifact imply any loader-status,
CLI path loading, or runtime authority? Does implementation remain held?

Context:
- C1-I (Research Agent): Emitted `compiler_profile_source.stage3_proof.json`
  at the stable path; proof updated to 27/27; all 5 required summary fields
  recorded; validation via `finalization_and_assembler_source_contract`; exact
  forbidden-token hits: 0; assembler field regression: 19/19
- C4-A (R46 Architect): Governing B1 closure criteria — 5 items, "not closed by"
  list, mechanical evidence requirements
- C3-A (R47 Architect): Amendment 1 — `standalone_artifact_valid: true` must
  mean validation by the same source contract as finalization proof/assembler;
  not JSON-only; proof summary must record `standalone_artifact_validation_path`

---

[Agree]

1. **Artifact exists at the exact required stable path.** Independently verified:
   `igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/
   compiler_profile_source.stage3_proof.json` exists as a top-level
   `compiler_profile_id_source` JSON object with `status: finalized`.

2. **Artifact is not a summary wrapper.** Independent verification:
   `artifact.wrapper=false` — no `finalized_source_example` key at the top
   level. The artifact is the source object itself, not an envelope containing
   it.

3. **All 12 canonical slots are present and complete.** Independent verification:
   `slot_order` matches the canonical 12-slot list exactly; `slot_assignments`
   keys match `slot_order`; all 12 slots carry a non-empty `implementation_id`.
   No discovery, defaulting, or lookup is implied by the artifact structure —
   all assignments are explicit.

4. **ID prefix formats are correct.** Independent verification:
   - `compiler_profile_id` begins with `compiler_profile_unified/sha256:` ✓
   - `descriptor_digest` begins with `compiler_profile_descriptor/sha256:` ✓
   - `finalization_payload_digest` begins with `sha256:` (full 64 hex chars) ✓

5. **Authority flags are correctly false.** `dispatch_migration_authorized: false`
   and `runtime_authority_granted: false`. The artifact cannot be read as
   granting runtime authority or dispatch migration. These are the same source-
   object authority flags whose closed state has been proven by V6/V7 across
   every prior PROP-036 proof round.

6. **Validation-chain evidence satisfies C3-A Amendment 1.** The proof summary
   records `standalone_artifact_validation_path="finalization_and_assembler_
   source_contract"` — not "json_wellformed" or "field_presence_only". The
   proof check `B1.standalone_artifact_validates_via_source_contract` PASS
   confirms that the artifact was passed through `validate_source!`, the
   same validator that drives V1..V7 (covering unfinalized status, unsupported
   namespace, malformed id, digest mismatch, slot-order mismatch, runtime
   authority flag, and dispatch migration flag). This is not JSON-only
   well-formedness. C3-A Amendment 1 is satisfied.

7. **Exact forbidden-token scan is real and independently verified.** The
   proof records `standalone_artifact_exact_forbidden_token_hits=0`. Independent
   scan (external to the proof script) confirms: 0 exact hits from the full
   10-token forbidden list (`absent_legacy`, `present_verified`, `mismatch`,
   `malformed`, `missing_required`, `runtime_ready`, `evaluation_ready`,
   `gate3_authorized`, `runtime_authority`, `production_ready`) against the
   standalone artifact JSON. Neither keys nor scalar values match any forbidden
   token exactly.

8. **All 5 required C4-A B1 summary fields are present with correct values.**
   Independent verification:

   ```text
   standalone_artifact_path = "igniter-lang/experiments/…/compiler_profile_source.stage3_proof.json"
   standalone_artifact_exists = true
   standalone_artifact_valid = true
   standalone_artifact_validation_path = "finalization_and_assembler_source_contract"
   standalone_artifact_exact_forbidden_token_hits = 0
   ```

9. **Named generation command is the existing finalization proof.** The
   artifact is produced by
   `ruby igniter-lang/experiments/minimal_compiler_profile_finalization_proof/
   minimal_compiler_profile_finalization_proof.rb` — the same command
   established in C4-A B1 item 3. The command reproduces the artifact reliably
   (proof 27/27 PASS; artifact fields identical on independent re-read).

10. **Neighbor regression is green.** Assembler field proof 19/19 PASS confirms
    the source-validation contract used by the finalization proof is unaffected
    by the proof changes that added the B1 artifact and checks.

11. **No CLI/path-loading/runtime authority implication.** C1-I's non-
    authorization list is consistent with all prior gates. No CLI file was
    touched. The artifact is a proof-owned output, not a CLI behavior change.

---

[Challenge]

1. **B1 formal closure still awaits Architect gate acceptance (runtime-pressure
   lens).** C1-I recommends "B1 closed." All five C4-A closure items are
   satisfied and independently verified here. However, the precedent from B7/B8
   is that a blocker closes when an Architect gate (C3-A for B7/B8) formally
   records it as closed, not when a research or implementation card alone
   recommends it. C4-A requires that the future CLI implementation authorization
   "explicitly close every blocker below" — which implies an Architect gate must
   accept the B1 closure evidence before the implementation authorization can
   cite B1 as closed. The evidence is ready; the formal gate record is not yet
   written. Non-blocker for the artifact quality assessment; NB for the B1
   closure status chain.

---

[Missing]

1. **Architect gate confirmation of B1 closure.** The artifact and closure
   evidence satisfy every C4-A and C3-A requirement. A brief Architect gate
   acknowledgment — either a standalone B1-closure gate record or inclusion in
   a CLI implementation-authorization gate — is the remaining step before B1
   is formally recorded as closed. This is a process step, not a quality gap.

---

[Sharper Question]

All required evidence exists and is independently verified. The only remaining
step is Architect formal closure. Should B1 closure be recorded in a dedicated
gate addendum now, or should it be bundled into the CLI implementation
authorization gate as part of the full B1..B9 closure package?

---

[Route]

**Verdict: proceed.**

The B1 standalone artifact proof satisfies every C4-A and C3-A Amendment 1
requirement. Artifact quality is clean across all independent verification
checks. No vocabulary leaks, no CLI implication, no runtime authority surface.
Proof 27/27 PASS; neighbor regression 19/19 PASS; validation is real
(`finalization_and_assembler_source_contract`), not JSON-only.

Blockers: none.

Non-blockers (NB):
- NB-1: B1 formal closure awaits Architect gate acceptance — the evidence
  satisfies all criteria; a gate record (standalone or bundled with
  implementation authorization) is the remaining process step

Next recommended surface (single bounded slice):

B1/B2/B7/B8 are satisfied. Remaining CLI blockers are B3/B4/B5/B6 and B9.
B4/B5 require actual CLI implementation. B3 hybrid model is already designed
(C2-P1, adopted in C4-A). B6 adversarial scanner self-test is defined (C3-A
Amendment 2). These four naturally form a single CLI implementation proof
bundle:

- Authorize a CLI implementation card that adds `--compiler-profile-source
  PATH.json` to `igc compile`, using only the C3-A approved hybrid refusal
  model, and requires the full B3/B4/B5/B6 proof matrix including the C3-A
  Amendment 2 adversarial scanner self-test
- B9 pressure review follows automatically as this present card's successor on
  the implementation proof

Bundling B3/B4/B5/B6 into one implementation card is preferable to staging
them because B6 scan surface depends on B3/B4/B5 artifact classes — all four
closure proofs require CLI behavior to have landed first.
