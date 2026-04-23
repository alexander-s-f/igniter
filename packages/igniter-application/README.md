# igniter-application

Clean-slate contracts-native local application runtime for Igniter.

This package is intentionally separate from `igniter-app`.

- `igniter-application` is the new target package for local app assembly/runtime
- `igniter-app` remains a frozen legacy/reference package during the reset

Primary entrypoints:

- `require "igniter-application"`
- `require "igniter/application"`

Primary API:

- `Igniter::Application.build_kernel`
- `Igniter::Application.build_profile`
- `Igniter::Application.with`
- `Igniter::Application::Kernel`
- `Igniter::Application::Profile`
- `Igniter::Application::Environment`
- `Igniter::Application::Snapshot`
- `Igniter::Application::BootReport`

The application layer also now owns a first local session seam for durable
host-side orchestration around contracts-native compose/collection flows:

- configurable `session_store` seam on `Application::Kernel`
- default `MemorySessionStore`
- `Environment#run_compose_session`
- `Environment#run_collection_session`
- `Environment#compose_invoker`
- `Environment#collection_invoker`
- `Environment#remote_compose_invoker`
- `Environment#remote_collection_invoker`
- `Environment#fetch_session`
- `Environment#sessions`

That keeps local session durability in `igniter-application`, while the actual
graph semantics still live in `igniter-contracts` and `igniter-extensions`.

Remote execution is still not a cluster layer here; these helpers only define a
transport-ready adapter seam over the same session model. Real routing,
placement, and distributed coordination should arrive later in
`igniter-cluster`.

First clean external host adapter:

- `Igniter::Server::ApplicationHost`
