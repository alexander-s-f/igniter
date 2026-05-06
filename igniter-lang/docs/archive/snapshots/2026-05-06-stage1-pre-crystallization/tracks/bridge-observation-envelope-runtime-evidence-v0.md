# Track: Bridge Observation Envelope Runtime Evidence v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

This slice extends the bridge observation vocabulary with runtime evidence.

`PROP-005` defines the typed observation envelope. `runtime-contracts-and-
execution-environments-v0` defines runtime as a semantic contract. This track
joins them:

```text
projection/value/receipt observation
  -> links to runtime_observation
  -> links to execution_environment_observation
  -> carries meaning_status
  -> tells humans/agents whether action is safe
```

This is a bridge vocabulary slice only. It does not prescribe wire format,
package code, transport, or runtime implementation.

## Source Horizon

- `igniter-lang/docs/proposals/PROP-005-bridge-observation-envelope-v0.md`
- `igniter-lang/docs/proposals/PROP-004b-axiom-layer-type-signatures-v0.md`
- `igniter-lang/docs/tracks/runtime-contracts-and-execution-environments-v0.md`
- `igniter-lang/docs/tracks/temporal-contracts-and-projections-v0.md`
- `igniter-lang/docs/axiomatic-contract-model.md`
- `igniter-lang/docs/temporal-positioning.md`

## Compact Claim

[D] Runtime evidence is bridge-level semantic evidence, not platform noise.

A projection or receipt that does not say which runtime produced it cannot
support reproducible, auditable, or agent-safe action.

```text
action_safe_result =
  value_or_projection
  + temporal_horizon
  + runtime_contract
  + execution_environment
  + meaning_status
  + receipt
```

## Vocabulary Additions

This track proposes three bridge vocabulary additions:

1. `runtime_observation`
2. `execution_environment_observation`
3. `meaning_status`

It also proposes two link relations:

1. `:executed_by`
2. `:produced_in`

`PROP-005` currently defines a closed `LinkRel` family. Therefore these links
are a deliberate extension candidate for the next formal envelope revision or
bridge implementation profile.

[D] In this track, names ending in `_observation` are bridge profile names.
They lower onto existing `PROP-005` kinds unless and until the formal envelope
adds new closed `ObsKind` values. In particular:

| Profile name | v0 envelope kind |
|--------------|------------------|
| `runtime_observation` | `:descriptor_observation` |
| `execution_environment_observation` | `:descriptor_observation` |
| `projection_observation` | `:value_observation` or `:descriptor_observation` profile |

## runtime_observation

A `runtime_observation` describes the runtime contract that promises execution
semantics.

```text
Obs[:descriptor_observation, RuntimeContractPayload]

RuntimeContractPayload = Record {
  runtime_id                      : String
  runtime_contract_version         : VersionRef
  language_fragment                : :CORE | :ESCAPE_PROFILE
  supported_escapes                : Collection[Symbol]
  clock_guarantees                 : Collection[ClockGuarantee]
  scheduler_guarantees             : Collection[SchedulerGuarantee]
  concurrency_guarantees           : Collection[ConcurrencyGuarantee]
  cache_policy                     : CachePolicySummary
  invalidation_policy              : InvalidationPolicySummary
  storage_replay_policy            : StorageReplayPolicySummary
  capability_executor_policy       : CapabilityExecutorPolicySummary
  distributed_composition_policy   : Option[DistributedCompositionSummary]
  result_status_policy             : ResultStatusPolicySummary
  observation_policy               : ObservationPolicySummary
}
```

Envelope placement:

```text
kind: :descriptor_observation
subject: runtime://<runtime_id>@<runtime_contract_version>
producer.kind: :runtime | :platform
temporal: None unless the runtime descriptor itself is versioned by time
```

[D] `runtime_observation` describes the promise. It should be stable enough
to link from many values, projections, failures, and receipts.

## execution_environment_observation

An `execution_environment_observation` describes the concrete runtime instance
that produced an observation.

