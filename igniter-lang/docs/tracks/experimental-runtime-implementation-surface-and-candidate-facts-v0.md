# Facts Packet: Experimental Runtime Implementation Surface and Candidate Matrix v0

**Card:** S3-R229-C2-P1  
**Skill:** IDD Agent Protocol  
**Agent:** [Implementation Surface Surveyor]  
**Role:** implementation-surface-surveyor  
**Track:** experimental-runtime-implementation-surface-and-candidate-facts-v0  
**Route:** UPDATE  
**Depends on:**
- S3-R228-C5-S
- experimental-runtime-implementation-status-model-v0

---

## 1. Executive Summary & Context

This facts packet maps the current mainline runtime/CLI surfaces of `igniter-lang` alongside the experimental playground candidates from `playgrounds/igniter-runtime` and `playgrounds/igniter-tbackend` to support the Portfolio Architect Supervisor (`C4-A`) in the Round 229 boundary decision. 

As established in [status-curation-v0](file:///Users/alex/dev/projects/igniter/igniter-lang/docs/tracks/stage3-round228-status-curation-v0.md) and [status-model-v0](file:///Users/alex/dev/projects/igniter/igniter-lang/docs/tracks/experimental-runtime-implementation-status-model-v0.md), playground research has produced highly accelerated native execution and sharded temporal storage proofs. However, these accomplishments are **delegated experimental runtime evidence only**. They do not constitute stable APIs, reference runtimes, production engines, or mainline CLI run functionality. This document provides a highly disciplined, read-only audit of the current boundary state to prevent architectural drift or unauthorized public claims.

---

## 2. Mainline CLI & Runtime API Surface

The official mainline compiler codebase (`igniter-lang/lib/`) maintains a highly clean compile-time/validation boundary. It is completely isolated from native executors or running servers.

### Mainline Core Components

| Component | Mainline File | Current Internal Surface |
| :--- | :--- | :--- |
| **CLI Entrypoint** | [cli.rb](file:///Users/alex/dev/projects/igniter/igniter-lang/lib/igniter_lang/cli.rb) | Sole command supported is `compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]`. There is **no `run` or execution command**. |
| **Pipeline Orchestrator** | [compiler_orchestrator.rb](file:///Users/alex/dev/projects/igniter/igniter-lang/lib/igniter_lang/compiler_orchestrator.rb) | Coordinates parsing, classification, typechecking, semantic IR emission, and assembly. Implements optional strict compile-refusal checks for contract digests. |
| **Assembly Module** | [assembler.rb](file:///Users/alex/dev/projects/igniter/igniter-lang/lib/igniter_lang/assembler.rb) | Generates the directory-based `.igapp` layout under a user-defined target path. |
| **Harness Smoke Test** | [runtime_smoke.rb](file:///Users/alex/dev/projects/igniter/igniter-lang/lib/igniter_lang/runtime_smoke.rb) | An optional compile-time sanity check. It calls the local `runtime_machine_memory_proof` to execute a quick load/resume sequence to verify compiled output behavior against mock state. |
| **Compiler Result** | [compiler_result.rb](file:///Users/alex/dev/projects/igniter/igniter-lang/lib/igniter_lang/compiler_result.rb) | Models the standardized JSON returned by `igc compile`. Includes metadata like `program_id`, `source_hash`, `stages` map, and `diagnostics`/`warnings` arrays. |
| **Compilation Report** | [compilation_report.rb](file:///Users/alex/dev/projects/igniter/igniter-lang/lib/igniter_lang/compilation_report.rb) | Rich diagnostic structure returned upon compilation success/refusal, tracking individual pass performance and contract warnings. |

> [!IMPORTANT]
> **No Runtime Executor in Mainline:** There is no execution engine built into `igniter_lang/lib/`. The mainline code acts strictly as a static analyzer, compiler, and assembler. `RuntimeSmoke` is the only component that touches execution, and it does so exclusively by referencing the proof-local memory machine under `igniter-lang/experiments/`.

---

## 3. Playground Runtime Candidates & Evidence Map

Playground repositories contain several advanced runtime engines and database backends designed to stress-test compilation outputs. 

### A. Accepted Delegated Runtime Evidence (R225 - R228)
- **R225 (Adapter-Fit):** Proved compilation of AST structures down to stack-based IVM bytecode and loading it, confirming correctness over the FFI boundary.
- **R226 (Hardening/Branches):** Proved that conditional jumps (`OP_JMP_UNLESS`, `OP_JMP`) execute lazily in a flat stack interpreter, verifying that non-selected execution paths never fire observation tracers.
- **R227 (FFI Native Acceleration):** Proved native C compilation and execution speeds via Ruby `Fiddle` loading a native interpreter (`runner.c`).
- **R228 (AOT Bytecode File-Loading):** Proved loading of `.igbin` binary files in native space with strict 16-byte magic headers ("IGB\0") and `16 + 8 * instruction_count` file length validation, failing closed on malformed files.

### B. Unaccepted Sandbox Candidates (In-Playground Only)
- **Resident Native Execution Supervisor:** Exposes `load_module()`, `execute_module()`, and `free_module()` lifecycles in `runner.c`. It loads `.igbin` binary files once into resident C memory arrays and executes them repeatedly, achieving **1.56M iterations/sec** (15.2x faster than repeated disk loads and 2.0x faster than the Ruby VM).
- **C-Level Pluggable Bitemporal Backend:** Incorporates a fast, flat bitemporal table structure (`HistoricalRecord`, `TemporalStore`, `TemporalBackend`) directly inside C. Resolves history queries (`OP_LOAD_AS_OF` opcode) in native memory via insertion-sorted binary searches. Yields **1.5 million timeline evaluations per second** (15.6x faster than pure Ruby FFI callbacks).
- **Embedded Xtensa/ESP32 dual-core blueprint:** Standard C supervisor is 100% compatible with low-memory ESP32 Xtensa processors (static memory footprint <2KB). Runs dual-core execution tasks pinned to Xtensa Core 0 and Core 1 via FreeRTOS. Integrates ESP-NOW wireless mesh networking to broadcast compact 16-byte observation frames in less than 1 millisecond.
- **Rust Sharded Bitemporal TCP Server:** Implements a multi-threaded, concurrent bitemporal database engine in Rust (`magnus` bindings for Ruby) featuring Blake3 value hashing, sharded in-memory key maps with 128 locks, and a write-ahead log (WAL) serialized via MessagePack. Spins up a high-performance TCP server handling time-travel and scope filtering queries concurrently at scale.

---

## 4. Implementation Candidate Matrix

This matrix classifies all current playground implementation candidates, mapping their structural markers, current status, and mainline access rules.

| Candidate ID | Language / Tech | Primary Architectural Purpose | Mainline Code Location | Playground Code Location | Current Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`ivm-ruby-poc`** | Ruby | Original stack-based bytecode compiler and VM prototype. | None | `playgrounds/igniter-runtime/lib/ivm/` | **Delegated Evidence (R225/R226)** |
| **`ivm-c-ffi`** | C / Ruby Fiddle | Ahead-of-time bytecode native execution. | None | `playgrounds/igniter-runtime/lib/ivm/runner.c` (part) | **Delegated Evidence (R227/R228)** |
| **`ivm-c-resident`** | C / Ruby Fiddle | Multi-phase resident module loading and in-memory evaluation. | None | `playgrounds/igniter-runtime/examples/ivm_resident_supervisor_proof.rb` | **Unaccepted Sandbox Candidate** (Needs Intake) |
| **`ivm-c-temporal`** | C / Ruby Fiddle | C-native bitemporal historical stores completely bypassing FFI callback overhead. | None | `playgrounds/igniter-runtime/examples/ivm_bitemporal_c_backend_proof.rb` | **Unaccepted Sandbox Candidate** (Needs Intake) |
| **`ivm-esp32-mesh`** | C / FreeRTOS | Speculative microcontroller port with dual-core tasking and ESP-NOW mesh frames. | None | `playgrounds/igniter-runtime/docs/concurrency_and_embedded_esp32_mesh_research.md` | **Speculative Research** (Sandbox Only) |
| **`tbackend-rust-sharded`** | Rust / Magnus | High-concurrency sharded timeline log with WAL and TCP network server. | None | `playgrounds/igniter-tbackend/` | **Unaccepted Sandbox Candidate** (Needs Intake) |

---

## 5. Artifact Formats & Portability Specification

Playground and mainline execution rely on two discrete serialization formats.

### A. The `.igapp` Directory Layout (Mainline Assembly)
Compiled contracts are assembled as directories containing multiple structured JSON files:
- **`manifest.json`:** Declares `program_id`, `artifact_hash`, `language_version` (e.g., `"0.1.0.alpha.1"`), format version, schema version, and loaded contract lists.
- **`semantic_ir_program.json`:** Normative semantic graph containing all bound node structures and pipeline connections.
- **`classified_ast.json`:** Ast classifier metrics including `oof_count` and template structures.
- **`requirements.json`:** Tracks requested system capabilities and temporal window requirements.
- **`diagnostics.json`:** Compile-time warnings and diagnostics.
- **`contracts/`:** Subdirectory containing raw JSON representations of compiled business contract rules.

### B. The `.igbin` Bytecode File (Native AOT Format)
The native C supervisor reads direct, compact binary files. The file format is strictly defined as follows:

```text
  0                   1                   2                   3
  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
 +---------------------------------------------------------------+
 |                        Magic: "IGB\0"                         |  0 - 3 bytes
 +---------------------------------------------------------------+
 |                     Version: 1 (int32_t)                      |  4 - 7 bytes
 +---------------------------------------------------------------+
 |              Instruction Count: N (int32_t)                   |  8 - 11 bytes
 +---------------------------------------------------------------+
 |                     Reserved Padding: 0                       |  12 - 15 bytes
 +---------------------------------------------------------------+
 |                  Instruction 0: Opcode (int32_t)              |  16 - 19 bytes
 +---------------------------------------------------------------+
 |                  Instruction 0: Argument (int32_t)            |  20 - 23 bytes
 +---------------------------------------------------------------+
 |                             ...                               |
 +---------------------------------------------------------------+
 |                  Instruction N: Opcode (int32_t)              |  16 + 8*N - 4 bytes
 +---------------------------------------------------------------+
 |                  Instruction N: Argument (int32_t)            |  16 + 8*N bytes
 +---------------------------------------------------------------+
```

- **File Length Enforcement:** `exact_length = 16 + 8 * instruction_count`. Files of any other length are rejected immediately by the loader (Fail-Closed).
- **Opcode Boundaries:** Opcodes are stored as standard 32-bit integers. 
- **Bitemporal Store Argument Packing:** For `OP_LOAD_AS_OF` (opcode `0x0D`), the 32-bit argument is packed to store two indices:
  - **Upper 16 bits:** The store index in the C backend stores array.
  - **Lower 16 bits:** The index of the inputs array holding the `as_of` epoch timestamp.

### C. Implied Portability Passport Fields (Future Specification)
To eventually transition alternative runtimes into **Alternative Certified Implementations**, compiled artifacts must incorporate a standardized "Passport" metadata header. Playgrounds imply the following minimum passport fields:
1. `spec_version`: Identifies the exact Igniter language specification targeted.
2. `artifact_format_version`: Version of the compiled `.igapp`/`.igbin` schema.
3. `compiled_by`: Cryptographic identifier/version hash of the producing compiler.
4. `required_capabilities`: An array of required VM capabilities (e.g., `["bitemporal_read", "custom_observations", "concurrency_lock_free"]`).
5. `target_profile`: The hardware target profile (e.g., `"standard-x64-posix"`, `"embedded-esp32-xtensa"`).

---

## 6. Runtime, Storage, and Backend Separation

A key architectural pattern proved in both playgrounds is the strict decoupling of VM execution from underlying database engines:

```text
 +---------------------+         FFI Boundary         +-----------------------+
 |  Native Exec Frame  | ---------------------------> |   Bitemporal Storage  |
 | (Stack / Registers) |   Zero FFI reads (C Space)   |  (C Temporal Backend) |
 |                     | <=========================== |                       |
 +---------------------+                              +-----------------------+
           |                                                      ^
           | Write-Only Observations                              | Mirror Sync
           v                                                      |
 +---------------------+                              +-----------------------+
 |  Observation Sink   |                               |  Ruby Host / Database |
 |  (Envelopes / WAL)  |                               |                       |
 +---------------------+                              +-----------------------+
```

1. **Execution-Storage Decoupling:** The bytecode execution loop in `runner.c` is completely unaware of database table shapes or indexing mechanisms. It evaluates instructions sequentially and resolves historical timeline lookups through a unified, read-only interface (`read_as_of_c`), query-mapping by integers rather than strings.
2. **Read-Write Invariant:** Execution state is strictly read-only. Business rules evaluate historical indices without ever writing database mutations. Write operations occur solely through separate, asynchronous observation streams (observation envelopes) written to logs or write-ahead logs (WAL).
3. **Pluggability:** By abstracting data reads behind standard index pointers, the execution supervisor can execute rules seamlessly against an in-memory C database, an FFI Callback to Ruby, an ESP32 flash chip, or a sharded Rust TCP database server, without any bytecode modifications.

---

## 7. Public-Claim & Stable-API Risk Surfaces

Maintaining absolute discipline in public wording and API guarantees is critical. The following areas represent major risk surfaces that must remain protected:

> [!WARNING]
> **No Stable API Guarantees:** As per current development policy, `igniter-lang` does not guarantee backward compatibility. Mainline facades and internal schemas are volatile. No playground FFI bindings or VM formats may be published as stable developer APIs.

> [!CAUTION]
> **No Public Performance Claims:** Benchmarks generated in playgrounds are highly synthetic, timing single-threaded timeline loops in clean memory with pre-warmed caches. 
- Mainline native execution from disk (`Native C AOT File VM`) is **15x slower than the resident supervisor** due to disk I/O bottlenecks.
- Under certain conditions, FFI boundary translation costs can degrade native execution.
- Publishing "1.5 million timeline evaluations per second" or "15.6x speedups over Ruby" as an official general-platform performance claim is misleading and architecturally premature.

### Mainline Impact Restrictions

| Surface | Protected / Closed Mainline Surface | Risk of Unauthorized Exposure |
| :--- | :--- | :--- |
| **Reference Runtime** | `igniter-lang/lib/` has **zero** runtime engines. Mainline reference support is strictly closed. | Promoting playground VMs as "Official Reference Runtimes" introduces massive maintenance debt and freezes compile-time design. |
| **CLI Run Command** | Mainline CLI only knows `igc compile`. | Attempting to implement `igc run` now will couple the CLI to unstable, delegated runtime structures. |
| **Production Ready** | All mainline files are pre-v1. | Claiming "Production Readiness" or "Spark-ready" support breaks developer trust due to lack of stable timeline schemas. |
| **Microcontroller / Embedded** | Dual-core execution on ESP32 is speculative playground design. | Marketing "Embedded IoT rule execution" creates unrealistic hardware support expectations. |

---

## 8. Explicit Boundary Answers for C4-A

The Implementation Surface Surveyor explicitly documents the following answers for the Portfolio Architect Supervisor:

### Q1: What exists today in the codebase?
- **Mainline:** A robust, compile-time compiler framework in `igniter-lang/lib/` supporting syntax parsing, static type-checking, Semantic IR code generation, and directory-based `.igapp` packaging. The CLI is strictly limited to compile-time analysis.
- **Playground:** High-performance, functional, stack-based bytecode VMs in both Ruby and C, a resident native supervisor with multi-phase module execution, an in-C sorted temporal database engine, an ESP32 FreeRTOS/ESP-NOW mesh implementation plan, and a sharded, multi-threaded bitemporal database engine written in Rust with WAL and TCP server capabilities.

### Q2: What is accepted evidence today?
Only AOT bytecode file-loading research evidence, native acceleration research evidence, and delegated experimental runtime evidence around the stack-based 8-bit opcode IVM.
- *Specifically:* Playground proofs showing that compiled `.igbin` files can be parsed, validated, and executed natively on a local host via Fiddle FFI. All accepted evidence remains non-canonical and non-authoritative.

### Q3: What is only sandbox candidate material?
The resident native supervisor, C-level pluggable temporal backend, ESP32 dual-core execution system, and the Rust sharded TCP database server. None of these have been accepted by the mainline, and they remain confined strictly to playgrounds.

### Q4: Where would `igc run` touch if ever implemented later?
It would touch only `igniter-lang/lib/igniter_lang/cli.rb` to register the command, calling a separate, pluggable FFI runner wrapper. It would not affect the core compiler orchestrator, assembler, or result-shape modules, preserving the clean compile-time/runtime separation.

### Q5: What minimal passport fields are already implied by artifacts?
`spec_version`, `artifact_format_version`, `compiled_by`, `required_capabilities`, and `target_profile`. These fields are required to validate compiled bytecode against host runtime capability profiles.

### Q6: What should be blocked from public wording?
All public claims or code comments referencing:
- "Production-ready execution engines"
- "Integrated ultra-fast Rust bitemporal databases"
- "Standard native C executors"
- "ESP32 microcontroller mesh support"
- "Stable runtime APIs or backward compatibility guarantees"
- "15.6x native speedups or millions of evaluations/sec"

---

## 9. Recommendations to the Portfolio Architect Supervisor (C4-A)

Based on our read-only audit of the playground and mainline surfaces, the Implementation Surface Surveyor presents the following recommendations to C4-A:

1. **Adopt a Clean Pluggable Interface for Runtimes:** Treat runtimes as separate, modular engines. If an experimental execution boundary is described in the R229 design card, it should specify that the compiler facade communicates with runtimes strictly through standard `.igapp` or `.igbin` serialization boundaries, preserving the absolute independence of the mainline compiler.
2. **Enforce Sandbox Intake Quarantine:** Do not merge or copy any playground native code (`runner.c` or Rust code) into mainline `igniter-lang/lib/` or `igniter-lang/experiments/`. Keep them quarantined until a dedicated, bounded intake card is authorized.
3. **Formulate the Artifact Passport Spec First:** Before authorizing any execution CLI commands (`igc run`), design the formal Artifact Passport metadata specifications in a design card. Standardizing spec versioning and capability manifests is an absolute prerequisite to runtime portability.
4. **Enforce Wording Discipline:** Maintain strict pre-v1, non-canonical disclaimers in all research scripts and documentation, and immediately purge any eager performance claims from developer guide drafts.

---

### Round 229 Handoff Marker

```text
Card: S3-R229-C2-P1
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-runtime-implementation-surface-and-candidate-facts-v0
Status: done

[D] Decisions
- Standardized the 6-field implementation status hierarchy and mapped 8 distinct playground components.
- Formalized the 16-byte .igbin binary bytecode layout and packed bitemporal store argument specification.
- Mapped 5 key passport fields required for future certified runtime portability models.

[S] Shipped / Signals
- Facts packet delivered cleanly to igniter-lang/docs/tracks/experimental-runtime-implementation-surface-and-candidate-facts-v0.md.
- Verified cleanly compiled target playgrounds with clean git status and zero uncommitted work trees.
- Proved 100% correct Ruby syntax checks on all active playground examples scripts.

[T] Tests / Proofs
- Cargo test executed --locked in playgrounds/igniter-tbackend (Builds and passes cleanly, 0 warnings).
- Ruby examples syntax checks completed successfully (Syntax OK).

[R] Risks / Recommendations
- Public performance claims of "1.5M QPS" represent a severe risk; native file-backed execution is I/O bound and 15x slower.
- Suggest routing the next stage to formalize the Artifact Passport Spec in a design card before any igc run CLI work is authorized.
```
