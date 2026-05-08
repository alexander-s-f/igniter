# Igniter-Lang Applied Pressure Directions

Status: meta thesis
Date: 2026-05-06
Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/applied-pressure-directions.md`
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Claim

[D] Igniter-Lang should develop under four applied pressure directions:

```text
1. Operational systems
2. Human-agent symbiosis
3. OSINT-like fractal traceability
4. Sandbox / simulation / world modeling
```

Together they sharpen the current identity:

```text
Igniter-Lang is an Epistemic Contract Language
for observable execution, human-agent co-reasoning,
evidence-native analysis, and scenario-safe simulation.
```

The directions are not separate languages. They are pressure lanes over the
same spine:

```text
contract + explicit time + observation evidence
  -> ParsedProgram
  -> ClassifiedProgram
  -> TypedProgram
  -> SemanticIR
  -> CompiledProgram / .igapp
  -> RuntimeMachine.load(...)
  -> evaluate / checkpoint / resume
  -> SemanticImage + CompatibilityReport
  -> TBackend adapters
  -> schema evolution + migration receipts
```

## Direction 1: Operational Systems

Purpose: prove the language against real business and application systems.

Current anchor:

```text
Spark CRM
  -> technician availability
  -> dispatch
  -> lead signals
  -> telephony
  -> order operation actions
  -> schema evolution and receipts
```

This direction tests whether Igniter-Lang can model systems where decisions
matter, effects happen, facts drift, schedules change, and humans need
explanations.

Core pressure:

- tenant scope;
- explicit time and timezone;
- schedules, availability, routing, orders;
- external vendors and FFI;
- idempotency and receipts;
- diagnostics and why-not reasons;
- schema drift and migration evidence.

Primary question:

```text
Can this language build and explain real operational systems without
collapsing into ordinary app code or vague audit logs?
```

Near tracks:

- `spark-technician-availability-fixture-v0`
- `spark-lead-signal-boundary-fixture-v0`
- `spark-operation-action-lifecycle-fixture-v0`

## Direction 2: Human-Agent Symbiosis

Purpose: make the language useful when an agent writes and a human reads.

The first symbiosis case is not autonomous execution. It is:

```text
agent proposes / writes
human reads / reviews / corrects / accepts
runtime verifies / records
```

[D] Human-agent symbiosis requires Igniter-Lang to be review-native. A human
should be able to inspect the authored artifact at the level of intention,
contract, evidence, risk, and effect rights, not only at the level of syntax.

Core pressure:

- idea representation;
- draft vs accepted contract;
- human-readable semantic images;
- review diffs over meaning, not only text;
- uncertainty and assumptions;
- agent proposal receipts;
- human approval/correction receipts;
- action rights tied to accepted projections.

Candidate vocabulary:

```text
IdeaDraft
IntentContract
ReviewProjection
AgentProposalObservation
HumanCorrectionReceipt
AcceptanceReceipt
MeaningDiff
UncertaintyBoundary
```

Primary question:

```text
Can an agent author an Igniter-Lang artifact that a human can confidently
review, challenge, accept, and later audit?
```

Guardrail:

[X] Do not treat agent reasoning text as the artifact of record. The artifact
of record is the contract, observation chain, semantic image, and receipts.

Near tracks:

- `human-agent-readable-contracts-pressure-v0`
- `agent-proposal-human-review-fixture-v0`
- `meaning-diff-and-acceptance-receipt-v0`

## Direction 3: OSINT-Like Fractal Traceability

Purpose: make the language friendly for systems that search, gather, analyze,
fact-check, reconcile, and report.

This is not only "OSINT applications." It is a traceability requirement that
repeats at every level:

```text
language axiom
  -> grammar/type rule
  -> contract
  -> observation
  -> source evidence
  -> claim
  -> inference
  -> contradiction
  -> report
  -> action
  -> correction
