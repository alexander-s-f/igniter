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
- `contracts/reminder_contract.rb` and `contracts/tracker_log_contract.rb`
  experiment with persistence as graph-owned command/result/mutation semantics.
- `contracts/reminder_record_contract.rb` sketches the target
  `contract :Reminder do persist... field... end` metadata surface.
- `services/contract_record_set.rb` turns that metadata into a tiny generated
  record API: `all`, `find`, `save`, `update`, `delete`, and `clear`.
- `contracts/tracker_record_contract.rb` declares trackers as record
  persistence, composed with tracker-log history for dashboard projections.
- `contracts/tracker_read_model_contract.rb` derives tracker dashboard facts
  from tracker records plus tracker-log history.
- `contracts/tracker_log_history_contract.rb` and `services/contract_history.rb`
  sketch append-only `history` semantics for logs and signals.
- tracker logs are persisted as first-class top-level history and projected back
  into tracker read models for the dashboard.
- `contracts/companion_action_history_contract.rb` models user/runtime receipts
  as append-only history.
- `contracts/activity_feed_contract.rb` projects action history into the
  dashboard activity feed.
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
