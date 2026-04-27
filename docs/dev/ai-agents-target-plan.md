# AI And Agents Target Plan

This track moves live AI and agent behavior out of application examples and
back into package-owned Igniter surfaces.

Status: accepted direction, not stable API.

## Motivation

Applications should configure AI and agents; they should not invent provider
clients, agent loops, tool policy, memory, or replay seams locally.

The Companion application is the current proof pressure: it needs live LLM
value, credentials, stored user state, and future assistant capsules, but those
capabilities must become reusable package primitives before they harden inside
one app.

## Package Ownership

### `igniter-ai`

Owns provider-neutral AI execution:

- provider clients and model request/response envelopes
- credentials-aware client configuration
- live, fake, and recorded execution modes
- prompt/message/transcript value objects
- usage, errors, provider metadata, and response normalization
- evaluation and replay seams for examples and tests

Does not own:

- long-running agent loops
- application routing or boot lifecycle
- web rendering
- MCP transport

First provider target: OpenAI Responses API, wrapped behind an Igniter request
envelope so examples do not call provider-specific clients directly.

### `igniter-agents`

Owns agent runtime semantics over contracts and AI:

- agent definitions, runs, turns, traces, and lifecycle state
- tool catalogs, tool calls, and tool policy
- memory/context interfaces
- planning and handoff envelopes
- human gates, approvals, and resumable waits
- supervisor and worker coordination vocabulary

Does not own:

- provider-specific HTTP clients
- Rails/Rack/web rendering
- distributed mesh placement
- application-specific assistant features

`igniter-agents` depends conceptually on `igniter-ai` for model execution and
on contracts for typed tools/results. It should stay usable without web.

## Boundary Rules

- `igniter-application` wires credentials, store choices, boot lifecycle, and
  app-local configuration into AI/agent packages.
- `igniter-web` renders chat, approval, stream, and review surfaces from
  application snapshots; it does not run agent logic.
- `igniter-mcp-adapter` exposes existing tool catalogs over transport; it does
  not become the agent runtime.
- `igniter-extensions` may provide tool packs and diagnostics over contracts,
  but not provider-specific AI execution.
- Example apps may demonstrate capabilities, but app-local AI code is treated
  as temporary until the corresponding package primitive exists.

## Human DSL Shape

The package APIs should support two equal forms:

- agent-facing explicit objects for tests, tooling, replay, and generated code
- human-facing sugar DSL for compact application configuration

Target application shape:

```ruby
Igniter::Application.define(:companion) do
  credential :openai_api_key, env: "OPENAI_API_KEY"

  ai do
    provider :openai, credential: :openai_api_key, model: "gpt-5.2"
    mode ENV["COMPANION_LIVE"] == "1" ? :live : :fake
  end

  agents do
    assistant :daily_companion do
      use_model :openai
      use_tools :reminders, :trackers, :countdowns
      memory :sqlite, namespace: :companion
      human_gate :approval, for: :destructive_actions
    end
  end
end
```

This is illustrative, not accepted API.

## First Implementation Slice

Status: package skeleton and application-level AI provider DSL landed; agent
runtime is still next.

1. Create `packages/igniter-ai` with zero production dependencies.
2. Move the Companion OpenAI Responses behavior behind
   `Igniter::AI::Providers::OpenAIResponses`.
3. Add fake and recorded providers so examples stay offline by default.
4. Add request/response envelopes with normalized `text`, `usage`, `metadata`,
   and `error`.
5. Let `igniter-application` configure AI providers through credentials without
   provider-specific code in the app.
6. Keep Companion as the reference consumer and remove its local provider once
   the package slice is green.

Acceptance:

- no network calls in default specs or example smoke
- live mode requires explicit environment opt-in
- provider errors return structured failure envelopes
- credentials remain redacted in profiles and manifests
- Companion still runs in fake/offline mode and can opt into live mode

## Second Implementation Slice

1. Create `packages/igniter-agents` around minimal agent run state.
2. Treat tools as contracts-first callables.
3. Add a single-turn assistant runner over `igniter-ai`.
4. Add trace envelopes that can be rendered by application/web surfaces.
5. Add human gate state without requiring a web package.

Acceptance:

- agent runs are serializable and replayable
- tool calls expose typed inputs/results
- web can render run state without owning runtime logic
- applications can run a simple assistant without custom loop code

## Legacy Filter

Legacy package layout is useful as vocabulary, not as code to restore blindly.

Accepted concepts:

- separate AI and agent packages
- provider abstraction
- tool registry
- skill/runtime-contract idea
- registry-backed agent adapter

Rejected for now:

- broad SDK umbrella
- server-first agent sessions
- package surfaces that require distributed runtime
- provider APIs leaking into application examples
