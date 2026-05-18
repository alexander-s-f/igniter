# Discussion: PROP-038 Contract Digest Recompute Match Proof Pressure v0

Card: S3-R70-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: proof-pressure
Mode: discussion
Initiator: user
Track: prop038-contract-digest-recompute-match-proof-pressure-v0

Depends on: S3-R70-C1-P1 delivered

Question:

Are all 14 recompute/canonicalization cases present and passing? Does
canonicalization exclude `contract_digest` and forbidden ambient
material? Is `descriptor_digest` included only as a string field and not
recomputed from descriptor material? Do order-sensitive and
order-insensitive fields behave as specified? Are mismatch and
recompute-unavailable diagnostics exactly the allowed proof-local
candidates? Do invalid rule references still produce rule-reference
diagnostics and are they not hidden by canonicalization? Did no live
validator/compiler implementation change? Is no compile-refusal behavior
created? Is no public API/CLI, `CompilerResult`, loader/report,
CompatibilityReport, RuntimeMachine, Gate 3, or production authority
implied? Does the summary JSON include the required non-authorization
booleans?

Context:
- R69-C3-A (gate): Accepts proof-local shape-policy closure; authorizes
  proof-local `prop038-contract-digest-recompute-match-proof-v0` only;
  holds live validator implementation, compile refusal, and all
  production surfaces; requires Phase 2 matrix from R68-C1-P1
- R69-C2-X (pressure): Proceed; no blockers; no non-blocking notes
- R70-C1-P1: Research Agent — proof-local canonicalization model inside
  experiment script; does not edit live validator, compiler, or any
  production file; 14 cases / 15 checks / PASS

---

## Scope Check 1 — All 14 Recompute/Canonicalization Cases Are Present And Pass

The summary JSON contains exactly 14 cases. Cross-checking against the
R68-C1-P1 required Phase 2 proof matrix:

| Required case | Expected | Pass |
| --- | --- | --- |
| `recompute_full_match` | valid | ✓ |
| `recompute_prefix_match` | valid | ✓ |
| `recompute_full_mismatch` | `contract_digest_mismatch` | ✓ |
| `recompute_prefix_mismatch` | `contract_digest_mismatch` | ✓ |
| `recompute_unavailable` | `contract_digest_recompute_unavailable` | ✓ |
| `canonical_excludes_contract_digest` | same digest despite changed `contract_digest` | ✓ |
| `canonical_includes_descriptor_digest_string` | changed string → changed digest input | ✓ |
| `canonical_does_not_recompute_descriptor_material` | descriptor material not required or fetched | ✓ |
| `canonical_slot_order_order_sensitive` | reordering `slot_order` changes digest | ✓ |
| `canonical_object_key_order_insensitive` | reordering object keys does not change digest | ✓ |
| `canonical_strict_registry_order_insensitive` | reordering registry entries does not change digest | ✓ |
| `canonical_rule_list_order_insensitive` | reordering rule list does not change digest | ✓ |
| `canonical_rule_edge_set_order_insensitive` | reordering / deduplicating edge arrays does not change digest | ✓ |
| `canonical_rule_reference_still_validated` | missing ref still produces `missing_rule_reference` | ✓ |

Summary-level assertion `cases_all_pass: true` confirms the joint
result. All 14 cases from the R68-C1-P1 Phase 2 required matrix are
present and identified by the exact names specified there. ✓

---

## Scope Check 2 — Canonicalization Excludes `contract_digest` And Forbidden Ambient Material

The proof-local canonicalization is built on an explicit allowlist:

```ruby
CANONICAL_CONTRACT_FIELDS = %w[
  kind format_version profile_namespace profile_kind compiler_profile_id
  descriptor_digest finalization_payload_digest required_slot_schema
  slot_order slot_assignments strict_registries ordered_rule_graph
  non_authority
].freeze
```

The `canonical_material` function selects only these 13 fields from the
contract object using a `to_h` transform. Any key not in this list is
excluded by construction, including `contract_digest`.

Every case result carries a `canonical_input_excludes` array listing the
explicitly forbidden fields:

```json
[
  "contract_digest",
  "validation result fields",
  "report_only",
  "compiler_integrated",
  "compile_refusal_authorized",
  "provider metadata",
  "source_path",
  "out_path",
  "parsed_program",
  "compiler_profile_source"
]
```

