# Igniter Companion

Companion is a ready-to-go Igniter application experiment. It is aimed at
ordinary users first: run the app, add optional credentials, and use small
assistant capsules.

Current capsules:

- reminders
- trackers
- countdowns
- body battery
- daily plan
- daily summary
- hub install surface

The launcher is intentionally thin. App-local infrastructure lives under
`companion/`:

- `configuration.rb` owns credentials and store backend selection.
- `runtime.rb` owns server and smoke wiring.
- `app_dsl.rb` owns app-local routing and AI/provider configuration sugar.
- `services/store_backends.rb` provides the store interface and SQLite backend.
- `services/companion_persistence.rb` collects app-local generated persistence
  capabilities and read-model projections behind the Store façade.
- `contracts/reminder_contract.rb` and `contracts/tracker_log_contract.rb`
  experiment with persistence as graph-owned command/result/mutation semantics.
- `contracts/countdown_contract.rb` applies the same command/result/mutation
  semantics to a user-facing countdown creation flow.
- command contracts now return normalized persistence operations:
  `record_append`, `record_update`, `history_append`, or `none`.
- `contracts/persistence_manifest_contract.rb` projects records, histories,
  projections, and command operations into `/setup/manifest`.
- `contracts/reminder_record_contract.rb` sketches the target
  `contract :Reminder do persist... field... index... scope... command... end`
  metadata surface.
- `contracts/daily_focus_record_contract.rb` models daily focus as a date-keyed
  persisted record instead of a scalar state slot.
- `contracts/countdown_record_contract.rb` models countdowns as generated
  persisted records.
- `contracts/countdown_read_model_contract.rb` derives days-remaining facts
  from countdown records for the dashboard.
- `services/contract_record_set.rb` turns that metadata into a tiny generated
  record API: `all`, `find`, `save`, `update`, `delete`, `clear`, `scope`, and
  `command`.
- `contracts/tracker_record_contract.rb` declares trackers as record
  persistence, composed with tracker-log history for dashboard projections.
- `contracts/tracker_read_model_contract.rb` derives tracker dashboard facts
  from tracker records plus tracker-log history.
- `contracts/article_record_contract.rb` and `contracts/comment_history_contract.rb`
  are a static, wizard-shaped durable type proof: `Article` is a record with
  typed fields, enum status defaults, scopes, index, and publish command
  metadata; `Comment` is append-only history related back to articles.
- `contracts/wizard_type_spec_record_contract.rb` stores sandbox-authored
  durable type specs as persisted JSON data before static materialization. The
  seeded spec uses `schema_version: 1` and host-neutral `storage.shape`, while
  keeping `persist`/`history` aliases for current app-local compatibility.
- `contracts/wizard_type_spec_history_contract.rb` keeps append-only spec
  lineage for future migrations.
- `contracts/wizard_type_spec_export_contract.rb` projects portable dev/prod
  config: dev keeps history, prod compresses to latest specs.
- `contracts/wizard_type_spec_migration_plan_contract.rb` projects review-only
  migration candidates from spec lineage; it classifies field changes without
  running migrations.
- `contracts/infrastructure_loop_health_contract.rb` projects the self-supporting
  infrastructure loop from readiness, materialization, parity, and migration
  diagnostics.
- `contracts/materializer_gate_contract.rb` keeps future materializer
  write/git/test/restart capabilities behind an explicit approval gate and emits
  a structured review-only approval request.
- `contracts/materializer_preflight_contract.rb` packages loop health, parity,
  migration status, blocked capabilities, and approval request into a review
  packet without granting materializer capabilities.
- `contracts/materializer_runbook_contract.rb` turns that preflight packet into
  a blocked, review-only materializer runbook with one capability per step.
- `contracts/materializer_receipt_contract.rb` records the blocked runbook as a
  review-only, non-executed receipt suitable for future history persistence.
- `contracts/materializer_attempt_history_contract.rb` declares that future
  receipt history as static `history` metadata before any automatic append path.
- `contracts/materializer_attempt_contract.rb` lowers a review-only receipt into
  a normalized `history_append :materializer_attempts` intent without applying it.
- `contracts/durable_type_materialization_contract.rb` is the read-only bridge
  from future wizard/configurator output to static contract materialization
  plans. `/setup/materialization-plan` and `.json` expose that plan for agents
  without writing files.
- `contracts/static_materialization_parity_contract.rb` checks whether that
  read-only plan matches the current static manifests. `/setup/materialization-parity`
  and `.json` expose drift before any future materializer gains write capability.
- `services/companion_persistence.rb` exposes report-only relation manifests
  for `trackers.id -> tracker_logs.tracker_id` and
  `articles.id -> comments.article_id`; the tracker read-model manifest declares
  its relation as an input. Relation health warnings are graph-owned,
  per-relation, structured, diagnostic-only, and include review suggestions
  without enforcing writes. `/setup/relation-health` exposes the same projection
  directly, with `/setup/relation-health.json` for tools. The dashboard surfaces
  the current relation-health summary as a quiet diagnostic signal.
- `contracts/daily_plan_contract.rb` emits the Today next-action signal and
  quick action command intent from explicit facts rather than a whole snapshot.
- `POST /today/quick-action` executes the current graph-owned target, so the
  dashboard does not hardcode domain command routes for Today.
- `contracts/tracker_log_history_contract.rb` and `services/contract_history.rb`
  sketch append-only `history` semantics for logs and signals.
- tracker logs are persisted as first-class top-level history and projected back
  into tracker read models for the dashboard.
- `contracts/companion_action_history_contract.rb` models user/runtime receipts
  as append-only history.
- `contracts/activity_feed_contract.rb` projects action history into the
  dashboard activity feed.
- `contracts/persistence_readiness_contract.rb` projects persistence registry
  validation into readiness diagnostics.
- `services/hub_installer.rb` installs local hub capsules through transfer.
- the dashboard exposes the local hub catalog and install action.
- `igniter-ai` contains the live OpenAI Responses provider.
- `igniter-agents` contains the declared `daily_companion` runtime capability.
- `contracts/daily_summary_contract.rb` uses the human contract DSL form.

Run smoke:

```bash
ruby examples/application/companion_poc.rb
```

Run the local browser surface:

```bash
ruby examples/application/companion_poc.rb server
```

Set `OPENAI_API_KEY` to make the app live-ready. The app stays deterministic by
default; smoke mode proves setup state, capsule shape, SQLite-backed store,
local hub installation, and the offline path.

Smoke mode forces offline behavior unless `COMPANION_LIVE=1` is set.

The live summary action runs the declared `daily_companion` agent, which uses
OpenAI's Responses API through `igniter-ai` when the user explicitly submits
the live summary form. Page render and smoke do not call the provider.
