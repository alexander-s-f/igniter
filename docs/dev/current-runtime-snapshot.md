# Current Runtime Snapshot

This snapshot describes the current public package graph and proof surface.

## Package Graph

- `igniter-contracts`: canonical embedded kernel for contract declaration,
  compilation, execution, diagnostics, class DSL, and the core Contractable
  service protocol.
- `igniter-extensions`: optional packs, operational tooling, domain behavior,
  language packs such as observable piecewise decisions, numeric scaling, and
  formulas, differential/shadow utilities, and MCP-facing tool semantics.
- `igniter-embed`: host integration and registration layer for applications
  that want Igniter contracts inside an existing runtime, including
  migration/shadow wrappers over the core Contractable idea.
- `igniter-application`: contracts-native local application runtime,
  app-owned environment composition, transfer receipts, and installed-capsule
  registries.
- `igniter-ai`: provider-neutral AI execution, request/response envelopes,
  fake/live/recorded provider modes, and response normalization.
- `igniter-agents`: minimal agent definitions, runs, turns, traces, tool-call
  evidence, single-turn assistant execution over `igniter-ai`, and
  application-level agent DSL wiring.
- `igniter-hub`: local capsule catalog discovery, transfer bundle metadata,
  and app-facing install candidate summaries.
- `igniter-web`: mounted web surfaces over explicit application snapshots.
- `igniter-cluster`: distributed planning, routing, and mesh execution layer.
- `igniter-mcp-adapter`: transport-facing adapter for MCP tool catalogs and
  invocation.
- `igniter-store`: experimental contract-native hot fact engine with immutable
  facts, time-travel reads, causation, access paths, reactive invalidation,
  retention/compaction, StoreServer transport, and package-local docs/specs.
- `igniter-companion`: experimental typed Record/History facade over
  `igniter-store`, used to converge Companion app-local persistence manifests
  with package-level Store/History facts without making persistence a core API.

Planned rebuilds:

- richer agent memory/context, handoff, human-gate, and contracts-first tool
  execution semantics.
- relation auto-wiring from app-local relation manifests into store-side
  RelationRule remains active pressure, not accepted core semantics.

## Public Proof

Current proof starts from:

- [Application Showcase Portfolio](../guide/application-showcase-portfolio.md)
- [Igniter Lang Foundation](../guide/igniter-lang-foundation.md)
- [Examples](../../examples/README.md)

The flagship application set is Lense, Chronicle, Scout, Dispatch, and
Companion.

## Boundaries

- Lang descriptors and metadata manifests are report-only unless a future
  runtime semantics track explicitly accepts enforcement.
- Showcase web surfaces are manual-review/example surfaces, not production
  server behavior.
- Legacy, expert, research, and agent-cycle documents are private working
  material under `playgrounds/docs/`.
- Public package APIs should graduate only from repeated, low-ceremony shapes
  proven across examples.
- `igniter-store` and `igniter-companion` are package-level pressure surfaces,
  not umbrella/core guarantees. The Store server hosts durable facts and
  projections; contract computation stays in the app.
- Capsule transfer is now agent-aware at the declaration/evidence layer:
  agents can be carried as capabilities, but transfer does not execute agents.
- `igniter-hub` is local-only in the first slice. Companion can display and
  install a local hub capsule through transfer, then record installed state via
  the `igniter-application` registry, but there is no remote download,
  signature, or trust policy yet.
