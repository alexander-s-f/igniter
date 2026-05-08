# Track: Future Syntax Pressure Formalization v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: `igniter-lang/future-syntax-pressure-formalization-v0`
Card: S2-R15-C4-P
Status: done
Date: 2026-05-07

---

## Purpose

Convert the current human/agent comprehension pressure into formal grammar
questions without freezing syntax and without changing the parser.

This is a pre-PROP formalization note. It does not promote any pressure fixture
to canon.

Primary artifacts read:

- `docs/reviews/2026-05-07-compiler-pipeline-gap-review.md`
- `docs/meta-proposals/syntax-density-human-agent-research-v0.md`
- `docs/meta-proposals/human-agent-comprehension-results-001-field-supply-watch-v0.md`
- `docs/meta-proposals/human-agent-comprehension-results-002-field-supply-watch-v2.md`
- `docs/meta-proposals/human-agent-comprehension-results-003-academic-sorting-structures-v0.md`
- `docs/meta-proposals/human-agent-comprehension-results-004-surface-layering-from-spec-review-v0.md`
- `docs/meta-proposals/abstraction-layering-primitive-sugar-pressure-v0.md`
- `docs/meta-proposals/data-structures-as-contract-surface-pressure-v0.md`
- `docs/meta-proposals/rust-comparison-language-pressure-v0.md`
- `experiments/human_agent_syntax_comprehension_fixture/field_supply_watch.ig`
- `experiments/human_agent_syntax_comprehension_fixture/field_supply_watch_v2.ig`
- `experiments/human_agent_syntax_comprehension_fixture/academic_sorting_structures.ig`
- `docs/proposals/accepted/PROP-015-grammar-module-system-v0.md`
- `docs/proposals/PROP-016-polymorphism-traits-contract-shapes-v0.md`
- `docs/proposals/PROP-024-olap-point-primitive-v0.md`

---

## Classification Map

Legend:

- **Canonical syntax**: should likely become direct grammar once proofed.
- **Dense sugar**: may lower to canonical nodes, but must be opt-in/proven.
- **Profile / surface alias**: human-facing facade over an already canonical
  primitive or profile.
- **Non-canon experiment**: useful specimen pressure, not proposed grammar yet.

| Construct | Current Signal | Classification | Formal Question |
|-----------|----------------|----------------|-----------------|
| `compute name = expr` | Existing contract-body node syntax | Canonical syntax | Keep as the explicit graph-node form. |
| `let name = expr` in `def`/block bodies | PROP-015 already uses local single-assignment in pure function bodies | Canonical syntax inside expression/block bodies | Enforce no rebinding, no lifecycle/evidence clauses. |
| `let name = expr` directly in contract body | Used heavily in pressure fixtures to reduce visual noise | Dense sugar over `compute` | Is contract-body `let` allowed only when no evidence/lifecycle/output metadata is attached? |
| Dense contract signature `contract Add(a: T) -> out: U` | Readable and common in fixtures | Dense sugar | Must lower to canonical input/output declarations with stable spans. |
| `mesh SupplyAnalysisMesh { ... }` | V2 improved comprehension vs `agent mesh` | Profile / surface alias | Is `mesh` a capability profile, a runtime target, or both? |
| `delegate x to Mesh capability :cap { ... }` | Strong v2 comprehension, fixed positional ambiguity | Likely canonical construct, exact syntax pre-PROP | Is delegate an expression binding, an ESCAPE declaration, or a capability call node? |
| `await_review name when cond { ... } -> override` | Strong lifecycle signal for suspend/resume | Likely canonical construct, exact syntax pre-PROP | Does it always suspend? Can it be nonblocking? What is the typed result and timeout behavior? |
| `metric regional_supply { dims ... }` | Friendlier than `olap_point`; clear analytics intent | Profile / surface alias | Should `metric` lower to `olap_point`/`OLAPPoint`, and how is it disambiguated from invariant severity `:metric`? |
| `olap_point` / `OLAPPoint[T,Dims]` | PROP-024 and Stage 2 implementation | Canonical syntax/type primitive | Keep as precise low-level term even if `metric` aliases it. |
| `variant Name[T] { case: Type }` | Rust comparison and academic fixture signal | Likely canonical syntax | Needs exhaustiveness and closed-case rules before parser work. |
| `match variant { case bind -> ... }` | Required by ADTs, readable in fixture | Likely canonical syntax | Define exhaustiveness, shadowing, and fragment rules. |
| `contract Sort[T where Ordered[T]]` | Fixture-readable but conflicts with PROP-016 spelling | Non-canon experiment | Prefer current PROP-016 `T: Ordered[T]` until an errata chooses `where`. |
| `contract Add[T: Additive]` | PROP-016 | Canonical candidate | Needs proof of constraint resolution and monomorphization. |
| `trait Ordered[T]` | PROP-016 and fixture agree on concept | Canonical candidate | Syntax mostly stable; impl resolution is the hard part. |
| `profile audited_mesh { ... }` | Strong comprehension and hides recurring defaults | Profile syntax candidate | Profiles must expand to explicit lifecycle/evidence/backend/capability fields. |
| `packet`, `event`, `view`, `receipt` | Data-shape profiles improve comprehension | Profile / surface alias | Each must declare whether it is structural, materialized, durable, audit-only, or runtime-emitted. |
| `receipt SortProof` | Academic fixture overloaded receipt/proof | Non-canon experiment | Use `proof`/`witness` for academic obligations; reserve receipt for audit artifacts. |
| `content_hash(...)` for receipt id | Reviewers flagged magic identity | Non-canon experiment | Prefer declarative receipt identity syntax if promoted. |
| Magic numeric thresholds | Reviewers understood but could not verify | Non-canon experiment | Prefer `threshold`/`const` named declarations before grammar promotion. |
| Stream method chains | Readable in review 004 | Dense sugar | Lower to `stream/window/map/filter/fold_stream` primitives after stream OOF rules remain stable. |

