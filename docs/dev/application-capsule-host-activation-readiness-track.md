# Application Capsule Host Activation Readiness Track

This track follows the accepted post-transfer host integration boundary.

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

[Architect Supervisor / Codex] Accepted as the next broad track.

Transfer completion and post-transfer integration review now have clear
boundaries. The next useful artifact is a read-only host activation readiness
surface: a way to ask whether the receiving host has supplied enough explicit
decisions to make a transferred capsule eligible for activation.

This is still not activation. It is a preflight/readiness step before any
future host-owned boot, load, mount, or route work.

## Goal

Define the smallest read-only activation readiness shape over explicit inputs:

- transfer receipt or compatible receipt hash
- handoff/assembly metadata when available
- host-supplied decisions for exports, capabilities, manual wiring,
  load paths, providers, contracts, lifecycle, and optional mounts
- optional supplied web surface metadata as opaque context

The output should answer: "Is the host ready to activate this transferred
capsule, and what is still missing?"

## Scope

In scope:

- read-only activation readiness design, docs, and optional value object
- stable findings/checklist vocabulary if implemented
- public guide/current-doc wording
- deterministic example only if a value object lands
- web boundary review for mount intents and surface metadata

Out of scope:

- automatic activation
- mutating host wiring
- loading constants
- app boot
- provider lifecycle execution
- contract execution
- route activation
- mount binding
- browser traffic
- project-wide discovery
- cluster placement
- private app-specific material

## Task 1: Activation Readiness Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Decide whether this cycle needs a value object or should stay design/docs
  only.
- If implemented, add a read-only application-owned report/facade, for
  example `ApplicationHostActivationReadiness` and
  `Igniter::Application.host_activation_readiness(...)`.
- Consume only explicit value objects or compatible hashes. Do not discover
  project state or inspect directories beyond supplied artifact data.
- Report stable `ready`, `blockers`, `warnings`, `decisions`, `manual_actions`,
  `mount_intents`, `surface_count`, and `metadata` if a value object lands.
- Treat an incomplete/invalid transfer receipt as a blocker.
- Treat unresolved required host exports/capabilities/manual wiring as
  blockers or warnings according to explicit host decisions.
- Do not mutate, boot, load, mount, route, execute contracts, activate web, or
  place work on a cluster.

## Task 2: Human Path And Example

Owner: `[Agent Application / Codex]`

Acceptance:

- Update guide/current docs so the user sees the difference between transfer
  receipt, post-transfer integration review, activation readiness, and future
  activation.
- If a value object lands, add a deterministic smoke example and register it in
  the examples catalog.
- Keep the example over temp/local data and explicit host decisions.
- Do not imply that readiness performs activation.

## Task 3: Web Readiness Boundary

Owner: `[Agent Web / Codex]`

Acceptance:

- Confirm web-related readiness remains about supplied mount intents and
  surface metadata only.
- Confirm readiness does not require `igniter-web` for non-web capsules.
- Confirm no route activation, mount binding, browser traffic, screen graph
  inspection, or application-to-web dependency is introduced.
- If wording is needed, update only docs/README text unless a web-owned helper
  is explicitly justified.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_end_to_end.rb
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb
```

If a readiness example lands, run it directly and ensure
`spec/current/example_scripts_spec.rb` covers it through the catalog. If web
package code or examples change, include:

```bash
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2. Prefer a narrow
   read-only readiness report only if it reduces real repeated ceremony beyond
   the accepted docs/checklist boundary.
2. `[Agent Web / Codex]` performs Task 3 as boundary review for optional web
   readiness metadata.
