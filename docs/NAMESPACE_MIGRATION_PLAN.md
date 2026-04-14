# Igniter Namespace Migration Plan

## Goal

Reshape `Igniter` into clear logical layers inside the monorepo without preserving backward compatibility or adding shims.

This is a namespace and dependency-boundary migration first, not a gem split.

## Current Status

Completed so far:

- core actor/tool foundation moved under `lib/igniter/core/*`
- AI layer moved under `lib/igniter/ai/*`
- built-in AI agents moved under `Igniter::AI::Agents`
- channels foundation introduced under `lib/igniter/channels/*`
- first built-in transport added as `Igniter::Channels::Webhook`
- remote execution split into `Igniter::Server::RemoteAdapter` and `Igniter::Cluster::RemoteAdapter`
- mesh moved to `Igniter::Cluster::Mesh`
- consensus moved to `Igniter::Cluster::Consensus`
- replication moved to `Igniter::Cluster::Replication`
- legacy `integrations/llm`, `integrations/agents`, top-level `skill`, `tool_registry`, and duplicate `agent/*` files removed

Current public entrypoints:

- `require "igniter"` — contract/model/compiler/runtime core
- `require "igniter/core"` — actor runtime and tool foundation
- `require "igniter/core/<feature>"` — focused core features such as `tool`, `memory`, `temporal`, `metrics`
- `require "igniter/extensions/<feature>"` — behavioral extensions such as `auditing`, `capabilities`, `content_addressing`
- `require "igniter/ai"` — AI providers, executors, skills, transcription
- `require "igniter/channels"` — transport-neutral communication adapters
- `require "igniter/server"` — HTTP/service hosting
- `require "igniter/cluster"` — distributed runtime
- `require "igniter/app"` — opinionated application profile
- `require "igniter/rails"` — Rails plugin entrypoint

## Root Vs Layered Layout

Target filesystem rule:

- `lib/igniter/` keeps only top-level layer entrypoints.
- `lib/igniter/core/` holds the substantive core implementation.
- `lib/igniter/extensions/` holds behavioral extension entrypoints.
- `lib/igniter/ai/`, `server/`, `cluster/`, `channels/`, `app/` hold their own authoritative code.
- `lib/igniter/plugins/` is the intended home for framework-specific integrations such as Rails.
- Rails plugin relocation completed under `lib/igniter/plugins/rails/*`, with `lib/igniter/rails.rb` as the short public entrypoint.

Keep in `lib/igniter/`:

- `igniter.rb`
- layer entrypoints like `core.rb`, `ai.rb`, `channels.rb`, `server.rb`, `cluster.rb`, `application.rb`, `plugins.rb`, `rails.rb`, `agents.rb`
- nested public entrypoint folders such as `core/`, `extensions/`, and `rails/`

Completed implementation relocation into `lib/igniter/core/`:

- `compiler/`
- `model/`
- `runtime/`
- `dsl/`
- `events/`
- `diagnostics/`
- `metrics/`
- `saga/`
- `provenance/`
- `property_testing/`
- `incremental/`
- `dataflow/`
- `execution_report/`
- `memory/`
- `differential/`
- authoritative `extensions/{auditing,reactive,introspection}` support code
- core primitives and feature implementations previously left at the root

Target stack:

```text
Igniter                  # core
Igniter::AI             # AI and model-driven execution
Igniter::Server         # HTTP/service hosting
Igniter::Cluster        # distributed runtime
Igniter::Application    # opinionated app profile over Server
Igniter::Channels       # communication adapters (Telegram, WhatsApp, email, webhook, etc.)
```

## Rules

### Layer rules

- `Igniter` is the core API surface.
- `Igniter::AI` may depend on `Igniter`.
- `Igniter::Server` may depend on `Igniter` and `Igniter::AI`.
- `Igniter::Cluster` may depend on `Igniter`, `Igniter::AI`, and `Igniter::Server`.
- `Igniter::Application` may depend on `Igniter::Server` and optional upper layers.
- `Igniter::Channels` may depend on `Igniter` and be used by `Igniter::AI` or `Igniter::Application`.

