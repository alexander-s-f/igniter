# Igniter Lang Metadata Manifest Implementation Track

This track implements the narrow report-only metadata manifest accepted by
[Igniter Lang Metadata Manifest Scoping Track](./igniter-lang-metadata-manifest-scoping-track.md).

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
- [Igniter Lang Metadata Manifest Scoping Track](./igniter-lang-metadata-manifest-scoping-track.md)
- [Igniter-Lang Implementation Delta Report](../research-horizon/igniter-lang-implementation-delta-report.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting metadata manifest
scoping.

Implement only a read-only report manifest over already-declared operation
metadata.

## Goal

Make Lang verification reports show declared metadata without implying runtime
semantics.

The result should answer:

- what descriptors, return types, deadlines, and WCET metadata were declared
- whether the report is explicitly report-only
- whether execution remains unchanged when metadata is present
- whether docs/examples say "declared, not enforced"

## Scope

In scope:

- `Igniter::Lang::MetadataManifest`
- `VerificationReport#metadata_manifest`
- `VerificationReport#to_h` including metadata manifest data
- extraction from existing operation attributes:
  `type:`, `return_type:`, `deadline:`, `wcet:`
- tests proving metadata appears in reports and does not affect execution
- update `examples/contracts/lang_foundation.rb` or add one compact example if
  useful
- no new production dependencies

Out of scope:

- `store` DSL keyword
- `Igniter::Lang.metadata` builder
- invariant metadata integration
- warnings/findings for budget overrun
- runtime deadline monitoring
- store adapters, OLAP handlers, temporal rules, time machine, physical unit
  enforcement, parser, grammar, AST, Rust backend, exports
- changing compiler/runtime execution behavior
- changing `ExecutionResult`

## Task 1: Contracts Implementation

Owner: `[Agent Contracts / Codex]`

Acceptance:

- Add immutable/read-only `Igniter::Lang::MetadataManifest`.
- Extract descriptor declarations from `type:` and declared metadata from
  `return_type:`, `deadline:`, and `wcet:` operation attributes.
- Mark manifest and every requirement-like entry as report-only/not enforced.
- Add `metadata_manifest` to `VerificationReport` without changing existing
  `ok?` behavior.
- Add focused specs proving:
  metadata appears in reports;
  execution output is unchanged;
  invalid compilation findings still drive `ok?`;
  manifest serialization is stable.
- Keep `require "igniter/lang"` additive.

## Task 2: Research Wording Review

Owner: `[Research Horizon / Codex]`

Acceptance:

- Review docs/examples for overclaiming.
- Ensure wording says "declared, not enforced" for return type, deadline, and
  WCET metadata.
- Confirm `store`, `olap`, `rule`, `time_machine`, physical units, grammar,
  Rust, and export phases remain deferred.
- If the wording cannot be made unambiguous, recommend reverting to foundation
  only.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- This is not a language feature launch; it is report plumbing.
- Do not add new DSL keywords in this track.
- Do not turn metadata into warnings, findings, or runtime policy.
- Prefer boring hashes/value objects over clever language surfaces.
- The manifest is useful only if no reader can mistake it for enforcement.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
bundle exec rspec packages/igniter-contracts/spec spec/current
ruby examples/run.rb smoke
bundle exec rubocop packages/igniter-contracts/lib/igniter/lang.rb packages/igniter-contracts/lib/igniter/lang/types.rb packages/igniter-contracts/lib/igniter/lang/backend.rb packages/igniter-contracts/lib/igniter/lang/backends/ruby.rb packages/igniter-contracts/lib/igniter/lang/verification_report.rb packages/igniter-contracts/spec/igniter/lang_spec.rb examples/contracts/lang_foundation.rb examples/catalog.rb
git diff --check
```

If new Lang files are added, include them in the changed-file RuboCop command.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Contracts / Codex]` implements the report-only metadata manifest.
2. `[Research Horizon / Codex]` reviews non-enforcement wording.
3. `[Architect Supervisor / Codex]` reviews additive behavior and truth in
   labeling.

## Handoff Notes

[Agent Contracts / Codex] Task 1 landed for review.

Implemented the narrow report-only metadata manifest without adding DSL
keywords or runtime behavior. Added immutable
`Igniter::Lang::MetadataManifest`, wired
`VerificationReport#metadata_manifest`, and serialize
`metadata_manifest:` through `VerificationReport#to_h`. The manifest extracts
only already-declared operation attributes: `type:` descriptors,
`return_type:`, `deadline:`, and `wcet:`. Requirement-like entries carry
`enforced: false`, and the manifest semantics report
`report_only: true` / `runtime_enforced: false`.

Execution is unchanged: metadata remains operation attributes consumed only by
the report path. No `store` keyword, `Igniter::Lang.metadata` builder,
warnings/findings, deadline monitoring, store adapters, parser/grammar, or
`ExecutionResult` changes were added.

Updated the compact `examples/contracts/lang_foundation.rb` proof to print the
report-only manifest flag.

Verification:

```bash
bundle exec rspec packages/igniter-contracts/spec spec/current
ruby examples/run.rb smoke
bundle exec rubocop packages/igniter-contracts/lib/igniter/lang.rb packages/igniter-contracts/lib/igniter/lang/types.rb packages/igniter-contracts/lib/igniter/lang/metadata_manifest.rb packages/igniter-contracts/lib/igniter/lang/backend.rb packages/igniter-contracts/lib/igniter/lang/backends/ruby.rb packages/igniter-contracts/lib/igniter/lang/verification_report.rb packages/igniter-contracts/spec/igniter/lang_spec.rb examples/contracts/lang_foundation.rb examples/catalog.rb
git diff --check
```

Results: `201 examples, 0 failures`; examples smoke `81 passed, 0 failed`;
changed-file RuboCop no offenses; diff check passed.
