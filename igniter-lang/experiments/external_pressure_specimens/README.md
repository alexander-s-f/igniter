# External Pressure Specimens

Status: reference · not compiled
Date: 2026-05-10
Source: External Pressure Review (S3-R26)
Governance: META-EXPERT-013

These are hypothetical Igniter-Lang programs written to pressure-test the
language specification beyond Stage 1–2 features. They exercise constructs
that are proposed (ch10–ch13) but not yet implemented.

They do not compile against the current compiler (v0.1.0.pre.stage2).
They are reference specimens for proposal authorship and regression fixture design.

---

## Programs

| File | Domain | Score | Primary gaps exercised |
|------|--------|-------|----------------------|
| [NewsClarityAggregator.ig](NewsClarityAggregator.ig) | News fact-checking pipeline | 9.2/10 | contract modifiers, profiles, service loops, evidence, privileged contracts |
| [IgniterSwarmTriangulationV1.ig](IgniterSwarmTriangulationV1.ig) | Robot swarm positioning | 9.4/10 | contract modifiers, timer-driven loops, uncertainty invariants, BiHistory temporal joins |
| [RealTimeVideoProcessorV1.ig](RealTimeVideoProcessorV1.ig) | Realtime video analysis | 9.1/10 | placement declarations, latency budgets, effect contracts, service loops |

---

## Language Constructs Exercised

These programs exercise proposed language constructs from ch10–ch13:

### Already in proposals (PROP-031+)

- `pure contract`, `observed contract`, `effect contract`, `privileged contract`,
  `irreversible contract` — ch10, PROP-031
- `via profile_name` — ch11, PROP-032
- `output ... evidence [refs]` — PROP-033
- Profile declarations (`profile audited_truth_mesh { ... }`) — ch11, PROP-034

### Proposed, not yet in proposals

- `service contract ... heartbeat ... checkpoint ... cancellation` — ch13
- `loop item in stream max_steps N on_exhaustion :suspend { }` — ch13
- `loop tick in clock.every(N.ms)` — ch13
- `write store <- value evidence [refs]` — ch13
- `view V: T { from store, columns [...], filters [...] }` — ch? (not yet)
- `placement P { mode, stages { X on :node }, fallback { ... } }` — ch? (not yet)
- `observes external/model/robot X` shorthand — part of PROP-035

---

## Usage

Use these specimens to:

1. **Validate proposals**: check that a proposed grammar extension correctly
   handles constructs appearing in these programs
2. **Design fixtures**: extract sub-programs as positive/negative fixtures for
   regression suites
3. **Identify gaps**: constructs in these programs with no corresponding PROP
   represent open language design work

Do not add these programs to the standard regression matrix. They are forward-
looking references, not current-compiler tests.
