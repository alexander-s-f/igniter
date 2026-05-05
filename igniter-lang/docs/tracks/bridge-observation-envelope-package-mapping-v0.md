# Track: Bridge Observation Envelope Package Mapping v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

This slice maps current package evidence into the bridge observation envelope
without package edits.

It is a metadata-only preflight:

- no package API changes
- no runtime code changes
- no migration
- no new wire format
- no package-level promise that these mappings already emit

The goal is to decide which current package fields can lower into
`ObsPacket[kind, T]` profiles and which fields are missing before implementation.

## Source Horizon

- `igniter-lang/docs/proposals/PROP-005-bridge-observation-envelope-v0.md`
- `igniter-lang/docs/proposals/PROP-004b-axiom-layer-type-signatures-v0.md`
- `igniter-lang/docs/proposals/PROP-006-runtime-contract-specification-v0.md`
- `igniter-lang/docs/proposals/PROP-007-conformance-verification-v0.md`
- `igniter-lang/docs/tracks/bridge-observation-envelope-runtime-evidence-v0.md`
- `packages/igniter-ledger/lib/igniter/store/fact.rb` (read-only)
- `packages/igniter-ledger/lib/igniter/store/igniter_store.rb` (read-only)
- `packages/igniter-durable-model/lib/igniter/durable_model/receipts.rb` (read-only)
- `packages/igniter-durable-model/lib/igniter/durable_model/command_flow_view*.rb` (read-only)
- `packages/igniter-durable-model/lib/igniter/durable_model/command_flow_decision.rb` (read-only)
- `packages/igniter-durable-model/lib/igniter/durable_model/store.rb` (read-only)

## Compact Claim

[D] The current packages already expose enough metadata to define a
metadata-only bridge profile:

```text
Ledger Fact
  -> fact_observation

DurableModel CommandFlowView
  -> projection observation profile

DurableModel CommandFlowViewPin / CommandFlowDecisionReceipt
  -> receipt_observation profile

RuntimeContract / AxiomDescriptor
  -> session-start platform observations
```

[D] The largest gap is not facts or receipts. The largest gap is explicit
runtime/session evidence:

```text
AxiomDescriptor packet
RuntimeContract packet
execution_environment packet
verification_observation packet
:executed_by / :produced_in / :observed_under links
```

Until those exist, many package observations can be inspectable but not fully
reproducible under Igniter-Lang semantics.

## Mapping Scope

This track only maps package data shapes to bridge profiles.

| Package surface | Bridge target | Status |
|-----------------|---------------|--------|
| `Igniter::Store::Fact` | `fact_observation` | ready metadata |
| `Igniter::Store::IgniterStore#write/#append` | fact emission source | ready metadata |
| `CommandFlowViewDescriptor` | projection descriptor profile | ready metadata |
| `CommandFlowView` | projection value profile | ready metadata |
| `CommandFlowViewPin` | pinned decision receipt profile | strong metadata |
| `CommandFlowDecision` | decision history fact + receipt profile | strong metadata |
| `CommandFlowDecisionReceipt` | receipt_observation profile | strong metadata |
| `CommandPolicyDecision` | intent/policy decision profile | ready metadata |
| `CommandApplyReceipt` | receipt_observation profile | partial metadata |
| `RuntimeContract` / `AxiomDescriptor` | session packets | spec-only, missing package emission |
| `VerificationPayload` | verification_observation | spec-only, missing package emission |

## Ledger Facts To fact_observation

Current package field source:

```text
Igniter::Store::Fact = {
  id
  store
  key
  value
  value_hash
  causation
  transaction_time
  valid_time
  schema_version
  producer
  derivation
}
```

Bridge lowering:

```text
Obs[:fact_observation, LedgerFactPayload]

identity:
  id: fact.id
  space: "ledger://<store>"
  kind: :fact_observation
  subject: "fact://<store>/<key>/<id>"

provenance:
  producer:
    kind: :runtime | :platform
    id: fact.producer || "igniter-ledger"
  emitted_at: fact.transaction_time
  content_hash: fact.value_hash

temporal:
  transaction_time: fact.transaction_time
  valid_time: fact.valid_time

payload:
  fact_id: fact.id
  store: fact.store
  key: fact.key
  value: fact.value
  value_hash: fact.value_hash
  schema_version: fact.schema_version
  producer: fact.producer
  derivation: fact.derivation

links:
  - rel: :caused_by
    ref: fact.causation
    required: false
```

