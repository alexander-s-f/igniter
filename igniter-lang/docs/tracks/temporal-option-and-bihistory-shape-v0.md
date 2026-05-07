# Track: Temporal Option and BiHistory Shape v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/temporal-option-and-bihistory-shape-v0
Status: done
Date: 2026-05-07
Amends: PROP-022 (History[T] constructor) — implementation errata

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — runtime fixture implementation in §Part 5.
- `[Igniter-Lang Bridge Agent]` — no new bridge pressure.

---

## Part 1: Canonical Runtime JSON Encoding for Option[T]

PROP-022 uses `Option[T]` as the return type of all temporal point access
operations. The runtime JSON encoding was not previously defined.

**[D] Option[T] has exactly two canonical JSON representations:**

```json
Some(value):   { "kind": "some", "value": <T> }
None:          { "kind": "none" }
```

**[D] `{ "kind": "none" }` is the canonical gap representation.** It signals that no value exists at the queried temporal coordinate. It is NOT `null`, NOT `{}`, NOT `{ "value": null }`.

**[D] `{ "kind": "some", "value": V }` is the canonical present-value representation.** `V` is the runtime JSON encoding of `T`. For `Option[Integer]`: `{ "kind": "some", "value": 42 }`.

### Type-specific examples

```text
Option[Integer]:
  Some:  { "kind": "some", "value": 42 }
  None:  { "kind": "none" }

Option[String]:
  Some:  { "kind": "some", "value": "active" }
  None:  { "kind": "none" }

Option[Decimal[2]]:
  Some:  { "kind": "some", "value": "123.45" }   -- Decimal as string per PROP-DM
  None:  { "kind": "none" }

Option[ChangeEvent[T]]:
  Some:  { "kind": "some", "value": { "changed_at": "<ISO8601>", "value": <T> } }
  None:  { "kind": "none" }
```

**[D] `Option[T]` values must never be encoded as bare `null` in SemanticIR outputs.** Using `null` for None conflates "absent" with "unknown" and breaks downstream type checks.

---

## Part 2: history_at — Shape and Type Rule

`history_at` is the v0 canonical function-shaped accessor for `History[T]`.

```text
Signature:  history_at(h: History[T], as_of: DateTime) -> Option[T]

SemanticIR node kind:  temporal_access_node (from PROP-022 §6)

Classification:
  ESCAPE if h comes from a TBackend-backed read node.
  CORE only if h is a proof-local memory stub explicitly marked @proof_local.

Grammar surface (future):  history.at(as_of)
                            history[as_of]
                            history_at(history, as_of)     ← v0 functional form
```

### Minimal SemanticIR shape for history_at

```json
{
  "kind":         "temporal_access_node",
  "name":         "job_count_at_dispatch",
  "axis":         "valid_time",
  "history_ref":  "job_count_history",
  "as_of_ref":    "as_of",
  "result_type":  { "name": "Option", "params": ["Integer"] },
  "fragment_class": "escape"
}
```

### Runtime output shape

```text
Evaluating history_at(job_count_history, as_of: T1):
  If job_count_history has a value at T1:  { "kind": "some", "value": 3 }
  If gap at T1:                            { "kind": "none" }
```

---

## Part 3: bihistory_at — Shape and Type Rule

`bihistory_at` is the two-axis accessor for `BiHistory[T]`.

```text
Signature:  bihistory_at(h: BiHistory[T], vt: DateTime, tt: DateTime) -> Option[T]

SemanticIR node kind:  temporal_access_node (same kind; axis: "bitemporal")

Classification:  always ESCAPE in v0 (bitemporal reads are TBackend-only).

Grammar surface (future):  history[vt: t1, tt: t2]
                            bihistory_at(history, vt, tt)  ← v0 functional form
```

### Minimal SemanticIR shape for bihistory_at

```json
{
  "kind":           "temporal_access_node",
  "name":           "hgb_at_decision",
  "axis":           "bitemporal",
  "history_ref":    "hgb_history",
  "valid_time_ref": "decision_time",
  "tx_time_ref":    "recorded_as_of",
  "result_type":    { "name": "Option", "params": ["LabValue"] },
  "fragment_class": "escape"
}
```

**[D] `bihistory_at` requires both `valid_time_ref` and `tx_time_ref`.** Missing either axis → OOF-BT2 or OOF-BT3 (see §Part 4).

### Runtime output shape

```text
Evaluating bihistory_at(hgb_history, vt: T1, tt: T2):
  If a value exists at (T1, T2):  { "kind": "some", "value": { "hgb": 12.4, "unit": "g/dL" } }
  If no value at (T1, T2):        { "kind": "none" }
```

---

## Part 4: Grammar / Type / Runtime Boundary Table

```text
Concept              Grammar surface (v0)         TypedProgram type          Runtime JSON
───────────────────  ───────────────────────────  ─────────────────────────  ──────────────────────
History[T]           History[Integer]             { name:"History",          memory stub / TBackend
                                                   params:["Integer"] }
BiHistory[T]         BiHistory[Money]             { name:"BiHistory",        TBackend only (v0)
                                                   params:["Money"] }
history_at result    Option[T]                    { name:"Option",           { kind:"some", value:V }
                                                   params:["Integer"] }       { kind:"none" }
bihistory_at result  Option[T]                    same                       same
as_of                DateTime (input/const)       { name:"DateTime",         ISO8601 string
                                                   params:[] }
vt / tt (BiHistory)  DateTime (input/const)       same                       ISO8601 string
history gap          —                            —                          { kind:"none" }
history present      —                            —                          { kind:"some", value:V }
```

---

## Part 5: OOF Rules

**Inherited from PROP-022:**

