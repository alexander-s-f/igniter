# Track: Runtime Contracts and Execution Environments v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

This slice investigates runtime as a contract-addressable semantic boundary.

`axiomatic-contract-model.md` states:

```text
Runtime
  = contract over execution of contracts
```

This is the missing layer between typed language meaning and concrete
execution. A user contract is not fully meaningful as:

```text
eval(G, Tt, inputs)
```

unless we also know which runtime contract executed it:

```text
eval(LanguageContract, RuntimeContract, UserContract, Tt, inputs)
  -> result | observations | failures | receipts
```

## Source Horizon

- `igniter-lang/docs/axiomatic-contract-model.md`
- `igniter-lang/docs/temporal-positioning.md`
- `igniter-lang/docs/proposals/PROP-001-semantic-domain-v0.md`
- `igniter-lang/docs/proposals/PROP-004-type-system-v0.md`
- `igniter-lang/docs/proposals/PROP-005-bridge-observation-envelope-v0.md`
- `igniter-lang/docs/tracks/temporal-contracts-and-projections-v0.md`
- `docs/dev/execution-model.md` (read-only platform context)
- `docs/dev/cluster-target-plan.md` (read-only platform context)

## Compact Claim

[D] A **RuntimeContract** declares what a human, agent, compiler, or bridge can
rely on about contract execution.

```text
RuntimeContract = {
  runtime_id
  language_fragment
  clock_guarantees
  scheduler_guarantees
  concurrency_guarantees
  cache_policy
  invalidation_policy
  storage_replay_policy
  capability_executor_policy
  observation_policy
  distributed_composition_policy
  result_status_policy
}
```

[D] An **ExecutionEnvironment** is a concrete runtime instance plus bound
resources:

```text
ExecutionEnvironment = {
  runtime_contract
  host_ref
  clock_source
  store_bindings
  scheduler_binding
  capability_bindings
  observation_sink
  temporal_context
}
```

The runtime contract is the semantic promise. The execution environment is the
place where that promise is instantiated.

## Why Runtime Is Semantic

Runtime behavior changes meaning when it affects:

- which clock supplied `as_of`
- whether reads are replayable
- whether parallel branches observe the same fact horizon
- whether cache hits are still valid
- whether an effect was authorized, skipped, retried, or blocked
- whether distributed peers agree on result identity
- whether a value is reproducible, live, stale, or provisional

[D] These are not "implementation details" when a human or agent acts from a
projection. They are part of the evidence chain.

## Clock Guarantees

A runtime must declare which temporal promises it can make.

| Guarantee | Meaning | Result impact |
|-----------|---------|---------------|
| `:none` | Runtime does not supply semantic time | Cannot produce temporal claims |
| `:wall_clock_reported` | Clock is reported but not semantic input | Useful for provenance only |
| `:fixed_as_of` | Evaluation receives a fixed `as_of` | Can support reproducible results |
| `:monotonic_order` | Runtime can order events within one execution | Supports deterministic event traces |
| `:replay_clock` | Runtime can restore a prior temporal cursor | Supports replay/audit |
| `:causal_clock` | Runtime tracks causal boundaries across peers | ESCAPE until distributed semantics settle |

[D] `emitted_at` / `observed_at` is never the semantic clock. It is packet
production time. `as_of`, `replay_cursor`, and causal clock are semantic
runtime inputs only when declared by `clock_guarantees`.

### Clock Rule

```text
runtime_can_claim_reproducible_time =
  fixed_as_of &&
  fixed_rule_version &&
  replay_clock_or_no_replay &&
  no_ambient_wall_clock_reads
```

[X] A runtime may not silently read current wall-clock time inside a CORE
contract and still label the result reproducible.

## Scheduler And Concurrency Guarantees

The scheduler decides how demand-driven nodes are evaluated. The concurrency
policy declares which interleavings are allowed and observable.

| Scheduler | Guarantee | Class |
|-----------|-----------|-------|
| `:inline_deterministic` | Single-threaded topological demand resolution | CORE |
| `:parallel_deterministic_join` | Parallel branches may run, but joins preserve deterministic result identity | CORE if no shared mutable reads |
| `:async_deferred` | Nodes may return pending/deferred values | CORE with explicit pending state |
| `:speculative` | Runtime may compute candidates not ultimately used | ESCAPE unless observations mark speculation |
| `:distributed` | Nodes may run on different runtime contracts | ESCAPE until composition is declared |

