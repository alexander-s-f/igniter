# Track: Spark Pipeline Parser Acceptance v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/spark-pipeline-parser-acceptance-v0
Status: done
Date: 2026-05-06
Depends on: spark-pipeline-grammar-v0, PROP-014, PROP-015
Artifacts:
  - igniter-lang/experiments/parser/igniter_lang_parser.rb
  - igniter-lang/source/vendor_lead_pipeline.ig
  - igniter-lang/source/vendor_lead_pipeline.parsed_program.expected.json
  - igniter-lang/source/tenant_availability_projection.ig
  - igniter-lang/source/tenant_availability_projection.parsed_program.expected.json

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — parser now accepts the source form for
  both fixture targets. Research Agent may reference `tenant_availability_projection.ig`
  and its parsed JSON when building the classifier/SemanticIR fixture proof.
- `[Igniter-Lang Bridge Agent]` — no action until fixture proof is stable.

---

## Frame

This slice adds parser acceptance for the Spark pipeline grammar surface
defined in `spark-pipeline-grammar-v0`. It is syntax-only — no classifier,
typechecker, or SemanticIR lowering is performed here.

Accepted surface:

```text
pipeline <Name>[<InType>, <OutType>, <ErrType>] {
  step <name>: <def_ref>
  ...
}

read <name>: <TypeRef>
  from <string>
  lifecycle :<atom>
  scoped_by <ref>           -- new
  cardinality <int>..<int>  -- new
  schema_version <string>   -- new
  tenant_free               -- new
```

This is the same additive-superset philosophy as the polymorphic-add
parser acceptance slice: existing accepted fixtures are unaffected.

---

## Parser Changes

### 1. New keywords added to KEYWORDS

```text
pipeline  step  scoped_by  cardinality  schema_version  tenant_free
```

All match `[a-z_]+`; no identifier character changes needed.

### 2. `..` lexed as `:dot_dot` token

The `.` branch in `next_token` was:

```text
when "." then
  advance; Token.new(:dot, ".", l, c)
```

Changed to:

```text
when "." then
  if peek(1) == "."
    advance; advance
    Token.new(:dot_dot, "..", l, c)
  else
    advance; Token.new(:dot, ".", l, c)
  end
```

`:dot_dot` added to `TOKEN_TYPES`. This change is backward-compatible:
no existing source uses `..` syntax.

### 3. `ParsedProgram` builder

`parse` method initializes `"pipelines" => []`.
`parse_top_decl` routes `"pipeline"` → `parse_pipeline_decl`.
`to_h` includes `"pipelines" => @ast.fetch("pipelines", [])`.

### 4. `parse_pipeline_decl`

```text
PipelineDecl := "pipeline" Name "[" TypeRef "," TypeRef "," TypeRef "]"
                "{" StepDecl+ "}"
StepDecl     := "step" Name ":" QualifiedRef
```

Emits `OOF-PG5` into `parse_errors` if steps list is empty.
Emits `OOF-PG-step` into `parse_errors` if non-`step` token found inside body.

### 5. `parse_step_decl`

Reuses existing `parse_qualified_ref` for the step ref. This correctly
handles both unqualified (`validate_and_find_vendor`) and module-qualified
(`SparkCRM.Steps.validate_and_find_vendor`) refs.

### 6. Extended `parse_read_decl`

After `lifecycle`, the parser now optionally consumes:

```text
scoped_by    -> name_token!(%i[ident])
cardinality  -> parse_cardinality_bound (two IntLit + :dot_dot)
schema_version -> string_lit
tenant_free  -> bare keyword; boolean flag
```

Emits `OOF-PG3` into `parse_errors` if both `scoped_by` and `tenant_free`
are present on the same read declaration.

The new fields appear in the `ReadDecl` node only when present.
`tenant_free` always appears (defaults to `false`).

### 7. `grammar_version` detection

```text
"spark-pipeline-v0"  -- if pipelines[] non-empty OR any read has scoped_by
"polymorphic-v0"     -- if traits/impls/contract_shapes non-empty
"0.1.0"              -- baseline
```

---

## Proof Output

