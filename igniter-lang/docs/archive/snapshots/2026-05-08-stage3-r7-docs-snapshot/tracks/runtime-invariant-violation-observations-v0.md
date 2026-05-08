# Runtime Invariant Violation Observations v0

Card: S2-R12-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/runtime-invariant-violation-observations-v0
Status: done
Date: 2026-05-07

## Goal

Model runtime invariant failures as observation-shaped violation records without
changing compile-time `invariant_node` lowering.

This slice is runtime proof work only. It does not alter parser, typechecker,
or SemanticIR emitter behavior, and it does not implement deferred OOF-I1,
OOF-I3, or OOF-I5.

## Source Horizon

- `invariant-severity-parser-impl-v0.md`: parser and TypeChecker own PINV/TINV
  checks; deferred OOF-I1/I3/I5 stay deferred.
- `invariant-severity-semanticir-lowering-v0.md`: compile-time typed invariant
  declarations lower to `invariant_node`, not `invariant_violation_node`.
- `invariant_severity_proof.rb`: proof-local runtime evaluator already covered
  severity behavior; this slice refines its runtime observation model.

## Boundary Decision

[D] Compile-time SemanticIR keeps this shape:

```text
invariant_node
  severity: error | warn | soft | metric
  output_effect: blocks | warns | uncertain | metric
```

[D] Runtime violations now emit observation records:

```text
invariant_violation_observation
  node.kind: invariant_violation_node
  node.source_node_kind: invariant_node
  node.source_node_ref: <compile-time invariant name>
  node.severity: error | warn | soft | metric
  node.output_effect: block_trusted_output | attach_warning |
                      promote_to_uncertain | record_metric
```

[D] `invariant_violation_node` is not added to compile-time SemanticIR. It is a
runtime observation payload nested inside `invariant_violation_observation`.

## Severity Runtime Behavior

| Severity | Runtime violation observation | Evaluation behavior |
|----------|-------------------------------|---------------------|
| `error` | `invariant_violation_node`, `blocks_trusted_output: true` | blocks trusted output |
| `warn` | `invariant_violation_node`, `output_effect: attach_warning` | continues with warning |
| `soft` | `invariant_violation_node`, `output_effect: promote_to_uncertain` | continues as `~T` uncertain |
| `metric` | `invariant_violation_node`, `output_effect: record_metric` | continues; records metric |

All runtime violation observations link back to the compile-time invariant:

```text
evidence_links:
  rel: runtime_violation_of
  to: invariant_node/<name>
```

Satisfied invariants now emit `invariant_verification_observation`, keeping the
runtime observation stream explicit without confusing satisfied checks with
violation records.

## Proof Updates

[S] `invariant_severity_proof` now records two explicit summary models:

```text
compile_time_node_model:
  node_kind: invariant_node
  runtime_violation_nodes_emitted: false

runtime_observation_model:
  observation_kind: invariant_violation_observation
  node_kind: invariant_violation_node
  source_node_kind: invariant_node
```

[S] New proof checks:

```text
observations.compile_time_nodes_remain_invariant_node
observations.no_compile_time_violation_nodes
observations.error_violation_node
observations.warn_violation_node
observations.soft_violation_node
observations.metric_violation_node
observations.violation_node_severities
observations.violation_links_compile_time_node
```

## Verification

```text
ruby -c igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
  -> Syntax OK

ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
  -> PASS invariant_severity_proof

ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
  -> PASS stage1_close_candidate
```

## Changed Files

```text
igniter-lang/docs/tracks/runtime-invariant-violation-observations-v0.md
igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
igniter-lang/experiments/invariant_severity_proof/summary.json
igniter-lang/experiments/invariant_severity_proof/golden/error_blocks.json
igniter-lang/experiments/invariant_severity_proof/golden/warn_allows.json
igniter-lang/experiments/invariant_severity_proof/golden/soft_uncertain.json
igniter-lang/experiments/invariant_severity_proof/golden/metric_records.json
```

## Handoff

```text
Card: S2-R12-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/runtime-invariant-violation-observations-v0
Status: done

[D] Decisions
- Runtime invariant failures now emit invariant_violation_observation records.
- invariant_violation_node is runtime observation payload shape, not compile-time SemanticIR lowering.
- Compile-time invariant_node semantics remain unchanged.
- Deferred OOF-I1/I3/I5 remain out of scope.

[S] Shipped / Signals
- error/warn/soft/metric severity behavior is covered through runtime violation observations.
- Every violation observation links back to its source invariant_node.
- Satisfied invariants emit invariant_verification_observation.

[T] Tests / Proofs
- ruby -c igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb -> Syntax OK
- ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations
- Production RuntimeMachine still needs a real invariant evaluation boundary before these observation records become package behavior.
- Keep OOF-I1 (@bitemporal), OOF-I3 (~T), and OOF-I5 (requirements DB) in their deferred compile-time lanes.

[Next] Suggested next slice
- runtime-invariant-observation-runtime-machine-boundary-v0: decide where production RuntimeMachine should emit and persist invariant_violation_observation records.
```
