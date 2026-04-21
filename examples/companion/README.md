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
```

`bin/dev` also writes per-node logs to `var/log/dev/*.log`.

Then open:

- API status: `http://127.0.0.1:4567/v1/home/status`
- dashboard: `http://127.0.0.1:4567/dashboard`

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
