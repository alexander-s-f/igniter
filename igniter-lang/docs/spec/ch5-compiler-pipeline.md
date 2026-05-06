# Ch5: Compiler Pipeline

Source PROPs: PROP-018, PROP-019.1
Status: accepted (four-stage model); partial (Slice 0 + TypeChecker proof pending)

---

## 5.1 Four-Stage Pipeline (PROP-019.1 §Part 3)

```
source.ig
  │
  ▼ Stage 0: Parse
  ParsedProgram (JSON)              ← stable boundary
  │
  ▼ Stage 1: Classify  (Pass 0)
  ClassifiedProgram (JSON)          ← CORE / ESCAPE / OOF per node
  │  if pass_result == "oof" → skip Stage 2
  ▼ Stage 2: Typecheck  (Pass 1)
  TypedProgram (JSON)               ← resolved types, no unresolved T
  │  if pass_result == "oof" → skip Stage 3
  ▼ Stage 3: Emit
  SemanticIRProgram (JSON)          ← only on full success
  +
  CompilationReport (JSON)          ← always written
  │
  ▼ Assemble
  .igapp/ directory                 ← loadable bundle
  │
  ▼ Load
  RuntimeMachine.load(path)         → trusted CompatibilityReport
```

**Key invariant**: SemanticIRProgram is ONLY emitted when `CompilationReport.pass_result == "ok"`.
OOF contracts NEVER appear in a loadable SemanticIRProgram.

---

## 5.2 Stage Interfaces

| Stage | Input | Output | Skips if |
|-------|-------|--------|----------|
| Parse | source.ig | ParsedProgram | parse error → OOF report |
| Classify | ParsedProgram | ClassifiedProgram | — |
| Typecheck | ClassifiedProgram | TypedProgram | classify OOF |
| Emit | ClassifiedProgram + TypedProgram | SemanticIRProgram | typecheck OOF |
| Assemble | CompilationReport + SemanticIRProgram | .igapp/ | pass_result != "ok" |

---

## 5.3 Operator Name Resolution (PROP-019.1 §Part 5)

`stdlib.numeric.add` is a **pre-resolution name** (generic).

Before SemanticIR emission, the TypeChecker resolves it to the monomorphic form:

```
stdlib.numeric.add + Integer args  →  stdlib.integer.add
stdlib.numeric.add + Float args    →  stdlib.float.add
stdlib.numeric.add + Decimal[N]    →  stdlib.decimal.add
```

Unresolved `stdlib.numeric.add` in SemanticIR → OOF-P1 (must be caught before emission).

---

## 5.4 Accepted v0 Source Subset (PROP-018 §Part 1)

What the Stage 1 pipeline handles:

```
✅  CORE contracts: input, compute (pure expr or stdlib call), output
✅  Decimal types with scale annotation
✅  ESCAPE contracts: read ... from "path" lifecycle :...
✅  def blocks (pure, non-recursive)
✅  TypeDecl (structural records)
✅  module + import declarations
✅  Collection[T] stdlib (fold, map, filter, avg)
✅  OOF rejection: P1 (unresolved), P4 (cycle), CE4 (confidence as bool)

⏳  OOF rejection at parse time (partial — known gap)
⏳  TypeChecker proof (Slice B — not yet run)
🔴  Assembler (blocked on Slice 0 golden migration)
🔴  Stdlib execution (Slice C — not yet connected to RuntimeMachine)
```

---

## 5.5 Conformance Cases (PROP-018 §Part 5)

The minimal set of conformance cases required for Stage 1:

```
C-1  Pure CORE contract (Add) → SemanticIR with fragment_class: "core"
C-2  Decimal type annotation → Decimal[2] propagated correctly
C-3  Scoped read contract → SemanticIR with fragment_class: "escape"
C-4  OOF — unresolved symbol → CompilationReport.pass_result: "oof"
C-5  OOF — Decimal scale mismatch → OOF-TC5 in diagnostics
```
