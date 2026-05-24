# First RC Branch Conditional Scope Disposition v0

Card: S3-R164-C2-D
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Track: first-rc-branch-conditional-scope-disposition-v0
Route: UPDATE
Depends on:
- S3-R164-C1-A
Status: done
Date: 2026-05-24

---

## Summary

Recommendation: choose **Option A**.

First RC should explicitly exclude branch/conditional `if_expr` from the
release-candidate language-feature scope, while preserving
`branch_conditional_if_expr_unsupported` as an open post-RC language/compiler
gap.

Reason:

- the harness already proves the rest of the repo-local compiler RC acceptance
  packet as proof-local evidence with `14/14` command matrix PASS,
  `failed_checks: 0`, and one HOLD only;
- the remaining HOLD is not a harness or compiler regression;
- supporting `if_expr` requires new semantics across parser/typechecker and
  possibly SemanticIR/compiler surfaces, which is a different lane than first
  RC acceptance;
- keeping `if_expr` as a first-RC requirement would turn a scoped release
  boundary into a language-expansion gate.

This design does not authorize code changes, parser/TypeChecker/SemanticIR or
compiler changes, RC evidence gathering, release execution, or public claims.

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-follow-up-closure-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-harness-semantic-profile-refusal-follow-up-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-closure-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-map-v0.md`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`

---

## Current State

S3-R164-C1-A accepted semantic follow-up closure and formally closed the R162
semantic profile-source qualified diagnostic condition.

Remaining open HOLD:

```text
branch_conditional_if_expr_unsupported
```

Accepted facts:

- command matrix: `14/14 PASS`;
- failed checks: `0`;
- semantic profile wrong-kind qualified diagnostic: present and accepted;
- generated outputs remain proof-local harness evidence only;
- official RC evidence gathering remains closed;
- branch/conditional `if_expr` is unsupported by the current TypeChecker
  (`OOF-TY0 Unsupported expression kind: if_expr`);
- the remaining HOLD is an accepted boundary signal, not an implementation
  failure.

The harness summary records covered first-RC feature families:

- Add-style baseline;
- boolean gate/conjunction;
- integer arithmetic;
- mixed-type multi-input contract;
- POC-derived synthetic contract;
- negative/refusal corpus;
- CLI/API/load-path/profile-source transport surfaces.

---

## Option Comparison

### Option A: First RC Explicitly Excludes Branch/Conditional `if_expr`

Disposition:

```text
first_rc_excludes_branch_conditional_if_expr
```

Release-readiness impact:

- positive: unblocks a bounded repo-local compiler RC path without inventing
  new language semantics;
- preserves the existing harness as useful proof-local evidence;
- converts `if_expr` from RC-blocking HOLD into an explicit out-of-scope
  first-RC non-claim, if accepted by Portfolio.

Demo/POC impact:

- first RC can still demonstrate a coherent local compiler path for baseline
  contracts, boolean gates, integer arithmetic, mixed inputs, POC-derived
  synthetic contracts, refusals, CLI/API, load-path, and artifact checks;
- public demo remains closed;
- branch/conditional examples must not appear in first-RC demo/POC language.

Risk of overclaim:

- low if docs/non-claims explicitly say branch/conditional `if_expr` is not in
  first-RC scope;
- medium if future docs say "language RC" without listing excluded features.

Effect on harness status:

- current proof-local harness remains `HOLD`;
- a later accepted scope-aware harness/evidence route may treat
  `branch_conditional_if_expr_unsupported` as an expected out-of-scope condition
  instead of a HOLD, but only after Portfolio accepts the narrower first-RC
  boundary;
- no current harness output should be rewritten by this card.

Required docs/non-claims wording:

```text
First RC excludes branch/conditional `if_expr`. The release-candidate scope
does not claim branch or conditional expression support. Any source requiring
`if_expr` remains unsupported by the current TypeChecker and is outside this
RC. Branch/conditional support remains a post-RC language/compiler design and
proof topic.
```

Exact next route:

```text
S3-R164-C3-A
Track: first-rc-branch-conditional-scope-disposition-decision-v0
Mode: acceptance decision
Decision target: accept/hold/reject Option A and decide whether a scope-aware
RC evidence authorization review may open next.
```

If accepted, candidate follow-up route:

```text
compiler-release-acceptance-harness-scope-aware-rc-evidence-authorization-review-v0
```

Mode:

```text
authorization review only
```

Purpose:

```text
Decide whether official first-RC evidence gathering may open under the narrowed
scope, with branch/conditional `if_expr` explicitly excluded and non-claimed.
```

---

### Option B: First RC Waits Until Branch/Conditional Support Is Designed And Implemented

Disposition:

```text
first_rc_waits_for_branch_conditional_support
```

Release-readiness impact:

- blocks first RC until branch/conditional semantics, parser/TypeChecker and
  likely SemanticIR/compiler behavior are designed, authorized, implemented,
  and proven;
- keeps the original R160 diversity ambition fully intact;
- turns first RC from a release-boundary exercise into a language-feature
  expansion milestone.

Demo/POC impact:

- delays a hands-on RC-like compiler packet;
- eventual demo could be richer, but only after a new semantics lane closes;
- increases risk that release-readiness work loses momentum behind a broader
  compiler feature.

Risk of overclaim:

- low after implementation is accepted;
- high before implementation if docs imply branch support is near/expected.

Effect on harness status:

- harness remains `HOLD`;
- official RC evidence gathering remains closed;
- no PASS path exists until branch/conditional support is implemented and the
  harness rerun passes.

Required docs/non-claims wording:

```text
First RC is held until branch/conditional `if_expr` support is accepted.
Current harness evidence remains proof-local and cannot be promoted to RC
evidence while `branch_conditional_if_expr_unsupported` remains open.
```

Exact next route:

```text
branch-conditional-if-expr-language-support-design-v0
Mode: design-only
```

Later required routes would include proof, implementation authorization,
implementation, acceptance, and harness rerun. None are opened by this card.

---

### Option C: First RC Keeps `if_expr` As HOLD But Still Opens Limited RC Evidence

Disposition:

```text
limited_rc_evidence_with_known_hold
```

Release-readiness impact:

- creates ambiguous RC state: evidence would be gathered while the harness
  remains top-level `HOLD`;
- risks treating HOLD as a soft warning rather than a boundary;
- conflicts with S3-R164-C1-A direction that the HOLD must not be quietly
  waived.

Demo/POC impact:

- may produce a partial "RC-like" packet quickly;
- likely confuses users and downstream lanes because the packet is both RC
  evidence and not RC evidence.

Risk of overclaim:

- high;
- "limited RC evidence" is easy to misread as accepted RC evidence, especially
  once artifacts exist.

Effect on harness status:

- harness remains `HOLD`;
- evidence gathering would not be able to close RC acceptance;
- any PASS/HOLD distinction becomes muddier.

Required docs/non-claims wording:

```text
This is limited pre-RC evidence only. It is not official RC evidence and cannot
be used for release-candidate acceptance while
`branch_conditional_if_expr_unsupported` remains unresolved.
```

Exact next route:

```text
not recommended
```

If forced by Portfolio, the route should be named pre-RC, not RC:

```text
compiler-release-pre-rc-limited-evidence-map-v0
Mode: design/report only
```

---

### Option D: Route Separate Branch/Conditional Design/Proof Lane Before RC

Disposition:

```text
separate_branch_conditional_lane_before_rc
```

Release-readiness impact:

- keeps first RC on hold while a separate branch/conditional lane maps support;
- cleaner than Option B if the first step is design/proof only;
- still delays official RC evidence gathering.

Demo/POC impact:

- may improve future demos and corpus richness;
- does not help immediate first-RC boundary unless the lane is intentionally
  small and finishes quickly;
- creates another dependency before RC.

Risk of overclaim:

- low if design/proof-only language is strict;
- medium if stakeholders assume design/proof means implementation is imminent.

Effect on harness status:

- harness remains `HOLD`;
- official RC evidence gathering remains closed;
- later branch/conditional proof may either enable implementation planning or
  support a narrower RC exclusion decision.

