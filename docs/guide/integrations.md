# Integrations

Use this page for environment-specific surfaces that adapt Igniter into a host
framework or UI/runtime package.

## Current Integration Surfaces

- `require "igniter/plugins/rails"` for Rails integration
- `require "igniter-web"` for current human-authored web surfaces
- schema-driven rendering remains a guide-level authoring direction, not a
  current package entrypoint in this repository

## Rails Integration

Use `require "igniter/plugins/rails"` when Rails is the host application and
Igniter is embedded inside it.

That entrypoint is intentionally narrow:

- it loads the embedded Igniter kernel plus Rails adapters
- it does not silently pull `igniter/app`, `igniter/server`, or `igniter/cluster`
- it is the canonical public surface; `require "igniter/rails"` is not

Reach for it when you want controllers, jobs, or channels to call contracts
without promoting the whole app into a larger Igniter hosting profile.

## Practical Split

Use:

- runtime layers for execution/hosting concerns
- sdk packs for optional shared capabilities
- integrations for framework or environment adaptation

For Rails specifically:

- embedded Rails usage stays in integrations
- app/server/cluster remain separate runtime choices
- crossing into those layers should be explicit in code and docs

## Current Reading Path

- [App](./app.md)
- [SDK](./sdk.md)
- [`packages/igniter-embed/README.md`](../../packages/igniter-embed/README.md)
- [`packages/igniter-web/README.md`](../../packages/igniter-web/README.md)
- [`packages/igniter-extensions/README.md`](../../packages/igniter-extensions/README.md)
