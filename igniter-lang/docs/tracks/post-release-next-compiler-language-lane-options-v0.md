# Post Release Next Compiler Language Lane Options v0

Card: S3-R186-C2-P1
Agent: [Lang Supervisor / Compiler-Profile Architect]
Role: lang-supervisor
Track: post-release-next-compiler-language-lane-options-v0
Route: UPDATE
Status: done
Date: 2026-05-26

---

## Summary

Recommendation:

```text
pause the release lane after the successful 0.1.0.alpha.1 publication
keep any second release route closed
open branch/conditional if_expr scope-and-semantics design/proof planning next
```

The next highest-value non-release lane is the post-RC language/compiler
boundary for branch/conditional `if_expr`. It is the clearest accepted alpha
exclusion, it already has machine-visible harness and release-scope evidence,
and resolving its design boundary would improve both future release coverage
and the user's ability to feel richer local compiler examples later.

This packet does not authorize implementation, a second release route, public
demo claims, production claims, Spark integration, or any public/API/runtime
widening.

---

## Evidence Read

- `igniter-lang/docs/tracks/stage3-round185-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/first-rc-branch-conditional-scope-disposition-v0.md`
- `igniter-lang/docs/tracks/first-rc-branch-conditional-scope-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-summary-package-v0.md`
- `igniter-lang/docs/tracks/compiler-release-target-versioning-and-execution-options-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-boundary-v0.md`
- targeted `rg` over compiler/language release exclusions, `if_expr`,
  profile finalization/discovery/defaulting, and analyzer/tracer/visualizer
  references.

---

## Current Post-Release State

Accepted release fact:

```text
igniter_lang 0.1.0.alpha.1 is published on RubyGems
exact tag igniter-lang-v0.1.0.alpha.1 is present locally and on origin
release execution was accepted with no incident, yank, abort, or remediation route
```

Allowed public wording remains bounded to alpha availability for the installed
`igc` CLI and accepted `--compiler-profile-source PATH.json` transport.

R185 handoff explicitly points away from immediate release continuation:

```text
return to compiler/language feature lane or run a short post-release hygiene
round; do not open another release execution route immediately.
```

Current major known exclusions:

- branch/conditional `if_expr`;
- profile finalization/discovery/defaulting;
- named/generated profile lookup;
- inline JSON profile input;
- env/config/sidecar profile lookup;
- all-grammar/stable/production/public-demo claims;
- public API/CLI widening beyond accepted `igc compile` and
  `--compiler-profile-source PATH.json`;
- loader/report and CompatibilityReport readiness;
- runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache behavior;
- Spark integration and Spark public evidence claims;
- Ruby Framework compatibility claims;
- signing, deployment, gem yank, force push, broad tag push, or another
  release execution route.

---

## Options Matrix

| Option | Value unlocked | Risk / why not now | Next route shape | Recommendation |
| --- | --- | --- | --- | --- |
| Return to compiler/language feature lane | Moves Stage 3 back from release mechanics to language capability. | Too broad unless narrowed to one known exclusion. | Choose one feature boundary only. | Accept, narrowed to `if_expr`. |
| Open branch/conditional `if_expr` design/proof planning | Addresses the clearest accepted first-RC/alpha exclusion; improves future harness coverage and richer local POC examples. | Implementation touches parser/TypeChecker/SemanticIR/compiler surfaces if rushed. | Design/proof planning only; no code. | **Recommended next dispatch.** |
| Open profile finalization/discovery/defaulting design-only pressure | Useful later for profile ergonomics and package stories. | High claim-drift risk: easy to confuse caller-supplied `PATH.json` transport with discovery/defaulting or public config behavior. | Design-only pressure after `if_expr` or separate Portfolio approval. | Defer. |
| Open analyzer/tracer/visualizer acceptance harness design | Could improve acceptance harness inspection and local understanding. | Tooling is not the main blocker after alpha; risks demo/tooling expansion before language gap is handled. | Design-only only, no implementation. | Defer behind language feature boundary. |
| Demo/POC package planning | May improve user-facing feel. | Public demo/package planning right after alpha risks overclaim; POC evidence already served release-readiness seed role. | Later planning route only. | Not now. |
| Pause and observe release feedback | Keeps posture calm after public alpha. | Passive observation alone does not advance Stage 3 compiler/language work. | Background status watch, no active card unless feedback arrives. | Keep as background posture. |
| Short post-release hygiene round | Captures R185 process lessons: explicit approval wording, `--pre` listing, docs sync wording. | Process hygiene, not the highest-value compiler/language lane. | Tiny docs/process card if desired. | Optional support, not primary lane. |