[D] Concurrency is safe only when the runtime can explain the join:

```text
join_observation = {
  branches
  branch_horizons
  scheduler
  selected_values
  discarded_values
  failure_policy
}
```

[R] Parallelism should not change the value of a CORE contract. If it can
change the value, the result must be marked `:provisional`, `:live`, or
`:failed` depending on the cause.

## Cache And Invalidation

Cache is part of the runtime contract because cached values can preserve or
corrupt semantic meaning.

```text
CacheKey = {
  graph_hash
  node_path
  input_hash
  temporal_context_hash
  rule_version
  runtime_contract_version
  capability_policy_hash
}
```

[D] A cache hit is semantically valid only if the cache key covers every value
that could change the result meaning.

### Invalidation Causes

| Cause | Meaning |
|-------|---------|
| `input_changed` | Caller-visible input changed |
| `fact_changed` | Store/History fact inside `fact_scope` changed |
| `rule_changed` | Contract, guard, policy, or type rule changed |
| `horizon_changed` | `as_of`, `rule_version`, `fact_scope`, or replay cursor changed |
| `capability_changed` | Grant, denial, scope, or executor policy changed |
| `runtime_changed` | Runtime contract version or guarantee set changed |
| `cache_expired` | TTL/freshness policy exceeded |
| `unknown_dependency` | Runtime cannot prove freshness |

```text
cache_status = :fresh | :stale | :unknown | :provisional
```

[D] `:unknown` and `:provisional` are not failure statuses. They are runtime
evidence statuses that may force a projection to be live or provisional.

## Storage And Replay

Storage/replay support is a runtime promise, not a universal language fact.

```text
StorageReplayPolicy = {
  store_consistency
  snapshot_support
  history_support
  replay_cursor_support
  compaction_visibility
  restore_guarantee
}
```

| Support | Meaning | Result impact |
|---------|---------|---------------|
| `snapshot_support` | Runtime can persist execution/cache state | Enables resume evidence |
| `history_support` | Runtime can read append-only facts | Enables replay windows |
| `replay_cursor_support` | Runtime can pin and restore cursor | Enables audit-grade replay |
| `compaction_visibility` | Runtime reports what compaction removed or summarized | Prevents false replay claims |
| `restore_guarantee` | Runtime can restore equivalent execution identity | Supports reproducible receipt review |

[D] A runtime without replay cursor support may still produce live projections,
but it cannot honestly produce audit-grade reproducible replay results.

[R] Compaction should produce observations. A compacted history is acceptable
only if the runtime can say which facts were preserved, summarized, or made
unavailable.

## Capability Executor

Effects are not executed by contracts directly. They pass through a capability
executor whose guarantees are part of the runtime contract.

```text
CapabilityExecutorPolicy = {
  grant_model
  dry_run_support
  review_only_support
  idempotency_key_support
  retry_policy
  receipt_guarantee
  redaction_policy
}
```

| Outcome | Meaning |
|---------|---------|
| `:executed` | Capability granted and effect performed |
| `:dry_run` | Capability path evaluated without mutation |
| `:review_only` | Human/agent approval required before mutation |
| `:blocked` | Capability denied or missing |
| `:provisional` | Executor cannot prove final effect status yet |

[D] Capability execution must produce `receipt_observation` or
`failure_observation`. Silent effects are OOF for Igniter-Lang semantics.

[R] Mutation-grade actions from live projections must first pin a reproducible
decision horizon, then execute under a capability executor that emits a receipt.

## Distributed Runtime Composition

Distributed execution composes runtime contracts.

```text
RuntimeCompositionContract = {
  members: Collection[RuntimeContractRef]
  placement_policy
  routing_policy
  clock_relationship
  observation_sync_policy
  cache_coherence_policy
  capability_delegation_policy
  failure_merge_policy
}
```

[D] A distributed result is reproducible only if every participating runtime
can prove compatible guarantees for the slice being produced.

```text
distributed_reproducible =
  all(member.result_status == :reproducible) &&
  compatible(member.horizon) &&
  compatible(member.clock_guarantees) &&
  observation_sync_policy.deduplicates_identity &&
  capability_delegation_policy.receipted
```

If one peer is live, stale, provisional, or has an unpinned horizon, the
composition cannot be more reproducible than that weakest member.

### Distributed Observation Requirements