### Already Present

| Needed field | Current source |
|--------------|----------------|
| stable fact id | `Fact#id` |
| store identity | `Fact#store` |
| subject key | `Fact#key` |
| payload | `Fact#value` |
| content hash | `Fact#value_hash` |
| causation | `Fact#causation` |
| transaction time | `Fact#transaction_time` |
| valid/domain time | `Fact#valid_time` |
| schema version | `Fact#schema_version` |
| producer hint | `Fact#producer` |
| derivation hint | `Fact#derivation` |

### Missing / Bridge-Supplied

| Missing field | Bridge handling |
|---------------|-----------------|
| canonical `ObsSpace` | derive from store name |
| typed `SubjectRef` URI | derive from store/key/id |
| `ProducerRef` shape | normalize `producer` or default to package/runtime |
| `PrivacyPolicy` | default package profile; no raw redaction signal on Fact |
| `TypedLink` values | lower `causation`/`derivation` into links |
| `executed_by` / `produced_in` | unavailable until runtime session packets exist |

[D] Ledger facts are the easiest bridge target. They already carry the exact
identity/provenance/time/hash shape needed for `fact_observation`.

## Durable CommandFlowView To Projection Observation

Current package fields:

```text
CommandFlowView = {
  schema_version
  kind
  name
  owner
  status
  mode
  horizon
  filters
  action_policy
  slice
  monitor
  summary
  generated_at
  execution_boundary
  store_fact_exposed
  value_hash_exposed
}
```

Bridge profile:

```text
Obs[:value_observation, CommandFlowProjectionPayload]

identity:
  space: "durable-model://command-flow-view"
  kind: :value_observation
  subject: "projection://command-flow/<owner>/<name>"

payload:
  profile: :projection_observation
  name: view.name
  owner: view.owner
  status: view.status
  mode: view.mode
  horizon: view.horizon
  filters: view.filters
  action_policy: view.action_policy
  summary: view.summary
  execution_boundary: view.execution_boundary
  meaning_status: inferred from view.mode/horizon
```

Conservative bridge rule:

```text
view.mode == :live
  -> meaning_status = :live

view.mode == :reproducible + stable_horizon + runtime/session links
  -> meaning_status = :reproducible

view.mode == :reproducible + stable_horizon + missing runtime/session links
  -> meaning_status = :provisional

missing horizon fields
  -> meaning_status = :unknown
```

### Already Present

| Needed field | Current source |
|--------------|----------------|
| projection name | `CommandFlowView#name` |
| owner / subject boundary | `CommandFlowView#owner` |
| status | `CommandFlowView#status` |
| live/reproducible mode | `CommandFlowView#mode` |
| horizon | `CommandFlowView#horizon` |
| action policy | `CommandFlowView#action_policy` |
| summary | `CommandFlowView#summary` |
| produced time | `CommandFlowView#generated_at` |
| app boundary | `CommandFlowView#execution_boundary` |
| non-exposure flags | `store_fact_exposed`, `value_hash_exposed` |

### Missing / Bridge-Supplied

| Missing field | Bridge handling |
|---------------|-----------------|
| stable observation id | hash canonical view payload |
| content hash | hash canonical payload |
| `executed_by` | missing until runtime packet |
| `produced_in` | missing until execution environment packet |
| explicit `observed_under` link | derive from horizon or session RuntimeContract |
| payload redaction policy | derive from exposure flags |

[D] `CommandFlowView` is already a named slice in package form. It should be
lowered as a projection profile, not as an arbitrary dashboard payload.

## Durable Descriptor To Projection Descriptor

Current package fields:

```text
CommandFlowViewDescriptor = {
  schema_version
  kind
  name
  owner
  filters
  horizon
  mode
  action_policy
  rules
  metadata
  execution_boundary
}
```

Bridge profile:

```text
Obs[:descriptor_observation, CommandFlowProjectionDescriptorPayload]

subject: "projection-descriptor://command-flow/<owner>/<name>"
payload:
  profile: :projection_descriptor
  name
  owner
  filters
  horizon
  mode
  action_policy
  rules
  metadata
  execution_boundary
```

[D] The descriptor maps to `descriptor_observation`; evaluated views map to
`value_observation` with `profile: :projection_observation`.

## Durable Pin To Receipt Observation

Current package fields:

