# Igniter::Application v1

`Igniter::Application` is an optional base class that packages contracts, executors, YAML config, a background scheduler, and server startup into a single coherent entry point. It replaces the raw `Igniter::Server.configure` boilerplate and provides a conventional project layout.

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
├── application.rb       ← Application class (entry point)
├── application.yml      ← base config (port, log_format, etc.)
├── Gemfile
├── config.ru            ← Rack entry point for Puma / Unicorn
├── bin/start            ← convenience start script
├── contracts/           ← put Contract subclasses here
└── executors/           ← put Executor subclasses here
```

### 2. Define your Application

```ruby
# application.rb
require "igniter"
require "igniter/server"
require "igniter/application"

Dir[File.join(__dir__, "executors/**/*.rb")].sort.each { |f| require f }
Dir[File.join(__dir__, "contracts/**/*.rb")].sort.each { |f| require f }

class MyApp < Igniter::Application
  config_file File.join(__dir__, "application.yml")   # optional

  configure do |c|
    c.port  = ENV.fetch("PORT", 4567).to_i
    c.store = Igniter::Runtime::Stores::MemoryStore.new
  end

  register "OrderContract",   OrderContract
  register "InvoiceContract", InvoiceContract

  schedule :cleanup, every: "1h" do
    puts "[cleanup] #{Time.now.strftime("%H:%M")}"
  end

  schedule :daily_report, every: "1d", at: "09:00" do
    DailyReportContract.new.resolve_all(date: Date.today)
  end
end

MyApp.start if $PROGRAM_NAME == __FILE__
```

### 3. Run

```bash
# Built-in HTTP server (blocking)
ruby application.rb

# Rack / Puma
bundle exec puma config.ru
```

---

## DSL Reference

### `config_file(path)`

Load a YAML file as the base configuration. Applied **before** the `configure` block — values in the block always win.

```ruby
config_file File.join(__dir__, "application.yml")
```

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
executors_path "executors/"
contracts_path "contracts/"
```

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
server:
  port: 4567
  host: "0.0.0.0"
  log_format: text      # "text" (default) or "json"
  drain_timeout: 30     # seconds for graceful SIGTERM shutdown
```

Keys under `server:` map 1-to-1 to `AppConfig` attributes. Values from YAML are applied first; the `configure` block runs afterwards and overrides anything.

ENV variables are not expanded in YAML — read them in the `configure` block:

```ruby
configure do |c|
  c.port = ENV.fetch("PORT", 4567).to_i
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
require_relative "application"
run MyApp.rack_app
```

```bash
bundle exec puma config.ru -p 4567
```

### `MyApp.config`

Returns the `AppConfig` instance (populated after the first call to `start` or `rack_app`).

---

## Build Order

1. YAML file loaded → values applied to `AppConfig`
2. `executors_path` / `contracts_path` directories required
3. `configure` blocks run in declaration order (override YAML)
4. `Server::Config` built from `AppConfig`
5. Contracts registered on the server registry
6. Scheduler started (one thread per job)

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

`examples/companion/` is a full production-style application built with `Igniter::Application`. It implements a distributed voice AI assistant pipeline:

```
ESP32 microphone → ASR → Intent → Chat (LLM) → TTS → ESP32 speaker
```

**Single-process demo (mock executors, no hardware):**

```bash
ruby examples/companion/demo.rb
```

**Orchestrator node (HP t740, real Ollama):**

```bash
# Requires: ollama serve (llama3.1:8b pulled)
bundle exec ruby examples/companion/application.rb
```

**See also:** [`examples/companion/README.md`](../examples/companion/README.md)

---

## Integration with igniter-server

`Igniter::Application` is a thin wrapper around `Igniter::Server`. The underlying `Server::Config` and `HttpServer` are the same — you can still use `Igniter::Server.configure` directly when you don't need the Application scaffold.

The two approaches are compatible in the same process: `Igniter::Application#start` calls `Igniter::Server::HttpServer.new(config).start` internally.
