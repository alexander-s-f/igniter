# Experimental Igniter VM Candidate Surface Facts v0

Card: S3-R239-C2-P1
Skill: IDD Agent Protocol
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-igniter-vm-candidate-surface-facts-v0
Route: REVIEW
Status: complete
Date: 2026-06-03

Depends on:
- S3-R239-C1-A

---

## Authority Notice

This is a read-only facts packet. It does not authorize code edits, mainline runtime/API/CLI/package changes, `igc run` widening, `.igbin` execution, compiler passport emission, RuntimeSmoke productization, Reference Runtime support, public runtime support, stable API, production readiness, Spark integration, release evidence, public performance claims, official/reference status, alternative certification, or portability guarantees.

`playgrounds/igniter-lab/igniter-vm` is reviewed here strictly as delegated experimental VM candidate evidence only. Evidence is not authority.

No lab code was edited. No mainline code was edited.

---

## Inputs Read

The following playground and mainline inputs were inspected:
- Mainline authorization decision: `igniter-lang/docs/tracks/experimental-igniter-vm-candidate-intake-authorization-review-v0.md`
- Mainline status curation: `igniter-lang/docs/tracks/stage3-round238-status-curation-v0.md`
- Mainline stdlib acceptance decision: `igniter-lang/docs/tracks/experimental-stdlib-candidate-proof-acceptance-decision-v0.md`
- Mainline stdlib proof track: `igniter-lang/docs/tracks/experimental-stdlib-candidate-proof-v0.md`
- Playground stdlib proof summary: `playgrounds/igniter-lab/igniter-stdlib/out/stdlib_candidate_proof/summary.json`
- Playground VM build manifest: `playgrounds/igniter-lab/igniter-vm/Cargo.toml`
- Playground VM lockfile: `playgrounds/igniter-lab/igniter-vm/Cargo.lock`
- Playground VM README: `playgrounds/igniter-lab/igniter-vm/README.md`
- Playground VM sources:
  - `playgrounds/igniter-lab/igniter-vm/src/lib.rs`
  - `playgrounds/igniter-lab/igniter-vm/src/instructions.rs`
  - `playgrounds/igniter-lab/igniter-vm/src/value.rs`
  - `playgrounds/igniter-lab/igniter-vm/src/compiler.rs`
  - `playgrounds/igniter-lab/igniter-vm/src/tbackend.rs`
  - `playgrounds/igniter-lab/igniter-vm/src/reactive.rs`
  - `playgrounds/igniter-lab/igniter-vm/src/pipeline.rs`
  - `playgrounds/igniter-lab/igniter-vm/src/vm.rs`
  - `playgrounds/igniter-lab/igniter-vm/src/main.rs`
- Playground VM integration tests:
  - `playgrounds/igniter-lab/igniter-vm/tests/vm_tests.rs`
  - `playgrounds/igniter-lab/igniter-vm/tests/reactive_tests.rs`

---

## [D] Decision — Recommendation

**Accept `igniter-vm` as delegated experimental VM candidate evidence for intake.**

The Virtual Machine demonstrates a working stack-based, register-gated execution architecture with a built-in ahead-of-time (AOT) compiler translating SemanticIR AST node graphs to bytecode. It is fully grounded in the accepted R238 stdlib candidate proof through a Cargo path dependency on `igniter-stdlib`, utilizing its `Decimal` implementation to evaluate validated arithmetic operations.

Exact recommendation for C4-A:
1. **Accept crate structure:** Intake the Rust crate targets (`lib` and `bin`) and dependencies.
2. **Accept execution model:** Classify the instruction pointer control flow, flat value stack, registers, and opcode behaviors.
3. **Accept compilation pipeline:** Record the AST lowering rules mapping high-level constructs (literal, ref, binary_op, if_expr, temporal_read, emit_observation, map_reduce_aggregate) to linear bytecode.
4. **Accept bitemporal observations:** Acknowledge the generation of `temporal_live_read_observation` and `emit_observation` records containing 16-character SHA256 hex hashes as valid audit evidence.
5. **Flag gaps:** Document the absence of a `runtime_implementation_id` and capability manifest within the VM crate itself, and note that `reactive_tests.rs` relies on starting an external `tbackend` daemon executable through an absolute path.
6. **Maintain holds:** Keep `igc run` Slice 1 held and keep all public, performance, and Reference Runtime claims strictly closed.

