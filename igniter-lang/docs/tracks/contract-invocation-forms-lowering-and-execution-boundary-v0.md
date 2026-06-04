# Contract Invocation Forms Lowering and Execution Boundary v0

Track:     `contract-invocation-forms-lowering-and-execution-boundary-v0`
Status:    design-boundary
Date:      2026-06-04
Route:     S3-R249-C1-D
Authority: no implementation authority; no canonical syntax authority

---

## 1. Purpose

This document establishes the design specification and lowering boundary for the contract invocation form system. It aligns the experimental findings of the Rust compiler proof (`LAB-FORMS-P2`) with the canonical requirements of the Igniter multi-contract runtime.

The core focus of this route (`S3-R249-C1-D`) is defining:
1.  **Canonical vs. DX syntax** options for declaring forms.
2.  **Type-directed candidate filtering** during resolution.
3.  **Strict fail-closed ambiguity policy** (`E-FORM-AMBIG`).
4.  **Lowering pass mechanics** (rewriting AST to explicit `Call` or `ContractInvocation` targets).
5.  **Initial runtime stance** (inlining / monomorphization, deferring VM linking).

---

## 2. Syntax & DX Specification

### 2.1. Canonical Explicit Form
The explicit pattern binding remains the authoritative, structural definition for registering form elements:

```igniter
contract Add[T: Numeric](left: T, right: T) -> result: T
  form (left) "+" (right)
  priority 5
  associativity :left
```

### 2.2. `form:` DX Sugar Candidate
To reduce boilerplate for standard symbolic operators, we introduce the `form:` shorthand as a parser-level candidate:

```igniter
contract Add[T: Numeric](left: T, right: T) -> result: T
  form: +
  priority 5
```

**Desugaring Rules:**
*   The parser maps `form: +` to the canonical positional arguments of the contract. For a binary signature `(A, B)`, it desugars into `form (param_1) "+" (param_2)`.
*   If the contract has fewer or more than two parameters, using `form: +` (infix sugar) is rejected with `E-FORM-STRUCT`.

---

## 3. Type-Directed Candidate Filter

Resolution must run post-typecheck, utilising operand types to narrow candidates. 

```
[Expression: a + b] 
       │
       ▼
1. Fetch Trigger Index (op: "+") ────────► Candidates: [Add, Concat, MatrixAdd]
       │
       ▼
2. Resolve Operand Types ────────────────► a: Vector3, b: Vector3
       │
       ▼
3. Match Signatures/Traits (PROP-016) ───► Filtered: [MatrixAdd] (resolved to Vector3)
       │
       ▼
4. Target Lowering ──────────────────────► MatrixAdd(a, b)
```

### Resolution Algorithm:
1.  **Trigger Filter**: Look up the symbol (e.g. `+`) in the `FormRegistry` to retrieve all candidate entries.
2.  **Type Filter**: For the target expression node (e.g. `BinaryOp { left, right }`), check the resolved type tags of the arguments (`left_type`, `right_type`).
    *   Compare the operand types against the parameter types of the candidate contract.
    *   If the candidate contract is generic (e.g. `Add[T: Additive]`), resolve the trait bounds (`Additive[Vector3]`) using the typechecker's monomorphization table.
3.  **Scope/Import Filter**: Apply `hiding` and `overriding` import constraints of the current module.
4.  **Trust/Priority Filter**: Sort remaining candidates by priority and trust levels.

---

## 4. Strict Ambiguity Policy (`E-FORM-AMBIG`)

> [!CRITICAL]
> Declaration order must never dictate language semantics. real ambiguity must fail-closed.

If, after type-directed filtering, scope resolution, and priority sorting, multiple candidates remain for a trigger, the compiler **must** refuse compilation with error `E-FORM-AMBIG`.

```
-- Example of Ambiguous Triggers:
contract FloatAdd(left: Float, right: Float) -> Float { form (left) "+" (right) }
contract CustomAdd(left: Float, right: Float) -> Float { form (left) "+" (right) }

-- In Use:
x + y  -- ERROR: E-FORM-AMBIG (matches both FloatAdd and CustomAdd with equal priority)
```

### Corrective Actions:
*   The user must bypass form resolution by using an explicit call: `FloatAdd(x, y)`.
*   Alternatively, the user must use module imports with overriding policies to select a winner at the namespace boundary:
    ```igniter
    import FloatAdd overriding (+)
    ```

### Warnings vs. Errors:
*   `W-FORM-SHADOWED`: Emitted only if a higher-priority or higher-trust form shadows a lower-priority candidate. Compilation succeeds.
*   `E-FORM-AMBIG`: Raised if equal-precedence candidates survive type filtering. Compilation fails.

---

## 5. Lowering Target & AST Rewriting

Forms must disappear entirely before bytecode compilation. The compiler introduces a dedicated **Lowering Pass** after typecheck.

```diff
- Expr::BinaryOp { op: "+", left: a, right: b }
+ Expr::ContractInvocation { contract: "stdlib.Numeric.Add", args: [a, b] }
```

*   The output `semantic_ir_program.json` in the `.igapp` archive must contain **only explicit nodes** (`ContractInvocation` or `Call`).
*   Any presence of unresolved trigger symbols (like `+` or `.sum` that are not compiler primitives) in the final SemanticIR will fail static validation checks (`SIR-2: no_unresolved_trait_method_calls`).

---

## 6. First Runtime Stance: Monomorphization / Inlining

To keep the VM simple, robust, and free of dynamic resolution complexities, the first mainline implementation adopts an **inlining/monomorphization** strategy:

```
[Contract Caller] 
       │ (lowered)
       ▼
[Call: Add(left, right)] 
       │ (inliner pass)
       ▼
[Inlined Add compute nodes into Caller graph]
       │
       ▼
[Flat Bytecode Instructions compiled by VM Compiler]
```

### Invariants:
1.  **No VM Form Tables**: The VM has no knowledge of the form registry or form resolution traces. It only executes bytecode.
2.  **Inlined Subroutines**: The compiler flattens called contracts directly into the caller's compute node list during assembly.
3.  **Deferred Linking**: A VM stack frame/linker that dynamically resolves and jumps to separate contract bytecode blocks is deferred to later stages.

---

## 7. Closed Surfaces & Non-Goals

The following boundaries remain closed under `S3-R249-C1-D`:
*   **No VM Bytecode changes**: The VM execution loop is untouched.
*   **No production gem release**: All changes are confined to the `igniter-lang` workspace.
*   **No stable API or public grammar claims**: Syntax structures remain experimental.
