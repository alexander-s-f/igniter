# Igniter-Lang Next Slices

Status: active planning note
Date: 2026-05-06
Supervisor: `[Architect Supervisor / Codex]`

## Current Fixed Point

Recent closed slices:

- `polymorphic-add-igapp-fixture-v0`
- `migration-replacement-image-checker-v0`
- `spark-tenant-and-pipeline-formalization-v0`
- `spark-technician-availability-fixture-pressure-v0`
- `schema-compatibility-diagnostics-igniter-contracts-plan-v0`

Verification currently green:

```text
polymorphic_add_classifier_proof.rb
polymorphic_add_semanticir_emission_proof.rb
runtime_machine_memory_proof.rb
runtime_machine_memory_proof.rb --verify-fixtures
packet_builder_check.rb
parser add / availability_projection / polymorphic_add
```

## Recommended Order

### 1. Research Agent

`polymorphic-add-runtime-load-boundary-v0`

Prove whether `fixtures/polymorphic_add.igapp/` can be loaded as-is by the
current RuntimeMachine loader. If not, document the minimal loader
normalization needed for bracketed contract ids, specialization manifest, and
generic metadata.

### 2. Research Agent

`spark-technician-availability-fixture-v0`

Turn the Applied Pressure fixture spec into an executable synthetic fixture:
TenantScope, ScopedFactRead, PipelineStep/StepObservation, AvailabilitySnapshot,
why-not reasons, and negative tenant/time/status cases.

### 3. Compiler/Grammar Expert

`spark-pipeline-grammar-v0`

Define source syntax for pipeline declarations and `scoped_by` reads. Keep
pipeline semantics as `Result.flat_map + StepObservation`; no new runtime
composition operator.

### 4. Bridge Agent

`schema-migration-bridge-profile-v0`

Carry the stabilized replacement image payload/link spec into a bridge profile:
`migration_chain`, no `supersedes`, `replaces`, `caused_by`, `produced_by`,
`produced_in`, and `OOF-MR3` wrong-fingerprint blocking.

### 5. Package Agent

Hold for now unless we explicitly approve package work.

Candidate package slice:

`igniter-contracts-schema-compatibility-diagnostic-v0`

Implement the already-planned metadata-only `SchemaCompatibilityDiagnostic` in
`packages/igniter-contracts`. This is package work, so it should be assigned
only after the Architect explicitly switches Package Agent from durable-model
to `igniter-contracts`.

## Package Agent Decision

[D] Keep Package Agent waiting for the moment.

Reason:

- Last durable-model track is done and stable.
- Igniter-Lang is producing fast-moving bridge semantics.
- The next package task should be large and clear, not a small cleanup.
- Best next package task is likely `SchemaCompatibilityDiagnostic v0` in
  `packages/igniter-contracts`, but it should start after this planning point
  is accepted.

