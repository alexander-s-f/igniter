# Igniter Companion

Companion is a ready-to-go Igniter application experiment. It is aimed at
ordinary users first: run the app, add optional credentials, and use small
assistant capsules.

Current capsules:

- reminders
- trackers
- countdowns
- daily summary

Run smoke:

```bash
ruby examples/application/companion_poc.rb
```

Run the local browser surface:

```bash
ruby examples/application/companion_poc.rb server
```

Set `OPENAI_API_KEY` to make the app live-ready. The first slice does not call
the provider yet; it proves the setup state, capsule shape, and offline smoke
path.

Smoke mode forces offline behavior unless `COMPANION_LIVE=1` is set.
