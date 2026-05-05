# Track: Failure Observation v0

Status: proposal
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

Prove the observable spine on one narrow, high-value case:

```text
Failure is an observation.
Failure is an unsatisfied contract, not an exception side-channel.
```

This is not a runtime implementation, exception hierarchy, or package API
proposal. It is a semantic model for failure packets that can later inform
compiler diagnostics, health drift, blocked capability flows, materializer
parity failures, and bridge proposals.

## Source Horizon

Read-only sources used:

- `igniter-lang/docs/tracks/observable-contract-language-v0.md`
- `igniter-lang/docs/tracks/observable-spine-v0.md`
- `docs/dev/execution-model.md`
- `packages/igniter-contracts/README.md`
- `packages/igniter-contracts/lib/igniter/contracts/execution/diagnostics*.rb`
- `lib/igniter/errors.rb`
- `packages/igniter-ledger/docs/open-protocol.md`
- `packages/igniter-ledger/docs/tracks/changefeed-production-diagnostics-v0.md`
- `packages/igniter-ledger/docs/relations-specification.md`
- `packages/igniter-durable-model/docs/current-status.md`
- `packages/igniter-durable-model/docs/manifest-glossary.md`
- `examples/application/companion/contracts/static_materialization_parity_contract.rb`
- `examples/application/companion/contracts/materializer_gate_contract.rb`
- `examples/application/companion/contracts/materializer_preflight_contract.rb`

## Compact Claim

[D] A failure observation is a structured claim that an expected contract,
constraint, descriptor, effect, capability, temporal assumption, or platform
boundary was not satisfied under a named context.

Failure should answer five questions without requiring a host stack trace:

1. What failed?
2. Which expectation did it violate?
3. What caused or informed the failure?
4. What can a human, agent, compiler, or runtime safely do next?
5. Which details were redacted, deferred, or gated behind debug capability?

In Igniter-Lang, failure is not the absence of output. It is an output in the
diagnostic plane.

## Failure Packet

This pseudo-structure is **proposed as the v0 failure payload inside the
ObservationPacket envelope**, not final wire syntax:

```text
ObservationPacket {
  schema_version: 1
  kind: :failure_observation
  observation_id: ObservationId
  space: ObservationSpace
  subject: SubjectRef
  status: :failed | :rejected | :blocked | :degraded
  producer: ProducerRef
  observed_at: Timestamp
  content_hash: Hash
  privacy: PrivacyPolicy
  links: [ObservationLink]
  temporal?: TemporalContext
  diagnostics: [FailureDiagnostic]
  capabilities?: CapabilitySummary
  actor?: ActorRef
  payload?: FailurePayload
}
```

Required failure semantics:

- `status` distinguishes fault shape:
  - `failed`: attempted evaluation/execution did not satisfy the contract
  - `rejected`: compiler/verifier/protocol refused an invalid shape or request
  - `blocked`: execution/action was intentionally not attempted
  - `degraded`: system is live but a semantic service level is not healthy
- `subject` is the smallest contract-relevant thing that failed: contract,
  node, descriptor, intent, packet, relation, materializer plan, capability, or
  platform boundary.
- `diagnostics` carries at least one compact failure diagnostic.
- `links` carries at least one `violates`, `caused_by`, or `observed_under`
  link.
- `privacy` says whether values, prompts, traces, or payloads were redacted.

## Diagnostic Shape

This pseudo-structure is **proposed as v0**:

```text
FailureDiagnostic {
  reason_code: ReasonCode
  severity: :info | :warning | :error | :fatal
  path?: PathRef
  expectation?: ExpectationRef
  actual?: RedactedValueSummary
  summary: String
  remediation?: RemediationHint
  retry?: RetryPolicy
  debug_ref?: GatedArtifactRef
}
```

Field guidance:

- `reason_code` is machine-stable and compact.
- `severity` is for user/operator priority, not semantic truth.
- `path` points to graph/node/field/relation/capability location.
- `expectation` names the violated contract, descriptor, type, guard, invariant,
  policy, or capability.
- `actual` is optional and redaction-aware.
- `summary` is short human text.
- `remediation` is structured enough for agents to propose a next action.
- `retry` is explicit; do not infer retryability from severity.
- `debug_ref` points to gated host details when they exist.

## Reason Code Taxonomy

[D] v0 should reserve a small top-level taxonomy and allow specific package
codes under each family.

Core reason families:

| Family | Example codes | Meaning |
|--------|---------------|---------|
| `compile` | `cycle_detected`, `unknown_node`, `missing_output`, `unsupported_construct`, `out_of_fragment` | Static graph or language shape was rejected |
| `input` | `missing_input`, `invalid_input_type`, `invalid_input_shape`, `collection_key_missing` | Caller data failed boundary requirements |
| `constraint` | `type_mismatch`, `guard_failed`, `invariant_violated`, `deadline_unmet`, `privacy_policy_failed` | Declared constraint was not satisfied |
| `dependency` | `dependency_failed`, `dependency_pending`, `stale_dependency`, `unresolved_reference` | Required upstream observation unavailable or failed |
| `temporal` | `as_of_unavailable`, `rule_version_missing`, `causal_context_missing`, `freshness_lag_exceeded`, `history_gap` | Time/replay/causal semantics could not be satisfied |
| `effect` | `effect_rejected`, `idempotency_conflict`, `receipt_missing`, `store_write_failed`, `append_failed` | External mutation or its receipt failed |
| `capability` | `capability_missing`, `capability_denied`, `approval_required`, `execution_not_allowed`, `grant_forbidden` | Authority boundary blocked action |
| `materializer` | `parity_drift`, `source_horizon_incomplete`, `artifact_hash_mismatch`, `dry_run_failed`, `review_only_boundary` | Static materialization could not proceed safely |
| `agent` | `tool_denied`, `evidence_incomplete`, `proposal_rejected`, `unsafe_payload_redacted`, `model_boundary_failed` | Agent participation failed under declared policy |
| `platform` | `backend_unavailable`, `transport_error`, `provider_error`, `clock_unavailable`, `unsupported_platform_feature` | A named platform/axiom boundary failed |
| `diagnostic` | `health_drift`, `delivery_degraded`, `subscriber_failed`, `queue_pressure`, `descriptor_drift` | Report-only health/observability signal |

Specific platforms may emit more precise codes, but they should preserve the
family. Example: `diagnostic.changefeed_queue_pressure` can lower to family
`diagnostic`, code `queue_pressure`, and extension
`platform_code: :changefeed_queue_pressure`.

## Link Requirements

[D] Failure observations should be explainable by links, not by prose alone.

Required link patterns by failure shape:

| Shape | Required links |
|-------|----------------|
| Compiler rejection | `violates` descriptor/fragment rule; `caused_by` source descriptor or syntax artifact |
| Input failure | `violates` input descriptor/type; `caused_by` caller value observation if available |
| Runtime node failure | `violates` node contract; `caused_by` failed dependency or platform boundary |
| Health drift | `violates` health descriptor; `observed_under` platform/runtime snapshot |
| Blocked capability | `violates` capability policy; `caused_by` intent or approval state |
| Materializer parity drift | `violates` parity constraint; `derived_from` plan/static descriptor refs |
| Temporal failure | `violates` temporal constraint; `observed_under` `as_of` or replay context |
| Agent failure | `violates` tool/privacy/capability policy; `caused_by` agent intent or tool receipt |

Recommended relation use:

- `violates`: the expected contract/constraint that was not satisfied
- `caused_by`: the observation, intent, dependency, or platform boundary that
  explains why
- `observed_under`: time, platform, rule version, or execution context
- `depends_on`: upstream observations that had to exist for evaluation
- `redacts`: privacy contract that removed raw details

