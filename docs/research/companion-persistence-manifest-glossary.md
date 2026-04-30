# Companion Persistence Manifest Glossary

Status date: 2026-04-30.
Scope: app-local Companion manifest vocabulary. Not public API.

## Claim

The Companion persistence manifest is now readable as a compact capability map.
Agents should use this glossary before changing persistence, relations,
materializer review flows, or future extraction boundaries.

## Reading Order

Read `/setup/manifest` top down:

1. `schema_version`
2. `records`
3. `histories`
4. `projections`
5. `commands`
6. `relations`
7. `summary`

Then read `/setup/materializer.json` for the compact review lifecycle status.
Read `/setup/materializer/descriptor-health.json` when changing the
materializer status descriptor.
Read `/setup/storage-plan.json` when discussing field/table lowerings. It is a
review-only sketch, not a DB schema or migration plan.
Read `/setup/storage-plan-health.json` when changing storage-plan vocabulary or
checking that it remains non-executing.
Read `/setup/storage-migration-plan.json` when discussing R2 storage-plan diffs.
It is a review-only migration candidate report, not a runner.
Read `/setup/storage-migration-plan-health.json` when changing R2 migration
candidate vocabulary or checking no-execution/no-SQL boundaries.
Read `/setup/field-type-plan.json` before changing field vocabulary, defaults,
enum domains, JSON fields, required keys, relation type checks, access paths,
or materializer dry-run output.
Read `/setup/field-type-health.json` when checking that R2a type validation
remains report-only and non-executing.
Read `/setup/relation-type-plan.json` before changing relation joins,
projection inputs, access-path sketches, FK discussions, or migration planning.
Read `/setup/relation-type-health.json` when checking that R2b relation type
compatibility remains report-only and non-enforcing.
Read `/setup/health.json` for the compact report-only current-state packet.
Read `/setup/handoff.json` first when rotating context between agents.

Use `/setup/manifest/glossary-health.json` to check whether the manifest still
contains the required glossary terms.
The same report is also summarized in `/setup` as `manifest_glossary`.

## Terms

`schema_version`

- Current value: `1`.
- Means the manifest shape is intentionally versioned.
- Does not imply a public API guarantee.

`storage`

- Canonical durable descriptor.
- `storage.shape: :store` means future `Store[T]`.
- `storage.shape: :history` means future `History[T]`.
- `persist` and `history` remain compatibility aliases beside `storage`.

`storage_plan_sketch`

- Review-only R1 lowerings exposed at `/setup/storage-plan.json`.
- Maps records to storage/table name candidates, primary key candidates,
  columns from field descriptors, index candidates, and scope/query
  descriptors.
- Maps histories to append-only table candidates with partition key candidates.
- Includes adapter type mapping candidates such as JSON fields to
  `:json_document`.
- Keeps `schema_changes_allowed: false` and `sql_generation_allowed: false`.
- Does not imply a table-per-contract guarantee, migration runner, DB planner,
  index creation, or backfill.

`storage_plan_health`

- Report-only drift check exposed at `/setup/storage-plan-health.json`.
- Validates no-gate/no-grant descriptor policy, disabled schema changes,
  disabled SQL generation, Store/History lowerings, key candidates,
  field-derived columns, adapter type candidates, index/scope sources, and
  summary counts.
- Does not feed into runtime execution or authorize migrations.

`storage_migration_plan`

- Review-only R2 storage-plan diff exposed at
  `/setup/storage-migration-plan.json`.
- Compares current and previous storage-plan descriptors when a previous plan is
  supplied; current app state passes `nil` previous plan and reports stable.
- Classifies storage candidates as stable, additive, destructive, or ambiguous
  based on columns, indexes, scopes, keys, adapter, and append-only changes.
- Emits candidates with `review_only: true`,
  `migration_execution_allowed: false`, and `sql_generation_allowed: false`.
- Does not create migrations, generate SQL, alter DB schema, backfill data, or
  request capabilities.

`storage_migration_plan_health`

- Report-only R2 drift check exposed at
  `/setup/storage-migration-plan-health.json`.
