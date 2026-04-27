# Igniter in Science, Robotics, Space, and Medicine

*Validation report — critical and scientific domains.*
*Date: 2026-04-27.*

---

## §0 Hypothesis and Validation Approach

**Hypothesis**: Igniter is not an enterprise-only framework. Its core primitives —
validated dependency graphs, `History[T]`, compile-time invariants, distributed
contracts, temporal rules, and OLAP Point — are exactly the primitives that science,
robotics, space, and medicine have been missing from their software stacks. The
enterprise use case is one instance of a more general pattern.

**Validation method**: for each domain, identify the deepest recurring pain, map it
directly to a specific Igniter primitive, sketch a DSL that would eliminate the pain,
identify what Igniter can do here that nothing else can, and collect the platform
insight the domain reveals.

**Anti-validation signal** to watch for: cases where Igniter adds overhead without
value, or where existing domain tools (Snakemake, ROS, MATLAB/Simulink, Epic) are
simply better. Honesty here matters more than advocacy.

---

## §1 Science — Reproducibility and Pipeline Integrity

### The Pain

The replication crisis in science is not a culture problem — it is a software
architecture problem. The actual root causes:

1. **Preprocessing parameters change silently.** An analysis from 2019 cannot be
   reproduced because the normalisation function was updated in the shared library.
   Nobody knows which version was used.

2. **Pipelines are ad-hoc DAGs.** Every lab has its own Python scripts chained with
   shell calls. There is no type-checking between stages. A column rename breaks the
   pipeline at runtime, not at definition time.

3. **Data quality is checked late or never.** Quality gates exist in comments
   ("TODO: validate that pval < 0.05") or post-hoc scripts, not in the pipeline
   definition.

4. **Multi-dimensional analysis is opaque.** Analysing across conditions × time ×
   patient × gene requires bespoke pandas gymnastics. The dimensional structure is
   invisible in the code.

### Igniter Fit

| Pain | Igniter primitive | Mechanism |
|------|-------------------|-----------|
| Silent parameter changes | `BiHistory[T]` + `as_of` | Every input versioned; `as_of: original_date` reproduces exact state |
| Runtime pipeline breaks | Typed contract graph | Type mismatch detected at compile time, not at step N of a 12-hour job |
| Late quality gates | `invariant` as first-class node | Quality constraints woven into the pipeline definition, verified before execution |
| Opaque multi-dim analysis | `OLAPPoint[T, dims]` | Dimensions declared; `slice`/`rollup`/`drill` as native operations |

### DSL Sketch — Protein Fold Analysis Pipeline

```ruby
store :raw_sequences,     BiHistory[Sequence],   backend: :log
store :model_registry,    BiHistory[ModelState], backend: :log
store :analysis_results,  History[FoldResult],   backend: :timeseries

contract :protein_fold_analysis do
  input :sequence_id, String
  input :as_of, DateTime, default: -> { Time.now }

  lookup :sequence,      from: :raw_sequences,  key: :sequence_id, as_of: :as_of
  lookup :model,         from: :model_registry, key: "alphafold-v2", as_of: :as_of

  compute :preprocessed, with: [:sequence],            call: Preprocessing
  compute :prediction,   with: [:preprocessed, :model], call: FoldPredictor
  compute :quality,      with: [:prediction],           call: QualityScorer

  # Quality gates woven into the definition — not in a separate script
  invariant "quality.score >= 0.70",
    on: :quality, message: "Fold quality below acceptable threshold"
  invariant "prediction.confidence_intervals.all? { |ci| ci.width < 0.1 }",
    on: :prediction

  output :fold,    from: :prediction
  output :quality, from: :quality
end

# Exact reproduction of a 2023 run — same model, same preprocessing, same data
result = ProteinFoldAnalysis.call(
  sequence_id: "P12345",
  as_of: DateTime.new(2023, 1, 15, 14, 0, 0)
)

# "What would the result be today with last year's model?"
counterfactual = ProteinFoldAnalysis.call(
  sequence_id: "P12345",
  as_of: DateTime.now,
  model: model_registry[:as_of Date.new(2023, 1, 1)]
)
```

### OLAPPoint for Multi-Omics Analysis

