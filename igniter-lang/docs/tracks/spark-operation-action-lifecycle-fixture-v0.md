# Track: Spark Operation Action Lifecycle Fixture v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/spark-operation-action-lifecycle-fixture-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`
Artifacts:
- `igniter-lang/experiments/spark_operation_action_lifecycle_fixture/spark_operation_action_lifecycle_fixture.rb`
- `igniter-lang/docs/tracks/spark-operation-action-lifecycle-pressure-v0.md`

---

## Frame

This slice turns the Spark operation action lifecycle pressure case into an
executable synthetic fixture.

Safety boundary:

- synthetic actor, order, schedule, company config, request, execution, and
  bridge refs only
- no real Spark CRM data
- no endpoints, provider configs, raw provider payloads, secrets, tokens,
  customers, phones, emails, queue names, or infrastructure details
- proof fixture only, not package adapter code

---

## What The Fixture Models

Positive case:

```text
ActorObservation
  + OperationSubjectObservation
  + ScheduleStateObservation
  + CompanyActionConfigVersion
  -> OperationContext
  -> ActionPolicyProjection
  -> OperationIntent(appointment_in_progress)
  -> ExecutableActionCheck
  -> OperationExecutionReceipt
  -> OperationIntent(appointment_cancel_request)
  -> OperationRequestReceipt
  -> duplicate OperationRequestReceipt(non-admission)
  -> optional ExternalBridgeReceipt
```

Core decision:

```text
visible action policy != executable action authority
```

The policy projection explains what is visible. The execution path still emits
a fresh `ExecutableActionCheck` before mutating schedule state.

---

## Positive Result

Visible actions:

```text
appointment_in_progress      execution
appointment_complete         execution
appointment_cancel_request   request
operator_callback            request
```

Hidden action:

```text
appointment_dispute          request
reason: action_disabled_or_schedule_not_disputable
```

Execution action:

```text
appointment_in_progress:
  before_state.schedule_status: planned
  after_state.schedule_status: in_progress
  receipt: OperationExecutionReceipt
  status: ok
```

Request action:

```text
appointment_cancel_request:
  request_status: pending
  status: created
  schedule_status_changed: false
```

Duplicate pending request:

```text
status: duplicate_pending_suppressed
created_new_request: false
schedule_status_changed: false
diagnostic: operation_request.duplicate_pending
```

Optional bridge:

```text
ExternalBridgeReceipt:
  bridge_kind: helpdesk_ticket
  provider_payload_policy: redacted
  status: ok
```

The bridge receipt remains ESCAPE-side evidence. It does not become the core
operation request fact.

---

## Negative / Boundary Cases

[D] Policy drift blocks execution:

```text
diagnostic: operation_action.policy_context_drift
schedule_status_changed: false
requires:
  - fresh OperationContext
  - fresh executable policy check
```

[D] Request action cannot mutate schedule:

```text
diagnostic: operation_request.unexpected_subject_mutation
request_created: false
execution_created: false
```

[D] State transition without execution receipt blocks/downgrades:

```text
diagnostic: operation_execution.receipt_missing_for_state_transition
semantic_image_status: provisional_or_blocked
```

[D] Already-in-progress execution emits no-op evidence:

```text
kind: OperationNoOpReceipt
status: no_op
diagnostic: operation_execution.already_in_target_state
schedule_status_changed: false
new_execution_receipt_required: open_question
```

[D] Missing bridge capability does not invalidate the core request:

```text
diagnostic: external_bridge.capability_missing
status: bridge_skipped_or_blocked
operation_request_status: pending
core_operation_valid: true
external_record_created: false
```

---

## Proof Output

```text
ruby igniter-lang/experiments/spark_operation_action_lifecycle_fixture/spark_operation_action_lifecycle_fixture.rb
```

Output:

```text
PASS spark_operation_action_lifecycle_fixture
policy.visible_hidden_table: ok
policy.visibility_not_authority: ok
execution.in_progress_receipt: ok
request.cancel_pending_receipt: ok
request.no_schedule_mutation: ok
duplicate.pending_non_admission: ok
bridge.capability_present_receipt: ok
negative.policy_drift_blocked: ok
negative.request_mutation_blocked: ok
negative.missing_execution_receipt_blocked: ok
negative.no_op_receipt: ok
negative.bridge_capability_missing: ok
safety.synthetic_only: ok
positive.policy.visible: appointment_in_progress:execution, appointment_complete:execution, appointment_cancel_request:request, operator_callback:request
positive.execution: planned -> in_progress
positive.request: created schedule_changed=false
duplicate: duplicate_pending_suppressed created_new_request=false
bridge_missing: bridge_skipped_or_blocked diagnostic=external_bridge.capability_missing
```

The proof also supports:

```text
ruby igniter-lang/experiments/spark_operation_action_lifecycle_fixture/spark_operation_action_lifecycle_fixture.rb --dump
```

to inspect generated synthetic observations.

---

## Gap Report

### Compiler / Grammar

[Next] Formalize `ActionPolicyProjection` and `ExecutableActionCheck` as
distinct evidence types, or define a projection freshness rule that forces the
same separation.

[Next] Define request and execution actions as disjoint result types. Request
actions create workflow receipts; execution actions create mutation receipts.

[Next] Decide whether state transitions are CORE transitions, ESCAPE host
effects with receipts, TBackend lifecycle operations, or a layered model.

[Q] `OperationNoOpReceipt` is used in this proof, but the formal rule remains
open: should idempotent no-ops always emit fresh no-op evidence, or may they
reuse prior execution receipts?

### Bridge

[Next] Draft/complete metadata-only bridge profiles for:

- `OperationActionDiagnostic`
- `OperationRequestReceipt`
- `OperationExecutionReceipt`
- `OperationNoOpReceipt`
- `ExternalOperationBridgeReceipt`

[Q] Bridge should keep external records as provider-neutral ESCAPE evidence,
not core operation truth.

---

## Boundaries

[X] Rejected: real Spark CRM reads, endpoints, credentials, provider configs,
raw provider payloads, queue names, customer data, phones, or emails.

[X] Rejected: visible action policy as durable execution authority.

[X] Rejected: request actions mutating order/schedule state.

[X] Rejected: external bridge ticket/article records as language-core facts.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/spark-operation-action-lifecycle-fixture-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Built a stdlib-only executable synthetic fixture.
- Positive case emits ActionPolicyProjection, ExecutableActionCheck,
  OperationExecutionReceipt, OperationRequestReceipt, duplicate pending
  non-admission evidence, and optional ExternalBridgeReceipt.
- appointment_in_progress mutates planned -> in_progress only with execution
  receipt evidence.
- appointment_cancel_request creates pending workflow evidence and does not
  mutate schedule status.
- Duplicate pending request creates no second request and no schedule mutation.
- Policy drift, unexpected request mutation, missing execution receipt,
  already-in-target no-op, and missing bridge capability are covered.

[R] Recommendations:
- Compiler/Grammar: formalize visible policy vs executable authority, request
  vs execution result types, state transition receipts, and no-op semantics.
- Bridge: define provider-neutral operation diagnostics and receipts before
  mapping to package surfaces.

[S] Signals:
- Action UI is a projection, not authority.
- Human/agent intent needs its own observation before side effects.
- Request de-dupe is idempotency over pending workflow state.
- Mutation without receipt should block or downgrade meaning.

[T] Tests / Proofs:
- spark_operation_action_lifecycle_fixture.rb -> PASS

[Files] Changed:
- igniter-lang/experiments/spark_operation_action_lifecycle_fixture/spark_operation_action_lifecycle_fixture.rb
- igniter-lang/docs/tracks/spark-operation-action-lifecycle-fixture-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Fresh execution check vs context-hash reuse?
- Must every no-op emit OperationNoOpReceipt?
- Which layer owns state transition semantics?
- How should request status lifecycle compose with execution receipts?

[X] Rejected:
- Real Spark data or endpoints.
- Request actions mutating schedules.
- Visible policy as execution authority.
- External bridge records as core facts.

[Next] Proposed next slice:
- Compiler/Grammar Expert: action lifecycle/result type formalization.
- Bridge Agent: operation diagnostic and receipt bridge profile refinement.
```
