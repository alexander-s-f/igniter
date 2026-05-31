# Experimental Use Productization Route Options v0

Card: S3-R222-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-use-productization-route-options-v0
Route: UPDATE
Status: done / recommended-bounded-experimental-quickstart
Date: 2026-05-31

Depends on:
- S3-R221-C5-S

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round221-status-curation-v0.md`
- `igniter-lang/docs/tracks/
  counterfactual-audit-report-api-boundary-decision-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/README.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/ruby-api.md`
- `igniter-lang/RELEASE_NOTES.md`
- `igniter-lang/lib/igniter_lang.rb`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/bin/igc`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/lib/igniter_lang/version.rb`
- `igniter-lang/source/*.ig`
- `igniter-lang/experiments/` index scan

---

## Decision Summary

Recommendation:

```text
open a bounded experimental quickstart/workflow implementation authorization
review next
```

Preferred next track:

```text
experimental-use-quickstart-workflow-authorization-review-v0
```

Why:

- the fastest honest route to experimental use is not more runtime work;
- the published alpha already has an installed `igc` compiler path;
- there is no `igniter-lang/examples/` directory yet;
- current `source/*.ig` files include usable fixtures but mix parser-only and
  compiler-accepted semantics;
- a bounded quickstart/workflow can create a first developer success path
  without widening API, runtime, report fields, or public claims.

---

## Fixed Boundaries

R221 closed:

```text
counterfactual report/API expansion paused
all report/API field and sidecar design routes held
Option D carrier held
implementation, public claim, Spark, release, runtime, and production authority closed
```

This route preserves:

- pre-v1 no-stable-API stance;
- no production readiness claim;
- no public demo claim;
- no Spark integration claim;
- no release execution;
- no counterfactual report/API or Option D reopening.

Allowed wording:

```text
experimental
alpha
pre-v1
subject to change
bounded quickstart
no stable API guarantee
not production-ready
```

Forbidden wording:

```text
stable API
production-ready
public demo-ready
Spark-ready
runtime-ready
all grammar support
v1 compatibility
```

---

## Current Surface Facts

Published package:

- `igniter_lang 0.1.0.alpha.1` is available on RubyGems;
- executable: `igc`;
- current version: `0.1.0.alpha.1`;
- gem files include `lib/**/*.rb`, `bin/igc`, `README.md`,
  and `RELEASE_NOTES.md`.

Current user-visible compile path:

```text
igc compile SOURCE --out OUT.igapp
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

Ruby facade:

```ruby
IgniterLang.compile(
  source_path: source_path,
  out_path: out_path,
  sample_input: nil,
  sample_input_resolver: nil,
  runtime_smoke: nil,
  compiler_profile_source: nil
)
```

RuntimeSmoke:

- proof-backed;
- not production runtime;
- not public runtime support;
- not a carrier for counterfactual evidence.

Examples:

```text
igniter-lang/examples/ is absent
```

Fixture sources:

- `source/add.ig` is the clearest bounded compiler success seed;
- `source/availability_projection.ig`,
  `source/tenant_availability_projection.ig`,
  `source/vendor_lead_pipeline.ig`,
  `source/decimal_contract.ig`, and `source/polymorphic_add.ig` carry useful
  domain signals but include parser-only or non-runtime semantics that need
  careful labeling.

---

## Productization Options Matrix

```text
Option: experimental sample app / workflow lane
TTEU impact: High
Size: Small
Proof burden: Low/Medium
API risk: Low
Claim risk: Low if fenced
Verdict: Best next route

Option: CLI-first compile/run usability lane
TTEU impact: High
Size: Medium
Proof burden: Medium
API risk: Medium
Claim risk: Medium
Verdict: Split: compile now, run later

Option: RuntimeSmoke / runtime harness productization
TTEU impact: Medium
Size: Medium/High
Proof burden: High
API risk: High
Claim risk: High
Verdict: Hold

Option: docs-only experimental quickstart
TTEU impact: Medium
Size: Small
Proof burden: Low
API risk: Low
Claim risk: Medium
Verdict: Useful but not enough alone

Option: package/gem hygiene lane
TTEU impact: Medium
Size: Medium
Proof burden: Medium
API risk: Medium
Claim risk: Low
Verdict: Later, after quickstart shape

Option: pause / hold
TTEU impact: None
Size: None
Proof burden: None
API risk: Low
Claim risk: Low
Verdict: Wrong for market pressure
```

TTEU:

```text
time to experimental use
```

---

## Preferred Route

Open a bounded implementation-authorization review for:

```text
experimental-use-quickstart-workflow-v0
```

Candidate implementation shape, if later authorized:

- create `igniter-lang/examples/experimental_quickstart_v0/`;
- include a minimal accepted `add.ig` or copied bounded source fixture;
- include a tiny README or command transcript under the example directory;
- include a script or proof harness that:
  - compiles the source through local or installed `igc`;
  - writes output only under an example-local or temp `out/`;
  - verifies `.igapp` presence and public result status;
  - optionally runs a read-only installed-gem smoke if explicitly authorized;
