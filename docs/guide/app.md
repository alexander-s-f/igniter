# App

Use this section when Igniter becomes the runtime shape of an application, not just an embedded logic kernel.

## App Means

- `Igniter::App` as the opinionated single-node runtime/profile
- host, loader, and scheduler seams
- stack-shaped projects and app boot conventions
- app diagnostics, app evolution, and governance-oriented runtime surfaces

`App` sits above the kernel. It should compose `core`, not reshape it.

## Current First Reads

- [Guide](../guide/README.md)
- [Guide: How-Tos](../guide/how-tos.md)
- [Guide: Configuration](../guide/configuration.md)
- [Guide: Deployment Modes](../guide/deployment-modes.md)
- [Current: App Structure](../current/app-structure.md)
- [Stacks Next](../STACKS_NEXT.md)
- [CLI](../CLI.md)

## Supporting Reference

- [Guide: Configuration](../guide/configuration.md)
- [Guide: Integrations](../guide/integrations.md)
- [Dev: Legacy Reference](../dev/legacy-reference.md)

## Useful Supporting Docs

- [Store Adapters](../STORE_ADAPTERS.md)
- [Schema Rendering Authoring](../SCHEMA_RENDERING_AUTHORING.md)
- [Frontend Authoring](../FRONTEND_AUTHORING.md)
- [Frontend Components](../FRONTEND_COMPONENTS.md)
- [Guide: Integrations](../guide/integrations.md)

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

## Scaffold Direction

The generator surface now has a small progression:

- base scaffold for one root app
- `dashboard` profile for a mounted second app and simple operational UI
- `cluster` profile for a local capability mesh sandbox with node profiles
- `playground` profile for a richer local proving surface

Current scaffold direction:

- app-local code should be emitted inside the owning app without an extra
  mandatory `app/` wrapper
- runtime-first folders `contracts/`, `executors/`, `agents/`, `tools/`, and
  `skills/` should stay top-level inside the app
- web/UI surfaces should live under optional `web/handlers`, `web/views`, and
  `web/components`
- only genuinely shared stack code should land in `lib/<project>/shared`
- generated operator/dashboard surfaces should prefer `igniter-frontend` page
  classes over raw HTML string assembly

## Canonical Shape

The preferred app/runtime shape is now:

- `stack.rb` defines apps and mounts
- `stack.yml` defines root app, persistence, and optional node profiles
- `bin/start`, `bin/dev`, and `bin/console` are the canonical runtime entry points
- `Igniter::Stack` owns the server/runtime container
- `Igniter::App` stays a portable mounted module

## Current App Structure Direction

The current direction is:

- app-local code lives inside the app
- stack-level `lib` is only for code that is truly shared
- apps should be portable and mountable across stacks
- cross-app access should use explicit app-to-app APIs, not implicit shared constants

Current cross-app contract:

- provider app exposes an interface with `expose`
- or, more readably for app-to-app contracts, `provide`
- stack registration declares dependency with `access_to: [...]`
- mounted consumer apps resolve it through `App.interface(:name)` / `App.interfaces`
- the stack still exposes `Stack.interface(:name)` / `Stack.interfaces` as the lower-level surface
- the generated `playground` and `cluster` profiles both demonstrate this
  pattern directly in scaffolded code

For frontend authoring, the recommended path is:

- `igniter-frontend`
- Arbre
- Tailwind surfaces

Hardcoded HTML strings in Ruby are not the preferred authoring model.
See [Current: App Structure](../current/app-structure.md) for the active
structure doctrine and migration direction.

## Current App Model

Think of `Igniter::App` as a leaf runtime package inside a stack, not as the
entire deployment topology.

- `require "igniter/app"` is the canonical app umbrella
- `require "igniter/app/runtime"` is the narrower leaf-runtime entrypoint
- host choice is declarative at the app layer
- scheduler choice is declarative at the app layer
- loader choice is declarative at the app layer
- scaffold APIs are an explicit pack, not part of the minimal runtime load path

The main operational split is:

- `Igniter::App` owns app profile and assembly
- `Igniter::Stack` owns mounted coordination and stack runtime
- `Igniter::Server` provides hosting/transport
- `Igniter::Cluster` extends that into network-aware execution

Legacy `service/topology` support has been removed from the canonical stack runtime. Read older historical docs only through [`../dev/legacy-reference.md`](../dev/legacy-reference.md).
