# Igniter::Application v1

`Igniter::Application` is the leaf runtime for one app inside an Igniter workspace.

It packages contracts, executors, YAML config, a background scheduler, and host
startup into a single coherent entry point. By default that host is
`Igniter::Server`, but the application layer now owns the assembly lifecycle and
delegates deployment/runtime specifics through a host adapter seam. It replaces the
raw `Igniter::Server.configure` boilerplate and is usually coordinated by a root
`Igniter::Workspace`.

See [WORKSPACES_V1.md](./WORKSPACES_V1.md) for the standard `apps/` layout.

---

## Quick Start

### 1. Generate a scaffold

```bash
igniter-server new my_app
cd my_app
bundle install
bin/start
```

This creates:

```
my_app/
├── workspace.rb         ← Workspace coordinator
├── workspace.yml        ← workspace metadata
├── apps/
│   └── main/
│       ├── application.rb
│       ├── application.yml
│       ├── app/
│       │   ├── contracts/
│       │   ├── executors/
│       │   ├── tools/
│       │   ├── agents/
│       │   └── skills/
│       └── spec/
├── lib/my_app/shared/   ← shared libraries / helpers
├── bin/start            ← convenience start script
├── bin/demo             ← runnable smoke demo
├── Gemfile
├── config.ru            ← Rack entry point for Puma / Unicorn
└── spec/                ← shared + integration + workspace-level specs
```

### 2. Define your leaf app

```ruby
# apps/main/application.rb
require "igniter/app"
require "igniter/core"

module MyApp
  class MainApp < Igniter::Application
    root_dir __dir__
    config_file "application.yml"
    host :server

    executors_path "app/executors"
    contracts_path "app/contracts"

    configure do |c|
      c.port  = ENV.fetch("PORT", 4567).to_i
      c.store = Igniter::Runtime::Stores::MemoryStore.new
    end

    on_boot do
      register "OrderContract",   MyApp::OrderContract
      register "InvoiceContract", MyApp::InvoiceContract
    end

    schedule :cleanup, every: "1h" do
      puts "[cleanup] #{Time.now.strftime("%H:%M")}"
    end

    schedule :daily_report, every: "1d", at: "09:00" do
      MyApp::DailyReportContract.new.resolve_all(date: Date.today)
    end
  end
end
```

`require "igniter/app"` is the canonical umbrella entrypoint. It loads the default
server host pack for you, which in turn brings in the server runtime, and it also
loads the default threaded scheduler pack for recurring background jobs plus the
default filesystem loader pack for eager app code loading. Scaffold generation is
now a separate explicit pack loaded through `require "igniter/app/scaffold_pack"`.
`MyApp.start` and `MyApp.rack_app` also activate the server remote transport for you.
If you want to resolve `remote:` nodes outside a hosted app lifecycle, activate
`Igniter::Server` or `Igniter::Cluster` transport explicitly.

Host selection is now declarative at the application layer:

```ruby
class MainApp < Igniter::Application
  host :server   # default
end

require "igniter/cluster"

class ClusterApp < Igniter::Application
  host :cluster
end
```

If you need a completely custom runtime host, `host_adapter SomeAdapter.new` still
works as the escape hatch. The `:server` profile is registered by
`require "igniter/app"`, while `:cluster` is registered when the cluster
entrypoint is loaded.

Background job execution is similarly pluggable:

```ruby
scheduler :threaded   # default
```

and custom adapters can be selected through the scheduler registry.

Application code loading is pluggable too:

```ruby
loader :filesystem   # default eager file loader
```

If your application uses scaffold generation APIs such as
`Igniter::Application::Generator`, load `require "igniter/app/scaffold_pack"`.
Internally, `require "igniter/app"` now assembles its runtime behavior via
`require "igniter/app/runtime_pack"` and
`require "igniter/app/workspace_pack"`.
If you want just the leaf application runtime without workspace support, use
`require "igniter/app/runtime"` instead.

