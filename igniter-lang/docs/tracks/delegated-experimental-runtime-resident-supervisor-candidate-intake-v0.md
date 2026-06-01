# Track Document: Delegated Experimental Runtime Resident Supervisor Candidate Intake v0

**Card:** S3-R230-C2-I  
**Skill:** IDD Agent Protocol  
**Agent:** [Igniter-Lang Research Agent]  
**Role:** research-agent  
**Track:** delegated-experimental-runtime-resident-supervisor-candidate-intake-v0  
**Route:** UPDATE  
**Depends on:**
- S3-R230-C1-A

---

## 1. Context & Architectural Rationale

This document establishes the **Resident Native Supervisor Candidate Intake Packet** as a delegated experimental runtime candidate proof. 

### Core Architectural Bottleneck
In Round 228, direct filesystem-backed native evaluation of AOT bytecode (`.igbin` files) was successfully proved. However, file-per-evaluation parsing and validation loops proved heavily disk I/O-bound, performing **15x slower** than the memory-based Ruby Virtual Machine. 

### The Solution: Multi-Phase Resident Lifecycle
To solve this I/O bottleneck, the Resident Native Supervisor splits evaluation into two distinct stages:
1. **Module Loading Stage (once):** Reads a `.igbin` file from disk, performs full Magic, Version, and Jump-boundary validation, allocates memory for instructions on the heap, and returns a resident pointer to a `LoadedModule` struct.
2. **Timeline Evaluation Stage (repeatedly):** Executes the loaded in-memory module multiple times with different inputs, completely bypassing the filesystem and resolving the I/O bottleneck.

---

## 2. Bounded Candidate Profile

