# Track: PROP-038 Library Validator Extraction Design v0

Card: S3-R64-C1-P1
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop038-library-validator-extraction-design-v0`
Route: UPDATE
Status: done
Date: 2026-05-17

---

## Goal

Design the Option B library validator extraction boundary for PROP-038 without
implementing code.

This track does not authorize or perform implementation. It prepares an exact
future boundary for an internal validator such as:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
```

---

## Inputs Read

- `igniter-lang/docs/gates/prop038-proof-local-missing-after-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/prop038-compiler-profile-contract-implementation-authorization-decision-v0.md`
- `igniter-lang/docs/tracks/prop038-proof-local-missing-after-implementation-v0.md`
- `igniter-lang/docs/discussions/prop038-proof-local-missing-after-pressure-v0.md`
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`

---

## Inspection Commands

```text
rg -n "module IgniterLang|class .*Validator|validate_|diagnostic|Diagnostics|CompilerResult|CompilationReport|compiler_profile_source|AssemblyRefused|Result|Struct|Data.define|Value" igniter-lang/lib/igniter_lang
```

Result:

- no existing `CompilerProfileContractValidator`;
- current compiler diagnostics are centralized for compiler report categories in
  `IgniterLang::Diagnostics`;
- assembler owns `compiler_profile_source.*` validation and refusal;
- orchestrator only transports `compiler_profile_source` into assembler;
- no current production path accepts `compiler_profile_contract`.

```text
rg --files igniter-lang/lib/igniter_lang | sort
```

Result:

- likely future library file location confirmed:
  `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`;
- no `igniter-lang/spec` directory exists in this workspace.

Files inspected after `rg`:

- `igniter-lang/lib/igniter_lang/diagnostics.rb`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`
- `igniter-lang/lib/igniter_lang/compilation_report.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/assembler.rb`
- `igniter-lang/lib/igniter_lang.rb`

No code was edited.

---

## Current Evidence

R63 acceptance closes proof-local Option A:

```text
missing-after missing_rule_reference coverage: closed
```

Current proof summary:

```text
track=prop038-proof-local-missing-after-implementation-v0
extends_track=compiler-profile-contract-validator-coverage-proof-v0
status=PASS
cases=13
checks=23
```

Covered proof-local cases:

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

---

## Design Decision

```text
Option B should be an internal, non-integrated, non-refusal library validator.
```

Meaning:

- it validates a caller-supplied `compiler_profile_contract` Hash;
- it returns a validation result object;
- it does not read files;
- it does not build or finalize contracts;
- it does not project `compiler_profile_id_source`;
- it does not call the compiler, orchestrator, assembler, or report layer;
- it does not write `.igapp`, reports, receipts, `.ilk`, sidecars, or goldens;
- invalid contracts do not refuse compilation.

---

## Proposed Future API Shape

Recommended module:

```ruby
module IgniterLang
  module CompilerProfileContractValidator
    module_function

    def validate(contract, digest_reference_policy: :prop038_24_plus)
      # returns string-key Hash
    end
  end
end
```

Recommended return shape:

```json
{
  "kind": "compiler_profile_contract_validation_result",
  "format_version": "0.1.0",
  "valid": false,
  "diagnostics": [
    {
      "code": "compiler_profile_contract.missing_rule_reference",
      "message": "ordered rule parse.contract_modifiers references missing rule \"parse.nonexistent_rule\"",
      "path": "ordered_rule_graph.rules.parse.contract_modifiers"
    }
  ],
  "diagnostic_codes": [
    "compiler_profile_contract.missing_rule_reference"
  ],
  "digest_reference_policy": "prop038_24_plus",
  "compiler_integrated": false,
  "compile_refusal_authorized": false
}
```

Rationale:

- string-key Hashes match existing compiler/proof artifacts;
- no new public class is needed;
- no exception is raised for invalid contracts;
- result shape is explicit that the validator is not integrated and not
  refusal-capable.

Recommended loading:

```ruby
require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"
```

from proof/spec code only.

Do not add a top-level `require_relative` in `igniter-lang/lib/igniter_lang.rb`
for the first extraction. That avoids implying public facade support.

---

## Validation Scope For Option B

The first extraction should be proof-parity only.

Move from the proof script into the library validator:

- `REQUIRED_SLOTS`
- `OPTIONAL_SLOTS`
- `ALL_SLOTS`
- diagnostic construction for `compiler_profile_contract.*`
- ordered-rule cycle detection;
- contract validation logic currently represented by `validate_contract`.

Keep in the proof script:

- `build_contract`;
- source projection checks;
- proof case construction;
- summary writing;
- proof-only separation assertions;
- `future_profile_not_supplied` design artifact;
- execution-order/disclaimer proof material.