- Validates descriptor policy, status vocabulary, record/history report shapes,
  report and candidate counts, and candidate review-only/no-execution/no-SQL
  flags.
- Does not authorize migration execution or SQL generation.

`field_type_plan`

- Report-only R2a validation exposed at `/setup/field-type-plan.json`.
- Validates field descriptor vocabulary, defaults, enum domains, JSON fields,
  datetime values, required key presence, and current seeded payload shape.
- Preserves `persist -> Store[T]` and `history -> History[T]` explicitly in the
  descriptor.
- Does not gate runtime, change schema, generate SQL, execute materializer
  steps, or grant capabilities.

`field_type_health`

- Report-only drift check exposed at `/setup/field-type-health.json`.
- Validates descriptor policy, Store/History lowerings, supported field types,
  required-key coverage, enum/json checks, no type issues, summary counts, and
  no schema/SQL/materializer execution.
- Does not authorize relation enforcement, DB migrations, access-path nodes, or
  typed write execution.

`relation_type_plan`

- Report-only R2b relation compatibility plan exposed at
  `/setup/relation-type-plan.json`.
- Checks join field descriptors for `Relation[Store[A], History[B]]` edges.
- Treats `:unspecified` fields as inferred compatibility so legacy/simple
  fields do not become premature public type commitments.
- Keeps `relation_enforcement_allowed: false` and
  `foreign_key_generation_allowed: false`.

`relation_type_health`

- Report-only drift check exposed at `/setup/relation-type-health.json`.
- Validates descriptor policy, Relation/Store/History lowerings, report-only
  enforcement, join reports, missing-field checks, mismatch checks, summary
  counts, and no FK/enforcement capability.
- Does not authorize FK generation, relation enforcement, DB migrations, or
  runtime graph-node changes.

`records`

- Durable record capabilities.
- Record APIs expose `all`, `find`, `save`, `update`, `delete`, `clear`,
  `scope`, and `command`.
- Writes still apply only through the app boundary.

`histories`

- Append-only capabilities.
- History APIs expose `append`, `all`, `where`, and `count`.
- Do not treat histories as CRUD records.

`operation_descriptors`

- Canonical operation vocabulary beside compatibility `operations` lists.
- Fields: `name`, `kind`, `target_shape`, `mutates`, `boundary`.
- `target_shape` is `:store`, `:history`, or `:none`.
- `boundary: :app` means graph contracts compute intent; app/store applies it.

`commands`

- Graph-owned behavior contracts.
- Commands return result plus normalized mutation intent.
- Current mutation operations: `record_append`, `record_update`,
  `history_append`, and `none`.

`projections`

- Graph-owned read models.
- `reads` lists capability inputs.
- `relations` lists typed relation inputs.
- Projections do not own writes.

`relations`

- Typed manifest edges, not ORM associations.
- Compatibility fields include `kind`, `from`, `to`, `join`, `cardinality`,
  `integrity`, `consistency`, `projection`, and `enforced`.
- Canonical `descriptor` includes source/target storage shapes, lowering
  metadata, and enforcement policy.

`relation.descriptor.enforcement`

- Current mode: `:report_only`.
- `enforced: false` must remain true for this app-local proof.
- Relation health may warn, but it does not reject writes or repair data.

`materializer_status`

- Compact status packet exposed at `/setup/materializer.json`.
- Alias over materializer supervision, not a new capability.
- Shows phase, next action, attempt audit, approval audit, and command intents.
- Includes canonical `descriptor` with `schema_version: 1`,
  `kind: :materializer_status`, review-only state, history targets, command
  intents, and audit counts.
- Must not grant write/git/test/restart capabilities.
- `grants_capabilities: false` and `execution_allowed: false` are part of the
  descriptor contract.

`materializer_status_descriptor_health`

- Report-only drift check exposed at
  `/setup/materializer/descriptor-health.json`.
- Verifies schema version, descriptor kind, review-only state, no capability
  grants, no execution, app-boundary requirement, history targets, command
  intents, audit counts, and status/phase alignment.
- `status: :stable` means the compact status descriptor still preserves the
  materializer safety boundary.
- Does not make persistence readiness stricter.

