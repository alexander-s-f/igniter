# Igniter Enterprise Readiness Synthesis Track

This track synthesizes the current public/enterprise readiness state after the
showcase portfolio and Igniter-Lang foundation were made discoverable.

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

- [Application Showcase Portfolio Guide Track](./application-showcase-portfolio-guide-track.md)
- [Igniter Lang Foundation Guide Finalization Track](./igniter-lang-foundation-guide-finalization-track.md)
- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)
- [Igniter Lang Foundation](../guide/igniter-lang-foundation.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting the Lang foundation guide.

The next step is synthesis and prioritization, not another feature by default.

## Goal

Decide what Igniter needs next to feel credible as an enterprise-grade solution.

The result should answer:

- what is now strong enough for public onboarding
- what is still risky or confusing for enterprise evaluators
- whether next work should be release/docs hardening, examples/spec smoke
  helper, Embed/SparkCRM pressure, Contracts/Lang continuation, or another app
- what should remain explicitly deferred

## Scope

In scope:

- compact synthesis only
- review of current guide entrypoints, showcase portfolio, Lang foundation, and
  verification story
- next-track recommendation with clear acceptance criteria
- identification of risks/gaps that block enterprise confidence

Out of scope:

- implementing new runtime features
- adding new DSL keywords
- changing package APIs
- starting parser/Rust/live/cluster/persistence work
- broad documentation rewrite

## Task 1: Application/Web Readiness Synthesis

Owner: `[Agent Application / Codex]` and `[Agent Web / Codex]`

Acceptance:

- Assess whether the four showcase apps and portfolio guide are enough for a
  public application onboarding path.
- Identify any missing proof, docs, smoke, manual review, or mutation-boundary
  language that would confuse enterprise evaluators.
- Recommend whether the next application/web work should be docs hardening,
  smoke-helper design, or no action.

## Task 2: Contracts/Lang Readiness Synthesis

Owner: `[Agent Contracts / Codex]`

Acceptance:

- Assess whether `igniter-contracts`, class DSL, Embed-facing contract pressure,
  and Lang foundation docs form a coherent current contracts story.
- Identify what is safe to present publicly and what remains experimental.
- Recommend whether next contracts work should be docs hardening,
  smoke-helper/support tooling, Embed/SparkCRM follow-up, Lang metadata
  continuation, or no action.

## Task 3: Research Horizon Filter

Owner: `[Research Horizon / Codex]`

Acceptance:

- Review current research/doc horizon for ideas that should influence the next
  track.
- Filter out attractive but premature work such as grammar, Rust, live agents,
  cluster runtime, or production connectors unless current evidence demands it.
- Recommend one high-leverage next track and one explicit non-goal.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- Keep this synthesis compact. It should help choose the next track, not become
  a strategy novel.
- Prefer work that increases trust: reproducibility, onboarding clarity,
  verification, release hygiene, and honest boundaries.
- Do not restart legacy as an onboarding path. Legacy remains reference/private
  context.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
git diff --check
```

If code changes unexpectedly, run affected specs/smoke/lint.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` and `[Agent Web / Codex]` synthesize
   application/web readiness.
2. `[Agent Contracts / Codex]` synthesizes contracts/lang readiness.
3. `[Research Horizon / Codex]` filters the horizon into one next-track
   recommendation.
4. `[Architect Supervisor / Codex]` chooses the next active track.
