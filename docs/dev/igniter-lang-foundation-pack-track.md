# Igniter Lang Foundation Pack Track

This track graduates the narrowest useful part of the Igniter-Lang research
into a bounded development track.

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

- [Igniter-Lang Implementation Delta Report](../research-horizon/igniter-lang-implementation-delta-report.md)
- [Igniter-Lang Implementation Strategy](../experts/igniter-lang/igniter-lang-implementation.md)

## Decision

[Architect Supervisor / Codex] Accepted Research Horizon's filter:

```text
Ruby DSL first. Grammar later.
```

The expert implementation document is valuable as a horizon map, but only the
Foundation Pack slice is accepted for development now.

Accepted first slice:

- `Igniter::Lang` namespace
- `Igniter::Lang::Backends::Ruby` wrapper over current contracts APIs
- immutable type descriptors such as `History`, `BiHistory`, `OLAPPoint`, and
  `Forecast`
- read-only `VerificationReport`
- docs/examples proving current contracts can compile/execute through the Lang
  wrapper

Rejected/deferred for this track:

- parser, `.il` files, grammar, AST front-end
- Rust backend, certified export, AADL/TLA+/Coq export
- real store runtime, OLAP runtime, temporal rules, time machine, forecasts
- physical unit algebra enforcement
- deadline runtime monitoring, warning channel changes, WCET enforcement
- changing existing contract execution semantics
- new production dependencies

## Goal

Create an additive language foundation that gives Igniter-Lang a real Ruby DSL
reference surface without committing to new runtime semantics.

The result should answer:

- can `require "igniter/lang"` load without changing existing contracts?
- can a Ruby backend wrapper compile, execute, and verify using current
  `Igniter::Contracts` APIs?
- can type descriptors survive as operation metadata?
- can a verification report be inspected and serialized?
- can docs explain which features are metadata/report-only versus real runtime
  semantics?

## Scope

In scope:

- additive package code in the contracts/lang area chosen by
  `[Agent Contracts / Codex]`
- tests for wrapper delegation, descriptors, report serialization, and
  metadata preservation
- one compact example or guide note if useful
- no dependency additions

Out of scope:

- modifying existing contract execution behavior
- changing `ExecutionResult` shape
- adding warning channels
- adding stores, OLAP handlers, temporal rules, unit algebra, deadline runtime,
  or backend export behavior
- parser/grammar work
- any claim that metadata declarations are enforced semantics

## Task 1: Contracts Foundation

Owner: `[Agent Contracts / Codex]`

Status: Landed; awaiting `[Architect Supervisor / Codex]` review.

Acceptance:

- Add `require "igniter/lang"` as an additive entrypoint.
- Implement `Igniter::Lang::Backends::Ruby` as a thin wrapper over current
  contracts compile/execute/diagnose or verification APIs.
- Implement immutable type descriptors for `History`, `BiHistory`, `OLAPPoint`,
  and `Forecast`, with a small inspectable/serializable shape.
- Implement a read-only `VerificationReport` shape that can be built from the
  Ruby backend wrapper without changing runtime execution.
- Prove descriptors can be used in operation metadata, for example `type:`.
- Add focused specs/examples; existing contract specs must pass unchanged.

## Task 2: Research Filter And Docs

Owner: `[Research Horizon / Codex]`

Acceptance:

- Add a compact research handoff or guide note that explains the accepted
  Foundation Pack boundary.
- Mark `store`, `invariant metadata`, `deadline`, `wcet`, `olap`,
  `time_machine`, physical units, Rust, and grammar as later phases.
- Make the docs explicit that Foundation Pack features are reference DSL,
  descriptors, wrappers, and reports, not new runtime semantics.
- Keep the grammar friction log in research, not in public onboarding docs.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- This is a foundation track, not a language launch.
- The code should feel boring and additive. If a change needs compiler/runtime
  behavior changes, it belongs to a later phase.
- Prefer current pack/profile/contracts APIs over inventing an AST.
- The first proof should make future language work safer, not make current
  applications more complex.
- Do not let the expert document's later phases leak into implementation.

## Verification Gate

Before supervisor acceptance, run at minimum:

```bash
bundle exec rspec spec/igniter
ruby examples/run.rb smoke
bundle exec rubocop
git diff --check
```

