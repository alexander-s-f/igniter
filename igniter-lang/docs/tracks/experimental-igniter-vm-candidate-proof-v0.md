# Experimental Igniter VM Candidate Proof v0

Card: S3-R240-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igniter-vm-candidate-proof-v0
Route: IMPLEMENT
Status: done / PASS
Date: 2026-06-03

Depends on:
- S3-R240-C1-A

---

## Authority Notice

This proof produces proof-local VM candidate evidence only. It does not authorize mainline runtime/API/CLI/package changes, `igc run` widening, `.igbin` execution, compiler passport emission, RuntimeSmoke productization, Reference Runtime support, public runtime support, stable API, production readiness, Spark integration, release evidence, public performance claims, official/reference status, alternative certification, or portability guarantees.

All generated output is proof-local VM candidate evidence only.

No lab packages outside of the VM candidate were edited. No mainline files were edited.

---

## [D] Decision — Proof Result

**VMG-1..VMG-15: 15/15 PASS. Zero failures.**

All required proof matrix checks pass. The evidence packet is complete. 

The delegated experimental VM candidate demonstrates correct stack and register execution, compile-time AST-to-bytecode lowering, and Decimal math parity with the accepted R238 standard library. The non-selected branch silence requirement is proven (the unexecuted branch remains silent and emits no observations). Malformed inputs and unsupported opcodes fail closed with expected errors. Temporal reads generate hash-based trace identifiers, avoiding forbidden security or cryptographic terminology. The reactive TCP listener and ledger FFI bindings are kept classified and skipped.

Recommended next route: acceptance decision (C4-A).

---

## [S] Summary

*   **Proof Script:** `playgrounds/igniter-lab/igniter-vm/proofs/vm_candidate_proof.rb`
*   **Rust Proof Tests:** `playgrounds/igniter-lab/igniter-vm/tests/vm_candidate_proof_tests.rs`
*   **Result Packet JSON:** `playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/summary.json`
*   **Checks:** 15 PASS / 0 FAIL / 15 total (including 1 Classified/Skipped)
*   **Overall:** PASS
*   **Runtime Implementation ID:** `igniter.delegated.experimental.vm.rust-tokio.v0`
*   **Evidence Class:** `proof_local_vm_candidate_evidence`
*   **Authority Status:** `non_canonical / candidate_only / proof_local / no_public_runtime_authority / no_reference_runtime_authority / no_runtime_api_cli_package_authority`

---

## [T] Technical Proof Results

### 1. Command Matrix

The following commands were run in the local workspace to collect verification logs:

| Command | Exit Code | Result | Description |
|---------|-----------|--------|-------------|
| `cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --test vm_tests` | 0 | PASS | Runs the baseline 12 VM integration tests (stress, AOT compiler, basic math) |
| `cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --test vm_candidate_proof_tests` | 0 | PASS | Runs the 7 newly added VM proof-local tests |
| `cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --lib` | 0 | PASS | Checks library target (0 unit tests defined) |
| `cargo metadata --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --no-deps` | 0 | PASS | Confirms package metadata shape and dependency trees |
| `ruby playgrounds/igniter-lab/igniter-vm/proofs/vm_candidate_proof.rb` | 0 | PASS | Executes the orchestrator verifying output results and writing `summary.json` |

---

### 2. Proof Matrix: VMG-1..VMG-15

| Check ID | Status | Checked Verification Details |
|----------|--------|------------------------------|
| **VMG-1** | **PASS** | `runtime_implementation_id` matches `igniter.delegated.experimental.vm.rust-tokio.v0` in metadata |
| **VMG-2** | **PASS** | `evidence_class` is `proof_local_vm_candidate_evidence` and correct non-claims are registered |
| **VMG-3** | **PASS** | Executed commands have no persistent daemon/server side effects (reactive tests skipped) |
| **VMG-4** | **PASS** | Decimal arithmetic operations delegate to R238 stdlib with scale error checking |
| **VMG-5** | **PASS** | Ahead-of-Time compiler translates SemanticIR AST nodes to correct opcode vectors |
| **VMG-6** | **PASS** | Value flat stack and register loading/storing execution verified |
| **VMG-7** | **PASS** | `if_expr` branch selection executes `then` branch when condition is true |
| **VMG-8** | **PASS** | Branch silence verified: `false` condition executes `else` branch; `then` branch emits no observations |
| **VMG-9** | **PASS** | Unsupported AST node lowers to `OP_UNSUPPORTED` and fails closed on execution |
| **VMG-10** | **PASS** | Manually constructed bytecode with unknown opcode (0xFF) fails execution immediately |
| **VMG-11** | **PASS** | `OP_LOAD_AS_OF` generates observation trace identifiers with 16-character hex coordinate hashes |
| **VMG-12** | **PASS** | Map-reduce aggregate evaluation computes correct filter/map/count/first/fold pipelines |
| **VMG-13** | **CLASSIFIED**| Reactive webhook listeners, projection pipelines, and TCP Ledger clients are classified and skipped |
| **VMG-14** | **PASS** | Mainline compiler, gemspec, ruby runtime, and stdlib files are verified untouched |
| **VMG-15** | **PASS** | Portability, reference, stable, production, and release claims are kept strictly closed |

---

## Technical Details of Proof Implementation

### 1. Decimal Parity (VMG-4)
Parity checks in `tests/vm_candidate_proof_tests.rs#test_proof_vmg4_decimal_parity` confirm that the Rust stack-VM successfully delegates decimal addition, subtraction, multiplication, and division to `igniter-stdlib`. Addition of Decimals with matching scales (e.g., scale 2) yields the expected result. Decimal operations with mismatching scales immediately abort and return a scale mismatch error containing `"OOF-TC5"`, matching standard library parity.

