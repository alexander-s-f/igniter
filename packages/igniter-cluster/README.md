# igniter-cluster

Clean-slate contracts-native distributed runtime for Igniter.

This package is intentionally separate from the archived cluster package.

- `igniter-cluster` is the new target package for distributed execution
- `packages/archive/igniter-cluster` remains reference-only until deletion

Primary entrypoints:

- `require "igniter-cluster"`
- `require "igniter/cluster"`

Primary API:

- `Igniter::Cluster.build_kernel`
- `Igniter::Cluster.build_profile`
- `Igniter::Cluster.with`
- `Igniter::Cluster::Kernel`
- `Igniter::Cluster::Profile`
- `Igniter::Cluster::Environment`

The first active slice is intentionally narrow:

- explicit `Peer` registry
- explicit `placement` seam
- declarative `PlacementPolicy` default
- declarative `RoutePolicy` and `AdmissionPolicy` defaults
- raw `router` and `admission` seams as low-level escape hatches
- raw `placement` seam as a low-level escape hatch
- explicit `transport` seam
- cluster-owned `compose_invoker`
- cluster-owned `collection_invoker`

The current implementation builds on `Igniter::Application::TransportRequest`
and `TransportResponse`, so the distributed path can grow without redesigning
contracts DSL or application session semantics.
