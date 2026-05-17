# Track: PROP-038 Contract Digest Validation Policy Design v0

Card: S3-R68-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop038-contract-digest-validation-policy-design-v0`
Route: UPDATE
Status: done
Date: 2026-05-17

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Implementation Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Design the PROP-038 `contract_digest` validation policy after R67 report-only
compiler integration, without authorizing or implementing code.

This track is documentation-only. It does not edit code, modify PROP-038,
authorize implementation, authorize compile refusal, or widen public/API/runtime
surfaces.

---

## Inputs Read

- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/gates/prop038-library-validator-extraction-acceptance-decision-v0.md`
- `docs/gates/prop038-library-validator-extraction-design-decision-v0.md`
- `docs/discussions/prop038-library-validator-extraction-design-pressure-v0.md`
- `docs/discussions/prop038-report-only-compiler-integration-implementation-pressure-v0.md`
- `docs/tracks/stage3-round67-status-curation-v0.md`
- `lib/igniter_lang/compiler_profile_contract_validator.rb`
- `experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json`

---

## Current Accepted State

Accepted validator API:

```ruby
IgniterLang::CompilerProfileContractValidator.validate(
  contract,
  digest_reference_policy: :prop038_24_plus
)
```

Accepted result surface:

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

R65/R67 accepted:

- descriptor digest is shape-only;
- `contract_digest` validation is deferred;
- diagnostics are local to `CompilerProfileContractValidator`;
- diagnostics are not centralized in `IgniterLang::Diagnostics`;
- report-only compiler integration can attach an in-memory
  `compiler_profile_contract_validation` report field;
- invalid validation does not change compile status, stages, public result,
  assembler execution, `.igapp` manifest, or refusal behavior.

Current validator validates:

```text
descriptor_digest: compiler_profile_descriptor/sha256:<24+ lowercase hex>
finalization_payload_digest: sha256:<64 lowercase hex>
```

Current validator does not validate:

```text
contract_digest format
contract_digest recompute/match
```

---

## Recommended Policy

Recommended policy:

```text
hybrid
```

Meaning:

```text
Current validator remains prop038_24_plus and report-only.
No contract_digest validation is added now.
Future contract_digest validation should be designed in two stages:
  1. shape-only proof
  2. recompute-match proof
Implementation remains held until both policy and proof matrix are accepted.
```

Short answer:

| Question | Answer |
| --- | --- |
| Should the current validator remain `prop038_24_plus` shape-only for now? | Yes. Keep current behavior. Do not add `contract_digest` checks in this card. |
| Is full recomputation stable enough to design? | Yes, as a design target. |
| Is full recomputation stable enough to implement now? | No. Canonicalization needs proof before code. |
| Where would diagnostics live later? | Local to `CompilerProfileContractValidator` under `compiler_profile_contract.*`, and inside the in-memory validation result if integrated. |
| Can digest diagnostics ever become compile refusal? | Not by this route. They remain report-only unless a later explicit compile-refusal gate authorizes refusal. |
| Smallest safe implementation slice, if any? | After proof, shape-only `contract_digest_invalid` in the internal validator, report-only only. No recomputation first. |

---

## Policy Options

| Option | Meaning | Recommendation |
| --- | --- | --- |
| Deferred | Keep `contract_digest` entirely ignored. | Safe current state, but insufficient as a long-term contract policy. |
| Shape-only | Validate `contract_digest` reference shape under `prop038_24_plus`. | Smallest future implementation slice after proof. |
| Recompute-match | Canonicalize contract material, recompute digest, compare to declared ref. | Correct long-term integrity policy, but not implementation-ready yet. |
| Hybrid | Hold current behavior; prove shape-only; then prove recompute-match. | Recommended. |

---

## Contract Digest Meaning

`contract_digest` identifies the canonical contract object.

PROP-038 says:

```text
contract_digest: compiler_profile_contract/sha256:<24+ lowercase hex>
```

and:

```text
The digest is computed over canonicalized contract material excluding
contract_digest itself.
```

This track clarifies that this is a future validation target, not current
validator behavior.

---

## Descriptor Digest vs Contract Digest

Keep these separate:

| Field | Identifies | Validation source | Recompute material |
| --- | --- | --- | --- |
| `descriptor_digest` | Compiler profile descriptor identity | Descriptor material, not currently supplied to validator | Descriptor object/document only |
| `contract_digest` | Whole compiler profile contract identity | Contract object supplied to validator | Contract object excluding `contract_digest` |

Rules:

- Contract digest recomputation must not attempt to recompute
  `descriptor_digest`.
- Contract digest canonicalization includes the `descriptor_digest` string as a
  field value.
- A malformed `descriptor_digest` remains
  `compiler_profile_contract.descriptor_digest_invalid`.
- A mismatched `descriptor_digest` against external descriptor material is not a
  `contract_digest` mismatch unless the contract object's own digest also fails.
- Descriptor material discovery remains out of scope for the current validator.

---

## Short vs Full Digest References

Current policy:

```text
prop038_24_plus
```

Interpretation:

- namespaced digest references may use 24 or more lowercase hexadecimal
  characters;
- full 64-character SHA-256 references are valid;
- shorter-than-64 references are prefix references, not full durable identity;
- uppercase hex is invalid;
- non-hex characters are invalid;
- prefixes shorter than 24 hex characters are invalid.

Recommended future policies:

| Policy | Accepted contract digest ref | Match behavior if recompute is enabled |
| --- | --- | --- |
| `prop038_24_plus` | `compiler_profile_contract/sha256:<24+ lowercase hex>` | Computed full SHA-256 must start with the declared hex prefix. |
| `prop038_full_sha256` | `compiler_profile_contract/sha256:<64 lowercase hex>` | Computed full SHA-256 must exactly equal declared hex. |

Do not introduce `prop038_full_sha256` in code before a separate policy/proof
gate.

---

## Recompute Canonicalization Design

If recompute-match is later pursued, the canonicalization input material should
be:

```text
contract object excluding contract_digest
```

Included top-level fields:

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

Excluded:

```text
contract_digest
validation result fields
report_only
compiler_integrated
compile_refusal_authorized
provider metadata
source_path / out_path / parsed_program
compiler_profile_source
```

Canonicalization rules for a future proof:

| Material | Canonicalization rule |
| --- | --- |
| Object keys | Sort recursively by UTF-8 string key. |
| Strings / booleans / null | Use canonical JSON scalar representation. |
| `slot_order` | Preserve order; the order is semantic. |
| `required_slot_schema.required_slots` | Preserve declared order for v0; compare to canonical expected slots separately. |
| `required_slot_schema.optional_slots` | Preserve declared order for v0; compare to canonical expected slots separately. |
| `required_slot_schema.all_slots` | Preserve declared order for v0; compare to canonical expected slots separately. |
| `slot_assignments` | Sort slot keys recursively; values sorted by object key. |
| `strict_registries` | Sort registry names; sort entries by `[key, owner_slot, rule_ref]` because entry order has no semantics. |
| `ordered_rule_graph.rules` | Sort by `rule_id`; graph semantics come from edges, not list order. |
| Rule `before` / `after` arrays | Sort unique rule ids for digest material; reference validity remains a separate validation rule. |
| `non_authority` | Sort object keys. |

Canonical JSON output must be UTF-8, contain no insignificant whitespace, and use
string keys only.

This design intentionally separates:

```text
canonicalization for digest
validation rules for contract correctness
```

Canonicalization should not silently fix invalid contract semantics. It only
normalizes material for hashing.

---

## Diagnostic Vocabulary Proposal

Future diagnostic codes should stay local to:

```text
compiler_profile_contract.*
```

Proposed codes:

| Code | Meaning | First allowed policy |
| --- | --- | --- |
| `compiler_profile_contract.contract_digest_invalid` | `contract_digest` is missing or does not match the selected reference shape. | shape-only |
| `compiler_profile_contract.contract_digest_recompute_unavailable` | Selected policy requires recomputation but canonical material or canonicalization support is unavailable. | recompute-match |
| `compiler_profile_contract.contract_digest_mismatch` | Recomputed full SHA-256 does not match the declared full digest or prefix. | recompute-match |
| `compiler_profile_contract.contract_digest_policy_unsupported` | Caller selected a digest policy the validator does not support. | shape-only |

Do not add these to `IgniterLang::Diagnostics` without a separate diagnostics
centralization decision.

Do not append these to top-level `report["diagnostics"]` without a separate
report integration decision.

If integrated later, these diagnostics live inside:

```text
report["compiler_profile_contract_validation"]["diagnostics"]
```

and remain report-only unless compile refusal is explicitly authorized.

---

## Report-Only vs Refusal Policy

Default rule:

```text
contract_digest diagnostics remain report-only
```

Even if later implemented, these diagnostics should not change:

- compile status;
- `pass_result`;
- stages;
- compiler diagnostics;
- public result;
- assembler execution;
- `.igapp` manifest;
- refusal report creation.

Compile refusal can be considered only after:

1. PROP-038 contract digest policy is accepted or amended.
2. Shape-only and recompute-match proofs pass.
3. Report-only integration proves digest diagnostics are stable.
4. A separate compile-refusal gate explicitly authorizes refusal and exact write
   scope.

This card does not open that path.

---

## Required Proof Matrix Before Implementation

### Phase 1: Shape-Only Proof

Required cases:

| Case | Expected result |
| --- | --- |
| `valid_short_contract_digest` | valid under `prop038_24_plus`. |
| `valid_full_contract_digest` | valid under `prop038_24_plus`. |
| `missing_contract_digest` | `compiler_profile_contract.contract_digest_invalid`. |
| `contract_digest_wrong_namespace` | `compiler_profile_contract.contract_digest_invalid`. |
| `contract_digest_too_short` | `compiler_profile_contract.contract_digest_invalid`. |
| `contract_digest_non_hex` | `compiler_profile_contract.contract_digest_invalid`. |
| `contract_digest_uppercase_hex` | `compiler_profile_contract.contract_digest_invalid`. |
| `unsupported_digest_policy` | `compiler_profile_contract.contract_digest_policy_unsupported`. |

Regression checks:

- existing 13-case validator matrix remains PASS;
- R67 report-only integration remains unchanged;
- `valid_contract` and `invalid_contract` public results remain unchanged;
- `compile_refusal_authorized=false`;
- no `.igapp` mutation.

### Phase 2: Recompute-Match Proof

Required canonicalization cases:

| Case | Expected result |
| --- | --- |
| `recompute_full_match` | Recomputed full SHA-256 matches full declared ref. |
| `recompute_prefix_match` | Recomputed full SHA-256 starts with declared 24+ prefix under `prop038_24_plus`. |
| `recompute_full_mismatch` | `compiler_profile_contract.contract_digest_mismatch`. |
| `recompute_prefix_mismatch` | `compiler_profile_contract.contract_digest_mismatch`. |
| `recompute_unavailable` | `compiler_profile_contract.contract_digest_recompute_unavailable`. |
| `canonical_excludes_contract_digest` | Changing only `contract_digest` does not change recomputed material hash input. |
| `canonical_includes_descriptor_digest_string` | Changing `descriptor_digest` string changes recomputed contract digest input. |
| `canonical_does_not_recompute_descriptor_material` | Missing descriptor material does not become descriptor recompute behavior. |
| `canonical_slot_order_order_sensitive` | Reordering `slot_order` changes digest input. |
| `canonical_object_key_order_insensitive` | Reordering object keys does not change digest input. |
| `canonical_strict_registry_order_insensitive` | Reordering strict registry entries does not change digest input. |
| `canonical_rule_list_order_insensitive` | Reordering rule list by non-semantic order does not change digest input. |
| `canonical_rule_edge_set_order_insensitive` | Reordering `before` / `after` edge arrays does not change digest input. |
| `canonical_rule_reference_still_validated` | Missing refs still produce `missing_rule_reference`; canonicalization does not hide invalidity. |

