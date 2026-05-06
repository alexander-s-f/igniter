# Track: Sandbox Simulation World Modeling Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/sandbox-simulation-world-modeling-pressure-v0.md`
Status: done
Slice state: done on 2026-05-06
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track opens the first non-operational pressure lane for Igniter-Lang:
sandbox simulation and world modeling.

It starts from a Spark-like dispatch/capacity world, but the scenario is fully
synthetic. The goal is not to model Spark CRM production. The goal is to test
whether Igniter-Lang can represent a simulated world, run baseline vs
intervention scenarios, compare outcomes, and keep synthetic/counterfactual
evidence separate from facts.

Safety boundary:

- synthetic IDs only;
- no real Spark data, customers, tenants, employees, orders, endpoints,
  provider payloads, tokens, credentials, or infrastructure details;
- no production decision may be inferred from this fixture;
- simulation output is not real observation.

## Source Horizon

- `igniter-lang/docs/applied-pressure-directions.md`
- `igniter-lang/docs/modeling-methodologies-pressure.md`
- `igniter-lang/docs/tracks/spark-technician-availability-fixture-pressure-v0.md`
- `igniter-lang/docs/tracks/spark-lead-signal-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/spark-operation-action-lifecycle-pressure-v0.md`
- `igniter-lang/docs/proposals/PROP-013-stdlib-fold-aggregate-v0.md`
- `igniter-lang/docs/proposals/PROP-003-grammar-fragment-classification-v0.md`

## Compact Claim

[D] A simulation language lane must begin with a trust distinction:

```text
RealObservation          = evidence from the world
SyntheticObservation     = output generated inside a model
ForecastObservation      = synthetic output about future time under assumptions
CounterfactualObservation = synthetic output under an intervention that did not happen
```

[D] The first proof should be a bounded deterministic discrete-event scenario,
not stochastic modeling or optimization:

```text
WorldModel
  + AssumptionSet
  + ParameterSet
  + Intervention
  + SimulationHorizon
  -> ScenarioRun
  -> SyntheticObservation / CounterfactualObservation
  -> ComparisonReport
  -> ModelValidityReport
```

[D] The core guardrail:

```text
simulation_success != production truth
counterfactual_improvement != authorized operational action
```

## Vocabulary

### WorldModel

`WorldModel` is a contract-addressable model of a system boundary.

```text
WorldModel = {
  model_id,
  model_kind,
  modeled_system_boundary,
  state_schema_ref,
  event_schema_ref,
  transition_rules_ref,
  allowed_observation_kinds,
  validity_policy_ref
}
```

For this fixture:

```text
model_id: world_model/spark-like-dispatch-capacity@0.1.0
model_kind: :deterministic_discrete_event
modeled_system_boundary: :synthetic_dispatch_capacity
transition_rules_ref: transition_rules/slot_assignment@1
allowed_observation_kinds:
  - SyntheticObservation
  - CounterfactualObservation
  - ForecastObservation
```

### AssumptionSet

`AssumptionSet` records what the model assumes instead of observing.

```text
AssumptionSet = {
  assumption_set_id,
  model_ref,
  assumptions,
  invalidity_conditions,
  evidence_links
}
```

Fixture assumptions:

```text
assumption_set_id: assumptions/dispatch-capacity/synthetic-simple@1
assumptions:
  - all jobs have fixed two-hour duration
  - all technicians are equally skilled
  - travel time is ignored
  - customers accept any technician in the same slot
  - demand events are deterministic and predeclared
  - no cancellations occur
invalidity_conditions:
  - travel time matters
  - skills differ
  - appointment windows are flexible
  - demand distribution is calibrated from reality
evidence_links: []
```

[D] Empty evidence links are allowed only because this is a sandbox proof. They
force `ModelValidityReport.status = :unvalidated_synthetic`.

### ParameterSet

`ParameterSet` contains values varied between scenarios.

```text
ParameterSet = {
  parameter_set_id,
  model_ref,
  parameters,
  unit_policy,
  deterministic_seed
}
```

Baseline:

```text
parameter_set_id: params/dispatch-capacity/baseline@1
technician_count: 1
workday_slots:
  - 2026-05-07T09:00:00-04:00..2026-05-07T11:00:00-04:00
  - 2026-05-07T11:00:00-04:00..2026-05-07T13:00:00-04:00
  - 2026-05-07T13:00:00-04:00..2026-05-07T15:00:00-04:00
  - 2026-05-07T15:00:00-04:00..2026-05-07T17:00:00-04:00
assignment_policy: :first_available_technician
deterministic_seed: none
```

Intervention parameter set:

```text
parameter_set_id: params/dispatch-capacity/add-one-technician@1
technician_count: 2
workday_slots: same_as_baseline
assignment_policy: :first_available_technician
deterministic_seed: none
```

### Intervention

`Intervention` is not an observation. It is a deliberate counterfactual edit to
the scenario.

```text
Intervention = {
  intervention_id,
  kind,
  target_parameter,
  from_value,
  to_value,
  do_not_confuse_with_observation: true
}
```

Fixture intervention:

```text
intervention_id: intervention/add-one-technician@1
kind: :capacity_change
target_parameter: technician_count
from_value: 1
to_value: 2
```

## Observation Kind Boundary

| Kind | Source | Trust meaning | May authorize production action? |
|------|--------|---------------|----------------------------------|
| `RealObservation` | measured or imported real-world fact | evidence about actual world under temporal scope | only through policy/action contracts |
| `SyntheticObservation` | model-generated event or state | evidence about a scenario run only | no |
| `ForecastObservation` | model output about future time | synthetic prediction under assumptions | no |
| `CounterfactualObservation` | model output under intervention | synthetic outcome for a world that did not happen | no |

OOF rules for the fixture:

```text
OOF-SIM1: SyntheticObservation used as RealObservation.
OOF-SIM2: CounterfactualObservation linked as audit fact.
OOF-SIM3: ForecastObservation emitted without model, assumption, parameter,
          and horizon refs.
OOF-SIM4: ScenarioRun without bounded max_steps.
OOF-SIM5: Stochastic run without seed or sampling policy.
```

## Fixture Identity

All facts are synthetic.

```text
fixture_id: sandbox_simulation_world_modeling_minimal_v0
world_model_ref: world_model/spark-like-dispatch-capacity@0.1.0
baseline_scenario_ref: scenario/dispatch-capacity/baseline@1
intervention_scenario_ref: scenario/dispatch-capacity/add-one-technician@1
simulation_horizon: 2026-05-07T09:00:00-04:00..2026-05-07T17:00:00-04:00
timezone: America/New_York
time_step: event_driven
max_steps: 6
step_bound_source: deterministic_event_list.count
evaluation_criteria:
  - accepted_job_count
  - missed_job_count
  - technician_slot_utilization
  - conflict_count
```

## Synthetic Event List

The model receives a bounded deterministic list of six job requests. These are
synthetic demand events, not Spark orders or real leads.

```text
SyntheticJobRequest j-001:
  requested_slot: 2026-05-07T09:00:00-04:00..2026-05-07T11:00:00-04:00
  duration_slots: 1

SyntheticJobRequest j-002:
  requested_slot: 2026-05-07T09:00:00-04:00..2026-05-07T11:00:00-04:00
  duration_slots: 1

SyntheticJobRequest j-003:
  requested_slot: 2026-05-07T11:00:00-04:00..2026-05-07T13:00:00-04:00
  duration_slots: 1

SyntheticJobRequest j-004:
  requested_slot: 2026-05-07T11:00:00-04:00..2026-05-07T13:00:00-04:00
  duration_slots: 1

SyntheticJobRequest j-005:
  requested_slot: 2026-05-07T13:00:00-04:00..2026-05-07T15:00:00-04:00
  duration_slots: 1

SyntheticJobRequest j-006:
  requested_slot: 2026-05-07T15:00:00-04:00..2026-05-07T17:00:00-04:00
  duration_slots: 1
```

## Scenario Run A: Baseline

```text
ScenarioRun = {
  scenario_run_id: scenario_run/dispatch-capacity/baseline/20260507
  scenario_ref: scenario/dispatch-capacity/baseline@1
  world_model_ref: world_model/spark-like-dispatch-capacity@0.1.0
  assumption_set_ref: assumptions/dispatch-capacity/synthetic-simple@1
  parameter_set_ref: params/dispatch-capacity/baseline@1
  intervention_ref: null
  observation_kind: SyntheticObservation
  max_steps: 6
  status: :completed
}
```

