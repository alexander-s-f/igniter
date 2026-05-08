# Track: Runtime Smoke Post-Switch Full Coverage v0

Card: S3-R8-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/runtime-smoke-post-switch-full-coverage-v0`
Status: done
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Expand the post-switch runtime smoke from Add + BiHistory to all six current
`emit_typed` surfaces:

1. CORE Add/compute
2. `stream_fold`
3. `OLAPPoint`
4. History single-axis TEMPORAL access
5. BiHistory bitemporal TEMPORAL access
6. invariant severity

No live TBackend, temporal executor, Ledger binding, or production cache is
introduced.

---

## Decision

[D] CORE-like surfaces use the strongest available runtime path per surface:

| Surface | Smoke path |
| --- | --- |
| Add/compute | `IgniterLang.compile` + existing `IgniterLang::RuntimeSmoke` + RuntimeMachine evaluate |
| `stream_fold` | `IgniterLang.compile` + `.igapp` load + proof-local finite replay evaluator |
| `OLAPPoint` | `IgniterLang.compile` + `.igapp` load + proof-local memory OLAP evaluator |
| invariant severity | `emit_typed` from dedicated typed fixture + `.igapp` load + proof-local invariant evaluator |

[D] TEMPORAL surfaces use:

```text
compile -> load_for_inspection -> evaluation_refusal
```

This preserves the current Gate 3 rule: History/BiHistory artifacts may load for
inspection, but evaluation remains structurally refused.

[D] C1 CompatibilityReport shape is cross-checked by reading the existing
`runtime_compatibility_report_temporal_load_check` summary for a History
artifact.

---

## Implemented Proof

Added:

```text
igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/
  runtime_smoke_post_switch_full_coverage.rb
  inputs/
  out/runtime_smoke_post_switch_full_coverage_summary.json
  out/*.igapp/
```

The proof writes only synthetic inputs under its own experiment directory and
assembles output `.igapp/` artifacts under its own `out/` directory.

---

## Coverage

| Surface | Result | Signal |
| --- | --- | --- |
| CORE Add/compute | PASS | RuntimeMachine evaluates `19 + 23 -> 42` and resumes trusted |
| `stream_fold` | PASS | finite replay consumes 3 events and folds to `24` |
| `OLAPPoint` | PASS | synthetic facts aggregate to exact Decimal string `"20.00"` |
| History[T] | PASS | loads for inspection; evaluate refuses with `runtime.temporal_execution_unsupported` and `history_read` |
| BiHistory[T] | PASS | loads for inspection; evaluate refuses with `runtime.temporal_execution_unsupported` and `bihistory_read` |
| invariant severity | PASS | typed invariant fixture loads; error invariant satisfied, warn invariant emits non-blocking observation |
| C1 CompatibilityReport cross-check | PASS | History report has load accepted and evaluation readiness blocked |

Uncovered surfaces:

```text
none
```

---

## Known Gaps

[R] `stream_fold` compile/load works, but runtime smoke still uses proof-local
defaults for `window.size`, `fold_stream.init`, and `fold_stream.fn_ref` because
the assembled stream SemanticIR surface does not yet carry all runtime replay
metadata.

[R] Invariant severity runtime smoke uses the existing typed fixture for
severity metadata. The source-to-classifier metadata preservation question stays
with Compiler/Grammar; this runtime card does not repair compiler metadata.

[R] TEMPORAL evaluation remains closed. The smoke intentionally proves refusal,
not execution.

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb
```

Observed output:

```text
PASS runtime_smoke_post_switch_full_coverage
core_add_compute.compile_load_evaluate: ok
stream_fold.compile_load_evaluate: ok
olap_point.compile_load_evaluate: ok
history_single_axis.load_refuse_eval: ok
bihistory_bitemporal.load_refuse_eval: ok
invariant_severity.compile_load_evaluate: ok
compatibility_report_cross_check: ok
no_uncovered_surfaces: ok
uncovered_surfaces: none
summary: igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/out/runtime_smoke_post_switch_full_coverage_summary.json
```

Regressions:

```text
ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb -> PASS
ruby igniter-lang/experiments/runtime_smoke_temporal_post_switch/runtime_smoke_temporal_post_switch.rb -> PASS
ruby -c igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb -> Syntax OK
```

---

## Handoff

```text
Card: S3-R8-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/runtime-smoke-post-switch-full-coverage-v0
Status: done

[D] Decisions
- Covered all six post-switch emit_typed surfaces in one runtime smoke proof.
- CORE-like surfaces load/evaluate where proof-local runtime support exists.
- TEMPORAL surfaces compile/load for inspection and structurally refuse
  evaluation.
- C1 CompatibilityReport shape is cross-checked for History.

[S] Shipped / Signals
- Added runtime_smoke_post_switch_full_coverage experiment and summary JSON.
- Add evaluates to 42, stream fold evaluates to 24, OLAPPoint evaluates to
  Decimal string 20.00, invariant severity emits runtime observations.
- History and BiHistory preserve load_accept_evaluate_refuse.

[T] Tests / Proofs
- runtime_smoke_post_switch_full_coverage -> PASS
- runtime_compatibility_report_temporal_load_check -> PASS
- runtime_smoke_temporal_post_switch -> PASS
- ruby -c runtime_smoke_post_switch_full_coverage.rb -> Syntax OK

[R] Risks / Recommendations
- Stream runtime replay metadata should be made explicit in emitted SemanticIR.
- Invariant source/classifier metadata preservation remains a Compiler/Grammar
  follow-up; this proof uses the typed fixture for severity.
- Gate 3 remains closed: no live TBackend, temporal executor, Ledger ops, or
  production cache.

[Next] Suggested next slice
- Runtime CompatibilityReport executor boundary, or Compiler/Grammar repair for
  stream replay metadata and invariant metadata preservation.
```
