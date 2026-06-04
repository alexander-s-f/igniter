# Contract Invocation Forms Memory Recovery and DX Boundary v0

Track: `contract-invocation-forms-memory-recovery-and-dx-boundary-v0`
Status: design/recovery input
Date: 2026-06-04
Authority: no implementation authority; no canonical syntax authority

## Purpose

Recover the older Agent-C `form` concept as a high-priority language-design
input, separate it from the current `form NAME -> TypeTarget` constructor-alias
pressure, and define the smallest honest route for improving contract
composition and developer experience without creating stable grammar or runtime
claims.

This document does not authorize parser, typechecker, SemanticIR, stdlib,
runtime, CLI, package, public-docs, or release changes.

## Source Evidence

Current live docs:

- `docs/spec-extension-gap-analysis.md` defines `form NAME -> TypeTarget` as a
  named constructor alias over a declared type.
- `docs/dev/canonical-semantic-model.md` and
  `docs/dev/semantic-governance-heat-map.md` keep that constructor-form surface
  as a candidate/gap, not implemented authority.
- `docs/proposals/PROP-016-polymorphism-traits-contract-shapes-v0.md` defines
  the trait/polymorphism layer used by bounded polymorphic `Add`.
- `source/polymorphic_add.ig` is parser-only pressure for `Add[T: Additive]`.

Recovered archive evidence, read-only and non-authoritative:

- `/Users/alex/dev/data/archive/igniter/playgrounds/docs/external/Agent-C/C0-Form-Concept.md`
- `/Users/alex/dev/data/archive/igniter/playgrounds/docs/external/Agent-C/C1-Stdlib-Forms.md`
- `/Users/alex/dev/data/archive/igniter/playgrounds/docs/external/Agent-C/C5-Compiler-Interface.md`
- `/Users/alex/dev/data/archive/igniter/playgrounds/docs/external/Agent-C/PROP-Forms-v0.md`
- `/Users/alex/dev/data/archive/igniter/playgrounds/docs/external/Agent-C/C7-Covenant.md`

Recovered core principle:

```text
Contracts define meaning.
Forms expose meaning.
Forms are typed aliases, not macros.
Form resolution is static.
Runtime does not resolve forms.
```

## Vocabulary Split

The word `form` currently points at two useful but different ideas. Do not merge
them silently.

| Name | Working Meaning | Example | Status |
| --- | --- | --- | --- |
| Constructor form | A named constructor alias over a declared type; produces a typed module artifact/constant. | `form population -> PopulationSpec` | Existing current-doc pressure, not implemented authority |
| Contract invocation form | A typed source spelling for invoking an already declared contract. | `form (left) "+" (right)` on `Add` | Recovered archive pressure, not canonical syntax |

Recommended docs wording:

```text
Constructor forms name typed artifacts.
Invocation forms name ways to call contracts.
Neither form creates meaning; both must lower to typed, explicit constructs.
```

## Recovered Contract Invocation Form Model

Archive model:

```igniter
contract Add[T: Numeric](left: T, right: T) -> result: T
  form (left) "+" (right)
  priority 5
  associativity :left
{
  result = left.add(right)
}
```

Meaning:

```igniter
a + b
```

lowers to:

```igniter
Add(a, b)
```

and then to SemanticIR-style explicit invocation:

```text
Invoke(Add, [a, b])
```

The form disappears before runtime. If SemanticIR still contains unresolved
operator/form names, the lowering failed.

## DX Value

Contract invocation forms directly improve composition and developer experience:

- let users write domain-shaped expressions while preserving contract meaning;
- make stdlib operations feel natural without hardcoding every operator into
  core grammar;
- keep explicit calls available as the fully qualified fallback;
- let docs, IDEs, examples, and agents surface both the readable form and the
  lowered contract call;
- move ambiguity detection into compile-time type/form resolution instead of
  runtime behavior.

The important design move is not "operator sugar." It is a disciplined contract
entrypoint model:

```text
human/agent source spelling -> static form resolution -> explicit contract call
```

## Polymorphism Relationship

Polymorphism should remain in the type/trait/contract layer, not inside `form`
itself.

Current accepted pressure already says:

```igniter
trait Additive[T] {
  def add(a: T, b: T) -> T
}

contract Add[T: Additive] implements AddShape[T] {
  compute sum = add(a, b)
}
```

Invocation forms should reference this resolved contract surface:

```igniter
contract Add[T: Additive](left: T, right: T) -> result: T
  form (left) "+" (right)
```

Open design question:

```text
Does `+` remain numeric-only through `Additive[T]`, while String/Collection use
`++`, or does a later stdlib route allow type-directed non-numeric forms under
the same token?
```

Recommended starting stance: preserve current PROP-016 policy. `+` remains
numeric `Additive[T]`; String/Collection append remains `++` or explicit
stdlib calls unless a separate stdlib/forms route changes that.

## Syntax Candidate Matrix

| Candidate | Shape | Strength | Risk | Recommendation |
| --- | --- | --- | --- | --- |
| Archive explicit form | `form (left) "+" (right)` | Names parameter binding directly; good for trust/audit | Verbose for common operators | Best recovery baseline |
| Shorthand directive | `form: infix "+"` or `form: +` | Pleasant DX; matches user memory of `form:` | Hides binding/priority/associativity unless expanded | Treat as future sugar over explicit form |
| Forms block | `forms { infix "+" left: left right: right }` | Scales to many forms and metadata | More syntax surface | Consider during proposal authoring |
| Constructor form reuse | `form population -> PopulationSpec` | Already documented current pressure | Different concept; would overload `form` dangerously | Keep separate as constructor forms |

