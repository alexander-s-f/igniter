# Application Capsule Activation Guide Consolidation Track

This track consolidates the accepted capsule activation proof into compact
public and active-track documentation.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

Constraints:

- `:activation_safety` from [Constraint Sets](./constraints.md)
- [Host Activation Ledger Verification Receipt Track](./application-capsule-host-activation-ledger-verification-receipt-track.md)
- [Capsule Transfer Finalization Roadmap](./application-capsule-transfer-finalization-roadmap.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting ledger verification and
activation receipt.

The implementation path is now complete enough to explain plainly: transfer
receipt proves files moved, ledger activation receipt proves reviewed
application-owned confirmations were acknowledged, and real host/web activation
still remains out of scope.

## Goal

Make the current capsule transfer/activation story easy to read without walking
through every dev track.

The consolidated story must explain:

- transfer receipt vs activation receipt
- dry-run and commit-readiness stop line
- ledger adapter proof and its intentionally fake-host nature
- verification/readback before receipt
- rejected runtime/web activation behavior
- where Phase 5 web/host mount activation would start later

## Scope

In scope:

- guide consolidation in `docs/guide/application-capsules.md`
- compact `docs/dev/tracks.md` current-state update
- roadmap wording updates if needed
- example/catalog references if needed
- no package/runtime changes unless correcting a documentation mismatch

Out of scope:

- new activation behavior
- new receipt behavior
- real host activation
- web mount activation
- route binding
- Rack/browser traffic
- enterprise orchestration implementation
- showcase app implementation

## Task 1: Application Capsule Guide Consolidation

Owner: `[Agent Application / Codex]`

Acceptance:

- Ensure the public guide explains the accepted ledger-backed lifecycle:
  transfer receipt -> dry-run -> commit-readiness -> ledger commit ->
  ledger verification -> activation receipt.
- Make the non-activation boundary explicit and user-understandable.
- Keep code snippets aligned with
  `examples/application/capsule_host_activation_ledger_adapter.rb`.
- Avoid duplicating long dev-track rationale.

## Task 2: Web Boundary Language

Owner: `[Agent Web / Codex]`

Acceptance:

- Ensure guide/dev wording does not imply web mount activation is implemented.
- Make `review_mount_intent` and `web_leftovers` read as evidence/leftovers,
  not as route binding.
- Keep Phase 5 web/host mount activation separate.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
ruby examples/application/capsule_host_activation_ledger_adapter.rb
ruby examples/run.rb smoke
```

Run focused specs if package code changes.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` consolidates the guide-level activation story.
2. `[Agent Web / Codex]` guards wording around web/mount boundaries.
3. `[Architect Supervisor / Codex]` decides whether capsule transfer can pause
   as finalized-for-now and the team can return to showcase/app work.

[Agent Application / Codex]
track: `docs/dev/application-capsule-activation-guide-consolidation-track.md`
status: landed
delta: consolidated `docs/guide/application-capsules.md` around the accepted
  lifecycle: transfer receipt -> activation readiness/plan/verification ->
  dry-run -> commit-readiness -> ledger commit -> ledger verification ->
  separate activation receipt.
delta: clarified transfer receipt vs activation receipt: transfer receipt
  proves files moved and verified; activation receipt proves only
  ledger-backed acknowledgement/readback closure and does not replace the
  transfer receipt.
delta: made the non-activation boundary explicit: the file-backed ledger is a
  fake-host audit proof, not load path mutation, constant loading,
  provider/contract registration, app boot, web mount binding, route
  activation, Rack/browser traffic, contract execution, discovery, or cluster
  placement.
delta: updated the roadmap stop line and compact `tracks.md` current-state
  wording to reflect Phase 3/4 acceptance and guide consolidation as the active
  step.
verify: `git diff --check` passed.
verify: `ruby examples/application/capsule_host_activation_ledger_adapter.rb`
  passed.
verify: `ruby examples/run.rb smoke` passed, 76 examples.
ready: `[Agent Web / Codex]` can guard wording around `review_mount_intent`,
  `web_leftovers`, and Phase 5 mount activation; then `[Architect Supervisor /
  Codex]` can decide whether capsule transfer is finalized-for-now.
block: none

[Agent Web / Codex]
track: `docs/dev/application-capsule-activation-guide-consolidation-track.md`
status: landed
delta: tightened `docs/guide/application-capsules.md` wording so
  `web_leftovers` clearly means skipped mount work waiting for a future
  web/host-owned lane.
delta: confirmed the guide does not present `review_mount_intent`,
  `web_mount_adapter_evidence`, or `web_leftovers` as mount receipts, route
  binding, Rack calls, rendered screens, browser checks, or live web surfaces.
delta: Phase 5 web/host mount activation remains separate from the accepted
  ledger-backed activation proof.
verify: `git diff --check` passed.
verify: `ruby examples/application/capsule_host_activation_ledger_adapter.rb`
  passed.
ready: `[Architect Supervisor / Codex]` can decide whether capsule transfer is
  finalized-for-now.
block: none

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after guide review.

Accepted:

- The public guide now explains the accepted capsule lifecycle without requiring
  readers to reconstruct every dev track.
- Transfer receipt and activation receipt are clearly separate: transfer
  proves files moved; activation receipt proves only ledger-backed confirmation
  acknowledgement/readback closure.
- The file-backed ledger adapter is explicitly framed as a fake-host audit
  proof, not real host activation.
- The guide preserves the stop line: no load path mutation, constant loading,
  provider/contract registration, app boot, web mount binding, route
  activation, Rack/browser traffic, rendering, contract execution, discovery,
  or cluster placement.
- `review_mount_intent` and `web_leftovers` are framed as skipped future
  web/host-owned work, not as live web activation.

Decision:

- Capsule transfer and ledger-backed activation are finalized-for-now.
- Real host activation and web/host mount activation remain future tracks.
- Return the active workstream to practical showcase/application pressure.
- Open [Application Showcase Selection Track](./application-showcase-selection-track.md)
  to choose the first one-process reference app and define the minimum POC slice.

Verification:

- `git diff --check` passed.
- `ruby examples/application/capsule_host_activation_ledger_adapter.rb` passed.
- `ruby examples/run.rb smoke` passed with 76 examples and 0 failures.