Integration checks if wired through R67 report-only path:

- valid digest attaches `valid=true`;
- mismatch attaches `valid=false`;
- mismatch still returns compile status `ok`;
- mismatch does not alter public result;
- mismatch does not mutate `.igapp`;
- mismatch does not write refusal report;
- provider exception still behaves as nil.

---

## Smallest Safe Implementation Slice

No implementation is recommended from this card.

If a later C3-A insists on an implementation route, the smallest safe slice is:

```text
contract_digest shape-only validation in CompilerProfileContractValidator
```

Allowed only after Phase 1 proof/design acceptance.

Exact limits for that future slice:

- add `contract_digest_invalid`;
- add `contract_digest_policy_unsupported` only if policy selection is surfaced;
- keep `digest_reference_policy: prop038_24_plus`;
- do not recompute digest;
- do not add mismatch diagnostics;
- keep diagnostics local to validator;
- keep report-only behavior;
- do not change `CompilerResult`;
- do not persist reports or sidecars;
- do not mutate `.igapp`;
- do not centralize diagnostics.

---

## Recommendation For C3-A

Recommended C3-A route:

```text
authorize next design/proof route
```

Specific recommendation:

```text
Open a proof-local contract_digest shape-policy proof first.
Hold implementation.
Hold recompute-match implementation.
Hold compile refusal.
```

Suggested next card:

```text
prop038-contract-digest-shape-policy-proof-v0
```

Scope:

- exercise Phase 1 shape-only matrix;
- preserve current validator behavior in live compiler unless explicitly
  authorized later;
- produce summary JSON only under an experiment directory;
- do not edit compiler integration paths;
- do not mutate `.igapp`;
- do not change public API/CLI, `CompilerResult`, loader/report, or
  CompatibilityReport.

Do not modify PROP-038 yet. If Phase 1 and Phase 2 proofs later stabilize new
digest diagnostics, open a separate PROP-038 errata card to add the
`contract_digest_*` diagnostic vocabulary and policy text.

---

## Non-Authorization

This track does not authorize:

- implementation;
- compile refusal;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted success reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` changes;
- loader/report behavior;
- CompatibilityReport behavior;
- `IgniterLang::Diagnostics` centralization;
- RuntimeMachine / Gate 3 widening;
- Ledger/TBackend;
- BiHistory;
- stream/OLAP production execution;
- cache;
- production behavior.

---

## Handoff

```text
Card: S3-R68-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop038-contract-digest-validation-policy-design-v0
Status: done

[D] Decisions
- Recommended policy: hybrid.
- Keep current validator at prop038_24_plus with no contract_digest validation
  for now.
- Full recomputation is designable but premature to implement.
- Future diagnostics should live under compiler_profile_contract.* and remain
  local to CompilerProfileContractValidator / in-memory validation reports.
- descriptor_digest and contract_digest remain separate identities.

[S] Signals
- R67 report-only integration is stable enough to carry future digest
  diagnostics as report-only fields.
- Digest recomputation needs canonicalization proof before code.
- Shape-only contract_digest validation is the smallest future implementation
  slice, but only after proof and C3-A authorization.

[T] Tests / Proofs
- Documentation-only design slice.
- No code or experiment commands run.

[R] Recommendation
- C3-A should authorize a proof-local
  prop038-contract-digest-shape-policy-proof-v0 route.
- Hold implementation, recompute-match implementation, compile refusal,
  persisted output, public API/CLI, loader/report, CompatibilityReport, and
  production behavior.

[Next]
- Prove contract_digest shape policy under prop038_24_plus, then separately
  prove recompute canonicalization before any implementation request.
```
