# PROP-038 Contract Digest Strict Mode Refusal Trigger Boundary Map v0

Status: active-orientation
Owner: [Org Architect Supervisor]
Source card: `S3-R76-C0-O`
Date: 2026-05-19
Authority: orientation only / non-authority

This map helps R76 agents distinguish strict-mode/refusal trigger design from
enabling compile refusal, changing compiler/orchestrator behavior, widening
public surfaces, or creating persisted artifacts.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-contract-digest-compile-refusal-preconditions-decision-v0.md
igniter-lang/docs/tracks/stage3-round75-status-curation-v0.md
igniter-lang/docs/gates/prop038-contract-digest-live-validator-implementation-acceptance-decision-v0.md
igniter-lang/docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
```

---

## Current Authority Snapshot

R75 accepted compile-refusal preconditions design and kept refusal closed.

Current accepted separation:

| Layer | Current status |
| --- | --- |
| Contract-object invalidity | Live in internal validator result. |
| Report-only validation diagnostics | Live as nested in-memory report metadata. |
| Compiler compile refusal | Closed. Not authorized. |
| Loader/report status | Separate vocabulary. Not opened. |
| Runtime/production readiness | Separate runtime gates. Not opened. |

Accepted core rule:

```text
compiler_profile_contract.* diagnostic != compile refusal
```

R76 may design strict source and refusal wording. It may not implement or enable
strict behavior.

---

## What Strict Mode May Mean As Design Vocabulary Only

In R76, "strict mode" may be used only as candidate design vocabulary for a
future refusal trigger. It may describe a possible future condition under which
contract digest validation could become compile-refusal evidence.

Allowed design meanings:

```text
explicit strict profile/contract requirement source
explicit caller/config/profile trigger category
explicit compiler-level refusal wording candidate
explicit fail-open/fail-closed policy option
explicit proof-local strict-mode matrix proposal
```

Not allowed meanings:

```text
runtime flag already exists
compiler already refuses
CLI/API already exposes strict mode
CompilerResult already carries strict/refusal fields
loader/report or CompatibilityReport already sees strict mode
strict mode is production behavior
```

Naming hazard:

```text
strict mode != strict_registries
```

PROP-038 `strict_registries` are contract object ownership structures. R76
strict mode is only a candidate future refusal trigger concept.

---

## Report-Only / No-Refusal Invariants Still Active

Current live behavior remains report-only:

```text
validator diagnostics may be emitted
digest diagnostics stay nested under
  compiler_profile_contract_validation.diagnostics
top-level report["diagnostics"] remains unchanged
compile status remains unchanged
pass_result remains unchanged
stages remain unchanged
public result remains unchanged
CompilerResult remains unchanged
assembler execution remains unchanged
.igapp manifest remains unchanged
refusal report is not written
nil/non-Hash/provider-error/validator-error paths remain no-field/no-refusal
```

Accepted fixed validator/report flags remain:

```text
compiler_integrated=false
compile_refusal_authorized=false
report_only=true
```

Any R76 design must preserve these as current behavior. It can propose what
future proof would be needed to change them; it cannot change them.

---

## Possible Trigger-Source Categories

These are non-authority options for design exploration only:

```text
1. Contract object field:
   A future field inside compiler_profile_contract declares strict digest
   expectations.

2. Compiler profile descriptor:
   A future descriptor or profile-level policy declares strict digest handling.

3. Finalized compiler_profile_source:
   A future finalized source object carries a strict/refusal trigger.

4. Orchestrator configuration:
   A future internal constructor/config option requests strict behavior.

5. CLI/API caller intent:
   A future public caller flag or API option requests strict behavior.

6. Test/proof-local harness only:
   A proof-local trigger demonstrates refusal semantics without public surface.
```

R76 should evaluate these as design categories, not accepted surfaces. Public
CLI/API, orchestrator config, and contract object shape changes remain closed
unless later opened by Architect decision.

---

## Candidate Refusal Evidence Classes

R75 status to preserve:

| Diagnostic | R75 future-candidate status |
| --- | --- |
| `contract_digest_mismatch` | Strongest conditional future candidate, not enabled. |
| `contract_digest_invalid` | Possible strict-mode candidate, not enabled. |
| `contract_digest_recompute_unavailable` | Held by default. |
| `contract_digest_policy_unsupported` | Not refusal by default. |

Orientation note:

```text
contract_digest_mismatch
  strongest future candidate because it is a proven identity contradiction
  after successful recomputation.

contract_digest_recompute_unavailable
  held by default because it may be validator/canonicalizer capability failure,
  not caller contract invalidity.
```

R76 may refine wording and trigger preconditions. It must not turn any row into
active compile-refusal behavior.

---

## Forbidden Surfaces For R76

Closed in R76:

```text
code implementation
proof-local refusal implementation
enabling compile refusal
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
new refusal report artifacts
persisted report sidecars
.igapp manifest changes
existing compiler golden migration
loader/report fixture changes
CompatibilityReport fixture changes
public CLI/API examples that imply live support
```

---

## Likely Pressure Hazards For C3-X

C3-X should pressure-test:

```text
1. Strict vocabulary inflation:
   Does "strict mode" become an implied implemented feature?

2. strict_registries confusion:
   Does design confuse future strict-mode refusal trigger with PROP-038
   strict registry ownership structures?

3. Trigger-source authority drift:
   Does a candidate source category become accepted without a gate?

4. Public-surface creep:
   Does CLI/API caller intent become exposed or documented as live behavior?

5. Orchestrator creep:
   Does internal configuration become an actual constructor/API change?

6. Refusal enablement:
   Does design change compile outcome, refusal-report behavior, or
   `compile_refusal_authorized` semantics?

7. Report-only regression:
   Do top-level diagnostics, public result, CompilerResult, `.igapp`, stages, or
   pass_result change in the wording?

8. Recompute-unavailable fail-closed jump:
   Does an operational capability failure become a compile-breaking error
   without recovery wording?

9. Proof-local overreach:
   Does a proposed proof matrix quietly implement refusal behavior?

10. Persisted artifact creep:
    Does the design create sidecars, loader/report status, CompatibilityReport,
    receipts, `.ilk`, signing, or production claims?

11. Wrapper-code ambiguity:
    If compiler-level wrapper codes are proposed, are they clearly future
    wording candidates and not current `IgniterLang::Diagnostics` entries?

12. Phase ordering:
    Does the design preserve the route:
    report-only live behavior -> strict trigger design -> proof-local refusal
    matrix proposal -> separate future authorization?
```

---

## Next-Route Guardrail

Safe R76 output shape:

```text
strict trigger source options
refusal wording candidates
fail-open/fail-closed policy options
proof-local matrix proposal
open blockers
explicit non-authorizations
```

Unsafe R76 output shape:

```text
implementation card without another Architect gate
live compiler/orchestrator changes
public CLI/API strict mode
persisted reports or sidecars
compile refusal enabled
```

---

## One-Line Handoff

Design strict-mode triggers; do not create the switch.
