# Igniter::App v1

Historical reference.

For the current canonical app model, start with:

- [docs/guide/app.md](../../guide/app.md)
- [docs/guide/deployment-modes.md](../../guide/deployment-modes.md)
- [docs/guide/configuration.md](../../guide/configuration.md)

## What This Old Document Was About

This V1 document described the earlier app/service reading where:

- `Igniter::App` often implied a service/process boundary
- more runtime detail lived directly on the app abstraction
- stack/runtime packaging was less clearly separated

That is no longer the preferred model.

## What Is Still Historically Useful

### 1. The old DSL surface

These concepts still matter even though the surrounding runtime model changed:

- `host`
- `scheduler`
- `loader`
- `config_file`
- `configure`
- `executors_path`
- `contracts_path`
- `tools_path`
- `agents_path`
- `skills_path`
- `route`
- `register`
- `schedule`

### 2. The older lifecycle framing

The old document is still useful if you are trying to understand how earlier app
boot worked around:

- `MyApp.start`
- `MyApp.rack_app`
- `MyApp.config`
- app-local `app.yml`
- isolated per-subclass registries/configuration

### 3. The old scaffold shape

It also captures the pre-package-era explanation of:

- `apps/main/app.rb`
- `apps/main/app.yml`
- `bin/start`
- `config.ru`
- root stack/app relationships

## What Changed Since V1

The current preferred reading is:

- `Igniter::App` is a leaf runtime package inside a stack
- `Igniter::Stack` owns mounted coordination and stack runtime
- `Igniter::Server` provides hosting/transport
- `Igniter::Cluster` extends that into network-aware execution
- scaffold APIs are explicit packs, not part of the smallest runtime load path

The older `--service` / `rack_service` framing is historical and not the
supported stack-runtime model going forward.

## If You Are Reading Old Code

Use this file only as a glossary for older app/service language. For behavior and
entrypoints that should guide new work, always prefer:

- [docs/guide/app.md](../../guide/app.md)
- [docs/current/stacks.md](../../current/stacks.md)
- [docs/guide/cli.md](../../guide/cli.md)
