# Compiler Profile Contract Proof v0

Card: S3-R58-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/compiler-profile-contract-proof-v0
Route: UPDATE
Status: done
Date: 2026-05-16

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - owns future formal slot schema, ordered-rule semantics, and diagnostic vocabulary.
- [Igniter-Lang Bridge Agent] - future profile transport / package boundary awareness only; no bridge behavior changed here.

---

## Scope

Build the proof-local canonical `compiler_profile_contract` experiment
authorized by S3-R57-C4-A.

Read:

- `docs/gates/compiler-profile-contract-boundary-decision-v0.md`
- `docs/tracks/compiler-profile-contract-boundary-v0.md`
- `docs/tracks/compiler-profile-contract-bridge-surface-review-v0.md`
- `docs/discussions/compiler-profile-contract-boundary-pressure-v0.md`
- `docs/gates/compiler-profile-obligation-coverage-proof-decision-v0.md`
- `docs/tracks/compiler-profile-obligation-coverage-proof-v0.md`
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `experiments/compiler_profile_obligation_coverage_proof/out/compiler_profile_obligation_coverage_summary.json`

This slice emits proof output only under its own experiment directory. It does
not touch live compiler dispatch, `.igapp` artifacts, goldens, CLI/API,
loader/report, CompatibilityReport, RuntimeMachine, Gate 3, Ledger/TBackend,
BiHistory, stream/OLAP, cache, or production behavior.

---

## Produced

```text
igniter-lang/experiments/compiler_profile_contract_proof/
  compiler_profile_contract_proof.rb
  out/compiler_profile_contract_proof_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
```

Observed output:

```text
PASS compiler_profile_contract_proof
```

Syntax check:

```bash
ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
```

Observed output:

```text
Syntax OK
```

---

## Canonical Object

The proof validates a canonical `compiler_profile_contract` object with:

- `kind: "compiler_profile_contract"`
- `format_version: "0.1.0"`
- `descriptor_digest`
- `finalization_payload_digest`
- `required_slot_schema`
- `slot_order`
- `slot_assignments`
- `strict_registries`
- `ordered_rule_graph`
- non-authority flags:
  - `runtime_authority_granted: false`
  - `dispatch_migration_authorized: false`
  - `compiler_understanding_only: true`
- `contract_digest`

The valid contract projects back to the existing finalized
`compiler_profile_id_source` artifact:

```text
source_projection_matches_profile_source: true
```

This proves the contract can sit before the existing source transport without
changing the current source artifact shape.

---

## Contract Cases

| Case | Result | Diagnostic result |
| --- | --- | --- |
| `valid_contract` | valid | no diagnostics |
| `missing_required_slot` | invalid | `compiler_profile_contract.missing_required_slot` plus follow-on owner/rule owner diagnostics caused by the removed slot |
| `duplicate_strict_key` | invalid | `compiler_profile_contract.duplicate_strict_key` |
| `rule_cycle` | invalid | `compiler_profile_contract.rule_cycle` |
| `runtime_authority_forbidden` | invalid | `compiler_profile_contract.runtime_authority_forbidden` |
| `dispatch_migration_forbidden` | invalid | `compiler_profile_contract.dispatch_migration_forbidden` |

The `missing_required_slot` case intentionally removes `oof_registry`; the
additional `unknown_owner_slot` and `unknown_rule_owner_slot` diagnostics are
expected downstream consistency evidence, not replacement diagnostics.

---

## Diagnostic Separation

The proof preserves three diagnostic boundaries:

| Boundary | Proof result |
| --- | --- |
| Contract schema missing slot vs obligation coverage missing slot | `compiler_profile_contract.missing_required_slot` is distinct from `compiler_profile_obligation.missing_slot` |
| Contract diagnostics vs loader/report vocabulary | loader/report terms such as `absent_legacy`, `present_verified`, `mismatch`, `malformed`, and `missing_required` do not appear as contract diagnostics |
| Contract diagnostics vs source transport diagnostics | `compiler_profile_source.*` terms do not appear as contract diagnostics |

Short rule:

```text
missing_required_slot != missing_slot != missing_required
```

They answer different questions:

1. Is the contract object missing a schema-required compiler slot?
2. Does emitted program surface coverage require a slot absent from the supplied profile?
3. Is a manifest/report missing a required profile identity under a future rollout policy?

---

## Future `profile_not_supplied`

The proof records the future design behavior requested by this card:

```json
{
  "status": "profile_not_supplied",
  "required_slots": [
    "contract_modifiers",
    "core",
    "escape_boundary",
    "fragment_registry",
    "oof_registry",
    "pipeline"
  ],
  "missing_slots": []
}
```

This keeps `profile_not_supplied` from pretending that a concrete supplied
profile failed coverage. The required slots remain visible, while
`missing_slots` is empty because there is no supplied profile to compare.

---

## Execution Ordering

The proof fixes the design ordering as:

```text
compiler_profile_contract_validated
  -> finalizes_to_compiler_profile_id_source
  -> source_transported_and_validated_by_compiler_profile_source
  -> semantic_ir_emitted
  -> semanticir_profile_obligation_checkpoint
  -> manifest_report_interpretation_later
```

Required disclaimer:

```text
SemanticIR profile-obligation checkpoint is a proposed future design position, not current implementation.
```

---

## Non-Authority Boundary

The summary records all non-authorized surfaces as false:

- live compiler dispatch
- `.igapp` artifacts
- goldens
- CLI/API
- loader/report
- CompatibilityReport
- RuntimeMachine
- Gate 3
- Ledger/TBackend
- BiHistory
- stream/OLAP production behavior
- cache
- production behavior

The contract is compiler-understanding metadata only. It does not grant runtime
authority, dispatch migration authority, loader readiness, or execution
readiness.

---

## Summary Checks

The proof summary reports PASS for:

```text
valid_contract.accepted
source_projection.matches_profile_source
missing_required_slot.diagnostic
duplicate_strict_key.diagnostic
rule_cycle.diagnostic
runtime_authority.diagnostic
dispatch_migration.diagnostic
separation.obligation_missing_slot_present
separation.contract_missing_required_slot_distinct
separation.loader_terms_absent
separation.source_terms_absent
future_profile_not_supplied.required_slots_populated
future_profile_not_supplied.missing_slots_empty
ordering.contract_before_source
ordering.obligation_after_semanticir
disclaimer.present
```

---

## Remaining Blockers

Before PROP authoring or implementation authorization:

1. Pressure review of the canonical contract object shape and digest relationship.
2. Decision whether this becomes a new PROP, a PROP-036 amendment, or a spec chapter addition.
3. Compiler/Grammar ownership of the formal slot schema and ordered-rule graph semantics.
4. Stable one-owner registry semantics for strict keys across OOF descriptors and fragment owners.
5. Decision on PROP-037 progression slot treatment before progression implementation; v0 keeps progression metadata under `pipeline`.
6. Explicit implementation authorization with narrow write scope before any compiler/orchestrator behavior changes.
7. Golden/artifact mutation policy if contract validation becomes persisted in future artifacts.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/compiler-profile-contract-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Canonical compiler_profile_contract proof shape is viable as a pre-source contract object.
- Contract diagnostics stay under compiler_profile_contract.* and remain separate from compiler_profile_obligation.*, compiler_profile_source.*, and loader/report vocabulary.
- profile_not_supplied future behavior should expose required_slots while keeping missing_slots empty.
- SemanticIR profile-obligation checkpoint remains proposed future design, not current implementation.

[S] Signals:
- Valid contract projects to the existing finalized compiler_profile_id_source artifact.
- Strict registry one-owner checks, ordered-rule references, and ordered-rule cycle detection are proof-covered.
- Non-authority flags reject runtime authority and dispatch migration authority.

[T] Tests / Proofs:
- PASS: ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
- PASS: ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb

[R] Recommendations:
- Send this proof to Compiler/Grammar Expert for pressure on formal slot schema, ordered-rule semantics, and diagnostic vocabulary.
- Use this as evidence for PROP authoring or a PROP-036 amendment only after pressure review.

[Files] Changed:
- igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
- igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json
- igniter-lang/docs/tracks/compiler-profile-contract-proof-v0.md

[Q] Open Questions:
- Should compiler_profile_contract become a standalone PROP or a PROP-036 amendment?
- Which role owns the durable registry of strict keys once this moves beyond proof-local shape?

[X] Rejected:
- No CLI/API exposure, loader/report behavior, CompatibilityReport behavior, RuntimeMachine behavior, dispatch migration, or production behavior was added.

[Next] Proposed next slice:
- Compiler/Grammar pressure review for contract schema precision, digest semantics, ordered-rule graph, and diagnostic namespace before implementation authorization.
```
