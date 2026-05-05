# Runtime Machine Memory Proof

Status: done
Slice state: done on 2026-05-05
Slice name: `runtime-machine-ffi-ruby-receipt-fixtures-v0`
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

Validate a selected-profile candidate:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb --profile-mode selected_profile --candidate <dir>
```

Expected checker summary:

```text
PASS runtime_machine_proof_packet_builder_check
profile_mode: ok
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

Profile modes:

- `full_log` - requires Session A and Session B packet logs and performs exact
  golden payload comparison.
- `selected_profile` - allows `obs_packets` without full session logs, requires
  `profile_mode`, selected packets, and compares the selected packet surface
  plus result hash.

## Sidecar Builder Profiles

Build candidate artifacts from standalone sidecar profiles and check them
against the golden fixtures:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb
```

Write a candidate directory and check it:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb --candidate /tmp/runtime_machine_sidecar_candidate
```

Write a candidate directory without running the checker:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb --write-candidate <dir>
```

Build a selected-profile candidate:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb --profile-mode selected_profile --candidate /tmp/runtime_machine_sidecar_selected
```

Expected summary:

```text
PASS runtime_machine_proof_sidecar_builder_profiles
candidate_dir: <dir>
profile_mode: <full_log | selected_profile>
proof_capture: ok
write_candidate: ok
packet_builder_check: ok
```

Profile builders:

- `ObsPacketsProfile`
- `SemanticImageProfile`
- `CompatibilityReportsProfile`
- `NegativeEvidenceProfile`
- `ResultSummaryProfile`

## External Candidate Normalizer

Normalize a tiny raw external candidate fixture into a selected-profile
candidate directory and check it:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb
```

Write to a specific candidate directory and check it:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb --candidate /tmp/runtime_machine_external_candidate_normalized
```

Expected summary:

```text
PASS runtime_machine_external_candidate_normalizer
raw_candidate: <path>
candidate_dir: <dir>
profile_mode: selected_profile
normalize.raw.schema_version: ok
normalize.raw.profile_mode: ok
normalize.raw.source.full_session_logs: ok
normalize.assert.result_hash: ok
normalize.assert.semantic_image_content_hash: ok
normalize.assert.trusted_resume_status: ok
normalize.assert.negative_evidence_policy: ok
normalize.assert.required_links.read_from: ok
normalize.assert.required_links.executed_by: ok
normalize.assert.required_links.produced_in: ok
normalize.assert.required_links.observed_under: ok
normalize.raw.normalization.semantic_substitutions: ok
write_candidate: ok
packet_builder_check: ok
```

The normalizer writes trusted admission artifacts:

- `manifest.json`
- `obs_packets.golden.json`
- `semantic_image.golden.json`
- `compatibility_reports.golden.json`
- `negative_evidence.golden.json`
- `result_summary.golden.json`

It also writes optional, non-admission human review artifacts:

- `external_ref_map.json`
- `adapter_diagnostics.json`

## FFI Ruby Receipt Fixtures

Validate standalone Ruby FFI ObsPacket fixtures:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb
```

Regenerate the committed fixture artifacts:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb --write-fixtures
```