```ruby
olap_point :ExpressionLevel, Float,
  dimensions: { gene: GeneId, sample: SampleId, condition: Condition, time: DateTime }

store :expression_data, OLAPPoint[Float, { gene: GeneId, sample: SampleId,
                                            condition: Condition, time: DateTime }],
  backend: :columnar,
  source:  :sequencing_pipeline,
  materialization: :incremental

contract :differential_expression do
  input :gene_set, Array[GeneId]
  input :condition_a, Condition
  input :condition_b, Condition
  input :time_point, DateTime

  olap :expr_a, ExpressionLevel,
    slice: { condition: :condition_a, time: :time_point },
    rollup: :mean, partition: :by_gene

  olap :expr_b, ExpressionLevel,
    slice: { condition: :condition_b, time: :time_point },
    rollup: :mean, partition: :by_gene

  compute :log_fold_change, with: [:expr_a, :expr_b], call: LogFoldCalc

  invariant "log_fold_change.finite?", on: :log_fold_change

  output :lfc, from: :log_fold_change
end
```

### Unique Advantages in Science

**What no existing tool does here:**

- **Snakemake / Nextflow**: declare pipeline topology but have no type system, no
  invariants, no temporal versioning. `as_of` reproduction is impossible — you must
  manually manage environment files.
- **DVC / MLflow**: track artifacts but not the computational structure. Invariants
  don't exist. Quality gates are post-hoc scripts.
- **Igniter**: the pipeline topology IS the type-checked program. `as_of` gives
  exact reproducibility for free. Invariants are the quality gates. `BiHistory[T]`
  is a complete audit trail satisfying most journal reproducibility requirements.

**Single most important advantage**: `as_of` on `BiHistory[T]` inputs turns
reproducibility from a process discipline into a language property. You can never
"forget" to record which version was used — the contract captures it by construction.

### Platform Insights Collected

- **Physical unit types**: science constantly works with `Kelvin`, `Meter`, `Pascal`,
  `Mole`. A `Float` labeled "temperature" might be C° or K. Wrong units caused the
  Mars Climate Orbiter loss. Unit types are refinement types: `Kelvin = Float where value >= 0.0`.
  The invariant system already supports this — but a built-in unit algebra would
  make it first-class.

- **Uncertainty as a type**: scientific measurements always carry uncertainty.
  `~Float` (probabilistic type) from the precomp document needs grounding in
  measurement theory: `~Float = { value: Float, uncertainty: Float }`. Uncertainty
  should propagate through the contract graph via standard error propagation rules.
  The `~T` probabilistic type is the right model — just needs physical grounding.

---

## §2 Robotics — Safety-Critical Control Loops

### The Pain

Robot software is the hardest software to reason about because it operates in the
physical world with real-time constraints and catastrophic failure modes:

1. **Safety constraints scattered across the codebase.** "Velocity must not exceed
   MAX_VELOCITY" appears as a check in three different files, gets removed during
   refactoring, and a robot crashes into a person.

2. **Behavioral modes are implicit state machines.** Emergency stop, degraded mode,
   normal operation — each mode has different rules. Implementing this as nested
   `if/elsif/else` chains makes the modes invisible and untestable.

3. **Sensor-actuator coupling.** Control loops mix sensing, computation, and
   actuation into monolithic classes. Testing any one part requires mocking everything
   else. The data flow is unreadable.

4. **No formal connection between specification and code.** The safety requirements
   document says "The robot shall not move faster than 0.5 m/s in a mapped
   environment." The code has `MAX_VELOCITY = 0.5` somewhere. Whether these are
   the same constraint is unknowable.

### Igniter Fit

| Pain | Igniter primitive | Mechanism |
|------|-------------------|-----------|
| Scattered safety constraints | `invariant` as first-class | Single source of truth; compiler verifies placement |
| Implicit state machines | Temporal `rule` system | Behavioral modes as named rules with `applies:` predicates |
| Sensor-actuator coupling | Contract graph topology | Sensor → compute → actuator declared as typed DAG |
| Spec-code disconnect | Invariants with labels | Invariant names become the specification items |

### DSL Sketch — Autonomous Navigation

```ruby
contract :navigation_step do
  input :sensor_fusion,  SensorState
  input :mission_plan,   MissionPlan
  input :robot_state,    RobotState

  compute :obstacle_map,       with: [:sensor_fusion],                          call: ObstacleMapper
  compute :path_candidate,     with: [:obstacle_map, :mission_plan, :robot_state], call: PathPlanner
  compute :velocity_command,   with: [:path_candidate, :robot_state],           call: VelocityController

  # Safety invariants — these ARE the safety requirements document, in executable form
  invariant "sensor_fusion.staleness < 100.milliseconds",
    on: :sensor_fusion, label: "REQ-SENSE-01"
  invariant "velocity_command.linear.abs <= MAX_LINEAR_VEL",
    on: :velocity_command, label: "REQ-SAFE-01"
  invariant "velocity_command.angular.abs <= MAX_ANGULAR_VEL",
    on: :velocity_command, label: "REQ-SAFE-02"
  invariant "path_candidate.clearance >= SAFETY_MARGIN",
    on: :path_candidate, label: "REQ-SAFE-03"

  output :command, from: :velocity_command
end
```