---

## [S] Signals

```text
igniter-vm (playgrounds/igniter-lab/igniter-vm/):
  Language:      Rust (edition 2021)
  Package:       igniter_vm v0.1.0
  Crate targets: library (src/lib.rs), binary (src/main.rs)
  Dependencies:  serde 1.0, serde_json 1.0, async-trait 0.1, tokio 1.0,
                 sha2 0.10, hex 0.4, crc32fast 1, chrono 0.4, uuid 1.0,
                 igniter_stdlib (local path dependency: ../igniter-stdlib)
  Built binary:  playgrounds/igniter-lab/igniter-vm/target/debug/igniter-vm
  Built library: playgrounds/igniter-lab/igniter-vm/target/debug/libigniter_vm.rlib

Cargo commands executed:
  cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --test vm_tests
    → 12/12 PASS (concurrency stress, map-reduce, AOT compiler, decimal ops, bitemporal query)
  cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --lib
    → 0/0 tests (library target contains no unit tests)
  cargo metadata --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --no-deps
    → Output structure validated successfully
```

---

## [T] Technical Inventory

### 1. Build and Dependency Surface

| Item | Fact | Status |
|------|------|--------|
| Package Name | `igniter_vm` | Confirmed in `Cargo.toml` |
| Version | `0.1.0` | Confirmed in `Cargo.toml` |
| Edition | `2021` | Confirmed in `Cargo.toml` |
| Dependencies | `serde`, `serde_json`, `async-trait`, `tokio`, `sha2`, `hex`, `crc32fast`, `chrono`, `uuid` | Confirmed in `Cargo.toml` |
| Stdlib Dependency | `igniter_stdlib = { path = "../igniter-stdlib" }` | Confirmed in `Cargo.toml` |
| Targets | `lib` (`src/lib.rs`), `bin` (`src/main.rs`), `tests` (`vm_tests.rs`, `reactive_tests.rs`) | Confirmed in `Cargo.toml` |

---

### 2. VM Instruction Set and Opcode Map

The VM operates on an 8-bit instruction opcode model defined in `src/instructions.rs`:

| Opcode Name | Opcode Hex | Arguments | Execution Behavior |
|-------------|------------|-----------|--------------------|
| `OP_PUSH_LIT` | `0x01` | `[LiteralValue]` | Pushes literal value to stack |
| `OP_LOAD_REF` | `0x02` | `[SymbolName]` | Loads binding value from inputs or temporal context |
| `OP_STORE_REG` | `0x03` | `[RegisterIndex]` | Pops stack and stores value in register |
| `OP_LOAD_REG` | `0x04` | `[RegisterIndex]` | Loads value from register and pushes to stack |
| `OP_ADD` | `0x05` | None | Pops two values, adds them (delegating Decimals to `igniter_stdlib`), pushes result |
| `OP_SUB` | `0x06` | None | Pops two values, subtracts them, pushes result |
| `OP_MUL` | `0x07` | None | Pops two values, multiplies them, pushes result |
| `OP_DIV` | `0x08` | None | Pops two values, divides them (checks zero/neg scale errors), pushes result |
| `OP_EQ` | `0x09` | None | Pops two values, compares them, pushes boolean equality |
| `OP_JMP` | `0x0A` | `[IPOffset]` | Jumps to instruction pointer offset |
| `OP_JMP_IF` | `0x0B` | `[IPOffset]` | Pops boolean, jumps to offset if true |
| `OP_JMP_UNLESS`| `0x0C` | `[IPOffset]` | Pops boolean, jumps to offset if false |
| `OP_LOAD_AS_OF`| `0x0D` | `[StoreName, CoordinateRef]` | Queries bound TBackend for fact value, pushes result, emits audit observation |
| `OP_EMIT_OBS` | `0x0E` | `[ObservationKind]` | Pops value, emits evaluation observation record, pushes value back to stack |
| `OP_RET` | `0x0F` | None | Pops value, returns it, halts execution loop |
| `OP_GT` | `0x10` | None | Pops two values, compares them (a > b), pushes result |
| `OP_MAP_REDUCE`| `0x11` | `[DescriptorJSON]` | Evaluates map-filter-aggregate pipelines (count, first, fold) |
| `OP_UNSUPPORTED`| `0x99` | None | Halts execution, returns unsupported operation error |

