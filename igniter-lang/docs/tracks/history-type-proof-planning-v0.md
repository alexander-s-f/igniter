# History Type Proof Planning v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/history-type-proof-planning-v0`
Status: done
Date: 2026-05-07

## Goal

Prepare the first Tier 1 executable proof for `History[T]` without
implementing it yet.

Source spec:

```text
docs/proposals/PROP-022-history-type-constructor-v0.md
```

## Decisions

[D] The first proof should cover only `History[T]`, not `BiHistory[T]`.

[D] The element type should be `Integer`, not a record, to avoid record-field
typing and Option unwrap pressure in the first slice.

[D] The operation should be single point access:

```text
history_at(history, as_of) -> Option[T]
```

This is equivalent to PROP-022 `h.at(t)` / `h[t]`, but it avoids adding method
call syntax in the first proof. Method-call syntax can lower to the same
SemanticIR node later.

[D] The proof must keep time explicit: `as_of` is a contract input. No ambient
`now`.

[D] The proof should treat the `History[T]` read as ESCAPE because it reads from
a TBackend-like temporal substrate. The access node itself is typed and
deterministic once evidence is provided.

## Minimal Fixture Sketch

Proposed future source file:

```text
experiments/history_type_proof/history_integer_point_access.ig
```

Sketch:

```text
module Fixture.HistoryProof

contract TechnicianJobCountAt {
  input technician_id: String
  input as_of: DateTime

  escape history_read

  read job_count_history: History[Integer]
    from "technician/{technician_id}/job_count"
    lifecycle :durable

  compute current_count = history_at(job_count_history, as_of)

  output current_count: Option[Integer] lifecycle :session
}
```

Synthetic runtime evidence:

```json
[
  { "valid_from": "2026-05-01T00:00:00Z", "value": 7 },
  { "valid_from": "2026-05-05T00:00:00Z", "value": 9 }
]
```

Evaluation input:

```json
{
  "technician_id": "tech/synthetic-1",
  "as_of": "2026-05-06T10:00:00Z"
}
```

Expected output:

```json
{ "current_count": { "some": 9 } }
```

The exact `Option[T]` JSON encoding can be settled by Compiler/Grammar Expert
before implementation. For a first proof, `{ "some": value }` and
`{ "none": true }` are sufficient and inspectable.

## Expected Pass Chain

```text
Parser
  -> accepts History[Integer], Option[Integer], DateTime
  -> emits ParsedProgram with read + compute history_at call

Classifier
  -> marks input declarations CORE
  -> marks read job_count_history ESCAPE because it touches history/TBackend
  -> records required capability: history_read
  -> classifies current_count as ESCAPE-derived value observation
  -> emits no OOF for explicit as_of

TypeChecker
  -> resolves generic TypeRef History[Integer]
  -> resolves generic TypeRef Option[Integer]
  -> resolves DateTime primitive
  -> checks history_at(History[T], DateTime) -> Option[T]
  -> rejects History access without explicit as_of as OOF-H1

SemanticIR
  -> emits temporal input/read descriptor for job_count_history
  -> emits history_access node for current_count
  -> no unresolved type variables
  -> no generic executable operator

.igapp assembler
  -> packages SemanticIRProgram + CompilationReport
  -> includes capability/requirement metadata for history_read
  -> refuses OOF-H1 negative report

RuntimeMachine
  -> load(.igapp/) -> trusted CompatibilityReport
  -> evaluate with synthetic history evidence
  -> history read stub returns point value at as_of
  -> checkpoint/resume remains trusted
```

## Required Additions

### Parser

[D] `History[Integer]` and `Option[Integer]` should become structured generic
TypeRefs, not opaque strings.

Current parser already accepts generic-looking annotations as strings for many
cases, but the proof should upgrade the representation to a consistent shape:

```json
{
  "kind": "type_ref",
  "name": "History",
  "params": [
    { "kind": "type_ref", "name": "Integer", "params": [] }
  ]
}
```

[Q] `@temporal` annotation is in PROP-022, but the first proof can defer
annotation syntax and use `escape history_read` plus explicit `as_of`.

### Classifier

[D] Add a narrow history read classification rule:

```text
read x: History[T] from "...":
  fragment_class: escape
  required_caps: ["history_read"]
```

[D] Add OOF-H1:

```text
history_at(history, t) requires t to resolve to explicit DateTime input or CORE
DateTime expression.
```

### TypeChecker

[D] Add generic `TypeRef` resolution for:

```text
History[T]
Option[T]
DateTime
```

[D] Add stdlib/history function signature:

```text
history_at(History[T], DateTime) -> Option[T]
```

[X] Do not add aggregate operations (`avg`, `sum`, `rollup`) yet.

### SemanticIR Emitter