If the implementation scope stays inside `packages/igniter-contracts`, include
any package-local specs or examples the agent adds.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Contracts / Codex]` implements or scopes the additive Lang
   foundation.
2. `[Research Horizon / Codex]` provides the narrowed research boundary and
   documentation guardrails.
3. `[Architect Supervisor / Codex]` reviews whether the foundation is truly
   additive and whether metadata/report-only language is clear.

## Handoff Notes

[Agent Contracts / Codex] Task 1 landed as an additive `igniter-contracts`
foundation. Added `require "igniter/lang"`, `Igniter::Lang::Backends::Ruby`
as a thin wrapper over current contracts compile/execute/diagnose/verify
surfaces, immutable descriptors for `History`, `BiHistory`, `OLAPPoint`, and
`Forecast`, and a read-only `VerificationReport` that serializes descriptor
metadata and current compilation findings. Added
`examples/contracts/lang_foundation.rb` as the compact smoke example. No
parser, grammar, runtime semantic changes, stores, OLAP runtime, warning
channel, deadline monitoring, or dependencies were added.

Verification:

```bash
bundle exec rspec packages/igniter-contracts/spec spec/current
ruby examples/run.rb smoke
bundle exec rubocop packages/igniter-contracts/lib/igniter/lang.rb packages/igniter-contracts/lib/igniter/lang/types.rb packages/igniter-contracts/lib/igniter/lang/backend.rb packages/igniter-contracts/lib/igniter/lang/backends/ruby.rb packages/igniter-contracts/lib/igniter/lang/verification_report.rb packages/igniter-contracts/spec/igniter/lang_spec.rb examples/contracts/lang_foundation.rb examples/catalog.rb
git diff --check
```

Results: `199 examples, 0 failures`; examples smoke `81 passed, 0 failed`;
changed-file RuboCop no offenses; diff check passed.

Gate caveat: the track's literal `bundle exec rspec spec/igniter` command does
not map to the current repository layout because `spec/igniter` no longer
exists; `spec/current` is the current top-level active spec scope. Full
`bundle exec rubocop` still reports pre-existing archived/research offenses, so
the changed-file lint scope was used for this slice.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted.

Decision:

- The Igniter-Lang foundation pack is accepted as additive.
- `require "igniter/lang"` loads a narrow Lang namespace without changing
  existing contract execution.
- `Igniter::Lang::Backends::Ruby` correctly acts as a wrapper over current
  contracts APIs rather than a new backend/runtime.
- `History`, `BiHistory`, `OLAPPoint`, and `Forecast` are accepted as immutable
  definition-time descriptors.
- `VerificationReport` is accepted as a read-only report over current
  compilation/artifact data.
- `examples/contracts/lang_foundation.rb` is accepted as the compact smoke
  proof.

Rejected/deferred remain unchanged:

- parser, `.il`, grammar, AST front-end
- Rust backend or certified export
- store/OLAP/time-machine runtime
- physical unit algebra enforcement
- deadline runtime monitoring, warning channels, WCET enforcement
- changes to current execution semantics

Supervisor verification:

```bash
bundle exec rspec packages/igniter-contracts/spec spec/current
ruby examples/run.rb smoke
bundle exec rubocop packages/igniter-contracts/lib/igniter/lang.rb packages/igniter-contracts/lib/igniter/lang/types.rb packages/igniter-contracts/lib/igniter/lang/backend.rb packages/igniter-contracts/lib/igniter/lang/backends/ruby.rb packages/igniter-contracts/lib/igniter/lang/verification_report.rb packages/igniter-contracts/spec/igniter/lang_spec.rb examples/contracts/lang_foundation.rb examples/catalog.rb
git diff --check
```

Result:

- RSpec passed with 199 examples and 0 failures.
- Examples smoke passed with 81 examples and 0 failures.
- Changed-file RuboCop passed with no offenses.
- `git diff --check` passed.

Note:

- The track's original `bundle exec rspec spec/igniter` gate is outdated for
  the current repository layout; `spec/current` is the active top-level scope.
- Full `bundle exec rubocop` still includes pre-existing archived/research
  offenses, so changed-file RuboCop is the practical gate for this slice.

Next:

- Open [Igniter Lang Metadata Manifest Scoping Track](./igniter-lang-metadata-manifest-scoping-track.md).
