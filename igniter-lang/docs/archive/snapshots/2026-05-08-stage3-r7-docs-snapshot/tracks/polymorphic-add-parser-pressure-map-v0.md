# Track: Polymorphic Add — Parser/Grammar Pressure Map v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/polymorphic-add-parser-pressure-map-v0
Status: done
Date: 2026-05-06
Depends on: PROP-014, PROP-015, PROP-016
Source fixture: `igniter-lang/source/polymorphic_add.ig`
Expected output: `igniter-lang/source/polymorphic_add.parsed_program.expected.json`

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — owns the parser experiment and
  acceptance harness. Must update `igniter_lang_parser.rb` and the
  spec file to integrate the new constructs once this map is accepted.
- `[Igniter-Lang Bridge Agent]` — no action yet; monomorphized SemanticIR
  shape is unchanged.

---

## Current Horizon (≤5 lines)

The existing parser (`experiments/parser/igniter_lang_parser.rb`) handles the
PROP-014/015 grammar kernel: module, import, contract, def, type, input, output,
compute, read, snapshot, window, escape. It produces clean ParsedProgram JSON for
`add.ig` and `availability_projection.ig` (0 parse errors, 158 specs green).
`polymorphic_add.ig` crashes the parser at a `trait` method body because `def`
inside `trait { }` hits `parse_function_decl`, which expects a block body (`{…}`),
but the fixture's trait method is signature-only — the parser blows up at `rbrace`.

---

## Section 1: Observed Parser Failure (Task 1)

### Exact error

```text
igniter_lang_parser.rb:306: Expected lbrace, got rbrace(}) (ParseError)
  from parse_block_body     (line 510)
  from parse_function_decl  (line 504)
  from parse_top_decl       (line 371)
```

### Root cause chain

```text
source line 8: "  def add(a: T, b: T) -> T"
  -> parse_top_decl sees "def" -> parse_function_decl
  -> expects "(" ... ")" "->" TypeRef "{" Body "}"
  -> BUT trait method body is missing: the closing "}" of the trait block
     is read as the opening lbrace for the def body
  -> parse_block_body says: Expected lbrace, got rbrace
```

The parser crashes **before** seeing any other novel construct.
After fixing trait-method parsing, it would next fail on:

```text
1. "trait" keyword — not in KEYWORDS; parsed as :ident, misrouted to parse_top_decl error branch
2. "impl" keyword  — same: :ident, then "Additive[Integer]" is consumed confusingly
3. "contract_shape" — read as :ident; "[" then misparses TypeParam as IndexAccess
4. "Add[T: Additive]" — contract header with generic TypeParams and bounds
5. "implements AddShape[T]" — "implements" is :ident consumed unexpectedly
6. Contract body: input/output ports ARE understood (same as current grammar);
   compute "sum = add(a, b)" is understood (call expr, same as current)
7. "impl Additive[Integer] using stdlib.numeric.add" — "using" is :ident
   and "stdlib.numeric.add" is a qualified identifier that the current
   read_ident_or_keyword may partially handle (it reads dots) but the
   context is completely wrong
```

---

## Section 2: Missing Grammar Constructs (Task 2)

The table below maps each new surface to its current parser status.

### 2a. Trait declarations

```text
trait Additive[T] {
  def add(a: T, b: T) -> T
}
```

**Current gap:**
- `trait` is not a keyword (KEYWORDS array). It's lexed as `:ident`.
- `parse_top_decl` doesn't handle `:ident` tokens as keywords — falls
  through to error branch.
- Even if routed correctly, `trait` needs a new production:

```text
[NEW GRAMMAR]
TraitDecl    := "trait" Name "[" TypeParam "]" "{" TraitMethod* "}"
TraitMethod  := "def" Name "(" Params? ")" "->" TypeRef
             -- NO body block. Signature only.
TypeParam    := Name
```

**Parser change needed:**
1. Add `"trait"` to `KEYWORDS`.
2. Add `parse_trait_decl` method.
3. Add `parse_trait_method` (variant of `parse_function_decl` without body).
4. Extend `parse_top_decl` to route `"trait"` correctly.
5. Extend `ParsedProgram` builder to emit `"traits"` array.

**ParsedProgram shape change (additive):**
```json
"traits": [
  {
    "kind": "trait",
    "name": "Additive",
    "type_params": ["T"],
    "methods": [
      { "kind": "trait_method", "name": "add",
        "params": [{"name":"a","type_annotation":"T"},
                   {"name":"b","type_annotation":"T"}],
        "return_type": "T" }
    ]
  }
]
```

