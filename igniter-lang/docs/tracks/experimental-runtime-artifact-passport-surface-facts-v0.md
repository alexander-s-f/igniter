# Facts Packet: Experimental Runtime Artifact Passport Surface Facts v0

**Card:** S3-R231-C2-P1  
**Skill:** IDD Agent Protocol  
**Agent:** [Implementation Surface Surveyor]  
**Role:** implementation-surface-surveyor  
**Track:** experimental-runtime-artifact-passport-surface-facts-v0  
**Route:** REVIEW  
**Depends on:**
- S3-R230-C4-A

---

## 1. Executive Summary & Context

This facts packet maps the current experimental runtime, backend, compiled artifact, and ActiveRecord app-consumer bridge surfaces across the Igniter ecosystem. Its primary purpose is to identify what metadata fields are required to establish a formal **Artifact Passport Portability Boundary** in future rounds.

In accordance with [resident-supervisor-acceptance](file:///Users/alex/dev/projects/igniter/igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-acceptance-decision-v0.md) and [r229-boundary-decision](file:///Users/alex/dev/projects/igniter/igniter-lang/docs/tracks/experimental-runtime-implementations-and-portability-boundary-decision-v0.md), this review operates under a strict **read-only boundary**. It does not accept any sandbox surface as official authority, nor does it authorize mainline runtime implementations, passport emission, or `igc run` development.

---

## 2. Inventory of Current Ecosystem Surfaces

To design a robust, portable passport metadata envelope, we must first map the four distinct surfaces that currently interact with compiled business rule artifacts:

```text
 +-------------------------------------------------------------------------+
 |                                COMPILER                                 |
 |  Produces:                                                              |
 |    - .igapp (Directory of manifest/diagnostics/SemanticIR/JSONs)        |
 |    - .igbin (AOT flat binary bytecode)                                  |
 +-------------------------------------------------------------------------+
                                      |
                                      v
 +-------------------------------------------------------------------------+
 |                            PORTABILITY PASSPORT                         |
 |  Future Metadata envelope establishing:                                 |
 |    - Target profile capability matches                                  |
 |    - Cryptographic verification digests                                 |
 +-------------------------------------------------------------------------+
                                      |
         +----------------------------+----------------------------+
         |                                                         |
         v                                                         v
 +----------------------------------+              +-------------------------------+
 |             RUNTIMES             |              |           BACKENDS            |
 |  - Ruby IVM VM (MemoryMachine)   |  OP_LOAD_VT  |  - Ruby MemoryHistoryBackend  |
 |  - Native C Interpreter          | ===========> |  - Native C Sorted Database   |
 |  - Resident C Supervisor         |  TCP Socket  |  - Rust Sharded WAL TCP Daemon|
 +----------------------------------+              +-------------------------------+
                                                                   ^
                                                                   | Replication
                                                                   |
                                                   +-------------------------------+
                                                   |         APP-CONSUMERS         |
                                                   |  - ActiveRecord SQL DB        |
                                                   |  - acts-as-tbackend Bridge    |
                                                   +-------------------------------+
```

### A. Runtimes (Instruction Execution Engines)
1. **`ivm-ruby-poc` (`playgrounds/igniter-runtime/lib/ivm/`):** A stack-based, 8-bit instruction set Virtual Machine written in Ruby. Used as the original semantics oracle.
2. **`ivm-c-ffi` (`playgrounds/igniter-runtime/lib/ivm/runner.c`):** Compiled C engine interpreted via Fiddle FFI.
3. **`ivm-c-resident` (`playgrounds/igniter-runtime/examples/ivm_resident_supervisor_proof.rb`):** Bounded multi-phase candidate loader (`load_module`) and in-memory evaluator (`execute_module`) designed to eliminate disk I/O.
4. **`ivm-esp32-mesh` (`playgrounds/igniter-runtime/docs/concurrency_and_embedded_esp32_mesh_research.md`):** Speculative microcontroller Dual-Core FreeRTOS task port executing rule logic directly pinned to hardware cores.

### B. Backends (Temporal Storage Substrates)
1. **`Ruby MemoryHistoryBackend` (`playgrounds/igniter-runtime/lib/ivm/tbackend.rb`):** Basic bitemporal list store written in Ruby, querying history via linear searches.
2. **`Native C Sorted Database` (`playgrounds/igniter-runtime/lib/ivm/runner.c`):** Static C structs (`HistoricalRecord`, `TemporalStore`, `TemporalBackend`) executing point lookups completely in native memory via insertion-sorted binary searches.
3. **`Rust Sharded TCP Daemon` (`playgrounds/igniter-tbackend/`):** Pre-spawned worker thread pool TCP server written in Rust, utilizing `magnus` bindings, Blake3 value hashing, 128-way sharded locks, and MessagePack-framed FileBackend WAL durability.

### C. App-Consumer Bridges (Data Replicators)
1. **`acts_as_tbackend` (`playgrounds/acts-as-tbackend/`):** An ActiveSupport::Concern ActiveRecord concern that mirrors model SQL transaction lifecycle commits (`after_commit` hooks) into the Rust TCP server daemon over sockets as bitemporal facts with unique UUIDs and causal lineage chains.

---

## 3. Surface & Field Gap Matrix

This matrix maps the current availability of Artifact Passport metadata fields across existing compiled formats and playground output summary structures, highlighting severe gaps.

| Passport Field Family | Mainline `.igapp` | Playground `.igbin` | Playground RSUP `summary.json` | Status / Gap Analysis |
| :--- | :---: | :---: | :---: | :--- |
| **`artifact_kind`** | **PARTIAL** | **MISSING** | **PARTIAL** | `.igapp` uses `"format": "igapp_dir"` inside `manifest.json`. `.igbin` has zero self-identifying markers. Both formats require explicit, distinct tags. |
| **`artifact_format_version`**| **PARTIAL** | **MISSING** | **PARTIAL** | `.igapp` uses `"format_version": "0.1.0"`. `.igbin` uses raw header version `1`. Missing unified portability version specs. |
| **`spec_version`** | **PARTIAL** | **MISSING** | **PARTIAL** | Mainline tracks `"grammar_version": "0.1.0"`. Missing explicit runtime semantics version boundaries. |
| **`compiled_by` / `compiler_id`**| **MISSING** | **MISSING** | **MISSING** | **Critical Gap.** No compiled artifact records the identity, build, or cryptographic signature of the compiler that produced it. |
| **`compiled_at`** | **MISSING** | **MISSING** | **MISSING** | **Critical Gap.** No compiled artifact has time metadata. |
| **`source_digest`** | **PARTIAL** | **MISSING** | **MISSING** | Mainline compiles with `"source_hash": "sha256:..."`. Completely missing from native binary executables. |
| **`semantic_ir_digest`** | **PARTIAL** | **MISSING** | **MISSING** | Mainline records `"semantic_ir_ref": "semanticir/..."`. Bytecode binaries have no reference back to their semantic graph. |
| **`artifact_digest`** | **PARTIAL** | **MISSING** | **MISSING** | Mainline assembler calculates `"artifact_hash"` over directory contents. Binary `.igbin` files lack cryptographic hashes. |
| **`runtime_target_kind`** | **MISSING** | **MISSING** | **PARTIAL** | Intaked playground output names `"implementation_class": "delegated.experimental.runtime"`. Excluded from binary files. |
| **`runtime_implementation_id`**| **MISSING** | **MISSING** | **PRESENT** | Only present inside playground summary JSON: `igniter.delegated.experimental.ivm.c_resident`. |
| **`required_capabilities`** | **MISSING** | **MISSING** | **PRESENT** | Present in playground `summary.json` manifest (e.g. `supports_load_once_execute_many`), but entirely absent from compiled binaries. |
| **`required_opcodes`** | **MISSING** | **MISSING** | **PRESENT** | Present in playground summary (e.g. `["0x01", "0x02"]`). Decoupled from mainline assembler. |
| **`input_contract`** | **PARTIAL** | **MISSING** | **MISSING** | `.igapp` defines input nodes in `semantic_ir_program.json`. `.igbin` has zero self-documenting input layouts. |
| **`failure_policy`** | **MISSING** | **MISSING** | **PARTIAL** | Summary notes `failure_behavior: "fail_closed_on_malformed_input"`. Missing compiled metadata tags. |
| **`evidence_class`** | **MISSING** | **MISSING** | **PRESENT** | Present in playground summary only. |
| **`authority_status`** | **MISSING** | **MISSING** | **PRESENT** | Present in playground summary only. |

---

## 4. Key Artifact Serialization Formats

### A. Mainline `.igapp` Assembly Structure
The assembled directory aggregates the following JSON payloads:
- `manifest.json`: Metadata linking program hashes, format schemas, and list of contracts.
- `semantic_ir_program.json` (or `semantic_ir.json` in older versions): Represents the compiled normative semantics graph.
- `classified_ast.json`: Tracks typechecker and AST metrics (e.g., `oof_count`).
- `requirements.json`: Captures lifecycle, temporal windows, and capability requests.
- `diagnostics.json`: Diagnostic collection.
- `contracts/`: Subdirectory storing independent contract JSON payloads.

### B. Playground AOT `.igbin` Bytecode format
The binary layout read by native executors is restricted to a compact structure:
- **Header (16 bytes):**
  - Magic (4 bytes): `\x49\x47\x42\x00` (`"IGB\0"`)
  - Version (4 bytes): `\x01\x00\x00\x00` (Int32 little-endian, always `1`)
  - Instruction Count (4 bytes): `N` (Int32 little-endian)
  - Padding (4 bytes): `\x00\x00\x00\x00` (Reserved)
- **Body (`8 * N` bytes):**
  - Stream of instruction records. Each record consists of:
    - Opcode (4 bytes): Int32 little-endian.
    - Argument (4 bytes): Int32 little-endian.
- **Fail-Closed Verification:** `exact_length == 16 + 8 * N`. File reading aborts instantly if length violates this rule.

---

## 5. Explicit Boundary Answers

The Implementation Surface Surveyor explicitly documents the following answers for S3-R231-C2-P1:

### Q1: Do current compiled artifacts already contain enough passport metadata?
- **No.** Current artifacts are almost completely devoid of portability metadata. The binary `.igbin` format has **zero** self-documenting metadata fields—lacking compiler IDs, digest chains, execution requirements, or input specifications. The directory-based `.igapp` format has partial compiler metrics, but is missing critical fields like target profile capability mapping, compilation timestamps, and failure policies.

### Q2: Which fields are missing or inconsistent?
- **Missing:** `compiled_by`/`compiler_id`, `compiled_at`, `source_digest`, `semantic_ir_digest`, `required_capabilities`/`feature_set`, `required_opcodes`, `failure_policy`, `evidence_class`, and `authority_status`.
- **Inconsistent:** The naming of digests in `.igapp` is highly inconsistent (e.g. `artifact_hash` in `manifest.json` vs `source_hash` in `semantic_ir_program.json`), and there is no unified definition of what constitutes a "correct execution model" identifier between FFI and native environments.

### Q3: Do `.igapp` and `.igbin` need different `artifact_kind` values?
- **Yes.** They represent fundamentally different compiler targets.
  - `.igapp` is a **directory-based logical graph assembly** containing human-readable JSON manifests, diagnostics, and Semantic IR nodes. It requires a high-level parsing runtime (such as `ivm-ruby-poc` or the mainline compiler facade).
  - `.igbin` is a **pre-compiled flat binary bytecode executable** designed for direct, zero-overhead memory loading by native interpreted runtimes (like `ivm-c-resident`).
  - To prevent loaders from crossing boundaries, `.igapp` should be mapped as `artifact_kind: "igapp_dir"` (or equivalent directory tag) and `.igbin` mapped as `artifact_kind: "igbin_aot_binary"`.

### Q4: Should the Rust TBackend be mapped as a runtime, backend, or separate temporal substrate candidate?
- The Rust `igniter-tbackend` is strictly a **delegated pluggable storage/backend (temporal substrate) candidate**.
  - It does not evaluate compiled bytecode or interpret IVM instructions.
  - It strictly manages sharded timeline indexes, binary-searchedpoint reads (`latest_for`), range queries (`facts_for`), write-ahead log persistence (`wal.rs`), and TCP stream frame serialization.
  - Decoupling it completely from runtime execution ensures a clean, storage-agnostic VM loop. It should **never** be mapped as a runtime.

### Q5: Should `acts-as-tbackend` be mapped as an app-consumer bridge, not a runtime?
- **Yes.** `acts-as-tbackend` is strictly an **app-consumer replication bridge**.
  - It is an ActiveRecord model extension that catches commit lifecycles and replicates database row mutations to the temporal server over TCP sockets as bitemporal facts.
  - It contains zero rule compiler, AST parser, or bytecode execution logic.

### Q6: Does any playground README or benchmark wording create public-claim risk?
- **Yes.** The [igniter-tbackend README.md](file:///Users/alex/dev/projects/igniter/playgrounds/igniter-tbackend/README.md#L106-L109) lists un-qualified speedup and throughput claims:
  - `"Mixed Reads/Writes Throughput: Resolves a blistering 25,749 requests/sec over TCP sockets!"`
  - `"Deep Timeline Point-in-Time Lookups: Achieves a 4.78x speedup over mainline under a history depth of 5,000 commits."`
- These measurements are single-threaded, in-memory, synthetic tests run in pre-warmed sandbox environments. 
- In accordance with AN-1 binding discipline, publishing these numbers without explicit `"informational research-signal / proof-local timing only"` qualifiers creates extreme public-claim and stable-API risks.

### Q7: Should any files outside `igniter-lang/docs/tracks/` be edited now?
- **No.** Under the current REVIEW boundary, all code files, playground files, gemspecs, and mainline compiler surfaces must remain strictly read-only and un-mutated.

---

## 6. Risk Notes for the Portfolio Architect Supervisor (C4-A)

The Surveyor highlights the following key risks to C4-A:

1. **Eager `igc run` Implementation Risk:** Implementing any execution command inside the mainline CLI (`igc run`) before the Artifact Passport specifications are codified is highly dangerous. It will result in the CLI directly coupling to volatile playground FFI VM entrypoints, creating severe architectural debt and breaking changes.
2. **FFI vs. Native Substrate Parity Risk:** The C resident supervisor bypasses FFI callback overhead by resolving temporal indices in compiled C memory. However, the Rust TBackend Daemon operates over TCP frames. This represents two divergent execution boundaries (direct in-memory pointers vs network serialization frames). The Artifact Passport must explicitly define the **Target Temporal Substrate** (e.g. `substrate: "c_memory_history"` vs `substrate: "tcp_socket_framed"`) to ensure runtimes do not attempt to load incompatible backends.
3. **Public Claim & Stable API Exposure Risk:** Playground README files contain aggressive marketing and speed claims. Under real production databases, these figures will fluctuate. Wording discipline must be strictly enforced: all sandbox-derived metrics must carry rough, informational-only, non-claim signals to protect the project's pre-v1 integrity.

---

## 7. Recommended Next Main Line Boundary Route

The Surveyor recommends routing the next card to:

```text
experimental-runtime-artifact-passport-minimum-boundary-design-v0
```

This next track should be design-only, focusing strictly on codifying the JSON schema for the Passport metadata block (including cryptographic signature chains, required capability manifests, and target execution profiles) to ensure complete runtime portability.

---

### Round 231 Handoff Marker

```text
Card: S3-R231-C2-P1
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-runtime-artifact-passport-surface-facts-v0
Status: done

[D] Decisions
- Standardized the four-tier ecosystem map (Runtimes, Backends, Artifacts, App-Consumers) to isolate the passport boundary.
- Mapped 16 discrete passport fields across 3 active compiled formats, exposing major cryptographic and capability manifest gaps.
- Confirmed that .igapp and .igbin must be categorized under separate artifact_kind tags to prevent loading mismatches.

[S] Shipped / Signals
- Created facts packet at igniter-lang/docs/tracks/experimental-runtime-artifact-passport-surface-facts-v0.md.
- Verified absolute read-only boundary with zero mainline, package, or playground file mutations.
- Identified un-qualified timing metrics in playgrounds/igniter-tbackend/README.md as public-claim risk surfaces.

[T] Tests / Proofs
- Performed read-only audit of the playgrounds/acts-as-tbackend concern and verified FFI network client structure.
- Audited sharded logarithmic timeline read bounds in Rust tbackend (128 RwLocks).

[R] Risks / Recommendations
- FFI direct memory pointers and TCP network frames represent two distinct execution substrates; the Passport must explicitly catalog substrate requirements.
- Suggest routing next to experimental-runtime-artifact-passport-minimum-boundary-design-v0 to codify passport schemas before igc run implementation.
```
