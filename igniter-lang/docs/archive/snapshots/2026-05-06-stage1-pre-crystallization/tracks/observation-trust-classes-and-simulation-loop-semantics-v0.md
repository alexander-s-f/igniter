# Track: Observation Trust Classes and Simulation Loop Semantics v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/observation-trust-classes-and-simulation-loop-semantics-v0
Status: done
Date: 2026-05-06
Pressure source: world-modeling, counterfactual planning, simulation contracts

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — fixture acceptance criteria in §Part 6.
- `[Igniter-Lang Bridge Agent]` — trust boundary implications in §Part 7.

---

## Part 1: Observation Trust Classes

### Decision: trust_class field, not separate obs kinds

**[D] Trust class is a field on every ObsPacket, not a new observation kind.**

```text
ObsPacket.trust_class:
  :real           -- observed from a live, authoritative source at as_of
  :runtime        -- produced by the RuntimeMachine during contract evaluation
  :synthetic      -- hand-authored or fixture-generated; no live source
  :forecast       -- projected future state; not yet observed
  :counterfactual -- what-if: describes a world that did NOT happen
```

Rationale: all five classes share the same lifecycle, link, and observation spine. Separate kinds would replicate structure for no semantic gain. Trust class is an orthogonal dimension.

### Trust class definitions

```text
RealObservation (trust_class: :real):
  - Sourced from a live TBackend read at a declared as_of.
  - Subject to scope rules (TenantScope, CardinalityBound).
  - May satisfy audit evidence requirements.
  - May satisfy policy check requirements.

RuntimeObservation (trust_class: :runtime):
  - Emitted by the RuntimeMachine during contract evaluation.
  - Includes value_observations, step_observations, snapshot_observations.
  - Lifecycle: :session, :window, :durable, or :audit per node declaration.
  - May satisfy operational evidence requirements.

SyntheticObservation (trust_class: :synthetic):
  - Hand-authored, fixture-generated, or test-scaffold data.
  - Must NOT satisfy :real or :audit evidence requirements.
  - May be used in simulation loops and world models.
  - Must carry synthetic_source: String (fixture_id or test_name).

ForecastObservation (trust_class: :forecast):
  - Projects a future state under a declared model.
  - Must carry forecast_horizon: Timestamp and model_ref: String.
  - Must NOT be used as :real evidence for action authorization.
  - May be consumed by ComparisonReport contracts.

CounterfactualObservation (trust_class: :counterfactual):
  - Describes a world branch that was NOT actualized.
  - Produced by counterfactual contracts (what-if analysis).
  - Must NOT satisfy :real, :runtime, or :audit evidence requirements.
  - Must carry scenario_id: String and divergence_point_ref: ObsId.
```

---

## Part 2: Evidence Satisfaction Rules

```text
Evidence requirement    Satisfied by trust_class
-------------------------------------------------
:real evidence          :real only
:audit evidence         :real, :runtime (lifecycle :audit) only
:operational evidence   :real, :runtime
:simulation evidence    :synthetic, :forecast, :counterfactual, :runtime
:review evidence        any trust_class (human review consumes all classes)
```

**[D] The evidence satisfaction table is enforced at classifier Pass 0.** A node that declares it requires `:real` evidence and receives a `:synthetic` observation is OOF-TR1 (trust class violation).

**[D] Trust class does not downgrade automatically.** A `:real` observation that feeds into a counterfactual analysis does not become `:counterfactual`. The output of a counterfactual contract is tagged `:counterfactual` regardless of its inputs' trust class.

---

## Part 3: Bounded Simulation Loop CORE Criteria

A simulation loop is CORE if and only if all five criteria hold:

```text
SC-1: Static max_steps
  max_steps is a literal Integer declared at the loop declaration site.
  Dynamic max_steps (from TBackend read or input port) -> ESCAPE.

SC-2: Deterministic event list OR explicit randomness policy
  Either:
    (a) The event sequence is a declared Collection[Event] (bounded, immutable), OR
    (b) A RandomnessPolicy is declared: { algorithm, seed_ref, max_draws: Integer }
  Ambient PRNG without seed_ref -> OOF-SL1.

SC-3: No ambient live stream
  The simulation loop may not read from a live TBackend stream inside the loop body.
  A snapshot of live data taken BEFORE the loop begins is permitted (one read, :durable).
  Live reads inside the loop body -> OOF-SL2.

SC-4: Immutable step state
  The state passed between steps must be a value type (record or primitive).
  Mutable reference passing (pointer semantics) -> OOF-SL3.
  In practice: the step function signature is (State, Event) -> State.

SC-5: Bounded output collection
  The simulation produces a Collection[StepResult] with max cardinality = max_steps.
  Unbounded output -> OOF-SL4.
```

