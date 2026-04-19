# SDK

Use this section when you need optional packs that extend Igniter without bloating the base kernel.

## SDK Means

- explicit capability packs
- layer-aware activation
- reusable optional surfaces such as AI, channels, tools, skills, and data

The SDK is a capability plane, not the foundation itself.

## Current First Reads

- [Guide](../guide/README.md)
- [Guide: How-Tos](../guide/how-tos.md)
- [Guide: API And Runtime](../guide/api-and-runtime.md)
- [Guide: AI And Tool Surfaces](../guide/ai-and-tools.md)
- [Module System](../dev/module-system.md)

## Supporting Reference

- [Guide: AI And Tool Surfaces](../guide/ai-and-tools.md)
- [Guide: Integrations](../guide/integrations.md)
- [Dev: Legacy Reference](../dev/legacy-reference.md)

## Current SDK Model

`sdk/*` is the optional capability plane, not another runtime pyramid.

- core stays minimal
- runtime layers stay responsible for hosting/distribution
- sdk packs provide optional shared capabilities that higher layers opt into explicitly

Canonical public entrypoints:

- `require "igniter/agents"`
- `require "igniter/ai"`
- `require "igniter/ai/agents"`
- `require "igniter/sdk/channels"`
- `require "igniter/sdk/data"`
- `require "igniter/sdk/tools"`

Activation can happen either by explicit `require` or through `use`, which is
just a thin declarative wrapper over normal loading.

## Pack Placement Rule

Put code in SDK when it is:

- optional
- shared
- reusable across more than one app/runtime
- not part of the minimal embedded kernel

Do not put code in SDK when it is better described as:

- core execution machinery
- app/server/cluster hosting behavior
- extension activation glue
- framework integration

## Practical Heuristic

- If a feature must always exist for `require "igniter"`, it likely belongs in [Core](../core/README.md), not SDK.
- If a feature is reusable but optional across apps or clusters, SDK is usually the right home.
