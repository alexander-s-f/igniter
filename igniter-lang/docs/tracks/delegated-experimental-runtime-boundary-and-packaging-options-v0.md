# Delegated Experimental Runtime Boundary And Packaging Options v0

Card: S3-R224-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-boundary-and-packaging-options-v0
Route: UPDATE
Status: done / recommend-reusable-helper-authorization-review
Date: 2026-05-31

Depends on:
- S3-R223-C5-S

---

## Decision Summary

Recommended next route:

```text
delegated experimental runtime reusable helper authorization review
```

Preferred next card:

```text
S3-R225-C1-A
Track: delegated-experimental-runtime-reusable-helper-authorization-review-v0
```

This is the smallest runtime-productization move that preserves the R223
boundary while reducing duplicated example-local runtime code.

Do not open `igc run` yet. Do not package a public runtime yet. Do not turn
RuntimeSmoke into the product runtime. Do not start Reference Runtime
implementation yet.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round223-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-v0.md`
- `igniter-lang/docs/discussions/experimental-executable-quickstart-pressure-v0.md`
- `igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/quickstart_result.json`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- advisory only: `igniter-lang/docs/inbox/compiler_gap_analysis_report.md`

The inbox compiler gap report is treated as advisory context only. It does not
open implementation or change the R223/R224 authority surface.

---

## Current Fixed Point

R223 accepted real executable evidence:

```text
.ig source -> compile -> .igapp -> delegated experimental runtime -> sum = 42
```

Accepted facts:

- source: `add_quickstart.ig`;
- compile status: `ok`;
- `.igapp` load status: `loaded`;
- adapter used: `false`;
- execution status: `ok`;
- actual result: `sum = 42`;
- proof matrix: `14/14 PASS`;
- result digest:
  `sha256:666952db1cf6018396dd2595690956cdf9337c4ca5f3d333f950f5218756731a`.

Accepted authority:

```text
delegated experimental runtime evidence only
non-canonical example-local runtime-learning evidence
```

Not accepted:

- Reference Runtime support;
- public runtime support;
- production runtime support;
- stable API;
- public demo readiness;
- Spark integration;
- release evidence.

---

## Route Options Matrix

```text
Option: keep delegated runtime harness example-local only
TTEU impact: Low/Medium
Implementation size: None
API/CLI risk: Very Low
Claim risk: Very Low
Runtime debt reduction: Low
Package/release implications: None
Proof burden: Low
Reversibility: High
Verdict: Too timid after R223 PASS
```

```text
Option: extract reusable examples-local delegated runtime helper
TTEU impact: High
Implementation size: Small
API/CLI risk: Low
Claim risk: Low if fenced
Runtime debt reduction: Medium
Package/release implications: None
Proof burden: Low/Medium
Reversibility: High
Verdict: Best next route
```

```text
Option: create internal experimental runtime package under experiments/
TTEU impact: Medium/High
Implementation size: Medium
API/CLI risk: Medium
Claim risk: Medium
Runtime debt reduction: Medium/High
Package/release implications: Medium
Proof burden: Medium/High
Reversibility: Medium
Verdict: Good later, premature now
```

```text
Option: design pre-v1 experimental igc run boundary
TTEU impact: High later
Implementation size: Design-only now
API/CLI risk: High
Claim risk: High
Runtime debt reduction: Medium
Package/release implications: High
Proof burden: High
Reversibility: Low/Medium
Verdict: Hold until reusable helper proves shape
```

```text
Option: Runtime Specification slice first
TTEU impact: Medium
Implementation size: Design-only
API/CLI risk: Low
Claim risk: Low
Runtime debt reduction: Medium
Package/release implications: None
Proof burden: Medium
Reversibility: High
Verdict: Parallel/later; not the immediate productization unlock
```

```text
Option: Reference Runtime boundary survey
TTEU impact: Medium later
Implementation size: Design-only
API/CLI risk: Medium
Claim risk: High
Runtime debt reduction: High later
Package/release implications: High later
Proof burden: High
Reversibility: Medium
Verdict: Too early before delegated helper boundary
```

```text
Option: pause
TTEU impact: None
Implementation size: None
API/CLI risk: None
Claim risk: None
Runtime debt reduction: None
Package/release implications: None
Proof burden: None
Reversibility: High
Verdict: Wrong after executable proof landed
```

TTEU:

```text
time to experimental use
```

---

## Recommended Route

Open an authorization review for:

```text
delegated-experimental-runtime-reusable-helper-v0
```

Candidate future implementation shape, if later authorized:

- extract a tiny helper under examples or experiments, not `lib/**`;
- keep quickstart executable through the helper;
- preserve the existing R223 example behavior and result shape;
- keep delegated runtime non-canonical;
- keep output example-local or temp-local;
- keep RuntimeSmoke unchanged;
- keep CLI `run` closed;
- keep package/gemspec/release closed.

Suggested default allowed write scope for the later implementation card:

```text
igniter-lang/examples/experimental_runtime_helpers/**
igniter-lang/examples/experimental_executable_quickstart_v0/**
igniter-lang/docs/tracks/delegated-experimental-runtime-reusable-helper-v0.md
```

Alternative allowed home if C4-A prefers experiments:

```text
igniter-lang/experiments/delegated_experimental_runtime_helper_v0/**
igniter-lang/docs/tracks/delegated-experimental-runtime-reusable-helper-v0.md
```

The preferred home is `examples/experimental_runtime_helpers/**` because the
helper is a developer-experience surface, not a canonical experiment result and
not a package surface.

---

## Why Not `igc run` Yet

`igc run` would create a public CLI surface. Even if labeled experimental, it
would strongly imply a runtime product boundary.

Open `igc run` only after:

- reusable helper shape is proven;
- input contract and sample input policy are defined;
- result/output key policy is defined;
- failure/HOLD behavior is proven;
- no-claim wording is attached to the CLI surface;
- packaging and gem inclusion stance are explicit.

For R224, `igc run` should remain design-only and closed to implementation.

---

## Why Not RuntimeSmoke Productization

RuntimeSmoke already exists as proof-context glue around proof RuntimeMachine.
Turning it into the product runtime now would collapse several boundaries:

- proof evidence vs product behavior;
- callback smoke vs runtime command;
- internal result shape vs user-facing runtime output;
- selected example execution vs public runtime support.

RuntimeSmoke should remain unchanged and unproductized for the next route.

---

## Why Not Reference Runtime Yet

Reference Runtime should be the canonical implementation candidate. That makes
it slower, more durable, and more claim-sensitive than the delegated
experimental runtime.

R223 proved the fast frontier path. The next useful move is to make that path
less duplicated and more repeatable, not to prematurely canonize it.

Reference Runtime boundary survey may open after the delegated helper proves
which runtime surface is worth canonizing.

---

## Runtime Specification Stance

Runtime Specification remains important, but it should not block the next
delegated helper step.

Recommended stance:

- keep Runtime Specification as the canonical/normative layer;
- do not implement it in R224/R225;
- capture learnings from the delegated helper as future spec input;
- open a Runtime Specification slice after the helper exposes repeated
  semantics or result-shape questions.

---

## Closed Surfaces

Remain closed:

- `igniter-lang/lib/**`;
- `igniter-lang/bin/igc`;
- `igniter-lang/igniter_lang.gemspec`;
- `igniter-lang/README.md`;
- public docs and body spec chapters;
- RuntimeSmoke source, behavior, callback, and result shape;
- CompilerResult and CompilationReport fields;
- report/result/receipt sidecars;
- public API/CLI widening;
- `igc run` implementation;
- Reference Runtime implementation;
- Runtime Specification implementation;
- stable API / v1 compatibility;
- production / public demo / Spark / release claims.

---

## Explicit Answers

Should delegated runtime remain example-local for now?

```text
Yes for authority; no for code duplication.

It should remain examples/experiment-local and non-canonical, but a reusable
helper route may open so future examples do not copy the full quickstart
harness.
```

May any packaging or extraction route open next?

```text
Yes. Open a reusable helper authorization review next.
Do not open public package, gemspec, or release packaging yet.
```

Does CLI `run` remain closed?

```text
Yes. `igc run` may be discussed later as design-only, but remains closed to
implementation now.
```

Should Runtime Specification open before more delegated runtime?

```text
No. Runtime Specification should stay canonical/normative, but the next
runtime-learning step should be delegated helper extraction. Specification can
consume the repeated patterns after the helper proves them.
```

Does Reference Runtime remain closed?

```text
Yes.
```

Do stable API, production, public demo, Spark, and release claims remain closed?

```text
Yes.
```

---

## Exact C4-A Recommendation

```text
Accept C1-D options recommendation.
Accept delegated runtime as non-canonical runtime-learning evidence only.
Open S3-R225-C1-A authorization review for a reusable delegated experimental
runtime helper under examples/ or experiments.

Do not open:
- direct implementation from C4-A;
- `igc run`;
- RuntimeSmoke productization;
- Reference Runtime implementation;
- Runtime Specification implementation;
- public runtime support;
- stable API / production / Spark / release claims.
```

Recommended next card:

```text
Card: S3-R225-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-reusable-helper-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R224-C4-A

Goal:
Decide whether a bounded reusable delegated experimental runtime helper may
begin, extracting repeatable logic from the accepted R223 quickstart while
keeping the helper non-canonical, examples/experiment-local, and outside
public API/CLI/runtime/release authority.

Candidate allowed write scope, if authorized:
- igniter-lang/examples/experimental_runtime_helpers/**
- igniter-lang/examples/experimental_executable_quickstart_v0/**
- igniter-lang/docs/tracks/
  delegated-experimental-runtime-reusable-helper-v0.md

Candidate behavior:
- keep R223 quickstart executable;
- move reusable delegated runtime load/evaluate/result packet logic into a
  helper;
- keep generated output example-local or temp-local;
- preserve `sum = 42` evidence path;
- keep RuntimeSmoke, `lib/**`, `bin/igc`, CompilerResult, CompilationReport,
  gemspec, README, public docs, CLI `run`, Reference Runtime, and release
  surfaces closed.

Deliver:
- Authorization decision doc in `igniter-lang/docs/tracks/`
- Compact decision summary
- If authorized: exact C2-I implementation boundary
- If held/redirected: blocker list
```
