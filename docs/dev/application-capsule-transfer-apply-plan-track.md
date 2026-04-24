# Application Capsule Transfer Apply Plan Track

This track follows the accepted capsule transfer intake plan cycle.

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

Igniter can now verify a transfer bundle artifact and preview its destination
intake against an explicit receiving root. The next step is still not applying
the transfer. The next step is a read-only apply plan: convert accepted intake
data into explicit ordered operations and preconditions so humans and agents can
review exactly what a future apply/extract operation would do.

This separates "what would be executed" from "execute it" and gives the future
mutable step a narrow contract.

## Goal

Design and land the smallest transfer apply plan:

- accept an explicit `ApplicationTransferIntakePlan` or compatible intake hash
- report whether the plan is executable based on intake readiness
- produce ordered operations for future directory creation and file copy
- preserve destination conflict/blocker data without mutating anything
- include manual host wiring operations as review-only steps
- preserve/count supplied web surface metadata without interpreting web
  internals
- expose stable `to_h`
- print deterministic smoke output using a temp intake plan

The report should answer: "If this intake were accepted, what exact operations
would a future apply step need to perform, and what still blocks it?"

## Scope

In scope:

- application-owned read-only apply plan value/report
- facade such as `Igniter::Application.transfer_apply_plan(...)`
- operation list derived from intake `planned_files` and `required_host_wiring`
- preconditions/blockers from intake readiness
- deterministic smoke example
- web compatibility review for metadata preservation only

Out of scope:

- creating directories
- copying files
- overwriting files
- deleting files
- modifying destination config
- applying host wiring
- extracting or installing bundles
- project-wide discovery
- loading constants
- booting apps
- mounting web
- routing browser traffic
- contract/service execution
- cluster placement
- private app-specific material

## Accepted Constraints

- Apply planning must be read-only.
- Operations must be explicit data, not executable lambdas/procs.
- Operation paths must come from the accepted intake plan and remain safe,
  destination-relative review data.
- Intake blockers remain blockers; the apply plan must not downgrade them.
- Web metadata remains supplied/opaque; application may count or preserve it,
  but must not inspect web internals.
- Manual host wiring may appear as operation data, but must not be applied.

## Task 1: Apply Plan Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned value/report, for example
  `ApplicationTransferApplyPlan`.
- Add a public facade, for example
  `Igniter::Application.transfer_apply_plan(intake_plan, metadata: {})`.
- Accept an `ApplicationTransferIntakePlan` object or a compatible serialized
  intake hash.
- Include stable `executable`, `artifact_path`, `destination_root`,
  `operations`, `operation_count`, `blockers`, `warnings`, `surface_count`, and
  `metadata` keys in `to_h`.
- Operation hashes should have stable `type`, `status`, `source`,
  `destination`, and `metadata` keys where applicable.
- Do not create, copy, write, delete, load, boot, mount, route, execute, or
  coordinate clusters.

## Task 2: Smoke Example

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_transfer_apply_plan.rb`

Acceptance:

- Build a temp verified artifact and intake plan.
- Produce a read-only apply plan.
- Print compact smoke keys for executable flag, operation count, blocker count,
  warning count, and surface count.
- Keep the example deterministic and safe for clean checkouts.

Suggested smoke keys:

```text
application_capsule_transfer_apply_executable=...
application_capsule_transfer_apply_operations=...
application_capsule_transfer_apply_blockers=...
application_capsule_transfer_apply_warnings=...
application_capsule_transfer_apply_surfaces=...
```

## Task 3: Web Metadata Compatibility

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify that apply planning preserves/counts supplied web metadata without
  requiring `igniter-web`.
- Add a package README note only if the apply-plan boundary is otherwise hard
  to discover.
- Do not add web-specific apply behavior to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_apply_plan.rb
ruby examples/application/capsule_transfer_intake_plan.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web package code or docs examples change, include the relevant
`packages/igniter-web/spec` slice.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with read-only apply
   planning over accepted intake data.
2. `[Agent Web / Codex]` performs Task 3 as a boundary check only.
3. Keep this as operation review. Do not turn it into extraction, copying,
   installation, activation, routing, execution, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-transfer-apply-plan-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationTransferApplyPlan`.