---

### 2b. Impl declarations

```text
impl Additive[Integer] using stdlib.numeric.add
```

**Current gap:**
- `impl` is not a keyword.
- The `using` keyword is not present.
- `stdlib.numeric.add` is a qualified reference. The current lexer
  `read_ident_or_keyword` reads dots only when followed by uppercase
  (module paths). `stdlib.numeric.add` is all-lowercase, so it would
  be read as three tokens: `stdlib`, `.`, `numeric` (then fail).

**Parser change needed:**
1. Add `"impl"` and `"using"` to `KEYWORDS`.
2. Add `parse_impl_decl` method:
   ```text
   ImplDecl := "impl" TraitRef "using" QualifiedRef
             | "impl" TraitRef "{" ImplMethod* "}"
   TraitRef := Name "[" TypeRef "]"
   QualifiedRef := Name ("." Name)*   -- allow any case, not just uppercase
   ```
3. Extend `parse_top_decl` to route `"impl"`.
4. Extend lexer: `read_ident_or_keyword` must accept `stdlib.numeric.add`
   as a single qualified-name token (or the parser must stitch dot-separated
   lowercase idents in a `parse_qualified_ref` helper).
5. Extend `ParsedProgram` builder to emit `"impls"` array.

**ParsedProgram shape change (additive):**
```json
"impls": [
  {
    "kind": "impl",
    "trait_ref": { "name": "Additive", "type_args": ["Integer"] },
    "using": { "kind": "qualified_ref", "name": "stdlib.numeric.add" }
  }
]
```

**Lexer note:**
The existing `read_ident_or_keyword` only follows dots before uppercase:
```ruby
break unless @source[@pos + 1] =~ /[A-Z]/  # only Module.Name paths
```
This must be relaxed for qualified refs (`stdlib.numeric.add`).
Two options:
- (A) Parse `stdlib` as ident, then in `parse_qualified_ref` stitch
  dot-separated ident tokens manually. **Preferred — no lexer change needed.**
- (B) Change the lexer rule. **Risk: breaks other dot uses (field access).**

**[D] Use option A: `parse_qualified_ref` in the parser, not a lexer change.**

---

### 2c. Contract shapes

```text
contract_shape AddShape[T] {
  input a: T
  input b: T
  output sum: T
}
```

**Current gap:**
- `contract_shape` is not a keyword. It lexes as a single ident
  (`contract_shape` contains `_`, allowed by `/[a-zA-Z0-9_.]/`).
  Actually: `_` is NOT in the lexer pattern `/[a-zA-Z0-9_.]/`,
  so `contract_shape` would lex as `contract` (keyword) + `_` (unknown char
  → nil → skip) + `shape` (ident). The `_` is silently discarded.
  The parser then sees `keyword("contract")` + `ident("shape")` + `lbracket`.
  `parse_contract_decl` reads name=`"shape"`, then sees `[` instead of `{` →
  another parse error.

**Lexer fix required (independent of grammar):**
Allow `_` in identifiers:
```ruby
while @pos < @source.length && peek =~ /[a-zA-Z0-9_]/   # add _
```
This also fixes any other `snake_case` identifiers that currently break.

**[D] This is the only lexer-level fix that is both safe and necessary.**
It does not affect keyword matching (keywords are matched by string equality).

**Parser change needed:**
1. Fix lexer: `_` in identifiers (above).
2. Add `"contract_shape"` handling. Two approaches:
   - (A) Treat `contract_shape` as a two-token sequence `contract` + `shape`
     and detect in `parse_top_decl` via lookahead.
   - (B) Add `contract_shape` as a single keyword.
   **[D] Option B: add `"contract_shape"` to KEYWORDS after the `_`-fix.**
   Single keyword is cleaner; avoids lookahead coupling between `contract`
   and the body dispatch.
3. Add `parse_contract_shape_decl`:
   ```text
   ShapeDecl := "contract_shape" Name "[" TypeParams "]" "{" ShapePort* "}"
   ShapePort := ("input" | "output") Name ":" TypeRef
   ```
   Body ports reuse existing `parse_input_decl` / `parse_output_decl`.
4. Extend `ParsedProgram` builder to emit `"contract_shapes"` array.

