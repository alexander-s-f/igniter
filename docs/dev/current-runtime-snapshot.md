# Current Runtime Snapshot

This snapshot describes the current public package graph and proof surface.

## Package Graph

- `igniter-contracts`: canonical embedded kernel for contract declaration,
  compilation, execution, diagnostics, and class DSL.
- `igniter-extensions`: optional packs, operational tooling, domain behavior,
  differential/shadow utilities, and MCP-facing tool semantics.
- `igniter-embed`: host integration and registration layer for applications
  that want Igniter contracts inside an existing runtime.
- `igniter-application`: contracts-native local application runtime and
  app-owned environment composition.
- `igniter-web`: mounted web surfaces over explicit application snapshots.
- `igniter-cluster`: distributed planning, routing, and mesh execution layer.
- `igniter-mcp-adapter`: transport-facing adapter for MCP tool catalogs and
  invocation.

## Public Proof

Current proof starts from:

- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)
- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)
- [Igniter Lang Foundation](../guide/igniter-lang-foundation.md)
- [Examples](../../examples/README.md)

The flagship application set is Lense, Chronicle, Scout, and Dispatch.

## Boundaries

- Lang descriptors and metadata manifests are report-only unless a future
  runtime semantics track explicitly accepts enforcement.
- Showcase web surfaces are manual-review/example surfaces, not production
  server behavior.
- Legacy, expert, research, and agent-cycle documents are private working
  material under `playgrounds/docs/`.
- Public package APIs should graduate only from repeated, low-ceremony shapes
  proven across examples.
