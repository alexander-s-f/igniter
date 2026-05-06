# Igniter-Lang Modeling Methodologies Pressure

Status: meta thesis
Date: 2026-05-06
Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/modeling-methodologies-pressure.md`
Depends on: `igniter-lang/docs/applied-pressure-directions.md`
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Claim

[D] Sandbox / simulation pressure should not start from one algorithm such as
genetic search. Igniter-Lang needs a more fundamental modeling frame:

```text
WorldModel
  + AssumptionSet
  + ParameterSet
  + Intervention
  + SimulationHorizon
  + EvaluationCriteria
  -> ScenarioRun
  -> SyntheticObservation
  -> ComparisonReport
  -> StrategyCandidate
```

Optimization methods, including genetic algorithms, sit above this frame as
search strategies over model-safe candidate contracts.

[D] Two modeling methodologies should receive priority pressure:

```text
Digital Twin
  -> living model calibrated by real observations

Agent-Based Modeling
  -> many agents with behavior rules interacting over simulated time
```

These are especially aligned with Igniter-Lang because both demand explicit
time, evidence, assumptions, calibration, and clear separation between real and
synthetic observations.

## Modeling Method Taxonomy

### Digital Twin

Purpose: maintain a live model of a real system, continuously calibrated by
observations.

```text
real observations
  -> calibration
  -> current model state
  -> scenario simulation
  -> prediction
  -> compare prediction to later reality
  -> model validity update
```

Best pressure domains:

- Spark CRM operations;
- technician capacity and utilization;
- lead acceptance and conversion;
- telephony/operator availability;
- home-lab / cluster health;
- supply chain and operations monitoring.

Igniter-Lang fit:

- real observations already have ObsPacket-like shape;
- calibration can be a contract;
- model validity can be a CompatibilityReport-like surface;
- prediction vs reality can produce a drift report;
- TBackend can store real and synthetic histories separately.

Candidate vocabulary:

```text
DigitalTwinModel
CalibrationEvidence
ModelStateSnapshot
PredictionObservation
RealityComparisonReport
ModelValidityReport
ModelDriftReceipt
```

Guardrail:

[X] A digital twin is not the real system. It is a calibrated semantic model
with explicit validity windows and drift evidence.

### Agent-Based Modeling

Purpose: model a system as interacting agents with local rules.

```text
AgentPopulation
  + BehaviorRules
  + Environment
  + InteractionProtocol
  + SimulatedTime
  -> EmergentOutcomes
```

Best pressure domains:

- customers, dispatchers, technicians, vendors, operators;
- biological cells/organisms;
- markets and competitors;
- epidemiology and policy;
- logistics and routing;
- social/information spread.

Igniter-Lang fit:

- each agent can be contract-addressable;
- behavior rules can be contracts;
- interactions can emit synthetic observations;
- scenario runs can be checkpointed and replayed;
- emergent outcomes can be compared to real observations for calibration.

Candidate vocabulary:

```text
AgentType
AgentInstance
BehaviorRule
InteractionEvent
EnvironmentState
AgentPopulationSnapshot
EmergentMetric
SyntheticInteractionObservation
```

Guardrail:

[X] Agent behavior rules are model assumptions unless calibrated by evidence.
They must not be treated as observed human/customer/technician truth.

### Discrete Event Simulation

Purpose: model a system as a sequence of timestamped events.

Good for:

- dispatch;
- queues;
- scheduling;
- telephony;
- job lifecycle;
- capacity planning.

Igniter-Lang fit:

```text
EventObservation
  -> StateTransition
  -> ScenarioTimeline
  -> SyntheticReceipt
```

This is likely the smallest executable simulation proof after technician
availability fixtures.

### System Dynamics

Purpose: model stocks, flows, feedback loops, and delays.

Good for:

- demand/capacity;
- cashflow;
- market growth;
- resource depletion;
- epidemiology;
- population dynamics.

Igniter-Lang pressure:

- continuous quantities need typed numeric semantics;
- feedback loops need bounded simulation steps;
- time granularity must be explicit.

### Causal Modeling

Purpose: distinguish prediction from intervention.

```text
observe X and Y
  !=
intervene do(X = x) and predict Y
```

Good for:

- strategy;
- policy;
- medical and treatment reasoning;
- business experiments;
- pricing and staffing interventions.

Igniter-Lang pressure:

- intervention must be distinct from observation;
- assumptions must be explicit;
- counterfactual output must be typed separately from fact.

### Monte Carlo Simulation

Purpose: run many scenario samples under uncertainty.

Good for:

- risk ranges;
- uncertain demand;
- job duration variability;
- failure probabilities;
- financial forecasts.

Igniter-Lang pressure:

- random seed and sampling policy must be explicit;
- result is a distribution, not a single fact;
- confidence/interval output must remain synthetic/forecast evidence.

### Optimization And Operations Research

Purpose: search for best feasible decisions under constraints.

Good for:

- scheduling;
- routing;
- assignment;
- staffing;
- resource allocation;
- pricing with constraints.

Methods:

- linear programming;
- integer programming;
- constraint programming;
- dynamic programming;
- heuristic search.

Igniter-Lang pressure:

- solver calls are ESCAPE unless proven CORE-bounded;
- feasibility certificates or solver receipts are required;
- recommended strategy is not approved action.

### Genetic Algorithms Over Contract Candidates

Purpose: explore large, discrete, irregular strategy spaces.

```text
Population[PolicyCandidateContract]
  -> classify/typecheck each candidate
  -> simulate
  -> score
  -> select
  -> mutate/recombine
  -> repeat
