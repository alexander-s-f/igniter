# PROP-038 Strict Refusal Result Shape Orientation Map v0

Status: active-orientation
Owner: [Org Architect Supervisor]
Source card: `S3-R80-C0-O`
Date: 2026-05-19
Authority: orientation only / non-authority

This map helps R80 agents distinguish strict-refusal result-shape and
non-persisting path design from live refusal implementation, `CompilerResult`
mutation, public result widening, or persisted report authorization.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-internal-orchestrator-strict-source-status-decision-v0.md
igniter-lang/docs/tracks/stage3-round79-status-curation-v0.md
igniter-lang/docs/tracks/internal-orchestrator-strict-source-and-status-design-v0.md
igniter-lang/docs/tracks/prop038-refusal-report-and-result-surface-survey-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
```

---

## What R79 Authorized

R79 accepted the internal orchestrator strict-source/status design and opened
only a narrower design route:

```text
strict-refusal-result-shape-and-nonpersisting-path-design-v0
```

Accepted design candidate:

```text
new non-persisting strict refusal path
```

Accepted internal strict source stance:

```text
internal orchestrator constructor option only
not exposed through IgniterLang.compile(...)
not exposed through CLI or bin/igc
not read from .igapp, manifest, loader/report, CompatibilityReport,
environment, config, or defaults
absence of strict source preserves current report-only behavior
```

Accepted status stance:

```text
refused = future live compiler status candidate only
CompilerResult remains unchanged
public result shape remains unchanged
```

---

## What R79 Did Not Authorize

R79 did not authorize:

```text
code implementation
live compiler/orchestrator behavior changes
live compile refusal
public API or CLI widening
CompilerResult changes
persisted reports or sidecars
parser / TypeChecker / SemanticIR changes
assembler or .igapp mutation
loader/report behavior
CompatibilityReport behavior
IgniterLang::Diagnostics centralization
dispatch migration
RuntimeMachine
Gate 3 widening
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

No implementation card may open directly from R79.

---

## Current Refusal / Result Facts

Current `CompilerOrchestrator#refusal` path:

```text
writes <out without .igapp>.compilation_report.json
returns CompilerResult.refusal(...)
```

Current `CompilerResult.public_result(...)`:

```text
removes only the internal "report" key
```

Implication:

```text
Any new top-level result field becomes public unless public_result changes.
```

Current nested validation diagnostics:

```text
compiler_profile_contract_validation.diagnostics
```

They are not appended to:

```text
report["diagnostics"]
```

Current live behavior:

```text
invalid PROP-038 validation does not set pass_result
invalid PROP-038 validation does not change public result
invalid PROP-038 validation does not prevent assembler execution
invalid PROP-038 validation does not write refusal report
```

---

## R80 Design Questions

R80 may design:

```text
strict-refusal result/status shape
new non-persisting orchestrator refusal path as a future candidate
malformed strict requirement policy
public result key-set behavior
nested vs public diagnostic exposure
how current report-only behavior remains default
how no-source/no-field/no-refusal behavior remains default
how report_for_assembly and .igapp boundaries remain protected
proof/regression requirements for a later implementation review
exact blockers before implementation authorization
```

R80 should answer without changing code, result schemas, public output, or
artifacts.

---

## Malformed Strict Requirement Policy Options

Non-authority options for R80 design:

| Option | Meaning | Hazard |
| --- | --- | --- |
| Ignore / report-only | Malformed strict requirement preserves current report-only behavior. | May hide caller/config mistakes. |
| Configuration error model | Malformed source becomes design-level `configuration_error`. | Could become public/compile behavior if wording is loose. |
| Future refused status | Malformed source could later refuse compile. | Too broad unless explicitly gated and messaged. |
| Preflight-only error | Bad source fails before compiler result. | Public API/CLI behavior; currently closed. |

Safe R80 stance:

```text
choose/design a policy for future review
do not implement it
do not make malformed source a live refusal
```

Current provider paths still remain:

```text
provider nil => no field / no refusal
provider non-Hash => no field / no refusal
provider exception => no field / no refusal
validator exception => no field / no refusal
```

---

## Public Result And Nested Diagnostics Hazards