Write and check a candidate fixture directory:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb --write-fixtures --candidate /tmp/runtime_machine_ffi_ruby_receipt_candidate
ruby igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb --candidate /tmp/runtime_machine_ffi_ruby_receipt_candidate
```

Expected summary:

```text
PASS runtime_machine_ffi_ruby_receipt_fixtures
fixture_dir: <dir>
manifest: ok
artifact_header: ok
descriptor_packets: ok
scenario_packets: ok
read_success: ok
write_audit_success: ok
capability_denied: ok
host_error: ok
cross_case: ok
```

Fixture scenarios:

- `read_success` - `fact_observation`, lifecycle `session`.
- `write_audit_success` - `receipt_observation`, lifecycle `audit`.
- `capability_denied` - `failure_observation`, lifecycle `session`,
  `host_call_attempted: false`.
- `host_error` - `failure_observation`, lifecycle `session`,
  `host_call_attempted: true`.

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

[D] Sidecar builder profiles can now emit a candidate fixture directory that
passes the structural checker without touching package code.

[D] The checker and sidecar builder now support `full_log` and
`selected_profile` modes. `selected_profile` is the first compatibility shape
for future bridge/package candidates that cannot or should not emit full
session logs.

[D] The external candidate normalizer proves the first selected-profile
admission path from raw external refs to canonical candidate artifacts, without
package edits.

[D] FFI Ruby receipt fixtures now prove read success, write/audit success,
capability denial, and host error as ObsPacket fixtures with checker
expectations.

## Files

- `runtime_machine_memory_proof.rb` - executable harness.
- `packet_builder_check.rb` - structural checker for golden or candidate
  fixture directories.
- `sidecar_builder_profiles.rb` - standalone sidecar profile builder that emits
  candidate fixture directories.
- `external_candidate_normalizer.rb` - standalone raw external candidate
  normalizer that emits selected-profile candidate directories.
- `external_candidate_fixture/raw_candidate.json` - tiny raw external candidate
  fixture with external refs and semantic assertions.
- `ffi_ruby_receipt_fixtures.rb` - standalone fixture generator/checker for
  Ruby FFI read/write/failure ObsPackets.
- `ffi_ruby_receipt_fixtures/*.json` - committed Ruby FFI receipt/failure
  fixture artifacts.
- `fixtures/*.golden.json` - structural golden artifacts generated from the
  harness.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: runtime-machine-ffi-ruby-receipt-fixtures-v0
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
- `sidecar_builder_profiles.rb` emits candidate artifact directories from
  standalone profile builders and checks them against golden fixtures.
- Checker and sidecar builder support `full_log` and `selected_profile` modes.
- `external_candidate_normalizer.rb` maps a raw external candidate fixture into
  selected-profile artifacts and checks them against golden fixtures.
- `ffi_ruby_receipt_fixtures.rb` emits and checks Ruby FFI read success,
  write/audit success, capability denied, and host error packets.

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
- Keep sidecar profiles as research-local adapters until the bridge packet
  schema is approved.
- Use `full_log` for proof-regression work and `selected_profile` for early
  bridge/package-derived candidate experiments.
- Keep external source maps and adapter diagnostics outside trusted admission
  evidence until the checker explicitly consumes them.
- Keep FFI receipt/failure fixtures standalone until an integration slice
  defines where package adapters emit them.

[S] Signals:
- Runtime Machine semantics are now executable at toy scale.
- The negative fixtures make false reproducibility visible.
- Structural fixtures are now stable enough to drive packet-builder tests.
- Fixture validation now has categories granular enough to tell whether drift
  came from packet identity, SemanticImage, CompatibilityReport, or summary
  behavior.
- Candidate artifact emission now has a clean seam before package integration:
  proof output -> profile builders -> candidate JSON -> structural checker.
- Selected-profile mode gives future agents a smaller target without weakening
  required evidence links or result hash checks.
- External candidate normalization now has an executable proof surface:
  raw external refs -> canonical selected-profile artifacts -> checker pass.
- FFI outcomes are now visible as packet fixtures, not prose-only examples.

[Q] Open Questions:
- Should this harness later move under an approved experiment runner?
- Should CompatibilityReport become a shared bridge fixture before any package
  implementation work?
- Should future fixtures split full packet logs from selected packet profiles?
- Should the checker eventually produce JSON diagnostics in addition to the
  compact PASS/FAIL text?
- Should sidecar profiles eventually accept external packet-builder output, or
  stay only as the memory proof candidate generator?
- Should selected-profile comparison also allow SemanticImage/report field
  substitutions under explicit compatibility rules?
- Should a future checker validate `external_ref_map.json` and
  `adapter_diagnostics.json`, or keep them human-review only?
- Should FFI `intent_observation` become a first-class packet kind before
  package integration?

[Next] Proposed next slice:
- `runtime-machine-normalized-equivalence-profile-v0`
  Define when package/bridge candidate packets may differ from golden fixtures
  while preserving result meaning, evidence links, lifecycle, and compatibility
  decisions.
```