```text
ruby experiments/parser/igniter_lang_parser.rb source/add.ig
  -> parse_errors: []
  -> grammar_version: 0.1.0

ruby experiments/parser/igniter_lang_parser.rb source/availability_projection.ig
  -> parse_errors: []
  -> grammar_version: 0.1.0

ruby experiments/parser/igniter_lang_parser.rb source/polymorphic_add.ig
  -> parse_errors: []
  -> grammar_version: polymorphic-v0

ruby experiments/parser/igniter_lang_parser.rb source/vendor_lead_pipeline.ig
  -> parse_errors: []
  -> grammar_version: spark-pipeline-v0
  -> pipelines[0].name: VendorLeadIntake
  -> pipelines[0].in_type: VendorLeadParams
  -> pipelines[0].err_type: LeadError
  -> steps: [find_vendor, check_hours, find_geo_bids, compute_response]

ruby experiments/parser/igniter_lang_parser.rb source/tenant_availability_projection.ig
  -> parse_errors: []
  -> grammar_version: spark-pipeline-v0
  -> reads: technician (scoped_by=company_scope, cardinality={min:1, max:1}, schema_version=technician-profile-v1, tenant_free=false)
            schedules  (scoped_by=company_scope, cardinality={min:0, max:500}, schema_version=schedule-slot-v1, tenant_free=false)
            off_schedules (scoped_by=company_scope, cardinality={min:0, max:200})
            day_off_config (scoped_by=company_scope, cardinality={min:0, max:1})
```

No regressions in existing fixtures. The 2 pre-existing spec failures
(`companion_poc` example script, root entrypoint archival) are unrelated
to the parser changes.

---

## Parse Negative Notes

### OOF-PG3: scoped_by + tenant_free conflict (parse-time)

```text
Source:
  read locs: Collection[Location]
    from "location/{zone}"
    lifecycle :durable
    scoped_by company_scope
    tenant_free

Parser emits:
  parse_errors: [
    { "message": "OOF-PG3: scoped_by and tenant_free are mutually exclusive on read 'locs'",
      "line": 0 }
  ]
```

### OOF-PG5: empty pipeline (parse-time)

```text
Source:
  pipeline Empty[A, B, E] { }

Parser emits:
  parse_errors: [
    { "message": "OOF-PG5: pipeline 'Empty' has no steps", "line": 0 }
  ]
```

### OOF-CB2: non-integer cardinality (parse-time)

```text
Source:
  cardinality n..500   -- 'n' is an ident, not an int_lit

Parser fails at expect_type!(:int_lit) and raises ParseError.
```

### OOF-TS1 and OOF-TS3: classifier-time (not parse-time)

Missing `scoped_by` on a `read Collection[T]` produces no parse error.
These are caught at classifier Pass 0. The parser emits a valid node with
`scoped_by: nil` and `tenant_free: false`; the classifier rejects it.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/spark-pipeline-parser-acceptance-v0
Status: done
Neighbors: Research Agent | Bridge Agent

[D] Decisions:
- parser now accepts pipeline/step/scoped_by/cardinality/schema_version/tenant_free.
- '..' lexed as :dot_dot (single token). Backward-compatible; no existing source uses '..'.
- scoped_by and tenant_free conflict is detected at parse time (OOF-PG3).
- Empty pipeline (OOF-PG5) is detected at parse time.
- OOF-TS1 and OOF-TS3 are classifier-time; the parser accepts nodes with nil scoped_by.
- grammar_version: spark-pipeline-v0 when pipelines or scoped reads present.
- All existing fixtures (add.ig, availability_projection.ig, polymorphic_add.ig) are
  unaffected: 0 parse errors, correct grammar versions.
- Existing ParsedProgram consumers gain a 'pipelines' array (empty for old fixtures).

[R] Recommendations:
- Research Agent: use tenant_availability_projection.ig + its expected JSON as the
  source fixture for the classifier/SemanticIR proof. The parser output is now validated.
- Do not implement OOF-TS1/TS3 in the parser. These are semantic checks (scope resolution,
  type annotation inspection) that belong in the classifier (Pass 0).
