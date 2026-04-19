# igniter-sdk

Local monorepo gem that owns Igniter's SDK registry plus non-AI optional packs:

- `Igniter::SDK`
- `Igniter::Channels`
- `Igniter::Data`
- built-in tools under `require "igniter/sdk/tools"`

AI now lives in `igniter-ai`, agents live in `igniter-agents`, and
`igniter-sdk` remains the capability registry and umbrella for pack activation.

Primary entrypoints:

- `require "igniter-sdk"`
- `require "igniter/sdk"`
- `require "igniter/sdk/channels"`
- `require "igniter/sdk/data"`
- `require "igniter/sdk/tools"`

Docs:

- [Guide](../../docs/guide/README.md)
- [SDK guide](../../docs/guide/sdk.md)
- [Dev](../../docs/dev/README.md)
