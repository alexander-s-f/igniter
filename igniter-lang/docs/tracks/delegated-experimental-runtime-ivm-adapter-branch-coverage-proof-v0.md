# Delegated Experimental Runtime: IVM Adapter Branch Coverage Proof v0

Card: S3-R226-C2-I
Skill: IDD Agent Protocol
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0
Route: UPDATE
Status: done
Date: 2026-06-01

Depends on:
- S3-R226-C1-A

---

## 1. Executive Summary

This track details the formal branch and comparison coverage hardening proof for the playground **Igniter Virtual Machine (IVM)** adapter.

We successfully verified, strictly inside the playground umbrella `playgrounds/igniter-runtime/`, the mapping, ahead-of-time (AOT) bytecode compilation, and lazy runtime execution of conditional branches (`if_expr`) and primitive comparisons (`>`) derived from freshly compiled source `.ig` files.

Every check in the **Branch Coverage Hardening Proof Matrix (BCP-1 to BCP-15)** has passed. Mainline packages, libraries (`igniter-lang/lib/**`), and executable tools (`bin/igc`) remain completely pristine and closed to modification.

> [!IMPORTANT]
> **IDD Protocol Wording & Claims Boundary**
> - The compiled virtual machine output and adapter execution results are **branch/comparison adapter-hardening evidence only** / **delegated experimental runtime evidence only**.
> - IVM is **not** Reference Runtime, **not** public runtime support, and **not** production runtime support.
> - No stable API is claimed, and `igc run` remains closed.
> - All observation traces captured are sandbox-local **valid-time observation-shaped traces** and **not** tamper-evident, signed, or AT-10-compliant security/audit authorities.

---

## 2. Hardened Adapter Support & Gap Matrix

The following table documents the hardened adapter capabilities, unmapped node sets, and execution-safety characteristics established by this proof:

| AST / Node Category | Mainline Compiler Form | Adapted Playground IVM Form | Hardening Status |
| :--- | :--- | :--- | :--- |
| **Integer Literal** | `{"kind": "literal", "value": 42}` | `{"kind": "literal", "value": 42}` | **Supported** |
| **Input / Coordinate Ref**| `{"kind": "ref", "name": "a"}` | `{"kind": "ref", "name": "a"}` | **Supported** |
| **Integer Add Operator** | `{"kind": "call", "fn": "stdlib.integer.add", "args": [a, b]}` | `{"kind": "binary_op", "operator": "+", "left": a, "right": b}` | **Supported** |
| **Lazy If Expression** | `{"kind": "if_expr", "condition": c, "then_branch": t, "else_branch": e}` | `{"kind": "if_expr", "condition": c, "then_branch": t, "else_branch": e}` | **Supported** (Maps fresh compiled AST) |
| **Lazy Branch Jumps** | Compiled to jump blocks in CompiledProgram | Flat VM jumps (`OP_JMP_UNLESS`, `OP_JMP`) | **Supported** (Flat bytecode relative offsets) |
| **Infix Comparison (`>`)**| `{"kind": "call", "fn": "stdlib.integer.gt", "args": [a, b]}` | `{"kind": "binary_op", "operator": ">", "left": a, "right": b}` | **Supported** (Mapped to native VM `OP_GT`) |
| **Apply (Add)** | `{"kind": "apply", "operator": "stdlib.integer.add", "operands": [a, b]}` | `{"kind": "binary_op", "operator": "+", "left": a, "right": b}` | **Supported** |
| **Selected Unmapped Node**| Any unmapped expression kind in selected path | `OP_UNSUPPORTED` bytecode instruction | **Supported** (Fails closed: raises `ExecutionError`) |
| **Unselected Unmapped Node**| Any unmapped expression kind in unselected path | `OP_UNSUPPORTED` bytecode instruction | **Supported** (Skipped at runtime: unselected silence) |
| **Object Field Access** | `{"kind": "field_access", "object": obj, "field": f}` | `{"kind": "unsupported"}` | **Gap (Unmapped)** (Triggers unmapped node flow) |

---

## 3. Proof Matrix Verification (BCP-1..BCP-15)

All fifteen checks of the branch coverage proof matrix have been verified:

*   **BCP-1: Source-Backed branch/comparison artifact identified with provenance**
    *   *Provenance*: Freshly compiled in the playground using mainline compiler dependencies from proof-local `.ig` source fixtures.
    *   *Status*: **PASS**
*   **BCP-2: Digest fields cleaned and separated**
    *   *File Digest*: `1526337ba19eaa83671eeae434f77a6f401bb846177a2b6fa6cf39972c7938fa` (computed strictly over `semantic_ir_program.json`).
    *   *Bundle Digest*: `29e65165bc4fe3a6844a09907ac0454e02218262679b73d886e636d82c8c1766` (manifest SHA256). They are distinct and not conflated.
    *   *Status*: **PASS**
*   **BCP-3: Fresh compile attempted**
    *   *Verification*: Mainline compiler compiled `minimal_if_else.ig` and `minimal_gt.ig` successfully into playground `out/` folder.
    *   *Status*: **PASS**
*   **BCP-4: Branch `if_expr` maps to IVM AST representation**
    *   *Verification*: Freshly compiled conditional branch AST mapped cleanly into IVM conditional structure.
    *   *Status*: **PASS**
*   **BCP-5: IVM bytecode includes branch jump semantics**
    *   *Verification*: AST compiled successfully into relative flat jump bytecode (`OP_JMP_UNLESS`, `OP_JMP`).
    *   *Status*: **PASS**
