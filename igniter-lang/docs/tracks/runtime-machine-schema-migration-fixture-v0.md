# Track: Runtime Machine Schema Migration Fixture v0

Status: done
Slice state: done on 2026-05-06
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`
Role: Research / Proof Stabilization
Artifacts:
- `igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/fixtures/*.json`

---

## Frame

The previous slice restored `schema_check` as a standalone proof by moving the
runtime boundary to:

```text
loaded_unit + loaded_schema_descriptor
```

This slice adds the next PROP-017 proof point: a tiny schema migration fixture
that reaches `schema_check:migrating` and emits migration evidence without
claiming a production migration engine.

---

## Migration Fixture

The fixture creates:

```text
old SemanticImage
  schema_version: 0.0.0

new loaded schema descriptor
  schema_version: 0.1.0
  migration:
    from 0.0.0
    to   0.1.0
    strategy identity_schema_migration
```

The RuntimeMachine path is:

```text
boot
load ToyDispatchContract(schema_version: 0.1.0, migrations: [...])
  -> descriptor_observation: MigrationDescriptor
resume(old SemanticImage)
  -> CompatibilityReport schema_check outcome: migrating
emit_schema_migration_receipt(...)
  -> intent_observation
  -> receipt_observation lifecycle:audit
```

The receipt must carry:

- `caused_by` -> migration intent
- `produced_by` -> migration descriptor id/ref
- `replaces` -> old SemanticImage id

---

## Implementation

Smallest coherent changes:

- `ToyDispatchContract` can carry `migrations` inside `schema_descriptor`.
- `RuntimeMachine#load` emits `MigrationDescriptor` packets for loaded
  migrations and records `migration_descriptor_refs` in `loaded_unit`.
- `CompatibilityChecker#schema_check` now reports exact `migration_ref` and
  `migration_available` only when the visible migration matches the old/new
  versions.
- `RuntimeMachine#emit_schema_migration_receipt` emits a local migration
  intent and audit receipt.
- `packet_builder_check.rb` accepts `intent_observation`, validates
  `migrating_schema_drift`, and checks migration receipt links.

This is still a proof fixture. It does not execute a general migration DSL, does
not rewrite TBackend history, and does not produce a replacement SemanticImage.

---

## Proofs

```text
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb
  -> PASS

ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb --verify-fixtures
  -> PASS

ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
  -> PASS

ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb --profile-mode selected_profile --candidate /private/tmp/igniter_lang_schema_migration_selected_check
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
Track: igniter-lang/docs/tracks/runtime-machine-schema-migration-fixture-v0.md
Status: done

[D] Decisions:
- `schema_check:migrating` is now executable in the standalone memory proof.
- A migration must be visible in the loaded schema descriptor and match
  `(from_version, to_version)` before `migration_available` is true.
- Migration evidence is descriptor -> intent -> audit receipt.
- The receipt requires caused_by, produced_by, and replaces links.
- This fixture stops before a full migration engine or replacement
  SemanticImage.

[R] Recommendations:
- Keep migration execution as a future slice with explicit MigrationDecl
  semantics, audit receipts, and replacement SemanticImage production.
- Require candidate packet builders to preserve migration receipt links before
  accepting schema migration evidence.
- Keep `intent_observation` in the checker kind set; it is already part of the
  observation vocabulary and migration/FFI paths need it.

[S] Signals:
- PROP-017 now has all three resume-side outcomes in executable fixtures:
  trusted, provisional, and migrating.
- The selected_profile sidecar still passes after adding migration evidence.
- The next useful boundary is replacement SemanticImage, not more report-only
  metadata.

[Q] Open Questions:
- Should migration receipt use `produced_by` or `produced_in` for the migration
  descriptor relationship, or both?
- Should a migration produce a fresh SemanticImage immediately, or a
  MigrationReceipt that a later checkpoint consumes?
- How should multi-hop migrations choose paths: direct only, shortest path, or
  policy-selected?

[Next] Proposed next slice:
- runtime-machine-migration-replacement-image-v0:
  produce a replacement SemanticImage after a toy identity migration and prove
  the second CompatibilityReport returns trusted.
```
