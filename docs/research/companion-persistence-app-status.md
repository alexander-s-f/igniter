# Companion Persistence App Status

Status date: 2026-04-29.
Scope: Companion application proof only. No core, package, stable API, grammar,
or migration-generator promotion.

## Current Claim

Companion now validates contract persistence as an app-local capability model:
persistent shapes are declared by contracts, relations are reported as typed
manifest edges, behavior is computed by graph contracts, and side effects are
applied at the app/store boundary.

The proof is strong enough to guide the next research slice. It is not yet a
public Igniter persistence API.

## App-Local Surface

`Companion::Contracts::PersistenceSketchPack` adds report-only DSL keywords:

- `persist`
- `history`
- `field`
- `index`
- `scope`
- `command`

These keywords compile to metadata operations in Companion contract manifests.
They do not change the core contracts runtime.

Current record capabilities:

- `Reminder`: `persist`, fields, `index :status`, `scope :open`, command
  metadata for `complete`
- `Tracker`: `persist`, fields
- `DailyFocus`: `persist`, date-keyed workflow/session record
- `Countdown`: `persist`, fields

Current history capabilities:

- `TrackerLog`: `history`, append-only tracker measurements
- `CompanionAction`: `history`, append-only user/runtime receipts

Current projection contracts:

- `TrackerReadModelContract`: `Tracker` records plus `TrackerLog` history
- `CountdownReadModelContract`: countdown records to dashboard facts
- `ActivityFeedContract`: action history to activity facts

Current relation capability:

- `tracker_logs_by_tracker`: report-only `event_owner` relation from `Tracker`
  records to `TrackerLog` history with `join: { id: :tracker_id }`,
  `cardinality: :one_to_many`, `projection: :tracker_read_model`, and
  `enforced: false`

Current relation diagnostics:

- `PersistenceRelationHealthContract` projects per-relation status, structured
  warnings, repair suggestions, and summary
- orphan tracker-log entries produce diagnostic-only `missing_source` warnings
- relation warnings do not reject writes or repair data

Current user-defined-type pressure test:

- `WizardTypeSpec`: static persisted record for dynamic contract specs, with
  `id`, `contract`, and JSON `spec`
- `WizardTypeSpecChange`: append-only history for spec lineage and future
  migration planning
- `Article`: static record contract shaped like a future wizard output, with
  typed fields, enum status default, scopes, index, and publish command metadata
- `Comment`: static append-only history contract with an `article_id` relation
  field
- `comments_by_article`: report-only relation from `Article` records to
  `Comment` history, with enforcement still disabled
- `DurableTypeMaterializationContract`: read-only graph contract that accepts a
  persisted wizard-shaped spec and returns the static contract/history/relation
  plan plus required materializer capabilities
- `StaticMaterializationParityContract`: read-only graph contract that compares
  that plan with the already materialized static manifests and reports drift
- `WizardTypeSpecExportContract`: read-only export projection with dev mode
  retaining history and prod mode compressed to latest specs only
- `Wizard Type Spec Architecture`: research response now treats
  `WizardTypeSpec` as future `Store[ContractSpec]` and
  `WizardTypeSpecChange` as future `History[ContractSpecChange]`

Current command contracts:

- `ReminderContract`: create/complete, success/refusal, mutation intent
- `CountdownContract`: create, success/refusal, mutation intent
- `TrackerLogContract`: append, success/refusal, mutation intent

Current operation algebra:

- `record_append`
- `record_update`
- `history_append`
- `none`

## Registry Shape

`CompanionPersistence` is now the app-local capability registry/factory.

It owns:

- record bindings
- history bindings
- projection bindings
- projection input bindings
- command operation manifests
- relation manifests
- relation health reports
- validation errors
- readiness projection
- setup manifest projection

It validates:

- record bindings have `persist`
- history bindings have `history`
- record classes cover declared fields
- indexes reference declared fields
- command metadata uses supported operations
- command metadata changes declared fields
- projection contracts compile
- projection reads point at known capabilities
- projection relation inputs point at known relations
- relation endpoints exist
- relation endpoint kinds match relation kind
- relation join fields exist
- relation enforcement remains false

## Runtime Boundary

`CompanionStore` remains the mutation boundary:

- graph command contracts compute results and mutation intents
- `CompanionStore#apply_persistence_mutation` applies normalized operations
- app backend persists the whole Companion state
- command/user/runtime receipts append to `CompanionAction` history
- relation health is reported as diagnostics over existing state, not as write
  enforcement