Behavioral modes as temporal rules — no `if/elsif` chains:

```ruby
# Emergency stop — highest priority, overrides everything
rule :emergency_stop do
  applies_to :velocity_command
  applies:   -> { sensor_fusion.collision_probability > 0.8 }
  compute:   -> { VelocityCommand.zero }
  priority:  1000
end

# Battery conservation mode
rule :low_battery_crawl do
  applies_to :velocity_command
  applies:   -> { robot_state.battery_level < 0.15 }
  compute:   -> (cmd) { cmd.scale(0.3) }
  priority:  10
end

# Degraded sensor mode — slower and more conservative
rule :degraded_sensing do
  applies_to :path_candidate
  applies:   -> { sensor_fusion.active_sensors < MINIMUM_SENSORS }
  compute:   -> { PathPlanner.conservative_mode(obstacle_map, mission_plan, robot_state) }
  priority:  50
end
```

### DSL Sketch — Robot Swarm Coordination

```ruby
contract :swarm_coordination do
  input :swarm_id,    String
  input :robot_count, Integer

  await :all_ready, event: :robot_ready, count: :robot_count,
        correlate_by: :swarm_id

  compute :formation, with: [:all_ready], call: FormationPlanner
  compute :task_assignment, with: [:formation, :all_ready], call: TaskAssigner

  invariant "task_assignment.all? { |r| r.assigned? }", on: :task_assignment
  invariant "formation.no_collisions?", on: :formation

  effect :broadcast_plan, depends_on: :task_assignment,
           call: SwarmBroadcast, idempotent: true

  output :plan, from: :task_assignment
end
```

### Unique Advantages in Robotics

**What no existing tool does here:**

- **ROS 2**: publish-subscribe messaging with no type-checked pipelines, no invariants.
  Safety is entirely the programmer's responsibility.
- **Simulink**: block diagrams with constraints, but generated code is opaque,
  untestable, and locked to MATLAB.
- **Igniter**: the contract graph is the control architecture. Invariants with
  labels become traceable to the safety requirements document. Temporal rules
  replace implicit state machines. The same framework runs on the robot and in
  test suites — no mocking required.

**Single most important advantage**: invariants with `label:` annotations create a
live, executable safety requirements document. Every requirement is either satisfied
by construction or raises a verified exception. Certification evidence is generated
automatically.

### Platform Insights Collected

- **Real-time execution contracts**: in robotics, "this control loop runs in < 10ms"
  is not a performance goal — it is a correctness requirement. The language needs
  deadline contracts: `contract :navigation_step, deadline: 10.milliseconds`. This
  connects to worst-case execution time (WCET) analysis. The DAG structure of a
  contract makes WCET more tractable than for arbitrary programs — the critical path
  is computable at compile time.

- **Invariant labels as certification artifacts**: `label: "REQ-SAFE-01"` connects
  an invariant to a requirements management ID. With a requirements database, the
  compiler can verify 100% requirement coverage. This is exactly what DO-178C (avionics),
  ISO 26262 (automotive), and IEC 62443 (industrial) require.

---

## §3 Space — Telemetry, Mission Contracts, and Ground Systems

### The Pain

Space systems engineering has some of the highest software quality requirements on
Earth — and some of the most persistent pain:

1. **Telemetry corrections after calibration updates.** A sensor on a spacecraft has
   its calibration updated. Six months of historical telemetry must be re-interpreted.
   The original "wrong" values must be preserved for mission analysis. Standard
   time-series databases either overwrite or require custom correction schemas.

2. **Ground-spacecraft event correlation.** Commands sent from the ground take 20
   minutes to reach Mars. Responses arrive 20 minutes later. Correlating commands with
   their effects requires causal bookkeeping across a 40-minute window of uncertainty.

3. **Mission rules encoded in code, not declarations.** "Power the heater if
   temperature drops below 250K AND we are not in eclipse" is buried in a C routine.
   Updating it requires a software build, upload, and verification cycle.

