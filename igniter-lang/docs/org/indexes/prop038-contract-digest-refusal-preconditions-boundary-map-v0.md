# PROP-038 Contract Digest Refusal Preconditions Boundary Map v0

Status: active-orientation
Owner: [Org Architect Supervisor]
Source card: `S3-R75-C0-O`
Date: 2026-05-18
Authority: orientation only / non-authority

This map helps R75 agents distinguish compile-refusal precondition design from
enabling refusal, compiler integration, public surfacing, persisted artifacts,
and production authority.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-contract-digest-live-validator-implementation-acceptance-decision-v0.md
igniter-lang/docs/gates/prop038-contract-digest-live-implementation-design-decision-v0.md
igniter-lang/docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
igniter-lang/docs/tracks/stage3-round74-status-curation-v0.md
```

---

## Current Live Validator State

R74 accepted the bounded PROP-038 `contract_digest` live validator
implementation only inside:

```text
IgniterLang::CompilerProfileContractValidator
```

Accepted validator API:

```ruby
validate(contract, digest_reference_policy: :prop038_24_plus)
```

Accepted validator result keys:

```text
compile_refusal_authorized
compiler_integrated
diagnostic_codes
diagnostics
digest_reference_policy
format_version
kind
valid
```

Accepted fixed flags:

```text
compiler_integrated=false
compile_refusal_authorized=false
```

Accepted live internal validator diagnostics:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

These diagnostics are live in the internal validator result. They are not
compile-refusal behavior.

---

## Current Report-Only / No-Refusal Invariants

Accepted R71/R74 invariants:

```text
digest diagnostics remain nested under:
  compiler_profile_contract_validation.diagnostics

top-level report["diagnostics"] remains unchanged
compile status remains ok when source compiles
pass_result remains unchanged
stages remain unchanged
public result remains unchanged
assembler execution remains unchanged
.igapp manifest remains unchanged
refusal report is not written
nil/non-Hash/provider-error paths remain no-field/no-refusal
CompilerResult remains unchanged
```

R75 precondition design must treat these as the current live behavior to
preserve, not as optional history.

---

## Refusal vs Contract-Object Invalidity

PROP-038 states that invalid contract diagnostics are refusal rules for the
contract object only. They do not create compile-time refusal behavior unless a
later implementation card explicitly authorizes that behavior.

Working distinction:

```text
contract-object invalidity:
  validator returns valid=false and contract diagnostics
  result remains internal/report-only under current authority

compile refusal:
  compiler changes compile outcome or writes refusal behavior
  not authorized in R75
```

R75 may ask whether contract-object invalidity should ever become compile
refusal and under what conditions. It may not make that transition.

---

## Allowed R75 Preconditions Design Questions

R75 design may explore:

```text
Which validator diagnostics, if any, are candidates for future compile refusal?
Should refusal require all report-only invariants to remain proven first?
Should refusal require a complete report-only integration proof over live code?
What proof matrix would be required before refusal could open?
What exact compiler/orchestrator touchpoints would need future authorization?
Should refusal be all-or-nothing or phased by diagnostic class?
How should provider nil/non-Hash/provider-error paths behave under any future refusal design?
What user-facing error/report shape would need separate design before surfacing?
What gates must exist before persisted artifacts, loader/report, or CompatibilityReport can observe refusal?
```

R75 design should produce preconditions and blocker questions. It should not
author implementation or public behavior.

---

## Forbidden Implementation / Public / Runtime Surfaces

Closed in R75:

```text
code implementation
compile refusal enablement
compiler/orchestrator changes
public API or CLI widening
CompilerResult changes
persisted success reports or sidecars
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

Closed artifact moves:

```text
new refusal report artifacts
persisted report sidecars
.igapp manifest changes
existing compiler golden migration
loader/report fixture changes
CompatibilityReport fixture changes
```

---

## Refusal Preconditions Candidates

These are orientation candidates only, not authority:

```text
1. Live validator closure accepted.
   R74 is satisfied.

2. Report-only integration remains stable over live validator behavior.
   Diagnostics stay nested and no compile/public/persisted behavior changes.

3. Refusal target is explicitly named.
   A future gate must say whether refusal applies to all contract diagnostics
   or only selected `contract_digest_*` diagnostics.

4. Compiler touchpoint is explicitly named.
   No compiler/orchestrator path can be inferred from validator invalidity.

5. Public/report shape is separately designed.
   Refusal cannot leak through undocumented public/API/CLI/CompilerResult
   behavior.

6. Persisted-artifact policy is separately designed.
   Any refusal report, sidecar, `.igapp`, loader/report, or CompatibilityReport
   behavior needs a new gate.

7. Provider edge cases stay explicit.
   nil, non-Hash, and provider-error behavior must be decided before refusal.

8. No production implication.
   Refusal design does not imply RuntimeMachine, Gate 3, runtime, cache, or
   production readiness.
```

---

## Pressure Hazards For C2-X

C2-X should pressure-test:

```text
1. Name collapse:
   Did "contract-object refusal" get shortened into "compile refusal"?

2. Authority drift:
   Did the design imply compile refusal is already authorized because the
   validator is live?

3. Integration creep:
   Did precondition design sneak in compiler/orchestrator touchpoints without
   a future gate boundary?

4. Public surfacing creep:
   Did diagnostics become CLI/API/CompilerResult/user-facing behavior?

5. Report persistence creep:
   Did report-only nested diagnostics become persisted reports, sidecars,
   loader/report, CompatibilityReport, or `.igapp` changes?

6. Diagnostics centralization creep:
   Did the design move codes into `IgniterLang::Diagnostics`?

7. Edge-case ambiguity:
   Are nil/non-Hash/provider-error paths still no-field/no-refusal under the
   current authority?

8. Proof gap:
   Are future refusal proof requirements specific enough to prevent a jump from
   validator tests directly to compiler behavior?

9. Production language:
   Did the design imply runtime readiness, cache behavior, Gate 3 widening,
   Ledger/TBackend, or production semantics?

10. Phase ordering:
    Does the design preserve the sequence:
    live validator -> report-only proof -> refusal preconditions -> separate
    future refusal authorization?
```

---

## One-Line Handoff

Design refusal preconditions; do not enable refusal.
