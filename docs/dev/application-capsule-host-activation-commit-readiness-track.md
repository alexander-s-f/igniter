# Application Capsule Host Activation Commit Readiness Track

This track follows the accepted dry-run-only host activation execution report.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

## Decision

[Architect Supervisor / Codex] Accepted as the next activation track.

Do not implement activation commit yet. The next safe step is a read-only
commit-readiness gate over explicit dry-run evidence and explicit host/web
adapter evidence.

## Goal

Answer whether a future activation commit track may be proposed.

The result should make clear:

- dry-run evidence is present and executable
- refusals are empty
- application-owned operations have an explicit host target
- skipped host-owned/manual/web-owned items are accounted for
- future commit adapters are supplied explicitly, not discovered
- no mutation has happened

## Scope

In scope:

- a small read-only readiness value object or facade, if implementation is
  justified by the existing activation chain
- explicit input from `ApplicationHostActivationDryRunResult` or a compatible
  dry-run hash
- optional explicit adapter evidence supplied by the caller
- stable serializable keys such as `ready`, `commit_allowed`, `dry_run`,
  `committed`, `blockers`, `warnings`, `required_adapters`,
  `provided_adapters`, `would_apply_count`, `skipped_count`, and `metadata`
- refusal/blocker reporting for missing or invalid dry-run evidence

Out of scope:

- commit mode
- host mutation
- load path mutation
- constant loading
- automatic discovery
- provider/contract registration
- boot
- mount binding
- route activation
- rendering, Rack calls, or browser traffic
- contract execution during activation
- cluster placement

## Task 1: Application Commit Readiness

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest read-only readiness API that consumes explicit dry-run
  evidence.
- Keep `commit_allowed` descriptive only; do not expose or call commit mode.
- Require explicit adapter evidence for future application-owned activation
  work if readiness is marked true.
- Preserve skipped host-owned/manual/web-owned operations as accountability
  evidence.
- Add compact spec/example coverage if runtime code changes.

## Task 2: Web Adapter Evidence Boundary

Owner: `[Agent Web / Codex]`

Acceptance:

- Define only the evidence a future web mount adapter would need.
- Keep `review_mount_intent` outside application-owned commit readiness unless
  represented as supplied web/host evidence.
- Do not add web activation runtime, route binding, rendering, Rack calls,
  browser traffic, screen/component graph inspection, or application-to-web
  dependency.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_host_activation_dry_run.rb
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb
git diff --check
```

If Ruby implementation files change:

```bash
rake rubocop
```

If `packages/igniter-web` changes:

```bash
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 as read-only commit readiness.
2. `[Agent Web / Codex]` performs Task 2 only if web adapter evidence wording
   is needed.
3. Do not add activation commit, mutation, loading, discovery, registration,
   boot, mount binding, route activation, rendering, browser traffic, contract
   execution, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-host-activation-commit-readiness-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationHostActivationCommitReadiness`.
- Added `Igniter::Application.host_activation_commit_readiness(...)`.
- Added `examples/application/capsule_host_activation_commit_readiness.rb`
  and registered it in the active examples catalog.
- Updated public/current docs to describe commit-readiness as a read-only gate.
Accepted:
- Commit readiness consumes explicit dry-run objects or compatible hashes only.
- `to_h` includes stable `ready`, `commit_allowed`, `dry_run`, `committed`,
  `blockers`, `warnings`, `required_adapters`, `provided_adapters`,
  `would_apply_count`, `skipped_count`, and `metadata`.
- `commit_allowed` is descriptive only and does not expose commit mode.
- Readiness requires executable dry-run evidence with no refusals and explicit
  adapter evidence for application-owned work, host-owned evidence, manual
  actions, and web/host-owned mount metadata when present.
- Missing or invalid dry-run evidence, committed evidence, dry-run refusals,
  non-executable dry-runs, and missing adapter evidence are blockers.
- No activation commit, host mutation, loading, discovery,
  provider/contract registration, app boot, mount binding, route activation,
  rendering, Rack/browser traffic, contract execution, or cluster placement was
  introduced.
Verification:
- `ruby examples/application/capsule_host_activation_commit_readiness.rb`
  passed.
- `ruby examples/application/capsule_host_activation_dry_run.rb` passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed with 148 examples, 0 failures.
- `ruby examples/run.rb smoke` passed with 73 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_host_activation_commit_readiness.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_host_activation_commit_readiness.rb examples/catalog.rb`
  passed with no offenses.
- `rake rubocop` passed with 465 files inspected and no offenses.
- `git diff --check` passed.
Needs:
- `[Agent Web / Codex]` can review web adapter evidence wording for
  `review_mount_intent`.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-host-activation-commit-readiness-track.md`
Status: landed.
Changed:
- Reviewed `ApplicationHostActivationCommitReadiness` for
  `review_mount_intent` and web adapter evidence boundaries.
- Added `igniter-web` README wording that `web_mount_adapter_evidence` is
  explicit acknowledgement/future adapter evidence, not a mount/router/Rack
  adapter instance.
Accepted:
- `review_mount_intent` stays outside application-owned commit readiness
  unless represented as supplied web/host evidence.
- Commit readiness compares supplied adapter evidence only and does not
  discover, instantiate, bind, activate, render, call Rack, inspect
  screen/component graphs, or send browser traffic.
- No web activation runtime, route binding, rendering, Rack calls, browser
  traffic, screen/component graph inspection, or application-to-web dependency
  was introduced.
Needs:
- `[Architect Supervisor / Codex]` can accept the commit-readiness gate.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the 2026-04-25 cycle.

Accepted:

- `ApplicationHostActivationCommitReadiness` is accepted as a read-only gate
  over explicit dry-run evidence and supplied adapter evidence.
- `Igniter::Application.host_activation_commit_readiness(...)` is accepted as
  the public application facade.
- The report is serializable and includes `ready`, `commit_allowed`, dry-run
  and committed flags, blockers, warnings, required/provided adapters,
  operation counts, and metadata.
- `commit_allowed` is descriptive only. It does not expose or perform commit.
- Web mount adapter evidence remains acknowledgement/future-adapter evidence,
  not a live mount/router/Rack adapter.

Supervisor fix:

- Renamed the internal constructor from `ApplicationHostActivationCommitReadiness.inspect`
  to `.build` so the class does not override Ruby's normal `inspect`.

Still rejected:

- activation commit
- host mutation
- loading or discovery
- provider/contract registration
- app boot
- mount binding
- route activation
- rendering, Rack calls, or browser traffic as part of activation
- contract execution during activation
- cluster placement

Verification:

- `ruby examples/application/capsule_host_activation_commit_readiness.rb`
  passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed with 148 examples and 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_host_activation_commit_readiness.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_host_activation_commit_readiness.rb examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.

Next:

- Pause host activation expansion and continue through
  [Application Web Interactive POC Track](./application-web-interactive-poc-track.md).