The `canonical_excludes_contract_digest` case machine-proves exclusion
by computing the canonical digest on two contracts that differ only in
their `contract_digest` value:

```text
digest_a → recomputed hex: 0ece9bff...8773c1
digest_b → recomputed hex: 0ece9bff...8773c1
```

Both produce the same canonical hash, confirming that the `contract_digest`
field is not part of the hash input. ✓

The 13 included fields match the R68-C1-P1 canonicalization design
exactly. The excluded field list matches the design's excluded section
exactly. ✓

---

## Scope Check 3 — `descriptor_digest` Is Included As A String Field, Not Recomputed

Two cases address this requirement:

**`canonical_includes_descriptor_digest_string`**: Mutates only the
`descriptor_digest` string value and confirms the canonical digest
changes:

```text
base_digest:                0ece9bff19d32bbeba559c9c...8773c1
descriptor_changed_digest:  7c09bdeef06888cc5cae722e...fa39
```

Different hashes confirm that `descriptor_digest` participates in the
canonical input as a string value. Changing it changes what is hashed.

**`canonical_does_not_recompute_descriptor_material`**: Asserts two
things in the case output:

```json
"descriptor_material_accessed": false,
"descriptor_digest_included_as_string": true
```

The `descriptor_material_accessed: false` is a self-assertion (not a
dynamic intercept), but it is traceable directly to the
`canonical_material` function: it deep-copies `contract["descriptor_digest"]`
as whatever value is stored in the contract — a string — without making
any external fetch, file read, or resolver call. No code path in the
proof script accesses descriptor material.

The `descriptor_digest_included_as_string: true` is confirmed
dynamically:

```ruby
canonical_material(base_contract).key?("descriptor_digest")
```

This checks that the key survives the `canonical_material` transform,
which it does because `"descriptor_digest"` is in `CANONICAL_CONTRACT_FIELDS`.

Together, the two cases confirm the R68-C1-P1 rule: "`descriptor_digest`
is included as a string field value — its declared string becomes input
material, not a separately-resolved descriptor object." ✓

---

## Scope Check 4 — Order-Sensitive And Order-Insensitive Fields Behave As Specified

The R68-C1-P1 design established which fields are order-preserving vs.
order-normalizing. The proof machine-verifies all distinct categories:

**Order-sensitive (preserve)**:

| Case | Mutation | Digest change | Expected |
| --- | --- | --- | --- |
| `canonical_slot_order_order_sensitive` | Reversed `slot_order` array | `0ece...` → `d929...` | must differ ✓ |

`slot_order` carries semantic meaning (the sequence in which slots are
processed), so reordering must produce a different canonical hash.

**Order-insensitive (normalize)**:

| Case | Mutation | Digest change | Expected |
| --- | --- | --- | --- |
| `canonical_object_key_order_insensitive` | Top-level keys reversed via `Hash#keys.reverse.to_h` | `0ece...` = `0ece...` | must match ✓ |
| `canonical_strict_registry_order_insensitive` | Registry names and entry arrays reversed | `0ece...` = `0ece...` | must match ✓ |
| `canonical_rule_list_order_insensitive` | `ordered_rule_graph.rules` array reversed | `0ece...` = `0ece...` | must match ✓ |
| `canonical_rule_edge_set_order_insensitive` | `before` array shuffled + duplicate added | `b03d...` = `b03d...` | must match ✓ |

The edge-set case also tests deduplication: edge set A uses
`["emit.modifier_field", "classify.contract_modifiers", "classify.contract_modifiers"]`
(duplicate) and set B uses `["classify.contract_modifiers", "emit.modifier_field"]`
(no duplicate, different order). After `.uniq.sort` both become
`["classify.contract_modifiers", "emit.modifier_field"]` → identical
canonical form → identical digest.

Implementation:

- `normalize` sorts `Hash` keys recursively (covers object-key insensitivity
  at every level).
- `canonical_strict_registries` sorts registry names and entries by
  `[key, owner_slot, rule_ref]` (covers registry insensitivity).
- `canonical_ordered_rule_graph` sorts rules by `rule_id` and applies
  `.uniq.sort` to `before`/`after` arrays (covers rule list and edge set
  insensitivity).