- **Provisional Runtime ID:** `igniter.delegated.experimental.ivm.c_resident`
- **Evidence Label:** `resident_supervisor_candidate_intake`
- **Evidence Class:** `resident-supervisor candidate intake evidence only`
- **Implementation Status:** Delegated Experimental Runtime Candidate (Sandbox quarantine preserved).
- **Source Files:**
  - C Supervisor Core: [runner.c](file:///Users/alex/dev/projects/igniter/playgrounds/igniter-runtime/lib/ivm/runner.c)
  - FFI Bindings / Harness: [resident_supervisor_candidate_intake_proof.rb](file:///Users/alex/dev/projects/igniter/playgrounds/igniter-runtime/examples/resident_supervisor_candidate_intake_proof.rb)

---

## 3. Resident Lifecycle API & Entrypoints

The candidate implements three standard entrypoints in C, loaded via Ruby Fiddle FFI:

### A. `load_module`
```c
LoadedModule* load_module(const char* filepath, int32_t* error_code);
```
- **Behavior:** Loads `.igbin` once, checks magic (`"IGB\0"`), version (`1`), matches expected file size (`16 + 8 * instruction_count`), validates opcodes statically, and performs out-of-bound jump analysis.
- **Memory Allocation:** Dynamically allocates the `LoadedModule` container and `Instruction` array on the C heap. Returns a pointer or `NULL` if malformed.

### B. `execute_module`
```c
int32_t execute_module(const LoadedModule* module, const int32_t* inputs, int32_t* error_code);
```
- **Behavior:** Receives the resident `LoadedModule` memory pointer along with a packed integer array of inputs. Executes stack-based interpreter opcodes strictly in memory at hardware speeds.

### C. `free_module`
```c
void free_module(LoadedModule* module);
```
- **Behavior:** Releases all heap-allocated instruction arrays and structural containers, ensuring a clean memory lifecycle.

---

## 4. Capability Manifest Stance

This candidate has a restricted execution profile. All temporal, sharded, and network operations are explicitly excluded to isolate the supervisor proof.

```json
{
  "runtime_implementation_id": "igniter.delegated.experimental.ivm.c_resident",
  "implementation_class": "delegated.experimental.runtime",
  "evidence_class": "delegated experimental runtime candidate evidence only",
  "artifact_inputs": [".igbin proof-local file"],
  "execution_model": "load_once_execute_many",
  "resident_lifecycle": ["load_module", "execute_module", "free_module"],
  "supported_opcodes": ["0x01", "0x02", "0x05", "0x09", "0x10", "0x0A", "0x0C", "0x0F", "0x99"],
  "supported_expression_kinds": ["literal", "ref", "binary_op", "if_expr"],
  "supports_aot_bytecode_file_input": true,
  "supports_resident_module_loading": true,
  "supports_load_once_execute_many": true,
  "supports_if_expr_lazy_branching": true,
  "supports_ruby_ivm_parity_subset": true,
  "supports_temporal_read": false,
  "temporal_backend_kind": "none / excluded",
  "trace_kind": "none",
  "unsupported_features": ["C temporal backend", "Rust TBackend", "ESP32/mesh", "todolist", "igc run"],
  "failure_behavior": "fail_closed_on_malformed_input",
  "memory_lifecycle": "manual_free_via_free_module",
  "authority_status": "non-canonical / evidence-only"
}
```

---

## 5. Candidate Proof & Verification Matrix

The RSUP proof matrix was successfully executed on **2026-06-01** using the dedicated intake proof harness.

| Check | Name | Outcome | Verification Detail |
| :--- | :--- | :--- | :--- |
| **RSUP-1** | Candidate source inventoried | **PASS** | `runner.c` contains all required supervisor lifecycles. |
| **RSUP-2** | Identity recorded | **PASS** | Provisional ID and evidence classes matches curation guidelines. |
| **RSUP-3** | Capability manifest emitted | **PASS** | Manifest exported inside summary JSON under the playground out path. |
| **RSUP-4** | Module loads once | **PASS** | Validates headers and maps instructions in memory successfully. |
| **RSUP-5** | Repeated execution | **PASS** | Pointer executed multiple times without calling filesystem read again. |
| **RSUP-6** | True-branch parity | **PASS** | `flag = true` returns `42`, matching Ruby IVM Oracle perfectly. |
| **RSUP-7** | False-branch parity | **PASS** | `flag = false` returns `99`, matching Ruby IVM Oracle perfectly. |
| **RSUP-8** | Lazy branches intact | **PASS** | Non-selected branches are structurally jumped over and remain silent. |
| **RSUP-9** | Unsupported fails closed | **PASS** | Injecting opcode `0x99` (Unsupported) causes execution abort and return code `-1` / error `3`. |
| **RSUP-10**| Malformed fails closed | **PASS** | Bad magic returns `NULL` and error `11`. Truncated size returns `NULL` and error `14`. |
| **RSUP-11**| `free_module` exercised | **PASS** | Called memory release Fiddle function on loaded module pointer. |
| **RSUP-12**| Performance informational | **PASS** | Timing results labeled and contained within research-only context. |
| **RSUP-13**| Accepted evidence pristine | **PASS** | R228 `ivm_aot_bytecode_file_loading_proof` is untouched and remains PASS. |
| **RSUP-14**| Boundary route separation | **PASS** | Decoupled completely from C temporal backend, Rust TBackend, and ESP32. |
| **RSUP-15**| Mainline closed scan | **PASS** | Mainline source files scan completed, proving zero unauthorized modifications. |
| **RSUP-16**| Non-claims compliance | **PASS** | Zero forbidden claims present in code lines or track documentation. |

---

## 6. Informational-Only Timing Analysis

Timing measurements were performed over **50,000 iterations** (with a **1,000 iteration warmup**). 

> [!CAUTION]
> **Informational Research-Signal / Proof-Local Timing Only:**
> The benchmarks below represent synthetic loop performance in a clean, pre-warmed single-thread context on a local developer machine. They are **not public speedup claims, production benchmarks, or Reference Runtime metrics**.

- **Ruby IVM VM loop:** `0.0477 seconds` (~1,048,284 iter/sec)
- **Native C AOT File loop (disk I/O bound):** `0.4689 seconds` (~106,639 iter/sec)
- **Native C Resident Supervisor VM:** `0.0296 seconds` (~1,690,388 iter/sec)

### Key Architectural Lesson
Moving from disk-backed execution to resident native supervisor execution speeds up native timeline iterations by **15.6x**, successfully eliminating the disk I/O bottleneck. In-memory native execution runs approximately **1.6x faster** than the Ruby interpreter loop, validating that bypassing interpreter instruction decoding overhead scales rule execution.

---

## 7. Separate Route Stance

To prevent scope creep and maintain architectural boundaries, the following tracks **remain closed and unauthorized** by this intake:
- **C-Level Pluggable Temporal Backend:** Intake is held for a separate, subsequent boundary decision.
- **Rust Sharded TCP Database Server:** Retains sandbox candidate status requiring its own intake reviews.
- **Microcontroller / ESP32 mesh:** Remains speculative, comparative hardware research only.
- **`igc run` CLI command:** Remains closed to implementation.
- **Reference Runtime / Spark integration:** Strictly closed.

---

## 8. Non-Claims & Risk Containment Stance

This document does not authorize:
- Mainline runtime modifications, API exposure, gemspec edits, or package version changes.
- `igc run` CLI command implementation.
- Production readiness claims, stable pre-v1 API promises, or Reference Runtime certifications.
- Portable artifact declarations (artifact passport remains future-only).

---

## 9. Recommended Next Main Line Boundary Route

With the resident supervisor candidate successfully quarantined and verified in the playground, the next primary move for Igniter-Lang runtime architecture is:

```text
experimental-runtime-artifact-passport-minimum-boundary-v0
```

This next design-only track should define the formal metadata passport fields required to validate compiled `.igbin`/`.igapp` artifacts across differing execution profiles before any execution CLI commands (`igc run`) are introduced.

---

### Handoff Card Signature

```text
Card: S3-R230-C2-I
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-resident-supervisor-candidate-intake-v0
Status: done

[D] Decisions
- Quarantined resident supervisor candidate under provisional ID igniter.delegated.experimental.ivm.c_resident.
- Successfully verified resident lifecycle load_module, execute_module, and free_module.
- Maintained absolute separate-route quarantine on C temporal, Rust sharded, and ESP32.

[S] Shipped / Signals
- Created proof script at playgrounds/igniter-runtime/examples/resident_supervisor_candidate_intake_proof.rb.
- Exported candidate intake summary JSON under playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/summary.json.
- Produced official intake track document under igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-v0.md.

[T] Tests / Proofs
- Checked syntax on both resident supervisor and AOT file loading proof scripts (Syntax OK).
- Ran all 16 checks under the RSUP matrix, resulting in 16/16 PASS.
- Verified cleanly compiled librunner.dylib and passed git diff/status sanity sweeps.

[R] Risks / Recommendations
- Remeasured timings confirm 15.6x I/O bottleneck elimination, but must remain strictly informational / non-public timing signals.
- Suggest routing the next round to experimental-runtime-artifact-passport-minimum-boundary-v0 to establish artifact passport design before mainline CLI run work.
```
