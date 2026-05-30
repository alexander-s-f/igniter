# Branch Conditional Counterfactual Audit Doc Target Survey v0

Card: S3-R206-C2-P1
Agent: [Archive/Form Expert]
Role: archive-form-expert
Track: branch-conditional-counterfactual-audit-doc-target-survey-v0
Route: UPDATE
Status: done
Date: 2026-05-30

Depends on:
- S3-R205-C4-S

---

## Route Statement

Route: UPDATE
Card: S3-R206-C2-P1
Role: archive-form-expert
Stage/Round observed: Stage 3 / Round 205 accepted; R206 vocabulary/spec sync
is the next design-only route.

Affected neighbor roles:

- Compiler/Grammar Expert: future vocabulary/spec sync owner.
- Status Curator / Meta Expert: future status-only or map sync owner.
- Implementation Agent: not active for this slice; implementation remains closed.

This survey is archaeology/form work. It does not authorize implementation,
grammar mutation, parser/runtime/spec edits, public claims, or report/schema
changes.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round205-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-concept-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-boundary-decision-v0.md`
- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`
- `igniter-lang/docs/language-spec.md`
- `igniter-lang/docs/spec/README.md`
- `igniter-lang/docs/spec/ch2-source-surface.md`
- `igniter-lang/docs/spec/ch5-compiler-pipeline.md`
- `igniter-lang/docs/spec/ch6-semanticir.md`
- `igniter-lang/docs/spec/ch7-runtime.md`
- `igniter-lang/docs/dev/canonical-semantic-model.md`
- `igniter-lang/docs/dev/semantic-governance-heat-map.md`
- `igniter-lang/docs/current-status.md`

Role refresh reads:

- `igniter-lang/AGENTS.md`
- `igniter-lang/roles/README.md`
- `igniter-lang/roles/base-role.md`
- `igniter-lang/roles/archive-form-expert.md`
- `igniter-lang/handoff/onboarding-archive-form-expert-v0.md`
- `igniter-lang/handoff/INSTANCE_ROUTING.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/operating-model.md`
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`

---

## Accepted R205 Maximum Claim

R205 accepts proof-local Level 1 concept evidence only:

```text
if_expr branch intentions can be statically described for actual and latent
branches without evaluating latent branches, using explanatory-only metadata and
optional assumptions-shaped premise refs.
```

Binding non-equivalences:

```text
explanatory_only descriptor != runtime execution
branch_intention proof != public counterfactual support
assumptions_shaped_metadata != PROP-032 grammar extension
Level 1 static audit != Level 2 counterfactual dry-run
```

Closed surfaces remain:

- parser, grammar, and source syntax changes;
- branch-level `uses assumptions` syntax;
- TypeChecker or SemanticIR schema/canon mutation;
- runtime, evaluator, RuntimeSmoke, and proof RuntimeMachine changes;
- non-selected branch evaluation;
- Level 2 dry-run and Level 3 comparison report;
- dependency/cache authority;
- report/result/receipt/CompatibilityReport shape changes;
- public API/CLI, release, demo, Spark, production, and public
  counterfactual/runtime claims.

---

## Target Survey

| Target | Current role in docs | Safe future placement? | Survey recommendation |
| --- | --- | --- | --- |
| `docs/current-status.md` | Active status scoreboard and next-route pointer. | Yes, if Status Curator owns it. | Best immediate status-only home. Record R205 accepted proof-local vocabulary and C4-A route, without spec detail. |
| `docs/dev/semantic-governance-heat-map.md` | Cross-layer drift index. | Yes, preferred design-map home. | Add a future row only after C4-A decision: `branch_intention` as proof-local/static-audit vocabulary with grammar/runtime/report closed. |
| `docs/dev/canonical-semantic-model.md` | Verifiable entity index, not aspirational design. | Only if C4-A chooses `spec_candidate` with no golden authority, or defers until a golden/schema anchor exists. | Avoid as first target unless wording says "not a compiler entity" or C4-A explicitly wants a candidate row. |
| `docs/language-spec.md` | Public entry-point index. | Yes, but tiny index note only. | If touched later, add only a coverage-summary line pointing to accepted proof-local status; do not define syntax or schema here. |
| `docs/spec/README.md` | Chapter index and coverage matrix. | Yes, tiny row only after C4-A. | Add "Level 1 branch-intention vocabulary: proof-local/design-only" only if the sync needs discoverability. |
| `docs/spec/ch2-source-surface.md` | Source grammar and parsed surface. | High-risk; touch only to say "no new source syntax." | If authorized, add a non-syntax disposition note near `if_expr`/assumptions sections. Do not add BNF. |
| `docs/spec/ch5-compiler-pipeline.md` | Production pipeline and internal compiler support. | Medium-risk. | If authorized, add design-only note under `if_expr` internal compiler support: static audit vocabulary does not change pipeline stages or `CompilationReport`. |
| `docs/spec/ch6-semanticir.md` | SemanticIR, CompilationReport, and artifact shapes. | High-risk. | Prefer avoid for first sync. If touched, wording must state no `branch_intention` SemanticIR node/field and no `CompilationReport` shape change. |
| `docs/spec/ch7-runtime.md` | RuntimeMachine, CompatibilityReport, cache, receipt-adjacent behavior. | Very high-risk. | Avoid in C4-A unless only adding a closed-surface note. It can easily imply runtime/counterfactual support. |
| `docs/proposals/PROP-032-assumptions-block-v0.md` | Assumptions grammar and pipeline proposal. | Avoid for now. | Do not amend unless a separate PROP-032 amendment route opens. Branch premise labels are not PROP-032 receipt `assumption_refs`. |
| `docs/ruby-api.md` / public docs | Caller-facing API/docs. | No. | Avoid entirely; this is not public API/CLI support. |

---

## Wording Risk Matrix

| Risk class | Risky drift | Safe treatment |
| --- | --- | --- |
| Public/runtime/API claim | "Igniter-Lang supports counterfactual audit." | Say "proof-local Level 1 static branch audit vocabulary." |
| PROP-032 branch syntax drift | Branch-level `uses assumptions` or `assumption_refs` as branch syntax. | Say "optional proof-local branch premise labels, not PROP-032 syntax or receipt semantics." |
| SemanticIR schema drift | A new `branch_intention` node/field in Ch6. | Say "descriptor vocabulary is not a SemanticIRProgram schema change." |
| Report/result/receipt drift | Adding `branch_intention` to `CompilationReport`, `CompilerResult`, receipt, or `CompatibilityReport`. | Say "concept summary/proof output only; report/result/receipt shapes unchanged." |
| Runtime/counterfactual drift | Latent branch produces value/failure/readiness. | Say "latent branch is not evaluated; no would-result, would-output, would-fail." |
| Cache/dependency drift | Static latent refs become dependency/cache authority. | Say "static refs are explanatory-only and carry no dependency/cache authority." |
| Release evidence drift | R205 proof rewrites alpha release evidence. | Say "accepted release evidence remains historical and unchanged." |

---

## Safe Wording Snippets

Use these only after a future authorized docs/spec sync card:

```text
Level 1 branch-intention vocabulary is proof-local static audit vocabulary for
explaining actual and latent if_expr branches without evaluating latent branches.
It is not source syntax, not a SemanticIR schema field, not runtime behavior, and
not public counterfactual audit support.
```

```text
`branch_intention` names an explanatory lens over an if_expr branch pair. The
actual branch may be tied to actual-path evidence; the latent branch may be
described from typed/SemanticIR structure only and must carry a non-execution
guarantee.
```

```text
Proof-local branch premise refs may be assumptions-shaped, but they are not
PROP-032 branch syntax and are not PROP-032 receipt `assumption_refs`.
```

```text
Level 1 static audit explicitly excludes would-result, would-output, would-fail,
latent runtime value, latent runtime failure, Level 2 dry-run, dependency/cache
authority, and report/result/receipt/CompatibilityReport shape changes.
```

---

## Forbidden Wording Snippets

Do not use:

```text
Igniter-Lang supports counterfactual audit.
```

```text
Branches can use assumptions with `uses assumptions` at branch level.
```

```text
SemanticIR now emits branch_intention records.
```

```text
CompilationReport / CompilerResult / receipt / CompatibilityReport includes
branch_intention or assumption_refs for branches.
```

```text
The runtime can evaluate, dry-run, replay, or report latent branch results.
```

```text
Static latent refs participate in dependency tracking or cache keys.
```

```text
R205 proves public counterfactual audit, production runtime support, Spark
support, or CLI/API behavior.
```

---

## Glossary / Index Needs

Recommended glossary terms for a future sync:

| Term | Safe definition |
| --- | --- |
| `branch_intention` | Proof-local explanatory record/lens for an `if_expr` branch pair. |
| `actual_branch` | Branch selected by the actual evaluated condition. |
| `latent_branch` | Branch not selected and not evaluated. |
| `branch_role` | `actual` or `latent`. |
| `branch_label` | `then` or `else`. |
| `static_branch_metadata` | Typed/SemanticIR-derived facts used for explanation only. |
| `intention_source` | Proof-local source for the explanation. |
| `explanatory_only` | Marker that the descriptor has no runtime/cache/dependency/public authority. |
| `non_execution_guarantee` | Positive marker that a latent branch was not executed. |

Index need:

- A small "proof-local vocabulary" row in `docs/spec/README.md` or
  `docs/language-spec.md` is useful only if C4-A chooses a spec-visible sync.
- A stronger glossary should live in a track/design note first, not in Ch2/Ch6/Ch7.

---

## Preferred Target Set

For C4-A, prefer a narrow, split target set:

1. `docs/current-status.md` as status-only map update by Status Curator, if the
   project needs active visibility now.
2. `docs/dev/semantic-governance-heat-map.md` as the main design-governance
   placement for the vocabulary/risk row.
3. `docs/spec/README.md` or `docs/language-spec.md` as a tiny index pointer only
   if C4-A wants spec discoverability.
4. `docs/spec/ch2-source-surface.md` only for a non-syntax disposition note.
5. Defer `docs/spec/ch5-compiler-pipeline.md` and `docs/spec/ch6-semanticir.md`
   unless C4-A explicitly wants negative sync text.
6. Avoid `docs/spec/ch7-runtime.md` in the first sync.

---

## Docs To Avoid For Now

Avoid in the next sync unless C4-A explicitly narrows wording:

- `docs/proposals/PROP-032-assumptions-block-v0.md`
- `docs/spec/ch7-runtime.md`
- public caller-facing API/CLI docs
- runtime, loader/report, CompatibilityReport, receipt, or release docs

Reason: these targets can easily hoist proof-local vocabulary into grammar,
runtime, receipt, or public API authority.

---

## One Card Or Split?

Recommendation: split into design + implementation.

Suggested split:

1. C4-A: authority/design decision chooses exact target set and authorizes only
   wording class.
2. C4-B or C5-P: docs/spec sync applies approved wording.

Do not combine target choice and spec edit in one broad implementation card. The
surface crosses Ch2/Ch5/Ch6/Ch7, PROP-032, report/result/receipt vocabulary, and
public non-claims; a small authority checkpoint is cheaper than cleaning up
authority drift later.

---

## Is Status-Only Enough Now?

Yes.

Status-only is enough now because R205 is already visible in `current-status.md`
and the next route is design-only. No parser/runtime/report/API implementation
is waiting on vocabulary placement. A future sync is useful for discoverability,
but not urgent enough to risk grammar or runtime hoist.

If C4-A wants movement now, choose the minimal route:

```text
status/dev-map sync only; no Ch2/Ch5/Ch6/Ch7 body edits yet
```

---

## Exact Docs/Spec Target Recommendation For C4-A

Recommended C4-A decision:

```text
Approve Option A:
  target only docs/current-status.md and docs/dev/semantic-governance-heat-map.md
  for Level 1 branch-intention vocabulary visibility;
  optionally add a one-line index pointer in docs/spec/README.md;
  do not edit PROP-032, Ch2 BNF, Ch5 pipeline semantics, Ch6 SemanticIR schema,
  Ch7 RuntimeMachine, public API/CLI docs, or report/result/receipt docs.