Do not add new validation rules in the extraction unless a gate updates the
diagnostic vocabulary.

Specifically, do not introduce new diagnostics for:

- duplicate `rule_id`;
- contract digest mismatch;
- malformed top-level object beyond existing `wrong_kind` handling;
- unknown `stage`;
- missing optional slots.

Those may be valid future questions, but they are outside proof-parity Option B.

---

## Digest And Canonicalization Design

### Descriptor Digest Input Material

Decision for Option B:

```text
Do not recompute descriptor_digest in the first library validator.
```

Reason:

- the validator receives only a contract object;
- the canonical descriptor material is not present in that object;
- loading, discovering, inferring, or finalizing descriptor material would exceed
  Option B and risk public/profile discovery behavior.

Option B should validate only the reference shape already proven:

```text
compiler_profile_descriptor/sha256:<24+ lowercase hex>
```

Required later before any descriptor digest recomputation:

- exact descriptor object/material;
- canonical serialization;
- whether the digest excludes any digest field;
- caller ownership of descriptor material;
- diagnostic code for digest mismatch if needed.

### Contract Digest

PROP-038 defines `contract_digest` as computed over canonicalized contract
material excluding `contract_digest` itself. The current proof builds the digest
that way, but the proof validator does not diagnose `contract_digest` mismatch.

Decision for Option B:

```text
Keep proof parity and do not add contract_digest mismatch validation unless C3-A
explicitly authorizes a diagnostic vocabulary addition.
```

If C3-A wants contract-digest validation in the library extraction, it must
also authorize:

- a diagnostic code such as `compiler_profile_contract.contract_digest_invalid`
  or `compiler_profile_contract.contract_digest_mismatch`;
- exact canonicalization rules;
- whether short digest references may match by prefix or require exact emitted
  reference equality.

Recommended canonicalization if later authorized:

```text
normalize Hash keys by string form, recursively normalize arrays and hashes,
then JSON.generate(normalized_material) with no pretty spacing.
```

This matches the proof helper and the current assembler canonical hashing style.

### Short-Vs-Full Digest Policy

Decision for Option B:

```text
Default policy: :prop038_24_plus
```

Meaning:

- `descriptor_digest` accepts 24+ lowercase hex references;
- `contract_digest`, if shape-checked later, accepts 24+ lowercase hex
  references;
- `finalization_payload_digest` remains full 64-character SHA-256.

Do not use full-64-only policy in Option B because no durable, persisted,
report, receipt, `.ilk`, `.igapp`, loader/report, or production-facing output is
being created.

---

## Diagnostic Placement

Decision:

```text
Keep compiler_profile_contract.* diagnostic construction local to
CompilerProfileContractValidator.
```

Do not centralize in `IgniterLang::Diagnostics` for Option B.

Reason:

- `IgniterLang::Diagnostics` currently enriches compiler diagnostics with
  compiler report categories such as parser/classifier/typechecker/assembler;
- moving contract diagnostics there would imply report-layer ownership;
- Option B is internal object validation, not compiler report integration.

The validator may have a private/module-local helper:

```ruby
def diagnostic(code, message, path = nil)
  {
    "code" => "compiler_profile_contract.#{code}",
    "message" => message,
    "path" => path
  }
end
```

---

## Contract Object Input Ownership

Decision:

```text
The caller owns the contract object.
```

Option B validator accepts an already-materialized Hash and validates it. It
must not:

- read JSON paths;
- parse inline JSON;
- discover default profiles;
- finalize descriptors;
- derive a contract from `compiler_profile_source`;
- derive `compiler_profile_source` from a contract;
- call `IgniterLang.compile`;
- widen CLI or Ruby facade inputs.

For first implementation proof, the existing experiment remains the caller and
continues to build proof-local contract objects.

---

## Proof-Local Parity Requirements

A future implementation must prove:

```text
same 13 cases
same expected diagnostic codes
same PASS status
same non-authorization flags
```

Required parity matrix:

| Case | Expected |
| --- | --- |
| `valid_contract` | valid |
| `missing_required_slot` | `compiler_profile_contract.missing_required_slot` |
| `duplicate_strict_key` | `compiler_profile_contract.duplicate_strict_key` |
| `duplicate_fragment_class_owner` | `compiler_profile_contract.duplicate_strict_key` |
| `rule_cycle` | `compiler_profile_contract.rule_cycle` |
| `missing_rule_reference` | `compiler_profile_contract.missing_rule_reference` |
| `missing_after_rule_reference` | `compiler_profile_contract.missing_rule_reference` |
| `wrong_kind` | `compiler_profile_contract.wrong_kind` |
| `unsupported_format_version` | `compiler_profile_contract.unsupported_format_version` |
| `descriptor_digest_invalid` | `compiler_profile_contract.descriptor_digest_invalid` |
| `finalization_payload_digest_invalid` | `compiler_profile_contract.finalization_payload_digest_invalid` |
| `runtime_authority_forbidden` | `compiler_profile_contract.runtime_authority_forbidden` |
| `dispatch_migration_forbidden` | `compiler_profile_contract.dispatch_migration_forbidden` |