---

### 3. Ahead-of-Time (AOT) Compiler and AST Lowering

`src/compiler.rs` translates a SemanticIR AST JSON contract (`expression` field) recursively:

*   `literal` AST nodes compile to `OP_PUSH_LIT` instructions.
*   `ref` AST nodes compile to `OP_LOAD_REF` instructions.
*   `binary_op` AST nodes compile the operands recursively, then emit `OP_ADD`/`OP_SUB`/`OP_MUL`/`OP_DIV`/`OP_EQ`/`OP_GT`.
*   `if_expr` AST nodes compile the condition recursively, emit a placeholder `OP_JMP_UNLESS`, compile the `then` branch, emit a placeholder `OP_JMP`, compile the `else` branch, and then backpatch the jump target offsets.
*   `temporal_read` AST nodes compile to `OP_LOAD_AS_OF` instructions.
*   `emit_observation` AST nodes compile the inner expression, then emit `OP_EMIT_OBS`.
*   `map_reduce_aggregate` AST nodes serialize the descriptor and compile to `OP_MAP_REDUCE`.
*   `unsupported` AST nodes compile to `OP_UNSUPPORTED`.
*   Any unrecognized node returns a compile-time `Err`.

---

### 4. Bitemporal Query and Observation Auditing

The VM interacts with a pluggable `TBackend` interface (`src/tbackend.rs`) to query temporal facts:

*   `OP_LOAD_AS_OF` queries `read_as_of(store, coordinate_value)`.
*   The in-memory timeline search identifies the latest fact valid as of the given timestamp coordinate (valid-time axis).
*   Executing `OP_LOAD_AS_OF` automatically appends a `temporal_live_read_observation` record to the VM's observation sink.
*   The observation record generates a 16-character SHA256 hex coordinate hash using the first 8 bytes of the SHA256 digest of `"{store}-{coordinate_value}"` as its `observation_id` (e.g., `obs/live-read/3c10c9b7b775a455`), ensuring tamper-evidence.

---

### 5. Webhook Listener and Reactive Projection Pipeline

`src/reactive.rs` and `src/pipeline.rs` orchestrate reactive projections:

*   `ReactiveListener` binds a `TcpListener` on a local port, listening for HTTP/1.1 POST webhooks.
*   `ProjectionPipeline` registers webhooks on a remote TCP ledger (`LedgerTcpBackend`), receives incoming database events, spawns a new VM thread, executes the contract bytecode using event coordinates, and writes computed projections back to the ledger store.
*   This reactive loop operates on an out-of-band concurrency model using `tokio::spawn` and async web services.

---

### 6. Relationship to R238 Stdlib Candidate Proof

*   **Path Dependency:** `igniter-vm` compiles against `igniter-stdlib` (accepted in R238) via cargo path referencing.
*   **Arithmetic Delegation:** The VM's `OP_ADD`, `OP_SUB`, `OP_MUL`, `OP_DIV`, and `OP_GT` implementations delegate to `igniter_stdlib::decimal::Decimal` functions, verifying that the FFI/C-ABI Decimal layer is functionally compatible with the Rust VM.
*   **Collections & Temporal Isolation:** The VM does not import or use `igniter_stdlib::collections` or `igniter_stdlib::temporal`. Instead, collections mapping/folding is implemented directly inside the VM's `OP_MAP_REDUCE` evaluator, isolating it from the unverified parts of the stdlib.

---

### 7. Relationship to Artifact Passport Minimum Fields

*   **Crate Gap:** The `igniter_vm` crate has no built-in mechanism to emit or parse passport manifests (`*.passport.json`).
*   **Missing Fields:** `runtime_implementation_id`, `evidence_class`, and `non_claims` fields are completely absent from the VM source code and build targets.
*   **Status:** While R232 verified passport manifests for existing Ruby/IVM runtimes, the Rust VM candidate remains unintegrated with the passport metadata structure.

