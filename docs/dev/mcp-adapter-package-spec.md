# MCP Adapter Package

## Purpose

`igniter-mcp-adapter` is the transport-facing package that sits on top of the
tooling semantics already defined in `igniter-extensions`.

Its job is not to invent new tools. Its job is to adapt the existing catalog
and invocation surface into a package that can host:

- a real MCP server
- CLI wrappers
- editor integrations
- agent-facing bridges

## Source Of Truth

The semantic source of truth stays in `igniter-extensions`:

- `Igniter::Extensions::Contracts.mcp_tools`
- `Igniter::Extensions::Contracts.mcp_call(...)`
- `Igniter::Extensions::Contracts.mcp_creator_session(...)`

The adapter package should treat those as authoritative.

## Why A Separate Package

This split gives us scalability by default:

- `igniter-extensions` owns debug/creator/tooling semantics
- `igniter-mcp-adapter` owns transport/runtime integration concerns
- future adapters can reuse the same semantic surface without duplicating logic

That means we can add more than one adapter later:

- MCP server adapter
- CLI adapter
- IDE adapter
- web/dev console adapter

## Package Boundary

`igniter-mcp-adapter`:

- depends on `igniter-extensions`
- should not depend directly on `igniter-contracts` internals
- should not define new creator/debug semantics
- should not become a second tool catalog source

## Minimal Public Surface

Near-term public surface:

- `Igniter::MCP::Adapter.tool_catalog`
- `Igniter::MCP::Adapter.tool_names`
- `Igniter::MCP::Adapter.tool_definition(name)`
- `Igniter::MCP::Adapter.invoke(name, ...)`
- `Igniter::MCP::Adapter.creator_session(...)`

This is intentionally thin. It keeps the adapter package honest.

## Current State

This is already real in the monorepo:

- `Igniter::MCP::Adapter`
  thin delegation over the semantic tooling surface
- `Igniter::MCP::Adapter::Server`
  transport-ready tool definitions and tool result envelopes
- `Igniter::MCP::Adapter::Host`
  stdio JSON-RPC host over the server wrapper

So this package is no longer only a design placeholder.

## Next Likely Steps

1. decide whether we want additional MCP surfaces like `resources/list` or
   `prompts/list`, or whether tools-only is the right first stable contract
2. keep request validation aligned with generated schemas
3. only add transport/runtime concerns that do not create a second semantic source
4. use this package as the only place where MCP transport specifics evolve
