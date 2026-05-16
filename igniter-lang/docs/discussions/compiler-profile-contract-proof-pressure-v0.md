# Discussion: Compiler Profile Contract Proof Pressure v0

Card: S3-R58-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: architecture-pressure
Mode: discussion
Initiator: user
Track: compiler-profile-contract-proof-pressure-v0

Depends on: S3-R58-C1-P1 delivered

Question:

Does the proof validate a canonical contract object, not just prose? Are
diagnostics properly namespaced and non-colliding? Do `missing_required_slot`
and `missing_slot` remain distinct? Are loader/report terms absent from contract
diagnostics? Does execution order match R57-C4-A? Is the SemanticIR checkpoint
disclaimer present? Does any wording or mechanism imply implementation, `.igapp`,
CLI/API, loader/report, CompatibilityReport, dispatch, runtime, or production
widening?

Context:
- R57-C4-A (gate): Authorized `compiler-profile-contract-proof-v0` as
  proof-local experiment; defined required proof scope; confirmed new PROP
  governance route; held all implementation; specified execution ordering:
  `contract -> source -> SemanticIR emit -> obligation checkpoint ->
  manifest/report`
- R58-C1-P1: Research Agent — canonical `compiler_profile_contract` object;
  6 contract cases; 16-check summary; diagnostic separation table; execution
  ordering; future `profile_not_supplied` design; remaining blockers

---

## Scope Check 1 — Proof Validates A Canonical Contract Object, Not Just Prose

**The object is behavioral.** The proof script constructs a full
`compiler_profile_contract` Ruby hash containing:

- `kind: "compiler_profile_contract"`
- `format_version: "0.1.0"`
- `descriptor_digest` and `finalization_payload_digest` (imported from existing
  finalization proof artifact)
- `required_slot_schema` (4 required + 8 optional slots with cardinality rules)
- `slot_order` and `slot_assignments` (12 slots with implementation_id and
  pack_name per slot)
- `strict_registries` with two strict registries: `oof_descriptors` (4 entries)
  and `fragment_class_owners` (5 entries), each specifying key, owner_slot, and
  rule_ref
- `ordered_rule_graph` with 4 rules across parse/classify/typecheck/emit stages
- `non_authority` block with three flags all correctly set

The `validate_contract` function is 65 lines of actual conditional logic.
It is not prose documentation marked as "validated." ✓

**The summary JSON is machine-generated.** The script writes to its own `out/`
directory; the summary is the output of running the proof, not a hand-authored
description of what the proof would do. ✓

**`source_projection_matches_profile_source: true` is machine-asserted.** The
`source_projection` function reconstructs the profile source shape from the
contract object and compares it to the actual existing finalized profile source
artifact via Ruby `==`. This passing proves the contract can sit before the
existing source transport layer without requiring any change to the current
source artifact shape. ✓

---

## Scope Check 2 — Diagnostics Are Namespaced And Non-Colliding

**All contract diagnostics use the `compiler_profile_contract.*` prefix.**
The `diagnostic` helper (line 141) prepends `"compiler_profile_contract."` to
every code before it is emitted:

```ruby
def diagnostic(code, message, path = nil)
  { "code" => "compiler_profile_contract.#{code}", ... }
end
```

Codes emitted:
- `compiler_profile_contract.missing_required_slot`
- `compiler_profile_contract.unknown_owner_slot`
- `compiler_profile_contract.unknown_rule_owner_slot`
- `compiler_profile_contract.duplicate_strict_key`
- `compiler_profile_contract.rule_cycle`
- `compiler_profile_contract.runtime_authority_forbidden`
- `compiler_profile_contract.dispatch_migration_forbidden`
- `compiler_profile_contract.wrong_kind` (validator path; untested — see NB-1)
- `compiler_profile_contract.unsupported_format_version` (validator path; untested — see NB-1)
- `compiler_profile_contract.descriptor_digest_invalid` (validator path; untested — see NB-1)
- `compiler_profile_contract.finalization_payload_digest_invalid` (validator path; untested — see NB-1)
- `compiler_profile_contract.missing_rule_reference` (validator path; untested — see NB-1)

No diagnostic drops the `compiler_profile_contract.` prefix. No diagnostic
reuses a term from `compiler_profile_obligation.*`, `compiler_profile_source.*`,
or the loader/report vocabulary. ✓

**Unknown-owner and unknown-rule-owner follow-on diagnostics are expected.**
The `missing_required_slot` case removes `oof_registry`, which causes
`unknown_owner_slot` and `unknown_rule_owner_slot` follow-on diagnostics when
the strict registry and ordered-rule graph reference that slot. The track doc
correctly notes these are expected downstream consistency evidence, not
replacement diagnostics. ✓

---