```text
CommandFlowViewPin = {
  schema_version
  kind
  status
  meaning_status
  name
  owner
  action
  actor
  capabilities
  missing_capabilities
  horizon
  view
  receipt
  errors
  warnings
  metadata
  generated_at
  execution_boundary
}
```

Bridge profile:

```text
Obs[:receipt_observation, CommandFlowPinReceiptPayload]

identity:
  id: pin.receipt[:receipt_id]
  space: "durable-model://command-flow-pin"
  subject: "receipt://command-flow-pin/<receipt_id>"

payload:
  profile: :decision_receipt
  receipt_id: pin.receipt[:receipt_id]
  status: pin.status
  meaning_status: pin.meaning_status
  view_name: pin.name
  owner: pin.owner
  action: pin.action
  actor: pin.actor
  capabilities: pin.capabilities
  missing_capabilities: pin.missing_capabilities
  decision_horizon: pin.horizon
  errors: pin.errors
  warnings: pin.warnings
  metadata: pin.metadata
  generated_at: pin.generated_at

links:
  - rel: :derived_from
    ref: projection_observation_id_for(pin.view)
    required: true
  - rel: :executed_by
    ref: runtime_observation_id
    required: true for reproducible claims
  - rel: :produced_in
    ref: execution_environment_observation_id
    required: true for reproducible claims
```

### Already Present

| Needed field | Current source |
|--------------|----------------|
| receipt id | `pin.receipt[:receipt_id]` |
| pin status | `CommandFlowViewPin#status` |
| meaning status | `CommandFlowViewPin#meaning_status` |
| action | `CommandFlowViewPin#action` |
| actor | `CommandFlowViewPin#actor` |
| capabilities | `#capabilities`, `#missing_capabilities` |
| decision horizon | `#horizon` |
| source view | `#view` |
| generated time | `#generated_at` |
| errors/warnings | `#errors`, `#warnings` |

### Missing / Bridge-Supplied

| Missing field | Bridge handling |
|---------------|-----------------|
| projection observation id | bridge hashes/captures source view |
| runtime links | require session packets |
| capability policy observation id | derive later from policy descriptor |
| content hash | hash canonical receipt payload |

[D] `CommandFlowViewPin` is already the package shape closest to an
Igniter-Lang action-safe receipt.

## Durable Decision History To fact_observation + receipt_observation

`CommandFlowDecision` is a DurableModel History that stores app-owned decision
events:

```text
CommandFlowDecision = {
  owner
  view_name
  action
  actor
  status
  meaning_status
  receipt_id
  horizon
  capabilities
  missing_capabilities
  view_status
  monitor_status
  summary
  errors
  warnings
  metadata
  store_fact_exposed
  value_hash_exposed
}
```

`Store#append_command_flow_decision` also returns:

```text
CommandFlowDecisionReceipt = {
  schema_version
  kind
  status
  receipt_id
  decision_receipt_id
  owner
  view_name
  action
  actor
  meaning_status
  errors
  warnings
  metadata
  generated_at
  store_fact_exposed
  value_hash_exposed
}
```

Bridge lowering:

```text
CommandFlowDecision history append
  -> fact_observation

CommandFlowDecisionReceipt
  -> receipt_observation
```

The history fact proves that the app persisted the decision. The receipt
proves the append boundary and carries app-safe outcome metadata.

### Already Present

| Needed field | Current source |
|--------------|----------------|
| persisted decision payload | `CommandFlowDecision` fields |
| receipt id | `CommandFlowDecisionReceipt#receipt_id` |
| decision receipt id | `#decision_receipt_id` |
| meaning status | decision + receipt |
| horizon | decision payload |
| capability summary | decision payload |
| exposure policy hints | `store_fact_exposed`, `value_hash_exposed` |

### Missing / Bridge-Supplied

| Missing field | Bridge handling |
|---------------|-----------------|
| link from receipt to fact id | not returned directly; bridge must capture append fact if available |
| runtime/session links | require session packets |
| stable typed subject refs | derive from owner/view/action/receipt id |

## CommandPolicyDecision To Intent/Policy Observation

Current package fields:

```text
CommandPolicyDecision = {
  status
  owner
  command
  subject_key
  operation
  actor
  required_capabilities
  granted_capabilities
  missing_capabilities
  review_required
  errors
  warnings
  metadata
  execution_boundary
}
```

Bridge profile:

```text
Obs[:intent_observation, CommandPolicyDecisionPayload]
```

or:

```text
Obs[:constraint_observation, CommandPolicyDecisionPayload]
```

Recommendation: use `intent_observation` when the decision is attached to a
command flow, and `constraint_observation` when it is emitted as a reusable
policy/capability check.

Meaning status:

| Package status | Bridge computation_status | meaning_status |
|----------------|---------------------------|----------------|
| `:allowed` | `:ok` | `:provisional` until runtime/capability receipt is linked |
| `:denied` | `:blocked` | `:reproducible` if deterministic policy inputs are fixed and session links exist |
| `:review_required` | `:blocked` | `:live` or `:provisional` depending on approval horizon |

[D] A denied or review-required decision is not a runtime error. It is
capability/policy evidence.

## CommandApplyReceipt To receipt_observation

Current package fields:

```text
CommandApplyReceipt = {
  status
  owner
  command
  subject_key
  operation
  target
  mutation_intent
  activity_recorded
  execution_boundary
  errors
  warnings
}
```

Bridge profile:

```text
Obs[:receipt_observation, CommandApplyReceiptPayload]
```

Mapping:

| Package status | computation_status | meaning_status |
|----------------|--------------------|----------------|
| `:applied` | `:ok` | `:provisional` until runtime + fact receipt links are present |
| `:rejected` | `:rejected` | `:reproducible` if rejection inputs/policy are fixed and session links exist |

Missing:

- no `meaning_status` field yet
- no direct runtime links
- no direct `fact_id` / `value_hash` by design
- no explicit projection source link

[R] Keep `CommandApplyReceipt` app-safe. Do not expose Ledger internals just to
satisfy the bridge; use links to fact/receipt observations when available.

## RuntimeContract And AxiomDescriptor Session Packets

`PROP-004b` requires `AxiomDescriptor` platform observations at session start.
`PROP-006` requires `RuntimeContract` platform observations at session start.
`PROP-007` adds `verification_observation` as conformance evidence.

Bridge session prelude:

```text
session_start:
  emit Obs[:platform_observation, AxiomDescriptor]
  emit Obs[:platform_observation, RuntimeDescriptor]
  emit execution_environment_observation
  optionally emit Obs[:verification_observation, VerificationPayload]
```

Required links:

```text
RuntimeDescriptor:
  links:
    - rel: :observed_under
      ref: axiom_descriptor_obs_id
      required: true

value/projection/fact/receipt observations:
  links:
    - rel: :observed_under
      ref: runtime_descriptor_obs_id
      required: true
    - rel: :executed_by
      ref: runtime_descriptor_obs_id
      required: true when runtime-produced
    - rel: :produced_in
      ref: execution_environment_obs_id
      required: true for reproducible claims
```

### Current Package Reality

| Packet | Package support today | Gap |
|--------|-----------------------|-----|
| `AxiomDescriptor` | spec-only in `PROP-004b` | no package emission |
| `RuntimeDescriptor` | spec-only in `PROP-006` | no package emission |
| `execution_environment_observation` | package has hints (`execution_boundary`, stores, generated time) | no standard packet |
| `verification_observation` | spec-only in `PROP-007` | no package emission |
| `observed_under` links | partial temporal fields exist | no standard links |
| `executed_by` / `produced_in` | not present | bridge must add |

[D] Session packets are the first implementation seam. Without them, package
facts and receipts are inspectable but not fully runtime-reproducible.

## meaning_status Mapping

Bridge should compute `meaning_status` conservatively.

### Facts

| Source | Rule |
|--------|------|
| Ledger fact with transaction_time/value_hash/id | `:reproducible` if linked to RuntimeDescriptor + AxiomDescriptor |
| Ledger fact without runtime session links | `:provisional` |
| Fact from live query result without pinned as_of | `:live` |
| Fact after invalidation/compaction without replay proof | `:stale` or `:unknown` |

### CommandFlowView

| Source | Rule |
|--------|------|
| `mode: :live` | `:live` |
| `mode: :reproducible` + stable horizon + runtime/session links | `:reproducible` |
| `mode: :reproducible` + stable horizon but missing runtime links | `:provisional` |
| missing horizon fields | `:unknown` |

### Pin / Decision / Receipt

