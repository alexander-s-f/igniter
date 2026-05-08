# Track: Migration Replacement Image Checker v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/migration-replacement-image-checker-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`
Artifacts:
- `igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/fixtures/*.json`

---

## Frame

This slice aligns the RuntimeMachine migration proof and packet checker with
`migration-replacement-image-formalization-v0`.

The proof remains single-hop only:

```text
old SemanticImage
  -> schema_check:migrating
  -> migration intent
  -> audit migration receipt
  -> replacement SemanticImage
  -> trusted CompatibilityReport
```

---

## What Changed

Replacement image payload now includes:

- `migration_receipt_ref`
- `replaces_image_id`
- `migration_chain: []`

Replacement image packet links now include:

- `replaces -> old image`
- `caused_by -> migration receipt`
- `produced_by -> migration descriptor observation`
- `produced_in -> execution environment`

Replacement image packet links now explicitly exclude:

- `supersedes`

The replacement `SemanticImage` packet lifecycle is `session`; the migration
receipt remains `audit`.

---

## P-1 Through P-10

The proof output now exposes every formal target:

- P-1: `migration_receipt_ref` present and correct.
- P-2: `replaces_image_id` points to the old image.
- P-3: packet has `replaces -> old image`.
- P-4: packet has `caused_by -> migration receipt`.
- P-5: packet has no `supersedes`.
- P-6: replacement fingerprint matches the loaded schema descriptor.
- P-7: second `CompatibilityReport.schema_check.decision == trusted`.
- P-8: second `CompatibilityReport.overall/resume_status == trusted`.
- P-9: single-hop `migration_chain == []`.
- P-10: forged wrong-fingerprint replacement image is blocked as `OOF-MR3`.

---

## OOF-MR3 Negative

The proof creates a forged replacement image by changing only the replacement
image `schema_fingerprint` and recomputing image identity. Resume against that
image now yields:

```text
CompatibilityReport.schema_check.decision == blocked
CompatibilityReport.schema_check.oof_code == OOF-MR3
CompatibilityReport.resume_status == blocked
```

The golden compatibility report key is:

```text
blocked_migration_replacement_wrong_fingerprint
```

---

## Verification

```text
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb --verify-fixtures
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
```

All pass.

Fixture spot checks:

```text
migration_chain=[]
lifecycle=session
links=observed_under,observed_under,observed_under,produced_in,caused_by,produced_by,replaces
has_supersedes=false
oof=OOF-MR3
schema_decision=blocked
resume_status=blocked
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/migration-replacement-image-checker-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- RuntimeMachine replacement image proof now matches the formal single-hop
  replacement image spec.
- migration_chain is [] for the current single-hop fixture.
- Replacement image packets use replaces, caused_by, produced_by, produced_in.
- Replacement image packets must not use supersedes.
- OOF-MR3 is enforced by CompatibilityChecker for forged replacement images
  whose schema_fingerprint does not match the loaded schema descriptor.

[R] Recommendations:
- Next slice can test RuntimeMachine.load or package bridge behavior against
  this stabilized replacement image fixture.
- Keep multi-hop migration deferred until this single-hop contract is reviewed.

[S] Signals:
- The checker now validates packet link rels, not only payload fields.
- The OOF-MR3 negative is visible in both proof output and golden reports.

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
- igniter-lang/docs/tracks/migration-replacement-image-checker-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Should migration receipt preservation be checked by a future TBackend
  compaction proof?
- Should multi-hop continuity checks live in this checker or a separate
  migration DAG checker?

[X] Rejected:
- Reintroducing supersedes on replacement image packets.
- Multi-hop migration in this slice.
- Treating OOF-MR3 as provisional.

[Next] Proposed next slice:
- schema-migration-bridge-profile-v0:
  carry the stabilized replacement image payload/link spec into the bridge
  profile, while keeping multi-hop proof separate.
```
