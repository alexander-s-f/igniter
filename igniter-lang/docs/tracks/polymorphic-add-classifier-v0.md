# Track: Polymorphic Add — Classifier v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/polymorphic-add-classifier-v0
Status: done
Date: 2026-05-06
Depends on: PROP-016, polymorphic-add-parser-pressure-map-v0
Source fixture: `igniter-lang/source/polymorphic_add.ig`
ParsedProgram: `igniter-lang/source/polymorphic_add.parsed_program.expected.json`

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — must implement parser acceptance first
  (polymorphic-add-parser-acceptance-v0). This track defines what comes after.
- `[Igniter-Lang Bridge Agent]` — no action. Monomorphized SemanticIR shape
  is already specified in PROP-016 §Part 9.

---

## Current Horizon

ParsedProgram accepts the polymorphic_add.ig surface (pending Research Agent
parser slice). This track defines what three passes do next:
Pass 0 (ClassifiedProgram), Pass 1 (TypedProgram), and SemanticIR lowering.
The invariant from PROP-016 is fixed: no type variables survive to SemanticIR.

---

## Stage Map

```text
ParsedProgram (parser output — strings only, no resolution)
  -> Pass 0: ClassifiedProgram
       trait env, impl env, coherence checks, fragment classification,
       generic contract tagging, qualified ref resolution
  -> Pass 1: TypedProgram
       T substitution per specialization request, implements check,
       trait method resolution, concrete typed nodes
  -> SemanticIR Lowering
       one ContractIR per monomorphization, no type variables, impl erased
  -> CompiledProgram (.igapp)
       RuntimeMachine.load(...)
```

---

## Pass 0: ClassifiedProgram

### 0-A. Trait Environment (TraitEnv)

Input: `parsed_program.traits[]`

For each trait node:

```text
TraitEnv[trait_name] = {
  name:        String,                    -- "Additive"
  type_params: [String],                  -- ["T"]
  methods:     [TraitMethodSig]
}

TraitMethodSig = {
  name:        String,                    -- "add"
  params:      [{ name, type_param }],    -- type_param is a string like "T"
  return_type: String                     -- "T"
}
```

Result: `classified_program.trait_env` — a map from trait name to TraitEnvEntry.

**No resolution yet.** Types remain as strings (type variable names or concrete names).
Duplicate trait name in the same module → OOF-CL1 (see §Rejection Rules).

---

### 0-B. Impl Environment (ImplEnv)

Input: `parsed_program.impls[]`

For each impl node:

```text
ImplEnv[(trait_name, concrete_type)] = {
  trait_name:    String,          -- "Additive"
  concrete_type: String,          -- "Integer"
  kind:          :using | :body,
  operator_ref:  String | nil,    -- "stdlib.numeric.add"  (for :using)
  methods:       [ImplMethod]     -- (for :body, empty for :using)
}
```

**Qualified ref resolution (for `using`):**

`stdlib.numeric.add` is resolved against the axiom table:

```text
STDLIB_AXIOM_TABLE["stdlib.numeric.add"] = {
  kind:        :tier1_axiom,
  operator_id: "stdlib.numeric.add",
  signature:   "(Integer, Integer) -> Integer"  -- generic: (T: Numeric, T) -> T
}
```

If the qualified ref is not in the axiom table → OOF-CL5 (unresolved qualified ref).

**Fragment class of an impl:**

```text
:using stdlib.*  -> CORE  (axiom is Tier 1, no escape)
:body (pure)     -> CORE
:body with TBackend read or FFI -> ESCAPE (or OOF if undeclared)
```

---

### 0-C. Coherence Checks

Applied after TraitEnv and ImplEnv are built. These map directly to PROP-016 CR-1/2/3.

**CR-1 — No orphan impls:**

```text
For each impl in ImplEnv:
  The impl must be declared in the same module as:
    (a) the trait, OR
    (b) the concrete type.
  "stdlib.numeric.add" implements "Additive" for "Integer":
    Additive is declared in this module -> CR-1 PASS.
  If neither -> OOF-CL3 (orphan impl).
```