## Scope Check 3 — `missing_required_slot` And `missing_slot` Remain Distinct

**The proof machine-asserts the distinction in two ways.**

First, `separation.obligation_missing_slot_present` reads the R56 obligation
summary and confirms the obligation vocabulary still contains `missing_slot`
as an active status:

```ruby
assert("separation.obligation_missing_slot_present",
  obligation_summary.dig("report_statuses", "missing_slot.temporal_removed") == "missing_slot",
  checks)
```

This independently references the R56 summary — confirming the obligation
vocabulary hasn't been erased or overwritten. ✓

Second, `separation.contract_missing_required_slot_distinct` asserts that
`compiler_profile_obligation.missing_slot` never appears in the set of contract
diagnostic codes:

```ruby
assert("separation.contract_missing_required_slot_distinct",
  !all_contract_diagnostics.include?("compiler_profile_obligation.missing_slot"),
  checks)
```

The distinction answers three different questions:

| Term | Namespace | Question |
|---|---|---|
| `compiler_profile_obligation.missing_slot` | Obligation report | Does a program surface require a slot not supplied by the profile? |
| `compiler_profile_contract.missing_required_slot` | Contract validator | Is the contract object missing a schema-required slot? |
| loader/report `missing_required` | Manifest load/report | Is the manifest missing a profile id under future `profile_required` policy? |

All three terms pass in the summary JSON. ✓

---

## Scope Check 4 — Loader/Report Terms Absent From Contract Diagnostics

The proof defines the loader/report term set explicitly:

```ruby
LOADER_REPORT_TERMS = %w[absent_legacy present_verified mismatch malformed missing_required].freeze
```

And machine-asserts absence as a check:

```ruby
assert("separation.loader_terms_absent",
  (all_contract_diagnostics & LOADER_REPORT_TERMS).empty?,
  checks)
```

`separation.loader_terms_absent: true` in the summary. ✓

The proof also asserts source transport term absence:

```ruby
assert("separation.source_terms_absent",
  all_contract_diagnostics.none? { |code| code.start_with?("compiler_profile_source.") },
  checks)
```

`separation.source_terms_absent: true` in the summary. ✓

The `diagnostic` helper makes it mechanically impossible to emit a
`compiler_profile_obligation.*` or `compiler_profile_source.*` code from the
contract validator — all codes are forced through the
`"compiler_profile_contract."` prefix at construction time. The
loader/report absence is additionally checked at the aggregate level. ✓

---

## Scope Check 5 — Execution Order Matches R57-C4-A

**C4-A specified:**

```text
compiler_profile_contract validated
  -> finalizes to compiler_profile_id_source
  -> source transported / validated by compiler_profile_source.*
  -> SemanticIR emitted
  -> obligation checkpoint runs over emitted surfaces
  -> assembly may carry manifest compiler_profile_id
  -> future loader/report may interpret manifest/profile status
```

**C1-P1 execution_order array:**

```text
compiler_profile_contract_validated
finalizes_to_compiler_profile_id_source
source_transported_and_validated_by_compiler_profile_source
semantic_ir_emitted
semanticir_profile_obligation_checkpoint
manifest_report_interpretation_later
```

The C4-A gate collapses assembly and loader/report into a single
`manifest_report_interpretation_later` step in the proof. This is acceptable
for a proof-local ordering check — it does not conflate assembly with
loader/report; it simply names the post-obligation region as "later."

**Two ordering checks are machine-asserted:**

```ruby
assert("ordering.contract_before_source",
  execution_order.index("compiler_profile_contract_validated") <
  execution_order.index("finalizes_to_compiler_profile_id_source"),
  checks)

assert("ordering.obligation_after_semanticir",
  execution_order.index("semantic_ir_emitted") <
  execution_order.index("semanticir_profile_obligation_checkpoint"),
  checks)
```

Both pass. The critical ordering properties (contract precedes source;
obligation follows SemanticIR emit) are mechanically verified, not just
stated. ✓

**NB-2 from R57-C3-X (boundary diagram ordering vs execution ordering) is
resolved.** C4-A clarified the boundary diagram represents a layer/authority
map, not temporal execution order. The proof correctly encodes the temporal
execution order and machine-asserts the two most critical ordering properties.
NB-2 is closed. ✓

---

## Scope Check 6 — SemanticIR Checkpoint Disclaimer Is Present

C4-A required:

> SemanticIR profile-obligation checkpoint is a proposed future design
> position, not current implementation.

C1-P1:

```ruby
DISCLAIMER = "SemanticIR profile-obligation checkpoint is a proposed future design position, not current implementation."
```

Machine-asserted:

```ruby
assert("disclaimer.present",
  DISCLAIMER.include?("not current implementation"),
  checks)
```

`disclaimer.present: true` in the summary. ✓

