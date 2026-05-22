# Ecosystem Pulse: RuView Scan v0

Status: ecosystem pulse scan
Owner: [Portfolio Architect Supervisor]
Date: 2026-05-22
Method: `docs/org/tracks/ecosystem-pulse-scan-methodology-v0.md`

---

## Source

Project:

```text
https://github.com/ruvnet/RuView
```

Public pages read:

- GitHub repository overview and README;
- `plugins/ruview` README;
- `docs/adr` index;
- root `CLAUDE.md` overview.

Visible public signals at scan time:

```text
stars: ~63k
forks: ~8k
positioning: WiFi CSI sensing platform for spatial intelligence, presence,
vitals, pose, environment mapping, and edge modules
```

These public numbers are time-sensitive and should not be treated as durable
facts.

---

## Snapshot

RuView presents itself as a WiFi sensing platform that turns commodity WiFi
signals into spatial intelligence without cameras or wearables.

Visible capability clusters:

- ESP32-S3 / WiFi CSI sensing;
- presence, vital signs, fall/motion/activity detection;
- room/environment fingerprinting;
- mesh and multistatic sensing;
- Rust/Python stack;
- Docker simulation path;
- edge module catalog;
- ADR-heavy architecture documentation;
- Claude Code and Codex plugin with domain commands and skills.

The README marks the project as beta and notes that APIs and firmware may
change. It also names hardware and model limitations.

---

## What It Is

Best category:

```text
domain capability platform for RF/WiFi sensing
```

Secondary categories:

```text
edge sensing toolkit
hardware/software demo platform
applied ML/Rust/Python research system
domain-specific agent/plugin toolkit
```

RuView is not primarily an orchestration governance system. It is a concrete
domain tool surface that can provide observations, signals, embeddings, and
possibly local edge actions.

---

## Why It Is Growing

Interpretation:

- It has a strong "wow" demo promise: see presence/vitals/movement with WiFi,
  no cameras.
- It offers a ladder of entry: Docker simulation, live ESP32, full appliance.
- It packages hardware, ML, demo UI, ADRs, and plugin workflow together.
- It is visually and narratively legible to non-specialists.
- It touches domains with immediate imagination: care, rescue, retail,
  buildings, safety, robotics.
- It ships domain-specific Claude/Codex workflow support rather than a generic
  agent framework.

Strongest growth lesson:

```text
a hard technical domain becomes approachable when demo path, hardware path,
docs, and agent workflow are packaged as one experience
```

---

## Architecture Lens

| Axis | RuView signal |
| --- | --- |
| Runtime | Strong. Sensing server, CLI/API, firmware, Docker, edge modules. |
| Governance | ADR-heavy, but not an authority/gate system like Igniter. |
| Memory | Present through fingerprints, vector-like environment memory, and appliance concepts. |
| Coordination | Present in mesh/multistatic sensing and plugin workflows. |
| UX | Strong. Docker demo, hardware options, live demos, domain module catalog. |
| Safety | Strong claims around privacy/no-camera and witness/attestation concepts; needs claim-by-claim validation before adoption. |
| Portability | Strong as a domain toolkit; not a general orchestration method. |

---

## Our Coordinate Match

RuView-like systems fit Igniter as external capability/tool providers, not as
language cores.

Coordinate mapping:

```text
RuView asks: what can RF/WiFi signals infer about the world?
Igniter asks: what may the system believe, decide, do, explain, and audit?
```

For the rescue pressure specimens, RuView-like sensing maps naturally to:

```text
observed contract IngestSensorStream
  input raw: MeshPacket
  output signatures: List[VictimSignature]
  evidence [raw]
```

It can provide `VictimSignature`, confidence, uncertainty, movement, presence,
breathing, or room fingerprints. It should not own `MakeRescueDecision`,
`ExecuteRescueAction`, authority, compensation, or post-audit.

---

## Useful Pressure

Questions RuView creates for Igniter:

1. Can Igniter cleanly represent external observation providers without giving
   them decision authority?
2. Do we need a future capability/tool boundary distinct from effect surfaces?
3. How should tool output carry confidence, uncertainty, epistemic status, and
   evidence?
4. How should effect adapters differ from observation providers?
5. Can profile/pack descriptors eventually describe tool capabilities without
   runtime binding?
6. Can future demos show Igniter governing a tool-rich world without pretending
   to implement the tools?

Strongest pressure:

```text
Igniter should be able to govern RuView-like systems, not absorb them.
```

---

## What To Adopt

Adopt as patterns:

- demo ladder:
  ```text
  simulation -> local device/tool -> full applied system
  ```
- `works today / proof-local / design-only / closed` capability matrix;
- domain-specific agent commands/skills instead of generic portable
  orchestration packaging;
- ADR/decision index as public trust surface;
- clear hardware/runtime limitations near the first-run path;
- distinction between observation capability and decision authority.

---

## What To Avoid

Avoid:

- porting RuView or RF sensing into Igniter;
- treating external tool claims as trusted evidence without validation;
- giving tools authority to decide privileged actions;
- opening hardware/runtime integration before language boundaries mature;
- letting demo excitement widen parser/runtime/production surfaces;
- adopting "no camera / privacy" claims without our own compliance language.

---

## One Bounded Consequence

Create a future design pressure note:

```text
igniter-lang/docs/tracks/external-capability-tool-boundary-pressure-v0.md
```

No implementation opens from this scan.

