# PROP-038 Strict Mode Current Compiler Surface Survey v0

Card: S3-R76-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop038-strict-mode-current-compiler-surface-survey-v0
Route: UPDATE
Status: done
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-contract-digest-compile-refusal-preconditions-decision-v0.md`

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - strict source semantics and refusal wording.
- [Igniter-Lang Bridge Agent] - CLI/report/API surface awareness; no bridge implementation changed.

---

## Scope

Read-only survey of the current compiler/report/CLI surface to identify where a
future strict-mode/refusal trigger could be designed, and where it must not be
inferred from current report-only plumbing.

Read:

- `docs/gates/prop038-contract-digest-compile-refusal-preconditions-decision-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/gates/prop038-contract-digest-live-validator-implementation-acceptance-decision-v0.md`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/compilation_report.rb`
- `lib/igniter_lang/compiler_result.rb`
- `lib/igniter_lang/cli.rb`
- `lib/igniter_lang.rb`
- `lib/igniter_lang/assembler.rb`
- `bin/igc`
- `rg "compiler_profile_contract|compiler_profile_source|compile\\(" igniter-lang/lib igniter-lang/exe`
- `rg "strict|refusal|contract_digest|compiler_profile_contract_validation|compile_refusal_authorized|report_only" igniter-lang/lib/igniter_lang igniter-lang/bin`

No code was edited. This track does not propose implementation code and does
not authorize surface widening.

---

## Current Surface Map

### Compiler Profile Contract Provider Entry Point

Current entry point:

```text
IgniterLang::CompilerOrchestrator.new(
  compiler_profile_contract_provider: provider
)
```

Current call site:

```text
CompilerOrchestrator#compile
  after emit_typed and report enrichment
  only when report["pass_result"] == "ok"
  calls compiler_profile_contract_validation(...)
```

Provider call shape:

```ruby
provider.call(
  source_path: source_path,
  out_path: out_path,
  parsed_program: parsed,
  compiler_profile_source: compiler_profile_source
)
```

Current behavior:

- provider must respond to `call`;
- provider return must be a `Hash`;
- non-Hash/nil returns produce no validation field;
- provider or validator exceptions are rescued and produce no validation field;
- returned Hash is validated with `CompilerProfileContractValidator.validate(contract)`;
- no strict-mode parameter is passed;
- no caller-facing refusal signal is returned from this provider path.

### Validation Result

Current internal validator:

```text
IgniterLang::CompilerProfileContractValidator.validate(
  contract,
  digest_reference_policy: :prop038_24_plus
)
```

Current result shape includes:

```text
valid
diagnostics
diagnostic_codes
digest_reference_policy
compiler_integrated=false
compile_refusal_authorized=false
```

The validator now emits `contract_digest_*` diagnostics internally, but the
result itself explicitly says:

```text
compile_refusal_authorized=false
compiler_integrated=false
```

That is a report-local status, not a compiler refusal trigger.

### Report Annotation

Current annotation helper:

```ruby
CompilationReport.with_compiler_profile_contract_validation(
  report: report,
  validation: validation
)
```

Behavior:

- nil validation returns the original report;
- non-nil validation adds:

```text
report["compiler_profile_contract_validation"] = validation.merge("report_only" => true)
```

It does not mutate:

- `report["pass_result"]`;
- `report["stages"]`;
- top-level `report["diagnostics"]`;
- `semantic_ir_ref`;
- source metadata.

### Refusal Boundary

Current compiler refusal gate:

```text
return refusal(report, source_path, out_path) unless report["pass_result"] == "ok"
```

The report-only contract validation is attached before this line, but it does
not change `pass_result`. Therefore an invalid contract validation result does
not currently trigger refusal.

Other refusal paths are unrelated:

- parse failure;
- assembler refusal;
- runtime smoke failure;
- internal compiler error.

Those should not be reused as implicit PROP-038 strict-mode semantics.

### Assembly Boundary

`CompilerOrchestrator#compile` captures:

```ruby
report_for_assembly = report
```

before report-only contract validation is attached. The assembler receives
`report_for_assembly`, not the annotated report.

