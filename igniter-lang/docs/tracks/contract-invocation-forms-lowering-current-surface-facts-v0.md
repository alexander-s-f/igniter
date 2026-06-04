# Track: contract-invocation-forms-lowering-current-surface-facts-v0

Date:    2026-06-04
Card:    S3-R250-C2-P1
Depends: S3-R250-C1-D
Status:  complete
Result:  pass (Current-surface facts curated)
Route:   REPORT

*Implementation Surface Surveyor report. Devkit current-surface evidence only.*
*No canonical syntax authority or implementation authority is claimed.*

---

## 1. Current Surface Facts & Status

This document reports the current implementation facts for the contract invocation form system, comparing the experimental lab-local Rust compiler (`igniter-lab/igniter-compiler`) with the mainline Ruby compiler (`igniter-lang/lib/igniter_lang/`).

### 1.1. Parser & Registry Status
*   **Lab Compiler (Rust)**: Fully parses explicit form declarations (`form (left) "+" (right)`), priority, associativity, and the `no_form` modifier on contracts. It builds a `FormRegistry` index mapping trigger tokens (e.g. `+`) to structural elements and kind.
*   **Mainline Compiler (Ruby)**: Zero parser support for the `form` keyword, `no_form` contract modifier, or `contract_shape` form templates.

### 1.2. Sidecar vs. Lowering Status
*   **Lab Compiler (Rust)**: Lowering is in `sidecar_resolution_only` state. The compiler Resolver walks the AST, determines resolution, and writes `form_table.json` and `form_resolution_trace.json`. However, the main AST is **never lowered**; `semantic_ir_program.json` preserves generic `binary_op` nodes.
*   **Mainline Compiler (Ruby)**: No sidecar files are generated. However, the mainline `TypeChecker` currently does a primitive type of lowering: it rewrites binary operations directly (e.g., `left + right` is translated to an explicit `apply` node targeting `"stdlib.integer.add"`).

### 1.3. Typechecker & Type-Directed Dispatch
*   **Lab Compiler (Rust)**: The typechecker is a simplified skeleton and does not provide type annotations to the resolver. The resolver operates name-by-name, which makes type-directed filtering the primary blocker.
*   **Mainline Compiler (Ruby)**: The typechecker (`typechecker.rb`) infers types recursively (`infer_expr`) and enforces type mismatch rules, but has no registry to resolve generic trigger symbols to custom contract signatures.

### 1.4. Monomorphization & Traits (`PROP-016`)
*   **Mainline & Lab**: Bounded polymorphism (`Additive[T]`) is parsed conceptually but not yet monomorphized at Pass 0. Mainline fixtures (like `polymorphic_add.ig`) are parsed but not compiled or executed under traits. 

### 1.5. Import Hiding / Overriding
*   **Lab Compiler (Rust)**: Parses `import M hiding (foo) overriding (+)` syntax, but the scope-filtering is not wired to the resolver or registry.
*   **Mainline Compiler (Ruby)**: Zero parser or scope-table support.

### 1.6. Ambiguity, `no_form`, and Misses
*   **Lab Compiler (Rust)**: Implements strict fail-closed errors for:
    *   `E-FORM-AMBIG`: ambiguity blocks compilation (zero resolved forms, null winner).
    *   `E-FORM-NOFM-MATCH`: fail-closed if matching a `no_form` contract.
    *   `primitive_pass_through`: known primitives pass through silently.
    *   `unresolved_trigger`: unknown operators raise warnings/traces.
*   **Mainline Compiler (Ruby)**: Zero support for these diagnostics.

---

## 2. Compact Support & Gap Matrix

| Compiler / Runtime Surface | Mainline Status (Ruby) | Lab Status (Rust) | Lowering Gap & Target Fact |
| :--- | :--- | :--- | :--- |
| **Syntax Parsing** | ❌ No support |  Parsed (P1, P2) | Parse `form (a) "op" (b)` and `no_form`. |
| **Form Registry** | ❌ No support |  Built & Indexed (P3) | Index triggers to contract targets. |
| **Type-Directed Filter** | ❌ No support | ❌ Name-only (Blocker) | Resolver must query operand types. |
| **AST Lowering** | ⚠️ Hardcoded primitives | ❌ Sidecar only (H3) | Rewrite generic AST ops to Call nodes. |
| **Import Scope Hiding** | ❌ No support | ❌ Parse only | Filter resolver candidates by scope. |
| **Ambiguity (E-FORM-AMBIG)**| ❌ No support |  Fail-Closed (H1) | Refuse compilation on equal precedence. |
| **no_form Fail-Closed** | ❌ No support |  Fail-Closed (H5) | Block invocation matches on `no_form`. |
| **VM Execution (Linking)** | ❌ No support | ❌ No support | Called graphs must inline before VM. |

---

## 3. Implementation Risk Map & C4-A Notes

### Risk Map
1.  **SemanticIR Schema Contamination**: If the compiler emits unresolved form triggers to the `.igapp`, the VM will fail or crash. AST lowering must be a mandatory pre-condition before bytecode emission.
2.  **VM Subroutine authority drift**: Attempting to implement stack frames and subroutine jumps inside the VM adds runtime state complexity. Inlining contract graphs during compilation avoids runtime authoring risks.
3.  **Tie-Breaking by Order**: Allowing declaration order to settle ambiguities introduces indeterminism. Tie-breaking must be restricted to explicit namespace overrides or result in a hard compilation error.
4.  **Coherence of Operator Policies**: `+` must remain strictly numeric. Concatenation `++` must be a separate sequence operator to prevent type coercion vulnerabilities.

### Architect Supervisor (C4-A) Recommendation
*   **Verdict**: Accept `LAB-FORMS-P4` as preflight evidence.
*   **Lowering Route**: Authorize a design boundary for compiler lowering that transforms generic syntax to explicit calls.
*   **VM Linking**: Keep VM dynamic subroutine linking closed/deferred. Mandate graph inlining/monomorphization as the sole target for execution.
*   **Authority Constraints**: Keep parser, typechecker, and runtime changes closed.
