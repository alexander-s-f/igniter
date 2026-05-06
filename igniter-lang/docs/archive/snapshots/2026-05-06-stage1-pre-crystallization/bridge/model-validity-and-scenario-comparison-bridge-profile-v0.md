# Model Validity And Scenario Comparison Bridge Profile v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `igniter-lang/model-validity-and-scenario-comparison-bridge-profile-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Applied Pressure Agent]`

## Purpose

Prepare metadata-only bridge profiles for simulation/world-modeling outputs.

This bridge note does not authorize platform UI work, package edits, production
decisions, operational actions, provider adapters, or real-data simulation
claims.

## Current Horizon

- Simulation output is not real observation.
- Counterfactual improvement is strategy pressure, not action authority.
- Model validity is not runtime compatibility.
- Reproducible simulation can still be invalid for reality.
- Strategy candidates are review-only until a separate operation/action
  contract consumes them.

## Source Signals

[S] `sandbox-simulation-world-modeling-fixture-v0` is executable and synthetic.
It proves:

```text
WorldModel
  + AssumptionSet(calibration_status: none_sandbox_unvalidated)
  + ParameterSet(technician_count: 1)
  + ParameterSet(technician_count: 2)
  + Intervention(technician_count 1 -> 2)
  + bounded deterministic event list
  -> ScenarioRun(baseline)
  -> ScenarioRun(add-one-technician)
  -> SyntheticObservation x6
  -> CounterfactualObservation x6
  -> ScenarioComparisonReport
  -> ModelValidityReport(status: unvalidated_synthetic)
```

[S] The proof passes trust-boundary checks:

```text
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
```

[S] `sandbox-simulation-world-modeling-pressure-v0` fixes the semantic
guardrail:

```text
simulation_success != production truth
counterfactual_improvement != authorized operational action
```

## Bridge Claim

[D] Simulation/world-modeling outputs may move toward platform work only as
metadata-only diagnostics and reports:

```text
WorldModel descriptor
  + AssumptionSet
  + ParameterSet(s)
  + SimulationHorizon
  -> SimulationRunDiagnostic
  -> ScenarioComparisonReport
  -> ModelValidityReport
  -> StrategyCandidate(review_only)
```

[D] These profiles can support review and explanation. They must not authorize
staffing, scheduling, execution, provider calls, or real-world claims.

## Observation Trust Classes

```json
{
  "profile": "simulation_observation_trust_v0",
  "classes": {
    "RealObservation": {
      "meaning": "evidence about the actual world under temporal scope",
      "may_authorize_production_action": "only through separate policy/action contracts"
    },
    "SyntheticObservation": {
      "meaning": "model-generated event or state inside a scenario run",
      "may_authorize_production_action": false
    },
    "ForecastObservation": {
      "meaning": "synthetic prediction about future time under assumptions",
      "may_authorize_production_action": false
    },
    "CounterfactualObservation": {
      "meaning": "synthetic outcome under an intervention that did not happen",
      "may_authorize_production_action": false
    }
  },
  "blocked_reuse": [
    "SyntheticObservation as RealObservation",
    "CounterfactualObservation as audit fact",
    "ForecastObservation without model, assumption, parameter, and horizon refs"
  ]
}
```

## JSON Shape Examples

### SimulationRunDiagnostic

