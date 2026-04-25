# Application Capsule Host Activation Execution Boundary Track

This track follows the accepted host activation guide consolidation cycle.

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

[Architect Supervisor / Codex] Accepted as the next implementation-boundary
track.

The review chain is now complete through verified activation intent. The next
question is whether Igniter is ready to define a first mutable activation
boundary. This track is a design/boundary track first. It must not implement
activation execution unless a later supervisor decision explicitly narrows and
accepts a safe executable slice.

## Goal

Define the activation execution boundary before any mutation exists:

- which reviewed operations belong to application-owned host activation
- which operations remain host-owned only
- which operations remain web-owned only
- which operations are too risky for v1
- what preconditions, refusal rules, and receipts would be required if a
  future execution slice is accepted

The output should answer: "What would it mean to execute activation safely, and
what must still remain manual or package-owned?"

## Scope

In scope:

- docs/design over the accepted readiness/plan/verification chain
- mapping operation types to possible future owners
- refusal-first preconditions for any future execution boundary
- receipt/report requirements for a future mutable activation slice
- web boundary review for mount-related operations

Out of scope:

- implementing activation execution
- mutating host wiring
- modifying load paths
- loading constants
- registering providers/contracts
- booting apps or providers
- binding mounts
- activating routes
- browser traffic
- contract execution
- project-wide discovery
- cluster placement

## Task 1: Application Execution Boundary Map

Owner: `[Agent Application / Codex]`

Acceptance:

- Draft the smallest public/dev boundary section or track note that maps
  current activation plan operations to ownership:
  `confirm_host_export`, `confirm_host_capability`, `confirm_load_path`,
  `confirm_provider`, `confirm_contract`, `confirm_lifecycle`,
  `acknowledge_manual_actions`, and `review_mount_intent`.
- Separate review-only, possible future application-owned, host-owned, and
  web-owned operations.
- Define refusal-first preconditions for any future execution: verified plan,
  explicit commit, explicit host target, no unresolved blockers/findings, no
  implicit discovery, no ambient constant loading.
- Define the receipt/report shape a future execution would need.
- Do not add runtime code, facades, examples, or mutation.

## Task 2: Web Execution Boundary Map

Owner: `[Agent Web / Codex]`

Acceptance:

- Map `review_mount_intent` to future web-owned/host-owned activation only.
- Confirm application must not bind web mounts, activate routes, inspect screen
  graphs, render, or send browser traffic.
- Define what evidence a future web-owned activation adapter would need before
  it could be proposed.
- Do not add runtime code, route activation, mount binding, rendering, or
  browser traffic.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

No tests are required unless implementation files change, which this track
should avoid.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 as a boundary/design pass only.
2. `[Agent Web / Codex]` performs Task 2 as web ownership review only.
3. Do not add executable activation behavior, host mutation, loading, boot,
   provider/contract registration, mount binding, route activation, browser
   traffic, contract execution, discovery, or cluster placement.