If your application uses custom tools or agents, also load `require "igniter/core"`.
If it uses the built-in operational tool pack, load `require "igniter/tools"`.
If it uses skills, providers, or `Igniter::AI.configure`, also load `require "igniter/ai"`.

### 3. Run through the workspace

```bash
bin/start
bin/start main

# Rack / Puma
bundle exec puma config.ru
```

The generated root `workspace.rb` is a workspace coordinator; it selects the leaf app
and calls `MainApp.start` under the hood.

---

## DSL Reference

### `host(name)`

Select the canonical application host profile.

```ruby
host :server   # default single-node host
host :cluster  # cluster-aware host
```

This keeps host choice declarative while preserving `host_adapter(...)` for custom
adapters. `host :cluster` requires `require "igniter/cluster"` so the cluster host
pack can register itself.

### `register_host(name) { ... }`

Register an additional host profile in the application host registry.

```ruby
register_host :inline do
  MyInlineHost.new
end

host :inline
```

The registered builder can also accept the application class as an argument if it
needs app-specific wiring.

### `scheduler(name)`

Select the canonical background job runtime for `schedule`.

```ruby
scheduler :threaded   # default in-process scheduler
```

### `register_scheduler(name) { ... }`

Register an additional scheduler adapter profile.

```ruby
register_scheduler :inline do
  MyInlineScheduler.new
end

scheduler :inline
```

### `loader(name)`

Select the code-loading strategy used before `on_boot`.

```ruby
loader :filesystem   # default eager loader for app/**/*.rb paths
```

### `register_loader(name) { ... }`

Register an additional code-loader adapter profile.

### `config_file(path)`

Load a YAML file as the base configuration. Applied **before** the `configure` block — values in the block always win.

```ruby
root_dir __dir__
config_file "application.yml"
```

`root_dir __dir__` makes relative paths resolve from the app directory (`apps/main/`),
not from the repo root.

### `configure { |c| ... }`

Block receives an `AppConfig` instance. May be called multiple times; blocks are applied in order.

```ruby
configure do |c|
  c.host              = "0.0.0.0"
  c.port              = 4567
  c.log_format        = :json          # :text (default) or :json
  c.drain_timeout     = 30             # seconds for SIGTERM drain
  c.store             = my_store       # any store adapter
  c.metrics_collector = Igniter::Metrics::Collector.new
end
```

### `executors_path(path)` / `contracts_path(path)`

Eagerly require all `.rb` files under the given directory on startup.

```ruby
executors_path "app/executors"
contracts_path "app/contracts"
```

Related entrypoints:

- `tools_path(path)`
- `agents_path(path)`
- `skills_path(path)`

### `route(method, path, with: nil) { ... }`

Register a custom app-level HTTP endpoint. This is useful for inbound webhooks,
Telegram bot updates, or lightweight internal callbacks that should live inside
the leaf app rather than in a separate Rack service.

```ruby
route "POST", "/telegram/webhook" do |params:, body:, headers:, raw_body:, **|
  { ok: true, received: body }
end
```

Or delegate to a callable object:

```ruby
route "POST", "/telegram/webhook", with: MyApp::TelegramWebhook
```

Callable handlers receive:

- `params:` — named path captures for regex routes
- `body:` — parsed JSON request body
- `headers:` — normalized request headers
- `raw_body:` — raw request body string
- `env:` — Rack env when running under Rack, otherwise `nil`
- `config:` — current host runtime config (`Igniter::Server::Config` when using the default server host)

Return either:

- a plain object / hash → auto-wrapped as `200` JSON
- or a full response hash with `status`, `body`, and optional `headers`

### `register(name, contract_class)`

Register a contract for HTTP dispatch.

```ruby
register "OrderContract", OrderContract
```

### `schedule(name, every:, at: nil) { ... }`

Define a recurring background job. Starts automatically with `start` / `rack_app`.

```ruby
schedule :heartbeat, every: "30s" do
  HealthCheckContract.new.resolve_all
end

schedule :daily_report, every: "1d", at: "09:00" do
  DailyReportContract.new.resolve_all(date: Date.today)
end
```

