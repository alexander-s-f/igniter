# Module System

Igniter currently has three architectural axes.

## 1. Runtime Layers

This is the hosting/execution pyramid:

```text
core -> server/app -> cluster
```

Current public entrypoints:

- `require "igniter"`
- `require "igniter/core"`
- `require "igniter/server"`
- `require "igniter/app"`
- `require "igniter/stack"`
- `require "igniter/cluster"`

Rules:

- lower layers must not know about upper layers
- upper layers may compose lower layers explicitly
- loading a layer should not silently mutate unrelated runtime state

## 2. SDK Packs

This is the optional capability plane:

```text
igniter/sdk/agents
igniter/sdk/ai
igniter/sdk/channels
igniter/sdk/data
igniter/sdk/tools
```

Rules:

- packs are optional and shared
- top-level optional shortcuts are not public API
- packs may depend downward, never upward
- packs must not become hidden boot mechanisms

## 3. Integrations

This is the environment/framework integration plane:

- `require "igniter/plugins/rails"`
- `require "igniter-frontend"`
- `require "igniter-schema-rendering"`

Rules:

- integrations adapt Igniter to an environment or UI surface
- integrations are not the core runtime pyramid
- integrations are not generic capability packs

## Current Practical Heuristic

Ask these questions in order:

1. Is it fundamental execution machinery?
2. Is it optional and reusable?
3. Is it an environment/framework adapter?

That maps to:

- runtime/core layer
- sdk pack
- integration/package