Baseline expected events:

| Event | Slot | Technician capacity | Outcome | Observation kind |
|-------|------|---------------------|---------|------------------|
| `j-001` | 09-11 | 1 | accepted | `SyntheticObservation` |
| `j-002` | 09-11 | 1 | missed_capacity | `SyntheticObservation` |
| `j-003` | 11-13 | 1 | accepted | `SyntheticObservation` |
| `j-004` | 11-13 | 1 | missed_capacity | `SyntheticObservation` |
| `j-005` | 13-15 | 1 | accepted | `SyntheticObservation` |
| `j-006` | 15-17 | 1 | accepted | `SyntheticObservation` |

Baseline summary:

```text
accepted_job_count: 4
missed_job_count: 2
conflict_count: 2
available_technician_slots: 4
used_technician_slots: 4
technician_slot_utilization: 1.00
```

## Scenario Run B: Add One Technician

```text
ScenarioRun = {
  scenario_run_id: scenario_run/dispatch-capacity/add-one-technician/20260507
  scenario_ref: scenario/dispatch-capacity/add-one-technician@1
  world_model_ref: world_model/spark-like-dispatch-capacity@0.1.0
  assumption_set_ref: assumptions/dispatch-capacity/synthetic-simple@1
  parameter_set_ref: params/dispatch-capacity/add-one-technician@1
  intervention_ref: intervention/add-one-technician@1
  observation_kind: CounterfactualObservation
  max_steps: 6
  status: :completed
}
```

Intervention expected events:

| Event | Slot | Technician capacity | Outcome | Observation kind |
|-------|------|---------------------|---------|------------------|
| `j-001` | 09-11 | 2 | accepted | `CounterfactualObservation` |
| `j-002` | 09-11 | 2 | accepted | `CounterfactualObservation` |
| `j-003` | 11-13 | 2 | accepted | `CounterfactualObservation` |
| `j-004` | 11-13 | 2 | accepted | `CounterfactualObservation` |
| `j-005` | 13-15 | 2 | accepted | `CounterfactualObservation` |
| `j-006` | 15-17 | 2 | accepted | `CounterfactualObservation` |

Intervention summary:

```text
accepted_job_count: 6
missed_job_count: 0
conflict_count: 0
available_technician_slots: 8
used_technician_slots: 6
technician_slot_utilization: 0.75
```

## Comparison Report

```text
ComparisonReport = {
  report_id: comparison/dispatch-capacity/baseline-vs-add-one-tech@1
  baseline_run_ref: scenario_run/dispatch-capacity/baseline/20260507
  comparison_run_ref: scenario_run/dispatch-capacity/add-one-technician/20260507
  comparison_kind: :counterfactual
  metrics:
    accepted_job_count_delta: 2
    missed_job_count_delta: -2
    conflict_count_delta: -2
    utilization_delta: -0.25
  interpretation:
    - add-one-technician removes all synthetic capacity misses
    - added capacity reduces utilization from 1.00 to 0.75
    - result is strategy pressure, not action authority
  trust_status: :synthetic_counterfactual
}
```

## Model Validity Report

Because the fixture has no real calibration evidence, it must not claim real
predictive validity.

```text
ModelValidityReport = {
  report_id: model_validity/dispatch-capacity/synthetic-simple@1
  world_model_ref: world_model/spark-like-dispatch-capacity@0.1.0
  assumption_set_ref: assumptions/dispatch-capacity/synthetic-simple@1
  calibration_evidence_refs: []
  validation_window: null
  status: :unvalidated_synthetic
  allowed_uses:
    - language_fixture
    - scenario_comparison_shape
    - trust_boundary_pressure
  forbidden_uses:
    - production_staffing_decision
    - real_capacity_forecast
    - customer_or_employee_claim
}
```

[D] The comparison report may say the intervention improved the synthetic
scenario. The validity report must say this does not prove real-world staffing
value.

## Negative Cases

### SIM-1: Synthetic Observation Treated As Real

Input:

