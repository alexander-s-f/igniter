# Ch2: Source Surface and Grammar

Source PROPs: PROP-014, PROP-015
Status: accepted (grammar kernel); partial (OOF rejection at parse time)
Proof: experiments/parser/ — 61 specs, add.ig + availability_projection.ig + polymorphic_add.ig

---

## 2.1 Guiding Constraints (PROP-014 §Guiding Constraints)

```
C-1  Syntax must map directly to SemanticIR node types.
     No syntax without a SemanticIR equivalent.
C-2  Every construct must declare its observable properties at source level.
     No implicit defaults hiding semantic choices.
C-3  The source language must be human-writable.
C-4  The source language must be agent-readable.
C-5  Parser output (ParsedProgram) is a stable JSON boundary.
     All downstream passes consume ParsedProgram, not raw source.
```

**Decision**: SemanticIR is the stable toolchain center. The parser is a frontend
pass that emits ParsedProgram. It does not own evaluation, lifecycle, or runtime.

---

## 2.2 Grammar Kernel v0 BNF (PROP-015 §Part 4)

```text
SourceFile    := ModuleDecl? ImportDecl* TopDecl*

ModuleDecl    := "module" ModPath
ImportDecl    := "import" ModPath ("." "{" Name ("," Name)* "}")?
ModPath       := Name ("." Name)*

TopDecl       := ContractDecl | TypeDecl | FunctionDecl | ExternalDecl

ContractDecl  := "contract" Name "{" BodyDecl* "}"
BodyDecl      := EscapeDecl | InputDecl | ReadDecl | ComputeDecl
               | SnapshotDecl | WindowDecl | OutputDecl

EscapeDecl    := "escape" Name
InputDecl     := "input" Name ":" TypeRef
ReadDecl      := "read"  Name ":" TypeRef "from" StrLiteral LifecycleAnn?
ComputeDecl   := "compute" Name "=" Expr
SnapshotDecl  := "snapshot" Name "=" Expr LifecycleAnn?
WindowDecl    := "window" StrLiteral "{" WindowOpt* "}"
WindowOpt     := ("kind" | "unit" | "on_close") ":" Name
OutputDecl    := "output" Name ":" TypeRef LifecycleAnn?
LifecycleAnn  := "lifecycle" LifecycleClass
LifecycleClass:= ":local"|":session"|":window"|":durable"|":audit"

TypeDecl      := "type" Name "{" FieldDecl* "}"
FieldDecl     := Name ":" TypeRef "?"?

FunctionDecl  := "def" Name "(" Params? ")" "->" TypeRef "{" Body "}"
Params        := Param ("," Param)*
Param         := Name ":" TypeRef
Body          := Stmt* Expr
Stmt          := "let" Name "=" Expr

ExternalDecl  := "external" LangId Name "{" ExternalOpt* "}"
LangId        := "ruby" | "rust" | "js" | "wasm"

TypeRef       := "Integer"|"Float"|"String"|"Bool"|"Timestamp"|"Date"|"Symbol"
               | Name
               | "Collection[" TypeRef "]"
               | "Option["     TypeRef "]"
               | "Result["     TypeRef "," TypeRef "]"
               | "Map["        TypeRef "," TypeRef "]"

Expr          := Literal | Ref | BinOp | Call | IfExpr | BlockExpr
               | FieldAccess | IndexAccess | Lambda | ArrayLit | RecordLit
               | LetExpr

Literal       := IntLit | FloatLit | StrLiteral | BoolLit | NilLit
BinOp         := Expr Op Expr
Op            := "+" | "-" | "*" | "/" | "==" | "!=" | "<" | ">" | "<=" | ">="
               | "&&" | "||" | "++"
Call          := Name "(" (Expr ("," Expr)*)? ")"
IfExpr        := "if" Expr "{" Expr "}" ("else" "{" Expr "}")?
BlockExpr     := "{" Stmt* Expr "}"
Lambda        := "(" Params? ")" "->" Expr | Name "->" Expr
FieldAccess   := Expr "." Name
IndexAccess   := Expr "[" Expr "]"
ArrayLit      := "[" (Expr ("," Expr)*)? "]"
RecordLit     := "{" (Name ":" Expr ("," Name ":" Expr)*)? "}"
LetExpr       := "let" Name "=" Expr   -- inside Body only
```

**Note**: This is NOT a final grammar. It is the minimal syntax kernel
sufficient to produce SemanticIR for the two canonical fixture contracts
(Add, AvailabilityProjection). Full grammar is a separate track.

---

## 2.3 ParsedProgram Shape (PROP-014 §Part 3, PROP-018 §Part 2)

The parser emits a stable JSON structure:

```json
{
  "kind": "parsed_program",
  "grammar_version": "0.1.0",
  "source_path": "source/add.ig",
  "source_hash": "sha256:<hex>",
  "module": "Lang.Examples.Add",
  "imports": [],
  "types": [],
  "functions": [],
  "contracts": [
    {
      "kind": "contract",
      "name": "Add",
      "escapes": [],
      "inputs": [
        { "kind": "input_decl", "name": "a", "type": "Integer" },
        { "kind": "input_decl", "name": "b", "type": "Integer" }
      ],
      "reads": [],
      "computes": [
        { "kind": "compute_decl", "name": "sum",
          "expr": { "kind": "call", "fn": "stdlib.numeric.add",
                    "args": [{"kind":"ref","name":"a"}, {"kind":"ref","name":"b"}] } }
      ],
      "outputs": [
        { "kind": "output_decl", "name": "result", "type": "Integer",
          "expr": { "kind": "ref", "name": "sum" } }
      ]
    }
  ]
}
```

**ParsedProgram is a stable boundary**: all downstream passes (classifier,
typechecker, emitter) consume ParsedProgram JSON, never raw source.

---

## 2.4 def Blocks (PROP-015 §Part 1)

User-defined functions via `def`:

```
def clamp(value: Float, lo: Float, hi: Float) -> Float {
  if value < lo { lo }
  else { if value > hi { hi } else { value } }
}
```

**Semantic rules**:
- Non-recursive (self-reference is OOF-F1)
- Pure: no reads, no effects, no ambient state
- Inlined at the call site in SemanticIR (no lambda node in emitted IR)
- Scope: module-level or contract-local

---

## 2.5 TypeDecl (PROP-015 §Part 2)

User-defined structural record types:

```
type ProductRef {
  id:   Integer
  sku:  String
  name: String?
}
```

**Semantic rules**:
- Structural (not nominal): two types with identical fields are compatible
- Optional fields (`?`) map to `Option[T]` in TypeEnv
- TypeDecl produces a named entry in the program's TypeEnv

---

## 2.6 Module System (PROP-015 §Part 3)

```
module Lang.Examples.Add
import Lang.Stdlib.{ fold, map, filter }
```

**Resolution rules**:
- Module path = dotted name, no filesystem path inference
- Import resolution is compile-time only
- Circular imports are OOF-M1
- Unknown import is OOF-M2

---

## 2.7 OOF Rules at Parse Stage

```
OOF-G1  Unrecognized keyword at top level
OOF-G2  Missing type annotation on input/output
OOF-G3  Malformed lifecycle class (not in LifecycleClass set)
OOF-F1  Recursive def (self-reference)
OOF-M1  Circular import
OOF-M2  Unknown import path
```

**Implementation gap**: The current parser (experiments/parser/) does not
yet reject all OOF-G constructs at parse time. This is a known Stage 1 gap.
