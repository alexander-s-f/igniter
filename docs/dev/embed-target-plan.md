# Embed Target Plan

`Embed` is the contracts-first operating mode. It is the foundation for
`Application` and `Cluster`, not a side feature.

## Owns

- contract DSL and class DSL consumption
- graph model, compilation, validation, and local execution
- finalized profiles, explicit packs, and diagnostics hooks
- host-local registry/discovery, graph cache, reload integration, and named
  execution for embedded hosts

Typical hosts: Rails apps, jobs, scripts, CLIs, services, and local automation.

## Does Not Own

- application boot lifecycle
- server/container runtime
- scheduler orchestration
- stack composition
- network routing
- consensus, replication, or distributed placement

Those belong to `Application` and `Cluster`.

## Package Rule

The embedded package story is:

- `igniter-contracts` for executable graph semantics
- `igniter-extensions` for optional packs over that kernel
- no required dependency on app, stack, cluster, Rails, or legacy core

`require "igniter"` may stay as a convenience umbrella, but architecture should
remain explicit: contracts kernel, packs, profile, environment.

## Authoring Rule

Two authoring forms are equal before any host layer exists:

- block DSL for generated and low-level kernel usage
- class DSL for human-edited contracts in apps, Rails projects, and examples

`Embed` must consume those forms. It must not redefine the contract language.

## Success

Embed is successful when an existing host can run contracts with explicit packs,
diagnostics, and local runtime behavior without adopting application hosting,
stack orchestration, cluster semantics, or legacy/core assumptions.