3. Keep this as activation readiness only. Do not add activation, host wiring
   mutation, constant loading, app boot, route mounting, browser traffic,
   contract execution, discovery, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-host-activation-readiness-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationHostActivationReadiness`.
- Added `Igniter::Application.host_activation_readiness(...)`.
- Added `examples/application/capsule_host_activation_readiness.rb` and
  registered it in the active examples catalog.
- Updated public/current docs to position host activation readiness as a
  read-only preflight after transfer receipt and post-transfer integration
  review.
Accepted:
- Host activation readiness consumes explicit transfer receipts, optional
  handoff manifests, and host-supplied decisions or compatible hashes.
- `to_h` includes stable `ready`, `blockers`, `warnings`, `decisions`,
  `manual_actions`, `mount_intents`, `surface_count`, and `metadata`.
- Incomplete transfer receipts are blockers.
- Missing required host export decisions, missing required host capabilities,
  and unresolved manual actions are blockers.
- Missing load path, provider, contract, lifecycle, and optional mount
  decisions are warnings.
- Web readiness remains supplied/opaque metadata plus optional mount-intent
  review; no `igniter-web` dependency or route activation was introduced.
- No activation, host wiring mutation, constant loading, app boot, provider
  lifecycle execution, mount binding, route activation, browser traffic,
  contract execution, discovery, or cluster placement was introduced.
Verification:
- `ruby examples/application/capsule_host_activation_readiness.rb` passed.
- `ruby examples/application/capsule_transfer_end_to_end.rb` passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed with 135 examples, 0 failures.
- `ruby examples/run.rb smoke` passed with 69 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_host_activation_readiness.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_host_activation_readiness.rb examples/catalog.rb`
  passed with no offenses.
Needs:
- `[Agent Web / Codex]` can perform Task 3 boundary review for optional web
  readiness metadata and mount-intent wording.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-host-activation-readiness-track.md`
Status: landed.
Changed:
- Reviewed `ApplicationHostActivationReadiness` against the web/application
  boundary.
- Added a short `packages/igniter-web/README.md` note for host activation
  readiness as read-only preflight over reviewed web mount decisions.
Accepted:
- Web-related readiness remains supplied mount-intent and surface metadata
  review only.
- `igniter-application` does not require `igniter-web`, `SurfaceManifest`, Rack
  apps, route activation, mount binding, browser traffic, or screen/component
  inspection for activation readiness.
- No web-owned helper is needed yet; future real web activation should stay
  web-owned or host-owned.
Verification:
- `ruby examples/application/capsule_host_activation_readiness.rb` passed.
- `ruby examples/application/capsule_transfer_end_to_end.rb` passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed.
- `bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb`
  passed.
- `git diff --check` passed.
Needs:
- `[Architect Supervisor / Codex]` review/accept the host activation readiness
  track and choose the next broad handoff.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the 2026-04-25 agent cycle.

The readiness slice landed in the right shape:

- `ApplicationHostActivationReadiness` is application-owned read-only
  preflight over explicit transfer receipt, optional handoff manifest, and
  host-supplied decisions.
- `Igniter::Application.host_activation_readiness(...)` does not activate
  anything; it only reports readiness, blockers, warnings, decisions, manual
  actions, mount intents, surface count, and metadata.
- Incomplete receipts, missing required host exports/capabilities, and
  unresolved manual actions are blockers.
- Missing load path, provider, contract, lifecycle, and optional mount
  decisions are warnings.
- Web readiness remains supplied mount-intent/surface metadata review only.
- No host wiring mutation, constant loading, app boot, provider lifecycle
  execution, contract execution, mount binding, route activation, browser
  traffic, discovery, cluster placement, or `igniter-web` dependency was
  introduced.

Supervisor verification:

```bash
ruby examples/application/capsule_host_activation_readiness.rb
ruby examples/application/capsule_transfer_end_to_end.rb
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
bundle exec rubocop packages/igniter-application/lib/igniter/application/application_host_activation_readiness.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_host_activation_readiness.rb examples/catalog.rb
```

Results:

- host activation readiness smoke passed
- end-to-end transfer smoke passed
- application/current specs passed with 135 examples, 0 failures
- web skeleton/composer specs passed with 19 examples, 0 failures
- targeted RuboCop passed with no offenses

Next implementation track:

- [Application Capsule Host Activation Plan Track](./application-capsule-host-activation-plan-track.md)
