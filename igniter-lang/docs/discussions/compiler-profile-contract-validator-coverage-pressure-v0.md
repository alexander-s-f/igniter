# Discussion: Compiler Profile Contract Validator Coverage Pressure v0

Card: S3-R60-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: architecture-pressure
Mode: discussion
Initiator: user
Track: compiler-profile-contract-validator-coverage-pressure-v0

Depends on: S3-R60-C1-P1 delivered

Question:

Are all five required validator paths proof-covered? Is `missing_rule_reference`
evidence precise enough for ordered-rule graph semantics? Did the proof preserve
the R58 accepted object shape and diagnostics? Did namespace separation remain
intact? Did optional positional `required_slots` cleanup land or remain tracked?
Did optional `fragment_class_owners` duplicate coverage land or remain explicitly
optional? Is ordered-rule `stage` still routed to later PROP scope, not silently
decided? Did any wording imply PROP authoring, implementation, dispatch, runtime,
or production authority?

Context:
- R59-C3-A (gate): Accepted R59 grammar ownership record; held PROP authoring;
  authorized `compiler-profile-contract-validator-coverage-proof-v0`; listed 7
  PROP-authoring blockers including all five validator coverage gaps
- R60-C1-P1: Research Agent — extended existing proof experiment; 12 case matrix
  all PASS; 22 checks all PASS; positional lookup replaced; optional
  fragment_class_owners case included

---

## Scope Check 1 — All Five Required Validator Paths Are Proof-Covered

The R59 PROP-authoring blockers listed five validator branches without proof
cases. Checking each against the summary JSON directly:

| Required path | Expected diagnostic | JSON case result | Pass |
|---|---|---|---|
| `missing_rule_reference` | `compiler_profile_contract.missing_rule_reference` | `actual: ["compiler_profile_contract.missing_rule_reference"]` | ✓ |
| `wrong_kind` | `compiler_profile_contract.wrong_kind` | `actual: ["compiler_profile_contract.wrong_kind"]` | ✓ |
| `unsupported_format_version` | `compiler_profile_contract.unsupported_format_version` | `actual: ["compiler_profile_contract.unsupported_format_version"]` | ✓ |
| `descriptor_digest_invalid` | `compiler_profile_contract.descriptor_digest_invalid` | `actual: ["compiler_profile_contract.descriptor_digest_invalid"]` | ✓ |
| `finalization_payload_digest_invalid` | `compiler_profile_contract.finalization_payload_digest_invalid` | `actual: ["compiler_profile_contract.finalization_payload_digest_invalid"]` | ✓ |

The corresponding named checks in `checks` array:

| Check name | pass |
|---|---|
| `missing_rule_reference.diagnostic` | true |
| `wrong_kind.diagnostic` | true |
| `unsupported_format_version.diagnostic` | true |
| `descriptor_digest_invalid.diagnostic` | true |
| `finalization_payload_digest_invalid.diagnostic` | true |

All five required paths are machine-asserted, not only described in prose. ✓

**Check count progression:** R58 had 16 machine-asserted checks. R60 adds 6 new
checks (the five required paths plus `duplicate_fragment_class_owner.diagnostic`
for the optional registry-general case). R60 total: 22 checks, all PASS. ✓

---

## Scope Check 2 — `missing_rule_reference` Evidence Is Precise Enough

The JSON case record for `missing_rule_reference`:

```json
{
  "code": "compiler_profile_contract.missing_rule_reference",
  "message": "ordered rule emit.modifier_field references missing rule \"emit.nonexistent_rule\"",
  "path": "ordered_rule_graph.rules.emit.modifier_field"
}
```

This establishes three facts:
1. **Referential scope:** the check targets `ordered_rule_graph.rules[*].before` /
   `ordered_rule_graph.rules[*].after` entries;
2. **Resolution requirement:** every reference must resolve to a declared
   `rule_id` in the same graph;
3. **Diagnostic granularity:** the diagnostic names the offending rule and the
   unresolvable target, giving implementation-quality diagnostic information.

The PROP can derive the formal invariant from this evidence:

```text
Every target named in a rule's before[] or after[] must be a rule_id
declared in ordered_rule_graph.rules.
```

This is sufficient for PROP authoring of the ordered-rule graph semantics. ✓

**One-direction observation (see NB-1).** The case tests a missing reference in
a `before` entry (`emit.modifier_field` references `emit.nonexistent_rule` in its
`before` list). The validator's referential check is direction-agnostic by
code structure (both `before` and `after` refs are resolved in the same pass).
The diagnostic message confirms this by not specifying "before" or "after" —
it says "references missing rule." Non-blocking for PROP authoring but worth
covering both directions in a future proof evolution or implementation test.

---

## Scope Check 3 — R58 Accepted Object Shape And Diagnostics Preserved

Checking all accepted R58 checks against the R60 summary:

| R58 check | R60 result |
|---|---|
| `valid_contract.accepted` | PASS ✓ |
| `source_projection.matches_profile_source` | PASS ✓ |
| `missing_required_slot.diagnostic` | PASS ✓ |
| `duplicate_strict_key.diagnostic` | PASS ✓ |
| `rule_cycle.diagnostic` | PASS ✓ |
| `runtime_authority.diagnostic` | PASS ✓ |
| `dispatch_migration.diagnostic` | PASS ✓ |
| `separation.obligation_missing_slot_present` | PASS ✓ |
| `separation.contract_missing_required_slot_distinct` | PASS ✓ |
| `separation.loader_terms_absent` | PASS ✓ |
| `separation.source_terms_absent` | PASS ✓ |
| `future_profile_not_supplied.required_slots_populated` | PASS ✓ |
| `future_profile_not_supplied.missing_slots_empty` | PASS ✓ |
| `ordering.contract_before_source` | PASS ✓ |
| `ordering.obligation_after_semanticir` | PASS ✓ |
| `disclaimer.present` | PASS ✓ |

All 16 R58 checks still pass. ✓

The canonical object structure is also unchanged: same `slot_order` (12 slots),
same `slot_assignments`, same `strict_registries`, same `ordered_rule_graph`
(4 rules: parse/classify/typecheck/emit contract_modifiers), same `non_authority`
flags. No regression in the accepted proof shape. ✓

The SemanticIR disclaimer is present in the JSON:

```text
"SemanticIR profile-obligation checkpoint is a proposed future design position,
not current implementation."
```

The R57 NB-1 disclaimer requirement is satisfied. ✓

Execution order is preserved and machine-checked:

```text
compiler_profile_contract_validated
  -> finalizes_to_compiler_profile_id_source
  -> source_transported_and_validated_by_compiler_profile_source
  -> semantic_ir_emitted
  -> semanticir_profile_obligation_checkpoint
  -> manifest_report_interpretation_later
```

The R57 NB-2 (boundary diagram vs. execution ordering) resolution remains
intact. ✓

---

## Scope Check 4 — Diagnostic Namespace Separation Intact

All new diagnostic codes introduced by R60 are correctly namespaced:

| New diagnostic | Namespace | Correct? |
|---|---|---|
| `compiler_profile_contract.missing_rule_reference` | `compiler_profile_contract.*` | ✓ |
| `compiler_profile_contract.wrong_kind` | `compiler_profile_contract.*` | ✓ |
| `compiler_profile_contract.unsupported_format_version` | `compiler_profile_contract.*` | ✓ |
| `compiler_profile_contract.descriptor_digest_invalid` | `compiler_profile_contract.*` | ✓ |
| `compiler_profile_contract.finalization_payload_digest_invalid` | `compiler_profile_contract.*` | ✓ |

Machine-asserted separation in the summary JSON:

```json
"diagnostic_separation": {
  "contract_missing_required_slot": "compiler_profile_contract.missing_required_slot",
  "obligation_missing_slot_status": "compiler_profile_obligation.missing_slot",
  "distinct": true,
  "loader_report_terms_absent_as_contract_diagnostics": true,
  "compiler_profile_source_terms_absent_as_contract_diagnostics": true
}
```

The three-way separation rule remains intact:

```text
missing_required_slot != missing_slot != missing_required
```

No new diagnostic code uses loader/report vocabulary or obligation vocabulary.
No new diagnostic crosses namespace boundaries. ✓

---

## Scope Check 5 — Optional Positional `required_slots` Cleanup Landed

R58 NB-1 was a positional lookup: `obligation_summary.dig("reports", 2,
"artifacts", 0, "required_slots")`. R60 replaces this with named case/status
selection.

The JSON `future_profile_not_supplied_design` section confirms:

```json
"future_profile_not_supplied_design": {
  "case": "future_profile_not_supplied_design",
  "status": "profile_not_supplied",
  "required_slots": ["contract_modifiers", "core", "escape_boundary",
    "fragment_registry", "oof_registry", "pipeline"],
  "missing_slots": []
}
```

The `"case": "future_profile_not_supplied_design"` field confirms the lookup
is now case-name based. The positional debt from R58 is closed. ✓

Shape is preserved: `required_slots` populated, `missing_slots` empty — the
design decision from R57 C4-A and R58 NB-2 resolution remains intact. ✓

The `future_profile_not_supplied.required_slots_populated` and
`future_profile_not_supplied.missing_slots_empty` checks both pass. ✓

---

## Scope Check 6 — Optional `fragment_class_owners` Coverage Landed

The R59 NB-2 recommended adding a `fragment_class_owners` duplicate key case as
optional evidence for registry-general one-owner semantics. R60 includes it.

From the validator case matrix:

```json
{
  "case": "duplicate_fragment_class_owner",
  "expected": "compiler_profile_contract.duplicate_strict_key",
  "actual": ["compiler_profile_contract.duplicate_strict_key"],
  "pass": true
}
```

Diagnostic detail confirms the correct registry:

```json
{
  "code": "compiler_profile_contract.duplicate_strict_key",
  "message": "strict registry fragment_class_owners has duplicate key \"temporal\"",
  "path": "strict_registries.fragment_class_owners.temporal"
}
```

The R59 NB-2 concern is now fully closed. The PROP can claim registry-general
one-owner semantics with proof coverage across both `oof_descriptors` (R58) and
`fragment_class_owners` (R60). ✓

Both `duplicate_strict_key.diagnostic` and `duplicate_fragment_class_owner.diagnostic`
checks pass. ✓

---

## Scope Check 7 — Ordered-Rule `stage` Correctly Deferred To PROP Scope

The proof does not add any validator branch that checks `stage` values against a
permitted set. The canonical object and all new cases continue to use `parse`,
`classify`, `typecheck`, `emit` as stage names, but these remain unvalidated
in the proof.

The track handoff raises this explicitly as an open question:

> "Should stage values be validated now, or documented as informational until a
> later proof?"

The `remaining_blockers_before_prop_authoring` in the JSON includes:

```text
PROP text must decide whether ordered_rule_graph.stage is normative validated
vocabulary or informational metadata.
```

This is the correct routing. The R59 NB-1 concern is preserved as a PROP-scope
question, not silently decided in the proof. ✓

A future PROP that defines the ordered-rule graph vocabulary must resolve this
before text freezes — but that decision belongs to Compiler/Grammar Expert in
the PROP authoring phase, not to the proof coverage phase.

---

## Scope Check 8 — No PROP Authoring, Implementation, Or Widening Implied

**Explicit gate preserved.** The track scope opens with: "This track does not
author PROP text and does not authorize implementation." ✓

The `remaining_blockers_before_prop_authoring` list in the JSON starts with:

```text
Architect decision to lift the R59 hold and explicitly authorize PROP authoring
```

This is the correct ordering: proof coverage does not self-authorize PROP
authoring. The gate chain is enforced. ✓

**Non-authorizations machine-asserted.** The `non_authorizations_preserved`
block in the JSON shows all 13 surfaces at `false` (none touched):