```text
Obs[:descriptor_observation, ExecutionEnvironmentPayload]

ExecutionEnvironmentPayload = Record {
  execution_environment_id : String
  runtime_contract_ref     : ObsId | ExternalRef
  host_ref                 : Option[ExternalRef]
  process_ref              : Option[String]
  clock_source             : ClockSourceRef
  scheduler_binding        : SchedulerBindingRef
  store_bindings           : Collection[StoreBindingRef]
  history_bindings         : Collection[HistoryBindingRef]
  capability_bindings      : Collection[CapabilityBindingRef]
  observation_sink         : ObservationSinkRef
  execution_id             : Option[String]
  trace_id                 : Option[String]
}
```

Envelope placement:

```text
kind: :descriptor_observation
subject: environment://<execution_environment_id>
producer.kind: :runtime | :platform
links:
  - rel: :describes
    ref: runtime_contract_ref
    required: true
```

[D] `execution_environment_observation` describes the instance. It may be
re-emitted as host bindings, store bindings, or capability bindings change.

## meaning_status

`meaning_status` records what the runtime can honestly claim about the result's
semantic strength.

```text
MeaningStatus =
  :reproducible
  | :live
  | :provisional
  | :stale
  | :unknown
```

It is orthogonal to the failure model:

```text
ResultEvidence = Record {
  computation_status : :ok | :failed | :rejected | :blocked
  service_level      : :nominal | :degraded
  meaning_status     : MeaningStatus
}
```

### Placement

[D] In v0 bridge vocabulary, `meaning_status` should live in the payload of
value/projection/receipt/failure observations that are produced by runtime
execution.

```text
projection_observation.payload.meaning_status
receipt_observation.payload.meaning_status
failure_observation.payload.meaning_status
value_observation.payload.meaning_status
```

Reason: `PROP-005` does not yet define a top-level meaning-status group, and
`extensions` cannot change core semantics. Payload placement makes the field
visible without mutating the formal envelope type prematurely.

[R] A later PROP-005 revision may promote `meaning_status` into a formal
diagnostic/result-evidence group if repeated bridge pressure confirms it.

## Link Relations

This track proposes two new `TypedLink.rel` values:

```text
LinkRel += :executed_by | :produced_in
```

| Link | From | To | Required | Meaning |
|------|------|----|----------|---------|
| `:executed_by` | value/projection/failure/receipt observation | `runtime_observation` | true for runtime-produced packets | Which runtime contract made the result meaningful |
| `:produced_in` | value/projection/failure/receipt observation | `execution_environment_observation` | true for runtime-produced packets | Which concrete environment produced this packet |

`executed_by` links to the promise. `produced_in` links to the instance.

[D] A packet may have `executed_by` without `produced_in` only when the bridge
knows the runtime contract but the concrete environment was redacted or not
captured. In that case the missing environment must appear as a diagnostic,
and the result cannot claim `meaning_status: :reproducible`.

## Projection References To Runtime Evidence

A projection observation should include named slice, horizon, runtime links,
and meaning status.

```text
Obs[:value_observation, ProjectionEvidencePayload]

ProjectionEvidencePayload = Record {
  name             : SliceName
  contract_ref     : ContractRef
  output_type      : TypeRef
  mode             : :reproducible | :live
  horizon          : ProjectionHorizon
  meaning_status   : MeaningStatus
  action_policy    : ActionPolicySummary
  result_summary   : Option[Any]
}

links:
  - rel: :observed_under
    ref: horizon_observation_or_temporal_context_ref
    required: true
  - rel: :executed_by
    ref: runtime_observation_id
    required: true
  - rel: :produced_in
    ref: execution_environment_observation_id
    required: true
  - rel: :depends_on
    ref: fact_or_descriptor_observation_id
    required: false
```

Classification:

- `meaning_status: :reproducible` requires stable horizon plus runtime evidence.
- `meaning_status: :live` is valid for moving horizons.
- `meaning_status: :provisional` is valid for pending or weak runtime proof.
- `meaning_status: :stale` means invalidation has outpaced the observation.
- `meaning_status: :unknown` means runtime evidence is incomplete.

[D] A projection without runtime links may still be inspectable as a platform
artifact, but it is not an action-safe Igniter-Lang projection.

## Receipt References To Runtime Evidence

A receipt observation should bind the action to both projection evidence and
runtime evidence.