**Interval formats:**

| Format | Meaning |
|--------|---------|
| `30` | 30 seconds (Integer) |
| `"30s"` | 30 seconds |
| `"5m"` | 5 minutes |
| `"2h"` | 2 hours |
| `"1d"` | 1 day |
| `{ hours: 1, minutes: 30 }` | 90 minutes |

`at: "HH:MM"` delays the first run until the next occurrence of that wall-clock time, then repeats with `every:`.

---

## application.yml Reference

```yaml
server_host:
  port: 4567
  host: "0.0.0.0"
  log_format: text      # "text" (default) or "json"
  drain_timeout: 30     # seconds for graceful SIGTERM shutdown
```

Keys under `server_host:` map 1-to-1 to the default server host settings. Legacy
`server:` is still accepted for compatibility. Values from YAML are applied first;
the `configure` block runs afterwards and overrides anything.

ENV variables are not expanded in YAML — read them in the `configure` block:

```ruby
configure do |c|
  c.server_host.port = ENV.fetch("PORT", 4567).to_i
end
```

---

## Lifecycle

### `MyApp.start`

Builds the config, registers contracts, starts background jobs, then starts the built-in pure-Ruby HTTP server (blocking). Registers `at_exit` to stop the scheduler.

### `MyApp.rack_app`

Same as `start` but returns a Rack-compatible application instead of blocking. Use with Puma, Unicorn, or any Rack server:

```ruby
# config.ru
require_relative "workspace"
run MyApp::Workspace.rack_app(:main)
```

```bash
bundle exec puma config.ru -p 4567
```

### `MyApp.config`

Returns the `AppConfig` instance (populated after the first call to `start` or `rack_app`).

---

## Build Order

1. YAML file loaded → values applied to `AppConfig`
2. `executors_path` / `contracts_path` / `tools_path` / `agents_path` / `skills_path` directories loaded
3. `on_boot` blocks run
4. `configure` blocks run in declaration order (override YAML)
5. `HostConfig` built from `AppConfig`
6. Concrete host adapter maps `HostConfig` into its runtime config
7. Contracts and custom routes registered on the runtime config
8. Scheduler started (one thread per job)

---

## Subclass Isolation

Each `Igniter::Application` subclass gets its own isolated set of registered contracts, scheduled jobs, and configure blocks via the `inherited` hook. Subclasses do not share state:

```ruby
class AppA < Igniter::Application
  register "ContractA", ContractA
end

class AppB < Igniter::Application
  register "ContractB", ContractB
end
# AppA and AppB have completely independent registries
```

---

## Companion App Example

`examples/companion/` is the main workspace-based production-style demo. It implements a distributed voice AI assistant pipeline split across `apps/main` and `apps/inference`.

```
ESP32 microphone → ASR → Intent → Chat (LLM) → TTS → ESP32 speaker
```

**Single-process demo (mock executors, no hardware):**

```bash
ruby examples/companion/bin/demo
```

**Orchestrator node (HP t740, real Ollama):**

```bash
# Requires: ollama serve (llama3.1:8b pulled)
bundle exec ruby examples/companion/workspace.rb main
```

**See also:** [`examples/companion/README.md`](../examples/companion/README.md) and [`examples/companion_legacy/README.md`](../examples/companion_legacy/README.md)

---

## Integration with igniter-server

`Igniter::Application` is a thin wrapper around hosting, with `Igniter::Server` as the
default host adapter. You can still use `Igniter::Server.configure` directly when you
don't need the application/profile scaffold.

The two approaches are compatible in the same process: the default application host
eventually delegates to `Igniter::Server::HttpServer`, but that server-specific wiring
now lives in `Igniter::Application::ServerHost`, not in `Igniter::Application` itself.

For cluster-aware app hosting, the canonical adapter is now
`Igniter::Application::ClusterHost`.
That keeps the host model application-facing while still reusing the cluster/server
runtime implementation underneath.