```json
"non_authorizations_preserved": {
  "live_compiler_dispatch": false,
  "igapp_artifacts": false,
  "goldens": false,
  "cli_api": false,
  "loader_report": false,
  "compatibility_report": false,
  "runtime_machine": false,
  "gate3": false,
  "ledger_tbackend": false,
  "bihistory": false,
  "stream_olap_production": false,
  "cache": false,
  "production_behavior": false
}
```

All 13 non-authorization flags are `false`. ✓

The handoff `[X] Rejected` section names everything excluded: "No PROP
authoring, implementation, CLI/API behavior, loader/report behavior,
CompatibilityReport behavior, RuntimeMachine behavior, dispatch migration, or
production behavior was added." ✓

---

## Additional Integrity Check: Remaining Blockers List Is Sound

The `remaining_blockers_before_prop_authoring` in the summary JSON lists five
items. Checking each:

1. **Architect decision to lift the R59 hold** — correct; proof coverage does
   not self-authorize. ✓

2. **Stage normative vs. informational** — correct carry-forward from R59 NB-1
   and C3-A explicit answer. ✓

3. **Stable descriptor/finalization digest semantics** — this is a new item
   surfaced by the proof coverage work. The `descriptor_digest_invalid` and
   `finalization_payload_digest_invalid` cases prove the validator uses regex
   patterns (`compiler_profile_descriptor/sha256:<hex>` and
   `sha256:<64 hex>`). The PROP must express these as normative format
   specifications, not proof-local regex strings. This is a legitimate PROP gap
   correctly identified by the proof work. ✓

4. **Slot assignment = declared ownership, not execution/dispatch** — correct
   carry-forward from R59 ownership decision. ✓

5. **Progression metadata under `pipeline` for v0** — correct preservation of
   PROP-037 gate from R57 C4-A. ✓

All five remaining blockers are legitimate, precisely stated, and scoped to
PROP-authoring obligations rather than proof coverage. The list does not
contain implementation requirements disguised as PROP requirements. ✓

---

[Agree]

1. **All five required validator paths are now machine-asserted.** The R59
   validator coverage blockers are closed. Proof coverage is sufficient for
   PROP authoring to proceed after a separate Architect authorization.

2. **`missing_rule_reference` evidence supports ordered-rule graph semantics.**
   The case proves the "references must resolve to declared rule_id" invariant
   with a named rule and named missing target. The PROP can derive the formal
   referential-integrity rule from this case.

3. **R58 shape and all 16 R58 checks are intact.** Zero regressions. The proof
   extension adds coverage without disturbing accepted behavior.

4. **Namespace separation is machine-asserted for all new diagnostics.** Five
   new codes, all correctly under `compiler_profile_contract.*`. The three-way
   separation triple remains intact.

5. **Both optional items landed.** Positional lookup is replaced with named
   case selection (closes R58 NB-1). `fragment_class_owners` duplicate case is
   included (closes R59 NB-2). The PROP can claim registry-general one-owner
   semantics with proof coverage across both registries.

6. **Stage question correctly deferred.** No silent decision in the proof;
   explicitly listed as a PROP-authoring question.

7. **Remaining blockers list is well-formed.** Item 3 (digest format
   specification) is a new accurate gap surfaced by the proof coverage work.
   The governance gate (Architect authorization required) is correctly first.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect decision.

---

[NB-1 — Non-blocking: `missing_rule_reference` tests missing `before` target only; `after` direction not separately covered]

The `missing_rule_reference` case tests an entry in a rule's `before` list
(`emit.modifier_field` references `emit.nonexistent_rule` in its `before`
targets). The message says "references missing rule" without specifying direction,
and the validator code is direction-agnostic by structure (one pass for all
`before + after` refs).

A future proof evolution or implementation test should add an explicit case where
the missing target is an `after` entry rather than a `before` entry. This would
close the direction-agnostic claim by proof rather than by code inspection.

Non-blocking: the PROP can define the referential-integrity invariant
direction-agnostically. The existing case plus validator structure is sufficient
for PROP authoring. Recommend adding the missing-`after` case in a follow-up
proof or the implementation verification suite.

---

[NB-2 — Non-blocking: digest format PROP gap is correctly surfaced; PROP should express it as a specification, not a regex]