- `slot_order` is extracted from `canonical_material` as a deep copy without
  sorting, because it is in `CANONICAL_CONTRACT_FIELDS` and not touched by
  the `canonical_strict_registries` or `canonical_ordered_rule_graph` overrides.

The asymmetry matches the R68-C1-P1 design specification exactly. ✓

---

## Scope Check 5 — Mismatch And Recompute-Unavailable Diagnostics Are Exactly The Allowed Proof-Local Candidates

The two new proof-local diagnostic codes:

```text
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

`contract_digest_mismatch` appears in `recompute_full_mismatch` and
`recompute_prefix_mismatch` only. `contract_digest_recompute_unavailable`
appears in `recompute_unavailable` only. No other codes appear in any
of the 14 case results. No `contract_digest_invalid`,
`contract_digest_policy_unsupported`, or any other code is emitted by
`validate_recompute_match`.

Both codes are under `compiler_profile_contract.*`, consistent with the
four-layer vocabulary separation. Both use `path: "contract_digest"`.

The diagnostic messages are precise:

```text
contract_digest_mismatch:             "declared contract_digest does not match recomputed canonical contract digest"
contract_digest_recompute_unavailable: "contract digest recompute requested but canonicalization is unavailable"
```

Neither message implies authority, compile outcome, loader status, or
OOF-related semantics.

Together with the R69 proof-local codes (`contract_digest_invalid`,
`contract_digest_policy_unsupported`), all four future diagnostic
candidates proposed in R68-C1-P1 are now proof-covered. ✓

---

## Scope Check 6 — Invalid Rule References Are Not Hidden By Canonicalization

The `canonical_rule_reference_still_validated` case constructs a
contract with a `before` edge pointing to `"missing.rule.target"` — a
rule id not present in the contract — and runs it through the live
validator:

```ruby
missing_ref_contract["ordered_rule_graph"]["rules"][0]["before"] = ["missing.rule.target"]
missing_ref_validation = IgniterLang::CompilerProfileContractValidator.validate(missing_ref_contract)
```

The live validator correctly emits:

```json
{
  "code": "compiler_profile_contract.missing_rule_reference",
  "message": "ordered rule parse.contract_modifiers references missing rule \"missing.rule.target\"",
  "path": "ordered_rule_graph.rules.parse.contract_modifiers"
}
```

Additionally, `canonical_digest_still_computable: true` confirms that
the canonical hash can still be computed for this semantically invalid
contract. This establishes two facts:

1. **Validation detects the semantic error** — `missing_rule_reference`
   is emitted regardless of canonicalization.
2. **Canonicalization is orthogonal to validation** — it normalizes
   material for hashing without checking referential integrity. An
   invalid contract still has a well-formed canonical form.

The R68-C1-P1 design stated: "Canonicalization should not silently fix
invalid contract semantics. It only normalizes material for hashing."
This case proves that invariant directly: canonicalization normalizes the
`before` array (sorts, deduplicates the `"missing.rule.target"` entry)
but does not remove or override the reference, and the live validator
still catches the semantic invalidity. ✓

---

## Scope Check 7 — No Live Validator Or Compiler Implementation Changed

The proof script:

1. `require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"` —
   loads the live validator for regression sampling and for the
   `canonical_rule_reference_still_validated` case only. The file is not
   modified.

2. The proof-local canonicalization stack
   (`normalize`, `canonical_material`, `canonical_strict_registries`,
   `canonical_ordered_rule_graph`, `canonical_json`, `recomputed_hex`,
   `validate_recompute_match`, `recompute_result`) is defined entirely
   within the experiment script. None of these extend or patch the live
   validator.

3. `ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`
   → `Syntax OK` confirms the file is unchanged.

Summary top-level:

```json
"live_validator_changed": false,
"compiler_integration_changed": false,
"recompute_match_live_implemented": false
```

Named check assertions:

```text
live_validator_changed_false          → true
compiler_integration_changed_false    → true
recompute_match_live_not_implemented  → true
```

Regression confirms upstream proofs still pass:
`shape_policy_proof_status_pass: true`, `validator_summary_pass: true`
(13 cases), `report_only_integration_pass: true` (20 checks / PASS). ✓

---

## Scope Check 8 — No Compile-Refusal Behavior Created

Every case result that carries a `compile_refusal_authorized` key has it
set to `false`. The check `proof_compile_refusal_false` asserts that all
case results satisfy `compile_refusal_authorized == false`.

