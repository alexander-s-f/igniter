# Track: Temporal Contracts and Projections v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

This slice turns the temporal thesis into a practical product/semantic model:

```text
contract + explicit time + named slice = projection a human or agent can act on
```

It does not define grammar, runtime materialization, or package APIs. It
names the product unit that sits between a typed contract and an action:
the **named slice**.

## Source Horizon

- `igniter-lang/docs/temporal-positioning.md`
- `igniter-lang/docs/proposals/PROP-001-semantic-domain-v0.md`
- `igniter-lang/docs/proposals/PROP-003-grammar-fragment-classification-v0.md`
- `igniter-lang/docs/proposals/PROP-004-type-system-v0.md`
- `igniter-lang/docs/tracks/observable-spine-v0.md`
- `igniter-lang/docs/tracks/failure-observation-v0.md`
- `igniter-lang/docs/tracks/track-errata-application-v0.md`

## Compact Claim

[D] A **named slice** is the product-language unit for a typed projection:

```text
NamedSlice = name + contract_ref + output_shape + horizon + action_policy
```

The type system sees it as:

```text
Projection[T, horizon]
```

The product layer sees it as:

```text
"the thing the screen, operator, agent, or reviewer is allowed to rely on"
```

A named slice is not just a query result. It is a declared semantic boundary:

- what contract produced the value
- which temporal horizon was used
- which facts and rules were visible
- whether the result is reproducible or live
- which human/agent actions are valid from this view

## Formal Alignment

`PROP-004` defines the core type as `Projection[T, horizon]` with `as_of`,
`rule_version`, and `fact_scope`. This practical slice carries
`replay_cursor` as a product-level horizon refinement because `PROP-001`'s
temporal context `Tt` includes replay and because humans/agents need a pinned
cursor for audit and reconstruction.

[R] A later formal pass should decide whether `replay_cursor` becomes part of
`ProjectionHorizon` itself or remains an associated replay link on
`History[T]`/projection observations.

## Named Slice Definition

A named slice has a stable name because humans and agents need to reference it
without restating the whole contract graph.

```text
NamedSlice ::= {
  name          : SliceName
  contract_ref  : ContractRef
  output_type   : T
  horizon       : ProjectionHorizon
  mode          : :reproducible | :live
  subject       : SubjectRef | :many
  action_policy : ActionPolicy
}
```

The name is semantic, not cosmetic. `technician_availability_now` and
`technician_availability_as_of_dispatch` may share most code, but they are
different slices because they support different actions.

## Projection Modes

### Reproducible Projection

[D] A reproducible projection has no moving horizon fields.

```text
ProjectionHorizon = {
  as_of         : fixed TimeRef
  rule_version  : fixed VersionRef
  fact_scope    : bounded StoreRef | HistoryRef | FactSetRef
  replay_cursor : fixed CursorRef | :none
}
```

It can answer:

- "Why did the system recommend this?"
- "What would we have seen at that moment?"
- "Can an auditor, reviewer, or agent replay the same meaning?"

Reproducible projections are the default for:

- approvals
- explanations
- failure review
- command receipts
- agent handoff
- tests and regression comparisons

### Live Projection

[D] A live projection has at least one moving horizon field, usually
`as_of: :latest`, `rule_version: :latest`, or an open fact scope.

```text
ProjectionHorizon = {
  as_of         : :latest | caller_supplied TimeRef
  rule_version  : :latest | VersionRef
  fact_scope    : :all | dynamic StoreRef | HistoryRef
  replay_cursor : :none | open CursorRef
}
```

It can answer:

- "What should the operator see now?"
- "Which candidate is currently available?"
- "Is the service still degraded?"
- "Should an agent refresh before acting?"

Live projections are valid but not reproducible until they are pinned. Any
action taken from a live projection must either:

- capture a pinned receipt projection at decision time, or
- declare that the action was taken from a live view and may require refresh.

## Horizon Fields

`ProjectionHorizon` is the semantic boundary of a slice.

| Field | Meaning | Reproducible requirement |
|-------|---------|--------------------------|
| `as_of` | Semantic read point for facts, stores, histories, and contracts | fixed `TimeRef` |
| `rule_version` | Version of rules, guards, policies, and contract definitions | fixed `VersionRef` |
| `fact_scope` | Which facts, stores, histories, tenants, subjects, or partitions are visible | bounded reference |
| `replay_cursor` | Historical cursor used to rebuild or replay a slice | fixed cursor or `:none` |

