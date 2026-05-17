# Track: PROP-038 Report-Only Compiler Integration Implementation v0

Card: S3-R67-C1-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop038-report-only-compiler-integration-implementation-v0`
Route: UPDATE
Status: done
Date: 2026-05-17

---

## Goal

Implement Candidate A only:

```text
internal provider plus in-memory CompilationReport annotation
```

for PROP-038 compiler profile contract validation, report-only and never
refusal.

Authority:

- `igniter-lang/docs/gates/prop038-report-only-compiler-integration-design-decision-v0.md`

---

## Inputs Read

- `igniter-lang/docs/gates/prop038-report-only-compiler-integration-design-decision-v0.md`
- `igniter-lang/docs/tracks/prop038-report-only-compiler-integration-design-v0.md`
- `igniter-lang/docs/discussions/prop038-report-only-compiler-integration-design-pressure-v0.md`
- `igniter-lang/docs/gates/prop038-library-validator-extraction-acceptance-decision-v0.md`
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `igniter-lang/docs/tracks/stage3-round66-status-curation-v0.md`
- `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/compilation_report.rb`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`

---

## Files Changed

Edited only:

- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/compilation_report.rb`
- `igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb`
- `igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json`
- `igniter-lang/docs/tracks/prop038-report-only-compiler-integration-implementation-v0.md`

No changes were made to:

- `igniter-lang/lib/igniter_lang.rb`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`

---

## Implementation

`CompilerOrchestrator` now accepts an internal constructor injection:

```ruby
compiler_profile_contract_provider: nil
```

Provider contract:

```ruby
provider.call(
  source_path: source_path,
  out_path: out_path,
  parsed_program: parsed,
  compiler_profile_source: compiler_profile_source
)
```

Rules implemented:

- the provider must respond to `call`;
- provider return must be `Hash` or is treated as absent;
- provider exceptions are rescued and treated as absent;
- returned Hash values are validated through
  `IgniterLang::CompilerProfileContractValidator.validate`;
- nil or failed providers preserve legacy behavior and attach no report field.

`CompilationReport` now exposes:

```ruby
with_compiler_profile_contract_validation(report:, validation:)
```

The helper attaches:

```json
"compiler_profile_contract_validation": {
  "report_only": true
}
```

to the in-memory report only when validation exists.

The validation path does not modify:

- `pass_result`;
- `stages`;
- compiler diagnostics;
- assembler execution;
- compile status;
- public result shape.

The annotated report is not passed into the assembler. The assembler receives
the pre-annotation report so `.igapp` manifest/artifact output remains stable
against the no-provider baseline.

---

## Proof Experiment

Created:

```text
igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
```

Summary:

```text
igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json
```

Observed summary state:

```text
kind=prop038_report_only_compiler_integration_summary
format_version=0.1.0
track=prop038-report-only-compiler-integration-implementation-v0
status=PASS
cases=5
checks=20
failed_checks=0
```

Cases:

- `baseline_no_provider`
- `valid_contract`
- `invalid_contract`
- `nil_provider`
- `exception_provider`

---

## Required Proof Matrix

| Required case | Proof result |
| --- | --- |
| valid contract attaches `compiler_profile_contract_validation.valid=true` | PASS |
| invalid contract attaches `valid=false` and diagnostics | PASS |
| invalid contract still returns compile status `ok` when program otherwise compiles | PASS |
| public result remains unchanged | PASS |
| no `.igapp` manifest changes | PASS |
| no refusal report is written because of contract validation | PASS |
| provider nil preserves legacy behavior and does not attach the field | PASS |
| provider exception preserves legacy behavior and does not attach the field | PASS |

Additional checks passed:

- attached validation records `"report_only" => true`;
- invalid contract leaves `pass_result`, `stages`, and compiler diagnostics
  unchanged;
- invalid contract still executes assembler output;
- validator result keeps `compiler_integrated=false`;
- validator result keeps `compile_refusal_authorized=false`;
- valid, nil, and exception providers preserve comparable public result shape.

---

## Command Matrix

| Command | Result | Output |
| --- | --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` | PASS | `Syntax OK` |
| `ruby -c igniter-lang/lib/igniter_lang/compilation_report.rb` | PASS | `Syntax OK` |
| `ruby -c igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS | `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS | `PASS prop038_report_only_compiler_integration` |

---

## Non-Authorizations Preserved

This implementation did not create:

- compile refusal;
- public API or CLI widening;
- persisted success report or sidecar;
- `.igapp` manifest mutation from validation annotation;
- loader/report or CompatibilityReport;
- centralized diagnostics in `IgniterLang::Diagnostics`;
- `CompilerResult` changes;
- parser, TypeChecker, SemanticIR, assembler, dispatch, RuntimeMachine, Gate 3,
  Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

Descriptor digest behavior remains shape-only.

`contract_digest` validation remains deferred.

---

## Recommendation

```text
C3-A: accept
```

Reason:

- Candidate A is implemented within the authorized internal provider/report
  boundary;
- all eight required proof cases pass;
- public result, refusal behavior, CLI/API, and `.igapp` manifest output remain
  unchanged against the no-provider baseline.