```text
observation_ref: synthetic/dispatch-capacity/baseline/j-001
declared_as: RealObservation
```

Expected:

```text
status: :blocked
diagnostic: simulation.synthetic_observation_used_as_real
comparison_report_status: :invalid
```

### SIM-2: Counterfactual Used As Audit Fact

Input:

```text
observation_ref: counterfactual/dispatch-capacity/add-one-tech/j-002
linked_to: operation_execution/real-world-placeholder
link_rel: :proves_actual_execution
```

Expected:

```text
status: :blocked
diagnostic: simulation.counterfactual_not_audit_fact
```

### SIM-3: Unbounded Scenario Loop

Input:

```text
scenario_run_id: scenario_run/unbounded
max_steps: null
event_source: live_stream
```

Expected:

```text
status: :blocked
diagnostic: simulation.unbounded_loop_oof
fragment_class: OOF
```

### SIM-4: Stochastic Run Without Seed

Input:

```text
model_kind: :monte_carlo
sample_count: 1000
random_seed: null
sampling_policy_ref: null
```

Expected:

```text
status: :blocked
diagnostic: simulation.randomness_policy_missing
fragment_class: ESCAPE_or_OOF
```

### SIM-5: Model Validity Overclaim

Input:

```text
calibration_evidence_refs: []
status: :validated
```

Expected:

```text
status: :blocked
diagnostic: model_validity.calibration_evidence_missing
```

## What Current Igniter-Lang Handles

- Contract-addressable observations can represent model inputs, synthetic
  events, scenario summaries, reports, and diagnostics.
- Explicit time and horizons already fit simulation horizons.
- `Collection[T]`, `fold`, `map`, and bounded aggregation from PROP-013 can
  express the deterministic event list and summary metrics.
- CORE / ESCAPE / OOF already gives a useful boundary:
  - deterministic bounded event simulation can be CORE candidate;
  - stochastic sampling and solver-backed optimization are ESCAPE unless
    bounded with receipts;
  - unbounded loops and live streams without bounds are OOF.
- `CompatibilityReport` and schema migration work provide a precedent for
  `ModelValidityReport`, but not a final design.

## Where Trust Boundaries Break

- Observation kinds are not yet formalized enough to prevent synthetic output
  from being reused as real evidence.
- `WorldModel` is not yet clearly a contract, module, artifact, or runtime
  loadable unit.
- Bounded simulation loops need a formal termination rule distinct from normal
  collection folds if state transitions are modeled step-by-step.
- Interventions need causal/counterfactual semantics; they are not just
  parameter edits.
- Model validity is not the same as runtime compatibility. A model can run
  reproducibly and still be invalid for reality.
- Strategy candidates need an approval boundary before becoming operational
  actions.

## Concrete Research Agent Fixture Request

Please implement a standalone fixture proof:

```text
track_request: sandbox_simulation_world_modeling_fixture_v0
suggested_dir: igniter-lang/experiments/sandbox_simulation_world_modeling_fixture/
inputs:
  - WorldModel descriptor
  - AssumptionSet with empty calibration evidence
  - baseline ParameterSet
  - add-one-technician ParameterSet
  - Intervention(add technician_count 1 -> 2)
  - bounded deterministic synthetic event list of six job requests
outputs:
  - baseline ScenarioRun
  - add-one-technician ScenarioRun
  - SyntheticObservation events for baseline
  - CounterfactualObservation events for intervention
  - ComparisonReport
  - ModelValidityReport(status: :unvalidated_synthetic)
  - golden negative diagnostics for SIM-1..SIM-5
checker:
  - validates max_steps equals event count
  - validates baseline accepted/missed/conflict/utilization metrics
  - validates intervention metrics
  - validates ComparisonReport deltas
  - validates ModelValidityReport does not claim real validity
  - rejects synthetic-as-real and counterfactual-as-audit links
safety:
  - synthetic facts only
  - no Spark data, endpoints, provider payloads, credentials, tokens, customer
    data, or infrastructure names
```

Proof acceptance:

- baseline accepts 4 jobs and misses 2;
- intervention accepts 6 jobs and misses 0;
- comparison reports `accepted_job_count_delta = 2`;
- all scenario outputs are synthetic/counterfactual, not real;
- model validity remains `:unvalidated_synthetic`;
- unbounded loops and missing randomness policy are blocked.

