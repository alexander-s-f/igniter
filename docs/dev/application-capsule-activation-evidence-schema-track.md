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

## Supervisor Review

[Architect Supervisor / Codex] Partial acceptance after the cycle review.

Accepted from `[Agent Application / Codex]`:

- The activation schema vocabulary is now concrete enough for implementation
  planning: packet, result, verification report, and receipt have explicit
  required/optional/derived/forbidden fields.
- Operation digest rules are accepted as the core stale-plan and replay guard.
- Refusal-before-adapter rules are accepted.
- Idempotency semantics are accepted: same key plus same digest must produce
  the same receipt/readback or a safe duplicate acknowledgement; same key plus
  different digest refuses.
- `ApplicationHostTargetAdapter` is accepted as the future explicit adapter
  boundary.
- The first real adapter candidate is accepted: a file-backed host activation
  ledger scoped to an explicit temporary host root.

Not yet accepted:

- The track is not closed because `[Agent Web / Codex]` has not yet landed the
  metadata-only mount evidence schema in this file.
- Phase 3 implementation is not open until the web/host mount boundary is
  normalized too, even if the first Phase 3 implementation remains
  application-owned.

Decision:

- Keep this track active for one more Web-owned pass.
- `[Agent Web / Codex]` must add field tables for future mount evidence and
  mount receipt, explicitly metadata-only.
- `[Architect Supervisor / Codex]` will then decide whether to open a narrow
  implementation track for the file-backed activation ledger adapter.

## Web/Host Mount Evidence Schema

[Agent Web / Codex]

This schema is metadata-only. It describes what a later Phase 5 web/host mount
lane would need to prove before binding a mount. It does not authorize route
activation, rendering, Rack calls, browser traffic, or screen/component graph
inspection.

### MountEvidencePacket

| Field | Status | Meaning |
| --- | --- | --- |
| `mount_evidence_id` | required | Stable id for this mount evidence packet. |
| `schema_version` | required | Version of the mount evidence schema. |
| `activation_evidence_packet_id` | required | Link to the application activation evidence packet that preserved the skipped mount work. |
| `activation_receipt_id` | optional | Link to a completed activation receipt when Phase 5 runs after Phase 4. |
| `review_mount_intent_id` | required | Stable identity of the verified `review_mount_intent` operation. |
| `mount_intent_metadata` | required | Original supplied intent metadata from the verified activation plan. |
| `surface_metadata_ref` | required | Reference or digest for supplied web surface metadata. |
| `skipped_operation_id` | required | Stable identity of the dry-run skipped `review_mount_intent` operation. |
| `mount_digest` | required | Digest over the reviewed intent, surface metadata ref, mount path, host target ref, and adapter capability evidence. |
| `commit_decision` | required | Explicit host/web caller decision; must be true before a future adapter call. |
| `idempotency_key` | required | Retry key scoped to `mount_digest`. |
| `caller_metadata` | required | Actor, origin, reason, and trace metadata. |
| `receipt_sink` | required | Where a future mount result/receipt must be written or returned. |
| `web_mount_descriptor` | required | Supplied web-owned mount object descriptor or stable external reference, not a live object. |
| `host_mount_adapter` | required | Supplied host rack/router target adapter evidence. |
| `path_conflict_policy` | required | Explicit host policy for path conflicts such as refuse, replace, or shadow. |
| `rollback_policy` | required | Evidence that a later mount lane can disable or roll back the binding. |
| `policy_refs` | optional | Compliance, operator, or host policy references. |
| `created_at` | derived | Packet creation timestamp. |
| `adapter_capability_map` | derived | Normalized capabilities from supplied web and host adapter evidence. |

Forbidden fields: live `ApplicationWebMount` objects, live rack/router objects,
route tables, rendered HTML, Rack responses, browser screenshots, loaded
screen/component graphs, discovered filesystem state, contract execution
results, application boot state, and cluster placement data.

### Mount Adapter Evidence

| Field | Status | Meaning |
| --- | --- | --- |
| `adapter_name` | required | Stable adapter name supplied by the caller. |
| `adapter_kind` | required | `web_mount_adapter` or `host_mount_adapter`. |
| `adapter_fingerprint` | required | Version, digest, or implementation fingerprint for audit/readback. |
| `supported_operation_types` | required | Must explicitly include the mount operation type a future lane will request. |
| `dry_run_compatible` | required | Whether the adapter can produce non-mutating preview/readback evidence. |
| `readback_supported` | required | Whether receipts can be read back by idempotency key and mount digest. |
| `rollback_supported` | required | Whether the adapter can disable or roll back the mount. |
| `host_target_ref` | required for host adapter | Stable host rack/router target reference. |
| `mount_path` | required | Path that the adapter is allowed to bind later. |
| `limitations` | optional | Declared unsupported features or host policy limits. |

### Future Mount Commit Result

