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

## Next Likely Steps

1. add a server-facing wrapper that maps `tool_catalog` into real MCP tool definitions
2. expose JSON-schema-like request metadata derived from the existing argument catalog
3. add request/response validation at the adapter boundary
4. only then add transport runtime concerns like sessions, IO, or long-lived server state
