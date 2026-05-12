# PROP-037 CompatibilityReport Readiness Proof v0

Card: S3-R41-C1-P1
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `prop037-compatibility-report-readiness-proof-v0`
Status: done
Date: 2026-05-12

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` owns future parser, TypeChecker,
  SemanticIR, and OOF-PR6/OOF-PR8 compiler-context work.
- `[Igniter-Lang Bridge Agent]` may later map descriptor metadata into manifest
  and runtime-profile bridge requirements.

## Route

```text
Route: UPDATE
Card: S3-R41-C1-P1
Role: research-agent
Stage/Round observed: Stage 3 / Round 41
Previous accepted PROP-037 evidence: S3-R38-C2-P1, S3-R40-C1-P1
```

## Goal

Prove that valid PROP-037 progression descriptor metadata can be consumed into a
CompatibilityReport-shaped report while runtime readiness remains closed.

This proof keeps runtime readiness refusal separate from compiler OOF
diagnostics.

## Inputs Read

```text
igniter-lang/AGENTS.md
igniter-lang/roles/README.md
igniter-lang/roles/research-agent.md
igniter-lang/docs/agent-context.md
igniter-lang/docs/current-status.md
igniter-lang/docs/operating-model.md
igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md
igniter-lang/docs/tracks/prop037-progression-descriptor-shape-proof-v0.md
igniter-lang/docs/tracks/prop037-descriptor-oof-pr-proof-v0.md
igniter-lang/docs/tracks/stage3-round40-status-curation-v0.md
```

## Boundary

This track is proof-local report consumption only. It does not authorize or
implement:

```text
parser syntax
TypeChecker implementation
SemanticIR implementation
assembler or .igapp changes
RuntimeMachine scheduler
progression materializer
Ledger/TBackend binding
durable queue
durable checkpoint
receipt sink implementation
checkpoint persistence
production execution
ProgressionPack dispatch
new PROGRESSION fragment class
```

## Proof Shape

The proof consumes three valid descriptor fixtures, one per accepted PROP-037 v0
`source_kind`:

| Fixture | `source_kind` | Runtime readiness |
| --- | --- | --- |
| `clock_every_valid_descriptor` | `clock.every` | `ready: false` |
| `queue_valid_descriptor` | `queue` | `ready: false` |
| `external_event_valid_descriptor` | `external_event` | `ready: false` |

Each report emits:

```json
{
  "kind": "compatibility_report",
  "report_mode": "report_only",
  "descriptor_profile": {
    "progression_profile_status": "present"
  },
  "compiler_oof": {
    "pass_result": "ok",
    "diagnostics": []
  },
  "progression_runtime_readiness": {
    "ready": false,
    "reason": "progression.runtime_execution_not_authorized",
    "separate_from_compiler_oof": true
  }
}
```

Runtime readiness refusal is intentionally not an OOF diagnostic. It is a
CompatibilityReport readiness field stating that the descriptor is understood
but not executable.

## Live-Call Invariant

The proof records all live-call attempt flags as false:

```text
progression_scheduler_call_attempted
progression_materializer_call_attempted
progression_receipt_sink_call_attempted
durable_queue_call_attempted
durable_checkpoint_call_attempted
ledger_call_attempted
tbackend_call_attempted
production_cache_call_attempted
checkpoint_persistence_call_attempted
progression_pack_dispatch_attempted
```

## Decisions

[D] Valid PROP-037 progression descriptors can be represented in a
CompatibilityReport-shaped output with descriptor metadata present.

[D] Valid descriptors have no compiler OOF diagnostics in this report
consumption proof.

[D] Runtime readiness remains closed with stable refusal code:

```text
progression.runtime_execution_not_authorized
```

[D] Runtime readiness refusal is separate from compiler OOF diagnostics.

[D] The proof does not introduce a `PROGRESSION` fragment class or any runtime
scheduler/materializer binding.

## Proof

Command:

```text
ruby igniter-lang/experiments/prop037_compatibility_report_readiness_proof/prop037_compatibility_report_readiness_proof.rb
```

Output:

```text
PASS prop037_compatibility_report_readiness_proof
valid_descriptors_all_present: ok
descriptor_metadata_present: ok
valid_descriptors_have_no_oof: ok
runtime_readiness_false: ok
runtime_refusal_code_stable: ok
runtime_refusal_separate_from_compiler_oof: ok
no_scheduler_or_materializer_invocation: ok
no_durable_or_external_runtime_invocation: ok
no_progression_fragment_class_or_runtime_binding: ok
closed_source_kind_coverage: ok
summary: igniter-lang/experiments/prop037_compatibility_report_readiness_proof/prop037_compatibility_report_readiness_proof_summary.json
```

Summary artifact:

```text
igniter-lang/experiments/prop037_compatibility_report_readiness_proof/prop037_compatibility_report_readiness_proof_summary.json
```

## Remaining Gaps Before Implementation

| Layer | Remaining gap |
| --- | --- |
| Parser | Service-loop/progression source syntax and parser implementation remain unauthorized. |
| Classifier/TypeChecker | Compiler-owned progression AST/typed descriptor boundary remains open; OOF-PR6 and OOF-PR8 still need fragment context. |
| SemanticIR | Progression node/artifact shape and golden fixture plan remain future work. |
| Assembler/.igapp | Manifest schema authorization for `progression_sources` remains blocked. |
| RuntimeMachine | Scheduler/materializer authority and proof-local implementation plan remain absent. |
| Durability | Durable queue/checkpoint/receipt sink design and authorization remain absent. |
| Ledger/TBackend | Separate binding decision required; progression metadata does not imply it. |
| Production execution | Explicit runtime/production gate required. |
| ProgressionPack | Compiler profile/pack migration authorization remains absent. |

## Changed Files

```text
igniter-lang/docs/tracks/prop037-compatibility-report-readiness-proof-v0.md
igniter-lang/experiments/prop037_compatibility_report_readiness_proof/prop037_compatibility_report_readiness_proof.rb
igniter-lang/experiments/prop037_compatibility_report_readiness_proof/prop037_compatibility_report_readiness_proof_summary.json
```

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/prop037-compatibility-report-readiness-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Valid PROP-037 descriptor metadata can be consumed into report-only CompatibilityReport shape.
- Valid descriptors produce no OOF in this proof.
- Runtime readiness remains false with `progression.runtime_execution_not_authorized`.
- Readiness refusal is separate from compiler OOF diagnostics.
- No scheduler, materializer, Ledger/TBackend, durable queue/checkpoint, receipt sink, ProgressionPack, or PROGRESSION fragment class is authorized.

[R] Recommendations:
- Next implementation-facing card should first decide manifest/CompatibilityReport schema ownership for `progression_sources`.
- OOF-PR6 and OOF-PR8 should remain with compiler-owned AST/typed fragment context.

[S] Signals:
- Descriptor coverage includes `clock.every`, `queue`, and `external_event`.
- The report includes explicit no-live-call flags for scheduler/materializer/durability/runtime bindings.

[T] Tests / Proofs:
- `ruby -c igniter-lang/experiments/prop037_compatibility_report_readiness_proof/prop037_compatibility_report_readiness_proof.rb` PASS.
- `ruby igniter-lang/experiments/prop037_compatibility_report_readiness_proof/prop037_compatibility_report_readiness_proof.rb` PASS.

[Files] Changed:
- `igniter-lang/docs/tracks/prop037-compatibility-report-readiness-proof-v0.md`
- `igniter-lang/experiments/prop037_compatibility_report_readiness_proof/prop037_compatibility_report_readiness_proof.rb`
- `igniter-lang/experiments/prop037_compatibility_report_readiness_proof/prop037_compatibility_report_readiness_proof_summary.json`

[Q] Open Questions:
- Which artifact owns `progression_sources`: manifest-only, CompatibilityReport-only, or both?
- What is the first accepted SemanticIR/assembler shape for progression metadata without a PROGRESSION fragment class?

[X] Rejected:
- Treating valid descriptor readiness refusal as compiler OOF.
- Calling scheduler/materializer/Ledger/TBackend/durable queue/checkpoint/receipt sink from this proof.

[Next] Proposed next slice:
- Define the manifest/CompatibilityReport schema contract for `progression_sources`, still with runtime readiness closed.
```
