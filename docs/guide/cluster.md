# Cluster

Use this section when execution is no longer single-node and the network itself becomes part of the runtime.

## Cluster Means

- mesh membership and gossip
- capability-based routing across peers
- replication and distributed coordination
- resilience, plasticity, and decentralized runtime behavior
- cluster diagnostics and routing explainability

The cluster layer should stay above `Embed` and `Application`. It is not the
place to redefine the kernel.

## Current First Reads

- [Guide](../guide/README.md)
- [Guide: How-Tos](../guide/how-tos.md)
- [Dev: Cluster Target Plan](../dev/cluster-target-plan.md)

## Supporting Reference

- [Guide: Distributed Workflows](../guide/distributed-workflows.md)

## Useful Supporting Docs

- [Guide: Core Runtime Features](../guide/core-runtime-features.md)

## Examples

- [Examples index](../../examples/README.md)
- cluster-oriented examples such as `cluster/incidents`,
  `cluster/incident_workflow`, `cluster/mesh_diagnostics`,
  `cluster/remediation`, and `cluster/routing`
- [Playgrounds](../../playgrounds/README.md) for local-first cluster and home-lab experiments

## Cluster Reading Heuristic

- If the topic is about contracts or execution semantics without networking,
  it probably belongs back in [Core](./core.md).
- If the topic is about app boot/profile without network coordination, it
  probably belongs in [App](./app.md).

## Direction

Current design direction:

- `Cluster` is being reset as a contracts-native distributed runtime layer
- it should sit above `Embed` and `Application`, not redefine either of them
- new design work should follow the
  [Cluster Target Plan](../dev/cluster-target-plan.md)

Older cluster research and legacy notes are private working material under
`playgrounds/docs/`, not public onboarding.
