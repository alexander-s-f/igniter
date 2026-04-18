# Configuration

Use this index when the question is operational: boot shape, deployment, stack
layout, or persistence.

## Current Starting Points

- [CLI](../CLI.md)
- [Stacks Next](../STACKS_NEXT.md)
- [Deployment Modes](./deployment-modes.md)
- [App](../app/README.md)

## Runtime And Deployment Reference

- [Deployment v1](../DEPLOYMENT_V1.md)
- [Server v1](../SERVER_V1.md)
- [Store Adapters](../STORE_ADAPTERS.md)
- [Stacks v1](../STACKS_V1.md)

## Current Heuristic

- Start embedded with `require "igniter"` when the host app already exists.
- Move to `require "igniter/app"` when Igniter becomes the runtime shape.
- Move to `require "igniter/cluster"` only when distribution is a real execution concern.

## Project Shapes

- [Companion example](../../examples/companion/README.md)
- [Examples](../../examples/README.md)
- [Playgrounds](../../playgrounds/README.md)
