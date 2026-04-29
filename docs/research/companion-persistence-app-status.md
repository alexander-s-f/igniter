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

Current manifest scale:

- records: 6
- histories: 6
- projections: 5
- command groups: 5
- relations: 2
- total capabilities: 17

Current manifest vocabulary:

- top-level `schema_version: 1`
- durable capabilities expose canonical `storage.shape`
- record capabilities use `storage.shape: :store`
- history capabilities use `storage.shape: :history`
- current `persist`/`history` aliases remain present for compatibility
- `operation_descriptors` expose operation name, target shape, mutation flag,
  and `boundary: :app` next to compatibility `operations` lists
- relation descriptors expose source/target storage shapes, lowering metadata,
  and `enforcement.mode: :report_only`
- `/setup/manifest/glossary-health` reports whether required glossary terms are
  still present and stable
- `/setup` includes the same glossary health as a report-only summary signal;
  readiness does not become stricter because of glossary drift
- `/setup/health(.json)` summarizes readiness, relation health, manifest
  glossary health, materializer descriptor health, and infrastructure loop
  health as a report-only packet
- `/setup/materializer(.json)` exposes a `materializer_status` descriptor with
  schema version, review-only state, history targets, command intents, audit
  counts, `grants_capabilities: false`, and `execution_allowed: false`
- `/setup/materializer/descriptor-health(.json)` reports descriptor drift
  without changing readiness or granting execution

See [Companion Persistence Manifest Glossary](./companion-persistence-manifest-glossary.md)
for the compact agent reading guide.

Current record capabilities:

- `Reminder`: `persist`, fields, `index :status`, `scope :open`, command
  metadata for `complete`
- `Tracker`: `persist`, fields
- `DailyFocus`: `persist`, date-keyed workflow/session record
- `Countdown`: `persist`, fields
- `Article`: `persist`, wizard-shaped static user type proof
- `WizardTypeSpec`: `persist`, JSON durable spec store

Current history capabilities:

- `TrackerLog`: `history`, append-only tracker measurements
- `CompanionAction`: `history`, append-only user/runtime receipts
- `Comment`: `history`, append-only article comments
- `WizardTypeSpecChange`: `history`, append-only spec lineage
- `MaterializerAttempt`: `history`, append-only future materializer audit
  receipts; declared and manifest-visible, but not auto-appended by setup reads
- `MaterializerApproval`: `history`, append-only future approval audit receipts;
  declared and manifest-visible, but not auto-appended by setup reads

Current projection contracts:

- `TrackerReadModelContract`: `Tracker` records plus `TrackerLog` history
- `CountdownReadModelContract`: countdown records to dashboard facts
- `ActivityFeedContract`: action history to activity facts
- `MaterializerAuditTrailContract`: materializer attempt history to audit facts
- `MaterializerApprovalAuditTrailContract`: approval history to audit facts

Current relation capability:

- `tracker_logs_by_tracker`: report-only `event_owner` relation from `Tracker`
  records to `TrackerLog` history with `join: { id: :tracker_id }`,
  `cardinality: :one_to_many`, `projection: :tracker_read_model`, and
  `enforced: false`; its descriptor lowers `Store[Tracker]` to
  `History[TrackerLog]` through a report-only relation

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
- `WizardTypeSpecMigrationPlanContract`: review-only migration candidate
  projection over spec lineage; it classifies additive, destructive, and
  ambiguous field changes without executing migrations
- `InfrastructureLoopHealthContract`: self-supporting/fractal health projection
  over readiness, manifest, materialization plan, parity, and migration plan
- `MaterializerGateContract`: read-only capability gate that blocks
  write/git/test/restart materializer capabilities until explicit approval even
  when the infrastructure loop is healthy; it also emits a structured
  review-only approval request
- `MaterializerPreflightContract`: review packet that joins loop health, parity,
  migration status, gate state, blocked capabilities, and approval request
  without granting capability
- `MaterializerRunbookContract`: review-only protocol that lowers the preflight
  packet into blocked write/test/git/restart materializer steps
- `MaterializerReceiptContract`: review-only receipt projection that records the
  blocked runbook and non-executed step events for future history persistence
- `MaterializerAttempt`: static history contract for those future receipts,
  proving the path to `History[MaterializerAttempt]` without side effects
- `MaterializerAttemptContract`: command contract that lowers the review-only
  receipt into normalized `history_append :materializer_attempts` intent without
  applying it
- `MaterializerAuditTrailContract`: projection over `History[MaterializerAttempt]`
  for blocked attempt counts, blocked capabilities, and latest receipt
- `MaterializerSupervisionContract`: compact lifecycle read model over gate,
  preflight, runbook, receipt, attempt command intent, approval command intent,
  attempt audit, and approval audit; it also emits the canonical
  `materializer_status` descriptor consumed by `/setup/materializer(.json)`
- `MaterializerStatusDescriptorHealthContract`: report-only guard that validates
  the compact status descriptor still has schema version, review-only/no-grant
  boundaries, app-boundary requirement, history targets, command intents, audit
  counts, and status/phase alignment
- `SetupHealthContract`: report-only summary over persistence readiness,
  relation diagnostics, manifest glossary health, materializer descriptor
  health, and infrastructure loop health
- `MaterializerApprovalPolicyContract`: read-only decision model for human
  approval over requested materializer capabilities; it validates subset/unknown
  capabilities and still does not apply capabilities
- `MaterializerApprovalReceiptContract`: review-only receipt projection over the
  approval policy decision; approved receipts still keep
  `applies_capabilities: false`
- `MaterializerApproval`: static history contract for future approval receipts,
  proving the path to `History[MaterializerApproval]` without side effects
