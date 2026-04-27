# AI And Tool Surfaces

Use this page when you need optional AI-facing, agent-facing, or tool-facing
surfaces around contracts.

Public AI and agent APIs are not stable before v1. Current examples may prove
the shape locally; reusable provider and agent behavior should graduate into
`igniter-ai` and `igniter-agents`.

## Current Surface Areas

- tools for callable operations and tool schemas
- skills for multi-step callable sub-agents
- channels for transport-neutral outbound delivery
- transcription for audio-to-text pipelines

## Practical Split

- use a tool for one atomic callable operation
- use a skill for a bounded multi-step callable unit
- use a channel for outbound delivery/notification
- use transcription when audio becomes input to a graph

## Reading Path

- [Guide: How-Tos](./how-tos.md)
- [Guide: Integrations](./integrations.md)
- [`packages/igniter-extensions/README.md`](../../packages/igniter-extensions/README.md)
- [`packages/igniter-mcp-adapter/README.md`](../../packages/igniter-mcp-adapter/README.md)
- [AI And Agents Target Plan](../dev/ai-agents-target-plan.md)

Historical AI/tool references are private working material under
`playgrounds/docs/`.
