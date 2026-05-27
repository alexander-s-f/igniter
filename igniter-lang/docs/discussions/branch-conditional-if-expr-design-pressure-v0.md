# Branch Conditional If Expr Design Pressure v0

Card: S3-R187-C3-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Track: branch-conditional-if-expr-design-pressure-v0

Context:
- Write access: none
- Canon authority: none

---

## Inputs Read

| File | Card | Role |
| --- | --- | --- |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-scope-and-semantics-design-v0.md` | S3-R187-C1-D | Scope and semantics design |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-current-surface-and-evidence-survey-v0.md` | S3-R187-C2-P1 | Current-surface evidence survey |
| `igniter-lang/docs/tracks/post-release-hygiene-and-next-lane-decision-v0.md` | S3-R186-C4-A | Next-lane authorization (design/proof planning only) |
| `igniter-lang/docs/tracks/stage3-round186-status-curation-v0.md` | S3-R186-C5-S | R186 status curation |

---

## Question

Are the S3-R187 `if_expr` scope-and-semantics design (C1-D) and current-surface
evidence survey (C2-P1) semantically complete, correctly bounded, proof-ready,
and free of implementation authority — with v0 scope narrow enough, condition
and branch-unification semantics explicit, diagnostic ownership clear,
touchpoints mapped without authorizing edits, proof prerequisites concrete, and
all closed surfaces preserved?

---

## Scope Checks

| # | Check | Result | Notes |
| --- | --- | --- | --- |
| SC-1 | C1-D does not authorize parser, TypeChecker, SemanticIR, assembler, artifact, runtime, or public API/CLI changes | PASS | "This track does not authorize..." preamble explicit; no code edits |
| SC-2 | C2-P1 is read-only: Ruby probe, rg scans, sed reads — no file mutations | PASS | Command matrix confirms read-only; "[Files] Changed" section lists track doc only |
| SC-3 | V0 scope is narrow: expression-level only, else required, no statement/guard/pattern/multi-branch/else-less/branch-local-decl/effect | PASS | Semantics matrix deferred column confirms all non-v0 forms explicitly excluded |
| SC-4 | Condition type semantics are explicit: `Bool` required, no truthiness coercion, `OOF-IF1` for violation | PASS | C1-D §Diagnostics and §Semantics Matrix both specify this; C2-P1 risk table lists "Truthiness or Unknown could slip in without OOF-IF1" as identified risk |
| SC-5 | Branch unification semantics are explicit: exact type match required, no widening/coercion/union, `OOF-IF3` for mismatch | PASS | Semantics matrix: "Then and else branch types must match exactly" with numeric widening / union types in deferred column |
| SC-6 | Missing-else rule is explicit and addresses parser permissiveness: parser allows nil else; TypeChecker must reject via `OOF-IF2` | PASS | C1-D: "Require an else block; otherwise emit OOF-IF2." C2-P1 risk table: "Parser allows `else` to be nil. Expression-level `if` could become partial unless TypeChecker rejects missing else." |
| SC-7 | Branch value requirement is explicit: non-value branch rejected via `OOF-IF4` | PASS | C1-D: "Require final value expression for then and else blocks" in TypeChecker section |
| SC-8 | Diagnostic ownership is clear: Parser owns malformed syntax; TypeChecker owns OOF-IF1..OOF-IF4; SemanticIR owns no primary typing diagnostics | PASS | C1-D §Diagnostic Vocabulary: ownership column explicit for each code |
| SC-9 | Parser/TypeChecker/SemanticIR/assembler touchpoints are mapped by C2-P1 with file:line citations and not authorized for edit | PASS | Touchpoint table includes exact file:line for each layer; no edit is opened |
| SC-10 | Proof-only prerequisites are concrete: 12 named cases in C1-D proof matrix, 7 numbered items in C2-P1 future proof surfaces | PASS | Cases cover parser acceptance, mainline refusal survival, four OOF-IF proof-local models, SemanticIR sketch, release harness delta plan, closed-surface scan |
| SC-11 | C1-D and C2-P1 are mutually consistent on AST shape, current refusal, and recommended next route | PASS | AST `{ "kind": "if_expr", "cond": ..., "then": ..., "else": ... }` matches in both; primary refusal OOF-TY0 confirmed by both; proof-only next |
| SC-12 | No release/public-demo/production/all-grammar/Spark/API/CLI widening smuggled by either card | PASS | C1-D Closed Surfaces: comprehensive 18-surface list; C2-P1 Handoff [X] Rejected: explicit |
| SC-13 | Branch/conditional implementation remains closed | PASS | C1-D: "May implementation open next? No." C2-P1: "do not open implementation authorization yet." |
| SC-14 | Release harness markers must not change before accepted support; accepted alpha evidence must not be mutated retroactively | PASS | C1-D: "branch_conditional_if_expr remains excluded/out_of_scope in release evidence" until support accepted; C2-P1: same; harness mutation HELD |
| SC-15 | C2-P1's derivative secondary diagnostic (`Type mismatch: expected Integer, got Unknown`) is correctly identified as non-stable and must not be cited as the canonical refusal | PASS | C2-P1: "Do not cite the secondary `Unknown` type mismatch... as the canonical refusal" — explicit policy |
| SC-16 | C2-P1's pressure/specimen `.ig` files in `experiments/human_agent_syntax_comprehension_fixture/` and `experiments/pressure-specimens/` are correctly excluded from accepted corpus | PASS | C2-P1: "Useful future specimens, but not accepted compiler corpus or .igapp evidence" |
| SC-17 | No incorrect public docs claim of branch/conditional support was found by C2-P1 | PASS | C2-P1: "No incorrect support claim was found in targeted current docs/README scans" |

