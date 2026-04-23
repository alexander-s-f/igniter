# igniter-core

Legacy monorepo gem for Igniter's historical core kernel.

`igniter-core` remains in the monorepo as a reference implementation and
migration baseline while `igniter-contracts` becomes the replacement kernel.
Public runtime entrypoints from this package emit a legacy warning by default.
Set `IGNITER_LEGACY_CORE_REQUIRE=error` to fail fast instead, or
`IGNITER_LEGACY_CORE_REQUIRE=off` to silence the notice.

Legacy scope:

- contract/model/compiler/runtime primitives
- diagnostics and extensions foundations
- stream-loop and tool base classes

Legacy entrypoints:

- `require "igniter-core"`
- `require "igniter/core"`
- `require "igniter/core/tool"`
- `require "igniter/core/memory"`
- `require "igniter/core/metrics"`

Preferred direction:

- `require "igniter-contracts"`
- `require "igniter/contracts"`
- `require "igniter/extensions/contracts"`

Docs:

- [Guide](../../docs/guide/README.md)
- [Core guide](../../docs/guide/core.md)
- [Dev](../../docs/dev/README.md)
