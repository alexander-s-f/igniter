# Application Capsule Transfer Bundle Artifact Track

This track follows the accepted capsule transfer bundle plan cycle.

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

Igniter now has a full review chain and a read-only bundle plan. The next step
can create a small explicit bundle artifact, but only under tight constraints.

The artifact writer must be boring and predictable: it takes an accepted bundle
plan, writes to an explicit output path, includes only planned files, and
embeds serializable review metadata. It must not become project discovery,
runtime activation, web mounting, cluster placement, or a magic migration tool.

[Architect Supervisor / Codex] Accepted after the 2026-04-24 agent cycle.

Decision:

- `ApplicationTransferBundleArtifact`,
  `ApplicationTransferBundleArtifactResult`, and
  `Igniter::Application.write_transfer_bundle(...)` are accepted as the
  application-owned explicit artifact writer from bundle plans.
- Directory artifact shape with `files/` plus
  `igniter-transfer-bundle.json` metadata is accepted as the first artifact
  shape.
- Default refusal when `bundle_allowed` is false is accepted.
- Default refusal when output already exists is accepted.
- Parent directory creation only through explicit `create_parent: true` is
  accepted.
- Copying only `included_files` already present in the bundle plan is accepted.
- Web metadata remains supplied/opaque and is preserved only through serialized
  review metadata; the writer must not inspect web internals or web-local
  directories.

Verification:

```bash
ruby examples/application/capsule_transfer_bundle_artifact.rb
ruby examples/application/capsule_transfer_bundle_plan.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb
bundle exec rubocop packages/igniter-application/lib/igniter/application/application_transfer_bundle_artifact.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_transfer_bundle_artifact.rb examples/catalog.rb
```

Result: all passed.

Next:

- Continue through
  [Application Capsule Transfer Bundle Verification Track](./application-capsule-transfer-bundle-verification-track.md).
- Keep the next slice read-only. Verify/read back an artifact and report
  mismatches, but do not install, extract, activate, mount, route, execute, or
  coordinate clusters.

## Goal

Design and land the smallest transfer bundle artifact writer:

- accept an explicit `ApplicationTransferBundlePlan`
- require `bundle_allowed` unless an explicit override is provided
- require an explicit output path
- refuse to overwrite by default
- include only files already listed by the bundle plan
- include a serializable metadata manifest in the artifact
- expose a result/report with stable `to_h`
- print deterministic smoke output using a temporary output path

The artifact should answer: "What exact bundle did Igniter write, from which
plan, and which planned files/metadata did it contain?"

## Scope

In scope:

- application-owned transfer bundle artifact result/report value
- facade such as `Igniter::Application.write_transfer_bundle(...)`
- deterministic archive or directory artifact shape chosen conservatively
- explicit output path validation
- no-overwrite default
- embedded plan/readiness/manifest/inventory metadata
- smoke example that writes only to a temp directory
- web compatibility review for supplied metadata only

Out of scope:

- project-wide discovery
- including files not present in `ApplicationTransferBundlePlan#to_h`
- automatic destination selection
- overwriting existing artifacts by default
- installing or extracting bundles
- loading constants
- booting apps
- mounting web
- routing browser traffic
- contract/service execution
- cluster placement
- private app-specific material

## Accepted Constraints

- Artifact writing is allowed only from a bundle plan, not directly from a
  project root.
- Default behavior must refuse when `bundle_allowed` is false.
- Default behavior must refuse if the output already exists.
- The writer may create parent directories only if the caller explicitly asks
  for that behavior.
- The writer must not enumerate beyond `included_files` from the bundle plan.
- Web metadata remains supplied/opaque; application must not inspect web
  internals.
- The result must be serializable and include the final artifact path, included
  file count, metadata manifest path/name, and refusal reasons when blocked.

## Task 1: Artifact Writer Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned value/report, for example
  `ApplicationTransferBundleArtifact`.
- Add a public facade, for example
  `Igniter::Application.write_transfer_bundle(plan, output:, ...)`.
- Accept only an explicit bundle plan or object responding to `to_h`.
- Refuse when `bundle_allowed` is false unless an explicit review override is
  provided.