4. **Operational/analytical gap.** Housekeeping telemetry (operational) feeds anomaly
   reports, mission planning, and engineering analysis (analytical). The gap is managed
   with manual data exports and bespoke scripts.

### Igniter Fit

| Pain | Igniter primitive | Mechanism |
|------|-------------------|-----------|
| Telemetry corrections | `BiHistory[T]` | Corrections append new records; original values preserved; query at any (valid, transaction) pair |
| Causal event correlation | Distributed contracts + causal `as_of` | `await` correlates events; vector clocks track causal order across light-delay |
| Mission rules in code | Temporal `rule` declarations | Rules are data, not code; upl inkable without software build |
| Operational/analytical gap | `OLAPPoint source:` | Materialization contract bridges telemetry stream to OLAP store |

### DSL Sketch — Thermal Control with BiHistory

```ruby
store :temperature_telemetry, BiHistory[Kelvin],
  backend:        :timeseries,
  write:          :single_writer,   # telemetry arrives through one ground station
  consistency:    :causal,
  write_conflict: :last_wins        # later calibration supersedes earlier

# Six months after launch, calibration is updated. Append corrections — never overwrite.
# temperature_telemetry.append(
#   component: "thruster_1",
#   value: Kelvin.new(298.5),
#   valid_from: original_timestamp,
#   valid_until: original_timestamp,
#   recorded_from: Time.now   # ← transaction_time = now (correction time)
# )

contract :thermal_control_decision do
  input :component_id, String
  input :command_time,  DateTime

  lookup :temperature, from: :temperature_telemetry,
    # Critical for incident investigation:
    # "What temp did we THINK it was when we sent the command?"
    as_of:           :command_time,
    knowledge_as_of: :command_time

  lookup :limits, from: :component_specifications, key: :component_id

  compute :margin, with: [:temperature, :limits], call: ThermalMarginCalc

  invariant "temperature <= limits.max_operating",
    on: :temperature, label: "THERM-01", message: "Component over thermal limit"
  invariant "margin >= 0.0",
    on: :margin, label: "THERM-02"

  branch :recommendation do
    on { margin < 0.05 } => :emergency_shutdown
    on { margin < 0.15 } => :reduce_power
    on { margin >= 0.15 } => :nominal
  end

  output :recommendation, from: :recommendation
  output :margin,         from: :margin
end
```

### DSL Sketch — Mission Rules as Uplink-Able Declarations

```ruby
# These rules can be uplinked and applied without a software build cycle
rule :eclipse_heater do
  applies_to :heater_power_command
  applies:   -> { spacecraft_state.in_eclipse? &&
                  temperature_telemetry[:as_of as_of].value < Kelvin.new(250) }
  compute:   -> { HeaterCommand.on(power: 50.watts) }
  priority:  20
end

rule :emergency_heater do
  applies_to :heater_power_command
  applies:   -> { temperature_telemetry[:as_of as_of].value < Kelvin.new(230) }
  compute:   -> { HeaterCommand.on(power: 100.watts) }
  priority:  100
end

rule :safe_mode_power_budget do
  applies_to :heater_power_command
  applies:   -> { spacecraft_state.safe_mode? }
  compute:   -> (cmd) { cmd.clamp_power(20.watts) }
  priority:  200  # safe mode budget overrides everything
end
```

Ground-spacecraft coordination with causal `as_of`:

```ruby
contract :command_sequence_execution do
  correlate_by :sequence_id

  input  :sequence_id, String
  input  :commands,    Array[UplinkedCommand]

  await  :execution_ack, event: :telemetry_confirms_execution,
           correlate_by: :sequence_id,
           timeout: 3.hours   # light-round-trip to Mars + margin

  compute :outcome_analysis, with: [:commands, :execution_ack], call: OutcomeAnalyzer

  invariant "execution_ack.all_commands_confirmed?",
    on: :execution_ack, label: "CMD-ACK-01"

  output :outcome, from: :outcome_analysis
end
```

### Unique Advantages in Space

**What no existing tool does here:**

- **CCSDS / XTCE telemetry schemas**: define data formats but have no computation
  model, no invariants, no temporal reasoning.
- **MATLAB/SIMULINK for mission analysis**: good for simulation, terrible for
  operational systems. No audit trail, no type-checked pipelines.
- **GSFC GOTS / commercial ground systems**: custom per-mission, enormous cost,
  no shared primitives.