---

## Focus Areas

### 1. `let` vs `compute`

[D] `compute` remains the canonical contract graph-node declaration.

[D] `let` is canonical inside pure expression/block bodies because PROP-015 uses
it as single-assignment local binding.

[Q] Contract-body `let` should not be promoted until the compiler can prove
whether it lowers to:

```text
compute node       -- stable graph identity, diagnostics, dependencies
block local        -- no independent node identity
surface-only alias -- formatter rewrites to compute
```

Recommended direction:

```text
contract-body let = dense sugar over compute only in CORE contexts
```

Rules to test:

- no rebinding in the same contract scope
- no hidden output/evidence/lifecycle behavior
- generated diagnostics name the source binding, not an anonymous compute
- formatter can expand `let` to `compute` losslessly

---

### 2. `delegate`, `mesh`, and `await_review`

[D] `agent mesh` should stay non-canon. It over-associates distributed runtime
with autonomous AI.

[D] `mesh` is promising as a profile/surface alias over capability, trust, and
runtime-target metadata.

[D] `delegate ... capability ...` and `await_review ... when ...` are likely
real semantic constructs, not mere formatting sugar. Both cross CORE into
ESCAPE/lifecycle space.

Open questions:

- Does `delegate` bind an output value, a receipt, or both?
- Are retry/timeout clauses part of source syntax or profile expansion?
- Does `await_review` always suspend/resume, or can it attach a nonblocking
  warning?
- Which pass owns missing capability, invalid trust level, timeout type, and
  missing review role OOFs?

Recommended direction:

```text
mesh      -> profile/capability surface
delegate  -> ESCAPE node with required capability + trust contract
await_review -> ESCAPE node with lifecycle suspend/resume semantics
```

---

### 3. `metric` vs `OLAPPoint`

[D] `OLAPPoint[T,Dims]` remains the canonical type-level primitive.

[D] `olap_point` remains the precise low-level declaration from PROP-024.

[D] `metric` is a strong human-facing surface alias, but it must not erase the
OLAP semantics:

```text
metric regional_supply: Integer { dims ... }
  lowers to
olap_point regional_supply { measure: Integer, dimensions: ..., indexed: ... }
```

OOF risk:

```text
metric as invariant severity (:metric)
metric as analytics declaration
metric as runtime observation
```

These three meanings must have distinct AST locations and diagnostics.

---

### 4. ADT / Variant

[D] `variant` is a high-confidence canonical candidate. It is needed for
`Option`, `Result`, workflow states, academic structures, and exhaustive
matching.

Needed before parser work:

- closed-case representation in ParsedProgram
- constructor namespace rules (`nil`, `cons`, `ok`, `err`)
- exhaustive `match`
- non-exhaustive match OOF rule
- duplicate case OOF rule
- recursive variant restrictions and termination interaction

[D] `receipt` should not be reused for academic proofs. Use `proof` or `witness`
pressure for theorem/proof artifacts.

---

### 5. Generic Constraints

[D] The canonical concept is already PROP-016:

```text
contract Add[T: Additive]
```

[D] The academic fixture spelling remains non-canon:

```text
contract Sort[T where Ordered[T]]
```

Formal question:

```text
Should Stage 3 keep PROP-016's colon constraints, switch to where constraints,
or support both with one canonical formatter output?
```

Recommendation:

```text
parser accepts only one canonical spelling until monomorphization is proven
```

OOF risks:

- unresolved trait impl
- ambiguous impl
- constraint cycle
- generic template emitted to runtime
- type variable survives in SemanticIR

---

## OOF Risk Map

| Risk | Ambiguous Syntax Cause | Likely Owner |
|------|------------------------|--------------|
| local binding treated as graph node accidentally | contract-body `let` vs `compute` | Classifier / TypeChecker |
| shadowed or rebound name changes dependency graph | `let` allowed in nested blocks and contract body | Classifier |
| hidden lifecycle/evidence defaults | `using profile`, `packet`, `receipt`, `metric` aliases | TypeChecker / Emitter |
| capability silently absent | `delegate` to mesh without declared capability | TypeChecker |
| trust ordering assumed over symbols | `peer.trust at_least :regional_operator` | TypeChecker |
| blocking semantics unclear | `await_review` sync vs async | TypeChecker / Runtime |
| analytics write misclassified | `write metric at dims = value` vs OLAP mutation | TypeChecker / SemanticIR |
| invariant severity `:metric` confused with metric declaration | shared term `metric` | Parser / Classifier |
| non-exhaustive state handling | `match` over `variant` | TypeChecker |
| constructor namespace collision | `nil`, `some`, `ok`, domain case names | Parser / Classifier |
| unresolved generic impl | `T where Ordered[T]` / `T: Ordered[T]` | Classifier / TypeChecker |
| recursive generic/variant shape is infinite | `variant List[T]` + structural recursion | TypeChecker |
| proof/audit semantics blurred | `receipt SortProof` | Parser/Profile spec |
| unverifiable helper calls | external domain helpers without signatures | Classifier / TypeChecker |
| magic threshold cannot be audited | inline `0.700` style domain constants | TypeChecker / Lint |

---

## Recommended Stage 3 Grammar / Proof Slices

1. `future-syntax-pressure-registry-v0`
   - Mark pressure fixtures as non-canon explicitly.
   - Add a fixture manifest with intended constructs and parser status.

2. `let-compute-boundary-v0`
   - Decide contract-body `let` lowering.
   - Prove rebinding/shadowing diagnostics.
   - Formatter round-trip: dense `let` -> canonical `compute`.

3. `profile-expansion-surface-v0`
   - Define `profile using` expansion into lifecycle/evidence/backend fields.
   - Prove no hidden defaults survive into SemanticIR.

4. `metric-alias-olap-point-v0`
   - Treat `metric` as source alias for OLAPPoint.
   - Prove ambiguity isolation from invariant `severity: :metric`.

5. `delegate-await-review-escape-boundary-v0`
   - Define AST shape for delegate and await_review.
   - Assign OOF ownership for capability, trust, timeout, role, and lifecycle.

6. `variant-match-exhaustiveness-v0`
   - Add `variant` and `match` ParsedProgram shapes.
   - Prove duplicate case, missing case, constructor namespace, and recursive
     shape diagnostics.

7. `generic-constraints-spelling-v0`
   - Resolve `T: Trait` vs `T where Trait[T]`.
   - Prove monomorphization boundary and no type variables in SemanticIR.

8. `external-helper-signature-v0`
   - Formalize `external pure/native/ffi` signatures.
   - Prevent unverifiable helper calls in high-trust fixtures.

9. `named-threshold-const-v0`
   - Add or reject `threshold` as a profile over `const`.
   - Prove diagnostics for inline magic thresholds in audit/proof profiles.

10. `receipt-identity-surface-v0`
    - Replace magic `content_hash(...)` pressure with declarative receipt
      identity semantics if the pressure survives another fixture round.

---

## Handoff

```text
Card: S2-R15-C4-P
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/future-syntax-pressure-formalization-v0
Status: done

[D] Decisions:
- No parser changes in this slice.
- Treat pressure fixtures as research artifacts, not implicit grammar.
- Keep compute as canonical contract node syntax.
- Treat contract-body let, stream method chains, and dense signatures as sugar candidates.
- Treat metric as a likely surface alias over OLAPPoint.
- Treat variant/match as high-confidence canonical candidates pending proof.
- Keep PROP-016 generic constraint spelling canonical until an explicit errata.

[S] Signals:
- Delegate/await_review are semantic ESCAPE/lifecycle constructs, not just syntax decoration.
- Mesh is profile/capability surface, not "agent" semantics.
- Receipt/proof terminology needs separation before academic fixtures become grammar drivers.

[T] Tests / Proofs:
- Documentation-only slice. No executable tests run or required.

[R] Risks:
- Ambiguous future syntax can create OOF ownership ambiguity, hidden lifecycle defaults,
  unresolved trait dispatch, and misleading SemanticIR node identity.

[Next]
- Stage 3 should start with fixture registry + let/compute boundary before promoting
  broader future syntax.
```
