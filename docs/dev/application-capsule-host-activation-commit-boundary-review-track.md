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
