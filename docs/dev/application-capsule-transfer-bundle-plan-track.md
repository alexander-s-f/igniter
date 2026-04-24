# Application Capsule Transfer Bundle Plan Track

This track follows the accepted capsule transfer readiness cycle.

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

Igniter now has a complete read-only review chain for portable capsules:

- `ApplicationHandoffManifest`
- `ApplicationTransferInventory`
- `ApplicationTransferReadiness`

The next step is not a package writer. The next step is a read-only transfer
bundle plan: a serializable plan for what a future bundle/package operation
would include, exclude, and require before it is allowed to run.

This keeps one more inspection boundary between "ready" and "mutate the
filesystem".

## Goal

Design and land the smallest read-only transfer bundle plan:

- accept explicit transfer readiness, handoff manifest, and transfer inventory,
  or build them from explicit capsule inputs
- require readiness by default, with a visible policy to allow not-ready plans
  for review
- summarize planned bundle subject, capsules, included files, expected missing
  paths, supplied surfaces, blockers, warnings, and policy
- expose stable `to_h`
- print deterministic smoke output

The plan should answer: "If a future bundle tool were invoked, what would it
intend to include and what would still block or warn?"

## Scope

In scope:

- application-owned read-only transfer bundle plan value
- facade such as `Igniter::Application.transfer_bundle_plan(...)`
- compact include/exclude summary based on `ApplicationTransferInventory`
- readiness policy summary based on `ApplicationTransferReadiness`
- smoke example
- web compatibility review for optional supplied surface metadata

Out of scope:

- copying files
- creating archive/package artifacts
- writing manifests to disk
- deleting/moving files
- discovering unrelated directories
- autoloading constants
- booting apps
- mounting web
- routing browser traffic
- contract/service execution
- cluster placement
- private app-specific material

## Accepted Constraints

- The bundle plan is read-only and serializable.
- It composes existing explicit reports; it should not duplicate import/export
  matching, file enumeration, or readiness classification.
- It may summarize files already enumerated by transfer inventory, but it must
  not enumerate beyond explicit capsule roots and declared layout paths.
- If readiness is false, the default plan should be `ready: false` or
  `bundle_allowed: false` rather than silently allowing a package step.
- Web metadata remains supplied/opaque. Application must not inspect web
  internals.

## Task 1: Bundle Plan Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned value, for example
  `ApplicationTransferBundlePlan`.
- Add a public facade, for example
  `Igniter::Application.transfer_bundle_plan(...)`.
- Accept explicit `transfer_readiness:`, `handoff_manifest:`, and
  `transfer_inventory:` artifacts, and/or explicit capsule inputs that build
  them.
- Include stable `subject`, `ready`, `bundle_allowed`, `capsules`,
  `included_files`, `missing_paths`, `surfaces`, `blockers`, `warnings`,
  `policy`, `readiness`, and `metadata` keys in `to_h`.
- Do not copy, archive, write, delete, load, boot, mount, route, execute, or
  coordinate clusters.

## Task 2: Smoke Example

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_transfer_bundle_plan.rb`

Acceptance:

- Build a bundle plan over an intentionally not-ready transfer.
- Print compact smoke keys for subject, allowed flag, capsules, included file
  count, blocker codes, warning codes, and surface count.
- Keep the example deterministic and safe for clean checkouts.

Suggested smoke keys:

```text
application_capsule_transfer_bundle_subject=...
application_capsule_transfer_bundle_allowed=...
application_capsule_transfer_bundle_capsules=...
application_capsule_transfer_bundle_files=...
application_capsule_transfer_bundle_blockers=...
application_capsule_transfer_bundle_warnings=...
application_capsule_transfer_bundle_surfaces=...
```

## Task 3: Web Metadata Compatibility

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify bundle plan can carry supplied web surface metadata and surface counts
  without application inspecting web internals.
- Add a package README note only if the bundle-plan path is otherwise hard to
  discover.
- Do not add web-specific bundle behavior to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_bundle_plan.rb
ruby examples/application/capsule_transfer_readiness.rb
ruby examples/application/capsule_transfer_inventory.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web package code or docs examples change, include the relevant
`packages/igniter-web/spec` slice.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with a read-only
   transfer bundle plan.
2. `[Agent Web / Codex]` performs Task 3 as a boundary check only.
3. Keep this as planning. Do not turn it into archive writing, file copying,
   discovery, loading, activation, routing, execution, or cluster placement.
