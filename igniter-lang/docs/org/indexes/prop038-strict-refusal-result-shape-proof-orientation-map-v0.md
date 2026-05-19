# PROP-038 Strict Refusal Result Shape Proof Orientation Map v0

Status: active-orientation
Owner: [Org Architect Supervisor]
Source card: `S3-R81-C0-O`
Date: 2026-05-19
Authority: orientation only / non-authority

This map helps R81 agents distinguish proof-local result-shape modeling from
live compiler behavior, `CompilerResult` mutation, public API/CLI widening,
persisted reports, or `.igapp` artifact changes.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-strict-refusal-result-shape-decision-v0.md
igniter-lang/docs/tracks/stage3-round80-status-curation-v0.md
igniter-lang/docs/tracks/strict-refusal-result-shape-and-nonpersisting-path-design-v0.md
igniter-lang/docs/tracks/prop038-public-result-and-diagnostics-proof-surface-survey-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
```

---

## What R80 Authorized

R80 accepted strict-refusal result-shape and non-persisting path design, then
opened only a proof-local route:

```text
prop038-strict-refusal-result-shape-proof-local-v0
```

Accepted design/proof-local targets:

```text
future status vocabulary: refused
malformed strict requirement policy: configuration_error
strict-refusal public key-set allowlist
compilation_report_path: null for non-persisting target shape
nested diagnostics isolation
public wrapper diagnostic:
  compiler_profile_contract_refusal.contract_digest_mismatch
```

Accepted first future implementation candidate remains:

```text
new non-persisting strict refusal path
```

This remains a candidate, not implementation authority.

---

## What R80 Did Not Authorize

R80 did not authorize:

```text
live compiler/orchestrator code changes
live compile refusal
CompilerResult code changes
public API or CLI widening
persisted reports or sidecars
parser / TypeChecker / SemanticIR changes
assembler or .igapp mutation
loader/report behavior
CompatibilityReport behavior
IgniterLang::Diagnostics centralization
RuntimeMachine
Gate 3 widening
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

No live implementation card may open directly from R80.

---

## Exact Proof-Local Assertions Expected In R81

R81 proof-local experiment should assert:

```text
strict-refusal target result shape is modeled
malformed strict requirement configuration-error target shape is modeled
public key-set equals the accepted allowlist
public result has no report key
public result has no compiler_profile_contract_validation key
public result has no strict_refusal key
public result has no wrapper_evidence key
public result has no compile_refusal_authorized key
public result has no raw nested validator diagnostic objects
compilation_report_path is present and null for non-persisting target
nested diagnostics remain internal evidence
public wrapper diagnostic shape is explicit
no sidecar/report/artifact path is produced by proof-local target
legacy/report-only anchors are referenced and not contradicted
```

Expected proof-local output:

```text
JSON summary with pass/fail, cases, checks, failed checks, command matrix, and
non-authorizations preserved.
```

---

## Strict-Refusal Target Shape Anchors

Accepted public key-set allowlist:

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

Required public exclusions:

```text
report
compiler_profile_contract_validation
strict_refusal
wrapper_evidence
refusal_candidates
strict_validation_source
compile_refusal_authorized
raw_validation_diagnostics
```

Accepted non-persisting convention:

```json
{
  "compilation_report_path": null
}
```

Meaning:

```text
no sidecar compilation report was written
```

This is proof-local target shape only, not current live `CompilerResult` schema.

---

## Public Key-Set And Nested Diagnostics Hazards

Current fact:

```text
CompilerResult.public_result removes only "report".
Any new top-level result field would become public by default.
```

R81 must avoid:

```text
adding new live top-level result fields
assuming public_result is an allowlist
promoting internal evidence fields to public keys
```

Nested diagnostics isolation:

```text
report["compiler_profile_contract_validation"]["diagnostics"]
  remains internal evidence
```

Nested diagnostics must not become:

```text
report["diagnostics"]
IgniterLang::Diagnostics
public result diagnostics without wrapper policy
CLI/API public output
loader/report vocabulary
CompatibilityReport vocabulary
```

