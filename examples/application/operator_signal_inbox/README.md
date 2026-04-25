# Operator Signal Inbox

This is the second app-local interactive POC. It repeats the accepted
Application + Web pattern outside the task-board domain.

Copyable seams:

- `services/signal_inbox.rb` owns signal state, commands, action facts,
  `CommandResult`, and `SignalSnapshot`.
- `web/signal_inbox.rb` owns the rendered `igniter-web` surface and stable
  marker vocabulary.
- `app.rb` declares the `Igniter::Application.rack_app` service, web mount,
  command endpoints, and `/events`.
- `config.ru` exposes the same app to Rack-compatible runners.

Commands:

- `POST /signals/acknowledge` acknowledges an open signal by `id`.
- `POST /signals/escalate` escalates an open signal by `id` and `note`.
- Missing signals, closed signals, and blank escalation notes return app-local
  refusal feedback codes.
- `GET /events` renders from the same detached `SignalSnapshot` shape that the
  web board consumes.

Run the smoke launcher from the repository root:

```bash
ruby examples/application/signal_inbox_poc.rb
```

Run the local browser server:

```bash
ruby examples/application/signal_inbox_poc.rb server
```
