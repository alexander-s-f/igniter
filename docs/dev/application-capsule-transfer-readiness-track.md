# Application Capsule Transfer Readiness Track

This track follows the accepted capsule transfer inventory cycle.

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

Igniter now has two complementary transfer review artifacts:

- `ApplicationHandoffManifest` explains what is moving, dependency readiness,
  suggested host wiring, mount intents, and supplied surface metadata.
- `ApplicationTransferInventory` explains declared capsule material, expected
  paths, missing paths, safe file counts, and supplied surface path metadata.

The next step is a compact readiness report over those artifacts. This is the
last review gate before any future copy/package design: a human or agent should
be able to ask "is this transfer ready, and if not, what blocks it?"

This is not packaging. It is a decision/readiness report.

## Goal

Design and land the smallest read-only capsule transfer readiness report:

- accept an explicit handoff manifest and transfer inventory, or build both
  from explicit capsule inputs
- expose a single `ready` boolean
- separate blocking findings from warnings
- classify findings by source: manifest, inventory, surface metadata, policy
- summarize unresolved imports, unresolved mount intents, missing expected
  paths, skipped unsafe paths, and optional warnings
- expose stable `to_h`

The report should help agents decide whether the capsule set can proceed to a
future transfer/package step without making that step exist yet.

## Scope

In scope:

- application-owned read-only transfer readiness value
- facade such as `Igniter::Application.transfer_readiness(...)`
- small built-in policy vocabulary for blocking vs warning findings
- smoke example using existing handoff and inventory examples
- web compatibility review for optional web metadata wording

Out of scope:

- copying files
- creating archives or package artifacts
- mutating the filesystem
- discovering unrelated directories
- autoloading constants
- booting apps
- mounting web
- routing browser traffic
- contract/service execution
- cluster placement
- private app-specific material

## Accepted Constraints

- The readiness report composes existing explicit reports; it should not
  duplicate import/export matching or file enumeration logic.
- Inputs are explicit. There is no project-wide discovery.
- Policies start simple: required manifest readiness and no skipped unsafe
  inventory paths are blockers; missing expected paths may be blockers by
  default with room for an explicit policy later.
- Web remains optional supplied metadata. Application readiness may report that
  web metadata was supplied or absent, but must not inspect web internals.
- The result should be compact enough for agent handoff and CI smoke output.

## Task 1: Transfer Readiness Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned value, for example
  `ApplicationTransferReadiness`.
- Add a public facade, for example
  `Igniter::Application.transfer_readiness(...)`.
- Accept explicit `handoff_manifest:` and `transfer_inventory:` objects, and/or
  explicit capsule inputs that build them.
- Include `ready`, `blockers`, `warnings`, `summary`, `manifest`, and
  `inventory` keys in `to_h`.
- Findings should include stable `source`, `code`, `message`, and `metadata`
  fields.
- Do not copy, archive, create, delete, load, boot, mount, route, execute, or
  coordinate clusters.

## Task 2: Smoke Example

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_transfer_readiness.rb`

Acceptance:

- Build a readiness report for a not-ready capsule transfer and, if compact,
  a ready or less-blocked variant.
- Print compact smoke keys for `ready`, blocker codes, warning codes, and
  source counts.
- Keep the example deterministic and safe for clean checkouts.

Suggested smoke keys:

```text
application_capsule_transfer_readiness_ready=...
application_capsule_transfer_readiness_blockers=...
application_capsule_transfer_readiness_warnings=...
application_capsule_transfer_readiness_sources=...
```

## Task 3: Web Metadata Compatibility

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify readiness findings can reference supplied web metadata without
  application inspecting web internals.
- Add a package README note only if the readiness path is otherwise hard to
  discover.
- Do not add web-specific readiness behavior to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_readiness.rb
ruby examples/application/capsule_transfer_inventory.rb
ruby examples/application/capsule_handoff_manifest.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web package code or docs examples change, include the relevant
`packages/igniter-web/spec` slice.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with a narrow
   readiness report over existing handoff/inventory artifacts.
2. `[Agent Web / Codex]` performs Task 3 as a boundary check only.
3. Keep this as reporting/decision support. Do not turn it into transfer
   packaging, copying, discovery, loading, activation, routing, execution, or
   cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-transfer-readiness-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationTransferReadiness`.
- Added `Igniter::Application.transfer_readiness(...)`.
- Added `examples/application/capsule_transfer_readiness.rb` and registered it
  in the active examples catalog.
- Updated public/current docs to position readiness as the decision report over
  handoff manifests and transfer inventories.
Accepted:
- Readiness can accept explicit `handoff_manifest:` and `transfer_inventory:`
  objects, or build both from explicit capsule inputs.
- `to_h` includes `ready`, `blockers`, `warnings`, `summary`, `manifest`,
  `inventory`, and `metadata`.
- Findings include stable `severity`, `source`, `code`, `message`, and
  `metadata` fields.
- Required import failures, unresolved mount intents, skipped unsafe paths, and
  missing expected paths are blockers by default.
- Optional imports, absent supplied surface metadata, and deferred file
  enumeration are warnings.
- The report remains read-only: no copy, archive, create, delete, discovery,
  loading, boot, mount, routing, execution, or cluster placement.
Verification:
- `ruby examples/application/capsule_transfer_readiness.rb` passed.
- `ruby examples/application/capsule_transfer_inventory.rb` passed.
- `ruby examples/application/capsule_handoff_manifest.rb` passed.
- `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb`
  passed with 102 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_transfer_readiness.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_transfer_readiness.rb examples/catalog.rb`
  passed with no offenses.
Needs:
- `[Agent Web / Codex]` can perform Task 3 wording/boundary review for optional
  web metadata in readiness findings.
