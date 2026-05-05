# Runtime Machine Memory Proof

Status: done
Slice state: done on 2026-05-05
Slice name: `runtime-machine-memory-proof-implementation-v0`
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

## What It Proves

[D] A minimal Runtime Machine can make lifecycle continuity executable without
Ledger or package runtime integration.

[D] `:memory` TBackend can prove ordering, replay, snapshots, SemanticImage,
CompatibilityReport, and trusted resume inside one proof harness.

[D] `:memory` TBackend cannot claim durable restart after process memory loss.
The empty-backend resume fixture must remain blocked.

[D] Equal result hashes are not enough. The proof requires observation links
and compatibility evidence.

## Files

- `runtime_machine_memory_proof.rb` - executable harness.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: runtime-machine-memory-proof-implementation-v0
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

[R] Recommendations:
- Use this experiment as the next golden fixture source for sidecar packet
  builders.
- Keep package integration blocked until packet shape and write location are
  approved separately.
- Add file-backed TBackend only after memory lifecycle checks remain stable.

[S] Signals:
- Runtime Machine semantics are now executable at toy scale.
- The negative fixtures make false reproducibility visible.

[Q] Open Questions:
- Should this harness later move under an approved experiment runner?
- Should CompatibilityReport become a shared bridge fixture before any package
  implementation work?

[Next] Proposed next slice:
- `runtime-machine-proof-packet-fixtures-v0`
  Extract expected ObsPacket/CompatibilityReport fixtures from this harness.
```
