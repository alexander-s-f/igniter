# Application Capsule Transfer Guide Consolidation Track

This track follows the accepted capsule transfer receipt cycle.

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

The transfer chain is now complete enough to stop adding runtime machinery for
one cycle and make the user path coherent. The goal is a compact public story
and a runnable end-to-end smoke that shows the complete journey from capsule
declaration to transfer receipt.

This is a consolidation track, not a new capability track.

## Goal

Make the transfer path easy for a user or agent to follow:

- capsule declaration
- transfer inventory
- transfer readiness
- bundle plan
- bundle artifact write
- bundle verification
- intake plan
- apply plan
- dry-run apply
- committed apply
- applied verification
- transfer receipt

The output should answer: "How do I move one capsule from source review to a
verified receipt without learning every internal track document?"

## Scope

In scope:

- public guide wording in `docs/guide/application-capsules.md`
- current-state wording in `docs/current/app-structure.md`
- package-local README wording if the web boundary needs a short note
- one deterministic end-to-end example if it materially improves onboarding
- examples catalog registration if an example is added
- compact index updates for agent drill-down

Out of scope:

- new runtime value objects
- new facades
- changing transfer semantics
- applying host wiring
- activating web mounts/routes
- project-wide discovery
- install/extract automation
- cluster placement
- private app-specific material

## Task 1: End-To-End Public Path

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_transfer_end_to_end.rb`

Acceptance:

- Demonstrate the complete public transfer path from capsule declaration to
  transfer receipt.
- Include both dry-run apply and committed apply in the example.
- Print compact deterministic smoke keys for the major chain states, including
  readiness, bundle allowed, verification valid, intake accepted, apply
  executable, dry-run committed flag, committed flag, applied verification
  valid flag, and receipt complete flag.
- Use only temp directories and deterministic local files.
- Register the example in the active examples catalog if added.
- Do not add new runtime classes, facades, or transfer semantics.

Suggested smoke keys:

```text
application_capsule_transfer_end_to_end_ready=...
application_capsule_transfer_end_to_end_bundle_allowed=...
application_capsule_transfer_end_to_end_bundle_verified=...
application_capsule_transfer_end_to_end_intake_accepted=...
application_capsule_transfer_end_to_end_apply_executable=...
application_capsule_transfer_end_to_end_dry_run_committed=...
application_capsule_transfer_end_to_end_committed=...
application_capsule_transfer_end_to_end_applied_valid=...
application_capsule_transfer_end_to_end_receipt_complete=...
```

## Task 2: Guide Consolidation

Owner: `[Agent Application / Codex]`

Acceptance:

- Update `docs/guide/application-capsules.md` so a reader sees the complete
  transfer chain in one coherent section.
- Keep the boundary language clear: review artifacts are read-only until the
  explicit dry-run-first apply execution boundary.
- Make receipt the final audit/closure artifact.
- Keep host wiring manual and web activation out of the transfer chain.
- Keep wording compact; link examples instead of copying long code.

## Task 3: Web Boundary Review

Owner: `[Agent Web / Codex]`

Acceptance:

- Review the guide and any package README note for web boundary accuracy.
- Confirm web metadata is described as supplied/opaque context.
- Confirm the transfer path does not imply web route activation, screen
  inspection, mount binding, browser traffic, or a dependency from
  `igniter-application` to `igniter-web`.
- Add only small wording fixes if needed.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_end_to_end.rb
ruby examples/application/capsule_transfer_receipt.rb
bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb
```

If web package wording or web examples change, include:

```bash
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

If no end-to-end example is added, the agent must explain why the existing
examples already provide an equally compact user path.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 as a docs/example
   consolidation pass.
2. `[Agent Web / Codex]` performs Task 3 as boundary review only.
3. Keep this cycle user-facing and stabilizing. Do not add new transfer
   machinery, web activation, host wiring automation, discovery, contract
   execution, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-transfer-guide-consolidation-track.md`
Status: landed.
Changed:
- Added `examples/application/capsule_transfer_end_to_end.rb`.
- Registered the end-to-end example in the active examples catalog and README.
- Consolidated `docs/guide/application-capsules.md` with a complete
  declaration-to-receipt transfer path.
- Updated current app structure and runtime snapshot docs to reference the
  compact end-to-end smoke path.
Accepted:
- The example demonstrates capsule declaration, transfer inventory, transfer
  readiness, bundle plan, bundle artifact write, bundle verification,
  destination intake, apply planning, dry-run apply, committed apply, applied
  verification, and final receipt.
- The guide calls out that only committed apply mutates the destination
  filesystem and that mutation is limited to reviewed directory/file
  operations.
- Host wiring remains manual review data.
- Web surface metadata remains supplied/opaque context and does not imply web
  route activation, mount binding, browser traffic, or an `igniter-web`
  dependency.
- No new runtime classes, facades, transfer semantics, discovery, host wiring
  automation, web activation, contract execution, or cluster placement was
  introduced.
Verification:
- `ruby examples/application/capsule_transfer_end_to_end.rb` passed.
- `ruby examples/application/capsule_transfer_receipt.rb` passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed with 132 examples, 0 failures.
- `ruby examples/run.rb smoke` passed with 68 examples, 0 failures.
- `bundle exec rubocop examples/application/capsule_transfer_end_to_end.rb examples/catalog.rb`
  passed with no offenses.
Needs:
- `[Agent Web / Codex]` can perform Task 3 boundary wording review for the
  consolidated transfer guide.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-transfer-guide-consolidation-track.md`
Status: landed.
Changed:
- Reviewed the consolidated capsule transfer guide and end-to-end smoke path
  against the web/application boundary.
- Added a short `packages/igniter-web/README.md` note pointing to the complete
  end-to-end transfer example.
Accepted:
- The consolidated transfer guide describes web surface metadata as supplied
  opaque context.
- The end-to-end transfer example uses plain surface metadata hashes and does
  not require `igniter-web`.
- The transfer path does not imply web route activation, screen/component
  inspection, mount binding, browser traffic, or an `igniter-application`
  dependency on `igniter-web`.
Verification:
- `ruby examples/application/capsule_transfer_end_to_end.rb` passed.
- `ruby examples/application/capsule_transfer_receipt.rb` passed.
- `bundle exec rspec spec/current/example_scripts_spec.rb packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed.
- `bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb`
  passed.
- `git diff --check` passed.
Needs:
- `[Architect Supervisor / Codex]` review/accept the consolidated transfer
  guide track and choose the next broad handoff.
