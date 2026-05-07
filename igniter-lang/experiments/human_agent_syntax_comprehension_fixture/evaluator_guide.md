# Human-Agent Syntax Comprehension Fixture v0

File under test:

```text
field_supply_watch.ig
```

This fixture is intentionally hypothetical future Igniter-Lang syntax. It is not
claimed to parse with the current compiler.

---

## Suggested Blind Prompt

Give only `field_supply_watch.ig` to the participant and ask:

```text
You are seeing a program in an unfamiliar language.

1. Explain what the program does.
2. Identify the main data structures.
3. Identify what is historical, streaming, bitemporal, or analytical.
4. Explain where human review happens and why.
5. Explain what evidence/audit trail the program appears to preserve.
6. Identify anything confusing or ambiguous in the syntax.
```

---

## Expected High-Level Understanding

The program models a regional medical/field supply monitoring and dispatch
workflow:

- receives live field reports
- normalizes reports into demand signals
- verifies demand using recent historical reports
- reads bitemporal inventory as of valid and knowledge time
- reads supplier offers over a future window
- builds regional supply posture
- plans dispatch through a trusted mesh of agents/peers
- requires human review for high-risk dispatch
- emits durable dispatch plans and audit receipts
- writes shortage posture into an OLAP point

---

## Concepts Covered

| Concept | Surface in fixture |
|---------|--------------------|
| structural types | `type Region`, `type DemandSignal`, etc. |
| DTO/data profiles | `packet`, `event`, `view`, `receipt` |
| temporal history | `History[ReportReceived]`, `History[SupplierOfferUpdated]` |
| bitemporal access | `BiHistory[InventorySnapshot]` with `vt` and `tt` |
| stream input | `stream report_ingress` |
| bounded stream bridge | `fold_stream report_ingress window rolling 6.hours` |
| OLAP point | `olap_point regional_supply` |
| explicit time | `as_of`, `knowledge_as_of` |
| evidence | `evidence [...]` on outputs |
| lifecycle | `lifecycle :audit`, `:durable` |
| invariants | `demand_has_source`, `high_risk_requires_review` |
| override | `overridable_with HumanOverride`, `human_review` |
| mesh/agent execution | `agent mesh`, `mesh SupplyAnalysisMesh route_plan` |
| receipts | `DispatchDecisionReceipt` |

---

## Comprehension Scoring Sketch

Score each dimension from 0 to 2:

```text
0 -- missed or wrong
1 -- partially understood
2 -- clearly understood
```

Dimensions:

1. Overall purpose.
2. Data shape comprehension.
3. Temporal/history comprehension.
4. Stream/window comprehension.
5. Evidence/audit comprehension.
6. Human review/override comprehension.
7. Mesh/agent execution comprehension.
8. Risk/invariant comprehension.
9. Ability to identify ambiguity.
10. Ability to summarize without source-language context.

Maximum score: 20.

---

## Ambiguities To Watch

Participants may reasonably wonder:

- whether `packet`, `event`, `view`, and `receipt` are first-class declarations
  or profiles over `type`
- whether `mesh ... -> route_options` is synchronous or asynchronous
- whether `some(PlanDispatch(...))` returns a nested contract result or a value
- how `obs_refs(...)` is resolved
- whether `write regional_supply` is an effect or a declarative projection write
- how `trust_tier >= :regional_operator` orders symbols

These are useful signals. They show where compact syntax needs more explicit
grammar or diagnostics before it can become canon.

---

## Why This Fixture Is Useful

The program intentionally mixes:

- OSINT-like evidence and corroboration
- ERP/logistics dispatch
- temporal and bitemporal state
- stream-to-core folding
- human override
- mesh execution
- OLAP aggregation
- receipt/audit output

It is complex enough to test comprehension, but the domain names should make the
program understandable without Igniter-Lang context.
