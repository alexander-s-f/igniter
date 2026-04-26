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

[Agent Application / Codex]
track: `docs/dev/application-capsule-activation-evidence-schema-track.md`
status: landed
delta: `ActivationEvidencePacket` schema:
  required fields are `packet_id`, `schema_version`, `transfer_receipt_id`,
  `activation_readiness_id`, `activation_plan_id`,
  `activation_plan_verification_id`, `activation_dry_run_id`,
  `commit_readiness_id`, `operation_digest`, `commit_decision`,
  `idempotency_key`, `caller_metadata`, `receipt_sink`, and
  `application_host_adapter`.
delta: `ActivationEvidencePacket` optional fields are `policy_refs`,
  `reviewer_refs`, `expires_at`, and `notes`; derived fields are
  `created_at`, `operation_count`, `would_apply_count`, `skipped_count`, and
  `adapter_capability_map`; forbidden fields are live host objects, constants,
  loaded classes, Rack apps, route tables, rendered output, contract results,
  cluster placement data, and discovery results.
delta: `ActivationCommitResult` schema:
  required fields are `result_id`, `packet_id`, `operation_digest`,
  `committed`, `dry_run`, `applied_operations`, `skipped_operations`,
  `refusals`, `warnings`, `adapter_receipts`, `started_at`, `finished_at`,
  and `caller_metadata`; forbidden fields are runtime execution outputs,
  contract values, rendered screens, Rack/browser responses, and implicit
  host-discovery output.
delta: `ActivationVerificationReport` schema:
  required fields are `verification_id`, `packet_id`, `result_id`,
  `operation_digest`, `valid`, `complete`, `findings`,
  `verified_operations`, `unexpected_operations`, `adapter_readbacks`,
  `idempotency_key`, and `verified_at`; derived fields include applied,
  skipped, refused, warning, and finding counts.
delta: `ActivationReceipt` schema:
  required fields are `activation_receipt_id`, `schema_version`,
  `transfer_receipt_id`, `packet_id`, `result_id`, `verification_id`,
  `complete`, `valid`, `committed`, `operation_digest`, `counts`,
  `manual_leftovers`, `host_leftovers`, `web_leftovers`,
  `adapter_receipt_refs`, `audit_metadata`, and `issued_at`; it must not merge
  into or replace the transfer receipt.
delta: operation digest normalization: sort operations by stable operation id;
  include operation id, type, target, normalized metadata, source artifact
  identity, skipped/manual/web-owned operation identities, and accepted adapter
  capability requirements; stringify symbol keys, sort map keys, omit volatile
  timestamps, and refuse if any normalized input differs from the verified
  plan/dry-run/commit-readiness chain.
delta: refusal-before-adapter rules: refuse missing required fields, unsupported
  schema version, `commit_decision` other than explicit `true`, missing or
  expired idempotency key, stale evidence identity, digest mismatch,
  non-executable dry-run, committed dry-run evidence, dry-run refusals,
  missing adapter capability, unsupported operation type, requested host/manual/
  web work as application-owned, receipt sink absence, or any discovery/
  implicit destination input.
delta: idempotency semantics: the same `idempotency_key` plus
  `operation_digest` must return the same adapter receipts or a safe duplicate
  acknowledgement; a reused key with a different digest is a refusal; adapter
  readback must expose the key for verification.
delta: adapter contract: the first implementation requires a real
  caller-supplied `ApplicationHostTargetAdapter` that supports dry-run
  compatibility, explicit capabilities for `confirm_load_path`,
  `confirm_provider`, `confirm_contract`, and `confirm_lifecycle`, stable
  adapter fingerprint/version, per-operation receipt ids, readback by
  idempotency key, and refusal reporting; no registry lookup or ambient
  discovery is allowed.
delta: first real adapter candidate: a file-backed host activation ledger
  adapter scoped to an explicit temporary host root is the smallest acceptable
  Phase 3 proof because it can acknowledge confirmations and read receipts back
  without loading constants, mutating runtime state, booting apps, binding web,
  or executing contracts.
verify: `git diff --check` passed for docs-only schema.
ready: `[Agent Web / Codex]` can add metadata-only mount evidence schema, then
  `[Architect Supervisor / Codex]` can decide whether Phase 3 implementation is
  compact and safe enough to open.
block: none