**ParsedProgram shape change (additive):**
```json
"contract_shapes": [
  {
    "kind": "contract_shape",
    "name": "AddShape",
    "type_params": ["T"],
    "body": [
      {"kind":"input","name":"a","type_annotation":"T"},
      {"kind":"input","name":"b","type_annotation":"T"},
      {"kind":"output","name":"sum","type_annotation":"T"}
    ]
  }
]
```

---

### 2d. Generic contract parameters with trait bounds

```text
contract Add[T: Additive] implements AddShape[T] {
  compute sum = add(a, b)
}
```

**Current gap:**
- `parse_contract_decl` calls `name_token!` then expects `{` immediately.
  It does not parse `[TypeParams]` or `implements ShapeRef`.
- After the name `Add`, it sees `[` → `expect_type!(:lbrace)` fails.

**Parser change needed:**
1. Extend `parse_contract_decl`:
   ```text
   ContractDecl := "contract" Name TypeParamList? ImplementsClause? "{" BodyDecl* "}"
   TypeParamList := "[" TypeParamBound ("," TypeParamBound)* "]"
   TypeParamBound := Name (":" ConstraintList)?
   ConstraintList := Name ("[" TypeRef "]")? ("&" Name ("[" TypeRef "]")?)*
   ImplementsClause := "implements" ShapeRef ("," ShapeRef)*
   ShapeRef := Name ("[" TypeRef ("," TypeRef)* "]")?
   ```
2. Add `"implements"` to KEYWORDS.
3. Emit parsed type_params + bounds + implements into the contract node:
   ```json
   {
     "kind": "contract",
     "name": "Add",
     "type_params": [
       { "name": "T", "bounds": [{ "trait_ref": { "name": "Additive", "type_args": ["T"] } }] }
     ],
     "implements": { "name": "AddShape", "type_args": ["T"] },
     "body": [...]
   }
   ```

**ParsedProgram shape change:**
- `type_params` on contracts changes from `[]` (absent) to
  `[{ "name": ..., "bounds": [...] }]`. This is additive for contracts
  that have none; contracts with generic params get the richer form.
- `"implements"` field is new on contract nodes.

---

### 2e. Trait-bounded type parameters in TypeRef

```text
TypeParam := Name (":" ConstraintList)?
```

This is purely a parser addition within `TypeParamList`. The type-ref
parser itself (`parse_type_ref`) is not affected: `T` is a valid single-name
TypeRef. The bound `: Additive` is parsed separately in the TypeParam context,
not inside TypeRef.

**[D] `parse_type_ref` does NOT change for bounds. Bounds are parsed only
inside TypeParamList, not in general TypeRef positions.**

---

### 2f. Specialization call syntax (`Add[Integer]`)

The fixture does not contain specialization call syntax directly. The source
fixture only defines the generic `contract Add[T: Additive]`. Specialization
at call-site (`Add[Integer]{a:x, b:y}`) is a ClassifiedProgram / TypedProgram
concern — it is not in the source fixture and therefore not a parser gap here.

**[D] No parser work needed for specialization call syntax in this fixture.**
The call `add(a, b)` inside the contract body is already handled by
`parse_expr` → `parse_postfix` → call detection. `add` is an unresolved name
at parse time; resolution to the trait impl is a semantic pass concern.

---

## Section 3: Parser Work vs Semantic Work Separation (Task 3)

### Parser layer (ParsedProgram stage — pure syntax)

| Construct | Change needed |
|-----------|---------------|
| `_` in identifiers | Lexer: add `_` to ident character class |
| `trait` keyword | Lexer: add to KEYWORDS; parser: new `parse_trait_decl` |
| Trait method (no body) | Parser: `parse_trait_method` — like `parse_function_decl` but no body block |
| `impl … using …` | Lexer: add `impl`, `using` to KEYWORDS; parser: `parse_impl_decl` + `parse_qualified_ref` |
| `contract_shape` keyword | Lexer: add to KEYWORDS (after `_`-fix); parser: `parse_contract_shape_decl` |
| Generic contract header `[T: Bound]` | Parser: `parse_type_param_list` inside `parse_contract_decl` |
| `implements` clause | Lexer: add `implements` to KEYWORDS; parser: `parse_implements_clause` |
| ParsedProgram builder | Add `traits`, `impls`, `contract_shapes` arrays; enrich contract node |

**Nothing in this list requires type inference, trait resolution,
coherence checking, or monomorphization.**

---

### Semantic / compiler layer (ClassifiedProgram → TypedProgram → SemanticIR)

