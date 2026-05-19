# Track: PROP-038 Strict-Mode Refusal Trigger Proof-Local v0

Card: S3-R77-C1-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop038-strict-mode-refusal-trigger-proof-local-v0`
Route: UPDATE
Status: done
Date: 2026-05-19

---

## Goal

Implement a proof-local strict-mode refusal trigger experiment using the
gate-controlled proof-local source accepted by S3-R76-C4-A, without changing
live compiler/orchestrator behavior.

Authority:

- `igniter-lang/docs/gates/prop038-strict-mode-refusal-trigger-design-decision-v0.md`

---

## Inputs Read

- `igniter-lang/docs/gates/prop038-strict-mode-refusal-trigger-design-decision-v0.md`
- `igniter-lang/docs/tracks/prop038-contract-digest-strict-mode-refusal-trigger-design-v0.md`
- `igniter-lang/docs/tracks/prop038-strict-mode-current-compiler-surface-survey-v0.md`
- `igniter-lang/docs/discussions/prop038-strict-mode-refusal-trigger-design-pressure-v0.md`
- `igniter-lang/docs/gates/prop038-contract-digest-live-validator-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md`

---

## Changed Files

Primary R77 artifacts:

- `igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb`
- `igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/out/prop038_strict_mode_refusal_trigger_proof_summary.json`
- `igniter-lang/docs/tracks/prop038-strict-mode-refusal-trigger-proof-local-v0.md`

Verification-rerun artifact:

- `igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json`

The verification artifact was refreshed by the required R67 command rerun. The
only observed semantic delta is that the existing invalid-contract case now
records live validator `compiler_profile_contract.contract_digest_mismatch`
alongside `compiler_profile_contract.wrong_kind`, matching the accepted R74 live
validator behavior. No R67 code was edited.

No files under `igniter-lang/lib` were edited for this card.

---

## Proof-Local Model

Created proof-local source shape:

```json
{
  "kind": "compiler_profile_contract_strict_requirement",
  "format_version": "0.1.0",
  "mode": "strict_contract_digest",
  "source": "proof_local_gate",
  "refusal_candidates": [
    "compiler_profile_contract.contract_digest_mismatch"
  ],
  "recompute_unavailable_policy": "fail_open_report_only",
  "compile_refusal_authorized": false
}
```

Decision vocabulary modeled:

- `not_evaluated`;
- `allow`;
- `would_refuse`;
- `configuration_error`.

Wrapper vocabulary modeled proof-locally only:

```text
compiler_profile_contract_refusal.contract_digest_mismatch
```

Wrapper evidence cites:

```text
compiler_profile_contract.contract_digest_mismatch
```

No live compiler refusal is produced.

---

## Implementation Notes

The experiment consumes live:

```ruby
IgniterLang::CompilerProfileContractValidator.validate(...)
```

The trigger evaluator is proof-local wrapper code inside:

```text
igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/
```

Evaluation rules:

- no strict source => `not_evaluated`;
- strict proof-local source + valid contract => `allow`;
- strict proof-local source + `contract_digest_mismatch` => `would_refuse`;
- strict proof-local source + `contract_digest_invalid` => `allow` as held
  control behavior;
- strict proof-local source + unsupported policy =>
  `configuration_error`;
- strict proof-local source + `contract_digest_recompute_unavailable` =>
  fail-open `allow` with report-only evidence retained;
- nil, non-Hash, provider-error, and validator-error paths produce no validation
  field and `not_evaluated`.

Report-only compile/result behavior is modeled as unchanged for every case.

---

## Proof Matrix

Observed summary:

```text
kind=prop038_strict_mode_refusal_trigger_proof_summary
status=PASS
cases=12
checks=15
failed=0
```

Cases:

| Case | Decision | Result |
| --- | --- | --- |
| `report_only_valid_contract` | `not_evaluated` | PASS |
| `report_only_digest_mismatch_nested_only` | `not_evaluated` | PASS |
| `no_strict_source_not_evaluated` | `not_evaluated` | PASS |
| `strict_source_valid_contract_allow` | `allow` | PASS |
| `strict_source_digest_mismatch_would_refuse` | `would_refuse` | PASS |
| `strict_source_invalid_digest_held_control` | `allow` | PASS |
| `strict_source_unsupported_policy_configuration_error` | `configuration_error` | PASS |
| `strict_source_recompute_unavailable_fail_open` | `allow` | PASS |
| `nil_provider_no_field_no_refusal` | `not_evaluated` | PASS |
| `non_hash_provider_no_field_no_refusal` | `not_evaluated` | PASS |
| `provider_error_no_field_no_refusal` | `not_evaluated` | PASS |
| `validator_error_no_field_no_refusal` | `not_evaluated` | PASS |

Boundary checks pass:

- top-level diagnostics unchanged;
- public result unchanged;
- `CompilerResult` unchanged;
- `.igapp` not mutated;
- loader/report untouched;
- CompatibilityReport untouched;
- runtime untouched;
- production untouched;
- wrapper codes appear only in proof-local trigger evaluation.

---

## Command Matrix

| Command | Result | Output |
| --- | --- | --- |
| `ruby -c igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb` | PASS | `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb` | PASS | `PASS prop038_strict_mode_refusal_trigger_proof` |
| `ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | PASS | `PASS compiler_profile_contract_proof` |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS | `PASS prop038_report_only_compiler_integration` |

Regression summaries after rerun:

```text
compiler_profile_contract_proof_summary.json
  status=PASS cases=13 checks=30 failed=0

prop038_report_only_compiler_integration_summary.json
  status=PASS cases=5 checks=20 failed=0
```

---

## Non-Authorizations Preserved

This proof did not create:

- edits under `igniter-lang/lib`;
- live compiler/orchestrator behavior changes;
- live compile refusal;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted reports or sidecars outside proof-local experiment output;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation;
- loader/report behavior;
- CompatibilityReport behavior;
- diagnostics centralization;
- RuntimeMachine or Gate 3 behavior;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

---

## Recommendation

```text
C3-A: accept
```

Reason:

- the proof-local strict source model is implemented inside the authorized
  experiment boundary;
- only `contract_digest_mismatch` maps to proof-local `would_refuse`;
- invalid digest, unsupported policy, recompute unavailable, and legacy paths do
  not become refusal;
- required regression commands pass;
- live compiler behavior remains report-only/no-refusal.
