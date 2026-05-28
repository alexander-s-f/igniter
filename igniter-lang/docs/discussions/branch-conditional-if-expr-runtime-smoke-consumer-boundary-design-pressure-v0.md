# Branch Conditional If Expr Runtime Smoke Consumer Boundary Design Pressure v0

Card: S3-R202-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Track: branch-conditional-if-expr-runtime-smoke-consumer-boundary-design-pressure-v0

Context: public-github-only
Write access: none
Canon authority: none

Depends on:
- S3-R202-C1-D

---

## Question

Does the S3-R202-C1-D RuntimeSmoke consumer boundary design treat the transitive
evaluator load correctly (not as a support claim), keep `runtime_smoke.rb`
unchanged, specify a boundary specific enough for an authorization review,
explicitly preserve `RuntimeSmoke.run`/`callback`/`eval_input_for` shapes,
handle the dual-path evaluator question without forcing unification, cover the
required proof matrix cases, and keep root require, CompilerOrchestrator,
CompilerResult, CompilationReport, dynamic dep/cache, counterfactual audit, and
release/public/Spark/API/CLI all closed?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-boundary-design-v0.md`
  (S3-R202-C1-D design — done, design-only)
- `igniter-lang/docs/tracks/stage3-round201-status-curation-v0.md`
  (R201 status — accepted Slice 2 proof RuntimeMachine consumer; routes R202 design)
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-acceptance-decision-v0.md`
  (C4-A Slice 2 acceptance — accepted PRT-IF1..PRT-IF15 / 56/56 PASS)
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
  (live RuntimeSmoke — 80 lines; requires compiled_program; fixed result shape)
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
  (proof RuntimeMachine — if_expr adapter wired; local apply/field_access/tbackend_read)
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
  (live evaluator — Slice 2 dual-path; SUPPORTED_KINDS frozen)

---

## RuntimeSmoke Source State (Independently Verified)

`runtime_smoke.rb` (80 lines, frozen_string_literal):

```ruby
# Load path:
require_relative "../../experiments/runtime_machine_memory_proof/compiled_program"

# run() return shape (success):
{ "load_status", "contract_id", "evaluate_status", "outputs",
  "compatibility_report_status", "trusted" }

# run() return shape (failure):
{ "load_status" => "blocked", "error", "trusted" => false }

# callback: returns a lambda delegating to run()
# eval_input_for: special-cases contract_id == "Add" only; otherwise returns sample_input
# available?: checks for CompiledProgram and RuntimeMachine constants
# ensure_available!: raises LoadError if not available
```

The `run` method uses a blanket `rescue => e` that converts any exception to the
failure shape. This means evaluator-raised exceptions (`ConditionNotBoolError`,
`MalformedIfExprError`, etc.) would surface as `load_status: "blocked", trusted:
false` rather than being re-raised. This is existing behavior and relevant to
proof case design.

---

## Scope Check Matrix