- Added `Igniter::Application.transfer_apply_plan(...)`.
- Added `examples/application/capsule_transfer_apply_plan.rb` and registered
  it in the active examples catalog.
- Updated public/current docs to position apply planning as read-only
  operation review after transfer intake planning.
Accepted:
- Apply planning accepts an `ApplicationTransferIntakePlan` object or a
  compatible serialized intake hash.
- `to_h` includes stable `executable`, `artifact_path`, `destination_root`,
  `operations`, `operation_count`, `blockers`, `warnings`, `surface_count`,
  and `metadata`.
- Operations are explicit data with stable `type`, `status`, `source`,
  `destination`, and `metadata` keys.
- Future directory creation and file copy operations are derived from intake
  `planned_files`; manual host wiring operations are derived from
  `required_host_wiring`.
- Intake blockers remain blockers and make the plan non-executable.
- Supplied web surface metadata is counted without inspecting web internals.
- No directory creation, copying, overwriting, deleting, host wiring mutation,
  loading, booting, mounting, routing, execution, or cluster placement was
  introduced.
Verification:
- `ruby examples/application/capsule_transfer_apply_plan.rb` passed.
- `ruby examples/application/capsule_transfer_intake_plan.rb` passed.
- `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb`
  passed with 118 examples, 0 failures.
- `ruby examples/run.rb smoke` passed with 64 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_transfer_apply_plan.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_transfer_apply_plan.rb examples/catalog.rb`
  passed with no offenses.
Needs:
- `[Agent Web / Codex]` can perform Task 3 wording/boundary review for supplied
  web metadata preserved in apply planning.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-transfer-apply-plan-track.md`
Status: landed.
Changed:
- Reviewed `ApplicationTransferApplyPlan` against supplied web surface metadata.
- Confirmed `examples/application/capsule_transfer_apply_plan.rb` builds an
  apply plan from intake data with supplied `kind: :web_surface` metadata and
  reports `surface_count`.
- Updated `packages/igniter-web/README.md` with the apply operation planning
  boundary.
Accepted:
- Apply planning preserves supplied web surface metadata only as intake-derived
  `surface_count`.
- Operations are review data derived from planned files and required host
  wiring; no web-specific operation, mount binding, route activation, or
  screen/component inspection is introduced.
- No web-specific apply behavior is needed in `igniter-application`.
Needs:
- `[Architect Supervisor / Codex]` review the transfer apply plan track for
  acceptance.

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after 2026-04-25 agent cycle.

Accepted:

- `ApplicationTransferApplyPlan` is the right read-only operation review
  surface after transfer intake planning.
- `Igniter::Application.transfer_apply_plan(...)` may accept an
  `ApplicationTransferIntakePlan` object or a compatible serialized intake
  hash.
- Operations are explicit data, not executable callbacks.
- Future directory and file-copy operations are derived from intake
  `planned_files`; manual host wiring operations are review-only data derived
  from `required_host_wiring`.
- Intake blockers remain blockers and make the plan non-executable.
- Supplied web surface metadata remains opaque. The application layer may count
  it, but it must not inspect web internals or create web-specific operations.
- No directory creation, copying, overwriting, deleting, host wiring mutation,
  loading, booting, mounting, routing, execution, or cluster placement was
  introduced.

Verification:

```bash
ruby examples/application/capsule_transfer_apply_plan.rb
ruby examples/application/capsule_transfer_intake_plan.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb
bundle exec rubocop packages/igniter-application/lib/igniter/application/application_transfer_apply_plan.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_transfer_apply_plan.rb examples/catalog.rb
```

Result:

- apply-plan example passed
- intake example passed
- application/current specs passed with 118 examples, 0 failures
- web skeleton specs passed with 12 examples, 0 failures
- RuboCop passed with no offenses

Next:

- Continue through
  [Application Capsule Transfer Apply Execution Track](./application-capsule-transfer-apply-execution-track.md).
- The next cycle may introduce the first narrow mutable transfer boundary, but
  it must be explicit, refusal-first, dry-run by default, and limited to
  operation data produced by `ApplicationTransferApplyPlan`.
