# igniter-contracts

Public embedded kernel package for Igniter:

- contracts and DSL
- graph model and compiler
- execution/runtime primitives
- diagnostics, events, and core extension seams

Primary entrypoints:

- `require "igniter-contracts"`
- `require "igniter/contracts"`

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
now gives a lighter path too:

```ruby
environment = Igniter::Contracts.with

result = environment.run(inputs: {}) do
  const :tax_rate, 0.2
  output :tax_rate
end
```

Additional helpers:

- `Igniter::Contracts.build_kernel(*packs)`
- `Igniter::Contracts.build_profile(*packs)`
- `Igniter::Contracts.with(*packs)`
