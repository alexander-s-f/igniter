# Branch Conditional If Expr Current Surface And Evidence Survey v0

Card: S3-R187-C2-P1  
Agent: [Research Agent]  
Role: research-agent  
Track: branch-conditional-if-expr-current-surface-and-evidence-survey-v0  
Route: UPDATE  
Depends on: S3-R186-C4-A  
Status: done  
Date: 2026-05-26

Affected neighbors:
- Compiler/Grammar Expert: parser, TypeChecker, SemanticIR, assembler, and
  future proof/implementation review surfaces.
- Bridge Agent: release/public wording and non-claim preservation.
- Research Agent: evidence indexing and harness/refusal traceability.

---

## Current Horizon

Branch/conditional `if_expr` is the accepted alpha/first-RC exclusion selected
for the next compiler/language lane. Parser syntax already exists and produces
`kind: "if_expr"`; support is blocked downstream by TypeChecker
`OOF-TY0 Unsupported expression kind: if_expr`. Release evidence now treats the
feature as `out_of_scope`, not a harness HOLD. No implementation, release
reopen, public demo, production, all-grammar, or Spark claim is authorized.

---

## Inputs Read

Required:

- `igniter-lang/docs/tracks/post-release-hygiene-and-next-lane-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round186-status-curation-v0.md`
- `igniter-lang/docs/tracks/first-rc-branch-conditional-scope-decision-v0.md`
- `igniter-lang/docs/tracks/first-rc-branch-conditional-scope-disposition-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-proof-v0.md`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`

Discovered during survey:

- `igniter-lang/docs/tracks/branch-conditional-if-expr-scope-and-semantics-design-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-scope-aware-update-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-closure-decision-v0.md`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/README.md`
- `igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json`
- `igniter-lang/lib/igniter_lang/parser.rb`
- `igniter-lang/lib/igniter_lang/classifier.rb`
- `igniter-lang/lib/igniter_lang/typechecker.rb`
- `igniter-lang/lib/igniter_lang/semanticir_emitter.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`

---

## Command Matrix

| Command / search | Result | Notes |
| --- | --- | --- |
| `sed` over required R186/R164/R160/R161 docs and harness summary | PASS | Read-only evidence extraction. |
| `rg -n "if_expr|branch_conditional|branch|conditional|Unsupported expression kind" igniter-lang/lib igniter-lang/spec igniter-lang/experiments igniter-lang/docs/tracks ...` | PARTIAL | `igniter-lang/spec` does not exist; useful results returned for lib/experiments/docs before the missing-dir error. |
| `rg -n "if_expr|branch_conditional_if_expr|no_branch_conditional_claim|Unsupported expression kind" igniter-lang/experiments ...` | PASS | Found harness/evidence markers and no executable positive `if_expr` artifact. |
| `rg -n "if_expr|\bif\b|else" igniter-lang/experiments -g "*.ig" ...` | PASS | Found pressure/specimen `.ig` sources using `if`, not current accepted compiler corpus. |
| `ruby -I igniter-lang/lib -e '<parse/classify/typecheck minimal if_expr source>'` | PASS | Parser returns no parse errors and `expr.kind=if_expr`; TypeChecker emits `OOF-TY0`. |
| `rg -n "supports branch|supports conditional|supports if_expr|..." igniter-lang/README.md igniter-lang/docs igniter-lang/experiments ...` | PASS | No incorrect support claim found; one stale harness README status note found. |

No broad test suite was run.

---

## Touchpoint Table

