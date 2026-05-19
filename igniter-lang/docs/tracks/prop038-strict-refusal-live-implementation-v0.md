# Track: PROP-038 Strict Refusal Live Implementation v0

Card: S3-R83-C2-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop038-strict-refusal-live-implementation-v0`
Route: UPDATE
Status: done
Date: 2026-05-19

---

## Goal

Implement the bounded internal-only PROP-038 strict-refusal live slice exactly
within the S3-R83-C1-A authorization boundary.

Launch condition satisfied:

- `igniter-lang/docs/gates/prop038-strict-refusal-live-implementation-authorization-review-v0.md`
  explicitly authorizes bounded internal-only implementation for
  `prop038-strict-refusal-live-implementation-v0`.

---

## Inputs Read

- `igniter-lang/docs/gates/prop038-strict-refusal-live-implementation-authorization-review-v0.md`
- `igniter-lang/docs/gates/prop038-strict-refusal-live-implementation-scope-decision-v0.md`
- `igniter-lang/docs/gates/prop038-strict-refusal-result-shape-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md`

Additional acceptance anchors inspected during implementation:

- `igniter-lang/docs/gates/prop038-contract-digest-live-validator-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb`
- `igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb`

---

## Changed Files

Code:

- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`

Proof:

- `igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/prop038_strict_refusal_live_implementation_proof.rb`
- `igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/out/prop038_strict_refusal_live_implementation_proof_summary.json`

The proof uses a transient `out/work/` directory while running preservation
cases, then removes it before writing the final summary. The only persisted
proof output is the summary JSON.

Track:

- `igniter-lang/docs/tracks/prop038-strict-refusal-live-implementation-v0.md`

No public API/CLI files were edited.

---

## Implementation Summary

`CompilerOrchestrator` now accepts an internal-only constructor seam:

```ruby
compiler_profile_contract_strict_requirement: nil
```

The seam is evaluated only after report-only PROP-038 validation has been
attached and only while the compilation report still has `pass_result == "ok"`.

Strict terminal behavior:

- no strict requirement or nil strict requirement: legacy/report-only behavior;
- valid strict requirement + valid contract: normal assembly success;
- valid strict requirement + `compiler_profile_contract.contract_digest_mismatch`:
  non-persisting `status: "refused"`;
- malformed strict requirement: non-persisting
  `status: "configuration_error"`;
- provider nil, non-Hash, or exception: no validation field and no refusal.

`CompilerResult.strict_terminal` creates the accepted non-persisting public
shape for `refused` and `configuration_error`.

---

## Public Result Key-Set Evidence

Both `refused` and `configuration_error` public results expose exactly:

```text
kind
format_version
status
program_id
source_path
source_hash
grammar_version
stages
igapp_path
contracts
compilation_report_path
diagnostics
warnings
```

Evidence from
`igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/out/prop038_strict_refusal_live_implementation_proof_summary.json`:

```text
public_terminal_keysets.refused == public_terminal_keysets.configuration_error
status=PASS checks=46 failed_checks=0
```

Raw validator diagnostics remain nested under
`compiler_profile_contract_validation`; public diagnostics expose only wrapper
codes:

- `compiler_profile_contract_refusal.contract_digest_mismatch`
- `compiler_profile_contract_refusal.strict_requirement_malformed`

---

## Non-Persisting Evidence

Strict terminal paths do not write report sidecars or `.igapp` output.

Observed strict `refused` evidence:

```json
{
  "report_path_key_present": false,
  "report_path_written": false,
  "igapp_written": false,
  "manifest_written": false
}
```

Observed strict `configuration_error` evidence:

```json
{
  "report_path_key_present": false,
  "report_path_written": false,
  "igapp_written": false,
  "manifest_written": false
}
```

The proof also guards that `CompilerOrchestrator#refusal` is not called for
strict terminal paths and that the assembler is not called before the terminal
return.

---

## Preservation Evidence

The live proof covers preservation of:

- no strict source and nil strict source report-only behavior;
- valid strict source + valid contract assembly success;
- validator-invalid/no-strict-authority report-only behavior;
- provider nil, non-Hash, and exception no-field/no-refusal behavior;
- parse error path;
- OOF path;
- assembler refusal path;
- runtime smoke failure path;
- internal compiler error path.

Ordinary failure preservation paths are exercised transiently inside the proof
run and summarized; their generated sidecars are not left persisted in the
experiment output.

The strict terminal report keeps:

- `report.pass_result == "ok"`;
- nested `compile_refusal_authorized: false` on validator evidence;
- nested `report_only: true`;
- unchanged top-level report diagnostics.

---

## Command Matrix

| Command | Result | Output |
| --- | --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` | PASS | `Syntax OK` |
| `ruby -c igniter-lang/lib/igniter_lang/compiler_result.rb` | PASS | `Syntax OK` |
| `ruby -c igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/prop038_strict_refusal_live_implementation_proof.rb` | PASS | `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/prop038_strict_refusal_live_implementation_proof.rb` | PASS | `PASS prop038_strict_refusal_live_implementation_proof` |
| `ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | PASS | `PASS compiler_profile_contract_proof` |
| `ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | PASS | `PASS prop038_contract_digest_shape_policy_proof` |
| `ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb` | PASS | `PASS prop038_contract_digest_recompute_match_proof` |
| `ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb` | PASS | `PASS prop038_contract_digest_report_only_integration_proof` |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS | `PASS prop038_report_only_compiler_integration` |
| `ruby igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb` | PASS | `PASS prop038_strict_mode_refusal_trigger_proof` |
| `ruby igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb` | PASS | `PASS prop038_strict_refusal_result_shape_proof` |

New proof summary:

```text
kind=prop038_strict_refusal_live_implementation_proof_summary
status=PASS
cases=16
checks=46
failed_checks=0
```

---

## Non-Authorizations Preserved

This card did not implement or edit:

- public API/CLI widening;
- `IgniterLang.compile` signature;
- env/config/manifest/loader/report/CompatibilityReport strict source;
- persisted reports or sidecars for strict terminal paths;
- `.igapp` mutation for strict terminal paths;
- parser, TypeChecker, SemanticIR, assembler, diagnostics centralization;
- `.ilk`, receipts, signing;
- dispatch migration;
- RuntimeMachine or Gate 3;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

---

## Recommendation

```text
ready for pressure review
```