| Source | Rule |
|--------|------|
| `CommandFlowViewPin#meaning_status` | preserve, then validate links |
| `CommandFlowDecision#meaning_status` | preserve as persisted app decision evidence |
| `CommandFlowDecisionReceipt#meaning_status` | preserve, then link to decision fact |
| `CommandApplyReceipt` applied without runtime/fact links | `:provisional` |
| rejected/blocked with deterministic policy inputs | `:reproducible` if session links exist |

[D] Existing package `meaning_status` is authoritative as package-local
evidence, but bridge-level reproducibility still requires runtime/session
links.

## Already Gives / Missing Summary

### Package Already Gives

- stable Ledger fact id
- store/key identity
- content hash (`value_hash`)
- transaction time and valid time
- causation
- producer / derivation hints
- command flow view name/owner/mode/horizon/action policy
- app-safe pin receipt id
- command-flow pin `meaning_status`
- decision history payloads
- command-flow decision receipts
- capability summary fields (`capabilities`, `missing_capabilities`)
- exposure flags (`store_fact_exposed`, `value_hash_exposed`)

### Missing For Full Bridge

- emitted `AxiomDescriptor` platform observation
- emitted `RuntimeDescriptor` platform observation
- emitted `execution_environment_observation`
- emitted `verification_observation`
- canonical `ObsId` strategy for projection/receipt profiles
- canonical payload hash serialization
- `:executed_by` / `:produced_in` links
- `:observed_under` links to runtime/session packets
- standard privacy policy mapping from exposure flags
- app-safe link from decision receipt to underlying appended fact id
- conformance evidence that runtime behavior matches declared `RuntimeContract`

## Metadata-Only Implementation Preflight

[R] A first bridge adapter can be read-only/metadata-only:

1. Observe package objects after they are produced.
2. Build `ObsPacket` profiles in memory or sidecar output.
3. Derive ids and hashes using a canonical bridge serializer.
4. Attach synthetic runtime/session links only when session packets exist.
5. Downgrade `meaning_status` when required evidence is missing.
6. Emit diagnostics for gaps instead of modifying package behavior.

```text
package object -> bridge adapter -> ObsPacket profile
```

Not:

```text
package object -> package rewrite -> new runtime semantics
```

## Rejected Paths

[X] Editing packages before the bridge profile is approved.

[X] Treating app-safe Durable receipts as insufficient because they hide Ledger
internals. They are correct app-boundary evidence; bridge should link to lower
level facts when available.

[X] Claiming `:reproducible` from stable horizon alone. Runtime and axiom
session packets are also required.

[X] Mapping `CommandFlowView` as a dashboard-only artifact. It is already a
named projection shape.

[X] Exposing raw store facts through app-safe receipts. Use observation links.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/bridge-observation-envelope-package-mapping-v0.md
Status: done

[D] Decisions:
- Ledger facts lower cleanly into fact_observation.
- CommandFlowView lowers into projection observation profile.
- CommandFlowViewPin and CommandFlowDecisionReceipt lower into
  receipt_observation profiles.
- CommandFlowDecision history append is both a fact_observation and the source
  evidence for decision receipts.
- RuntimeContract and AxiomDescriptor must be emitted as session-start
  platform observations before bridge-level reproducibility can be claimed.
- Existing package meaning_status should be preserved but downgraded when
  runtime/session links are missing.

[R] Recommendations:
- Keep first package bridge metadata-only.
- Implement bridge adapter as sidecar/projection over existing package objects.
- Add session packet emission before touching package execution semantics.
- Use diagnostics for missing links instead of inventing false evidence.

[S] Signals:
- The platform is closer than expected: facts, hashes, horizons, pins, and
  app-safe receipts already exist.
- The core missing piece is not more package mutation, but canonical bridge
  evidence and runtime/session prelude packets.
- DurableModel's app-safe boundary aligns with the envelope privacy model.

[Q] Open Questions:
- Which canonical serializer should bridge use before RFC 8785 is formally
  adopted?
- Should decision receipts expose appended fact id, or should bridge capture
  it sidecar-only?
- Should `CommandApplyReceipt` grow meaning_status later, or should bridge
  compute it entirely outside the package?

[X] Rejected:
- Package edits in this slice.
- Runtime-reproducibility claims without RuntimeDescriptor/AxiomDescriptor.
- Leaking Ledger internals through app-safe receipts.

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/bridge-observation-envelope-implementation-plan-v0.md`
  as an Architect-reviewed sidecar plan before package edits.
```
