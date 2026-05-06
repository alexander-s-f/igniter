# Track: Runtime Machine Migration Replacement Image v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/runtime-machine-migration-replacement-image-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`
Artifacts:
- `igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/fixtures/*.json`

---

## Frame

The previous migration fixture proved:

```text
MigrationDescriptor
  -> schema_check:migrating CompatibilityReport
  -> intent_observation
  -> audit receipt_observation
```

It deliberately stopped before producing a replacement `SemanticImage`.
This slice adds the smallest toy identity migration path:

```text
old SemanticImage
  -> migration descriptor + intent + receipt
  -> replacement SemanticImage
  -> second CompatibilityReport: trusted
```

This is still a proof fixture. It is not a general migration DSL, not a
TBackend history rewrite, and not package integration.

---

## Replacement Image Shape

The replacement image copies the old image's runtime/contract/checkpoint/value
meaning and updates only the migration-specific semantic fields:

- `schema_version`
- `schema_fingerprint`
- `session_id`
- `produced_at`
- `execution_environment_ref`
- `contract_descriptor_ref`
- `observation_count`
- `observation_hash`
- `receipt_refs`
- `migration_receipt_ref`
- `replaces_image_id`
- `migration_chain`

The replacement image packet is emitted as a `platform_observation` with:

```text
links:
  caused_by -> migration receipt
  replaces  -> old SemanticImage image_id
```

The replacement image payload also carries:

```text
migration_receipt_ref -> migration receipt obs id
replaces_image_id     -> old SemanticImage image_id
```

This makes the continuity chain explicit in both packet links and image
content.

---

## Proof Path

The migration fixture now runs:

```text
boot
load ToyDispatchContract(schema_version: "0.1.0", migrations: [...])
resume(old image)
  -> schema_check:migrating
emit_schema_migration_receipt(...)
emit_replacement_semantic_image(...)
resume(replacement image)
  -> schema_check:trusted
```

The second report is trusted because it sees the replacement image:

```text
replacement SemanticImage.schema_fingerprint
  ==
RuntimeMachine.loaded_schema_descriptor.schema_fingerprint
```

The checker still derives report status from check outcomes. No compatibility
check was weakened.

---

## Checks Added

Runtime proof checks:

- `migration.replacement_image_links`
- `migration.replacement_image_schema`
- `migration.replacement_report_trusted`

Packet checker checks:

- selected packet set includes replacement SemanticImage packet
- selected packet set includes trusted replacement CompatibilityReport packet
- replacement image packet links `caused_by` the migration receipt
- replacement image packet links `replaces` the old image
- replacement image payload carries `migration_receipt_ref`
- replacement image payload carries `replaces_image_id`
- replacement report sees the replacement image id
- replacement report `schema` check is trusted/compatible/fingerprint-matched

Fixture additions:

- `semantic_image.golden.json`
  - `replacement_semantic_image`
  - `replacement_semantic_image_packet`
- `compatibility_reports.golden.json`
  - `trusted_after_migration_replacement`
- `obs_packets.golden.json`
  - `replacement_semantic_image_packet`
  - `replacement_trusted_compatibility_report_packet`
- `result_summary.golden.json`
  - migration replacement proof checks

---

## Proof Output

```text
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb
  -> PASS

ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb --verify-fixtures
  -> PASS

ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
  -> PASS
```

Important report pair:

```text
migrating_schema_drift:
  schema.decision: migrating
  image_id: old image

trusted_after_migration_replacement:
  schema.decision: trusted
  fingerprint_match: true
  image_id: replacement image
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/runtime-machine-migration-replacement-image-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Replacement SemanticImage is produced by a proof-local identity migration path.
- Replacement image continuity is explicit in packet links and payload fields.
- The second CompatibilityReport is trusted only when it evaluates the
  replacement image whose schema_fingerprint matches the loaded schema
  descriptor.
- No compatibility checks were weakened.
- No general migration DSL or TBackend history rewrite was introduced.

[R] Recommendations:
- Ask Compiler/Grammar Expert to formalize replacement-image payload fields and
  link rels before expanding beyond identity migration.
- Keep package/Bridge work blocked until normalized equivalence and migration
  image fields are settled.
- Consider whether replacement images should always be emitted immediately
  after a migration receipt or only at the next checkpoint.

[S] Signals:
- PROP-017 now has executable fixtures for migrating report, audit receipt,
  replacement image, and trusted post-migration report.
- The next risk is not schema_check itself; it is the formal semantics of
  replacement image continuity and multi-hop migration paths.

[T] Tests / Proofs:
- runtime_machine_memory_proof.rb -> PASS.
- runtime_machine_memory_proof.rb --verify-fixtures -> PASS.
- packet_builder_check.rb -> PASS.

[Files] Changed:
- igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb
- igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
- igniter-lang/experiments/runtime_machine_memory_proof/fixtures/manifest.json
- igniter-lang/experiments/runtime_machine_memory_proof/fixtures/obs_packets.golden.json
- igniter-lang/experiments/runtime_machine_memory_proof/fixtures/semantic_image.golden.json
- igniter-lang/experiments/runtime_machine_memory_proof/fixtures/compatibility_reports.golden.json
- igniter-lang/experiments/runtime_machine_memory_proof/fixtures/result_summary.golden.json
- igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_fixture/raw_candidate.json
- igniter-lang/experiments/runtime_machine_memory_proof/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/current-status.md
- igniter-lang/docs/tracks/runtime-machine-migration-replacement-image-v0.md

[Q] Open Questions:
- Should replacement images be emitted as audit observations, checkpoint
  observations, or a distinct migration lifecycle?
- Should the image use `replaces`, `supersedes`, or both for the old image link?
- Should multi-hop migrations produce one replacement image per hop or one final
  replacement image with a chain?

[X] Rejected:
- Treating `schema_check:migrating` as trusted without producing a replacement
  image.
- Changing CompatibilityReport severity rules to force trust.
- Implementing a general MigrationDecl executor in this proof slice.

[Next] Proposed next slice:
- migration-replacement-image-formalization-v0:
  formalize replacement image fields, link rels, lifecycle, and multi-hop
  semantics before bridge/package integration.
```