- **Igniter**: `BiHistory[T]` is the correct model for telemetry corrections — a
  spacecraft's housekeeping data is naturally bitemporal. The causal `as_of` with
  vector clocks handles the light-delay correlation problem. Mission rules as
  temporal declarations can be uplinked without a software build cycle.

**Single most important advantage**: `BiHistory[T]` with `knowledge_as_of` enables
the critical incident analysis query — "What did we know, and when did we know it?"
This is not achievable with standard time-series databases. It eliminates entire
categories of mission investigation complexity.

### Platform Insights Collected

- **Certified export of compiled graph**: space agencies (ESA, NASA) require formal
  specifications for safety-critical software. The compiled contract graph is already
  a formal DAG with typed edges and verified invariants. A compiler pass could export
  this as an AADL, SysML, or Modelica specification — the certification artifact
  already exists in the compilation artifact.

- **Uplink-able rule declarations**: mission rules as temporal declarations (not code)
  can be serialised, transmitted over a radio link, and applied at the receiver
  without a software update. This requires the rule system to be data — which it
  already is, structurally. The platform needs a rule serialisation format and a
  safe rule-injection API.

---

## §4 Medicine — Clinical Safety and Audit Trails

### The Pain

Healthcare software kills people when it gets the logic wrong, and creates legal
liability when it cannot prove it got the logic right:

1. **Drug interaction checking is bolt-on, not structural.** Drug interaction
   databases are queried at order entry and forgotten. Whether the check ran, what
   version it used, and what it found are not part of the medical record.

2. **Dosing logic is buried in code, not traceable to guidelines.** Clinical
   guidelines say "reduce dose by 50% for eGFR < 30". The code has
   `if egfr < 30 then dose * 0.5`. Whether these are the same constraint, and
   whether the code will be updated when the guideline changes, is unknowable.

3. **Corrections to medical records require full audit trail.** HIPAA and EHR
   standards require that every correction preserve the original, with who corrected
   it and when. Standard databases support this with custom audit tables — fragile,
   inconsistent, often missing.

4. **Clinical protocols change; running workflows must not break.** A dosing protocol
   update must not affect in-flight orders. Orders started under protocol v1 must
   complete under protocol v1.

### Igniter Fit

| Pain | Igniter primitive | Mechanism |
|------|-------------------|-----------|
| Bolt-on interaction checking | Contract as first-class stage | Interaction check is a typed node; its result is a contract output |
| Guideline-code disconnect | `invariant` with `label:` | Invariant name = guideline reference; compiler enforces it |
| Audit trail for corrections | `BiHistory[T]` | Every correction appends; original preserved; query at any valid/transaction time |
| Protocol versioning | `as_of` on rule stores | In-flight order pins rule version at start time |

### DSL Sketch — Medication Dosing Contract

```ruby
store :patient_vitals,    BiHistory[VitalSigns],  backend: :timeseries,
                          consistency: :strong,    write_conflict: :error
store :active_medications, BiHistory[Medication],  backend: :timeseries,
                           consistency: :strong
store :dosing_protocols,   BiHistory[DosingProtocol], backend: :log

contract :medication_dosing do
  input :patient_id,      String
  input :medication_order, MedicationOrder
  input :as_of,           DateTime, default: -> { Time.now }

  lookup :patient,     from: :ehr,                key: :patient_id
  lookup :vitals,      from: :patient_vitals,     key: :patient_id, as_of: :as_of
  lookup :active_meds, from: :active_medications, key: :patient_id, as_of: :as_of
  lookup :protocol,    from: :dosing_protocols,   key: :medication_order.drug_id,
                       as_of: :as_of   # ← pins protocol version at order time

  compute :renal_function,  with: [:patient, :vitals],             call: RenalFunctionCalc
  compute :interactions,    with: [:active_meds, :medication_order], call: DrugInteractionChecker
  compute :adjusted_dose,   with: [:medication_order, :renal_function, :protocol], call: DoseAdjuster

  # Each invariant is traceable to a clinical guideline reference
  invariant "interactions.none? { |i| i.severity == :contraindicated }",
    on: :interactions,
    label: "CG-INTERACTION-01",
    message: "Contraindicated drug combination — order blocked"

  invariant "interactions.none? { |i| i.severity == :major && !i.acknowledged? }",
    on: :interactions,
    label: "CG-INTERACTION-02"

  invariant "adjusted_dose.amount.between?(protocol.min_dose, protocol.max_dose)",
    on: :adjusted_dose,
    label: "CG-DOSE-RANGE-01",
    message: "Dose outside protocol-defined therapeutic range"

  invariant "adjusted_dose.amount <= medication_order.drug.absolute_max_dose",
    on: :adjusted_dose,
    label: "CG-DOSE-MAX-01",
    message: "Dose exceeds absolute maximum — potential overdose"

  invariant "renal_function.egfr > 0.0",
    on: :renal_function, label: "CG-RENAL-01"

  output :approved_dose, from: :adjusted_dose
  output :warnings,      from: :interactions
  output :protocol_used, from: :protocol   # ← audit trail: which protocol version
end
```

