# Application Capsule Host Activation Guide Consolidation Track

This track follows the accepted host activation plan verification cycle.

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

The host activation review chain now has readiness, plan, and plan
verification. The next useful move is not execution. It is user-facing
consolidation: make the path from transfer receipt to verified activation plan
easy to follow, and make the stop line before real activation unmistakable.

## Goal

Consolidate the post-transfer host activation review path:

- transfer receipt
- post-transfer host integration review
- host activation readiness
- host activation plan
- host activation plan verification
- explicit stop before activation execution

The output should answer: "What can Igniter review today, and where does real
host/web activation still begin later?"

## Scope

In scope:

- public guide/current-doc wording
- one compact end-to-end activation review example if useful
- examples catalog registration if an example is added
- package README wording for web boundary if needed

Out of scope:

- activation execution
- host mutation
- loading constants
- provider/contract registration
- app boot
- mount binding
- route activation
- browser traffic
- contract execution
- project-wide discovery
- cluster placement

## Task 1: Activation Review Path

Owner: `[Agent Application / Codex]`

Acceptance:

- Update public/current docs so a reader can follow the review path from
  transfer receipt through verified activation plan.
- Distinguish readiness, plan, verification, and future execution.
- Make the stop line explicit: Igniter has reviewed the activation intent, but
  has not activated the host.
- Do not add new runtime classes or facades.

## Task 2: Optional Smoke Path

Owner: `[Agent Application / Codex]`

Acceptance:

- If useful, add one deterministic example that prints compact keys for
  readiness ready, plan executable, verification valid, operation count, and
  finding count.
- Use temp/local data only.
- Register the example in the active examples catalog if added.
- Do not duplicate every earlier transfer example if the existing activation
  plan verification example already serves this role.

## Task 3: Web Stop-Line Review

Owner: `[Agent Web / Codex]`

Acceptance:

- Confirm public wording does not imply web activation.
- Confirm mount intents and `review_mount_intent` remain supplied metadata.
- Do not add route activation, mount binding, browser traffic, rendering,
  screen/component inspection, or application-to-web dependency.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_host_activation_plan_verification.rb
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb
```

If a new example lands, run it directly and ensure the examples catalog covers
it. If web package code or examples change, include:

```bash
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and decides whether Task 2 needs
   a new example or whether the existing verification example is enough.
2. `[Agent Web / Codex]` performs Task 3 as stop-line review.
3. Keep this as consolidation. Do not add activation execution or any host/web
   mutation.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-host-activation-guide-consolidation-track.md`
Status: landed.
Changed:
- Consolidated the public capsule guide host activation review path from
  transfer receipt through plan verification.
- Updated current app structure and runtime snapshot docs with the hard stop
  before execution.
Accepted:
- No new runtime classes, facades, or examples were added.
- The existing `examples/application/capsule_host_activation_plan_verification.rb`
  already serves the compact smoke path for readiness, plan, verification,
  operation count, and finding count.
- The stop line is explicit: verified activation intent is not host
  activation.
- No execution, host mutation, constant loading, provider/contract
  registration, app boot, mount binding, route activation, browser traffic,
  contract execution, discovery, or cluster placement was introduced.
Verification:
- `ruby examples/application/capsule_host_activation_plan_verification.rb`
  passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed with 142 examples, 0 failures.
- `git diff --check` passed.
Needs:
- `[Agent Web / Codex]` can perform Task 3 stop-line review for web activation
  wording.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-host-activation-guide-consolidation-track.md`
Status: landed.
Changed:
- Reviewed the consolidated public/current host activation guide wording from
  the web boundary side.
- No package README or runtime changes were needed; existing `igniter-web`
  wording already states that activation readiness, plan, and verification keep
  web mount intent as supplied metadata only.
Accepted:
- Public wording does not imply web activation.
- Mount intents and `review_mount_intent` remain supplied metadata/review
  operations until a future explicit web-owned activation adapter consumes
  them.
- No route activation, mount binding, browser traffic, rendering,
  screen/component inspection, application-to-web dependency, or executable
  web activation path was introduced.
Needs:
- `[Architect Supervisor / Codex]` can accept the host activation guide
  consolidation stop line.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the 2026-04-25 agent cycle.

The guide consolidation landed in the intended shape:

- The public guide now shows the review path from transfer receipt through
  host activation readiness, activation plan, and activation plan verification.
- No new runtime classes, facades, or examples were added.
- The existing `examples/application/capsule_host_activation_plan_verification.rb`
  is accepted as the compact smoke path for readiness, plan, verification,
  operation count, and finding count.
- The stop line is explicit: valid activation plan verification means
  activation intent was reviewed, not performed.
- Web mount intents and `review_mount_intent` remain supplied metadata/review
  operations until a future explicit web-owned or host-owned activation
  boundary consumes them.
- No execution, host mutation, constant loading, provider/contract
  registration, app boot, mount binding, route activation, browser traffic,
  rendering, screen/component inspection, contract execution, discovery, or
  cluster placement was introduced.

Supervisor verification:

```bash
ruby examples/application/capsule_host_activation_plan_verification.rb
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
git diff --check
```

Results:

- activation plan verification smoke passed
- application/current specs passed with 142 examples, 0 failures
- web skeleton/composer specs passed with 19 examples, 0 failures
- diff whitespace check passed

Next implementation track:

- [Application Capsule Host Activation Execution Boundary Track](./application-capsule-host-activation-execution-boundary-track.md)
