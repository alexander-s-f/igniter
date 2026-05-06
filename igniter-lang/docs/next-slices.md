# Igniter-Lang Next Slices

Status: active planning note
Date: 2026-05-06
Supervisor: `[Architect Supervisor / Codex]`

## Current Fixed Point

Recent closed slices:

- `polymorphic-add-runtime-load-boundary-v0`
- `spark-technician-availability-fixture-v0`
- `spark-pipeline-grammar-v0`
- `schema-migration-bridge-profile-v0`
- `spark-lead-signal-boundary-pressure-v0`

Verification currently green:

```text
polymorphic_add_classifier_proof.rb
polymorphic_add_semanticir_emission_proof.rb
runtime_machine_memory_proof.rb
runtime_machine_memory_proof.rb --verify-fixtures
packet_builder_check.rb
spark_technician_availability_fixture.rb
parser add / availability_projection / polymorphic_add
```

Known useful blocker:

```text
polymorphic_add_runtime_load_boundary_proof.rb
  -> CompiledProgram.load_igapp ok
  -> RuntimeMachine.load_program blocked by descriptor-ref shape drift
  -> direct evaluation blocked by missing stdlib.numeric.add operator
```

## Recommended Order

### 1. Research Agent

`polymorphic-add-runtime-loader-normalization-v0`

Patch/prove the current loader boundary discovered by the blocked proof:
descriptor-ref normalization, specialization manifest validation, metadata-only
generic rejection, and `stdlib.numeric.add` runtime operator support.

### 2. Research Agent

`spark-lead-signal-boundary-fixture-v0`

Implement the second Spark operational fixture: normalized lead signals,
deterministic idempotency, hourly rollup, exact Decimal totals, duplicate
suppression, retention receipts, and late closed-boundary diagnostics.

### 3. Compiler/Grammar Expert

`spark-pipeline-parser-acceptance-v0`

Add parser acceptance for the already-specified pipeline surface:
`pipeline`, `step`, `scoped_by`, `cardinality`, and `tenant_free`. Keep
classifier/typechecking proof separate unless it is tiny.

### 4. Bridge Agent

`spark-availability-diagnostics-bridge-profile-v0`

Map the executable availability fixture to metadata-only diagnostics: tenant
scope source, scoped reads, cardinality bounds, slot reason counts, source refs,
failed step, failure kind, and redaction policy.

### 5. Package Agent

`igniter-contracts-schema-compatibility-diagnostic-v0`

Implement the already-planned metadata-only `SchemaCompatibilityDiagnostic` in
`packages/igniter-contracts` with optional single-hop `migration_profile`
support. This is now ready to assign if the Architect wants Package Agent
active.

## Package Agent Decision

[D] Package Agent can move now, but only on the large bounded
`igniter-contracts-schema-compatibility-diagnostic-v0` slice.

Reason:

- Bridge has stabilized the report-only migration profile enough for package
  implementation.
- The slice is large enough to be worth Package Agent's context cost.
- Scope remains safe: diagnostic value object and report serialization only.
- No migration executor, multi-hop migration, path selection, TBackend rewrite,
  Ledger integration, or app/runtime enforcement.
