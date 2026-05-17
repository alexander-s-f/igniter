# Discussion: PROP-038 Proof-Local Missing-After Pressure v0

Card: S3-R63-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: implementation-pressure
Mode: discussion
Initiator: user
Track: prop038-proof-local-missing-after-pressure-v0

Depends on: S3-R63-C1-I delivered

Question:

Was write scope limited to `igniter-lang/experiments/compiler_profile_contract_proof/`?
Does the new case cover `after` references to a missing rule? Does it assert
`compiler_profile_contract.missing_rule_reference`? Do diagnostics remain
proof-local? Did proof-local summary output update without `.igapp`, golden,
CLI/API, loader/report, CompatibilityReport, runtime, or production changes? Are
24+ digest refs still proof-local only? Are report-only compiler integration and
compile refusal still held?

Context:
- R62-C3-A (gate): Authorized proof-local implementation only inside
  `experiments/compiler_profile_contract_proof/`; required missing-`after` case
  with `compiler_profile_contract.missing_rule_reference` diagnostic; explicitly
  held report-only integration and compile refusal; confirmed 24+ hex digest
  policy for proof-local scope only
- R63-C1-I: Implementation Agent — added `missing_after_rule_reference` case;
  mutation: `rules[0].after = ["parse.nonexistent_rule"]`; summary updated to
  23 checks / 13 cases / PASS; no production code touched

---

## Scope Check 1 — Write Scope Was Limited To The Authorized Directory

The track states edited files explicitly:

```text
igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json
igniter-lang/docs/tracks/prop038-proof-local-missing-after-implementation-v0.md
```

All three are within the authorized boundaries:
- The first two are in `experiments/compiler_profile_contract_proof/` — the
  exact authorized directory ✓
- The third is the track doc delivery artifact, explicitly required by the
  authorization gate ("Deliver: Track doc in `igniter-lang/docs/tracks/`") ✓

The track's scope statement: "No production compiler code was changed. No changes
were made to parser, TypeChecker, SemanticIR, assembler, `.igapp`, CLI/API,
loader/report, CompatibilityReport, dispatch, RuntimeMachine, Gate 3,
Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior." ✓

---

## Scope Check 2 — New Case Covers `after` References To A Missing Rule

The implementation uses mutation:

```text
ordered_rule_graph.rules[0].after = ["parse.nonexistent_rule"]
```

The first rule (`parse.contract_modifiers`) has its `after` array set to
reference `"parse.nonexistent_rule"` — a rule id that does not exist in
`ordered_rule_graph.rules`. ✓

This is precisely the direction gap identified in R60-C2-X NB-1: the R60 proof
tested a missing `before` target; R63 now tests a missing `after` target.

Independent verification from the summary JSON:

```json
{
  "name": "missing_after_rule_reference",
  "valid": false,
  "diagnostics": [{
    "code": "compiler_profile_contract.missing_rule_reference",
    "message": "ordered rule parse.contract_modifiers references missing rule \"parse.nonexistent_rule\"",
    "path": "ordered_rule_graph.rules.parse.contract_modifiers"
  }],
  "diagnostic_codes": ["compiler_profile_contract.missing_rule_reference"]
}
```

The message wording — "references missing rule" — is direction-neutral, matching
the R60 `before`-direction message exactly. This confirms the validator applies
the same referential-integrity check to both `before` and `after` entries without
distinguishing direction in the diagnostic output. ✓

