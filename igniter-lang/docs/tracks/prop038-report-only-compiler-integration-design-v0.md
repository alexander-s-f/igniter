# Track: PROP-038 Report-Only Compiler Integration Design v0

Card: S3-R66-C1-P1
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop038-report-only-compiler-integration-design-v0`
Route: UPDATE
Status: done
Date: 2026-05-17

---

## Goal

Design, without implementing, how PROP-038 internal validator results could later
become report-only compiler information without compile refusal, public API/CLI
widening, or production/runtime behavior.

This track does not authorize or perform implementation.

---

## Inputs Read

- `igniter-lang/docs/gates/prop038-library-validator-extraction-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/prop038-library-validator-extraction-design-decision-v0.md`
- `igniter-lang/docs/tracks/prop038-library-validator-extraction-implementation-v0.md`
- `igniter-lang/docs/discussions/prop038-library-validator-extraction-implementation-pressure-v0.md`
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `igniter-lang/docs/tracks/stage3-round65-status-curation-v0.md`
- `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/compilation_report.rb`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`

---

## Inspection Commands

```text
rg -n "compiler_profile_contract|CompilerProfileContractValidator|compiler_profile_source|CompilationReport|CompilerResult|report|diagnostics|sidecar|profile" igniter-lang/lib/igniter_lang igniter-lang/experiments/compiler_profile_contract_proof igniter-lang/docs/tracks/prop038-library-validator-extraction-implementation-v0.md igniter-lang/docs/gates/prop038-library-validator-extraction-acceptance-decision-v0.md
```

Result:

- `CompilerProfileContractValidator` exists only as an internal validator;
- proof experiment is the only current caller;
- public facade does not require the validator;
- orchestrator currently transports only `compiler_profile_source`;
- successful compiles keep `CompilationReport` in the internal orchestration
  result but do not persist a success report;
- refusal paths write a `.compilation_report.json`;
- `CompilerResult.public_result` removes the embedded internal report.

```text
rg -n "contract_digest|descriptor_digest|Validation Order|compile-time refusal|refusal|diagnostic|report-only|CompilerProfileObligationReport" igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
```

Result:

- PROP-038 keeps contract diagnostics under `compiler_profile_contract.*`;
- invalid contract diagnostics are refusal rules for the contract object only;
- current compiler compile-time refusal remains unauthorized;
- descriptor digest and `contract_digest` durable policies remain future-gated.

```text
rg -n "compiler_profile_contract|report-only|contract input|orchestrator|CompilationReport|CompilerResult|contract_digest|descriptor_digest|compile refusal" igniter-lang/docs/tracks/stage3-round65-status-curation-v0.md igniter-lang/docs/discussions/prop038-library-validator-extraction-implementation-pressure-v0.md
```

Result:

- R65 curation recommends design-only report integration planning;
- required design blockers match this card;
- report-only compiler integration, compile refusal, public API/CLI widening,
  loader/report, CompatibilityReport, runtime, Gate 3, and production behavior
  remain closed.

No code was edited by inspection.

---

## Current Surface Map

### Validator

File:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
```

Current behavior:

- public method: `validate(contract, digest_reference_policy: :prop038_24_plus)`;
- accepts an already-materialized contract Hash;
- returns a string-key validation result Hash;
- hardcodes `compiler_integrated=false`;
- hardcodes `compile_refusal_authorized=false`;
- keeps descriptor digest shape-only;
- keeps `contract_digest` validation deferred.

### Orchestrator

File:

```text
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
```

Current pipeline:

```text
parse -> classify -> typecheck -> emit -> report enrich -> assembly
```

Current profile behavior:

- accepts only `compiler_profile_source:` as compile-time profile input;
- forwards `compiler_profile_source` unchanged to assembler;
- does not validate or transport `compiler_profile_contract`;
- does not require the contract validator.

### Compilation Report

File:

```text
igniter-lang/lib/igniter_lang/compilation_report.rb
```

Current behavior:

- builds/enriches compiler diagnostics;
- has no `compiler_profile_contract_validation` field;
- successful report is embedded in orchestration internals and in the private
  `CompilerResult` `"report"` field;
- no success compilation report is persisted by the orchestrator.

### Compiler Result

File:

```text
igniter-lang/lib/igniter_lang/compiler_result.rb
```

Current behavior:

- `CompilerResult.ok` embeds internal `"report"`;
- `CompilerResult.public_result` removes `"report"`;
- public CLI output therefore does not expose internal report-only data unless
  `CompilerResult` is changed.

---

## Core Design Decision

```text
First report-only integration should be in-memory CompilationReport annotation
only.
```

Meaning:

- the compiler may validate an internally supplied already-materialized
  `compiler_profile_contract`;
- validation result is attached to the internal `CompilationReport`;
- compilation status remains unchanged;
- invalid contract validation does not refuse compilation;
- no public API or CLI input is added;
- no public `CompilerResult` output is changed;
- no success report is persisted;
- no `.igapp`, manifest, loader/report, CompatibilityReport, runtime, or
  production behavior changes.

This is report-only in the compiler's internal report object, not public output.

---

## Contract Input Ownership

Recommended input owner:

```text
internal compiler_profile_contract_provider
```

Shape:

```ruby
compiler_profile_contract_provider.call(
  source_path: source_path,
  out_path: out_path,
  parsed_program: parsed,
  compiler_profile_source: compiler_profile_source
)
```

The provider must return:

```text
Hash | nil
```

Rules:

- the provider owns the already-materialized contract Hash;
- nil means no contract validation field is attached;
- the orchestrator does not read paths for the contract;
- the orchestrator does not parse inline JSON;
- the orchestrator does not discover, default, infer, or finalize profiles;
- the orchestrator does not derive a contract from `compiler_profile_source`;
- the orchestrator does not derive `compiler_profile_source` from a contract;
- the public Ruby facade and CLI do not receive a new keyword/flag.

Recommended wiring:

```ruby
CompilerOrchestrator.new(compiler_profile_contract_provider: provider)
```

Do not add:

```ruby
IgniterLang.compile(..., compiler_profile_contract: ...)
```

Do not add:

```text
--compiler-profile-contract
```

Reason:

- constructor injection is internal enough for proof/spec callers;
- compile method and public facade remain stable;
- the first caller can be a proof-local harness, not CLI/API.

---

## Orchestrator Insertion Point

Recommended insertion point:

```text
after CompilationReport.enrich(...)
after semantic_ir is available
before `return refusal(...) unless report.pass_result == "ok"`
before assembler receives compiler_profile_source
```

Detailed shape:

```text
parse/classify/typecheck/emit complete
report = CompilationReport.enrich(...)
semantic_ir = compilation.fetch("semantic_ir")
report = maybe_attach_compiler_profile_contract_validation(report, context)
return refusal(report, ...) unless report.pass_result == "ok"
assemble_artifacts(... compiler_profile_source: compiler_profile_source)
```

Why this point:

- PROP-038 validation order places contract validation before finalized source
  transport and manifest interpretation;
- the compiler already has parsed/report context;
- report-only data can be attached before any assembler call;
- invalid contract validation cannot turn the report into an error.

Important:

- parse failures should not invoke the contract provider in the first
  report-only implementation;
- classifier/typechecker/emitter failure paths may attach contract validation
  only if C3-A explicitly wants validation on failed compilation reports;
- the recommended first implementation should validate only on the normal
  post-emit report path and preserve existing refusal causes.

---

## Report / Output Ownership Options

| Option | Owner | Persisted? | Public? | Write surfaces | Pros | Risks | Recommendation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A | Internal `CompilationReport` field | No | No | `compiler_orchestrator.rb`, `compilation_report.rb`, proof track | Smallest compiler integration; no public output; no golden migration; preserves CLI/API. | Only visible to internal orchestration/proof callers. | Recommended first implementation boundary. |
| B | `CompilerResult.ok` public result field | No | Yes | `compiler_result.rb`, CLI snapshots/proofs | Easy for CLI users to inspect. | Public output widening; likely CLI/API behavior change. | Hold. |
| C | Success `.compilation_report.json` | Yes | File output | `compiler_orchestrator.rb`, report paths, fixtures | Durable report artifact. | New persisted output and fixture/golden policy required. | Hold. |
| D | Separate sidecar JSON | Yes | File output | new sidecar writer, proof fixtures | Keeps report schema separate. | New artifact surface; output location policy unresolved. | Hold. |
| E | `.igapp` manifest/artifact | Yes | Artifact output | assembler / `.igapp` | Co-locates profile info with artifact. | Explicitly closed surface. | Reject. |
| F | Assembler refusal or source validation | N/A | Behavior | assembler | Reuses existing refusal machinery. | Creates compile refusal and conflates contract/source diagnostics. | Reject. |
| G | `IgniterLang::Diagnostics` centralization | Depends | Depends | diagnostics/report layers | Could unify category handling later. | Previously held; implies compiler report category semantics. | Hold. |

Recommended first owner:

```text
Option A: internal CompilationReport field only
```

Suggested field name:

```text
compiler_profile_contract_validation
```

Suggested field shape:

```json
{
  "kind": "compiler_profile_contract_validation_result",
  "format_version": "0.1.0",
  "valid": false,
  "diagnostics": [],
  "diagnostic_codes": [],
  "digest_reference_policy": "prop038_24_plus",
  "compiler_integrated": false,
  "compile_refusal_authorized": false,
  "report_only": true
}
```

Note:

- `report_only` would be report attachment metadata, not a validator field;
- the validator result itself should not be changed unless C3-A explicitly
  authorizes it.

---

## CompilationReport Design

Recommended helper:

```ruby
CompilationReport.with_compiler_profile_contract_validation(report:, validation:)
```

Behavior:

- return `report` unchanged when `validation` is nil;
- return `report.merge("compiler_profile_contract_validation" => validation.merge("report_only" => true))` when validation is present;
- do not modify `pass_result`;
- do not modify `stages`;
- do not append validator diagnostics into `report["diagnostics"]` in the first
  implementation.

Reason:

- appending to `diagnostics` risks being interpreted as compiler errors or
  warnings;
- the validator already returns its own diagnostics;
- keeping a separate field preserves vocabulary separation:

```text
compiler_profile_contract.* != compiler diagnostics != loader/report statuses
```

---

## CompilerResult Design

Recommended for first report-only implementation:

```text
Do not change CompilerResult.
```

Reason:

- successful internal report already flows through the private `"report"` key;
- `public_result` strips that key;
- exposing the validation result publicly would widen CLI/API output;
- the design goal forbids public API/CLI widening.

If future public output is desired, it must be a separate public-surface design
and authorization.

---

## Descriptor Digest And Canonicalization

Decision for first report-only integration:

```text
Continue validator behavior: descriptor digest shape-only.
```

The compiler integration should not recompute descriptor digest material because:

- the orchestrator receives a contract object, not descriptor material;
- descriptor material ownership remains unresolved;
- canonical descriptor serialization remains unresolved;
- recomputation would require new diagnostics and proof cases.

Allowed in first report-only implementation:

```text
compiler_profile_descriptor/sha256:<24+ lowercase hex> shape validation only
```

Still blocked before durable or persisted output:

- exact descriptor object/material;
- canonical serialization;
- whether any digest fields are excluded;
- short reference versus full 64-character reference policy;
- mismatch diagnostic vocabulary.

---

## Contract Digest Policy

Decision:

```text
Keep contract_digest format/mismatch diagnostics deferred for first report-only
compiler integration.
```

Reason:

- R65 accepted the validator with `contract_digest` validation deferred;
- enforcing it in report-only integration would add diagnostic vocabulary;
- `contract_digest_invalid` and `contract_digest_mismatch` remain unauthorized.

If C3-A wants `contract_digest` validation before report-only integration, route
to a separate diagnostic-vocabulary and canonicalization design card first.

---

## Report-Only Versus Compile Refusal

Hard separation:

```text
invalid compiler_profile_contract => report field only
invalid compiler_profile_contract != compile refusal
invalid compiler_profile_contract must not change pass_result
invalid compiler_profile_contract must not change stages
invalid compiler_profile_contract must not block assembly
```

The validation result must retain:

```json
{
  "compiler_integrated": false,
  "compile_refusal_authorized": false
}
```

The report attachment may add:

```json
{
  "report_only": true
}
```

Do not use:

- `CompilationReport.internal_error`;
- `CompilerResult.refusal`;
- `AssemblyRefused`;
- `report["pass_result"] = "error"`;
- stage values like `"error"` or `"skipped"` because of contract validation.

---

## Fixture / Golden Policy

Recommended first proof policy:

```text
new proof-local orchestrator report-only experiment, no golden migration
```

If implementation is authorized, add or update only proof-local experiment
fixtures/summaries that call `CompilerOrchestrator` directly with an internal
contract provider.

Do not update:

- `.igapp` goldens;
- CLI golden output;
- production spec fixtures;
- loader/report fixtures;
- CompatibilityReport fixtures.

Required proof cases for first implementation:

- valid contract attaches `compiler_profile_contract_validation.valid=true`;
- invalid contract attaches `valid=false` and diagnostics;
- invalid contract still returns compile status `ok` when the program otherwise
  compiles;
- public result remains unchanged;
- no `.igapp` manifest changes;
- no refusal report is written because of contract validation;
- provider nil preserves legacy behavior and does not attach the field.

---

## Exact Future Write Surfaces

Recommended bounded implementation write scope:

```text
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/experiments/prop038_report_only_compiler_integration/
igniter-lang/docs/tracks/<future-implementation-track>.md
```

Potentially read but not write:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/cli.rb
```