[D] Add temporal/history read shape aligned with PROP-022:

```json
{
  "kind": "temporal_input_node",
  "name": "job_count_history",
  "type": { "constructor": "History", "element_type": "Integer" },
  "axis": "single",
  "store_ref": "technician/{technician_id}/job_count",
  "as_of_ref": "as_of"
}
```

[D] Add the first access node:

```json
{
  "kind": "history_access",
  "name": "current_count",
  "source_ref": "job_count_history",
  "access": "point",
  "time_ref": "as_of",
  "result_type": {
    "constructor": "Option",
    "element_type": "Integer"
  }
}
```

`history_access` can later be reconciled with PROP-022's
`temporal_access_node` name; the proof should pick one canonical spelling
before writing goldens. Recommendation: use `history_access` in experiment code
but map it to `temporal_access_node` in final PROP-019.1 envelope if
Compiler/Grammar prefers the PROP wording.

### Assembler

[D] Preserve the Stage 1 `.igapp/` shape and add only the minimum metadata:

```text
requirements.capabilities.required_caps includes "history_read"
requirements.temporal.requires_as_of == true
```

### RuntimeMachine

[D] Add a proof-local history read stub, not a general TBackend implementation.

Required stub behavior:

```text
history_read(subject, as_of)
  -> select latest interval/value with valid_from <= as_of
  -> return Option[T]
```

[D] Runtime output must be evidence-producing, not raw value only. The access
must link to synthetic history observations.

## Smallest Executable Proof

Directory:

```text
experiments/history_type_proof/
```

Files:

```text
history_integer_point_access.ig
negative_history_missing_as_of.ig
history_type_proof.rb
golden/history_integer_point_access.parsed.json
golden/history_integer_point_access.classified.json
golden/history_integer_point_access.typed.json
golden/history_integer_point_access.semantic_ir.json
golden/history_integer_point_access.compilation_report.json
golden/negative_history_missing_as_of.compilation_report.json
out/history_integer_point_access.igapp/
history_type_proof_summary.json
```

Proof checks:

```text
parser.history_type_ref: ok
classifier.history_read_escape: ok
typechecker.history_at_option_integer: ok
semanticir.history_access_node: ok
assembler.history_igapp_written: ok
runtime.load_history_igapp_trusted: ok
runtime.evaluate_history_at: ok
negative.history_missing_as_of_oof_h1: ok
stage1_regression.close_candidate_pass: ok
```

## Acceptance Checklist For Future Slice

### Positive

```text
[ ] history_integer_point_access.ig parses with parse_errors: []
[ ] ParsedProgram contains structured History[Integer] TypeRef
[ ] ClassifiedProgram marks history read as ESCAPE with history_read capability
[ ] TypedProgram resolves history_at -> Option[Integer]
[ ] SemanticIRProgram includes one temporal/history input node
[ ] SemanticIRProgram includes one history_access/temporal_access node
[ ] CompilationReport pass_result == "ok"
[ ] .igapp/ is written
[ ] RuntimeMachine.load(.igapp/) returns trusted CompatibilityReport
[ ] RuntimeMachine.evaluate(...) returns current_count some(9)
[ ] checkpoint/resume remains trusted
```

### Negative

```text
[ ] Missing explicit as_of produces OOF-H1
[ ] OOF-H1 writes CompilationReport only
[ ] OOF-H1 emits no SemanticIRProgram
[ ] OOF-H1 writes no .igapp/
```

### Regression

```text
[ ] stage1_close_candidate remains PASS
[ ] production_compiler_cli_proof remains PASS
[ ] stdlib.numeric.add remains rejected at runtime
```

## Non-Goals

[X] No `BiHistory[T]`.

[X] No `stream T`.

[X] No `OLAPPoint[T, Dims]` implementation.

[X] No `avg`, `sum`, `rollup`, `changes`, `gaps`, or volatility operations.

[X] No ambient `now`.

[X] No production TBackend adapter.

## Open Questions

[Q] Should the canonical SemanticIR node be named `history_access` or
`temporal_access_node` for the first proof?

[Q] Should `Option[T]` runtime JSON use `{ "some": value }`, `{ "kind":
"some", "value": value }`, or nullable raw values with evidence metadata?

[Q] Should `History[T]` reads require an explicit `escape history_read`
declaration, or should `read x: History[T]` imply the capability?

[Q] Should parser support `@temporal` annotation in the first implementation
slice, or defer it until after point access works?

## Changed Files

```text
docs/tracks/history-type-proof-planning-v0.md
```

## Next

[Next] `history-type-point-access-proof-v0`: implement the minimal
`History[Integer]` point-access proof described here, with OOF-H1 negative and
RuntimeMachine memory-history stub.