### SimulationLoop declaration shape

```text
simulation_loop <Name> {
  max_steps    <IntLit>
  events       <Ref>               -- Collection[Event], pre-loaded before loop
  initial_state <Ref>              -- State value
  step_fn      <def_ref>           -- (State, Event) -> StepResult
  randomness   <policy_ref>?       -- RandomnessPolicy | omitted if deterministic
}

SimulationLoop lowers to a bounded fold in SemanticIR:
  fold(events, initial_state, step_fn) with max_steps guard.
  fragment_class: CORE if SC-1..5 hold; ESCAPE otherwise.
```

### RandomnessPolicy shape

```text
RandomnessPolicy = {
  algorithm: :pcg64 | :xoshiro256 | :chacha20
  seed_ref:  ObsId   -- the observation that provides the seed value
  max_draws: Integer -- maximum random draws per simulation run
}
lifecycle: :session (policy is declared per simulation invocation)
```

---

## Part 4: Intervention Typing

**[D] An Intervention is a declared, typed input that modifies the simulation's initial conditions or step behaviour. It is NOT an observed mutation.**

```text
Intervention = {
  kind:           Symbol          -- :parameter_override, :event_injection, :state_patch
  target_ref:     String          -- which simulation variable is affected
  value:          Any             -- the intervention value
  justification:  String          -- human-readable reason
  authority_ref:  ObsId | nil     -- who authorized this intervention
}
trust_class: :counterfactual (an intervention always produces counterfactual outputs)
```

**[D] An intervention applied to a real simulation run produces a counterfactual branch.** The original run remains `:runtime`. The intervened branch is `:counterfactual`. They are linked by `divergence_point_ref`.

**[D] Intervention is not a TBackend write.** It modifies the simulation input record only. No TBackend mutation occurs. Fragment class remains CORE if the simulation loop is CORE.

---

## Part 5: ComparisonReport Consumption Rule

```text
ComparisonReport = {
  kind:          :comparison_report
  baseline_ref:  ObsId             -- :runtime or :real observation
  alternate_ref: ObsId             -- :forecast or :counterfactual observation
  delta:         Collection[Delta]  -- { field, baseline_val, alternate_val, diff }
  model_ref:     String
  trust_class:   :review           -- always :review (not actionable without acceptance)
}
lifecycle: :session
```

**[D] ComparisonReport is review-only.** It may NOT be used as:
- Authorization for an OperationExecutionReceipt (OOF-TR2)
- Evidence for a RetentionExecutionReceipt (OOF-TR3)
- Input to a policy check (ExecutableActionCheck) (OOF-TR4)

**[D] To consume a ComparisonReport for action, an `acceptance contract` must explicitly accept it:**

```text
contract ReviewAcceptance {
  input  report: ComparisonReport
  input  reviewer_ref: ObsId       -- who reviewed
  input  decision: :accept | :reject

  compute acceptance = build_acceptance(report, reviewer_ref, decision)

  output acceptance: ReviewAcceptanceReceipt  lifecycle :audit
}
```

Only `ReviewAcceptanceReceipt` (`:audit`, `:real` or `:runtime`) may feed downstream action authorization. The ComparisonReport itself may not.

---

## Part 6: OOF Rules and SemanticIR Gates

### OOF Rules

```text
OOF-TR1: Trust class violation — synthetic/forecast/counterfactual satisfying real/audit requirement.
  A node requiring :real or :audit evidence receives an observation with
  trust_class :synthetic, :forecast, or :counterfactual.
  -> Classify error (Pass 0).

OOF-TR2: ComparisonReport used as action authorization.
  ComparisonReport.trust_class (:review) fed to check_ref of ExecutableActionCheck.
  -> Classify error (Pass 0).

OOF-TR3: ComparisonReport used as retention dry-run coverage.
  -> Classify error (Pass 0).

OOF-TR4: ComparisonReport used as policy check input.
  -> Classify error (Pass 0).

OOF-SL1: Ambient randomness in simulation loop.
  Random values drawn without a declared RandomnessPolicy (no seed_ref, no algorithm).
  -> OOF (Law 6: ambient IO).

OOF-SL2: Live TBackend read inside simulation loop body.
  A read node inside the step_fn that touches a live TBackend stream.
  -> ESCAPE escalation + OOF if fragment_class was declared :core.

OOF-SL3: Mutable state in simulation step.
  step_fn receives or returns a mutable reference type (not a value record).
  -> Classify error (Pass 0): simulation steps must be pure value transforms.

OOF-SL4: Unbounded simulation output.
  SimulationLoop without declared max_steps literal.
  -> Parse error (max_steps required field) or Classify error.

OOF-SL5: Intervention applied to :real run without counterfactual tagging.
  An intervention modifies a simulation whose output trust_class remains :runtime.
  -> Classify error: intervention always produces :counterfactual output.
```

