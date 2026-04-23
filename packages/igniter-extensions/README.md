# igniter-extensions

Public extension entrypoints for Igniter.

This package currently contains two architectural lanes:

- contracts-facing packs built on `Igniter::Contracts`
- legacy extension activators that still bridge into `igniter-core`

The legacy lane remains for migration. Those entrypoints will surface the
`igniter-core` / legacy-extension notice when loaded. Use
`IGNITER_LEGACY_CORE_REQUIRE=error` to make those loads fail fast during
migration cleanup.

This package owns the `igniter/extensions/*` activation surface, including:

- `require "igniter/extensions/dataflow"`
- `require "igniter/extensions/saga"`
- `require "igniter/extensions/provenance"`
- `require "igniter/extensions/differential"`
- `require "igniter/extensions/incremental"`
- `require "igniter/extensions/reactive"`
- `require "igniter/extensions/invariants"`
- `require "igniter/extensions/contracts"`

It also provides the package facade:

- `require "igniter-extensions"`

The package facade itself stays lightweight and does not eagerly load legacy
core runtime files.

Contracts-facing external packs now live here too:

- `Igniter::Extensions::Contracts::ExecutionReportPack`
- `Igniter::Extensions::Contracts::LookupPack`
- `Igniter::Extensions::Contracts::AggregatePack`
- `Igniter::Extensions::Contracts::AuditPack`
- `Igniter::Extensions::Contracts::CapabilitiesPack`
- `Igniter::Extensions::Contracts::CommercePack`
- `Igniter::Extensions::Contracts::CreatorPack`
- `Igniter::Extensions::Contracts::DataflowPack`
- `Igniter::Extensions::Contracts::DebugPack`
- `Igniter::Extensions::Contracts::DifferentialPack`
- `Igniter::Extensions::Contracts::JournalPack`
- `Igniter::Extensions::Contracts::InvariantsPack`
- `Igniter::Extensions::Contracts::McpPack`
- `Igniter::Extensions::Contracts::ProvenancePack`
- `Igniter::Extensions::Contracts::ReactivePack`
- `Igniter::Extensions::Contracts::SagaPack`

Those packs install into `Igniter::Contracts` through the public facade only:

```ruby
require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with

result = environment.run(inputs: { rates: { ua: 0.2 } }) do
  input :rates
  lookup :tax_rate, from: :rates, key: :ua
  output :tax_rate
end
```

Default helpers like `Igniter::Extensions::Contracts.with` currently install the
safe default packs (`ExecutionReportPack` and `LookupPack`). Operational packs
like `JournalPack` stay opt-in:

```ruby
environment = Igniter::Extensions::Contracts.with(
  Igniter::Extensions::Contracts::JournalPack
)
```

Applied presets can sit on top of those packs too:

```ruby
environment = Igniter::Extensions::Contracts.with_preset(:commerce)
```

For developer-focused observability, `DebugPack` can bundle profile,
compilation, execution, diagnostics, and provenance into one report:

```ruby
environment = Igniter::Extensions::Contracts.with(
  Igniter::Extensions::Contracts::DebugPack
)

report = Igniter::Extensions::Contracts.debug_report(
  environment,
  inputs: { amount: 10 }
) do
  input :amount
  output :amount
end
```

It can also audit a custom pack before finalize, which is the first bridge
toward a future `CreatorPack` workflow:

```ruby
audit = Igniter::Extensions::Contracts.audit_pack(MyDraftPack, environment)

audit.ok?
audit.missing_node_definitions
audit.missing_registry_contracts
audit.finalize_error
```

`CreatorPack` now adds a minimal scaffold/report workflow on top of that:

```ruby
scaffold = Igniter::Extensions::Contracts.scaffold_pack(
  name: :slug,
  profile: :feature_node,
  scope: :app_local,
  namespace: "MyCompany::IgniterPacks"
)

report = Igniter::Extensions::Contracts.creator_report(
  name: :slug,
  profile: :feature_node
)

workflow = Igniter::Extensions::Contracts.creator_workflow(
  name: :slug,
  profile: :feature_node,
  scope: :standalone_gem
)
```

Available authoring profiles:

- `:feature_node`
- `:operational_adapter`
- `:diagnostic_bundle`
- `:bundle_pack`

Available target scopes:

- `:app_local`
- `:monorepo_package`
- `:standalone_gem`

The workflow helper turns those decisions into an explicit authoring ladder:

- profile/scope selection
- scaffold generation
- implementation
- audit validation
- packaging readiness

It also separates recommended runtime dependency packs from development-only
tooling packs, so authoring guidance does not accidentally become runtime
bundle surface.

There is also a stateful wizard layer that can hold partial decisions before
you are ready to generate files:

```ruby
wizard = Igniter::Extensions::Contracts.creator_wizard(
  name: :delivery,
  capabilities: %i[effect executor]
)

wizard.current_decision
wizard.branching_hints
wizard.recommended_examples
completed = wizard.apply(scope: :standalone_gem)
```

For file generation, `CreatorPack` also exposes a multi-step writer with
explicit planning:

```ruby
writer = Igniter::Extensions::Contracts.creator_writer(
  name: :slug,
  profile: :feature_node,
  scope: :app_local,
  root: "/tmp/my_pack"
)

plan = writer.plan
result = writer.write
```

By default the writer uses `:skip_existing`, so existing files are preserved
unless you explicitly opt into `mode: :overwrite`.

`McpPack` is the first thin tooling adapter over those stabilized surfaces:

```ruby
environment = Igniter::Extensions::Contracts.with(
  Igniter::Extensions::Contracts::McpPack
)

Igniter::Extensions::Contracts.mcp_tools
result = Igniter::Extensions::Contracts.mcp_call(
  :creator_wizard,
  target: environment,
  name: :delivery,
  capabilities: %i[effect executor]
)
```

The goal is to adapt existing debug/creator primitives for external tools, not
to invent a second authoring stack.

For stepwise external tooling, `McpPack` also exposes a serialized
`creator_session` flow:

```ruby
session = Igniter::Extensions::Contracts.mcp_creator_session(
  target: environment,
  name: :delivery,
  capabilities: %i[effect executor]
)

updated = Igniter::Extensions::Contracts.mcp_call(
  :creator_session_apply,
  target: environment,
  session: session.to_h.fetch(:payload).fetch(:session),
  updates: { scope: :standalone_gem }
)
```

You can also drive scaffolding directly from capabilities:

```ruby
Igniter::Extensions::Contracts.scaffold_pack(
  name: :delivery,
  capabilities: %i[effect executor]
)
```

Legacy extension activators still exist for migration scenarios:

- `require "igniter/extensions/auditing"`
- `require "igniter/extensions/capabilities"`
- `require "igniter/extensions/dataflow"`
- `require "igniter/extensions/saga"`
- `require "igniter/extensions/provenance"`
- `require "igniter/extensions/differential"`
- `require "igniter/extensions/incremental"`
- `require "igniter/extensions/reactive"`
- `require "igniter/extensions/invariants"`

Those activators still route through `igniter-core` and should be treated as
legacy architecture, not as the long-term extension model.

The first canonical activator-to-pack migration target is now explicit:

- `require "igniter/extensions/execution_report"`
  -> `Igniter::Extensions::Contracts::ExecutionReportPack`
- `require "igniter/extensions/auditing"`
  -> `Igniter::Extensions::Contracts::AuditPack`
- `require "igniter/extensions/capabilities"`
  -> `Igniter::Extensions::Contracts::CapabilitiesPack`
- `require "igniter/extensions/dataflow"`
  -> `Igniter::Extensions::Contracts::DataflowPack`
- `require "igniter/extensions/provenance"`
  -> `Igniter::Extensions::Contracts::ProvenancePack`
- `require "igniter/extensions/saga"`
  -> `Igniter::Extensions::Contracts::SagaPack`
- `require "igniter/extensions/incremental"`
  -> `Igniter::Extensions::Contracts::IncrementalPack`
- `require "igniter/extensions/differential"`
  -> `Igniter::Extensions::Contracts::DifferentialPack`
- `require "igniter/extensions/reactive"`
  -> `Igniter::Extensions::Contracts::ReactivePack`
- `require "igniter/extensions/invariants"`
  -> `Igniter::Extensions::Contracts::InvariantsPack`

See [examples/contracts/execution_report_migration.rb](../../examples/contracts/execution_report_migration.rb)
and [examples/contracts/auditing.rb](../../examples/contracts/auditing.rb)
and [examples/contracts/capabilities.rb](../../examples/contracts/capabilities.rb)
and [examples/contracts/dataflow.rb](../../examples/contracts/dataflow.rb)
and [examples/contracts/differential.rb](../../examples/contracts/differential.rb)
and [examples/contracts/invariants.rb](../../examples/contracts/invariants.rb)
and [examples/contracts/provenance.rb](../../examples/contracts/provenance.rb)
and [examples/contracts/reactive.rb](../../examples/contracts/reactive.rb)
and [examples/contracts/saga.rb](../../examples/contracts/saga.rb)
and [examples/contracts/incremental.rb](../../examples/contracts/incremental.rb)
for runnable migration walkthroughs.

Docs:

- [Guide](../../docs/guide/README.md)
- [Core guide](../../docs/guide/core.md)
- [Dev](../../docs/dev/README.md)