In this fixture all impls are in `Lang.Examples.PolymorphicAdd`, same
module as the `trait Additive` declaration → CR-1 passes for both.

**CR-2 — At most one impl per (trait, type):**

```text
For each (trait_name, concrete_type) pair:
  count impls -> must be exactly 1.
  0 -> not a coherence error yet (missing impl detected at specialization time).
  2+ -> OOF-CL2 (duplicate impl).
```

**CR-3 — Impl completeness:**

```text
For each impl:
  Look up TraitEnv[trait_name].methods.
  For :using impls: the qualified ref must cover all trait methods.
    "stdlib.numeric.add" for Additive[Integer]:
      Additive has one method "add(T,T)->T".
      stdlib.numeric.add is the operator for "add". -> CR-3 PASS.
  For :body impls: every trait method must have an ImplMethod entry.
  Missing method -> OOF-CL4 (incomplete impl).
```

---

### 0-D. Contract Shape Registration (ShapeEnv)

Input: `parsed_program.contract_shapes[]`

```text
ShapeEnv[shape_name] = {
  name:        String,          -- "AddShape"
  type_params: [String],        -- ["T"]
  input_ports: [PortSpec],      -- [{ name: "a", type_ann: "T" }, ...]
  output_ports:[PortSpec]       -- [{ name: "sum", type_ann: "T" }]
}

PortSpec = { name: String, type_ann: String }
```

Type annotations remain as strings at this stage. No resolution.
Duplicate shape name → OOF-CL1 variant (name collision).

---

### 0-E. Generic Contract Tagging

Input: `parsed_program.contracts[]`

A contract is **generic** if `type_params` is non-empty.

```text
ClassifiedContract = {
  name:          String,                  -- "Add"
  is_generic:    Bool,                    -- true
  type_params:   [TypeParamBound],        -- [{name:"T", bounds:[...]}]
  implements:    ShapeRef | nil,          -- {name:"AddShape", type_args:["T"]}
  body:          [ClassifiedBodyDecl],
  fragment_class: :generic_pending        -- not yet :core/:escape/:oof
                                          -- concrete fragment assigned at specialization
}
```

**Fragment classification of the generic body:**

Walk body declarations and expressions:
- All refs (`a`, `b`) are input port refs → CORE candidate.
- `add(a, b)` is a call to a trait method name. At Pass 0 the name `add`
  is recorded as `trait_method_call("add")`, not yet resolved.
  Fragment is `CORE candidate` pending trait method resolution.
- No escape, no TBackend read, no FFI → fragment_class for concrete
  specializations will be `:core` (confirmed at Pass 1).

---

### 0-F. ClassifiedProgram Shape

```text
ClassifiedProgram = {
  module:           String,
  source_hash:      String,
  trait_env:        Map[String, TraitEnvEntry],
  impl_env:         Map[(String,String), ImplEnvEntry],
  shape_env:        Map[String, ShapeEnvEntry],
  contracts:        [ClassifiedContract],
  types:            [TypeDecl],
  functions:        [ClassifiedDef],
  classify_errors:  [ClassifyError]     -- non-empty -> halt
}
```

**[D] ClassifiedProgram still contains type variable strings.**
It carries resolution annotations (operator_ref, fragment_class) but
does NOT substitute T. Substitution is Pass 1.

---

## Pass 1: TypedProgram

### Input: ClassifiedProgram + specialization requests

A specialization request is the set of concrete type arguments to apply
to a generic contract. For this fixture:

```text
specialization_requests = [
  { contract: "Add", type_args: { "T" => "Integer" } },
  { contract: "Add", type_args: { "T" => "Float"   } }
]
```

**[Q-1] Where do specialization requests come from?** See §Open Questions.

---

### 1-A. Type Substitution

For each specialization request `{ contract: "Add", type_args: { "T" => "Integer" } }`:

```text
1. Clone the ClassifiedContract for "Add".
2. Substitute all occurrences of "T" with "Integer" in:
   - type_param bounds  (Additive["T"] -> Additive["Integer"])
   - implements ref     (AddShape["T"] -> AddShape["Integer"])
   - body decl type_annotations
   - expr type refs (none in this fixture body)
3. Produce a MonomorphicContractDraft:
   name:            "Add[Integer]"
   specialization_of: "Add"
   type_args:       { "T" => "Integer" }
   body:            (substituted clone)
```

**[D] Substitution is purely textual at this point** — strings are replaced
with strings. No type inference yet. Type checking follows immediately after.

---

### 1-B. Trait Method Resolution

For each `trait_method_call` node in the substituted body:

```text
Call("add", [ref("a"), ref("b")]) in Add[Integer]:
  1. Look up "add" in TraitEnv["Additive"].methods -> found.
  2. "Additive" is bound on "T" which is now "Integer".
  3. Look up ImplEnv[("Additive", "Integer")] -> found:
       operator_ref: "stdlib.numeric.add"
  4. Resolve call -> apply("stdlib.numeric.add", [ref("a"), ref("b")])
  5. Signature check: stdlib.numeric.add(Integer, Integer) -> Integer. PASS.
```

Result node:
```json
{
  "kind": "apply",
  "operator": "stdlib.numeric.add",
  "resolved_impl": "Additive[Integer]",
  "type_args": ["Integer"],
  "operands": [
    { "kind": "ref", "name": "a" },
    { "kind": "ref", "name": "b" }
  ]
}
```

If no impl found for the requested type → OOF-TY1 (missing impl at call site).

---

### 1-C. Implements Check

For `Add[Integer] implements AddShape[Integer]`:

```text
1. Resolve ShapeEnv["AddShape"] with T := "Integer":
   input_ports:  [{ name:"a", type_ann:"Integer" }, { name:"b", type_ann:"Integer" }]
   output_ports: [{ name:"sum", type_ann:"Integer" }]

2. The Add[Integer] body declares:
   input_ports: [inferred from AddShape] -> "a": Integer, "b": Integer
   output_ports: [inferred from AddShape] -> "sum": Integer

   NOTE: In this fixture, Add's body has only `compute sum`.
   Input and output ports are inherited from the shape via implements.
   The classifier must pull shape ports into the contract's typed port list
   when the contract itself omits explicit input/output declarations.

   [D] For generic contracts that declare `implements`, missing input/output
   ports are satisfied by the shape. The shape is authoritative for port
   names and types. The contract body must not contradict the shape.

3. For each shape input port: contract must have a matching input port.
   (satisfied via shape inheritance)
4. For each shape output port: contract must have a matching output port.
   "sum" must be produced. The compute node "sum" exists. PASS.
5. Type match: shape output "sum: T[Integer]" == compute node "sum: Integer". PASS.

Result: implements check PASS. Recorded as:
  "implements_check": [{ "shape": "AddShape[Integer]", "result": "pass" }]
```

Shape mismatch → OOF-TY2 (implements check failure).

---

### 1-D. Port Concretization

After implements check, the MonomorphicContractDraft gets explicit ports:

```text
TypedContract["Add[Integer]"] = {
  name:           "Add[Integer]",
  specialization_of: "Add",
  type_args:      { "T": "Integer" },
  fragment_class: :core,
  input_ports:    [
    { name: "a", type_tag: "Integer", lifecycle: "local" },
    { name: "b", type_tag: "Integer", lifecycle: "local" }
  ],
  compute_nodes:  [
    { name: "sum", type_tag: "Integer",
      expression: { kind: "apply", operator: "stdlib.numeric.add",
                    resolved_impl: "Additive[Integer]",
                    operands: [ref("a"), ref("b")] } }
  ],
  output_ports:   [
    { name: "sum", type_tag: "Integer", lifecycle: "session" }
  ],
  implements_check: [{ shape: "AddShape[Integer]", result: "pass" }]
}
```

