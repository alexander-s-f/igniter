# Experimental igc run Slice 1 Current Surface and VM Candidate Facts v0

Card: S3-R241-C2-P1
Skill: IDD Agent Protocol
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-igc-run-slice1-current-surface-and-vm-candidate-facts-v0
Route: SURVEY
Status: done

Depends on:
- S3-R241-C1-D

---

## 1. Executive Summary

This read-only facts packet maps the current mainline and experimental surfaces for the Slice 1 VM-candidate selector design of the `igc run` command. It documents current Slice 0 command shapes, passport fields, Rust VM candidate capabilities, gaps in selector/validation binding, and lab pressure inputs. 

> [!IMPORTANT]
> This is an evidence-gathering facts packet only. All stable API support, production readiness, compiler passport emission, Reference Runtime status, Spark CRM integration, and platform package execution authority remain strictly closed.

---

## 2. Current Slice 0 Command Shape and Selector Behavior

### CLI Invocation Shape
In Slice 0, the `run` command is exposed in [cli.rb](file:///Users/alex/dev/projects/igniter/igniter-lang/lib/igniter_lang/cli.rb) under the following usage pattern:

```text
igc run ARTIFACT.igapp \
  --passport PATH.passport.json \
  --input PATH.json \
  --runtime delegated-experimental:ivm-proof \
  --out PATH.json \
  --experimental
```

### Validation Constraints
The CLI parsing and verification logic is implemented in [experimental_igc_run.rb](file:///Users/alex/dev/projects/igniter/igniter-lang/lib/igniter_lang/experimental_igc_run.rb) and enforces the following:
* **`--experimental` flag:** Mandatory. Invocation fails if omitted (`missing_experimental`).
* **Artifact Target:** Must be a directory ending in `.igapp`. Single `.igbin` binary targets are rejected (`unsupported_path_igbin`).
* **Passport Parameter:** Requires explicit `--passport` pointing to a valid passport JSON file.
* **Input Object:** Requires explicit `--input` pointing to a JSON file containing a root object (`input_not_object`).
* **Output Target:** Requires explicit `--out` target file path.
* **Selector Match:** Only accepts the literal selector `delegated-experimental:ivm-proof`. Any other selector throws `unsupported_runtime`.

### Current Selector Behavior
When `delegated-experimental:ivm-proof` is selected, the runtime:
1. Dynamically requires the Ruby-implemented proof runtime from `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`.
2. Loads the `.igapp` using `RuntimeMachineMemoryProof::CompiledProgram.load_igapp(artifact_path)`.
3. Validates the program structure.
4. Evaluates the contract using `program.evaluate_contract(contract_name, input)`.

---

## 3. Current Result Packet Shape (Slice 0)

The result packet is written to the path specified in `--out` and conforms to the `experimental_igc_run_v0_result` kind:

```json
{
  "kind": "experimental_igc_run_v0_result",
  "format_version": "0.1.0",
  "card": "S3-R234-C2-I",
  "track": "experimental-igc-run-slice0-implementation-v0",
  "status": "ok",
  "experimental": true,
  "pre_v1": true,
  "stable_api": false,
  "artifact_ref": "/absolute/path/to/Add.igapp",
  "passport_ref": "/absolute/path/to/Add.igapp.passport.json",
  "input_ref": "/absolute/path/to/add_19_23.json",
  "runtime_selector": "delegated-experimental:ivm-proof",
  "runtime_authority": "non-canonical / delegated experimental",
  "outputs": {
    "sum": 42
  },
  "diagnostics": [],
  "non_claims": [
    "not stable API",
    "not production ready",
    "not public runtime support",
    "not Reference Runtime support",
    "not Spark integration",
    "not release evidence",
    "not public performance claim",
    "not compiler passport emission",
    "not igc run implementation"
  ],
  "not_compiler_result": true,
  "not_compilation_report": true,
  "not_compatibility_report": true,
  "not_receipt_sidecar": true,
  "not_release_evidence": true,
  "not_public_api_response_contract": true
}
```

---

## 4. Current Passport Manifest Fields

The schema for passport verification is drawn from existing proof-local manifests, such as [Add.igapp.passport.json](file:///Users/alex/dev/projects/igniter/igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json). The manifest fields are divided into metadata, validation tokens, capability descriptors, contracts, and proof markers:

| Field Name | Type | Description / Purpose |
| --- | --- | --- |
| `passport_kind` | String | Must equal `"artifact_passport"`. |
| `passport_schema_version` | String | Semantic version of the passport schema (e.g., `"0.1.0"`). |
| `artifact_kind` | String | Kind of artifact. Mainline Slice 0 enforces `"igapp_dir"`. |
| `artifact_format_version` | String | Underlying compilation package format version (e.g., `"0.1.0"`). |
| `artifact_ref` | String | Path reference to the compiled `.igapp` directory. Verified against path. |
| `artifact_digest` | String | Hash digest of the artifact (e.g. directory hash). Recomputed at execution time. |
| `spec_version` | String | Platform specification version targeted. |
| `semantics_profile` | String | The targeted core semantic execution profile. |
| `compiler_id` | String | Identifier for the compiler engine used. |
| `compiler_profile_id` | String | Profile ID of compilation rules enforced. |
| `compiled_at` | String | ISO 8601 compilation timestamp. |
| `source_ref` | String | Path to the source `.ig` file. |
| `source_digest` | String | SHA-256 hash of the original source. |
| `semantic_ir_ref` | String | Reference ID to the emitted SemanticIR JSON. |
| `semantic_ir_digest` | String | SHA-256 hash of the semantic_ir_program.json file. |
| `surface_dimension` | String | Execution dimension, must equal `"executable_runtime"`. |
| `runtime_target_kind` | String | Target substrate class, must equal `"delegated_experimental_runtime"`. |
| `runtime_implementation_id` | String | Target execution runtime ID (e.g., `"igniter.delegated.experimental.ivm.c_resident"`). |
| `backend_implementation_id` | String | Backend driver ID (e.g., `"deferred / not applicable for igapp_dir surface"`). |
| `consumer_surface_id` | String | Consumer binding ID (e.g., `"deferred / not applicable for igapp_dir surface"`). |
| `required_capabilities` | Array | Capabilities demanded by the program (e.g., `"core_pure_evaluation"`). |
| `feature_set` | Array | Language features utilized (e.g., `"integer_add"`, `"stdlib_integer_add"`). |
| `required_opcodes` | String/Array | Opcodes needed (or `"not_applicable"` if not AOT bytecode). |
| `execution_substrate` | String | Execution substrate descriptor. |
| `input_contract` | Object | Map of input names, types, scopes, and target contract metadata. |
| `output_contract` | Object | Map of output names, types, scopes, and target contract names. Cannot be deferred. |
| `failure_policy` | Object | Error policy parameters (e.g., `"fail_closed_on_invalid_input"`). |
| `evidence_class` | String | Nature of verification (e.g., `"proof-local evidence only"`). |
| `authority_status` | String | Authority classification. Must include `"non-canonical"` and `"evidence-only"`. |
| `non_claims` | Array | Explicit closed-scope denials required to prevent claim drift. |
| `producer_track` | String | Historical track label that produced the passport. |
| `authorized_by` | String | Architect authorization card ID. |
| `proof_card` | String | Intake/Proof implementation card ID. |
| `generated_at` | String | ISO 8601 passport creation timestamp. |
| `provenance_note` | Array | Summary notes explaining compilation provenance tracking. |

---

## 5. VM Candidate Capability Evidence

The alternative Rust VM candidate (`igniter.delegated.experimental.vm.rust-tokio.v0`) located in `playgrounds/igniter-lab/igniter-vm` has generated proof-local execution evidence under the following criteria:

* **Decimal Delegation Parity (VMG-4):** Integrates decimal math (`add`/`sub`/`mul`/`div`) with scale propagation matching standard library specifications. Includes fail-closed type checking for scale mismatches (error code `OOF-TC5`).
* **AST lowering (VMG-5):** AOT compiler successfully parses SemanticIR AST nodes and lowers them to a linear array of flat bytecode instructions.
* **Stack/Register Substrate (VMG-6):** Executes bytecode over a flat vector stack with a register-gated local hashmap.
* **Branch Selection (VMG-7):** Dynamically jumps instruction streams based on conditional expressions evaluation.
* **Branch Silence (VMG-8):** Non-selected branches remain completely silent, emitting zero observations to the output trace sink.
* **Fail-Closed on Unsupported Paths (VMG-9):** Encountering unsupported elements triggers `OP_UNSUPPORTED` and aborts execution with a fail-closed diagnostic.
* **Fail-Closed on Malformed Input (VMG-10):** Malformed bytecode arrays or unknown instruction opcodes halt execution immediately.
* **Temporal Live Read Observations (VMG-11):** `OP_LOAD_AS_OF` retrieves historical validity coordinates from `MemoryHistoryBackend` and logs observation IDs using a hash-based trace identifier format (`obs/live-read/[16-hex-chars]`).
* **Map-Reduce Aggregates (VMG-12):** Evaluates pipelines containing filters, maps, counts, folds, and ranges natively inside bytecode execution frames.
* **Network / Daemon Execution (VMG-13):** TCP listener daemons, projection pipelines, and reactive message receivers are kept classified and skipped during verification. No active TCP servers are started.

---

## 6. Loops and Recursion Pressure Evidence

### Active Lab Verification Evidence
Although VMG-13 was skipped in the R240 proof summary, the user added active verification tests to the Rust test suite in [vm_candidate_proof_tests.rs](file:///Users/alex/dev/projects/igniter/playgrounds/igniter-lab/igniter-vm/tests/vm_candidate_proof_tests.rs#L235-L345) to demonstrate loop capabilities. These tests verify the following three runtime primitives:

1. **Eager Loop Array Summation:** Demonstrates bytecode execution of `loop` nodes by summing elements of a native array (`[10, 20, 30]`) using body compute nodes to accumulate a final value of `60`.
2. **Fuel Bounds Exhaustion Failure (`OOF-L-FUEL`):** Proves fail-closed step limit tracking. Running a loop on an array of length 3 with `max_steps` set to 2 halts execution and returns a fuel-exhaustion error message (`OOF-L-FUEL`).
3. **Service Loop Clock Ticks (`tick.time`):** Verifies the parsing and mapping of clock ticks via service loop constructs, utilizing explicit temporal binding context inputs (`tick.time`).

### Lab Pressure Inputs
From [loops-and-recursion-pressure-package.md](file:///Users/alex/dev/projects/igniter/playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package.md) and its return analysis [loops-and-recursion-pressure-package-return.md](file:///Users/alex/dev/projects/igniter/playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package-return.md), the following constraints represent pressure targets for future compiler/runtime specification:
* **Postulate 28 (Loop Naming):** Mandates that all loop structures specify an explicit identifier so executions can be correlated with bitemporal transaction receipts.
* **Postulate 14 (Termination Proofs):** Mandates loop finiteness constraints. Either explicit step limits (`max_steps`) or termination proofs (e.g., `decreases fuel` markers in recursion) are required at the compiler level.
* **Temporal Isolation (Ban on `now()`):** Demands the absolute prohibition of global clock calls (`now()`) inside contracts to maintain deterministic execution. Clock ticks must be bound explicitly as input observations (`tick.time` or clock streams).

---

## 7. Support / Gap Matrix

This matrix maps capabilities against the current implementation state, highlighting gaps for naming, validation, and execution:

| Feature/Capability | Slice 0 Implementation | VM Candidate Evidence (Rust) | Slice 1 Design Stance | Gap / Hardening Required |
| --- | --- | --- | --- | --- |
| **CLI Command Vocabulary** | Exposes `igc run ARTIFACT.igapp` with mandatory options. | Scoped to unit tests / proof scripts. | Preserve Slice 0 CLI spine. | CLI must accept the new experimental selector. |
| **Runtime Selector** | Only accepts `delegated-experimental:ivm-proof`. | Metadata defines `igniter.delegated.experimental.vm.rust-tokio.v0`. | Introduce `delegated-experimental:igniter-vm-candidate`. | Binding selector to VM binary execution. |
| **Artifact Execution** | Evaluates `.igapp` AST JSON dynamically in Ruby. | Compiles and runs linear bytecode sequence. | Target `.igapp` only (No `.igbin`). | Map compiler lowering step into the CLI run pipeline. |
| **Passport Validation** | Validates directory digest, non-claims, and target ID. | Validates metadata format inside the proof runner. | Required, explicit, fail-closed validation. | Mismatch: Current Add.igapp passport targets `ivm.c_resident`. Need proof-local binding metadata. |
| **Compiler Passport Emission** | Closed. | Closed. | Remains Closed. | Passport metadata must be mocked or sideloaded as proof-local. |
| **OOF-TC5 / OOF-DM2 (Decimal Typings)** | N/A | Fully verified (scale parity and typecheck errors). | Include in execution verification. | Map VM type error codes to Slice 1 result packet diagnostics. |
| **Map-Reduce Aggregates** | N/A | Fully verified (range/filter/map/count pipelines). | Include in execution verification. | Verification of bytecode deserialization from `.igapp`. |
| **Temporal Live Reads** | N/A | Fully verified (loads via `MemoryHistoryBackend` and writes trace IDs). | Include in execution verification. | Binding host temporal backend to VM execution context. |
| **Local Loops / Fuel Checks** | N/A | Verified in candidate proof tests. | Excluded from Slice 1 scope. | Loop support is a pressure input only. Must fail-closed if found in Slice 1. |
| **Service Loops / Clock Ticks** | N/A | Verified in candidate proof tests. | Excluded from Slice 1 scope. | Must fail-closed if found. No TCP daemon or clock ticking servers. |
| **Closed Surfaces** | All mainline files preserved. | All mainline files preserved. | All mainline files preserved. | Verification that CLI integration does not expose unstable APIs. |

---

## 8. Closed-Surface Scan

A review of the workspace git state and documentation confirms that the mainline codebase remains completely isolated from experimental execution candidates. The following surfaces are preserved as strictly closed:

* **Platform Code:** [igniter-lang/lib/**](file:///Users/alex/dev/projects/igniter/igniter-lang/lib/) remains untouched. No bridge helpers, compile routines, or execution hooks are exposed in mainline.
* **CLI Wrapper:** [igniter-lang/bin/igc](file:///Users/alex/dev/projects/igniter/igniter-lang/bin/igc) has no changes that expose alternative backends or widen runtime selector mappings beyond Slice 0 limits.
* **Metadata & Spec:** [igniter_lang.gemspec](file:///Users/alex/dev/projects/igniter/igniter-lang/igniter_lang.gemspec) does not bundle alternate VM targets or define dependency hooks.
* **Public Documentation:** [README.md](file:///Users/alex/dev/projects/igniter/igniter-lang/README.md), [docs/README.md](file:///Users/alex/dev/projects/igniter/igniter-lang/docs/README.md), and [docs/ruby-api.md](file:///Users/alex/dev/projects/igniter/igniter-lang/docs/ruby-api.md) do not claim public runtime portability, alternative VM certification, or AOT compiler stability.
* **Diagnostics Registry:** `CompilerResult` and `CompilationReport` do not expose metadata placeholders for external execution states or VM instruction verification receipts.

---

## 9. C4-A Recommendation Inputs

This section outlines key technical inputs for the upcoming C4-A boundary decision:

### Design Status Readiness
The Slice 1 design boundary is technically ready as a specification for mapping the experimental `delegated-experimental:igniter-vm-candidate` selector. However, immediate implementation authorization should remain held.

### Passport and Target Mismatch Blocker
The mainline quickstart passport ([Add.igapp.passport.json](file:///Users/alex/dev/projects/igniter/igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json)) specifies:
* `runtime_implementation_id`: `igniter.delegated.experimental.ivm.c_resident`

The Rust VM candidate specifies:
* `runtime_implementation_id`: `igniter.delegated.experimental.vm.rust-tokio.v0`

If Slice 1 is implemented with strict passport validation, trying to execute `Add.igapp` against the Rust VM will fail validation due to the target implementation ID mismatch. 

> [!TIP]
> **Recommended Route:** Rather than opening compiler passport emission (which remains closed), a narrow VM capability/passport hardening proof should be routed next. This proof should produce a proof-local binding manifest matching `igniter.delegated.experimental.vm.rust-tokio.v0` and verifying correct fail-closed checks for mismatches.

### Runtime Specification Inputs
If the hardening proof reveals that capability mapping, observation traces, or branch silence criteria cannot be verified without normative rules, a redirect to a dedicated Runtime Specification input track (such as PROP-037+ updates) should be triggered before any `igc run` CLI integration is authorized.
