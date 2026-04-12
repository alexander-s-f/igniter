# Companion — Workspace Voice Assistant Demo

`examples/companion` is the canonical workspace-style Igniter demo.

It now combines both goals:

- show the standard `Igniter::Workspace` project shape
- demonstrate a realistic voice assistant split into `apps/main` and `apps/inference`
- show how an Igniter app can ship user-facing communication via Telegram

## Quick Start

From the repository root:

```bash
bundle exec ruby examples/companion/bin/demo
bundle exec ruby examples/companion/workspace.rb main
bundle exec ruby examples/companion/workspace.rb inference
```

Or from inside the example:

```bash
cd examples/companion
bin/demo
bin/start
bin/start inference
```

## Roles

| App | Responsibility |
|-----|----------------|
| `apps/main` | orchestrator, tools, skills, chat executor, proactive agents |
| `apps/inference` | ASR, intent classification, TTS executors and contracts |

Single-process demo mode uses `Companion::LocalPipelineContract` and mock executors so it
runs without hardware, Ollama, Whisper, or Piper.

## Persistence

Companion now splits persistence into two layers:

- workspace data in `workspace.yml` → notes, chat bindings, conversation state
- app execution store in `apps/<name>/application.yml` → pending/resumable executions

Default example config stays on in-memory adapters so the demo works without extra gems.
To persist data locally, add `sqlite3` and switch the adapters:

```yaml
# workspace.yml
persistence:
  data:
    adapter: sqlite
    path: var/companion_data.sqlite3
```

```yaml
# apps/main/application.yml
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
export TELEGRAM_CHAT_ID=123456789
```

Then the companion can forward summaries, reminders, or ad-hoc messages to Telegram
through `Companion::SendTelegramTool`.

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
2. `apps/main` builds a short per-chat conversation history
3. `Companion::ChatContract` generates the reply
4. `Igniter::Channels::Telegram` sends the response back to the same chat

So after wiring your bot webhook to the running companion, you can talk to it
directly in Telegram.

## Structure

```text
examples/companion/
├── workspace.rb
├── workspace.yml
├── apps/
│   ├── main/
│   │   ├── application.rb
│   │   ├── application.yml
│   │   ├── app/
│   │   │   ├── contracts/
│   │   │   ├── executors/
│   │   │   ├── tools/
│   │   │   ├── agents/
│   │   │   └── skills/
│   │   └── spec/
│   └── inference/
│       ├── application.rb
│       ├── application.yml
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

Use the workspace-level specs for shared and integration behavior, and the app-local specs
for role-specific behavior:

```bash
bundle exec rspec examples/companion/spec
bundle exec rspec examples/companion/apps/main/spec
bundle exec rspec examples/companion/apps/inference/spec
```

## Migration Note

The previous flat-layout implementation has been moved to
[`examples/companion_legacy`](../companion_legacy/README.md) as a temporary reference.

The new workspace companion is now the main demo stand. The legacy version is still useful for:

- historical comparison during migration
- distributed deployment notes

## ESP32 Client

Firmware for the ESP32-A1S audio kit now lives in
[`esp32/companion_client.ino`](./esp32/companion_client.ino).
