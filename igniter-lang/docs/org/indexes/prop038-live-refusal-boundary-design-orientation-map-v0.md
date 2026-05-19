# PROP-038 Live Refusal Boundary Design Orientation Map v0

Status: active-orientation
Owner: [Org Architect Supervisor]
Source card: `S3-R78-C0-O`
Date: 2026-05-19
Authority: orientation only / non-authority

This map helps R78 agents distinguish live-refusal implementation boundary
design from authorizing live refusal, changing compiler behavior, widening
public surfaces, or creating persisted artifacts.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-strict-mode-refusal-trigger-proof-local-acceptance-decision-v0.md
igniter-lang/docs/tracks/stage3-round77-status-curation-v0.md
igniter-lang/docs/gates/prop038-strict-mode-refusal-trigger-design-decision-v0.md
igniter-lang/docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
```

---

## What R77 Proved

R77 accepted a bounded proof-local trigger model:

```text
prop038-strict-mode-refusal-trigger-proof-local-v0
```

Accepted proof result:

```text
status=PASS
cases=12
checks=15
failed_checks=0
```

Accepted proof-local source:

```json
{
  "kind": "compiler_profile_contract_strict_requirement",
  "format_version": "0.1.0",
  "mode": "strict_contract_digest",
  "source": "proof_local_gate",
  "refusal_candidates": ["compiler_profile_contract.contract_digest_mismatch"],
  "recompute_unavailable_policy": "fail_open_report_only",
  "compile_refusal_authorized": false
}
```

Accepted proof-local decision vocabulary:

```text
not_evaluated
allow
would_refuse
configuration_error
```

Accepted proof-local wrapper code:

```text
compiler_profile_contract_refusal.contract_digest_mismatch
```

It cites evidence:

```text
compiler_profile_contract.contract_digest_mismatch
```

Only `contract_digest_mismatch` maps to proof-local `would_refuse`.
`contract_digest_invalid`, `contract_digest_policy_unsupported`, and
`contract_digest_recompute_unavailable` remain held/control/fail-open.

---

## What R77 Did Not Prove

R77 did not prove:

```text
live compiler/orchestrator behavior is safe to change
live compile refusal is authorized
public API/CLI strict mode source is designed
CompilerResult/status model is designed
refusal report behavior is designed
persisted report or sidecar behavior is designed
.igapp or assembler behavior under strict mode is designed
loader/report or CompatibilityReport semantics are designed
runtime or production readiness exists
```

R77 did not introduce:

```text
refused
compile_refusal_authorized=true
compiler_integrated=true
IgniterLang::Diagnostics entries
top-level report diagnostics
public API/CLI output
live compiler status
loader/report vocabulary
CompatibilityReport vocabulary
```

---

## Current Live Baseline

The live baseline remains:

```text
report-only compiler integration
in-memory CompilationReport field only
report_only=true
compiler_integrated=false
compile_refusal_authorized=false
compile status unchanged
pass_result unchanged
stages unchanged
public result unchanged
CompilerResult unchanged
assembler execution unchanged
.igapp unchanged
no refusal report written
```

Provider and failure paths remain:

```text
no provider => no field / no refusal
provider missing call => no field / no refusal
provider returns nil => no field / no refusal
provider returns non-Hash => no field / no refusal
provider raises => no field / no refusal
validator raises => no field / no refusal
existing unrelated compiler failures stay unrelated
```

---

## Remaining Live-Refusal Blockers

Open blockers before any live refusal implementation authorization:

```text
production/compiler strict source
live compiler/orchestrator implementation boundary
Ruby API source shape
CLI source shape
CompilerResult/status model
refusal report behavior
fail-closed policy for recompute unavailable
.igapp / assembly strict-mode boundary
loader/report semantics
CompatibilityReport semantics
runtime readiness semantics
production readiness semantics
golden/artifact mutation policy
public wording and user-facing error contract
proof and regression matrix for live behavior
```

R78 may design these boundaries. R78 may not close them as implementation
authority unless a later Architect gate explicitly does so.

---

## Possible Live Strict Source Categories

Non-authority options for comparison:

```text
1. Internal orchestrator option:
   private constructor/config trigger; closed until later implementation gate.