| SC | Scope check | Result | Evidence |
|----|-------------|--------|----------|
| SC-1 | Design is design-only | PASS | Card states "This card does not edit files, does not authorize implementation." Explicit answer: "Is RuntimeSmoke implementation authorized now? No. This design card authorizes nothing." No code files in write scope. |
| SC-2 | Transitive evaluator load not treated as support claim | PASS | "Distinctions" table explicitly separates transitive load (accepted consequence) from proof consumption (may open later) from RuntimeSmoke support (not yet accepted) from public runtime support (closed). Exact statement: "Transitive load alone must not be counted as support." RS-IF2 requires this distinction be machine-asserted. |
| SC-3 | RuntimeSmoke proof boundary specific enough for authorization review | PASS | Write scope named: `experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0/**` + track doc. Read-only surfaces named. Harness pattern (5 steps) specified. RS-IF1..RS-IF15 matrix defined. 5-command matrix specified. C3-A decision table lists 7 options. |
| SC-4 | RuntimeSmoke.run result shape explicitly preserved or deferred | PASS | Explicit answer: "May `RuntimeSmoke.run` result shape change? No. It must remain unchanged for the first RuntimeSmoke consumer proof." RS-IF7 requires exact key set unchanged. |
| SC-5 | RuntimeSmoke.callback behavior explicitly preserved or deferred | PASS | Explicit answer: "May `RuntimeSmoke.callback` change? No. It must remain unchanged." RS-IF8 covers this. Avoidance of orchestrator callback integration explicitly stated. |
| SC-6 | RuntimeSmoke.eval_input_for behavior explicitly preserved or fixture policy narrowly designed | PASS | Explicit answer: "May `RuntimeSmoke.eval_input_for` change? No." Fixture policy section: no new if_expr contract ids; `Add` special case unchanged; explicit `sample_input` from proof harness. RS-IF9 covers behavioral check. |
| SC-7 | Dual-path evaluator question explicitly handled; no silent unification forced | PASS | "Dual-Path Evaluator Stance" section: preserve dual path, do not unify before RuntimeSmoke work, duplication is future debt, do not disturb Slice 1 structural proof invariants, unification is not a prerequisite. Directly resolves C3-X NB-2 from R201. |
| SC-8 | Proof matrix covers positive if_expr, selected local kinds, non-selected branch isolation, regression, closed-surface scans, and no public claims | PASS | RS-IF3/RS-IF4: positive condition true/false. RS-IF5: selected `apply` through adapter. RS-IF6: non-selected branch doesn't fire. RS-IF7..RS-IF10: regression (run shape, callback, eval_input_for, dual-path). RS-IF11..RS-IF15: closed-surface scans. See NB-1 for field_access gap. |
| SC-9 | Root require remains closed | PASS | Explicit answer: "Does root require remain closed? Yes. `lib/igniter_lang.rb` remains closed." RS-IF12 covers this. |
| SC-10 | CompilerOrchestrator, CompilerResult, CompilationReport remain closed | PASS | Explicit answer: "Do `CompilerOrchestrator`, `CompilerResult`, and `CompilationReport` remain closed? Yes. The first RuntimeSmoke proof should not use compiler result/report integration." RS-IF11 covers this. Harness pattern explicitly says "Avoid using `CompilerOrchestrator#compile(..., runtime_smoke:)`." |
| SC-11 | Dynamic dependency/cache authority remains deferred | PASS | "Dependency and Cache Stance" section lists 6 forbidden behaviors. RS-IF13 covers this. Explicit answer: "Does dynamic dependency tracking remain deferred? Yes." |
| SC-12 | Counterfactual audit remains future pressure only | PASS | "Counterfactual Audit Stance" section names 6 forbidden behaviors. "Runtime is lazy. Audit is aware." explicit. RS-IF14 covers this. |
| SC-13 | Release/public/Spark/API/CLI claims remain closed | PASS | Closed surfaces section lists 18 items. Explicit answer: "Do Spark/API/CLI remain closed? Yes." Even accepted RuntimeSmoke proof would be proof-context evidence, not public runtime support. RS-IF15 covers this. |

**Verdict: proceed — 13/13 PASS, no blockers, 3 non-blocking notes.**

---

## Key Technical Observations

### Transitive Load Distinction Is Sound

The `runtime_smoke.rb` source confirms: it already `require_relative`s
`compiled_program.rb`. Since `compiled_program.rb` (after R201) `require_relative`s
`semanticir_expression_evaluator.rb`, loading RuntimeSmoke now transitively loads
the evaluator. C1-D's three-level claim hierarchy is correct and necessary:

```text
transitive evaluator load != RuntimeSmoke support
RuntimeSmoke proof support != public runtime support
public runtime support != production/runtime claim
```

RS-IF2 requires machine-asserting this classification. The design correctly
refuses to treat the transitive load as a feature.

### RuntimeSmoke.run Rescue Clause Implications

The actual `run` method has a blanket `rescue => e` that converts any unhandled
exception to `{ "load_status" => "blocked", "error" => ..., "trusted" => false }`.
This means evaluator-raised exceptions during proof smoke (e.g.,
`ConditionNotBoolError`, `MalformedIfExprError`, `UnsupportedExpressionKindError`)
would surface as the failure shape rather than propagating. This is existing
behavior, not a new risk. The proof harness for RS-IF3/RS-IF4 should verify
`trusted: true` for well-formed `if_expr` artifacts to confirm no hidden
exception is being swallowed.

