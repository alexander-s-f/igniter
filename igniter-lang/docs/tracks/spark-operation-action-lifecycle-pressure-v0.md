# Track: Spark Operation Action Lifecycle Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/spark-operation-action-lifecycle-pressure-v0.md`
Status: done
Slice state: done on 2026-05-06
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track prepares the third Spark operational pressure slice after
technician availability and lead signals. It turns order/schedule operation
actions into language pressure around actor scope, visible action policy,
executable action checks, request receipts, execution receipts, duplicate
pending request behavior, state transitions, and optional external bridge
receipts.

Safety boundary:

- synthetic IDs only;
- no real Spark data, customers, tenants, employees, phone numbers, endpoint
  paths, URLs, provider payloads, tokens, secrets, credentials, queue names, or
  infrastructure details;
- fixture is business-logic pressure, not a Spark implementation.

## Source Horizon

- `igniter-lang/docs/tracks/spark-crm-applied-language-pressure-v0.md`
- `igniter-lang/docs/tracks/spark-crm-real-business-candidate-map-v0.md`
- `igniter-lang/docs/tracks/spark-technician-availability-fixture-pressure-v0.md`
- `igniter-lang/docs/tracks/spark-lead-signal-boundary-pressure-v0.md`
- Sanitized local Spark CRM business-code review around operation requests,
  operation executions, action registry, appointment policy, and optional
  external-record linkage.

## Compact Claim

[D] Operation actions pressure a language distinction that typical application
code often blurs:

```text
visible action policy != executable action authority
request action         != execution action
request receipt        != execution receipt
external bridge link   != core operation fact
```

[D] Igniter-Lang should model this as a contract-addressable lifecycle:

```text
ActorObservation
  + OperationSubjectObservation
  + ScheduleStateObservation
  + CompanyActionConfigVersion
  + OperationHorizon
  -> ActionPolicyProjection
  -> OperationIntent
  -> OperationRequestReceipt | OperationExecutionReceipt | OperationFailure
  -> optional ExternalBridgeReceipt
```

## Fixture Identity

All IDs are synthetic and safe for public docs.

```text
fixture_id: spark_operation_action_lifecycle_minimal_v0
company_id: company/fixture-acme
actor_id: employee/tech-17
technician_id: tech/t-17
order_id: order/fixture-o-200
schedule_id: schedule/fixture-s-200
schema_version: operation_action_schema@0.1.0
policy_version: appointment_policy@1
action_config_version: company_action_config@1
operation_horizon: 2026-05-06T13:00:00Z..2026-05-06T13:30:00Z
as_of: 2026-05-06T13:00:00Z
timezone: America/New_York
source: employee_ui
source_ref: source/fixture-ui-session-001
```

Tenant scope:

```text
fact_scope:
  company_id: company/fixture-acme
  stores:
    - employees
    - orders
    - schedules
    - operation_requests
    - operation_executions
    - external_record_links
```

## Minimal Input Facts

### Actor

```text
ActorObservation = {
  actor_id: employee/tech-17
  company_id: company/fixture-acme
  roles: [:technician]
  technician_ref: tech/t-17
  subordinate_technician_refs: []
  manage_all_orders: false
  status: :active
}
```

### Order And Schedule Context

```text
OperationSubjectObservation = {
  order_id: order/fixture-o-200
  company_id: company/fixture-acme
  order_status: :scheduled
  subject_kind: :order_schedule
}

ScheduleStateObservation = {
  schedule_id: schedule/fixture-s-200
  order_id: order/fixture-o-200
  company_id: company/fixture-acme
  technician_id: tech/t-17
  status: :planned
  start_at: 2026-05-06T14:00:00Z
  end_at: 2026-05-06T15:00:00Z
  disputable: false
}
```

### Action Config

```text
CompanyActionConfigVersion = {
  company_id: company/fixture-acme
  version: company_action_config@1
  enabled_actions:
    - appointment_in_progress
    - appointment_complete
    - appointment_cancel_request
    - operator_callback
  disabled_actions:
    - appointment_dispute
}
```

### Operation Context

