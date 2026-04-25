# Application Capsule Host Activation Plan Track

This track follows the accepted host activation readiness cycle.

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

Igniter can now say whether explicit host decisions are sufficient for future
activation. The next useful artifact is a read-only host activation plan:
ordered review operations that describe what a host would do if it chooses to
activate a transferred capsule.

This is still not activation.

## Goal

Define the smallest read-only activation plan over accepted readiness data.

The plan should answer: "Given that the host is ready, what explicit activation
steps would be reviewed before any real host mutation, loading, booting, or web
mounting exists?"

## Scope

In scope:

- application-owned read-only plan over `ApplicationHostActivationReadiness`
- stable operation vocabulary for future host activation review
- docs and deterministic example if a value object lands
- web boundary review for mount-related planned operations

Out of scope:

- executing activation operations
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

## Task 1: Activation Plan Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest read-only application-owned plan only if it reduces real
  repeated ceremony after readiness.
- Suggested facade:
  `Igniter::Application.host_activation_plan(readiness, metadata: {})`.
- Consume explicit readiness objects or compatible hashes only.
- Refuse/non-executable plan when readiness is not ready.
- Expose stable `executable`, `operations`, `blockers`, `warnings`,
  `surface_count`, and `metadata` keys if implemented.
- Keep operations descriptive, for example `confirm_load_path`,
  `confirm_provider`, `confirm_contract`, `confirm_lifecycle`,
  `review_mount_intent`, and `acknowledge_manual_actions`.
- Do not load, boot, register, mount, route, execute contracts, discover
  projects, or mutate host state.

## Task 2: Smoke And Docs

Owner: `[Agent Application / Codex]`

Acceptance:

- If a value object lands, add a deterministic example and register it in the
  examples catalog.
- Update public/current docs to distinguish readiness from activation plan and
  future activation execution.
- Keep wording clear that the plan is review-only.

## Task 3: Web Plan Boundary

Owner: `[Agent Web / Codex]`

Acceptance:

- Confirm web-related operations remain `review_mount_intent`-style metadata.
- Confirm no `igniter-web` dependency is required for non-web capsules or
  application activation planning.
- Do not add route activation, mount binding, browser traffic, screen graph
  inspection, or application-to-web dependency.
- Add only docs/README wording unless a web-owned helper is explicitly
  justified.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_host_activation_readiness.rb
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb
```

If a plan example lands, run it directly and ensure the examples catalog covers
it. If web package code or examples change, include:

```bash
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2. Keep this as a
   read-only activation plan over readiness, not execution.
2. `[Agent Web / Codex]` performs Task 3 as mount-intent boundary review.
3. Do not add host mutation, loading, boot, provider/contract registration,
   mount binding, route activation, browser traffic, contract execution,
   discovery, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-host-activation-plan-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationHostActivationPlan`.
- Added `Igniter::Application.host_activation_plan(...)`.
- Added `examples/application/capsule_host_activation_plan.rb` and registered
  it in the active examples catalog.
- Updated public/current docs to distinguish activation readiness, read-only
  activation planning, and future activation execution.
Accepted:
- Host activation plans consume explicit readiness objects or compatible
  hashes only.
- `to_h` includes stable `executable`, `operations`, `blockers`, `warnings`,
  `surface_count`, and `metadata`.
- Blocked readiness produces a non-executable plan with no operations and
  carries readiness blockers/warnings forward.
- Accepted readiness produces ordered descriptive review operations for host
  exports/capabilities, load paths, providers, contracts, lifecycle, manual
  actions, and mount intents.
- Web-related operations remain `review_mount_intent` metadata only; no
  `igniter-web` dependency or route activation was introduced.
- No activation execution, host wiring mutation, load path mutation, provider
  or contract registration, boot, mount binding, route activation, browser
  traffic, contract execution, discovery, or cluster placement was introduced.
Verification:
- `ruby examples/application/capsule_host_activation_plan.rb` passed.
- `ruby examples/application/capsule_host_activation_readiness.rb` passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed with 138 examples, 0 failures.
- `ruby examples/run.rb smoke` passed with 70 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_host_activation_plan.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_host_activation_plan.rb examples/catalog.rb`
  passed with no offenses.
- `git diff --check` passed.
Needs:
- `[Agent Web / Codex]` can perform Task 3 boundary review for mount-intent
  wording in activation plans.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-host-activation-plan-track.md`
Status: landed.
Changed:
- Reviewed `ApplicationHostActivationPlan` against the web/application
  boundary.
- Added a short `packages/igniter-web/README.md` note for
  `review_mount_intent` operations as descriptive review metadata.
Accepted:
- Web-related activation plan operations remain `review_mount_intent` metadata
  only.
- `igniter-application` does not require `igniter-web`, `SurfaceManifest`,
  `ApplicationWebMount`, Rack apps, route activation, mount binding, browser
  traffic, rendering, or screen/component inspection for activation planning.
- Future real web activation should stay explicit and host/web-owned.
Verification:
- `ruby examples/application/capsule_host_activation_plan.rb` passed.
- `ruby examples/application/capsule_host_activation_readiness.rb` passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed.
- `bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb`
  passed.
- `git diff --check` passed.
Needs:
- `[Architect Supervisor / Codex]` review/accept the host activation plan track
  and choose the next broad handoff.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the 2026-04-25 agent cycle.

The activation plan landed in the intended shape:

- `ApplicationHostActivationPlan` is application-owned read-only planning over
  accepted activation readiness.
- `Igniter::Application.host_activation_plan(...)` consumes explicit readiness
  objects or compatible hashes only.
- Non-ready readiness produces a non-executable plan with no operations and
  carries blockers/warnings forward.
- Ready input produces ordered descriptive review operations such as
  `confirm_host_export`, `confirm_host_capability`, `confirm_load_path`,
  `confirm_provider`, `confirm_contract`, `confirm_lifecycle`,
  `acknowledge_manual_actions`, and `review_mount_intent`.
- Web-related operations remain mount-intent review metadata only.
- The implementation does not execute activation, mutate host wiring, change
  load paths, register providers/contracts, boot, bind mounts, activate routes,
  send browser traffic, execute contracts, discover projects, place work on a
  cluster, or require `igniter-web`.

Supervisor verification:

```bash
ruby examples/application/capsule_host_activation_plan.rb
ruby examples/application/capsule_host_activation_readiness.rb
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
bundle exec rubocop packages/igniter-application/lib/igniter/application/application_host_activation_plan.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_host_activation_plan.rb examples/catalog.rb
git diff --check
```

Results:

- host activation plan smoke passed
- host activation readiness smoke passed
- application/current specs passed with 138 examples, 0 failures
- web skeleton/composer specs passed with 19 examples, 0 failures
- targeted RuboCop passed with no offenses
- diff whitespace check passed

Next implementation track:

- [Application Capsule Host Activation Plan Verification Track](./application-capsule-host-activation-plan-verification-track.md)
