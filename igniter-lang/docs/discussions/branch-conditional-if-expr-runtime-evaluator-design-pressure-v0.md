# Branch Conditional If Expr Runtime Evaluator Design Pressure v0

Card: S3-R196-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Track: branch-conditional-if-expr-runtime-evaluator-design-pressure-v0

Context: internal — full read access to C1-D design track, R195 status
curation, R195 C3-A acceptance decision, and live runtime/evaluator source
files cited by C1-D (`runtime_smoke.rb`, `compiled_program.rb`)
Write access: none
Canon authority: none

---

## Question

Does the S3-R196-C1-D runtime/evaluator design correctly mandate lazy branch
semantics, prohibit non-selected branch execution unambiguously, specify
complete failure propagation, correctly bound static dependency union and
defer path-sensitive cache tracking, keep the design itself code-change-free,
avoid implying parser/TypeChecker/SemanticIR/compiler behavior changes, keep
all public/release/Spark/API/CLI claims closed, and provide a proof matrix
sufficient for a later implementation-authorization review?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-evaluator-design-v0.md` (S3-R196-C1-D)
- `igniter-lang/docs/tracks/stage3-round195-status-curation-v0.md` (S3-R195-C4-S)
- `igniter-lang/docs/tracks/branch-conditional-if-expr-release-harness-delta-proof-acceptance-decision-v0.md` (S3-R195-C3-A)
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb` (live code cross-check)
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb` (live code cross-check, particularly `eval_expr`)

---

## Live Code Cross-Check

C1-D's runtime architecture claims verified against live source:

```text
Claim 1: RuntimeSmoke is proof-backed and delegates to
         experiments/runtime_machine_memory_proof.
Verified: runtime_smoke.rb line 6 — require_relative
  "../../experiments/runtime_machine_memory_proof/compiled_program"
Status: ✓

Claim 2: The current proof evaluator raises on unknown expression kinds.
Verified: compiled_program.rb eval_expr (else branch) —
  raise ArgumentError, "Unknown expression kind: #{expr["kind"]}"
Status: ✓

Claim 3: No general production if_expr evaluator is present in lib/.
Verified: eval_expr case handles only: apply, field_access, literal, ref,
  tbackend_read. No if_expr case present.
Status: ✓

Claim 4: CompilerOrchestrator accepts optional runtime_smoke: callback
         after assembly and does not own expression evaluation.
Status: not re-read independently; consistent with C1-D description and
  no conflicting evidence in runtime_smoke.rb.

Claim 5: .igapp compute nodes carry expressions via assembler but this
         artifact carriage is not runtime support.
Status: consistent with CompiledProgram.evaluate_contract reading
  compute_nodes and calling eval_expr — no if_expr in eval_expr means
  any if_expr contract would currently raise at runtime.
