# Field Supply Watch v3 Evaluator Guide

File under test:

```text
field_supply_watch_v3.ig
```

This fixture is intentionally hypothetical future Igniter-Lang syntax. It is a
pressure artifact only and is not claimed to parse with the current compiler.

---

## Suggested Blind Prompt

Give only `field_supply_watch_v3.ig` to the participant and ask:

```text
You are seeing a program in an unfamiliar language.

1. Explain what the program does.
2. Identify the main data structures and data roles.
3. Identify what is historical, bitemporal, streaming, analytical, or audited.
4. Explain how risk thresholds are represented.
5. Explain what external helper functions are visible and whether they look pure.
6. Explain how receipt identity appears to be generated.
7. Explain where human review happens and whether it looks blocking/suspending.
8. Identify anything confusing, ambiguous, or impossible to verify.
```

---

## Expected High-Level Understanding

The program models a regional field supply monitoring and dispatch workflow. It:

- receives live field reports
- normalizes reports into demand signals
- verifies demand against recent reports
- names risk thresholds instead of embedding magic numbers
- declares helper functions with `external pure` signatures
- reads bitemporal inventory using valid time and transaction time
- builds a regional supply posture
- delegates route planning to a trusted mesh capability
- awaits human review for high-risk dispatch
- creates an audit receipt with declarative content-hash identity
- writes shortage state to an analytical metric

---

## Construct Status Table

| Construct | Status | Note |
|-----------|--------|------|
| `module`, `type`, `contract`, `read`, `output` | canon | Existing source/kernel concepts |
| ordinary operators and comparisons | canon | Existing expression grammar pressure/kernel |
| `History[T]`, `BiHistory[T]`, `stream` | canon | Stage 2 closed surfaces |
| invariant severity | canon | Stage 2 closed surface |
| `profile` | pressure | Runtime/proof/evidence mode surface, not closed source canon |
| `packet`, `event`, `receipt`, `view` | pressure | Strong data-role profiles; not closed top-level canon |
| `metric` | pressure | Friendly alias candidate over canonical `olap_point` / `OLAPPoint` |
| `mesh`, `delegate`, trust/admission syntax | pressure | Distributed execution vocabulary still open |
| `await_review` | pressure | Lifecycle/suspend/resume semantics still open |
| `threshold` | pressure | Verifiability candidate for named domain constants |
| `external pure fn(...) -> T` | pressure | Richer helper/FFI signature candidate |
| `id ... by content_hash(...)` | pressure | Declarative receipt identity candidate |
| `accumulate` | pressure | Human-facing alias candidate over `fold_stream` |
| `let` as contract-body compute replacement | pressure | Must preserve graph node identity if adopted |
| `EvidenceRef`, `evidence_refs(...)`, `evidence [...]` | pressure | Provenance identity and evidence surface still unsettled |

---

## Comprehension Scoring Sketch

Score each dimension from 0 to 2:

```text
0 -- missed or wrong
1 -- partially understood
2 -- clearly understood
```

Dimensions:

1. Overall workflow.
2. Data roles and DTO/profile comprehension.
3. Temporal and bitemporal comprehension.
4. Stream/window/accumulation comprehension.
5. Named threshold comprehension.
6. External helper signature comprehension.
7. Evidence/audit/receipt identity comprehension.
8. Mesh/delegation/trust comprehension.
9. Human review lifecycle comprehension.
10. Ability to distinguish readable syntax from verifiable semantics.

Maximum score: 20.

---

## Ambiguities To Watch

Useful signals include:

- whether `threshold` reads as a typed constant or policy object
- whether `external pure` is enough to make helper calls verifiable
- whether receipt `id ... by content_hash(...)` feels declarative or magical
- whether `accumulate` is clearer than `fold_stream`
- whether `metric` hides OLAP semantics too much
- whether `await_review` clearly implies suspend/resume behavior
- whether `evidence_refs(...)` still feels like hidden provenance magic
- whether `delegate` gets confused with AI model/tool invocation

---

## Recommendation

Prioritize next review for:

1. `threshold`
2. `external pure`
3. declarative receipt identity
4. `accumulate` versus `fold_stream`
5. `await_review` lifecycle semantics
