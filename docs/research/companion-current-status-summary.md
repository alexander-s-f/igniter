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
relation -> typed manifest edge
command -> normalized operation intent
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
```

Important boundary:

- approval/policy/receipt/history are data and audit shapes
- `applies_capabilities` remains false
- no write/git/test/restart capability is granted by setup reads
- explicit write paths exist only for recording blocked materializer attempts
  and approval receipts

## Most Important Insight

The system is becoming self-supporting:
contracts describe durable types, validate their own infrastructure, produce
review packets, define command intents, and expose audit trails for the process
that may later materialize contracts.

That fractal shape looks healthy, but it must stay app-local until the API
surface is smaller and the lowerings to `Store[T]` / `History[T]` are clearer.

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

- compact the materializer read surface around supervision
- keep lower-level setup endpoints as debug/proof surfaces while app-local

Acceptance:

- one supervision payload shows attempt and approval audit state
- next action advances without applying capabilities
- lower-level endpoints remain available for inspection