```

If C4-A insists on spec-body sync, use Option B:

```text
Ch2: add a non-syntax disposition note near if_expr/assumptions.
Ch5: add a negative pipeline note: no CompilationReport/CompilerResult shape
    change and no pipeline authority.
Ch6: add only a negative schema note: no branch_intention SemanticIR node/field.
Ch7: avoid, or add only a closed-surface note that Level 1 is not runtime,
    CompatibilityReport, receipt, dry-run, replay, or cache behavior.
```

Option A is preferred.

---

## Compact Handoff

[D] Survey done. R205 permits only proof-local Level 1 branch-intention
vocabulary/design sync. It does not authorize source syntax, runtime,
SemanticIR schema, report/result/receipt, CompatibilityReport, API/CLI, release,
Spark, production, Level 2 dry-run, or latent branch evaluation.

[S] Preferred target set for C4-A: status/dev-map first
(`current-status.md`, `semantic-governance-heat-map.md`), optional tiny index
pointer, avoid spec-body edits unless authority narrows exact negative wording.

[T] High-risk targets: PROP-032, Ch6 SemanticIR, Ch7 RuntimeMachine,
report/result/receipt/CompatibilityReport surfaces, public API/CLI docs.

[R] Split future sync into authority/design decision plus implementation docs
card. Status-only is enough for now.

[Next] Ask Compiler/Grammar Expert or Architect Supervisor to choose Option A
or B before any docs/spec sync implementation opens.
