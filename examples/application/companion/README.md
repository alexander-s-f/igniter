# Igniter Companion

Companion is a ready-to-go Igniter application experiment. It is aimed at
ordinary users first: run the app, add optional credentials, and use small
assistant capsules.

Current capsules:

- reminders
- trackers
- countdowns
- daily summary

The launcher is intentionally thin. App-local infrastructure lives under
`companion/`:

- `configuration.rb` owns credentials and store backend selection.
- `runtime.rb` owns server and smoke wiring.
- `app_dsl.rb` owns app-local routing/configuration sugar.
- `services/store_backends.rb` provides the store interface and SQLite backend.
- `igniter-ai` contains the live OpenAI Responses provider.
- `contracts/daily_summary_contract.rb` uses the human contract DSL form.

Run smoke:

```bash
ruby examples/application/companion_poc.rb
```

Run the local browser surface:

```bash
ruby examples/application/companion_poc.rb server
```

Set `OPENAI_API_KEY` to make the app live-ready. The first slice does not call
the provider yet; it proves the setup state, capsule shape, SQLite-backed store,
and offline smoke path.

Smoke mode forces offline behavior unless `COMPANION_LIVE=1` is set.

The live summary action uses OpenAI's Responses API when the user explicitly
submits the live summary form. Page render and smoke do not call the provider.