Hazard: public result key-set.

```text
CompilerResult.public_result strips only "report".
Any new top-level field is public by default.
```

R80 must require a future proof assertion:

```text
public_result key-set unchanged unless explicitly authorized
```

Hazard: nested diagnostics isolation.

```text
compiler_profile_contract_validation.diagnostics
  must not become top-level report["diagnostics"]
  must not become IgniterLang::Diagnostics
  must not become CLI/API public output
```

R80 must require a future proof assertion:

```text
nested diagnostics remain isolated unless explicitly surfaced by a later gate
```

Hazard: wrapper code visibility.

```text
compiler_profile_contract_refusal.contract_digest_mismatch
```

This remains design/proof-local wrapper vocabulary until a later gate decides
public visibility.

---

## Non-Persisting Path Design Guardrails

R80 may design a future path that:

```text
does not call existing CompilerOrchestrator#refusal
does not write <out>.compilation_report.json
does not write a separate sidecar
returns an in-memory result shape only if later authorized
skips assembly before .igapp artifacts are produced if live refused is later authorized
```

But R80 must not implement this path.

R80 must preserve:

```text
current CompilerOrchestrator#refusal behavior
current report_for_assembly boundary
current assembler behavior
current .igapp artifacts
current public result behavior
```

---

## Forbidden Implementation / Public / Persisted / Runtime Surfaces For R80

Closed in R80:

```text
code implementation
live compile refusal
compiler/orchestrator behavior changes
public API or CLI widening
CompilerResult changes
public result shape changes
persisted reports or sidecars
parser / TypeChecker / SemanticIR changes
assembler or .igapp mutation
loader/report behavior
CompatibilityReport behavior
IgniterLang::Diagnostics centralization
.ilk
CompilationReceipt links
signing
dispatch migration
RuntimeMachine
Gate 3 widening
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

Closed artifact/output moves:

```text
changing compilation_report.json semantics
writing new refusal reports
creating sidecars
changing .igapp manifests or contract files
changing CLI stdout/stderr/exit behavior
changing public Ruby result shape
changing loader/report or CompatibilityReport fixtures
```

---

## Pressure Hazards For C3-X

C3-X should pressure-test:

```text
1. Result-shape promotion:
   Does design text imply CompilerResult is changed or authorized?

2. Public key-set leak:
   Does a new top-level result field become public by default?

3. Nested diagnostics leak:
   Do nested contract diagnostics become top-level diagnostics or public output?

4. Non-persisting path implementation:
   Does design text create or authorize a new orchestrator path?

5. Existing #refusal mutation:
   Does design imply changing CompilerOrchestrator#refusal behavior?

6. Persistence creep:
   Does "refusal result" imply report/sidecar writes?

7. Malformed source ambiguity:
   Is malformed strict requirement policy explicit enough, without making it
   live behavior?

8. Provider path regression:
   Do nil/non-Hash/provider-error/validator-error paths remain no-field/no-refusal?

9. Assembly boundary:
   Does refused-path design preserve report_for_assembly and .igapp boundaries?

10. CLI/API creep:
    Does public source or public refusal wording imply API/CLI widening?

11. Wrapper vocabulary promotion:
    Does compiler_profile_contract_refusal.* become IgniterLang::Diagnostics or
    public schema?

12. Proof requirement loss:
    Are public_result key-set and nested-diagnostics isolation assertions
    explicitly carried forward?

13. Runtime language:
    Does the design imply RuntimeMachine, Gate 3, cache, Ledger/TBackend, or
    production readiness?
```

---

## Safe R80 Output Shape

Safe:

```text
result/status shape design options
non-persisting path design options
malformed strict requirement policy recommendation
public_result key-set proof requirement
nested diagnostics isolation proof requirement
no persisted report/sidecar proof requirement
exact blockers before implementation
explicit non-authorizations
```

Unsafe:

```text
implementation authorization
live refused behavior
CompilerResult schema mutation
public result widening
CLI/API changes
report or sidecar writes
loader/report or CompatibilityReport schema
runtime/production claims
```

---

## One-Line Handoff

Design the result shape; do not change the result.
