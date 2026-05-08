# Track: Operation Action Result Types and Transition Semantics v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/operation-action-result-types-and-transition-semantics-v0
Status: done
Date: 2026-05-06
Pressure source: spark-crm-real-business-candidate-map-v0 §Candidate 5

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — fixture acceptance criteria in §Part 6.
- `[Igniter-Lang Bridge Agent]` — ESCAPE receipt discipline in §Part 7.

---

## Part 1: Two Distinct Policy Checks

### ActionPolicyProjection

A projection that answers: **which actions are visible to this actor?**

```text
ActionPolicyProjection = {
  context_ref:    ObsId         -- OperationContext observation
  allowed:        Collection[ActionDescriptor]
  hidden:         Collection[ActionDescriptor]
  policy_ref:     String        -- rule version
  temporal:       TemporalCtx
}
lifecycle: :session
fragment:  :core (pure over bounded inputs)
```

`ActionDescriptor = { action_kind: Symbol, label: String, why_hidden: String | nil }`

**[D] ActionPolicyProjection is read-only and CORE.** It does not authorize execution. Showing an action does not mean it may be executed.

### ExecutableActionCheck

A check that answers: **may this specific action be executed right now?**

```text
ExecutableActionCheck = {
  context_ref:    ObsId           -- same OperationContext
  action_kind:    Symbol
  result:         :allowed | :denied
  denial_reason:  String | nil
  check_ref:      ObsId           -- this check observation's own id
  performed_at:   Timestamp
  policy_ref:     String
  policy_hash:    String          -- hash of policy inputs; freshness token
}
lifecycle: :session
fragment:  :core | :escape        -- CORE if policy inputs are CORE; ESCAPE if TBackend read
```

**[D] ExecutableActionCheck must be performed at execution time, not at projection time.** A stale ActionPolicyProjection may not substitute for a fresh ExecutableActionCheck. OOF-OA1 governs this.

**[D] `policy_hash`** is a content hash of the policy input fields at check time. It is used by duplicate request suppression (§Part 4) to detect whether the context changed between attempts.

---

## Part 2: Request Action vs Execution Action

### Request action result

A request action creates a pending operation record. It does not mutate the subject state directly.

```text
RequestActionResult = Ok(OperationRequestReceipt) | Err(RequestActionError)

OperationRequestReceipt = Obs[:platform_observation, RequestRecord]
RequestRecord = {
  receipt_kind:    :operation_request
  action_kind:     Symbol
  context_ref:     ObsId             -- OperationContext
  check_ref:       ObsId             -- ExecutableActionCheck.check_ref
  request_id:      String            -- stable id for this pending request
  idempotency_key: IdempotencyKey    -- from §decimal-idempotency-retention
  status:          :pending
  performed_at:    Timestamp
  actor_ref:       ObsId | nil
}
lifecycle: :durable
links:
  { rel: "authorized_by",  ref: check_ref }
  { rel: "identified_by",  ref: idempotency_key.value }
  { rel: "produced_in",    ref: session_id }
```

### Execution action result

An execution action mutates subject state and emits evidence of the before/after transition.

```text
ExecutionActionResult = Ok(OperationExecutionReceipt) | Err(ExecutionActionError)

OperationExecutionReceipt = Obs[:platform_observation, ExecutionRecord]
ExecutionRecord = {
  receipt_kind:   :operation_execution
  action_kind:    Symbol
  context_ref:    ObsId
  check_ref:      ObsId             -- fresh ExecutableActionCheck at execution time
  request_ref:    ObsId | nil       -- OperationRequestReceipt if preceded by request
  subject_before: ObsId             -- snapshot of subject state before mutation
  subject_after:  ObsId             -- snapshot of subject state after mutation
  performed_at:   Timestamp
  actor_ref:      ObsId | nil
  policy_hash:    String
}
lifecycle: :audit   (execution evidence is permanent)
links:
  { rel: "authorized_by",   ref: check_ref }
  { rel: "caused_by",       ref: request_ref } | nil
  { rel: "produced_in",     ref: session_id }
  { rel: "mutated_from",    ref: subject_before }
  { rel: "mutated_to",      ref: subject_after }
```

**[D] `subject_before` and `subject_after` are mandatory on all execution receipts.** Missing either is OOF-OA3.

**[D] `check_ref` on the execution receipt must point to a check performed within the current session.** A check from a previous session is stale — OOF-OA1.

---

