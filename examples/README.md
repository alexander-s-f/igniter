# Examples

These scripts are the runnable showcase for Igniter's core APIs, runtime flows,
and package boundaries.

For a higher-level public stack consumer, see
[examples/companion](/Users/alex/dev/projects/igniter/examples/companion/README.md).
`examples/` keeps both:

- small runnable scripts for focused API/runtime slices
- larger public proving grounds like `companion`

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
- `agent_orchestration.rb` — current `agent` node orchestration, deferred replies, and provenance.
- `async_store.rb` — deferred execution with store-backed resume.
- `basic_pricing.rb` — smallest end-to-end contract example.
- `contracts/basic_pricing.rb` — new-world `igniter-contracts` counterpart to the classic pricing example.
- `collection.rb` — `collection` fan-out and `CollectionResult`.
- `collection_partial_failure.rb` — partial-failure collection diagnostics.
- `composition.rb` — nested contracts via `compose`.
- `contracts/aggregates.rb` — external `lookup` + `aggregate` packs composed together.
- `contracts/build_effect_executor_pack.rb` — inline effect/executor pack authoring over the public contracts API.
- `contracts/build_your_own_pack.rb` — inline pack authoring over the public contracts API.
- `contracts/compose_your_own_packs.rb` — inline pack composition where one custom pack depends on another.
- `contracts/commerce.rb` — applied `igniter-contracts` commerce preset with public external packs.
- `contracts/dataflow.rb` — new-world dataflow session counterpart over `DataflowPack` + `IncrementalPack`.
- `contracts/diagnostics.rb` — new-world diagnostics report counterpart to the legacy diagnostics example.
- `contracts/effects.rb` — new-world effect/executor counterpart to the legacy effects example.
- `contracts/execution_report_migration.rb` — side-by-side migration from the legacy `execution_report` activator to `ExecutionReportPack`.
- `contracts/incremental.rb` — new-world incremental session counterpart over `IncrementalPack`.
- `contracts/introspection.rb` — new-world structured introspection counterpart to the legacy introspection example.
- `contracts/journal.rb` — external effect/executor pack as a runnable operational demo.
- `contracts/migration.rb` — side-by-side legacy `igniter-core` reference vs `igniter-contracts` target.
- `contracts/provenance.rb` — new-world lineage and provenance counterpart to the legacy provenance example.
- `contracts/saga.rb` — new-world saga counterpart with explicit compensation registry over `SagaPack`.
- `contracts/three_layer_migration.rb` — one use case shown as legacy core, raw contracts, and applied preset.
- `consensus.rb` — consensus-style vendor bid selection.
- `dataflow.rb` — incremental collections and maintained aggregates.
- `diagnostics.rb` — text diagnostics and `as_json` output.
- `differential.rb` — differential execution against a shadow path.
- `distributed_server.rb` — `await` / `deliver_event` lifecycle with a store.
- `distributed_workflow.rb` — correlated external events merged into one report.
- `effects.rb` — effect nodes, effect registry, and saga compensation.
- `incremental.rb` — incremental recomputation and memoization.
- `introspection.rb` — graph text, Mermaid output, plan explanation, and runtime explain output.
- `invariants.rb` — invariants plus property-based testing.
- `llm/research_agent.rb` — LLM planning + awaited tool results with mock fallback.
- `llm/tool_use.rb` — offline tool-use pipeline with a mock provider.
- `llm_tools.rb` — tool schemas, capability checks, and tool registry.
- `marketing_ergonomics.rb` — ergonomic DSL helpers on a compact graph.
- `mesh.rb` — static mesh routing behaviour.
- `mesh_gossip.rb` — peer convergence through gossip.
- `order_pipeline.rb` — guard + collection + branch + export.
- `provenance.rb` — provenance and output traceability.
- `reactive_auditing.rb` — reactive hooks plus audit timeline snapshots.
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

## Contracts Migration Track

The new `examples/contracts/` lane is where the public migration story should
grow:

- show `igniter-core` only as a reference implementation
- show `igniter-contracts` as the target embedded kernel
- show external packs as first-class runnable building blocks
- show how to author a new pack without reaching into internal namespaces
- show both authoring paths: graph semantics packs and operational effect/executor packs
- show how one custom pack can depend on another through the public kernel API
- show the same use case evolving across legacy core, raw contracts, and domain preset layers
- provide new-world counterparts for older root examples as migration waypoints
- provide activator-to-pack migration examples for legacy `igniter/extensions/*` surfaces
- keep richer domain packs runnable and easy to copy into host apps

### Migration Map

| Legacy example | Contracts counterpart | Migration note |
| --- | --- | --- |
| `basic_pricing.rb` | `contracts/basic_pricing.rb` | same smallest pricing flow, but through `Igniter::Contracts.with` |
| `dataflow.rb` | `contracts/dataflow.rb` | moves from legacy incremental collection patching to explicit `DataflowPack` sessions over `IncrementalPack` |
| `diagnostics.rb` | `contracts/diagnostics.rb` | moves from text/as_json diagnostics to typed `DiagnosticsReport` |
| `effects.rb` | `contracts/effects.rb` | moves from legacy effect nodes to explicit effect/executor seams |
| `incremental.rb` | `contracts/incremental.rb` | moves from patched contract mutation to explicit incremental sessions over `CompiledGraph` |
| `introspection.rb` | `contracts/introspection.rb` | moves from text/Mermaid explainers to structured compilation/result/diagnostics reports |
| `provenance.rb` | `contracts/provenance.rb` | moves from legacy contract patching to explicit lineage over `ExecutionResult` + `ProvenancePack` |
| `saga.rb` | `contracts/saga.rb` | moves from global `resolve_saga` patching to explicit `SagaPack` + compensation registry |
| n/a | `contracts/migration.rb` | direct core-vs-contracts side-by-side comparison |
| n/a | `contracts/three_layer_migration.rb` | legacy core vs raw contracts vs preset/domain layer |
| n/a | `contracts/execution_report_migration.rb` | legacy `igniter/extensions/execution_report` activator vs `ExecutionReportPack` |

Use the `contracts/` examples when you want the target embedded-kernel story.
Use the legacy root examples when you need to compare behavior during migration.
