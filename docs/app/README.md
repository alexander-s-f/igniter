# App

Use this section when Igniter becomes the runtime shape of an application, not just an embedded logic kernel.

## App Means

- `Igniter::App` as the opinionated single-node runtime/profile
- host, loader, and scheduler seams
- stack-shaped projects and app boot conventions
- app diagnostics, app evolution, and governance-oriented runtime surfaces

`App` sits above the kernel. It should compose `core`, not reshape it.

## Read First

- [Stacks Next](../STACKS_NEXT.md)
- [App v1](../APP_V1.md)
- [Server v1](../SERVER_V1.md)
- [Stacks v1](../STACKS_V1.md)
- [Deployment v1](../DEPLOYMENT_V1.md)

## Useful Supporting Docs

- [Store Adapters](../STORE_ADAPTERS.md)
- [View Schema Authoring](../VIEW_SCHEMA_AUTHORING.md)
- [Plugins v1](../PLUGINS_V1.md)

## Examples

- [Examples index](../../examples/README.md)
- [Companion example](../../examples/companion/README.md)
- [Playgrounds](../../playgrounds/README.md)

## Typical Flow

1. Start with core contracts.
2. Wrap them in an app profile.
3. Group apps into runtime services only when isolation or deployment needs justify it.
4. Add only the SDK packs the app actually needs.
5. Graduate to cluster only when distributed behavior is truly required.