```text
Obs[:receipt_observation, RuntimeBackedReceiptPayload]

RuntimeBackedReceiptPayload = Record {
  receipt_id       : String
  action_ref       : ActionRef
  actor_ref        : ActorRef
  status           : :accepted | :rejected | :deduplicated | :executed
                    | :dry_run | :review_only | :blocked | :provisional
  meaning_status   : MeaningStatus
  idempotency_key  : Option[String]
  decision_horizon : ProjectionHorizon
  capability_ref   : Option[CapabilityRef]
}

links:
  - rel: :caused_by
    ref: intent_observation_id
    required: true
  - rel: :derived_from
    ref: projection_observation_id
    required: true
  - rel: :executed_by
    ref: runtime_observation_id
    required: true
  - rel: :produced_in
    ref: execution_environment_observation_id
    required: true
  - rel: :satisfies
    ref: capability_policy_observation_id
    required: false
```

[D] A receipt is the pinning point for action. If an agent acts from a live
projection, the receipt must capture the pinned decision horizon and runtime
evidence used at action time.

## Failure References To Runtime Evidence

Runtime evidence also applies to failure observations.

```text
Obs[:failure_observation, RuntimeFailurePayload]

RuntimeFailurePayload = Record {
  failure_id          : FailureId
  computation_status  : :failed | :rejected | :blocked
  service_level       : :nominal | :degraded
  meaning_status      : MeaningStatus
  reason_family       : ReasonFamily
  runtime_cause       : Option[:clock | :scheduler | :cache | :storage
                              | :capability | :distributed | :unknown]
  platform_code       : Option[Symbol]
}

links:
  - rel: :violates
    ref: runtime_or_contract_expectation_ref
    required: true
  - rel: :executed_by
    ref: runtime_observation_id
    required: false
  - rel: :produced_in
    ref: execution_environment_observation_id
    required: false
```

Examples:

- cache key incomplete -> `meaning_status: :unknown`,
  `runtime_cause: :cache`
- replay cursor missing -> `meaning_status: :provisional`,
  `runtime_cause: :storage`
- capability denied -> `computation_status: :blocked`,
  `meaning_status: :reproducible` if the denial is fully receipted

## Agent Action Semantics

Agents must inspect `meaning_status` before acting.

| meaning_status | Agent may | Agent must not |
|----------------|-----------|----------------|
| `:reproducible` | explain, approve if capability permits, execute if receipt path is available | ignore policy/capability links |
| `:live` | inspect, rank, suggest, request pinning | mutate, approve, or execute without a pinned receipt horizon |
| `:provisional` | wait, request proof, ask for human review, emit low-confidence recommendation | present as final or execute |
| `:stale` | explain past state, compare to fresh projection | act as if current |
| `:unknown` | ask for missing runtime evidence or fail closed | infer safety from payload value alone |

### Agent Action Protocol

```text
1. Read projection_observation or receipt_observation.
2. Read payload.meaning_status.
3. Follow :executed_by to runtime_observation.
4. Follow :produced_in to execution_environment_observation.
5. If meaning_status is :live and action is high-impact, request pinning.
6. If meaning_status is :provisional, request missing proof or wait.
7. If meaning_status is :stale, refresh before current-world action.
8. If meaning_status is :unknown, fail closed.
9. Emit receipt_observation with runtime links for any accepted action.
```

[D] Agent action is safe only when the agent can explain the full chain:

```text
projection -> runtime contract -> execution environment -> capability receipt
```

## Bridge Wellformedness Rules

### WF-RT-1: Runtime Link Required

Any runtime-produced `value_observation`, `projection_observation`,
`receipt_observation`, or `failure_observation` must include `:executed_by`.

### WF-RT-2: Environment Link Required For Reproducible Claims

Any observation with `meaning_status: :reproducible` must include
`:produced_in`.

### WF-RT-3: Missing Runtime Evidence Weakens Meaning

If `:executed_by` or `:produced_in` is missing, the observation must not claim
`:reproducible`. It must be `:provisional`, `:unknown`, or a failure.

### WF-RT-4: Live Cannot Mutate Without Receipt Pinning

An agent or capability executor must not produce a mutation receipt directly
from `meaning_status: :live` unless the receipt captures a pinned decision
horizon.

### WF-RT-5: Stale Cannot Become Current By Receipt

