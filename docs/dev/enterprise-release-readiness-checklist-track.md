# Enterprise Release Readiness Checklist Track

This track creates a compact release/evaluator readiness checklist for the
current Igniter proof set.

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
- [Enterprise Public Entry Surface Hygiene Track](./enterprise-public-entry-surface-hygiene-track.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting public entry-surface
hygiene.

The next step is release readiness framing, not feature expansion.

## Goal

Give the team and an evaluator one small checklist that answers:

- what must pass before we call the current surface release/evaluation ready
- which commands are required versus optional/manual
- which docs/package entrypoints are part of the gate
- which known caveats are accepted for now
- which claims remain explicitly non-goals

## Scope

In scope:

- one compact guide/dev checklist or release-readiness note
- command gate matrix for examples, contracts specs, and narrow lint policy
- docs/readme entrypoint checks
- known caveat list for legacy/reference docs, full RuboCop archived/research
  offenses, and deferred production/runtime claims
- recommendation for whether smoke-helper extraction is worth a later
  examples/specs-only track

Out of scope:

- runtime/code feature work
- new application showcase
- public smoke-helper API
- browser automation default
- Lang runtime semantics, grammar, Rust, store, OLAP, deadline enforcement
- production server/auth/persistence/connectors/live/cluster deployment claims
- release automation, gem publishing, or version/tag work

## Task 1: Application And Examples Gate

Owner: `[Agent Application / Codex]`

Acceptance:

- Define the application/examples release gate around `ruby examples/run.rb
  smoke` and focused flagship commands.
- Include what the gate proves and what it does not prove.
- Identify any app/example discoverability gaps without implementing new
  application features.

## Task 2: Web Manual Review Gate

Owner: `[Agent Web / Codex]`

Acceptance:

- Define the manual Web review gate for the four flagship apps.
- Keep browser/server mode review-only and non-production.
- Include surface marker, feedback, `/events`, `/report` or `/receipt`, and
  mutation-boundary evidence categories.

## Task 3: Contracts And Lang Gate

Owner: `[Agent Contracts / Codex]`

Acceptance:

- Define contracts/package gate commands and focused examples.
- Preserve the changed-file RuboCop policy and explain the full RuboCop caveat
  without normalizing lint debt as acceptable forever.
- Keep Lang foundation and metadata manifest report-only.

## Task 4: Horizon Risk Filter

Owner: `[Research Horizon / Codex]`

Acceptance:

- Review the checklist for enterprise overclaiming.
- Mark release blockers versus deferred non-goals.
- Recommend next track after checklist: pause for human review, examples/spec
  smoke helper extraction, Embed/SparkCRM pressure, or another narrow
  hardening pass.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- "Release readiness" here means readiness of the current proof set for
  evaluator review, not gem publication or production certification.
- Keep the checklist short enough to use.
- Prefer objective commands and evidence categories over broad maturity prose.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
git diff --check
```

If code changes unexpectedly, run affected specs/smoke/lint.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` defines the application/examples gate.
2. `[Agent Web / Codex]` defines the manual Web review gate.
3. `[Agent Contracts / Codex]` defines contracts/Lang/package gates.
4. `[Research Horizon / Codex]` filters blockers versus deferred non-goals and
   recommends the post-checklist track.
