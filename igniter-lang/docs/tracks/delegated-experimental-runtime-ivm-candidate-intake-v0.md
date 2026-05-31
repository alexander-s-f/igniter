# Delegated Experimental Runtime: IVM Candidate Intake v0

Card: S3-R224-C2-P1
Skill: IDD Agent Protocol
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-ivm-candidate-intake-v0
Route: UPDATE
Status: done
Date: 2026-05-31

Depends on:
- S3-R223-C5-S
- S3-PLAN-IVM-POC-1

---

## 1. Intake Summary

This track provides a rigorous intake and fit-analysis of the **Igniter Virtual Machine (IVM)** prototype developed under the playground-only workspace:
`playgrounds/igniter-runtime/`

The IVM prototype demonstrates a lightweight, high-performance, stack-based bytecode virtual machine with register storage gating, ahead-of-time (AOT) jumps for lazy expression evaluation, pluggable temporal backend querying, and automatic trace observation sink emissions.

> [!IMPORTANT]
> **IDD Protocol Authority Fencing**
> - The IVM playground and its compiled output are **delegated experimental runtime candidate evidence only**.
> - IVM is **not** Reference Runtime.
> - IVM is **not** public runtime support.
> - IVM is **not** production runtime support.
> - IVM does **not** imply a stable API, does **not** authorize `igc run`, and does **not** authorize RuntimeSmoke productization.
> - Mainline code paths in `lib/**` and `bin/igc` remain strictly **closed** to implementation.

---

## 2. R223 Quickstart vs. IVM Comparison

The following table contrasts the accepted S3-Round 223 executable quickstart harness (`CompiledProgram` AST walker) with the playground IVM POC:

| Dimension | R223 Quickstart Harness (`CompiledProgram`) | Playground IVM (Bytecode Virtual Machine) |
| :--- | :--- | :--- |
| **Execution Pattern** | Recursive AST Walk (interpreter-style evaluation) | Stack-Based Bytecode decoding loop (8-bit opcodes) |
| **Bitemporal Reads** | Evaluates recursive `tbackend_read` nodes | Direct `LOAD_AS_OF` opcode resolving via pluggable backend |
| **Branch Semantics** | Delegate `if_expr` evaluation to external Ruby class | Inline relative `JMP_UNLESS` and `JMP` instruction pointers |
| **Side-Effects** | Sequential evaluation in Ruby AST node calls | Strict bytecode order; non-selected branches completely skipped |
| **Performance Profile** | High memory allocation due to recursive tree traversal | Linear instruction decoding loop; near-zero AST traversal overhead |
| **Trace Auditing** | Appends observations via manual machine-state transitions | Instruction-driven trace sink; `EMIT_OBS` compiles to bytecode |
| **Input Format** | Consumes full compiler-emitted `.igapp` JSON output | Consumes simplified AST JSON hash (requires compile phase) |
| **Monomorphic stdlib**| Monomorphic operators resolved during AST evaluation | Executed via primitive math opcodes (`ADD`, `SUB`, `MUL`, `DIV`, `EQ`) |

---

## 3. IVM Capability Matrix

The IVM prototype implements a complete, self-contained 8-bit instruction set. The following matrix documents the verified capabilities of this experimental runtime:

*   **Primitive Arithmetic Operations**:
    *   `OP_ADD` (0x05): Pop two, add, push.
    *   `OP_SUB` (0x06): Pop two, subtract, push.
    *   `OP_MUL` (0x07): Pop two, multiply, push.
    *   `OP_DIV` (0x08): Pop two, divide, push.
    *   *Verification Status*: Fully functional; verified in `examples/demo.rb` calculations.
*   **Variable & Input Reference Loading**:
    *   `OP_LOAD_REF` (0x02): Resolves named inputs from user variables or temporal context hashes, pushing values to stack.
    *   `OP_STORE_REG` (0x03) / `OP_LOAD_REG` (0x04): Allows register-gated value caching to prevent redundant calculations.
    *   *Verification Status*: Fully functional; supports bitemporal valid-time coordinates and raw input injection.
