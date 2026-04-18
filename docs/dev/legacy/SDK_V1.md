# Igniter SDK v1

Historical reference.

For the current canonical SDK reading, start with:

- [docs/guide/sdk.md](../../guide/sdk.md)
- [docs/guide/api-and-runtime.md](../../guide/api-and-runtime.md)
- [docs/dev/module-system.md](../module-system.md)

## What This Old Document Was Trying To Define

The V1 SDK write-up established three ideas that are still directionally useful:

- `sdk/*` is the public surface for optional shared capabilities
- SDK is a capability plane, not another runtime pyramid
- packs should depend downward, never upward

## The Historical Pack Set

The old built-in pack map was:

- `igniter/sdk/agents`
- `igniter/ai`
- `igniter/sdk/channels`
- `igniter/sdk/data`
- `igniter/sdk/tools`

That pack set is still the right high-level mental model.

## What Is Still Useful From V1

### Pack placement rule

SDK is still the right home when a capability is:

- optional
- shared
- reusable across multiple apps/runtimes
- not part of the minimal embedded kernel

### Pack-by-pack intuition

The old document is still useful as background for these distinctions:

- `agents` for reusable non-AI agents
- `ai` for providers, skills, transcription, and AI executors
- `channels` for transport/delivery adapters
- `data` for lightweight app-facing persistence
- `tools` for built-in operational tools, not tool primitives

## What Changed Since V1

The current docs now separate more clearly between:

- runtime layers
- sdk packs
- integrations/packages
- extensions activation entrypoints

Also, the package-era filesystem is now different from the older root-layout
assumptions. For example, the SDK implementation now lives in the package-owned
paths under `packages/igniter-sdk/`.

## If You Are Reading Old Code Or Notes

Use this file only as background rationale for why SDK exists and how the packs
were originally framed. For current package ownership, entrypoints, and loading
rules, always prefer:

- [docs/guide/sdk.md](../../guide/sdk.md)
- [docs/dev/module-system.md](../module-system.md)
- [docs/dev/package-map.md](../package-map.md)
