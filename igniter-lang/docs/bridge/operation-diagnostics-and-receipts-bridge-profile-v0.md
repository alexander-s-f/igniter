# Operation Diagnostics And Receipts Bridge Profile v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `igniter-lang/operation-diagnostics-and-receipts-bridge-profile-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Applied Pressure Agent]`

## Purpose

Prepare metadata-only bridge profiles for operation actions before package
work.

This note is generic. It must not create Spark-specific public package classes,
execute operations, call providers, mutate package code, or authorize external
bridge behavior.

## Current Horizon

- Operation actions need separate visible policy, executable authority,
  request receipt, execution receipt, and optional external bridge receipt.
- Observation evidence is the unit of trust; raw state values are not enough.
- Request actions and execution actions are separate result surfaces.
- Duplicate pending requests need idempotency/no-op evidence without hidden
  mutation.
- External bridges stay ESCAPE: capability-gated and receipt/failure-producing.

## Source Signals

[S] `spark-operation-action-lifecycle-pressure-v0` defines the approved pressure
surface: actor/order/schedule context, visible vs executable action policy,
request/execution receipts, duplicate pending request behavior, no-op pressure,
and optional external bridge receipts.

[S] `observable-spine-v0` provides the generic packet roles:
`constraint_observation`, `intent_observation`, `receipt_observation`,
`failure_observation`, and `platform_observation`.

[S] Current package inspection is read-only. `packages/igniter-contracts` has
`Igniter::Lang::VerificationReport` plus report-only metadata/diagnostic
precedent. `packages/igniter-application` has pending action and activation
receipt surfaces that may consume these profiles later, but should not be the
first semantic owner.

## Bridge Claim

[D] Operation action diagnostics should move into platform work first as
metadata-only profiles:

```text
OperationContext evidence
  -> ActionPolicyDiagnostic
  -> OperationIntent
  -> OperationRequestReceipt | OperationExecutionReceipt | OperationFailure
  -> optional ExternalOperationBridgeReceipt
```

[D] The first package target should be a generic diagnostic/receipt carrier,
not a Spark package surface and not an application mutation engine.

## Generic JSON Shapes

### ActionPolicyDiagnostic

```json
{
  "diagnostic_id": "operation_policy/fixture/action-001",
  "profile": "action_policy_diagnostic_v0",
  "action_ref": "operation_action/appointment_cancel_request",
  "action_kind": "request",
  "subject": {
    "subject_kind": "order_schedule",
    "subject_ref": "redacted:schedule:fixture-s-200",
    "order_ref": "redacted:order:fixture-o-200"
  },
  "actor": {
    "actor_ref": "redacted:actor:tech-17",
    "actor_kind": "user_like"
  },
  "decision": {
    "visible": true,
    "hidden": false,
    "executable": true,
    "compatibility_decision": "trusted"
  },
  "reasons": {
    "visible": ["actor_can_request_for_open_subject"],
    "hidden": [],
    "executable": ["fresh_context_policy_passed"]
  },
  "policy": {
    "policy_ref": "policy/appointment_policy@1",
    "policy_projection_ref": "obs/action-policy-projection-001",
    "policy_checked_at": "2026-05-06T13:00:00Z",
    "freshness": "current_context"
  },
  "evidence_links": {
    "operation_context_ref": "obs/operation-context-001",
    "actor_observation_ref": "obs/actor-001",
    "subject_observation_ref": "obs/subject-001",
    "schedule_state_ref": "obs/schedule-state-001",
    "action_config_ref": "obs/company-action-config-001"
  },
  "redaction_policy": {
    "profile": "operation_action_public_metadata_v0",
    "redacted_ref_kinds": ["actor", "user", "employee", "order", "schedule", "provider"],
    "raw_ref_export": false,
    "hash_source_refs": true
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "operation_execution_authorized": false,
    "external_bridge_authorized": false,
    "ledger_core": false
  }
}
```

Allowed policy reason families:

- `visible`: `actor_scope_matches`, `action_config_enabled`,
  `subject_state_visible`, `operator_visible`, `fresh_context_policy_passed`
- `hidden`: `action_config_disabled`, `actor_scope_denied`,
  `subject_state_hidden`, `policy_context_missing`, `privacy_redacted`
- `executable`: `fresh_context_policy_passed`, `capability_present`,
  `idempotency_clear`, `target_state_reachable`
- `blocked`: `policy_context_drift`, `capability_missing`,
  `duplicate_pending_request`, `already_in_target_state`,
  `state_transition_receipt_missing`

### OperationRequestReceipt