```text
OOF-H1: History[T] access without as_of context.
  history_at(h) called without as_of argument.
  Owner: TypeChecker (arity check via OperatorEnv).
  Severity: error.

OOF-H2: BiHistory[T] access without explicit (vt, tt) axes.
  bihistory_at(h) called with only one axis argument.
  Owner: TypeChecker (arity check).
  Severity: error.
```

**New OOF rules (this errata):**

```text
OOF-BT1: as_of axis type mismatch.
  history_at(h, as_of) where as_of is not DateTime (e.g., Integer literal).
  Owner: TypeChecker.
  Severity: error.
  Rule: as_of_ref must resolve to a node with type DateTime or compatible alias.

OOF-BT2: Missing valid_time axis in bihistory_at.
  bihistory_at called with tt but no vt.
  Owner: TypeChecker (arity + named arg check).
  Severity: error.

OOF-BT3: Missing transaction_time axis in bihistory_at.
  bihistory_at called with vt but no tt.
  Owner: TypeChecker.
  Severity: error.

OOF-BT4: Axis type mismatch in bihistory_at.
  vt or tt is not DateTime.
  Owner: TypeChecker.
  Severity: error.

OOF-BT5: BiHistory[T] used where History[T] expected without axis projection.
  BiHistory[T] assigned to a node typed History[T] without explicit .valid_at() or .as_known_at().
  Owner: TypeChecker.
  Severity: error.
  (Matches PROP-022 §2 subtyping rule: BiHistory ⊄ History without explicit projection.)
```

---

## Part 6: SparkCRM Bitemporal Fixture Return Shape

The fixture in `sparkcrm-history-pressure-v0` needs these return shapes:

```text
Scenario 1 — technician availability at dispatch time:
  result contract output:
    "available_at_dispatch": { "kind": "some", "value": true }
  or:
    "available_at_dispatch": { "kind": "none" }   -- gap; no record at vt

Scenario 2 — correction after the fact:
  at decision time:
    "hgb_at_decision": { "kind": "some", "value": { "hgb": 11.2, "unit": "g/dL" } }
  corrected value (different tt):
    "hgb_corrected":   { "kind": "some", "value": { "hgb": 12.4, "unit": "g/dL" } }
  correction delta:
    Both Option[T] present + hgb values differ -> correction event confirmed.

  The fixture does NOT assert a boolean; it asserts Option[T] shapes from two
  different temporal coordinates (vt: T1, tt: T1) vs (vt: T1, tt: T2).
```

---

## Part 7: Acceptance Checklist for Research Agent

```text
Option[T] runtime encoding:
  ☐ OPT-1: history_at returns { "kind":"some","value":V } on hit.
  ☐ OPT-2: history_at returns { "kind":"none" } on gap.
  ☐ OPT-3: bihistory_at returns { "kind":"some","value":V } on hit.
  ☐ OPT-4: bihistory_at returns { "kind":"none" } on gap.
  ☐ OPT-5: No null returned for None case in any accessor.

SemanticIR nodes:
  ☐ SIR-1: temporal_access_node with axis:"valid_time" for history_at.
  ☐ SIR-2: temporal_access_node with axis:"bitemporal" for bihistory_at.
  ☐ SIR-3: bihistory_at node carries valid_time_ref and tx_time_ref.

OOF checks:
  ☐ OOF-A: history_at(h) with no as_of -> TypeChecker OOF-H1.
  ☐ OOF-B: history_at(h, 42) where 42:Integer -> TypeChecker OOF-BT1.
  ☐ OOF-C: bihistory_at(h, vt_only) missing tt -> TypeChecker OOF-BT3.

SparkCRM fixture:
  ☐ SPK-1: History[Integer] proof produces Option[Integer] at two as_of points.
  ☐ SPK-2: BiHistory[T] proof produces Option[T] at (vt, tt) and (vt, tt2) pairs.
  ☐ SPK-3: The two results differ (correction scenario confirmed).
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/temporal-option-and-bihistory-shape-v0
Status: done

[D] Decisions:
- Option[T] canonical JSON: { kind:"some", value:V } | { kind:"none" }.
  null is forbidden as None encoding.
- history_at: temporal_access_node, axis:"valid_time", requires as_of_ref.
- bihistory_at: temporal_access_node, axis:"bitemporal",
  requires valid_time_ref AND tx_time_ref.
- bihistory_at is always ESCAPE in v0. No CORE path for bitemporal reads.
- 5 OOF rules: OOF-H1/H2 (inherited from PROP-022); OOF-BT1..BT5 (new).
  All owned by TypeChecker (axis type and arity checks).
- SparkCRM correction fixture returns two Option[T] values at (vt,tt) vs (vt,tt2);
  not a boolean diff.
- This is PROP-022 implementation errata. No new PROP number needed.

[S] BiHistory[T] is needed quickly for SparkCRM (vt != tt divergence is common).
    Do not defer bihistory_at to a later proof iteration.

[T] 11-item acceptance checklist: OPT-1..5, SIR-1..3, OOF-A..C, SPK-1..3.

[R] Research Agent: implement history_at + bihistory_at proof per this spec.
    Use memory stubs for v0. Do not require TBackend adapter for first proof.

[Files] Changed:
- igniter-lang/docs/tracks/temporal-option-and-bihistory-shape-v0.md [NEW]
- igniter-lang/docs/agent-motion.md [updated]

[Next]:
- [Research Agent]: history_at + bihistory_at executable proof
  with Option[T] { kind:"some"/"none" } output and SPK-1..3 coverage.
- [Compiler/Grammar Expert]: temporal grammar surface (history.at / history[t] syntax)
  — deferred until proof confirms runtime shape is stable.
```