Required docs/non-claims wording:

```text
Branch/conditional `if_expr` is under separate design/proof review and remains
outside accepted compiler behavior until a later implementation and acceptance
gate closes. Current RC evidence gathering remains closed.
```

Exact next route:

```text
branch-conditional-if-expr-scope-and-semantics-design-v0
Mode: design-only
```

This is a valid language-mainline route, but not the recommended immediate
first-RC route.

---

## Recommendation

Choose Option A.

Recommended disposition:

```text
first_rc_excludes_branch_conditional_if_expr
```

The first RC should be scoped as a repo-local compiler RC for already supported
surfaces:

- baseline Add-style compile;
- boolean gate/conjunction;
- integer arithmetic;
- mixed-type multi-input contract;
- POC-derived synthetic contract;
- parse/typecheck/refusal corpus;
- PROP-036 profile-source transport/refusal cases;
- CLI/API/load-path smoke;
- artifact normalization and closed-surface scan.

The first RC should explicitly not claim:

- branch/conditional `if_expr` support;
- broad language-feature completeness;
- public demo readiness;
- public release readiness;
- production runtime;
- Spark integration;
- Ruby Framework compiler compatibility;
- loader/report or public CompatibilityReport readiness.

Rationale:

- R160 required branch/conditional coverage only if already supported, or else
  a Portfolio scope decision accepting narrower first-RC language scope.
- R164 C1-A confirms `if_expr` is not currently supported and the remaining
  HOLD is a scope boundary, not a proof failure.
- A first RC can still be valuable as a bounded compiler acceptance packet
  without pretending to cover unsupported conditional expressions.
- Branch/conditional support should remain a separate post-RC language/compiler
  design/proof lane.

---

## Exact Next-Route Candidates

Recommended immediate route:

```text
Card: S3-R164-C3-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: first-rc-branch-conditional-scope-disposition-decision-v0
Route: UPDATE

Goal:
Accept, hold, or redirect the first-RC branch/conditional scope disposition.
Decide whether first RC may explicitly exclude branch/conditional `if_expr` and
whether an official RC evidence-gathering authorization review may open next.

Do not implement code.
Do not authorize parser, TypeChecker, SemanticIR, or compiler changes unless a
separate later route explicitly opens them.
Do not directly gather RC evidence in this decision.
```

If Option A is accepted, candidate next route:

```text
compiler-release-acceptance-harness-scope-aware-rc-evidence-authorization-review-v0
Mode: authorization review only
```

Possible later route if authorization review proceeds:

```text
compiler-release-acceptance-harness-official-rc-evidence-gathering-v0
Mode: bounded evidence gathering only
```

If Option A is rejected and branch support should lead:

```text
branch-conditional-if-expr-scope-and-semantics-design-v0
Mode: design-only
```

If Portfolio wants to preserve current HOLD without choosing:

```text
hold
Reason: branch_conditional_if_expr_unsupported remains unresolved and first-RC
scope cannot advance until it is either excluded or supported.
```

---

## Closed Surfaces

This design does not authorize:

- implementation;
- parser changes;
- TypeChecker changes;
- SemanticIR changes;
- classifier, assembler, or compiler changes;
- official RC evidence gathering;
- release execution;
- public release or public demo claims;
- public analyzer/tracer/visualizer implementation or command/UI;
- public API/CLI widening;
- root require changes;
- loader/report;
- `CompilationReport`, `CompilerResult`, or CompatibilityReport widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration
  outside already generated proof-local harness output;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

---

## Compact Receipt

```text
card: S3-R164-C2-D
track: first-rc-branch-conditional-scope-disposition-v0
status: done
recommendation: Option A
recommended_disposition: first_rc_excludes_branch_conditional_if_expr
remaining_language_gap: branch_conditional_if_expr_unsupported_post_rc
rc_evidence_gathering_authorized: no
compiler_changes_authorized: no
next_route: S3-R164-C3-A first-rc-branch-conditional-scope-disposition-decision-v0
```
