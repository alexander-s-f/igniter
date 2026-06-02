# Experimental Lab Ecosystem Surface Facts v0

Card: S3-R236-C2-P1
Skill: IDD Agent Protocol
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-lab-ecosystem-surface-facts-v0
Route: REVIEW
Status: complete
Date: 2026-06-02

Depends on:
- S3-R235-C5-S

---

## Authority Notice

This is a read-only facts packet. It does not authorize implementation,
mainline code changes, public claims, stable API, production readiness,
Reference Runtime support, public runtime support, Spark integration,
release evidence, or public performance claims.

No lab code was edited. No mainline code was edited.

---

## [D] Decision — Recommendation

**Route igniter-stdlib for the next candidate intake, followed by
igniter-vm.**

`igniter-stdlib` is the foundational dependency for `igniter-vm`. Its
verifier already passes locally, its scope is narrow and well-bounded
(Decimal arithmetic FFI + collections + temporal `.ig` signatures), and
it carries no overclaim wording. It is the cleanest next intake target.

`igniter-vm` follows because it depends on `igniter-stdlib`, has 12
Cargo tests passing locally, and covers a broader surface (temporal
reads, decimal arithmetic, branch execution, map-reduce, concurrency).

`igniter-tbackend` requires wording hardening before intake. Its README
uses authority-level language ("production-grade", "incredible
throughput", "prevents PostgreSQL bloat (SparkCRM)") that must be
re-contextualized as lab-local assertion before a formal facts packet
can be produced without risk of overclaim propagation.

`igniter-compiler` was already intaken in R235 (GAP-1..GAP-7 remain
open). No re-intake needed.

`igniter-runtime` (Ruby IVM) has accepted R225-R228 evidences in Main
Line. Resident supervisor intake (R230) is the pending next step there.

Exact recommendation:

```text
1. Route igniter-stdlib candidate intake next.
2. Route igniter-vm candidate intake after stdlib intake.
3. Hold igniter-tbackend pending wording hardening.
4. Igniter-runtime: carry forward resident supervisor intake route (R230).
5. acts-as-tbackend and igniter-apps: no intake needed; companion surfaces only.
```

---

## [S] Summary — Compact

```text
Lab components found (playgrounds/igniter-lab/):

  igniter-compiler   Rust    alternative experimental compiler candidate
                             already intaken R235; GAP-1..GAP-7 open
  igniter-runtime    Ruby    delegated experimental runtime candidate (IVM)
                             R225-R228 evidences accepted; resident supervisor pending
  igniter-vm         Rust    delegated experimental runtime candidate
                             12 cargo tests PASS (confirmed); depends on igniter-stdlib
  igniter-stdlib     Rust    stdlib candidate
                             verify_stdlib.rb PASS (confirmed); FFI Decimal exports
  igniter-tbackend   Rust    backend/substrate candidate
                             HOLD — README overclaim wording; starts server
  acts-as-tbackend   Ruby    adapter/integration candidate
                             ActiveRecord adapter sketch; demo requires network
  igniter-apps       Ruby    app-consumer / UX pressure
                             todolist CLI; local scratch state

Commands confirmed locally run (no network, no destructive ops):
  ruby verify_compiler.rb        → exit 0 / 5 sources PASS
  ruby verify_stdlib.rb          → exit 0 / 7 assertions PASS
  cargo test (igniter-vm)        → 12/12 PASS

Commands not run (server, network, or destructive):
  ruby test_suite.rb (tbackend)  → requires cargo build + Magnus FFI
  ruby verify_*.rb (tbackend)    → some start persistent TCP servers
  ruby demo.rb (acts-as-tbackend)→ requires bundler/inline (network)
  ruby examples/*.rb (runtime)   → prior evidence in R225-R228 out/ files

Lab assertion wording risks identified:
  igniter-tbackend README: "production-grade", "incredible throughput",
    "prevents PostgreSQL bloat (SparkCRM)", benchmark numbers without
    mainline context — HIGH RISK before intake
  verify_*.rb exit strings: "🏆 ALL TESTS PASSED SUCCESSFULLY!" — LOW RISK
    (same pattern as igniter-compiler verifier; lab-assertion scope)

No component creates mainline authority today.
```

---

## [T] Technical Inventory

### 1. igniter-compiler

**Classification:** alternative experimental compiler candidate (lab evidence only)

**Intake status:** accepted as lab candidate evidence — R235-C2-P1

**Location:** `playgrounds/igniter-lab/igniter-compiler/`

**Language:** Rust (edition 2021)

**Build output:** `target/release/igniter_compiler` (present; pre-built)

**Dependencies:**

```text
serde 1.0, serde_json 1.0, blake3 1.5, sha2 0.10
No network dependencies. No Magnus/FFI. Pure Rust.
```

**Pipeline:**

```text
Lexer → Parser → Classifier → TypeChecker → Emitter → Assembler
Outputs: .igapp directory with manifest, semantic_ir_program, compilation_report,
         requirements, diagnostics, classified_ast, projections, compatibility_metadata,
         contracts/*.json
```

**Verifier:** `verify_compiler.rb` — 5 sources, exit 0. Confirmed run.

**Known gaps (GAP-1..GAP-7, from R235-C2-P1):**

```text
GAP-1: vendor_lead_pipeline emits empty contracts array
GAP-2: --compiler-profile-source parsed but silently ignored
GAP-3: compiled_at hardcoded "2026-05-06T00:00:00Z"
GAP-4: source_path embeds absolute local machine path
GAP-5: no Cargo tests
GAP-6: OOF-M1 (pure contract escape check) commented out
GAP-7: no runtime_implementation_id in emitted artifacts
```

**Next:** No immediate intake needed. GAP-1..GAP-7 are lab-internal
hardening tasks. A future authorization review may open lab hardening.

---

### 2. igniter-runtime (Ruby IVM)

**Classification:** delegated experimental runtime candidate

**Intake status:** R225-R228 evidences accepted in Main Line; resident
supervisor intake pending (R230 authorized)

**Location:** `playgrounds/igniter-lab/igniter-runtime/`

**Language:** Ruby (IVM interpreter) + C extension (`lib/ivm/runner.c`)

**Structure:**

```text
lib/ivm.rb               IVM namespace and loader
lib/ivm/vm.rb            Stack-based VM in Ruby
lib/ivm/compiler.rb      SemanticIR-to-IVM-AST-to-bytecode compiler (Ruby)
lib/ivm/instructions.rb  Opcode definitions
lib/ivm/stdlib.rb        Stdlib bridge (calls into igniter-stdlib FFI or pure Ruby)
lib/ivm/tbackend.rb      TBackend adapter hook
lib/ivm/runner.c         C native runner extension (FFI acceleration)
```

**Proof scripts and their Main Line evidence:**

```text
examples/compiler_to_ivm_adapter_proof.rb
  → R225 adapter-fit evidence (PASS: AIP-1..AIP-12)
  → summary: out/compiler_to_ivm_adapter_proof/summary.json
  → supported nodes: literal, ref, binary_op (+), if_expr, apply (stdlib.integer.add)
  → unsupported: stdlib.integer.gt, field_access

examples/ivm_adapter_branch_coverage_proof.rb
  → R226 branch/comparison hardening evidence

examples/ivm_ffi_bytecode_acceleration_proof.rb
  → R227 native acceleration research evidence
  → not a public performance claim

examples/ivm_aot_bytecode_file_loading_proof.rb
  → R228 AOT bytecode file-loading research evidence

examples/ivm_resident_supervisor_proof.rb
examples/resident_supervisor_candidate_intake_proof.rb
  → R230 resident supervisor candidate intake
  → intake authorized by S3-R230-C1-A; separate track

examples/ivm_bitemporal_c_backend_proof.rb
  → C temporal backend research; separate candidate

examples/verify_vm_stdlib_integration.rb
  → VM + Rust stdlib FFI integration verification
  → not run in this session (prior evidence available from runtime docs)
```

**Fixtures:** `minimal_gt.ig`, `minimal_if_else.ig` — small `.ig` sources
for branch proof scripts

**Out/ artifacts (pre-existing evidence):**

```text
out/compiler_to_ivm_adapter_proof/summary.json — R225 PASS evidence
out/ivm_adapter_branch_coverage_proof/*.igapp   — R226 compiled artifacts
```

**Docs:**

```text
docs/ivm-poc-prototype.md
docs/resident_native_supervisor_research_report.md
docs/c_temporal_backend_integration_research_report.md
docs/concurrency_and_embedded_esp32_mesh_research.md
```

**Boundary (from README):** Playground evidence only. No public `igc run`
authority. No RuntimeSmoke, Reference Runtime, public API/CLI, package,
release, production, or Spark authority.

**Next:** Resident supervisor candidate intake (R230). C temporal backend
intake separate.

---

### 3. igniter-vm (Rust VM)

**Classification:** delegated experimental runtime candidate

**Intake status:** not yet intaken by Main Line

**Location:** `playgrounds/igniter-lab/igniter-vm/`

**Language:** Rust (edition 2021, async/tokio)

**Build output:** `target/release/igniter-vm` (binary), `libigniter_vm.rlib` (present)

**Dependencies:**

```text
serde 1.0, serde_json 1.0
async-trait 0.1
tokio 1.0 (full features)
sha2 0.10, hex 0.4, crc32fast 1
chrono 0.4 (serde feature)
uuid 1.0 (v4)
igniter_stdlib = { path = "../igniter-stdlib" }   ← local dep
```

**Architecture:**

```text
src/lib.rs          Module root
src/value.rs        Value type: Null, Bool, Integer, Float, Decimal { value, scale },
                    String (Arc<str>), Array, Record, Observation
src/instructions.rs Opcode definitions: OP_PUSH_LIT, OP_LOAD_REF, OP_LOAD_AS_OF,
                    OP_STORE_REG, OP_LOAD_REG, OP_ADD, OP_SUB, OP_MUL, OP_DIV,
                    OP_EQ, OP_GT, OP_AND, OP_NOT, OP_JUMP_IF_FALSE, OP_JUMP,
                    OP_EMIT_OBSERVATION, OP_MAP_REDUCE, OP_RET
src/vm.rs           Stack-based async VM; observation_sink (Mutex<Vec<Value>>)
src/compiler.rs     SemanticIR JSON → bytecode compiler
src/tbackend.rs     MemoryHistoryBackend (in-memory timeline for proof)
src/reactive.rs     Reactive pipeline support
src/pipeline.rs     Pipeline execution
src/main.rs         CLI entrypoint
```

**Cargo tests confirmed (2026-06-02):**

```text
tests/vm_tests.rs:
  test_decimal_addition_success                  ok
  test_decimal_addition_scale_mismatch_error     ok  (OOF-TC5)
  test_decimal_subtraction_success               ok
  test_decimal_subtraction_scale_mismatch_error  ok  (OOF-TC5)
  test_decimal_multiplication_scale_summation    ok
  test_decimal_division_scale_subtraction        ok
  test_decimal_division_by_zero_error            ok  (OOF-DM2)
  test_numeric_fallbacks                         ok
  test_bitemporal_nonblocking_load_as_of         ok
  test_high_concurrency_stress                   ok
  test_aot_compiler_lowering                     ok
  test_map_reduce_aggregate_optimizations        ok

tests/reactive_tests.rs: (present; not separately enumerated in output)

Result: 12 passed; 0 failed; finished in 0.01s
```

**Covered semantics:**

```text
Decimal arithmetic (add/sub/mul/div) with scale propagation and OOF-TC5/DM2
Integer and float fallback arithmetic
Temporal read: OP_LOAD_AS_OF → MemoryHistoryBackend point query
Observation sink: temporal_live_read_observation
if_expr: OP_JUMP_IF_FALSE / OP_JUMP branch semantics
AOT compiler lowering: SemanticIR JSON → bytecode
Map-reduce aggregate: filter/map/fold/count/first pipeline (OP_MAP_REDUCE)
Concurrency: 10-task tokio stress test
```

**Not covered / not proven:**

```text
stream / fold_stream execution
invariant node evaluation
OLAP point execution
temporal BiHistory (bitemporal two-axis read)
error recovery / partial execution
runtime_implementation_id declaration
```

**Wording risk:** README is empty ("# Igniter VM\n"). No overclaim risk.

**Next:** Candidate intake after igniter-stdlib intake. Requires:
`runtime_implementation_id`, evidence class, non-claims, supported-
semantics matrix, failure behavior, and proof commands to be documented
in intake packet.

---

### 4. igniter-stdlib (Rust)

**Classification:** stdlib candidate

**Intake status:** not yet intaken by Main Line

**Location:** `playgrounds/igniter-lab/igniter-stdlib/`

**Language:** Rust (edition 2021)

**Build output:** `target/release/libigniter_stdlib.dylib` (present;
`crate-type = ["rlib", "cdylib"]`)

**Dependencies:**

```text
serde 1.0, serde_json 1.0
No other dependencies. Zero third-party runtime deps beyond serde.
```

**Architecture:**

```text
src/lib.rs          FFI exports (stdlib_decimal_add/sub/mul/div)
src/decimal.rs      Decimal type: { value: i64, scale: u32 }
                    Operations: add, sub, mul, div
                    Scale rules: add/sub require equal scales (OOF-TC5);
                                 mul → scale = S1 + S2;
                                 div → scale = S1 - S2 (div by zero → OOF-DM2)
src/collections.rs  Collection operations (not separately inspected)
src/temporal.rs     Temporal primitives (not separately inspected)
```

**Signature files (.ig):**

```text
stdlib/math.ig        Math function signatures
stdlib/collections.ig Collection function signatures
stdlib/temporal.ig    Temporal function signatures
```

**FFI exports (no_mangle):**

```text
stdlib_decimal_add(a_val, a_scale, b_val, b_scale, *out_val, *out_scale) → i32
stdlib_decimal_sub(a_val, a_scale, b_val, b_scale, *out_val, *out_scale) → i32
stdlib_decimal_mul(a_val, a_scale, b_val, b_scale, *out_val, *out_scale) → void
stdlib_decimal_div(a_val, a_scale, b_val, b_scale, *out_val, *out_scale) → i32
```

**Verifier confirmed (2026-06-02):**

```text
verify_stdlib.rb:
  1. Builds CDYLIB target (cargo build --release already cached)
  2. Loads via Fiddle FFI
  3. Seven correctness assertions:
     A. Addition identical scale: PASS (10.50 + 25.25 = 35.75)
     B. Addition scale mismatch → OOF-TC5: PASS
     C. Subtraction identical scale: PASS (35.75 - 10.50 = 25.25)
     D. Subtraction scale mismatch → OOF-TC5: PASS
     E. Multiplication scale summation: PASS (10.5 * 2.5 = 26.25, scale 2)
     F. Division scale subtraction: PASS (26.25 / 2.5 = 10.5, scale 1)
     G. Division by zero → OOF-DM2: PASS
  4. Signature file presence: math.ig, collections.ig, temporal.ig PASS
Result: ALL STANDARD LIBRARY CORRECTNESS AND LINKABILITY TESTS PASSED
```

**Wording risk:** `verify_stdlib.rb` prints "🏆 ALL STANDARD LIBRARY
CORRECTNESS AND LINKABILITY TESTS PASSED SUCCESSFULLY!" — lab-assertion
style. Not a mainline authority claim.

**Critical observation:** `igniter-vm` declares `igniter_stdlib` as a
local path dependency. Stdlib intake should precede VM intake to avoid
a gap in the evidence chain.

**Next:** Prioritize for next candidate intake. Clean scope, proven FFI,
no overclaim wording.

---

### 5. igniter-tbackend (Rust + Magnus Ruby FFI)

**Classification:** backend/substrate candidate

**Intake status:** not yet intaken by Main Line. **Hold pending wording
hardening.**

**Location:** `playgrounds/igniter-lab/igniter-tbackend/`

**Language:** Rust (edition 2021) + Magnus Ruby FFI binding

**Build output:** `target/release/libigniter_tbackend_playground.dylib`,
`target/release/libigniter_tbackend_playground.bundle`, `target/release/tbackend`
(all present)

**Dependencies:**

```text
magnus 0.7          Ruby-Rust FFI bridge (requires Ruby headers at build time)
blake3 1.5          Content hashing
parking_lot 0.12    Sharded RwLocks (128 shards)
serde 1.0, serde_json 1.0
rmp-serde 1.3       MessagePack serialization
crc32fast 1         CRC32 framing
uuid 1.0 (v4, fast-rng)
ctrlc 3.4           Signal handling
```

**Architecture (Pack pattern):**

```text
src/main.rs          Standalone TCP server entrypoint
src/server.rs        TCP listener and request dispatcher
src/kernel.rs        Core store kernel (ShardedFactLog, FactLogInner)
src/fact.rs          Fact type definition
src/pure_core.rs     Pure bitemporal core operations
src/timeline.rs      Timeline index and partition_point search
src/lib.rs           Magnus Ruby FFI exports
src/packs/
  mod.rs             Pack registry
  base_audit.rs      Audit log, counters, latency
  multitenant_scanner.rs  Multi-tenant directory scanner
  mesh_cluster.rs    P2P gossip WAL replication
  trigger.rs         Async webhook dispatcher
  analytics.rs       Grouped analytics, SMAs, moving windows
  cross_store.rs     Cross-store joins
  snapshot.rs        Snapshot, WAL compaction
  diagnostics.rs     RAM footprint, disk audit
  pipeline.rs        Reactive event rules and template rendering
  auth.rs            Authentication pack
  mcp.rs             MCP pack
  query.rs           Query pack
```

**Verifier scripts present (not run):**

```text
test_suite.rb           Core unit + FFI tests (starts server, requires Magnus build)
verify_mesh.rb          P2P mesh cluster replication
verify_trigger.rb       Webhook dispatch
verify_analytics.rb     Analytics pack
verify_cross_store.rb   Cross-store joins
verify_snapshot.rb      Snapshot / WAL compaction
verify_diagnostics.rb   Uptime + memory footprint
verify_pipeline.rb      Reactive pipeline
verify_auth.rb          Authentication
verify_mcp.rb           MCP pack
verify_compiler_integration.rb  Compiler integration
```

**Support scripts (not run — start persistent processes):**

```text
run_server.rb           Starts tbackend binary as background server
demo_server.rb          Demo server with sample data
tbackend_service.rb     Service control plane (start/stop/status)
tbackend_repl.rb        Network REPL
bench.rb                Benchmark runner
```

**Overclaim wording register (HIGH RISK):**

```text
README.md:
  "production-grade"
    → overclaim; no mainline production proof
  "zero-dependency"
    → false; has magnus, parking_lot, etc.
  "incredible throughput"
    → public performance claim; no mainline proof
  "Production Use Cases: Prevent PostgreSQL bloat (SparkCRM)"
    → SparkCRM product claim; not authorized by Main Line
  "build edge swarms (RPi5/IoT)"
    → embedded deployment claim; not authorized
  "orchestrate out-of-band webhooks"
    → product use-case claim; lab-local only
  "128-way sharded locking concurrency"
    → design claim; in-lab only; not certified
  "O(log N) Logarithmic Temporal Scaling"
    → performance claim; in-lab benchmarks only; AN-1 from R229-C4-A applies
  "$O(\log N)$ ... reduces ... to $O(\log N)$" (technical_architecture.md)
    → mathematical performance claim; lab-local benchmark
  "MobX Transparent Functional Reactions"
    → borrowed external branding; not a mainline concept
  "🏆 ALL TESTS PASSED SUCCESSFULLY!" (README)
    → lab assertion; not mainline proof
  docs/technical_architecture.md and docs/user_guide.md
    → extensive production-level documentation language
    → all lab-local only; not authorized for public docs
```

**Why HOLD:** The overclaim density in the TBackend README and docs is
high enough that any intake packet risk citing these documents would
propagate authority-level language into Main Line. The wording must be
explicitly scoped as lab-assertion-only in the README before the component
can be cleanly intaken. This is a lab-internal hardening task.

**Next:** Lab-internal wording hardening of README (not a Main Line task).
After hardening, route a bounded candidate intake.

---

### 6. acts-as-tbackend (Ruby)

**Classification:** adapter/integration candidate

**Intake status:** not yet intaken; companion surface only

**Location:** `playgrounds/igniter-lab/acts-as-tbackend/`

**Language:** Ruby

**Structure:**

```text
lib/acts_as_tbackend.rb       Loader and thread-local client cache
lib/acts_as_tbackend/client.rb   TCP client for TBackend playground server
lib/acts_as_tbackend/extension.rb  ActiveRecord after_save/after_destroy hooks
demo.rb                       Demo script (requires bundler/inline + network)
```

**Boundary:** Local adapter sketch. No production ActiveRecord integration
authority. No Ledger/TBackend mainline mutation authority. No public API,
packaging, release, or deployment authority.

**Not run:** `demo.rb` uses `bundler/inline` with `source "https://rubygems.org"`,
which requires network access.

**Next:** No intake needed. Companion surface to igniter-tbackend. After
tbackend intake, acts-as-tbackend may be surveyed as an adapter candidate.

---

### 7. igniter-apps (Ruby todolist)

**Classification:** app-consumer / UX pressure

**Intake status:** no intake needed; local scratch application

**Location:** `playgrounds/igniter-lab/igniter-apps/todolist/`

**Language:** Ruby

**Structure:**

```text
todolist/todo.rb          CLI entrypoint and command parser
todolist/lib/temporal_store.rb  Local temporal store
todolist/lib/repl.rb      Interactive REPL
todolist/lib/ui.rb        CLI rendering helpers
todolist/todo.wal         Local WAL data (scratch state)
```

**Purpose:** Demonstrates temporal app patterns using WAL-backed history.
Does not depend on any other lab component directly. Local CLI only.

**Boundary:** Local product/app experiment. Not a public example. Not
release, package, production, or demo authority.

**Next:** No intake. Useful as app-consumer pressure if temporal runtime
and tbackend develop further.

---

## Component Classification Matrix

| Component | Classification | Intake Status | Priority |
|-----------|---------------|---------------|----------|
| igniter-compiler | alternative experimental compiler candidate | intaken R235 (GAP-1..7) | ongoing hardening |
| igniter-runtime (Ruby IVM) | delegated experimental runtime candidate | R225-R228 accepted | R230 resident supervisor next |
| igniter-vm (Rust) | delegated experimental runtime candidate | not intaken | HIGH — route next after stdlib |
| igniter-stdlib (Rust) | stdlib candidate | not intaken | HIGHEST — route next |
| igniter-tbackend (Rust) | backend/substrate candidate | not intaken | HOLD — wording hardening first |
| acts-as-tbackend (Ruby) | adapter/integration candidate | not intaken | LOW — companion surface only |
| igniter-apps/todolist | app-consumer / UX pressure | not intaken | no intake needed |

---

## Command / Proof Matrix

| Command | Run in this session | Result | Evidence class |
|---------|---------------------|--------|----------------|
| `ruby verify_compiler.rb` | Yes | exit 0 / 5 sources, fragment_class match | lab evidence (R235-C2-P1) |
| `ruby verify_stdlib.rb` | Yes | exit 0 / 7 assertions PASS | lab evidence — stdlib candidate |
| `cargo test` (igniter-vm) | Yes | 12/12 PASS, 0.01s | lab evidence — VM candidate |
| `ruby compiler_to_ivm_adapter_proof.rb` | No (prior) | PASS — AIP-1..AIP-12 | R225 accepted evidence |
| `ruby ivm_adapter_branch_coverage_proof.rb` | No (prior) | PASS | R226 accepted evidence |
| `ruby ivm_ffi_bytecode_acceleration_proof.rb` | No (prior) | PASS | R227 accepted evidence |
| `ruby ivm_aot_bytecode_file_loading_proof.rb` | No (prior) | PASS | R228 accepted evidence |
| `ruby verify_vm_stdlib_integration.rb` | No | not run (runtime env) | integration script present |
| `ruby test_suite.rb` (tbackend) | No | not run (starts server) | not confirmed |
| `ruby verify_*.rb` (tbackend) | No | not run (server/destructive) | not confirmed |
| `ruby demo.rb` (acts-as-tbackend) | No | not run (network required) | not confirmed |
| `ruby todo.rb` (apps) | No | not run | not needed |

---

## Artifact / Output Inventory

| Path | Type | Status |
|------|------|--------|
| `igniter-compiler/out/add.igapp/` | .igapp artifact | present; fragment_class: core |
| `igniter-compiler/out/decimal_contract.igapp/` | .igapp artifact | present; fragment_class: core |
| `igniter-compiler/out/availability_projection.igapp/` | .igapp artifact | present; fragment_class: escape |
| `igniter-compiler/out/tenant_availability_projection.igapp/` | .igapp artifact | present |
| `igniter-compiler/out/vendor_lead_pipeline.igapp/` | .igapp artifact | present; contracts: [] (GAP-1) |
| `igniter-runtime/out/compiler_to_ivm_adapter_proof/summary.json` | proof summary | present; R225 PASS |
| `igniter-runtime/out/ivm_adapter_branch_coverage_proof/*.igapp` | .igapp artifacts | present; R226 evidence |
| `igniter-stdlib/target/release/libigniter_stdlib.dylib` | compiled dylib | present; CDYLIB |
| `igniter-vm/target/release/igniter-vm` | compiled binary | present |
| `igniter-tbackend/target/release/tbackend` | compiled binary | present |
| `igniter-tbackend/target/release/libigniter_tbackend_playground.*` | Magnus bundle | present |

---

## Dependency / Toolchain Inventory

| Component | Language | Key deps | Build tool | Network required |
|-----------|----------|----------|------------|-----------------|
| igniter-compiler | Rust 2021 | serde, serde_json, blake3, sha2 | cargo | No (Cargo.lock present) |
| igniter-runtime | Ruby | (none; pure Ruby + C ext) | none / gcc for C | No |
| igniter-vm | Rust 2021 | tokio, serde, sha2, chrono, uuid, igniter_stdlib (local) | cargo | No |
| igniter-stdlib | Rust 2021 | serde, serde_json | cargo | No |
| igniter-tbackend | Rust 2021 | magnus, blake3, parking_lot, serde, rmp-serde, uuid, ctrlc | cargo | No |
| acts-as-tbackend | Ruby | activerecord, sqlite3 (via bundler/inline) | bundler | **Yes** (demo.rb) |
| igniter-apps | Ruby | (none visible) | none | No |

---

## Risk / Gap Inventory

### Wording Risks

| Component | Risk | Severity |
|-----------|------|----------|
| igniter-tbackend README | "production-grade", "incredible throughput", "prevents PostgreSQL bloat (SparkCRM)" | HIGH |
| igniter-tbackend docs/ | Extensive production-level architecture docs with performance claims | HIGH |
| igniter-tbackend bench.rb | Benchmark runner — produces numbers that could be cited as public claims | MEDIUM |
| igniter-compiler verify_compiler.rb | "100% compliant" exit string | LOW (intaken; documented in R235) |
| igniter-stdlib verify_stdlib.rb | "🏆 ALL TESTS PASSED SUCCESSFULLY!" | LOW (lab-assertion pattern) |

### Structural Gaps

| Component | Gap | Impact |
|-----------|-----|--------|
| igniter-compiler | GAP-1..GAP-7 (see R235-C2-P1) | intake closed; hardening pending |
| igniter-vm | No runtime_implementation_id | required for portability intake |
| igniter-vm | No evidence class declaration | required for intake |
| igniter-vm | No non-claims block | required for intake |
| igniter-stdlib | No runtime_implementation_id or evidence class | required for intake |
| igniter-tbackend | No Igniter spec version or capability manifest | required for intake |
| igniter-tbackend | depends on Magnus (Ruby headers at build) | build portability risk |
| igniter-tbackend | verify scripts start persistent TCP servers | cannot be run in read-only survey |
| acts-as-tbackend | depends on bundler/inline + network | cannot be run in read-only survey |

### Authority Non-Claims (confirmed for all components)

```text
No component creates mainline authority today.
No component creates Reference Runtime support.
No component creates public runtime support.
No component creates stable API guarantee.
No component creates production readiness.
No component creates Spark integration authority.
No component creates release evidence.
No component creates public performance claim.
No component is a certified alternative implementation.
No component creates artifact portability guarantee.
```

---

## Overclaim Register (Detailed)

### igniter-tbackend README.md

| Phrase | Category | Risk |
|--------|----------|------|
| "production-grade" | authority overclaim | HIGH — implies production readiness |
| "zero-dependency" | false claim | HIGH — has magnus, parking_lot, etc. |
| "incredible throughput" | public performance claim | HIGH — no mainline proof |
| "Prevent PostgreSQL bloat (SparkCRM)" | product claim | HIGH — SparkCRM not authorized |
| "build edge swarms (RPi5/IoT)" | deployment claim | MEDIUM — not authorized |
| "$O(\log N)$ Logarithmic Temporal Scaling" | perf claim | MEDIUM — lab-local benchmark only |
| "128-way sharded locking" | design claim | LOW — informational, but sounds official |
| "MobX Transparent Functional Reactions" | borrowed branding | LOW — misleading external term |
| "🏆 ALL TESTS PASSED SUCCESSFULLY!" | lab assertion | LOW — same pattern as other labs |

Per AN-1 (R229-C4-A): all performance numbers produced inside the lab
are accepted only as in-playground sandbox measurements and must not be
used for public wording, Main Line performance claims, candidate intake
status, release notes, public docs, product claims, or stable API/runtime
claims.

---

## [R] Routing — Exact Next

**Recommended next route:**

```text
Card: S3-R236-C3-A (or future authorization card)
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: igniter-stdlib-candidate-intake-authorization-review-v0

Goal:
Authorize a bounded stdlib candidate intake/proof packet for
igniter-stdlib (Rust), confirming its scope as a stdlib candidate only
(Decimal arithmetic FFI + .ig signature files), without authorizing
mainline stdlib replacement, public stdlib API, production readiness,
or any other closed surface.

Depends on:
- experimental-lab-ecosystem-surface-facts-v0 (this document)

Must not authorize:
- mainline stdlib replacement
- public stdlib API
- production readiness
- stable API before v1
- Spark integration
- release evidence
- public performance claims
```

**Secondary recommended route (after stdlib intake):**

```text
igniter-vm candidate intake authorization review
Depends on: igniter-stdlib intake closure
```

**Hold until lab-internal hardening:**

```text
igniter-tbackend candidate intake — hold until README wording hardened
```

**No route needed:**

```text
igniter-compiler — intaken R235; GAP-1..7 are lab-internal tasks
igniter-runtime  — R230 resident supervisor track already routing
acts-as-tbackend — companion surface; no intake
igniter-apps     — app pressure; no intake
```
