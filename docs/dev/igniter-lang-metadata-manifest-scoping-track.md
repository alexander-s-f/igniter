# Igniter Lang Metadata Manifest Scoping Track

This track scopes the next Igniter-Lang step after the additive foundation pack.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Contracts / Codex]
[Research Horizon / Codex]
```

Inputs:

- [Igniter Lang Foundation Pack Track](./igniter-lang-foundation-pack-track.md)
- [Igniter-Lang Implementation Delta Report](../research-horizon/igniter-lang-implementation-delta-report.md)
- [Igniter-Lang Implementation Strategy](../experts/igniter-lang/igniter-lang-implementation.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting the additive
Igniter-Lang foundation pack.

The next candidate is metadata/report-only language support. This is a scoping
track, not approval to implement runtime semantics.

## Goal

Define the smallest useful metadata manifest slice that can build on
`Igniter::Lang` without changing contract execution.

The result should answer:

- which metadata declarations are safe now
- how metadata appears in `VerificationReport`
- what wording prevents users from assuming runtime enforcement
- whether implementation should proceed next or wait for more pressure

Candidate metadata, if safely scoped:

- `store` declarations as manifest/report only
- `deadline` / `wcet` declarations as budget metadata only
- invariant metadata for existing external invariant suites
- optional `return_type:` reporting only, not enforcement

## Scope

In scope:

- design/scoping only
- report shape proposal for metadata manifests
- API sketch for Ruby DSL usage
- explicit non-enforcement language
- package ownership recommendation
- acceptance criteria for a later implementation track

Out of scope:

- implementing DSL keywords
- changing compiler/runtime behavior
- adding stores, adapters, OLAP handlers, time-machine behavior, warning
  channels, deadline monitoring, unit algebra, Rust, parser, or grammar
- claiming metadata is enforced
- public onboarding docs that imply the language is production-ready

## Task 1: Contracts Metadata Scoping

Owner: `[Agent Contracts / Codex]`

Acceptance:

- Propose the smallest metadata manifest model compatible with current
  contracts/profile/operation APIs.
- Identify which declarations can be represented without runtime behavior and
  which would require compiler/runtime changes.
- Sketch how `VerificationReport` would expose stores, deadlines, WCET,
  invariant metadata, or return-type metadata.
- Recommend whether the next step should be implementation, docs-only, or
  defer.

## Task 2: Research Boundary Scoping

Owner: `[Research Horizon / Codex]`

Acceptance:

- Reconcile the metadata manifest slice with the broader Igniter-Lang research.
- Keep `store`, `deadline`, `olap`, `rule`, `time_machine`, physical units,
  grammar, Rust, and export phases separated by actual semantic depth.
- Provide exact language for "metadata/report-only, not runtime enforcement".
- Identify the first real pressure test that would justify moving from metadata
  to runtime semantics.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- This is about truth in labeling. Metadata declarations are useful only if the
  docs and report shape do not overpromise.
- Do not sneak in runtime behavior because the DSL shape looks convenient.
- Prefer boring manifests over clever language constructs.
- If the scoping cannot make enforcement boundaries obvious, defer the feature.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
git diff --check
```

If code changes unexpectedly, run the relevant specs/smoke/lint for the touched
area.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Contracts / Codex]` scopes metadata manifest support over the current
   Lang foundation.
2. `[Research Horizon / Codex]` scopes the research boundary and non-enforcement
   wording.
3. `[Architect Supervisor / Codex]` decides whether to implement, document, or
   defer metadata manifests.
