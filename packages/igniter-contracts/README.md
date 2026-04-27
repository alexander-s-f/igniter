# igniter-contracts

Public embedded kernel package for Igniter:

- contracts and DSL
- graph model and compiler
- execution/runtime primitives
- diagnostics, events, and core extension seams

Primary entrypoints:

- `require "igniter-contracts"`
- `require "igniter/contracts"`
- `require "igniter/lang"` for the additive Lang foundation

Evaluator proof path:

- [Enterprise Verification](../../docs/guide/enterprise-verification.md)
- [Contract Class DSL](../../docs/guide/contract-class-dsl.md)
- [Igniter Lang Foundation](../../docs/guide/igniter-lang-foundation.md)

Current implementation focus:

- `Kernel`
- `Profile`
- `Environment`
- `Registry` / `OrderedRegistry`
- `Pack` / `BaselinePack`

## Intended Use

Use `igniter-contracts` when Igniter is embedded inside another host such as:

- Rails applications
- scripts and jobs
- existing service runtimes

This package is the lower-layer dependency that other runtime shapes should
build on top of. It should not pull:

- `igniter/app`
- `igniter/server`
- `igniter/cluster`
- frontend or schema-rendering packages

It also should not depend on `igniter-core`. During the rewrite, both packages
stay in the monorepo, but with different roles:

- `igniter-contracts`
  the new implementation that is expected to replace `igniter-core` at maturity
- `igniter-core`
  the legacy reference implementation used for comparison, parity checks, and
  migration confidence while the rewrite is still in flight

The legacy package now warns on public runtime entrypoints by default to make
that architectural direction explicit. It can be switched to fail-fast mode
with `IGNITER_LEGACY_CORE_REQUIRE=error`.

## Current Shape

`igniter-contracts` is now starting from its own internal primitives instead of
growing out of the legacy `igniter-core` umbrella. The first step is the
extensibility foundation:

- registries
- kernel/profile lifecycle
- environment sugar over a finalized profile
- packs
- a tiny baseline pack

## Ergonomics

You can still work directly with `Kernel` and `Profile`, but the public facade
now gives two equal authoring paths.

For the low-level embedded kernel API, compile or run a block directly:

```ruby
environment = Igniter::Contracts.with

result = environment.run(inputs: {}) do
  const :tax_rate, 0.2
  output :tax_rate
end
```

For app code and human-edited contract files, use the class DSL:

```ruby
class PriceContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country, type: :string

    compute :gross_total, depends_on: %i[order_total country] do |order_total:, country:|
      order_total * (country == "UA" ? 1.2 : 1.0)
    end

    output :gross_total
  end
end

contract = PriceContract.new(order_total: 100, country: "UA")
contract.result.gross_total
contract.update_inputs(order_total: 150)
contract.output(:gross_total)
```

Compute nodes may also use `call:` for service objects or callable classes:

```ruby
compute :gross_total, depends_on: %i[order_total country], call: Pricing::GrossTotal
```

Additional helpers:

- `Igniter::Contracts.build_kernel(*packs)`
- `Igniter::Contracts.build_profile(*packs)`
- `Igniter::Contracts.with(*packs)`

## Verification

Use the enterprise receipt as the compact public proof path:

```bash
bundle exec rspec packages/igniter-contracts/spec spec/current
ruby examples/run.rb smoke
```

Focused contracts/lang checks:

```bash
ruby examples/run.rb run contracts/class_pricing
ruby examples/run.rb run contracts/class_callable
ruby examples/run.rb run contracts/embed_class_registration
ruby examples/run.rb run contracts/contractable_shadow
ruby examples/run.rb run contracts/step_result
ruby examples/run.rb run contracts/lang_foundation
```

For narrow changes, run RuboCop on the changed files. Full-project RuboCop
currently includes pre-existing archived/research offenses, so changed-file
lint is the practical gate for focused package slices; this is a caveat, not a
quality target.

## Igniter Lang Foundation

`require "igniter/lang"` loads a small contracts-facing Lang namespace.
Currently this is an additive reference surface over the existing contracts
runtime:

- `Igniter::Lang.ruby_backend` wraps current compile, execute, diagnose, and
  verify APIs.
- `History`, `BiHistory`, `OLAPPoint`, and `Forecast` are immutable
  definition-time descriptors that can be attached as operation metadata.
- `VerificationReport` is read-only and follows current compilation findings.
- `MetadataManifest` reports declared `type:`, `return_type:`, `deadline:`,
  and `wcet:` metadata.

Metadata manifest fields are declared, not enforced. `return_type`, `deadline`,
and `wcet` appear in reports with `enforced: false`; they do not add runtime
checks, warnings, deadline monitoring, or `ExecutionResult` changes.

Try the compact proof:

```bash
ruby examples/contracts/lang_foundation.rb
```

See [Igniter Lang Foundation](../../docs/guide/igniter-lang-foundation.md) for
the short guide, or [Enterprise Verification](../../docs/guide/enterprise-verification.md)
for the accepted proof path.