Do not write:

- `igniter-lang/lib/igniter_lang.rb`;
- `igniter-lang/lib/igniter_lang/cli.rb`;
- `igniter-lang/lib/igniter_lang/compiler_result.rb` for first implementation;
- `igniter-lang/lib/igniter_lang/diagnostics.rb`;
- `igniter-lang/lib/igniter_lang/assembler.rb`;
- parser, classifier, TypeChecker, SemanticIR emitter;
- `.igapp` outputs/goldens;
- loader/report or CompatibilityReport surfaces;
- RuntimeMachine, runtime, Gate 3, production surfaces.

---

## Candidate Integration Options

| Candidate | Contract input | Report owner | Output visibility | Compiler behavior | Readiness |
| --- | --- | --- | --- | --- | --- |
| A. Internal provider + in-memory report | `CompilerOrchestrator` constructor provider | `CompilationReport` field | internal orchestration only | no status/stage/refusal change | Ready for bounded implementation review |
| B. Internal provider + persisted success report | constructor provider | success `.compilation_report.json` | file output | no refusal | Hold pending output/golden policy |
| C. Internal provider + sidecar | constructor provider | sidecar JSON | file output | no refusal | Hold pending sidecar policy |
| D. Compile keyword | `compile(... compiler_profile_contract:)` | any | internal/public ambiguity | no refusal possible | Hold because compile API widening risk |
| E. Public facade/CLI input | `IgniterLang.compile` or CLI flag | any | public | no refusal possible | Reject for this lane |
| F. Assembler/`.igapp` integration | derive near assembly | manifest/artifact | artifact output | risk of refusal | Reject |
| G. Contract digest enforcement first | provider | report field | internal | no refusal if report-only | Redirect to digest diagnostic design |

