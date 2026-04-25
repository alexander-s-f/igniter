# Application Capsule Host Activation Dry-Run Execution Track

This track follows the accepted host activation execution boundary map.

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

[Architect Supervisor / Codex] Accepted as the next narrow activation track.

The boundary map is useful enough to test as a dry-run execution report, but
Igniter is still not ready for host mutation. This track may add executable
read-only/dry-run behavior only. It must not add commit mode.

## Goal

Produce a refusal-first dry-run result over explicit, already verified host
activation plan data.

The result should answer:

- what would be considered applyable by application-owned activation logic
- what would remain host-owned/manual
- what would remain web-owned/host-owned mount metadata
- what would be refused before any future commit boundary

## Scope

In scope:

- a small application-owned dry-run value object or facade, if implementation
  is justified by the existing code shape
- explicit input from `ApplicationHostActivationPlanVerification` or equivalent
  verified plan data
- stable serializable keys such as `dry_run`, `committed`, `executable`,
  `would_apply`, `skipped`, `refusals`, `warnings`, `surface_count`, and
  `metadata`
- refusal when verification is invalid, plan is not executable, blockers or
  unresolved findings exist, or explicit host adapters are missing
- documentation and smoke coverage for the accepted dry-run path

Out of scope:

- commit mode
- host mutation
- modifying load paths
- loading constants
- automatic discovery
- registering providers or contracts
- booting apps or providers
- binding web mounts
- activating routes
- rendering, Rack calls, or browser traffic
- contract execution during activation
- cluster placement

## Task 1: Application Dry-Run Report

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest read-only/dry-run API that fits the existing application
  capsule activation chain.
- Require explicit verified activation plan data; do not infer project state.
- Return a serializable report that separates `would_apply`, `skipped`,
  `refusals`, and `warnings`.
- Set `dry_run: true` and `committed: false`; do not expose a commit option.
- Refuse unsafe inputs rather than degrading into implicit discovery.
- Add or update a compact example/spec if runtime code changes.

## Task 2: Web Boundary Review

Owner: `[Agent Web / Codex]`

Acceptance:

- Review the dry-run report shape for `review_mount_intent`.
- Keep mount activation as web-owned or host-owned future work.
- If wording is needed, update package/guide docs only.
- Do not add web runtime activation, route binding, rendering, Rack calls,
  browser traffic, or an application-to-web dependency.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_host_activation_plan_verification.rb
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb
git diff --check
```

If `packages/igniter-web` changes:

```bash
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

If Ruby implementation files change:

```bash
rake rubocop
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 as dry-run-only activation
   execution reporting.
2. `[Agent Web / Codex]` performs Task 2 only if the dry-run report touches
   `review_mount_intent` wording.
3. Do not add commit mode, mutation, loading, discovery, provider/contract
   registration, app boot, mount binding, route activation, rendering, browser
   traffic, contract execution, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-host-activation-dry-run-execution-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationHostActivationDryRunResult`.
- Added `Igniter::Application.dry_run_host_activation(...)`.
- Added `examples/application/capsule_host_activation_dry_run.rb` and
  registered it in the active examples catalog.
- Updated public/current docs to describe dry-run-only activation reporting.
Accepted:
- Dry-run consumes explicit activation plan verification objects or compatible
  hashes only.
- `to_h` includes stable `dry_run`, `committed`, `executable`, `would_apply`,
  `skipped`, `refusals`, `warnings`, `surface_count`, and `metadata`.
- The report is always `dry_run: true` and `committed: false`; no commit option
  exists.
- Application-owned operations become `would_apply` only with an explicit
  `host_target`.
- Host-owned evidence, manual actions, and `review_mount_intent` remain
  skipped review data for host/web-owned future work.
- Invalid verification, non-executable plans, missing host targets, and
  unsupported operations are refusal-first.
- No mutation, loading, discovery, provider/contract registration, app boot,
  mount binding, route activation, rendering, Rack/browser traffic, contract
  execution, or cluster placement was introduced.
Verification:
- `ruby examples/application/capsule_host_activation_dry_run.rb` passed.
- `ruby examples/application/capsule_host_activation_plan_verification.rb`
  passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed with 145 examples, 0 failures.
- `ruby examples/run.rb smoke` passed with 72 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_host_activation_dry_run_result.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_host_activation_dry_run.rb examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.
Needs:
- `[Agent Web / Codex]` can review the dry-run report shape for
  `review_mount_intent` boundary wording.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-host-activation-dry-run-execution-track.md`
Status: landed.
Changed:
- Reviewed `ApplicationHostActivationDryRunResult` for the
  `review_mount_intent` boundary.
- Added `igniter-web` README wording that dry-run activation reporting keeps
  mount intent as skipped evidence for a future web/host-owned adapter.
Accepted:
- `review_mount_intent` is skipped with a web/host-owned mount reason and does
  not enter `would_apply`.
- The dry-run report remains `dry_run: true`, `committed: false`, and has no
  commit path for web mount activation.
- No web runtime activation, route binding, rendering, Rack calls, browser
  traffic, screen/component inspection, or application-to-web dependency was
  introduced.
Needs:
- `[Architect Supervisor / Codex]` can accept the dry-run host activation
  execution track.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the 2026-04-25 cycle.

Accepted:

- `ApplicationHostActivationDryRunResult` is accepted as the first
  executable-adjacent activation artifact.
- The API consumes explicit verification objects or compatible hashes.
- The report is serializable and includes `dry_run`, `committed`,
  `executable`, `would_apply`, `skipped`, `refusals`, `warnings`,
  `surface_count`, and `metadata`.
- The report is always `dry_run: true` and `committed: false`.
- Application-owned operations move to `would_apply` only when an explicit host
  target is supplied.
- Host-owned evidence, manual actions, and `review_mount_intent` remain skipped
  review evidence for host/web-owned future work.

Still rejected:

- commit mode
- host mutation
- loading or discovery
- provider/contract registration
- app boot
- mount binding
- route activation
- rendering, Rack calls, or browser traffic
- contract execution during activation
- cluster placement

Verification:

- `ruby examples/application/capsule_host_activation_dry_run.rb` passed.
- `ruby examples/application/capsule_host_activation_plan_verification.rb`
  passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed with 145 examples and 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_host_activation_dry_run_result.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_host_activation_dry_run.rb examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.

Next:

- Continue through
  [Application Capsule Host Activation Commit Readiness Track](./application-capsule-host-activation-commit-readiness-track.md).
