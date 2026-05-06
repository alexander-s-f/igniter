# Ch4: Fragment Classification

Source PROPs: PROP-003, PROP-003 errata v0.1, PROP-020
Status: accepted; PASS proven
Proof: experiments/classifier_pass_proof/ — add, claim_evidence, evidence_linked_alert + OOF negatives

---

## 4.1 Three Fragment Classes (PROP-003)

```
CORE    Decidably valid, provably terminating.
        = Stratified Datalog fragment.
        = PTIME, confluent, deterministic.
        Classification is static (no runtime info needed).

ESCAPE  Capability-gated external dependency.
        = Declared, named, receipt-producing.
        = Propagates: through >> and embed; NOT across ||.

OOF     Out-of-fragment violation.
        = Compile error: emits failure_observation.
        = Never reaches SemanticIR.
```

**Classification is Pass 0** — runs before type checking. This preserves type-checking decidability.

---

## 4.2 Construct Classification Table (PROP-003 §Construct Classification)

| Construct | Class | Notes |
|-----------|-------|-------|
| `input` | CORE | Always |
| `const` | CORE | Always |
| `compute` (pure expr) | CORE | Propagates from deps |
| `compute` (with ESCAPE dep) | ESCAPE | Propagation |
| `output` | CORE or ESCAPE | Inherits from source |
| `read ... lifecycle` | ESCAPE | TBackend read |
| `read ... tenant_free: true, lifecycle: :durable` | CORE | Special case only |
| `escape Name` | ESCAPE | Explicit boundary |
| `fold(Collection[T], ...)` | CORE | TR-1: bounded |
| `fold_stream(...) @window_bounded` | CORE result | ESCAPE call, CORE result |
| `stream name: Type` | ESCAPE | Always unbounded |
| `T where φ` (decidable φ) | CORE | Refinement type |
| `T where φ` (arbitrary φ) | ESCAPE | `refinement_predicate` |
| `||` composition of ESCAPE | ESCAPE not propagated | ESCAPE stays local |
| `>>` with ESCAPE | ESCAPE propagated | Sequential chain |
| Unknown DSL extension | OOF | Default |

---

## 4.3 Named Escape Vocabulary v0 (PROP-003 §Named Escape Vocabulary)

The escape vocabulary is **closed** in v0:

```
stream_input           — stream name: Type (unbounded source)
bi_temporal            — BiHistory[T] corrections (append + audit trail)
refinement_predicate   — T where φ with arbitrary predicate
causal_clock           — LogicalTimestamp / vector clock operations
platform_extension_code — FFI / Ruby interop / external library calls
soft_real_time         — deadline annotations (Stage 3)
```

Unknown escape names → OOF (not silently accepted).

---

## 4.4 OOF Detection Rules (PROP-020 §Part 4)

```
OOF-P1   Unresolved symbol (not in program scope or SymbolTable)
OOF-P2   Pipeline operator (|>) used inside contract body
OOF-P4   Compute cycle (DAG dependency forms a cycle)
OOF-CE4  ConfidenceLabel value used as Bool
OOF-OS2  Alert emitted without evidence links
OOF-S1   fold_stream without @window_bounded or @count_bounded
OOF-S2   stream declaration without matching window
OOF-S3   ESCAPE construct inside fold_stream accumulator
OOF-S4   stream value accessed outside fold_stream
```

**Severity**:
- `error` → blocks SemanticIR emission for the containing contract
- `warning` → passes through; downstream passes see the warning

---

## 4.5 ClassifiedProgram Shape (PROP-020 §Part 5)

```json
{
  "kind": "classified_program",
  "pass_result": "ok | oof | error",
  "grammar_version": "0.1.0",
  "source_path": "source/add.ig",
  "contracts": [
    {
      "name": "Add",
      "fragment_class": "core | escape | oof",
      "nodes": [
        { "name": "a",   "node_kind": "input",   "class": "core" },
        { "name": "b",   "node_kind": "input",   "class": "core" },
        { "name": "sum", "node_kind": "compute",
          "class": "core",
          "deps": ["a", "b"],
          "call": "stdlib.numeric.add" },
        { "name": "result", "node_kind": "output", "class": "core" }
      ]
    }
  ],
  "diagnostics": []
}
```

**SymbolTable** (PROP-020 §Part 2):
- `program` scope: imports, types, functions
- `contract` scope: per-contract node names
- Pipeline names must NOT appear in contract body → OOF-P2

---

## 4.6 Propagation Rules (PROP-020 §Part 7)

```
1. Input/Const/EscapeDecl → their class directly
2. ReadDecl               → escape (unless tenant_free + durable)
3. ComputeDecl            → max(class(dep₁), ..., class(depₙ))
                            where oof > escape > core
4. One OOF dep            → entire compute chain is OOF
5. ESCAPE across ||       → does NOT propagate (independent contracts stay clean)
6. ESCAPE through >>      → propagates (sequential chain is infected)
```

---

## 4.7 Decidability (PROP-003 §Decidability Proof Sketch)

Classification is decidable in O(n) + O(V+E) time:
- Single pass over nodes in dependency order (topological sort of DAG)
- Per-node classification is a lookup + max-class propagation
- Cycle detection (OOF-P4) runs in O(V+E) with DFS
- Total: linear in program size
