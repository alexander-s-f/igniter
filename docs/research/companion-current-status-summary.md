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
- choose the next term only after the current glossary remains stable
- continue avoiding execution and capability grant controls

Acceptance:

- another agent can read manifest terms without reconstructing history
- glossary health remains stable
- materializer status descriptor health remains stable
- `/setup` surfaces glossary health without making readiness stricter
- no setup/read endpoint mutates durable state

Reference: [Companion Persistence Manifest Glossary](./companion-persistence-manifest-glossary.md).
