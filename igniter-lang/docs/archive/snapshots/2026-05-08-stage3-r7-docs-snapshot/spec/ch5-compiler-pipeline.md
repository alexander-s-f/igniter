# Ch5: Compiler Pipeline

Source PROPs: PROP-018, PROP-019.1, PROP-027, PROP-028
Status: synced after `CompilerOrchestrator` switched to `emit_typed` (S3-R5-C4)

Primary evidence:

- `docs/tracks/typed-emission-stage2-source-lowering-parity-v0.md`
- `docs/tracks/bihistory-source-fixture-parity-gate-v0.md`
- `docs/tracks/orchestrator-emit-typed-switch-v0.md`
- `experiments/production_compiler_cli/`
- `experiments/stage1_close_candidate/`
- `experiments/stage2_close_candidate/`

---

## 5.1 Production Pipeline

Public compilation now routes through the typed SemanticIR emission path:

```text
source.ig
  │
  ▼ Stage 0: Parse
  ParsedProgram
  │
  ▼ Stage 1: Classify
  ClassifiedProgram
  │
  ▼ Stage 2: Typecheck
  TypedProgram
  │
  ▼ Stage 3: Emit
  SemanticIREmitter.emit_typed(TypedProgram)
  │
  ▼
  SemanticIRProgram            only on full success
  CompilationReport            always written
  │
  ▼ Stage 4: Assemble
  .igapp/ directory
  │
  ▼ Stage 5: Load
  RuntimeMachine.load(path)
```

Key invariant:

```text
SemanticIRProgram is emitted only when CompilationReport.pass_result == "ok".
OOF contracts never appear in loadable SemanticIRProgram.
```

---

## 5.2 Stage Interfaces

| Stage | Production input | Output | Skips if |
|-------|------------------|--------|----------|
| Parse | source.ig | ParsedProgram | parse error -> OOF/error report |
| Classify | ParsedProgram | ClassifiedProgram | parse error |
| Typecheck | ClassifiedProgram | TypedProgram | classify OOF |
| Emit | TypedProgram | SemanticIRProgram + CompilationReport | typecheck OOF |
| Assemble | CompilationReport + SemanticIRProgram | `.igapp/` | `pass_result != "ok"` |
| Load | `.igapp/` | LoadResult / CompatibilityReport | invalid manifest/report/contract |

`SemanticIREmitter#emit_typed(typed_program)` is the production emitter entry.
It is the only Stage 2+ lowering path used by `CompilerOrchestrator`.

---

## 5.3 Legacy Parsed Emitter

`SemanticIREmitter#emit(parsed_program, sample_input:)` remains available as a
Stage 1 legacy/internal comparison path.

It is retained for:

- Stage 1 golden comparison;
- direct parsed-emitter regression fixtures;
- historical parity harness evidence.

It is not the production `CompilerOrchestrator` path for Stage 2+ language
surfaces.

The legacy parsed path may OOF or omit Stage 2 nodes that the typed path lowers
correctly. That mismatch is now recorded as legacy parity delta evidence, not
as a blocker for the production compiler path.

---

## 5.4 Public Behavior Delta From S3-R5-C4

Before the orchestrator switch, public compile used parsed emission:

```text
Parser -> Classifier -> TypeChecker -> emit(parsed) -> Assembler
```

After S3-R5-C4, public compile uses typed emission:

```text
Parser -> Classifier -> TypeChecker -> emit_typed(typed) -> Assembler
```

This intentionally changes public behavior for valid Stage 2 surfaces:

| Surface | Before parsed production path | After typed production path |
|---------|-------------------------------|-----------------------------|
| OLAPPoint access | could OOF or emit no SemanticIR | lowers to `olap_access_node` |
| stream fold | could OOF or emit no SemanticIR | lowers to `stream_input_node`, `window_decl_node`, `fold_stream_node` |
| History access | could OOF or emit no SemanticIR | lowers to `temporal_input_node`, `temporal_access_node` |
| BiHistory access | proof-local / not source-comparable until gate | source fixture lowers to temporal nodes |
| invariant severity | parsed path missed typed invariant surfaces | typed path lowers invariant nodes/surfaces |

This is a correction toward the Stage 2 language, not a relaxation of OOF
rules. Invalid sources still stop before loadable SemanticIR.

One known public diagnostic category delta:

```text
negative unresolved symbol:
  before switch: classifier_oof
  after switch:  typechecker_oof
```

The compile still fails; the owning diagnostic stage is later because the typed
pipeline carries more structure before rejection.

---

## 5.5 Operator Name Resolution

Generic stdlib names are pre-resolution names. Before SemanticIR emission, the
TypeChecker resolves them to monomorphic forms:

```text
stdlib.numeric.add + Integer args  -> stdlib.integer.add
stdlib.numeric.add + Float args    -> stdlib.float.add
stdlib.numeric.add + Decimal[N]    -> stdlib.decimal.add
```

Unresolved generic operator names must not survive into loadable SemanticIR.
They are OOF before assembly.

---

## 5.6 Accepted Source Surfaces

The production pipeline currently accepts and lowers:

```text
CORE contracts: input, compute, output
Decimal types with scale annotation
TypeDecl structural records
module + import declarations
Collection[T] stdlib surfaces
History[T] and BiHistory[T] typed temporal access
stream T with bounded fold_stream
OLAPPoint point access
invariant severity declarations
.igapp/ assembly for CORE / STREAM / TEMPORAL artifact surfaces
```

Still not canon or not production-executable:

```text
parser coordinate syntax for temporal reads remains unsettled
TEMPORAL RuntimeMachine evaluate is guarded/refused without approved support
production RuntimeMachine temporal cache is not enabled
Ledger / live TBackend read-write binding is not authorized
```

---

## 5.7 Conformance Cases

Minimum conformance cases:

```text
C-1  Pure CORE contract -> SemanticIR fragment_class "core"
C-2  Decimal type annotation -> Decimal[N] propagated correctly
C-3  OOF unresolved symbol -> CompilationReport pass_result "oof" or "error"
C-4  OLAPPoint source -> typed path emits olap_access_node
C-5  stream fold source -> typed path emits stream_input/window/fold nodes
C-6  History source -> typed path emits temporal_input_node + temporal_access_node
C-7  BiHistory source -> typed path emits bitemporal temporal nodes
C-8  invariant severity source -> typed path emits invariant lowering
C-9  Assembler refuses non-ok reports and writes no loadable `.igapp/`
C-10 TEMPORAL `.igapp/` loads for inspection but evaluate is guarded/refused
```

---

## 5.8 Evidence Notes

S3-R5-C4 switched production orchestration:

```ruby
classified = @classifier.classify(parsed, sample_input: resolved_sample_input)
typed = @typechecker.typecheck(classified)
compilation = @emitter.emit_typed(typed)
```

The previous parsed production call:

```ruby
compilation = @emitter.emit(parsed, sample_input: resolved_sample_input)
```

is now legacy/comparison behavior.

Proofs recorded for the switch:

```text
production_compiler_cli_proof: PASS
stage1_close_candidate: PASS
stage2_close_candidate: PASS
release-gate: PASS, publish not attempted
```