Protocol updates without breaking in-flight orders:

```ruby
# Protocol version pinned at order time via as_of — in-flight orders complete under
# the protocol that was current when they were created. New orders get the new protocol.
# Zero configuration needed — this is the natural behaviour of as_of on BiHistory[T].

rule :renal_dose_adjustment do
  applies_to :adjusted_dose
  applies:   -> { renal_function.egfr < 30.0 }
  compute:   -> (dose) { dose.scale(0.5) }
  priority:  10
  # Updating this rule creates a new BiHistory[T] record with transaction_time = now.
  # Orders started before now see the old rule. Orders started after see the new one.
end
```

### BiHistory for Medical Record Corrections

```ruby
store :lab_results, BiHistory[LabResult], backend: :timeseries, consistency: :strong

# Scenario: lab reports haemoglobin as 8.2 g/dL. Later they correct it to 11.4 (instrument error).
# BiHistory records both, with full audit trail:

# Original entry (valid_time = when blood was drawn, transaction_time = when result arrived)
# BiHistory append: { hgb: 8.2, valid_time: sample_time, recorded_from: report_time }

# Correction (same valid_time, new transaction_time = now)
# BiHistory append: { hgb: 11.4, valid_time: sample_time, recorded_from: Time.now, corrected_by: "Dr. Smith" }

# "What haemoglobin did the system show when we made the transfusion decision?"
hgb_at_decision = lab_results[:as_of transfusion_decision_time,
                                :knowledge_as_of transfusion_decision_time]
# → 8.2 (the value that was known at decision time)

# "What is the correct haemoglobin for that blood draw?"
hgb_correct = lab_results[:as_of sample_time, :knowledge_as_of Time.now]
# → 11.4 (post-correction value)
```

### Unique Advantages in Medicine

**What no existing tool does here:**

- **Epic / Cerner**: EHR platforms have dosing checks but they are black boxes.
  Which guideline was applied, which version, what the intermediate computations
  were — none of this is inspectable or testable.
- **Clinical decision support (CDS Hooks)**: event-driven hooks, no computation
  model, no invariants, no audit of computational provenance.
- **Custom dosing logic in EHR scripting languages**: bespoke, untestable,
  not connected to guidelines.
- **Igniter**: invariants with `label:` annotations are the clinical guidelines
  in executable form. `BiHistory[T]` satisfies audit requirements by construction.
  `as_of` protocol pinning means protocol updates never break in-flight orders.
  The compilation artifact is a formal specification that can support FDA 510(k) submissions.

**Single most important advantage**: invariants labeled with clinical guideline
references create a live, testable, auditable connection between the published
guideline and the running code. The gap between "what the guidelines say" and
"what the software does" — which causes adverse events — becomes a compiler error.

### Platform Insights Collected

- **Invariant violation severity levels**: medical invariants have different
  consequences. A contraindicated combination should `raise` (hard block).
  A major interaction should `warn` and require acknowledgement. A minor interaction
  should `log`. The invariant system needs a `severity:` parameter:
  `invariant "...", severity: :error | :warn | :log`.

- **Invariant acknowledgement workflow**: in medicine, a clinician can override
  an interaction warning with documented justification. The platform needs:
  `invariant "...", overridable_with: :documented_justification`. The override
  becomes part of the BiHistory audit trail.

---

## §5 Cross-Domain Synthesis

### The Pattern is Universal

All four domains share a single pattern:

```
Physical/digital world data
  → Typed sensor/input nodes
    → Typed computation graph (validated at compile time)
      → Safety invariants (verified before execution)
        → Typed output / actuation / recommendation
```

This is exactly a contract graph. The domains differ only in:
- The types involved (DNA sequences vs telemetry vs vital signs vs sensor fusion)
- The latency requirements (hours for science vs milliseconds for robotics)
- The regulatory framework (FDA vs ESA vs ISO vs journal review)
- The consequence of failure (wasted compute vs patient death vs lost spacecraft)

