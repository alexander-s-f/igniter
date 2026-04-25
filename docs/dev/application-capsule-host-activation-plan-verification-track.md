# Application Capsule Host Activation Plan Verification Track

This track follows the accepted host activation plan cycle.

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

[Architect Supervisor / Codex] Accepted as the next implementation track.

Igniter now has read-only readiness and a read-only activation plan. Before any
future execution boundary is considered, the next useful artifact is read-only
verification of the activation plan itself: does the plan faithfully represent
accepted readiness, and is it still only descriptive review work?

This is still not activation execution.

## Goal

Define the smallest read-only activation plan verification report.

It should answer: "Is this activation plan internally consistent, executable
only when readiness was ready, and limited to accepted descriptive operation
types?"

## Scope

In scope:

- application-owned read-only verification over activation plan data
- stable findings for invalid/non-descriptive operations
- deterministic example if a value object lands
- docs/current wording if needed
- web boundary review for `review_mount_intent`

Out of scope:

- executing plan operations
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

## Task 1: Plan Verification Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest read-only application-owned verification only if it reduces
  real repeated ceremony before future execution.
- Suggested facade:
  `Igniter::Application.verify_host_activation_plan(plan, metadata: {})`.
- Consume explicit activation plan objects or compatible hashes only.
- Expose stable `valid`, `executable`, `verified`, `findings`,
  `operation_count`, `surface_count`, and `metadata` keys if implemented.
- Verify only the supplied plan data:
  - executable plans have at least one reviewed operation unless the operation
    list is explicitly empty by policy
  - non-executable plans carry blockers and no operations
  - operation types are from the accepted descriptive vocabulary
  - operations have review status and do not claim applied/executed state
  - web-related operations are `review_mount_intent` metadata only
- Do not inspect project directories or host runtime state.
- Do not execute, mutate, load, boot, register, mount, route, execute
  contracts, activate web, or place work on a cluster.

## Task 2: Smoke And Docs

Owner: `[Agent Application / Codex]`

Acceptance:

- If verification lands, add a deterministic smoke example and register it in
  the examples catalog.
- Update guide/current docs to distinguish activation plan from plan
  verification and future activation execution.
- Keep wording clear that verification reads supplied plan data only.

## Task 3: Web Verification Boundary

Owner: `[Agent Web / Codex]`

Acceptance:

- Confirm verification treats `review_mount_intent` as metadata only.
- Confirm no `igniter-web` dependency is required.
- Do not add route activation, mount binding, browser traffic, screen graph
  inspection, or application-to-web dependency.
- Add only docs/README wording unless a web-owned helper is explicitly
  justified.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_host_activation_plan.rb
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb
```

If a verification example lands, run it directly and ensure the examples
catalog covers it. If web package code or examples change, include:

```bash
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2. Keep this as
   verification of supplied activation plan data, not activation.
2. `[Agent Web / Codex]` performs Task 3 as `review_mount_intent` boundary
   review.
3. Do not add execution, host mutation, loading, boot, provider/contract
   registration, mount binding, route activation, browser traffic, contract
   execution, discovery, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-host-activation-plan-verification-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationHostActivationPlanVerification`.
- Added `Igniter::Application.verify_host_activation_plan(...)`.
- Added `examples/application/capsule_host_activation_plan_verification.rb`
  and registered it in the active examples catalog.
- Updated public/current docs to distinguish activation plan verification from
  activation planning and future activation execution.
Accepted:
- Verification consumes explicit activation plan objects or compatible hashes
  only.
- `to_h` includes stable `valid`, `executable`, `verified`, `findings`,
  `operation_count`, `surface_count`, and `metadata`.
- Executable plans must contain review operations unless explicitly allowed by
  supplied policy/metadata.
- Non-executable plans are valid only when blockers explain the refusal and no
  operations are present.
- Operation types are limited to the accepted descriptive activation-review
  vocabulary and must remain `status: :review_required`.
- Web-related verification treats `review_mount_intent` as supplied intent
  metadata only; no `igniter-web` dependency or route activation was
  introduced.
- No activation execution, host mutation, loading, provider/contract
  registration, boot, mount binding, route activation, browser traffic,
  contract execution, discovery, or cluster placement was introduced.
Verification:
- `ruby examples/application/capsule_host_activation_plan_verification.rb`
  passed.
- `ruby examples/application/capsule_host_activation_plan.rb` passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed with 142 examples, 0 failures.
- `ruby examples/run.rb smoke` passed with 71 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_host_activation_plan_verification.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_host_activation_plan_verification.rb examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.
Needs:
- `[Agent Web / Codex]` can perform Task 3 boundary review for
  `review_mount_intent` verification wording.