```json
{
  "diagnostic_id": "simulation_run/diagnostic/baseline-20260507",
  "profile": "simulation_run_diagnostic_v0",
  "scenario_run_ref": "scenario_run/dispatch-capacity/baseline/20260507",
  "scenario_ref": "scenario/dispatch-capacity/baseline@1",
  "world_model_ref": "world_model/spark-like-dispatch-capacity@0.1.0",
  "assumption_set_ref": "assumptions/dispatch-capacity/synthetic-simple@1",
  "parameter_set_ref": "params/dispatch-capacity/baseline@1",
  "intervention_ref": null,
  "observation_kind": "SyntheticObservation",
  "simulation_horizon": "2026-05-07T09:00:00-04:00..2026-05-07T17:00:00-04:00",
  "boundedness": {
    "max_steps": 6,
    "event_count": 6,
    "step_bound_source": "deterministic_event_list.count",
    "bounded": true
  },
  "randomness": {
    "model_kind": "deterministic_discrete_event",
    "deterministic_seed": "none",
    "randomness_policy_ref": "not_applicable_deterministic"
  },
  "summary": {
    "accepted_job_count": 4,
    "missed_job_count": 2,
    "conflict_count": 2,
    "available_technician_slots": 4,
    "used_technician_slots": 4,
    "technician_slot_utilization": "1.00"
  },
  "evidence_links": {
    "world_model_descriptor_ref": "obs/world-model-descriptor",
    "assumption_set_descriptor_ref": "obs/assumption-set-descriptor",
    "parameter_set_descriptor_ref": "obs/baseline-parameter-set",
    "event_observation_refs": [
      "obs/synthetic/baseline/j-001",
      "obs/synthetic/baseline/j-002",
      "obs/synthetic/baseline/j-003",
      "obs/synthetic/baseline/j-004",
      "obs/synthetic/baseline/j-005",
      "obs/synthetic/baseline/j-006"
    ]
  },
  "diagnostics": [],
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "review_only": true,
    "may_authorize_production_action": false,
    "platform_ui_authorized": false,
    "package_edit_authorized": false,
    "ledger_core": false
  }
}
```

Blocked simulation diagnostics use the same profile with:

```json
{
  "status": "blocked",
  "diagnostics": [
    {
      "code": "simulation.unbounded_loop_oof",
      "severity": "error",
      "fragment_class": "OOF",
      "message": "ScenarioRun requires a static max_steps bound."
    }
  ]
}
```

### ScenarioComparisonReport

```json
{
  "report_id": "comparison/dispatch-capacity/baseline-vs-add-one-tech@1",
  "profile": "scenario_comparison_report_v0",
  "comparison_kind": "counterfactual",
  "baseline_run_ref": "scenario_run/dispatch-capacity/baseline/20260507",
  "comparison_run_ref": "scenario_run/dispatch-capacity/add-one-technician/20260507",
  "baseline_observation_kind": "SyntheticObservation",
  "comparison_observation_kind": "CounterfactualObservation",
  "metrics": {
    "accepted_job_count_delta": 2,
    "missed_job_count_delta": -2,
    "conflict_count_delta": -2,
    "utilization_delta": "-0.25"
  },
  "interpretation": [
    "add-one-technician removes all synthetic capacity misses",
    "added capacity reduces utilization from 1.00 to 0.75",
    "result is strategy pressure, not action authority"
  ],
  "trust_status": "synthetic_counterfactual",
  "evidence_links": {
    "baseline_run_report_ref": "simulation_run/diagnostic/baseline-20260507",
    "comparison_run_report_ref": "simulation_run/diagnostic/add-one-technician-20260507",
    "model_validity_report_ref": "model_validity/dispatch-capacity/synthetic-simple@1"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "review_only": true,
    "may_authorize_production_action": false,
    "may_be_used_as_audit_fact": false,
    "may_be_used_as_real_forecast": false,
    "platform_ui_authorized": false,
    "package_edit_authorized": false,
    "ledger_core": false
  }
}
```

### ModelValidityReport

```json
{
  "report_id": "model_validity/dispatch-capacity/synthetic-simple@1",
  "profile": "model_validity_report_v0",
  "world_model_ref": "world_model/spark-like-dispatch-capacity@0.1.0",
  "assumption_set_ref": "assumptions/dispatch-capacity/synthetic-simple@1",
  "validity_policy_ref": "model_validity_policy/sandbox-unvalidated@1",
  "calibration": {
    "calibration_status": "none_sandbox_unvalidated",
    "calibration_evidence_refs": [],
    "validation_window": null
  },
  "status": "unvalidated_synthetic",
  "allowed_uses": [
    "language_fixture",
    "scenario_comparison_shape",
    "trust_boundary_pressure"
  ],
  "forbidden_uses": [
    "production_staffing_decision",
    "real_capacity_forecast",
    "customer_or_employee_claim",
    "operation_authorization"
  ],
  "diagnostics": [],
  "evidence_links": {
    "world_model_descriptor_ref": "obs/world-model-descriptor",
    "assumption_set_descriptor_ref": "obs/assumption-set-descriptor"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "review_only": true,
    "may_authorize_production_action": false,
    "validated_for_reality": false,
    "platform_ui_authorized": false,
    "package_edit_authorized": false,
    "ledger_core": false
  }
}
```