| Concern | Stage |
|---------|-------|
| Trait impl coherence (CR-1, CR-2, CR-3) | ClassifiedProgram (Pass 0) |
| `impl Additive[Integer] using stdlib.numeric.add` resolution | ClassifiedProgram — resolve qualified ref to axiom entry |
| Trait method completeness check | ClassifiedProgram |
| `implements AddShape[T]` structural satisfaction check | TypedProgram (Pass 1) |
| Type variable `T` substitution | ClassifiedProgram monomorphization entry point |
| Monomorphization of `Add[T]` → `Add[Integer]`, `Add[Float]` | TypedProgram / SemanticIR lowering |
| `add(a, b)` → `apply("stdlib.numeric.add", [ref(a), ref(b)])` | TypedProgram (trait method resolution) |
| SemanticIR: no type variables survive | SemanticIR stage invariant (PROP-016 §Part 9) |
| RuntimeMachine load rejection of unresolved generics | Runtime boundary (unchanged) |

**[D] Monomorphization is a TypedProgram → SemanticIR concern, not a
parser concern. ParsedProgram must preserve the generic form (`T` as a
string type_annotation) so the semantic pass can substitute.**

---

### Monomorphization stage placement (PROP-016 clarification)

PROP-016 says "Pass 0 (Classify)". This track refines:

```text
Pass 0 (Classify): fragment classification (CORE/ESCAPE/OOF) and
  trait impl resolution lookup. Generic contracts are tagged
  as generic; specialization sites are recorded but NOT yet lowered.

Pass 1 (TypedProgram): substitute T, check implements, produce concrete
  typed nodes for each specialization.

SemanticIR lowering: emit one ContractIR per monomorphization.
  No type variables remain.
```

**[D] ParsedProgram retains type variable strings. ClassifiedProgram
retains them with impl resolution annotations. TypedProgram is
where substitution happens. SemanticIR is guaranteed clean.**

---

## Section 4: Proposed ParsedProgram Shape Changes (Task 4)

All changes are **additive**. No existing fields are renamed or removed.

### New top-level fields

```json
{
  "kind": "parsed_program",
  "...existing fields...",
  "traits": [...],
  "impls": [...],
  "contract_shapes": [...]
}
```

Previously these were absent (no key). Adding them as empty arrays `[]`
for programs that have none is safe — the existing two source fixtures
already emit `"functions": []` and `"types": []` in the same pattern.

### Contract node enrichment

```json
{
  "kind": "contract",
  "name": "Add",
  "type_params": [
    {
      "name": "T",
      "bounds": [
        { "trait_ref": { "name": "Additive", "type_args": ["T"] } }
      ]
    }
  ],
  "implements": { "name": "AddShape", "type_args": ["T"] },
  "body": [...]
}
```

Previously, `type_params` was absent (non-generic contracts). After:
- non-generic contracts: `"type_params": []`
- generic contracts: `"type_params": [{ "name": ..., "bounds": [...] }]`
- `"implements"` is absent for non-generic contracts; present for those
  that declare it. `null` is acceptable but absent is cleaner.

**[D] This is the only structural change to existing contract nodes.
Add and AvailabilityProjection acquire `"type_params": []` and
no `"implements"` field. Tests comparing those contracts should be
updated to expect the new empty `type_params` array.**

---

## Section 5: Implementation Order (Task 5)

### Phase 0: Lexer hardening (prerequisite)

**Safe, isolated, zero semantic risk.**

```text
1. Add `_` to ident character class.
   Verify: "contract_shape" lexes as a single ident token.
   Verify: "stdlib_core" also lexes correctly (regression: nil).

2. Add keywords: "trait", "impl", "using", "implements", "contract_shape".
   Verify: these lex as :keyword, not :ident.
   Verify: no existing keyword handling breaks (all existing keywords
   are distinct strings; no shadowing risk).
```

**Risk:** `_` in ident — the existing lexer regex `/[a-zA-Z0-9_.]/` already
includes `.` for module paths, but `_` is absent. Adding `_` should not
affect any current source fixtures (add.ig, availability_projection.ig)
because neither uses `_` in identifiers. **Verify with a before/after parse
run on both existing source fixtures.**

---

### Phase 1: Trait declarations

```text
3. parse_trait_decl: "trait" Name "[" TypeParam "]" "{" TraitMethod* "}"
4. parse_trait_method: "def" Name "(" Params? ")" "->" TypeRef  (no body)
5. Extend parse_top_decl to route "trait" -> parse_trait_decl
6. Extend ParsedProgram builder: emit "traits" array
7. Acceptance check: trait node matches expected.json "traits" section
```

