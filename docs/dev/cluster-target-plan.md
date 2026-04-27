# Cluster Target Plan

`Cluster` is the distributed runtime layer over `Embed` and, when useful,
`Application`. It places, routes, executes, and explains distributed work
without redefining contracts.

## Owns

- remote execution substrate
- capability-aware routing and admission
- peer identity, topology, health, and membership views
- ownership, placement, leases, failover, and remediation plans
- replication/capacity expansion where it is truly cluster semantics
- distributed diagnostics, traces, incidents, and operator timelines

## Does Not Own

- embedded graph semantics
- local app boot lifecycle
- generic app hosting
- code loading as a core cluster concern
- heavyweight coordination by default

## Boundary Rules

- `Embed` defines executable work.
- `Application` owns local host/runtime profile.
- `Cluster` decides where and how distributed work runs.
- Mesh behavior sits above explicit cluster plan semantics.

## Current Shape

The clean-slate package now includes capability queries, peer/topology/health
views, route/admission/placement/ownership/lease/failover/remediation policies,
explicit plans and execution reports, mesh request/response/attempt/trace
values, membership/discovery feeds, event logs, incidents, remediation plans,
and operator timelines.

## Success

Cluster is successful when distributed execution, routing, ownership, placement,
health, and remediation are explicit seams with structured explanations, and no
distributed concern leaks down into the embedded kernel.