### Design rules

- Embedded Rails usage must remain possible without loading server or cluster concerns.
- `Tool` is a core abstraction.
- `Skill` is an AI abstraction, not a core abstraction.
- Communication transports are not AI features; they live in `Channels`.
- `Application` is a packaging/profile layer, not a capability layer between `core` and `server`.

## Target Responsibilities

| Namespace | Responsibility |
|----------|----------------|
| `Igniter` | contract DSL, model, compiler, runtime, events, diagnostics, capabilities, caches, effects, core actor runtime |
| `Igniter::AI` | LLM providers, LLM executors, skills, transcription, AI discovery/registry |
| `Igniter::Server` | HTTP server, Rack app, API handlers, client, remote execution transport |
| `Igniter::Cluster` | consensus, mesh, replication, cluster routing |
| `Igniter::Application` | app config, autoloading, scheduler, generators, app bootstrap |
| `Igniter::Channels` | Telegram, WhatsApp, email, webhook, SMS, call-center, notification transports |

## Important Architecture Decisions

### Keep in core

- `Igniter::Agent`
- `Igniter::Supervisor`
- `Igniter::Registry`
- `Igniter::StreamLoop`
- `Igniter::Tool`
- core DSL/model/compiler/runtime

### Move to AI

- `Igniter::AI`
- `Igniter::AI::Executor`
- `Igniter::AI::Skill`
- `Igniter::AI::ToolRegistry`
- transcription providers and result objects
- AI-oriented built-in agents

### Keep Application above Server

`Igniter::Application` currently requires `igniter/server` and uses a server-backed host
adapter by default. It should stay a profile/framework over hosting, not a sibling
capability layer.

### Future communication adapters

Future Telegram / WhatsApp / email / webhook / SMS features should live under:

```text
Igniter::Channels::Telegram
Igniter::Channels::WhatsApp
Igniter::Channels::Email
Igniter::Channels::Webhook
Igniter::Channels::SMS
```

AI tools and skills may call these adapters, but the adapters themselves should not live in `Igniter::AI`.

## Migration Phases

## Phase 1: Establish the logical map

Create target directories and move obvious code without changing behavior:

- `lib/igniter/core/`
- `lib/igniter/ai/`
- `lib/igniter/server/`
- `lib/igniter/cluster/`
- `lib/igniter/app/`
- `lib/igniter/channels/`

This phase is mostly physical reorganization plus namespace cleanup.

## Phase 2: Move core actor and tool foundation

These files are structurally core and should move first.

| Current path | Target path | Target namespace |
|-------------|-------------|------------------|
| `lib/igniter/agent.rb` | `lib/igniter/core/agent.rb` | `Igniter::Agent` |
| `lib/igniter/agent/message.rb` | `lib/igniter/core/agent/message.rb` | `Igniter::Agent::Message` |
| `lib/igniter/agent/mailbox.rb` | `lib/igniter/core/agent/mailbox.rb` | `Igniter::Agent::Mailbox` |
| `lib/igniter/agent/state_holder.rb` | `lib/igniter/core/agent/state_holder.rb` | `Igniter::Agent::StateHolder` |
| `lib/igniter/agent/runner.rb` | `lib/igniter/core/agent/runner.rb` | `Igniter::Agent::Runner` |
| `lib/igniter/agent/ref.rb` | `lib/igniter/core/agent/ref.rb` | `Igniter::Agent::Ref` |
| `lib/igniter/supervisor.rb` | `lib/igniter/core/supervisor.rb` | `Igniter::Supervisor` |
| `lib/igniter/registry.rb` | `lib/igniter/core/registry.rb` | `Igniter::Registry` |
| `lib/igniter/stream_loop.rb` | `lib/igniter/core/stream_loop.rb` | `Igniter::StreamLoop` |
| `lib/igniter/tool.rb` | `lib/igniter/core/tool.rb` | `Igniter::Tool` |
| `lib/igniter/tool/discoverable.rb` | `lib/igniter/core/tool/discoverable.rb` | `Igniter::Tool::Discoverable` |

