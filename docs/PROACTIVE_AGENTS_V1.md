# Proactive Agents — V1

## Concept

Standard Igniter agents are **reactive** — they wait for messages and respond.
A **proactive** agent acts *without being asked*: it polls conditions on a
schedule, evaluates rules, and fires actions when conditions are met.

```
Reactive:   external message  →  handler  →  new state
Proactive:  timer tick        →  watchers  →  triggers  →  actions  →  new state
```

`ProactiveAgent` is an experimental base class that adds four DSL keywords and
a built-in scan lifecycle on top of the standard `Igniter::Agent` API.

---

## Architecture

```
ProactiveAgent < Igniter::Agent
    │
    ├── scan_interval  — register a recurring :_scan timer
    ├── watch          — register a named poll callable
    ├── trigger        — register condition + action pair
    └── proactive_initial_state
            │
            └── :_scan handler (auto-injected into every subclass)
                    1. Call each watcher → build context Hash
                    2. Evaluate each trigger condition(ctx)
                    3. Call action(state:, context:) for truthy conditions
                    4. Append FiredTrigger records, increment scan_count
```

### Execution model

Every `scan_interval` seconds the timer fires and posts a `:_scan` message.
The same `:_scan` handler is also callable programmatically — useful in specs
and for composing proactive agents with other agents.

When `active: false` (via `:pause`) the scan cycle is a no-op; timer still
fires but watchers are not called and triggers are not evaluated.

---

## DSL Reference

### `ProactiveAgent`

| Keyword | Description |
|---|---|
| `intent "…"` | Human-readable mission string (metadata, shown in `:status`) |
| `scan_interval N` | Register a recurring timer every N seconds |
| `watch :name, poll: callable` | Named watcher; callable returns current reading |
| `trigger :name, condition:, action:` | Register a conditional action |
| `proactive_initial_state extra` | Set initial state (merges ProactiveAgent defaults) |

### Built-in handlers (injected into every subclass)

| Handler | Type | Description |
|---|---|---|
| `:_scan` | state-mutating | Run one scan cycle |
| `:pause` | state-mutating | Suspend trigger evaluation (active: false) |
| `:resume` | state-mutating | Resume trigger evaluation (active: true) |
| `:status` | sync query → `Status` | Counts, intent, watcher/trigger names |
| `:context` | sync query → Hash | Last context snapshot |
| `:trigger_history` | sync query → Array | Up to 100 most recent `FiredTrigger` records |

---

## Quick start

```ruby
require "igniter/sdk/agents/proactive_agent"

class ServerTempMonitor < Igniter::Agents::ProactiveAgent
  intent "Alert when server room temperature exceeds safe range"

  scan_interval 10.0   # check every 10 seconds

  watch :temp_c, poll: -> { SensorAPI.read_temp }

  trigger :overheating,
    condition: ->(ctx) { ctx[:temp_c].to_f > 30 },
    action:    ->(state:, context:) {
      Notifier.alert("Server room temp: #{context[:temp_c]}°C")
      state.merge(last_alert_at: Time.now)
    }

  proactive_initial_state last_alert_at: nil
end

ref = ServerTempMonitor.start
status = ref.call(:status)
# => Status(active: true, scan_count: 0, intent: "Alert when …", …)
```

---

## Subclasses — AlertAgent and HealthCheckAgent

Two production-ready proactive agents are included in the stdlib:

```
require "igniter/sdk/agents"
```

### `AlertAgent`

Threshold-based numeric monitoring with a concise DSL:

```ruby
class ApiMonitor < Igniter::Agents::AlertAgent
  intent "Watch error rate and latency"
  scan_interval 15.0

  monitor :error_rate, source: -> { Metrics.error_rate }
  monitor :p99_ms,     source: -> { Metrics.p99_latency }

  threshold :error_rate, above: 0.05   # >5% errors
  threshold :p99_ms,     above: 800    # >800ms p99
  threshold :p99_ms,     below: 1      # ghost: no traffic at all

  proactive_initial_state alerts: [], silenced: false
end

ref    = ApiMonitor.start
ref.send(:silence)             # suppress new alerts
alerts = ref.call(:alerts)     # => Array<AlertRecord>
ref.send(:clear_alerts)
```

**AlertRecord fields**: `metric`, `value`, `kind` (`:above`/`:below`),
`threshold`, `fired_at`.

### `HealthCheckAgent`

Service liveness polling with automatic transition detection:

```ruby
class InfraHealth < Igniter::Agents::HealthCheckAgent
  intent "Monitor database and cache"
  scan_interval 30.0

  # poll returns truthy = healthy, falsy / raises = unhealthy
  check :database, poll: -> { DB.ping }
  check :cache,    poll: -> { Redis.current.ping == "PONG" }

  proactive_initial_state health: {}, transitions: []
end

ref         = InfraHealth.start
health      = ref.call(:health)       # => { database: :healthy, cache: :unhealthy }
all_ok      = ref.call(:all_healthy)  # => false
transitions = ref.call(:transitions)  # => [Transition(cache: unknown→unhealthy)]
```

Transitions are only recorded when status **changes** — no duplicate events for
persistently unhealthy services.

**Transition fields**: `service`, `from`, `to`, `occurred_at`.

---

## Building your own ProactiveAgent subclass

### Pattern: layering reactive and proactive handlers

```ruby
class StockWatcher < Igniter::Agents::ProactiveAgent
  intent "Monitor stock price and fire when it crosses buy/sell thresholds"

  scan_interval 60.0

  watch :price, poll: -> { FinanceAPI.last_price("AAPL") }

  trigger :buy_signal,
    condition: ->(ctx) { ctx[:price].to_f < 150 },
    action:    ->(state:, context:) {
      state.merge(signals: state[:signals] + [{ type: :buy, price: context[:price], at: Time.now }])
    }

  proactive_initial_state signals: []

  # Reactive handler for manual context override (e.g. in tests)
  on :inject_price do |state:, payload:|
    state.merge(context: state[:context].merge(price: payload[:price]))
  end

  on :signals do |state:, **|
    state[:signals].dup
  end
end
```

### Pattern: re-injecting handlers in a concrete subclass

Because `Agent.inherited` resets `@handlers`, any handlers defined in a
parent class (like `AlertAgent`) are NOT automatically present in
`Class.new(AlertAgent)` (used in tests or further subclasses).

Both `AlertAgent` and `HealthCheckAgent` override `inherited` and call
`inject_*_handlers!(subclass)` to ensure their handlers are always present.
Follow the same pattern when building your own concrete subclass:

```ruby
class MyAgent < Igniter::Agents::ProactiveAgent
  def self.inherited(subclass)
    super                          # ProactiveAgent.inherited injects :_scan etc.
    inject_my_handlers!(subclass)
  end

  private_class_method def self.inject_my_handlers!(klass)
    klass.on(:my_query) { |state:, **| state[:my_data].dup }
  end

  on :my_query do |state:, **|
    state[:my_data].dup
  end
end
```

### Testing: drive scans without a real timer

```ruby
RSpec.describe MyAgent do
  let(:h) { ->(type, state) { MyAgent.handlers[type].call(state: state, payload: {}) } }

  def base_state(extra = {})
    { active: true, context: {}, scan_count: 0,
      last_scan_at: nil, trigger_history: [] }.merge(extra)
  end

  it "fires trigger when condition is met" do
    # Call :_scan directly — no timer, no threads
    result = h.call(:_scan, base_state)
    expect(result[:trigger_history]).not_to be_empty
  end
end
```

---

## Companion example

`examples/companion_legacy/apps/main/app/agents/` shows proactive agents in the context of
the stack-based voice assistant companion:

| File | Agent | Mission |
|---|---|---|
| `apps/main/app/agents/conversation_nudge_agent.rb` | `ConversationNudgeAgent` | Detect silence and topic stagnation; propose conversation nudges |
| `apps/main/app/agents/system_watch_agent.rb` | `SystemAlertAgent` / `DependencyHealthAgent` | Monitor API metrics and service liveness |
| `bin/demo` | All four agents | Self-contained, runnable demonstration |

```bash
ruby examples/companion_legacy/bin/demo
```

---

## API quick reference

```ruby
# Base class DSL
class MyAgent < Igniter::Agents::ProactiveAgent
  intent        "…"
  scan_interval 5.0
  watch         :metric, poll: -> { source }
  trigger       :name, condition: ->(ctx) { … }, action: ->(state:, context:) { … }
  proactive_initial_state key: default_value
end

# Runtime
ref = MyAgent.start
ref.send(:pause)                       # suspend reactions
ref.send(:resume)                      # resume
ref.call(:status)                      # => Status struct
ref.call(:context)                     # => { metric: last_reading, … }
ref.call(:trigger_history)             # => [FiredTrigger, …]

# AlertAgent
ref.send(:silence)                     # suppress new alerts
ref.send(:unsilence)
ref.call(:alerts)                      # => [AlertRecord, …]
ref.send(:clear_alerts)

# HealthCheckAgent
ref.call(:health)                      # => { service: :healthy/:unhealthy }
ref.call(:all_healthy)                 # => true | false
ref.call(:transitions)                 # => [Transition, …]
ref.send(:reset)
```
