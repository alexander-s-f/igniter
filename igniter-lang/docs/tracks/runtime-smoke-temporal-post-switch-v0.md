# Runtime Smoke Temporal Post Switch v0

Card: S3-R7-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/runtime-smoke-temporal-post-switch-v0
Status: done
Date: 2026-05-08

## Goal

Run a small post-switch runtime smoke after the production compiler moved to:

```text
Parser -> Classifier -> TypeChecker -> SemanticIREmitter.emit_typed -> Assembler
```

Scope remains proof-level. This slice does not implement a temporal executor,
TBackend binding, or production cache.

## Proof

Command:

```text
ruby igniter-lang/experiments/runtime_smoke_temporal_post_switch/runtime_smoke_temporal_post_switch.rb
```

Output:

```text
PASS runtime_smoke_temporal_post_switch
core.compile_ok: ok
core.runtime_loads_and_evaluates: ok
temporal.compile_ok: ok
temporal.loads_for_inspection: ok
temporal.evaluate_refuses_structured: ok
core.sum: 42
temporal.load_status: loaded
temporal.evaluate_reason: runtime.temporal_execution_unsupported
summary: igniter-lang/experiments/runtime_smoke_temporal_post_switch/runtime_smoke_temporal_post_switch_summary.json
```

Syntax:

```text
ruby -c igniter-lang/experiments/runtime_smoke_temporal_post_switch/runtime_smoke_temporal_post_switch.rb
  -> Syntax OK
```

## CORE Smoke

Fixture:

```text
igniter-lang/experiments/source_to_semanticir_fixture/add.ig
```

Result:

```text
compile_status: ok
pass_result: ok
runtime.load_status: loaded
runtime.evaluate_status: ok
runtime.outputs.sum: 42
runtime.compatibility_report_status: trusted
runtime.trusted: true
```

[S] CORE Add-style `.igapp/` still loads and evaluates after the production
compiler switch to `emit_typed`.

## TEMPORAL Smoke

Fixture:

```text
igniter-lang/experiments/typed_emission_main_path_parity/sparkcrm_bihistory_source.ig
```

Result:

```text
compile_status: ok
pass_result: ok
load_for_inspection.status: loaded
load_for_inspection.mode: inspection_only
load_for_inspection.runtime_execution.guard_policy: load_accept_evaluate_refuse
evaluate_without_executor.kind: evaluation_refusal
evaluate_without_executor.status: blocked
evaluate_without_executor.guard_at: evaluate
evaluate_without_executor.reason_code: runtime.temporal_execution_unsupported
required_capabilities: bihistory_read
```

[S] TEMPORAL `.igapp/` loads for inspection through the post-switch production
compiler path.

[S] TEMPORAL evaluation refuses structurally. It does not crash, silently trust,
or pretend execution exists.

## Runtime Boundary Gaps

[R] Temporal executor remains intentionally absent.

[R] Runtime TBackend binding remains absent; `bihistory_read` is required by
the bundle but no live adapter is selected.

[R] Production temporal memoization/cache remains absent. The smoke checks the
load/evaluate guard only.

[R] The proof-local guarded runtime mirrors the accepted boundary:

```text
load:     accept_for_inspection
evaluate: refuse_temporal_contract
reason:   runtime.temporal_execution_unsupported
```

Future work should implement executor/TBackend only through an explicit Gate 3
authorization track.

## Changed Files

```text
igniter-lang/docs/tracks/runtime-smoke-temporal-post-switch-v0.md
igniter-lang/experiments/runtime_smoke_temporal_post_switch/runtime_smoke_temporal_post_switch.rb
igniter-lang/experiments/runtime_smoke_temporal_post_switch/runtime_smoke_temporal_post_switch_summary.json
```

## Handoff

```text
Card: S3-R7-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/runtime-smoke-temporal-post-switch-v0
Status: done

[D] Decisions
- Kept scope proof-level; no temporal executor, no TBackend binding, no production cache.
- Used the post-switch production compiler path for both CORE and TEMPORAL bundles.
- Treated TEMPORAL load as inspection-only and evaluation as guarded refusal.

[S] Shipped / Signals
- CORE Add-style bundle compiles, loads, evaluates, and returns `sum=42`.
- TEMPORAL BiHistory bundle compiles and loads for inspection.
- TEMPORAL evaluation returns structured `evaluation_refusal`, not an accidental crash.

[T] Tests / Proofs
- `ruby -c igniter-lang/experiments/runtime_smoke_temporal_post_switch/runtime_smoke_temporal_post_switch.rb` -> Syntax OK
- `ruby igniter-lang/experiments/runtime_smoke_temporal_post_switch/runtime_smoke_temporal_post_switch.rb` -> PASS

[R] Risks / Recommendations
- Runtime executor/TBackend remains the real boundary gap.
- Do not expand this proof into live temporal execution without explicit Gate 3 authorization.
- A later Gate 3 request should reuse the same refusal shape as the negative baseline.

[Next]
- `runtime-temporal-executor-gate3-request-v0` only if Architect wants to open live temporal evaluation.
```