Notes:

- Public constants stay the same.
- Directory layout changes first; namespace churn should be minimized during this step.
- `lib/igniter/integrations/agents.rb` should stop feeling like an integration and become a core entry point.

Recommended target:

| Current path | Target path | Target namespace |
|-------------|-------------|------------------|
| `lib/igniter/integrations/agents.rb` | `lib/igniter/core/agents.rb` | core entrypoint |

## Phase 3: Extract AI into its own area

These files should move together because they are tightly coupled.

| Current path | Target path | Target namespace |
|-------------|-------------|------------------|
| `lib/igniter/integrations/llm.rb` | `lib/igniter/ai.rb` | `Igniter::AI` entrypoint |
| `lib/igniter/integrations/llm/config.rb` | `lib/igniter/ai/config.rb` | `Igniter::AI::Config` |
| `lib/igniter/integrations/llm/context.rb` | `lib/igniter/ai/context.rb` | `Igniter::AI::Context` |
| `lib/igniter/integrations/llm/executor.rb` | `lib/igniter/ai/executor.rb` | `Igniter::AI::Executor` |
| `lib/igniter/integrations/llm/providers/base.rb` | `lib/igniter/ai/providers/base.rb` | `Igniter::AI::Providers::Base` |
| `lib/igniter/integrations/llm/providers/openai.rb` | `lib/igniter/ai/providers/openai.rb` | `Igniter::AI::Providers::OpenAI` |
| `lib/igniter/integrations/llm/providers/anthropic.rb` | `lib/igniter/ai/providers/anthropic.rb` | `Igniter::AI::Providers::Anthropic` |
| `lib/igniter/integrations/llm/providers/ollama.rb` | `lib/igniter/ai/providers/ollama.rb` | `Igniter::AI::Providers::Ollama` |
| `lib/igniter/integrations/llm/transcription/transcriber.rb` | `lib/igniter/ai/transcription/transcriber.rb` | `Igniter::AI::Transcription::Transcriber` |
| `lib/igniter/integrations/llm/transcription/transcript_result.rb` | `lib/igniter/ai/transcription/transcript_result.rb` | `Igniter::AI::Transcription::TranscriptResult` |
| `lib/igniter/integrations/llm/transcription/providers/base.rb` | `lib/igniter/ai/transcription/providers/base.rb` | `Igniter::AI::Transcription::Providers::Base` |
| `lib/igniter/integrations/llm/transcription/providers/openai.rb` | `lib/igniter/ai/transcription/providers/openai.rb` | `Igniter::AI::Transcription::Providers::OpenAI` |
| `lib/igniter/integrations/llm/transcription/providers/deepgram.rb` | `lib/igniter/ai/transcription/providers/deepgram.rb` | `Igniter::AI::Transcription::Providers::Deepgram` |
| `lib/igniter/integrations/llm/transcription/providers/assemblyai.rb` | `lib/igniter/ai/transcription/providers/assemblyai.rb` | `Igniter::AI::Transcription::Providers::AssemblyAI` |
| `lib/igniter/skill.rb` | `lib/igniter/ai/skill.rb` | `Igniter::AI::Skill` |
| `lib/igniter/skill/output_schema.rb` | `lib/igniter/ai/skill/output_schema.rb` | `Igniter::AI::Skill::OutputSchema` |
| `lib/igniter/skill/feedback.rb` | `lib/igniter/ai/skill/feedback.rb` | `Igniter::AI::Skill::*` |
| `lib/igniter/tool_registry.rb` | `lib/igniter/ai/tool_registry.rb` | `Igniter::AI::ToolRegistry` |

Recommended constant shape after migration:

- `Igniter::AI`
- `Igniter::AI::Executor`
- `Igniter::AI::Skill`
- `Igniter::AI::ToolRegistry`

Optional alias layer can be added only temporarily during the cut-over if needed internally, but is not required by plan.

## Phase 4: Separate built-in agent libraries

The current `lib/igniter/agents.rb` mixes core actor runtime with domain libraries and AI-specific agents.

Split it into:

| Current path | Target path | Target namespace |
|-------------|-------------|------------------|
| `lib/igniter/agents.rb` | `lib/igniter/agents.rb` | generic built-in agents entrypoint |
| `lib/igniter/ai/agents.rb` | `lib/igniter/ai/agents.rb` | AI/built-in AI agents entrypoint |
| `lib/igniter/agents/ai/*` | `lib/igniter/ai/agents/*` | `Igniter::AI::Agents::*` |
| `lib/igniter/agents/proactive/alert_agent.rb` | `lib/igniter/agents/proactive/alert_agent.rb` | `Igniter::Agents::AlertAgent` |
| `lib/igniter/agents/proactive/health_check_agent.rb` | `lib/igniter/agents/proactive/health_check_agent.rb` | `Igniter::Agents::HealthCheckAgent` |
| `lib/igniter/agents/proactive_agent.rb` | `lib/igniter/agents/proactive_agent.rb` | `Igniter::Agents::ProactiveAgent` |
| `lib/igniter/agents/observability/*` | `lib/igniter/agents/observability/*` or `lib/igniter/app/agents/observability/*` | depends on coupling |
| `lib/igniter/agents/reliability/*` | `lib/igniter/core/agents/reliability/*` if fully generic, otherwise `app` |
| `lib/igniter/agents/pipeline/*` | `lib/igniter/core/agents/pipeline/*` if fully generic, otherwise `app` |
| `lib/igniter/agents/scheduling/*` | `lib/igniter/app/agents/scheduling/*` | scheduling is app-profile behavior |

Decision rule:

- If an agent is generic mailbox/state/thread logic, it may live near core.
- If an agent assumes LLMs or AI workflows, keep it under `Igniter::AI::Agents`.
- If an agent is proactive/monitoring behavior without AI coupling, keep it under `Igniter::Agents`.

## Phase 5: Keep Application as a profile over Server

Application-related files should stay grouped and remain above server concerns.

| Current path | Target path | Target namespace |
|-------------|-------------|------------------|
| `lib/igniter/app.rb` | `lib/igniter/app.rb` | `Igniter::Application` |
| `lib/igniter/app/app_config.rb` | `lib/igniter/app/app_config.rb` | `Igniter::Application::AppConfig` |
| `lib/igniter/app/autoloader.rb` | `lib/igniter/app/autoloader.rb` | `Igniter::Application::Autoloader` |
| `lib/igniter/app/scheduler.rb` | `lib/igniter/app/scheduler.rb` | `Igniter::Application::Scheduler` |
| `lib/igniter/app/yml_loader.rb` | `lib/igniter/app/yml_loader.rb` | `Igniter::Application::YmlLoader` |
| `lib/igniter/app/generator.rb` | `lib/igniter/app/generator.rb` | `Igniter::Application::Generator` |

No need to invent `Igniter::Server::Application` unless the codebase later proves it cleaner.

## Phase 6: Introduce Channels

Channels are future-facing but the directory should exist early to keep the design honest.

Suggested initial structure:

```text
lib/igniter/channels.rb
lib/igniter/channels/base.rb
lib/igniter/channels/message.rb
lib/igniter/channels/delivery_result.rb
lib/igniter/channels/telegram/*
lib/igniter/channels/whatsapp/*
lib/igniter/channels/email/*
lib/igniter/channels/webhook/*
```

Suggested abstraction:

- `Channels::Base` for sending messages or events
- `Channels::Message` as normalized outbound payload
- `Channels::DeliveryResult` as normalized response

This lets:

- tools call channels directly,
- skills orchestrate channels,
- Rails/webhook integrations adapt inbound transport into contracts,
- server/app layers wire credentials and delivery policies.

## Phase 7: Cluster namespace cleanup

Cluster code already has a clear identity but should be grouped under `Igniter::Cluster`.

| Current path | Target path | Target namespace |
|-------------|-------------|------------------|
| `lib/igniter/consensus.rb` | `lib/igniter/cluster.rb` | `Igniter::Cluster` entrypoint |
| `lib/igniter/consensus/*` | `lib/igniter/cluster/consensus/*` | `Igniter::Cluster::Consensus::*` |
| `lib/igniter/mesh.rb` | `lib/igniter/cluster/mesh.rb` or `lib/igniter/cluster.rb` require tree | `Igniter::Cluster::Mesh` |
| `lib/igniter/mesh/*` | `lib/igniter/cluster/mesh/*` | `Igniter::Cluster::Mesh::*` |
| `lib/igniter/replication.rb` | `lib/igniter/cluster/replication.rb` | `Igniter::Cluster::Replication` |
| `lib/igniter/replication/*` | `lib/igniter/cluster/replication/*` | `Igniter::Cluster::Replication::*` |

Recommended public shape:

- `Igniter::Cluster::Consensus`
- `Igniter::Cluster::Mesh`
- `Igniter::Cluster::Replication`

## Phase 8: Fix the main architectural leak

This is the most important functional refactor.

Current problem:

- `remote` is declared in core DSL/model.
- `Runtime::Resolver` directly knows about `Igniter::Server::Client` and `Igniter::Cluster::Mesh`.

That means core currently knows about upper layers.

Files involved:

| Current path | Problem |
|-------------|---------|
| `lib/igniter/dsl/contract_builder.rb` | defines `remote` in the core DSL |
| `lib/igniter/model/remote_node.rb` | bakes remote transport into the core model |
| `lib/igniter/runtime/resolver.rb` | directly instantiates `Igniter::Server::Client` and calls `Igniter::Cluster::Mesh` |

Recommended direction:

1. Introduce a transport abstraction in core.
2. Let server provide the HTTP implementation.
3. Let cluster provide capability/pinned peer resolution.
4. Keep the core runtime calling only the abstraction.

Current status:

- Implemented: `Igniter::Runtime::RemoteAdapter`
- Implemented: `Igniter::Runtime.remote_adapter`
- Implemented: `Igniter::Server::RemoteAdapter` handles static HTTP transport
- Implemented: `Igniter::Cluster::RemoteAdapter` handles capability/pinned routing
- Implemented: `Runtime::Resolver` no longer directly references `Igniter::Server::Client` or `Igniter::Cluster::Mesh`

This gives us the seam we need for cluster-aware routing without reopening core runtime.

## Recommended First Real Cut

The first implementation pass should do only this:

1. Move actor runtime files into the core area.
2. Move `Tool` into the core area.
3. Create `Igniter::AI` and move LLM + skill + tool registry there.
4. Leave server, application, and cluster behavior unchanged for the moment.
5. Do not tackle `remote` abstraction until the namespace moves are complete.

This gives a clean early win without mixing structural reorg and hard runtime refactors in the same commit.

## Docs to update after each phase

- `README.md`
- `docs/ARCHITECTURE_V2.md`
- `docs/DEPLOYMENT_V1.md`
- `docs/APPLICATION_V1.md`
- `docs/SERVER_V1.md`
- `docs/LLM_V1.md`
- `docs/SKILLS_V1.md`
- `docs/TOOLS_V1.md`
- `docs/TRANSCRIPTION_V1.md`
- any examples requiring updated entry points

## Success Criteria

- A reader can tell from path and namespace which layer owns a file.
- Embedded Rails users can load core plus AI without loading server or cluster.
- Future Telegram/WhatsApp adapters have a clear home in `Igniter::Channels`.
- `Application` remains a profile over `Server`.
- Core no longer directly references `Server::Client` or `Mesh`.
