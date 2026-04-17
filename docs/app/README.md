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
3. Mount apps into one stack runtime by default.
4. Add local node profiles only when you actually need multi-instance local boot.
5. Add only the SDK packs the app actually needs.
6. Graduate to cluster only when distributed behavior is truly required.

## Canonical Shape

The preferred app/runtime shape is now:

- `stack.rb` defines apps and mounts
- `stack.yml` defines root app, persistence, and optional node profiles
- `Igniter::Stack` owns the server/runtime container
- `Igniter::App` stays a portable mounted module

Legacy `service/topology` support has been removed from the canonical stack runtime. Read older V1 docs as historical context only.
