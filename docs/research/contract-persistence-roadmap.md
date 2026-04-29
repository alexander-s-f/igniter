# Contract Persistence Roadmap

Status date: 2026-04-29.
Scope: Companion app-local proof, roadmap, and discussion summary. Not public
API, package API, DB planner, migration runner, or materializer execution.

## Claim

Persistence is proving the right architecture in Companion, but the next work
should clarify lowerings before adding execution:

```text
field metadata -> storage plan -> migration plan -> materialization plan
persist -> Store[T]
history -> History[T]
relation -> Relation[Store[A], History[B]]
command -> operation intent -> app boundary
```

The current system has enough evidence to reserve the future
`igniter-persistence` path. It does not yet have enough evidence to create a
package, infer SQL tables, run migrations, or let a materializer write files.

## Discussion Summary

### Do contract fields map to a table?

Current answer: no, not yet.

In Companion today, `field` declarations map to the contract persistence
manifest, generated app-local record/history APIs, payload normalization, and
read-model projections. SQLite currently stores the whole Companion state in one
`companion_state(key, payload)` JSON cell, so fields are not SQL columns and
contract capabilities are not separate SQL tables.

Target answer: yes, but only through an explicit storage plan.

For a relational adapter, `Store[T]` may later lower to a table-like storage
plan:

- `persist key: :id` -> primary identity candidate
- `field :name, type: :string` -> column candidate
- `field :spec, type: :json` -> JSON/document column candidate
- `index :status` -> index candidate
- `scope :open, where: ...` -> query/scope descriptor, not necessarily a DB
  view
- `history` -> append-only event/log table candidate, not CRUD

Rule: fields are portable storage descriptors first. Tables/columns are adapter
lowerings, not semantics baked into contracts.

### What is the migration status and model?

Current status: review-only planning exists; execution does not.

`WizardTypeSpecMigrationPlanContract` compares the latest spec snapshots in
`History[ContractSpecChange]`, classifies field changes, and emits review-only
candidate reports:

- `stable`: no field change
- `additive`: fields added
- `destructive`: fields removed
- `ambiguous`: existing field definitions changed

It does not create migration files, alter DB schema, backfill data, delete data,
or update static contracts.

Target model:

```text
ContractSpec vN
-> ContractSpecChange history
-> semantic diff
-> storage/table sketch diff
-> migration candidate plan
-> human/materializer review
-> explicit app-boundary execution later
-> receipt history
-> parity check
```

Split the migration concept:

- contract migration: static Ruby contract/app binding changes
- storage migration: adapter-specific table/column/index/backfill changes
- data migration: record/event transformation and repair

Only the first two should be planned soon. All execution stays blocked until
capabilities, approval, receipts, tests, and rollback/review surfaces are
modeled.

### What is the materialization status and process?

Current status: materialization is modeled, not executed.

Companion has:

- `WizardTypeSpec ~= Store[ContractSpec]`
- `WizardTypeSpecChange ~= History[ContractSpecChange]`
- `DurableTypeMaterializationContract` for static record/history/relation plan
- `StaticMaterializationParityContract` for plan-vs-static-manifest drift
- infrastructure loop health
- materializer gate, preflight, runbook, receipt, attempt history, approval
  receipt history, audit trails, supervision, descriptor health, and handoff
  packets

Current hard boundary:

- setup/read endpoints do not write files
- approval receipts do not grant capabilities
- `applies_capabilities` remains false
- `execution_allowed` remains false
- explicit POSTs only record audit receipts

Target process:

```text
draft spec
-> validate canonical shape
-> materialization plan
-> migration candidate plan
-> parity report
-> preflight/runbook
-> human approval
-> materializer writes static contracts and app bindings
-> tests
-> git/restart if approved
-> receipt history
-> parity recheck
```

The next materializer work should still be dry-run/report-only unless the slice
explicitly models capabilities, approvals, receipts, and rollback.

## Roadmap

### R0 Current Proof

Done app-locally:

- records, histories, projections, command groups, relations
- manifest `schema_version: 1`
- canonical `storage.shape`
- operation descriptors with app boundary
- relation descriptors with report-only enforcement
- materializer lifecycle and handoff packets
- promotion explicitly blocked

### R1 Storage Plan Sketch

Status: app-local proof added in Companion as `/setup/storage-plan(.json)`.

Add a report-only storage/table sketch contract.

Output:

- table/storage name candidates
- primary key candidate
- column candidates from fields
- adapter type mapping candidates
- index candidates
- scope/query descriptors
- history append-only table candidates

Non-goals:

- no DB schema changes
- no SQL generator
- no index creation
- no table-per-contract guarantee yet

Current proof keeps these non-goals explicit with `schema_changes_allowed: false`
and `sql_generation_allowed: false`.
`/setup/storage-plan-health.json` now verifies the non-executing shape as a
separate drift check.

### R2 Migration Plan V2

Status: app-local proof added in Companion as
`/setup/storage-migration-plan(.json)`.

Extend migration planning from field diff to storage-plan diff.

Classify:

- additive field/index/history/relation additions
- destructive removals
- ambiguous type/default/key/adapter/relation changes
- possible rename candidates, still review-only

Non-goals:

- no migration execution
- no backfills
- no destructive apply path

Current proof keeps R2 separate from `WizardTypeSpecMigrationPlanContract`: spec
diffs remain contract/spec migration planning, while storage-plan descriptor
diffs become review-only storage migration candidates.

### R3 Materializer Dry Run

Add a materializer dry-run packet that renders proposed file/binding changes as
review data.

Output:

- files that would change
- contracts that would be generated or updated
- app registry/binding changes
- migration candidates required
- tests that should run
- rollback notes

Non-goals:

- no filesystem writes
- no git
- no restart
- no capability grant from approval receipt alone

### R4 App-Local Executable Materializer

Only after R1-R3 stabilize, consider an explicitly approved app-local execution
slice.

Required gates:

- clean parity or accepted drift
- migration plan reviewed
- human approval grants exact capabilities
- write target restricted to app-local generated files
- tests named before execution
- receipts persisted after every step
- failure leaves a reviewable rollback packet

### R5 Extraction

After repeated app pressure:

- move descriptors/vocabulary to `igniter-extensions`
- move registry/adapters/setup/materializer host flows to
  `igniter-application`
- reserve `igniter-persistence` until adapter and migration semantics are
  stable

### R6 Lang Lowering

Only after the model is boring:

```text
persist -> Store[T]
history -> History[T]
relation -> Relation[Store[A], History[B]]
migration plan -> Plan[Store[T] vN -> vN+1]
materializer -> explicit capability-bearing agent/contract
```

## Handoff

```text
[Architect Supervisor / Codex]
Track: docs/research/contract-persistence-roadmap.md
Status: roadmap clarified for fields/table lowering, migrations, and
materialization.
[D] Current fields are manifest/API/payload descriptors, not SQL columns.
[D] Future table mapping must pass through explicit storage-plan descriptors.
[D] Migration status is review-only field/spec diff; no runner/generator.
[D] Materialization status is plan/parity/gate/runbook/audit only; no file
writes or capability grants.
[R] Do not infer tables, migrations, indexes, FKs, or dynamic execution from the
current Companion proof.
[S] Next best slice is R1: report-only storage/table sketch.
```
