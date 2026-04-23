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

- explicit `PeerProfile` identity model over name/capabilities/roles/labels
- explicit `PeerTopology` model for region/zone/labels locality
- richer `CapabilityQuery` intent over capabilities, traits, labels, region,
  and zone
- explicit `TopologyPolicy` and `RebalancePlan` for movement/rebalancing
  semantics
- explicit `OwnershipPolicy` and `OwnershipPlan` for workload/entity ownership
  planning
- explicit `LeasePolicy` and `LeasePlan` for TTL/renewal-aware coordination
  planning
- explicit `HealthPolicy` and `FailoverPlan` for degraded/failure transition
  planning
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
