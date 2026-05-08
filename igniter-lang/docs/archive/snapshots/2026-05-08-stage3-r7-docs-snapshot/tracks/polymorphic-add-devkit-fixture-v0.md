# Track: Polymorphic Add Devkit Fixture v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`
Artifacts:
- `igniter-lang/source/polymorphic_add.ig`
- `igniter-lang/source/polymorphic_add.parsed_program.expected.json`

---

## Frame

This slice adds a tiny source-level pressure fixture for bounded polymorphism:

```text
trait Additive[T]
impl Additive[Integer]
impl Additive[Float]
contract_shape AddShape[T]
contract Add[T: Additive] implements AddShape[T]
```

The goal is not a typechecker, not a final grammar promise, and not a parser
implementation. The goal is to pin the semantic boundary:

```text
polymorphic source reuse
  -> compile-time trait/impl resolution
  -> monomorphic SemanticIR specialization
  -> RuntimeMachine sees no unresolved overload
```

Guiding principle:

```text
Polymorphism makes contracts more reusable without making runtime meaning
ambiguous. No unresolved overloads in RuntimeMachine. No OO inheritance as the
primary model.
```

---

## Source Horizon

Read horizon:

- `docs/current-status.md`
- `docs/proposals/PROP-013-stdlib-fold-aggregate-v0.md`
- `docs/proposals/PROP-015-grammar-module-system-v0.md`
- `docs/runtime-model-spec-questions-v0.md`
- `docs/tracks/source-fixture-parser-acceptance-harness-v0.md`

Key constraints absorbed:

- `PROP-013` already uses bounded type parameters in stdlib signatures, but
  every operation still lowers to stable `stdlib.*` operators in SemanticIR.
- `PROP-015` explicitly defers generics and traits beyond the current v0
  grammar kernel.
- Runtime model decisions require immutable bindings, lexical resolution,
  value semantics, structural DAG evaluation, and no dynamic scope.
- Current parser harness parses only `add.ig` and `availability_projection.ig`.
  `polymorphic_add.ig` is a pressure fixture, not a current parser acceptance
  fixture.

Neighboring signal: `docs/proposals/PROP-016-polymorphism-traits-contract-shapes-v0.md`
is the formal companion proposal for this area. This track remains the compact
devkit fixture slice. The next slice should reconcile any deliberate shorthand
in this fixture with PROP-016's stricter grammar and conformance rules.

---

## Source Fixture

```text
module Lang.Examples.PolymorphicAdd

trait Additive[T] {
  def add(a: T, b: T) -> T
}

impl Additive[Integer] using stdlib.numeric.add
impl Additive[Float] using stdlib.numeric.add

contract_shape AddShape[T] {
  input a: T
  input b: T
  output sum: T
}

contract Add[T: Additive] implements AddShape[T] {
  compute sum = add(a, b)
}
```

`contract_shape` is structural conformance, not OO inheritance. It contributes
the expected contract surface for typechecking and specialization. It does not
provide state, behavior, parent methods, or dynamic dispatch.

---

## ParsedProgram Expectation

Expected shape is captured in:

```text
igniter-lang/source/polymorphic_add.parsed_program.expected.json
```

Important top-level additions beyond current `ParsedProgram`:

- `traits`: `Additive[T]` with method signature `add(T, T) -> T`
- `impls`: concrete witnesses for `Additive[Integer]` and `Additive[Float]`
- `contract_shapes`: structural input/output surface for `AddShape[T]`
- generic `contracts`: `Add[T: Additive]` with `implements AddShape[T]`

The current parser intentionally does not support `trait`, `impl`,
`contract_shape`, generic contract headers, or `implements`. A direct run of
the parser against this fixture is expected to fail until a future parser
pressure slice handles the new surface.

---

## Specialization Model

The generic contract is not loadable by RuntimeMachine. A compiler/type pass
must materialize requested specializations before SemanticIR:

```text
Add[T: Additive]
  + requested type_arg Integer
  + impl Additive[Integer] using stdlib.numeric.add
  -> Add[Integer]

Add[T: Additive]
  + requested type_arg Float
  + impl Additive[Float] using stdlib.numeric.add
  -> Add[Float]
```

Expected `Add[Integer]` SemanticIR sketch:

```json
{
  "contract_id": "Lang.Examples.PolymorphicAdd.Add[Integer]",
  "specialization_of": "Lang.Examples.PolymorphicAdd.Add",
  "type_args": { "T": "Integer" },
  "fragment_class": "core",
  "input_ports": [
    { "name": "a", "type_tag": "Integer", "lifecycle": "local" },
    { "name": "b", "type_tag": "Integer", "lifecycle": "local" }
  ],
  "compute_nodes": [
    {
      "name": "sum",
      "type_tag": "Integer",
      "expression": {
        "kind": "apply",
        "operator": "stdlib.numeric.add",
        "type_args": ["Integer"],
        "resolved_impl": "Additive[Integer]",
        "operands": [
          { "kind": "ref", "name": "a" },
          { "kind": "ref", "name": "b" }
        ]
      }
    }
  ],
  "output_ports": [
    { "name": "sum", "type_tag": "Integer", "lifecycle": "session" }
  ]
}
```

Expected `Add[Float]` is identical except `T`, input/output `type_tag`, and
`resolved_impl` are `Float` / `Additive[Float]`.

Result hash meaning must include the resolved operator identity, type args,
input values, and relevant axiom/runtime descriptors. It must not depend on a
runtime overload table or ambient host-language method lookup.

---

## Runtime Rejection Rules

[D] `add(a, b)` inside `Add[T]` is resolved before SemanticIR. The name `add`
is a trait method reference in source, not a RuntimeMachine operator.

[D] A specialization is valid only when exactly one visible impl satisfies the
bound for the requested type argument.

[D] `Add[String]` is rejected in this fixture because there is no
`impl Additive[String]`. String concatenation should use `++`,
`stdlib.string.concat`, or a future explicit `Concat[String]` contract. Numeric
`Additive` should not silently absorb string concat.

[D] RuntimeMachine.load must reject any artifact that still contains generic
type variables, unresolved trait method calls, or multiple candidate impls for
one call site.

---

## Rejected Paths

[X] Runtime overload dispatch. It makes evidence meaning depend on a live
dispatch table and breaks reproducibility.

[X] OO inheritance as the model for reuse. Contract shapes are structural
surfaces; traits are compile-time capability constraints.

[X] Implicit String `+`. It conflates numeric addition with sequence concat and
invites accidental coercion.

[X] Implementing a full typechecker in this slice. The fixture exists to show
the shape and pressure the next parser/type slices.

[X] Expanding the current parser without a bounded checker target. The parser
already has a partial acceptance track; this fixture should not destabilize it.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/polymorphic-add-devkit-fixture-v0.md
Status: done

[D] Decisions:
- Added polymorphic_add.ig as a pressure fixture, not a parser acceptance claim.
- Added expected ParsedProgram shape for trait/impl/contract_shape/generic
  contract surface.
- Generic Add must specialize to Add[Integer] and Add[Float] before SemanticIR.
- RuntimeMachine receives only monomorphic, resolved apply nodes.
- String concat is outside numeric Additive in this fixture.

[R] Recommendations:
- Keep this fixture out of current parser acceptance until a bounded parser
  pressure checker is created.
- Define coherence rules next: duplicate impls, orphan impls, import visibility,
  and specialization naming.
- Treat contract_shape as structural conformance only, not inheritance.
- Require RuntimeMachine load checks for unresolved generic variables and
  unresolved trait method calls.

[S] Signals:
- PROP-013 already needs constrained generic stdlib signatures such as
  min[T: Ordered], so Additive[T] fits the same direction.
- PROP-015 deliberately rejected generics/traits in v0; this fixture is a safe
  next pressure point rather than a contradiction.
- Runtime model decisions make compile-time resolution mandatory: lexical names,
  immutable bindings, value semantics, and DAG evaluation leave no room for
  dynamic overload meaning.

[Q] Open Questions:
- What are the exact coherence rules for impl visibility across modules?
- Should specialization ids use Add[Integer], Add$Integer, or a normalized hash?
- Is Additive a stdlib trait, or is numeric add just an axiom family with
  syntactic sugar in source?
- Where should requested specializations be declared: source, build manifest,
  or compiler entrypoint?
- Does `implements AddShape[T]` import shape ports into the contract lexical
  scope for compact fixture syntax, or must the contract redeclare all ports
  and use `implements` only as a check?
- Is `impl Additive[Integer] using stdlib.numeric.add` valid shorthand for a
  full impl body, or should v0 accept only explicit method bodies?

[Next] Proposed next slice:
- polymorphic-add-parser-pressure-check-v0:
  add a standalone checker that compares polymorphic_add.ig against the
  expected ParsedProgram shape, reconciles the fixture with PROP-016, or
  minimally extends the parser for this bounded surface without adding a full
  typechecker.
```
