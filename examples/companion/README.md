# Companion — Stack Voice Assistant Demo

`examples/companion` is the canonical stack-style Igniter demo.

It now combines both goals:

- show the standard `Igniter::Stack` project shape
- demonstrate a realistic voice assistant split into `apps/main` and `apps/inference`
- show how an Igniter app can ship user-facing communication via Telegram

## Quick Start

From the repository root:

```bash
bundle exec ruby examples/companion/bin/demo
bundle exec ruby examples/companion/stack.rb main
bundle exec ruby examples/companion/stack.rb inference
bundle exec ruby examples/companion/stack.rb dashboard
```

Or from inside the example:

```bash
cd examples/companion
bin/demo
bin/dev
bin/start
bin/start inference
bin/start --role admin
bin/start --env production --role api
```

## Roles

| App | Responsibility |
|-----|----------------|
| `apps/main` | orchestrator, tools, skills, chat executor, proactive agents |
| `apps/inference` | ASR, intent classification, TTS executors and contracts |
| `apps/dashboard` | stack monitoring, reminder/state overview, JSON status snapshot |

Single-process demo mode uses `Companion::LocalPipelineContract` and mock executors so it
runs without hardware, Ollama, Whisper, or Piper.

## Persistence

Companion now splits persistence into two layers:

- stack data in `stack.yml` → notes, chat bindings, conversation state
- app execution store in `apps/<name>/app.yml` → pending/resumable executions

Default example config stays on in-memory adapters so the demo works without extra gems.
To persist data locally, add `sqlite3` and switch the adapters:

```yaml
# stack.yml
persistence:
  data:
    adapter: sqlite
    path: var/companion_data.sqlite3
```

```yaml
# apps/main/app.yml
persistence:
  execution:
    adapter: sqlite
    path: var/main_executions.sqlite3
```

ENV still wins when needed:

```bash
export COMPANION_DATA_DB=var/companion_data.sqlite3
export COMPANION_EXECUTION_DB=var/main_executions.sqlite3
```

## Telegram Delivery

`apps/main` now includes a Telegram tool powered by `Igniter::Channels::Telegram`.

Configure:

```bash
export TELEGRAM_BOT_TOKEN=123456:your-bot-token
```

Then the companion can forward summaries, reminders, or ad-hoc messages to Telegram
through `Companion::SendTelegramTool`.

You can still set `TELEGRAM_CHAT_ID` explicitly, but it is no longer required once a
user has linked a chat through the inbound bot flow.

## Telegram Inbound Bot Workflow

`apps/main` also exposes a webhook endpoint for inbound Telegram updates:

```text
POST /telegram/webhook
```

Optional protection:

```bash
export TELEGRAM_WEBHOOK_SECRET=choose-a-random-secret
```

When configured, the companion expects the header
`X-Telegram-Bot-Api-Secret-Token` to match that secret.

The inbound MVP flow is:

1. Telegram sends a text update to `/telegram/webhook`
2. companion persists the chat binding and remembers the most recent / preferred chat
3. `apps/main` builds a short per-chat conversation history
4. `Companion::ChatContract` generates the reply
5. `Igniter::Channels::Telegram` sends the response back to the same chat

So after wiring your bot webhook to the running companion, you can talk to it
directly in Telegram.

Useful bot commands:

- `/start` — link the current chat and reset its local conversation history
- `/use_here` — make the current chat the default destination for future outbound Telegram messages
- `/notifications on` — enable persisted Telegram notifications for this chat
- `/notifications off` — disable persisted Telegram notifications for this chat
- `/reminders` — list active reminders linked to the current chat

Reminder requests are now persisted as structured records in companion data storage, not
just as loose notes. When a reminder is created from a linked Telegram chat, companion
also persists whether Telegram notifications are enabled for that chat, which gives us a
clean base for the future `apps/dashboard`.

## Seeded View Schemas

The dashboard now seeds two canonical schema-driven pages through
`Companion::Dashboard::ViewSchemaCatalog`:

- `/views/training-checkin` — contract-backed check-in flow
- `/views/weekly-review` — lightweight persisted review form

They are the current reference examples for authoring semantic schema nodes such as
`notice`, `fieldset`, and `actions`.