Validity overclaim uses the same profile with:

```json
{
  "status": "blocked",
  "diagnostics": [
    {
      "code": "model_validity.calibration_evidence_missing",
      "severity": "error",
      "attempted_status": "validated",
      "allowed_status": "unvalidated_synthetic"
    }
  ]
}
```

### AssumptionParameterDiff

```json
{
  "diff_id": "assumption_parameter_diff/dispatch-capacity/add-one-tech@1",
  "profile": "assumption_parameter_diff_v0",
  "world_model_ref": "world_model/spark-like-dispatch-capacity@0.1.0",
  "assumption_set_ref": "assumptions/dispatch-capacity/synthetic-simple@1",
  "baseline_parameter_set_ref": "params/dispatch-capacity/baseline@1",
  "comparison_parameter_set_ref": "params/dispatch-capacity/add-one-technician@1",
  "intervention_ref": "intervention/add-one-technician@1",
  "parameter_diffs": [
    {
      "parameter": "technician_count",
      "from_value": 1,
      "to_value": 2,
      "unit": "integer_count",
      "diff_kind": "capacity_change"
    }
  ],
  "unchanged_parameters": [
    "workday_slots",
    "assignment_policy"
  ],
  "assumption_warnings": [
    "travel time ignored",
    "technicians equally skilled",
    "demand events deterministic and predeclared",
    "calibration evidence empty"
  ],
  "evidence_links": {
    "baseline_parameter_set_ref": "obs/baseline-parameter-set",
    "comparison_parameter_set_ref": "obs/intervention-parameter-set",
    "intervention_descriptor_ref": "obs/intervention-add-one-technician"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "review_only": true,
    "may_authorize_production_action": false,
    "parameter_mutation_authorized": false,
    "platform_ui_authorized": false,
    "package_edit_authorized": false,
    "ledger_core": false
  }
}
```

### StrategyCandidate

```json
{
  "candidate_id": "strategy_candidate/dispatch-capacity/add-one-tech@1",
  "profile": "strategy_candidate_review_only_v0",
  "source_report_ref": "comparison/dispatch-capacity/baseline-vs-add-one-tech@1",
  "source_diff_ref": "assumption_parameter_diff/dispatch-capacity/add-one-tech@1",
  "candidate_kind": "capacity_strategy",
  "summary": "Review whether adding one technician could reduce synthetic missed-capacity events.",
  "supporting_synthetic_metrics": {
    "accepted_job_count_delta": 2,
    "missed_job_count_delta": -2,
    "conflict_count_delta": -2
  },
  "required_before_action": [
    "real calibration evidence",
    "human review",
    "separate operation/action policy check",
    "operation request or execution receipt"
  ],
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "review_only": true,
    "may_authorize_production_action": false,
    "may_create_operation_request": false,
    "may_execute_operation": false,
    "platform_ui_authorized": false,
    "package_edit_authorized": false,
    "ledger_core": false
  }
}
```

[D] `StrategyCandidate` is not an action plan. It is a review object. Any
future operational use must pass through separate action policy, capability,
request/execution receipt, and redaction semantics.

## Diagnostic Codes To Preserve

- `simulation.synthetic_observation_used_as_real`
- `simulation.counterfactual_not_audit_fact`
- `simulation.unbounded_loop_oof`
- `simulation.randomness_policy_missing`
- `model_validity.calibration_evidence_missing`

## Package Touchpoint Recommendation

[R] First package touchpoint, if Architect approves:

```text
packages/igniter-contracts/
  Igniter::Lang::VerificationReport
  optional generic simulation diagnostics / model validity payload section
```

Recommended first package surface:

```text
Igniter::Lang::SimulationDiagnosticProfile
```

or, for the smallest package change:

```text
VerificationReport#metadata[:simulation_diagnostics]
VerificationReport#metadata[:model_validity_reports]
VerificationReport#metadata[:scenario_comparison_reports]
```