A distributed runtime should emit or link:

- which runtime evaluated each contract/node
- which horizon each runtime used
- which route/placement policy selected the runtime
- which capability boundary allowed each effect
- which observations were deduplicated or merged
- which failures were local vs propagated

[X] Distributed execution as an invisible optimization. It affects identity,
clock, capability, failure, and replay semantics.

## Result Meaning Status

`failure-observation-v0` separates `computation_status` from `service_level`.
Runtime adds a third orthogonal axis: **meaning status**.

```text
meaning_status =
  :reproducible
  | :live
  | :provisional
  | :stale
  | :unknown
```

| Status | Meaning | Actor posture |
|--------|---------|---------------|
| `:reproducible` | Fixed horizon plus sufficient runtime replay/storage/clock guarantees | Safe for approval, audit, replay, mutation receipt |
| `:live` | Successful result from moving horizon or current runtime state | Safe for inspection and low-impact suggestions |
| `:provisional` | Runtime has a pending, speculative, weak, or not-yet-receipted guarantee | Wait, refresh, or request proof before high-impact action |
| `:stale` | Result was valid, but invalidation says it no longer matches requested horizon | Refresh or use only for history |
| `:unknown` | Runtime cannot prove whether result is fresh/replayable | Treat as blocked for mutation-grade actions |

This axis composes with failure status:

```text
ResultEvidence = {
  computation_status
  service_level
  meaning_status
}
```

Examples:

- `:ok x :nominal x :reproducible`: audit-grade success
- `:ok x :nominal x :live`: current dashboard value
- `:ok x :nominal x :provisional`: pending distributed/capability proof
- `:failed x :nominal x :reproducible`: replayable failed computation
- `:ok x :degraded x :live`: service is degraded but current value exists

[D] `:provisional` is not a failure. It is an honesty marker: the runtime has
not yet provided the guarantees required for a stronger claim.

## Acting From Runtime Evidence

Human/agent action should inspect both projection horizon and runtime contract.

```text
1. Read projection_observation.
2. Follow executed_by / produced_by runtime link.
3. Inspect meaning_status.
4. If action mutates or approves, require :reproducible.
5. If status is :live, pin the projection and re-evaluate under a receipt path.
6. If status is :provisional, request missing runtime evidence or wait.
7. If distributed, inspect member runtimes and failure merge policy.
8. Emit receipt_observation with projection horizon and runtime_contract_ref.
```

[D] A result is action-safe when the actor can answer:

- What contract produced it?
- At what temporal horizon?
- Under which runtime contract?
- With which cache/storage/capability guarantees?
- What observation or receipt proves the result?

## Example: Local Reproducible Runtime

```text
runtime_id: local_inline_v0
language_fragment: CORE
clock_guarantees: [:fixed_as_of, :monotonic_order]
scheduler_guarantees: [:inline_deterministic]
concurrency_guarantees: [:single_threaded]
cache_policy: dependency_keyed
invalidation_policy: downstream_on_input_or_fact_change
storage_replay_policy:
  snapshot_support: true
  replay_cursor_support: true
capability_executor_policy:
  dry_run_support: true
  receipt_guarantee: true
result_status_policy:
  stable_horizon + replay_cursor -> :reproducible
```

This runtime can support command review, audit, and replay slices when the
projection horizon is pinned.

## Example: Live Availability Runtime

```text
runtime_id: local_live_projection_v0
clock_guarantees: [:wall_clock_reported, :monotonic_order]
scheduler_guarantees: [:parallel_deterministic_join]
cache_policy: ttl_plus_subscription_invalidation
storage_replay_policy:
  replay_cursor_support: false
capability_executor_policy:
  review_only_support: true
result_status_policy:
  latest_horizon -> :live
```

This runtime can produce technician availability views, but assignment must
pin a decision projection under a runtime with receipt/replay support.

## Example: Distributed Capability Runtime

```text
runtime_id: cluster_capability_route_v0
members: [local_inline_v0, remote_peer_a, remote_peer_b]
clock_relationship: monotonic_local + reported_remote
routing_policy: capability_aware
observation_sync_policy: identity_dedup
capability_delegation_policy: delegated_with_receipts
failure_merge_policy: local_failure_preserved + propagated_summary
result_status_policy:
  any_member_provisional -> :provisional
  all_members_reproducible -> :reproducible
```

