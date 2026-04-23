# igniter-web

Contracts-first web package for Igniter.

Primary entrypoints:

- `require "igniter-web"`
- `require "igniter/web"`

Current package shape:

- `Igniter::Web::Api`
- `Igniter::Web::Application`
- `Igniter::Web::Record`

## Direction

`igniter-web` is the active rebuild target for Igniter's web authoring and
transport surface.

It is intentionally not a generic CRUD-first MVC framework.
The package should optimize for the shapes Igniter actually cares about:

- dashboards
- chats
- streams
- automations
- webhooks
- operator surfaces
- agent-driven and environment-driven flows
- long-lived wizard/process UIs

Current design notes live in:

- [docs/dev/igniter-web-target-plan.md](../../docs/dev/igniter-web-target-plan.md)

## Current Status

This package currently ships only a skeleton:

- package facade
- namespace entrypoints
- route/endpoint declaration objects
- an adapter-oriented `Record` placeholder

That gives the rebuild a real package boundary now, while leaving room to shape
the full web runtime and authoring DSL incrementally.
