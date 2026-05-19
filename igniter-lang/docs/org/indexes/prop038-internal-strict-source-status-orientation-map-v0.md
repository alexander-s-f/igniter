# PROP-038 Internal Strict Source Status Orientation Map v0

Status: active-orientation
Owner: [Org Architect Supervisor]
Source card: `S3-R79-C0-O`
Date: 2026-05-19
Authority: orientation only / non-authority

This map helps R79 agents distinguish the internal orchestrator strict-source
and status design route from implementation, public surface widening, persisted
report authorization, or live compile refusal.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-live-refusal-implementation-boundary-design-decision-v0.md
igniter-lang/docs/tracks/stage3-round78-status-curation-v0.md
igniter-lang/docs/tracks/prop038-live-refusal-current-pipeline-surface-survey-v0.md
igniter-lang/docs/gates/prop038-strict-mode-refusal-trigger-proof-local-acceptance-decision-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
```

---

## What R78 Authorized

R78 accepted the live-refusal implementation boundary design and opened only a
narrower design route:

```text
internal-orchestrator-strict-source-and-status-design-v0
```

Accepted design direction:

```text
internal orchestrator option = first live strict source candidate to design
post-validation, pre-assembly compiler gate = design guidance only
future live refused status likely needs explicit status vocabulary
would_refuse may graduate to live refused only behind a later implementation gate
```

Accepted current behavior:

```text
report-only remains current live behavior
live compile refusal remains closed
loader/report remains closed
CompatibilityReport remains closed
runtime/production remains closed
```

---

## What R78 Did Not Authorize

R78 did not authorize:

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

R78 did not fully choose a live strict source. It only selected the internal
orchestrator option as the first source candidate for R79 design.

---

## Current Pipeline Facts

Current pipeline shape:

```text
IgniterLang.compile(...)
  -> CompilerOrchestrator#compile
     -> Parser / Classifier / TypeChecker / SemanticIREmitter
     -> CompilationReport.enrich(...)
     -> report_for_assembly = report
     -> compiler_profile_contract_provider call only when pass_result == ok
     -> CompilationReport.with_compiler_profile_contract_validation(...)
     -> refusal(...) only when report["pass_result"] != "ok"
     -> Assembler.assemble_artifacts(report: report_for_assembly, ...)
     -> optional runtime_smoke
     -> CompilerResult.ok(...)
  -> CLI prints CompilerResult.public_result(...)
```

Current report-only validation insertion:

```text
internal provider on CompilerOrchestrator constructor
in-memory CompilationReport field only
report_only=true
compiler_integrated=false
compile_refusal_authorized=false
```

Current public shape:

```text
CompilerResult.public_result removes report
CLI stdout does not expose nested compiler_profile_contract_validation
CLI has no strict/refusal flag
IgniterLang.compile has no direct strict/refusal parameter
```

---

## `CompilerOrchestrator#refusal` Report-Write Tension

R78 explicitly routes this unresolved tension into R79:

```text
Existing CompilerOrchestrator#refusal writes:
  <out without .igapp>.compilation_report.json

R78 design pressure noted:
  "no persisted report" conflicts with reusing existing #refusal.
```

R79 must evaluate at least these options:

| Option | Meaning | Risk |
| --- | --- | --- |
| Reuse existing `#refusal` | Accept compilation report write and design shape/semantics. | Opens persisted report behavior; needs explicit artifact/report policy. |
| New non-persisting refusal path | Return refusal result without report write. | Requires explicit new compiler path/status design. |
| Distinct PROP-038 refusal report | Write separate schema artifact. | Requires separate report/artifact policy and probably reader semantics. |

Orientation rule:

```text
Choosing or implementing any option is not authorized by this org map.
```

---

## Candidate Strict-Source / Status / Report Questions For R79

R79 may design:

```text
internal orchestrator strict source shape
where the strict source is supplied
where the strict source is validated
how no-source preserves legacy report-only behavior
how malformed source behaves
how source authority is named in internal data
future live status vocabulary, including whether "refused" is needed
future wrapper evidence shape for contract_digest_mismatch
whether CompilerResult would need a schema change later
whether public result would expose wrapper diagnostics later
whether refusal reuses #refusal, creates non-persisting path, or needs distinct report
how report_for_assembly stays protected
how refused path would skip assembly without mutating .igapp
proof/regression matrix needed before implementation authorization
exact blockers before implementation authorization
```

R79 may not turn these answers into live behavior.

---

## Source Candidate Status

| Source option | R78/R79 orientation status |
| --- | --- |
| Internal orchestrator option | First candidate for R79 design only; not implemented. |
| Ruby facade/API option | Deferred; public Ruby surface remains closed. |
| CLI flag | Deferred; CLI remains closed. |
| Manifest/profile policy | Deferred; `.igapp`, loader/report, and profile policy remain closed. |
| Gate-controlled profile requirement | Proof/design source only; not production/compiler source. |

Pressure should reject any wording that promotes a deferred source into live
authority.

---

## Status Vocabulary Guardrail

Accepted proof-local vocabulary:

```text
would_refuse
```

Possible future live vocabulary:

```text
refused
```

R79 may design how `would_refuse` might graduate to `refused`, but only behind
a later implementation gate.

Unsafe promotions:

```text
would_refuse -> refused now
compiler_profile_contract_refusal.* -> IgniterLang::Diagnostics now
nested contract validation -> top-level report diagnostics now
compiler_refusal_decision -> CompilerResult schema now
```

---

## Forbidden Implementation / Public / Persisted / Runtime Surfaces For R79

Closed in R79:

```text
code implementation
live compile refusal
compiler/orchestrator behavior changes
public API or CLI widening
CompilerResult changes
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
writing new refusal reports
changing existing compilation_report.json semantics
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
1. Design-to-implementation jump:
   Does R79 text imply an implementation card can open without another gate?

2. Internal-source creep:
   Does "internal orchestrator option" become an actual constructor/config
   change?

3. Public-surface creep:
   Do Ruby facade/API or CLI source options become accepted or documented as live?

4. Report-write ambiguity:
   Does the design resolve or hide the #refusal report-write tension?

5. Persistence creep:
   Does reusing #refusal imply persisted reports without artifact policy?

6. Non-persisting path ambiguity:
   If a new non-persisting refusal path is proposed, is it clearly future
   design and not current CompilerResult behavior?

7. Status promotion:
   Does would_refuse become refused, or wrapper code become live diagnostics?

8. CompilerResult creep:
   Does possible status vocabulary become schema change?

9. Assembly boundary:
   Does strict mode alter report_for_assembly, assembler execution, or .igapp?

10. Report-only regression:
    Are current no-source/no-field/no-refusal paths preserved?

11. Loader/report and CompatibilityReport creep:
    Does report/status wording open closed schemas?

12. Runtime language:
    Does the design imply RuntimeMachine, Gate 3, cache, Ledger/TBackend, or
    production readiness?

13. Blocker discipline:
    Does the output list exact blockers before implementation authorization?
```

---

## Safe R79 Output Shape

Safe:

```text
internal source shape options
status/result vocabulary options
explicit #refusal report-write decision options
proof/regression matrix proposal
blockers before implementation
explicit non-authorizations
```

Unsafe:

```text
implementation authorization
live refused status
actual orchestrator source parameter
CLI/Ruby API strict option
persisted report behavior
CompilerResult schema change
runtime/production claim
```

---

## One-Line Handoff

Design the internal source and status boundary; do not wire the refusal path.
