# Compiler Profile Contract Validator Coverage Proof v0

Card: S3-R60-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/compiler-profile-contract-validator-coverage-proof-v0
Route: UPDATE
Status: done
Date: 2026-05-16

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - owns future PROP wording for slot schema, rule graph semantics, and diagnostic namespace.
- [Igniter-Lang Bridge Agent] - future transport/package awareness only; no bridge behavior changed in this proof.

---

## Scope

Close the R59 validator coverage blockers by extending the proof-local
`compiler_profile_contract` experiment.

Read:

- `docs/gates/compiler-profile-contract-prop-authoring-decision-v0.md`
- `docs/tracks/compiler-profile-contract-schema-and-rule-ownership-pressure-v0.md`
- `docs/discussions/compiler-profile-contract-schema-ownership-pressure-v0.md`
- `docs/gates/compiler-profile-contract-proof-decision-v0.md`
- `docs/tracks/compiler-profile-contract-proof-v0.md`
- `experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`

This track does not author PROP text and does not authorize implementation. It
does not touch live compiler dispatch, `.igapp` artifacts, goldens, CLI/API,
loader/report, CompatibilityReport, RuntimeMachine, Gate 3, Ledger/TBackend,
BiHistory, stream/OLAP, cache, or production behavior.

---

## Produced

Updated existing proof-local experiment:

```text
igniter-lang/experiments/compiler_profile_contract_proof/
  compiler_profile_contract_proof.rb
  out/compiler_profile_contract_proof_summary.json
```

Added track record:

```text
igniter-lang/docs/tracks/compiler-profile-contract-validator-coverage-proof-v0.md
```

The summary now reports:

```json
{
  "track": "compiler-profile-contract-validator-coverage-proof-v0",
  "extends_track": "compiler-profile-contract-proof-v0",
  "status": "PASS"
}
```

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | `PASS compiler_profile_contract_proof` |
| `ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | `Syntax OK` |

---

## Validator Case Matrix

| Case | Expected | Result |
| --- | --- | --- |
| `valid_contract` | valid | PASS |
| `missing_required_slot` | `compiler_profile_contract.missing_required_slot` | PASS |
| `duplicate_strict_key` | `compiler_profile_contract.duplicate_strict_key` | PASS |
| `duplicate_fragment_class_owner` | `compiler_profile_contract.duplicate_strict_key` | PASS |
| `rule_cycle` | `compiler_profile_contract.rule_cycle` | PASS |
| `missing_rule_reference` | `compiler_profile_contract.missing_rule_reference` | PASS |
| `wrong_kind` | `compiler_profile_contract.wrong_kind` | PASS |
| `unsupported_format_version` | `compiler_profile_contract.unsupported_format_version` | PASS |
| `descriptor_digest_invalid` | `compiler_profile_contract.descriptor_digest_invalid` | PASS |
| `finalization_payload_digest_invalid` | `compiler_profile_contract.finalization_payload_digest_invalid` | PASS |
| `runtime_authority_forbidden` | `compiler_profile_contract.runtime_authority_forbidden` | PASS |
| `dispatch_migration_forbidden` | `compiler_profile_contract.dispatch_migration_forbidden` | PASS |

New R60 coverage closes the five R59 blocker branches:

- `compiler_profile_contract.missing_rule_reference`
- `compiler_profile_contract.wrong_kind`
- `compiler_profile_contract.unsupported_format_version`
- `compiler_profile_contract.descriptor_digest_invalid`
- `compiler_profile_contract.finalization_payload_digest_invalid`

The optional `duplicate_fragment_class_owner` case strengthens the
registry-general one-owner claim by proving the same duplicate-key validator
path across `fragment_class_owners`, not only `oof_descriptors`.

---

## Preserved R58 Behavior

Preserved:

- valid canonical contract acceptance;
- source projection back to the existing finalized `compiler_profile_id_source`;
- existing R58 negative cases and diagnostics;
- execution order:

```text
compiler_profile_contract_validated
  -> finalizes_to_compiler_profile_id_source
  -> source_transported_and_validated_by_compiler_profile_source
  -> semantic_ir_emitted
  -> semanticir_profile_obligation_checkpoint
  -> manifest_report_interpretation_later
```

Required disclaimer remains present:

```text
SemanticIR profile-obligation checkpoint is a proposed future design position, not current implementation.
```

---

## Diagnostic Separation

Preserved:

| Boundary | Result |
| --- | --- |
| `compiler_profile_contract.missing_required_slot` vs `compiler_profile_obligation.missing_slot` | distinct |
| Loader/report terms as contract diagnostics | absent |
| `compiler_profile_source.*` terms as contract diagnostics | absent |

Short rule remains:

```text
missing_required_slot != missing_slot != missing_required
```

---

## `profile_not_supplied` Lookup

R60 removes the positional proof debt from R58. The proof now selects the
`profile_not_supplied` obligation report by named case/status instead of array
position.

Shape preserved:

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

---

## Remaining Blockers Before PROP Authoring

The R59 validator-coverage blocker is closed by this proof.

Remaining before PROP authoring:

1. Architect decision to lift the R59 hold and explicitly authorize PROP authoring.
2. PROP text must decide whether `ordered_rule_graph.stage` is normative validated vocabulary or informational metadata.
3. PROP text must define stable `descriptor_digest` and `finalization_payload_digest` semantics beyond proof-local projection.
4. PROP text must preserve that slot assignment means declared compiler-understanding ownership, not handler execution or dispatch authority.
5. PROP text must preserve progression metadata under `pipeline` for v0 unless a separate decision authorizes a `progression` slot.

Remaining before implementation authorization:

1. Separate Architect implementation authorization with exact write scope.
2. Golden/artifact mutation policy if contract validation becomes persisted.
3. Production diagnostic/reporting integration plan if validator output stops being proof-local.
4. Compiler/orchestrator insertion point must be authorized separately from this proof.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/compiler-profile-contract-validator-coverage-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- R60 extends the existing proof-local compiler_profile_contract experiment rather than creating a new live compiler path.
- All five R59 validator coverage blockers now have explicit proof cases.
- profile_not_supplied required_slots now use named/status report selection, not positional lookup.
- duplicate fragment_class_owners coverage is included as optional registry-general one-owner evidence.

[S] Signals:
- Summary status is PASS.
- Diagnostic namespace separation remains intact.
- Source projection and execution ordering remain intact.
- No authorizing or production surfaces were touched.

[T] Tests / Proofs:
- PASS: ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
- PASS: ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb

[R] Recommendations:
- Route to Architect for a decision on whether R59 hold can be lifted for PROP authoring.
- Before PROP text freezes, decide whether ordered_rule_graph.stage is normative vocabulary or metadata.

[Files] Changed:
- igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
- igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json
- igniter-lang/docs/tracks/compiler-profile-contract-validator-coverage-proof-v0.md

[Q] Open Questions:
- Should stage values be validated now, or documented as informational until a later proof?
- Should the future PROP define contract digest semantics directly or reference a shared digest normalization rule?

[X] Rejected:
- No PROP authoring, implementation, CLI/API behavior, loader/report behavior, CompatibilityReport behavior, RuntimeMachine behavior, dispatch migration, or production behavior was added.

[Next] Proposed next slice:
- Architect review: decide whether proof coverage is sufficient to authorize compiler_profile_contract PROP authoring.
```