---

### Phase 2: Impl declarations

```text
8. parse_qualified_ref: ident ("." ident)* — lowercase dot paths
9. parse_impl_decl: "impl" TraitRef "using" QualifiedRef
   (defer full-body impl to a later slice — fixture only uses "using")
10. Extend parse_top_decl to route "impl" -> parse_impl_decl
11. Extend ParsedProgram builder: emit "impls" array
12. Acceptance check: impl nodes match expected.json "impls" section
```

---

### Phase 3: Contract shapes

```text
13. parse_contract_shape_decl:
    "contract_shape" Name "[" TypeParam "]" "{" ShapePort* "}"
    ShapePort := ("input" | "output") Name ":" TypeRef
    (reuse parse_input_decl, parse_output_decl)
14. Extend parse_top_decl to route "contract_shape" -> parse_contract_shape_decl
15. Extend ParsedProgram builder: emit "contract_shapes" array
16. Acceptance check: contract_shapes match expected.json "contract_shapes"
```

---

### Phase 4: Generic contract headers

```text
17. parse_type_param_list: "[" TypeParamBound ("," TypeParamBound)* "]"
    TypeParamBound := Name (":" TraitRef ("&" TraitRef)*)?
    (TraitRef := Name ("[" TypeRef "]")?)
18. parse_implements_clause: "implements" ShapeRef
    ShapeRef := Name ("[" TypeRef "]")?
19. Extend parse_contract_decl to attempt parse_type_param_list before "{"
    and parse_implements_clause between TypeParamList and "{"
20. Enrich contract node: type_params + implements fields
21. Existing contracts: emit type_params: [] (backward compat)
22. Acceptance check: contract node matches expected.json "contracts" section
```

---

### Phase 5: Full fixture acceptance test

```text
23. Add polymorphic_add.ig to parser spec:
    parser.parse(File.read("source/polymorphic_add.ig"))
    compare to polymorphic_add.parsed_program.expected.json
    parse_errors must be []
24. Verify add.ig and availability_projection.ig still pass (61 existing specs)
```

---

## Section 6: Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| `_` in lexer breaks field access (`obj._field`) | Low — no `_`-prefixed fields in current fixtures | Run both existing fixtures before and after |
| New keywords shadow user idents | Low — `trait`, `impl`, `using`, `implements`, `contract_shape` are reserved | Document as reserved in PROP-016 |
| `parse_type_param_list` ambiguity with `parse_type_ref` lbracket | Medium — both start with `[` | Always attempt TypeParamList first in contract header position only |
| Existing `type_params: []` change breaks existing specs | Low — additive field, but specs may do exact JSON compare | Update spec expectations; add `"type_params": []` to add/availability JSON |
| Full-body `impl` deferred | Low for this fixture — `using` shorthand covers it | Note as open item for PROP-016 impl body phase |
| Multi-bound `T: A & B` parsing | Out of scope — fixture has single bound | `ConstraintList` can start as single-bound; extend later |

---

## Acceptance Criteria for This Track

- `igniter-lang/docs/tracks/polymorphic-add-parser-pressure-map-v0.md` exists
  and is complete. ✓
- Document clearly separates parser work from semantic/compiler work. ✓
- PROP-016 invariant preserved: no type variables in SemanticIR. ✓
  (SemanticIR work is entirely in the semantic layer; parser only captures
  the generic form as strings.)
- Recommended implementation order is numbered and sequenced. ✓
- ParsedProgram shape changes are minimal and additive. ✓

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/docs/tracks/polymorphic-add-parser-pressure-map-v0.md
Status: done

Neighbors:
- [Igniter-Lang Research Agent] — owns parser implementation; should
  execute Phases 0–5 above.
- [Igniter-Lang Bridge Agent] — no action at this stage.

[D] Decisions:
- Parser crash is at trait method body (no body block expected).
  Root: parse_function_decl called for trait method; expects "{Body}".
- "contract_shape" currently lexes as "contract" + dropped "_" + "shape".
  Lexer MUST add "_" to ident character class as Phase 0.
- "contract_shape" as a single keyword (not two-token sequence) is cleaner.
  Add to KEYWORDS after the _ fix.
- "using" shorthand impl ("impl T[X] using qualified.ref") is sufficient
  for this fixture. Full impl body deferred.
- parse_qualified_ref (parser helper, not lexer change) handles
  "stdlib.numeric.add"-style paths. Do not widen lexer dot rule.