The dashboard home page now also acts as a lightweight schema catalog/editor, so you
can browse stored schemas, open their rendered pages, fetch `/api/views` JSON, and
draft create/patch payloads from the same operator surface. It also shows recent
view submissions so the authoring/runtime feedback loop stays visible in one place,
including a submission detail page with payload inspection, normalization diff, and replay.

## Structure

```text
examples/companion/
├── stack.rb
├── stack.yml
├── config/
│   ├── topology.yml
│   ├── environments/
│   └── deploy/
│       ├── Dockerfile
│       ├── Procfile.dev
│       └── compose.yml
├── apps/
│   ├── dashboard/
│   │   ├── app.rb
│   │   ├── app.yml
│   │   └── spec/
│   ├── main/
│   │   ├── app.rb
│   │   ├── app.yml
│   │   ├── app/
│   │   │   ├── contracts/
│   │   │   ├── executors/
│   │   │   ├── tools/
│   │   │   ├── agents/
│   │   │   └── skills/
│   │   └── spec/
│   └── inference/
│       ├── app.rb
│       ├── app.yml
│       ├── app/
│       │   ├── contracts/
│       │   └── executors/
│       └── spec/
├── bin/
│   ├── demo
│   └── start
├── lib/
│   └── companion/
│       └── shared/
└── spec/
```

## Testing

Use the stack-level specs for shared and integration behavior, and the app-local specs
for role-specific behavior:

```bash
bundle exec rspec examples/companion/spec
bundle exec rspec examples/companion/apps/main/spec
bundle exec rspec examples/companion/apps/inference/spec
bundle exec rspec examples/companion/apps/dashboard/spec
```

## Deployment Reference

Companion now includes a canonical deployment layout under `config/`:

- [config/topology.yml](/Users/alex/dev/projects/igniter/examples/companion/config/topology.yml) describes deployment roles and wiring
- [config/environments/development.yml](/Users/alex/dev/projects/igniter/examples/companion/config/environments/development.yml) is the local overlay for dev-style boot
- [config/environments/production.yml](/Users/alex/dev/projects/igniter/examples/companion/config/environments/production.yml) is the production-oriented overlay
- [config/deploy/Dockerfile](/Users/alex/dev/projects/igniter/examples/companion/config/deploy/Dockerfile) is the shared container image
- [config/deploy/Procfile.dev](/Users/alex/dev/projects/igniter/examples/companion/config/deploy/Procfile.dev) is the generated local multi-process dev profile
- [config/deploy/compose.yml](/Users/alex/dev/projects/igniter/examples/companion/config/deploy/compose.yml) starts `main`, `inference`, and `dashboard` together

From the repository root:

```bash
docker compose -f examples/companion/config/deploy/compose.yml up --build
```

This deployment config is intentionally separate from `apps/*/app.yml`:

- `apps/*` defines the code and leaf runtime defaults
- `stack.yml` defines stack-level metadata and shared persistence defaults
- `config/topology.yml` defines how those apps are deployed together
- `config/environments/*` overlays topology/runtime intent per environment
- `config/deploy/*` holds container/runtime artifacts

Operational launch examples:

```bash
bin/start main
bin/start --role api
bin/start --role admin
bin/start --env production --role api
bin/dev
bin/start --print-procfile-dev
bin/start --write-procfile-dev
bin/start --profile local-compose --role admin
bin/start --print-compose
bin/start --write-compose
```

## Dashboard

Run the dashboard app:

```bash
cd examples/companion
bin/start dashboard
```

Then open:

- `http://localhost:4569/` for the HTML dashboard
- `http://localhost:4569/api/overview` for the JSON snapshot

The dashboard reads the same persisted stack data used by `apps/main`, so it can
show notes, active reminders, Telegram chat bindings, notification preferences, and
per-app execution-store summaries.

## Migration Note

The previous pre-generator-refresh version of this example now lives in
[`examples/companion_legacy`](../companion_legacy/README.md) as an archived reference.

The current `examples/companion` is the clean baseline regenerated from the current
stack/app scaffold and then selectively migrated forward. The legacy version is still
useful for:

- historical comparison during migration
- checking older deployment and app-shape decisions

## ESP32 Client

Firmware for the ESP32-A1S audio kit now lives in
[`esp32/companion_client.ino`](./esp32/companion_client.ino).