---

## Explicit Answers

### Should the release lane pause after R186?

```text
Yes.
```

The alpha release is accepted and verified. There is no incident, yank,
remediation, collision, or publish failure that requires a release follow-up.
Release feedback may be observed, but release execution should not remain the
active compiler-mainline lane.

### Should another release route remain closed?

```text
Yes.
```

No second release route should open without a fresh Portfolio/user decision
that names the target, version/tag/publish boundary, evidence delta, and public
wording. Current alpha success does not authorize another tag, push, publish,
signing, deployment, version change, or public claim expansion.

### What is the next highest-value non-release lane?

```text
branch/conditional if_expr scope-and-semantics design/proof planning
```

Reason:

- `if_expr` is the explicit first-RC and alpha exclusion with accepted
  non-claim wording;
- the current unsupported behavior is already concrete:
  `OOF-TY0 Unsupported expression kind: if_expr`;
- supporting it is a language/compiler semantics question, not a release
  harness fix;
- a design/proof plan can define the parser, TypeChecker, SemanticIR,
  assembler, artifact, and harness implications before any implementation
  authority is considered.

### Which surfaces remain closed?

- implementation of branch/conditional support;
- parser, classifier, TypeChecker, SemanticIR, assembler changes;
- root require, public API/CLI widening, and new CLI flags;
- release execution, second release route, version/tag/publish/sign/deploy;
- public demo, stable, all-grammar, production, or runtime claims;
- profile finalization/discovery/defaulting, named/generated lookup, inline
  JSON, env/config/sidecar lookup;
- analyzer/tracer/visualizer implementation or public tooling;
- loader/report, `CompilationReport`, `CompilerResult`, CompatibilityReport
  widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact-hash, or golden migration
  outside an explicitly authorized future route;
- Spark access, Spark fixtures/specs/integration, Spark public evidence, or
  production pressure;
- Ruby Framework compatibility/export claims;
- runtime, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing, deployment.

---

## Recommended Next Dispatch

```text
Card: S3-R187-C1-D
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-if-expr-scope-and-semantics-design-v0
Route: UPDATE
Depends on:
- S3-R186-C2-P1

Goal:
Design the branch/conditional if_expr scope, semantics, and proof plan from
the accepted post-RC/alpha exclusion evidence, without implementation.

Scope:
- Read:
  - igniter-lang/docs/tracks/post-release-next-compiler-language-lane-options-v0.md
  - igniter-lang/docs/tracks/first-rc-branch-conditional-scope-decision-v0.md
  - igniter-lang/docs/tracks/first-rc-branch-conditional-scope-disposition-v0.md
  - igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-v0.md
  - igniter-lang/docs/tracks/stage3-round185-status-curation-v0.md
  - igniter-lang/docs/current-status.md
  - current parser/TypeChecker/SemanticIR/assembler evidence for if_expr or
    unsupported-expression behavior discovered by rg
- Define:
  - current parser status for branch/conditional expression sources;
  - current TypeChecker refusal boundary and diagnostic ownership;
  - required semantics for condition type, branch type unification, diagnostics,
    and unsupported forms;
  - SemanticIR and artifact implications, if any;
  - release-harness corpus implications after support is eventually accepted;
  - minimal proof-only route required before implementation authorization.
- Do not implement code.
- Do not authorize implementation.
- Do not open release execution, public demo claims, production claims, Spark
  integration, profile discovery/defaulting, analyzer/tracer/visualizer
  implementation, or public API/CLI widening.

Deliver:
- Design track in igniter-lang/docs/tracks/
- Compact semantics/proof matrix
- Exact next proof-only or implementation-authorization-review recommendation
- Closed-surface list
```

Recommended follow-up after C1-D:

```text
S3-R187-C2-X
Track: branch-conditional-if-expr-design-pressure-v0
Mode: pressure review only
```

Optional support card, if Portfolio wants process hygiene in parallel:

```text
post-alpha-release-process-hygiene-notes-v0
Mode: docs/process only
Scope: R185 approval wording, prerelease RubyGems listing with --pre, and
post-publish docs sync wording lessons.
```

The support card should not block the `if_expr` design lane.
