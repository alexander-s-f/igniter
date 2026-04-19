# Igniter Stack/App Next

This document fixes the current direction for `Igniter::Stack` and `Igniter::App`.

It supersedes the more ceremony-heavy shape where runtime topology, ports, and process thinking were spread across too many files too early.

## Thesis

`Igniter::Stack` should be the server and composition root.

`apps/` should be mountable pluggable modules that live under the stack umbrella.

The desired reading experience for a stack should be:

- open `stack.rb`
- open `stack.yml`
- open `bin/start` or `bin/console` if you want the runtime entrypoint
- understand almost everything important

## Core Rule

### Stack

The stack owns:

- server lifecycle
- app mounting
- shared persistence and shared libraries
- local node launch profiles for development and experiments

The stack is the runtime container.

### App

An app owns:

- contracts
- executors
- tools
- agents
- skills
- routes and handlers
- app-local wiring

An app should be portable.

The ideal app story is:

- copy the app folder into another stack
- register it in `stack.rb`
- mount it
- it works

That also means:

- app-local code should live inside the app
- stack-level `lib` should not become the default home for app code
- if an app needs another app, that relationship should be explicit rather than hidden in shared helpers

An app is not the deployable unit by default.

### Node

A node is a running copy of the stack inside the cluster.

Node concerns include:

- identity
- trust
- capability claims
- discovery
- governance

This is cluster territory, not app territory.

## Design Decision

We now prefer:

- one server container per stack process
- many mounted apps inside that process
- multiple local node instances created by launching the same stack with different node profiles

We explicitly do **not** want the architecture to imply:

- one app = one server
- one app = one port
- one app = one deployable

## Configuration Direction

The strong configuration points should be:

- `stack.rb`
- `stack.yml`

### `stack.rb`

Should answer:

- which apps exist
- which app is the root app
- which apps are mounted

Example shape:

```ruby
class Stack < Igniter::Stack
  root_dir __dir__
  shared_lib_path "lib"

  app :main, path: "apps/main", klass: MainApp, default: true
  app :dashboard, path: "apps/dashboard", klass: DashboardApp

  mount :dashboard, at: "/dashboard"
end
```

### `stack.yml`

Should answer:

- stack metadata
- server defaults
- persistence
- optional local node launch profiles for dev / demos / home-lab

Example shape:

```yaml
stack:
  name: companion
  root_app: main
  default_node: seed
  shared_lib_paths:
    - lib

server:
  host: 0.0.0.0

nodes:
  seed:
    port: 4667
  edge:
    port: 4668
  analyst:
    port: 4669

persistence:
  data:
    adapter: sqlite
    path: var/companion_data.sqlite3
```

## Runtime Entry Points

The canonical stack-first boot surface is now:

- `bin/start`
- `bin/start --node NAME`
- `bin/console`
- `bin/console --node NAME`
- `bin/dev`

See [CLI](./CLI.md) for the short operational guide.

## What Moves Out Of The Center

These concepts are no longer part of the supported stack model:

- `topology.yml`
- `default_service`
- `replicas`
- deployment-role-driven app boot

## Important Distinction

Local multi-node development is a harness, not the architecture.

That means:

- the stack stays the same
- `bin/dev` can launch several node profiles
- cluster behavior comes from runtime identity/capabilities/trust
- not from a static topology document pretending to be the source of truth

The preferred direction is now:

1. stack-mounted runtime by default
2. node profiles in `stack.yml` for local multi-node boot
3. apps as portable mounted modules

Legacy `services/topology` compatibility has been removed from the canonical stack runtime.

## One-Line Rule

`Stack owns the server. App owns mounted functionality. Node owns distributed identity and behavior.`

## Current Structure Note

The current structure doctrine is now stricter than the older stack notes:

- `apps/<app>/` should own its own code
- `lib/<project>/shared` is only for genuinely shared stack-level code
- `igniter-frontend` with Arbre + Tailwind is the recommended app UI path
- hardcoded HTML strings in Ruby are an anti-pattern, even if some transitional generator output still uses them today

See also [App Structure](./app-structure.md).
