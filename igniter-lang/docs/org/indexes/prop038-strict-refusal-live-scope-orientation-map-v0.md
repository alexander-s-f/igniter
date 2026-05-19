# PROP-038 Strict Refusal Live Scope Orientation Map v0

Status: active-orientation
Owner: [Org Architect Supervisor]
Source card: `S3-R82-C0-O`
Date: 2026-05-19
Authority: orientation only / non-authority

This map helps R82 agents distinguish implementation-scope design/review from
implementation authorization.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-strict-refusal-result-shape-proof-acceptance-decision-v0.md
igniter-lang/docs/tracks/stage3-round81-status-curation-v0.md
igniter-lang/docs/tracks/prop038-strict-refusal-result-shape-proof-local-v0.md
igniter-lang/docs/gates/prop038-strict-refusal-result-shape-decision-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
```

---

## What R81 Proved

R81 accepted the proof-local strict-refusal result-shape experiment:

```text
status=PASS
cases=3
checks=44
failed_checks=0
```

Accepted proof-local coverage:

```text
strict-refusal target shape
malformed strict requirement configuration_error target shape
strict-refusal public key-set allowlist
compilation_report_path present and null
nested diagnostics isolation
public wrapper diagnostic shape
no sidecar / no report / no artifact target behavior
no .igapp target artifact
legacy/report-only anchors referenced and not contradicted
no live implementation
```

Accepted public key-set:

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

Accepted proof-local diagnostic codes:

```text
compiler_profile_contract_refusal.contract_digest_mismatch
compiler_profile_contract_refusal.strict_requirement_malformed
```

Raw validator diagnostic remains nested:

```text
compiler_profile_contract.contract_digest_mismatch
```

---

## What R81 Did Not Authorize

R81 did not authorize:

```text
live compiler/orchestrator behavior changes
live compile refusal
CompilerResult changes
public API/CLI widening
persisted reports or sidecars from live code
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

No live implementation card may open directly from R81.

---

## Exact R82 Scope-Review Questions

R82 may design/review:

```text
exact candidate live write scope
whether future implementation needs CompilerResult authority
whether future implementation needs CompilerOrchestrator authority
whether configuration_error shares the strict-refusal public key-set
whether configuration_error needs a smaller public surface
whether report.pass_result: "ok" remains invariant for all strict terminal paths
whether report.pass_result: "ok" applies only to digest-validation strict refusal
whether non-persisting/no-sidecar/no-report stance remains the first live route
whether a separate persisted-report policy question must open
how report-only current live behavior remains preserved
how public API/CLI closure remains preserved
exact blockers before any implementation authorization card
```

R82 must not implement any answer.

---

## Live Write-Scope Hazards

Candidate live write scope, if ever authorized, will likely involve sensitive
compiler/result surfaces. R82 may name candidates, but must not authorize them.

Likely candidate surfaces that require explicit future authority:

```text
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
possibly proof-local/live proof experiment files
possibly a track doc for implementation proof
```

Surfaces that must remain excluded unless separately opened:

```text
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/assembler.rb
parser / classifier / typechecker / semanticir_emitter
loader/report
CompatibilityReport
RuntimeMachine
Ledger/TBackend
```

Hazard: a "scope review" that names write surfaces can be mistaken for
implementation authorization. R82 must preserve this distinction.

---

## CompilerResult Authority Hazards

R81 proof-local shape uses:

```text
status: refused
status: configuration_error
compilation_report_path: null
public key-set allowlist
wrapper diagnostics
```

Live implementation would need explicit `CompilerResult` authority because:

```text
CompilerResult.public_result removes only "report"
new top-level result fields become public by default
CompilerResult.refusal currently derives diagnostics from top-level report diagnostics
current CompilerResult code has no live strict-refusal constructor
```

R82 should decide whether the next future implementation would need:

```text
new CompilerResult.strict_refusal(...)
changes to CompilerResult.refusal(...)
public_result allowlist behavior
new tests proving public key-set stability
```

R82 must not make those changes.

---

## CompilerOrchestrator Authority Hazards

Live strict refusal would need explicit `CompilerOrchestrator` authority because
the design candidate is:

```text
new non-persisting strict refusal path
```