```

All verifiable live-code claims in C1-D are confirmed.

---

## Scope Check Matrix

| ID | Check | Evidence | Result |
| --- | --- | --- | --- |
| SC-1 | Design-only — no runtime/evaluator code edits | C1-D changed-file list absent (design cards produce no code output); "Inputs Read" lists only source files; C1-D explicitly states "does not edit runtime/evaluator code"; no `require_relative`, `def`, or mutation language in body | PASS |
| SC-2 | Lazy semantics explicit and testable | 5-step evaluation order defined; "Non-selected branch evaluation is forbidden in v0" stated without qualification; semantics matrix covers all 10 behavioral cases; RT-IF3/RT-IF4 require proof that would-fail non-selected branches produce no failure | PASS |
| SC-3 | Non-selected branch prohibition unambiguous | Table row "Non-selected branch would fail → No failure; proof must show the non-selected branch is not evaluated"; failure-propagation table row "Non-selected branch failure → Must not fire"; explicit in both Semantics Matrix and Failure Propagation section; zero ambiguity about opt-out paths | PASS |
| SC-4 | Failure propagation complete and unambiguous | Failure table covers 6 distinct cases: condition failure, selected branch failure, non-selected branch (must not fire), malformed node, unsupported in selected path, unsupported in non-selected path. Condition-failure-before-branch-selection is explicit. | PASS |
| SC-5 | Static dependency union correctly bounded; path-sensitive cache deferred | "TypeChecker/SemanticIR dependency metadata remains conservative and includes condition plus both branches"; "Dynamic selected-branch dependency tracking is deferred"; "Path-sensitive cache keys, invalidation, freshness, or dependency receipts are out of scope until a separate cache/runtime design authorizes them" — all explicit | PASS |
| SC-6 | No parser/TypeChecker/SemanticIR/compiler behavior changes implied | C1-D closed surfaces list includes "parser, classifier, TypeChecker, SemanticIR, assembler changes"; design only observes accepted compiler output; no OOF-* code changes proposed; no `lib/igniter_lang/typechecker.rb` or `semanticir_emitter.rb` changes | PASS |
| SC-7 | No release/public/Spark/API/CLI claims | Closed surfaces explicitly enumerate: "public demo/release/stable/production/all-grammar claims"; "public API/CLI widening"; "Spark data, fixtures, specs, ids, integration, or demo behavior"; "release harness mutation or release command execution"; release lane confirmed paused | PASS |
| SC-8 | Proof matrix sufficient for later implementation-authorization review | RT-IF1..RT-IF13 covers: true/false branch selection (RT-IF1/2), would-fail non-selected branch (RT-IF3/4), condition failure (RT-IF5), selected branch failure (RT-IF6), non-Bool rejection (RT-IF7), malformed node (RT-IF8), unsupported in selected path (RT-IF9), unsupported in non-selected path (RT-IF10), nested recursion (RT-IF11), static-vs-dynamic dependency observation (RT-IF12), closed-surface scan (RT-IF13) | PASS |
| SC-9 | Implementation scope future-only; recommended placement clearly bounded | Placement table presents 5 options; Option A (proof-local experiment) recommended first; live runtime library integration held until proof-local semantics pass; "Live library/runtime implementation should wait" stated explicitly | PASS |

Overall: **9/9 PASS** — no blockers.

---

## [Agree]

- The lazy-evaluation mandate is unambiguous and correctly motivated.
  Eager evaluation is correctly rejected because it would fire non-selected
  branch failures and side effects, making branch conditionals operationally
  weaker than their source-language meaning. The 5-step evaluation order
  (evaluate condition → test Bool → select one branch → evaluate selected
  → return selected value) is the minimum necessary specification.

- The non-selected branch prohibition is stated twice — in the Semantics
  Matrix table and in the Failure Propagation table — with no hedges or
  opt-outs. This double coverage prevents a future implementation card from
  claiming partial laziness (e.g., "we short-circuit but the non-selected
  branch is still parsed by the evaluator") as compliant.

- The proof matrix item RT-IF3 ("Non-selected `then_branch` would fail — No
  failure when condition is `false`") and RT-IF4 ("Non-selected `else_branch`
  would fail — No failure when condition is `true`") are exactly the right
  proof cases. Without them, a proof could pass even with an eager evaluator
  that happened not to fail on the non-selected branch for the specific test
  inputs chosen.

- RT-IF10 ("Unknown non-selected-path expression kind — No failure") is a
  strong specification requirement. It requires the evaluator not to inspect
  or raise for non-selected branches even if they contain expression kinds
  the evaluator does not recognize. This is the correct behavior for a lazy
  evaluator and it is the right proof case to require.

- The Bool requirement section correctly prohibits truthy/falsy Ruby coercion
  (strings, numbers, arrays, hashes, nil). This is grounded in the compiler
  boundary that already requires canonical `{"name":"Bool","params":[]}`. A
  runtime that accepted any truthy Ruby value would silently widen the
  language semantics beyond the TypeChecker rule.

- The static dependency union policy is correctly conservative. The design
  explicitly separates two concepts that are easy to conflate: (1) the
  runtime evaluator may touch only the selected branch during execution, and
  (2) the compile-time/artifact dependency metadata still includes condition
  plus both branches. Keeping (2) unchanged is correct because changing it
  would require SemanticIR, `.igapp`, and cache invalidation design work that
  is explicitly deferred.

- The diagnostic vocabulary decision (no new `OOF-RT-*` codes in this design
  card) is correct. The design card correctly identifies that runtime errors
  belong to the runtime/evaluator layer, not the compiler OOF namespace, and
  that the existing proof runtime uses plain `ArgumentError` strings. The
  candidate `runtime.if_expr_*` codes are labeled provisional, not accepted.

- The placement option table is sound. Option A (proof-local experiment) is
  the only correct first step: it proves lazy semantics, malformed-node
  failure, and closed-surface isolation without touching live runtime paths.
  Option D (wire through `RuntimeSmoke`/`CompilerOrchestrator`) is correctly
  flagged as "not first" because it risks implying public/runtime support and
  report behavior changes.

- The live code cross-check confirms all verifiable C1-D architecture claims:
  `RuntimeSmoke` delegates to the proof experiment; `eval_expr` raises on
  unknown expression kinds; no `if_expr` case is present in the evaluator.
  The design is grounded in the actual current codebase state.

- The design-only discipline is clean. No code diffs, no new `require`
  statements, no implementation-authorized language. Inputs are read-only.
  The card explicitly states it does not authorize implementation.

---

## [Challenge]

No blocking challenges.

Three non-blocking clarification notes follow.

---

## [Missing]

No blocking gaps. Three non-blocking notes:

**NB-1: RT-IF12 "touch trace" concept introduces a new term without defining
its proof-implementation relationship**

The RT-IF12 proof case description reads: "Static deps remain union; runtime
trace touches selected path only." The term "runtime trace" or "touch trace"
does not appear elsewhere in the design or in the current runtime codebase. It
is not clear whether RT-IF12 requires the proof runner to instrument and record
which expressions were evaluated (a new mechanism), or whether it is sufficient
to assert the static dependency union value and separately assert that the proof
evaluator only called `eval_expr` on the selected branch (a structural argument
derivable from the implementation).

The concern is not semantic — RT-IF12 intent is clear (static metadata stays
conservative, but evaluator touches only selected path at runtime). The concern
is that a future implementation card might interpret "runtime trace" as requiring
a dynamic dependency recording mechanism, which would be a scope creep beyond
what the design permits.

Recommendation for C3-A: note in the acceptance gate that RT-IF12 may be
satisfied by structural proof (showing the evaluator's call path only reaches
`eval_expr` for the selected branch) rather than requiring a new instrumented
touch-tracing mechanism. The proof card should not introduce dynamic dependency
tracking to satisfy RT-IF12.

**NB-2: Candidate runtime diagnostic codes are provisional but the decision
boundary between "use them" and "don't" is deferred without a named gate**

The design presents five `runtime.if_expr_*` candidate codes and says "A future
implementation review should prefer existing runtime error surfaces if they are
sufficient." This creates an unresolved decision: either the proof evaluator uses
the `ArgumentError` / string-based error surfaces already in `eval_expr`, or it
introduces the candidate `runtime.*` structured codes.

For a proof-local experiment (Option A), this decision is low-stakes because the
proof outputs are local. For any live integration (Options B–D), the error surface
becomes observable. The design correctly leaves this to the implementation review,
but does not name what evidence would trigger "existing surfaces are sufficient"
vs. "structured codes are needed."

Recommendation for C3-A: note that the implementation authorization review must
explicitly decide the error surface (plain raise vs. structured `runtime.*`
codes) before any diagnostic code is published or appears in a non-local proof
summary. This is not a blocker for the design card.

**NB-3: Option C authorization criteria are undefined**

Option C ("Extend `runtime_machine_memory_proof` evaluator") is listed as
"viable only with explicit proof-runtime authorization" but does not define what
that authorization requires. Since Option A is the recommended first route, this
is a cosmetic gap — Option C cannot open until Option A completes and a separate
review names the criteria.

Recommendation for C3-A: carry the note that any future Option C authorization
review must require: (a) proof that adding a new `when "if_expr"` case does not
alter existing expression-kind behavior, and (b) an explicit decision about
whether `runtime_machine_memory_proof` experiments are the appropriate layer for
live production evaluator behavior. This is forward-guidance only; not a blocker
for current acceptance.

---

## [Sharper Question]

If the proof-local evaluator experiment (Option A) passes RT-IF1..RT-IF13,
does that result automatically authorize a live library evaluator
(Option B), or does a separate implementation-authorization review remain
required?

Answer: A separate authorization review remains required. Option A proves
lazy branch semantics in an isolated experiment environment. A live library
evaluator (`lib/igniter_lang/semanticir_expression_evaluator.rb` or an
equivalent) introduces:

1. A new public-facing `lib/` surface with naming, require-path, and API
   stability implications not addressed by the proof-local experiment.
2. Integration questions with `RuntimeSmoke`, `CompilerOrchestrator`, and
   the `evaluate_contract` call path in `compiled_program.rb`.
3. A new `require_relative` dependency chain not present in the proof
   experiment.
4. A result-shape decision for the live evaluator output that affects
   `CompilerResult`, `CompilationReport`, or any downstream that consumes
   evaluated contract values.

These are all surfaces the design correctly marks as closed (Option B risk
column: "Opens live lib surface, naming, require, and result-shape questions").
The design explicitly says "Live library/runtime integration ... should wait
until the proof shows lazy branch behavior, malformed-node failure, and
closed-surface isolation have passed." A passing Option A proof would be a
necessary input to Option B authorization but would not constitute authorization
by itself.

---

## [Route]

**Verdict: proceed — 9/9 PASS, no blockers.**

```text
checks total: 9
checks pass:  9
checks fail:  0
blockers:     none
non-blocking notes: 3

