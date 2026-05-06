# Track: Runtime Machine Schema Check Standalone Fix v0

Status: done
Slice state: done on 2026-05-06
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`
Role: Research / Proof Stabilization
Artifacts:
- `igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/fixtures/*.json`

---

## Frame

PROP-017 added `schema_version`, `schema_fingerprint`, and
`CompatibilityReport#schema_check`. The memory proof then gained a hidden load
order dependency:

```text
runtime_machine_memory_proof.rb
  -> CompatibilityChecker#schema_check
  -> @machine.loaded_program
```

`loaded_program` exists only when `compiled_program.rb` has reopened
`RuntimeMachine`. Running the memory proof directly failed with:

```text
NoMethodError: undefined method `loaded_program`
```

---

## Ownership Boundary

[D] RuntimeMachine should not require a `CompiledProgram` object to evaluate
schema compatibility. The primitive runtime boundary is:

```text
loaded_unit + loaded_schema_descriptor
```

`CompiledProgram` is one producer of a schema descriptor. The standalone toy
contract is another. `CompatibilityReport#schema_check` compares:

```text
SemanticImage.schema_fingerprint
  vs
RuntimeMachine.loaded_schema_descriptor.schema_fingerprint
```

This keeps PROP-017 intact while preserving the standalone proof boundary.

---

## Implementation

Smallest coherent fix:

- Added `ToyDispatchContract#schema_descriptor`, `#schema_version`, and
  `#schema_fingerprint`.
- Added `RuntimeMachine#loaded_schema_descriptor`.
- `RuntimeMachine#load` records schema version/fingerprint in `loaded_unit`.
- `RuntimeMachine#checkpoint` writes schema fields from `loaded_schema_descriptor`,
  not `@loaded_program`.
- `CompatibilityChecker#schema_check` reads `@machine.loaded_schema_descriptor`.
- `CompiledProgram#load_program` now assigns `@loaded_schema_descriptor` from
  `program.schema_descriptor`, while keeping `@loaded_program` only for
  compiled-program evaluation.

Regression checks added:

- `golden.semantic_image_schema_descriptor`
- `golden.schema_check_trusted`
- `negative.schema_drift_provisional`

The negative schema drift proves a fingerprint/version mismatch can produce
`provisional`, not accidentally collapse to `trusted`.

---

## Fixture Update

Golden fixtures were regenerated because SemanticImage now contains a real
schema fingerprint instead of `sha256:unknown`, and CompatibilityReport now
includes the provisional schema drift case.

Updated artifacts:

- `obs_packets.golden.json`
- `semantic_image.golden.json`
- `compatibility_reports.golden.json`
- `result_summary.golden.json`
- `manifest.json`

---

## Proofs

```text
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb
  -> PASS

ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb --verify-fixtures
  -> PASS

ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb --golden igniter-lang/experiments/runtime_machine_memory_proof/fixtures
  -> PASS

ruby -w -e 'require_relative "igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof"'
  -> no warnings

ruby -w -e 'require_relative "igniter-lang/experiments/runtime_machine_memory_proof/compiled_program"'
  -> no warnings
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/runtime-machine-schema-check-standalone-fix-v0.md
Status: done

[D] Decisions:
- RuntimeMachine owns loaded_schema_descriptor as the primitive schema boundary.
- RuntimeMachine does not need loaded_program for schema_check.
- CompiledProgram remains a producer of schema_descriptor, not the owner of
  compatibility semantics.
- SemanticImage should store a real schema_fingerprint for standalone toy
  contracts too.
- Resume status now preserves PROP-017 schema outcomes: provisional and
  migrating no longer collapse to trusted.

[R] Recommendations:
- Keep schema_check against loaded_schema_descriptor in future loaders.
- Add migrations only after a migration fixture can emit audit receipts and
  replaces links.
- Do not make RuntimeMachine expose loaded_program as a required public
  contract; keep it an integration detail for evaluate_program.

[S] Signals:
- The standalone proof now catches this exact regression through direct run.
- The golden path proves trusted schema match.
- The negative schema drift proves safe fingerprint mismatch returns
  provisional.
- Packet fixtures now carry the updated schema evidence.

[Q] Open Questions:
- Should loaded_schema_descriptor become a named LoadedUnitDescriptor record in
  the next formal proposal?
- Should contract drift compare artifact hash separately from schema drift, or
  should schema evolution eventually replace the current compiled_graph_hash
  contract check?
- How should migration_available select a concrete migration when several
  version paths are visible?

[Next] Proposed next slice:
- runtime-machine-schema-migration-fixture-v0:
  add a tiny migration descriptor/receipt fixture for schema_check:migrating
  without package integration.
```
