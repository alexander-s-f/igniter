# Application Capsule Transfer Receipt Track

This track follows the accepted capsule transfer applied verification cycle.

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

Igniter now has a full explicit transfer chain: plan, artifact, verification,
intake, apply plan, dry-run-first execution, and post-apply verification. The
next step is not more mutation. The next step is a compact transfer receipt:
one read-only audit artifact that summarizes what was reviewed, applied,
verified, refused, skipped, and still requires human action.

This receipt is useful for humans, agents, CI logs, and future private
pressure-tests because it gives a stable final handoff without rereading every
intermediate artifact.

## Goal

Design and land the smallest transfer receipt:

- accept explicit applied verification and optional upstream transfer reports
- summarize subject, artifact path, destination root, committed/valid status
- preserve counts for planned/applied/verified/findings/refusals/skipped
- summarize required manual host wiring as review-only
- preserve/count supplied web surface metadata without interpreting web
  internals
- expose stable `to_h`
- print deterministic smoke output using a temp committed and verified apply

The receipt should answer: "What was transferred, was it verified, and what
still needs manual attention?"

## Scope

In scope:

- application-owned read-only receipt value/report
- facade such as `Igniter::Application.transfer_receipt(...)`
- composition over explicit already-built transfer reports
- deterministic smoke example
- web compatibility review for metadata preservation only

Out of scope:

- creating directories
- copying files
- repairing files
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

- The receipt must be read-only.
- It must consume explicit reports/hashes; it must not discover missing
  upstream artifacts.
- It must not re-run apply execution or applied verification.
- It may classify status from supplied reports, but must not repair or mutate.
- Web metadata remains supplied/opaque; application may count or preserve it,
  but must not inspect web internals.

## Task 1: Receipt Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned value/report, for example
  `ApplicationTransferReceipt`.
- Add a public facade, for example
  `Igniter::Application.transfer_receipt(applied_verification, apply_result: nil, apply_plan: nil, metadata: {})`.
- Accept value objects or compatible serialized hashes.
- Include stable `complete`, `valid`, `committed`, `artifact_path`,
  `destination_root`, `counts`, `manual_actions`, `findings`, `refusals`,
  `skipped`, `surface_count`, and `metadata` keys in `to_h`.
- Do not create, copy, write, delete, repair, load, boot, mount, route, execute,
  or coordinate clusters.

## Task 2: Smoke Example

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_transfer_receipt.rb`

Acceptance:

- Build a temp committed apply and applied verification.
- Produce a read-only transfer receipt.
- Print compact smoke keys for complete flag, valid flag, committed flag,
  verified count, finding count, refusal count, skipped count, manual action
  count, and surface count.
- Keep the example deterministic and safe for clean checkouts.

Suggested smoke keys:

```text
application_capsule_transfer_receipt_complete=...
application_capsule_transfer_receipt_valid=...
application_capsule_transfer_receipt_committed=...
application_capsule_transfer_receipt_verified=...
application_capsule_transfer_receipt_findings=...
application_capsule_transfer_receipt_refusals=...
application_capsule_transfer_receipt_skipped=...
application_capsule_transfer_receipt_manual=...
application_capsule_transfer_receipt_surfaces=...
```

## Task 3: Web Metadata Compatibility

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify that the receipt preserves/counts supplied web metadata without
  requiring `igniter-web`.
- Confirm no web-specific receipt behavior is introduced.
- Add a package README note only if the receipt boundary is otherwise hard to
  discover.
- Do not add web-specific receipt behavior to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_receipt.rb
ruby examples/application/capsule_transfer_applied_verification.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web package code or docs examples change, include the relevant
`packages/igniter-web/spec` slice.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with read-only
   receipt generation.
2. `[Agent Web / Codex]` performs Task 3 as a boundary check only.
3. Keep this as audit/closure reporting. Do not add mutation, repair, web
   activation, app boot, routing, contract execution, discovery, or cluster
   placement.
