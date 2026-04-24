# Application Capsule Transfer Intake Plan Track

This track follows the accepted capsule transfer bundle verification cycle.

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

Igniter can now plan a capsule bundle, write an explicit directory artifact,
and verify that the written artifact matches its serialized review metadata.
The next step is not extraction or installation. The next step is a read-only
destination intake plan: given a verified bundle and an explicit destination
context, report what would be placed where, what would conflict, and which host
wiring remains required.

This gives humans and agents a receiving-side review artifact before any future
copy/import/install workflow exists.

## Goal

Design and land the smallest transfer intake plan:

- accept an explicit verified bundle or artifact path
- accept an explicit destination root
- read only the verified artifact metadata and destination filesystem state
- report planned destination paths for bundled files
- report destination conflicts without overwriting anything
- report required host wiring and unresolved imports from serialized metadata
- preserve/count supplied web surface metadata without interpreting web
  internals
- expose stable `to_h`
- print deterministic smoke output using a temp verified artifact and temp
  destination

The report should answer: "If this verified bundle were imported into this
destination, what would be safe, blocked, or still require host work?"

## Scope

In scope:

- application-owned read-only intake value/report
- facade such as `Igniter::Application.transfer_intake_plan(...)`
- composing the accepted bundle verification artifact
- destination conflict checks under an explicit destination root
- required host wiring summary from serialized handoff/plan metadata
- deterministic smoke example
- web compatibility review for metadata preservation only

Out of scope:

- extracting bundles
- copying files into the destination
- creating directories
- overwriting files
- modifying destination config
- project-wide discovery
- loading constants
- booting apps
- mounting web
- routing browser traffic
- contract/service execution
- cluster placement
- private app-specific material

## Accepted Constraints

- Intake planning must be read-only.
- Destination checks require an explicit destination root.
- Paths derived from artifact metadata must stay relative and safe before they
  are joined to the destination root.
- Existing destination files are conflicts, not overwrite instructions.
- Web metadata remains supplied/opaque; application may count or preserve it,
  but must not inspect web internals.
- The plan may recommend manual host wiring, but it must not apply it.

## Task 1: Intake Plan Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned value/report, for example
  `ApplicationTransferIntakePlan`.
- Add a public facade, for example
  `Igniter::Application.transfer_intake_plan(verification_or_path, destination_root:, metadata: {})`.
- Accept either an existing `ApplicationTransferBundleVerification` object or
  an explicit artifact path that can be verified internally.
- Include stable `ready`, `destination_root`, `artifact_path`,
  `verification_valid`, `planned_files`, `conflicts`, `blockers`, `warnings`,
  `required_host_wiring`, `surface_count`, and `metadata` keys in `to_h`.
- Do not extract, copy, write, load, boot, mount, route, execute, or coordinate
  clusters.

## Task 2: Smoke Example

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_transfer_intake_plan.rb`

Acceptance:

- Build, write, and verify a temp bundle artifact.
- Build an explicit temp destination context.
- Produce a read-only intake plan.
- Print compact smoke keys for ready flag, planned file count, conflict count,
  blocker count, required host wiring count, and surface count.
- Keep the example deterministic and safe for clean checkouts.

Suggested smoke keys:

```text
application_capsule_transfer_intake_ready=...
application_capsule_transfer_intake_planned=...
application_capsule_transfer_intake_conflicts=...
application_capsule_transfer_intake_blockers=...
application_capsule_transfer_intake_host_wiring=...
application_capsule_transfer_intake_surfaces=...
```

## Task 3: Web Metadata Compatibility

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify that intake planning preserves/counts supplied web metadata without
  requiring `igniter-web`.
- Add a package README note only if the intake boundary is otherwise hard to
  discover.
- Do not add web-specific intake behavior to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_intake_plan.rb
ruby examples/application/capsule_transfer_bundle_verification.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web package code or docs examples change, include the relevant
`packages/igniter-web/spec` slice.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with read-only
   destination intake planning.
2. `[Agent Web / Codex]` performs Task 3 as a boundary check only.
3. Keep this as receiving-side review. Do not turn it into extraction,
   installation, activation, routing, execution, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-transfer-intake-plan-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationTransferIntakePlan`.
- Added `Igniter::Application.transfer_intake_plan(...)`.
- Added `examples/application/capsule_transfer_intake_plan.rb` and registered
  it in the active examples catalog.
- Updated public/current docs to position intake planning as read-only
  destination review after bundle verification.
Accepted:
- Intake planning accepts an existing verification object or an explicit
  artifact path that is verified internally.
- Destination checks require an explicit `destination_root`.
- `to_h` includes stable `ready`, `destination_root`, `artifact_path`,
  `verification_valid`, `planned_files`, `conflicts`, `blockers`, `warnings`,
  `required_host_wiring`, `surface_count`, and `metadata`.
- Planned destination paths are derived from serialized artifact metadata and
  are checked for relative/safe placement under the destination root.
- Existing destination files are reported as conflicts and blockers, not
  overwrite instructions.
- Required host wiring is surfaced from serialized handoff/plan metadata.
- Supplied web surface metadata is counted without inspecting web internals.
- No extraction, copying, directory creation, host config mutation, loading,
  booting, mounting, routing, execution, or cluster placement was introduced.
Verification:
- `ruby examples/application/capsule_transfer_intake_plan.rb` passed.
- `ruby examples/application/capsule_transfer_bundle_verification.rb` passed.
- `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb`
  passed with 114 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_transfer_intake_plan.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_transfer_intake_plan.rb examples/catalog.rb`
  passed with no offenses.
Needs:
- `[Agent Web / Codex]` can perform Task 3 wording/boundary review for supplied
  web metadata preserved in intake planning.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-transfer-intake-plan-track.md`
Status: landed.
Changed:
- Reviewed `ApplicationTransferIntakePlan` against supplied web surface
  metadata.
- Confirmed `examples/application/capsule_transfer_intake_plan.rb` plans a
  verified artifact with supplied `kind: :web_surface` metadata and reports
  `surface_count`.
- Updated `packages/igniter-web/README.md` with the destination intake planning
  boundary.
Accepted:
- Intake planning counts supplied web surfaces from serialized bundle plan
  metadata only.
- Intake planning previews destination files from planned artifact entries; it
  does not require `igniter-web`, inspect `SurfaceManifest`, screen graphs,
  routes, Rack apps, components, mounts, browser transports, or web-local
  directories.
- No web-specific intake behavior is needed in `igniter-application`.
Needs:
- `[Architect Supervisor / Codex]` review the transfer intake plan track for
  acceptance.