## Part 3: Policy Freshness

```text
PolicyFreshnessRule:
  An ExecutableActionCheck is fresh if:
    (a) performed_at >= (now(ctx) - policy_ttl), AND
    (b) policy_hash matches the hash of current policy inputs.

  A check is stale if performed_at < (now(ctx) - policy_ttl).
  A check is invalidated if policy_hash != hash(current_policy_inputs).

policy_ttl:
  v0 default: same session only (lifecycle :session).
  A check from a previous session is always stale.
  Cross-session check reuse is OOF-OA1.
```

**[D] `policy_hash`** covers: `context_ref`, `action_kind`, `actor_ref`, `policy_ref`, `policy_version`. It does NOT cover `performed_at` (time is captured separately).

**[D] A reusable context hash is valid only within a single session.** Two requests in the same session for the same action may share a `policy_hash` if the context did not change. Sharing across sessions is OOF-OA1.

---

## Part 4: Duplicate Pending Request Semantics

Three cases at request time:

```text
1. No existing pending request for this (context, action_kind):
   -> Create OperationRequestReceipt (status: :pending).

2. Existing pending request with same IdempotencyKey:
   -> Do NOT create a new request.
   -> Emit OperationNoOpReceipt linking to the original request.
   -> IDEMPOTENT: caller receives no error.

3. Existing pending request with different IdempotencyKey but same (context, action_kind):
   -> Emit DuplicateRejectionReceipt with failure_kind: :pending_request_conflict.
   -> The new request is rejected. Not a no-op.
```

```text
OperationNoOpReceipt = Obs[:platform_observation, NoOpRecord]
NoOpRecord = {
  receipt_kind:    :operation_no_op
  action_kind:     Symbol
  context_ref:     ObsId
  original_ref:    ObsId            -- the existing OperationRequestReceipt
  idempotency_key: IdempotencyKey
  performed_at:    Timestamp
}
lifecycle: :session
links:
  { rel: "replaces",      ref: original_ref }
  { rel: "identified_by", ref: idempotency_key.value }
```

**[D] Case 2 and Case 3 are distinct.** Case 2 is a retry of the same intent (idempotent). Case 3 is a conflicting intent (rejected). The receiver must inspect `failure_kind` to distinguish them.

---

## Part 5: OOF Rules and SemanticIR Gates

### OOF Rules

```text
OOF-OA1: Stale ExecutableActionCheck reused across sessions.
  check_ref points to a check from a previous session.
  -> Execution blocked. A fresh check must be performed.

OOF-OA2: Execution without ExecutableActionCheck.
  OperationExecutionReceipt.check_ref is nil.
  -> Compile error (Pass 1: check_ref is required).

OOF-OA3: Execution receipt missing subject_before or subject_after.
  -> Compile error (Pass 1: both are required on :audit receipts).

OOF-OA4: Unexpected mutation without execution receipt.
  A TBackend write that is not covered by an OperationExecutionReceipt.
  -> OOF at runtime: ambient mutation outside declared effect.
  -> Classified as ESCAPE if declared; OOF if undeclared.

OOF-OA5: Visible action used as authorization for execution.
  ActionPolicyProjection.allowed used as check_ref (projection ≠ check).
  -> Compile error: check_ref must reference ExecutableActionCheck, not projection.

OOF-OA6: Policy hash mismatch at execution.
  ExecutionRecord.policy_hash != hash(current_policy_inputs) at execution time.
  -> Runtime rejection: context changed between check and execution.
  -> Emit a fresh ExecutableActionCheck and retry.

OOF-OA7: Execution action emitting request receipt.
  An execution action emits OperationRequestReceipt instead of ExecutionReceipt.
  -> Compile error (Pass 1 output type check): action_kind determines receipt type.
```

### SemanticIR Gates

```text
G-OA1: All execution result nodes must carry check_ref.
G-OA2: All execution result nodes must carry subject_before and subject_after.
G-OA3: check_ref type must be ExecutableActionCheck, not ActionPolicyProjection.
G-OA4: OperationRequestReceipt.idempotency_key must be present (non-nil).
G-OA5: External bridge effects (§Part 7) must be declared as ESCAPE with receipt_policy.
```

---

## Part 6: Research Agent Acceptance Criteria

Reference fixture: `spark-operation-action-lifecycle-fixture-v0`

