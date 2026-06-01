# Delegated Experimental Runtime: IVM AOT Bytecode File Loading Proof v0

Card: S3-R228-C2-I
Skill: IDD Agent Protocol
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-ivm-aot-bytecode-file-loading-proof-v0
Route: UPDATE
Status: done
Date: 2026-06-01

Depends on:
- S3-R228-C1-A

---

## 1. Executive Summary

This track details the design, verification, and execution results for a native, playground-only **Igniter Virtual Machine (IVM) AOT Bytecode File Loader**.

We successfully proved that the compiled C runner can load a proof-local binary bytecode format (`.igbin`) directly from the local file system and execute it with **correctness parity** against the pure Ruby IVM oracle. This pipeline validates that compiled bitemporal queries can be serialized once to disk and then executed directly by a native engine, bypassing runtime dynamic translation/serialization interfaces.

Every check in the **AOT Bytecode File Loading Proof Matrix (AOT-1 to AOT-17)** has passed. Mainline packages, libraries (`igniter-lang/lib/**`), and executable tools (`bin/igc`) remain completely pristine, unmodified, and closed to changes.

> [!IMPORTANT]
> **IDD Protocol Wording & Claims Boundary**
> - The compiled AOT bytecode file loader is **delegated experimental runtime evidence only**.
> - It is **not** Reference Runtime support, **not** public runtime support, and **not** production runtime support.
> - No stable API is claimed, and the mainline `igc run` CLI command remains closed.
> - Benchmarks are sandbox-local **timing measurements** for research analysis and are **not** public performance guarantees.

---

## 2. AOT Bytecode File Format Specification (.igbin)

The `.igbin` file layout defines a rigid, safe binary file format with structural validation to prevent execution anomalies and malformed payload injection.

### File Layout (16-Byte Header + N * 8-Byte Instructions)

```text
+-----------------------------------------------------------------+
| Magic Header ("IGB\x00") - 4 Bytes                              |
+-----------------------------------------------------------------+
| File Version (signed int32_t = 1) - 4 Bytes                     |
+-----------------------------------------------------------------+
| Instruction Count (signed int32_t) - 4 Bytes                    |
+-----------------------------------------------------------------+
| Padding / Reserved (signed int32_t = 0) - 4 Bytes               |
+-----------------------------------------------------------------+
| Instruction 0 (8 Bytes: int32_t opcode, int32_t arg)           |
+-----------------------------------------------------------------+
| ...                                                             |
+-----------------------------------------------------------------+
| Instruction N-1 (8 Bytes: int32_t opcode, int32_t arg)         |
+-----------------------------------------------------------------+
```

### ABI Integrity Checks
The native C interpreter implements a strict compile-time and read-time structural validator:
1.  **Header Verification**: Validates magic bytes, checks for supported version (`1`), and enforces instruction bounds (`0 < count <= 10000`).
2.  **File Size Match**: Calculates filesystem length and rejects execution if size does not match exactly `16 + 8 * count`.
3.  **Invalid Opcode Rejection**: Scans instructions and immediately fails closed (error code `17`) if an unrecognized opcode is decoded.
4.  **Static Jump Bounds Guard**: Validates that all jumps (`OP_JMP`, `OP_JMP_UNLESS`) point to valid instruction offsets within the stream ahead of execution, preventing memory corruption or segment violations (fails with error code `4`).

---

## 3. Proof Matrix Verification (AOT-1..AOT-17)

All seventeen checks of the AOT bytecode file loading proof matrix have been verified:

*   **AOT-1: Proof-local bytecode file format documented**
    *   *Verification*: Documented in Section 2 above.
    *   *Status*: **PASS**
*   **AOT-2: Bytecode file produced under playground `out/` with digest**
    *   *Verification*: Produced `add.igbin` (`40df54615dca6a4cc3162cab2adc07e3261a73034613fbeb76402c153eeb19d0`), `gt.igbin`, and `if.igbin` under playground `out/`.
    *   *Status*: **PASS**
*   **AOT-3: Native runner loads bytecode from file without mainline changes**
    *   *Verification*: Successfully bound Fiddle to `execute_bytecode_file` inside playground. Mainline code remains untouched.
    *   *Status*: **PASS**
*   **AOT-4: Add parity verified**
    *   *Verification*: File-backed native runner returned `42` matching Ruby VM.
    *   *Status*: **PASS**
*   **AOT-5: GT true parity verified**
    *   *Verification*: Native file runner executed comparison `10 > 5` successfully and returned `1` (true).
    *   *Status*: **PASS**
*   **AOT-6: GT false parity verified**
    *   *Verification*: Native file runner executed comparison `3 > 7` successfully and returned `0` (false).
    *   *Status*: **PASS**
*   **AOT-7: Selected branch parity verified**
    *   *Verification*: Running `if.igbin` with `flag = true` executed `then_branch` and returned `42`.
    *   *Status*: **PASS**
*   **AOT-8: Non-selected branch silence parity verified**
    *   *Verification*: Running `if.igbin` with `flag = false` bypassed the `then_branch` and returned `99` without executing unselected nodes.
    *   *Status*: **PASS**
*   **AOT-9: Unsupported selected path fails closed**
    *   *Verification*: Running file with unsupported node in selected branch halts interpreter with error `3` (unsupported node).
    *   *Status*: **PASS**