NB-1: RT-IF12 "touch trace" term is underspecified; may be satisfied by
      structural proof without dynamic dependency recording; C3-A should note
      this to prevent scope creep in implementation card

NB-2: Candidate runtime.if_expr_* codes deferred without a named gate condition;
      implementation authorization review must decide error surface before any
      code is published; non-blocking for design acceptance

NB-3: Option C authorization criteria undefined; Option A is recommended first
      so this is cosmetic; carry as forward-guidance only
```

**Exact recommendation for C3-A:**

```text
Accept runtime/evaluator design.

1. Accept lazy branch semantics as the required v0 runtime policy:
   evaluate condition → require Bool → select one branch → evaluate only
   selected branch → return selected value.

2. Accept that non-selected branch evaluation is forbidden. This includes
   expressions that would fail, raise, or produce side effects in the
   non-selected branch. RT-IF3 and RT-IF4 are binding proof requirements.

3. Accept the failure propagation table as the complete v0 policy:
   condition failure before branches, selected-branch failure propagated,
   non-selected branch must not fire, malformed node fails closed.

4. Accept the static dependency union policy: compiler/SemanticIR
   dependency metadata remains conservative (condition + both branches);
   dynamic selected-branch dependency tracking is deferred; path-sensitive
   cache keys and invalidation are out of scope for v0.

