# Branch Conditional Counterfactual Audit Adjacent Concepts Survey v0

Card: S3-R208-C2-P1  
Agent: [Research Agent #1]  
Role: research-agent  
Track: branch-conditional-counterfactual-audit-adjacent-concepts-survey-v0  
Route: UPDATE  
Depends on: S3-R207-C4-S  
Status: done  
Date: 2026-05-30

Affected neighbors:
- Compiler/Grammar Expert: semantics, diagnostic, and proof-boundary analogies.
- Bridge Agent: report/API/public-claim authority risks.
- Runtime / Bridge owners: dry-run isolation, cache/dependency authority, and
  external IO refusal risks.

---

## Current Horizon

R207 accepted only Level 1 proof-local static branch-intention vocabulary.
R208-C1-D designs Level 2 as an explicit isolated counterfactual dry-run
projection, not normal runtime. The governing phrase remains: Runtime is lazy.
Audit is aware. This survey classifies outside analogies for internal design
pressure only; it authorizes no design, implementation, report/API shape, public
claim, or runtime behavior.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round207-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-concept-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/dev/semantic-governance-heat-map.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-boundary-design-v0.md`

External reference anchors used for analogy only:

- KLEE / symbolic execution: <https://klee-se.org/> and
  <https://www.usenix.org/legacy/event/osdi08/tech/full_papers/cadar/cadar.pdf>
- Cousot abstract interpretation page:
  <https://www.di.ens.fr/~cousot/AI/>
- LLVM Language Reference, SSA/phi:
  <https://llvm.org/docs/LangRef.html#phi-instruction>
- TypeScript narrowing handbook:
  <https://www.typescriptlang.org/docs/handbook/2/narrowing.html>
- Dafny documentation: <https://dafny.org/latest/DafnyRef/DafnyRef>
- Rocq/Coq documentation: <https://rocq-prover.org/doc/>
- Racket contracts guide:
  <https://docs.racket-lang.org/guide/contracts.html>
- Liquid Haskell documentation:
  <https://ucsd-progsys.github.io/liquidhaskell/>
- rr debugger: <https://rr-project.org/>
- SWI-Prolog `findall/3`: <https://www.swi-prolog.org/pldoc/man?predicate=findall/3>
- Alloy documentation: <https://alloytools.org/documentation.html>
- HypoPG hypothetical indexes: <https://hypopg.readthedocs.io/>
- Pyro causal effects documentation:
  <https://docs.pyro.ai/en/stable/contrib.cevae.html>
- DoWhy counterfactual estimation:
  <https://www.pywhy.org/dowhy/v0.11/example_notebooks/dowhy_counterfactual_estimation.html>

---

## Compact Analogy Map

| Adjacent concept | Closest useful analogy | Mismatch / false friend | Borrow | Must not borrow | Authority risk |
| --- | --- | --- | --- | --- | --- |
| Symbolic execution | Explore latent paths under path conditions; useful mental model for "branch not taken can still be inspected." | Symbolic execution often aims for path coverage, constraint solving, bug finding, and path explosion. Igniter Level 2 is explicit dry-run projection from a branch-intention record, not whole-program path exploration. | Terms like path condition, path isolation, solver-free proof matrix as internal analogies. | Do not call Level 2 "symbolic execution" in public docs; do not imply exhaustive branch exploration or solver authority. | Grammar: low; runtime/cache/report/API/public claim: high if named externally. |
| Abstract interpretation | Static approximation with controlled over/under-approximation; useful for "audit can know safely limited facts." | Abstract interpretation is static analysis over abstract domains. Level 2 dry-run is explicit isolated evaluation under premises, not a sound whole-program approximation. | Discipline of declaring approximation boundaries and false-positive/false-negative policy. | Do not treat dry-run projection as a proof of all possible behavior. | Report/public claim: high; compiler diagnostics: medium. |
| CFG / SSA / static branch analysis | Branches, control-flow joins, phi-like merge points, and dependency union are useful compiler intuitions. | CFG/SSA is compiler representation, not audit evidence. A phi node is not a counterfactual trace. | Union dependency discipline; explicit branch/join shape in proof-local SemanticIR sketches. | Do not expose CFG/SSA vocabulary as user-facing counterfactual audit language. | SemanticIR/golden drift: high; public claim: medium. |
| Flow typing / type narrowing | Type systems narrow facts inside selected branches; good analogy for branch-local facts. | Narrowing describes the actual checked branch context. It does not evaluate latent branches or produce projected values. | Guard-specific type facts; condition must be Bool; branch-local type constraints. | Do not equate type narrowing with counterfactual dry-run. | TypeChecker: medium; public claim: low. |
| Verification-condition tools and proof assistants | VC generation separates program facts from proof obligations; proof assistants force explicit assumptions. | Proof obligations are not runtime projections. A verified theorem is stronger and different from a dry-run trace. | Explicit premise sets, obligation naming, rejected unproven authority. | Do not imply Level 2 proves correctness or produces formal proof certificates. | Report/public claim: high; grammar/typechecker: medium. |
| Refinement / contract systems | Contracts/refinements make assumptions and obligations local and checkable. | Runtime contracts enforce or monitor actual execution; refinements constrain values. Level 2 projection is explanatory/no-authority unless separately promoted. | Require explicit preconditions/premise set; distinguish checked fact from assumed premise. | Do not borrow enforcement authority or public contract guarantees for dry-run. | Runtime/report/API: high. |
| Debugger what-if / time-travel debugging | Replay/isolation intuitions: inspect a state without mutating the original run. | Time-travel debuggers replay actual history; they do not normally create authoritative alternate-world contract outputs. | Isolation language, replay-only disclaimers, "not the actual result" warning. | Do not call dry-run "time travel"; do not imply production replay, audit persistence, or reversible runtime. | Runtime/cache/report/public claim: high. |
| Logic programming / alternative-world queries | Querying alternate satisfying assignments resembles asking "under this premise, what projection follows?" | Logic programming enumerates solutions in a relation; Igniter contracts are not logic programs and Level 2 is not all-world search. | Explicit query/premise language for proof-local fixtures; avoid hidden mutation. | Do not make all-possible-worlds or completeness claims. | Grammar/API/public claim: high. |
| Database what-if analysis | Hypothetical indexes are a strong analogy: planner can estimate using non-materialized structures. | DB what-if often estimates costs/plans, not actual contract values; optimizer estimates are not audit facts. | "Hypothetical, non-materialized, no mutation" framing; clear "projection only" metadata. | Do not borrow query optimizer confidence or persistence semantics. | Cache/dependency/report: high. |
| Probabilistic programming counterfactuals | Closest vocabulary to "counterfactual" and "intervention"; useful warning that premises must be explicit. | Probabilistic/causal counterfactuals require structural causal assumptions and distributions. Igniter Level 2 v0 is deterministic proof-local dry-run under a declared premise set, not causal inference. | Premise/intervention discipline; explicit model/assumption disclosure. | Do not imply statistical causal validity, uncertainty semantics, or observed-world causal claims. | Public claim: very high; assumptions/report: high. |

---

## Warnings / False Friends

### 1. "Counterfactual" Is Useful But Hot

The word is accurate for the high-level question, but it carries causal
inference baggage. In Igniter-Lang Level 2, the safe internal phrase is:

```text
isolated counterfactual dry-run projection under an explicit premise set
```

Avoid unqualified phrases:

- "counterfactual result";
- "what would have happened" as a field name;
- "latent runtime value";
- "alternate actual output";
- "causal estimate";
- "branch simulation" without isolation/no-authority qualifiers.

### 2. Symbolic Execution Is The Tempting Wrong Label

Symbolic execution is the closest compiler/testing analogy, but it is too broad
and too authoritative-sounding. It suggests solver-backed path exploration and
possibly exhaustive behavior. Level 2 should not inherit that claim.

Safe internal use:

```text
symbolic-execution-adjacent: explicit path/premise discipline, not solver or
coverage authority
```

Unsafe public use:

```text
Igniter supports symbolic execution of branches.
```

### 3. Static Analysis Is Not Dry-Run

Abstract interpretation, CFG/SSA analysis, and flow typing help explain how the
compiler can know branch structure. They do not explain evaluating the latent
branch. They are Level 1 / compiler-shape analogies more than Level 2 dry-run
analogies.

### 4. Debugging Replay Is Not Audit Authority

Time-travel debugging and replay tools provide a useful isolation metaphor.
They are dangerous if they imply Igniter can rewind production state, replay
external systems, or persist audit facts. Level 2 v0 must stay proof-local and
pure/refusal-oriented.

### 5. Database What-If Is A Good Isolation Analogy

Hypothetical indexes are useful because they are intentionally non-materialized.
The analog to borrow is "the planner can reason without creating the thing."
The analog to reject is "the estimate becomes an execution fact."

---

## Direct Answers

### Does A Close Mainstream Language Analog Exist?

No single close mainstream language analog exists.

Pieces exist:

- parser/compiler branch representation from mainstream compilers;
- type narrowing from TypeScript/Kotlin-like systems;
- symbolic execution path exploration from testing/verification tools;
- contract/refinement premise discipline;
- debugger replay isolation;
- database hypothetical planning;
- causal/probabilistic counterfactual vocabulary.

Igniter-Lang's proposed Level 2 is a composite: explicit dry-run projection over
a latent branch, tied to branch-intention audit evidence, with authority zeros
and no mutation of runtime/report/cache/dependency state.

### Is "Runtime Is Lazy; Audit Is Aware" Distinct?

Yes.

The framing is distinct because it separates:

- actual runtime selection: only selected branch evaluates;
- Level 1 audit: latent branch can be described statically without execution;
- Level 2 dry-run: latent branch may be explicitly evaluated only inside an
  isolated no-authority projection context.

Most adjacent systems collapse at least two of these layers. Symbolic execution
explores paths; debuggers replay execution; proof tools prove obligations;
databases estimate plans. Igniter's useful distinction is the authority boundary
between actual runtime and audit/projection.

### Should Level 2 Borrow Vocabulary From Symbolic Execution?

Only sparingly, and only in internal docs.

Recommended:

- use Igniter-native terms from R208-C1-D:
  `counterfactual_dry_run`, `dry_run_projection`, `dry_run_trace`,
  `premise_set`, `projected_value`, `projected_failure`,
  `isolation_guarantee`, `no_authority`;
- optionally mention "symbolic-execution-adjacent" in design notes;
- avoid canonical/public fields named `path_condition`, `symbolic_state`,
  `solver`, `symbolic_result`, or `path_exploration`.

Reason: symbolic execution vocabulary implies solver/path-exhaustiveness
authority that Level 2 v0 does not have.

### Which Analogies Are Safe For Internal Docs Only?

Internal-only analogies:

- symbolic execution;
- abstract interpretation;
- CFG/SSA/phi;
- debugger time travel;
- probabilistic programming counterfactuals;
- database what-if/hypothetical index planning.

Potentially safe in public docs only after a later public wording gate:

- "dry-run projection";
- "isolated what-if projection";
- "does not affect actual runtime output";
- "no cache/report/runtime authority."

Even these should remain non-public for now because public counterfactual claims
are closed.

---

## Authority Risk Map

| Risk surface | Highest-risk borrowed analogy | Why it is risky | Guardrail |
| --- | --- | --- | --- |
| Grammar | Logic programming / flow typing | Could invite new source forms or branch-level assumption syntax. | Keep Level 2 proof-local; no syntax. |
| TypeChecker | Flow typing / refinements | Could overfit branch narrowing before dry-run semantics are proven. | Keep condition/branch typing separate from projection authority. |
| SemanticIR | CFG/SSA / symbolic execution | Could introduce canonical branch/projection nodes too early. | Use proof-local shape until spec/body promotion is authorized. |
| Runtime | Debugger replay / symbolic execution | Could imply latent branch execution in normal runtime. | Runtime remains lazy; dry-run explicit and isolated only. |
| Report/result/receipt | Verification/proof tools / contracts | Could imply proof certificate or official audit result. | No report/result/receipt/CompatibilityReport mutation. |
| Dependency/cache | Abstract interpretation / database what-if | Could make projected deps look cache-authoritative. | Authority zeros; explanatory refs only. |
| Public claim | Probabilistic counterfactuals / symbolic execution | Could imply causal/statistical or exhaustive guarantees. | No public counterfactual/demo/runtime claim. |

---

## Borrow / Do-Not-Borrow Summary

Borrow:

- explicit premise sets;
- isolation/no-mutation language;
- branch/path discipline;
- proof-local negative cases;
- declared approximation/projection limits;
- non-materialized/hypothetical framing;
- authority-zero metadata.

Do not borrow:

- solver/exhaustiveness claims;
- formal proof/correctness claims;
- causal inference claims;
- runtime replay claims;
- production time-travel claims;
- dependency/cache authority;
- public API/report vocabulary;
- "would_*" canonical field names.

---

## Recommendation For C4-A

Recommendation:

```text
accept survey as internal analogy map;
prefer guarded Igniter-native vocabulary from R208-C1-D;
do not borrow symbolic execution as the public or canonical Level 2 label;
route any next work to proof-local Level 2 concept proof authorization review;
keep implementation/report/API/runtime/public claims closed.
```

C4-A should treat this as evidence for vocabulary hygiene, not as authority for
Level 2 proof or implementation.

---

## Closed Surfaces

This card does not authorize:

- design acceptance;
- proof implementation;
- live implementation;
- parser/grammar/source syntax;
- branch-level `uses assumptions`;
- TypeChecker/SemanticIR schema/canon mutation;
- runtime/evaluator/RuntimeSmoke behavior;
- proof RuntimeMachine changes;
- non-selected branch evaluation in live runtime;
- Level 2 counterfactual dry-run implementation/proof;
- Level 3 comparison report;
- dependency/cache authority;
- report/result/receipt/CompatibilityReport shape changes;
- public API/CLI widening;
- release evidence rewrite or relabeling;
- public demo/release/stable/production/all-grammar/runtime/counterfactual
  claims;
- Spark data, fixtures, specs, ids, integration, or demo behavior;
- production behavior.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/branch-conditional-counterfactual-audit-adjacent-concepts-survey-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- No single mainstream language analog fully matches Igniter-Lang Level 2.
- Symbolic execution is the closest tempting analogy but too broad for canonical
  or public vocabulary.
- Igniter-native guarded terms from R208-C1-D should be preferred.

[R] Recommendations:
- Accept as internal analogy map.
- Use "isolated counterfactual dry-run projection" rather than symbolic
  execution or causal counterfactual vocabulary.
- Open only proof-local Level 2 concept proof authorization review next, if the
  lane continues.

[S] Signals:
- Runtime is lazy; Audit is aware remains distinct from adjacent traditions.
- Database hypothetical planning and debugger isolation are useful narrow
  analogies for no-mutation framing.
- Probabilistic counterfactual vocabulary is high-risk for public claims.

[T] Tests / Proofs:
- Documentation-only survey. No code proof run.
- External references used only as analogy anchors.

[Files] Changed:
- igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-adjacent-concepts-survey-v0.md

[Q] Open Questions:
- Should future proof-local fixtures include an "analogy false-friend" negative
  scan to reject symbolic_execution / would_result / causal_estimate terms?

[X] Rejected:
- No implementation.
- No public counterfactual claim.
- No report/result/receipt/CompatibilityReport shape.
- No cache/dependency authority.

[Next] Proposed next slice:
- branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-authorization-review-v0,
  proof-local only, if C4-A accepts the boundary and survey.
```
