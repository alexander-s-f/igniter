# Configuration

Use this index when the question is operational: boot shape, deployment, stack
layout, or persistence.

## Current Starting Points

- [CLI](./cli.md)
- [Application Capsules](./application-capsules.md)
- [Deployment Modes](./deployment-modes.md)
- [App](./app.md)

## Runtime And Deployment Reference

- [Deployment Modes](./deployment-modes.md)
- [Store Adapters](./store-adapters.md)
- [Application Capsules](./application-capsules.md)
- [Legacy Reference](../dev/legacy-reference.md)

## Current Heuristic

- Start embedded with `require "igniter"` when the host app already exists.
- Move to `require "igniter/app"` when Igniter becomes the runtime shape.
- Move to `require "igniter/cluster"` only when distribution is a real execution concern.

## Project Shapes

- [Examples](../../examples/README.md)
- [Application Showcase Portfolio](./application-showcase-portfolio.md)
- [Interactive App Structure](./interactive-app-structure.md)
- [Playgrounds](../../playgrounds/README.md)
