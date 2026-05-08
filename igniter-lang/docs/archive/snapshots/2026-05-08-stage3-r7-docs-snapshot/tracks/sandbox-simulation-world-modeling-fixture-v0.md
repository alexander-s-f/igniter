# Track: Sandbox Simulation World Modeling Fixture v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/sandbox-simulation-world-modeling-fixture-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`
Artifacts:
- `igniter-lang/experiments/sandbox_simulation_world_modeling_fixture/sandbox_simulation_world_modeling_fixture.rb`
- `igniter-lang/docs/tracks/sandbox-simulation-world-modeling-pressure-v0.md`

---

## Frame

This slice turns the sandbox/simulation pressure case into the first executable
synthetic world-modeling fixture.

Safety boundary:

- synthetic Spark-like scenario only
- no real Spark data
- no customers, employees, production orders, endpoints, provider payloads,
  credentials, tokens, queue names, or infrastructure details
- no production decision may be inferred from this fixture
- simulation output is not real observation

---

## What The Fixture Models

Positive case:

```text
WorldModel
  + AssumptionSet(calibration_status: none_sandbox_unvalidated)
  + ParameterSet(technician_count: 1)
  + ParameterSet(technician_count: 2)
  + Intervention(technician_count 1 -> 2)
  + deterministic SyntheticJobRequest x6
  -> ScenarioRun(baseline)
  -> ScenarioRun(add-one-technician)
  -> SyntheticObservation x6
  -> CounterfactualObservation x6
  -> ComparisonReport
  -> ModelValidityReport(status: unvalidated_synthetic)
```

The fixture proves this guardrail:

```text
simulation_success != production truth
counterfactual_improvement != authorized operational action
```

---

## Positive Result

Baseline:

```text
technician_count: 1
accepted_job_count: 4
missed_job_count: 2
conflict_count: 2
available_technician_slots: 4
used_technician_slots: 4
technician_slot_utilization: 1.00
observation_kind: SyntheticObservation
```

Intervention:

```text
technician_count: 2
accepted_job_count: 6
missed_job_count: 0
conflict_count: 0
available_technician_slots: 8
used_technician_slots: 6
technician_slot_utilization: 0.75
observation_kind: CounterfactualObservation
```

Comparison:

```text
accepted_job_count_delta: 2
missed_job_count_delta: -2
conflict_count_delta: -2
utilization_delta: -0.25
trust_status: synthetic_counterfactual
may_authorize_production_action: false
```

Model validity:

```text
status: unvalidated_synthetic
calibration_evidence_refs: []
allowed_uses:
  - language_fixture
  - scenario_comparison_shape
  - trust_boundary_pressure
forbidden_uses:
  - production_staffing_decision
  - real_capacity_forecast
  - personnel_claim
```

---

## Negative Cases

[D] Synthetic output cannot be declared real:

```text
diagnostic: simulation.synthetic_observation_used_as_real
comparison_report_status: invalid
```

[D] Counterfactual output cannot be audit evidence:

```text
diagnostic: simulation.counterfactual_not_audit_fact
```

[D] Scenario loops must be statically bounded:

```text
diagnostic: simulation.unbounded_loop_oof
fragment_class: OOF
```

[D] Stochastic runs need randomness policy evidence:

```text
diagnostic: simulation.randomness_policy_missing
fragment_class: ESCAPE_or_OOF
```

[D] Validated status requires calibration evidence:

```text
diagnostic: model_validity.calibration_evidence_missing
allowed_status: unvalidated_synthetic
```

---

## Proof Output

```text
ruby igniter-lang/experiments/sandbox_simulation_world_modeling_fixture/sandbox_simulation_world_modeling_fixture.rb
```

Output:

```text
PASS sandbox_simulation_world_modeling_fixture
positive.world_model_descriptor: ok
positive.assumption_calibration_explicit: ok
positive.max_steps_bounded: ok
baseline.metrics: ok
intervention.metrics: ok
comparison.deltas: ok
validity.unvalidated_synthetic: ok
observation_kinds.not_real: ok
negative.synthetic_as_real_blocked: ok
negative.counterfactual_audit_blocked: ok
negative.unbounded_loop_blocked: ok
negative.randomness_policy_missing: ok
negative.calibration_missing: ok
safety.synthetic_only: ok
baseline: accepted=4 missed=2 utilization=1.00
intervention: accepted=6 missed=0 utilization=0.75
comparison: accepted_delta=2 missed_delta=-2
validity: unvalidated_synthetic
```