The proof script should switch from local `validate_contract` to the library
validator and keep the summary under the same experiment `out/` directory.

---

## Fixture / Spec Policy

For first implementation:

```text
experiment parity proof only
```

Authorized future files should be:

- `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `igniter-lang/docs/tracks/<future-implementation-track>.md`

Do not create production spec fixtures or golden migrations unless C3-A expands
the boundary. The current workspace has no `igniter-lang/spec` directory.

---

## Exact Future Write Boundary

Recommended implementation card scope:

```text
Edit only:
- igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
- igniter-lang/experiments/compiler_profile_contract_proof/
- igniter-lang/docs/tracks/<future-track>.md
```

Implementation should:

- extract validator constants and `validate` behavior from the proof script;
- preserve current diagnostic codes and paths;
- preserve proof-local 24+ digest reference acceptance;
- preserve the 13-case matrix and 23-check PASS proof;
- keep the validator internal and non-integrated;
- avoid requiring the validator from the public Ruby facade;
- avoid `CompilerOrchestrator`, `CompilationReport`, `CompilerResult`,
  `IgniterLang::Diagnostics`, assembler, CLI/API, `.igapp`, loader/report,
  CompatibilityReport, RuntimeMachine, runtime, or production behavior.

---

## Blockers Before Library Validator Authorization

[B1] C3-A must explicitly authorize creating
`igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`.

[B2] C3-A must choose proof-parity extraction or expand diagnostics. If expanded,
new diagnostic codes are required for any new validation behavior.

[B3] C3-A must accept descriptor digest behavior for Option B:
shape validation only, no descriptor material recomputation.

[B4] C3-A must accept `:prop038_24_plus` as the library validator digest
reference policy for non-persisted internal validation.

[B5] C3-A must confirm diagnostics remain local to the validator and are not
centralized in `IgniterLang::Diagnostics`.

[B6] C3-A must confirm the caller supplies an already-materialized contract Hash
and that no path loading, finalization, discovery, or public input widening is
authorized.

[B7] C3-A must confirm the proof parity requirement: same 13 cases, same
diagnostic codes, same non-authorization guarantees.

[B8] C3-A must confirm no compiler integration and no compile refusal.

---

## Hold Reasons If C3-A Wants More Than Option B

Hold implementation if C3-A requires any of the following in the same slice:

- report-only compiler integration;
- compile refusal;
- public API or CLI contract input;
- descriptor digest recomputation from external material;
- full-64-only digest references;
- new diagnostic vocabulary;
- `CompilationReport` or `CompilerResult` output;
- `IgniterLang::Diagnostics` centralization;
- `.igapp`, receipt, `.ilk`, sidecar, loader/report, or CompatibilityReport
  output;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.

Those require separate design and authorization.

---

## Recommendation For C3-A

```text
authorize bounded Option B implementation: internal library validator extraction
```

Recommended C3-A boundary:

- proof-parity only;
- internal module only;
- no public facade or CLI require;
- no report-only compiler integration;
- no compile refusal;
- no new diagnostic vocabulary;
- descriptor digest shape validation only;
- `:prop038_24_plus` digest reference policy;
- experiment summary remains the only output.

If C3-A is not comfortable with shape-only descriptor digest behavior or with
deferring contract-digest mismatch diagnostics, then hold implementation and
open a narrower digest-diagnostic design card first.

---

## Handoff

```text
Card: S3-R64-C1-P1
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop038-library-validator-extraction-design-v0
Status: done

[D] Decisions
- Option B should be internal, non-integrated, and non-refusal.
- Validator API should be module_function `validate(contract,
  digest_reference_policy: :prop038_24_plus)`.
- Result should be a string-key validation hash, not an exception/refusal.
- Descriptor digest recomputation should remain out of scope for first library
  extraction.
- Diagnostics should stay local to the validator, not `IgniterLang::Diagnostics`.

[S] Signals
- Proof-local Option A is closed with 13 cases / 23 checks PASS.
- Current compiler has no `compiler_profile_contract` input.
- `IgniterLang::Diagnostics` is report-category oriented and should not own
  contract diagnostics yet.

[T] Tests / Proofs
- Design-only track.
- `rg` inspection completed.
- No test suite run because no code was changed.

[R] Recommendation
- C3-A should authorize bounded Option B library validator extraction with
  proof-parity only.
- Hold if C3-A wants digest recomputation, new diagnostics, compiler
  integration, or compile refusal in the same slice.
```
