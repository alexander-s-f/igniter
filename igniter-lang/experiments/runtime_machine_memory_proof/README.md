# Runtime Machine Memory Proof

Status: done
Slice state: done on 2026-05-05
Slice name: `runtime-machine-proof-packet-builder-check-v0`
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Purpose

This experiment implements the minimal standalone executable proof from:

- `igniter-lang/docs/tracks/runtime-machine-executable-proof-plan-v0.md`

It proves the Runtime Machine lifecycle with an in-process `:memory`
TBackend:

```text
boot -> load -> evaluate -> checkpoint -> resume -> re-evaluate
```

This is not a package integration.

## Boundary

Allowed:

- stdlib-only Ruby
- standalone ObsPacket mini-model
- standalone MemoryTBackend
- standalone RuntimeMachine
- toy CORE dispatch contract
- negative fixtures for blocked/downgraded/provisional outcomes

Not allowed:

- package edits
- Ledger dependency
- production API claims
- parser or `.il` syntax
- durable restart claim from process memory

## Run

From the repository root:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb
```

Expected summary:

```text
PASS runtime_machine_memory_proof
golden.boot: ok
golden.load: ok
golden.evaluate: ok
golden.checkpoint: ok
golden.resume: ok
golden.same_result_hash: ok
golden.evidence_links: ok
negative.ambient_time_blocked: ok
negative.empty_backend_resume_blocked: ok
negative.runtime_drift_downgraded: ok
negative.contract_drift_blocked: ok
negative.same_value_without_evidence: ok
negative.evidence_missing_provisional: ok
```

## Golden Fixtures

Generate structural golden artifacts:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb --write-fixtures
```

Verify current harness behavior against the committed fixture artifacts:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb --verify-fixtures
```

Expected fixture verification:

```text
PASS runtime_machine_memory_proof_fixtures
```

Fixture files:

- `fixtures/manifest.json`
- `fixtures/obs_packets.golden.json`
- `fixtures/semantic_image.golden.json`
- `fixtures/compatibility_reports.golden.json`
- `fixtures/negative_evidence.golden.json`
- `fixtures/result_summary.golden.json`

## Packet Builder Check

Validate fixture structure:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
```

Validate a generated candidate fixture directory against the golden fixtures:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb --candidate <dir>
```

Expected checker summary:

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

The checker validates:

- manifest raw SHA-256 hashes
- artifact schema and payload wrappers
- ObsPacket ids, payload hashes, kinds, and link shape
- resumed value packet evidence links
- SemanticImage content hash and image id
- CompatibilityReport status decisions
- negative evidence for ambient time and missing proof links
- result summary equality and trusted evidence status

## What It Proves

[D] A minimal Runtime Machine can make lifecycle continuity executable without
Ledger or package runtime integration.

[D] `:memory` TBackend can prove ordering, replay, snapshots, SemanticImage,
CompatibilityReport, and trusted resume inside one proof harness.

[D] `:memory` TBackend cannot claim durable restart after process memory loss.
The empty-backend resume fixture must remain blocked.

[D] Equal result hashes are not enough. The proof requires observation links
and compatibility evidence.

[D] Golden fixtures let the next layer validate packet structure, SemanticImage
content, and CompatibilityReport decisions without scraping PASS text.

[D] The packet builder check is now a machine-readable gate for future
sidecar-builder candidates.

## Files

- `runtime_machine_memory_proof.rb` - executable harness.
- `packet_builder_check.rb` - structural checker for golden or candidate
  fixture directories.
- `fixtures/*.golden.json` - structural golden artifacts generated from the
  harness.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: runtime-machine-proof-packet-builder-check-v0
Artifact: igniter-lang/experiments/runtime_machine_memory_proof/
Status: done

[D] Decisions:
- The first executable Runtime Machine proof is standalone and stdlib-only.
- The golden path proves boot/load/evaluate/checkpoint/resume/re-evaluate on a
  toy CORE dispatch contract.
- The proof distinguishes trusted in-harness resume from blocked process-memory
  loss.
- The proof treats missing evidence links as provisional even when value hashes
  match.
- The proof now exports golden ObsPacket, SemanticImage, CompatibilityReport,
  negative evidence, and result summary artifacts.
- `packet_builder_check.rb` validates structural fixture contracts and optional
  candidate fixture directories.

[R] Recommendations:
- Use this experiment as the next golden fixture source for sidecar packet
  builders.
- Keep package integration blocked until packet shape and write location are
  approved separately.
- Add file-backed TBackend only after memory lifecycle checks remain stable.
- Make the next checker consume `--verify-fixtures` or parse the JSON fixtures,
  not the human PASS summary.
- Make future sidecar builders emit the same artifact set first, then let this
  checker reject drift before any package integration.

[S] Signals:
- Runtime Machine semantics are now executable at toy scale.
- The negative fixtures make false reproducibility visible.
- Structural fixtures are now stable enough to drive packet-builder tests.
- Fixture validation now has categories granular enough to tell whether drift
  came from packet identity, SemanticImage, CompatibilityReport, or summary
  behavior.

[Q] Open Questions:
- Should this harness later move under an approved experiment runner?
- Should CompatibilityReport become a shared bridge fixture before any package
  implementation work?
- Should future fixtures split full packet logs from selected packet profiles?
- Should the checker eventually produce JSON diagnostics in addition to the
  compact PASS/FAIL text?

[Next] Proposed next slice:
- `runtime-machine-proof-sidecar-builder-profiles-v0`
  Build standalone sidecar builder profiles that emit candidate artifacts for
  this checker.
```
