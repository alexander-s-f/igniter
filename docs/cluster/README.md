# Cluster

Use this section when execution is no longer single-node and the network itself becomes part of the runtime.

## Cluster Means

- mesh membership and gossip
- capability-based routing across peers
- replication and distributed coordination
- resilience, plasticity, and decentralized runtime behavior
- cluster diagnostics and routing explainability

The cluster layer should stay above `core` and `app`. It is not the place to redefine the kernel.

## Read First

- [Guide](../guide/README.md)
- [Guide: How-Tos](../guide/how-tos.md)
- [Cluster State Snapshot](./STATE_NEXT.md)
- [Cluster Next](./ROADMAP_NEXT.md)
- [Distributed Contracts v1](../DISTRIBUTED_CONTRACTS_V1.md)
- [Mesh v1](../MESH_V1.md)
- [Consensus v1](../CONSENSUS_V1.md)
- [Deployment v1](../DEPLOYMENT_V1.md)

## Useful Supporting Docs

- [Capabilities v1](../CAPABILITIES_V1.md)
- [Cluster Debug v1](../CLUSTER_DEBUG_V1.md)
- [Server v1](../SERVER_V1.md)
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

Read V1 cluster docs as supporting reference, not as the first entrypoint.