The right form to introduce into docs now is therefore not a final syntax
promise. It is this boundary phrase:

```text
Contract invocation forms are typed, statically resolved aliases for explicit
contract calls. The archive syntax `form (left) "+" (right)` is the baseline
specimen; `form:` shorthand remains a DX candidate until proposal review.
```

## Boundary Invariants

1. No contract, no invocation form.
2. No type match, no form resolution.
3. No runtime dispatch for forms.
4. No macros.
5. No arbitrary user grammar.
6. No ambient global syntax injection.
7. Explicit contract call remains available.
8. Form selection evidence must be representable in compiler/link artifacts
   before any runtime/productization claim.
9. Constructor forms and invocation forms must remain distinguishable in docs
   until proposal text decides final names.
10. Before v1, no stable API or stable grammar promise is created.

## Proposed FormKind Recovery

Recovered FormKind taxonomy is valuable as a guardrail, not accepted canon:

| Kind | Example | First-Slice Stance |
| --- | --- | --- |
| Infix form | `a + b` | High priority |
| Prefix call form | `uuid()` / `error("msg")` | Medium priority |
| Postfix method form | `items.sum` | High priority for stdlib DX |
| Method call form | `items.take(10)` | Medium priority |
| Block method form | `items.where { it.active }` | High value, larger binder surface |
| Keyword/block form | `guard cond else errors`, `for x in xs { ... }` | Split into later design |

Recommended first slice: infix plus postfix only, with explicit rejection of
block/binder/keyword forms until their own route.

## Minimum Proposal Questions

Any future proposal or authoring route should answer:

1. Are constructor forms and invocation forms separate keywords, separate
   clauses, or one keyword with distinct grammar positions?
2. Is the baseline source syntax `form (left) "+" (right)` accepted, or does
   the language use `form:` shorthand that expands to it?
3. Which FormKinds are first-slice and which are deferred?
4. How do forms interact with imports/modules and trust levels?
5. How does resolution handle ambiguity?
6. What artifact records the chosen form/contract lowering?
7. How does this align with PROP-016 trait monomorphization?
8. Does the current `+` numeric-only decision remain intact?
9. Which OOF diagnostics name missing form, ambiguity, forbidden trust, and
   unresolved operator cases?
10. What proof fixtures are needed before parser/typechecker work?

## Route Options

| Option | Description | Pros | Cons | Recommendation |
| --- | --- | --- | --- | --- |
| Docs-only recovery boundary | Record concept, vocabulary split, and next proposal route. | Fast, prevents memory loss | Does not test syntax | Do now |
| Proposal authoring route | Create a `PROP-0XX` for contract invocation forms. | Moves toward canon deliberately | Needs facts and wording review | Open next |
| Facts/intake route | Survey current parser, PROP-016, current `form` gap, archives. | Reduces overclaim risk | Slower | Useful if C4-A wants more evidence |
| Proof fixture route | Add `.ig` pressure fixture for Add form lowering. | Concrete compiler pressure | Too early without proposal boundary | Defer |
| Implementation route | Parser/typechecker/form resolver edits. | Fast progress | Premature authority | Closed |

## Recommendation

Accept the concept as recovered high-priority design pressure, not as canonical
syntax.

Open next:

```text
Card: S3-R248-C1-D
Track: contract-invocation-forms-and-form-directive-boundary-v0
Route: UPDATE
Goal: Decide the proposal boundary for contract invocation forms, including
the relationship between archive `form (left) "+" (right)`, possible `form:`
shorthand, current constructor-form pressure, PROP-016 polymorphic Add, and
future stdlib DX.
```

Recommended C1-D read scope:

- this track doc;
- `docs/spec-extension-gap-analysis.md`;
- `docs/archive/history/history-s17-forms-research-snapshot.md`;
- `docs/proposals/PROP-016-polymorphism-traits-contract-shapes-v0.md`;
- `source/polymorphic_add.ig`;
- archive Agent-C `C0`, `C1`, `C5`, `PROP-Forms-v0`, `C7`;
- `docs/tracks/future-syntax-pressure-formalization-v0.md`;
- `docs/meta-proposals/syntax-pressure-registry-v0.md` if present.

Recommended C4-A answer to prefer:

```text
Proceed to proposal-boundary authoring for contract invocation forms.
Do not authorize parser/typechecker/SemanticIR implementation yet.
Keep `form:` shorthand as candidate sugar, not accepted syntax.
Keep constructor forms and invocation forms separate until the proposal decides
their final vocabulary.
Keep stable grammar/API/runtime/public/release claims closed.
```

## Closed Surfaces

Closed until a later explicit authorization:

- parser implementation;
- typechecker implementation;
- SemanticIR emission changes;
- stdlib form registry;
- runtime form handling;
- `igc run` widening;
- `.igapp` / `.igbin` artifact schema changes;
- compiler passport emission;
- public docs claims;
- stable grammar or stable API claims;
- production, Spark, release, public performance, certification, or portability
  claims.