If a failure has no meaningful link, it is too opaque for v0 and should be
wrapped as `platform.backend_unavailable` or held behind a gated debug artifact.

## Remediation Model

[D] Remediation should be structured enough for agents, but humble enough not to
pretend every fix is executable.

Proposed remediation shape:

```text
RemediationHint {
  action: :provide_input | :fix_descriptor | :change_rule | :review_policy |
          :record_approval | :retry_later | :inspect_debug_ref |
          :open_bridge_proposal | :no_action
  target?: SubjectRef
  safe_to_automate: Boolean
  requires_capability?: CapabilityRef
  summary: String
}
```

Rules:

- `safe_to_automate: false` is the default.
- Any remediation that mutates files, facts, stores, capabilities, approvals, or
  platform state must name a required capability.
- Diagnostic-only drift should usually recommend review, not execution.
- Compiler and input failures may suggest shape changes, but should not
  silently coerce values unless a coercion contract exists.
- Materializer failures should prefer `review_policy`, `record_approval`, or
  `open_bridge_proposal` over direct execution.

## Privacy And Debug Artifacts

[D] Failure packets must be useful when payloads are redacted.

Privacy fields should answer:

- Was `actual` omitted, summarized, hashed, or fully present?
- Were raw prompts, user data, stack traces, provider traces, SQL errors, or
  filesystem paths redacted?
- Is there a gated `debug_ref`?
- Which capability/retention policy controls that debug ref?

Host details that stay out of the packet by default:

- Ruby exception backtrace
- full SQL/provider/network error payload
- raw agent prompt or chain-of-thought
- complete user input when a hash/path/count is enough
- heap/thread/scheduler internals
- full generated artifact contents when an artifact ref and hash suffice

`debug_ref` may exist, but only as a gated artifact, not as required semantic
meaning.

## Worked Examples

These examples are **illustrative**, not final wire syntax.

### Missing Input

```text
kind: :failure_observation
status: :rejected
subject: contract://OrderTotal#input.order
diagnostics:
  - reason_code: input.missing_input
    severity: :error
    path: OrderTotal.input.order
    expectation: descriptor://OrderTotal/input/order
    summary: "Required input `order` was not provided."
    remediation:
      action: :provide_input
      target: contract://OrderTotal#input.order
      safe_to_automate: false
links:
  - rel: :violates
    ref: descriptor://OrderTotal/input/order
privacy:
  actual_policy: :omitted
```

### Health Drift

```text
kind: :failure_observation
status: :degraded
subject: setup://health/materializer_status_descriptor
diagnostics:
  - reason_code: diagnostic.descriptor_drift
    severity: :warning
    path: materializer_status.descriptor.grants_capabilities
    expectation: "grants_capabilities == false"
    summary: "Materializer status descriptor no longer preserves no-grant boundary."
    remediation:
      action: :review_policy
      safe_to_automate: false
links:
  - rel: :violates
    ref: descriptor://materializer_status/no_grant_boundary
  - rel: :observed_under
    ref: setup://health/current
privacy:
  actual_policy: :present_summary
```

### Blocked Capability

```text
kind: :failure_observation
status: :blocked
subject: materializer://attempt/static_contract_write
capabilities:
  requested: [:write_file, :run_tests, :git_commit]
  granted: []
  denied: [:write_file, :run_tests, :git_commit]
diagnostics:
  - reason_code: capability.approval_required
    severity: :info
    path: MaterializerGate.requested_capabilities
    summary: "Materializer remains review-only until explicit approval is recorded."
    remediation:
      action: :record_approval
      requires_capability: capability://record_materializer_approval
      safe_to_automate: false
links:
  - rel: :caused_by
    ref: intent://materializer_capability_request
  - rel: :violates
    ref: policy://materializer/no_hidden_capability_grants
```

### Materializer Parity Drift