| Surface | File / path | Current evidence | Survey result |
| --- | --- | --- | --- |
| Lexer keywords | `igniter-lang/lib/igniter_lang/parser.rb:42-54` | `if else let` are parser keywords. | Syntax token support exists. |
| Parser primary expression | `igniter-lang/lib/igniter_lang/parser.rb:1571-1620` | `parse_primary` dispatches keyword `if` to `parse_if_expr`. | Parser already accepts expression-level `if` in expression positions. |
| Parsed AST shape | `igniter-lang/lib/igniter_lang/parser.rb:1612-1620` | Returns `{ "kind"=>"if_expr", "cond"=>..., "then"=>..., "else"=>... }`. | Current shape matches C1-D design. |
| Classifier compute handling | `igniter-lang/lib/igniter_lang/classifier.rb:134-149` | Compute declarations keep `expr` and `expr_kind`; dependency scan is generic. | Classifier does not block `if_expr`; it classifies compute as core when refs resolve. |
| Classifier expression refs | `igniter-lang/lib/igniter_lang/classifier.rb:323-348` | Unknown expression kinds recursively scan hash values. | `if_expr` dependencies can be collected without explicit classifier support. |
| TypeChecker expression inference | `igniter-lang/lib/igniter_lang/typechecker.rb:196-231` | Only literals, refs, field access, binary ops, calls, and index access are handled; fallback emits `OOF-TY0`. | This is the current refusal owner. |
| SemanticIR typed emission gate | `igniter-lang/lib/igniter_lang/semanticir_emitter.rb:26-33` | `emit_typed` emits no SemanticIR when `type_errors` is non-empty. | Current mainline does not emit `.igapp` for blocked `if_expr`. |
| Legacy parsed emitter fallback | `igniter-lang/lib/igniter_lang/semanticir_emitter.rb:640-692` | Unknown expression kinds become unsupported with `OOF-P0`. | Defensive/legacy path exists; mainline typed path blocks earlier. |
| Compiler orchestration | `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb:55-83` | Parser -> classifier -> TypeChecker -> typed emitter; refusal before assembler when report is OOF. | Future implementation affects at least TypeChecker and SemanticIR before assembler sees a positive artifact. |
| Harness summary | `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json` | `release_scope.excluded_features` includes `branch_conditional_if_expr`; feature status is `out_of_scope`. | Current release harness marker is already scope-aware. |
| Official RC evidence | `igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json` | Source harness PASS, excluded feature present, `no_branch_conditional_claim` present. | Stable evidence for exclusion, not support. |
| Harness local README | `igniter-lang/experiments/compiler_release_acceptance_harness_v0/README.md:32-36` | Still says expected status is HOLD because `if_expr` is unsupported. | Stale doc note after scope-aware PASS; not an incorrect support claim. |
| Pressure/specimen sources | `igniter-lang/experiments/human_agent_syntax_comprehension_fixture/*.ig` and `experiments/pressure-specimens/**` | Several `.ig` examples contain `if`/nested `if`. | Useful future specimens, but not accepted compiler corpus or `.igapp` evidence. |
| Public README/docs claims | `igniter-lang/README.md` and `igniter-lang/docs/**` targeted scan | README says branch/conditional/all-grammar remain excluded. | No incorrect claim of branch/conditional support found. |

---

## Minimal Current Probe

Read-only Ruby probe source:

```igniter
module Survey.IfExpr

contract IfExprProbe {
  input flag: Bool
  input a: Integer
  input b: Integer

  compute chosen = if flag { a } else { b }

  output chosen: Integer
}
```

Observed result:

```json
{
  "parse_errors": [],
  "compute_expr_kind": "if_expr",
  "typed_status": "blocked",
  "type_errors": [
    {
      "rule": "OOF-TY0",
      "message": "Unsupported expression kind: if_expr",
      "node": "chosen",
      "line": null
    },
    {
      "rule": "OOF-TY0",
      "message": "Type mismatch: expected Integer, got Unknown",
      "node": "chosen",
      "line": null
    }
  ]
}
```

Interpretation:

- There is already parsed syntax for `if_expr`.
- The primary stable refusal is downstream TypeChecker `OOF-TY0 Unsupported
  expression kind: if_expr`.
- The secondary output type mismatch is derivative from `chosen` resolving to
  `Unknown`; future diagnostics should avoid relying on that as the canonical
  branch/conditional refusal.

---

## Current Refusal / Evidence Summary

Stable enough to cite:

- `if_expr` is excluded from first RC / alpha by S3-R164-C4-A.
- Scope-aware harness records `branch_conditional_if_expr` as `out_of_scope`.
- Official first-RC evidence records `branch_conditional_if_expr` under
  `release_scope.excluded_features`.