```text
OperationContext = {
  context_id: operation_context/company-fixture-acme/schedule-fixture-s-200/asof-20260506T130000Z
  actor_ref: employee/tech-17
  company_ref: company/fixture-acme
  order_ref: order/fixture-o-200
  schedule_ref: schedule/fixture-s-200
  policy_version: appointment_policy@1
  action_config_version: company_action_config@1
  as_of: 2026-05-06T13:00:00Z
}
```

## Expected Action Policy Projection

The first projection is read-only. It proves what the actor should see and why.
It does not authorize execution later unless the executable action check is
performed under compatible context evidence.

```text
ActionPolicyProjection = {
  projection_id: action_policy/schedule-fixture-s-200/asof-20260506T130000Z
  lifecycle: T.session
  context_ref: operation_context/company-fixture-acme/schedule-fixture-s-200/asof-20260506T130000Z
  visible_actions:
    - key: appointment_in_progress
      action_kind: :execution
      executable_under_current_context: true
      reason: :technician_owns_planned_appointment
    - key: appointment_complete
      action_kind: :execution
      executable_under_current_context: true
      reason: :technician_can_manage_not_done_not_canceled_appointment
    - key: appointment_cancel_request
      action_kind: :request
      executable_under_current_context: true
      reason: :technician_can_request_cancel_for_open_appointment
    - key: operator_callback
      action_kind: :request
      executable_under_current_context: true
      reason: :technician_can_request_operator_callback
  hidden_actions:
    - key: appointment_dispute
      action_kind: :request
      reason: :action_disabled_or_schedule_not_disputable
}
```

Expected result table:

| Action | Kind | Visible? | Executable under same context? | Expected next artifact |
|--------|------|----------|--------------------------------|------------------------|
| `appointment_in_progress` | execution | true | true | `OperationExecutionReceipt` |
| `appointment_complete` | execution | true | true | `OperationExecutionReceipt` |
| `appointment_cancel_request` | request | true | true | `OperationRequestReceipt` |
| `operator_callback` | request | true | true | `OperationRequestReceipt` |
| `appointment_dispute` | request | false | false | hidden diagnostic |

## Scenario A: Execution Action

The fixture executes `appointment_in_progress` from a planned appointment.

### Intent

```text
OperationIntent = {
  intent_id: operation_intent/fixture/in-progress-001
  action: appointment_in_progress
  action_kind: :execution
  actor_ref: employee/tech-17
  subject_ref: schedule/fixture-s-200
  source: employee_ui
  source_ref: source/fixture-ui-session-001
  requested_at: 2026-05-06T13:05:00Z
  policy_projection_ref: action_policy/schedule-fixture-s-200/asof-20260506T130000Z
}
```

### Execution Receipt

```text
OperationExecutionReceipt = {
  receipt_id: operation_execution/fixture/exec-001
  action: appointment_in_progress
  action_kind: :execution
  company_id: company/fixture-acme
  subject_ref: schedule/fixture-s-200
  performed_by_ref: employee/tech-17
  performed_at: 2026-05-06T13:05:00Z
  source: employee_ui
  source_ref: source/fixture-ui-session-001
  before_state:
    schedule_status: :planned
  after_state:
    schedule_status: :in_progress
  result_payload_policy: :redacted_business_summary
  operation_request_ref: null
  status: :ok
  links:
    - rel: :caused_by
      ref: operation_intent/fixture/in-progress-001
    - rel: :checked_against
      ref: action_policy/schedule-fixture-s-200/asof-20260506T130000Z
    - rel: :mutated
      ref: schedule/fixture-s-200
}
```

[D] The policy projection explains why the button was visible. The execution
receipt proves the state transition happened.

## Scenario B: Request Action

The fixture requests `appointment_cancel_request` after the appointment is in
progress. It creates a pending request and does not mutate schedule status.

### Intent

```text
OperationIntent = {
  intent_id: operation_intent/fixture/cancel-request-001
  action: appointment_cancel_request
  action_kind: :request
  actor_ref: employee/tech-17
  subject_ref: schedule/fixture-s-200
  source: employee_ui
  source_ref: source/fixture-ui-session-001
  requested_at: 2026-05-06T13:10:00Z
  payload_policy: :redacted_reason_summary
}
```

### Request Receipt