**Igniter is a computation model, not an enterprise tool.** The enterprise use case
is the domain where the strictest consequence of failure is financial loss. The other
domains have stricter consequences and therefore *more* need for the guarantees
Igniter provides.

### Shared Primitive Requirements

| Requirement | All four domains need it | Current Igniter | Gap |
|-------------|--------------------------|-----------------|-----|
| Typed dependency graph | Yes | ✓ Complete | None |
| Compile-time validation | Yes | ✓ Complete | None |
| `invariant` as first-class | Yes | ✓ Complete | Severity levels |
| `History[T]` / `BiHistory[T]` | Yes | ✓ Specified | Implementation |
| Temporal rules | Yes | ✓ Specified | Implementation |
| `as_of` query | Yes | ✓ Specified | Implementation |
| `OLAPPoint` multi-dim | Yes | ✓ Specified | Implementation |
| Distributed contracts | Yes | ✓ Complete | None |
| Physical unit types | Science, Space, Robotics | ✗ Missing | New primitive |
| Uncertainty propagation | Science, Robotics | ✗ Missing | Extend `~T` |
| Deadline contracts | Robotics, Space | ✗ Missing | New primitive |
| Certified export | Space, Medicine, Robotics | ✗ Missing | Compiler pass |
| Invariant severity levels | Medicine, Robotics | ✗ Missing | DSL extension |

---

## §6 Platform Development Insights

These are the insights the four domains collectively contribute to the platform
development roadmap. Ordered by strategic importance.

### Insight 1 — Physical Unit Types (highest value)

**Domain trigger**: Science (Mars Orbiter), Space (every unit-mismatch anomaly),
Medicine (mg vs mcg dosing errors kill patients), Robotics (angle in degrees vs radians).

**Proposal**: unit types as refinement types in the language.

```
type Kelvin = Float where value >= 0.0
type Meter = Float
type Newton = Float

# Algebra: Meter * (1 / Second^2) → Acceleration
# Compiler rejects: compute :force, with: [:mass_kg, :accel_m_s2] → Kelvin
```

Unit algebra is well-understood (dimensional analysis). Igniter's refinement type
system (via invariants + Liquid Types connection) can express this. The compiler
checks dimensional consistency at compile time.

**Development cost**: medium. Requires type algebra in the compiler.
**Value**: eliminates entire classes of bugs that have caused real fatalities and mission losses.

### Insight 2 — Invariant Severity Levels

**Domain trigger**: Medicine (warn vs block vs log), Robotics (hard stop vs advisory),
Space (mission-critical vs housekeeping).

**Proposal**: `severity:` parameter on invariants.

```
invariant "interactions.none? { |i| i.severity == :contraindicated }",
  severity: :error    # raises InvariantViolation, blocks execution

invariant "interactions.none? { |i| i.severity == :major && !i.acknowledged? }",
  severity: :warn,    # does not raise; logs + sets warning on output
  overridable_with: :documented_justification

invariant "response_time < 100.milliseconds",
  severity: :log      # records metric; does not affect execution
```

**Development cost**: low. Existing invariant system needs severity routing and
acknowledgement mechanism.
**Value**: makes the invariant system usable in all regulated domains without hard stops
for warnings.

### Insight 3 — Deadline Contracts (real-time extension)

**Domain trigger**: Robotics (10ms control loop), Space (telemetry processing
windows), Medicine (alarm response time requirements).

**Proposal**: `deadline:` parameter on contracts with compile-time WCET analysis.

```
contract :navigation_step, deadline: 10.milliseconds do
  # Compiler computes critical path through the DAG.
  # If max(node_wcet for nodes on critical path) > deadline → compile error.
  # Requires: WCET annotations on compute nodes.
  ...
end
```

**Node-level WCET annotation**:
```
compute :path_planning, with: [:obstacle_map, :mission_plan],
  call: PathPlanner,
  wcet: 3.milliseconds   # worst-case declared by the implementer
```

**Development cost**: high. Requires WCET analysis infrastructure. But the DAG
structure makes this more tractable than for arbitrary programs — the critical path
is exactly computable.
**Value**: enables Igniter in hard real-time domains (automotive, avionics, industrial
control) in addition to soft real-time (robotics, space ground systems).

### Insight 4 — Uplink-Able Rule Declarations

**Domain trigger**: Space (rule updates via radio link without software build),
Medicine (protocol updates without EHR deployment), Robotics (behavior update
without reflashing).