[D] `observed_at` is not a horizon field. It records when an observation packet
was produced. `as_of` records which semantic world the projection read.

### Horizon Stability

```text
stable(horizon) =
  fixed(as_of) &&
  fixed(rule_version) &&
  bounded(fact_scope) &&
  fixed_or_none(replay_cursor)
```

```text
reproducible(projection) = stable(projection.horizon)
```

[R] A compiler or bridge may expose this as a simple boolean, but the reason
should remain inspectable by field.

## Example: Command Lifecycle Slice

Purpose: show where an app-owned command is in its lifecycle and what action is
safe next.

```text
name: command_lifecycle_review
contract_ref: contracts/command_lifecycle
output_type:
  command_id: CommandId
  stage: :draft | :validated | :approved | :executing | :succeeded | :failed
  next_actions: Collection[ActionRef]
  blockers: Collection[FailureRef]
horizon:
  as_of: 2026-05-05T12:00:00Z
  rule_version: command_rules@7
  fact_scope: command_history(command_id)
  replay_cursor: command_history:cursor:8841
mode: :reproducible
```

Human action:

- approve only if `stage == :validated` and no blocking failures are present
- ask for explanation by following the projection's observation links
- compare against a later live slice before executing if the command is stale

Agent action:

- propose the next action, not execute it, unless capability policy grants it
- attach the projection horizon to the proposed receipt
- refresh or reject if current facts no longer match the pinned horizon

[D] This keeps lifecycle out of the grammar as a workflow engine. Lifecycle is
a projection over command facts, stages, policies, and failures.

## Example: Technician Availability Slice

Purpose: show which technician can be assigned under current or pinned
dispatch constraints.

```text
name: technician_availability_for_dispatch
contract_ref: contracts/technician_availability
output_type:
  job_id: JobId
  candidates:
    - technician_id: TechnicianId
      status: :available | :busy | :offline | :unknown
      skill_match: Bool
      distance_band: :near | :regional | :remote
      constraints: Collection[ConstraintRef]
horizon:
  as_of: :latest
  rule_version: dispatch_rules@latest
  fact_scope:
    stores: [technicians, schedules, jobs]
    subject: job_id
  replay_cursor: :none
mode: :live
```

Human action:

- inspect the live candidate list
- choose a technician only after the selected row is pinned into a decision
  receipt
- treat `:unknown` as a failure/constraint, not as silently available

Agent action:

- rank candidates from the live projection
- before assignment, request a reproducible decision slice:

```text
technician_assignment_decision =
  technician_availability_for_dispatch pinned at decision_time
```

- emit a receipt with the pinned horizon and selected candidate

[D] Availability is naturally live; assignment must become reproducible.

## Example: Failure Slice

Purpose: show what failed, whether the service is degraded, and what recovery
action is safe.

```text
name: failure_review_window
contract_ref: contracts/failure_projection
output_type:
  failures:
    - failure_id: FailureId
      computation_status: :ok | :failed | :rejected | :blocked
      service_level: :nominal | :degraded
      reason_family: ReasonFamily
      platform_code: Symbol | None
      subject: SubjectRef
      links: Collection[ObservationRef]
horizon:
  as_of: 2026-05-05T12:10:00Z
  rule_version: failure_rules@3
  fact_scope: failure_history(window: 15m, service: dispatch)
  replay_cursor: failure_history:cursor:9902
mode: :reproducible
```

Human action:

- separate "computation failed" from "service degraded"
- drill into linked facts, receipts, and constraints
- approve retry only if policy and capability links permit it

Agent action:

- cluster failures by reason family
- recommend retry, rollback, or escalation based on the slice
- include the horizon in every remediation proposal

[D] A failure slice is not an error list. It is an explainable temporal
projection over failed/rejected/blocked computations and service-level drift.

## Acting From A Projection

A projection is actionable only when the actor knows its mode and horizon.

| Actor need | Required projection property |
|------------|------------------------------|
| Inspect current state | live projection is acceptable |
| Make a reversible suggestion | live projection plus refresh policy |
| Approve, assign, execute, or mutate | pinned reproducible projection |
| Explain a past decision | reproducible projection with links |
| Audit or replay | reproducible projection with fixed cursor |

