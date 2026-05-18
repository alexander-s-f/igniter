# PROP-038 Contract Digest Recompute Match Proof v0

Card: S3-R70-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop038-contract-digest-recompute-match-proof-v0
Route: UPDATE
Status: done
Date: 2026-05-18

Authority ref:

- `docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md`

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - future PROP-038 errata / canonicalization wording.
- [Igniter-Lang Bridge Agent] - future report-only consumer awareness; no bridge behavior changed.

---

## Scope

Build proof-local evidence for future PROP-038 `contract_digest`
recompute-match behavior and canonicalization.

Read:

- `docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md`
- `docs/gates/prop038-contract-digest-validation-policy-decision-v0.md`
- `docs/tracks/prop038-contract-digest-validation-policy-design-v0.md`
- `docs/tracks/prop038-contract-digest-shape-policy-proof-v0.md`
- `docs/discussions/prop038-contract-digest-shape-policy-proof-pressure-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/gates/prop038-library-validator-extraction-acceptance-decision-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `experiments/prop038_contract_digest_shape_policy_proof/out/prop038_contract_digest_shape_policy_proof_summary.json`

This proof models canonicalization and recompute-match locally inside the
experiment. It does not edit the live validator, compiler, orchestrator,
CompilationReport, public API/CLI, assembler, runtime, or `.igapp` artifacts.

---

## Produced

```text
igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/
  prop038_contract_digest_recompute_match_proof.rb
  out/prop038_contract_digest_recompute_match_proof_summary.json
```

Track doc:

```text
igniter-lang/docs/tracks/prop038-contract-digest-recompute-match-proof-v0.md
```

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb` | `PASS prop038_contract_digest_recompute_match_proof` |
| `ruby -c igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb` | `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | `PASS prop038_contract_digest_shape_policy_proof` |
| `ruby -c igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | `Syntax OK` |
| `ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | `PASS compiler_profile_contract_proof` |
| `ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | `PASS prop038_report_only_compiler_integration` |
| `ruby -c igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | `Syntax OK` |
| `ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb` | `Syntax OK` |

---

## Canonicalization Model

Canonicalization input:

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

Explicitly excluded:

```text
contract_digest
validation result fields
report_only
compiler_integrated
compile_refusal_authorized
provider metadata
source/out paths
parsed program
compiler profile source transport
```

Canonical rules:

- object keys sort recursively;
- `slot_order` remains order-sensitive;
- strict registry names sort, and entries sort by `[key, owner_slot, rule_ref]`;
- ordered rules sort by `rule_id`;
- rule `before` / `after` arrays are unique sorted edge sets;
- `descriptor_digest` is included as a string field value;
- descriptor material is not fetched or recomputed.

---

## Case Matrix

| Case | Expected | Result |
| --- | --- | --- |
| `recompute_full_match` | valid | PASS |
| `recompute_prefix_match` | valid | PASS |
| `recompute_full_mismatch` | `compiler_profile_contract.contract_digest_mismatch` | PASS |
| `recompute_prefix_mismatch` | `compiler_profile_contract.contract_digest_mismatch` | PASS |
| `recompute_unavailable` | `compiler_profile_contract.contract_digest_recompute_unavailable` | PASS |
| `canonical_excludes_contract_digest` | same canonical digest despite changed `contract_digest` | PASS |
| `canonical_includes_descriptor_digest_string` | descriptor digest string changes canonical digest | PASS |
| `canonical_does_not_recompute_descriptor_material` | descriptor material is not required or fetched | PASS |
| `canonical_slot_order_order_sensitive` | `slot_order` order changes canonical digest | PASS |
| `canonical_object_key_order_insensitive` | top-level object key order does not change canonical digest | PASS |
| `canonical_strict_registry_order_insensitive` | registry and registry-entry order do not change canonical digest | PASS |
| `canonical_rule_list_order_insensitive` | ordered-rule list order does not change canonical digest | PASS |
| `canonical_rule_edge_set_order_insensitive` | `before` / `after` edge order and duplicates do not change canonical digest | PASS |
| `canonical_rule_reference_still_validated` | existing `compiler_profile_contract.missing_rule_reference` remains valid | PASS |

New proof-local diagnostics:

```text
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