```text
OperationRequestReceipt = {
  receipt_id: operation_request/fixture/req-001
  action: appointment_cancel_request
  action_kind: :request
  company_id: company/fixture-acme
  subject_ref: schedule/fixture-s-200
  requested_by_ref: employee/tech-17
  requested_at: 2026-05-06T13:10:00Z
  source: employee_ui
  source_ref: source/fixture-ui-session-001
  request_status: :pending
  idempotency_scope:
    subject_ref: schedule/fixture-s-200
    action: appointment_cancel_request
    status: :pending
  schedule_status_changed: false
  status: :created
  links:
    - rel: :caused_by
      ref: operation_intent/fixture/cancel-request-001
    - rel: :about
      ref: schedule/fixture-s-200
}
```

[D] A request action creates review/discussion work. It is not equivalent to
executing cancellation and must not silently mutate the appointment.

## Scenario C: Duplicate Pending Request

The fixture repeats the same cancel request while `req-001` is still pending.

```text
OperationIntent = {
  intent_id: operation_intent/fixture/cancel-request-duplicate-001
  action: appointment_cancel_request
  action_kind: :request
  actor_ref: employee/tech-17
  subject_ref: schedule/fixture-s-200
  requested_at: 2026-05-06T13:11:00Z
}
```

Expected duplicate receipt:

```text
OperationRequestReceipt = {
  receipt_id: operation_request/fixture/req-001-duplicate-receipt
  action: appointment_cancel_request
  action_kind: :request
  duplicate_of: operation_request/fixture/req-001
  request_status: :pending
  status: :duplicate_pending_suppressed
  created_new_request: false
  schedule_status_changed: false
  diagnostic: operation_request.duplicate_pending
}
```

Expected duplicate table:

| Attempt | Existing pending? | New request created? | Schedule changed? | Expected status |
|---------|-------------------|----------------------|-------------------|-----------------|
| `cancel-request-001` | false | true | false | `:created` |
| `cancel-request-duplicate-001` | true | false | false | `:duplicate_pending_suppressed` |

## Optional External Bridge Receipt

If a company-level bridge capability is enabled, the request may produce a
provider-neutral external bridge receipt. The bridge receipt must not become
the core operation fact.

```text
ExternalBridgeIntent = {
  intent_id: external_bridge_intent/fixture/req-001
  bridge_kind: :helpdesk_ticket
  subject_ref: operation_request/fixture/req-001
  capability_ref: capability/helpdesk_ticket_create@fixture
  payload_policy: :provider_neutral_summary
}

ExternalBridgeReceipt = {
  receipt_id: external_bridge_receipt/fixture/req-001
  bridge_kind: :helpdesk_ticket
  subject_ref: operation_request/fixture/req-001
  external_record_ref: external_record/fixture/ticket-001
  provider_payload_policy: :redacted
  status: :ok
  links:
    - rel: :caused_by
      ref: external_bridge_intent/fixture/req-001
    - rel: :bridges
      ref: operation_request/fixture/req-001
}
```

[D] External bridge effects are ESCAPE. They require declared capability,
provider-neutral receipt shape, redaction policy, and failure receipt when the
bridge cannot run.

## Negative Cases

### POL-1: Visible Policy Drift Before Execution

Input:

```text
policy_projection_ref: action_policy/schedule-fixture-s-200/asof-20260506T130000Z
intent_action: appointment_in_progress
execution_time: 2026-05-06T13:12:00Z
current_schedule_status: :canceled
```

Expected:

```text
status: :blocked
diagnostic: operation_action.policy_context_drift
receipt: OperationFailure
schedule_status_changed: false
requires:
  - fresh OperationContext
  - fresh executable policy check
```

### REQ-1: Request Action Mutates Schedule

Input:

```text
intent_action: appointment_cancel_request
action_kind: :request
after_state:
  schedule_status: :canceled
```

Expected:

```text
status: :blocked
diagnostic: operation_request.unexpected_subject_mutation
request_created: false
execution_created: false
```

### EXE-1: Execution Without Receipt

Input:

```text
intent_action: appointment_complete
before_state:
  schedule_status: :in_progress
after_state:
  schedule_status: :done
operation_execution_receipt: null
```

Expected:

```text
status: :blocked
diagnostic: operation_execution.receipt_missing_for_state_transition
semantic_image_status: :provisional_or_blocked
```

### IDEM-1: Already In Progress No-Op

Input:

```text
intent_action: appointment_in_progress
current_schedule_status: :in_progress
```

Expected:

```text
status: :no_op
diagnostic: operation_execution.already_in_target_state
new_execution_receipt_required: open_question
schedule_status_changed: false
```

Open pressure: the language must decide whether idempotent execution no-ops
emit `OperationNoOpReceipt` or reuse the previous execution receipt.

### BR-1: External Bridge Capability Missing

Input:

```text
operation_request_ref: operation_request/fixture/req-001
bridge_kind: :helpdesk_ticket
capability_ref: null
```

Expected:

```text
status: :bridge_skipped_or_blocked
diagnostic: external_bridge.capability_missing
operation_request_status: :pending
core_operation_valid: true
external_record_created: false
```

## Language Capability Demands

- `OperationContext` must be a typed, tenant-scoped, temporal observation
  bundle, not an ambient controller/session object.
- `ActionPolicyProjection` must distinguish visible, hidden, and executable
  actions with reasons and source evidence.
- `OperationIntent` must be explicit and addressable before request/execution.
- Request actions and execution actions must have different result types.
- State transitions must require receipt evidence linked to before/after
  observations.
- Duplicate pending requests need idempotency semantics over subject, action,
  and pending status.
- Optional external bridges must be ESCAPE effects with capability gates,
  redaction policy, receipts, and failure diagnostics.

## What Current Igniter-Lang Handles

- Contract-addressable observations can represent actor, schedule, order,
  policy, request, execution, and bridge facts.
- Explicit time and projection horizons can make visible policy checks
  reproducible.
- CORE / ESCAPE / OOF maps cleanly:
  - policy projection is mostly CORE over observed facts;
  - external bridge creation is ESCAPE;
  - hidden clock/session/current-user reads are OOF.
- Receipt and failure-observation patterns already exist from RuntimeMachine
  and FFI proof tracks.
- Schema and replacement image concepts can cover action/state shape drift.

## Where It Breaks Or Lacks Capability

- There is no settled formal type for `ActionPolicyProjection` vs
  `OperationExecutionAuthority`.
- State transition semantics are not yet first-class: before/after evidence,
  no-op semantics, and receipt requirements need formal rules.
- Idempotency is not yet a language primitive or stdlib pattern for pending
  request de-dupe.
- Request action lifecycle needs status transition rules:
  `pending -> approved/rejected/canceled/completed`.
- Bridge receipts exist as a pressure pattern, but provider-neutral operation
  bridge diagnostics are not formalized.

## Concrete Research Agent Fixture Request

Please implement a standalone fixture proof:

```text
track_request: spark_operation_action_lifecycle_fixture_v0
suggested_dir: igniter-lang/experiments/spark_operation_action_lifecycle_fixture/
inputs:
  - synthetic actor observation
  - synthetic order observation
  - synthetic planned schedule observation
  - synthetic company action config version
  - one execution intent: appointment_in_progress
  - one request intent: appointment_cancel_request
  - duplicate pending request attempt
  - optional bridge-capability-present case
  - negative cases POL-1, REQ-1, EXE-1, IDEM-1, BR-1
outputs:
  - ActionPolicyProjection
  - OperationExecutionReceipt for in-progress transition
  - OperationRequestReceipt for cancel request
  - duplicate pending request receipt
  - optional ExternalBridgeReceipt
  - golden negative diagnostics
checker:
  - validates visible vs hidden action table
  - validates request action does not mutate schedule
  - validates execution action mutates only with receipt
  - validates duplicate pending request creates no new request
  - validates policy context drift blocks execution
  - validates external bridge can fail without invalidating core request
safety:
  - synthetic facts only
  - no Spark data, endpoints, provider payloads, credentials, tokens, customer
    data, or infrastructure names
```

Proof acceptance:

- policy projection lists execution and request actions separately;
- `appointment_in_progress` changes schedule `:planned -> :in_progress` with
  an execution receipt;
- `appointment_cancel_request` creates a pending request receipt and does not
  change schedule status;