### SemanticIR Gates

```text
G-TR1: Every ObsPacket emitted by a simulation or counterfactual contract must carry trust_class.
G-TR2: trust_class must be one of the five declared values (no freeform strings).
G-TR3: SimulationLoop must carry max_steps (Integer literal) and events (Collection[Event] ref).
G-TR4: RandomnessPolicy must carry algorithm, seed_ref, max_draws — all required if randomness is used.
G-TR5: ComparisonReport must carry baseline_ref, alternate_ref, model_ref.
G-TR6: Intervention must carry kind, target_ref, value, justification.
```

---

## Part 7: Research Agent Acceptance Criteria

Reference fixture: `spark-simulation-trust-boundary-fixture-v0`

```text
Positive path (bounded CORE simulation):
  1. TechnicianAvailabilitySnapshot (trust_class: :real) — loaded before loop.
  2. SimulationLoop: max_steps: 7, events: Collection[SlotEvent] (pre-loaded).
  3. StepResult observations (trust_class: :runtime), 7 items.
  4. ComparisonReport: baseline=real snapshot, alternate=simulated forecast.
  5. ReviewAcceptanceReceipt: reviewer accepted the comparison.
  6. Only the ReviewAcceptanceReceipt may feed downstream action auth.

Negative cases:
  N1: ComparisonReport fed to ExecutableActionCheck.check_ref -> OOF-TR2.
  N2: SyntheticObservation used as :real evidence for availability check -> OOF-TR1.
  N3: SimulationLoop without max_steps -> OOF-SL4.
  N4: Random draw inside step_fn without RandomnessPolicy -> OOF-SL1.
  N5: Intervention applied; output trust_class remains :runtime -> OOF-SL5.
```

## Part 8: Bridge Implications

```text
BR-Trust: ObsPacket trust_class must be included in all Bridge metadata packets.
  Adapters that strip trust_class produce OOF-TR1-eligible observations.
  Bridge adapters must propagate trust_class from source to downstream packet.

BR-Simulation: Simulation loop outputs (trust_class: :runtime or :counterfactual)
  must not be forwarded to real-world action endpoints without a ReviewAcceptanceReceipt.
  Bridge rule: if packet.trust_class in [:counterfactual, :forecast] then
    require acceptance_receipt_ref before routing to action endpoint.

BR-ComparisonReport: ComparisonReport packets are review-only.
  Bridge adapters must not route them to action or policy check endpoints.
  They may be routed to review dashboards and human-readable diagnostic surfaces.
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/observation-trust-classes-and-simulation-loop-semantics-v0
Status: done

[D] Decisions:
- trust_class is a field on ObsPacket, not a separate observation kind.
  Five classes: :real, :runtime, :synthetic, :forecast, :counterfactual.
- Evidence satisfaction table enforced at classifier Pass 0.
  :real evidence satisfied only by :real trust_class.
  :audit evidence satisfied by :real + :runtime(:audit lifecycle) only.
- Simulation loop CORE criteria: SC-1..5 (static max_steps, deterministic or
  declared randomness, no live stream inside loop, immutable state, bounded output).
- RandomnessPolicy required when any random draw occurs: algorithm + seed_ref + max_draws.
- Intervention is typed input, not mutation. Produces :counterfactual output always.
- ComparisonReport is review-only (:review trust_class). Cannot authorize actions,
  retention, or policy checks (OOF-TR2/3/4).
- ReviewAcceptanceReceipt (:audit) is the correct downstream consumer of a ComparisonReport.
- 9 OOF rules: OOF-TR1..4, OOF-SL1..5.
- 6 SemanticIR gates: G-TR1..6.

[Files] Changed:
- igniter-lang/docs/tracks/observation-trust-classes-and-simulation-loop-semantics-v0.md [NEW]
- igniter-lang/docs/README.md  [updated]
- igniter-lang/docs/agent-motion.md  [updated]

[Next]:
- [Research Agent]: spark-simulation-trust-boundary-fixture-v0
  Implement the fixture per §Part 7.
- [Compiler/Grammar Expert]: simulation-loop-grammar-v0
  Add simulation_loop declaration to the parser grammar.
  Target: simulation_contract.ig parses cleanly with max_steps, events, step_fn.
- [Bridge Agent]: update metadata adapter spec to propagate trust_class field
  in all outbound observation packets (BR-Trust).
```