`manifest_glossary_health`

- Report-only drift check exposed at `/setup/manifest/glossary-health.json`.
- Also surfaced in `/setup` as a summary signal.
- Current stable state checks nine terms: schema version, record storage,
  record aliases, history storage, history aliases, operation descriptors,
  relation descriptors, projection reads, and command app boundaries.
- `status: :stable` means the current manifest matches this glossary.
- `status: :drift` means a term disappeared or stopped matching the glossary.

`setup_health`

- Report-only summary exposed at `/setup/health.json`.
- Includes `descriptor` with `schema_version: 1`, `kind: :setup_health`,
  `report_only: true`, `gates_runtime: false`, and
  `grants_capabilities: false`.
- Folds persistence readiness, relation health, manifest glossary health,
  materializer status descriptor health, and infrastructure loop health.
- Relation warnings become `review_items`, not runtime blockers.
- Does not grant capabilities and does not make readiness stricter.

`setup_handoff`

- Compact context-rotation packet exposed at `/setup/handoff.json`.
- Includes `descriptor` with `schema_version: 1`, `kind: :setup_handoff`,
  `report_only: true`, `gates_runtime: false`, and
  `grants_capabilities: false`.
- Carries reading order, manifest scale, current materializer phase, and next
  action.
- Reading order includes both handoff acceptance packets, so lifecycle progress
  can be checked without mutating setup state.
- Reading order also includes `/setup/handoff/lifecycle.json` as the compact
  stage map.
- Reading order includes `/setup/handoff/lifecycle-health.json` as the drift
  check for that stage map.
- Reading order includes `/setup/handoff/supervision.json` as the compact agent
  context packet.
- Reading order includes `/setup/handoff/packet-registry.json` as the indexed
  setup packet surface.
- Reading order includes `/setup/handoff/extraction-sketch.json` as the
  package-placement sketch without public API promise.
- Reading order includes `/setup/handoff/promotion-readiness.json` as the
  explicit package/API promotion blocker report.
- Reading order includes `/setup/handoff/digest.json` and
  `/setup/handoff/digest.txt` as the structured and plain-text compact diagram
  plus next-read summary.
- Reading order includes `/setup/handoff/next-scope.json` as the supervised
  backlog packet for the current reversible slice.
- Reading order includes `/setup/handoff/next-scope-health.json` as the drift
  check for supervised backlog shape.
- Carries `document_rotation` with the compact public docs and private track to
  read before older thread history.
- Carries `architecture_constraints` for app-local scope, no public API promise,
  no materializer execution, report-only relations, no approval grants, and
  `persist` / `history` lowerings.
- Carries `next_scope` with small reversible app-local candidates and forbidden
  moves.
- Carries `acceptance_criteria` for the recommended next scope, including proof
  markers and non-goals.
- It is a handoff/read model, not an execution or approval surface.

`setup_handoff_lifecycle`

- Read-only stage map exposed at `/setup/handoff/lifecycle.json`.
- Composes `setup_handoff`, `setup_handoff_acceptance`,
  `setup_handoff_approval_acceptance`, and `materializer_status`.
- Starts as `status: :pending`, `current_stage: :attempt_receipt`.
- Moves to `current_stage: :approval_receipt` after explicit attempt receipt.
- Becomes `status: :complete` only after explicit approval receipt while still
  keeping `gates_runtime: false` and `grants_capabilities: false`.

`setup_handoff_lifecycle_health`

- Report-only drift check exposed at `/setup/handoff/lifecycle-health.json`.
- Validates lifecycle descriptor shape, source packets, stage order, read views,
  explicit POST mutations, current stage, and next action.
- Stays outside `setup_health` because it depends on `setup_handoff`, which
  already depends on `setup_health`.

`setup_handoff_supervision`

- Single agent context packet exposed at `/setup/handoff/supervision.json`.
- Composes setup health, setup handoff, lifecycle, lifecycle health, and
  materializer status.
- Reports lifecycle status/stage, materializer phase, no-grant/no-execution
  signals, packet refs, and next action.
- It is not a runtime gate, approval, or execution surface.

`setup_handoff_packet_registry`