Lifecycle defaults:
- inputs: `:local` (PROP-014 §Semantic interpretation)
- compute nodes: `:session` (CORE default)
- outputs: match compute node lifecycle

---

### 1-E. TypedProgram Shape

```text
TypedProgram = {
  module:         String,
  source_hash:    String,
  specializations: [TypedContract],   -- one per request
  shapes:         Map[String, ConcreteShapeDescriptor],
  type_errors:    [TypeError]         -- non-empty -> halt
}
```

**[D] TypedProgram contains zero type variables.** Every `"T"` has been
replaced by `"Integer"` or `"Float"`. No further substitution is needed.

---

## SemanticIR Lowering

Input: `TypedProgram.specializations`

One ContractIR is emitted per TypedContract.

### ContractIR for Add[Integer]

```json
{
  "contract_id":        "Lang.Examples.PolymorphicAdd.Add[Integer]",
  "specialization_of":  "Lang.Examples.PolymorphicAdd.Add",
  "type_args":          { "T": "Integer" },
  "fragment_class":     "core",
  "input_ports": [
    { "name": "a", "type_tag": "Integer", "lifecycle": "local" },
    { "name": "b", "type_tag": "Integer", "lifecycle": "local" }
  ],
  "compute_nodes": [
    {
      "node_id":   "node_sum",
      "name":      "sum",
      "type_tag":  "Integer",
      "lifecycle": "session",
      "expression": {
        "kind":          "apply",
        "operator":      "stdlib.numeric.add",
        "resolved_impl": "Additive[Integer]",
        "type_args":     ["Integer"],
        "operands": [
          { "kind": "ref", "name": "a" },
          { "kind": "ref", "name": "b" }
        ]
      }
    }
  ],
  "output_ports": [
    { "name": "sum", "type_tag": "Integer", "lifecycle": "session" }
  ],
  "shapes": {
    "AddShape[Integer]": {
      "input_ports":  [{"name":"a","type_tag":"Integer"},{"name":"b","type_tag":"Integer"}],
      "output_ports": [{"name":"sum","type_tag":"Integer"}]
    }
  },
  "implements": [
    { "shape": "AddShape[Integer]", "check": "passed" }
  ]
}
```

**Add[Float] is structurally identical** with `"Integer"` replaced by `"Float"`.

### SemanticIR Invariants (enforced at lowering)

```text
SIR-1: No type variable strings in any type_tag field.
        Any remaining "T", "U", etc. -> lowering error -> OOF-SIR1.

SIR-2: No unresolved trait_method_call nodes.
        Any Call(fn) where fn was a trait method and is not yet an apply(operator)
        -> lowering error -> OOF-SIR2.

SIR-3: No generic contract in SemanticIR.
        Only monomorphic ContractIRs are emitted.
        The generic template ("Add") is not in SemanticIR at all.

SIR-4: resolved_impl must name a concrete (trait, type) pair.
        "Additive[Integer]" is concrete. "Additive[T]" is not -> OOF-SIR1.
```

---

## OOF / Rejection Rules

### Classify-time (Pass 0)

| Code | Condition | Action |
|------|-----------|--------|
| OOF-CL1 | Duplicate trait or shape name in module | Compile error |
| OOF-CL2 | Two impls for same (trait, type) | Compile error: CR-2 violation |
| OOF-CL3 | Orphan impl (neither trait module nor type module) | Compile error: CR-1 violation |
| OOF-CL4 | Impl missing a required trait method | Compile error: CR-3 violation |
| OOF-CL5 | `using` ref not in axiom table | Compile error: unresolved qualified ref |

### Type-time (Pass 1)

| Code | Condition | Action |
|------|-----------|--------|
| OOF-TY1 | No impl for (trait, concrete_type) at call site | Compile error: missing impl |
| OOF-TY2 | Implements check fails (missing port, type mismatch) | Compile error |
| OOF-TY3 | Type mismatch after substitution | Compile error |
| OOF-TY4 | Specialization requested for non-generic contract | Compile error |
| OOF-TY5 | Duplicate specialization request for same (contract, type_args) | Warning / deduplicate |

