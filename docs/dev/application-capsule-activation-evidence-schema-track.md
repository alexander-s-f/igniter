# Application Capsule Activation Evidence Schema Track

This track turns the accepted activation evidence vocabulary into a normative
schema before any mutable activation commit implementation.

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
- [Activation Evidence And Receipt Track](./application-capsule-host-activation-evidence-receipt-track.md)
- [Capsule Transfer Expert Report](../experts/capsule-transfer-expert-report.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting the evidence/receipt
handoff.

The previous track established the right vocabulary. This track must make that
vocabulary precise enough that a later implementation cannot guess field names,
identity rules, adapter semantics, or receipt closure rules.

## Goal

Define the minimum normative schema for a future narrow activation commit.

The result must make clear:

- exact packet/result/verification/receipt fields
- required vs optional fields
- stable identity and digest rules
- refusal conditions before adapter calls
- adapter evidence contract and readback guarantees
- the first real adapter candidate needed before implementation opens

## Scope

In scope:

- docs/design only
- schema tables for activation evidence packet, commit result, verification
  report, and activation receipt
- operation digest inputs and mismatch refusal rules
- idempotency key semantics
- adapter evidence contract
- first real adapter candidate recommendation
- agent-readable structured result requirements

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
- enterprise orchestration implementation

## Task 1: Normative Activation Schema

Owner: `[Agent Application / Codex]`

Acceptance:

- Define field tables for:
  - `ActivationEvidencePacket`
  - `ActivationCommitResult`
  - `ActivationVerificationReport`
  - `ActivationReceipt`
- Mark each field as required, optional, derived, or forbidden.
- Define operation digest inputs and stable normalization rules.
- Define refusal conditions before adapter calls.
- Define idempotency semantics and retry/readback expectations.
- Recommend the first real adapter candidate required before opening
  implementation.

## Task 2: Mount Evidence Schema Boundary

Owner: `[Agent Web / Codex]`

Acceptance:

- Define field tables for future web/host mount evidence and mount receipt.
- Keep the schema metadata-only for this phase.
- Explicitly forbid live route table inspection, rendering, Rack calls,
  browser traffic, and component graph inspection in this track.
- Define what must be proved later before a web/host mount commit lane opens.

## Supervisor Review Questions

[Architect Supervisor / Codex] will decide:

- whether the schema is compact enough to implement without heavy ceremony
- whether the first adapter candidate is real enough to test the evidence model
- whether Phase 3 can open as a narrow implementation track
- or whether capsule transfer should pause at commit-readiness for now

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

If code changes, the track is out of scope and must return to supervisor.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` converts activation evidence/receipt
   vocabulary into normative schema and adapter contract.
2. `[Agent Web / Codex]` converts mount evidence/receipt boundary into
   metadata-only schema.
3. `[Architect Supervisor / Codex]` decides whether Phase 3 implementation is
   safe to open.
