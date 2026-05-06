# Track: Runtime Machine External Candidate Normalizer Fixtures v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`
Artifacts:
- `igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_fixture/raw_candidate.json`

## Frame

The previous slice defined an admission contract:

```text
external raw candidate
  -> normalize into selected_profile artifacts
  -> packet_builder_check.rb --profile-mode selected_profile
  -> package integration may be considered later
```

This slice makes that contract executable with a tiny standalone raw candidate
fixture. It does not call package code and does not introduce a production API.

## Source Horizon

- `igniter-lang/docs/tracks/runtime-machine-external-candidate-and-ffi-proof-v0.md`
- `igniter-lang/docs/tracks/runtime-machine-proof-sidecar-profile-modes-v0.md`
- `igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/fixtures/`

## Compact Claim

[D] The first external candidate fixture is intentionally narrow:

```text
raw_candidate.json
  external refs
  semantic assertions
  full_session_logs: false

external_candidate_normalizer.rb
  validates assertions against golden proof facts
  emits selected_profile candidate artifacts
  writes optional human diagnostics
  runs packet_builder_check.rb
```

[D] The normalizer proves admission, not semantic substitution freedom. The
current checker still requires exact selected packet equality and result hash
equality against the memory proof golden fixtures.

## Raw Fixture

The raw fixture is:

```text
igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_fixture/raw_candidate.json
```

It carries:

- `profile_mode: selected_profile`
- `source.full_session_logs: false`
- external refs such as `spark://orders/O-100`
- canonical refs such as `order/o-1`
- semantic substitutions with reasons
- expected result hash
- expected SemanticImage content hash
- expected trusted resume status
- required link rels: `read_from`, `executed_by`, `produced_in`,
  `observed_under`
- `negative_evidence_policy: preserve`

## Normalized Candidate Directory

The normalizer writes:

```text
candidate/
  manifest.json
  obs_packets.golden.json
  semantic_image.golden.json
  compatibility_reports.golden.json
  negative_evidence.golden.json
  result_summary.golden.json
  external_ref_map.json
  adapter_diagnostics.json
```

Trusted admission files are only:

```text
manifest.json
obs_packets.golden.json
semantic_image.golden.json
compatibility_reports.golden.json
negative_evidence.golden.json
result_summary.golden.json
```

The manifest hashes only those trusted files. `external_ref_map.json` and
`adapter_diagnostics.json` are intentionally human-review aids in v0.

## Normalization Rules

[D] `obs_packets.golden.json` is normalized to the selected-profile surface:

```text
payload:
  profile_mode: selected_profile
  selected:
    dispatch_candidate_value
    resumed_dispatch_candidate_value
    semantic_image_packet
    trusted_compatibility_report_packet
```

[D] Other required artifacts preserve the memory proof golden payloads:

- `semantic_image.golden.json`
- `compatibility_reports.golden.json`
- `negative_evidence.golden.json`
- `result_summary.golden.json`

[D] The raw fixture must prove before emission:

- selected-profile mode is explicit;
- full session logs are absent;
- result hash matches the proof result hash;
- SemanticImage content hash matches the proof image;
- trusted resume status matches the CompatibilityReport;
- required evidence rels exist on the resumed selected value;
- negative evidence policy is preserve;
- semantic substitutions are declared.

## Commands

Default run:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb
```

Run into a known candidate directory:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb \
  --candidate /tmp/runtime_machine_external_candidate_normalized
```

Check emitted candidate directly:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb \
  --profile-mode selected_profile \
  --candidate /tmp/runtime_machine_external_candidate_normalized
```

Expected normalizer output:

```text
PASS runtime_machine_external_candidate_normalizer
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

## What This Proves

[D] An external candidate can start as raw external refs and semantic
assertions, then normalize into selected-profile proof artifacts.

[D] Optional diagnostics can travel beside admission artifacts without becoming
trusted evidence.

[D] The selected-profile checker remains the hard gate. The normalizer does not
grant trust by itself.

[D] Absence of full session logs is explicit and compatible with
selected-profile admission.

## What It Does Not Prove

[X] It does not prove package integration.

[X] It does not allow external candidates to change selected packet content.

[X] It does not validate `external_ref_map.json` as trusted evidence.

[X] It does not prove Ruby FFI receipt/failure packet shapes yet.

[X] It does not promote selected-profile to `full_log`.

## Risks

- The current normalizer uses golden payloads after validating raw semantic
  assertions. A real adapter will need richer field-level mapping before
  package output can differ.
- Optional diagnostics can become misleading if humans treat them as trusted
  admission evidence.
- The exact selected comparison is useful for v0 but too strict for future
  normalized equivalence profiles.
- The fixture uses Spark-like refs for pressure, but no real Spark package
  semantics.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/runtime-machine-external-candidate-normalizer-fixtures-v0.md
Artifacts:
- igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb
- igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_fixture/raw_candidate.json
Status: done

[D] Decisions:
- Added a standalone raw external candidate fixture.
- Added a standalone normalizer that emits selected-profile candidate
  artifacts and invokes the packet-builder checker.
- Trusted admission remains the existing required artifact set.
- Optional `external_ref_map.json` and `adapter_diagnostics.json` are
  human-review only in v0.
- Full session logs remain absent and explicit.

[R] Recommendations:
- Keep package integration blocked until a real external adapter passes this
  same selected-profile gate.
- Add a future normalized-equivalence checker profile before allowing selected
  packets to differ semantically from the memory proof golden packets.
- Keep optional diagnostics outside manifest trust until the checker owns their
  schema.

[S] Signals:
- The bridge admission surface is now executable: raw external refs ->
  normalized selected-profile artifacts -> checker pass.
- The next useful proof is FFI receipt/failure packet fixtures.

[Q] Open Questions:
- Should external ref maps become typed observations or stay diagnostics?
- Should the normalizer reject stale optional files in candidate directories?
- What exact field substitutions should a real package adapter be allowed to
  make?

[Next] Proposed next slice:
- `runtime-machine-ffi-ruby-receipt-fixtures-v0`
  Add standalone Ruby FFI read/write/failure ObsPacket fixtures and checker
  expectations without package integration.
```