```json
{
  "receipt_id": "operation_request/fixture/req-001",
  "profile": "operation_request_receipt_v0",
  "request_ref": "operation_request/fixture/req-001",
  "operation_ref": "operation/fixture/cancel-request",
  "action_ref": "operation_action/appointment_cancel_request",
  "action_kind": "request",
  "request_status": "pending",
  "receipt_status": "created",
  "actor_ref": "redacted:actor:tech-17",
  "subject_refs": {
    "order_ref": "redacted:order:fixture-o-200",
    "schedule_ref": "redacted:schedule:fixture-s-200"
  },
  "idempotency": {
    "idempotency_key": "hash:idempotency/request/schedule/action/pending",
    "scope": ["subject_ref", "action_ref", "request_status"],
    "duplicate_of": null,
    "created_new_request": true,
    "side_effects_performed": false
  },
  "requested_at": "2026-05-06T13:10:00Z",
  "source": {
    "source_kind": "user_interface",
    "source_ref": "redacted:source:ui-session-001"
  },
  "evidence_links": {
    "operation_intent_ref": "obs/operation-intent-001",
    "policy_diagnostic_ref": "operation_policy/fixture/action-001",
    "subject_before_ref": "obs/schedule-state-before-001"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "operation_execution_authorized": false,
    "external_bridge_authorized": false,
    "ledger_core": false
  }
}
```

### OperationExecutionReceipt

```json
{
  "receipt_id": "operation_execution/fixture/exec-001",
  "profile": "operation_execution_receipt_v0",
  "execution_ref": "operation_execution/fixture/exec-001",
  "request_ref": null,
  "operation_ref": "operation/fixture/in-progress",
  "action_ref": "operation_action/appointment_in_progress",
  "action_kind": "execution",
  "execution_status": "succeeded",
  "failure_kind": null,
  "actor_ref": "redacted:actor:tech-17",
  "subject_refs": {
    "order_ref": "redacted:order:fixture-o-200",
    "schedule_ref": "redacted:schedule:fixture-s-200"
  },
  "state_transition": {
    "subject_ref": "redacted:schedule:fixture-s-200",
    "before_state_ref": "obs/schedule-state-before-001",
    "after_state_ref": "obs/schedule-state-after-001",
    "changed": true,
    "summary": {
      "status_from": "planned",
      "status_to": "in_progress"
    }
  },
  "performed_at": "2026-05-06T13:05:00Z",
  "evidence_links": {
    "operation_intent_ref": "obs/operation-intent-001",
    "policy_diagnostic_ref": "operation_policy/fixture/action-001",
    "capability_check_ref": "obs/capability-check-001"
  },
  "packet_links": {
    "caused_by": "obs/operation-intent-001",
    "checked_against": "operation_policy/fixture/action-001",
    "produced_by": "runtime/fixture-operation-executor",
    "produced_in": "run/fixture-operation-lifecycle-v0"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "operation_execution_authorized": false,
    "external_bridge_authorized": false,
    "ledger_core": false
  }
}
```

### Duplicate Pending Request / Idempotent No-Op

```json
{
  "receipt_id": "operation_request/fixture/req-001-duplicate",
  "profile": "operation_idempotency_receipt_v0",
  "operation_ref": "operation/fixture/cancel-request",
  "action_ref": "operation_action/appointment_cancel_request",
  "decision": "idempotent_no_op",
  "receipt_status": "duplicate_pending_suppressed",
  "original_request_ref": "operation_request/fixture/req-001",
  "duplicate_request_ref": "operation_intent/fixture/cancel-request-duplicate-001",
  "idempotency_key": "hash:idempotency/request/schedule/action/pending",
  "created_new_request": false,
  "state_changed": false,
  "side_effects_performed": false,
  "diagnostics": [
    {
      "code": "operation_request.duplicate_pending",
      "severity": "info",
      "message": "Duplicate pending request suppressed by metadata-only idempotency profile."
    }
  ],
  "evidence_links": {
    "original_request_receipt_ref": "operation_request/fixture/req-001",
    "duplicate_intent_ref": "obs/operation-intent-duplicate-001",
    "pending_request_read_ref": "obs/pending-request-read-001"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "operation_execution_authorized": false,
    "external_bridge_authorized": false,
    "ledger_core": false
  }
}
```

### Optional ExternalOperationBridgeReceipt

```json
{
  "receipt_id": "external_operation_bridge/fixture/bridge-001",
  "profile": "external_operation_bridge_receipt_v0",
  "bridge_kind": "provider_neutral_work_item",
  "operation_request_ref": "operation_request/fixture/req-001",
  "operation_execution_ref": null,
  "provider_ref": "redacted:provider:helpdesk",
  "external_subject_ref": "hash:external-subject/fixture-ticket-001",
  "provider_receipt_ref": "hash:provider-receipt/fixture-ticket-001",
  "bridge_status": "delivered",
  "failure_kind": null,
  "capability_ref": "capability/external_operation_bridge@fixture",
  "evidence_links": {
    "external_bridge_intent_ref": "obs/external-bridge-intent-001",
    "capability_check_ref": "obs/external-bridge-capability-check-001",
    "operation_request_receipt_ref": "operation_request/fixture/req-001"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "external_bridge_authorized": false,
    "provider_call_authorized": false,
    "ledger_core": false
  }
}
```

[D] This optional profile is only a receipt shape. It does not authorize a
provider call. A real bridge remains ESCAPE and needs declared capability,
intent, receipt/failure evidence, redaction review, and Architect approval.