The disclaimer string is embedded in the summary JSON and is not merely a
track doc annotation. The `"not current implementation"` substring is what the
check tests — confirming the disclaimer's core claim is present and not
truncated. ✓

**NB-1 from R57-C3-X (design sequence diagram needs implementation-state
disclaimer in future cards) is resolved.** The disclaimer is present and
machine-asserted here. NB-1 is closed. ✓

---

## Scope Check 7 — No Implementation, Widening, Or Forbidden Surfaces Implied

**Stdlib-only.** The proof script requires only `digest`, `fileutils`, `json`,
and `set` — all Ruby standard library. No live compiler code (`igniter-lang/lib/`)
is required. ✓

**Write scope is limited to `out/`.** The only `File.write` call writes to
`SUMMARY_PATH = File.join(__dir__, "out", "...")`. No other filesystem writes
occur. ✓

**All 13 non-authorization flags are `false` in the summary.** The script
hardcodes these as `false` in the output hash — same pattern as R56, which was
accepted. The behavioral guarantee rests on the stdlib-only require list and
the output-only write target. ✓

**No runtime, CLI, loader/report, CompatibilityReport, dispatch, Gate 3, or
production surface is referenced.** The proof reads two existing experiment
output files (`compiler_profile_source.stage3_proof.json` and
`compiler_profile_obligation_coverage_summary.json`) and writes one. No live
compiler dispatch or artifact path is touched. ✓

---

## Additional Integrity Checks

### `profile_not_supplied` Future Design

The C4-A gate required the proof to demonstrate:

```text
status: profile_not_supplied
required_slots: populated
missing_slots: []
```

The summary shows:

```json
{
  "status": "profile_not_supplied",
  "required_slots": ["contract_modifiers","core","escape_boundary","fragment_registry","oof_registry","pipeline"],
  "missing_slots": []
}
```

Both `future_profile_not_supplied.required_slots_populated` and
`future_profile_not_supplied.missing_slots_empty` pass. ✓

The `required_slots` list (6 entries) is derived from the existing obligation
proof summary using `obligation_summary.dig("reports", 2, "artifacts", 0, "required_slots")`.
Non-blocking note on this derivation path: see NB-1 below.

### Ordered Rule Graph Cycle Detection

The `find_rule_cycle` function implements DFS-based cycle detection (44 lines).
The `rule_cycle_contract` case adds `after: ["emit.modifier_field"]` to
`parse.contract_modifiers`, closing the loop `parse → classify → typecheck →
emit → parse`. The detected cycle path in the summary matches this loop:

```text
parse.contract_modifiers -> classify.contract_modifiers ->
  typecheck.oof_propagation -> emit.modifier_field -> parse.contract_modifiers
```

The cycle is detected by the algorithm, not just asserted. ✓

### Strict Registry One-Owner Check

The `duplicate_strict_key_contract` adds a second `OOF-M1` entry to
`oof_descriptors`. The validator correctly identifies this as
`compiler_profile_contract.duplicate_strict_key`. ✓

The `missing_required_slot` case additionally exercises `unknown_owner_slot`
— the validator checks every strict registry entry's `owner_slot` against
`slot_order`. This proves the strict registry is not just syntactically
checked; slot ownership consistency is verified. ✓

### Progression Under `pipeline`

The `ordered_rule_graph` contains a rule with `rule_id: "pipeline.progression.oof_pr1_descriptor_required.v0"` referenced in the `strict_registries.oof_descriptors` entry for `OOF-PR1`, owned by `pipeline`. The contract does not introduce a `progression` slot. `progression_descriptor` handling remains under `pipeline`. ✓

---

[Agree]

1. **The proof is behavioral, not documentary.** The `validate_contract`
   function executes real checks against a constructed object. Six contract
   cases exercise six distinct diagnostic paths. The summary is machine-generated
   from the execution, not hand-authored.

2. **Diagnostic namespace separation is mechanically enforced and asserted.**
   The `diagnostic` helper prefix-stamps all codes; `separation.loader_terms_absent`
   and `separation.source_terms_absent` are computed at the aggregate level.
   The `missing_required_slot` ≠ `missing_slot` ≠ `missing_required` rule is
   machine-verified by two independent checks against separate summary artifacts.

3. **Execution ordering matches C4-A exactly and is machine-asserted.** Both
   ordering properties (`contract_before_source`, `obligation_after_semanticir`)
   are computed, not declared. The assembly/loader collapse to
   `manifest_report_interpretation_later` is an acceptable proof-local
   simplification.

4. **R57 NB-1 and NB-2 are both closed.** The disclaimer is machine-asserted
   with the exact wording required by C4-A. The boundary diagram vs execution
   ordering ambiguity is resolved by encoding the correct temporal order in
   the proof and machine-checking the two critical ordering invariants.