- The parse_cardinality_bound helper assumes exactly two int_lits with a '..' separator.
  If decimal or expression cardinality is needed later, extend this method; do not widen
  the grammar without a formal track.

[S] Signals:
- The parser delta is small: 6 new keywords, one new lexer case (dot_dot), two new parse
  methods (parse_pipeline_decl, parse_step_decl, parse_cardinality_bound), and extension
  of parse_read_decl. The existing grammar extension pattern (polymorphic-add) was
  followed precisely.
- parse_qualified_ref already handles unqualified step refs (e.g. "validate_and_find_vendor")
  because the lexer reads underscore identifiers as single tokens.
- tenant_availability_projection.ig is now the parser-validated form of the availability
  fixture. It supersedes the informal §2-B example from spark-pipeline-grammar-v0.

[T] Tests / Proofs:
- add.ig: parse_errors: [], grammar_version: 0.1.0. PASS.
- availability_projection.ig: parse_errors: [], grammar_version: 0.1.0. PASS.
- polymorphic_add.ig: parse_errors: [], grammar_version: polymorphic-v0. PASS.
- vendor_lead_pipeline.ig: parse_errors: [], grammar_version: spark-pipeline-v0,
  pipeline VendorLeadIntake with 4 steps. PASS.
- tenant_availability_projection.ig: parse_errors: [], grammar_version: spark-pipeline-v0,
  4 reads with scoped_by/cardinality/schema_version/tenant_free. PASS.
- OOF-PG3 (scoped_by + tenant_free): parse error emitted. PASS (manual verification).
- OOF-PG5 (empty pipeline): parse error emitted. PASS (manual verification).
- 640 specs: 2 pre-existing failures unrelated to parser. No regressions.

[Files] Changed:
- igniter-lang/experiments/parser/igniter_lang_parser.rb  [MODIFIED]
- igniter-lang/source/vendor_lead_pipeline.ig             [NEW]
- igniter-lang/source/vendor_lead_pipeline.parsed_program.expected.json [NEW]
- igniter-lang/source/tenant_availability_projection.ig   [NEW]
- igniter-lang/source/tenant_availability_projection.parsed_program.expected.json [NEW]
- igniter-lang/docs/tracks/spark-pipeline-parser-acceptance-v0.md [NEW]
- igniter-lang/docs/README.md  [updated]
- igniter-lang/docs/agent-motion.md  [updated]

[Q] Open Questions:
- Q-1: Should the parser spec file (if any) be extended with pipeline/scoped_by tests?
  Recommendation: yes. Add a spec for vendor_lead_pipeline.ig and
  tenant_availability_projection.ig matching expected JSON. Deferred to Research Agent
  spec extension slice.
- Q-2: Should OOF-PG3 emit a ParseError (halt) or a parse_errors entry (continue)?
  Current: parse_errors entry (continue); parse succeeds. This matches the polymorphic
  parser behavior for soft errors. A future strict-mode flag could make it halt.

[X] Rejected:
- OOF-TS1/TS3 in parser. These require type resolution (Collection[T] detection) and
  scope resolution (is 'company_scope' in scope?). Parser does not have this context.
- Dynamic cardinality expressions. parse_cardinality_bound only accepts int_lit..int_lit.
- '..' as two consecutive dot tokens. Single :dot_dot token is cleaner and forward-safe
  for future range literal syntax.
- Changes to existing accepted fixtures. add.ig, availability_projection.ig, and
  polymorphic_add.ig are unchanged.

[Next] Proposed next slices:
1. [Research Agent]: spark-technician-availability-fixture-v0
   Use tenant_availability_projection.ig as the source fixture reference.
   Build classifier and SemanticIR lowering from hand-authored ParsedProgram JSON
   matching tenant_availability_projection.parsed_program.expected.json.

2. [Research Agent]: spark-pipeline-parser-spec-v0
   Extend the parser spec file with pipeline/scoped_by/cardinality/tenant_free test cases.
   Verify: vendor_lead_pipeline.ig matches vendor_lead_pipeline.parsed_program.expected.json.
   Verify: tenant_availability_projection.ig matches expected JSON.
   Verify: OOF-PG3 and OOF-PG5 produce parse_errors entries.
```