*   **Lazy Branching & Control Flow**:
    *   `OP_JMP` (0x0A) / `OP_JMP_UNLESS` (0x0C): Compiles nested conditional `if_expr` nodes into flat linear jumps.
    *   *Verification Status*: Excellent. In Timeline A (3 jobs), only the minor branch is evaluated. In Timeline B (5 jobs), only the major branch is evaluated. Lazy branch guarantees are completely met.
*   **Temporal Query Unwrapping**:
    *   `OP_LOAD_AS_OF` (0x0D): Interfaces with pluggable `TBackend` historical database layer.
    *   *Verification Status*: Resolves valid-time history queries dynamically and unwraps the option envelope (`{"kind" => "some", "value" => X}`) to push the raw primitive value to the stack.
*   **Automatic Trace Auditing**:
    *   `OP_EMIT_OBS` (0x0E): Pushes computation traces directly to observation sink.
    *   *Verification Status*: Intercepts values during bytecode execution to construct signed, timestamped, tamper-evident observation envelopes (compliant with AT-10 standards).

---

## 4. Missing Proof Matrix

While the playground IVM is a highly mature delegated experimental runtime candidate, the following negative proofs and semantic gaps are identified:

| Gap Code | Title / Gap Description | Risk Level | Mitigation Stance |
| :--- | :--- | :--- | :--- |
| **MP-01** | **Stack Underflow Failures** | Medium | A check for underflow is implemented, but tests for empty stack pops on arithmetic/ret are confined to playground assertions. |
| **MP-02** | **Jump Out-of-Bounds** | Medium | Invalid branch offset bounds checks are coded, but no test fixture verifies error raising during invalid jumps. |
| **MP-03** | **Non-Boolean Jumps** | High | Non-boolean evaluation on `OP_JMP_IF` or `OP_JMP_UNLESS` raises `ConditionTypeError`. Explicit negative compilation fixtures are missing. |
| **MP-04** | **Uninitialized Register Reads**| Low | Reading from an unallocated register raises `RegisterBoundsError`. Requires formal test coverage. |
| **MP-05** | **Bitemporal Transaction Time** | High | `LOAD_AS_OF` currently resolves Valid-Time only. Transaction-time database dimensions and bitemporal OLAP aggregation remain unproven. |
| **MP-06** | **Streaming & Sliding Windows** | High | Stream-native sliding windows (`aggr:count` over time ranges) are not represented in the flat instruction set. |

---

## 5. `.igapp` / SemanticIR Adapter Gap Analysis

The compiler developed under `igniter-lang` outputs a structured `.igapp` bundle (specifically emitting `semantic_ir_program.json` in accordance with PROP-019.1). The playground IVM, however, consumes a simplified AST format directly defined as a Hash. 

To bridge mainline compiler output with the playground IVM, the following adapter gaps must be closed:

```
[Mainline Compiler Output]
      │
      ├──> manifest.json
      ├──> semantic_ir_program.json ───> [Requires Adapter mapping] ───> [IVM AOT Compiler] ───> [IVM Bytecode]
      └──> contracts/add.json
```

1.  **Format Mismatch**:
    *   *Mainline*: Structured JSON files split between schema manifests, requirements, and isolated contract definitions.
    *   *IVM AST*: A single, nested expression tree Hash (`contract["expression"]`).
2.  **Operator Mapping**:
    *   *Mainline*: Lowers functions to monomorphic standard library operators like `stdlib.integer.add` or `stdlib.integer.gt`.
    *   *IVM Compiler*: Translates operations through generic binary operator AST nodes (`"operator" => "=="`, `"+"`, etc.) mapping to direct hardware-like opcodes (`OP_ADD`, `OP_EQ`).
3.  **Bitemporal Read Semantics**:
    *   *Mainline*: Emits recursive `tbackend_read` AST nodes with subject string templates (`subject_template` like `"technician_jobs"`).
    *   *IVM Compiler*: Compiles `temporal_read` nodes directly mapping to the `OP_LOAD_AS_OF` instruction.

---

## 6. Runtime Boundary Recommendation

In strict alignment with the three-runtime distinction, we recommend the following boundary rules:

1.  **Accepted Evidence Only**:
    *   Accept the IVM playground implementation as a **delegated experimental runtime candidate**.
    *   Do **not** promote the playground code to `lib/**`. It must remain fully isolated under `playgrounds/igniter-runtime/` to prevent contamination of mainline gemspec / codebase.
