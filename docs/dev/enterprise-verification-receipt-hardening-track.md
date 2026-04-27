# Enterprise Verification Receipt Hardening Track

This track turns the current public Igniter proof set into one compact
enterprise-facing verification path and receipt.

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

- [Igniter Enterprise Readiness Synthesis Track](./igniter-enterprise-readiness-synthesis-track.md)
- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)
- [Igniter Lang Foundation](../guide/igniter-lang-foundation.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting enterprise readiness
synthesis.

The next step is trust hardening, not feature expansion.

## Goal

Give an enterprise evaluator one clear way to verify the current Igniter story.

The result should answer:

- which commands are canonical verification commands
- what each command proves
- which showcase apps are flagship application proof
- how contracts/lang verification fits the story
- where Web/manual review fits without implying production server readiness
- what remains explicitly out of scope

## Scope

In scope:

- user-facing guide or guide section for enterprise verification
- compact verification receipt/document
- links from guide/index docs if needed
- examples/catalog discoverability wording if needed
- design note for an examples/specs-scoped smoke helper boundary

Out of scope:

- implementing smoke helper code
- new product apps
- new runtime behavior
- new package APIs or DSLs
- browser automation default
- production server/auth/persistence/scheduler/connectors/live/cluster work
- Lang grammar/Rust/store/OLAP/time-machine/deadline enforcement

## Task 1: Application/Web Verification Path

Owner: `[Agent Application / Codex]` and `[Agent Web / Codex]`

Acceptance:

- Define the flagship application verification path for Lense, Chronicle,
  Scout, and Dispatch.
- Tie together smoke output, mounted surface marker, one success/refusal flow,
  `/events` parity, `/report` or `/receipt`, and mutation-boundary proof.
- Keep manual server mode as review scaffolding, not production behavior.
- If a smoke helper is discussed, keep it examples/specs-scoped and design-only.

## Task 2: Contracts/Lang Verification Path

Owner: `[Agent Contracts / Codex]`

Acceptance:

- Define the contracts-facing verification path for package specs, examples
  smoke, class DSL, Embed-facing contract pressure, StepResultPack, and Lang
  foundation.
- Include the practical caveat that full RuboCop currently includes
  pre-existing archived/research offenses, so changed-file lint is used for
  narrow slices.
- Keep Lang wording explicit: descriptors and metadata manifests are declared
  and report-only unless future runtime semantics are accepted.

## Task 3: Horizon Non-Goals

Owner: `[Research Horizon / Codex]`

Acceptance:

- Review the verification receipt for overclaiming.
- Add concise non-goal language for grammar/Rust/live agents/cluster/runtime
  expansion.
- Recommend whether the next track after hardening should be release hygiene,
  smoke-helper implementation, Embed/SparkCRM follow-up, or pause for review.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- A receipt is evidence, not a new runtime artifact.
- Prefer a short command matrix and clear proof statements over broad prose.
- Do not make legacy a public onboarding path.
- Do not turn examples/spec smoke mechanics into package APIs in this track.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
git diff --check
```

If code changes unexpectedly, run affected specs/smoke/lint.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted.

The enterprise verification receipt is now the current evaluator-facing proof
entrypoint:

- `docs/guide/enterprise-verification.md` gives one compact command matrix and
  receipt path across contracts, flagship applications, Web/manual review, and
  Lang foundation.
- The four flagship applications are correctly framed as reproducible
  one-process evidence, not as a public application framework API.
- Web markers remain inspection seams, not marker DSL/component API.
- Contracts/Lang wording is strict enough: report-only metadata does not imply
  runtime checks, warnings, deadline monitoring, store behavior, or execution
  result changes.
- Smoke-helper extraction remains examples/specs-scoped and design-only.
- Research/runtime expansion, production server behavior, cluster placement,
  connectors, LLM/provider behavior, grammar/Rust, and package API promotion
  remain explicitly deferred.

Supervisor verification:

- `git diff --check` passed.
- `ruby examples/run.rb run application/lense_poc` passed.
- `ruby examples/run.rb run contracts/lang_foundation` passed.
- `ruby examples/run.rb smoke` passed with 81 examples.
- `bundle exec rspec packages/igniter-contracts/spec spec/current` passed with
  201 examples.

Supervisor follow-up:

- Updated `examples/README.md` so the active lane list includes the newer
  flagship app, Web mount, agent-native, StepResultPack, and Lang foundation
  examples already present in the runner catalog.
- Open the next track as public entry-surface hygiene: make the top-level
  onboarding path match the accepted enterprise verification story before any
  new feature/API expansion.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` and `[Agent Web / Codex]` define the
   application/Web verification path.
2. `[Agent Contracts / Codex]` defines the contracts/Lang verification path.
3. `[Research Horizon / Codex]` filters the receipt for overclaiming and next
   track recommendation.
4. `[Architect Supervisor / Codex]` reviews whether the verification path is
   strong enough to become the enterprise proof entrypoint.

[Agent Application / Codex]
track: `docs/dev/enterprise-verification-receipt-hardening-track.md`
status: landed
delta: added `docs/guide/enterprise-verification.md` with the flagship
  application verification path for Lense, Chronicle, Scout, and Dispatch.
delta: defined application receipt evidence across success/refusal flow,
  mounted surface marker, `/events` parity, `/report` or `/receipt`, and
  mutation-boundary proof.
delta: linked the verification entrypoint from `docs/guide/README.md` and
  `docs/guide/application-showcase-portfolio.md`; added
  `examples/README.md` discoverability for the flagship checks.
delta: kept manual server mode and smoke-helper discussion explicitly
  non-runtime/non-production.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can add manual-review specifics;
  `[Agent Contracts / Codex]` can add contracts/lang verification details;
  `[Research Horizon / Codex]` can filter for overclaiming.
block: none

[Agent Web / Codex]
track: `docs/dev/enterprise-verification-receipt-hardening-track.md`
status: landed
delta: updated `docs/guide/enterprise-verification.md` with a Web/manual-review
  receipt matrix for Lense, Chronicle, Scout, and Dispatch covering server
  commands, surface markers, success/refusal feedback evidence, `/events`, and
  `/report` or `/receipt` checks.
delta: clarified that browser receipt checks use app-local `data-` attributes
  as inspection seams, not marker DSL or component API.
delta: corrected `docs/guide/application-showcase-portfolio.md` surface
  markers for Chronicle, Scout, and Dispatch to match the actual mounted HTML.
verify: `git diff --check` passed.
ready: `[Agent Contracts / Codex]` can add contracts/lang verification details;
  `[Research Horizon / Codex]` can filter for overclaiming; then
  `[Architect Supervisor / Codex]` can review the enterprise receipt.
block: none

[Agent Contracts / Codex]
track: `docs/dev/enterprise-verification-receipt-hardening-track.md`
status: landed
delta: updated `docs/guide/enterprise-verification.md` with the contracts/lang
  verification path, canonical package/root spec command, focused contracts
  example commands, class DSL, Embed pressure, StepResultPack, Lang foundation,
  and changed-file RuboCop caveat.
delta: updated `examples/README.md` with focused contracts/lang evaluator
  checks.
delta: kept Lang wording explicit: descriptors and metadata manifests are
  declared/report-only, and `type:`, `return_type:`, `deadline:`, and `wcet:`
  do not imply runtime checks, warnings, findings, deadline monitoring, store
  behavior, or `ExecutionResult` changes.
verify: `git diff --check` passed; focused contracts/lang examples passed:
  `contracts/class_pricing`, `contracts/class_callable`,
  `contracts/embed_class_registration`, `contracts/contractable_shadow`,
  `contracts/step_result`, and `contracts/lang_foundation`.
ready: `[Research Horizon / Codex]` can filter for overclaiming; then
  `[Architect Supervisor / Codex]` can review the enterprise receipt.
block: none

[Research Horizon / Codex]
track: `docs/dev/enterprise-verification-receipt-hardening-track.md`
status: landed
delta: reviewed `docs/guide/enterprise-verification.md` for overclaiming and
  added explicit receipt non-goal language.
delta: clarified that the receipt is not certification, security audit,
  compliance review, SLA, or release guarantee.
delta: kept grammar/Rust/Lang runtime semantics, live agents, Semantic
  Gateway, Line-Up runtime, LLM/provider behavior, connectors, cluster
  placement, production server behavior, and package API promotion deferred.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` can review the enterprise receipt.
block: none
