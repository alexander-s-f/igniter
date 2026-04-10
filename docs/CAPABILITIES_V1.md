# Capability-Based Security — v1

Capabilities let executors declare what external resources they need, and let operators
enforce policies that deny specific capabilities at runtime. This makes the security surface
of every graph visible and auditable at a glance.

## Quick Start

```ruby
require "igniter/capabilities"

# 1. Declare capabilities on executors
class DatabaseLookup < Igniter::Executor
  capabilities :database

  def call(id:)
    DB.find(id)
  end
end

class PureCalculator < Igniter::Executor
  pure  # shorthand for capabilities(:pure)

  def call(x:, y:)
    x + y
  end
end

# 2. Enforce a policy
policy = Igniter::Capabilities::Policy.new(denied: [:database])
Igniter::Capabilities.policy = policy

# 3. Execution raises CapabilityViolationError for denied nodes
class MyContract < Igniter::Contract
  define do
    input :id
    compute :record, depends_on: :id, call: DatabaseLookup
    output :record
  end
end

MyContract.new(id: 42).resolve_all
# => Igniter::Capabilities::CapabilityViolationError:
#    Node 'record' executor DatabaseLookup uses denied capabilities: database
```

## Executor DSL

### `capabilities(*caps)`

Declare one or more capabilities required by the executor.

```ruby
class EmailSender < Igniter::Executor
  capabilities :network, :external_api

  def call(to:, body:)
    Mailer.send(to: to, body: body)
  end
end
```

### `pure`

Shorthand for `capabilities(:pure)`. Marks the executor as having no side effects — its
output is fully determined by its inputs. `pure` executors participate in
[content-addressed caching](CONTENT_ADDRESSING_V1.md).

```ruby
class TaxCalculator < Igniter::Executor
  pure

  def call(amount:, rate:)
    amount * rate
  end
end
```

### `pure?`

Returns `true` if the executor declares the `:pure` capability.

```ruby
TaxCalculator.pure?  # => true
```

### Accessing declared capabilities

```ruby
EmailSender.declared_capabilities  # => [:network, :external_api]
TaxCalculator.declared_capabilities  # => [:pure]
```

## Known Capabilities

| Symbol | Meaning |
|--------|---------|
| `:pure` | No side effects; output determined by inputs only |
| `:network` | Makes outbound TCP/HTTP connections |
| `:database` | Reads or writes a database |
| `:filesystem` | Reads or writes the local filesystem |
| `:external_api` | Calls a third-party API |
| `:messaging` | Publishes to a message queue or event stream |
| `:queue` | Reads from a job or task queue |
| `:cache` | Reads or writes a distributed cache |

You can also use any custom symbol — the system does not restrict you to this list.

## Policy Enforcement

### `Igniter::Capabilities::Policy`

```ruby
policy = Igniter::Capabilities::Policy.new(denied: [:network, :filesystem])
Igniter::Capabilities.policy = policy
```

Setting the policy to `nil` disables all capability checks:

```ruby
Igniter::Capabilities.policy = nil  # no-op, all executors run freely
```

The policy is global (process-wide). It is typically set at boot time.

### `CapabilityViolationError`

Raised by the resolver at the start of `resolve_compute` before the executor is invoked.
The error includes the node name and the violated capabilities in its message:

```ruby
begin
  contract.resolve_all
rescue Igniter::Capabilities::CapabilityViolationError => e
  puts e.message
  # => "Node 'fetch_data' executor DataFetcher uses denied capabilities: network"
end
```

## Graph Introspection

After `require "igniter/extensions/capabilities"` (or `require "igniter/capabilities"`) the
compiled graph gains two introspection methods:

### `required_capabilities`

Returns a Hash of `{ node_name => [capabilities] }` for every node whose executor
declares at least one capability.

```ruby
require "igniter/capabilities"

class MyContract < Igniter::Contract
  define do
    input :id
    compute :record,   depends_on: :id, call: DatabaseLookup
    compute :total,    depends_on: :record, call: PureCalculator
    output :total
  end
end

MyContract.compiled_graph.required_capabilities
# => { record: [:database], total: [:pure] }
```

### `capabilities_for(node_name)`

Returns the declared capabilities of a single node as an array.

```ruby
MyContract.compiled_graph.capabilities_for(:record)
# => [:database]

MyContract.compiled_graph.capabilities_for(:total)
# => [:pure]

MyContract.compiled_graph.capabilities_for(:id)
# => []  (input nodes have no executor)
```

## Environment-Based Policy Pattern

A common pattern is to load the policy from environment configuration so that the
same codebase enforces different rules in development vs. production:

```ruby
# config/igniter.rb
DENIED_CAPS = case ENV["RAILS_ENV"]
              when "test"       then %i[network database filesystem]
              when "production" then []
              else                   []
              end

Igniter::Capabilities.policy = Igniter::Capabilities::Policy.new(denied: DENIED_CAPS)
```

This lets your test suite run without real I/O while production executions are unrestricted.

## Files

| File | Purpose |
|------|---------|
| `lib/igniter/capabilities.rb` | `Capabilities` module, `Policy` class, `CapabilityViolationError` |
| `lib/igniter/extensions/capabilities.rb` | Patches `CompiledGraph` with `required_capabilities` / `capabilities_for` |
| `lib/igniter/executor.rb` | `capabilities`, `pure`, `pure?`, `declared_capabilities`, `fingerprint` DSL |
| `lib/igniter/runtime/resolver.rb` | `check_capability_policy!` guard in `resolve_compute` |
| `spec/igniter/capabilities_spec.rb` | 16 examples |