2. Ruby facade/API option:
   caller-facing Ruby option; public surface remains closed.

3. CLI flag:
   command-line strict mode; CLI widening remains closed.

4. Manifest/profile policy:
   source from manifest/profile material; .igapp/profile policy mutation
   remains closed.

5. Gate-controlled profile requirement:
   authority object bound by gate decision; still requires live source design.

6. Proof-local gate source:
   already proven as model source; not a live source.
```

Design comparison should answer:

```text
where the source is read
who owns the authority
how it is observable
how no-source behaves
how invalid source behaves
how it avoids becoming default refusal
what proof is required before implementation
```

---

## Live Decision Placement Questions

R78 may design where a future live refusal decision would sit relative to:

```text
contract validation provider
CompilerProfileContractValidator result
CompilationReport report-only annotation
pass_result
assembly input report_for_assembly
public result shaping
CompilerResult construction
refusal report generation
```

Current safe default:

```text
report-only annotation stays before any hypothetical refusal decision
assembler receives report_for_assembly captured before annotation
public result remains unchanged
```

Any future design that changes this order needs explicit implementation
authorization later.

---

## Forbidden Implementation / Public / Persisted / Runtime Surfaces For R78

Closed in R78:

```text
code implementation
live compile refusal
proof-local code changes
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

Closed vocabulary promotions:

```text
would_refuse -> refused
compiler_profile_contract_refusal.* -> IgniterLang::Diagnostics
proof_local_gate -> live strict source
compiler_refusal_decision -> live compiler status
loader_report_status -> loader/report behavior
runtime_readiness -> runtime behavior
```

---

## Pressure Hazards For C3-X

C3-X should pressure-test:

```text
1. Proof-to-production jump:
   Does R77 proof-local success get treated as live refusal readiness?

2. Source-category promotion:
   Does a candidate live strict source become accepted authority without a gate?

3. Public-surface creep:
   Do Ruby API or CLI source options become implementation-ready surfaces?

4. CompilerResult creep:
   Does status/refusal design imply actual CompilerResult field changes?

5. Refusal-report creep:
   Does design imply persisted reports, sidecars, .ilk, receipts, signing, or
   golden/artifact mutation?

6. Assembly/.igapp creep:
   Does strict mode affect assembler behavior or .igapp manifests?

7. Loader/report and CompatibilityReport creep:
   Do closed status vocabularies become accepted schema?

8. Vocabulary promotion:
   Does `would_refuse` become `refused`, or wrapper code become live diagnostic
   vocabulary?

9. Default-refusal hazard:
   Does absence of strict source accidentally become fail-closed behavior?

10. Recompute-unavailable hazard:
    Does fail-open/report-only become fail-closed without operational recovery
    design?

11. No-field path regression:
    Are nil/non-Hash/provider-error/validator-error paths still no-field and
    no-refusal under current live behavior?

12. Runtime language:
    Does the design imply RuntimeMachine, Gate 3, cache, Ledger/TBackend, or
    production behavior?

13. Phase ordering:
    Does the design preserve:
    proof-local model -> live boundary design -> separate implementation
    authorization -> implementation proof?
```

---

## Safe R78 Output Shape

Safe:

```text
remaining blocker map
source category comparison
decision placement design
CompilerResult/status/refusal-report options as future design only
proof/regression requirements
explicit non-authorizations
```

Unsafe:

```text
implementation card opened directly
live refusal authorized
compiler/orchestrator behavior changed
public API/CLI source accepted as live
persisted artifacts introduced
runtime/production claims
```

---

## One-Line Handoff

Design the live refusal boundary; do not cross it.
