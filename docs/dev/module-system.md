# Module System

Igniter's public module map is pre-v1 and package-first.

## Current Axes

- `igniter-contracts`
  embedded graph kernel: DSL, compilation, execution, diagnostics
- `igniter-extensions`
  optional packs over contracts: dataflow, differential, reporting, tooling
- `igniter-embed`
  host integration and configuration, especially Rails-style embedding
- `igniter-application`
  local app profile, providers, services, capsules, transfer, activation review
- `igniter-web`
  contracts-first web surfaces and app-local interactive screens
- `igniter-cluster`
  distributed routing, placement, ownership, health, and remediation
- `igniter-mcp-adapter`
  MCP-facing tool catalog and invocation surface

## Rules

- Lower layers must not know about upper layers.
- Optional behavior should be an explicit pack, not hidden boot mutation.
- Integrations adapt Igniter to a host; they are not runtime layers.
- Web owns rendering; application owns app profile and lifecycle.
- Cluster owns distribution; contracts stay local-first and host-agnostic.

## Rails Boundary

Rails embedding should use `igniter-embed` / Rails integration surfaces. It
should not implicitly load application hosting, web rendering, or cluster
coordination.

## Placement Heuristic

Ask in this order:

1. Is it executable graph semantics? Put it in `igniter-contracts`.
2. Is it optional reusable behavior over contracts? Put it in
   `igniter-extensions`.
3. Is it host integration? Put it in `igniter-embed` or a specific adapter.
4. Is it local app runtime? Put it in `igniter-application`.
5. Is it human/browser interaction? Put it in `igniter-web`.
6. Is it distributed execution or coordination? Put it in `igniter-cluster`.
