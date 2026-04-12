# Companion — Workspace Voice Assistant Demo

`examples/companion` is the canonical workspace-style Igniter demo.

It now combines both goals:

- show the standard `Igniter::Workspace` project shape
- demonstrate a realistic voice assistant split into `apps/main` and `apps/inference`

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
