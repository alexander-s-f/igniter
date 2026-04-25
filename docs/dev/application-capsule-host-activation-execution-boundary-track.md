# Application Capsule Host Activation Execution Boundary Track

This track follows the accepted host activation guide consolidation cycle.

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

[Architect Supervisor / Codex] Accepted as the next implementation-boundary
track.

The review chain is now complete through verified activation intent. The next
question is whether Igniter is ready to define a first mutable activation
boundary. This track is a design/boundary track first. It must not implement
activation execution unless a later supervisor decision explicitly narrows and
accepts a safe executable slice.

## Goal

Define the activation execution boundary before any mutation exists:

- which reviewed operations belong to application-owned host activation
- which operations remain host-owned only
- which operations remain web-owned only
- which operations are too risky for v1
- what preconditions, refusal rules, and receipts would be required if a
  future execution slice is accepted

The output should answer: "What would it mean to execute activation safely, and
what must still remain manual or package-owned?"

## Scope

In scope:

- docs/design over the accepted readiness/plan/verification chain
- mapping operation types to possible future owners
- refusal-first preconditions for any future execution boundary
- receipt/report requirements for a future mutable activation slice
- web boundary review for mount-related operations

Out of scope:

- implementing activation execution
- mutating host wiring
- modifying load paths
- loading constants
- registering providers/contracts
- booting apps or providers
- binding mounts
- activating routes
- browser traffic
- contract execution
- project-wide discovery
- cluster placement

## Task 1: Application Execution Boundary Map

Owner: `[Agent Application / Codex]`

Acceptance:

- Draft the smallest public/dev boundary section or track note that maps
  current activation plan operations to ownership:
  `confirm_host_export`, `confirm_host_capability`, `confirm_load_path`,
  `confirm_provider`, `confirm_contract`, `confirm_lifecycle`,
  `acknowledge_manual_actions`, and `review_mount_intent`.
- Separate review-only, possible future application-owned, host-owned, and
  web-owned operations.
- Define refusal-first preconditions for any future execution: verified plan,
  explicit commit, explicit host target, no unresolved blockers/findings, no
  implicit discovery, no ambient constant loading.
- Define the receipt/report shape a future execution would need.
- Do not add runtime code, facades, examples, or mutation.

## Task 2: Web Execution Boundary Map

Owner: `[Agent Web / Codex]`

Acceptance:

- Map `review_mount_intent` to future web-owned/host-owned activation only.
- Confirm application must not bind web mounts, activate routes, inspect screen
  graphs, render, or send browser traffic.
- Define what evidence a future web-owned activation adapter would need before
  it could be proposed.
- Do not add runtime code, route activation, mount binding, rendering, or
  browser traffic.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

No tests are required unless implementation files change, which this track
should avoid.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 as a boundary/design pass only.
2. `[Agent Web / Codex]` performs Task 2 as web ownership review only.
3. Do not add executable activation behavior, host mutation, loading, boot,
   provider/contract registration, mount binding, route activation, browser
   traffic, contract execution, discovery, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-host-activation-execution-boundary-track.md`
Status: landed.
Changed:
- Added public/current docs for the future host activation execution boundary.
- Updated the runtime snapshot with the docs-only execution boundary map.
Accepted:
- No runtime classes, facades, examples, or mutation were added.
- Current activation plan operations are mapped by ownership:
  review-only/host-owned evidence, possible future application-owned work,
  host-owned manual work, and web-owned/host-owned mount activation metadata.
- Risky behaviors are explicitly kept out of the first execution boundary:
  project-wide discovery, automatic constant loading, inferred registration,
  automatic boot, implicit web mount binding, route activation, browser
  traffic, contract execution during activation, and cluster placement.
- Future execution preconditions are refusal-first: valid plan verification,
  explicit commit, explicit host target/adapters, no blockers/findings/manual
  actions, no implicit discovery, and no ambient constant loading.
- Future execution would require transfer-style reports plus a separate
  receipt/audit before activation closure.
- `review_mount_intent` remains web-owned or host-owned metadata; application
  must not bind web mounts, activate routes, render, call Rack, inspect web
  graphs, or send browser traffic.
- No activation execution, host mutation, loading, provider/contract
  registration, app boot, mount binding, route activation, browser traffic,
  contract execution, discovery, or cluster placement was introduced.
Verification:
- `git diff --check` passed.
Needs:
- `[Agent Web / Codex]` can perform Task 2 web-owned activation boundary
  review.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-host-activation-execution-boundary-track.md`
Status: landed.
Changed:
- Added `igniter-web` README wording that maps future web activation to a
  separate explicit adapter proposal rather than an implied application
  execution step.
Accepted:
- `review_mount_intent` remains web-owned or host-owned activation metadata.
- Application must not bind web mounts, activate routes, inspect screen or
  component graphs, render, call Rack, send browser traffic, or discover web
  surfaces.
- A future web-owned activation adapter would need explicit evidence before it
  can be proposed: valid plan verification, caller commit decision, reviewed
  mount-intent operation, original intent metadata, supplied web mount object,
  supplied host/router target, and a dry-run/commit receipt shape.
- No runtime code, route activation, mount binding, rendering, browser traffic,
  or application-to-web dependency was introduced.
Needs:
- `[Architect Supervisor / Codex]` can accept the docs-only activation
  execution boundary map.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the 2026-04-25 cycle.

Accepted:

- The track stayed docs-only and did not introduce activation execution.
- Application-owned, host-owned, web-owned, review-only, and rejected activation
  responsibilities are now separated clearly enough for the next narrow slice.
- `review_mount_intent` remains metadata for future web-owned or host-owned
  activation; application must not bind mounts, activate routes, render, call
  Rack, inspect web graphs, or send browser traffic.
- Future mutable activation still requires a separate supervisor decision,
  explicit commit boundary, explicit host adapters, refusal-first validation,
  and transfer-style receipt/audit.

Still rejected:

- commit mode
- host mutation
- load path modification
- constant loading
- automatic discovery
- provider/contract registration
- boot
- mount binding
- route activation
- rendering, Rack calls, or browser traffic
- contract execution during activation
- cluster placement

Verification:

- `ruby examples/application/capsule_host_activation_plan_verification.rb`
  passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed with 142 examples and 0 failures.
- `bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb`
  passed with 19 examples and 0 failures.
- `git diff --check` passed.

Next:

- Continue through
  [Application Capsule Host Activation Dry-Run Execution Track](./application-capsule-host-activation-dry-run-execution-track.md).
