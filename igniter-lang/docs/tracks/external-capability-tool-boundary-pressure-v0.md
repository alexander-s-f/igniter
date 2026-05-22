# External Capability Tool Boundary Pressure v0

Status: future design pressure / parked
Owner: [Portfolio Architect Supervisor]
Date: 2026-05-22
Source pulse: `igniter-lang/docs/org/reports/ecosystem-pulse-ruview-scan-v0.md`

---

## Purpose

Record the future design pressure raised by RuView-like systems without opening
implementation, parser, runtime, or production work.

The pressure is not to port RuView into Igniter. The pressure is to make sure
Igniter can eventually govern systems that use external domain tools, sensors,
effect adapters, and applied runtimes as capability providers.

Short form:

```text
external tool provides signals/effects
Igniter owns belief, authority, decision, evidence, receipt, and audit
```

---

## Anchor Specimens

Relevant pressure specimens:

```text
igniter-lang/experiments/pressure-specimens/igniter-swarm-rescue-orchestrator-v1.ig
igniter-lang/experiments/pressure-specimens/igniter-swarm-rescue-orchestrator-v2.ig
```

Representative contract surface:

```text
observed contract IngestSensorStream
  input raw: MeshPacket
  output signatures: List[VictimSignature]
  evidence [raw]
```

In this model, a RuView-like WiFi CSI sensing system can be understood as an
observation provider for `VictimSignature`, room fingerprints, presence, vital
signs, fall signals, or related inferred observations.

It must not own rescue decisions, privileged actions, authority, compensation,
or post-audit closure.

---

## Candidate Vocabulary

These names are pressure vocabulary only, not language canon:

```text
Capability Tool
Observation Provider
Effect Adapter
Evidence Source
Authority-Free Tool
Authority-Bound Effect
```

Possible future shape:

```text
tool RuViewPresenceSensor
  provides observation VictimSignature
  evidence raw_csi_window
  confidence bounded
  epistemic_kind inferred
  authority none
```

Possible future effect shape:

```text
tool DroneCommandAdapter
  provides effect drone_command
  authority required
  compensation required
  receipt required
```

These sketches are not parser syntax and do not authorize grammar work.

---

## Design Principle

External capability tools answer:

```text
What can the world tell us?
What external action can be performed?
```

Igniter answers:

```text
What are we allowed to believe?
What are we allowed to decide?
What are we allowed to do?
What evidence must be carried?
What authority is required?
What must be explainable, reversible, refused, or audited?
```

Therefore, tool output may become evidence or candidate observation, but it must
not become decision authority by itself.

---

## Pressure On Existing Language Axes

This pressure touches, but does not open:

- observed contracts;
- external progression;
- assumptions and constraints;
- evidence lists;
- epistemic state;
- effect surfaces;
- authority references;
- receipts;
- post-audit;
- profile/pack descriptors;
- future capability registry or tool registry ideas.

---

## Boundaries

Still closed:

- parser syntax;
- TypeChecker rules;
- SemanticIR changes;
- compiler implementation;
- runtime tool execution;
- production adapters;
- RuView integration;
- Spark integration;
- Ledger/TBackend binding;
- drone, sensor, RF, or hardware implementation;
- claims that Igniter currently governs external tools.

---

## Future Design Questions

When this pressure is reopened, answer:

1. Is a capability/tool boundary a language concept, a profile/pack descriptor
   concept, or a runtime/application concept?
2. How does an observation provider declare confidence, uncertainty,
   epistemic kind, and evidence?
3. How does an effect adapter declare authority, compensation, and receipts?
4. Can tools be authority-free by default, with authority attached only at
   contract/effect boundaries?
5. How should capability descriptors relate to `compiler_profile_contract`,
   pack descriptors, and source-envelope authority?
6. What proof specimen is the smallest useful non-production validation?

---

## Parked Consequence

Do not open implementation now.

Recommended later route, after the current compiler/profile foundation matures:

```text
external-capability-tool-boundary-design-v0
```

