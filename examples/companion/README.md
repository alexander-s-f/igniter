# Companion — Cluster Next Sandbox

`examples/companion` is the proving surface for the current `Stack/App` and `Cluster Next` direction.

The intended reading order is now simple:

1. [stack.rb](/Users/alex/dev/projects/igniter/examples/companion/stack.rb)
2. [stack.yml](/Users/alex/dev/projects/igniter/examples/companion/stack.yml)

That is the point.

## Mental Model

- `Stack` is the server container
- `main` is the root app
- `dashboard` is mounted at `/dashboard`
- local mesh nodes are launch profiles of the same stack

So companion is no longer modeled as “many app-servers”.
It is one mounted stack that can be launched several times with different node profiles.

## Local Nodes

The default local mesh is declared in [stack.yml](/Users/alex/dev/projects/igniter/examples/companion/stack.yml):

| Node | Port | Intent | Effective capability shape |
|---|---:|---|---|
| `seed` | `4667` | bootstrap / routing node | `notes_api`, `mesh_seed`, `routing`, mocked `notifications` |
| `edge` | `4668` | edge / audio-facing node | `notes_api`, `speech_io`, mocked `whisper_asr`, `piper_tts` |
| `analyst` | `4669` | reasoning / knowledge node | `notes_api`, `assistant_orchestration`, mocked `local_llm`, `rag` |

Each node runs the same stack:

- `main` on `/`
- `dashboard` on `/dashboard`

## Boot

From the repository root:

```bash
cd examples/companion
bundle install
bin/console --node seed
bin/dev
```

Then open:

- [http://127.0.0.1:4667/v1/home/status](http://127.0.0.1:4667/v1/home/status)
- [http://127.0.0.1:4668/v1/home/status](http://127.0.0.1:4668/v1/home/status)
- [http://127.0.0.1:4669/v1/home/status](http://127.0.0.1:4669/v1/home/status)
- dashboards:
  `http://127.0.0.1:4667/dashboard`,
  `http://127.0.0.1:4668/dashboard`,
  `http://127.0.0.1:4669/dashboard`

To run one node explicitly:

```bash
PORT=4668 \
IGNITER_NODE=edge \
COMPANION_NODE_NAME=companion-edge \
COMPANION_NODE_ROLE=edge \
COMPANION_NODE_URL=http://127.0.0.1:4668 \
COMPANION_LOCAL_CAPABILITIES=notes_api,speech_io \
COMPANION_MOCK_CAPABILITIES=whisper_asr,piper_tts \
COMPANION_SEEDS=http://127.0.0.1:4667 \
COMPANION_START_DISCOVERY=true \
bin/start --node edge
```

## What To Look At

- [stack.rb](/Users/alex/dev/projects/igniter/examples/companion/stack.rb) defines mounted apps
- [stack.yml](/Users/alex/dev/projects/igniter/examples/companion/stack.yml) defines server defaults, persistence, and local node profiles
- [apps/main/app.rb](/Users/alex/dev/projects/igniter/examples/companion/apps/main/app.rb) turns `main` into a `cluster_app` host
- [lib/companion/shared/capability_profile.rb](/Users/alex/dev/projects/igniter/examples/companion/lib/companion/shared/capability_profile.rb) derives effective and mocked capabilities from env
- [lib/companion/shared/stack_overview.rb](/Users/alex/dev/projects/igniter/examples/companion/lib/companion/shared/stack_overview.rb) exposes stack/node/peer state to the UI and status API

## Self-Heal Demo

The dashboard now includes a small `Self-Heal Demo`.

It can trigger:

- a synthetic governance gate
- a synthetic peer repair incident

And then show:

- the published routing report
- plan actions
- the latest repair tick
- governance trail changes after automated remediation

## Validation

```bash
bundle exec rspec examples/companion/spec
bundle exec rspec examples/companion/apps/main/spec
bundle exec rspec examples/companion/apps/dashboard/spec
```
