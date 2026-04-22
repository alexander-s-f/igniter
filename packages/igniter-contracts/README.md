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

## Current Shape

`igniter-contracts` is now starting from its own internal primitives instead of
growing out of the legacy `igniter-core` umbrella. The first step is the
extensibility foundation:

- registries
- kernel/profile lifecycle
- packs
- a tiny baseline pack
