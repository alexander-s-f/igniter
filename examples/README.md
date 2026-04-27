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

For app-level evaluation, start with the flagship application checks:

```bash
ruby examples/run.rb run application/lense_poc
ruby examples/run.rb run application/chronicle_poc
ruby examples/run.rb run application/scout_poc
ruby examples/run.rb run application/dispatch_poc
```

These are the richer current application examples. Their portfolio guide lives
at [Application Showcase Portfolio](../docs/guide/application-showcase-portfolio.md).

The focused contracts/lang checks are:

```bash
ruby examples/run.rb run contracts/class_pricing
ruby examples/run.rb run contracts/class_callable
ruby examples/run.rb run contracts/embed_class_registration
ruby examples/run.rb run contracts/contractable_shadow
ruby examples/run.rb run contracts/step_result
ruby examples/run.rb run contracts/lang_foundation
```

## Active Example Lane

Active runnable examples live in `examples/application/`,
`examples/contracts/`, and `examples/cluster/`:

- `application/blueprint.rb`
- `application/capsule_layout.rb`
- `application/capsule_authoring_dsl.rb`
- `application/capsule_assembly_plan.rb`
- `application/capsule_composition.rb`
- `application/capsule_handoff_manifest.rb`
- `application/capsule_host_activation_commit_readiness.rb`
- `application/capsule_host_activation_dry_run.rb`
- `application/capsule_host_activation_plan.rb`
- `application/capsule_host_activation_plan_verification.rb`
- `application/capsule_host_activation_readiness.rb`
- `application/capsule_host_activation_ledger_adapter.rb`
- `application/capsule_inspection.rb`
- `application/capsule_manifest.rb`
- `application/interactive_web_poc.rb`
- `application/signal_inbox_poc.rb`
- `application/lense_poc.rb`
- `application/chronicle_poc.rb`
- `application/scout_poc.rb`
- `application/dispatch_poc.rb`
- `application/capsule_transfer_applied_verification.rb`
- `application/capsule_transfer_apply_execution.rb`
- `application/capsule_transfer_apply_plan.rb`
- `application/capsule_transfer_bundle_artifact.rb`
- `application/capsule_transfer_bundle_plan.rb`
- `application/capsule_transfer_bundle_verification.rb`
- `application/capsule_transfer_end_to_end.rb`
- `application/capsule_transfer_intake_plan.rb`
- `application/capsule_transfer_inventory.rb`
- `application/capsule_transfer_receipt.rb`
- `application/capsule_transfer_readiness.rb`
- `application/feature_flow_report.rb`
- `application/flow_session.rb`
- `application/layout.rb`
- `application/mounts.rb`
- `application/web_mount.rb`
- `application/web_surface_structure.rb`
- `application/web_surface_manifest.rb`
- `application/agent_native_plan_review.rb`
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
- `contracts/step_result.rb`
- `contracts/lang_foundation.rb`
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

`application/interactive_web_poc.rb` is a stable launcher. The copyable
app-local skeleton for that POC lives in
`application/interactive_operator/`.

`application/signal_inbox_poc.rb` repeats the same application/web pattern in a
non-task signal inbox domain. Its copyable skeleton lives in
`application/operator_signal_inbox/`.

## Archive Note

Legacy-root demos and migration scripts were moved out of the active example
lane. We are not treating them as the current framework surface anymore; they
will be recreated intentionally on top of the new package graph.

## Validation

The catalog lives in [catalog.rb](./catalog.rb). Both
[run.rb](./run.rb) and the current root specs under
[spec/current](../spec/current) use that same source of truth.
