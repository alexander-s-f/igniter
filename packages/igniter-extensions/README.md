# igniter-extensions

Public extension entrypoints for Igniter.

This package owns the `igniter/extensions/*` activation surface, including:

- `require "igniter/extensions/dataflow"`
- `require "igniter/extensions/saga"`
- `require "igniter/extensions/provenance"`
- `require "igniter/extensions/differential"`
- `require "igniter/extensions/incremental"`

It also provides the package facade:

- `require "igniter-extensions"`

Docs:

- [Guide](../../docs/guide/README.md)
- [Core layer](../../docs/core/README.md)
- [Dev](../../docs/dev/README.md)
