# Examples

These scripts are the runnable showcase for Igniter's core APIs, runtime flows,
and package boundaries.

## Runner

From the project root:

```bash
ruby examples/run.rb list
ruby examples/run.rb smoke
ruby examples/run.rb all
ruby examples/run.rb run basic_pricing
```

`smoke` runs the self-contained examples we keep green in CI. `all` prints the
same pass/fail report but also shows manual or not-yet-updated examples as
skipped with a reason.

There is also a matching rake task:

```bash
rake examples
```

For higher-level guidance on when to use each orchestration style, see
[patterns](../docs/concepts/patterns.md).

## Smoke Examples

- `agents.rb` — supervision, registry lookups, and stream loops.
- `async_store.rb` — deferred execution with store-backed resume.
- `basic_pricing.rb` — smallest end-to-end contract example.
- `collection.rb` — `collection` fan-out and `CollectionResult`.
- `collection_partial_failure.rb` — partial-failure collection diagnostics.
- `composition.rb` — nested contracts via `compose`.
- `consensus.rb` — consensus-style vendor bid selection.
- `dataflow.rb` — incremental collections and maintained aggregates.
- `diagnostics.rb` — text diagnostics and `as_json` output.
- `differential.rb` — differential execution against a shadow path.
- `distributed_server.rb` — `await` / `deliver_event` lifecycle with a store.
- `distributed_workflow.rb` — correlated external events merged into one report.
- `effects.rb` — effect nodes, effect registry, and saga compensation.
- `incremental.rb` — incremental recomputation and memoization.
- `invariants.rb` — invariants plus property-based testing.
- `llm/research_agent.rb` — LLM planning + awaited tool results with mock fallback.
- `llm/tool_use.rb` — offline tool-use pipeline with a mock provider.
- `llm_tools.rb` — tool schemas, capability checks, and tool registry.
- `marketing_ergonomics.rb` — ergonomic DSL helpers on a compact graph.
- `mesh.rb` — static mesh routing behaviour.
- `mesh_gossip.rb` — peer convergence through gossip.
- `order_pipeline.rb` — guard + collection + branch + export.
- `provenance.rb` — provenance and output traceability.
- `ringcentral_routing.rb` — webhook routing with nested collections.
- `saga.rb` — saga rollback walkthrough.

## Manual Examples

- `llm/call_center_analysis.rb` — requires an `audio_url` argument.

Run it like this:

```bash
ruby examples/run.rb run llm/call_center_analysis https://example.com/audio.mp3
```

## Pending Refresh

- `mesh_discovery.rb` — the script documents the dynamic discovery flow, but it
  still needs a refresh for the current mesh router API before it can rejoin
  the smoke suite.
- `server/node1.rb`
- `server/node2.rb`
  These are long-lived multi-terminal server demos and still use the older
  entrypoint layout, so they are intentionally not part of the automated runner.
- `elocal_webhook.rb` — placeholder stub, no executable walkthrough yet.

## Validation

The catalog lives in [catalog.rb](/Users/alex/dev/projects/igniter/examples/catalog.rb).
Both [run.rb](/Users/alex/dev/projects/igniter/examples/run.rb) and the specs
[example_scripts_spec.rb](/Users/alex/dev/projects/igniter/spec/igniter/example_scripts_spec.rb)
and [example_runner_spec.rb](/Users/alex/dev/projects/igniter/spec/igniter/example_runner_spec.rb)
use that same source of truth.
