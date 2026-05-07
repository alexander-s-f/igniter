# History Type Proof v0

Role: `[Igniter-Lang Research Agent]`
Track: `history-type-proof-v0`
Status: done
Date: 2026-05-07

## Horizon

Stage 1 is closed and remains the regression baseline.
`History[T]` is a Stage 2 / Tier 1 feature from PROP-022.
The first proof should demonstrate value-over-time, not the whole temporal
system.
Time stays explicit through `as_of`; there is no ambient runtime clock.
The runtime side may use a proof-local memory history stub.

## Goal

Turn `history-type-proof-planning-v0` into the smallest executable proof path
for `History[T]`.

The proof should answer one question:

```text
Given two append observations for the same subject, does a contract reading
History[Integer] at an explicit as_of point project the correct Option[Integer]?
```

## Decisions

[D] Use only `History[Integer]` for the first proof.

[D] Do not include `BiHistory[T]`, `stream T`, `OLAPPoint`, temporal aggregates,
corrections, compaction, subscriptions, or production TBackend adapters.

[D] Model append as synthetic proof input, not as source-language mutation.
The proof seeds a memory history backend with append observations before
evaluation.

[D] Model projection as point access:

```text
history_at(job_count_history, as_of) -> Option[Integer]
```

This keeps the first syntax surface function-shaped. Later grammar work can
map `history.at(as_of)` or `history[as_of]` to the same semantic node.

[D] Use PROP-022's canonical SemanticIR wording for the executable artifact:
`temporal_input_node` plus `temporal_access_node`.

[D] Treat the read as ESCAPE because it touches a TBackend-like substrate.
The point projection is deterministic once its explicit `as_of` and append
evidence are fixed.

## Minimal Source Fixture Sketch

Future source:

```text
experiments/history_type_proof/history_integer_point_access.ig
```

Sketch:

```text
module Fixture.HistoryTypeProof

contract TechnicianJobCountAt {
  input technician_id: String
  input as_of: DateTime

  escape history_read

  read job_count_history: History[Integer]
    from "technicians/{technician_id}/job_count"
    lifecycle :durable

  compute current_count = history_at(job_count_history, as_of)

  output current_count: Option[Integer] lifecycle :session
}
```

Negative source:

```text
module Fixture.HistoryTypeProof

contract TechnicianJobCountWithoutAsOf {
  input technician_id: String

  escape history_read

  read job_count_history: History[Integer]
    from "technicians/{technician_id}/job_count"
    lifecycle :durable

  compute current_count = history_at(job_count_history)

  output current_count: Option[Integer] lifecycle :session
}
```

The negative should fail before SemanticIR with `OOF-H1`.

## Proof Data

The proof-local backend seeds append observations:

```json
[
  {
    "kind": "history_append_observation",
    "subject": "technicians/tech-synthetic-1/job_count",
    "valid_from": "2026-05-01T00:00:00Z",
    "value": 7,
    "value_type": "Integer"
  },
  {
    "kind": "history_append_observation",
    "subject": "technicians/tech-synthetic-1/job_count",
    "valid_from": "2026-05-05T00:00:00Z",
    "value": 9,
    "value_type": "Integer"
  }
]
```

Evaluation input:

```json
{
  "technician_id": "tech-synthetic-1",
  "as_of": "2026-05-06T10:00:00Z"
}
```

Expected projection:

```json
{
  "current_count": { "some": 9 }
}
```

The compact proof artifact should also include a second projection check:

```text
as_of = 2026-05-03T10:00:00Z -> { "some": 7 }
```

This proves value-over-time rather than only current-value lookup.

## Expected Pass Chain

```text
Parser
  -> ParsedProgram
  -> ClassifiedProgram
  -> TypedProgram
  -> SemanticIRProgram
  -> .igapp/
  -> RuntimeMachine.load(...)
  -> RuntimeMachine.evaluate(...)
```

### Parser

Must become real implementation:

```text
History[Integer]
Option[Integer]
DateTime
read ... from ... lifecycle ...
history_at(job_count_history, as_of)
```

Parser output should carry structured generic `TypeRef`, not opaque strings:

```json
{
  "kind": "type_ref",
  "name": "History",
  "params": [
    { "kind": "type_ref", "name": "Integer", "params": [] }
  ]
}
```

May remain proof-local for the first executable slice:

```text
@temporal annotation syntax
method syntax: history.at(as_of)
index syntax: history[as_of]
```

### Classifier

Must become real implementation:

```text
read x: History[T] -> fragment_class: escape
required_caps includes "history_read"
history_at requires explicit DateTime argument or TemporalCtx
missing as_of -> OOF-H1
```

May remain proof-local:

```text
Detailed TBackend adapter class selection
History[T] subtyping into BiHistory[T]
Numeric[T] aggregate checks
```

### TypeChecker

Must become real implementation:

```text
History[T]
Option[T]
DateTime
history_at(History[T], DateTime) -> Option[T]
```

The accepted TypedProgram must contain no unresolved type variables.

May remain proof-local:

```text
Option unwrap operators
History[T] range access
History[T] aggregates
History[Record] field-sensitive typing
```

### SemanticIR

Must become real implementation:

```json
{
  "kind": "temporal_input_node",
  "name": "job_count_history",
  "type": { "constructor": "History", "element_type": "Integer" },
  "axis": "single",
  "store_ref": "technicians/{technician_id}/job_count",
  "as_of_ref": "as_of"
}
```

```json
{
  "kind": "temporal_access_node",
  "name": "current_count",
  "source_ref": "job_count_history",
  "access": "point",
  "time_ref": "as_of",
  "result_type": { "constructor": "Option", "element_type": "Integer" }
}
```

May remain proof-local:

```text
Canonical provenance packet shape for every history access
Temporal aggregate nodes
OLAP unification
```

### .igapp Assembler

Must become real implementation:

```text
manifest.json
semantic_ir_program.json
compilation_report.json
contracts/*.json
requirements.json
```

`requirements.json` should include:

```json
{
  "capabilities": { "required_caps": ["history_read"] },
  "temporal": { "requires_as_of": true }
}
```

May remain proof-local:

```text
Backend adapter descriptor negotiation
Production package location
```

### RuntimeMachine

Must become proof-local first:

```text
MemoryHistoryBackend.append(subject, valid_from, value, observation_ref)
MemoryHistoryBackend.read_as_of(subject, as_of)
```

Read rule:

```text
select latest append with valid_from <= as_of
return Option[T]
```

Runtime proof must emit or expose evidence links:

```text
history_access_observation
  subject: technicians/tech-synthetic-1/job_count
  as_of: 2026-05-06T10:00:00Z
  selected_append_ref: <append observation for value 9>
  result: { some: 9 }
```

Must become real implementation later:

```text
RuntimeMachine capability check for history_read
RuntimeMachine evaluation support for temporal_access_node
CompatibilityReport remains trusted after load
checkpoint/resume preserves explicit as_of horizon
```

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
golden/history_integer_point_access.semantic_ir_program.json
golden/history_integer_point_access.compilation_report.json
golden/negative_history_missing_as_of.compilation_report.json
out/history_integer_point_access.igapp/
history_type_proof_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb
```

Expected PASS lines:

```text
history.append_seed_observations: ok
parser.history_integer_fixture: ok
classifier.history_read_escape: ok
typechecker.history_at_option_integer: ok
semanticir.temporal_input_node: ok
semanticir.temporal_access_node: ok
assembler.history_igapp: ok
runtime.load_history_igapp_trusted: ok
runtime.evaluate_as_of_2026_05_03: ok
runtime.evaluate_as_of_2026_05_06: ok
negative.missing_as_of_oof_h1: ok
```

## Acceptance Checklist For Implementation Slice

```text
[ ] Source fixture parses without parse_errors
[ ] Parser emits structured History[Integer] and Option[Integer] TypeRefs
[ ] Classifier marks history read ESCAPE and requires history_read
[ ] TypeChecker resolves history_at -> Option[Integer]
[ ] Missing as_of produces OOF-H1 before SemanticIR
[ ] Positive SemanticIRProgram uses temporal_input_node
[ ] Positive SemanticIRProgram uses temporal_access_node
[ ] Positive .igapp/ assembles with requires_as_of and history_read metadata
[ ] RuntimeMachine.load(.igapp/) returns trusted CompatibilityReport
[ ] Runtime evaluation at 2026-05-03 returns some(7)
[ ] Runtime evaluation at 2026-05-06 returns some(9)
[ ] Runtime output links to selected append observation
[ ] stage1_close_candidate remains PASS
```

## Risks And Boundaries

[R] The first proof should not introduce source-language append. Append belongs
in TBackend semantics and should be proven as fixture setup until write/correction
semantics have their own track.

[R] Parser support for `read ... from ... lifecycle ...` may be the largest
grammar delta. If it is too large, the first executable proof may start from a
hand-authored ParsedProgram and mark parser acceptance as a separate neighbor
track.

[R] `Option[T]` JSON encoding should be fixed before goldens are written. Use
`{ "some": value }` and `{ "none": true }` unless Compiler/Grammar chooses a
different canonical form.

[R] Keep `temporal_access_node` as the fixture node name to match PROP-022
literally.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: history-type-proof-v0
Status: done

[D] Decisions
- First executable proof is History[Integer] point projection only.
- Append is proof-local seed evidence, not language mutation.
- Projection uses explicit as_of and emits temporal_access_node.
- Missing as_of is OOF-H1 before SemanticIR.

[S] Shipped / Signals
- Defined minimal source fixture and negative fixture sketch.
- Defined proof-local append observations and two as_of projection checks.
- Split parser/typechecker/runtime responsibilities from proof-local stubs.

[T] Tests / Proofs
- Documentation slice only.
- Future command: ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb

[R] Risks / Recommendations
- If parser read/generic TypeRef support is too large, start executable proof
  from hand-authored ParsedProgram and split parser acceptance into neighbor work.
- Settle Option[T] runtime JSON encoding before writing goldens.

[Next] Suggested next slice
- history-type-point-access-proof-v0: implement the bounded experiment with
  MemoryHistoryBackend, OOF-H1 negative, .igapp assembly, and RuntimeMachine load/eval.
```