## Compiler/Grammar Expert Questions

1. Should `RealObservation`, `SyntheticObservation`, `ForecastObservation`,
   and `CounterfactualObservation` be distinct observation kinds, trust classes
   on `Obs[kind,T]`, or payload policies?
2. Should `WorldModel` be a contract, module, schema-backed artifact,
   `.igapp/` loadable unit, or RuntimeMachine-side descriptor?
3. What is the smallest formal bounded simulation loop that can classify as
   CORE: fold over event list, `simulate(max_steps)`, or a new transition
   operator?
4. Are stateful step transitions in a ScenarioRun allowed in CORE when state
   is immutable between steps and `max_steps` is static?
5. How should `Intervention` be typed so it cannot be confused with observed
   fact mutation?
6. Is `ForecastObservation` just a future-timestamped
   `SyntheticObservation`, or does it need its own kind because it makes a
   prediction claim?
7. Should `ModelValidityReport` reuse `CompatibilityReport` dimensions, or
   be a separate report over calibration, validation window, drift, and
   assumption coverage?
8. What OOF rule prevents a `ComparisonReport` from being consumed as
   operational authorization without a review/action contract?

## Bridge Agent Candidates

- `ModelValidityReport` bridge profile with calibration evidence refs,
  validation window, allowed uses, forbidden uses, and drift diagnostics.
- `ScenarioComparisonReport` profile for baseline vs intervention metrics,
  deltas, sensitivity notes, and trust status.
- `SimulationRunDiagnostic` profile for boundedness, seed/sampling policy,
  model version, assumption refs, parameter refs, and output observation kind.
- `AssumptionParameterDiff` profile for human-readable review of what changed
  between baseline and intervention.
- `StrategyCandidate` bridge candidate that can be reviewed but cannot execute
  production changes without a separate operation/action receipt.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/sandbox-simulation-world-modeling-pressure-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Opened the sandbox/simulation/world-modeling lane with a synthetic
  Spark-like discrete-event/digital-twin scenario.
- Defined WorldModel, ScenarioRun, AssumptionSet, ParameterSet, and
  Intervention as contract-addressable simulation artifacts.
- Separated RealObservation, SyntheticObservation, ForecastObservation, and
  CounterfactualObservation as trust boundary pressure.
- Fixed baseline vs add-one-technician as the first concrete comparison.

[R] Recommendations:
- Research Agent should implement the deterministic fixture before stochastic,
  optimization, or agent-population work.
- Compiler/Grammar Expert should formalize observation kinds/trust classes and
  bounded simulation loop semantics.
- Bridge Agent should draft ModelValidityReport and ScenarioComparisonReport
  profiles before any platform simulation UI is considered.

[S] Signals:
- Simulation aligns strongly with explicit time, observations, SemanticImage,
  TBackend histories, and comparison reports.
- Model validity is not runtime compatibility; reproducible simulation can
  still be invalid for reality.
- Interventions require causal/counterfactual typing, not ordinary mutation.

[T] Tests / Proofs:
- Not run; documentation/specification slice only.
- Requested Research Agent proof:
  `igniter-lang/experiments/sandbox_simulation_world_modeling_fixture/`.

[Files] Changed:
- igniter-lang/docs/tracks/sandbox-simulation-world-modeling-pressure-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Distinct observation kinds vs trust classes on one observation type?
- Is WorldModel a contract/module/artifact/runtime descriptor?
- What bounded simulation loop can remain CORE?
- How does a ComparisonReport stay non-authorizing until a review/action
  contract consumes it?

[X] Rejected:
- Treating simulation output as real observation.
- Treating counterfactual output as audit fact.
- Unbounded simulation loops in CORE.
- Production staffing/action decisions from an unvalidated synthetic model.

[Next] Proposed next slice:
- Research Agent: implement `sandbox_simulation_world_modeling_fixture_v0`.
- Compiler/Grammar Expert: formalize observation kinds and bounded simulation
  loop rules.
- Bridge Agent: draft ModelValidityReport and ScenarioComparisonReport bridge
  candidates.
```
