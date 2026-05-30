# Branch Conditional Counterfactual Audit Vocabulary Spec Sync v0

Card: S3-R206-C1-D  
Agent: [Compiler/Grammar Expert]  
Role: compiler-grammar-expert  
Track: branch-conditional-counterfactual-audit-vocabulary-spec-sync-v0  
Route: UPDATE  
Depends on: S3-R205-C4-S

## Purpose

Design the docs/spec vocabulary sync boundary for Level 1 branch-intention and
counterfactual-audit terminology after the accepted R205 concept proof, without
opening grammar, runtime execution, report/result shape, public API/CLI, Level 2
dry-run, release evidence, or public claims.

## Neighbor Awareness

Affected neighbor roles:

- Research Agent: owns proof-local descriptor evidence and future proof matrix.
- Spec/Status Curator: owns later status/index synchronization if approved.
- Assumptions / Bridge owners: own any future PROP-032 relationship change.
- Release Readiness Agent: owns release evidence wording and public non-claims.

This track speaks only as `[Compiler/Grammar Expert]`.

## Inputs Read

- `docs/tracks/stage3-round205-status-curation-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-concept-proof-acceptance-decision-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-concept-proof-v0.md`
- `docs/discussions/branch-conditional-counterfactual-audit-concept-proof-pressure-v0.md`
- `docs/tracks/branch-conditional-counterfactual-audit-boundary-decision-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`
- `docs/language-spec.md`
- `docs/spec/ch2-source-surface.md`
- `docs/spec/ch5-compiler-pipeline.md`
- `docs/spec/ch6-semanticir.md`
- `docs/spec/ch7-runtime.md`
- `docs/dev/canonical-semantic-model.md`
- `docs/dev/semantic-governance-heat-map.md`
- `lib/igniter_lang/semanticir_expression_evaluator.rb`
- `experiments/runtime_machine_memory_proof/compiled_program.rb`
- `lib/igniter_lang/runtime_smoke.rb`

## Current Fixed Point

R205 accepts Level 1 concept evidence only:

```text
Runtime is lazy. Audit is aware.
```

The language may statically describe branch intention around an accepted
expression-level `if_expr`, including the selected branch and the non-selected
branch, while preserving the guarantee that the non-selected branch is not
evaluated.

That acceptance does not canonize the proof descriptor shape and does not create
runtime dry-run, report/result fields, public counterfactual support, or grammar
surface.

## Vocabulary Decision

Level 1 vocabulary is stable enough for a narrow docs/spec sync as terminology,
not as object schema.

| Term | Recommended docs status | Meaning |
| --- | --- | --- |
| `branch_intention` | Accept as Level 1 docs vocabulary | Static explanatory record for an `if_expr` branch decision surface. |
| `actual_branch` | Accept as Level 1 docs vocabulary | The branch selected by an observed condition value in a proof/runtime observation context. |
| `latent_branch` | Accept as Level 1 docs vocabulary | The non-selected branch, inspected structurally but not evaluated. |
| `branch_role` | Accept as supporting docs vocabulary | Role label such as actual or latent. |
| `branch_label` | Accept as supporting docs vocabulary | Source-level branch label such as then or else. |
| `condition_observation` | Accept as supporting docs vocabulary | Already-observed condition value or condition structure; not a new evaluation command. |
| `static_branch_metadata` | Accept as supporting docs vocabulary | Structural facts such as expression kind, resolved type facts, and static refs/deps. |
| `intention_source` | Accept as supporting docs vocabulary | Source of the explanation, usually compiler/SemanticIR structure or proof-local metadata. |
| `explanatory_only` | Accept as required boundary flag | The record explains branch structure and carries no execution authority. |
| `non_execution_guarantee` | Accept as required boundary term | Positive assertion that the latent branch was not evaluated. |

## Proof Descriptor Decision

The proof-local descriptor kind `if_expr_branch_intention` should remain
non-canonical.

It may be mentioned in docs only as R205 proof evidence. It must not be described
as:

- SemanticIR node kind;
- CompilationReport field;
- CompilerResult field;
- CompatibilityReport field;
- RuntimeSmoke output contract;
- receipt shape;
- public API/CLI object;
- `.igapp` artifact schema.

Future canonicalization would require a separate schema/report/API decision. The
current sync should only canonize vocabulary and non-claim boundaries.

## Assumptions Relationship

Assumptions are a candidate premise capsule, not the branch-intention surface.

Recommended wording:

```text
Level 1 branch-intention metadata may refer to assumptions-shaped premise labels
in proof-local evidence, but those labels are explanatory-only and do not extend
PROP-032 grammar, receipt semantics, or contract-level `uses assumptions`.
```

Boundary:

- `uses assumptions NAME` remains contract-body syntax only.
- Branch-level `uses assumptions` remains closed.
- Proof-local `assumption_refs` in branch-intention descriptors are not
  canonical PROP-032 `assumption_refs`.
- No PROP-032 amendment is needed for this vocabulary sync.

If a later card wants branch-level premise binding, route it through a dedicated
PROP-032 amendment or new proposal rather than smuggling it through this sync.

## Forbidden Level 1 Vocabulary

These terms must not appear as positive Level 1 claims. They may appear only in a
forbidden-vocabulary list or Level 2+ discussion:

```text
would_result
would_output
would_fail
counterfactual result
counterfactual output
counterfactual failure
latent runtime value
latent runtime failure
latent execution
latent branch execution
simulated branch result
dry-run result
branch replay
replayed branch value
```

Reason: Level 1 explains latent branch intention from static structure. It does
not produce alternate runtime values, failures, outputs, receipts, or reports.

## Level 2 Dry-Run Firewall

Level 2 counterfactual dry-run remains closed.

Any future Level 2 route must require a separate gate and must define at least:

- explicit dry-run invocation source;
- effect-free isolation;
- no mutation of actual runtime result;
- no replacement of actual output;
- no cache/dependency authority unless separately designed;
- no production/runtime/public API/CLI authority by default;
- distinct diagnostics/reporting vocabulary.

Level 1 docs must use `static branch audit` or `branch intention` when no branch
execution occurs. They must not use dry-run wording for the Level 1 surface.

## Proposed Later Docs/Spec Sync Boundary

Recommended next write scope, if C3-A approves:

```text
docs/language-spec.md
docs/spec/ch5-compiler-pipeline.md
docs/spec/ch6-semanticir.md
docs/spec/ch7-runtime.md
docs/tracks/branch-conditional-counterfactual-audit-vocabulary-spec-sync-v0.md
```

Recommended edits:

- `docs/language-spec.md`: add a short coverage note that Level 1 branch
  intention is accepted vocabulary/proof evidence only, while Level 2 dry-run
  and public claims remain closed.
- `docs/spec/ch5-compiler-pipeline.md`: update the `if_expr` section to say the
  compiler pipeline may provide structural facts used by proof-local Level 1
  branch-intention explanations; this does not add compiler report fields.
- `docs/spec/ch6-semanticir.md`: add a note that the flat `if_expr`
  `condition` / `then_branch` / `else_branch` shape is the structural source for
  proof-local branch-intention descriptors; `if_expr_branch_intention` is not a
  SemanticIR node or artifact schema.
- `docs/spec/ch7-runtime.md`: add a runtime boundary note that lazy evaluation
  remains the rule: condition first, selected branch only, latent branch not
  evaluated. Level 1 explanation does not imply Level 2 dry-run or public runtime
  support.

Recommended non-edits in this sync:

- Do not edit `docs/spec/ch2-source-surface.md`; grammar/source syntax is not
  changing.
- Do not edit `docs/proposals/PROP-032-assumptions-block-v0.md`; assumptions are
  only a candidate premise capsule for this Level 1 vocabulary.
- Do not edit dev governance docs in the first sync. `canonical-semantic-model`
  and `semantic-governance-heat-map` have broader status-curation ownership and
  should be refreshed by a status/dev-doc card if needed.

## Non-Claim Block

This vocabulary sync must not claim or imply:

- parser or grammar changes;
- branch-level assumptions syntax;
- new TypeChecker diagnostics beyond accepted OOF-IF1..OOF-IF4;
- new SemanticIR node kinds;
- RuntimeSmoke public support;
- public runtime/evaluator support;
- Level 2 counterfactual dry-run;
- report/result/CompatibilityReport/receipt fields;
- dependency/cache authority;
- release harness/evidence mutation;
- public demo/stable/production/all-grammar support;
- Spark/API/CLI support.

## Decision Answers

| Question | Answer |
| --- | --- |
| Is Level 1 vocabulary stable enough for docs/spec sync? | Yes, as terminology and boundaries only. |
| Should proof-local `if_expr_branch_intention` be canonized? | No. Keep it proof-local and non-canonical. |
| Should `branch_intention`, `actual_branch`, `latent_branch`, and `non_execution_guarantee` become docs vocabulary? | Yes, with explicit explanatory-only and non-execution boundaries. |
| Are assumptions described as premise capsule only? | Yes. They are one candidate capsule, not the branch-intention surface. |
| Is a PROP-032 amendment needed now? | No. |
| Does Level 2 dry-run remain closed? | Yes. It requires a separate gate. |
| May a docs/spec edit open next? | Yes, limited to Ch5/Ch6/Ch7 plus the language-spec index; no Ch2, PROP, runtime, report, API, or release edits. |

## C3-A Options

Recommended: accept this design and authorize a narrow docs/spec sync using the
write scope above.

Other valid options:

- Conditional accept: require Spec/Status Curator review before editing
  `language-spec.md`.
- Hold: keep vocabulary track-only if Architect wants no spec terminology before
  a canonical report/schema decision.
- Redirect: route to PROP amendment only if the goal changes from vocabulary to
  branch-level premise binding.

## Recommendation

Accept the vocabulary sync boundary.

The next card should be a docs-only C3-I sync limited to `language-spec.md`,
Ch5, Ch6, and Ch7. It should explicitly preserve the proof-local status of
`if_expr_branch_intention`, keep assumptions as premise-capsule wording only,
and repeat the Level 2 dry-run firewall.

## Closed Surfaces

- Implementation.
- Parser/grammar/source syntax.
- TypeChecker/SemanticIR schema expansion.
- Runtime/evaluator behavior changes.
- RuntimeSmoke public support.
- Report/result/CompatibilityReport/receipt shape.
- Dependency/cache authority.
- Level 2 dry-run.
- Release evidence mutation.
- Public demo/stable/production/all-grammar claims.
- Spark/API/CLI surfaces.