```

[D] OSINT-like pressure strengthens the existing rule that observation evidence
is the unit of trust. It adds claim lifecycle, source provenance, confidence,
contradiction handling, and fact-check snapshots.

Core pressure:

- source observation and provenance;
- claim decomposition;
- evidence links;
- source reliability and confidence;
- temporal validity;
- contradiction reports;
- redaction and citation policy;
- reproducible analysis snapshots;
- correction receipts.

Candidate vocabulary:

```text
Claim
SourceObservation
EvidenceLink
ConfidenceAssessment
ContradictionReport
FactCheckSnapshot
AnalystDecision
CorrectionReceipt
CitationPolicy
```

Primary question:

```text
Can the language preserve a fractal evidence chain from language axiom to
application claim to final decision?
```

Guardrail:

[X] Do not let a claim become trusted because it is repeated, summarized, or
present in a model output. Trust requires evidence links and temporal context.

Near tracks:

- `osint-fractal-traceability-pressure-v0`
- `claim-evidence-factcheck-fixture-v0`
- `contradiction-and-correction-receipt-v0`

## Direction 4: Sandbox / Simulation / World Modeling

Purpose: let humans and agents model systems in a sandbox, play scenarios, and
search for strategy without confusing simulation with reality.

This direction adds counterfactual and synthetic worlds:

```text
hypothesis + assumptions + parameters + simulated time
  -> scenario run
  -> synthetic observations
  -> comparison report
  -> strategy candidate
```

[D] Simulation is a first-class pressure direction, but simulated observations
must not be treated as real observations.

```text
real_observation != synthetic_observation
runtime_observation != forecast_observation
counterfactual_observation != audit fact
```

Core pressure:

- model boundaries;
- assumptions and calibration evidence;
- parameter sets;
- interventions;
- simulated time;
- random seeds and sampling policy;
- sensitivity analysis;
- baseline vs counterfactual comparison;
- strategy candidates;
- validity windows.

Candidate vocabulary:

```text
WorldModel
Scenario
AssumptionSet
ParameterSet
Intervention
SimulationRun
SyntheticObservation
ForecastObservation
CounterfactualObservation
CalibrationEvidence
SensitivityReport
StrategyCandidate
ModelValidityWindow
```

Primary question:

```text
Can the language model a system as a sandbox, explore "what if" strategies,
and preserve the boundary between simulated meaning and real-world evidence?
```

Guardrail:

[X] A simulation result must never speak with the voice of fact. It must always
say:

```text
Under assumptions A,
with model M,
over horizon H,
using parameters P,
simulation produced outcome O,
with uncertainty U,
calibrated by evidence E.
```

Near tracks:

- `sandbox-simulation-world-modeling-pressure-v0`
- `business-enterprise-scenario-fixture-v0`
- `simulation-observation-trust-boundary-v0`

## Shared Pressure Matrix

| Pressure | Operational | Human-Agent | OSINT | Sandbox |
|----------|-------------|-------------|-------|---------|
| Explicit time | schedule/window/as_of | review moment | claim validity | simulated horizon |
| Observation evidence | receipts/failures | proposal/review receipts | source/evidence links | synthetic observations |
| Contract addressability | business facts/actions | ideas/intents | claims/reports | world models/scenarios |
| CORE/ESCAPE/OOF | host/vendor effects | agent tools/actions | web/source ingestion | simulation engine/model calls |
| Schema evolution | app drift/migrations | meaning diffs | source/schema drift | model version drift |
| Diagnostics | why-not reasons | human-readable review | contradiction reports | sensitivity reports |
| Trust boundary | action rights | acceptance rights | fact-check confidence | real vs simulated |

## Strategic Insight

[S] These four lanes form a useful development triangle plus one sandbox axis:

```text
Operational systems
  prove the language can run real applications.

Human-agent symbiosis
  proves humans can read and govern agent-authored meaning.

OSINT-like traceability
  proves claims, evidence, uncertainty, and corrections remain inspectable.

