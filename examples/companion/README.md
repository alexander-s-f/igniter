# Companion — Cluster Next Sandbox

`examples/companion` is now the fresh proving ground for `Stack/App vNext` and
`Igniter::Cluster Next`.

It is intentionally small and plastic:

- `apps/` stay code boundaries
- `services:` act as local node instances
- each node advertises a capability envelope
- some capabilities can be mocked to simulate future hardware or software
- the same stack can run several local nodes with one `bin/dev`

The previous richer voice-assistant workspace now lives in
[`examples/companion_legacy`](/Users/alex/dev/projects/igniter/examples/companion_legacy/README.md).

## Local Mesh

The default topology boots three local nodes:

| Service | Port | Intent | Effective capability shape |
|---|---:|---|---|
| `seed` | `4667` | bootstrap / routing node | `notes_api`, `mesh_seed`, `routing`, mocked `notifications` |
| `edge` | `4668` | edge / audio-facing node | `notes_api`, `speech_io`, mocked `whisper_asr`, `piper_tts` |
| `analyst` | `4669` | reasoning / knowledge node | `notes_api`, `assistant_orchestration`, mocked `local_llm`, `rag` |

Each service hosts:

- `apps/main` on `/`
- `apps/dashboard` on `/dashboard`

So one service equals one local node instance, not one app.

## Boot

From the repository root:

```bash
cd examples/companion
bundle install
bin/dev
```

Then open:

- seed status: [http://127.0.0.1:4667/v1/home/status](http://127.0.0.1:4667/v1/home/status)
- edge status: [http://127.0.0.1:4668/v1/home/status](http://127.0.0.1:4668/v1/home/status)
- analyst status: [http://127.0.0.1:4669/v1/home/status](http://127.0.0.1:4669/v1/home/status)
- dashboards:
  `http://127.0.0.1:4667/dashboard`,
  `http://127.0.0.1:4668/dashboard`,
  `http://127.0.0.1:4669/dashboard`

To run one node explicitly:

```bash
PORT=4668 \
IGNITER_SERVICE=edge \
COMPANION_NODE_NAME=companion-edge \
COMPANION_NODE_ROLE=edge \
COMPANION_NODE_URL=http://127.0.0.1:4668 \
COMPANION_LOCAL_CAPABILITIES=notes_api,speech_io \
COMPANION_MOCK_CAPABILITIES=whisper_asr,piper_tts \
COMPANION_SEEDS=http://127.0.0.1:4667 \
COMPANION_START_DISCOVERY=true \
bin/start --service edge
```

## Selective Capability Mocking

Capability envelopes are driven by environment variables in
[config/topology.yml](/Users/alex/dev/projects/igniter/examples/companion/config/topology.yml).

The key knobs are:

- `COMPANION_LOCAL_CAPABILITIES`
- `COMPANION_MOCK_CAPABILITIES`
- `COMPANION_NODE_TAGS`
- `COMPANION_SEEDS`
- `COMPANION_START_DISCOVERY`

This means you can simulate a node gaining or losing powers without changing app
code. For example:

```bash
COMPANION_MOCK_CAPABILITIES=local_llm,rag,vector_store bin/start --service analyst
```

That is exactly the bridge toward capability-first cluster routing.

## What To Look At

- [config/topology.yml](/Users/alex/dev/projects/igniter/examples/companion/config/topology.yml) defines the local mesh
- [apps/main/app.rb](/Users/alex/dev/projects/igniter/examples/companion/apps/main/app.rb) turns `main` into a `cluster_app` host
- [lib/companion/shared/capability_profile.rb](/Users/alex/dev/projects/igniter/examples/companion/lib/companion/shared/capability_profile.rb) derives effective and mocked capabilities from env
- [lib/companion/shared/stack_overview.rb](/Users/alex/dev/projects/igniter/examples/companion/lib/companion/shared/stack_overview.rb) exposes node + service + peer state to the UI and status API

## Validation

```bash
bundle exec rspec examples/companion/spec
bundle exec rspec examples/companion/apps/main/spec
bundle exec rspec examples/companion/apps/dashboard/spec
```