### Harness Pattern Relies on load_igapp

The recommended harness calls `RuntimeSmoke.run(out_path: ..., sample_input:
...)` which internally calls `CompiledProgram.load_igapp(out_path)`. This
requires actual `.igapp` directory artifacts on disk, unlike the Slice 2 proof
harness which built in-memory `CompiledProgram` objects directly. The
authorization review must decide the artifact creation strategy. See NB-2.

### eval_input_for Pass-Through Policy Is Correctly Scoped

The actual `eval_input_for` implementation:
```ruby
def eval_input_for(contract_id, sample_input)
  return { "a" => 19, "b" => 23 } if contract_id == "Add"
  sample_input
end
```

For any proof-owned `if_expr` contract (with a non-"Add" id), this returns
`sample_input` unchanged. The design's fixture policy (explicit `sample_input`
from harness, no if_expr special-case added) is sound and requires no change to
`eval_input_for`.

---

## Non-Blocking Notes

**NB-1: RS-IF5 covers only `apply` for proof RuntimeMachine-local kinds; `field_access` has no dedicated case.**

The RS-IF proof matrix's RS-IF5 requires: "Selected branch uses proof RuntimeMachine
local `apply` — Output proves adapter path works through smoke." `field_access`
is also a proof RuntimeMachine-local kind that routes through the same
`external_evaluator` adapter path. Its coverage in the RS-IF matrix is implicit
only (via RS-IF7 regression or not at all).

The C3-A should either: (a) expand RS-IF5 to cover both `apply` and
`field_access` (RS-IF5a / RS-IF5b), or (b) add an explicit RS-IF5b for
`field_access` before the authorization review opens. This closes the coverage
gap identified in the design without changing the overall matrix count
significantly.

**NB-2: `.igapp` artifact creation policy is underspecified in the design.**

The harness pattern says: "Create proof-owned source/artifact inside the
experiment directory. Produce or provide `.igapp` under the proof-owned `out/`
directory." However, `RuntimeSmoke.run` calls `CompiledProgram.load_igapp(out_path)`,
which reads JSON files from a directory on disk. The design does not specify
whether the proof harness should:

(a) Hand-author `.igapp` directories (matching the existing proof fixture pattern
    in `experiments/runtime_machine_memory_proof/`);
(b) Write minimal in-memory structures to a temporary directory during the proof;
(c) Use an existing `.igapp` fixture from another experiment.

The authorization review card must specify the exact artifact creation strategy
before the implementation card begins, since the choice affects the proof
harness architecture and the closed-surface scan scope. Option (b) is safest —
consistent with the design's "no CompilerOrchestrator" policy.

**NB-3 (informational): RS-IF matrix does not require testing RuntimeSmoke rescue behavior for evaluator errors.**

The design's RS-IF matrix does not include a case for malformed `if_expr` or
non-Bool condition when routed through `RuntimeSmoke.run`. Such cases would
surface as `load_status: "blocked", trusted: false` via the blanket rescue
clause, not as raised exceptions. Explicitly proving this behavior (one negative
case via `RuntimeSmoke.run`) would confirm that the rescue clause correctly
absorbs evaluator errors and does not widen the public surface.

This is not a blocker: the positive cases (RS-IF3/RS-IF4) with `trusted: true`
implicitly confirm the evaluator integrates correctly. However, C3-A may
optionally add an RS-IF16 negative case to the matrix before the authorization
review for completeness.

---

## [Agree]

- The three-level support distinction (transitive load / RuntimeSmoke proof /
  public runtime) is the correct framing and is necessary before any smoke
  proof work begins.
- Keeping `runtime_smoke.rb` unchanged for the first RuntimeSmoke consumer proof
  is correct. The evaluator adapter path in `compiled_program.rb` is already the
  integration layer; there is no need to add evaluator awareness to
  `runtime_smoke.rb` itself.