### SemanticIR-time

| Code | Condition | Action |
|------|-----------|--------|
| OOF-SIR1 | Type variable string survives to lowering | Fatal lowering error |
| OOF-SIR2 | Unresolved trait method call survives to lowering | Fatal lowering error |

### Specific fixture cases

**Add[Integer]:** all checks pass. Accepted.

**Add[Float]:** all checks pass. Accepted.

**Add[String]:**
- Pass 1: look up ImplEnv[("Additive", "String")] → not found.
- OOF-TY1: "No impl of Additive for String."
- Compile error. Not emitted to SemanticIR.
- Per PROP-016: `String is NOT Additive. Use ++ or stdlib.string.concat.`

**Add[T] without specialization:** generic template is never loaded by
RuntimeMachine. Only monomorphic specializations are in SemanticIR.
RuntimeMachine.load rejects any artifact still containing type variable
strings (SIR-1 gate).

---

## Separation Summary

| Concern | Stage | Lives in |
|---------|-------|----------|
| Trait/shape/impl registration | Pass 0 | ClassifiedProgram |
| Qualified ref resolution | Pass 0 | ClassifiedProgram.impl_env |
| Coherence (CR-1/2/3) | Pass 0 | ClassifiedProgram.classify_errors |
| T substitution | Pass 1 | TypedProgram |
| Implements check | Pass 1 | TypedProgram |
| Trait method → apply() | Pass 1 | TypedProgram |
| One ContractIR per mono | Lowering | SemanticIR |
| No type vars | Lowering invariant | SemanticIR (enforced) |
| No runtime overload | Runtime boundary | RuntimeMachine.load |

---

## Open Questions

[Q-1] **Specialization request source.** In this fixture, who asks for
`Add[Integer]` and `Add[Float]`? Three options:
- (A) A build manifest / compiler entrypoint lists requested specializations.
- (B) Every call site `Add[Integer]{...}` in other contracts triggers it.
- (C) The `impl` declarations implicitly create specializations for all
  `(trait, type)` pairs covered.
Recommendation: (A) for v0 — explicit build manifest entry. Option (C) would
create all mathematically possible specializations, which is wasteful.

[Q-2] **Shape port inheritance.** When `contract Add[T] implements AddShape[T]`
omits explicit `input`/`output` declarations, does the compiler infer them from
the shape? The fixture's Add body has only `compute sum`. Recommendation: yes —
shape ports are authoritative; the contract body need not re-declare them.
This must be a formal decision before the TypedProgram implementation.

[Q-3] **Generic template in CompiledProgram.** Should the generic `Add` template
appear in the `.igapp` artifact at all, or only the monomorphic specializations?
Recommendation: include the template as a metadata descriptor only (not as a
loadable ContractIR). It supports tooling introspection without violating SIR-3.

[Q-4] **`using` shorthand completeness.** `impl Additive[Integer] using stdlib.numeric.add`
provides only the `add` method. If `Additive` gains more methods (e.g., `zero`),
the `using` shorthand becomes incomplete (OOF-CL4). Should `using` be expanded
to include a full method map, or require a full body impl at that point?
Recommendation: OOF-CL4 at classify time if trait methods > operator arity
of the `using` ref. Force explicit body for multi-method traits.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/docs/tracks/polymorphic-add-classifier-v0.md
Status: done

Neighbors:
- [Igniter-Lang Research Agent]: implement parser acceptance first, then
  this classifier spec is the implementation target for the semantic pass.
- [Igniter-Lang Bridge Agent]: no action yet.

[D] Decisions:
- Pass 0 (ClassifiedProgram) builds TraitEnv, ImplEnv, ShapeEnv.
  No type variable substitution. Coherence checks run here.
- Pass 1 (TypedProgram) does substitution, implements check, and
  trait method -> apply() resolution. One TypedContract per specialization.
- SemanticIR lowering emits one ContractIR per monomorphization. Generic
  template does not appear as a loadable ContractIR.