```text
kind: :failure_observation
status: :failed
subject: materializer://parity/static_manifests
diagnostics:
  - reason_code: materializer.parity_drift
    severity: :warning
    path: "StaticMaterializationParity.mismatches"
    summary: "Static materialization drift detected."
    remediation:
      action: :open_bridge_proposal
      safe_to_automate: false
links:
  - rel: :violates
    ref: constraint://static_materialization/parity
  - rel: :derived_from
    ref: descriptor://materialization_plan/current
  - rel: :derived_from
    ref: descriptor://manifest_snapshot/current
privacy:
  actual_policy: :present_summary
```

## Bridge Candidates

[R] Do not edit packages from this track. Bridge through explicit proposal docs
after Architect review.

1. **Diagnostics failure bridge.** Map current compiler/runtime diagnostics and
   `Igniter::Error` context (`graph`, `node`, `path`, `execution`,
   `source_location`) into `failure_observation` shape.

2. **Setup health drift bridge.** Map Companion/Durable Model health packets
   into `diagnostic.health_drift` or `diagnostic.descriptor_drift` failures
   with structured remediation and no-grant semantics.

3. **Materializer blocked/parity bridge.** Map materializer gate, preflight,
   parity, blocked attempts, and approval receipts into failure observations
   that preserve review-only and no-hidden-capability boundaries.

## Rejected Paths

[X] Failure as raw exception. Host exceptions may inform diagnostics, but they
are not the semantic packet.

[X] Failure as prose only. Humans need summaries; agents and compilers need
reason codes, paths, links, and remediation shape.

[X] Failure as automatic repair. A remediation hint is not a grant.

[X] Failure as global severity. Severity is consumer priority; reason family and
status carry semantics.

[X] Failure packets that require raw values or prompts. Redacted/hash-only
failures must remain useful.

[X] Treating degraded health as runtime failure. A system can be live while a
semantic service level is degraded.

[X] Flattening all blocked states into errors. Blocked can be the correct and
safe result.

## Next Slice Recommendation

[R] Next slice: `bridge-observation-envelope-v0`.

Purpose: turn the first three research slices into an explicit bridge proposal
candidate without editing package code. It should map Ledger Open Protocol
packets, Durable Model descriptors/receipts, and current diagnostics into the
observation envelope and failure model.

It should answer:

- Which current packet fields map cleanly to the observation envelope?
- Which fields require extension or redaction policy?
- Which package concepts should remain package-local?
- Which exact bridge docs should be created before any implementation slice?

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/failure-observation-v0
Status: done

[D] Decisions:
- Failure is an observation in the diagnostic plane, not an exception
  side-channel.
- v0 failure status is `failed`, `rejected`, `blocked`, or `degraded`.
- Reason codes use a small family taxonomy with package-specific refinements.
- Failure observations require explanatory links, especially `violates`,
  `caused_by`, and `observed_under`.
- Remediation hints are reviewable suggestions, not capability grants.

[R] Recommendations:
- Run `bridge-observation-envelope-v0` next to map current package packet shapes
  into the envelope without editing package code.
- Treat privacy/redaction and debug artifacts as core failure semantics.
- Keep blocked and degraded outcomes distinct from hard errors.

[S] Signals:
- Current runtime docs already store failures as node state and events.
- Current errors already carry graph/node/path/source/execution context.
- Durable Model health and materializer packets already model drift, blocked
  capability, review-only, and no-grant boundaries.
- Ledger diagnostics prefer compact serializable summaries over raw runtime
  objects.

[Q] Open Questions:
- Should reason families become a shared enum in a later bridge proposal?
- How should content hashes be computed for redacted failure payloads?
- Which debug artifact capability model is sufficient for stack traces and
  provider errors?

[X] Rejected:
- Raw exception as semantic failure.
- Prose-only failure reports.
- Automatic repair from remediation hints.
- Raw prompt/value capture as required audit.
- Treating every blocked state as an error.

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/bridge-observation-envelope-v0.md`
```