This runtime can route work across peers, but its result is only as strong as
the weakest participating runtime guarantee.

## Bridge Candidates

[R] Extend `PROP-005` bridge vocabulary with runtime evidence:

```text
runtime_observation:
  kind: :descriptor_observation
  subject: runtime_contract_ref
  payload:
    runtime_id
    language_fragment
    clock_guarantees
    scheduler_guarantees
    concurrency_guarantees
    cache_policy
    invalidation_policy
    storage_replay_policy
    capability_executor_policy
    distributed_composition_policy
    result_status_policy
```

```text
execution_environment_observation:
  kind: :descriptor_observation
  subject: execution_environment_ref
  payload:
    runtime_contract_ref
    host_ref
    store_bindings
    clock_source
    scheduler_binding
    capability_bindings
    observation_sink
```

```text
value_observation | projection_observation | receipt_observation:
  links:
    - rel: executed_by
      to: runtime_contract_ref
    - rel: produced_in
      to: execution_environment_ref
```

[R] Runtime evidence should be metadata/observation first. Do not require
package runtime rewrites until the bridge vocabulary is approved.

## Core vs Escape

| Construct | Class | Reason |
|-----------|-------|--------|
| Inline deterministic runtime contract | CORE | Evaluation order is explicit and decidable |
| Fixed `as_of` clock guarantee | CORE | Closed temporal evaluation |
| Replay cursor support | CORE | Explicit History capability |
| Cache with complete dependency key | CORE | Freshness is checkable |
| Deferred pending node | CORE | Pending state is explicit |
| Parallel deterministic join | CORE | Result identity preserved |
| Speculative execution | ESCAPE | Requires speculation observations |
| Distributed runtime composition | ESCAPE | Requires declared composition contract |
| Causal clock across peers | ESCAPE | Distributed temporal model not settled |
| Ambient wall-clock reads | OOF | Violates temporal explicitness |
| Silent effects without receipt | OOF | Violates capability/observation model |
| Hidden cache reuse across horizons | OOF | Violates reproducibility |

## Rejected Paths

[X] Runtime as invisible implementation detail. Runtime guarantees can change
result meaning.

[X] Reproducible result from live clock. Reproducibility requires pinned
semantic time and sufficient replay/storage guarantees.

[X] Cache as performance-only. Cache participates in meaning when it supplies
a value instead of recomputing it.

[X] Distributed execution as transparent optimization. Runtime composition
must be observable.

[X] Capability executor as host callback. Effects require declared grants,
policies, and receipts.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/runtime-contracts-and-execution-environments-v0.md
Status: done

[D] Decisions:
- RuntimeContract is the semantic promise over contract execution.
- ExecutionEnvironment is a concrete runtime instance with bound clocks,
  stores, schedulers, capabilities, and observation sinks.
- Runtime meaning status is orthogonal to computation_status and service_level:
  reproducible, live, provisional, stale, unknown.
- Reproducibility requires both stable projection horizon and runtime guarantees
  for clock, replay/storage, cache freshness, and capability receipts.
- Distributed runtime composition cannot be stronger than its weakest member
  guarantee.

[R] Recommendations:
- Add runtime_observation and execution_environment_observation to the bridge
  vocabulary before package implementation work.
- Link projection/value/receipt observations to runtime evidence with
  executed_by and produced_in links.
- Treat provisional as an honesty marker, not a failure.
- Keep distributed composition ESCAPE until runtime composition contracts are
  formalized.

[S] Signals:
- `axiomatic-contract-model.md` is productive: language, runtime, user
  contracts, and time now compose without collapsing into one layer.
- Cache/invalidation is semantic once projections become action boundaries.
- Capability executor receipts are the runtime half of agent-safe action.

[Q] Open Questions:
- Should meaning_status become a formal field in ObsPacket, projection payload,
  or diagnostic summary?
- Is distributed runtime composition always ESCAPE in v0, or can a local
  deterministic cluster profile be CORE?
- Should cache keys formally include runtime_contract_version, or is that a
  bridge/runtime implementation invariant?

[X] Rejected:
- Runtime as hidden platform magic.
- Ambient clocks.
- Silent effects.
- Hidden cross-horizon cache reuse.
- Invisible distributed execution.

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/bridge-observation-envelope-v0.md`, incorporating
  named slices, projection horizons, runtime_observation,
  execution_environment_observation, and receipt pinning.
```