- Implements check at Pass 1: shape ports are authoritative when the
  contract omits explicit input/output declarations.
- Add[String] is rejected at OOF-TY1 (no impl of Additive for String).
  This is a compile error, not a runtime error.
- "stdlib.numeric.add" is resolved against an axiom table at Pass 0.
  Unresolved qualified ref -> OOF-CL5.
- No runtime overload table. No dynamic dispatch. Impl is erased in SemanticIR;
  only the concrete operator ref ("stdlib.numeric.add") survives.
- Three SemanticIR invariants enforced at lowering:
  SIR-1: no type variable strings.
  SIR-2: no unresolved trait method calls.
  SIR-3: only monomorphic ContractIRs emitted.

[R] Recommendations:
- Answer Q-1 (specialization request source) before implementing TypedProgram.
  Build manifest (option A) is simplest for v0.
- Answer Q-2 (shape port inheritance) before implementing implements check.
  Shape-authoritative ports make the Add fixture body valid as written.
- Do not implement a full type inference engine. Substitution is string
  replacement. Type checking is axiom signature lookup. Keep it simple.
- The STDLIB_AXIOM_TABLE should be a static file, not computed at classify
  time. It is the Tier 1 axiom registry from PROP-004b.

[S] Signals:
- The classifier for this fixture is small: one trait, two impls, one shape,
  one generic contract, two specializations. The total work is bounded.
- OOF-TY1 (Add[String]) exercises the most important runtime safety rule:
  "no unresolved overloads reach RuntimeMachine." This is the core invariant.
- The resolved SemanticIR for Add[Integer] is identical to the hand-authored
  add.igapp fixture contract (with added specialization_of metadata). The
  pipeline is closing.

[T] Tests / Proofs:
- ClassifiedProgram: trait_env has Additive, impl_env has (Additive,Integer)
  and (Additive,Float), shape_env has AddShape, classify_errors is empty.
- TypedProgram: two TypedContracts (Add[Integer], Add[Float]),
  implements_check pass for both, type_errors empty.
- Add[String]: OOF-TY1, type_errors non-empty, halts before SemanticIR.
- SemanticIR: two ContractIRs, both SIR-1/2/3 compliant, operator is
  "stdlib.numeric.add" (not "add"), no "T" in any type_tag field.

[Files] Changed:
- igniter-lang/docs/tracks/polymorphic-add-classifier-v0.md  [NEW]
- igniter-lang/docs/README.md  [updated — track registered]
- igniter-lang/docs/agent-motion.md  [updated — position + log]

[Q] Open Questions:
- Q-1: Specialization request source (build manifest vs call-site vs impl coverage).
- Q-2: Shape port inheritance for contracts that omit explicit ports.
- Q-3: Generic template presence in .igapp artifact.
- Q-4: `using` completeness for multi-method traits.

[X] Rejected:
- Runtime overload table: incompatible with CORE determinism and reproducibility.
- Dynamic dispatch: OOF-P1 (PROP-016 §Part 8).
- Monomorphization at parse time: ParsedProgram must retain type variables
  as strings for agent inspection and incremental tooling.
- Implements check at parse time: requires type env not available at parse.
- Add[String] as valid: no impl of Additive for String. String concat uses ++.

[Next] Proposed next slices:
1. [Architect Supervisor] Resolve Q-1 and Q-2 before implementation begins.

2. [Research Agent]: polymorphic-add-classifier-proof-v0
   Implement ClassifiedProgram + TypedProgram as a standalone Ruby script
   (like runtime_machine_memory_proof.rb). Consume the expected ParsedProgram
   JSON, produce ClassifiedProgram + two TypedContracts, verify Add[String]
   is rejected.

3. [Compiler/Grammar Expert]: polymorphic-add-semanticir-emission-v0
   Define the SemanticIR .igapp fixture for Add[Integer] and Add[Float].
   This closes the loop: source -> ParsedProgram -> ClassifiedProgram ->
   TypedProgram -> SemanticIR -> .igapp -> RuntimeMachine.load.
```
