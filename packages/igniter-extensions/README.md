# igniter-extensions

Public extension entrypoints for Igniter.

This package owns the `igniter/extensions/*` activation surface, including:

- `require "igniter/extensions/dataflow"`
- `require "igniter/extensions/saga"`
- `require "igniter/extensions/provenance"`
- `require "igniter/extensions/differential"`
- `require "igniter/extensions/incremental"`
- `require "igniter/extensions/contracts"`

It also provides the package facade:

- `require "igniter-extensions"`

The first contracts-facing external pack now lives here too:

- `Igniter::Extensions::Contracts::ExecutionReportPack`
- `Igniter::Extensions::Contracts::LookupPack`

That pack installs into `Igniter::Contracts` through the public facade only:

```ruby
require "igniter/extensions/contracts"

profile = Igniter::Contracts.build_kernel
  .install(Igniter::Extensions::Contracts::ExecutionReportPack)
  .install(Igniter::Extensions::Contracts::LookupPack)
  .finalize
```

Docs:

- [Guide](../../docs/guide/README.md)
- [Core guide](../../docs/guide/core.md)
- [Dev](../../docs/dev/README.md)