The proof's `descriptor_digest_invalid` and `finalization_payload_digest_invalid`
cases prove the validator rejects malformed digests using regex patterns:

```text
descriptor_digest:           compiler_profile_descriptor/sha256:<hex>
finalization_payload_digest: sha256:<64 hex>
```

These patterns are currently defined only in the proof-local validator code.
The R60 track correctly adds "PROP text must define stable digest semantics
beyond proof-local projection" to the remaining-blockers list.

The PROP should express this as:
- a normative format: `"compiler_profile_descriptor/sha256:" + <lowercase-hex-64>` for descriptor digest;
- a normative format: `"sha256:" + <lowercase-hex-64>` for finalization payload digest;
- a statement of what the hex digest value represents (e.g., SHA-256 of the
  descriptor document content; SHA-256 of the finalization payload).

Non-blocking for validator coverage review. The gap is correctly identified;
resolution belongs to PROP authoring.

---

## Verdict

**Proceed.**

All eight scope checks pass. All five R59-required validator paths are machine-
asserted with correct diagnostics. `missing_rule_reference` establishes the
referential-integrity invariant for ordered-rule graph semantics precisely enough
for PROP authoring. All 22 checks pass; zero R58 regressions; namespace
separation machine-asserted intact. Both optional items (positional lookup
cleanup, `fragment_class_owners` coverage) landed, closing R58 NB-1 and R59
NB-2. Ordered-rule `stage` question correctly deferred to PROP scope.
Remaining blockers list is accurate and well-formed. No implementation,
PROP authoring, or forbidden surface widening is implied.

Two non-blocking notes: NB-1 (`missing_rule_reference` tested in `before`
direction only; `after` direction should be covered in a future proof or
implementation test); NB-2 (digest format must be expressed normatively in PROP,
not as proof-local regex — already correctly flagged in remaining blockers).

---

[Route]

**Verdict: proceed.**

No blockers.

**Recommended Architect decision (C3-A):**

1. Accept R60 validator coverage proof. All five R59 PROP-authoring blockers
   are closed. R58 NB-1 (positional lookup) and R59 NB-2 (fragment_class_owners
   coverage) are also closed. The validator is complete for current design
   intent.

2. Lift the R59 PROP-authoring hold. Authorize a new PROP for
   `compiler_profile_contract`. This PROP must be a new proposal, not a
   PROP-036 errata.

3. PROP authoring scope must include:
   - normative contract object schema: `kind`, `format_version`, `descriptor_digest`,
     `finalization_payload_digest`, `required_slot_schema`, `slot_order`,
     `slot_assignments`, `strict_registries`, `ordered_rule_graph`,
     `non_authority`, `contract_digest`;
   - formal `descriptor_digest` and `finalization_payload_digest` format
     specifications (NB-2 — not proof-local regex);
   - resolution of `ordered_rule_graph.stage` as normative validated vocabulary
     or informational metadata (NB-1 from R59);
   - explicit statement: slot assignment = declared compiler-understanding
     ownership, not handler execution or dispatch authority;
   - referential-integrity rule for `ordered_rule_graph`: every `before`/`after`
     target must resolve to a declared `rule_id`;
   - one-owner registry invariant as registry-general (not `oof_descriptors`-specific);
   - progression descriptor under `pipeline` for v0 unless separate decision
     opens a `progression` slot;
   - explicit non-authority section: no runtime authority, no dispatch migration,
     no production, no loader/report, no CompatibilityReport.

4. Implementation authorization remains held until after PROP acceptance and a
   separate implementation authorization decision with named write scope.

5. All other surfaces (loader/report, CompatibilityReport, dispatch, Gate 3,
   runtime, production) remain closed.

**For R61:**
- If C3-A lifts the hold, R61 can begin PROP authoring under Compiler/Grammar
  Expert ownership.
- NB-1 (missing `after`-direction `missing_rule_reference` case) is an optional
  addition for the implementation verification suite, not a PROP-authoring
  prerequisite.
- No implementation, loader/report, or runtime work opens from R60.
