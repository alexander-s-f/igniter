# Track: Runtime Machine Proof Sidecar Profile Modes v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`
Artifacts:
- `igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb`

## Frame

This slice adds profile modes to the Runtime Machine memory proof sidecar
checker.

Previous sidecar work assumed one strict artifact shape:

```text
full session logs
  + selected packets
  + SemanticImage
  + CompatibilityReport set
  + negative evidence
  + result summary
```

That is right for proof regression. It is too strict for early bridge/package
candidates, which may be able to emit selected packet profiles before they can
emit full Session A / Session B packet logs.

This slice introduces two modes:

```text
full_log
selected_profile
```

It remains standalone:

- no package edits
- no Ledger dependency
- no bridge runtime dependency
- no production API claim

## Source Horizon

- `igniter-lang/docs/tracks/runtime-machine-proof-packet-builder-check-v0.md`
- `igniter-lang/docs/tracks/runtime-machine-proof-sidecar-builder-profiles-v0.md`
- `igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb`

## Compact Claim

[D] `full_log` is for proof regression. `selected_profile` is for bridge
candidate admission.

```text
full_log:
  require session_a/session_b packet logs
  compare complete golden payloads

selected_profile:
  allow no session logs
  require payload profile_mode
  require selected packets
  compare selected packet surface + result hash
  still validate SemanticImage, CompatibilityReport, negative evidence
```

[D] `selected_profile` is smaller, not weaker. It still requires:

- valid packet ids and payload hashes
- evidence links on resumed value packet
- SemanticImage content identity rules
- CompatibilityReport status rules
- negative evidence for false reproducibility
- result hash equality

## Commands

Full-log candidate:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb \
  --profile-mode full_log \
  --candidate /tmp/runtime_machine_sidecar_full_log
```

Full-log check:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb \
  --profile-mode full_log \
  --candidate /tmp/runtime_machine_sidecar_full_log
```

Selected-profile candidate:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb \
  --profile-mode selected_profile \
  --candidate /tmp/runtime_machine_sidecar_selected
```

Selected-profile check:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb \
  --profile-mode selected_profile \
  --candidate /tmp/runtime_machine_sidecar_selected
```

Expected selected-profile output:

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
selected_comparison: ok
```

## Mode Semantics

### full_log

`full_log` requires:

- `obs_packets.payload.sessions.session_a`
- `obs_packets.payload.sessions.session_b`
- `obs_packets.payload.selected`
- all other fixture artifacts

When candidate and golden directories differ, `full_log` performs exact payload
comparison for all artifact files.

Use `full_log` when:

- verifying the memory proof itself
- checking golden fixture drift
- proving a candidate can emit complete proof logs

### selected_profile

`selected_profile` requires:

- `obs_packets.payload.profile_mode = selected_profile`
- `obs_packets.payload.selected`
- all other fixture artifacts

It does not require:

- `obs_packets.payload.sessions.session_a`
- `obs_packets.payload.sessions.session_b`

When candidate and golden directories differ, `selected_profile` compares:

- selected packet surface
- result hash

It still runs structural checks for:

- SemanticImage
- CompatibilityReport
- negative evidence
- result summary

Use `selected_profile` when:

- a future bridge/package candidate can emit selected packets before full logs
- package internals should not expose complete session logs yet
- an agent needs a smaller candidate surface without dropping evidence links

## Design Notes

[D] The sidecar builder now writes selected-profile `obs_packets` artifacts as:

```text
payload:
  profile_mode: selected_profile
  selected:
    dispatch_candidate_value
    resumed_dispatch_candidate_value
    semantic_image_packet
    trusted_compatibility_report_packet
```

[D] The checker accepts optional session logs in selected mode. If a selected
candidate includes sessions, the checker validates them; it simply does not
require them.

[D] Default mode remains `full_log` to preserve strict regression behavior.

[D] The mode flag is explicit:

```text
--profile-mode full_log
--profile-mode selected_profile
```

## Risks

- `selected_profile` may allow candidates with structurally valid but incomplete
  provenance unless later external adapter rules constrain source refs.
- Future bridge outputs may need compatibility substitutions for SemanticImage
  or CompatibilityReport fields.
- Strict selected packet comparison is useful now, but package-derived outputs
  may require profile-specific normalization.
- Supporting many modes too early could blur the proof boundary.

## Rejected Paths

[X] Make selected-profile the default.

[X] Let selected-profile skip evidence-link validation.

[X] Let selected-profile pass without SemanticImage and CompatibilityReport
checks.

[X] Treat selected-profile as final package integration approval.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/runtime-machine-proof-sidecar-profile-modes-v0.md
Artifacts:
- igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
- igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb
Status: done

[D] Decisions:
- Added explicit `full_log` and `selected_profile` modes.
- `full_log` preserves strict complete artifact comparison.
- `selected_profile` allows candidates without session logs while preserving
  selected packet, SemanticImage, CompatibilityReport, negative evidence, and
  result summary checks.
- Default remains `full_log`.

[R] Recommendations:
- Use `full_log` for proof and fixture regression.
- Use `selected_profile` for the first external bridge/package candidate
  adapter experiments.
- Define substitution/normalization rules before allowing selected-profile
  package candidates to differ in SemanticImage or report fields.

[S] Signals:
- The checker now has a smaller bridge-admission surface that does not weaken
  evidence requirements.
- Future agents can start with selected packets instead of full replay logs.

[Q] Open Questions:
- Which SemanticImage/report fields may differ for package-derived selected
  candidates?
- Should selected-profile emit JSON diagnostics for missing optional sessions?
- Should external candidate adapters target selected-profile first?

[Next] Proposed next slice:
- `runtime-machine-proof-external-candidate-adapter-v0`
  Define how an external bridge/package candidate directory can map into the
  selected-profile artifact contract.
```