Why first:

- `igniter-contracts` already carries report-only Lang metadata and diagnostic
  precedent.
- Simulation reports can stay package-neutral and non-authorizing.
- It keeps platform UI, operational actions, Ledger, and real-data adapters out
  of the first package slice.

Not first:

- Platform UI: blocked by this bridge profile.
- `packages/igniter-application`: may later consume review-only reports, but
  should not own simulation semantics first.
- `packages/igniter-ledger` / Ledger clients: may later transport durable
  report refs as a TBackend adapter, but must not become language core.
- Spark-specific package namespaces: blocked.

## Explicit Non-Authorization Semantics

[D] Every profile in this note carries:

```json
{
  "report_only": true,
  "runtime_enforced": false,
  "review_only": true,
  "may_authorize_production_action": false,
  "platform_ui_authorized": false,
  "package_edit_authorized": false,
  "ledger_core": false
}
```

[X] This bridge does not authorize:

- platform UI work
- package edits
- real-data simulation adapters
- staffing, scheduling, dispatch, or customer-impacting actions
- using synthetic/counterfactual/forecast output as real observation
- using counterfactual output as audit fact
- unbounded CORE simulation loops
- stochastic simulation without seed or sampling policy evidence
- treating Ledger as required language core

## Package Agent Approval / Blocker Note

[R] Package Agent may start only after explicit Architect Supervisor approval.
The approved package slice should be generic, metadata-only, report-only, and
non-authorizing.

[X] Package Agent is blocked from:

- editing packages from this bridge slice
- adding platform simulation UI
- creating Spark-specific public package classes
- implementing simulation engines, solvers, stochastic sampling, or provider
  adapters
- converting StrategyCandidate into an operation request or execution
- serializing real customer/order/provider-like data in these profiles
- treating synthetic/counterfactual/forecast observations as real evidence
- treating Ledger as language core

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/model-validity-and-scenario-comparison-bridge-profile-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent | Applied Pressure Agent

[D] Decisions:
- Mapped executable sandbox simulation fixture outputs into metadata-only bridge profiles.
- Defined JSON shapes for SimulationRunDiagnostic, ScenarioComparisonReport, ModelValidityReport, AssumptionParameterDiff, and StrategyCandidate.
- Distinguished RealObservation from SyntheticObservation, ForecastObservation, and CounterfactualObservation.
- Kept StrategyCandidate review-only and non-action-authorizing.
- Added explicit non-authorization semantics for platform UI, package edits, production action, and Ledger-as-core.

[R] Recommendations:
- First package touchpoint, after Architect approval, should be packages/igniter-contracts as a generic report-only simulation diagnostics/model validity carrier.
- Prefer VerificationReport metadata sections for smallest package surface, or Igniter::Lang::SimulationDiagnosticProfile if a standalone class is approved.
- Keep platform UI and application action flow as later consumers only.

[S] Signals:
- sandbox_simulation_world_modeling_fixture.rb passes model descriptor, boundedness, metrics, deltas, unvalidated validity, trust-boundary negatives, and synthetic-only safety.
- Reproducible simulation can still be invalid for reality.
- Counterfactual improvement is strategy pressure, not action authority.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/sandbox_simulation_world_modeling_fixture/sandbox_simulation_world_modeling_fixture.rb -> PASS.

[Files] Changed:
- igniter-lang/docs/bridge/model-validity-and-scenario-comparison-bridge-profile-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should first package work use VerificationReport metadata sections or a standalone SimulationDiagnosticProfile class?
- Should observation trust classes be separate packet kinds or policy fields on one observation envelope?
- What future review/action contract may consume StrategyCandidate without collapsing the trust boundary?

[X] Rejected:
- Platform UI or package edits in this slice.
- Simulation output as real observation.
- Counterfactual output as audit fact.
- StrategyCandidate as action authorization.
- Real-data simulation adapters, operational actions, unbounded CORE loops, and Ledger-as-core.

[Next] Proposed next slice:
- Architect-reviewed package plan for generic simulation diagnostics/model validity carriers in igniter-contracts.
```
