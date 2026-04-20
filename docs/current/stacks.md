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

### One Connection Point

If something is connected, it should be connected in one place.
If something is configured, it should be configured in one place.
If something can be disconnected, it should be disconnected from that same place.

The practical meaning is:

- app mounting belongs in `stack.rb`
- stack/runtime configuration belongs in `stack.yml`
- app-local configuration belongs in `apps/<app>/app.yml`
- cross-app access belongs in `app ..., access_to: [...]`
- shared stack code belongs in `lib/<project>/shared`

What we do **not** want:

- the same concern repeated in DSL + YAML + helper constants
- hidden second entrypoints for the same runtime feature
- “almost the same” configuration duplicated across several files
- coupling that is easy to add but hard to remove

The mental model should feel like one plug and one socket:

- easy to see where a thing is attached
- easy to remove it again
- no hunting across the repo to understand one runtime concern

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

More concretely:

- a node is not an app
- a node is a stack umbrella with one or more mounted apps inside it
- a node is the cluster/runtime boundary, not the code-organization boundary

Node concerns include:

- identity
- trust
- capability claims
- discovery
- governance

This is cluster territory, not app territory.

### Cluster

A cluster is a dynamic set of running stack nodes.

At bootstrap time, those nodes should be treated as equal peers.

Differentiation should happen dynamically from:

- capabilities
- trust
- availability
- policy
- current workload

Static node “roles” should not become the primary execution model.

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

- server defaults
- persistence
- optional local node launch profiles for dev / demos / home-lab
- advanced stack overrides only when they are actually needed

Minimal default shape:

```yaml
server:
  host: 0.0.0.0
  port: 4567

persistence:
  data:
    adapter: sqlite
    path: var/companion_data.sqlite3
```

When a stack really needs local multi-node boot, add node profiles explicitly:

```yaml
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

## Cluster Ignition Proposal

The next cluster boot model should likely move away from “fully pre-described
node topology” and toward “ignite from one live stack node”.

The intended metaphor is:

- one candle is lit first
- that candle lights the next ones
- the cluster grows from a seed runtime rather than from a static role map

The proposal direction is:

- one stack node can be started directly
- that node receives an `ignite` instruction
- the instruction tells it how to create or reach peer runtimes
- peers join as stack nodes
- differentiation happens later through capability publication and routing

That means the cluster bootstrap question becomes:

- where can the first node bind?
- how does it replicate locally or remotely?
- how do new peers obtain enough config to start and join?

Not:

- what fixed role does each machine have forever?

### Local Development Shape

A promising local shape looks like:

```yaml
dev:
  host: 0.0.0.0
  port: 4567
  ignite:
    replicas:
      - 4568
      - 4569
```

Meaning:

- start one stack node on `4567`
- ask it to ignite sibling local replicas on `4568` and `4569`
- let capability/trust/discovery establish the real runtime field after boot

### Remote / Production Shape

A promising remote shape looks like:

```yaml
prod:
  host: 0.0.0.0
  port: 4567
  ignite:
    servers:
      - config/ssh_rpi5_16gb_1.yml
      - config/ssh_rpi5_16gb_2.yml
      - config/ssh_hp.yml
```

Meaning:

- start or target one initial stack node
- give it a list of remote bootstrap targets
- let the runtime bring up peer stack nodes there
- let the cluster become differentiated through capabilities, not static role labels

### Important Status

This is a **proposal direction**, not yet the canonical config contract.

What is already settled:

- node = running stack umbrella
- cluster = dynamic set of stack nodes
- capabilities are the real differentiator
- static role-first cluster modeling is the wrong center

What is still open:

- exact `ignite:` schema
- whether `ignite` lives under `dev/prod` environments or another deployment section
- how much of remote bootstrap belongs to core stack runtime vs cluster replication tooling
- whether local `replicas:` should become the main replacement for current node-profile-heavy dev boot

Legacy `services/topology` compatibility has been removed from the canonical stack runtime.

## One-Line Rule

`Stack owns the server. App owns mounted functionality. Node owns distributed identity and behavior.`

## Current Structure Note

The current structure doctrine is now stricter than the older stack notes:

- `apps/<app>/` should own its own code
- `lib/<project>/shared` is only for genuinely shared stack-level code
- `igniter-frontend` with Arbre + Tailwind is the recommended app UI path
- hardcoded HTML strings in Ruby are an anti-pattern, even if some transitional generator output still uses them today
- explicit cross-app access already exists through `app ..., access_to: [...]`
  plus `App.expose`; mounted apps can read allowed interfaces through
  `App.interface(:name)`, while the stack still provides `Stack.interface(:name)`

See also [App Structure](./app-structure.md).
