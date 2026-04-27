# Application Target Plan

`Application` is the contracts-native local host/profile layer above `Embed`.
It assembles contracts, packs, services, loaders, schedulers, host adapters, and
diagnostics into one local runtime profile.

## Owns

- `Kernel`, `Profile`, and `Environment`
- app config, manifest, layout, and blueprint
- providers, services, contracts, and local interfaces
- host, loader, scheduler, boot, shutdown, and lifecycle reports
- app-local session durability and transport-ready local invoker seams
- application capsules, sparse structure plans, imports, exports, handoff,
  transfer, and activation review artifacts

## Does Not Own

- embedded graph semantics
- distributed routing, placement, ownership, membership, or failover
- generic web rendering or route activation
- old `Igniter::App` subclass/global mutation semantics
- scaffold behavior inside the minimal runtime

## Boundary Rules

- `Embed` defines executable work.
- `Application` hosts local app runtime and app-owned lifecycle.
- `Stack` coordinates multiple apps only when needed.
- `Cluster` adds distributed execution above local runtime.
- `igniter-web` owns screens, components, routes, and rendering.

## Current Shape

The clean-slate package lives in `packages/igniter-application` and already
contains the new kernel/profile/environment direction, explicit lifecycle
plans, provider reports, app manifests, sparse layouts, capsules, transfer
review, host activation review, and receipt-shaped evidence artifacts.

## Success

Application is successful when one local app can boot without legacy/core
assumptions, profiles are explicit and comparable, host seams are adapters, and
old `Igniter::App` can be deleted as architecture rather than preserved as a
compatibility burden.
