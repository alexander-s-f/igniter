# Companion

`examples/companion` is the public flagship assistant app for Igniter.

Its job is not only to demonstrate APIs in isolation, but to exercise Igniter
as a real product runtime:

- assistant-facing workflows
- operator-facing follow-up and visibility
- contracts, agents, tools, and skills in one stack
- portable multi-app composition through explicit app boundaries

The current slice is intentionally small, but honest:

- `main` owns the assistant-side API surface
- `dashboard` owns the operator desk
- one shared overview API feeds the operator surface
- one shared note flow proves cross-app persistence and explicit app-to-app access

This is the starting point, not the finished vision.

## Bootstrapping

```bash
cd examples/companion
bundle install
ruby bin/demo
bin/console
bin/start
bin/dev
bin/dev-cluster
```

`bin/dev` also writes per-node logs to `var/log/dev/*.log`.
`bin/dev-cluster` starts a local multi-replica cluster simulation from the same
directory by using the `dev-cluster` environment profile.

Then open:

- API status: `http://127.0.0.1:4567/v1/home/status`
- dashboard: `http://127.0.0.1:4567/dashboard`

Local cluster mode also starts:

- replica-1: `http://127.0.0.1:4568/dashboard`
- replica-2: `http://127.0.0.1:4569/dashboard`

## Local Cluster Persistence

`Companion` keeps local cluster persistence separate per node even when all
replicas run from the same repo checkout.

- single-node mode uses `examples/companion/var`
- `bin/dev-cluster` uses `examples/companion/var/dev-cluster/nodes/<node>`
- each node gets its own execution stores and note store
- replicas do not share one SQLite file

That means the local cluster imitation is honest about the default storage
boundary: one node, one local persistence root.

## Current Direction

Use Companion to evolve the public assistant product in thin vertical slices
rather than copying a whole production-shaped system up front.

Good next moves are:

1. one real assistant workflow
2. one real operator follow-up loop
3. one useful tool or skill slice
4. one restored execution path

Only after those feel coherent should Companion pull in deeper distributed
capabilities like routed remote agents or `ignite`-driven expansion.

## Design Rule

Companion should aim to become better and more capable than `OpenClaw`, but it
should do that by making Igniter's strengths tangible:

- explicit runtime contracts
- durable sessions
- operator-visible orchestration
- app portability
- later, trustworthy distributed execution