5. Accept RT-IF1..RT-IF13 as the required proof matrix for a later
   implementation-authorization review. The proof matrix is sufficient
   for a proof-local evaluator experiment (Option A).

6. Accept the Option A placement recommendation: a new proof-local
   experiment directory is the authorized first implementation route.
   Live runtime library integration (Options B–D) remains closed until
   Option A passes and a separate review names the live write scope.

7. Carry NB-1: note in the authorization boundary for the implementation
   card that RT-IF12 may be satisfied by structural proof (call-path
   analysis showing eval_expr is only reached for the selected branch)
   without requiring a new dynamic touch-tracing mechanism.

8. Carry NB-2: the implementation authorization review must decide the
   error surface (plain raise vs. structured runtime.* codes) before any
   runtime diagnostic code appears in a non-local proof summary.

9. Carry NB-3: any future Option C authorization must require proof
   of existing-expression-kind non-regression and an explicit decision
   about the proof-runtime vs. production-runtime layer boundary.

10. Keep all closed surfaces closed:
    runtime/evaluator implementation, live RuntimeSmoke / CompilerOrchestrator
    behavior changes, parser / TypeChecker / SemanticIR / assembler,
    release execution, public release / demo / stable / production /
    all-grammar claims, Spark, API / CLI, .igapp / manifest / golden
    mutation, docs / spec edits.
```

Route: `track` — accept design; authorize a later implementation-authorization
review for a proof-local if_expr runtime/evaluator experiment only; keep live
runtime, release, public, Spark, API/CLI, artifact, and production surfaces
closed.
