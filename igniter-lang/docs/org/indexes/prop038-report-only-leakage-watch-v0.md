# PROP-038 Report-Only Leakage Watch v0

Status: active orientation note
Owner: [Org Architect Supervisor]
Date: 2026-05-17
Source card: `S3-R67-C0-O`
Authority: orientation only, not canon

---

## Purpose

Give future agents a compact leakage checklist for the R67 report-only
implementation lane.

This note does not authorize code, semantics, report behavior, public output,
compile refusal, persisted artifacts, loader/report, CompatibilityReport,
runtime, or production behavior.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-report-only-compiler-integration-design-decision-v0.md
igniter-lang/docs/tracks/prop038-report-only-compiler-integration-design-v0.md
igniter-lang/docs/discussions/prop038-report-only-compiler-integration-design-pressure-v0.md
igniter-lang/docs/org/indexes/prop038-report-integration-boundary-map-v0.md
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
```

---

## Current Authority Snapshot

Latest relevant authority:

```text
igniter-lang/docs/gates/prop038-report-only-compiler-integration-design-decision-v0.md
```

Decision status:

```text
accepted-authorized-bounded-report-only-implementation
```

Authorized candidate:

```text
Candidate A only:
internal provider on CompilerOrchestrator constructor
in-memory CompilationReport field only
report-only, never refusal
```

Accepted field name:

```text
compiler_profile_contract_validation
```

Accepted implementation interpretation:

```text
compiler_integrated=false means "validation result does not drive compile
outcome"; it does not mean "the validator was not called inside the compiler".
```

---

## Allowed R67 Write Surfaces

Authorized implementation may edit only:

```text
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/experiments/prop038_report_only_compiler_integration/
igniter-lang/docs/tracks/prop038-report-only-compiler-integration-implementation-v0.md
```

Implementation may read but must not edit:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/cli.rb
```

Any diff outside this set is a leakage candidate and should be reviewed against
the gate before acceptance.

---

## Public-Output Leakage Checks

Report-only annotation must stay internal.

Check after implementation:

```text
CompilerResult was not edited.
CompilerResult.public_result still removes the private "report" key.
CLI output did not gain compiler_profile_contract_validation.
igniter-lang/lib/igniter_lang.rb did not require or expose the validator.
No new compile keyword or CLI flag was added.
No public Ruby facade input was widened.
```

Red flags:

```text
compiler_profile_contract_validation appears in public_result output
--compiler-profile-contract appears anywhere
IgniterLang.compile(... compiler_profile_contract: ...) appears anywhere
compiler_profile_contract_provider is exposed outside CompilerOrchestrator.new
```

Safe mental model:

```text
internal orchestration report may carry the field
public result must not expose it in this first implementation
```

---

## Refusal Creep Checks

Invalid contract validation must never become compilation refusal in this lane.

Check after implementation:

```text
invalid contract + otherwise-ok source => orchestration status remains "ok"
report["pass_result"] remains unchanged
report["stages"] remains unchanged
assembler execution is not blocked
CompilerResult.refusal is not called because of contract validation
CompilationReport.internal_error is not used for contract validation
AssemblyRefused is not raised for contract validation
validator diagnostics are not appended into report["diagnostics"]
```

Forbidden behaviors:

```text
pass_result="error" because compiler_profile_contract is invalid
stage="error" or "skipped" because compiler_profile_contract is invalid
status="oof" or "error" because compiler_profile_contract is invalid
writing a refusal .compilation_report.json because of contract validation
```

The attached validation result can be invalid:

```text
"valid" => false
```

but the compile result must remain governed by the source program's existing
compiler path, not by PROP-038 contract validity.

---

## Persisted Artifact And Golden Mutation Checks

Allowed proof surface:

```text
igniter-lang/experiments/prop038_report_only_compiler_integration/
```

Do not mutate:

```text
.igapp artifacts
.igapp manifests
existing goldens
CLI golden output
production spec fixtures
loader/report fixtures
CompatibilityReport fixtures
persisted success .compilation_report.json
sidecar JSON
```

Required proof intent:

```text
new proof-local experiment only
no golden migration
no success report persistence
no refusal report written because of contract validation
public result remains unchanged
```

If an implementation creates or modifies durable output outside the proof
experiment, route it back to Architect review before acceptance.

---

## Provider Exception Semantics

Authorized first implementation policy:

```text
compiler_profile_contract_provider exceptions are rescued and treated as nil.
```

Meaning:

```text
provider raises => no compiler_profile_contract_validation field attached
provider raises => legacy behavior preserved
provider raises != compiler internal_error
provider raises != compile refusal
```

Leakage checks:

```text
provider exception does not alter pass_result
provider exception does not alter stages
provider exception does not write a report/refusal artifact
provider exception does not surface in public result
```

This may hide provider bugs, but R66 accepted it as the safest first
report-only boundary.

---

## `compiler_integrated=false` Interpretation

The validator result keeps:

```text
compiler_integrated=false
compile_refusal_authorized=false
```

In R67, this is not a claim that the validator was never called by
`CompilerOrchestrator`.

Accepted meaning:

```text
compiler_integrated=false
  => the validation result does not drive compile outcome

compile_refusal_authorized=false
  => invalid validation cannot refuse compilation
```

Proof should assert outcome separation:

```text
invalid contract + otherwise-ok program = compile status ok
public result unchanged
assembler still runs
field may exist only in internal in-memory report
```

Do not flip these flags in R67.

---

## Post-Implementation Acceptance Checklist

Before accepting any R67 implementation, check:

```text
1. Only allowed write surfaces changed.
2. CompilerResult, CLI, public facade, assembler, diagnostics, parser,
   classifier, TypeChecker, SemanticIR, loader/report, CompatibilityReport,
   RuntimeMachine, and runtime surfaces did not change.
3. Provider input is constructor-only and internal.
4. Provider returns Hash | nil; exceptions are rescued as nil.
5. Report helper attaches only compiler_profile_contract_validation.
6. Attachment adds report_only=true.
7. pass_result and stages are unchanged.
8. diagnostics array is not polluted with compiler_profile_contract.* codes.
9. public result remains unchanged.
10. no persisted success report, sidecar, .igapp, or golden mutation.
11. contract_digest validation remains deferred.
12. unknown owner-slot diagnostics remain unauthorized.
13. proof-local experiment covers valid, invalid, nil, and exception provider
    cases plus public-output/non-refusal/non-persistence checks.
```

---

## Return Summary

R66 opened a narrow R67 implementation lane: internal provider plus in-memory
`CompilationReport` annotation only. The leakage danger is that future agents may
mistake "report-only validation exists inside the compiler" for public output,
compile refusal, persisted report behavior, loader/report status, or production
authority.

The compact rule:

```text
attach internal field, do not change outcome, do not expose, do not persist
```
