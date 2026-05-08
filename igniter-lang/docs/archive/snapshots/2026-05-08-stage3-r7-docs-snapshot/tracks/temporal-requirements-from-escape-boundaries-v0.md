# temporal-requirements-from-escape-boundaries-v0

Card: S3-R4-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Status: implemented

## Goal

Derive `.igapp/requirements.json` temporal and escape capability requirements
from SemanticIR `escape_boundaries` instead of static assembler defaults.

## Decision

`Assembler#requirements_for` now receives the SemanticIR program and uses:

- `contracts[].escape_boundaries[].required_caps` as the source of truth for
  `requirements.capabilities.required_caps`.
- `contracts[].escape_boundaries[].produces` as the source of truth for
  `requirements.capabilities.effect_kinds`.
- `contracts[].fragment_class` as the emitted `requirements.fragments`
  evidence.
- Temporal access nodes only as metadata evidence for axes and coordinate refs;
  runtime execution and cache behavior remain out of scope.

This fixes the previous static behavior where CORE artifacts advertised
temporal TBackend requirements.

## Requirement Mapping

| SemanticIR evidence | Requirements result |
| --- | --- |
| no escape boundaries | `required_caps: []`, `read_as_of: false`, `append_atomic: false` |
| `history_read` | `requires_as_of: true`, `requires_valid_time: true`, `read_as_of: true` |
| `bihistory_read` | `requires_valid_time: true`, `requires_transaction_time: true`, `requires_replay: true`, `read_as_of: true`, `replay_enabled: true` |
| `stream_input` | `has_window: true`, `required_caps: ["stream_input"]`, temporal TBackend caps remain false |

`append_atomic` stays false because this slice derives read requirements only.
No live runtime enforcement, Ledger calls, or TBackend adapter binding were
added.

## Proof

New proof:

```bash
ruby igniter-lang/experiments/temporal_requirements_from_escape_boundaries/temporal_requirements_from_escape_boundaries.rb
```

Result:

```text
PASS temporal_requirements_from_escape_boundaries
core_vs_history_requirements_differ: ok
core_vs_bihistory_requirements_differ: ok
core_vs_stream_requirements_differ: ok
history_requires_valid_time_only: ok
bihistory_requires_valid_and_transaction_time: ok
stream_does_not_require_temporal_tbackend: ok
```

The proof compares:

- CORE Add: no required caps and no temporal TBackend caps.
- History: `history_read` derived from `escape_boundaries`.
- BiHistory: `bihistory_read` derived from `escape_boundaries`.
- Stream: `stream_input` derived from `escape_boundaries` without temporal
  TBackend requirements.

Summary artifact:
`igniter-lang/experiments/temporal_requirements_from_escape_boundaries/summary.json`

## Regression

```text
PASS igapp_assembler_proof
PASS production_compiler_cli_proof
PASS source_to_semanticir_fixture_golden_check
PASS temporal_semanticir_access_node --check-golden
PASS stage1_close_candidate
PASS stage2_close_candidate
```

## Compatibility With C1/C2

C1 temporal SemanticIR access node compatibility:
this slice consumes the `escape_boundaries` emitted beside
`temporal_access_node` and does not change the temporal node shape.

C2 runtime temporal cache contract compatibility:
requirements now record temporal capability and coordinate evidence, but no
cache key, memoization, runtime enforcement, Ledger call, or TBackend adapter
binding is introduced. The RuntimeMachine cache contract can still treat these
requirements as report/descriptor evidence.

CompatibilityReport descriptor consumption:
`required_caps` is now descriptor-readable from the assembled requirements
packet while remaining report-only.

## Remaining Gaps

- Temporal `.igapp` execution is still out of scope for this card.
- A later RuntimeMachine slice must enforce `history_read` / `bihistory_read`
  against real adapter descriptors.
- The assembler requirements builder now has a clear source of truth, but
  manifest policy for first-class temporal package execution remains a separate
  boundary.

## Handoff

[D] `requirements.json` is now derived from SemanticIR `escape_boundaries`,
not static assembler defaults.

[S] CORE, History, BiHistory, and Stream/ESCAPE requirements are distinct in
proof output.

[T] Guards passed: temporal requirements proof, igapp assembler proof,
production compiler CLI proof, source-to-SemanticIR golden check, temporal
SemanticIR golden check, Stage 1 close candidate, and Stage 2 close candidate.

[R] Runtime enforcement and Ledger/TBackend adapter binding remain explicitly
out of scope.

[Next] Implement descriptor/runtime enforcement for derived temporal caps once
the RuntimeMachine adapter boundary is ready.