- Current parser can produce `if_expr`.
- Current TypeChecker blocks it with `OOF-TY0 Unsupported expression kind:
  if_expr`.

Not stable enough to cite as future behavior:

- The derivative `Type mismatch: expected Integer, got Unknown` diagnostic.
- Legacy parsed-emitter `OOF-P0 Unsupported expression kind` for `if_expr`,
  because current orchestrator uses typed emission and blocks earlier.
- Harness README `Expected Status HOLD`, because the scope-aware update changed
  the current harness summary to PASS with `out_of_scope`.

---

## Answers To Required Questions

### Is there already parsed syntax for `if_expr`?

Yes.

`if` and `else` are lexer/parser keywords, `parse_primary` dispatches `if` to
`parse_if_expr`, and a minimal compute expression parses with `parse_errors: []`
and `expr.kind: "if_expr"`.

This is not only unsupported downstream expression-kind evidence.

### Is existing refusal evidence stable enough to cite?

Yes, with scope.

Stable citation:

```text
Current compiler path parses `if_expr` but TypeChecker blocks it with
OOF-TY0 Unsupported expression kind: if_expr. First RC / alpha evidence marks
branch_conditional_if_expr as out_of_scope, not supported.
```

Do not cite the secondary `Unknown` type mismatch or legacy parsed-emitter
fallback as the canonical refusal.

### Must any current release harness marker change before future support?

No marker must change before proof-only work.

Before accepted implementation support can be reflected in release evidence,
future harness evidence must change in a new authorized route:

- `feature_coverage.branch_conditional_if_expr.status`: `out_of_scope` ->
  `covered`;
- `release_scope.excluded_features`: remove or historical-scope it for the new
  evidence packet only;
- `no_branch_conditional_claim`: preserve for first-RC/alpha history, but do not
  carry as a current support non-claim after support is accepted;
- add positive and negative branch/conditional corpus cases.

Do not mutate accepted alpha/first-RC historical evidence retroactively.

### Do any current docs claim branch/conditional support incorrectly?

No incorrect support claim was found in targeted current docs/README scans.

Found docs mostly say the feature is excluded or a post-RC lane. One local
harness README line is stale because it still says the harness expected status
is HOLD, while current scope-aware summary is PASS with `if_expr` out of scope.
That is docs hygiene, not a branch support overclaim.

---

## Semantic / Artifact Assumptions At Risk

| Assumption | Current state | Risk if support is added hastily |
| --- | --- | --- |
| Condition typing | No TypeChecker path. | Truthiness or Unknown could slip in without `OOF-IF1`. |
| Else requirement | Parser allows `else` to be nil. | Expression-level `if` could become partial unless TypeChecker rejects missing else. |
| Branch type unification | No branch inference. | Output may be Unknown or silently widened without policy. |
| Branch value requirement | Parser block body can be empty or statement-shaped. | Empty branch could produce no value unless `OOF-IF4` exists. |
| Dependencies | Classifier currently gathers recursive refs; C1-D recommends union deps. | Path-sensitive deps should not be invented in v0. |
| SemanticIR shape | No typed `if_expr` node emitted today. | Assembler/runtime assumptions may break if shape is introduced without a proof. |
| `.igapp` exposure | No accepted positive `.igapp` currently contains `if_expr`. | Golden/artifact drift if harness corpus changes before support is accepted. |
| Release claims | Current evidence says out_of_scope. | Future docs could accidentally say all grammar or branch support before implementation acceptance. |

---

## Minimal Future Proof / Review Surfaces

Recommended next proof-only prerequisites before implementation authorization:

1. Parser acceptance fixture for minimal `if <Bool> { expr } else { expr }`
   showing current `if_expr` AST shape.
2. Current mainline refusal fixture proving TypeChecker `OOF-TY0` remains the
   pre-implementation behavior.
3. Proof-local TypeChecker model for future `OOF-IF1..OOF-IF4`:
   non-Bool condition, missing else, branch type mismatch, and non-value branch.
