# Igniter Channels v1

Historical reference.

For the current canonical reading, start with:

- [docs/guide/ai-and-tools.md](./guide/ai-and-tools.md)
- [docs/guide/sdk.md](../../guide/sdk.md)

## What This Old Document Was About

The V1 write-up framed `Igniter::Channels` as the transport-neutral outbound
communication layer.

## What Is Still Historically Useful

- the distinction between channel delivery and app/framework integration
- the generic message-envelope idea
- early webhook and Telegram adapter examples

## What Changed Since V1

Channels now sit more clearly inside the SDK capability plane and should be read
through that current layer map first.
