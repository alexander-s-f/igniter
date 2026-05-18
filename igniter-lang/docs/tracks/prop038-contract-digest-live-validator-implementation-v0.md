# Track: PROP-038 Contract Digest Live Validator Implementation v0

Card: S3-R74-C1-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop038-contract-digest-live-validator-implementation-v0`
Route: UPDATE
Status: done
Date: 2026-05-18

---

## Goal

Implement all four accepted PROP-038 `contract_digest` diagnostics inside
`IgniterLang::CompilerProfileContractValidator` only, with proof parity and
report-only/no-refusal invariants preserved.

Authority:

- `igniter-lang/docs/gates/prop038-contract-digest-live-implementation-design-decision-v0.md`

---

## Inputs Read

- `igniter-lang/docs/gates/prop038-contract-digest-live-implementation-design-decision-v0.md`
- `igniter-lang/docs/tracks/prop038-contract-digest-live-implementation-design-v0.md`
- `igniter-lang/docs/tracks/prop038-contract-digest-live-implementation-surface-survey-v0.md`
- `igniter-lang/docs/discussions/prop038-contract-digest-live-implementation-design-pressure-v0.md`
- `igniter-lang/docs/gates/prop038-contract-digest-errata-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md`
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`

---

## Files Changed

Edited only authorized files:

- `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb`
- `igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb`
- `igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/out/prop038_contract_digest_shape_policy_proof_summary.json`
- `igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb`
- `igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/out/prop038_contract_digest_recompute_match_proof_summary.json`
- `igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb`
- `igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/out/prop038_contract_digest_report_only_integration_proof_summary.json`
- `igniter-lang/docs/tracks/prop038-contract-digest-live-validator-implementation-v0.md`

No compiler/orchestrator, public API/CLI, `CompilerResult`, assembler,
loader/report, CompatibilityReport, runtime, or production files were edited.

---

## Implementation

Implemented inside `IgniterLang::CompilerProfileContractValidator`:

- `contract_digest` shape validation:
  `compiler_profile_contract/sha256:<24+ lowercase hex>`;
- exactly `digest_reference_policy: :prop038_24_plus`;
- canonical contract digest recomputation under R70/R72 rules;
- declared digest prefix comparison against recomputed full SHA-256 hex;
- four accepted diagnostics:
  - `compiler_profile_contract.contract_digest_invalid`;
  - `compiler_profile_contract.contract_digest_policy_unsupported`;
  - `compiler_profile_contract.contract_digest_mismatch`;
  - `compiler_profile_contract.contract_digest_recompute_unavailable`.

Added Ruby stdlib requires only:

```ruby
require "digest"
require "json"
```

Kept unchanged:

- validator API: `validate(contract, digest_reference_policy: :prop038_24_plus)`;
- validator result top-level fields;
- `compiler_integrated=false`;
- `compile_refusal_authorized=false`;
- diagnostics local to the validator;
- canonicalization helpers private.

Recompute behavior:

- skipped when policy is unsupported;
- skipped when `contract_digest` shape is invalid;
- runs even when unrelated structural diagnostics exist;
- emits `contract_digest_recompute_unavailable` if canonicalization cannot run.

Mutation safety:

- proof guards assert validator input contracts are not mutated.

---

## Proof Updates

Base contract proof:

- canonical contract builder now uses R70/R72 canonical digest material;
- existing 13-case validator matrix remains PASS;
- result-shape guard confirms no new top-level validator fields;
- mutation guards confirm no caller contract mutation.

Shape-policy proof:

- now calls the live validator directly;
- covers all 8 shape-policy cases;
- valid short/full cases use recomputed canonical digest prefix/full reference.

Recompute-match proof:

- now calls the live validator for full/prefix match, mismatch, and unavailable
  cases;
- retains canonicalization sensitivity checks against proof-local expected
  material.

Report-only integration proof:

- now uses live validator results;
- adds `report_only` only in the proof-local report annotation;
- preserves nested-only diagnostics and no-outcome-change invariants.

---

## Proof Summary

Observed generated summary state:

```text
compiler_profile_contract_proof_summary.json
  status=PASS cases=13 checks=30 failed=0

prop038_contract_digest_shape_policy_proof_summary.json
  status=PASS cases=8 checks=20 failed=0

prop038_contract_digest_recompute_match_proof_summary.json
  status=PASS cases=14 checks=16 failed=0

prop038_contract_digest_report_only_integration_proof_summary.json
  status=PASS cases=12 checks=21 failed=0
```

Validator result keys remain exactly:

```text
compile_refusal_authorized
compiler_integrated
diagnostic_codes
diagnostics
digest_reference_policy
format_version
kind
valid
```

Digest diagnostic coverage:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

Report-only invariants recorded true:

- digest diagnostics nested under
  `compiler_profile_contract_validation.diagnostics`;
- top-level `report["diagnostics"]` unchanged;
- `pass_result` unchanged;
- stages unchanged;
- compile status remains `ok` when source compiles;
- public result unchanged;
- assembler execution unchanged;
- `.igapp` manifest unchanged;
- refusal report not written.

---

## Command Matrix

| Command | Result | Output |
| --- | --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb` | PASS | `Syntax OK` |
| `ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | PASS | `Syntax OK` |
| `ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | PASS | `PASS compiler_profile_contract_proof` |
| `ruby -c igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | PASS | `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | PASS | `PASS prop038_contract_digest_shape_policy_proof` |
| `ruby -c igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb` | PASS | `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb` | PASS | `PASS prop038_contract_digest_recompute_match_proof` |
| `ruby -c igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb` | PASS | `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb` | PASS | `PASS prop038_contract_digest_report_only_integration_proof` |

---

## Non-Authorizations Preserved

This implementation did not create:

- compiler/orchestrator integration changes;
- compile refusal;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted success reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation;
- loader/report or CompatibilityReport behavior;
- diagnostics centralization in `IgniterLang::Diagnostics`;
- dispatch migration;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

---

## Recommendation

```text
accept
```

Reason:

- the one-slice internal validator implementation is complete within the
  authorized write scope;
- all four accepted `contract_digest_*` diagnostics are live in the validator;
- required proof matrix passes;
- validator API/result shape, report-only placement, and no-refusal invariants
  are preserved.
