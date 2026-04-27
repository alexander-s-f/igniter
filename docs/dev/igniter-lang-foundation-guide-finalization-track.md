# Igniter Lang Foundation Guide Finalization Track

This track finalizes user-facing wording for the accepted Igniter-Lang
foundation and metadata manifest.

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
- [Igniter Lang Metadata Manifest Implementation Track](./igniter-lang-metadata-manifest-implementation-track.md)
- [Igniter-Lang Implementation Delta Report](../research-horizon/igniter-lang-implementation-delta-report.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting the metadata manifest
implementation.

The next step is guide/discoverability finalization, not another feature.

## Goal

Make the accepted Lang foundation easy to discover while preventing
overclaiming.

The result should answer:

- how to require and use the additive Lang foundation
- what the Ruby backend wrapper does
- what descriptors are
- what the metadata manifest reports
- why `return_type`, `deadline`, and `wcet` are declared metadata, not enforced
- what phases remain research/future work

## Scope

In scope:

- user-facing guide note or package README update
- example/catlog wording if needed
- compact dev-doc cross-link if needed
- explicit "declared, not enforced" language

Out of scope:

- new code behavior
- new DSL keywords
- store/invariant/deadline implementation
- runtime semantics, warnings, findings, adapters, parser, grammar, AST, Rust,
  exports
- public claim that Igniter-Lang is a complete language

## Task 1: Contracts Guide Finalization

Owner: `[Agent Contracts / Codex]`

Acceptance:

- Add or update docs so `require "igniter/lang"` is discoverable from the
  contracts-facing docs.
- Explain Ruby backend wrapper, descriptors, `VerificationReport`, and
  `MetadataManifest` in a compact way.
- Include the `examples/contracts/lang_foundation.rb` run command.
- State that metadata manifest fields are report-only.

## Task 2: Research Wording Finalization

Owner: `[Research Horizon / Codex]`

Acceptance:

- Review guide wording for overclaiming.
- Keep grammar/Rust/store/OLAP/time-machine/deadline-runtime phases in research
  or future-work language.
- Ensure public docs do not imply runtime enforcement for `return_type`,
  `deadline`, or `wcet`.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- This is a wording hardening pass. Keep it short.
- The guide should make Lang feel real enough to try and modest enough to
  trust.
- Avoid turning research vocabulary into a product promise.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
git diff --check
```

If code changes, run the relevant specs/smoke/lint for the touched area.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Contracts / Codex]` finalizes contracts-facing Lang docs.
2. `[Research Horizon / Codex]` checks the wording boundary.
3. `[Architect Supervisor / Codex]` decides whether Lang foundation is
   discoverable enough for now.
