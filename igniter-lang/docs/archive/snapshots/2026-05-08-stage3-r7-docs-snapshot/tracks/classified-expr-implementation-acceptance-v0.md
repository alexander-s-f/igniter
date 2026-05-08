# Track: ClassifiedExpr Implementation Acceptance v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/classified-expr-implementation-acceptance-v0
Status: done
Date: 2026-05-06
Amends: PROP-023 (ClassifiedExpr boundary)
Pressure source: actual classifier output observed in experiments/

---

## Part 1: Current vs Target — Field-by-Field Gap Map

Observed in `classifier_pass_proof/golden/*.classified.json` and
`typechecker_proof/classified/*.classified.json`.

```text
FIELD / CONCEPT         CURRENT (actual)              TARGET (PROP-020/023)
──────────────────────  ────────────────────────────  ──────────────────────────────
Top-level kind          "classified_program"           "classified_program"   ✓
Contract array name     "contracts"                    "contracts"            ✓
Contract object kind    "classified_contract"          "classified_contract"  ✓
Contract identifier     "contract_id" (fqn string)    "contract_name" (plain name)
Node array name         "declarations"                 "nodes"
Node identifier         "decl_id" ("input:a")          REMOVE — use kind+name
Expr carrier fields     "expr_kind" + raw "expr"       single "expr": ClassifiedExpr
Expr kinds (compute)    "binary_op", "call", etc.      all -> "call" (normalized)
binary_op op: "+"       { kind:"binary_op", op:"+" }   { kind:"call", fn:"stdlib.integer.add", ... }
Ref expr                { kind:"ref", name }            { kind:"ref", name, dep:"input:a", fragment_class }
oof_log at contract     present                         REMOVE (move to diagnostics[])
oof_log at program      present                         REMOVE (move to diagnostics[])
semantic_ir_ref         present at top level            REMOVE (belongs in CompilationReport)
pass_result             absent                          ADD "ok"|"oof"|"skipped"
diagnostics             absent                          ADD []  (unified OOF entries)
```

**[D] `binary_op` is a parser convenience; it must be lowered to `call` form by the classifier.** `{ kind:"binary_op", op:"+" }` on Integer operands → `{ kind:"call", fn:"stdlib.integer.add", ... }`. The TypeChecker must never see `binary_op`.

---

## Part 2: Classifier Output Migration — What Changes

### A. Top-level envelope

```text
ADD:  "pass_result": "ok" | "oof"
ADD:  "diagnostics": [{ rule, severity, message, node, path, line }]
REMOVE: "semantic_ir_ref"     -- belongs in CompilationReport (PROP-019.1)
REMOVE: "oof_log"             -- replaced by "diagnostics"
KEEP: kind, classifier_version, program_id, source_path, source_hash,
      grammar_version, module, type_declarations, contracts
```

### B. ClassifiedContract

```text
RENAME: "contract_id" -> "contract_name"   (plain name; not fqn)
ADD:    "fqn": "<module>.<name>"           (optional; preserve for diagnostics)
RENAME: "declarations" -> "nodes"
REMOVE: "oof_log"                          -- entries move to top-level diagnostics
KEEP:   kind, fragment_class, symbols, dependency_graph
```

### C. ClassifiedNode (declaration → node)

```text
REMOVE: "decl_id"             -- not needed; kind+name is sufficient
ADD:    "expr": <ClassifiedExpr>  -- normalized, replaces "expr_kind" + raw "expr"
REMOVE: "expr_kind"           -- redundant with expr.kind
KEEP:   kind, name, fragment_class, deps, missing_refs, type_annotation
```

### D. ClassifiedExpr normalization

```text
binary_op { op:"+" }   ->  CExpr::Call { fn:"stdlib.integer.add", args:[L,R] }
binary_op { op:"-" }   ->  CExpr::Call { fn:"stdlib.integer.sub", args:[L,R] }
binary_op { op:"*" }   ->  CExpr::Call { fn:"stdlib.integer.mul", args:[L,R] }
binary_op { op:"==" }  ->  CExpr::Call { fn:"stdlib.integer.eq",  args:[L,R] }
binary_op { op:"<" }   ->  CExpr::Call { fn:"stdlib.integer.lt",  args:[L,R] }
-- Type prefix (integer/float/decimal) determined by operand type_annotation.
-- In classifier: use declared annotation for prefix selection.
-- If ambiguous (no annotation): emit CExpr::OofCall { oof_rule:"OOF-P1" }.

ref { name }            ->  CExpr::Ref { name, dep:"<kind>:<name>", fragment_class }
field_access { object, field }
                        ->  CExpr::FieldAccess { expr:<CExpr>, field, fragment_class }
call { fn, args }       ->  CExpr::Call (already normalized; add fragment_class to args)
```

**[D] `dep` on `CExpr::Ref` uses `decl_id` format: `"<kind>:<name>"`.** Example: `"input:a"`, `"compute:sum"`. This is the only place `decl_id` survives — as a dep pointer value.

---

## Part 3: Updated ClassifiedNode JSON Shape

```json
{
  "kind":            "compute",
  "name":            "sum",
  "type_annotation": "Integer",
  "fragment_class":  "core",
  "deps":            ["a", "b"],
  "missing_refs":    [],
  "expr": {
    "kind":          "call",
    "fn":            "stdlib.integer.add",
    "args": [
      { "kind":"ref", "name":"a", "dep":"input:a", "fragment_class":"core" },
      { "kind":"ref", "name":"b", "dep":"input:b", "fragment_class":"core" }
    ],
    "fragment_class": "core"
  }
}
```