- The dual-path evaluator resolution is correct: preserve both paths, record
  duplication as debt, do not make unification a prerequisite for Slice 3 work.
- The `eval_input_for` fixture policy (explicit `sample_input`, no if_expr
  special-case) correctly prevents polluting `RuntimeSmoke` with proof-owned
  defaults.
- RS-IF1..RS-IF15 scope is appropriate for a first RuntimeSmoke consumer proof.
- All closed surfaces are explicitly named and correctly closed.

---

## [Challenge]

- The design states "Produce or provide `.igapp` under the proof-owned `out/`
  directory" without deciding which strategy to use. Since `RuntimeSmoke.run`
  uses `load_igapp`, the authorization review cannot proceed without this
  decision. The design is correct to defer it, but C3-A must require a decision
  before dispatching the authorization review.

- RS-IF2 requires "Transitive evaluator load classified — Recorded as load
  consequence, not support by itself." The proof harness cannot easily machine-assert
  this as a behavioral check — it is more of a documentation/claim check. The
  authorization review should specify whether RS-IF2 is a source scan (confirming
  no `RuntimeSmoke support` phrasing in the proof harness claims) or a behavioral
  assertion (confirming that merely loading RuntimeSmoke does not trigger any
  evaluator invocation without an explicit `.igapp` fixture call). Both are
  achievable; the authorization review card should name which form is required.

---

## [Missing]

- `.igapp` artifact creation strategy. See NB-2.
- RS-IF5 `field_access` coverage. See NB-1.
- RS-IF2 machine-assertion form (source scan vs. behavioral). See Challenge.

---

## [Sharper Question]

Given that `RuntimeSmoke.run` requires a real `.igapp` directory on disk, the
smallest better question is:

> Should the RS-IF3/RS-IF4 proof artifacts be hand-authored `.igapp` directories
> inside the proof experiment (consistent with `runtime_machine_memory_proof/`
> fixtures), or should the proof harness write them programmatically to a
> temporary directory at runtime and clean them up after verification?

The answer determines the harness architecture for the entire Slice 3 proof.

---

## [Route]

Proceed. Route to:

```text
Card: S3-R202-C3-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Route: ACCEPTANCE DECISION
Track: branch-conditional-if-expr-runtime-smoke-consumer-boundary-design-v0
Depends on:
- S3-R202-C2-X
```

Required before C3-A dispatches the authorization review:

1. Accept the design and authorize a later implementation-authorization review
   for a proof-owned RuntimeSmoke consumer harness with no `runtime_smoke.rb`
   edits.
2. Resolve NB-1: expand RS-IF5 to cover both `apply` and `field_access` (as
   RS-IF5a/RS-IF5b or a single expanded case), binding for the authorization
   review card.
3. Resolve NB-2: decide the `.igapp` artifact creation strategy and state it
   explicitly in the authorization review boundary. Recommended: programmatic
   in-memory write to a proof-owned `out/` directory (consistent with
   no-CompilerOrchestrator policy and cleanable after proof run).
4. Resolve Challenge (RS-IF2 form): specify whether RS-IF2 is satisfied by a
   source scan of the proof harness (no support-claim language) or by a
   behavioral assertion (confirming load without eval). Either form is
   acceptable; the authorization review card must name it.
5. Optionally add RS-IF16 negative case (RuntimeSmoke rescue absorbs evaluator
   error, returns `trusted: false`) — not required, but recommended for
   comprehensive proof coverage.

Surfaces that must remain closed through the authorization review and any
subsequent implementation card:

- `igniter-lang/lib/igniter_lang/runtime_smoke.rb` (no edits);
- root require `igniter-lang/lib/igniter_lang.rb`;
- `CompilerOrchestrator`, `CompilerResult`, `CompilationReport`, `Diagnostics`;
- release execution, RubyGems publish, tag/push/sign/deploy;
- public API/CLI widening or public runtime support claims;
- Spark data, fixtures, specs, ids, integration, or demo behavior;
- dynamic dependency/cache authority;
- counterfactual audit implementation;
- Slice 1 structural proof invariants (dual-path evaluator must not be unified).
