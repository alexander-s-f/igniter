# Track: Runtime Machine Proof Packet Builder Check v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`
Artifact: `igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb`

## Frame

This slice adds a structural checker for the Runtime Machine memory proof
fixtures.

The previous slice produced golden artifacts:

```text
fixtures/*.golden.json
```

This slice adds a checker:

```text
packet_builder_check.rb
  -> manifest check
  -> packet identity check
  -> SemanticImage check
  -> CompatibilityReport check
  -> negative evidence check
  -> result summary check
```

It remains standalone:

- no package edits
- no Ledger dependency
- no bridge runtime dependency
- no production API claim

## Source Horizon

- `igniter-lang/docs/tracks/runtime-machine-proof-packet-fixtures-v0.md`
- `igniter-lang/experiments/runtime_machine_memory_proof/README.md`
- `igniter-lang/experiments/runtime_machine_memory_proof/fixtures/`

## Compact Claim

[D] Golden artifacts need a checker that understands structure, not only file
equality.

```text
candidate artifact dir
  + golden artifact dir
  -> packet_builder_check
  -> PASS | FAIL + category diagnostics
```

[D] The checker is the first gate for future sidecar packet-builder candidates.
Those candidates should emit the same artifact set first; only then should they
be considered for package integration.

## Checker Commands

Check the committed golden fixtures:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
```

Check a generated candidate directory against the golden fixtures:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb --candidate <dir>
```

Check with explicit golden directory:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb \
  --golden igniter-lang/experiments/runtime_machine_memory_proof/fixtures \
  --candidate <dir>
```

Expected output:

```text
PASS runtime_machine_proof_packet_builder_check
manifest: ok
artifact_headers: ok
obs_packets: ok
semantic_image: ok
compatibility_reports: ok
negative_evidence: ok
result_summary: ok
```

When a candidate directory differs from the golden directory, the checker also
performs `golden_comparison`.

## Validation Rules

### Manifest

The checker verifies:

- schema version is `runtime-machine-proof-packet-fixtures-v0`
- manifest artifact kind is `manifest`
- each expected golden file is listed
- each listed content hash equals raw SHA-256 of the file bytes

### Artifact Headers

Each artifact must carry:

```text
schema_version
artifact
payload
```

Artifact names must match:

- `obs_packets`
- `semantic_image`
- `compatibility_reports`
- `negative_evidence`
- `result_summary`

### ObsPacket

Every packet in session logs and selected fixtures must satisfy:

- known kind
- required fields: `id`, `kind`, `subject`, `payload`, `payload_hash`,
  `temporal`, `links`
- `payload_hash == hash(payload)`
- `id == hash(kind, subject, payload_hash, temporal, links)`
- links have `rel`, `ref`, and boolean `required`
- repeated packet ids have identical packet content

The resumed DispatchCandidate value packet must include:

- `executed_by`
- at least four `read_from` links
- at least three `observed_under` links
- `produced_in`

### SemanticImage

The checker verifies:

- `content_hash` is computed from the image without `image_id` and
  `content_hash`
- `image_id` is derived from `content_hash`
- SemanticImage packet payload equals the SemanticImage payload
- checkpoint receipt references the SemanticImage packet
- checkpoint `seq_id` matches replay cursor position

### CompatibilityReport

The checker verifies expected status decisions:

| Report | Expected |
|--------|----------|
| trusted resume | `trusted` |
| empty backend resume | `blocked` |
| runtime drift | `downgraded` |
| contract drift | `blocked` |

It also verifies `report_id` from checks and derives resume status from check
outcomes.

[D] Runtime drift must downgrade the runtime dimension while backend remains
compatible. Backend compatibility is checked by backend capability/content
hash, not by runtime-linked packet identity.

### Negative Evidence

The checker verifies:

- missing `as_of` emits `temporal.as_of_missing`
- same value without evidence keeps the same payload hash
- same value without evidence is `provisional`
- missing proof list is exactly:

```text
executed_by
read_from
observed_under
produced_in
```

### Result Summary

The checker verifies:

- proof pass is true
- all named checks are ok
- result and resumed result hashes match
- evidence status is trusted

## Design Notes

[D] The checker deliberately stays in the experiment directory. It is a research
gate, not a package test runner.

[D] The checker reuses the memory proof canonical hash policy to avoid a second
identity model.

[D] The checker prints compact category diagnostics. Field-level failures are
printed only when something breaks.

## Risks

- Exact candidate comparison may be too strict for later builder profiles that
  intentionally omit full packet logs.
- The checker currently emits text diagnostics only, not JSON diagnostics.
- The checker validates the toy packet model, not final bridge ObsPacket API.
- Future fixture sets may need profile-specific comparison modes.

## Rejected Paths

[X] Treat `--verify-fixtures` file equality as enough for packet-builder work.

[X] Allow candidate packet builders to pass with equal value hashes but missing
links.

[X] Move checker into packages before bridge integration is approved.

[X] Treat fixture JSON as final production wire format.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/runtime-machine-proof-packet-builder-check-v0.md
Artifact: igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
Status: done

[D] Decisions:
- Added standalone packet-builder structural checker.
- Checker validates manifest hashes, artifact headers, ObsPacket identity,
  SemanticImage content, CompatibilityReport decisions, negative evidence, and
  result summary.
- Candidate directories can be checked against golden fixtures with
  `--candidate`.
- Runtime drift remains a downgrade while backend compatibility stays tied to
  backend capability/content hash.

[R] Recommendations:
- Make future sidecar builders emit this fixture artifact set before touching
  packages.
- Use this checker as the first gate for candidate sidecar packet output.
- Add JSON diagnostics only when a real candidate needs them.

[S] Signals:
- Runtime Machine proof has moved from text PASS to structural validation.
- The checker gives enough category detail to localize packet identity,
  SemanticImage, CompatibilityReport, or negative-evidence drift.

[Q] Open Questions:
- Should candidate builders be allowed to emit selected packet profiles only?
- Should checker comparison support ignore-lists or profile modes?
- Should diagnostics be emitted as JSON for future CI-like use?

[Next] Proposed next slice:
- `runtime-machine-proof-sidecar-builder-profiles-v0`
  Build standalone sidecar builder profiles that emit candidate artifacts for
  this checker.
```
