# PROP-038 Strict Refusal Result Shape Proof Local v0

Card: S3-R81-C1-P1  
Agent: [Igniter-Lang Research Agent]  
Role: research-agent  
Status: done  
Date: 2026-05-19  
Authority ref: `igniter-lang/docs/gates/prop038-strict-refusal-result-shape-decision-v0.md`

## Neighbor Roles

Affected neighbor roles:

- Compiler/Grammar Expert: future implementation may request compiler/result boundary changes, but this card does not.
- Bridge Agent: future public API/CLI exposure and integration language may reference this proof, but no bridge behavior is authorized here.

## Current Horizon

- PROP-038 digest validation remains report-only in live compiler behavior.
- R80 accepted a future strict-refusal target shape and a malformed strict-requirement `configuration_error` shape.
- This card proves those shapes locally without changing `CompilerOrchestrator`, `CompilerResult`, CLI/API, reports, assembler, or runtime behavior.
- Public diagnostics carry wrapper evidence only; raw validator diagnostics stay nested.
- The non-persisting strict path writes no `.igapp`, sidecar, refusal report, or compilation report path.

## Proof

New proof:

```text
igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb
```

Summary:

```text
igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/out/prop038_strict_refusal_result_shape_proof_summary.json
```

The proof models two future target result shapes and one anchor-reference case:

| Case | Expected status | Key assertion |
| --- | --- | --- |
| `strict_refusal_contract_digest_mismatch` | `refused` | Public result uses only wrapper diagnostic `compiler_profile_contract_refusal.contract_digest_mismatch`; raw `compiler_profile_contract.contract_digest_mismatch` stays nested under `report.compiler_profile_contract_validation`. |
| `malformed_strict_requirement_configuration_error` | `configuration_error` | Malformed strict requirement is distinct from validator failure and uses `compiler_profile_contract_refusal.strict_requirement_malformed`. |
| `legacy_report_only_anchors_referenced` | anchor PASS | Existing report-only and strict-trigger anchors remain referenced and not contradicted. |

Public key allowlist proven exactly:

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

The proof also asserts:

- `compilation_report_path` is present and `null`.
- `igapp_path` is `null`.
- `contracts` is empty.
- assembly is `skipped`.
- `report.pass_result` remains `ok` in the internal modeled report.
- top-level report diagnostics remain unchanged unless wrapper diagnostics are explicitly modeled.
- no modeled produced path ends in `.compilation_report.json`.
- no modeled produced path contains `.igapp`.
- live compiler/orchestrator, `CompilerResult`, public API/CLI, assembler, diagnostics centralization, loader/report, CompatibilityReport, RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, and production behavior remain closed.

## Anchor Handling

This card references existing proof summaries rather than rerunning every upstream proof:

- `experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `experiments/prop038_contract_digest_shape_policy_proof/out/prop038_contract_digest_shape_policy_proof_summary.json`
- `experiments/prop038_contract_digest_recompute_match_proof/out/prop038_contract_digest_recompute_match_proof_summary.json`
- `experiments/prop038_contract_digest_report_only_integration_proof/out/prop038_contract_digest_report_only_integration_proof_summary.json`
- `experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json`
- `experiments/prop038_strict_mode_refusal_trigger_proof/out/prop038_strict_mode_refusal_trigger_proof_summary.json`

The R81 proof checks those anchors are `PASS` and specifically preserves the report-only/non-persisting expectations from R67, R71, and R77.

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb` | PASS: `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb` | PASS: 3 cases, 44 checks, 0 failed checks |

Exact proof output:

```text
PASS prop038_strict_refusal_result_shape_proof
cases: 3
checks: 44
failed_checks: 0
public_keys: kind,format_version,status,program_id,source_path,source_hash,grammar_version,stages,igapp_path,contracts,compilation_report_path,diagnostics,warnings
diagnostic_codes: compiler_profile_contract_refusal.contract_digest_mismatch,compiler_profile_contract_refusal.strict_requirement_malformed
summary: experiments/prop038_strict_refusal_result_shape_proof/out/prop038_strict_refusal_result_shape_proof_summary.json
```

## Recommendation

Recommendation for C3-A: accept proof-local closure.

This proof is suitable as implementation evidence for the target result shape only. It does not authorize live strict refusal, live compiler/orchestrator mutation, public API/CLI widening, persisted reports, `.igapp` changes, loader/report integration, CompatibilityReport changes, RuntimeMachine behavior, or production behavior.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: prop038-strict-refusal-result-shape-proof-local-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Modeled strict digest mismatch as public `status: refused` with wrapper diagnostic only.
- Modeled malformed strict requirement as public `status: configuration_error`.
- Kept raw validator diagnostics nested under internal `report.compiler_profile_contract_validation`.
- Kept `compilation_report_path` present and null for the non-persisting target shape.

[R] Recommendations:
- Accept proof-local closure for C3-A.
- Future implementation authorization should name exact write scopes for `CompilerResult`, `CompilerOrchestrator`, report persistence, CLI/API exposure, and proof regressions separately.

[S] Signals:
- Public key allowlist is exact and stable in the proof summary.
- Existing report-only anchors are referenced as PASS and not contradicted.
- No `.igapp`, sidecar, refusal report, loader/report, CompatibilityReport, runtime, or production behavior is modeled as live.

[T] Tests / Proofs:
- PASS `ruby -c igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb`
- PASS `ruby igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb`

[Files] Changed:
- igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb
- igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/out/prop038_strict_refusal_result_shape_proof_summary.json
- igniter-lang/docs/tracks/prop038-strict-refusal-result-shape-proof-local-v0.md

[Q] Open Questions:
- Should future live implementation keep `report.pass_result: ok` internally for all strict refusals, or only for digest-validation refusal paths?
- Should public `status: configuration_error` share the same allowlist permanently, or receive a smaller config-error-specific public surface?

[X] Rejected:
- No live compiler/orchestrator edits.
- No live compile refusal.
- No `CompilerResult` code changes.
- No public API/CLI widening.
- No persisted reports, sidecars, `.igapp`, loader/report, CompatibilityReport, RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

[Next] Proposed next slice:
- Implementation-gated strict-refusal boundary review, with explicit write scopes and regression assertions for public key-set, nested diagnostic isolation, and non-persisting report behavior.
```