---

### 8. Relationship to `igc run` Slice 0 and Slice 1 Readiness

*   **Design Fit:** `igc run` Slice 0 design defines the interface for local CLI invocation. The binary executable `igniter-vm run` conforms to this layout by taking `--contract <path>`, `--inputs <path>`, and `--as-of <timestamp>` arguments.
*   **Slice 1 Status:** Widening the mainline `igc` compiler tool to execute contracts natively remains closed. The Rust VM's reactive and AOT compilation logic provides excellent proof-local sandbox evidence, but does not open runtime integration or widen mainline capabilities.

---

## Support / Gap Matrix

| Component Surface | Coverage Status | Evidence Status | Dependency on R238 | Missing Passport | Future Proof Target |
|-------------------|-----------------|-----------------|--------------------|------------------|---------------------|
| **Crate Shape** | Library + Binary | Verified | N/A | Yes | No |
| **AOT Compiler** | AST JSON to Bytecode | Verified | N/A | Yes | Yes (Compiler passport) |
| **Flat Stack Execution** | Flat Stack + Registers | Verified | N/A | Yes | Yes (Execution proof) |
| **Decimal Ops** | Delegated Decimal | Verified | Depends on stdlib | Yes | Yes (Decimal math proof) |
| **Bitemporal Queries** | `OP_LOAD_AS_OF` (1D) | Verified | N/A | Yes | Yes (Bitemporal proof) |
| **Audit Observations**| SHA256 hex coordinate hash | Verified | N/A | Yes | Yes (Audit proof) |
| **Map-Reduce Agg** | map/filter/fold/count/first| Verified | N/A | Yes | Yes (Aggregates proof) |
| **Tokio Concurrency** | 10-thread stress tests | Verified | N/A | Yes | No |
| **TCP Ledger Backend**| Socket serialization | Unrun (Daemon required) | N/A | Yes | No |
| **Reactive Listener** | HTTP webhook server | Unrun (Daemon required) | N/A | Yes | No |

---

## Gap and Wording Register

### Structural Gaps

*   **G-1: No Crate-Level Metadata:** `igniter_vm` does not define a `runtime_implementation_id` or capability manifest in its source files.
*   **G-2: Missing Passport Manifest:** The VM cannot emit compiler/runtime passport descriptors.
*   **G-3: No Library Unit Tests:** `cargo test --lib` reports 0 tests. All test coverage is defined in integration scripts under `tests/`.
*   **G-4: TCP Test Dependency:** `tests/reactive_tests.rs` attempts to execute an external `tbackend` daemon binary via an absolute machine path (`/Users/alex/dev/projects/igniter/playgrounds/igniter-lab/igniter-tbackend/target/release/tbackend`) and open local ports, preventing it from being run during read-only sandbox verification.

### Wording Risks (Low Severity Comments)

*   `src/lib.rs:2` comment: `"Premium, high-performance concurrent bitemporal VM crate"`
*   `src/main.rs:2` comment: `"High-performance, premium-class CLI for igniter-vm"`
*   `tests/vm_tests.rs:2` comment: `"Premium, comprehensive integration and concurrency verification suite"`
*   *Verdict:* These comments use playground-assertion phrasing. They are not visible in any CLI output, public documentation, or mainline files, representing low risk.

---

## Command Matrix

The following Cargo verification commands were executed in a read-only environment:

| Command | Working Directory | Exit Code | Result Details | Status |
|---------|-------------------|-----------|----------------|--------|
| `cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --test vm_tests` | Workspace Root | `0` | 12 tests passed, 0 failed. Verifies Decimal math, branching, aggregates, concurrency, and temporal queries. | PASS |
| `cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --lib` | Workspace Root | `0` | 0 tests executed. No unit tests defined inside `src/`. | PASS (0 tests) |
| `cargo metadata --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --no-deps` | Workspace Root | `0` | Package metadata JSON returned correctly. Validates dependencies and targets. | PASS |

---

## Evidence vs Authority Classification

To prevent authority leakage, all VM candidate elements are classified below:

| Playground Element | Evidence Classification | Authority Status |
|--------------------|-------------------------|------------------|
| `playgrounds/igniter-lab/igniter-vm/` | Delegated experimental VM candidate | Non-canonical sandbox prototype |
| `target/debug/igniter-vm` | Playground executable CLI | Candidate CLI only; no mainline runtime authority |
| AOT Compiler lowering | Compiler pipeline evidence | Prototype lowering only; no compiler passport authority |
| MemoryHistoryBackend | Lab temporal mock | Sandbox simulator; no bitemporal database authority |
| Observation auditing | Proof-local audit trace | Prototype audit trail; no security or cryptographic signature claims |
| `reactive_tests.rs` | Concurrency integration sketch | Playground test only; starts servers and uses local ports |

---

## Closed-Surface Scan

The following mainline and production paths remain unchanged and strictly closed:

| Mainline Path | Status | Changed by C2-P1 |
|---------------|--------|------------------|
| `igniter-lang/lib/**` | Closed | No |
| `igniter-lang/bin/igc` | Closed | No |
| `igniter-lang/igniter_lang.gemspec` | Closed | No |
| `igniter-lang/README.md` | Closed | No |
| `igniter-lang/docs/README.md` | Closed | No |
| `igniter-lang/docs/ruby-api.md` | Closed | No |
| `igniter-lang/lib/igniter_lang/runtime_smoke.rb` | Closed | No |
| `igniter-lang/lib/igniter_lang/compiler_result.rb` | Closed | No |
| `igniter-lang/lib/igniter_lang/compilation_report.rb` | Closed | No |

---

## Explicit Answers

*   **Whether `igniter-vm` is intake-ready as candidate evidence:**
    Yes. The Rust crate compiles successfully, and the comprehensive integration suite (`vm_tests.rs`) compiles and reports 12/12 test passes, demonstrating a functional stack VM execution model.
*   **Whether it depends on accepted stdlib candidate proof evidence:**
    Yes. It declares a direct path dependency on `igniter-stdlib` (accepted in R238) and uses its validated `Decimal` struct for VM decimal operations.
*   **Whether it provides enough evidence for later proof-local VM proof authorization review:**
    Yes. The VM's test coverage of compiler lowering, conditional branching, map-reduce aggregations, and high concurrency stress provides a solid baseline for authorizing a future proof-local VM proof card.
*   **Whether it creates runtime/public/reference/stable/production authority:**
    No. It is constrained to `playgrounds/igniter-lab/igniter-vm/` and creates no mainline execution authority.
*   **Whether `igc run` Slice 1 should remain held:**
    Yes. Widening the mainline `igc` compiler tool to support runtime execution remains held.
*   **Whether frontier/conformance adjacent artifacts were excluded:**
    Yes. All adjacent artifacts under `conformance/` or `polymorphic_traits_proof/` were excluded.
*   **Whether public/stable/production/Reference Runtime/Spark/release/performance/portability claims remain closed:**
    Yes. All such claims remain closed. No alternative certifications or portability guarantees are opened.

---

## C4-A Recommendation

It is recommended that the supervisor agent (`portfolio-architect-supervisor`) accepts `igniter-vm` as candidate evidence under the following conditions for the next round:

```text
runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
evidence_class:            delegated_experimental_vm_candidate_evidence
supported_surface:         AOT compiler, stack execution, register gating, Decimal math,
                           observations, map-reduce aggregation
unsupported_surface:       bitemporal BiHistory, stream processing, invariant checks
gap_register:              G-1 (no crate metadata), G-2 (no passport manifest),
                           G-3 (no lib unit tests), G-4 (tests depend on local ports/tcp server)
non_claims:                not Reference Runtime, not public runtime support, not stable API,
                           not production ready, not release evidence, not Spark integration,
                           no performance or portability guarantees
```

The next Main Line route should authorize a bounded, proof-local VM proof implementation to address these metadata gaps (e.g., generating `summary.json` with the required metadata and testing Decimal operations natively) without opening runtime or CLI authority.

---

Card: S3-R239-C2-P1
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-igniter-vm-candidate-surface-facts-v0
Status: complete
