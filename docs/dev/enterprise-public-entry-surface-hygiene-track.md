# Enterprise Public Entry Surface Hygiene Track

This track aligns the public repository entrypoints with the accepted
enterprise verification receipt.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
[Agent Contracts / Codex]
[Research Horizon / Codex]
```

Inputs:

- [Enterprise Verification](../guide/enterprise-verification.md)
- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)
- [Igniter Lang Foundation](../guide/igniter-lang-foundation.md)
- [Examples](../../examples/README.md)
- [Root README](../../README.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting enterprise verification
receipt hardening.

The next step is public entry-surface hygiene, not new product scope.

## Goal

Make a new evaluator's first 10 minutes coherent:

- root README points to the current proof path
- examples README, guide index, package READMEs, and showcase docs agree on
  what is current
- stale references to removed/private legacy material are corrected or clearly
  marked as reference-only
- the enterprise receipt remains the compact proof path

## Scope

In scope:

- README/index/doc wording and links
- examples/catalog discoverability corrections
- package README cross-links to the accepted proof path
- stale public onboarding references caused by legacy relocation
- concise known-caveat wording for full RuboCop archived/research offenses

Out of scope:

- runtime/code feature work
- new app implementation
- new package APIs or DSLs
- changing the verification receipt's semantics
- restoring legacy as a public onboarding path
- production server/auth/persistence/cluster/connectors/LLM claims

## Task 1: Root And Examples Entrypoints

Owner: `[Agent Application / Codex]`

Acceptance:

- Root README links to Enterprise Verification, Application Showcase
  Portfolio, Igniter Lang Foundation, and active examples without stale
  removed-example references.
- `examples/README.md` stays aligned with `ruby examples/run.rb list` for the
  active flagship and verification examples.
- Legacy relocation is framed as private/reference context, not onboarding.

## Task 2: Web And Application Guide Links

Owner: `[Agent Web / Codex]`

Acceptance:

- Application/Web guide links consistently point evaluators to Enterprise
  Verification for proof and Application Showcase Portfolio for app review.
- Manual server wording stays review-only and does not imply production server,
  browser automation, auth, persistence, live transport, or deployment.
- Surface markers remain app-local inspection seams.

## Task 3: Contracts/Lang Package Entrypoints

Owner: `[Agent Contracts / Codex]`

Acceptance:

- `packages/igniter-contracts/README.md` and related package-local docs point
  to Enterprise Verification and Igniter Lang Foundation where appropriate.
- Lang wording remains report-only and avoids implying runtime enforcement.
- Changed-file RuboCop caveat is referenced only where useful and does not
  normalize broad lint debt as acceptable product quality.

## Task 4: Horizon Overclaim Filter

Owner: `[Research Horizon / Codex]`

Acceptance:

- Review the public entry surfaces for overclaiming.
- Flag stale claims about production readiness, agents, LLM/provider behavior,
  cluster/distributed guarantees, or Lang runtime semantics.
- Recommend whether the next track should be release-readiness checklist,
  examples/spec smoke helper extraction, Embed/SparkCRM pressure follow-up, or
  pause for human review.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- Do not expand the enterprise proof claim; make the entrypoints easier to
  find and harder to misread.
- Prefer compact links and command pointers over long repeated explanations.
- Public docs should make current packages, showcase apps, and verification
  receipts feel like one coherent product surface.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
git diff --check
```

If code changes unexpectedly, run affected specs/smoke/lint.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted.

The public entry surface is now coherent enough for the current enterprise
evaluation story:

- Root README points evaluators to Enterprise Verification, the showcase
  portfolio, active examples, and current package READMEs without local
  absolute paths or stale companion onboarding.
- `examples/README.md` and guide entrypoints now route toward active runnable
  examples, the application showcase portfolio, and the compact enterprise
  proof path.
- `packages/igniter-contracts/README.md`, `packages/igniter-web/README.md`,
  and app/web guides preserve the accepted boundaries: proof path yes,
  production server/API graduation no.
- Research Horizon's overclaim filter is accepted: cluster, production server,
  auth, persistence, live transport, connectors, LLM/provider behavior, Lang
  runtime enforcement, grammar/Rust, and smoke-helper/API promotion remain out
  of the verified claim.

Supervisor follow-up:

- Cleaned guide-level stale public links that still pointed to removed
  companion, old `docs/<layer>/README.md` paths, removed package README files,
  and local absolute `igniter-frontend` package links.
- Kept frontend/schema rendering guides as direction/reference wording, but
  routed current proof back to `igniter-web`, Enterprise Verification, and the
  showcase portfolio.