```text
Positive path:
  1. OperationContext with technician actor + planned appointment.
  2. ActionPolicyProjection: mark_in_progress allowed; complete allowed;
     cancel_request allowed; dispute_request hidden (why_hidden: "no active job").
  3. ExecutableActionCheck for mark_in_progress: result: :allowed.
  4. OperationExecutionReceipt for mark_in_progress:
     subject_before: schedule obs (status: :planned)
     subject_after:  schedule obs (status: :in_progress)
     check_ref: check from step 3
     lifecycle: :audit
  5. ExecutableActionCheck for complete: result: :allowed.
  6. OperationExecutionReceipt for complete:
     subject_before: schedule obs (status: :in_progress)
     subject_after:  schedule obs (status: :completed)
     lifecycle: :audit

Duplicate request path:
  7. OperationRequestReceipt for cancel_request: status: :pending.
  8. Second cancel_request attempt (same IdempotencyKey):
     -> OperationNoOpReceipt linking to step 7. No new request created.
  9. Third cancel_request attempt (different IdempotencyKey, same context):
     -> DuplicateRejectionReceipt: failure_kind: :pending_request_conflict.

Negative cases:
  N1: Execution without check_ref -> OOF-OA2.
  N2: check_ref from a different session -> OOF-OA1 blocked.
  N3: ActionPolicyProjection.allowed used as check_ref -> OOF-OA5.
  N4: Missing subject_before on execution receipt -> OOF-OA3.
```

---

## Part 7: Bridge / ESCAPE Receipt Discipline

External bridge effects (e.g. creating a helpdesk ticket, external record link) follow ESCAPE discipline:

```text
ExternalBridgeEffect = {
  effect_kind:    Symbol             -- :helpdesk_ticket, :external_record_link, etc.
  action_ref:     ObsId              -- the OperationExecutionReceipt that triggered it
  receipt_policy: :at_most_once | :at_least_once | :exactly_once
  provider:       String             -- provider-neutral identifier
}
-- fragment: ESCAPE (calls external provider)
-- Must emit ExternalBridgeReceipt on success.
-- Must emit ExternalBridgeFailureReceipt on failure (not silent).

ExternalBridgeReceipt = Obs[:platform_observation, BridgeRecord]
BridgeRecord = {
  receipt_kind:   :external_bridge
  effect_kind:    Symbol
  action_ref:     ObsId
  external_id:    String    -- provider-assigned id (redacted in diagnostics)
  performed_at:   Timestamp
}
lifecycle: :audit
links:
  { rel: "caused_by",     ref: action_ref }
  { rel: "produced_by",   ref: provider }
```

**[D] External bridge is ESCAPE with mandatory receipt.** A bridge call without a receipt is OOF-OA4 (unexpected mutation).

**[D] `external_id` must be redacted in diagnostics when privacy policy applies.** The bridge adapter is responsible for applying redaction before emitting diagnostic packets.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/operation-action-result-types-and-transition-semantics-v0
Status: done

[D] Decisions:
- ActionPolicyProjection (visible actions) ≠ ExecutableActionCheck (authorization).
  Using a projection as a check is OOF-OA5.
- ExecutableActionCheck is session-scoped. Cross-session reuse is OOF-OA1.
- policy_hash covers context_ref, action_kind, actor_ref, policy_ref, policy_version.
  Mismatch at execution -> OOF-OA6, must re-check.
- Request action -> OperationRequestReceipt (:durable).
- Execution action -> OperationExecutionReceipt (:audit) with subject_before/after.
- Three duplicate pending request outcomes: no-op (same key), rejection (different key,
  same context), or fresh creation (no existing pending).
- OperationNoOpReceipt links to original request via :replaces.
- External bridge effects are ESCAPE with receipt_policy and mandatory
  ExternalBridgeReceipt or ExternalBridgeFailureReceipt.
- 7 OOF rules: OOF-OA1..7. 5 SemanticIR gates: G-OA1..5.

[Files] Changed:
- igniter-lang/docs/tracks/operation-action-result-types-and-transition-semantics-v0.md [NEW]
- igniter-lang/docs/README.md  [updated]
- igniter-lang/docs/agent-motion.md  [updated]

[Next]:
- [Research Agent]: spark-operation-action-lifecycle-fixture-v0
  Implement the fixture per §Part 6 criteria.
- [Bridge Agent]: map ExternalBridgeReceipt to metadata-only descriptor for
  helpdesk/external-record adapter (BR-4 from candidate-map).
```