The proof also supports:

```text
ruby igniter-lang/experiments/sandbox_simulation_world_modeling_fixture/sandbox_simulation_world_modeling_fixture.rb --dump
```

to inspect generated synthetic observations.

---

## Gap Report

### Compiler / Grammar

[Next] Formalize `RealObservation`, `SyntheticObservation`,
`ForecastObservation`, and `CounterfactualObservation` as distinct observation
kinds or trust classes on `Obs[kind,T]`.

[Next] Define the smallest CORE-bounded simulation operator. This proof uses a
static `max_steps == deterministic_event_list.count` loop.

[Next] Type `Intervention` so it cannot be confused with observed fact
mutation.

[Q] Is `WorldModel` a contract, module, schema-backed artifact, `.igapp`
loadable unit, or runtime descriptor?

[Q] What OOF rule prevents `ComparisonReport` from becoming operational
authorization without a separate review/action contract?

### Bridge

[Next] Draft metadata-only bridge profiles for:

- `ModelValidityReport`
- `ScenarioComparisonReport`
- `SimulationRunDiagnostic`
- `AssumptionParameterDiff`
- `StrategyCandidate`

[Q] Bridge should keep strategy candidates reviewable but non-executable until
an operation/action receipt consumes them.

---

## Boundaries

[X] Rejected: real Spark data, customers, employees, production orders,
endpoints, provider payloads, credentials, tokens, queue names, or
infrastructure details.

[X] Rejected: simulation output as real observation.

[X] Rejected: counterfactual output as audit fact.

[X] Rejected: unbounded loops in CORE.

[X] Rejected: production staffing/action decisions from an unvalidated
synthetic model.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/sandbox-simulation-world-modeling-fixture-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Built a stdlib-only executable synthetic fixture.
- Positive case emits WorldModel, AssumptionSet, baseline ParameterSet,
  add-one-technician ParameterSet, Intervention, two ScenarioRuns,
  SyntheticObservation events, CounterfactualObservation events,
  ComparisonReport, and ModelValidityReport.
- Baseline accepts 4 jobs and misses 2; intervention accepts 6 and misses 0.
- ComparisonReport is synthetic_counterfactual and cannot authorize
  production action.
- ModelValidityReport remains unvalidated_synthetic because calibration
  evidence is empty.
- SIM-1..SIM-5 negative trust-boundary cases are covered.

[R] Recommendations:
- Compiler/Grammar: formalize observation trust classes, bounded simulation
  loops, Intervention typing, and ComparisonReport consumption rules.
- Bridge: define ModelValidityReport and ScenarioComparisonReport profiles
  before any platform simulation UI is considered.

[S] Signals:
- Model validity is not runtime compatibility.
- Reproducible simulation can still be invalid for reality.
- Counterfactual improvement is strategy pressure, not action authority.

[T] Tests / Proofs:
- sandbox_simulation_world_modeling_fixture.rb -> PASS

[Files] Changed:
- igniter-lang/experiments/sandbox_simulation_world_modeling_fixture/sandbox_simulation_world_modeling_fixture.rb
- igniter-lang/docs/tracks/sandbox-simulation-world-modeling-fixture-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Distinct observation kinds vs trust classes?
- Is WorldModel a contract/module/artifact/runtime descriptor?
- Which bounded simulation loop form can remain CORE?
- How does a ComparisonReport stay non-authorizing until review/action?

[X] Rejected:
- Real Spark data or endpoints.
- Simulation output as real observation.
- Counterfactual output as audit fact.
- Unvalidated synthetic model as production decision support.

[Next] Proposed next slice:
- Compiler/Grammar Expert: observation-kind and bounded simulation semantics.
- Bridge Agent: ModelValidityReport and ScenarioComparisonReport profiles.
```
