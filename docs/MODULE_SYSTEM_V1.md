# Igniter Module System v1

Historical reference.

For the current canonical module-system reading, start with:

- [docs/dev/module-system.md](./dev/module-system.md)
- [docs/dev/package-map.md](./dev/package-map.md)
- [docs/sdk/README.md](./sdk/README.md)

## What This Old Document Was Defining

The V1 module-system write-up introduced three axes:

1. runtime layers
2. sdk packs
3. plugins/integrations

That three-axis model is still the right high-level architectural intuition.

## What Is Still Historically Useful

### Runtime-vs-capability-vs-integration split

The old document is still useful as background for these questions:

- what belongs in the runtime pyramid
- what belongs in sdk packs
- what belongs in environment/framework integrations

### Earlier public entrypoint map

It also captures the older public require story around:

- `igniter`
- `igniter/core`
- `igniter/server`
- `igniter/app`
- `igniter/stack`
- `igniter/cluster`
- `igniter/sdk/*`
- `igniter/plugins/rails`

## What Changed Since V1

The package-era filesystem and ownership model are now different.

In particular:

- root is intentionally thin
- packages own most canonical implementation paths
- integrations are no longer thought of primarily as `lib/igniter/plugins/*`
- package-owned docs now live beside each gem README

So older root-layout examples in the V1 module-system write-up should be read as
historical, not normative.

## If You Are Reading Old Architecture Notes

Use this file as background rationale only. For current placement and ownership
rules, always prefer:

- [docs/dev/module-system.md](./dev/module-system.md)
- [docs/dev/package-map.md](./dev/package-map.md)
- [docs/dev/architecture.md](./dev/architecture.md)