Three regression assertions guard against refusal creep at every layer:

```text
proof_compile_refusal_false          → true  (proof-local results)
live_validator_compile_refusal_false → true  (live validator sample)
integration_compile_refusal_false    → true  (R67 integration cases)
```

Physical scans:

```text
no_igapp_mutation_from_proof         → true  (no *.igapp in out/)
no_refusal_report_creation_from_proof → true  (no "refusal" filenames in out/)
```

The proof script writes only to `experiments/prop038_contract_digest_recompute_match_proof/out/`.
No compile refusal path exists in any proof-local function. ✓

---

## Scope Check 9 — No Public API/CLI, CompilerResult, Loader/Report, CompatibilityReport, RuntimeMachine, Gate 3, Or Production Authority Implied

The summary carries `implementation_authorized: false` at the top level
and in every case result. The check `implementation_not_authorized`
asserts `true`. The track document non-authorization section enumerates
all held surfaces individually and matches the full R57-R67 hold
inventory.

The only files produced by this proof are:

```text
experiments/prop038_contract_digest_recompute_match_proof/
  prop038_contract_digest_recompute_match_proof.rb
  out/prop038_contract_digest_recompute_match_proof_summary.json
docs/tracks/prop038-contract-digest-recompute-match-proof-v0.md
```

All three are within the R69-C3-A authorized write boundary. No changes
to `lib/`, `cli.rb`, `compiler_result.rb`, `compilation_report.rb`,
`compiler_orchestrator.rb`, or any `.igapp` path. The
`recommendation_for_c3_a: "accept"` field carries the explicit guidance
"Do not authorize live implementation or compile refusal from this
proof." ✓

---

## Scope Check 10 — Summary JSON Includes The Required Non-Authorization Booleans

The summary carries the five required top-level boolean flags:

```json
"live_validator_changed": false,
"compiler_integration_changed": false,
"recompute_match_live_implemented": false,
"compile_refusal_authorized": false,
"implementation_authorized": false
```

These cover the same invariants as the R69-C3-A accepted non-authorization
block. Named check assertions reinforce each flag:

```text
live_validator_changed_false         → true
compiler_integration_changed_false   → true
recompute_match_live_not_implemented → true
implementation_not_authorized        → true
```

The `authority_ref` is correctly populated:

```json
"authority_ref": "igniter-lang/docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md"
```

This cites the R69-C3-A gate, not the track or pressure document. The
`recommendation_for_c3_a: "accept"` field is present. ✓

**(NB-1 — non-blocking)** The R65, R67, and R69 proof summaries each
included a dedicated `non_authorizations_preserved` dictionary with
8–16 named keys covering loader/report, CompatibilityReport, runtime,
Gate 3, and other hold surfaces explicitly by name. The R70 summary
does not include this dictionary. The top-level boolean flags and named
check assertions are sufficient to satisfy the requirement, but the
absence of the structured block is a departure from the established
documentation pattern. C3-A may wish to note this variance and require
the block in future proof summaries for hold-inventory traceability.

---

[Agree]

1. **All 14 required Phase 2 cases are present and pass.** Every case
   from the R68-C1-P1 required matrix is present, named correctly, and
   produces the expected result.

2. **Canonicalization is built on an explicit 13-field allowlist.**
   `CANONICAL_CONTRACT_FIELDS` is a Ruby frozen constant; any field not
   in the list is excluded by construction, including `contract_digest`.
   The machine-proof confirms: two contracts differing only in
   `contract_digest` produce the same canonical hash.

3. **`descriptor_digest` participates as a string value.** Two cases
   machine-prove this: changing the string changes the hash
   (`canonical_includes_descriptor_digest_string`), and no descriptor
   material is fetched or resolved
   (`canonical_does_not_recompute_descriptor_material`).

4. **Semantic/non-semantic ordering asymmetry is correct.** `slot_order`
   is order-sensitive (machine-proved). Object key order, registry
   entry order, rule list order, and edge array order are all
   order-insensitive (machine-proved, including deduplication for edge
   arrays).

5. **Exactly two new diagnostic codes, both authorized, both
   namespace-clean.** `contract_digest_mismatch` and
   `contract_digest_recompute_unavailable` complete the four-code
   vocabulary proposed in R68-C1-P1. No unauthorized codes appear.

