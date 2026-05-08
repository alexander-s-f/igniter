# Track: Spark CRM Real Business Candidate Map v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/spark-crm-real-business-candidate-map-v0.md`
Status: done
Slice state: done on 2026-05-06
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This slice uses the real local Spark CRM codebase as applied pressure for
Igniter-Lang implementation candidates.

Safety boundary for this document:

- no secrets;
- no tokens;
- no endpoint paths or URLs;
- no vendor client configuration;
- no deployment, queue, or infrastructure specifics;
- no customer, tenant, or operator data.

Only business processes and abstract business logic are recorded here.

## Source Review Hygiene

Reviewed real Spark CRM business code locally, limited to domain models and
service objects around scheduling, technician availability, lead signal
analytics, telephony state, order operation actions, and external-record
linkage policy.

Intentionally omitted from this public track:

- route files and concrete endpoint shapes;
- credentials and secret-bearing config;
- provider client code and provider URLs;
- request examples;
- infrastructure settings;
- raw vendor payload examples.

One source file contains a private request example in a comment. It is not
quoted, summarized, or used as a language signal.

## Compact Claim

[D] The real Spark CRM codebase confirms that the best Igniter-Lang candidates
are not generic CRUD rewrites. The promising candidates are business
boundaries where trust, time, idempotency, scope, and receipts already matter:

```text
lead signals -> analytics boundary -> retention receipt
technician availability -> schedule/off-schedule/day-off evidence -> slice
telephony events -> correlated call state -> operator availability signal
order operation action -> request/execution receipt -> optional external link
```

[D] These candidates should become fixtures before production integration.
They are concrete enough to test Igniter-Lang, but small enough to avoid
turning the language lab into a Rails port.

## Candidate 1: Lead Signal Boundary

Real business process:

```text
lead outbox event
  -> normalize channel/trade/vendor/zip/geography
  -> derive stable idempotency key
  -> insert lead signal
  -> update hourly rollup
  -> serve accepted/rejected aggregates
  -> enforce retention cutoff
```

Why it is a strong Igniter-Lang candidate:

- It already has observation-like material: event payload, signal timestamp,
  request/trace identifiers, accepted/rejected outcome, bid amount, and
  idempotency key.
- It naturally separates raw signal lifecycle from hourly rollup lifecycle.
- It pressures Decimal arithmetic, canonical hashing, dedupe, aggregation, and
  retention.
- It can be tested without exposing provider endpoints or credentials.

Language demands:

- `LeadSignalObservation` with redacted payload policy.
- `IdempotencyKey` as deterministic CORE over a bounded normalized record.
- Decimal/Money or explicit host numeric policy for bid amounts.
- `HourlyLeadSignalRollup` as `BoundaryMaterialization`.
- `RetentionReceipt` that proves deletion/compaction was policy-covered.

Failure modes:

- duplicate signal accepted because idempotency fields drift;
- rollup count differs from raw signals after retention;
- bid total changes because Decimal is coerced through Float;
- retention deletes raw signals before rollup/boundary receipt exists;
- late signal arrives for a closed hour without migration/reopen evidence.

First fixture shape:

```text
3 lead signals in one hour
  -> 2 accepted, 1 rejected
  -> rollup counts and bid totals
  -> retention dry-run receipt
  -> retention execution receipt
```

## Candidate 2: Technician Availability Slice

Real business process:

```text
company time policy
  + technician profile
  + schedules
  + off_schedules
  + day_off_config
  + requested date/window
  -> slot list
  -> busy/job/off percentages
  -> available? decision
```

Why it is a strong Igniter-Lang candidate:

- It is exactly the "explicit time plus observations" shape.
- It depends on tenant scope, timezone, schedule status, and day-off policy.
- It already has known edge cases around inclusive/exclusive workday slots and
  canceled schedule status.
- It supports both live UI slices and pinned dispatch/marketing decisions.

Language demands:

- `AvailabilityHorizon` with fixed `as_of`, company timezone, date window,
  rule version, and tenant scope.
- `DayOffConfigVersion` as schema-versioned structural data, not untyped JSON.
- `ScheduleSlotObservation` and `OffScheduleObservation` with status filters.
- Stable interval semantics: inclusive start, exclusive end, and explicit slot
  duration.
- Diagnostic reasons for `busy`, `off`, `job`, and `available`.

Failure modes:

- off-by-one workday slot makes every day look available;
- canceled schedule blocks a technician incorrectly;
- timezone changes recompute a different date window;
- missing tenant scope mixes schedules across companies;
- `day_off_config` shape changes without migration receipt.

First fixture shape:

```text
one company, one technician, one day
  -> one planned schedule
  -> one off_schedule
  -> one day_off_config block
  -> slot projection
  -> availability snapshot
```

