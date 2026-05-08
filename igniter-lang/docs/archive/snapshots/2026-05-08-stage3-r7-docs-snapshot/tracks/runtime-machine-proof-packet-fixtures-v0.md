# Track: Runtime Machine Proof Packet Fixtures v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`
Artifact: `igniter-lang/experiments/runtime_machine_memory_proof/fixtures/`

## Frame

This slice turns the executable memory proof into structural golden artifacts.

Before this slice, the proof could be checked by text:

```text
PASS runtime_machine_memory_proof
```

After this slice, the proof can be checked by deterministic JSON artifacts:

```text
ObsPacket log
SemanticImage
CompatibilityReport set
negative evidence
result summary
manifest hashes
```

This remains a standalone experiment:

- no package edits
- no Ledger dependency
- no production API claim
- no bridge packet implementation yet

## Source Horizon

- `igniter-lang/docs/tracks/runtime-machine-executable-proof-plan-v0.md`
- `igniter-lang/experiments/runtime_machine_memory_proof/README.md`
- `igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb`

## Compact Claim

[D] The next layer should not scrape PASS text. It should compare structural
artifacts.

```text
runtime_machine_memory_proof.rb
  -> --write-fixtures
  -> fixtures/*.golden.json
  -> --verify-fixtures
  -> structural pass/fail
```

[D] The fixture boundary is:

```text
current harness behavior
  -> canonical JSON fixture
  -> manifest content hash
  -> future checker / packet builder expectation
```

If a future packet builder changes one field, link, hash, or compatibility
decision, fixture verification should fail with a file-level mismatch.

## Fixture Files

The harness now writes these files:

```text
igniter-lang/experiments/runtime_machine_memory_proof/fixtures/
  manifest.json
  obs_packets.golden.json
  semantic_image.golden.json
  compatibility_reports.golden.json
  negative_evidence.golden.json
  result_summary.golden.json
```

### manifest.json

Purpose: declare the fixture schema and content hashes for every golden file.

Use:

- detect accidental fixture drift
- allow later checkers to verify fixture identity before using payloads
- avoid relying on mtimes or ad hoc file lists

### obs_packets.golden.json

Purpose: preserve the expected ObsPacket structure from the golden run.

It includes:

- Session A packet log
- Session B packet log after trusted resume
- selected packets for:
  - DispatchCandidate value
  - resumed DispatchCandidate value
  - SemanticImage packet
  - trusted CompatibilityReport packet

[D] Full packet logs are useful now because the shape is still small. A later
slice may split full logs from minimal selected packet profiles.

### semantic_image.golden.json

Purpose: preserve the checkpointed SemanticImage and its packet wrapper.

It includes:

- semantic image payload
- semantic image ObsPacket
- checkpoint receipt

This fixture proves that image identity is content-addressed and carries:

- axiom descriptor ref
- runtime contract ref
- backend descriptor ref and backend descriptor hash
- compiled graph hash
- observation hash
- value hash
- checkpoint ref
- replay cursor
- temporal horizon

### compatibility_reports.golden.json

Purpose: preserve expected resume decisions.

It includes:

| Case | Expected |
|------|----------|
| trusted resume | `trusted` |
| empty backend resume | `blocked` |
| runtime drift | `downgraded` |
| contract drift | `blocked` |

[D] Runtime drift is a downgrade, not a backend block. Backend compatibility is
checked by capability/content hash, not by runtime-linked packet identity.

### negative_evidence.golden.json

Purpose: preserve false-reproducibility examples.

It includes:

- ambient-time blocked failure packet
- same value without evidence links
- provisional evidence status for missing `executed_by`, `read_from`,
  `observed_under`, and `produced_in` links

### result_summary.golden.json

Purpose: preserve the human proof summary as structured data.

It includes:

- check names and pass/fail state
- result hash
- resumed result hash
- same-result assertion
- evidence status

## Harness Commands

Generate fixtures:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb --write-fixtures
```

Verify fixtures:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb --verify-fixtures
```

Expected verification:

```text
PASS runtime_machine_memory_proof_fixtures
```

## Fixture Contract

A fixture artifact is valid when:

1. It is generated from the harness, not hand-written.
2. It is canonical JSON with stable key order.
3. It is listed in `manifest.json`.
4. Its content hash matches the manifest.
5. `--verify-fixtures` passes after a fresh harness run.
6. The normal proof still passes.

## Design Notes

[D] The fixture schema name is:

```text
runtime-machine-proof-packet-fixtures-v0
```

[D] Golden artifacts are intentionally local to the experiment. They are not
yet package test fixtures.

[D] The harness now exposes two machine-readable modes:

- `--write-fixtures`
- `--verify-fixtures`

[D] `--verify-fixtures` compares file contents, not only normalized object
equality. This catches accidental formatting and manifest drift too.

## Risks

- Full packet logs may become noisy if the toy proof grows.
- File-level mismatches are simple and strict; later tooling may need
  field-level diagnostics.
- Golden files can create false confidence if generated after a behavioral
  regression without review.
- Fixture identity still depends on the harness mini ObsPacket model, not the
  eventual bridge packet builder.

## Rejected Paths

[X] Parse the human PASS text as a structural contract.

[X] Store fixtures outside the experiment before package integration is
approved.

[X] Treat fixture JSON as production wire format.

[X] Generate fixtures with ambient wall-clock timestamps.

[X] Allow runtime drift to masquerade as TBackend incompatibility.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/runtime-machine-proof-packet-fixtures-v0.md
Artifact: igniter-lang/experiments/runtime_machine_memory_proof/fixtures/
Status: done

[D] Decisions:
- Runtime Machine memory proof now exports structural golden artifacts.
- The fixture schema is `runtime-machine-proof-packet-fixtures-v0`.
- Golden artifacts include ObsPacket logs, SemanticImage, CompatibilityReport
  decisions, negative evidence, result summary, and manifest hashes.
- `--verify-fixtures` is the machine-readable proof check for the next layer.
- Runtime drift remains downgraded while empty backend and contract drift are
  blocked.

[R] Recommendations:
- Use `--verify-fixtures` as the first gate for future packet-builder work.
- Keep fixtures local to the experiment until bridge packet shape is approved.
- In the next slice, build a checker that compares sidecar packet builder
  output against these golden artifacts.

[S] Signals:
- The proof can now be consumed by tools, not only humans.
- CompatibilityReport and SemanticImage are now concrete enough to become
  fixture-driven contracts.
- The backend descriptor hash vs runtime-linked packet identity distinction is
  important and should be preserved.

[Q] Open Questions:
- Should future golden files include minimal selected packets only, or keep full
  session logs?
- Should field-level mismatch reporting live in this harness or in a separate
  checker?
- Should fixture manifests later include semantic version compatibility ranges?

[Next] Proposed next slice:
- `runtime-machine-proof-packet-builder-check-v0`
  Validate future sidecar packet-builder output against these structural golden
  artifacts.
```
