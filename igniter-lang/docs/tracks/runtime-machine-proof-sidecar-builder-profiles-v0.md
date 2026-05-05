# Track: Runtime Machine Proof Sidecar Builder Profiles v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`
Artifact: `igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb`

## Frame

This slice adds standalone sidecar builder profiles for the Runtime Machine
memory proof.

The previous layers were:

```text
runtime_machine_memory_proof.rb
  -> fixtures/*.golden.json
  -> packet_builder_check.rb
```

This slice adds:

```text
proof output
  -> sidecar builder profiles
  -> candidate artifact directory
  -> packet_builder_check.rb --candidate <dir>
```

It remains standalone:

- no package edits
- no Ledger dependency
- no bridge runtime dependency
- no production API claim

## Source Horizon

- `igniter-lang/docs/tracks/runtime-machine-proof-packet-fixtures-v0.md`
- `igniter-lang/docs/tracks/runtime-machine-proof-packet-builder-check-v0.md`
- `igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb`

## Compact Claim

[D] A future package or bridge builder should first prove it can emit the same
artifact set as the memory proof.

```text
ObsPacketsProfile
SemanticImageProfile
CompatibilityReportsProfile
NegativeEvidenceProfile
ResultSummaryProfile
  -> candidate fixtures
  -> structural checker
```

[D] The sidecar builder profiles are not package adapters yet. They are the
research-local profile boundary that future adapters must match.

## Commands

Build a candidate directory in the default temp location and check it:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb
```

Build and check an explicit candidate directory:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb \
  --candidate /tmp/runtime_machine_sidecar_candidate
```

Write candidate artifacts without running the checker:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb \
  --write-candidate <dir>
```

Expected output:

```text
PASS runtime_machine_proof_sidecar_builder_profiles
candidate_dir: <dir>
proof_capture: ok
write_candidate: ok
packet_builder_check: ok
```

The emitted candidate directory is then accepted by:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb \
  --candidate <dir>
```

## Profile Set

The sidecar profile set writes the same artifact contract as the golden
fixtures:

```text
manifest.json
obs_packets.golden.json
semantic_image.golden.json
compatibility_reports.golden.json
negative_evidence.golden.json
result_summary.golden.json
```

### ObsPacketsProfile

Maps proof packet logs into the candidate `obs_packets` artifact.

Preserves:

- Session A packet log
- Session B packet log
- selected DispatchCandidate packets
- selected SemanticImage packet
- selected trusted CompatibilityReport packet

### SemanticImageProfile

Maps checkpoint output into the candidate `semantic_image` artifact.

Preserves:

- SemanticImage payload
- SemanticImage packet
- checkpoint receipt

### CompatibilityReportsProfile

Maps trusted and negative resume reports into the candidate
`compatibility_reports` artifact.

Preserves expected statuses:

- trusted resume: `trusted`
- empty backend resume: `blocked`
- runtime drift: `downgraded`
- contract drift: `blocked`

### NegativeEvidenceProfile

Maps false-reproducibility evidence into `negative_evidence`.

Preserves:

- missing `as_of` failure packet
- same value without evidence packet
- provisional missing-link evidence status

### ResultSummaryProfile

Maps proof check outcomes into `result_summary`.

Preserves:

- pass/fail checks
- result hash
- resumed result hash
- trusted evidence status

## Design Notes

[D] Candidate file names intentionally match golden file names. The checker
expects the artifact contract, not a separate candidate naming convention.

[D] The default candidate directory is a temp directory. The experiment does
not commit generated candidates by default.

[D] `--write-candidate` is useful for inspecting generated artifacts or handing
them to another checker process.

[D] This profile layer currently uses memory proof output as input. Future
builders can replace that source with package-derived sidecar output while
keeping the same artifact contract.

## Risks

- The profiles currently mirror the full golden artifact set; future package
  builders may need selected-profile modes.
- The checker uses strict golden comparison when candidate and golden dirs are
  different.
- Candidate artifacts are generated from the toy memory proof, not production
  runtime behavior.
- This slice may look like a package builder, but it is still research-local.

## Rejected Paths

[X] Write candidate artifacts into package test fixtures.

[X] Accept candidate output that skips the structural checker.

[X] Treat sidecar profiles as final bridge packet API.

[X] Generate candidates from current package objects before bridge approval.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/runtime-machine-proof-sidecar-builder-profiles-v0.md
Artifact: igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb
Status: done

[D] Decisions:
- Added standalone sidecar builder profiles for the memory proof.
- Profiles emit candidate artifact directories with the same contract as the
  golden fixtures.
- Candidate artifacts pass `packet_builder_check.rb --candidate <dir>`.
- Profiles remain research-local and do not touch packages.

[R] Recommendations:
- Keep future bridge/package builders behind this artifact contract first.
- Add selected-profile/full-log comparison modes before accepting partial
  package-derived candidates.
- Use temp candidate dirs for experiments; commit only golden fixtures.

[S] Signals:
- The proof now has a clean candidate pipeline:
  proof output -> profiles -> candidate artifacts -> structural checker.
- This gives Package/Bridge agents a concrete target without approving package
  integration.

[Q] Open Questions:
- Should checker support selected-profile mode before package-derived output?
- Should profile builders emit JSON diagnostics describing source provenance?
- Should sidecar profiles eventually read external candidate packets directly?

[Next] Proposed next slice:
- `runtime-machine-proof-sidecar-profile-modes-v0`
  Define selected-profile vs full-log comparison modes before package bridge
  work begins.
```