Existing diagnostic preserved:

```text
compiler_profile_contract.missing_rule_reference
```

---

## Regression Checks

Summary state:

```json
{
  "status": "PASS",
  "failed_checks": [],
  "shape_policy_proof_status": "PASS",
  "live_validator_changed": false,
  "compiler_integration_changed": false,
  "recompute_match_live_implemented": false,
  "compile_refusal_authorized": false,
  "implementation_authorized": false
}
```

Regression signals:

- R69 shape-policy proof remains PASS;
- existing 13-case validator matrix remains PASS;
- R67 report-only integration remains PASS;
- public result remains unchanged in the integration summary;
- proof-local and live validator paths keep `compile_refusal_authorized=false`;
- proof output contains no `.igapp` artifact;
- proof output contains no refusal report.

---

## Non-Authorizations Preserved

No live validator implementation.

No compiler/orchestrator integration implementation.

No compile refusal.

No public API/CLI widening.

No `CompilerResult` changes.

No persisted success reports or sidecars.

No parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation except
proof-local generated output and allowed rerun of existing proof-local outputs.

No loader/report or CompatibilityReport.

No `IgniterLang::Diagnostics` centralization.

No RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
production behavior.

---

## Recommendation For C3-A

Recommendation:

```text
accept
```

Reason:

- all required recompute/canonicalization cases pass;
- mismatch and recompute-unavailable diagnostics are separated;
- canonicalization excludes `contract_digest` and excluded runtime/report/provider material;
- descriptor digest remains a string input, not a descriptor-material fetch;
- shape-policy, validator matrix, and report-only compiler integration remain PASS;
- live implementation and compile refusal remain closed.

Recommended next route after acceptance:

```text
prop038-contract-digest-report-only-integration-proof-v0
```

only if Architect explicitly authorizes a proof-local integration phase. Do not
infer live validator implementation or compile refusal from this proof.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/prop038-contract-digest-recompute-match-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Modeled contract_digest recompute-match locally using canonical contract material excluding contract_digest.
- Kept recompute-match out of the live validator/compiler.
- Preserved report-only and non-refusal behavior.
- Confirmed missing_rule_reference remains a separate contract validity diagnostic and is not hidden by canonicalization.

[S] Signals:
- Summary status PASS with failed_checks [].
- All 14 required cases pass.
- Shape-policy proof, 13-case validator matrix, and R67 report-only integration remain PASS.
- live_validator_changed=false, compiler_integration_changed=false, recompute_match_live_implemented=false.

[T] Tests / Proofs:
- PASS: ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
- PASS: ruby -c igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
- PASS: ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
- PASS: ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
- PASS: ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb

[R] Recommendations:
- C3-A can accept this proof-local recompute-match closure.
- Do not authorize live implementation or compile refusal from this proof.
- If continuing, route to a separate report-only integration proof that keeps digest diagnostics nested and non-refusal.

[Files] Changed:
- igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
- igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/out/prop038_contract_digest_recompute_match_proof_summary.json
- igniter-lang/docs/tracks/prop038-contract-digest-recompute-match-proof-v0.md

[Q] Open Questions:
- Should recompute diagnostics be added to PROP-038 text before or after report-only integration proof?
- Should durable storage later require full 64-character contract digests?

[X] Rejected:
- No live validator implementation, compiler/orchestrator integration, compile refusal, public API/CLI widening, `CompilerResult` changes, loader/report behavior, CompatibilityReport behavior, RuntimeMachine behavior, or production behavior was added.

[Next] Proposed next slice:
- Architect C3-A acceptance decision; if accepted, consider a separate report-only integration proof for recompute diagnostics.
```