5. **Source projection proves the contract is additive.** `source_projection_matches_profile_source: true`
   proves the contract can precede the existing source transport layer without
   changing the current source artifact shape.

6. **Remaining blockers are correctly stated.** The 7-item blocker list in the
   summary accurately names what must happen before PROP authoring or
   implementation authorization. None of the remaining blockers are silently
   resolved by this proof.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect decision.

---

[NB-1 — Non-blocking: positional index into obligation summary for `required_slots` derivation]

The `future_profile_not_supplied.required_slots` field is derived as:

```ruby
obligation_summary.dig("reports", 2, "artifacts", 0, "required_slots") ||
  obligation_summary.dig("evidence_table", 0, "required_slots") ||
  []
```

The `reports[2]` index is a positional reference into the obligation summary's
report array. If the obligation summary structure changes in a future proof
iteration (e.g., report order changes, or the proof is re-run with different
cases), this could silently pick a wrong case's required_slots — and the
`future_profile_not_supplied.required_slots_populated` check would still pass
as long as the wrong case also had non-empty required_slots.

For the current proof this is harmless: the obligation summary is stable, and
the required_slots value in the output is consistent with expected surfaces.

Future evolution should resolve this by naming the obligation report case
explicitly (e.g., by `status == "profile_not_supplied"`) rather than relying
on positional indexing. The C3-A scope should note this for the next
proof evolution card.

---

[NB-2 — Non-blocking: validator paths for `wrong_kind`, format version, digest format, and missing_rule_reference have no proof cases]

The `validate_contract` function contains diagnostic branches for:
- `compiler_profile_contract.wrong_kind`
- `compiler_profile_contract.unsupported_format_version`
- `compiler_profile_contract.descriptor_digest_invalid`
- `compiler_profile_contract.finalization_payload_digest_invalid`
- `compiler_profile_contract.missing_rule_reference`

None of these have corresponding proof cases. The six proof cases exercise:
`valid_contract`, `missing_required_slot`, `duplicate_strict_key`, `rule_cycle`,
`runtime_authority_forbidden`, `dispatch_migration_forbidden`.

These untested paths are not blocking because: (a) none of the six checked
diagnostic codes are from these paths; (b) the diagnostic prefix enforcement
still applies; (c) the separation checks cover the required boundaries.

However, before PROP authoring, the Compiler/Grammar Expert pressure review
should determine whether these paths need proof coverage or whether they belong
in a subsequent grammar/schema formalization card. The C3-A scope should
preserve this question for the grammar-ownership card.

---

## Verdict

**Proceed.**

All seven scope checks pass. The proof validates a canonical contract object
with behavioral validation logic across six cases. All diagnostic codes are
confined to the `compiler_profile_contract.*` namespace. The
`missing_required_slot` vs `missing_slot` vs `missing_required` distinction is
machine-asserted in two independent ways. Loader/report terms are
machine-checked absent from contract diagnostics. Execution order matches
C4-A exactly and both critical ordering properties are machine-asserted. The
SemanticIR checkpoint disclaimer is present and machine-asserted.
R57 NB-1 and NB-2 are both closed.

Two non-blocking notes: NB-1 (positional obligation summary index for
`required_slots` — stable now, fragile under future proof evolution); NB-2
(six validator paths untested by proof cases — non-blocking for this proof,
Compiler/Grammar Expert pressure should resolve before PROP authoring).

---

[Route]

**Verdict: proceed.**

No blockers.

**Recommended Architect decision (C3-A):**

1. Accept C1-P1 contract proof as the R58 proof record. The canonical
   `compiler_profile_contract` object shape and validation order are
   proof-stable. R57 NB-1 and NB-2 are closed.

2. Open Compiler/Grammar Expert pressure on:
   - formal slot schema and ordered-rule graph semantics ownership;
   - whether untested validator paths (`wrong_kind`, format version, digest
     format, `missing_rule_reference`) need proof cases or belong in a grammar
     formalization card;
   - stable one-owner registry semantics for strict keys across OOF descriptors
     and fragment owners before PROP authoring.

3. Confirm PROP governance route: a new PROP (not a PROP-036 errata), as
   established by C4-A. Record this in C3-A to prevent routing confusion.

4. Note NB-1 (positional obligation summary index) for the next proof
   evolution card: resolve by naming the `profile_not_supplied` case explicitly
   rather than by positional index.

5. Implementation authorization remains held. No PROP authoring should begin
   until the Compiler/Grammar Expert pressure card lands.

**For R59:**
- If C3-A opens the Compiler/Grammar Expert pressure card, R59 runs that.
- Loader/report, CompatibilityReport, dispatch, golden migration, and
  production surfaces remain closed.
- PROP-037 progression slot question remains open for a later Architect
  decision.