All 17 scope checks: **PASS**. No blockers.

---

## [Agree]

- C1-D's v0 scope decision (expression-level if/else only, else required,
  `Bool` condition, exact branch type match) is the right minimal target. Each
  of the four semantics rules independently closes a distinct attack surface for
  unsound typing: OOF-IF1 closes truthiness coercion, OOF-IF2 closes partial
  expressions, OOF-IF3 closes type widening, OOF-IF4 closes empty/statement-
  shaped branches. Taken together they form a sound minimal type-safe expression
  for v0.

- C2-P1's evidence is genuinely useful: the parser:line citation confirms the
  exact dispatch path (`parse_primary` → keyword `if` → `parse_if_expr`) and
  the live Ruby probe confirms the boundary (parse succeeds, TypeChecker emits
  `OOF-TY0`, output node is `Unknown`). This is the right evidence posture —
  collect a live minimal probe rather than hypothesize.

- The design card correctly handles the parser permissiveness gap. Parser
  currently allows `else: nil`. C1-D explicitly assigns the missing-else
  requirement to TypeChecker as OOF-IF2, which is the right layer to enforce
  semantic constraints that the grammar intentionally leaves flexible for
  statement-level use later.

- C1-D's `resolved_type` field in the typed expression (`"resolved_type":
  "...matched branch type..."`) and `deps: union of all branch deps` are the
  right conservative choices for v0. Union dependencies avoid path-sensitive
  dependency pruning, which would require a significantly more complex proof
  surface. This is correctly deferred.

- C2-P1 correctly flags that the existing harness README still says "Expected
  Status HOLD" — this is stale docs after the scope-aware PASS, not an
  incorrect support claim. The survey rightly does not mutate it and leaves
  cleanup to a future card.

- The two-card structure (C1-D semantics design + C2-P1 code survey) is well-
  chosen: C1-D establishes semantic intent without code access, C2-P1 grounds
  the design in live code evidence independently. Together they provide a sound
  foundation for the proof-only card.

---

## [Challenge]

- **OOF-IF5 dual ownership is unresolved.** C1-D assigns OOF-IF5 to "Parser or
  TypeChecker" and says "reserve for future syntax boundary; do not emit unless
  needed." This is a placeholder diagnostic with no single owner. If OOF-IF5
  is eventually emitted, the evaluator at that future pressure round will not
  know whether parser or TypeChecker is the authority and whether the other layer
  is suppressing a redundant emission. The design card should either commit to
  one owner or eliminate OOF-IF5 as a named code and leave the future syntax
  boundary as TBD. As written, the dual-owner pattern could leak into the proof
  card and require an ad-hoc ownership resolution.

- **`Bool` type identity is not pinned.** C1-D says "Condition type: Must be
  `Bool`" without specifying what `Bool` resolves to in the current type system.
  C2-P1's probe source uses `input flag: Bool` but does not show how `Bool` is
  represented in the resolved type name (string, symbol, canonical reference).
  The condition type check at OOF-IF1 requires the TypeChecker to compare the
  resolved condition type against `Bool`. If `Bool` resolves to a different
  internal name (e.g., `"Boolean"`, `{ name: "Bool", params: [] }`), the OOF-IF1
  trigger condition in the proof model could be imprecise. The proof card should
  pin the exact resolved type representation before modeling OOF-IF1.

---

## [Missing]

- **No explicit specification of the SemanticIR branch-lowering choice.** C1-D
  identifies two open questions for the proof-only route: "(a) whether branch
  blocks lower as `branch_expr` wrappers or directly as final expressions; (b)
  whether the dependency graph records all branch dependencies or annotates them
  as conditional." C1-D recommends union dependencies first, but does not pin
  the `branch_expr` wrapper question. The proof card will need to make this
  choice before modeling the SemanticIR shape. Both options are stated but no
  recommended default is given. The proof card owner should record which one
  they model and why, so the C4-A can evaluate the choice.

- **Proof fixture experiment directory path is unspecified.** Neither C1-D nor
  C2-P1 names the experiment directory for the proof-only fixtures. Prior proof
  rounds used `igniter-lang/experiments/<track_name>/` with a companion README
  and summary JSON. The proof card (S3-R187-C3-P1 in C1-D, or the yet-to-be-
  named next proof route) should specify this path before running commands. Not
  a blocker for C3-X acceptance, but a prerequisite for proof card dispatch.

- **Stale harness README cleanup has no explicit assignment.** C2-P1 flags the
  stale HOLD note in `experiments/compiler_release_acceptance_harness_v0/
  README.md:32-36` as docs hygiene and asks whether it should be cleaned in a
  separate card. C1-D does not mention it. C3-A should decide at dispatch: fold
  into the proof card as a write-scope addition, or defer to a standalone hygiene
  card. Either is acceptable; the current open question should not become an
  implicit authorization.

---

## [Sharper Question]

> When the proof-local TypeChecker model tests OOF-IF1 ("condition is not
> `Bool`"), what exactly is the condition type it compares against — a resolved
> type string `"Bool"`, a hash `{ name: "Bool", params: [] }`, or the internal
> representation from a `Bool` input node's resolved type field?

This question determines whether the proof-local model faithfully represents the
future live TypeChecker, or whether the proof-local model will use a hardcoded
string that diverges from what the TypeChecker would actually resolve. If the
proof-local model uses the wrong shape, the OOF-IF1 proof gives false confidence.
The proof card should open C2-P1 `typechecker.rb:196-231` to read one resolved
type from an accepted positive `Bool` input, then pin that representation before
modeling OOF-IF1.

---

## [Route]

Proceed with non-blocking notes.

- All 17 scope checks PASS.
- No blockers.
- Three non-blocking notes:

**NB-1:** OOF-IF5 dual ownership ("Parser or TypeChecker") should be resolved
to a single owner or eliminated as a named code before the proof card models the
`OOF-IF*` vocabulary. Recommended: drop OOF-IF5 from the proof card scope
entirely and leave future syntax boundary as TBD until a concrete trigger is
identified.

**NB-2:** `Bool` type identity should be pinned by reading a resolved `Bool`
input from `typechecker.rb` before modeling OOF-IF1. The proof card should
record the exact resolved type representation used as the gate condition.

**NB-3:** SemanticIR `branch_expr`-wrapper vs direct-expression lowering is
left open. The proof card should commit to one model and record the choice
explicitly so C4-A can evaluate it at acceptance. Recommended default:
direct-expression lowering (no `branch_expr` wrapper) for minimal SemanticIR
surface, unless a read of `semanticir_emitter.rb` shows existing analogous
wrapper usage.

---

## Recommended C4-A Decision Boundary

Portfolio C4-A may accept both S3-R187-C1-D and S3-R187-C2-P1 and open the
proof-only route:

```text
Card: S3-R187-C3-P1 (or next sequential card designation)
Agent: [Compiler/Grammar Expert]
Track: branch-conditional-if-expr-semantics-proof-v0
Mode: proof-only / no compiler code edits
```

Binding gate conditions from NB-1..NB-3 for the proof card:

```text
OOF-IF5 handling: drop from proof scope or assign single owner before modeling
Bool resolved type: pin from live typechecker.rb read before modeling OOF-IF1
SemanticIR branch shape: commit to wrapper vs direct and record choice explicitly
```

Optional add to proof card write scope:

```text
Stale harness README HOLD note cleanup (experiments/compiler_release_acceptance_harness_v0/README.md:32-36)
```

Implementation authorization review should not open until the proof card passes
and its diagnostics/SemanticIR shape are accepted by pressure and C4-A.

---

## Compact Pressure Verdict

```text
card:           S3-R187-C3-X
track:          branch-conditional-if-expr-design-pressure-v0
verdict:        proceed with non-blocking notes
checks:         17/17 PASS
blockers:       none
non-blocking:   3

NB-1: OOF-IF5 dual ownership (Parser or TypeChecker) unresolved — drop from
      proof scope or assign single owner before modeling OOF-IF* vocabulary.

NB-2: Bool type identity not pinned — proof card must read resolved Bool
      representation from typechecker.rb before modeling OOF-IF1 trigger
      condition.

NB-3: SemanticIR branch lowering choice open (branch_expr wrapper vs direct
      expression) — proof card must commit to one model and record the choice
      explicitly.

C4-A recommended decision:
  accept C1-D and C2-P1; open proof-only route with NB-1..NB-3 as binding
  gate conditions; carry stale harness README cleanup as optional proof card
  addition; keep implementation authorization closed.

closed surfaces confirmed:
  parser/TypeChecker/SemanticIR/assembler changes, if_expr implementation,
  release execution, second release route, stable/production/demo/all-grammar
  claims, Spark, runtime, API/CLI widening, profile finalization/discovery/
  defaulting, harness golden mutation before accepted support.
```
