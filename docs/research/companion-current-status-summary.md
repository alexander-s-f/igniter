# Companion Current Status Summary

Status date: 2026-04-29.
Role: compact handoff for `[Architect Supervisor / Codex]`.
Scope: Companion app-local proof only; no public persistence API promise.

## Current Claim

Companion now proves a contract-declared persistence capability model where:

- durable shapes are contracts (`persist`, `history`, fields, metadata)
- behavior is graph-owned command/result/mutation intent
- side effects happen only at the app/store boundary
- setup/read endpoints remain inspectable and mostly side-effect-free
- materializer capability flow is modeled before any real capability is granted

## Proven Shape

Current manifest scale:

- records: 6
- histories: 6
- projections: 5
- command groups: 5
- relations: 2
- total capabilities: 17

Core validated path:

```text
persist -> Store[T]
history -> History[T]
storage.shape=:store/:history -> canonical manifest descriptor
relation -> typed manifest edge
relation_descriptor -> source/target storage shapes + report-only enforcement
command -> normalized operation intent
operation_descriptor -> explicit target shape + mutation boundary
materializer_status.descriptor -> review-only lifecycle + no capability grants
materializer_status_descriptor_health -> report-only no-grant/no-execution guard
setup_health.descriptor -> report-only summary over readiness + guardrails
setup_handoff.descriptor -> compact context rotation packet
setup_handoff_lifecycle -> read-only lifecycle map over handoff acceptance
setup_handoff_lifecycle_health -> drift check without setup_health cycle
setup_handoff_supervision -> single agent context packet over handoff lifecycle
setup_handoff_packet_registry -> read-only index of setup/handoff packet surface
setup_handoff_extraction_sketch -> landing-zone map without package promise
setup_handoff_promotion_readiness -> explicit blocked signal for package/API promotion
setup_handoff_digest -> compact text diagram and next-read summary (.json + .txt)
setup_handoff_next_scope -> supervised backlog packet, not execution
app boundary -> explicit mutation application
projection -> graph-owned read model
```

## Materializer Vertical

The latest work built a full review-only materializer lifecycle:

```text
WizardTypeSpec
-> materialization plan
-> parity
-> infrastructure loop health
-> gate
-> preflight
-> runbook
-> receipt
-> attempt command
-> explicit attempt POST
-> attempt history
-> audit trail
-> supervision
-> approval policy
-> approval receipt
-> approval history shape
-> approval command
-> explicit approval POST
-> approval audit trail
-> supervision with attempt + approval audit
-> materializer_status descriptor with review-only/no-grant boundary
-> materializer_status_descriptor_health report-only guard
```

Important boundary:

- approval/policy/receipt/history are data and audit shapes
- `applies_capabilities` remains false
- no write/git/test/restart capability is granted by setup reads
- explicit write paths exist only for recording blocked materializer attempts
  and approval receipts
- the compact materializer status packet now has its own descriptor, but that
  descriptor is only inspection metadata
- descriptor health now checks that the status packet still refuses capability
  grants and execution

## Most Important Insight

The system is becoming self-supporting:
contracts describe durable types, validate their own infrastructure, produce
review packets, define command intents, and expose audit trails for the process
that may later materialize contracts.

That fractal shape looks healthy, but it must stay app-local until the API
surface is smaller and the lowerings to `Store[T]` / `History[T]` are clearer.

## Landing Zone

Persistence has enough signal to reserve a future home, but not enough to split
now.

Recommended path:

- current: Companion app-local proof
- first extraction: contract vocabulary/descriptors toward `igniter-extensions`
- first runtime host extraction: registry, adapters, setup/readiness,
  app-boundary writes, and materializer review flows toward
  `igniter-application`
- later, if repeated evidence appears: create `igniter-persistence`

Avoid `igniter-data` for this capability. It is too broad; the sharper concept
is durable `Store[T]`, append-only `History[T]`, typed relations, command
intents, materialization, and audit.

## Current Boundary

Do not promote yet:

- `persist` / `history` / `field` / `index` / `scope` / `command` to core
- materializer execution
- migration generator
- DB planner
- relation enforcement
- approval capability grants
- dynamic runtime contract execution

Do preserve:

- `persist -> Store[T]`
- `history -> History[T]`
- `WizardTypeSpec ~= Store[ContractSpec]`
- `WizardTypeSpecChange ~= History[ContractSpecChange]`
- `MaterializerAttempt ~= History[MaterializerAttempt]`
- `MaterializerApproval ~= History[MaterializerApproval]`

## Next Reversible Slice

Best next move:

- use manifest glossary health as the guardrail for the next implementation
  slice
- use `/setup/health.json` as the compact current-state packet before deeper
  changes
- use `/setup/handoff.json` as the first read after context rotation
- use `/setup/handoff/digest.txt` as the compact human handoff, or
  `/setup/handoff/digest.json` as the structured agent map before
  following the deeper packet list
- use `/setup/handoff/next-scope.json` as the supervised backlog packet before
  treating any candidate as the current slice
- use `/setup/handoff/lifecycle.json` as the compact lifecycle map before
  reading individual acceptance packets
- use `/setup/handoff/lifecycle-health.json` as the lifecycle drift check; it
  intentionally stays outside `setup_health` to avoid a cyclic packet graph
- use `/setup/handoff/supervision.json` when an agent needs one compact packet
  with lifecycle stage, health signals, packet refs, and next action
- use `/setup/handoff/packet-registry.json` when an agent needs the indexed
  setup packet surface plus explicit receipt POST paths
- use `/setup/handoff/extraction-sketch.json` when an agent needs the
  app-local/extensions/application/future-persistence placement map
- use `/setup/handoff/promotion-readiness.json` when an agent needs the current
  blocker list for package/API promotion
- follow its `reading_order` through both handoff acceptance packets before
  deciding that the materializer lifecycle advanced
- follow its `document_rotation` block before reading long thread history
- keep its `architecture_constraints` intact before implementing a new slice
- use `next_scope` through `/setup/handoff/next-scope.json` as a supervised
  backlog, not an execution command
- use its embedded `acceptance_criteria` before calling a small slice complete
- use `/setup/handoff/acceptance.json` to observe acceptance before/after an
  explicit app-boundary action
- `POST /setup/handoff/acceptance/record` is only an explicit alias for the
  same materializer attempt receipt path
- use `/setup/handoff/approval-acceptance.json` to observe the follow-up
  approval receipt as audit data, not as a capability grant
- choose the next term only after the current glossary remains stable
- continue avoiding execution and capability grant controls

Acceptance:

- another agent can read manifest terms without reconstructing history
- glossary health remains stable
- materializer status descriptor health remains stable
- setup health remains stable or reports review items without blocking runtime
- setup health descriptor remains report-only and does not gate runtime
- setup handoff remains read-only and points to the current reading order
- setup handoff keeps public/private document rotation compact
- setup handoff preserves app-local/no-public-API/no-execution constraints
- setup handoff keeps next scope small, reversible, and app-local
- setup handoff defines acceptance without creating a runtime gate
- setup handoff acceptance remains report-only and pending until explicit POST
- setup handoff approval acceptance remains report-only, and satisfaction still
  requires `applied_count: 0`
- `/setup` surfaces glossary health without making readiness stricter
- no setup/read endpoint mutates durable state

Reference: [Companion Persistence Manifest Glossary](./companion-persistence-manifest-glossary.md).
