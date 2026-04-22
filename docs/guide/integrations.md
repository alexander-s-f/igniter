# Integrations

Use this page for environment-specific surfaces that adapt Igniter into a host
framework or UI/runtime package.

## Current Integration Surfaces

- `require "igniter/plugins/rails"` for Rails integration
- `require "igniter-frontend"` for human-authored web UI
- `require "igniter-schema-rendering"` for schema-driven rendering

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

- [App](../app/README.md)
- [SDK](../sdk/README.md)
- [`packages/igniter-rails/README.md`](../../packages/igniter-rails/README.md)
- [`packages/igniter-frontend/README.md`](../../packages/igniter-frontend/README.md)
- [`packages/igniter-schema-rendering/README.md`](../../packages/igniter-schema-rendering/README.md)