---

## Blockers Before Any Implementation Card

[B1] C3-A must explicitly authorize report-only compiler integration. R65
acceptance does not authorize it.

[B2] C3-A must approve the internal provider ownership model and confirm no
public API/CLI widening.

[B3] C3-A must approve in-memory `CompilationReport` annotation as the first
output owner, with no persisted success report or sidecar.

[B4] C3-A must approve the exact insertion point: after report enrichment and
before assembler transport.

[B5] C3-A must confirm invalid contract validation cannot alter `pass_result`,
`stages`, assembler execution, or compile status.

[B6] C3-A must confirm descriptor digest remains shape-only for this
non-persisted report-only implementation.

[B7] C3-A must confirm `contract_digest` format/mismatch validation remains
deferred, or redirect to a digest diagnostic design first.

[B8] C3-A must approve proof-local experiment scope and no `.igapp`, CLI,
public-result, loader/report, CompatibilityReport, or production fixture/golden
mutation.

[B9] C3-A must confirm `CompilerResult` and public CLI output remain unchanged
for the first implementation.

[B10] C3-A must confirm `IgniterLang::Diagnostics` centralization remains held.

---

## Recommendation

```text
recommended route: authorize bounded implementation review
```

Recommended implementation review boundary:

- internal provider on `CompilerOrchestrator` constructor;
- in-memory `CompilationReport` field only;
- no `CompilerResult` change;
- no public facade or CLI input;
- no persisted success report;
- no sidecar;
- no `.igapp` mutation;
- no compile refusal;
- descriptor digest remains shape-only;
- `contract_digest` validation remains deferred;
- proof-local experiment proves report-only behavior and unchanged public result.

If C3-A wants any persisted output, public output, contract digest enforcement,
or descriptor digest recomputation, do not authorize implementation from this
track. Redirect first to a narrower design card for that expanded surface.

---

## Handoff

```text
Card: S3-R66-C1-P1
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop038-report-only-compiler-integration-design-v0
Status: done

[D] Decisions
- First report-only integration should be in-memory CompilationReport annotation
  only.
- Contract input should be internal provider ownership on CompilerOrchestrator
  construction, not compile/facade/CLI input.
- Recommended insertion point is after report enrichment and before assembler
  transport.
- CompilerResult, public facade, CLI, assembler, `.igapp`, diagnostics
  centralization, loader/report, CompatibilityReport, runtime, and production
  surfaces stay closed.
- Descriptor digest remains shape-only and contract_digest validation remains
  deferred.

[S] Signals
- Current compiler has no independent contract input path.
- Successful reports are internal today; public results strip the internal
  report field.
- This makes in-memory CompilationReport annotation the smallest report-only
  integration that avoids public API/CLI widening.

[T] Tests / Proofs
- Design-only track.
- `rg` inspection completed.
- No tests run because no code was changed.

[R] Recommendation
- Authorize bounded implementation review for Candidate A only.
- Hold or redirect if C3-A wants persistence, public output, digest enforcement,
  compile refusal, or production/runtime behavior.
```
