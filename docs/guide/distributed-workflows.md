# Distributed Workflows

Use this page when a contract is no longer just in-process computation and must
wait for or react to signals that may arrive later or on another node.

## Current Mental Model

Distributed workflow concerns belong above the embedded kernel:

- the contract graph stays explicit
- correlation keys matter more than process memory
- waiting on external signals should be visible in workflow state
- transport stays outside the workflow model

## Current Reading Path

- [Cluster](../cluster/README.md)
- [cluster/STATE_NEXT.md](../cluster/STATE_NEXT.md)
- [cluster/ROADMAP_NEXT.md](../cluster/ROADMAP_NEXT.md)
- [Guide: Deployment Modes](./deployment-modes.md)

## Historical Deep Reference

For the older detailed design write-up, see
[Distributed Contracts v1](../DISTRIBUTED_CONTRACTS_V1.md).