```

[D] Genetic algorithms are valid as a search strategy, not as the modeling
foundation.

Good for:

- policy search where gradients are unavailable;
- mixed discrete rules;
- large strategy spaces;
- "good enough" candidate discovery.

Risks:

- hard-to-explain candidates;
- overfitting to the simulator;
- invalid mutations;
- unsafe optimized policies;
- fitness functions that encode the wrong goal.

Igniter-Lang rule:

```text
optimized_candidate != approved_policy
simulation_success != production truth
```

Every candidate contract must still pass classification, typing, capability,
and safety checks before it can be simulated or proposed.

### Bayesian Modeling

Purpose: update beliefs as evidence arrives.

Good for:

- demand estimation;
- conversion forecasts;
- uncertainty-aware strategy;
- medical and scientific inference.

Igniter-Lang pressure:

- prior/posterior must be evidence-linked;
- confidence must be typed carefully;
- probability should not become unbounded arbitrary computation in v0.

### Game Theory

Purpose: model strategic actors that react to each other.

Good for:

- market competition;
- vendor behavior;
- pricing;
- adversarial OSINT;
- negotiation.

Igniter-Lang pressure:

- agent assumptions must be explicit;
- equilibrium claims must link to model and solver evidence;
- strategic outputs remain synthetic/counterfactual unless observed.

## Preferred Initial Stack

[R] For Igniter-Lang, start simulation pressure with this layered stack:

```text
1. Discrete Event Simulation
   Smallest operational proof: events -> state transitions -> synthetic receipts.

2. Digital Twin
   Calibrate a living model with real observations, then compare prediction to reality.

3. Agent-Based Modeling
   Add contract-addressable agents and behavior rules.

4. Search Strategies
   Add optimization, Monte Carlo, Bayesian optimization, or genetic search over
   typed scenario/policy candidates.
```

This ordering keeps the trust boundary clear while still allowing ambitious
world modeling later.

## Spark CRM First Simulation Candidate

Spark provides a concrete first sandbox:

```text
WorldModel: SparkAvailabilityBusiness
Agents:
  - CustomerLead
  - Technician
  - DispatcherPolicy
  - VendorPolicy
Environment:
  - company workday
  - service zones
  - demand distribution
  - job duration distribution
Parameters:
  - technician_count
  - availability_threshold
  - workday hours
  - lead acceptance policy
Interventions:
  - add technicians
  - change threshold
  - shift workday
  - change bidding policy
Outputs:
  - accepted lead rate
  - available slots
  - utilization
  - missed demand
  - conflict count
  - forecast confidence
```

Minimal fixture:

```text
baseline scenario
  vs intervention: add one technician
  -> synthetic lead acceptance outcomes
  -> capacity comparison report
  -> strategy candidate
```

The fixture must include:

- assumptions;
- parameter set;
- random seed or deterministic event list;
- simulation horizon;
- synthetic observations;
- comparison report;
- explicit statement that outputs are not real observations.

## Trust Boundaries

[D] Observation kinds must distinguish reality from model output:

```text
RealObservation
RuntimeObservation
SyntheticObservation
ForecastObservation
CounterfactualObservation
CalibrationObservation
ComparisonReport
StrategyCandidate
```

[D] A strategy candidate must carry:

- model ref;
- scenario ref;
- assumptions ref;
- parameter set ref;
- evaluation criteria;
- synthetic outcome refs;
- uncertainty or sensitivity summary;
- known invalidity conditions.

[X] Strategy candidates do not authorize production action. They can be
reviewed, compared, and promoted only through a human/agent approval contract
with receipts.

## Formal Questions

[Q] Are synthetic/forecast/counterfactual observations distinct observation
kinds, or should they be trust classes on one observation type?

[Q] Should a `WorldModel` be a contract, a module, or a separate artifact
loaded by RuntimeMachine?

[Q] Can agent behavior rules be ordinary contracts over agent state and
environment state?

[Q] What is the smallest bounded simulation loop that can remain CORE?

[Q] When does a simulation engine become ESCAPE, and what receipt does it need?

[Q] Can calibration reuse `CompatibilityReport`, or does it need
`ModelValidityReport`?

[Q] Should genetic recombination of contracts be allowed only over declared
variation points?

## Handoff

[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/modeling-methodologies-pressure.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Digital Twin and Agent-Based Modeling are priority modeling pressure methodologies.
- Genetic algorithms are a search strategy over typed policy/contract candidates, not the modeling foundation.
- Simulation outputs must be typed separately from real/runtime observations.

[R] Recommendations:
- Research Agent should start with a small Spark discrete-event/digital-twin fixture before broad agent populations.
- Compiler/Grammar Expert should formalize observation trust kinds and bounded simulation loop rules after fixture pressure.
- Bridge Agent should wait for model fixtures before mapping simulation reports to platform UI/diagnostics.

[S] Signals:
- Digital Twin aligns strongly with TBackend, SemanticImage, CompatibilityReport, and observation evidence.
- Agent-Based Modeling aligns with contract-addressable entities and behavior contracts.
- Optimization/search should sit above scenario semantics.

[T] Tests / Proofs:
- Documentation-only meta thesis; no tests were run.

[Files] Changed:
- `igniter-lang/docs/modeling-methodologies-pressure.md`
- `igniter-lang/docs/README.md`

[Q] Open Questions:
- Should the first simulation proof be deterministic discrete-event or stochastic Monte Carlo?
- Should Spark simulation begin from technician availability or lead signal acceptance?
- What is the smallest useful `ModelValidityReport`?

[X] Rejected:
- No treating genetic algorithms as the core language model.
- No treating simulation success as production truth.
- No unbounded probabilistic semantics in v0.

[Next] Proposed next slice:
- `[Igniter-Lang Applied Pressure Agent]` `spark-digital-twin-simulation-pressure-v0`.
- `[Igniter-Lang Applied Pressure Agent]` `agent-based-modeling-contracts-pressure-v0`.
