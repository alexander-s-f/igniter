# Application Capsule Host Activation Evidence And Receipt Track

This track defines the evidence and receipt shape required before any future
activation commit implementation.

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
- [Activation Commit Boundary Review](./application-capsule-host-activation-commit-boundary-review-track.md)

## Decision

[Architect Supervisor / Codex] Accepted as the next docs/design slice.

The boundary review did not authorize immediate activation commit
implementation. It authorized only the next design step: define the exact
evidence packet and receipt/audit shape a future narrow commit would require.

## Goal

Define the minimum evidence and receipt vocabulary for a future adapter-backed
activation commit.

The result must make clear:

- what evidence enters a future commit
- what operation digest or plan identity must match
- what adapters are explicit
- what a future commit result would report
- how post-commit verification would read back evidence
- how activation receipt stays separate from transfer receipt

## Scope

In scope:

- docs/design only
- evidence packet fields
- operation digest/identity requirements
- adapter evidence fields
- commit result report shape
- post-commit verification requirements
- activation receipt requirements
- web/host mount evidence as future Phase 5 metadata only

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

## Task 1: Application Evidence And Receipt Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Define the future activation evidence packet.
- Define plan/operation digest matching requirements.
- Define future commit result and verification report fields.
- Define activation receipt closure fields.
- Keep transfer receipt separate from activation receipt.

## Task 2: Web/Host Mount Evidence Shape

Owner: `[Agent Web / Codex]`

Acceptance:

- Define mount evidence as explicit web/host-supplied metadata only.
- Keep route binding, rendering, Rack calls, browser traffic, and screen graph
  inspection out of this phase.
- Define what a future web/host mount receipt would need if Phase 5 opens.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

If code changes, the track is out of scope and must return to supervisor.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` defines activation evidence, commit result,
   verification, and receipt vocabulary.
2. `[Agent Web / Codex]` defines mount evidence/receipt boundaries without
   activation behavior.
3. `[Architect Supervisor / Codex]` decides whether a future narrow
   implementation track is safe enough to open.

[Agent Application / Codex]
track: `docs/dev/application-capsule-host-activation-evidence-receipt-track.md`
status: landed
delta: future `ActivationEvidencePacket` should include transfer receipt
  identity, activation readiness identity, verified plan identity,
  verification identity, dry-run identity, commit-readiness identity,
  operation digest, explicit `commit: true`, idempotency key, caller metadata,
  receipt sink, and supplied adapter evidence.
delta: operation digest must be computed over the verified plan operation ids,
  operation types, targets, normalized metadata, skipped/manual/web-owned
  operation identities, and source artifact identities; any mismatch refuses
  before adapter calls.
delta: adapter evidence must be explicit and caller-supplied: application host
  target adapter name/kind/capabilities, adapter version or fingerprint,
  supported operation types, dry-run compatibility marker, and receipt/readback
  support; no discovery or ambient adapter lookup.
delta: future `ActivationCommitResult` should report committed/dry-run flags,
  evidence packet id, operation digest, applied application-owned operations,
  skipped host/manual/web operations, refusals, warnings, adapter receipts,
  timestamps, caller metadata, and no contract/runtime execution results.
delta: post-commit verification must read adapter receipts back against the
  verified plan and evidence packet, checking operation identity, adapter
  acknowledgement, idempotency key, applied/skipped/refused counts, and absence
  of unplanned operations.
delta: `ActivationReceipt` should close only activation, with activation
  receipt id, linked transfer receipt id, evidence packet id, commit result id,
  verification id, complete/valid/committed booleans, counts, findings,
  manual/web/host leftovers, adapter receipt refs, and audit metadata.
delta: transfer receipt remains separate: it proves files moved and verified;
  activation receipt proves only the later adapter-backed activation decision.
delta: recommendation: keep this as a required design artifact before any
  runtime commit track; if the packet/result/verification/receipt shape is too
  heavy to implement narrowly, pause at commit-readiness.
verify: `git diff --check` passed for docs-only evidence/receipt shape.
ready: `[Agent Web / Codex]` can define web/host mount evidence and future
  mount receipt boundaries; `[Architect Supervisor / Codex]` can then decide
  whether any narrow implementation track is safe.
block: none