2.  **Keep Mainline CLI & Specs Closed**:
    *   `bin/igc` and any user-facing CLI wrappers must **not** expose bytecode execution (`igc run` remains strictly prohibited).
    *   `RuntimeSmoke` and mainline test suites in `spec/` remain closed to IVM execution.
3.  **Reference Runtime Stays Closed**:
    *   No Reference Runtime support is claimed. The Reference Runtime remains a closed normative spec target.
4.  **No Stable API Wording**:
    *   All proposals, records, and documentation referencing IVM must feature prominent warnings that the bytecode VM is an unreleased pre-v1 sandbox candidate.

---

## 7. Explicit Answers to Card Questions

*   **Should IVM be accepted as a delegated experimental runtime candidate?**
    *   **Yes**. It provides excellent, high-fidelity proof that SemanticIR graphs can be pre-compiled into lightweight, flat bytecode streams with lazy branching.
*   **Does IVM replace the R223 delegated runtime harness or sit beside it?**
    *   **It sits beside it**. The R223 quickstart AST interpreter is the accepted mainline delegated harness. IVM is a separate, sandbox-only, compiled virtual machine alternative.
*   **Does IVM currently execute compiler-emitted `.igapp`?**
    *   **No**. It consumes a simplified, nested expression AST format.
*   **Should a `.igapp -> IVM` adapter route open next?**
    *   **Yes, as a playground-only proof**. We recommend authorizing a design/proof route to compile a compiler-emitted `.igapp` into IVM bytecode without touching mainline gemspec or lib.
*   **Should reusable helper extraction wait for IVM intake?**
    *   **Yes**. All extraction of common bitemporal helpers or observation envelopes must remain frozen until IVM intake is ratified.
*   **Is C/Rust/FFI acceleration premature or may it open as a later playground-only route?**
    *   **Mainline acceleration is premature**. However, a playground-only exploration of a C/Rust FFI bytecode interpreter under the playgrounds umbrella is a highly valuable research track that may open later.
*   **Should the Runtime Specification absorb any IVM semantics now?**
    *   **No**. The Runtime Specification remains closed to implementation.
*   **Does Reference Runtime remain closed?**
    *   **Yes, Reference Runtime remains closed**.
*   **Do public runtime, stable API, CLI, production, Spark, and release claims remain closed?**
    *   **Yes, they remain strictly closed**.

---

## 8. Recommended Next Route & Action Plan

We propose opening a playground-only adapter proof track:
`compiler-to-ivm-adapter-proof-v0`

```text
Goal:
Implement a playground-only AOT pipeline that consumes a compiler-emitted .igapp (with its semantic_ir_program.json), maps it to IVM AST representation, compiles it to bytecode, and executes it via the IVM stack machine.

Scope:
- Write playground-only files under playgrounds/igniter-runtime/.
- Absolutely no edits to igniter-lang/lib/** or mainline specs.
```

---

## 9. Handoff Metadata

Card: S3-R224-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-ivm-candidate-intake-v0
Status: done

[D] Decisions
- Accept IVM playground as a delegated experimental runtime candidate under the sandbox-only evidence fence.
- Retain the R223 quickstart AST harness as the primary mainline delegated harness; keep IVM beside it.
- Keep Reference Runtime, public runtime, stable API, and CLI execution boundaries closed.

[S] Signals
- Playground IVM compiled and disassembles recursive ASTs to flat 10-instruction bytecode.
- Bytecode lazy branch selection evaluated Timeline A (Jobs=3 -> minor bonus) and Timeline B (Jobs=5 -> major bonus) with zero eager branch side-effects.
- Signed observation trace envelopes dynamically emitted by the VM loop.

[T] Tests / Proofs
- Run `ruby -Ilib examples/demo.rb` in playground: PASS. Disassembly and timelines evaluation match expected values.

[R] Risks / Recommendations
- **Risk**: Prematurely merging VM code to mainline could break the Zero production dependency policy of Igniter.
- **Recommendation**: Keep all IVM code in `playgrounds/igniter-runtime/`. Open a playground-only `.igapp -> IVM` compile adapter route next to test bridge capabilities.

[Next]
- Open design/proof authorization review for a playground-local compiler-to-ivm-adapter-proof-v0.
