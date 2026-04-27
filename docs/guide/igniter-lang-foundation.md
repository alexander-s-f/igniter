# Igniter Lang Foundation

Igniter Lang is currently an additive contracts-facing foundation, not a
separate production language runtime.

Use it when you want a small reference surface for:

- loading the Lang namespace with `require "igniter/lang"`
- compiling and executing through the current contracts runtime
- attaching definition-time descriptors such as `History`, `BiHistory`,
  `OLAPPoint`, and `Forecast`
- inspecting a read-only `VerificationReport`
- seeing declared metadata in a report-only `MetadataManifest`

## Quick Start

Run the compact example:

```bash
ruby examples/contracts/lang_foundation.rb
```

For the accepted evaluator proof path, see
[Enterprise Verification](./enterprise-verification.md).

Minimal usage:

```ruby
require "igniter/lang"

backend = Igniter::Lang.ruby_backend
history_type = Igniter::Lang::History[Numeric]

compiled = backend.compile do
  input :price_history, type: history_type

  compute :latest_price,
          depends_on: [:price_history],
          return_type: Numeric,
          deadline: 50,
          wcet: 20 do |price_history:|
    price_history.fetch(:latest)
  end

  output :latest_price
end

result = backend.execute(compiled, inputs: { price_history: { latest: 120.0 } })
report = backend.verify(compiled)

result.output(:latest_price)
report.metadata_manifest.to_h
```

## Ruby Backend Wrapper

`Igniter::Lang.ruby_backend` returns `Igniter::Lang::Backends::Ruby`, a thin
wrapper over the existing `Igniter::Contracts` compile, execute, diagnose, and
verify surfaces.

It does not introduce a new compiler, runtime, scheduler, parser, or AST. The
compiled artifact is still a contracts artifact, and execution behavior stays
the same as ordinary contracts execution.

## Descriptors

Descriptors are immutable definition-time metadata objects:

```ruby
Igniter::Lang::History[Numeric]
Igniter::Lang::BiHistory[String]
Igniter::Lang::OLAPPoint[Numeric, { region: String }]
Igniter::Lang::Forecast[Float]
```

They can be attached to operation metadata, usually with `type:`. Today they are
inspectable declarations. They are not physical unit checks, storage adapters,
OLAP runtime handlers, temporal rules, or inferred type enforcement.

## Verification Reports

`backend.verify(...)` returns a read-only `Igniter::Lang::VerificationReport`.
`ok?` follows current compilation findings only.

The report exposes:

- `descriptors`
- `findings`
- `metadata_manifest`
- `to_h`

## Metadata Manifest

`Igniter::Lang::MetadataManifest` reports metadata that was already declared on
operations:

- `type:` descriptors
- `return_type:`
- `deadline:`
- `wcet:`

Manifest data is declared, not enforced. Requirement-like entries include
`enforced: false`, and manifest semantics include:

```ruby
{
  report_only: true,
  runtime_enforced: false
}
```

This means `return_type`, `deadline`, and `wcet` are visible in reports, but
they do not create runtime checks, warnings, findings, deadline monitoring, or
execution-result changes.

## Deferred

These remain future/research phases:

- standalone grammar, parser, AST, and `.il` files
- Rust backend and certified exports
- store DSL or Lang metadata builder
- OLAP, time-machine, and temporal-rule runtime behavior
- physical unit algebra enforcement
- invariant metadata integration
- deadline/WCET runtime monitoring, warnings, or findings

## Related

- [Enterprise Verification](./enterprise-verification.md)
- [Contract Class DSL](./contract-class-dsl.md)