A receipt may acknowledge action over a stale projection only as historical
review. It may not represent a stale projection as current-world evidence.

### WF-RT-6: Provisional Must Name Missing Proof

`meaning_status: :provisional` must include a diagnostic naming the missing
runtime proof:

```text
missing_proof: :replay_cursor | :capability_receipt | :distributed_member
             | :cache_freshness | :clock_guarantee | :environment_ref
```

## Example: Live Projection To Pinned Receipt

```text
projection_observation:
  subject: slice://technician_availability_for_dispatch
  payload:
    mode: :live
    meaning_status: :live
    horizon:
      as_of: :latest
      rule_version: dispatch_rules@latest
  links:
    - rel: :executed_by
      ref: runtime://local_live_projection_v0
    - rel: :produced_in
      ref: environment://dispatch-web-1
```

Agent action:

```text
recommend candidate, then request pinning before assignment
```

Pinned receipt:

```text
receipt_observation:
  subject: receipt://assignment/8841
  payload:
    action_ref: assign_technician
    meaning_status: :reproducible
    decision_horizon:
      as_of: 2026-05-05T12:15:00Z
      rule_version: dispatch_rules@42
      fact_scope: job/123 + technicians + schedules
      replay_cursor: dispatch-history:cursor:8841
  links:
    - rel: :derived_from
      ref: projection_observation_id
    - rel: :executed_by
      ref: runtime://local_inline_v0
    - rel: :produced_in
      ref: environment://assignment-worker-2
```

[D] The live projection supported recommendation. The pinned receipt supports
assignment.

## Bridge Implementation Shape

[R] First implementation should be metadata-only:

- emit runtime descriptors
- emit execution environment descriptors
- add runtime links to existing projection/value/receipt observations
- compute `meaning_status` from already-known runtime evidence
- do not rewrite package execution semantics
- do not require distributed runtime changes

[R] Package-specific fields should remain payload summaries or extension
metadata until the bridge profile proves which fields deserve formal status.

## Rejected Paths

[X] Runtime evidence as log-only metadata. It changes whether a result is
action-safe.

[X] `executed_by` and `produced_in` as optional decoration for reproducible
results. Reproducibility requires runtime evidence.

[X] Agent mutation from live projection without pinning.

[X] Treating `provisional` as failure. It is a weaker evidence claim, not
necessarily a failed computation.

[X] Promoting `meaning_status` to a top-level envelope field before a formal
PROP-005 revision. In this track it lives in payload/result evidence.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/bridge-observation-envelope-runtime-evidence-v0.md
Status: done

[D] Decisions:
- Add runtime_observation as descriptor evidence for RuntimeContract.
- Add execution_environment_observation as descriptor evidence for the concrete
  runtime instance.
- Add meaning_status to runtime-produced observation payloads.
- Extend LinkRel with :executed_by and :produced_in as bridge vocabulary
  candidates.
- Projection and receipt observations must link to runtime evidence when they
  support agent or human action.
- live/provisional/stale/unknown weaken agent action rights; reproducible is
  required for mutation-grade action.

[R] Recommendations:
- Treat this track as a PROP-005 bridge profile or errata candidate.
- Keep the first package bridge metadata-only.
- Make missing runtime evidence degrade meaning_status instead of silently
  claiming reproducibility.
- Require agents to fail closed on meaning_status: :unknown.

[S] Signals:
- Runtime evidence completes the action chain started by named slices.
- :executed_by vs :produced_in cleanly separates promise from instance.
- meaning_status gives agents a compact action gate without collapsing failure,
  service health, and reproducibility into one field.

[Q] Open Questions:
- Should :executed_by and :produced_in become CORE LinkRel values in PROP-005,
  or a bridge-profile extension first?
- Should meaning_status be promoted to a formal ObsPacket group?
- Is projection_observation a new ObsKind, or should it remain a typed
  value_observation/descriptor_observation profile in v0?

[X] Rejected:
- Runtime evidence as platform logs.
- Agents acting from payload values without checking runtime evidence.
- Mutation receipts from live projections without pinning.

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/bridge-observation-envelope-package-mapping-v0.md`
  as a metadata-only package mapping preflight, no package edits.
```
