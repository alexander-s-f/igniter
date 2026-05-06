# Ch3: Type System

Source PROPs: PROP-004, PROP-004 errata v0.1, PROP-021
Status: accepted (type grammar, rules); pending proof (typechecker experiment not yet run)
Proof: experiments/typechecker/ — not yet implemented (Slice B)

---

## 3.1 Type Grammar (PROP-004 §Type Grammar)

```
Type :=
    Integer | Float | String | Bool | Timestamp | Date | Symbol
  | Decimal[N]                    -- fixed-point, N decimal places
  | Record { f₁: T₁, ..., fₙ: Tₙ }
  | Variant { case₁: T₁ | ... | caseₙ: Tₙ }
  | Collection[T]                 -- finite, bounded
  | Option[T]                     -- Some(T) | None
  | Result[T, E]                  -- Ok(T) | Err(E)
  | Map[K, V]                     -- derived from group_by
  | Store[T]                      -- TBackend-backed storage
  | History[T]                    -- temporal storage (single axis)
  | BiHistory[T]                  -- bitemporal storage (two axes)
  | TemporalCtx[policy]           -- contract-level time parameter
  | Projection[T, horizon]        -- named temporal slice
  | T where φ                     -- refinement type (CORE if φ decidable; else ESCAPE)
  | Obs[kind, T]                  -- observation packet
  | Ref[T]                        -- mutable reference (ESCAPE)
  | ContractRef[In, Out]          -- contract as value
  | Any                           -- top type (dynamic boundary)
  | Never                         -- bottom type (unreachable)
```

**Stage 1 subset** (what the TypeChecker v0 handles):
`Integer, Float, String, Bool, Decimal[N], Record{}, Collection[T], Option[T], Result[T,E]`

`History[T]`, `BiHistory[T]`, `OLAPPoint[T,Dims]`, `~T` → **Stage 2** (reserved, OOF if used in Stage 1).

---

## 3.2 Subtyping (PROP-004 §Subtyping)

```
Record width subtyping:   { a: T, b: U, c: V } <: { a: T, b: U }
Record depth subtyping:   { a: T } <: { a: U }  if T <: U
Collection covariant:     Collection[T] <: Collection[U]  if T <: U
Option covariant:         Option[T] <: Option[U]          if T <: U
ContractRef contravariant on inputs, covariant on outputs
Ref invariant:            Ref[T] <: Ref[U]  only if T = U
```

---

## 3.3 Typing Rules (PROP-004 §Typing Rules)

```
Rule 1 Literal:        ⊢ 42 : Integer;  ⊢ "x" : String;  ⊢ true : Bool
Rule 2 Variable:       Γ(x) = T  ⊢  x : T
Rule 3 Field access:   e : { f: T, ... }  ⊢  e.f : T
Rule 4 Built-in call:  fn : (T₁..Tₙ → U)  e₁:T₁..eₙ:Tₙ  ⊢  fn(e₁..eₙ) : U
Rule 5 Case:           e : Variant { case₁:T₁ | ... }
                       ⊢  case e of case₁(x) -> e₁ : U   if each branch : U
Rule 6 Temporal:       e : Store[T]  Tt : TemporalCtx
                       ⊢  e.at(Tt) : T
```

---

## 3.4 Temporal Capability System (PROP-004 §Temporal Capability)

**Tt as contract-level parameter**: every contract receives an implicit `Tt: TemporalCtx`
parameter. Evaluations without explicit `Tt` are OOF (Law 6).

**Storage type capabilities**:
```
Store[T]      — as_of-capable (point read at Tt)
History[T]    — as_of + replay-capable (Stage 2)
BiHistory[T]  — requires bi_temporal ESCAPE capability (Stage 2)
```

**Projection[T, horizon]**: type-level representation of a named temporal slice.
Reproducible iff `horizon` contains no `:latest` references.

---

## 3.5 Annotation-Driven Type Resolution (PROP-021 §Part 3)

The TypeChecker v0 is **annotation-driven**: declared `type_annotation` is ground truth.
Inferred type must match; mismatch → `OOF-TC1`.

```
parse_type_annotation("Integer")     → TypeRef::Base(:integer)
parse_type_annotation("Decimal[2]")  → TypeRef::Decimal(scale: 2)
parse_type_annotation("Option[String]") → TypeRef::Generic(:option, [TypeRef::Base(:string)])
```

**Three environments**:
```
TypeEnv     — global: type aliases, struct fields
ShapeEnv    — per-contract: node name → TypeRef
OperatorEnv — stdlib operator signatures
```

---

## 3.6 Type-Level OOF Rules (PROP-021 §Part 6)

```
OOF-TC1  Declared type_annotation does not match inferred type
OOF-TC2  Field access on non-record type
OOF-TC3  Call arity mismatch
OOF-TC4  Collection[T] where element type is unknown
OOF-TC5  Decimal scale mismatch in add (must be equal)
OOF-CE4  ConfidenceLabel used as Bool (enforced with full inferred types)
OOF-DM2  Decimal division by statically-known zero
```

**Decimal rules**:
- `Decimal[A] + Decimal[B]`: requires `A == B` → result `Decimal[A]`; else `OOF-TC5`
- `Decimal[A] * Decimal[B]`: result `Decimal[A+B]` (always valid)

---

## 3.7 TypedProgram Shape (PROP-021 §Part 5)

```json
{
  "kind": "typed_program",
  "pass_result": "ok | oof | skipped",
  "grammar_version": "0.1.0",
  "source_path": "source/add.ig",
  "contracts": [
    {
      "name": "Add",
      "fragment_class": "core",
      "nodes": [
        { "name": "a",   "node_kind": "input",   "resolved_type": "Integer" },
        { "name": "b",   "node_kind": "input",   "resolved_type": "Integer" },
        { "name": "sum", "node_kind": "compute",
          "resolved_type": "Integer",
          "operator": "stdlib.integer.add",
          "arg_refs": ["a", "b"] },
        { "name": "result", "node_kind": "output", "resolved_type": "Integer" }
      ]
    }
  ],
  "diagnostics": []
}
```

**Skipping rule**: if `ClassifiedProgram.pass_result == "oof"`, TypeChecker
returns `pass_result: "skipped"` and forwards classifier diagnostics unchanged.