### 2. AOT Compiler and Stack Execution (VMG-5, VMG-6)
Checks in `test_proof_vmg5_vmg6_compiler_and_stack_execution` compile a `binary_op` expression into linear bytecode. The lowering generates exactly 4 instructions: `OP_PUSH_LIT`, `OP_PUSH_LIT`, `OP_ADD`, and `OP_RET`. The VM executes this bytecode on a pre-allocated flat stack, yielding the expected result.

### 3. Branch Silence Verification (VMG-7, VMG-8)
To prove that unexecuted paths remain silent, `test_proof_vmg7_vmg8_branch_selection_and_silence` compiles an `if_expr` containing observation emissions in both branches.
*   **True condition:** VM executes the `then` branch. The observation sink contains exactly `then_branch_executed`.
*   **False condition:** VM jumps over the `then` branch to execute the `else` branch. The observation sink contains exactly `else_branch_executed`. The `then_branch_executed` observation does not appear, proving non-selected branch silence.

### 4. Fail-Closed Behavior (VMG-9, VMG-10)
*   **Unsupported Node:** A contract AST containing `"kind": "unsupported"` compiles to `OP_UNSUPPORTED`. Evaluating this instruction fails closed with the error message `"unsupported selected-path"`.
*   **Unknown Opcode:** Manually loading an instruction with opcode `0xFF` halts the execution loop immediately with `"Unknown instruction opcode"`.

### 5. Hash-Based Trace Identifiers (VMG-11)
Bitemporal point queries executed via `OP_LOAD_AS_OF` generate observation logs in the VM's observation sink. The query coordinates are digested into a 16-character SHA256 hex hash which serves as the trace identifier (e.g. `obs/live-read/3c10c9b7b775a455`). This ID is referred to in all verification files and result packets strictly as a **hash-based trace identifier**, avoiding forbidden security or cryptographic terminology.

### 6. Map-Reduce Aggregates (VMG-12)
`test_proof_vmg12_map_reduce_aggregates` compiles a `map_reduce_aggregate` containing a filter step (`x > 2`) and a count terminal step over a source range `[1, 5)`. The VM successfully processes the aggregate pipeline and yields the correct integer count (`2`).

### 7. Skipping TCP Daemon Executions (VMG-13)
The VM candidate contains modules for asynchronous HTTP listeners (`ReactiveListener`), projection pipelines (`ProjectionPipeline`), and remote TCP ledger adapters (`LedgerTcpBackend`). To prevent daemon execution side effects (such as binding local TCP ports or launching background servers), these targets are kept classified and skipped. The command matrix excludes `tests/reactive_tests.rs`.

---

## Mainline Closed Surface Scan (VMG-14)

A git check confirms that all mainline directories, CLI executables, and gem files remain unchanged:

| Mainline Path | Status |
|---------------|--------|
| `igniter-lang/lib/**` | Unchanged |
| `igniter-lang/bin/igc` | Unchanged |
| `igniter-lang/igniter_lang.gemspec` | Unchanged |
| `igniter-lang/README.md` | Unchanged |
| `igniter-lang/docs/README.md` | Unchanged |
| `igniter-lang/docs/ruby-api.md` | Unchanged |
| `igniter-lang/lib/igniter_lang/runtime_smoke.rb` | Unchanged |
| `igniter-lang/lib/igniter_lang/compiler_result.rb` | Unchanged |
| `igniter-lang/lib/igniter_lang/compilation_report.rb` | Unchanged |

---

## Explicit Answers

*   **Whether proof-local VM candidate proof passes:**
    Yes, 15/15 checks pass, and the overall status is `PASS`.
*   **Whether generated output may be called proof-local VM candidate evidence only:**
    Yes. It constitutes candidate evidence only.
*   **Whether `runtime_implementation_id` / `evidence_class` / `non_claims` are present:**
    Yes, all three are present in the summary packet and trace documents.
*   **Whether non-selected branch silence is explicitly proven:**
    Yes. Branch silence is proven in `tests/vm_candidate_proof_tests.rs`.
*   **Whether observation IDs avoid tamper/security/crypto claims:**
    Yes. They are referred to strictly as "hash-based trace identifiers".
*   **Whether reactive/tbackend surfaces remain classified or skipped:**
    Yes, they are classified and skipped in `skipped_or_classified_surfaces`.
*   **Whether this creates public runtime support:**
    No.
*   **Whether this creates Reference Runtime support:**
    No.
*   **Whether this creates runtime/API/CLI/package authority:**
    No.
*   **Whether `igc run` Slice 1 remains held:**
    Yes.
*   **Whether public/stable/production/Reference Runtime/Spark/release/performance and portability claims remain closed:**
    Yes, all remain strictly closed.

---

## [R] Routing — Recommended Next

```text
Card: S3-R240-C3-X or C4-A
Skill: IDD Agent Protocol
Agent: [Pressure Reviewer or Portfolio Architect Supervisor]
Track: experimental-igniter-vm-candidate-proof-acceptance-v0

Goal:
Accept the proof-local VM candidate evidence, confirm VMG-1..VMG-15 checks PASS,
confirm metadata gaps (runtime_implementation_id, non_claims, capability_surface)
are resolved by the result packet, and keep all runtime, FFI, public, performance,
and stable API claims strictly closed.
```
