# Igniter Web Target Plan

This note defines the current high-priority rebuild track for `igniter-web`.

It should be read together with:

- [Module System](./module-system.md)
- [Application Target Plan](./application-target-plan.md)
- [Application And Web Integration](./application-web-integration.md)
- [Current: App Structure](../current/app-structure.md)

## Status

This track is now high priority.

Practical meaning:

- we should treat `igniter-web` as an active package, not a vague future idea
- new web authoring work should target this package
- `igniter-frontend` should be treated as deprecated legacy/reference material,
  not as the target architecture

## Core Thesis

Igniter should not rebuild a generic CRUD-first Rails clone.

The web layer should instead reflect the real interaction model Igniter is good
at:

- chats
- dashboards
- streams
- operator surfaces
- automations
- agent-driven flows
- long-lived wizards and process UIs
- environment-driven or proactive actions, not only user-initiated requests

That means the center of the web package is not `index/show/create/update`.
The center is interaction, process, projection, and contracts-native runtime
integration.

## Package Shape

`igniter-web` should group three intentionally different surfaces:

### 1. `Igniter::Web::Api`

This is the lower, more Igniter-native web surface.

It should be:

- contracts-first
- explicit
- suitable for HTTP ingress/egress and mounted transport concerns
- capable of representing more than classic JSON CRUD

Primary lanes:

- `command`
- `query`
- `stream`
- `webhook`
- later, possibly `signal`, `projection`, or similar runtime-specific lanes

This layer is the honest transport boundary.
It adapts web requests into contracts, process steps, projections, and runtime
surfaces without pretending the domain itself is MVC.

### 2. `Igniter::Web::Application`

This is the higher, more authoring-oriented web surface.

It should be:

- more Sinatra-like or Rails-like in feel
- convention-friendly
- allowed to use a moderate amount of magic for developer experience
- built as sugar over `Igniter::Web::Api`, not as a separate philosophy

Likely responsibilities:

- route DSL
- page/layout authoring
- template and component conventions
- forms and submissions
- session and flash helpers
- wizard/process flow ergonomics
- mount-friendly URL helpers
- streaming page surfaces for live projections

The goal is not "maximum purity".
The goal is a high-class developer layer that feels expressive and fast.

### 3. `Igniter::Web::Record`

This should be an optional persistence-facing facade, not the center of the
package.

It should begin as:

- a unified interface
- adapter-driven
- intentionally thin
- easy to defer or reshape later

It should not force the whole web layer into ORM-first thinking.

Current direction:

- treat `Record` as a convenience boundary
- keep it optional
- avoid turning contracts into disguised Active Record callbacks

## Naming Direction

Preferred package name:

- `igniter-web`

Preferred public namespaces:

- `Igniter::Web::Api`
- `Igniter::Web::Application`
- `Igniter::Web::ScreenSpec`
- `Igniter::Web::Composer`
- `Igniter::Web::ViewGraph`
- `Igniter::Web::Record`

This is currently preferred over a classical `igniter-mvc` naming lane because
the target authoring model is broader than MVC and more faithful to Igniter's
contracts/process orientation.

## First-Class Primitives

The first-class primitives should reflect Igniter's actual workload shape.

Prefer building around concepts such as:

- `command`
- `query`
- `stream`
- `webhook`
- `page`
- `wizard`
- `session`
- `process`
- `projection`
- `component`
- `composer`
- `view_graph`

These are more important than mirroring Rails defaults like:

- `controller`
- `view`
- `model`
- `resource`

Those words may still appear as compatibility or convenience vocabulary, but
they should not dictate the core design.

## Application Capsule Structure

[Agent Web / Codex] Web now treats application structure through the public
`igniter-application` layout profile seam. Application owns the top-level
`:web` group (`web` in `:capsule`, `app/web` in `:standalone` and
`:expanded_capsule`). `igniter-web` owns the vocabulary inside that root.

Initial web-local surface groups:

- `screens` for composed screen specs and agent-managed flows
- `pages` for routeable page templates
- `components` for reusable Arbre-backed view components
- `projections` for stream/read-model targets, not CRUD models
- `webhooks` for external ingress endpoints
- `assets` for optional web-local static or generated assets

[Agent Web / Codex] This is exposed as `Igniter::Web::SurfaceStructure` and
`Igniter::Web.surface_structure(blueprint)`. It intentionally derives from
`blueprint.layout.path(:web)` instead of asking `igniter-application` to model
`web/screens`, `web/pages`, or other web internals as application core groups.