### Action Protocol

```text
1. Read named slice.
2. Inspect mode and horizon.
3. If action is high-impact and slice is live, pin it.
4. Follow failure/capability/privacy links.
5. Act only if action_policy permits the actor and the horizon is suitable.
6. Emit receipt_observation with observed_under: projection.horizon.
```

[D] The action is not justified by the value alone. It is justified by:

```text
value + horizon + links + action_policy + receipt
```

This is what makes projections agent-friendly: an agent can tell whether it is
looking at a dashboard, an audit record, or an execution boundary.

## Core vs Escape

| Construct | Class | Reason |
|-----------|-------|--------|
| Fixed `as_of` projection | CORE | Closed evaluation at fixed `Tt` |
| `as_of: :latest` live projection | CORE | Explicitly non-reproducible |
| Fixed `rule_version` | CORE | Decidable rule identity |
| `rule_version: :latest` | CORE | Explicit live rule dependency |
| Bounded `fact_scope` | CORE | Finite visible world |
| Open `fact_scope: :all` | ESCAPE | May depend on unbounded platform scope |
| Fixed `replay_cursor` | CORE | Replay boundary is explicit |
| Open stream cursor | ESCAPE | Incremental stream semantics not settled |
| Valid-time + transaction-time query | ESCAPE | Bitemporal model deferred |
| Ambient wall-clock reads | OOF | Violates temporal explicitness |

## Bridge Candidates

[R] Future bridge work should map platform projections into the observation
envelope with these fields:

```text
projection_observation:
  identity:
    observation_id
    space
    kind: :projection_observation
    subject: named_slice.name
  provenance:
    producer
    observed_at
    content_hash
  policy:
    privacy
    capabilities
  payload:
    name
    contract_ref
    output_type
    mode
    horizon
    action_policy
```

[R] Do not ask packages to execute Igniter-Lang projections yet. The bridge
should first describe projection metadata and receipts.

## Rejected Paths

[X] Named slice as UI-only label. The name is semantic and appears in
observations, receipts, and agent handoff.

[X] Live projection as "almost reproducible." A live projection is useful, but
it must be pinned before audit-grade or mutation-grade action.

[X] `observed_at` as `as_of`. Packet time and semantic read time are different.

[X] Workflow engine semantics in v0. Command lifecycle is modeled as projection
over facts and stages, not as an imperative process language.

[X] Unbounded hidden fact scope. If fact scope is open, the projection must say
so and should be treated as ESCAPE until bounded.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/temporal-contracts-and-projections-v0.md
Status: done

[D] Decisions:
- A named slice is the product-language unit represented by
  Projection[T, horizon] in the type system.
- Reproducible projection means fixed as_of, fixed rule_version, bounded
  fact_scope, and fixed/no replay_cursor.
- Live projection is valid but explicitly non-reproducible; high-impact
  actions must pin it into a receipt horizon.
- Human/agent action is justified by value + horizon + links + action_policy
  + receipt, not by value alone.

[R] Recommendations:
- Use named slices as the bridge vocabulary for projection metadata.
- Carry horizon fields in projection_observation payloads.
- Require pinned reproducible projections for approvals, assignments,
  execution, audit, and remediation.
- Keep package work metadata/receipt-only until bridge-observation-envelope-v0
  is approved.

[S] Signals:
- The temporal model now has a practical action boundary.
- Technician availability demonstrates the live-to-pinned transition.
- Failure slices naturally consume the two-dimensional failure errata.

[Q] Open Questions:
- Should `fact_scope: :all` be ESCAPE or OOF for v0 production usage?
- Should `replay_cursor` be formalized inside `ProjectionHorizon`, or remain
  an associated replay link from `History[T]`?
- Should action_policy be part of Projection[T, horizon] formally, or only
  part of named slice metadata?
- Do we need a separate `decision_projection` kind, or is pinned
  projection_observation plus receipt_observation enough?

[X] Rejected:
- Treating slices as dashboards only.
- Allowing ambient wall-clock reads.
- Letting agents mutate from live projections without pinning.

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/bridge-observation-envelope-v0.md`, now including
  named slice, horizon, projection_observation, and receipt pinning semantics.
```