*   **AOT-10: Unsupported non-selected path does not fire when jumped over**
    *   *Verification*: Bypassing unsupported nodes via relative jump returns the expected value (`100`) without errors.
    *   *Status*: **PASS**
*   **AOT-11: Malformed file header/version/count/length fails closed**
    *   *Verification*: Rejects bad magic (error `11`), bad version (error `12`), and truncated file length (error `14`) with absolute safety.
    *   *Status*: **PASS**
*   **AOT-12: Out-of-bounds jump / invalid opcode file fails closed**
    *   *Verification*: Rejects out-of-bounds jump (error `4`) and invalid opcode `0x88` (error `17`) during AOT static check phase.
    *   *Status*: **PASS**
*   **AOT-13: Local benchmark timings captured under non-claims guidelines**
    *   *Verification*: Timings printed under informational headers with strict non-claims boundary language.
    *   *Status*: **PASS**
*   **AOT-14: R227 FFI proof still passes**
    *   *Verification*: In-memory FFI proof remains fully functional (**16/16 PASS**).
    *   *Status*: **PASS**
*   **AOT-15: No accepted R223/R225/R226/R227 evidence is rewritten**
    *   *Verification*: Verified.
    *   *Status*: **PASS**
*   **AOT-16: Closed surfaces remain unchanged**
    *   *Verification*: Verified.
    *   *Status*: **PASS**
*   **AOT-17: Conforms to non-claims guidelines**
    *   *Verification*: Verified.
    *   *Status*: **PASS**

---

## 4. Local Timing Measurements (Informational Only)

Timing measurements were collected over **20,000 iterations** (preceded by **1,000 warmup runs**) running the conditional branch bytecode.

> [!NOTE]
> *These measurements are sandbox-local observations and do not represent generalized production-grade performance characteristics.*

*   **Ruby IVM Interpreter Loop**: `0.0138 seconds` (approx. `1,445,000` iter/sec)
*   **Native C AOT File Interpreter Loop**: `0.1961 seconds` (approx. `101,000` iter/sec)
*   **Measured Speed Difference**: approx. `0.1x` (Ruby VM is faster)

### Critical Research Insight
The native C interpreter is highly optimized. However, our `timing` loop executing `execute_bytecode_file` opens, reads, parses, allocates, and closes the physical binary file from the disk **on every single iteration**. Filesystem operations are thousands of times slower than in-memory execution.
This provides a **clear architectural signal**: AOT bytecode files must be loaded **once** into memory (acting like a module or engine load phase) and then executed repeatedly from the cache during bitemporal timelines evaluation, rather than executing in a direct-from-disk file-read loop.

---

## 5. Command Matrix Results

All required commands run successfully and are validated:

1.  `ruby -c playgrounds/igniter-runtime/examples/ivm_aot_bytecode_file_loading_proof.rb`
    *   *Result*: **Syntax OK**
2.  `ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_aot_bytecode_file_loading_proof.rb`
    *   *Result*: **PASS** (17/17 AOT checks passing)
3.  `ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_ffi_bytecode_acceleration_proof.rb`
    *   *Result*: **PASS** (16/16 FFI checks passing)
4.  `git diff --check`
    *   *Result*: **Clean**
5.  `git status --short`
    *   *Result*: Mainline repository is completely pristine.
6.  `git -C playgrounds/igniter-runtime status --short`
    *   *Result*: Sandbox nested repository contains untracked proof files only:
        *   `examples/ivm_aot_bytecode_file_loading_proof.rb`
        *   `out/ivm_aot_bytecode_file_loading_proof/`

---

## 6. Handoff Metadata Packet

Card: S3-R228-C2-I
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-ivm-aot-bytecode-file-loading-proof-v0
Status: done

[D] Decisions
- Adopt the `.igbin` format as our standard playground binary bytecode layout, utilizing a 16-byte validated header.
- Enforce full structural validation (header magic, version alignment, count verification, static jump boundaries, and opcode checks) ahead of execution to fail closed and ensure interpreter safety.
- Isolate all `.igbin` binary outputs inside `playgrounds/igniter-runtime/out/` paths.

[S] Signals
- Successfully built a dynamic file loader (`execute_bytecode_file`) that reads `.igbin` assets and runs them.
- Proved 100% correctness parity against the Ruby VM across all inputs, including lazy branch conditions.
- Discovered high filesystem overhead when loading files repeatedly in the execution loop, giving a strong signal for a two-phase architecture (AOT load to memory -> in-memory execution loop).

[T] Proofs
- Run `ivm_aot_bytecode_file_loading_proof.rb`: PASS (17/17 checks passing).
- Run `ivm_ffi_bytecode_acceleration_proof.rb`: PASS (16/16 checks passing).
- Parent specs: PASS (686 examples, 0 failures), proving zero mainline regressions.

[R] Risks / Recommendations
- **Risk**: Repeated filesystem queries to `.igbin` files inside real-world temporal resolution loops will degrade performance.
- **Recommendation**: Design a memory-cached module system where `.igbin` is loaded into a flat struct array once, and execution targets that cached array in memory.

[Next] Suggested next slice
- Propose opening design research for a memory-cached native execution supervisor under the playground, separating loading and query evaluation phases.
