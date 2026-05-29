# Branch Conditional Assumptions Capsule Fit Analysis v0

Card: S3-R204-C2-P1
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: branch-conditional-assumptions-capsule-fit-analysis-v0
Route: UPDATE
Status: done
Date: 2026-05-29

Depends on:
- S3-R203-C5-S

---

## Purpose

Evaluate whether PROP-032 `assumptions {}` can serve as the native capsule for
`if_expr` branch intentions, or whether branch intentions need a distinct
counterfactual-audit surface.

This is analysis only. It does not authorize grammar mutation, spec mutation,
implementation, runtime behavior, public API/CLI widening, or release/public
claims.

---

## Inputs Read

- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`
- `igniter-lang/docs/tracks/stage3-round203-status-curation-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/proposals/README.md`

---

## Current Authority Baseline

PROP-032 currently means:

- `assumptions {}` is a module-scoped declaration surface for epistemic
  provenance;
- every assumption is named and typed by fields such as `kind`, `statement`,
  `strength`, and optional `source`;
- `uses assumptions NAME` appears in a contract body, not inside expression
  branches;
- the accepted experiment-pass status is bounded to the compiler surface;
- PROP-033 evidence validation and runtime receipt behavior remain excluded by
  the current living maps.

Current `if_expr` authority means:

- expression-level `if_expr` has accepted internal compiler support;
- the TypeChecker sees the full branch structure and uses union dependencies;
- SemanticIR carries a flat `if_expr` shape with `condition`, `then_branch`,
  `else_branch`, and `resolved_type`;
- proof/runtime slices preserve lazy evaluation: only the selected branch is
  evaluated;
- RuntimeSmoke has proof-context consumer evidence only, not public runtime
  support;
- counterfactual audit remains future pressure/design-only.

---

## Branch Intention Classification

Branch intentions are related to assumptions, but they are not identical.

| Form | Fit for branch intentions | Boundary |
| --- | --- | --- |
| Assumption | Good for branch premises: thresholds, heuristics, declared world premises, calibration claims. | Names what a branch relies on, not what the branch is for. |
| Evidence annotation | Useful later for explaining derivation or static dependencies. | Evidence validation is PROP-033 territory and remains excluded. |
| Explanation | Strong fit for the branch-intention surface. | Explanation must stay static and non-executing. |
| Obligation | Possible future fit when a selected branch creates a contractual duty. | A non-selected branch must not create runtime obligation authority. |
| Contract | Too broad for this slice. | Branches live inside an expression; do not promote them into standalone contracts by analysis fiat. |
| Counterfactual descriptor | Best near-term fit. | A proof-local descriptor can name branch intent, premise refs, static type/dependency facts, and non-evaluation status without changing source syntax. |

Conclusion:

```text
assumptions are a strong candidate component of branch intention,
but not the whole branch-intention capsule.
```

---

## Fit Analysis

### Can assumptions name branch premises without becoming runtime values?

Yes, within the existing PROP-032 model, assumption names can identify premises
without runtime injection. For branch-intention work, this should be limited to
metadata references such as:

```text
branch_intention.assumption_refs = ["risk_threshold_is_valid"]
```

This must not imply that a non-selected branch reads an assumption as a runtime
value or that its computation occurred.

### Can assumptions describe non-selected branch intent without branch evaluation?

Partly. Assumptions can describe premises a non-selected branch would rely on,
but they do not by themselves describe the branch's purpose, expected outcome
shape, or explanation. A counterfactual audit can statically say:

```text
non-selected branch: not evaluated
static intent: explainable from branch descriptor
premises: named by assumption_refs
```

It must not say:

```text
would_result: <runtime value>
would_fail_with: <runtime error>
runtime_dependency_authority: true
```

unless a later card separately authorizes explicit counterfactual execution.

### Is branch-level `uses assumptions` compatible with current PROP-032?

Not as source syntax. Current PROP-032 attaches `uses assumptions NAME` to the
contract body. A branch-level attachment would be a grammar and semantics
extension.

Compatible proof-local route:

- keep source `uses assumptions NAME` at contract level if using real
  PROP-032-shaped source;
- represent branch-level premise relevance in proof-owned metadata or a derived
  descriptor;
- do not introduce `then uses assumptions`, `else uses assumptions`, or branch
  body declarations in canonical grammar.

### Should a future proof use assumptions-shaped fixture metadata?

Yes, with a strict label:

```text
assumptions-shaped proof metadata, not PROP-032 grammar extension
```

The proof may use a descriptor shaped like:

```json
{
  "assumptions": [
    {
      "name": "risk_threshold_is_valid",
      "kind": "heuristic",
      "statement": "The static threshold is suitable for this branch explanation.",
      "strength": 0.7,
      "source": null
    }
  ],
  "branch_intentions": [
    {
      "if_expr_id": "if:risk_gate",
      "branch": "then",
      "intent": "select remediation path when the condition is true",
      "assumption_refs": ["risk_threshold_is_valid"],
      "evaluation_status": "not_evaluated_in_actual_false_path"
    }
  ]
}
```

This shape is illustrative proof metadata only. It does not define syntax,
SemanticIR, report, receipt, CLI, or public API shape.

---

## Explicit Answers

### Are assumptions a good candidate capsule?

Yes, but only as a capsule for branch premises. They are not sufficient as the
whole branch-intention capsule.

### Should assumptions be treated as the default branch-intention capsule now?

No. Treat assumptions as the leading candidate for premise references inside a
larger branch-intention/counterfactual-audit descriptor. Do not make them the
default branch-intention surface yet.

### Is new branch-intention vocabulary needed before syntax?

Yes. A vocabulary is needed before syntax, especially for:

- selected branch;
- non-selected branch;
- branch intention;
- static premise refs;
- static dependency/type facts;
- non-evaluation guarantee;
- counterfactual descriptor;
- explicit separation from runtime values, runtime obligations, receipts, and
  dependency/cache authority.

### Can `uses assumptions` attach to a branch under current PROP-032?

No. Under current PROP-032 it attaches to a contract body. Branch-level
attachment would require a future amendment or new proposal.

### Is a PROP-032 amendment required before a proof-local concept route?

No. A proof-local concept route can use assumptions-shaped fixture metadata or
derived descriptors without amending PROP-032, provided the route states that it
does not change grammar, parser, classifier, TypeChecker, SemanticIR, reports,
receipts, runtime, or public API/CLI.

### Should implementation remain held?

Yes. Implementation, grammar/spec mutation, runtime changes, RuntimeSmoke
changes, report/receipt shape changes, dependency/cache authority, public API/CLI
widening, release claims, and production behavior should remain held.

---

## Overload Risks

Avoid these overloads:

- treating every branch explanation as an assumption;
- treating assumption `strength` as a branch probability or runtime branch
  confidence;
- treating non-selected branch `assumption_refs` as proof that the branch ran;
- using `assumption_refs` to create path-sensitive dependency/cache authority;
- adding branch-level `uses assumptions` syntax before a vocabulary decision;
- treating PROP-032 receipt language as active runtime authority while the
  current accepted status excludes runtime receipt behavior;
- turning counterfactual audit into dry-run execution without a separate gate.

---

## Recommendation For C4-A

Recommended decision:

```text
accept assumptions as a candidate premise capsule for branch intentions;
do not accept assumptions as the default branch-intention surface yet;
require a distinct branch-intention / counterfactual-audit vocabulary before syntax;
permit only a future proof-local metadata route, with no grammar/spec/runtime mutation;
keep implementation held.
```

Exact boundary recommendation:

```text
Counterfactual audit Level 1 may statically describe both selected and
non-selected branches. It may name branch premise references using
PROP-032-shaped assumption metadata. It must not evaluate the non-selected
branch, produce counterfactual runtime values, create runtime obligations,
change dependency/cache authority, mutate RuntimeSmoke/report/receipt shapes,
or introduce branch-level `uses assumptions` syntax.
```

Recommended next proof route, if C4-A accepts:

```text
branch-conditional-counterfactual-audit-concept-proof-v0
proof-local metadata only
no source grammar changes
no compiler/runtime source changes
no public claims
```

---

## Compact Handoff

Card: S3-R204-C2-P1
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: igniter-lang/branch-conditional-assumptions-capsule-fit-analysis-v0
Status: done

[D] Decisions
- Assumptions fit branch premises, not the whole branch-intention concept.
- Current PROP-032 `uses assumptions` is contract-body only.
- No PROP-032 amendment is needed for proof-local assumptions-shaped metadata.

[S] Shipped / Signals
- Produced C4-A-ready boundary recommendation for assumptions/counterfactual
  audit.

[T] Tests / Proofs
- No tests run; documentation/analysis-only card.

[R] Risks / Recommendations
- Do not overload `strength` into branch probability or runtime confidence.
- Do not make non-selected branch metadata imply evaluation, obligations,
  receipts, or dependency/cache authority.
- Route only proof-local metadata next if C4-A accepts.

[Next] Suggested next slice
- S3-R204-C3-X pressure should challenge whether the descriptor vocabulary is
  precise enough and whether assumptions-shaped metadata leaks grammar or
  runtime authority.
