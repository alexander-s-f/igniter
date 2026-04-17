# SDK

Use this section when you need optional packs that extend Igniter without bloating the base kernel.

## SDK Means

- explicit capability packs
- layer-aware activation
- reusable optional surfaces such as AI, channels, tools, skills, and data

The SDK is a capability plane, not the foundation itself.

## Read First

- [SDK v1](../SDK_V1.md)
- [Module System v1](../MODULE_SYSTEM_V1.md)

## Capability Packs

- [LLM v1](../LLM_V1.md)
- [Channels v1](../CHANNELS_V1.md)
- [Tools v1](../TOOLS_V1.md)
- [Skills v1](../SKILLS_V1.md)
- [Transcription v1](../TRANSCRIPTION_V1.md)

## Related Reference

- [Capabilities v1](../CAPABILITIES_V1.md)
- [Plugins v1](../PLUGINS_V1.md)

## Practical Heuristic

- If a feature must always exist for `require "igniter"`, it likely belongs in [Core](../core/README.md), not SDK.
- If a feature is reusable but optional across apps or clusters, SDK is usually the right home.