- ParsedProgram type_params changes are additive. Non-generic contracts
  emit type_params: []. No existing field is renamed or removed.
- Monomorphization lives at TypedProgram stage, not Parse. ParsedProgram
  retains T as a string. SemanticIR invariant (no type variables) is
  enforced only at SemanticIR lowering.
- Specialization call syntax (Add[Integer]{a:x,b:y}) is out of scope for
  this fixture and this parser slice.

[R] Recommendations:
- Execute Phases 0–5 in order. Phase 0 (lexer) is a prerequisite for all
  others and the least risky change.
- Run existing parser acceptance tests (add.ig, availability_projection.ig)
  after each phase to verify zero regression.
- The grammar_version field in ParsedProgram should update to
  "polymorphic-v0" when the fixture is accepted.
- Do NOT implement trait coherence, monomorphization, or implements check
  in the parser slice. Those belong to ClassifiedProgram and TypedProgram.
- [Q] from Research Agent: Should "impl Additive[Integer] using X" also
  accept a full body form? Recommendation: defer. Only "using" shorthand
  in this slice.

[S] Signals:
- The parser is structurally close. The gap is 5 new constructs (trait,
  impl, using, contract_shape, generic contract header) and one lexer fix
  (_). No fundamental grammar redesign is required.
- The existing contract body parser (input/output/compute) already handles
  everything in AddShape and the Add contract body. The pressure is entirely
  in the new top-level declaration forms.
- PROP-016 Part 9 (SemanticIR representation) is already correct and
  does not need changes. The parser delta does not touch SemanticIR.
- The expected ParsedProgram JSON in polymorphic_add.parsed_program.expected.json
  is already well-formed and serves as a direct acceptance target for the
  parser spec.

[T] Tests / Proofs:
- Phase 0 test: parse add.ig and availability_projection.ig before and after
  lexer _ fix — both must produce parse_errors: [].
- Phase 5 test: parse polymorphic_add.ig; compare JSON output to
  polymorphic_add.parsed_program.expected.json field by field; parse_errors: [].
- Regression: all 61 existing parser acceptance specs must remain green.

[Files] Changed:
- igniter-lang/docs/tracks/polymorphic-add-parser-pressure-map-v0.md  [NEW]

[Q] Open Questions:
- [Q-1] Should "impl Trait[Type] using stdlib.ref" be the only impl form in
  the parser, or should full-body impl be added in the same slice?
  Recommendation: "using" only for this slice; full body in next.
- [Q-2] Should trait type_params support multiple params "[T, U]" or only
  single "[T]"? Fixture uses single only. Recommendation: single in this
  slice, trivially extendable.
- [Q-3] Should implements accept a list of shapes ("implements A[T], B[T]")?
  PROP-016 allows a list. Fixture uses single. Recommendation: single for
  this slice, list-form is a follow-on.
- [Q-4] Should the "grammar_version" field change when polymorphic constructs
  are accepted? Recommendation: yes — update to "polymorphic-v0" in the
  ParsedProgram builder.

[X] Rejected:
- Widening lexer dot rule to allow lowercase qualified paths: parse_qualified_ref
  helper is safer and preserves existing dot behavior (field access, module paths).
- Two-token "contract" + "shape" lookahead: single "contract_shape" keyword
  is cleaner.
- Implementing monomorphization in the parser: that is a semantic concern.
  ParsedProgram must preserve type variables as strings.
- Implementing trait coherence or implements check in the parser: these are
  Pass 1 (TypedProgram) concerns.

[Next] Proposed next slices:
1. [Research Agent]: polymorphic-add-parser-acceptance-v0
   Execute Phases 0–5 from this map. Produce passing parse spec for
   polymorphic_add.ig. Update grammar_version to "polymorphic-v0".
   Verify 0 regression on existing 61 specs.

2. [Compiler/Grammar Expert]: polymorphic-add-classifier-v0
   Define ClassifiedProgram extension for trait/impl/contract_shape nodes.
   Specify coherence checks (CR-1, CR-2, CR-3 from PROP-016).
   Specify impl resolution for "using stdlib.*" pattern.
   This is the semantic pass that sits between ParsedProgram and TypedProgram.

3. [Compiler/Grammar Expert]: polymorphic-add-monomorphizer-v0
   Define TypedProgram monomorphization: T substitution, implements check,
   SemanticIR emission of Add[Integer] and Add[Float].
   No type variables in emitted SemanticIR.
```
