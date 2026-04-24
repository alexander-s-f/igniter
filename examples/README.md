# Examples

`examples/` is now the contracts-native runnable surface for Igniter.

Active examples are limited to:

- `igniter-contracts`
- `igniter-extensions`
- `igniter-application`
- `igniter-cluster`
- `igniter-mcp-adapter`

Older legacy-root demos were moved out of the active tree and should not be
treated as current reference material.

## Runner

From the project root:

```bash
ruby examples/run.rb list
ruby examples/run.rb smoke
ruby examples/run.rb all
ruby examples/run.rb run contracts/basic_pricing
```

`smoke` and `all` currently point at the same active catalog: the runnable
contracts-native examples we keep green.

There is also a matching rake task:

```bash
rake examples
```

## Active Example Lane

Active runnable examples live in `examples/application/`, `examples/contracts/`, and `examples/cluster/`:

- `application/blueprint.rb`
- `application/capsule_layout.rb`
- `application/capsule_authoring_dsl.rb`
- `application/capsule_assembly_plan.rb`
- `application/capsule_composition.rb`
- `application/capsule_handoff_manifest.rb`
- `application/capsule_inspection.rb`
- `application/capsule_manifest.rb`
- `application/feature_flow_report.rb`
- `application/flow_session.rb`
- `application/layout.rb`
- `application/mounts.rb`
- `application/structure_plan.rb`
- `cluster/incidents.rb`
- `cluster/incident_workflow.rb`
- `cluster/mesh_diagnostics.rb`
- `cluster/remediation.rb`
- `cluster/routing.rb`

- `contracts/basic_pricing.rb`
- `contracts/class_pricing.rb`
- `contracts/class_callable.rb`
- `contracts/embed_class_registration.rb`
- `contracts/contractable_shadow.rb`
- `contracts/embed_human_sugar.rb`
- `contracts/aggregates.rb`
- `contracts/auditing.rb`
- `contracts/branching.rb`
- `contracts/build_effect_executor_pack.rb`
- `contracts/build_your_own_pack.rb`
- `contracts/capabilities.rb`
- `contracts/collection.rb`
- `contracts/commerce.rb`
- `contracts/composition.rb`
- `contracts/compose_your_own_packs.rb`
- `contracts/content_addressing.rb`
- `contracts/create_pack.rb`
- `contracts/dataflow.rb`
- `contracts/debug.rb`
- `contracts/debug_pack_authoring.rb`
- `contracts/diagnostics.rb`
- `contracts/differential.rb`
- `contracts/effects.rb`
- `contracts/incremental.rb`
- `contracts/introspection.rb`
- `contracts/invariants.rb`
- `contracts/journal.rb`
- `contracts/mcp.rb`
- `contracts/mcp_host.rb`
- `contracts/mcp_server.rb`
- `contracts/provenance.rb`
- `contracts/reactive.rb`
- `contracts/saga.rb`

These are the examples the runner and the current root specs validate.

## Archive Note

Legacy-root demos and migration scripts were moved out of the active example
lane. We are not treating them as the current framework surface anymore; they
will be recreated intentionally on top of the new package graph.

## Validation

The catalog lives in [catalog.rb](/Users/alex/dev/projects/igniter/examples/catalog.rb).
Both [run.rb](/Users/alex/dev/projects/igniter/examples/run.rb) and the current
root specs under [spec/current](/Users/alex/dev/projects/igniter/spec/current)
use that same source of truth.
