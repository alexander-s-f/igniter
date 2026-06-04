# Contract Invocation Forms Lowering Boundary Pressure v0

Card: S3-R250-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: contract-invocation-forms-lowering-boundary-pressure-v0
Route: REVIEW
Status: done / accept
Date: 2026-06-04

Depends on:
- S3-R250-C1-D
- S3-R250-C2-P1

---

## Verdict

Pressure verdict:

```text
ACCEPT
```

C1-D and C2-P1 keep the forms lowering lane inside design/facts authority.
They accept LAB-FORMS-P4 as preflight evidence only, preserve implementation
closure, and correctly identify type-directed dispatch as the next blocking
semantic proof before any mainline lowering implementation.

No hold or redirect is required before C4-A.

---

## Inputs Reviewed

```text
igniter-lang/docs/tracks/
  contract-invocation-forms-lowering-and-execution-boundary-v0.md
igniter-lang/docs/tracks/
  contract-invocation-forms-lowering-current-surface-facts-v0.md
igniter-lang/docs/tracks/
  contract-invocation-forms-memory-recovery-and-dx-boundary-v0.md
playgrounds/igniter-lab/.agents/LAB-FORMS-P4.md
playgrounds/igniter-lab/lab-docs/
  lab-contract-invocation-forms-lowering-preflight-v0.md
playgrounds/igniter-lab/lab-docs/
  lab-contract-invocation-forms-hardening-proof-v0.md
playgrounds/igniter-lab/igniter-compiler/out/
  lab_contract_invocation_forms_hardening_proof/summary.json
igniter-lang/docs/cards/S3/S3-R250.md
```

---

## Pressure Matrix

| Check | Verdict | Note |
| --- | --- | --- |
| `form:` canonical overclaim | PASS | C1-D says `form:` is DX sugar pressure only, not canonical syntax or implementation authority. |
| Explicit `form (left) "+" (right)` | PASS | C1-D demotes this to strongest baseline specimen/candidate, not stable grammar. |
| Lab-to-canon leakage | PASS | LAB-FORMS evidence remains lab-frontier/preflight only; C1-D explicitly rejects lab behavior as canon. |
| Sidecar evidence vs SemanticIR facts | PASS | C1-D/C2-P1 preserve `sidecar_resolution_only`; sidecars show intent, not IR lowering. |
| Type-directed dispatch | PASS | C1-D and C2-P1 identify operand/result type filtering as required before implementation authorization. |
| `E-FORM-AMBIG` policy | PASS | Ambiguity remains hard error after filtering; no winner is selected. |
| Declaration-order tie-breaker | PASS | Declaration order is explicitly rejected as a semantic winner. |
| Primitive pass-through / unresolved trigger | PASS | Classification is accepted as design evidence; true `unresolved_form_error` is deferred until type filtering exists. |
| Import hiding/overriding | PASS | Parse evidence exists, enforcement unproven; future implementation must wire scope tables. |
| Lowering target | PASS | Future target is explicit `ContractInvocation` / `Call`; no form-trigger meaning may leak into SemanticIR. |
| Inlining/monomorphization before VM | PASS | First runtime stance is compile-time graph inlining / monomorphization before bytecode. |
| VM linker | PASS | Dynamic linker, subroutine frames, registry loading, and runtime dispatch remain deferred. |
| Implementation authority | PASS | Parser, TypeChecker, SemanticIR, runtime, API/CLI/package changes remain closed. |
| Public/stable/runtime claims | PASS | Stable grammar/API, public runtime, Reference Runtime, production, Spark, release, performance, certification, and portability claims remain closed. |

---

## Claim-Risk Notes

No blocking authority drift found.

Non-blocking risks for C4-A to record:

1. LAB-FORMS-P4 says "canonical syntax remains explicit `form (left) \"+\"
   (right)`" in one preflight row. C1-D correctly narrows this to "baseline
   syntax candidate" and "not stable grammar." C4-A should use the C1-D wording,
   not the stronger lab shorthand.
2. C2-P1 says the lab "fully parses" explicit form declarations. That is a lab
   implementation fact only. It must not be read as mainline parser support or
   stable grammar.
3. Sidecar artifacts on OOF are useful evidence but not a persistence/report
   policy. C4-A should not open sidecar/report/artifact-schema authority from
   this boundary.
4. SemanticIR lowering should not open before type-directed dispatch is proven,
   unless C4-A explicitly chooses a very narrow design-only lowering route.

These are record items, not blockers.

---

## C4-A Recommendation

Exact recommendation:

```text
ACCEPT forms lowering boundary
ACCEPT C2-P1 as facts-only current-surface evidence
ACCEPT LAB-FORMS-P4 as lab-frontier preflight evidence only
KEEP implementation held
OPEN type-directed dispatch proof-local route next
```

C4-A should explicitly record:

```text
form: remains DX sugar candidate only
explicit form (left) "+" (right) remains baseline candidate only
no canonical/stable syntax is accepted
sidecar resolution evidence is not SemanticIR lowering fact
type-directed dispatch is required before implementation authorization
E-FORM-AMBIG remains hard error after filtering
declaration order must not choose semantic winners
primitive_pass_through is not a fail-closed security claim
unresolved_form_error remains deferred until type filtering exists
forms must lower to explicit Call or ContractInvocation before runtime
SemanticIR must not retain form-trigger meaning after lowering
inlining/monomorphization should precede VM linker work
VM linker/subroutine frames remain deferred
lab behavior is not canon
parser/typechecker/SemanticIR/runtime/API/CLI/package authority remains closed
stable grammar/API, public runtime, Reference Runtime, production, Spark,
release, performance, official/reference status, certification, and portability
claims remain closed
```

Recommended next route:

```text
contract-invocation-forms-type-directed-dispatch-proof-v0
```

Recommended boundary for that route:

```text
proof-local/design route only
prove expression-level type availability for form resolution
prove candidate filtering by operand/result types and trait bounds
prove E-FORM-AMBIG after type filtering
prove unresolved_form_error classification
preserve sidecar evidence as audit-only
do not authorize mainline parser/typechecker/SemanticIR implementation
do not authorize VM linker or runtime dispatch
do not create stable/public/runtime/release/performance/certification claims
```

Fallback if C4-A chooses not to open a proof route:

```text
contract-invocation-forms-proposal-errata-authoring-v0
```

Use the fallback only if C4-A decides syntax/vocabulary must be formalized
before proving type-directed dispatch.