## Candidate 3: Scheduler Authorization And Candidate Scope

Real business process:

```text
current employee role
  -> available technician set
  -> selectable technician ids
  -> schedule/off-schedule reads for a period
```

Why it is a strong Igniter-Lang candidate:

- It is small but semantically important.
- It turns role, company, manager/subordinate relation, and technician identity
  into a typed scope.
- It can prove why a user can or cannot see/assign a technician.

Language demands:

- `ActorScope` contract with role and company evidence.
- `ManageableTechnicianSet` as a projection, not an ambient authorization
  helper.
- Blocked diagnostic when actor/company scope is missing.
- Optional redaction of technician/user details in diagnostics.

Failure modes:

- technician manager sees technicians outside their subordinate set;
- technician sees another technician's schedule;
- admin scope is not bounded by company;
- empty scope is treated as no data instead of denied action.

First fixture shape:

```text
admin actor + manager actor + technician actor
  -> three different ManageableTechnicianSet outputs
  -> denied projection for unrelated actor
```

## Candidate 4: Telephony Event Correlation

Real business process:

```text
provider event
  -> external call id extraction
  -> find or create phone call
  -> correlate related provider events
  -> create/update call leg
  -> update operator live call status
  -> mark event processed
```

Why it is a strong Igniter-Lang candidate:

- Telephony is high-signal ESCAPE pressure: external events are unordered,
  provider-shaped, duplicate-prone, and partially correlated.
- It has a clean normalized semantic target: phone call, call leg, operator
  state, processed event receipt.
- It connects directly to dispatch/availability because operator availability
  can change from call state.

Language demands:

- `TelephonyEventObservation` with provider-neutral normalized fields.
- `ExternalIdExtraction` as Result, not silent nil.
- Correlation window with explicit `as_of` and time range.
- `ProcessedEventReceipt` linked to call/call-leg mutation.
- Late/duplicate event handling with idempotency and failure observations.

Failure modes:

- event without external id is silently dropped;
- two providers report the same call but correlation evidence is missing;
- operator live status remains stale after an ended leg;
- duplicate event increments processing without idempotent receipt;
- raw provider payload is exposed in diagnostics without redaction policy.

First fixture shape:

```text
pre-call event + presence event + post-call event
  -> one PhoneCall
  -> one CallLeg
  -> operator status transitions
  -> processed receipts
```

## Candidate 5: Order Operation Action Lifecycle

Real business process:

```text
actor + schedule/order context
  -> visible actions
  -> policy check
  -> request action or execution action
  -> operation request/execution record
  -> optional external-record link
  -> messages and resolution
```

Actions include appointment progress, completion, dispute request, cancel
request, and operator callback request.

Why it is a strong Igniter-Lang candidate:

- It is a compact model of action rights, human/agent intent, execution
  receipts, idempotency, and external bridge effects.
- It separates request actions from execution actions.
- It already has a durable audit shape through operation request/execution
  records and optional external links.

Language demands:

- `OperationContext` with actor, company, subject, order, and schedule refs.
- `ActionPolicyProjection` listing allowed/hidden actions with reasons.
- `OperationRequestReceipt` for pending request creation and duplicate pending
  request handling.
- `OperationExecutionReceipt` for schedule mutation.
- External bridge effects as ESCAPE with provider-neutral receipts.

Failure modes:

- visible action differs from executable action because policy was evaluated
  under a different context;
- duplicate pending request is treated as a fresh request;
- schedule status mutation succeeds but execution receipt is missing;
- completion recalculates order status without an evidence link;
- external ticket/article creation is attempted without bridge capability.

First fixture shape:

```text
technician actor + planned appointment
  -> visible actions
  -> mark in progress execution
  -> complete execution
  -> duplicate cancel request blocked/deduplicated
```

## Candidate Ranking

Recommended implementation pressure order:

1. `spark-technician-availability-fixture-v0`
2. `spark-lead-signal-boundary-fixture-v0`
3. `spark-operation-action-lifecycle-fixture-v0`
4. `spark-telephony-correlation-fixture-v0`
5. `spark-scheduler-actor-scope-fixture-v0`

Rationale:

- Availability is the clearest continuation of existing Igniter-Lang fixtures.
- Lead signals pressure aggregation, idempotency, Decimal, and retention.
- Operation actions pressure capability-gated receipts with a manageable state
  machine.
- Telephony is very valuable but should follow a smaller ESCAPE/event proof.
- Scheduler actor scope is small and may fold into availability or operation
  action fixtures.

## Cross-Cutting Language Pressure

[S] Real Spark CRM strengthens these language requirements:

- tenant scope must be semantic, not ambient;
- timezone and business-day calculations must be part of `TemporalCtx`;
- Decimal is likely needed before bid/threshold evidence is trusted;
- idempotency keys should be first-class evidence;
- request/execution distinction should be visible in contract composition;
- redaction policy must travel with observations and diagnostics;
- retention is a semantic operation, not a background cleanup detail;
- external links are bridge receipts, not core language facts.

## Requests For Research Agent

RA-1: build `spark-technician-availability-fixture-v0`.

- Use one company, one technician, one date, one schedule, one off schedule,
  and one day-off rule.
- Prove slot projection, availability snapshot, and failure diagnostics for
  missing tenant scope and timezone drift.

RA-2: build `spark-lead-signal-boundary-fixture-v0`.

- Use normalized lead signals, idempotency hash, hourly rollup, and retention
  receipts.
- Include duplicate and late-signal cases.

RA-3: build `spark-operation-action-lifecycle-fixture-v0`.

- Use action policy projection, one request action, one execution action, and
  duplicate pending request behavior.
- Emit request/execution receipts.

RA-4: defer telephony until event/ESCAPE fixture shape is settled.

- Start with provider-neutral normalized event fixtures, not provider clients.

## Questions For Compiler/Grammar Expert

CG-1: should tenant scope be a parameter on `Store[T]`/`History[T]`, a field in
`ProjectionHorizon.fact_scope`, or both?

CG-2: should `Decimal` enter the v0 type grammar as a base type, trait-bound
numeric type, or host policy type?

CG-3: how should idempotency be typed: content-addressed value, receipt field,
or effect requirement?

CG-4: should operation request/execution be modeled as contract composition,
state-machine transition, or capability-gated effect pair?

CG-5: what formal rule turns retention from host cleanup into
`T.compact`/`T.audit` evidence?

CG-6: how should late stream/event arrival interact with a closed boundary:
blocked, migrating, or reopened with receipt?

## Bridge Candidates For Bridge Agent

BR-1: metadata-only descriptor for Spark tenant/time/read boundaries.

BR-2: selected-profile adapter target for lead signal rollup artifacts.

BR-3: diagnostics map for technician availability: slot reasons, source refs,
tenant scope, timezone, day-off version, schedule statuses.

BR-4: provider-neutral external-record link receipt shape for operation
requests and helpdesk-style bridges.

BR-5: redaction policy map for phone, customer, raw provider payload, and
access-token-like fields.

## Rejected Paths

[X] Do not publish endpoints, tokens, URLs, provider payload examples, or
infrastructure details in Igniter-Lang tracks.

[X] Do not begin with payment or credential-bearing integrations.

[X] Do not treat Rails `Current`, tenant globals, clock calls, or random token
generation as trusted language semantics.

[X] Do not make external helpdesk/telephony providers part of the language
core. They are ESCAPE adapters with receipts.

## Handoff

[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/spark-crm-real-business-candidate-map-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Real Spark CRM business logic provides five sanitized Igniter-Lang implementation candidates.
- The first recommended fixture is technician availability; lead-signal boundary is the second.
- Public Igniter-Lang docs must omit Spark secrets, endpoints, provider URLs, raw request examples, infrastructure, and credentials.

[R] Recommendations:
- Research Agent should implement availability and lead-signal fixtures first.
- Compiler/Grammar Expert should prioritize tenant scope, Decimal, idempotency, retention, and request/execution semantics.
- Bridge Agent should prepare metadata-only descriptors and diagnostic maps, not package edits.

[S] Signals:
- Spark lead signals already look like observation packets plus boundary materialization.
- Spark order operations already separate requested intent from execution receipt.
- Telephony is a rich ESCAPE case but should wait until provider-neutral event fixtures exist.

[T] Tests / Proofs:
- Documentation-only source review; no Spark or Igniter tests were run.
- Sensitive source content was intentionally excluded from this track.

[Files] Changed:
- `igniter-lang/docs/tracks/spark-crm-real-business-candidate-map-v0.md`
- `igniter-lang/docs/README.md`

[Q] Open Questions:
- Should the first Spark proof reuse `availability_projection.ig` or create a new source fixture?
- Should Decimal block lead-signal proof, or can the proof pin Decimal as a host-policy escape first?
- Should operation lifecycle be its own proof, or compose with availability after the first two fixtures?

[X] Rejected:
- No public endpoints or secrets.
- No provider-client implementation work.
- No edits to `/Users/alex/dev/projects/sparkcrm`.

[Next] Proposed next slice:
- `[Igniter-Lang Research Agent]` `spark-technician-availability-fixture-v0`.
- `[Igniter-Lang Research Agent]` `spark-lead-signal-boundary-fixture-v0`.
- `[Igniter-Lang Compiler/Grammar Expert]` `spark-tenant-decimal-idempotency-formalization-v0`.