- add a track doc with evidence and non-claims.

Do not include in the first slice:

- RuntimeSmoke productization;
- report/result/API fields;
- new public CLI flags;
- source grammar widening;
- profile discovery/defaulting/finalization;
- Spark integration;
- release execution.

---

## Route Rationale

Why examples/quickstart first:

- it turns the alpha package into something a developer can try quickly;
- it does not require a new API contract;
- it can use the already accepted `igc compile` path;
- it reveals friction before runtime/product API design;
- it gives the project a market-facing direction without making market-facing
  claims.

Why not runtime first:

- RuntimeSmoke remains proof-context only by R220/R221;
- runtime productization would reopen selected execution vs proof support
  ambiguity;
- no report/API exposure fence authorizes runtime output claims;
- the fastest useful signal is a compileable workflow, not a runtime surface.

Why not docs-only:

- docs-only improves explanation but not actual use;
- the current gap is "can I try this?" not only "can I read about this?";
- a quickstart without a runnable/provable path risks becoming another status
  artifact.

Why not package hygiene first:

- package hygiene matters after the quickstart shape is known;
- packaging examples into the gem may be useful later, but first we need a
  repo-local experimental workflow proof;
- changing gemspec/package files before the workflow exists increases churn.

---

## No-Stable-API Stance

The current wording is directionally sufficient, but the next route should make
it visible in the quickstart itself:

```text
Igniter-Lang is pre-v1 alpha. This quickstart is experimental and subject to
change. It is not a stable API, production, public demo, Spark, runtime, or
all-grammar support claim.
```

This does not require a public docs rewrite in the next implementation slice.
It should live inside the example/track boundary unless C4-A authorizes wider
docs edits.

---

## Recommended Proof / Regression Shape

For the next authorization review, require:

- `ruby -c` on any added Ruby script;
- local quickstart command/harness PASS;
- output confined to example-local `out/` or temp directory;
- no `lib/**` changes unless explicitly authorized;
- no `CompilerResult` / `CompilationReport` field changes;
- no RuntimeSmoke behavior changes;
- no public docs/body spec edits by default;
- no package/gemspec changes by default;
- forbidden phrase scan for stable/production/public-demo/Spark/runtime-ready
  claims.

---

## Explicit Answers

- Does experimental-use pressure change sequencing?
  Yes. Pause proof-only counterfactual expansion and route toward a bounded
  quickstart/workflow.
- What is the smallest honest experimental-use route?
  A repo-local experimental quickstart/workflow around accepted `igc compile`.
- Should implementation authorization open next?
  Yes, as a bounded authorization review, not direct implementation.
- Is another survey needed first?
  No. C2-P1 may add facts in parallel, but C1-D recommendation is already
  clear.
- Should CLI be the next primary surface?
  Yes, the existing `igc compile` path should be the first usable surface.
- Should RuntimeSmoke be the next primary surface?
  No. Keep proof-context only.
- Should examples be primary?
  Yes, create the first bounded `examples/experimental_quickstart_v0`.
- Should docs be primary?
  Secondary: example-local quickstart docs only unless later authorized.
- Should package hygiene be primary?
  Not yet; defer until quickstart shape is proven.
- Is no-stable-API-before-v1 wording sufficient?
  Sufficient if repeated inside the quickstart boundary.
- Do public/stable/production/Spark/release claims remain closed?
  Yes.

---

## Exact C4-A Recommendation

For S3-R222-C4-A:

```text
accept C1-D productization route recommendation
accept the route as bounded experimental quickstart/workflow first
open implementation-authorization review next
do not authorize implementation directly in C4-A
keep stable API unpromised before v1
keep release execution closed
keep public demo/production/Spark/runtime-ready claims closed
keep counterfactual report/API and Option D lanes paused
```

Recommended next card:

```text
Card: S3-R223-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-use-quickstart-workflow-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R222-C4-A

Goal:
Decide whether a bounded experimental quickstart/workflow implementation may
begin, using the existing `igc compile` surface and no stable API, production,
runtime, Spark, or release claims.

Candidate allowed write scope:
- igniter-lang/examples/experimental_quickstart_v0/**
- igniter-lang/docs/tracks/experimental-use-quickstart-workflow-v0.md

Default closed unless explicitly authorized:
- igniter-lang/lib/**
- igniter-lang/igniter_lang.gemspec
- igniter-lang/README.md
- igniter-lang/docs/README.md
- public docs/body spec
- RuntimeSmoke behavior/result shape
- CompilerResult / CompilationReport fields
- release/tag/publish/deploy

Deliver:
- Authorization decision doc in `igniter-lang/docs/tracks/`
- Exact C2-I implementation boundary or blocker list
```