OOF case (unresolved ref):

```json
{
  "kind":            "compute",
  "name":            "sum",
  "type_annotation": "Integer",
  "fragment_class":  "oof",
  "deps":            ["a", "missing_b"],
  "missing_refs":    ["missing_b"],
  "expr": {
    "kind": "call",
    "fn":   "stdlib.integer.add",
    "args": [
      { "kind":"ref",     "name":"a",        "dep":"input:a", "fragment_class":"core" },
      { "kind":"oof_ref", "name":"missing_b", "oof_rule":"OOF-P1" }
    ],
    "fragment_class": "oof"
  }
}
```

---

## Part 4: TypeChecker Changes Required

The TypeChecker proof (`typechecker_proof/`) reads from `typechecker_proof/classified/*.classified.json`. After classifier migration, these files will use the new shape. Required TypeChecker changes:

```text
TC-1: Read "nodes" array (not "declarations").
TC-2: Read "contract_name" (not "contract_id").
TC-3: Read expr as ClassifiedExpr; stop reading "expr_kind" as a separate field.
TC-4: Expect all expr.kind values from: literal, ref, call, field_access, record,
      oof_ref, oof_call, oof_field_access. Raise on unknown kind.
TC-5: Skip type inference for OOF exprs (oof_ref, oof_call, oof_field_access).
TC-6: Read top-level "pass_result" to short-circuit (return skipped) if "oof".
TC-7: Read top-level "diagnostics" (not "oof_log") for forwarding.
```

---

## Part 5: Golden File Compatibility

```text
Files to update (classifier golden):
  experiments/classifier_pass_proof/golden/*.classified.json
  experiments/typechecker_proof/classified/*.classified.json
  experiments/igapp_assembler_proof/out/*/classified_ast.json

Migration is structural-only. Content is the same; shape changes:
  declarations -> nodes
  contract_id  -> contract_name
  remove decl_id from nodes
  remove oof_log (top + contract level)
  add pass_result, diagnostics
  remove semantic_ir_ref
  normalize expr: binary_op -> call; add dep to ref; add fragment_class to all exprs

[D] Golden files must be regenerated by re-running classifier_pass_proof.rb
    after the classifier is updated. Do not hand-edit them.
```

---

## Part 6: Implementation Checklist for Research Agent

```text
Classifier (classifier_pass_proof.rb):
  ☐ CI-1: Emit "nodes" (not "declarations") in ClassifiedContract.
  ☐ CI-2: Emit "contract_name" (not "contract_id") in ClassifiedContract.
           Preserve fqn as "fqn" field (optional).
  ☐ CI-3: Remove "decl_id" from node objects.
  ☐ CI-4: Remove "expr_kind" from node objects.
  ☐ CI-5: Emit "expr": <ClassifiedExpr> on compute/snapshot/read nodes.
  ☐ CI-6: Lower binary_op exprs to CExpr::Call with stdlib fn name.
           Use type_annotation prefix for fn resolution.
  ☐ CI-7: Emit CExpr::Ref with "dep":"<kind>:<name>" and "fragment_class".
  ☐ CI-8: Emit CExpr::OofRef/OofCall/OofFieldAccess for unresolved refs.
  ☐ CI-9: Remove "oof_log" from ClassifiedContract and ClassifiedProgram.
  ☐ CI-10: Add "diagnostics": [...] at top level (OOF entries from all contracts).
  ☐ CI-11: Add "pass_result": "ok" | "oof" at top level.
  ☐ CI-12: Remove "semantic_ir_ref" from ClassifiedProgram.

TypeChecker (typechecker_proof.rb):
  ☐ TC-1..TC-7 per §Part 4 above.

Golden files:
  ☐ GF-1: Re-run classifier_pass_proof.rb; regenerate all golden files.
  ☐ GF-2: Verify add.classified.json: compute:sum expr.kind = "call",
           fn = "stdlib.integer.add", args[0].dep = "input:a".
  ☐ GF-3: Verify negative_unresolved_symbol.classified.json:
           expr contains oof_ref with oof_rule: "OOF-P1".
           top-level diagnostics contains OOF-P1 entry.
           oof_log fields absent.
  ☐ GF-4: Verify typechecker proof still passes against regenerated golden files.
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/classified-expr-implementation-acceptance-v0
Status: done

[D] Decisions:
- "declarations" renamed to "nodes" in ClassifiedContract.
- "contract_id" renamed to "contract_name"; fqn preserved optionally.
- "decl_id" removed from node objects (dep pointer format "kind:name" kept as dep value).
- "expr_kind" removed; expr carries ClassifiedExpr with kind field.
- binary_op lowered to CExpr::Call by classifier using operand type_annotation prefix.
- oof_log removed at all levels; replaced by top-level "diagnostics" + "pass_result".
- semantic_ir_ref removed (belongs in CompilationReport per PROP-019.1).
- 12-item classifier checklist: CI-1..CI-12.
- 7 TypeChecker changes: TC-1..TC-7.
- 4 golden file checks: GF-1..GF-4.
- Golden files must be regenerated by tool, not hand-edited.

[Files] Changed:
- igniter-lang/docs/tracks/classified-expr-implementation-acceptance-v0.md [NEW]
- igniter-lang/docs/agent-motion.md [updated]

[Next]:
- [Research Agent]: Apply CI-1..CI-12 to classifier_pass_proof.rb.
  Regenerate golden files (GF-1..GF-4).
  Then apply TC-1..TC-7 to typechecker_proof.rb.
  Then re-run all proofs; all must pass.
```
