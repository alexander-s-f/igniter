# Track: PROP-038 Library Validator Extraction Implementation v0

Card: S3-R65-C1-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop038-library-validator-extraction-implementation-v0`
Route: UPDATE
Status: done
Date: 2026-05-17

---

## Goal

Implement the bounded Option B internal PROP-038 library validator extraction
with proof parity only.

Authority:

- `igniter-lang/docs/gates/prop038-library-validator-extraction-design-decision-v0.md`

Authorized behavior mode:

```text
internal library validator, non-integrated, non-refusal, proof-parity only
```

---

## Scope Kept

Edited only:

- `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `igniter-lang/docs/tracks/prop038-library-validator-extraction-implementation-v0.md`

No top-level require was added to:

```text
igniter-lang/lib/igniter_lang.rb
```

No production compiler behavior changed.

No changes were made to parser, TypeChecker, SemanticIR, assembler, `.igapp`,
CLI/API, loader/report, CompatibilityReport, dispatch, RuntimeMachine, Gate 3,
Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

---

## Implementation

Created:

```text
IgniterLang::CompilerProfileContractValidator
```

Public API:

```ruby
validate(contract, digest_reference_policy: :prop038_24_plus)
```

The validator:

- accepts an already-materialized contract Hash;
- returns a string-key validation result Hash;
- keeps diagnostics local to the validator;
- validates descriptor digest shape only;
- keeps `contract_digest` format/mismatch validation deferred;
- does not read paths;
- does not discover, default, finalize, or load profiles;
- does not integrate with compiler reports or orchestrator behavior;
- does not raise compile refusal.

Return shape:

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

Only `validate` is public on the module. Helper methods remain private.

---

## Proof Update

Updated the existing proof script to call:

```ruby
IgniterLang::CompilerProfileContractValidator.validate(contract)
```

Moved proof-local validation constants/helpers/logic into the validator:

- required/optional/all slot constants;
- `compiler_profile_contract.*` diagnostic construction;
- ordered-rule cycle detection;
- proof-parity validation logic.

Kept proof-local-only material in the experiment:

- contract construction;
- source projection checks;
- proof case matrix;
- summary writing;
- vocabulary separation assertions;
- future `profile_not_supplied` design artifact;
- execution-order/disclaimer assertions.

---

## Proof Summary

Updated:

```text
igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json
```

Observed summary state:

```text
track=prop038-library-validator-extraction-implementation-v0
extends_track=prop038-proof-local-missing-after-implementation-v0
status=PASS
cases=13
matrix=13
checks=27
validator_kind=compiler_profile_contract_validation_result
policy=prop038_24_plus
compiler_integrated=false
compile_refusal_authorized=false
```

The 13-case proof matrix is preserved:

- `valid_contract`
- `missing_required_slot`
- `duplicate_strict_key`
- `duplicate_fragment_class_owner`
- `rule_cycle`
- `missing_rule_reference`
- `missing_after_rule_reference`
- `wrong_kind`
- `unsupported_format_version`
- `descriptor_digest_invalid`
- `finalization_payload_digest_invalid`
- `runtime_authority_forbidden`
- `dispatch_migration_forbidden`

The summary now machine-records the validator result shape and false integration
flags.

Note:

- `contract_digest` format/mismatch validation remains intentionally deferred.
- `unknown_owner_slot` and `unknown_rule_owner_slot` were not extracted into the
  library validator because the R65 authority explicitly disallowed adding those
  currently unproven diagnostics to this implementation.

---

## Command Matrix

| Command | Result | Output |
| --- | --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb` | PASS | `Syntax OK` |
| `ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | PASS | `Syntax OK` |
| `ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | PASS | `PASS compiler_profile_contract_proof` |

Additional API surface check:

```text
validate_public=true
diagnostic_public=false
result_public=false
cycle_public=false
```

---

## Non-Authorizations Preserved

This implementation did not create:

- compiler integration;
- report-only compiler behavior;
- compile refusal;
- public API or CLI widening;
- path loading or inline JSON parsing;
- descriptor digest recomputation;
- `contract_digest` validation;
- centralized diagnostics in `IgniterLang::Diagnostics`;
- `.igapp`, loader/report, CompatibilityReport, receipt, `.ilk`, signing, or
  sidecar output;
- dispatch, RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP,
  cache, or production behavior.

---

## Recommendation

```text
next route: accept extraction
```

Reason:

- bounded Option B was implemented inside the authorized files;
- required command matrix is PASS;
- proof summary remains PASS with 13 cases;
- the validator exposes only `validate`;
- false integration/refusal flags are machine-recorded;
- held surfaces remain held.

Do not open report-only compiler integration yet. If the next lane wants that,
it should be a separate design card for contract input ownership, report/output
location, descriptor digest canonicalization, fixture/golden policy, and
orchestrator insertion point.

---

## Handoff

```text
Card: S3-R65-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop038-library-validator-extraction-implementation-v0
Status: done

[D] Decisions
- Extracted the proof-local validator into
  IgniterLang::CompilerProfileContractValidator.
- Exposed only `validate`.
- Kept diagnostics local to the validator.
- Kept descriptor digest as shape-only validation.
- Deferred contract_digest validation exactly as authorized.
- Did not add top-level facade require or compiler integration.

[S] Shipped
- New internal validator file.
- Proof script now calls the validator.
- Proof summary regenerated with validator result shape and false
  integration/refusal flags.
- Track document added.

[T] Tests / Proofs
- PASS ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
- PASS ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
- PASS ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb

[R] Recommendation
- Accept extraction.
- Hold report-only compiler integration for a separate design/authorization
  route.
```