This keeps compute nodes side-effect-free while still making persistence behavior
inspectable.

## Product Proof

Current Companion product flows use the persistence model:

- dashboard reads open reminders through `ContractRecordSet#scope(:open)`
- tracker cards are projections from tracker records plus tracker-log history
- countdown cards are projections from countdown records
- activity feed is a projection from action history
- Today quick action is graph-owned and can invoke tracker-log append or
  reminder-complete flows without the UI owning persistence semantics
- dashboard status exposes relation-health summary as a diagnostic signal
- `/setup` and `/setup/manifest` expose readiness and manifest state
- `/setup/relation-health` exposes relation diagnostics for humans
- `/setup/relation-health.json` exposes relation diagnostics for tools
- `/setup/materialization-plan` exposes the read-only wizard-spec to static
  contract materialization plan
- `/setup/materialization-parity` exposes plan-to-static-manifest parity for
  agents and reviewers
- `/setup/wizard-type-specs` exposes stored dynamic specs before materialization
- `/setup/wizard-type-spec-export` exposes dev/prod portable config projections

## Validated Concepts

- `persist` is viable Ruby product sugar for `Store[T]`.
- `history` is viable Ruby product sugar for `History[T]`.
- `index`, `scope`, and `command` metadata can be reported before DB planning or
  runtime enforcement.
- Generated record/history APIs can be app-local and tiny.
- Projections should be graph-owned, not hidden in UI code.
- Relations should begin as typed manifest edges, not ORM associations or DB
  foreign keys.
- Relation health can reach `warn` phase while enforcement remains false.
- Mutation intents need a small operation algebra, not ad hoc symbols.
- Store should shrink toward a boundary facade, not grow into an ORM.

## Boundaries

Not accepted yet:

- public package API
- core DSL keywords
- runtime database abstraction
- migration generator
- automatic SQL indexes
- relation enforcement
- distributed placement
- `Igniter::Lang` grammar syntax
- treating histories as mutable CRUD

## Authoring Rule

Dynamic authoring is allowed as a sandbox. A wizard/configurator may collect a
durable type shape, preview it, and run local experiments, but durable
production behavior should materialize into static contracts before it becomes
part of the app. The materializer may later be a specialized agent or contract
with explicit capabilities such as write, git, push, update, and restart. Until
that exists, Companion strengthens the static contract shape first.

## Latest Research Move

Two relation slices have landed app-locally:

- `Store[Tracker] + History[TrackerLog] -> TrackerReadModelContract`
- `Store[Article] + History[Comment] -> comments_by_article`
- relation manifest is exposed through setup manifest
- readiness includes relation count and relation warning count
- projection manifest declares relation input
- relation health reports orphan history references as warnings
- relation repair suggestions are command-intent shaped, but not executable
  repair behavior

The next safe move is materialization hardening or relation-health ergonomics,
still app-local:

- keep dynamic wizard/configurator output sandboxed until it materializes into
  static contracts
- store dynamic wizard output as durable specs, not executable runtime code
- keep spec history append-only for dev/migration work; prod export may compress
  to latest-only specs
- prefer a future canonical spec shape with `schema_version` and
  `storage.shape`, while keeping current `persist`/`history` compatibility
- keep materialization planning read-only until explicit write/git/test/restart
  capabilities are modeled
- require parity to pass before a future materializer requests write/git/restart
- keep relation enforcement false
- keep relation repair suggestions review-only
- avoid cascade semantics, FK generation, and DB planners
- preserve `persist -> Store[T]`, `history -> History[T]`, and future
  `Relation[Store[A], History[B]]`

## Handoff

```text
[Architect Supervisor / Codex]
Track: docs/research/companion-persistence-app-status.md
Status: current Companion app-level persistence proof summarized.
[D] Persistence stays app-local while the concept settles.
[D] Current validated shape is records + histories + projections + command
operation intents + relation manifests + relation health +
registry/readiness/manifest.
[R] Do not promote `persist`, `history`, `index`, `scope`, `command`, or
relation declarations into core from this proof alone.
[R] Preserve `persist -> Store[T]` and `history -> History[T]`.
[S] Reminder now proves metadata beyond fields: index, scope, and command
metadata are reportable and usable by app-local generated APIs.
[S] Tracker to TrackerLog proves projection relation input and warning path.
[S] Article to Comment proves user-defined-type pressure through static
contracts before dynamic materialization.
Next: keep relation health diagnostic-only; harden static materialization shape
before adding wizard runtime.
Block: none.
```