**Current state**: temporal rules are Ruby procs — not serialisable.

**Proposal**: a subset of rule declarations expressible as data (JSON/MessagePack):

```json
{
  "rule": "eclipse_heater",
  "applies_to": "heater_power_command",
  "applies": { "op": "and",
               "args": [
                 { "field": "spacecraft_state.in_eclipse", "eq": true },
                 { "field": "temperature.value", "lt": 250.0 }
               ]},
  "compute": { "type": "constant", "value": { "power_watts": 50 } },
  "priority": 20
}
```

The restricted rule DSL (no arbitrary Ruby, only field comparisons + arithmetic +
constants) is serialisable, transmittable, and safely injectable without a code deployment.

**Development cost**: medium. Requires a rule expression language + safe evaluator
(already partially exists via the rule applies/compute structure).
**Value**: opens Igniter to operational environments where code deployment is impossible
(spacecraft) or heavily regulated (medical devices).

### Insight 5 — Certified Export from Compiled Graph

**Domain trigger**: Space (ESA/NASA formal verification requirements), Medicine
(FDA 510(k)), Robotics (DO-178C, ISO 26262), Science (reproducibility requirements).

The compiled contract graph is already a formal DAG with typed edges, verified
invariants, and resolution order. This is a formal specification. A compiler pass
could export it as:

- **AADL** (Architecture Analysis and Design Language) — aerospace
- **SysML / UML** — general systems engineering
- **Modelica** — physical system simulation
- **Coq/TLA+** — formal verification
- **SBOM** (Software Bill of Materials) — supply chain / FDA

**Development cost**: medium per format. The compiler already has the information;
the work is the serialisation format.
**Value**: turns Igniter's compilation artifact into a regulatory submission artifact.
This is a significant commercial differentiator in regulated industries.

### Insight 6 — Uncertainty Propagation through Contract Graph

**Domain trigger**: Science (measurement uncertainty), Robotics (sensor noise),
Space (orbit determination uncertainty), Medicine (lab test precision).

**Current state**: `~T` (probabilistic type) exists in the precomp document as a
theoretical construct. It needs physical grounding.

**Proposal**: `~Float` as a built-in uncertain type with propagation rules.

```
type ~Float = { value: Float, std_dev: Float }

# Arithmetic propagation follows standard error propagation:
# ~a + ~b → ~(a+b) with σ = sqrt(σa² + σb²)    (independent)
# ~a * ~b → ~(a*b) with σ/μ = sqrt((σa/μa)² + (σb/μb)²)

compute :position_estimate, with: [:gps, :imu], call: SensorFusion
# → type is ~Position (uncertain position with covariance)

invariant "position_estimate.value.distance_to(target) < 1.0",
  on: :position_estimate
# Compiler warns if position_estimate.std_dev is large enough that the invariant
# may not hold with high probability
```

**Development cost**: medium. Requires type-level arithmetic rules for uncertainty
propagation. Connects to the `~T` type already in the spec.

---

## §7 Verdict

**Validation result: confirmed with differentiation.**

Igniter fits scientific and critical domains not despite its enterprise origins but
because the enterprise problem and the science/robotics/space/medicine problem are
the same problem at different consequence levels:

> A complex computation with many inputs, typed dependencies, invariants that must
> hold, temporal state that must be correct, and a need to know exactly what
> happened when.

The enterprise version of this problem results in wrong invoices. The medical
version results in patient deaths. The same primitives solve both; the stakes
differ.

**The domains reveal Igniter's actual value proposition more sharply than
enterprise use cases do.** In enterprise, invariants are nice to have. In medicine,
invariants with label references to clinical guidelines are the gap between
certification and liability. In space, `BiHistory[T]` with `knowledge_as_of` is
the gap between incident analysis and mission loss investigation. The critical
domains are not edge cases — they are the proof that the design is correct.

**Six platform insights collected** (§6), ordered by strategic importance:
1. Physical unit types (eliminates unit-mismatch failures, well-understood model)
2. Invariant severity levels (low cost, high value for regulated domains)
3. Deadline contracts (high cost, enables hard real-time domains)
4. Uplink-able rule declarations (medium cost, unique differentiator for space/IoT)
5. Certified export from compiled graph (medium per format, commercial differentiator)
6. Uncertainty propagation (medium cost, grounded extension of existing `~T`)

Of these, **physical unit types + invariant severity levels** have the highest
value/cost ratio and should be considered for near-term specification.
