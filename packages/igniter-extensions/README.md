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

Those packs install into `Igniter::Contracts` through the public facade only:

```ruby
require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with

result = environment.run(inputs: { rates: { ua: 0.2 } }) do
  input :rates
  lookup :tax_rate, from: :rates, key: :ua
  output :tax_rate
end
```

Docs:

- [Guide](../../docs/guide/README.md)
- [Core guide](../../docs/guide/core.md)
- [Dev](../../docs/dev/README.md)
