# Application Capsule Transfer Bundle Verification Track

This track follows the accepted capsule transfer bundle artifact cycle.

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

Igniter can now write a tiny explicit bundle artifact from a bundle plan. The
next step is not installation or extraction. The next step is read-only
verification: inspect the artifact, read its metadata manifest, compare planned
files with actual artifact files, and report mismatches.

This gives humans and agents confidence that an artifact matches its review
metadata before any future import/install workflow exists.

## Goal

Design and land the smallest transfer bundle verification report:

- accept an explicit artifact path
- read `igniter-transfer-bundle.json`
- verify the expected `files/` entries exist
- report missing, extra, or malformed entries
- report supplied surface metadata count without interpreting web internals
- expose stable `to_h`
- print deterministic smoke output using a temp artifact

The report should answer: "Does this written bundle match the plan metadata it
contains?"

## Scope

In scope:

- application-owned read-only verification value/report
- facade such as `Igniter::Application.verify_transfer_bundle(path)`
- metadata manifest parsing
- file presence comparison under the artifact directory
- deterministic smoke example
- web compatibility review for metadata preservation only

Out of scope:

- extracting/installing bundles
- copying bundle contents into a destination app
- project-wide discovery
- loading constants
- booting apps
- mounting web
- routing browser traffic
- contract/service execution
- cluster placement
- private app-specific material

## Accepted Constraints

- Verification reads only the explicit artifact path.
- Verification must not mutate the filesystem.
- Verification must not trust arbitrary paths inside metadata for filesystem
  traversal; file checks stay under the artifact directory.
- Verification reports mismatches rather than repairing them.
- Web metadata remains supplied/opaque; application may count or preserve it,
  but must not inspect web internals.

## Task 1: Verification Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned value/report, for example
  `ApplicationTransferBundleVerification`.
- Add a public facade, for example
  `Igniter::Application.verify_transfer_bundle(path)`.
- Read and parse `igniter-transfer-bundle.json`.
- Check planned file entries against actual files under `files/`.
- Include stable `valid`, `artifact_path`, `metadata_entry`, `missing_files`,
  `extra_files`, `malformed_entries`, `included_file_count`,
  `actual_file_count`, `surface_count`, and `metadata` keys in `to_h`.
- Do not install, extract, copy into a destination, load, boot, mount, route,
  execute, or coordinate clusters.

## Task 2: Smoke Example

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_transfer_bundle_verification.rb`

Acceptance:

- Build and write a temp bundle artifact.
- Verify it read-only.
- Print compact smoke keys for valid flag, included count, actual count,
  missing count, extra count, and surface count.
- Keep the example deterministic and safe for clean checkouts.

Suggested smoke keys:

```text
application_capsule_transfer_verify_valid=...
application_capsule_transfer_verify_included=...
application_capsule_transfer_verify_actual=...
application_capsule_transfer_verify_missing=...
application_capsule_transfer_verify_extra=...
application_capsule_transfer_verify_surfaces=...
```

## Task 3: Web Metadata Compatibility

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify that bundle verification preserves/counts supplied web metadata
  without requiring `igniter-web`.
- Add a package README note only if the verification path is otherwise hard to
  discover.
- Do not add web-specific verification behavior to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_bundle_verification.rb
ruby examples/application/capsule_transfer_bundle_artifact.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web package code or docs examples change, include the relevant
`packages/igniter-web/spec` slice.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with read-only bundle
   verification.
2. `[Agent Web / Codex]` performs Task 3 as a boundary check only.
3. Keep this as artifact verification. Do not turn it into install/extract,
   activation, routing, execution, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-transfer-bundle-verification-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationTransferBundleVerification`.
- Added `Igniter::Application.verify_transfer_bundle(path)`.
- Added `examples/application/capsule_transfer_bundle_verification.rb` and
  registered it in the active examples catalog.
- Updated public/current docs to position bundle verification as read-only
  artifact readback after explicit artifact writing.
Accepted:
- Verification reads only the explicit artifact path.
- Verification parses `igniter-transfer-bundle.json`.
- Planned files are checked only under the artifact `files/` directory.
- Missing files, extra files, and malformed/unsafe entries are reported rather
  than repaired.
- Supplied web surface metadata is counted from serialized plan metadata
  without inspecting web internals.
- `to_h` includes stable `valid`, `artifact_path`, `metadata_entry`,
  `missing_files`, `extra_files`, `malformed_entries`,
  `included_file_count`, `actual_file_count`, `surface_count`, and `metadata`.
- No install/extract, destination copy, loading, booting, mounting, routing,
  execution, or cluster placement was introduced.
Verification:
- `ruby examples/application/capsule_transfer_bundle_verification.rb` passed.
- `ruby examples/application/capsule_transfer_bundle_artifact.rb` passed.
- `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb`
  passed with 111 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_transfer_bundle_verification.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_transfer_bundle_verification.rb examples/catalog.rb`
  passed with no offenses.
Needs:
- `[Agent Web / Codex]` can perform Task 3 wording/boundary review for supplied
  web metadata preserved in bundle verification.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-transfer-bundle-verification-track.md`
Status: landed.
Changed:
- Reviewed `ApplicationTransferBundleVerification` against supplied web surface
  metadata.
- Confirmed `examples/application/capsule_transfer_bundle_verification.rb`
  verifies a written artifact with supplied `kind: :web_surface` metadata and
  reports `surface_count`.
- Updated `packages/igniter-web/README.md` with the bundle verification
  readback boundary.
Accepted:
- Bundle verification counts supplied web surfaces from the serialized bundle
  plan metadata only.
- Verification does not require `igniter-web`, inspect `SurfaceManifest`,
  screen graphs, routes, Rack apps, components, mounts, browser transports, or
  web-local directories.
- No web-specific verification behavior is needed in `igniter-application`.
Needs:
- `[Architect Supervisor / Codex]` review the transfer bundle verification
  track for acceptance.
