# Application Capsule Transfer Apply Execution Track

This track follows the accepted capsule transfer apply plan cycle.

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

Igniter now has a full read-only transfer chain from capsule metadata through
bundle artifact verification, destination intake planning, and apply operation
planning. The next useful step is the first narrow mutable boundary, but it
must stay explicit and refusal-first.

The application layer may execute only the reviewed operation data produced by
`ApplicationTransferApplyPlan`. It must default to dry-run/report mode and
require an explicit commit flag before touching the destination filesystem.

## Goal

Design and land the smallest transfer apply execution result:

- accept an explicit `ApplicationTransferApplyPlan` or compatible serialized
  apply-plan hash
- default to dry-run mode
- require an explicit commit option for filesystem mutation
- refuse non-executable plans
- refuse overwrite by default
- execute only `ensure_directory` and `copy_file` operations from the plan
- keep `manual_host_wiring` as review-only/not-applied output
- report applied/skipped/refused operations with stable `to_h`
- print deterministic smoke output using a temp plan

The result should answer: "What would happen, or what happened, when this
reviewed apply plan was applied under explicit policy?"

## Scope

In scope:

- application-owned apply execution result/report
- facade such as `Igniter::Application.apply_transfer_plan(...)`
- dry-run result over apply-plan operations
- explicit committed filesystem execution for directories and file copies
- refusal reporting for non-executable plans, overwrite conflicts, unsupported
  operation types, unsafe/missing paths, and missing artifact sources
- deterministic smoke example
- web compatibility review for metadata preservation only

Out of scope:

- applying host wiring
- route activation
- web mount binding
- web screen/component inspection
- deleting files
- overwriting files by default
- project-wide discovery
- loading constants
- booting apps
- contract/service execution
- cluster placement
- private app-specific material

## Accepted Constraints

- Dry-run must be the default.
- Filesystem mutation requires an explicit option such as `commit: true`.
- Execution must consume operation data from the apply plan; it must not
  rediscover files or infer extra work.
- The executor may create directories and copy files only under the destination
  root from the plan.
- Existing destination files are refusals unless an explicit future policy is
  accepted in a later track.
- `manual_host_wiring` operations are reported as skipped/review-only and are
  never applied.
- Web metadata remains supplied/opaque; application may count or preserve it,
  but must not inspect web internals.

## Task 1: Execution Result Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned value/report, for example
  `ApplicationTransferApplyResult`.
- Add a public facade, for example
  `Igniter::Application.apply_transfer_plan(apply_plan, commit: false, metadata: {})`.
- Accept an `ApplicationTransferApplyPlan` object or a compatible serialized
  apply-plan hash.
- Include stable `committed`, `executable`, `applied`, `skipped`, `refusals`,
  `operation_count`, `artifact_path`, `destination_root`, `surface_count`, and
  `metadata` keys in `to_h`.
- In dry-run mode, report what would be applied without writing.
- In commit mode, create directories and copy files only from reviewed
  operations.
- Do not apply host wiring, activate web, load, boot, route, execute contracts,
  or coordinate clusters.

## Task 2: Smoke Example

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_transfer_apply_execution.rb`

Acceptance:

- Build a temp verified artifact, intake plan, and apply plan.
- Produce a dry-run apply result.
- Produce an explicit committed apply result into a temp destination.
- Print compact smoke keys for dry-run committed flag, committed flag, applied
  count, refusal count, and copied file existence.
- Keep the example deterministic and safe for clean checkouts.

Suggested smoke keys:

```text
application_capsule_transfer_apply_dry_run_committed=...
application_capsule_transfer_apply_commit_committed=...
application_capsule_transfer_apply_applied=...
application_capsule_transfer_apply_refusals=...
application_capsule_transfer_apply_copied=...
```

## Task 3: Web Metadata Compatibility

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify that apply execution preserves/counts supplied web metadata without
  requiring `igniter-web`.
- Confirm no web-specific operation is executed.
- Add a package README note only if the execution boundary is otherwise hard to
  discover.
- Do not add web-specific execution behavior to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_apply_execution.rb
ruby examples/application/capsule_transfer_apply_plan.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web package code or docs examples change, include the relevant
`packages/igniter-web/spec` slice.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with explicit,
   dry-run-first apply execution.
2. `[Agent Web / Codex]` performs Task 3 as a boundary check only.
3. Keep this as a narrow filesystem transfer boundary. Do not add host wiring
   mutation, web activation, app boot, routing, contract execution, discovery,
   overwrite policy, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-transfer-apply-execution-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationTransferApplyResult`.
- Added `Igniter::Application.apply_transfer_plan(...)`.
- Added `examples/application/capsule_transfer_apply_execution.rb` and
  registered it in the active examples catalog.
- Updated public/current docs to position apply execution as explicit,
  dry-run-first, refusal-first transfer execution over reviewed apply plans.
Accepted:
- Apply execution accepts an `ApplicationTransferApplyPlan` object or a
  compatible serialized apply-plan hash.
- `to_h` includes stable `committed`, `executable`, `applied`, `skipped`,
  `refusals`, `operation_count`, `artifact_path`, `destination_root`,
  `surface_count`, and `metadata`.
- Dry-run is the default and reports reviewed operations without writing.
- `commit: true` is required for filesystem mutation.
- Commit mode preflights reviewed operations before mutation and refuses unsafe
  paths, missing artifact sources, destination overwrites, unsupported
  operation types, and non-executable plans.
- Only reviewed `ensure_directory` and `copy_file` operations can mutate the
  destination filesystem.
- `manual_host_wiring` operations are skipped/review-only and never applied.
- Supplied web surface metadata is counted without requiring `igniter-web` or
  executing web-specific operations.
- No host wiring mutation, web activation, loading, booting, routing, contract
  execution, discovery, overwrite policy, or cluster placement was introduced.
Verification:
- `ruby examples/application/capsule_transfer_apply_execution.rb` passed.
- `ruby examples/application/capsule_transfer_apply_plan.rb` passed.
- `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb`
  passed with 122 examples, 0 failures.
- `ruby examples/run.rb smoke` passed with 65 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_transfer_apply_result.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_transfer_apply_execution.rb examples/catalog.rb`
  passed with no offenses.
Needs:
- `[Agent Web / Codex]` can perform Task 3 boundary review for opaque web
  metadata and confirm no web-specific execution behavior is needed.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-transfer-apply-execution-track.md`
Status: landed.
Changed:
- Reviewed `ApplicationTransferApplyResult` against supplied web surface
  metadata and execution behavior.
- Updated `examples/application/capsule_transfer_apply_execution.rb` and the
  examples catalog so committed apply execution proves `surface_count` is
  preserved.
- Updated `packages/igniter-web/README.md` with the dry-run-first apply
  execution boundary.
Accepted:
- Apply execution preserves supplied web surface metadata only as
  apply-plan-derived `surface_count`.
- Commit mode mutates only reviewed `ensure_directory` and `copy_file`
  operations; no web-specific operation, surface install, mount binding, route
  activation, or screen/component inspection is introduced.
- No web-specific execution behavior is needed in `igniter-application`.
Needs:
- `[Architect Supervisor / Codex]` review the transfer apply execution track
  for acceptance.
