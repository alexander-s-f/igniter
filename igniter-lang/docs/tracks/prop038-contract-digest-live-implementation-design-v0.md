# Track: PROP-038 Contract Digest Live Implementation Design v0

Card: S3-R73-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop038-contract-digest-live-implementation-design-v0`
Route: UPDATE
Status: done
Date: 2026-05-18

Authority ref:

- `docs/gates/prop038-contract-digest-errata-acceptance-decision-v0.md`

Affected neighbor roles: `[Igniter-Lang Implementation Agent]`,
`[Igniter-Lang Research Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Design the exact bounded live validator implementation slice for PROP-038
`contract_digest` validation without implementing code and without authorizing
implementation.

This track is design-only. It does not edit code, change compiler integration,
authorize compile refusal, widen public API/CLI behavior, mutate `.igapp`
artifacts, or centralize diagnostics.

---

## Inputs Read

- `docs/gates/prop038-contract-digest-errata-acceptance-decision-v0.md`
- `docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md`
- `docs/gates/prop038-contract-digest-recompute-match-proof-decision-v0.md`
- `docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/gates/prop038-library-validator-extraction-acceptance-decision-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/tracks/stage3-round72-status-curation-v0.md`
- `lib/igniter_lang/compiler_profile_contract_validator.rb`

---

## Current Accepted State

The live internal validator boundary is:

```ruby
IgniterLang::CompilerProfileContractValidator.validate(
  contract,
  digest_reference_policy: :prop038_24_plus
)
```

The accepted live result shape is:

```json
{
  "kind": "compiler_profile_contract_validation_result",
  "format_version": "0.1.0",
  "valid": true,
  "diagnostics": [],
  "diagnostic_codes": [],
  "digest_reference_policy": "prop038_24_plus",
  "compiler_integrated": false,
  "compile_refusal_authorized": false
}
```

Current live validator behavior validates:

```text
descriptor_digest
finalization_payload_digest
required slots
strict registry duplicate keys
ordered rule references and cycles
non_authority runtime/dispatch flags
```

Current live validator behavior does not validate:

```text
contract_digest shape
contract_digest recompute/match
contract_digest policy unsupported
contract_digest recompute unavailable
```

R72 accepts the PROP-038 errata/design text and keeps live implementation held.
This card may design the next implementation boundary only.

---

## Recommendation

Recommended implementation shape:

```text
one bounded internal validator slice
```

Rationale:

- R69 proves `contract_digest` shape policy: 8 cases PASS.
- R70 proves recompute/canonicalization policy: 14 cases PASS.
- R71 proves report-only integration placement: 12 cases PASS.
- R72 accepts the errata/design text into PROP-038.
- Splitting shape-only first would create a temporary live half-policy after the
  full shape + recompute design has already been proofed and accepted.

Fallback:

```text
split shape-only first, recompute-match later
```

Use the fallback only if Architect wants an intentionally smaller implementation
card despite the accepted proof chain. The fallback must still preserve all
report-only/no-refusal invariants.

Not recommended:

```text
hold
```

There are no design blockers to drafting a bounded implementation card. The
implementation itself remains unauthorized until a later gate explicitly opens
it.

---

## Proposed Future Implementation Card Boundary

Recommended future card:

```text
Track: prop038-contract-digest-live-validator-implementation-v0
Goal: Implement PROP-038 contract_digest validation inside the internal
CompilerProfileContractValidator only.
```

Allowed write scope for that future card:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json
igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json
igniter-lang/docs/tracks/prop038-contract-digest-live-validator-implementation-v0.md
```

The proof files are included only to prove live behavior and report-only
integration. The implementation must remain in the validator file unless a
separate gate widens scope.

Disallowed write scope:

```text
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/semanticir_emitter.rb
igniter-lang/lib/igniter_lang/typechecker.rb
igniter-lang/lib/igniter_lang/parser.rb
igniter-lang/lib/igniter_lang/assembler.rb
igniter-lang/.igapp artifacts or goldens
loader/report or CompatibilityReport surfaces
public API/CLI surfaces
```

If implementation discovers a need to touch any disallowed path, the card must
stop and request a widened Architect decision.

---

## Validator API And Result Shape

Recommended API change:

```text
none
```

Keep:

```ruby
validate(contract, digest_reference_policy: :prop038_24_plus)
```

Recommended result-shape change:

```text
none
```

Digest diagnostics should reuse existing result fields:

```text
diagnostics
diagnostic_codes
valid
digest_reference_policy
compiler_integrated=false
compile_refusal_authorized=false
```

Do not add result fields such as:

```text
contract_digest_status
canonical_material
computed_contract_digest
report_only
compiler_integrated_reason
```

Those would widen the live validator surface beyond the accepted result shape.
Proofs may compute expected digests locally, but the live result should not
expose canonical material or computed digest values.

---

## Canonicalization Helper Boundary

Recommended helper placement:

```text
private helpers inside IgniterLang::CompilerProfileContractValidator
```

Recommended private helper vocabulary:

```text
CONTRACT_DIGEST_PATTERN
SUPPORTED_CONTRACT_DIGEST_POLICIES
validate_contract_digest(diagnostics, contract, policy)
contract_digest_reference(contract)
contract_digest_hex(reference)
canonical_contract_material(contract)
canonicalize_for_digest(value, context: nil)
compute_contract_digest_hex(contract)
normalize_ordered_rule(rule)
normalize_strict_registry_entries(entries)
```

Implementation notes:

- `canonical_contract_material` must remove `contract_digest`.
- The helper must not fetch descriptor material.
- `descriptor_digest` is included as a string field value.
- Canonical material must not include provider metadata, `source_path`,
  `out_path`, `parsed_program`, `compiler_profile_source`, validation result
  fields, or report-only/compiler integration flags.
- Helpers remain private implementation details, not public API.

Permitted standard-library dependencies for the future implementation:

```text
digest
json
set
```

`set` already exists in the validator. `digest` and `json` are acceptable only
inside the validator implementation card; they must not introduce production
dependencies.

---

## Digest Policy Handling

Live implementation should support exactly:

```text
prop038_24_plus
```

Policy behavior:

| Condition | Diagnostic |
| --- | --- |
| `digest_reference_policy` is not `prop038_24_plus` | `compiler_profile_contract.contract_digest_policy_unsupported` |
| `contract_digest` is missing or malformed | `compiler_profile_contract.contract_digest_invalid` |
| shape and policy are valid, but canonicalization/recompute cannot run | `compiler_profile_contract.contract_digest_recompute_unavailable` |
| shape, policy, and recompute are valid, but declared digest prefix does not match computed digest | `compiler_profile_contract.contract_digest_mismatch` |

Accepted reference shape:

```text
compiler_profile_contract/sha256:<24+ lowercase hex>
```

Under `prop038_24_plus`, the declared hex is a prefix reference. The computed
full SHA-256 hex digest must start with the declared hex prefix. A 64-character
reference is therefore an exact full-digest match by prefix equality.

Do not introduce:

```text
prop038_full_sha256
shape_only
recompute_optional
refusal_on_mismatch
```

without a separate policy gate.

---

## Diagnostic Ordering

Recommended deterministic ordering for future implementation:

1. Existing kind/format/digest shape diagnostics already in the validator.
2. `compiler_profile_contract.contract_digest_policy_unsupported`.
3. `compiler_profile_contract.contract_digest_invalid`.
4. Existing structural diagnostics: required slots, strict registries, ordered
   rules, non-authority flags.
5. `compiler_profile_contract.contract_digest_recompute_unavailable` or
   `compiler_profile_contract.contract_digest_mismatch`.

Recompute should be skipped if policy is unsupported or `contract_digest` shape
is invalid.

Recompute may still run when unrelated structural diagnostics exist, because
R70 proves digest canonicalization separately from rule-reference validity.
This allows a contract to report both structural errors and digest mismatch in
one validator result.

---

## Canonicalization Rules To Implement

Canonical material:

```text
contract object excluding contract_digest
```

Included fields:

```text
kind
format_version
profile_namespace
profile_kind
compiler_profile_id
descriptor_digest
finalization_payload_digest
required_slot_schema
slot_order
slot_assignments
strict_registries
ordered_rule_graph
non_authority
```

Excluded fields:

```text
contract_digest
validation result fields
report_only
compiler_integrated
compile_refusal_authorized
provider metadata
source_path / out_path
parsed_program
compiler_profile_source
```

Ordering rules:

- object keys sort recursively;
- `slot_order` remains order-sensitive;
- strict registry names are order-insensitive;
- strict registry entries are order-insensitive;
- ordered-rule list is order-insensitive;
- `before` and `after` edge arrays are sorted unique sets;
- `descriptor_digest` is included as a string field value;
- descriptor material is not fetched or recomputed.

---

## Report-Only And No-Refusal Invariants

Future implementation must preserve:

```text
compiler_integrated=false
compile_refusal_authorized=false
```

When report-only compiler integration is exercised, digest diagnostics must live
only under:

```text
report["compiler_profile_contract_validation"]["diagnostics"]
report["compiler_profile_contract_validation"]["diagnostic_codes"]
```

They must not append to:

```text
report["diagnostics"]
```

They must not centralize in:

```text
IgniterLang::Diagnostics
```

Digest diagnostics must not change:

- compile status;
- `pass_result`;
- stages;
- public result;
- `CompilerResult`;
- assembler execution;
- `.igapp` manifests or goldens;
- refusal-report behavior.

---

## Proof Matrix For Future Implementation

The implementation card should prove at least this matrix.

### Validator Proof

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
```

Required coverage:

| Area | Required cases |
| --- | --- |
| Existing parity | Existing 13 validator cases still PASS. |
| Shape policy | `valid_short_contract_digest`, `valid_full_contract_digest`, `missing_contract_digest`, `contract_digest_wrong_namespace`, `contract_digest_too_short`, `contract_digest_non_hex`, `contract_digest_uppercase_hex`, `unsupported_digest_policy`. |
| Recompute policy | `recompute_full_match`, `recompute_prefix_match`, `recompute_full_mismatch`, `recompute_prefix_mismatch`, `recompute_unavailable`. |
| Canonicalization | `canonical_excludes_contract_digest`, `canonical_includes_descriptor_digest_string`, `canonical_does_not_recompute_descriptor_material`, `canonical_slot_order_order_sensitive`, `canonical_object_key_order_insensitive`, `canonical_strict_registry_order_insensitive`, `canonical_rule_list_order_insensitive`, `canonical_rule_edge_set_order_insensitive`, `canonical_rule_reference_still_validated`. |
| Result shape | No new top-level validator result fields; existing flags remain false. |

### Report-Only Integration Proof

Command:

```bash
ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
```

Required coverage:

| Area | Required checks |
| --- | --- |
| Nested placement | Digest diagnostics appear only under `compiler_profile_contract_validation.diagnostics`. |
| Top-level diagnostics | No digest diagnostics are appended to top-level `report["diagnostics"]`. |
| Report-only status | Compile status, pass result, stages, public result, assembler execution, `.igapp`, and refusal-report behavior remain unchanged. |
| Provider behavior | Nil/non-Hash/provider-error paths remain no-field/no-refusal as accepted in R67. |
| Compiler result | `CompilerResult` remains unchanged. |

### Syntax And Regression Checks

Commands:

```bash
ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby -c igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
```

Optional broad regression, if the implementation card owner wants extra
confidence:

```bash
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
```

The optional commands should not become required unless the implementation
touches compiler paths outside the validator, which this design does not allow.

---

## Exact C3-A Implementation Contract

[Next] Proposed future authorization text:

```text
Card: S3-R74-C1-I
Agent: [Igniter-Lang Implementation Agent]
Track: prop038-contract-digest-live-validator-implementation-v0

Goal:
Implement PROP-038 contract_digest validation inside
IgniterLang::CompilerProfileContractValidator only.

Allowed:
- add contract_digest shape validation;
- add prop038_24_plus recompute/prefix-match validation;
- add private canonicalization helpers inside the validator;
- emit the four accepted contract_digest_* diagnostics in validator-local
  result diagnostics;
- update validator and report-only integration proofs.

Required invariants:
- no validator API change;
- no validator result-shape widening;
- diagnostics remain nested in compiler_profile_contract_validation when
  report-only compiler integration is exercised;
- no top-level report diagnostics;
- no compile refusal;
- no public API/CLI widening;
- no CompilerResult change;
- no assembler or .igapp mutation;
- no loader/report, CompatibilityReport, runtime, or production behavior.
```

---

## Open Questions And Blockers

Implementation blockers before authorization:

- Architect must explicitly authorize the implementation card and write scope.
- The implementation card must choose whether proof updates stay in existing
  proof experiments or create a new proof-local digest live validator experiment.
- If any path needs data from outside the validator, the card must stop and
  request widened scope.

Open questions:

[Q] Should a future durable profile format require 64-character
`contract_digest` references even though `prop038_24_plus` accepts 24+ prefix
references for Stage 3?

[Q] Should overlong digest references beyond 64 hex characters remain accepted
by the literal `24+` shape, or should a later errata tighten the upper bound to
64 before persisted/durable use?

[Q] Should `compiler_profile_contract.contract_digest_recompute_unavailable`
ever occur in live code after canonicalization helpers are implemented, or
should it remain a defensive diagnostic for unsupported future policies and
unexpected canonicalizer failures?

[Q] Should full-digest-only policy, if needed later, be named
`prop038_full_sha256` or handled as a new PROP-038 errata gate?

---

## Non-Authorization Preserved

This track does not authorize:

- code implementation;
- compiler/orchestrator implementation;
- compile refusal;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted success reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation;
- loader/report or CompatibilityReport behavior;
- `IgniterLang::Diagnostics` centralization;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.

---

## Recommendation

Recommendation for C3-A:

```text
accept design; open a separately authorized one-slice internal validator
implementation card if Architect wants live validation next.
```

Reason:

- the accepted R69-R72 proof/design chain is sufficient to define the exact
  bounded implementation boundary;
- the implementation can remain entirely inside the internal validator plus
  proof updates;
- no public/compiler/runtime surfaces need to widen;
- report-only/no-refusal invariants remain explicit and testable.