Supervisor verification:

- `git diff --check` passed.
- Public-guide stale-link scan for removed companion, old layer README paths,
  old uppercase frontend docs, removed package README files, and local
  `igniter-frontend` package paths returned no matches.
- `ruby examples/run.rb smoke` passed with 81 examples.

Decision:

Open the next track as a narrow release-readiness checklist. Do not implement
new runtime behavior, extract smoke helpers, or open another product app until
the current proof set has a compact release/evaluator readiness gate.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` cleans root/examples entrypoints.
2. `[Agent Web / Codex]` cleans app/web guide links and manual-review wording.
3. `[Agent Contracts / Codex]` cleans contracts/lang package entrypoints.
4. `[Research Horizon / Codex]` reviews the public surface for overclaiming
   and recommends the next post-hygiene track.

[Agent Web / Codex]
track: `docs/dev/enterprise-public-entry-surface-hygiene-track.md`
status: landed
delta: updated `docs/guide/interactive-app-structure.md` to point evaluators
  to Enterprise Verification for the proof path and to clarify manual server
  mode as review scaffolding only.
delta: updated `docs/guide/app.md` so small interactive app readers start from
  Enterprise Verification, then Application Showcase Portfolio, then the
  copyable structure convention.
delta: updated `packages/igniter-web/README.md` with proof-path links and
  explicit Web boundary wording: no production server claim, marker DSL, route
  DSL, component DSL, browser automation default, auth, persistence, live
  transport, deployment behavior, or cluster placement.
verify: `git diff --check` passed.
ready: `[Agent Application / Codex]`, `[Agent Contracts / Codex]`, and
  `[Research Horizon / Codex]` can complete their hygiene passes; then
  `[Architect Supervisor / Codex]` can review the entry surface.
block: none

[Agent Contracts / Codex]
track: `docs/dev/enterprise-public-entry-surface-hygiene-track.md`
status: landed
delta: updated `packages/igniter-contracts/README.md` with evaluator proof
  links, verification commands, focused contracts/lang checks, and a narrow
  changed-file RuboCop caveat.
delta: linked `docs/guide/igniter-lang-foundation.md`,
  `docs/guide/contract-class-dsl.md`, and `docs/guide/api-and-runtime.md` back
  to the accepted Enterprise Verification path.
delta: kept Lang wording report-only and avoided new runtime enforcement,
  store, warning, deadline-monitoring, or `ExecutionResult` claims.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` after remaining entry-surface hygiene
  and Research Horizon overclaim review.
block: none

[Agent Application / Codex]
track: `docs/dev/enterprise-public-entry-surface-hygiene-track.md`
status: landed
delta: cleaned root README public onboarding links toward Enterprise
  Verification, Application Showcase Portfolio, user guide, active examples,
  and current package READMEs without local absolute paths.
delta: removed stale root README entrypoint fragments for legacy/core/agent/sdk
  lanes and removed the missing `examples/companion` public landmark.
delta: aligned examples onboarding with the accepted flagship application
  verification path and linked the application showcase portfolio.
delta: replaced the missing companion-app reading path in `docs/README.md`
  with Enterprise Verification, Application Showcase Portfolio, Interactive
  App Structure, and active examples.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]`, `[Agent Contracts / Codex]`, and
  `[Research Horizon / Codex]` can continue hygiene review.
block: none

[Research Horizon / Codex]
track: `docs/dev/enterprise-public-entry-surface-hygiene-track.md`
status: landed
delta: reviewed root, guide, examples, package README, Research Horizon, and
  expert entry surfaces for overclaiming against the accepted Enterprise
  Verification path.
delta: tightened the root README cluster wording from broad distributed runtime
  posture to distributed planning/mesh execution with deployment guarantees
  deferred.
delta: confirmed public surfaces now keep production server, auth,
  persistence, live transport, cluster placement/deployment guarantees,
  connectors, LLM/provider behavior, Lang runtime enforcement, grammar/Rust,
  and smoke-helper/API promotion out of the verified claim.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` can review the entry surface.
block: none

Recommended next post-hygiene track:

Open a narrow release-readiness checklist track before implementing new
features or extracting smoke helpers.

Suggested acceptance:

- one checklist that names release blockers, verification commands, package
  docs, examples smoke, changed-file lint policy, legacy/reference caveats,
  and known non-goals
- no runtime/API changes
- no new product app
- no `interactive_app`, Lang continuation, cluster runtime, live agents, or
  connector work
- smoke-helper extraction remains a later examples/specs-only track if release
  checklist work shows repeated maintenance pain
