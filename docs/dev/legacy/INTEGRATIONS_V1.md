# Igniter Integrations v1

Historical reference.

For the current canonical integrations reading, start with:

- [docs/guide/integrations.md](./guide/integrations.md)
- [docs/dev/module-system.md](./dev/module-system.md)
- [docs/dev/package-map.md](./dev/package-map.md)

## What This Old Document Was Defining

The V1 integrations write-up explained the distinction between:

- runtime layers
- sdk capability packs
- framework/environment integrations

That distinction is still useful.

## What Is Still Historically Useful

### Why integrations are not sdk packs

The old document is still valuable as rationale for keeping framework adapters
separate from reusable optional capabilities.

### Rails as the original plugin example

It also preserves the original framing for:

- `require "igniter/plugins/rails"`
- `Igniter::Rails`
- framework-facing adapters and generators

### The earlier plugin/package language

The document captures the transition period where integrations were described
partly as `plugins/*` and partly as higher-level monorepo packages.

## What Changed Since V1

The current package-era reading is now clearer:

- Rails remains the canonical plugin-style integration surface
- frontend and schema rendering are package-owned integration surfaces
- root `plugins` namespace is no longer treated as a broad home for all optional UI work

## If You Are Reading Old Integration Notes

Use this file as background rationale only. For current placement and public
entrypoints, always prefer:

- [docs/guide/integrations.md](./guide/integrations.md)
- [docs/dev/module-system.md](./dev/module-system.md)
- [docs/dev/package-map.md](./dev/package-map.md)