**R60-C2-X NB-1 is now machine-closed.** The direction-agnostic referential-
integrity claim in PROP-038 §8.1 ("Every target in `before` and `after` must
resolve to a declared `rule_id`") is now backed by machine-asserted proof cases
for both directions. ✓

---

## Scope Check 3 — Diagnostic Is `compiler_profile_contract.missing_rule_reference`

From the summary JSON:
- `diagnostic_codes: ["compiler_profile_contract.missing_rule_reference"]` ✓
- `checks[].name = "missing_after_rule_reference.diagnostic"` → `pass: true` ✓

Machine-asserted. The correct namespace is used; no loader/report vocabulary,
no obligation vocabulary, no source vocabulary. ✓

The diagnostic code is identical to the R60 `before`-direction case — confirming
the single `missing_rule_reference` diagnostic covers both reference directions.
The PROP does not need a separate `missing_after_rule_reference` code. ✓

---

## Scope Check 4 — Diagnostics Remain Proof-Local

The track states: "Diagnostics remain local to the proof script." ✓

Non-authorization list confirms: "No production compiler integration; ... centralized diagnostics in `IgniterLang::Diagnostics`" not created. ✓

The summary JSON `non_authorizations_preserved` block: all 13 flags are `false` —
machine-asserted that no forbidden surface was touched. ✓

The R62-C3-A gate directive: "`compiler_profile_contract.*` diagnostics stay
inside the proof script" — satisfied. ✓

---

## Scope Check 5 — Proof-Local Summary Updated; No Other Changes

Independent summary JSON verification:

| Field | R60 value | R63 value | Delta |
|---|---|---|---|
| `track` | `compiler-profile-contract-validator-coverage-proof-v0` | `prop038-proof-local-missing-after-implementation-v0` | updated ✓ |
| `extends_track` | `compiler-profile-contract-proof-v0` | `compiler-profile-contract-validator-coverage-proof-v0` | correctly advanced ✓ |
| `status` | `PASS` | `PASS` | preserved ✓ |
| `cases` count | 12 | 13 | +1 new case ✓ |
| `validator_case_matrix` count | 12 | 13 | +1 new row ✓ |
| `checks` count | 22 | 23 | +1 new check ✓ |
| Failing checks | 0 | 0 | no regressions ✓ |
| `non_authorizations_preserved` | all false | all false | preserved ✓ |

The canonical contract object (slot schema, ordered_rule_graph, non_authority
flags, digests) is unchanged. All 22 R60 checks still pass with no regressions. ✓

The `extends_track` lineage correctly advances from R60's validator coverage proof
rather than jumping to an earlier track. The proof chain is R58 → R60 → R63. ✓

---

## Scope Check 6 — Digest References Remain Proof-Local Only

The summary JSON canonical contract still carries:

```text
descriptor_digest: "compiler_profile_descriptor/sha256:0a2b4b79dda5d9657e6642b3"  (24-char)
finalization_payload_digest: "sha256:a3829357ff3d34d23a82f5b7fbe22018fa66ef88efa5dd9bd04ab10f4fe4d8d4"  (64-char)
```

Short 24-char references remain for `descriptor_digest` and `contract_digest`,
as permitted by the R62-C3-A gate:

```text
descriptor_digest: 24+ lowercase hex accepted [proof-local]
contract_digest:   24+ lowercase hex accepted [proof-local]
```

The track states: "The proof-local digest reference policy remains PROP-038-
compatible: descriptor_digest: compiler_profile_descriptor/sha256:<24+ lowercase
hex>; contract_digest: compiler_profile_contract/sha256:<24+ lowercase hex>." ✓

The gate's constraint for durable/persisted output (full 64-character SHA-256
required) is not violated — no durable or persisted output was created. ✓

The open policy questions from B1 (descriptor digest input material) and B2
(short-vs-full policy for durable output) remain correctly unresolved for this
proof-local scope. ✓

---

## Scope Check 7 — Report-Only Integration And Compile Refusal Remain Held

The track non-authorization section explicitly preserves:
- "report-only compiler integration" ✓
- "compile refusal" ✓

The recommendation section: "report-only compiler integration and compile refusal
should remain held" ✓

The handoff [D] Decisions: "First implementation should be proof-local only.
Report-only compiler integration is held pending contract-input and report output
policy. Compile-refusal capability is not ready." ✓

The open questions in the handoff correctly name the still-unresolved policy
questions:
- "Descriptor digest input material remains unresolved outside proof-local
  projection."
- "Persisted/durable short-vs-full digest policy remains unresolved outside
  proof-local output."

These are correctly carried forward, not accidentally resolved. ✓

---

## Additional Integrity Check: Proof Chain Counts Are Consistent

The track summary reports `library_blockers=4` and `integration_blockers=5`.
These replace the old `remaining_blockers_before_prop_authoring` and
`remaining_blockers_before_implementation_authorization` fields from the R60
summary. The restructured blocker groups are:

**Library blockers (4):** These correspond to the policy questions that must
be resolved before Option B (isolated library validator) can be authorized:
1. Descriptor digest input material
2. Short-vs-full digest policy for implementation
3. Diagnostic namespace placement (proof-local vs. production helper)
4. Contract object input source (how does a non-proof caller construct one)

**Integration blockers (5):** These correspond to what must be resolved before
Options C/D (compiler integration) can be authorized:
1. Compiler insertion point
2. Report/output location
3. Report-only vs. refusal authorization
4. Fixture/golden policy
5. Public API/CLI contract input

This restructuring correctly reflects the two future gate paths (library extract
first, then compiler integration), replacing the earlier PROP-authoring-focused
blocker labels that were stale after PROP-038 was accepted. ✓

---

[Agree]

1. **R60-C2-X NB-1 is machine-closed.** Both `before` and `after` directions
   for missing rule references are now proof-asserted. PROP-038 §8.1's
   direction-agnostic referential-integrity invariant is fully evidence-backed.

2. **Write scope was exactly right.** Proof experiment + track doc only. No
   production, no CLI, no API, no assembler, no diagnostics helper, no goldens.

3. **The direction-neutral diagnostic wording is correct.** Using the same
   `compiler_profile_contract.missing_rule_reference` code for both `before`
   and `after` direction violations is the right design — a PROP reference
   failure is a reference failure regardless of which edge caused it.

4. **Check count advancement is correct.** R60 22 → R63 23, with zero
   regressions. The proof chain (R58 → R60 → R63) is correctly linked through
   `extends_track`.

5. **Short digest references are correctly scoped.** 24+ hex is permitted
   proof-locally; the full 64-character requirement for durable/persisted output
   is preserved as a future constraint.

6. **Recommendation to next gate is appropriately forward-looking.** The
   recommendation ("consider library validator design") correctly names the
   next meaningful step without authorizing it.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect decision.

---

## Verdict

**Proceed.**

All seven scope checks pass. Write scope was strictly limited to the authorized
proof experiment directory plus required track doc. The new
`missing_after_rule_reference` case correctly mutates an `after` entry to
reference a nonexistent rule and machine-asserts `compiler_profile_contract.
missing_rule_reference`. This closes R60-C2-X NB-1: the ordered-rule graph's
referential-integrity invariant is now direction-agnostically machine-proved
across both `before` (R60) and `after` (R63) directions. All 23 checks pass;
zero regressions; all 13 `non_authorizations_preserved` flags are machine-
asserted false. Proof-local 24+ hex digest policy maintained; durable/persisted
full 64-char constraint preserved. Report-only integration and compile refusal
correctly held with open policy questions named.

No non-blocking notes.

---

[Route]

**Verdict: proceed.**

No blockers. No non-blocking notes.

**Recommended Architect decision (C3-A):**

1. Accept the R63 proof-local implementation. R60-C2-X NB-1 (missing `after`
   direction for `missing_rule_reference`) is now machine-closed. The
   `compiler_profile_contract` proof chain (R58 → R60 → R63) is complete for
   current scope.

2. The next meaningful step is a design and authorization review for library
   validator extraction (Option B from the R62 scope survey: new
   `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`).
   Before that card can be authorized, a separate design decision must resolve:
   - B1: exact descriptor digest input material and canonicalization;
   - B2: short-vs-full digest policy for library validation output;
   - B7: diagnostic namespace — local to the new validator file vs. shared
     `IgniterLang::Diagnostics` helper.

3. Report-only compiler integration remains held until B1, B2, B3 (behavior
   authorization), B4 (output location), and B8 (orchestrator insertion point)
   are resolved.

4. Compile refusal remains held pending a dedicated gate.

5. All other surfaces (loader/report, CompatibilityReport, CLI/API, assembler,
   `.igapp`, dispatch, Gate 3, runtime, production) remain closed.

**For R64:**
- If C3-A opens the library validator design decision, R64 can produce a design
  card for Option B scope, resolving B1/B2/B7 before any library code is written.
- No new proof-local work is needed from R63 unless a later reviewer requests
  additional adversarial cases.
- No compiler integration work opens from R63.
