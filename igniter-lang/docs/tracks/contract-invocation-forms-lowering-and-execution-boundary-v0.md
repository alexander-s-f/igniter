# Contract Invocation Forms Lowering and Execution Boundary v0

Card: S3-R250-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: contract-invocation-forms-lowering-and-execution-boundary-v0
Route: UPDATE
Status: done / design-ready
Date: 2026-06-04

Depends on:
- S3-R248-C5-S
- LAB-FORMS-P4

---

## Decision

Design-ready with implementation held.

Decision:

```text
accept LAB-FORMS-P4 as preflight evidence
accept contract invocation forms lowering as a design boundary
do not authorize implementation yet
route C4-A to accept boundary and choose a proof/design next step
```

This document replaces the lab-self-issued preflight stance with an
Architect-owned boundary. It does not make lab behavior canonical and does not
authorize parser, TypeChecker, SemanticIR, runtime, API, CLI, package, stable
grammar, public API, public runtime support, Reference Runtime support,
production, Spark, release, public demo, performance, certification, or
portability claims.

---

## Authority Boundary

Accepted as evidence:

```text
contract-invocation-forms-memory-recovery-and-dx-boundary-v0
LAB-FORMS-P1 enhanced proof
LAB-FORMS-P2 hardening proof
LAB-FORMS-P4 lowering preflight
forms_analysis_and_execution_gaps
PROP-016 polymorphism / traits / contract shapes
source/polymorphic_add.ig as parser-only pressure
```

Not accepted:

```text
stable grammar
canonical `form:` syntax
parser implementation authority
TypeChecker implementation authority
SemanticIR lowering implementation authority
runtime support
VM linker support
public runtime support
Reference Runtime support
public API
production readiness
Spark integration
release evidence
public demo evidence
public performance evidence
official/reference status
alternative certification
portability guarantee
lab behavior as canon
```

This C1-D changed only:

- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-and-execution-boundary-v0.md`

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round248-status-curation-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-memory-recovery-and-dx-boundary-v0.md`
- `playgrounds/igniter-lab/.agents/LAB-FORMS-P1.md`
- `playgrounds/igniter-lab/.agents/LAB-FORMS-P2.md`
- `playgrounds/igniter-lab/.agents/LAB-FORMS-P4.md`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-enhanced-proof-v0.md`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-hardening-proof-v0.md`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-lowering-preflight-v0.md`
- `playgrounds/igniter-lab/lab-docs/forms_analysis_and_execution_gaps.md`
- `playgrounds/igniter-lab/igniter-compiler/out/lab_contract_invocation_forms_hardening_proof/summary.json`
- `playgrounds/igniter-lab/igniter-compiler/src/form_resolver.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/typechecker.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/emitter.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/assembler.rs`
- `igniter-lang/source/polymorphic_add.ig`
- `igniter-lang/docs/proposals/PROP-016-polymorphism-traits-contract-shapes-v0.md`

---

## Design Boundary

### 1. Vocabulary

Keep constructor forms and invocation forms separate.

| Term | Meaning | Status |
| --- | --- | --- |
| Constructor form | Names a typed artifact/constructor over a declared type. | Existing current-doc pressure; not this route's main target. |
| Contract invocation form | Names a source spelling for invoking an already declared contract. | This route's design target. |

Boundary phrase:

```text
Constructor forms name typed artifacts.
Invocation forms name ways to call contracts.
Neither creates meaning; both must lower to explicit typed constructs.
```

### 2. Baseline Syntax

The strongest baseline specimen remains:

```igniter
contract Add[T: Additive](left: T, right: T) -> result: T
  form (left) "+" (right)