## Redaction Policy

[D] Actor, order, schedule, provider, user-like, employee-like, source-session,
external-record, and customer-adjacent refs must default to redacted or hashed
forms in package diagnostics.

Rules:

- synthetic research refs may be shown in research docs
- package payloads default to `raw_ref_export: false`
- provider payloads, URLs, endpoints, tokens, credentials, queue names,
  customer names, phone numbers, emails, and infrastructure identifiers are not
  allowed in public diagnostic payloads
- source refs must preserve evidence identity without exposing raw provider or
  user data
- redaction omissions should still have stable content hashes when used as
  evidence links

## Package Touchpoint Recommendation

[R] First package touchpoint, if Architect approves:

```text
packages/igniter-contracts/
  Igniter::Lang::VerificationReport
  optional generic operation diagnostics / receipts payload section
```

Recommended first package surface:

```text
Igniter::Lang::OperationDiagnosticProfile
```

or, if the Architect wants smaller change surface:

```text
VerificationReport#metadata[:operation_diagnostics]
VerificationReport#metadata[:operation_receipts]
```

Why first:

- `igniter-contracts` already owns report-only Lang metadata and diagnostic
  precedent.
- It can carry generic policy/request/execution/idempotency/external-bridge
  metadata without executing operations.
- It keeps Spark, application readiness, Ledger, and provider bridges out of
  the first package slice.

Not first:

- `packages/igniter-application`: useful later for pending-action display and
  readiness consumption, but it should not define the generic semantic profile.
- `packages/igniter-ledger` / Ledger clients: useful later for durable
  transport and idempotency readback, but Ledger is a TBackend adapter, not
  language core.
- Spark-specific package classes: blocked by this bridge profile.

## Package Agent Approval / Blocker Note

[R] Package Agent may start only after explicit Architect Supervisor approval.
The approved slice should be metadata-only, generic, report-only, and should
preserve:

- `report_only: true`
- `runtime_enforced: false`
- required `evidence_links`
- redaction policy defaulting to no raw ref export
- no operation execution authorization
- no external provider call authorization
- no Ledger-as-core semantics

[X] Package Agent is blocked from:

- editing packages from this bridge slice
- creating Spark-specific public package classes
- implementing operation execution or provider bridge behavior
- enforcing application readiness from these profiles
- adding an idempotency store or mutating pending requests
- treating Ledger as required language core
- serializing raw actor/order/schedule/provider-like refs by default

## Explicitly Unauthorized

[X] No package edits in this bridge slice.

[X] No Spark-specific public package classes.

[X] No operation execution engine, provider bridge, or external call.

[X] No production migration behavior or schema migration coupling.

[X] No real Spark data, provider payloads, endpoints, credentials, customers,
phone numbers, emails, queue names, or infrastructure details.

[X] No application readiness enforcement.

[X] No Ledger-as-core semantics.

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/operation-diagnostics-and-receipts-bridge-profile-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent | Applied Pressure Agent

[D] Decisions:
- Prepared generic metadata-only profiles for ActionPolicyDiagnostic, OperationRequestReceipt, OperationExecutionReceipt, idempotent no-op/duplicate pending request, and optional ExternalOperationBridgeReceipt.
- Kept visible policy, executable authority, request receipts, execution receipts, and external bridge receipts separate.
- Preserved CORE / ESCAPE / OOF: policy diagnostics are report-only metadata; external bridge behavior remains capability-gated ESCAPE.
- Required evidence links and redaction policy for actor/order/schedule/provider-like refs.

[R] Recommendations:
- First package touchpoint should be packages/igniter-contracts as a generic report-only operation diagnostic/receipt carrier.
- Prefer VerificationReport metadata sections if Architect wants the smallest change; otherwise consider Igniter::Lang::OperationDiagnosticProfile.
- Keep igniter-application as a later consumer and Ledger as an optional TBackend/transport adapter.

[S] Signals:
- spark-operation-action-lifecycle-pressure-v0 is the approved source signal for operation policy and receipt semantics.
- observable-spine-v0 already has intent/receipt/failure/platform packet roles that match these profiles.
- Current package read-only inspection shows VerificationReport and schema diagnostic precedent in igniter-contracts.

[T] Tests / Proofs:
- Docs-only bridge slice. No package tests run.

[Files] Changed:
- igniter-lang/docs/bridge/operation-diagnostics-and-receipts-bridge-profile-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should the first package slice use VerificationReport metadata sections or a standalone OperationDiagnosticProfile class?
- Must every idempotent execution no-op emit a dedicated receipt, or can it link to prior receipt evidence?

[X] Rejected:
- Package edits in this slice.
- Spark-specific public package classes.
- Operation execution, provider calls, idempotency store mutation, application readiness enforcement, and Ledger-as-core.

[Next] Proposed next slice:
- Architect-reviewed package plan for a generic operation diagnostics/receipts carrier in igniter-contracts.
```