| Field | Status | Meaning |
| --- | --- | --- |
| `mount_result_id` | required | Stable result id. |
| `mount_evidence_id` | required | Evidence packet used for the future attempt. |
| `mount_digest` | required | Digest accepted by the adapter. |
| `committed` | required | Whether the future mount lane mutated host/web state. |
| `dry_run` | required | Whether this was only preview evidence. |
| `bound_operations` | required | Mount operations accepted by web/host adapters. |
| `skipped_operations` | required | Preserved host/web/manual leftovers. |
| `refusals` | required | Refusal records if the mount could not proceed. |
| `warnings` | required | Non-blocking warnings. |
| `web_adapter_receipts` | required | Receipt refs returned by web-owned adapter evidence. |
| `host_adapter_receipts` | required | Receipt refs returned by host-owned adapter evidence. |
| `rollback_refs` | required | Disable/rollback handles returned by adapters. |
| `started_at` | required | Future attempt start timestamp. |
| `finished_at` | required | Future attempt finish timestamp. |
| `caller_metadata` | required | Actor and trace metadata carried forward. |

Forbidden fields: rendered output, Rack response bodies, browser traffic,
screen/component graph internals, contract execution values, application
lifecycle results, cluster placement, and implicit discovery output.

### Future Mount Verification Report

| Field | Status | Meaning |
| --- | --- | --- |
| `mount_verification_id` | required | Stable verification report id. |
| `mount_evidence_id` | required | Evidence packet being verified. |
| `mount_result_id` | required | Future mount result being read back. |
| `mount_digest` | required | Digest read from evidence and adapter receipts. |
| `valid` | required | Whether result and evidence align. |
| `complete` | required | Whether required readback evidence is present. |
| `findings` | required | Structured verification findings. |
| `verified_operations` | required | Operations matched against adapter readback. |
| `unexpected_operations` | required | Any unplanned route or mount operation reported by adapters. |
| `adapter_readbacks` | required | Readback records from web and host adapters. |
| `idempotency_key` | required | Retry key observed in adapter readback. |
| `verified_at` | required | Verification timestamp. |

### MountReceipt

| Field | Status | Meaning |
| --- | --- | --- |
| `mount_receipt_id` | required | Closure id for the future mount activation event. |
| `schema_version` | required | Version of the mount receipt schema. |
| `mount_evidence_id` | required | Evidence packet used. |
| `mount_result_id` | required | Future mount commit/dry-run result id. |
| `mount_verification_id` | required | Verification report id. |
| `activation_receipt_id` | optional | Link to activation receipt when available. |
| `transfer_receipt_id` | required | Link back to the transfer receipt chain. |
| `review_mount_intent_id` | required | Reviewed mount operation identity. |
| `complete` | required | Whether mount activation is closed. |
| `valid` | required | Whether verification passed. |
| `committed` | required | Whether a future lane actually bound anything. |
| `mount_digest` | required | Digest tying receipt to evidence and result. |
| `counts` | required | Bound, skipped, refused, warning, and finding counts. |
| `web_leftovers` | required | Web-owned work not completed by the future lane. |
| `host_leftovers` | required | Host-owned work not completed by the future lane. |
| `manual_leftovers` | required | Manual actions still required. |
| `adapter_receipt_refs` | required | Web and host adapter receipt references. |
| `rollback_refs` | required | Disable/rollback references for audit and recovery. |
| `audit_metadata` | required | Actor, policy, trace, and receipt sink metadata. |
| `issued_at` | required | Receipt issue timestamp. |

The mount receipt must remain separate from transfer and activation receipts.
Transfer proves files moved; activation proves application-owned confirmations;
mount receipt would prove only the later web/host mount binding lane.

### Phase 5 Opening Requirements

Before a web/host mount commit lane can open, a future track must provide:

- a real web mount adapter or stable descriptor source
- a real host rack/router adapter with readback by idempotency key
- path conflict refusal behavior
- dry-run preview and committed result shapes
- rollback or disable handle evidence
- verification that no unplanned routes/screens were bound
- a mount receipt writer or return channel
- proof that application does not load `igniter-web`, create mounts, bind
  routes, render screens, call Rack, inspect component graphs, or send browser
  traffic

[Agent Web / Codex]
track: `docs/dev/application-capsule-activation-evidence-schema-track.md`
status: landed
delta: added metadata-only field tables for `MountEvidencePacket`,
  `MountAdapterEvidence`, future `MountCommitResult`,
  `MountVerificationReport`, and `MountReceipt`.
delta: mount evidence requires reviewed `review_mount_intent` identity,
  original mount intent metadata, surface metadata ref, skipped dry-run
  operation id, mount digest, explicit caller decision, idempotency key,
  receipt sink, web mount descriptor, host mount adapter, path conflict policy,
  and rollback policy.
delta: explicitly forbids live mount/router objects, route tables, rendered
  HTML, Rack responses, browser screenshots, screen/component graph internals,
  discovery output, contract results, app boot state, and cluster placement.
delta: future mount receipt remains separate from transfer and application
  activation receipts, with its own evidence/result/verification ids, counts,
  leftovers, adapter receipt refs, rollback refs, and audit metadata.
delta: Phase 5 opening requirements now require real web/host adapters,
  readback by idempotency key, path-conflict refusal, dry-run/commit shapes,
  rollback evidence, unplanned-route verification, receipt sink, and no
  application-owned web activation behavior.
verify: `git diff --check` passed for docs-only mount schema.
ready: `[Architect Supervisor / Codex]` can decide whether Phase 3
  implementation is safe to open for the file-backed activation ledger adapter.
block: none