Proof-local wrapper code:

```text
compiler_profile_contract_refusal.contract_digest_mismatch
```

It remains proof/design vocabulary until a later implementation/public-surface
gate decides otherwise.

---

## Malformed `configuration_error` Target-Shape Requirement

R80 accepted:

```text
malformed strict requirement => configuration_error
```

R81 must specify and verify this target as concretely as the `refused` target.

Required distinctions:

```text
configuration_error is not contract_digest_mismatch
configuration_error is not validator failure
configuration_error is not produced when no strict source exists
configuration_error is not live compiler behavior
configuration_error uses distinct reason from digest mismatch
configuration_error skips assembly only as proof-local target shape
```

Accepted design-only reason code:

```text
compiler_profile_contract_refusal.strict_requirement_malformed
```

This is not `IgniterLang::Diagnostics` and not public/live output unless later
authorized.

---

## Non-Persisting / Artifact Assertions

R81 should assert:

```text
strict-refusal target does not call existing CompilerOrchestrator#refusal
strict-refusal target writes no .compilation_report.json sidecar
strict-refusal target writes no distinct PROP-038 report
strict-refusal target creates no .igapp
strict-refusal target does not call Assembler.assemble_artifacts
existing ordinary refusal paths remain unchanged as live code facts
```

Proof-local model may describe these as target invariants. It must not modify
or intercept current live paths.

---

## Forbidden Live / Public / Persisted / Runtime Surfaces For R81

Closed in R81:

```text
live compiler/orchestrator code changes
live compile refusal
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

Closed public/persistence moves:

```text
changing CLI stdout/stderr/exit behavior
changing public Ruby result shape
changing CompilerResult.public_result
changing CompilerResult.refusal
adding CompilerResult.strict_refusal
writing report sidecars
changing .igapp manifests or compilation_report artifacts
changing loader/report or CompatibilityReport fixtures
```

---

## Pressure Hazards For C2-X

C2-X should pressure-test:

```text
1. Proof-local/live confusion:
   Does the proof imply `refused` is live compiler behavior?

2. CompilerResult mutation:
   Did C1-I edit or imply edits to CompilerResult code/schema?

3. Public key-set leak:
   Does public target include disallowed keys or omit allowlist checks?

4. Nested diagnostics leak:
   Did raw compiler_profile_contract.* diagnostics become public/top-level?

5. Wrapper promotion:
   Did compiler_profile_contract_refusal.* become IgniterLang::Diagnostics?

6. Null report path ambiguity:
   Is compilation_report_path present and null, with clear no-sidecar meaning?

7. Persistence creep:
   Did proof create sidecar/report/.igapp artifacts outside the proof output?

8. Non-persisting path implementation:
   Did the experiment implement an actual orchestrator path?

9. Malformed source weakness:
   Is configuration_error target shape as concrete as refused target shape?

10. No-source regression:
    Does absence of strict source preserve report-only/no-refusal behavior?

11. Provider path regression:
    Do provider nil/non-Hash/error and validator error paths remain no-field/no-refusal?

12. Assembly boundary:
    Does the proof keep report_for_assembly and .igapp boundaries untouched?

13. API/CLI creep:
    Does the proof mention or imply public strict-mode flags/options?

14. Anchor contradiction:
    Does the proof contradict R67/R71/R77 report-only anchors?

15. Runtime language:
    Does the proof imply RuntimeMachine, Gate 3, cache, Ledger/TBackend, or
    production readiness?
```

---

## Safe R81 Output Shape

Safe:

```text
proof-local experiment directory
proof-local target shape builder/checker
summary JSON under experiment out/
public key-set assertion
nested diagnostics isolation assertion
configuration_error target assertion
no sidecar/report/artifact assertion
explicit non-authorizations
track doc
```

Unsafe:

```text
live compiler/orchestrator code changes
CompilerResult code/schema changes
public API/CLI changes
persisted reports or sidecars
.igapp changes
loader/report or CompatibilityReport schema
runtime/production claims
```

---

## One-Line Handoff

Prove the target shape locally; do not shape the live compiler.