- duplicate pending request returns duplicate evidence and does not create a
  second request;
- policy drift between visibility and execution is blocked;
- optional external bridge receipt is capability-gated and provider-neutral.

## Compiler/Grammar Expert Questions

1. Should visible action policy and executable authority be two distinct
   types, for example `ActionPolicyProjection` and
   `ExecutableActionCheck`, or one projection with freshness constraints?
2. Should request actions and execution actions be encoded as disjoint
   contract result types, tagged union variants, or different contract kinds?
3. What is the formal state transition primitive: `Transition[S]`,
   `MutationReceipt[S]`, lifecycle operation, or ESCAPE-only host effect?
4. Is duplicate pending request behavior an `IdempotencyKey`, a uniqueness
   constraint in a TBackend adapter, or a CORE admission contract over current
   observations?
5. Must every idempotent no-op execution emit a receipt, or can the runtime
   reuse prior receipt evidence when target state already holds?
6. Can a policy projection authorize later execution if its context hash
   matches, or must execution always recompute policy at `performed_at`?
7. How should request status transitions be typed:
   `pending -> approved/rejected/canceled/completed` as state machine,
   lifecycle, or schema-backed enum?
8. Should external bridge receipts be represented by the same FFI/ESCAPE
   receipt discipline or a separate `BridgeEffect` abstraction?

## Bridge Agent Candidates

- `OperationActionDiagnostic` profile for visible/hidden/executable action
  explanations, including actor reason, schedule status reason, company config
  reason, and context drift.
- `OperationRequestReceipt` profile with request status, duplicate pending
  evidence, source/source-ref redaction, and subject links.
- `OperationExecutionReceipt` profile with before/after state, performer,
  policy check ref, and mutation links.
- `OperationNoOpReceipt` candidate for already-in-target-state execution.
- `ExternalOperationBridgeReceipt` profile for helpdesk-style ticket/article
  links without provider-specific payload exposure.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/spark-operation-action-lifecycle-pressure-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Fixed the third Spark operational pressure slice around actor/order/schedule
  context, visible action policy, executable action checks, request receipts,
  execution receipts, duplicate pending requests, and optional bridge receipts.
- Treated visible policy and execution authority as separate evidence moments.
- Treated request actions as pending workflow creation, not subject mutation.
- Treated external helpdesk-style linkage as ESCAPE bridge evidence, not core
  operation truth.

[R] Recommendations:
- Research Agent should implement the fixture with positive execution,
  positive request, duplicate pending request, policy drift, unexpected request
  mutation, missing execution receipt, no-op, and bridge capability cases.
- Compiler/Grammar Expert should formalize request/execution result types,
  state transition receipts, idempotency/no-op behavior, and policy freshness.
- Bridge Agent should draft operation diagnostics and receipt profiles before
  any package integration is attempted.

[S] Signals:
- Action UI is language pressure: visibility is an explainable projection, not
  authorization by itself.
- Human/agent intent needs its own observation before side effects.
- Operation request de-dupe is idempotency over pending workflow state.
- State mutation without execution receipt should downgrade or block meaning.

[T] Tests / Proofs:
- Not run; documentation/specification slice only.
- Requested Research Agent proof:
  `igniter-lang/experiments/spark_operation_action_lifecycle_fixture/`.

[Files] Changed:
- igniter-lang/docs/tracks/spark-operation-action-lifecycle-pressure-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Is executable authority a fresh check, a projection with context hash, or
  both?
- Do idempotent execution no-ops require new `OperationNoOpReceipt` evidence?
- Does state transition belong in CORE, ESCAPE, TBackend, or a layered model?
- How should request status lifecycle compose with execution receipts?

[X] Rejected:
- Publishing real Spark endpoint, payload, provider, customer, credential, or
  infrastructure details.
- Treating visible action policy as durable execution authority.
- Treating request actions as schedule/order mutations.
- Treating external bridge tickets/articles as language-core facts.

[Next] Proposed next slice:
- Research Agent: implement `spark_operation_action_lifecycle_fixture_v0`.
- Compiler/Grammar Expert: formalize operation request/execution and state
  transition receipt semantics.
- Bridge Agent: draft operation diagnostic and receipt bridge candidates.
```