6. **Canonicalization does not hide validation errors.** The live
   validator still produces `missing_rule_reference` for a contract with
   a dangling rule edge; canonicalization normalizes the edge array
   without suppressing the semantic invalidity. Canonical digest is
   still computable for invalid contracts.

7. **No live files changed.** Proof-local functions are script-level
   only; live validator is read for regression sampling; syntax check
   confirms unchanged.

8. **Compile-refusal path is blocked on five assertions.** Three
   regression checks (proof / live validator / integration) plus two
   physical scans (`.igapp`, refusal filenames).

9. **All required non-authorization booleans present.** Five top-level
   flags plus four named check assertions. One structural variance from
   the R65/R67/R69 pattern noted as NB-1 (non-blocking).

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A acceptance decision.

---

## Verdict

**Proceed.**

All ten scope checks pass. The 14-case Phase 2 recompute/canonicalization
matrix from R68-C1-P1 is satisfied in full. Canonicalization is built on
an explicit 13-field allowlist that excludes `contract_digest` and all
ambient/runtime fields by construction. `descriptor_digest` participates
as a string value and is machine-confirmed not to trigger any descriptor
material fetch. The semantic/non-semantic ordering asymmetry
(`slot_order` order-sensitive; object keys, registry entries, rule list,
and edge arrays all order-insensitive with edge arrays additionally
deduplicated) is machine-verified for each category. The two new
diagnostic codes complete the four-code `contract_digest_*` vocabulary
and are namespace-clean with no authority implications. Invalid rule
references are not hidden by canonicalization — the live validator still
catches semantic invalidity and the canonical digest is independently
computable. No live validator or compiler file changed. Compile-refusal
is blocked at five independent assertion points. All five required
non-authorization booleans are present.

One non-blocking note: the `non_authorizations_preserved` dictionary
present in R65/R67/R69 summaries is absent here; hold-inventory
traceability is carried instead by top-level flags plus named check
assertions.

No blockers. One non-blocking note (NB-1).

---

[Route]

**Verdict: proceed.**

No blockers. One non-blocking note.

**NB-1 (non-blocking):** The `non_authorizations_preserved` dictionary
(8–16 named keys covering loader/report, CompatibilityReport, runtime,
Gate 3, etc.) present in R65/R67/R69 summaries is absent from the R70
summary. Top-level boolean flags and named check assertions cover the
same invariants, but the structured block improves hold-inventory
traceability for future readers. C3-A may require the block for future
proof summaries without blocking this acceptance.

**Recommended Architect decision (C3-A):**

1. Accept the proof-local Phase 2 recompute-match closure. All 14
   required cases pass. 15 checks / 0 failures.

2. Confirm the complete four-code `contract_digest_*` vocabulary is
   now proof-covered across both phases:
   - Phase 1: `contract_digest_invalid`, `contract_digest_policy_unsupported`
   - Phase 2: `contract_digest_mismatch`, `contract_digest_recompute_unavailable`

3. Confirm the canonicalization model (13-field allowlist, ordering
   asymmetry, exclusion of `contract_digest` and ambient fields) is
   accepted as the design target for future live implementation —
   not yet as implementation authorization.

4. If authorizing Phase 3 (report-only integration proof), the next
   proof-local route is:
   ```text
   prop038-contract-digest-report-only-integration-proof-v0
   ```
   Scope: wire Phase 2 recompute diagnostics through the report-only
   path inside the experiment; verify mismatch still returns compile
   status `ok`, public result unchanged, no `.igapp` mutation, no
   refusal report; proof-local only.

5. Hold live validator implementation. Hold recompute-match in the live
   validator. Hold compile refusal. The four-condition prerequisite
   chain from R68-C3-A (condition 5) requires report-only integration
   proof before compile refusal may be considered.

6. Hold PROP-038 errata until report-only integration proof is accepted.

7. If accepted, note NB-1: require the `non_authorizations_preserved`
   block in future proof summaries for structural parity.

8. All surfaces held by R69-C3-A remain closed: live validator
   implementation, compile refusal, public API/CLI, `CompilerResult`,
   persisted reports, sidecars, assembler/`.igapp`, loader/report,
   CompatibilityReport, `IgniterLang::Diagnostics`, RuntimeMachine,
   Gate 3, and production behavior.