Implication:

```text
compiler_profile_contract_validation is in-memory report metadata only.
It is not currently assembled into .igapp artifacts.
```

The assembler separately validates `compiler_profile_source` under
`compiler_profile_source.*` vocabulary. That is a PROP-036 source transport
boundary, not a strict contract-digest refusal boundary.

### Public Result Boundary

`CompilerResult.ok(...)` includes the internal `report` field in the internal
result object.

`CompilerResult.public_result(result)` removes:

```text
report
```

The CLI prints:

```ruby
CompilerResult.public_result(orchestration.fetch("result"))
```

Therefore report-only validation is not part of current public CLI JSON output.

### CLI / API Exposure

Current CLI:

```text
igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]
```

Current CLI supports `compiler_profile_source` transport only. It does not
support:

- `--compiler-profile-contract`;
- `--strict`;
- `--strict-profile`;
- digest policy selection;
- compile-refusal policy selection.

Current Ruby facade:

```ruby
IgniterLang.compile(
  source_path:,
  out_path:,
  sample_input: nil,
  sample_input_resolver: nil,
  runtime_smoke: nil,
  compiler_profile_source: nil,
  orchestrator: CompilerOrchestrator.new
)
```

The facade does not expose `compiler_profile_contract_provider:` directly. A
caller can pass a custom orchestrator, but this remains an internal injection
boundary and not a strict-mode public API.

---

## No-Field / No-Refusal Paths

Current no-field/no-refusal paths:

| Path | Current behavior |
| --- | --- |
| no provider | no `compiler_profile_contract_validation` field |
| provider does not respond to `call` | no field |
| provider returns nil | no field |
| provider returns non-Hash | no field |
| provider raises | no field |
| validator raises | no field |
| compile pass before validation is not ok | existing refusal path; contract provider is not the cause |

These paths are intentionally fail-open with respect to contract validation.
They must not be reinterpreted as strict-mode failure without a new explicit
strict source and user-facing wording decision.

---

## Must Not Infer Strict Mode From...

Do not infer strict mode from:

- presence of `compiler_profile_contract_provider`;
- presence of `compiler_profile_contract_validation` in the in-memory report;
- `validation["valid"] == false`;
- any `compiler_profile_contract.contract_digest_*` diagnostic;
- `report_only: true`;
- `compile_refusal_authorized=false`;
- `compiler_integrated=false`;
- `digest_reference_policy: "prop038_24_plus"`;
- successful recomputation;
- `contract_digest_mismatch`;
- `contract_digest_recompute_unavailable`;
- CLI `--compiler-profile-source`;
- assembler `compiler_profile_source.*` refusal vocabulary;
- loader/report vocabulary;
- public result status;
- runtime smoke failure;
- temporal executor refusal vocabulary;
- `.igapp` manifest content.

Short rule:

```text
compiler_profile_contract.* diagnostic != compiler compile refusal
```

Strict mode requires a future explicit source, status semantics, wording, proof,
and authorization.

---

## Potential Future Write-Scope Candidates

These are non-authority observations only. They are not implementation
authorization.

| Candidate file | Why a future card might request it | Current caution |
| --- | --- | --- |
| `lib/igniter_lang/compiler_orchestrator.rb` | It owns the current provider hook, report annotation point, and refusal boundary. | Must not change without explicit strict-mode authorization. |
| `lib/igniter_lang/compilation_report.rb` | It owns the report-only merge helper. | Current helper is intentionally non-refusal and nested. |
| `lib/igniter_lang/compiler_result.rb` | It owns public-vs-internal result shaping and refusal result shape. | Public result currently strips `report`; exposing strict diagnostics would widen surface. |
| `lib/igniter_lang/cli.rb` | It owns CLI flags and exit behavior. | No strict flag exists; adding one is public API widening. |
| `lib/igniter_lang.rb` | It owns the Ruby facade. | No direct contract provider or strict policy argument exists. |
| `lib/igniter_lang/compiler_profile_contract_validator.rb` | It owns diagnostics and digest validation. | Live diagnostics exist, but result flags still say no compile refusal. |
| `lib/igniter_lang/assembler.rb` | It owns `.igapp` assembly and `compiler_profile_source` validation. | Current contract validation is intentionally not assembled into `.igapp`. |
| `bin/igc` | It owns process exit from CLI success boolean. | Exit behavior must not change without CLI/refusal authorization. |