It must not reuse the existing path silently:

```text
CompilerOrchestrator#refusal
```

because existing `#refusal` writes:

```text
<out without .igapp>.compilation_report.json
```

R82 should require an explicit future decision that the first strict-refusal
implementation either:

```text
does not call CompilerOrchestrator#refusal
```

or opens a separate persisted-report policy if it does.

R82 must not change the orchestrator.

---

## `report.pass_result` Open Question

R81 accepted proof-local:

```text
report.pass_result: "ok"
```

for strict digest-mismatch and malformed strict-requirement target shapes.

Open before live implementation:

```text
Does pass_result: "ok" apply to all future strict terminal paths?
Or only to digest-validation strict refusal paths?
Should configuration_error keep pass_result: "ok"?
```

Hazard: mutating `report["pass_result"]` could route through existing refusal
behavior and sidecar report writes. R82 should keep this visible.

---

## `configuration_error` Public-Surface Open Question

R81 accepted proof-local:

```text
malformed strict requirement => configuration_error
```

Open before live implementation:

```text
Does configuration_error permanently share the strict-refusal 13-key public
allowlist?
Or does it need a smaller configuration-error-specific public surface?
```

Accepted proof-local reason code:

```text
compiler_profile_contract_refusal.strict_requirement_malformed
```

Hazards:

```text
configuration_error must not become digest mismatch
configuration_error must not be produced when no strict source exists
configuration_error must not become CLI preflight behavior without public API/CLI authority
configuration_error must not create persisted report behavior
```

---

## Forbidden Implementation / Public / Persisted / Runtime Surfaces For R82

Closed in R82:

```text
code implementation
live compile refusal
live compiler/orchestrator behavior changes
CompilerResult code changes
public API or CLI widening
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
changing CompilerResult.public_result
adding CompilerResult.strict_refusal
changing CompilerOrchestrator#refusal
adding live orchestrator strict-source option
writing report sidecars
changing .igapp manifests or compilation_report artifacts
changing CLI stdout/stderr/exit behavior
changing public Ruby result shape
changing loader/report or CompatibilityReport fixtures
```

---

## Pressure Hazards For C3-X

C3-X should pressure-test:

```text
1. Authorization slip:
   Does implementation-scope review read as implementation authorization?

2. Write-scope ambiguity:
   Are candidate live files named as candidates, not opened write surfaces?

3. CompilerResult authority gap:
   Does the design require CompilerResult changes but fail to say so?

4. CompilerOrchestrator authority gap:
   Does the design require orchestrator changes but fail to say so?

5. #refusal persistence leak:
   Does the design accidentally reuse CompilerOrchestrator#refusal and write a
   sidecar report?

6. pass_result ambiguity:
   Is report.pass_result: "ok" policy explicitly scoped?

7. configuration_error surface ambiguity:
   Does configuration_error public shape remain unresolved or over-broad?

8. Public key-set drift:
   Does future live surface still match the R81 proof allowlist, or explicitly
   route a new decision?

9. Nested diagnostics leak:
   Do raw compiler_profile_contract.* diagnostics become public/top-level?

10. Report-only regression:
    Does current live report-only behavior stay unchanged when strict source is
    absent?

11. API/CLI creep:
    Does any public source or CLI strict flag appear?

12. Artifact creep:
    Does live scope imply .igapp/report/sidecar changes?

13. Runtime language:
    Does the design imply RuntimeMachine, Gate 3, cache, Ledger/TBackend, or
    production readiness?

14. Blocker discipline:
    Are blockers exact enough before any implementation authorization?
```

---

## Safe R82 Output Shape

Safe:

```text
candidate live write-scope list
CompilerResult authority requirement statement
CompilerOrchestrator authority requirement statement
pass_result policy decision or blocker
configuration_error public-surface decision or blocker
non-persisting/no-sidecar stance
exact blockers before implementation authorization
explicit non-authorizations
```

Unsafe:

```text
implementation card opened directly
live compiler/orchestrator changes
CompilerResult schema changes
public API/CLI changes
persisted reports or sidecars
.igapp changes
runtime/production claims
```

---

## One-Line Handoff

Review the live scope; do not open the live write.