*   **BCP-6: Selected branch executes and returns expected value**
    *   *Verification*: VM executed the conditional branch bytecode with `flag = true`, returned `chosen = a` (42) successfully.
    *   *Status*: **PASS**
*   **BCP-7: Non-selected branch does not execute**
    *   *Verification*: VM executed the conditional branch bytecode with `flag = false`, returned `chosen = b` (99) successfully.
    *   *Status*: **PASS**
*   **BCP-8: Unsupported selected-path node fails closed locally**
    *   *Verification*: Mapped a mock conditional contract with unmapped `field_access` in the selected branch. VM decoded `OP_UNSUPPORTED` at runtime, threw a high-priority `ExecutionError`.
    *   *Status*: **PASS**
*   **BCP-9: Unsupported non-selected-path node does not fire when unselected**
    *   *Verification*: Mapped a mock conditional contract with unmapped `field_access` in the unselected branch. VM executed under `flag = false` successfully bypassed `OP_UNSUPPORTED` via relative jump offsets, returning expected value `100` with zero side-effects.
    *   *Status*: **PASS**
*   **BCP-10: `stdlib.integer.gt` stance is explicit**
    *   *Stance*: **MAPPED**.
    *   *Status*: **PASS**
*   **BCP-11: Playground-local comparison behavior tested (OP_GT)**
    *   *Verification*: Fully compiled comparison bytecode with the new `OP_GT` opcode (0x10). Run VM on `10 > 5` -> returned `true`; run VM on `3 > 7` -> returned `false`.
    *   *Status*: **PASS**
*   **BCP-12: R225 Add adapter proof still passes**
    *   *Verification*: Add regression proof executed successfully, returning `42`.
    *   *Status*: **PASS**
*   **BCP-13: Accepted R223/R225 evidence pristine**
    *   *Verification*: Original quickstart `quickstart_result.json` remains present, unmodified, and reads `PASS`.
    *   *Status*: **PASS**
*   **BCP-14: Closed surfaces remain pristine**
    *   *Verification*: No mainline tracked files are dirty.
    *   *Status*: **PASS**
*   **BCP-15: Wording conforms and Reference Runtime remains closed**
    *   *Verification*: Verified.
    *   *Status*: **PASS**

---

## 4. Machine-Readable Summary JSON

Our hardened summary JSON is exported at:
[summary.json](file:///Users/alex/dev/projects/igniter/playgrounds/igniter-runtime/out/ivm_adapter_branch_coverage_proof/summary.json)

---

## 5. Command Matrix Results

All required commands have successfully run and are validated:

*   `ruby -Iplaygrounds/igniter-runtime/lib /Users/alex/dev/projects/igniter/playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb`
    *   *Result*: **PASS** (12/12 R225 regression checks passing)
*   `ruby -c /Users/alex/dev/projects/igniter/playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb`
    *   *Result*: **Syntax OK**
*   `ruby -Iplaygrounds/igniter-runtime/lib /Users/alex/dev/projects/igniter/playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb`
    *   *Result*: **PASS** (15/15 branch/comparison coverage checks passing)
*   `git diff --check`
    *   *Result*: Clean (no whitespace errors)
*   `git status --short`
    *   *Result*: Mainline repository is completely pristine (untracked docs/tracks file created).
*   `git -C playgrounds/igniter-runtime status --short`
    *   *Result*: Sandbox nested repository contains only local IVM modifications and new proof files under playgrounds tree.

---

## 6. Recommended Next Route & Action Plan

With branch/comparison adapter coverage fully hardened and proven, we propose moving forward with a playground-only **FFI / C Bytecode Acceleration Research Pass**:
`playgrounds-ffi-c-bytecode-acceleration-research-v0`

```text
Goal:
Implement a playground-only C/Rust interpreter or FFI acceleration binding that loads the generated 8-bit binary bytecode stream, executes it outside the Ruby runtime loop, and returns observations back.

Scope:
- Exclusively playground-local directories.
- No gemspec or mainline lib modifications.
```

---

## 7. Handoff Metadata

Card: S3-R226-C2-I
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0
Status: done

[D] Decisions
- Retain the mainline compiler facade and `.igapp` output shape exactly; bridge them to IVM using a separate, pluggable playground adapter.
- Maintain a strict boundary separating compiled file-specific digests (`semantic_ir_program_sha256`) from bundle/directory digests (`source_igapp_manifest_sha256_or_null`).
- Implement bytecode fail-closed state (`OP_UNSUPPORTED` instruction) to guarantee that unmapped expressions raise errors at runtime only if their branch is selected.

[S] Signals
- Mapped fresh compiler-emitted conditional `if_expr` AST nodes to linear relative bytecode jump opcodes.
- Proven selected branch execution (evaluated cond=true -> returned 42) and unselected branch silence (evaluated cond=false -> returned 99 without firing unselected observations).
- Fully implemented greater-than (`OP_GT`) comparison opcode and mapped `stdlib.integer.gt` call nodes.

[T] Proofs
- Run `/Users/alex/dev/projects/igniter/playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb`: PASS. All 15 coverage checks verified successfully.
- Mainline regression specs: PASS (686 examples, 0 failures), proving zero mainline side-effects.

[R] Risks / Recommendations
- **Risk**: Merging the virtual machine or adapter code directly to the mainline lib at this stage remains blocked by Gem packaging constraints.
- **Recommendation**: Maintain all IVM code in `playgrounds/igniter-runtime/`. Open a playground-local FFI or C/Rust acceleration research pass next.

[Next]
- Propose opening design/proof authorization review for a playgrounds-ffi-c-bytecode-acceleration-research-v0 track.
