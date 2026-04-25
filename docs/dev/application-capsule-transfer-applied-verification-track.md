# Application Capsule Transfer Applied Verification Track

This track follows the accepted capsule transfer apply execution cycle.

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

Igniter now has an explicit dry-run-first transfer executor. The next step is
not broader mutation. The next step is read-only post-apply verification:
inspect a committed apply result, the reviewed apply plan, artifact files, and
destination filesystem, then report whether the destination matches what was
reviewed and applied.

This gives humans and agents a closure artifact after the first mutable
transfer boundary.

## Goal

Design and land the smallest applied transfer verification report:

- accept an explicit apply result or compatible serialized apply-result hash
- accept the reviewed apply plan when needed for expected operation context
- verify committed `copy_file` operations against destination files
- verify expected destination directories exist
- report missing, unexpected, mismatched, skipped, and refused operation
  findings
- preserve/count supplied web surface metadata without interpreting web
  internals
- expose stable `to_h`
- print deterministic smoke output using a temp committed apply

The report should answer: "Did the committed destination state match the
reviewed transfer apply result?"

## Scope

In scope:

- application-owned read-only applied verification value/report
- facade such as `Igniter::Application.verify_applied_transfer(...)`
- destination filesystem readback for reviewed operations
- comparison against artifact source files when available
- deterministic smoke example
- web compatibility review for metadata preservation only

Out of scope:

- creating directories
- copying files
- repairing missing files
- overwriting files
- applying host wiring
- route activation
- web mount binding
- web screen/component inspection
- project-wide discovery
- loading constants
- booting apps
- contract/service execution
- cluster placement
- private app-specific material

## Accepted Constraints

- Applied verification must be read-only.
- It must consume explicit apply result/apply plan data; it must not discover
  unrelated destination state.
- It may compare reviewed artifact source and destination files by presence,
  byte size, and content equality using Ruby stdlib only.
- It must report mismatches rather than repair them.
- `manual_host_wiring` remains review-only evidence and is not verified as an
  applied host mutation.
- Web metadata remains supplied/opaque; application may count or preserve it,
  but must not inspect web internals.

## Task 1: Applied Verification Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned value/report, for example
  `ApplicationTransferAppliedVerification`.
- Add a public facade, for example
  `Igniter::Application.verify_applied_transfer(apply_result, apply_plan: nil, metadata: {})`.
- Accept an `ApplicationTransferApplyResult` object or compatible serialized
  apply-result hash.
- Include stable `valid`, `committed`, `artifact_path`, `destination_root`,
  `verified`, `findings`, `refusals`, `skipped`, `operation_count`,
  `surface_count`, and `metadata` keys in `to_h`.
- Do not create, copy, write, delete, repair, load, boot, mount, route, execute,
  or coordinate clusters.

## Task 2: Smoke Example

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_transfer_applied_verification.rb`

Acceptance:

- Build a temp verified artifact, intake plan, apply plan, and committed apply
  result.
- Produce a read-only applied verification report.
- Print compact smoke keys for valid flag, committed flag, verified count,
  finding count, refusal count, skipped count, and surface count.
- Keep the example deterministic and safe for clean checkouts.

Suggested smoke keys:

```text
application_capsule_transfer_applied_verify_valid=...
application_capsule_transfer_applied_verify_committed=...
application_capsule_transfer_applied_verify_verified=...
application_capsule_transfer_applied_verify_findings=...
application_capsule_transfer_applied_verify_refusals=...
application_capsule_transfer_applied_verify_skipped=...
application_capsule_transfer_applied_verify_surfaces=...
```

## Task 3: Web Metadata Compatibility

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify that applied verification preserves/counts supplied web metadata
  without requiring `igniter-web`.
- Confirm no web-specific destination verification is introduced.
- Add a package README note only if the verification boundary is otherwise hard
  to discover.
- Do not add web-specific verification behavior to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_applied_verification.rb
ruby examples/application/capsule_transfer_apply_execution.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web package code or docs examples change, include the relevant
`packages/igniter-web/spec` slice.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with read-only
   post-apply verification.
2. `[Agent Web / Codex]` performs Task 3 as a boundary check only.
3. Keep this as readback/reporting. Do not add repair, overwrite, web
   activation, app boot, routing, contract execution, discovery, or cluster
   placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-transfer-applied-verification-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationTransferAppliedVerification`.
- Added `Igniter::Application.verify_applied_transfer(...)`.
- Added `examples/application/capsule_transfer_applied_verification.rb` and
  registered it in the active examples catalog.
- Updated public/current docs to position applied verification as read-only
  post-apply readback over committed transfer results.
Accepted:
- Applied verification accepts an `ApplicationTransferApplyResult` object or a
  compatible serialized apply-result hash.
- Optional `apply_plan:` provides reviewed expected operation context.
- `to_h` includes stable `valid`, `committed`, `artifact_path`,
  `destination_root`, `verified`, `findings`, `refusals`, `skipped`,
  `operation_count`, `surface_count`, and `metadata`.
- Verified directories and files are derived only from explicit result/plan
  operation data.
- File verification checks destination presence, artifact source presence,
  byte size, and content equality.
- Refusals, skipped operations, dry-run results, unexpected applied
  operations, missing material, unsafe paths, and mismatches are reported
  without repair.
- `manual_host_wiring` remains review-only evidence and is not verified as an
  applied host mutation.
- Supplied web surface metadata is counted without requiring `igniter-web` or
  introducing web-specific destination verification.
- No directory creation, copying, overwriting, repair, host wiring mutation,
  web activation, loading, booting, routing, contract execution, discovery, or
  cluster placement was introduced.
Verification:
- `ruby examples/application/capsule_transfer_applied_verification.rb` passed.
- `ruby examples/application/capsule_transfer_apply_execution.rb` passed.
- `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb`
  passed with 127 examples, 0 failures.
- `ruby examples/run.rb smoke` passed with 66 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_transfer_applied_verification.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_transfer_applied_verification.rb examples/catalog.rb`
  passed with no offenses.
Needs:
- `[Agent Web / Codex]` can perform Task 3 boundary review for opaque web
  metadata and confirm no web-specific destination verification is needed.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-transfer-applied-verification-track.md`
Status: landed.
Changed:
- Reviewed applied verification against the web/application boundary.
- Added a short `packages/igniter-web/README.md` note for the post-apply
  verification boundary.
Accepted:
- Applied verification preserves the supplied `surface_count` from the explicit
  committed apply result.
- `igniter-application` does not require `igniter-web`, `SurfaceManifest`, web
  mounts, screen graphs, pages, components, or route activation for applied
  verification.
- No web-specific destination verification behavior is needed in
  `igniter-application`; web metadata remains opaque review context.
Verification:
- `ruby examples/application/capsule_transfer_applied_verification.rb` passed.
- `ruby examples/application/capsule_transfer_apply_execution.rb` passed.
- `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb`
  passed.
- `bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb`
  passed.
- `git diff --check` passed.
Needs:
- `[Architect Supervisor / Codex]` review/accept the applied verification
  track and decide the next transfer boundary.