- Refuse to overwrite existing output by default.
- Include only files from `plan.to_h.fetch(:included_files)`.
- Include serializable metadata derived from the plan.
- Expose stable `to_h` with `written`, `artifact_path`, `included_file_count`,
  `metadata_entry`, `refusals`, and `metadata`.
- Do not discover, load, boot, mount, route, execute, install, extract, or
  coordinate clusters.

## Task 2: Smoke Example

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_transfer_bundle_artifact.rb`

Acceptance:

- Build a bundle plan and write an artifact to a temp directory only.
- Use explicit override only if the example intentionally uses a not-ready plan.
- Print compact smoke keys for written flag, artifact basename, included files,
  metadata entry, and refusal count.
- Keep the example deterministic and safe for clean checkouts.

Suggested smoke keys:

```text
application_capsule_transfer_artifact_written=...
application_capsule_transfer_artifact_file=...
application_capsule_transfer_artifact_included=...
application_capsule_transfer_artifact_metadata=...
application_capsule_transfer_artifact_refusals=...
```

## Task 3: Web Metadata Compatibility

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify artifact metadata can carry supplied web surface metadata without
  application inspecting web internals.
- Add a package README note only if the artifact path is otherwise hard to
  discover.
- Do not add web-specific artifact behavior to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_bundle_artifact.rb
ruby examples/application/capsule_transfer_bundle_plan.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web package code or docs examples change, include the relevant
`packages/igniter-web/spec` slice.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with a tiny explicit
   artifact writer.
2. `[Agent Web / Codex]` performs Task 3 as a boundary check only.
3. Keep this as artifact creation from an explicit plan. Do not turn it into
   project discovery, install/extract, activation, routing, execution, or
   cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-transfer-bundle-artifact-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationTransferBundleArtifact` and
  `ApplicationTransferBundleArtifactResult`.
- Added `Igniter::Application.write_transfer_bundle(...)`.
- Added `examples/application/capsule_transfer_bundle_artifact.rb` and
  registered it in the active examples catalog.
- Updated public/current docs to position artifact writing as an explicit
  output-path-only step after accepted bundle plans.
Accepted:
- Artifact writing accepts only an explicit bundle plan or object responding to
  `to_h`.
- Default behavior refuses when `bundle_allowed` is false.
- Default behavior refuses existing output paths.
- Parent directories are created only when `create_parent: true` is passed.
- The directory artifact includes only `included_files` already present in the
  bundle plan and writes serialized review metadata to
  `igniter-transfer-bundle.json`.
- The result exposes stable `to_h` with `written`, `artifact_path`,
  `included_file_count`, `metadata_entry`, `refusals`, and `metadata`.
- No project discovery, install/extract, loading, booting, mounting, routing,
  execution, or cluster placement was introduced.
Verification:
- `ruby examples/application/capsule_transfer_bundle_artifact.rb` passed.
- `ruby examples/application/capsule_transfer_bundle_plan.rb` passed.
- `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb`
  passed with 108 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_transfer_bundle_artifact.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_transfer_bundle_artifact.rb examples/catalog.rb`
  passed with no offenses.
Needs:
- `[Agent Web / Codex]` can perform Task 3 wording/boundary review for supplied
  web metadata in transfer bundle artifacts.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-transfer-bundle-artifact-track.md`
Status: landed.
Changed:
- Reviewed `ApplicationTransferBundleArtifact` against supplied web surface
  metadata.
- Updated `examples/application/capsule_transfer_bundle_artifact.rb` so the
  written metadata manifest proves a supplied web surface survives inside the
  serialized bundle plan.
- Updated the examples catalog, `packages/igniter-web/README.md`, and the
  application capsule guide with the artifact metadata boundary.
Accepted:
- Transfer bundle artifacts preserve supplied web surface hashes in
  `igniter-transfer-bundle.json` as review metadata.
- The writer copies only files already listed by the bundle plan; it does not
  inspect `SurfaceManifest`, screen graphs, routes, Rack apps, components,
  mounts, browser transports, or web-local directories.
- No web-specific artifact behavior is needed in `igniter-application`.
Needs:
- `[Architect Supervisor / Codex]` review the transfer bundle artifact track
  for acceptance.
