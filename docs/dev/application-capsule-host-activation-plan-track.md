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
