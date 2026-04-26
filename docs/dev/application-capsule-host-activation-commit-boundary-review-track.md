# Application Capsule Host Activation Commit Boundary Review Track

This track decides whether a future activation commit implementation should
exist, and if so, what the smallest safe boundary is.

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
- [Capsule Transfer Finalization Roadmap](./application-capsule-transfer-finalization-roadmap.md)

## Decision

[Architect Supervisor / Codex] Accepted as the next docs/design slice.

Do not implement activation commit in this track. The goal is to decide whether
Phase 3 of the finalization roadmap should exist.

## Goal

Define a safe activation commit boundary over existing verified activation
plan, dry-run, and commit-readiness evidence.

The review must answer:

- which operations, if any, can be application-owned
- which operations remain host-owned/manual/web-owned
- what explicit adapter evidence is mandatory
- what must still be refused
- what verification and receipt would be required after any future commit

## Scope

In scope:

- docs/design analysis
- allowed/refused operation matrix
- adapter evidence requirements
- activation verification/receipt requirements
- recommendation: implement narrow commit, add another dry-run proof, or pause

Out of scope:

- Ruby implementation
- commit mode
- host mutation
- load path mutation
- constant loading/discovery
- provider/contract registration
- app boot
- mount binding
- route activation
- rendering/Rack/browser traffic
- contract execution
- cluster placement

## Task 1: Application Commit Boundary

Owner: `[Agent Application / Codex]`

Acceptance:

- Review existing activation readiness/plan/verification/dry-run/commit
  readiness artifacts.
- Propose the smallest possible application-owned commit boundary, or recommend
  pause.
- Define mandatory explicit host target/adapter evidence.
- Define post-commit verification and receipt needs.

## Task 2: Web/Host Mount Boundary

Owner: `[Agent Web / Codex]`

Acceptance:

- Review `review_mount_intent` and web adapter evidence boundaries.
- State what remains web-owned or host-owned.
- Define what evidence a future web mount adapter would have to provide without
  activating routes in this track.
- Reject screen inspection, rendering, Rack calls, browser traffic, and web
  route binding for this phase.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

If code changes, the track is out of scope and must return to supervisor.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` maps application-owned commit boundary options.
2. `[Agent Web / Codex]` maps web/host mount evidence boundaries.
3. `[Architect Supervisor / Codex]` decides whether a future implementation
   track is accepted, narrowed, or paused.

[Agent Application / Codex]
track: `docs/dev/application-capsule-host-activation-commit-boundary-review-track.md`
status: landed
delta: application-owned commit boundary should be limited to adapter-backed
  confirmation of already verified `confirm_load_path`, `confirm_provider`,
  `confirm_contract`, and `confirm_lifecycle` operations.
delta: application must not own host exports/capabilities, manual host wiring,
  `review_mount_intent`, web route binding, runtime boot, constant loading,
  contract execution, browser/Rack traffic, or cluster placement.
delta: mandatory evidence: complete transfer receipt, verified activation plan,
  dry-run result, commit-readiness with `commit_allowed`, exact plan/operation
  digest, explicit `commit: true` decision, explicit host target adapter,
  adapter capability map, idempotency key, caller metadata, and receipt sink.
delta: refusal matrix: refuse missing/stale evidence, committed dry-run input,
  non-executable dry-run, dry-run refusals, missing adapter evidence, operation
  digest mismatch, unsupported operation type, skipped host/manual/web work
  requested as application-owned, or any discovery/implicit destination.
delta: post-commit verification must read adapter-returned operation receipts
  back against the verified plan and produce a separate activation receipt;
  transfer receipt remains separate from activation receipt.
delta: recommendation: do not implement broad activation commit; accept only a
  future narrow adapter-backed commit track after the adapter evidence and
  activation receipt shape are documented, otherwise pause at readiness.
verify: `git diff --check` passed for docs-only boundary review.
ready: `[Agent Web / Codex]` can map web/host mount evidence boundaries, then
  `[Architect Supervisor / Codex]` can narrow or pause Phase 3.
block: none

[Agent Web / Codex]
track: `docs/dev/application-capsule-host-activation-commit-boundary-review-track.md`
status: landed
delta: `review_mount_intent` should remain skipped web/host-owned evidence in
  any future narrow application activation commit; it must not become an
  application-owned operation in Phase 3.
delta: future web mount adapter evidence should be explicit plain evidence:
  verified `review_mount_intent` operation, original intent metadata, explicit
  caller decision, supplied web-owned mount object or equivalent descriptor,
  supplied host rack/router target adapter, idempotency key, caller metadata,
  and receipt sink.
delta: web-owned work remains creation/binding of `ApplicationWebMount` or
  equivalent web mount objects, route table activation, screen/render behavior,
  Rack handling, browser checks, and any component/screen graph interpretation.
delta: host-owned work remains rack/router integration, host runtime wiring,
  mount path conflict checks, network exposure, auth/session policy, and
  operational rollback/disable controls.
delta: refused for this phase: screen inspection, rendering, Rack calls,
  browser traffic, route binding, mount binding, implicit web discovery,
  application-to-web dependency, treating `web_mount_adapter_evidence` as a
  live adapter, or converting skipped mount review into applied activation.
delta: recommendation: allow a future Phase 3 only for narrow application-owned
  confirmations; keep web mount activation for Phase 5 with a separate
  web/host adapter, verification, and activation receipt.
verify: `git diff --check` passed for docs-only boundary review.
ready: `[Architect Supervisor / Codex]` can narrow Phase 3 or pause activation
  commit after verification.
block: none

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the cycle review.

Accepted:

- A broad activation commit remains rejected.
- A future Phase 3 may exist only as a narrow, adapter-backed application-owned
  confirmation boundary over already verified `confirm_load_path`,
  `confirm_provider`, `confirm_contract`, and `confirm_lifecycle` operations.
- Application must not own host exports/capabilities, manual host wiring,
  `review_mount_intent`, web route binding, runtime boot, constant loading,
  contract execution, browser/Rack traffic, or cluster placement.
- Mandatory future evidence includes complete transfer receipt, verified
  activation plan, dry-run result, commit-readiness with `commit_allowed`, exact
  plan/operation digest, explicit `commit: true`, explicit host target adapter,
  adapter capability map, idempotency key, caller metadata, and receipt sink.
- Web mount activation remains Phase 5 web/host-owned work. `review_mount_intent`
  is not application-owned commit work.

Decision:

- Do not open runtime implementation yet.
- Open [Application Capsule Host Activation Evidence And Receipt Track](./application-capsule-host-activation-evidence-receipt-track.md)
  to define evidence, commit-result, verification, and receipt shapes first.

Verification:

- `git diff --check` passed.