[Agent Web / Codex] Non-web applications remain first-class. A blueprint only
activates the top-level `:web` group when `web_surfaces` or explicit groups
request it; `InteractionTarget` remains independent from file placement.

## Surface Manifest Metadata

[Agent Web / Codex] Web now exposes `Igniter::Web::SurfaceManifest` and
`Igniter::Web.surface_manifest(application, name:, path:)` as a web-owned
exports/imports description for a surface.

The manifest records exports such as:

- routeable pages
- routeable composed screens
- command/query/stream/webhook endpoints
- web-local mount declarations

It records imports such as:

- contract targets from command routes and screen actions
- service targets from query routes
- projection targets from stream routes and stream screen elements
- agent targets from chat screen elements

[Agent Web / Codex] `SurfaceManifest#to_capsule_export` emits a plain
application-compatible export hash with `kind: :web_surface`, `target:` as the
mount path, and the detailed web manifest nested in metadata.

[Agent Web / Codex] For the agent-native interaction session track,
`SurfaceManifest#to_h` also includes `interactions`:

- `pending_inputs` extracted from `ask`
- `pending_actions` extracted from `action`
- `streams` extracted from `stream`
- `chats` extracted from `chat`

[Agent Web / Codex] These are metadata candidates for application-owned flow
snapshots. They do not imply browser transport, web-owned durability, or
contract execution.

[Agent Web / Codex] `Igniter::Web.flow_pending_state(...)` is the explicit
web-owned adapter from candidate interaction metadata into plain
application-compatible `pending_inputs` and `pending_actions` hashes. This
keeps the mapping inspectable at the flow session boundary instead of hiding it
inside application runtime magic.

[Agent Web / Codex] This is intentionally not a second capsule manifest. It is
the web-side input that the application-level exports/imports model can consume
without learning about Arbre, pages, components, or screen graph internals.

## Explicit Non-Goals

- do not rebuild old `igniter-frontend` structure as-is
- do not make the package CRUD-first
- do not force `ControllerContract` or `ViewContract` abstractions
- do not make persistence the center of the web architecture
- do not push web authoring concerns down into `igniter-contracts`
- do not require cluster semantics inside the minimal web package core

## Dependency Direction

The intended layering is:

```text
igniter-contracts
  -> igniter-extensions
  -> igniter-application
  -> igniter-web
```

Rules:

- `igniter-web` may depend on `igniter-application`
- `igniter-application` must not depend on `igniter-web`
- `igniter-contracts` must remain ignorant of web/UI concerns
- persistence adapters, UI lanes, and richer authoring DSL can grow inside
  `igniter-web` without contaminating lower layers

## DX Policy

For `igniter-web`, some controlled magic is a feature, not a failure.

Good candidates for convenience and convention:

- implicit template lookup
- route generation from named actions/pages
- compact `root` / `page` declarations
- layout inheritance
- route helpers
- form binding
- params coercion/validation ergonomics
- mounted-path awareness
- authoring sugar for stream-driven pages and long-lived flows

Still keep explicit:

- application/profile boundaries
- transport to contract handoff
- adapter seams
- transactions
- runtime ownership and lifecycle seams

## Initial Milestones

### Milestone 0. Skeleton

- create `packages/igniter-web`
- expose the package facade and namespaces
- add a short package README
- capture the current target plan in this document

### Milestone 1. `Api`

- define route/endpoint declarations for `command`, `query`, `stream`, and
  `webhook`
- define the request/response abstraction boundary
- map contracts/process/projection execution through the web transport surface

### Milestone 2. `Application`

- introduce the authoring DSL
- define page/layout/template conventions
- add wizard/process authoring ergonomics
- add stream-first page helpers for dashboards, chats, and operator surfaces

### Milestone 3. `Record`

- keep the initial surface intentionally small
- validate real app needs before deepening the abstraction
- add only the adapter hooks and authoring ergonomics we actually need

## Working Heuristic

When a web feature is proposed, ask in this order:

1. Is this a contracts/process transport concern?
2. Is this an authoring/DX concern?
3. Is this a persistence convenience concern?

That usually maps to:

- `Api`
- `Application`
- `Record`

This should help the package stay coherent while still allowing the web layer
to be substantially more ergonomic than the lower runtime layers.