Potential test/proof candidates in a future card:

- proof-local strict-mode matrix before live behavior;
- CLI/API surface proof if a strict source becomes public;
- public result / report persistence proof if any diagnostic becomes user-facing;
- `.igapp` non-mutation proof if strict mode stays pre-assembly.

---

## Risks

1. **Confusing contract invalidity with compiler refusal.**
   The validator can now report contract invalidity, including digest mismatch,
   but compile refusal remains a separate compiler outcome.

2. **Assuming provider presence means strict requirement.**
   Provider injection currently means "optional report-only annotation attempt,"
   not "profile contract is required."

3. **Using `compile_refusal_authorized=false` as a hidden switch.**
   It is a negative assertion, not a toggle. There is no current positive
   strict-mode value.

4. **Leaking report-only details into public CLI/API.**
   `CompilerResult.public_result` strips `report`; exposing nested validation
   would be a public-surface decision.

5. **Mixing PROP-036 source transport with PROP-038 contract strictness.**
   `--compiler-profile-source` and assembler `compiler_profile_source.*`
   validation are not contract-digest strict mode.

6. **Letting `.igapp` artifacts drift.**
   Current assembly uses `report_for_assembly` captured before validation
   annotation. Strict-mode design must decide whether this remains true.

---

## Questions For C3-X / C4-A

1. What is the explicit strict source?
   Possible options include Ruby-only provider contract, CLI flag, finalized
   source policy, config/manifest, or no public strict source yet.

2. Does strict mode require a caller-supplied contract Hash, or can absence of a
   provider be strict-failure?

3. Should refusal be represented as a new compiler-level wrapper diagnostic
   that cites `compiler_profile_contract.*` as evidence?

4. Should `contract_digest_recompute_unavailable` fail open or fail closed under
   strict mode?

5. Should strict-mode diagnostics appear in public `CompilerResult`, persisted
   refusal reports, both, or neither?

6. Should strict refusal occur before assembly, and should the annotated
   validation report ever reach `.igapp` artifacts?

7. Should CLI strict behavior exist at all in the next slice, or remain Ruby
   facade/orchestrator-only until report wording stabilizes?

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/prop038-strict-mode-current-compiler-surface-survey-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Current surface is report-only: provider -> validator -> nested in-memory report.
- Current refusal boundary remains pass_result-based and unrelated to contract validation.
- Current public CLI/API has no strict-mode source.
- Current public CLI output strips the report and therefore hides report-only validation.

[S] Signals:
- Live validator has contract_digest diagnostics, but result flags remain compiler_integrated=false and compile_refusal_authorized=false.
- No-field/no-refusal paths are broad and intentional.
- report_for_assembly is captured before contract validation annotation.

[T] Tests / Proofs:
- Read-only survey; no proof command required.
- rg scan completed for compiler_profile_contract, compiler_profile_source, compile(, strict/refusal/report_only surfaces.

[R] Recommendations:
- C3-X/C4-A should not authorize strict/refusal from current plumbing alone.
- First decide explicit strict source, user-facing refusal wording, fail-open/fail-closed policy, and public/private report boundary.

[Files] Changed:
- igniter-lang/docs/tracks/prop038-strict-mode-current-compiler-surface-survey-v0.md

[Q] Open Questions:
- What source explicitly turns report-only validation into strict requirement?
- What public result or refusal report wording is acceptable?
- Does recompute unavailable fail open or closed under strict mode?

[X] Rejected:
- No code implementation, compile refusal, public API/CLI widening, CompilerResult change, persisted report, loader/report behavior, CompatibilityReport behavior, RuntimeMachine behavior, or production behavior was added.

[Next] Proposed next slice:
- C3-X pressure review of this surface survey before any strict-mode proof or implementation card.
```
