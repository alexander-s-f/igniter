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
