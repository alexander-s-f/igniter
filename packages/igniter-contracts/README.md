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

Current proof path:

- [Contract Class DSL](../../docs/guide/contract-class-dsl.md)
- [Igniter Lang Foundation](../../docs/guide/igniter-lang-foundation.md)
- [Getting Started](../../docs/guide/getting-started.md)

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

- application hosting
- server/runtime containers
- cluster coordination
- web rendering or schema-rendering packages

It also should not depend on the legacy core implementation. Legacy code remains
reference/parity material during the rewrite, not the public architecture.

## Current Shape

`igniter-contracts` starts from its own internal primitives:

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

Contractable services expose a small service protocol to compute nodes:

```ruby
class BodyBatteryScorer
  include Igniter::Contracts::Contractable

  contractable :call do
    input :sleep_hours
    input :training_minutes
    output :score
  end

  def call(sleep_hours:, training_minutes:)
    sleep_score = observe(:sleep_score) { [[sleep_hours / 8.0, 1.0].min * 40, 0].max }
    training_score = observe(:training_score) { training_minutes <= 45 ? 10 : 2 }

    success(score: [[45 + sleep_score + training_score, 100].min, 0].max.round)
  end
end

compute :body_battery,
        depends_on: %i[sleep_hours training_minutes],
        using: BodyBatteryScorer
```

`using:` returns a normalized payload with `outputs`, `observations`, `error`,
and `success`. The service owns its internal implementation; Igniter owns the
graph boundary and result protocol.

Use `output:` when the graph should expose one named service output as the
compute value:

```ruby
compute :score,
        depends_on: %i[sleep_hours training_minutes],
        using: BodyBatteryScorer,
        output: :score
```

Additional helpers:

- `Igniter::Contracts.build_kernel(*packs)`
- `Igniter::Contracts.build_profile(*packs)`
- `Igniter::Contracts.with(*packs)`

## Verification

Use focused package specs and runnable examples as the current proof path:

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
the short guide.
