# igniter-app

Local monorepo gem that owns Igniter's application runtime layer:

- `Igniter::App`
- app hosts, loaders, schedulers, diagnostics, evolution, and generators

Primary entrypoints:

- `require "igniter-app"`
- `require "igniter/app"`
- `require "igniter/app/runtime"`
- `require "igniter/app/scaffold_pack"`

Contracts-native application prototype:

- `Igniter::App.build_kernel`
- `Igniter::App.build_profile`
- `Igniter::App.with`
- `Igniter::App::Kernel`
- `Igniter::App::Profile`
- `Igniter::App::Environment`
- `Igniter::App::Snapshot`
- `Igniter::App::BootReport`

Docs:

- [Guide](../../docs/guide/README.md)
- [App guide](../../docs/guide/app.md)
- [Dev](../../docs/dev/README.md)
