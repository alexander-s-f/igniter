# igniter-rails

Local monorepo gem that owns Igniter's Rails integration surface:

- `Igniter::Rails`
- `Igniter::Rails::ContractJob`
- `Igniter::Rails::WebhookHandler`
- `Igniter::Rails::CableAdapter`
- `Igniter::Rails::Railtie`

Primary entrypoints:

- `require "igniter-rails"`
- `require "igniter/plugins/rails"`

## Embedded Rails Profile

The canonical Rails scenario is still an embedded Igniter runtime inside an
existing Rails app:

```ruby
require "igniter"
require "igniter/plugins/rails"
```

Use this when Rails already owns:

- boot lifecycle
- HTTP/controller flow
- background jobs
- Action Cable or other Rails framework surfaces

And Igniter only needs to provide:

- contracts
- compile-time validation
- lazy runtime execution
- resumable executions through a configured store

## What The Rails Plugin Loads

`require "igniter/plugins/rails"` loads the embedded kernel plus the Rails
adapter package. It does not implicitly load:

- `igniter/app`
- `igniter/server`
- `igniter/cluster`

Those layers stay opt-in. If a Rails app later wants Igniter's app/server or
cluster runtime, require those entrypoints explicitly.

`require "igniter/rails"` is not a public entrypoint.

## Typical Setup

```ruby
# config/initializers/igniter.rb
require "igniter/plugins/rails"

Igniter.execution_store =
  Igniter::Runtime::Stores::ActiveRecordStore.new(
    record_class: ContractExecutionRecord
  )
```

Example integration points:

```ruby
class ProcessOrderJob < ApplicationJob
  include Igniter::Rails::ContractJob::Perform
end

class WebhooksController < ApplicationController
  include Igniter::Rails::WebhookHandler
end

class OrderChannel < ApplicationCable::Channel
  include Igniter::Rails::CableAdapter
end
```

## Boundary Contract

- `igniter-rails` owns the `Igniter::Rails` namespace.
- It is an integration package, not part of the runtime hosting pyramid.
- It should remain usable from the embedded kernel without silently promoting
  the app into `app`, `server`, or `cluster` mode.
- Framework glue belongs here; generic runtime or hosting behavior belongs in
  the runtime packages.

Docs:

- [Guide](../../docs/guide/README.md)
- [Deployment Modes](../../docs/guide/deployment-modes.md)
- [Integrations](../../docs/guide/integrations.md)
- [Dev](../../docs/dev/README.md)