4. Proof-local typed expression shape:
   `kind: if_expr`, typed condition, typed then/else branches, resolved type,
   union deps.
5. Proof-local SemanticIR shape preserving `if_expr` as expression node, not
   new fragment/capability.
6. Release harness delta plan: one future positive branch corpus case plus
   targeted negatives, with accepted alpha evidence left unchanged.
7. Closed-surface scan proving no public/demo/all-grammar/release claim drift.

Implementation-review prerequisites:

- explicit gate authorizing TypeChecker changes;
- explicit gate authorizing SemanticIR emitter shape;
- assembler/golden impact review before `.igapp` artifact update;
- runtime smoke/evaluator support separated unless explicitly in scope.

---

## C3-X Risk List

| Risk | Severity | Notes |
| --- | --- | --- |
| Treating parser support as full feature support | High | Parser already accepts `if_expr`, but TypeChecker/SemanticIR do not support it. |
| Relying on derivative mismatch diagnostic | Medium | `expected Integer, got Unknown` is an artifact of unsupported inference. |
| Forgetting missing-else policy | High | Parser permits nil else; C1-D says expression-level v0 should require else. |
| Mutating accepted alpha evidence | High | Historical `out_of_scope` evidence must stay intact. |
| Changing harness feature marker too early | High | `out_of_scope` -> `covered` should wait for accepted support. |
| All-grammar/public-demo claim drift | High | Branch support is a visible release exclusion; docs must stay precise. |
| Pressure specimens mistaken for accepted corpus | Medium | Many `.ig` pressure/human-comprehension files use `if`; they are not current compile evidence. |
| SemanticIR/assembler drift | Medium | No positive `.igapp` shape currently proves `if_expr`. |
| Runtime overclaim | Medium | Compiler support does not automatically imply runtime evaluation support. |

---

## Recommendation

Recommendation:

```text
proceed to proof-only branch-conditional-if-expr-semantics-proof-v0;
do not open implementation authorization yet;
preserve release evidence as out_of_scope until support is accepted.
```

Best immediate proof-only lane:

- use the existing parser shape as a positive parser fact;
- model future TypeChecker/SemanticIR behavior proof-locally;
- keep current mainline refusal evidence visible;
- leave harness/release markers unchanged except in a future accepted support
  evidence packet.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/branch-conditional-if-expr-current-surface-and-evidence-survey-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Survey found parser syntax already exists for if_expr.
- Current support is blocked at TypeChecker with OOF-TY0, not parser absence.
- Release/harness evidence currently marks branch_conditional_if_expr as
  out_of_scope and should not change before accepted support.

[R] Recommendations:
- Open proof-only semantics fixture next.
- Treat C1-D OOF-IF1..OOF-IF4 as future proof-local diagnostics before code.
- Keep runtime/evaluator support separate from compiler support.

[S] Signals:
- Minimal probe: parse_errors [], expr.kind if_expr, typed contract blocked.
- Official RC evidence: branch_conditional_if_expr in excluded_features and
  no_branch_conditional_claim present.
- No current public docs support overclaim found; harness README has stale HOLD
  wording only.

[T] Tests / Proofs:
- Targeted parser/classifier/typechecker Ruby probe run.
- Targeted rg scans over lib/docs/experiments.
- No broad test suite run.

[Files] Changed:
- igniter-lang/docs/tracks/branch-conditional-if-expr-current-surface-and-evidence-survey-v0.md

[Q] Open Questions:
- Should the next proof-only fixture live under Compiler/Grammar ownership or
  Research ownership with Compiler/Grammar review?
- Should the stale harness README HOLD note be cleaned in a separate docs
  hygiene card?

[X] Rejected:
- No implementation.
- No parser/TypeChecker/SemanticIR/assembler edits.
- No harness/golden/.igapp mutation.
- No release/public-demo/production/all-grammar/Spark claim.

[Next] Proposed next slice:
- branch-conditional-if-expr-semantics-proof-v0, proof-only, with parser fact,
  current refusal, future OOF-IF diagnostics model, SemanticIR sketch, and
  release-harness delta plan.
```
