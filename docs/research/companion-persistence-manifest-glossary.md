# Companion Persistence Manifest Glossary

Status date: 2026-04-29.
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
- It is a handoff/read model, not an execution or approval surface.

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
