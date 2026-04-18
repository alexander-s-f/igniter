# Cluster

Use this section when execution is no longer single-node and the network itself becomes part of the runtime.

## Cluster Means

- mesh membership and gossip
- capability-based routing across peers
- replication and distributed coordination
- resilience, plasticity, and decentralized runtime behavior
- cluster diagnostics and routing explainability

The cluster layer should stay above `core` and `app`. It is not the place to redefine the kernel.

## Current First Reads

- [Guide](../guide/README.md)
- [Guide: How-Tos](../guide/how-tos.md)
- [Cluster State Snapshot](./STATE_NEXT.md)
- [Cluster Next](./ROADMAP_NEXT.md)

## Supporting Reference

- [Guide: Distributed Workflows](../guide/distributed-workflows.md)
- [Dev: Legacy Reference](../dev/legacy-reference.md)

## Useful Supporting Docs

- [Guide: Core Runtime Features](../guide/core-runtime-features.md)
- [Backlog](../BACKLOG.md)

## Examples

- [Examples index](../../examples/README.md)
- cluster-oriented scripts such as `mesh.rb`, `mesh_discovery.rb`, `mesh_gossip.rb`, `distributed_server.rb`, `distributed_workflow.rb`
- [Playgrounds](../../playgrounds/README.md) for local-first cluster and home-lab experiments

## Cluster Reading Heuristic

- If the topic is about contracts or execution semantics without networking, it probably belongs back in [Core](../core/README.md).
- If the topic is about app boot/profile without network coordination, it probably belongs in [App](../app/README.md).

## Direction

If you want the current implemented state, start with [Cluster State Snapshot](./STATE_NEXT.md).
If you want the development direction beyond that, continue to [Cluster Next](./ROADMAP_NEXT.md).

Read older cluster docs only through [`../dev/legacy-reference.md`](../dev/legacy-reference.md), not as the first entrypoint.
