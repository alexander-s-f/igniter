# Application Showcase Portfolio Guide Track

This track turns the accepted richer showcase portfolio into an
enterprise-facing guide and discoverability surface.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

Constraints:

- `:interactive_poc_guardrails` from [Constraint Sets](./constraints.md)
- [Application Showcase Portfolio Final Synthesis Track](./application-showcase-portfolio-final-synthesis-track.md)
- [Interactive App Structure](../guide/interactive-app-structure.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting the final showcase
portfolio synthesis.

The next step is enterprise-facing documentation/discoverability, not runtime
API extraction.

## Goal

Make Lense, Chronicle, Scout, and Dispatch easy for a new developer or
enterprise evaluator to discover, run, compare, and understand as current
Igniter application examples.

The result should answer:

- what each showcase proves
- how to run each smoke and manual server mode
- what package capabilities each showcase exercises
- what evidence artifacts exist
- what mutation boundaries are guaranteed
- what repeated structure is convention versus package API
- where legacy material lives in the story now

## Scope

In scope:

- user-facing guide/index updates under `docs/guide/`
- compact dev-doc cross-links if needed
- README/discoverability wording if needed
- clear table or matrix across Lense, Chronicle, Scout, and Dispatch
- run commands, manual server commands, receipt/report endpoints, and mutation
  boundary summary
- explicit "not yet API" notes for repeated app/web shapes

Out of scope:

- product app implementation
- public `Igniter.interactive_app` facade
- shared command result, snapshot, receipt/report, marker, route, UI, or screen
  APIs
- smoke-helper implementation
- live transport, LLMs, connectors, schedulers, persistence, auth, production
  server behavior, or cluster placement
- making legacy a public onboarding entrypoint

## Task 1: Portfolio Guide Content

Owner: `[Agent Application / Codex]`

Acceptance:

- Add or update a user-facing showcase portfolio guide under `docs/guide/`.
- Present Lense, Chronicle, Scout, and Dispatch as the four richer current
  application examples.
- Include purpose, workflow, packages exercised, evidence artifact,
  mutation-boundary guarantee, smoke command, and manual server command for
  each showcase.
- Explain the repeated app structure as a copyable convention, not a framework
  contract.
- Keep legacy material reference-only; public onboarding should start from
  current packages, guides, and showcase apps.

## Task 2: Web/Manual Review Discoverability

Owner: `[Agent Web / Codex]`

Acceptance:

- Add or update Web-facing guide language so manual browser review is easy to
  follow for all four showcases.
- Include surface names, `/events`, `/report` or `/receipt`, feedback markers,
  and stable inspection seams at guide level.
- Keep Web repetition as guide-level convention; do not propose a marker DSL,
  route DSL, UI kit, component DSL, live transport, or browser automation
  default.
- Ensure docs do not imply production server behavior.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- This is a clarity and onboarding track. Keep it compact.
- The guide should feel enterprise-serious: reproducible commands, evidence
  artifacts, explicit boundaries, and current package story.
- Avoid turning the guide into a historical narrative. Legacy is private/
  reference context, not the current product path.
- Do not invent new features while documenting the portfolio.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
git diff --check
```

If examples or code change, run the affected example smoke and RuboCop commands.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` writes or updates the app-side portfolio guide
   content.
2. `[Agent Web / Codex]` writes or updates the Web/manual-review
   discoverability content.
3. `[Architect Supervisor / Codex]` reviews whether the portfolio is clear
   enough to become the current public onboarding path.

[Agent Application / Codex]
track: `docs/dev/application-showcase-portfolio-guide-track.md`
status: landed
delta: added `docs/guide/application-showcase-portfolio.md` as the
  evaluator-facing portfolio map for Lense, Chronicle, Scout, and Dispatch.
delta: linked the new portfolio guide from `docs/guide/README.md` and
  `docs/guide/interactive-app-structure.md`.
delta: documented purpose, workflow, packages exercised, evidence artifact,
  mutation boundary, smoke command, manual server command, copyable convention,
  not-yet-API boundaries, and legacy reference-only positioning.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can add Web/manual-review discoverability details;
  then `[Architect Supervisor / Codex]` can review public onboarding readiness.
block: none

[Agent Web / Codex]
track: `docs/dev/application-showcase-portfolio-guide-track.md`
status: landed
delta: updated `docs/guide/application-showcase-portfolio.md` with a
  Web/manual-review map for Lense, Chronicle, Scout, and Dispatch, including
  mounted surface files, surface markers, evidence endpoints, and review focus.
delta: documented guide-level inspection seams for `/events`, `/report` or
  `/receipt`, feedback markers, activity markers, command actions, and domain
  `data-` attributes while keeping them app-local.
delta: clarified that manual server mode is example scaffolding and that the
  portfolio does not require browser automation, live transport, production
  server behavior, auth, persistence, schedulers, connectors, or LLM/provider
  integration.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` can review public onboarding readiness.
block: none

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted.

Decision:

- The showcase portfolio guide is accepted as the current public onboarding
  path for richer Igniter applications.
- Lense, Chronicle, Scout, and Dispatch are now presented as a coherent
  enterprise-facing portfolio: reproducible, one-process, offline,
  contracts-native, inspectable through Web, and backed by evidence artifacts.
- The guide correctly separates copyable convention from public API. Repeated
  app/web shapes remain guide-level doctrine, not a framework contract.
- Legacy material remains reference/private context, not the current onboarding
  entrypoint.

Supervisor verification:

```bash
git diff --check
```

Result:

- `git diff --check` passed.

Next:

- Accept Research Horizon's Igniter-Lang delta as filtered research input and
  open a narrow [Igniter Lang Foundation Pack Track](./igniter-lang-foundation-pack-track.md).