```

Status:

```text
baseline syntax candidate
not stable grammar
not parser implementation authority
```

Rationale:

- it binds source positions to contract parameters explicitly;
- it is audit-friendly;
- it avoids hiding parameter binding behind shorthand before proposal review.

### 3. `form:` DX Sugar

`form:` remains a DX sugar candidate only.

Examples such as:

```igniter
form: +
```

may be discussed as shorthand over the explicit baseline, but this C1-D does not
accept them as canonical grammar.

Decision:

```text
form: is pleasant DX pressure
form: is not canonical syntax
form: must not be implemented before proposal/boundary acceptance
```

### 4. Current Lab Status

LAB-FORMS-P2/P4 show the current lab posture accurately:

```text
semantic_ir_lowering_status = sidecar_resolution_only
```

Current lab evidence:

- parser recognizes form declarations;
- FormRegistry and FormResolver exist;
- `form_table.json` and `form_resolution_trace.json` are emitted as sidecars;
- `E-FORM-AMBIG` refuses ambiguity with no winner;
- `no_form` fail-closed behavior is demonstrated;
- explicit calls bypass form resolution and remain visible in trace;
- `+` and `++` are separate triggers;
- SemanticIR still contains `binary_op` nodes;
- no `ContractInvocation` / `Call` lowering is produced in SemanticIR.

Therefore:

```text
lab forms prove a useful trust-boundary slice
lab forms do not prove execution lowering
lab forms do not prove runtime support
```

### 5. Type-Directed Dispatch

Type-directed candidate filtering is required before implementation
authorization.

Required future pipeline:

```text
parse type-blind source expression
typecheck expression operands
build form candidate set by trigger
filter by operand/result types and trait bounds
apply import hiding/overriding
apply priority/trust policy
lower to explicit call or refuse
```

Without type-directed dispatch:

- `P4` remains sidecar evidence, not lowered IR fact;
- true `unresolved_form_error` cannot be distinguished from primitive
  pass-through or missing trigger cases;
- String `+` rejection relies on a separate typechecker gate rather than a
  form-resolution gate;
- generic `Add[T: Additive]` cannot safely resolve from form syntax.

### 6. PROP-016 Relationship

Forms should sit above the PROP-016 type/trait layer, not replace it.

Design stance:

```text
traits and contract shapes define meaning
forms expose a typed source spelling for that meaning
monomorphization removes unresolved polymorphism before runtime
```

For `Add`:

```text
`+` should initially remain numeric/Additive only
String/Collection concatenation should use `++` or explicit stdlib calls
unless a later stdlib/operator policy route changes that
```

### 7. Ambiguity Policy

`E-FORM-AMBIG` remains hard error after type filtering.

Decision:

```text
declaration order must never choose a semantic winner
equal-precedence surviving candidates refuse compilation
explicit contract calls remain the disambiguation escape hatch
```

Priority or trust may shadow lower-ranked candidates only when the policy is
explicit and auditable. That shadowing policy is not implementation authority in
this card.

### 8. Primitive Pass-Through and Unresolved Trigger

LAB-FORMS-P2 correctly separates:

| Case | Meaning | First stance |
| --- | --- | --- |
| `primitive_pass_through` | Known language primitive has no form candidate. | Not an error by itself. |
| `unresolved_trigger` | Unknown trigger has no form candidate. | Candidate diagnostic path. |
| `unresolved_form_error` | Trigger exists, but no candidate survives type/scope filtering. | Deferred until type-directed dispatch exists. |

This route accepts the classification as design evidence only.

### 9. Import Hiding / Overriding

Import hiding/overriding parsing is lab evidence, but enforcement is not proven.

Future implementation must decide:

```text
where scope tables live
how forms enter module scope
whether overriding is import-boundary only
how hidden forms appear in diagnostics/evidence
```

Do not implement resolution until C2-P1/C4-A have confirmed the current surface
facts and a later route authorizes the implementation boundary.

### 10. Lowering Target

Forms should lower before runtime / VM execution.

Preferred target:

```text
ContractInvocation or Call
```

Required invariant:

```text
after lowering, SemanticIR must not retain form-trigger meaning
```

Sidecar artifacts may remain useful for audit:

- `form_table.json`;
- `form_resolution_trace.json`;
- lowered call trace / selection evidence.

But sidecars are not a substitute for lowered IR facts.

### 11. First Runtime Stance

Prefer compile-time inlining / monomorphization before VM linker work.

First runtime stance:

```text
lower form syntax to explicit calls
resolve trait/generic contracts
monomorphize concrete contract targets
inline called graphs before VM bytecode
```

This keeps the VM simple and avoids turning forms into runtime dispatch.

### 12. Deferred Runtime Stance

VM dynamic linker / subroutine frames remain deferred.

Deferred work includes:

- contract registry loading inside VM;
- `OP_CALL` dispatch to user contracts;
- stack frames for contract calls;
- return-value binding across contract frames;
- VM-level dynamic dispatch/linking.

None of that opens from this C1-D.

---

## Compact Forms Lowering Boundary Matrix

| Surface | Status | C1-D stance |
| --- | --- | --- |
| LAB-FORMS-P4 | Accepted | Preflight evidence only. |
| Invocation form concept | Accepted | High-priority design input. |
| Constructor form concept | Separate | Do not merge silently. |
| `form (left) "+" (right)` | Baseline candidate | Stronger explicit syntax specimen. |
| `form:` | Candidate | DX sugar only; not canonical. |
| Parser type-blindness | Accepted invariant | Parser should not do type dispatch. |
| Type-directed dispatch | Required | Main blocker before implementation. |
| `E-FORM-AMBIG` | Accepted policy | Hard error; no declaration-order winner. |
| Primitive pass-through | Accepted classification | Not a security fail-closed claim. |
| `unresolved_form_error` | Deferred | Requires type filter. |
| Import hiding/overriding | Gap | Parse evidence exists; enforcement unproven. |
| SemanticIR lowering | Required future target | Sidecar-only is insufficient. |
| Sidecar artifacts | Evidence | Useful audit/support packets, not IR facts. |
| PROP-016 traits | Required relationship | Forms resolve through traits/monomorphization. |
| `+` policy | Conservative | Numeric/Additive only first; `++` separate. |
| Inlining/monomorphization | Preferred first runtime stance | Before VM linker. |
| VM linker/subroutine frames | Deferred | Not next implementation default. |
| Runtime form dispatch | Closed | Forms disappear before runtime. |
| Stable grammar/API | Closed | Pre-v1; no promise. |
| Lab behavior as canon | Closed | Frontier evidence only. |

---

## Route Options

### Option A: Forms Lowering Implementation Authorization Review

Hold for now.

Reason:

```text
type-directed dispatch and current-surface facts need C2-P1/C3-X/C4-A closure
before implementation can be safely scoped
```

### Option B: Type-Directed Dispatch Proof-Local Route

Candidate next route if C4-A wants more evidence before implementation.

Would prove:

- expression-level resolved type availability;
- candidate filtering by parameter type;
- generic `Add[T: Additive]` handling;
- `unresolved_form_error`;
- `E-FORM-AMBIG` after filtering.

### Option C: SemanticIR Lowering Proof-Local Route

Candidate next route if type facts are already sufficient.

Would prove:

- `BinaryOp` / field / method form lowering to `Call` or `ContractInvocation`;
- no form-trigger leakage into SemanticIR;
- sidecar evidence remains audit-only;
- no runtime form dispatch.

### Option D: Proposal / Errata Authoring Route

Useful if C4-A decides syntax and vocabulary need formal proposal text before
any proof-local compiler work.

Recommended if there is disagreement about:

- constructor forms vs invocation forms;
- `form:` sugar;
- FormKind first slice;
- OOF diagnostic names.

### Option E: Stdlib / Operator Policy Route

Hold as separate route.

Only needed if C4-A wants to revisit `+` numeric-only policy or introduce
stdlib-wide form registration.

### Option F: Pause

Not recommended. LAB-FORMS-P4 gives enough evidence to keep moving through a
bounded design/proof route.

---

## Explicit Answers

### Is LAB-FORMS-P4 accepted as preflight evidence?

Yes. LAB-FORMS-P4 is accepted as preflight evidence only.

### Is `form:` canonical syntax?

No. `form:` is a DX sugar candidate only.

### Does `form (left) "+" (right)` remain the stronger baseline syntax candidate?

Yes. It remains the stronger baseline specimen because it makes parameter
binding explicit.

### Should forms lower before runtime / VM execution?

Yes. Forms should lower before runtime. The VM should not know about forms.

### Is type-directed dispatch required before implementation?

Yes. Type-directed candidate filtering is the primary blocker before mainline
implementation authorization.

### Does `E-FORM-AMBIG` remain hard error after filtering?

Yes. Ambiguity after filtering must refuse compilation.

### May declaration order choose a winner?

No. Declaration order must not decide semantic meaning.

### Should inlining/monomorphization precede VM linker work?

Yes. The first runtime stance should prefer compile-time inlining and
monomorphization.

### Does VM linker / subroutine frame work remain deferred?

Yes.

### May implementation authorization open next?

Not directly from C1-D. C4-A may choose a future implementation authorization
review only if C2-P1/C3-X show the boundary is tight enough. The safer
recommendation is a proof-local type-directed dispatch or SemanticIR lowering
route before live implementation.

### Does lab behavior create canonical authority?

No. Lab behavior remains frontier evidence only.

### Do protected claims remain closed?

Yes. Public runtime, stable grammar/API, production, public demo, Reference
Runtime, Spark, release, public performance, official/reference,
certification, and portability claims remain closed.

---

## Exact C4-A Recommendation

Recommended C4-A decision:

```text
accept forms lowering boundary
accept LAB-FORMS-P4 as preflight evidence only
keep implementation held
route either type-directed dispatch proof-local route or SemanticIR lowering
proof-local route next, depending on C2-P1/C3-X facts
```

Preferred next route before implementation:

```text
contract-invocation-forms-type-directed-dispatch-proof-v0
```

Fallback next route if facts show typed-expression data is already sufficient:

```text
contract-invocation-forms-semanticir-lowering-proof-v0
```

Future implementation authorization may open only after a narrow proof/design
route resolves:

- expression-level type annotation access;
- generic/trait monomorphization relationship;
- import hiding/overriding enforcement;
- `E-FORM-AMBIG` after type filtering;
- `unresolved_form_error` semantics;
- lowered `Call` / `ContractInvocation` shape;
- no form-trigger leakage into SemanticIR;
- no runtime form dispatch;
- sidecar artifact status.
