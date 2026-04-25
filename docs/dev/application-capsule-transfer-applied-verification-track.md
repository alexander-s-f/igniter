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