- Read-only packet index exposed at `/setup/handoff/packet-registry.json`.
- Lists setup/handoff packet endpoints, packet roles, descriptor boundaries,
  reading order, and explicit receipt POST paths.
- All indexed packets must remain report-only, `gates_runtime: false`, and
  `grants_capabilities: false`.

`setup_handoff_extraction_sketch`

- Read-only landing-zone packet exposed at
  `/setup/handoff/extraction-sketch.json`.
- Keeps current scope `companion_app_local`.
- Names extraction candidates for `igniter-extensions` and
  `igniter-application`, while reserving future `igniter-persistence`.
- Must keep `package_promise: false` and `package_split_now: false`.

`setup_handoff_promotion_readiness`

- Report-only blocker packet exposed at
  `/setup/handoff/promotion-readiness.json`.
- Current expected status is `:blocked`.
- Names why package/API promotion is not ready yet.
- Allowed next steps must keep Companion app-local and gather repeated pressure.

`setup_handoff_digest`

- Compact human/agent packet exposed at `/setup/handoff/digest.json` and as
  plain text at `/setup/handoff/digest.txt`.
- Includes a short ASCII text diagram, highlights, and recommended next reads.
- Composes supervision, extraction sketch, and promotion readiness.
- Remains report-only with no runtime gate and no capability grants.

`setup_handoff_next_scope`

- Supervised backlog packet exposed at `/setup/handoff/next-scope.json`.
- Pulls `next_scope` and `acceptance_criteria` out of the large handoff packet.
- Names the recommended app-local slice, candidate list, forbidden moves,
  explicit receipt POST paths, and current lifecycle next action.
- Remains report-only and does not grant execution, approval, or package/API
  promotion capability.

`setup_handoff_next_scope_health`

- Drift-check packet exposed at `/setup/handoff/next-scope-health.json`.
- Validates descriptor no-gate/no-grant policy, recommended candidate presence,
  scoped candidate endpoints, explicit setup POST mutation paths, forbidden
  moves, acceptance alignment, and lifecycle next action vocabulary.
- Remains outside `/setup/health` so the next-scope backlog can be supervised
  without becoming a global runtime readiness gate.

`setup_handoff_acceptance`

- Report-only acceptance status exposed at `/setup/handoff/acceptance.json`.
- Evaluates the recommended handoff scope without executing it.
- Starts as `status: :pending` on clean setup state.
- Becomes `status: :satisfied` only after explicit
  `POST /setup/materializer-attempts/record`.
- Also has an explicit convenience alias:
  `POST /setup/handoff/acceptance/record`.
- Must keep `gates_runtime: false` and `grants_capabilities: false`.

## `setup_handoff_approval_acceptance`

Report-only follow-up acceptance packet for the approval receipt step.

- Exposed at `/setup/handoff/approval-acceptance(.json)`.
- Starts as `status: :pending` on clean setup state.
- Becomes `status: :satisfied` only after explicit attempt and approval receipt
  POSTs.
- Also has an explicit convenience alias:
  `POST /setup/handoff/approval-acceptance/record`.
- Must keep `applied_count: 0`, `gates_runtime: false`, and
  `grants_capabilities: false`.

## Current Lowerings

```text
persist alias -> storage.shape=:store -> Store[T]
history alias -> storage.shape=:history -> History[T]
relation descriptor -> Relation[Store[A], History[B]]
command mutation -> normalized operation intent -> app boundary
projection reads -> graph-owned read model
setup health -> report-only current-state packet
setup handoff -> compact agent context rotation packet
```

## Do Not Infer

- Do not infer DB tables, SQL indexes, foreign keys, cascades, or migrations.
- Do not infer runtime contract generation from `WizardTypeSpec`.
- Do not infer capability grants from approval receipts.
- Do not infer public API stability from manifest vocabulary.

## Next Safe Slice

Use this glossary to keep future slices small:

- add missing manifest terms here before expanding implementation
- update `manifest_glossary_health` when this glossary intentionally changes
- keep compatibility aliases until lowerings stabilize
- prefer report-only diagnostics before runtime enforcement
- keep setup/read endpoints side-effect-free