Sandbox / simulation
  proves the language can reason about hypothetical systems without confusing
  models with facts.
```

[S] The same language primitives appear in all four lanes:

- `Contract`;
- `TemporalCtx`;
- `Projection`;
- `Observation`;
- `FailureObservation`;
- `ReceiptObservation`;
- `SemanticImage`;
- `CompatibilityReport`;
- `TBackend`;
- `SchemaDescriptor`;
- `CapabilityGate`.

This is a signal that the current spine is not too narrow. It is capable of
being pressured into broader epistemic work without becoming a generic
unstructured scripting language.

## Development Policy

[R] Keep all four directions active as pressure, but sequence proofs:

1. Continue operational Spark fixtures because they are concrete and nearby.
2. Add human-agent readability pressure before syntax hardens too much.
3. Add OSINT claim/evidence fixtures before diagnostics become app-specific.
4. Add sandbox/simulation trust-boundary fixtures before forecast/model outputs
   can be mistaken for real observations.

[R] Treat new directions as fixture/proposal work first. Do not implement
package, compiler, or runtime changes until a concrete proof or formal track
identifies the needed primitive.

## Open Formal Questions

[Q] Should `SyntheticObservation`, `ForecastObservation`, and
`CounterfactualObservation` be distinct observation kinds or payload policies
over one `observation_kind` family?

[Q] Is `Claim` a contract, a projection, or a first-class semantic object?

[Q] How does `MeaningDiff` relate to `CompatibilityReport.schema_check`?

[Q] Should human acceptance be modeled as capability-gated ESCAPE, audit
receipt, or both?

[Q] How should confidence be typed without turning the language into an
unbounded probabilistic programming language?

[Q] What is the minimal sandbox engine boundary that remains contractable
without making simulation semantics the language core?

## Handoff

[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/applied-pressure-directions.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Four applied pressure directions are now fixed: operational systems, human-agent symbiosis, OSINT-like fractal traceability, and sandbox/simulation/world modeling.
- These directions extend the existing Epistemic Contract Language spine rather than replacing it.
- Simulated/counterfactual observations must remain distinct from real/runtime observations.

[R] Recommendations:
- Keep Spark operational fixtures moving first while opening small pressure tracks for human-agent readability, OSINT traceability, and simulation trust boundaries.
- Research Agent should convert each new pressure direction into one minimal fixture.
- Compiler/Grammar Expert should formalize observation-kind boundaries, claim semantics, meaning diffs, and simulation trust rules only after fixture pressure lands.
- Bridge Agent should wait for proof artifacts before mapping these directions into package diagnostics or UI surfaces.

[S] Signals:
- The same primitives recur across all directions: contracts, time, observations, receipts, SemanticImage, CompatibilityReport, TBackend, schema descriptors, and capability gates.
- OSINT and simulation pressure make trust boundaries sharper: evidence is not repetition, and simulation is not fact.
- Human-agent pressure suggests Igniter-Lang should become review-native, not merely executable.

[T] Tests / Proofs:
- Documentation-only meta thesis; no tests were run.

[Files] Changed:
- `igniter-lang/docs/applied-pressure-directions.md`
- `igniter-lang/docs/README.md`

[Q] Open Questions:
- Which non-operational fixture should land first: human-agent review, OSINT claim evidence, or sandbox simulation?
- Should new observation kinds be formalized before or after the first fixture?
- How much probabilistic/confidence semantics belongs in v0?

[X] Rejected:
- No replacement of the current Igniter-Lang spine.
- No treating simulation output as fact.
- No treating agent prose as the artifact of record.

[Next] Proposed next slice:
- `[Igniter-Lang Applied Pressure Agent]` `human-agent-readable-contracts-pressure-v0`.
- `[Igniter-Lang Applied Pressure Agent]` `osint-fractal-traceability-pressure-v0`.
- `[Igniter-Lang Applied Pressure Agent]` `sandbox-simulation-world-modeling-pressure-v0`.