- `MaterializerApprovalContract`: command contract that lowers an approval
  receipt into normalized `history_append :materializer_approvals` intent
  without applying it
- `MaterializerApprovalAuditTrailContract`: projection over
  `History[MaterializerApproval]` for approval counts, granted/rejected
  capabilities, applied count, and latest receipt
- `Wizard Type Spec Architecture`: research response now treats
  `WizardTypeSpec` as future `Store[ContractSpec]` and
  `WizardTypeSpecChange` as future `History[ContractSpecChange]`
- seeded wizard specs now use canonical `schema_version: 1` and
  `storage.shape`, while preserving `persist`/`history` aliases for current
  app-local compatibility

Current command contracts:

- `ReminderContract`: create/complete, success/refusal, mutation intent
- `CountdownContract`: create, success/refusal, mutation intent
- `TrackerLogContract`: append, success/refusal, mutation intent
- `MaterializerAttemptContract`: record blocked review-only attempt,
  success/refusal, mutation intent
- `MaterializerApprovalContract`: record approval decision receipt,
  success/refusal, mutation intent

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
- `/setup/health` exposes a compact report-only setup health packet for agents
- `/setup/relation-health` exposes relation diagnostics for humans
- `/setup/relation-health.json` exposes relation diagnostics for tools
- `/setup/materialization-plan` exposes the read-only wizard-spec to static
  contract materialization plan
- `/setup/materialization-parity` exposes plan-to-static-manifest parity for
  agents and reviewers
- `/setup/wizard-type-specs` exposes stored dynamic specs before materialization
- `/setup/wizard-type-spec-export` exposes dev/prod portable config projections
- `/setup/wizard-type-spec-migration-plan` exposes review-only migration
  candidates from spec lineage
- `/setup/infrastructure-loop-health` exposes whether the contract-managed
  infrastructure loop is self-supporting without requesting write capability
- `/setup/materializer-gate` exposes the current materializer capability gate;
  default state is blocked by `human_approval_required`
- `/setup/materializer-preflight` exposes the review packet for a future human
  approval flow
- `/setup/materializer/descriptor-health` exposes the materializer status
  descriptor guard for agents and reviewers
- `/setup/materializer-runbook` exposes the blocked review-only materializer
  steps that a future approved agent could execute
- `/setup/materializer-receipt` exposes the non-executed audit receipt for the
  blocked materializer runbook
- `/setup/materializer-attempt-command` exposes the computed history append
  intent for that receipt without appending it
- `POST /setup/materializer-attempts/record` is the explicit app-boundary write
  path that applies that intent and persists one attempt receipt
- `/setup/materializer-audit-trail` exposes the read model over persisted
  materializer attempts
- `/setup/materializer` exposes the canonical compact materializer status packet;
  it is an alias over supervision, not a new capability
- `/setup/materializer-supervision` exposes a compact status, phase, signals,
  next action, attempt command intent, approval command intent, attempt audit,
  and approval audit summary for the whole materializer lifecycle
- `/setup/materializer-approval-policy` exposes the default pending approval
  decision and proves approval is explicit policy data, not hidden capability
- `/setup/materializer-approval-receipt` exposes an audit-ready approval receipt
  without applying any capability
- `/setup/materializer-approval-command` exposes the computed approval history
  append intent without appending it
- `POST /setup/materializer-approvals/record` is the explicit app-boundary write
  path that persists one approval receipt without applying capability
- `/setup/materializer-approval-audit-trail` exposes the read model over
  persisted approval receipts
- the dashboard surfaces the compact materializer packet as a review-only card
  with no execute action

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

## Landing Zone

Persistence is now important enough to reserve a landing path, but not important
enough to split a package from this proof alone.

Current placement decision:

- keep the next iteration app-local in Companion
- extract contract-facing vocabulary/descriptors toward `igniter-extensions`
  only after the manifest vocabulary stops moving
- extract host/runtime binding, adapters, setup/readiness surfaces, explicit
  write boundaries, and materializer review flows toward `igniter-application`
  only after a second app/example repeats the pressure
- reserve `igniter-persistence` as the future package name if a separate package
  becomes justified
- avoid `igniter-data` for now because it is too broad and blurs persistence
  with dataflow, analytics, datasets, and ETL
- keep `igniter-contracts` host-agnostic; persistence remains optional
  vocabulary plus app-boundary behavior

See [Contract Persistence Landing Zone](./contract-persistence-landing-zone.md).

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

The next safe move is vocabulary and materializer hardening, still app-local:

- keep relation metadata typed and report-only
- keep approval reads side-effect-free
- apply approval persistence only through an explicit app-boundary POST
- keep dynamic wizard/configurator output sandboxed until it materializes into
  static contracts
- store dynamic wizard output as durable specs, not executable runtime code
- keep spec history append-only for dev/migration work; prod export may compress
  to latest-only specs
- migration planning may classify changes, but must remain review-only
- prefer a future canonical spec shape with `schema_version` and
  `storage.shape`, while keeping current `persist`/`history` compatibility
- keep materialization planning read-only until explicit write/git/test/restart
  capabilities are modeled
- require parity to pass before a future materializer requests write/git/restart
- track the infrastructure loop as contract output so the system can inspect its
  own support structure
- keep materializer write/git/test/restart capabilities behind an explicit
  approval gate
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
[S] Fractal/self-supporting shape is positive evidence: contracts now describe
durable specs, validate infrastructure, compute materializer review packets, and
project audit trails for their own future materialization path.
Next: stabilize manifest vocabulary, operation algebra, relation semantics, and
materializer approval lifecycle while keeping capability grants review-only and
non-applied.
Block: none.
```
