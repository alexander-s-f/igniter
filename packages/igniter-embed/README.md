# Igniter Embed

`igniter-embed` is the host-local layer for applications that want to register,
cache, and execute Igniter contracts without adopting the full application
runtime.

```ruby
contracts = Igniter::Embed.configure(:sparkcrm) do |config|
  config.cache = true
  config.pack Igniter::Contracts::ProjectPack
end

contracts.register(:tax_quote) do
  input :amount
  compute :tax, depends_on: [:amount] do |amount:|
    amount * 0.2
  end
  output :tax
end

result = contracts.call(:tax_quote, amount: 100)
result.success?
result.output(:tax)
```

For human-facing app initializers, `host` is sugar over the same host-local
configuration:

```ruby
contracts = Igniter::Embed.host(:shop) do
  owner Shop
  path "app/contracts"
  cache !Rails.env.development?

  contracts do
    add :price_quote, PriceContract
  end
end
```

For app-local contract classes, prefer host-level registration:

```ruby
class PriceContract < Igniter::Contract
  define do
    input :amount
    compute :total, depends_on: [:amount] do |amount:|
      amount * 1.2
    end
    output :total
  end
end

contracts = Igniter::Embed.configure(:shop) do |config|
  config.root "app/contracts"
  config.contract PriceContract, as: :price_quote
end

contracts.call(:price_quote, amount: 100).output(:total)
```

Named contract classes can also be registered directly:

```ruby
contracts.register(PriceContract)
contracts.call(:price, amount: 100)
```

`config.root` is the host-local directory where contract files live. It is
metadata for explicit registration unless discovery is enabled.

Discovery is opt-in:

```ruby
contracts = Igniter::Embed.configure(:shop) do |config|
  config.root "app/contracts"
  config.discover!
end
```

By default discovery requires `**/*_contract.rb` under `config.root` and
registers newly loaded, named `Class < Igniter::Contract` definitions by
inferred name. Anonymous contract classes are ignored by discovery and must be
registered explicitly with `as:` if you want to call them through the host.

Prefer explicit `config.contract` for application boot paths where stable
naming matters. If explicit registration and discovery produce the same name,
the explicit registration wins. If two discovered classes infer the same name,
discovery raises `Igniter::Embed::DiscoveryError` and asks you to register them
explicitly.

Rails integration is optional:

```ruby
require "igniter/embed/rails"

Igniter::Embed::Rails.install(
  contracts,
  reloader: Rails.application.reloader,
  cache: !Rails.env.development?
)
```

The Rails adapter only connects host reload callbacks to `container.reload!`.
The base package remains Rails-free.

## Contractable Shadowing

`igniter-contracts` owns the core `Contractable` service protocol used by
`compute using:`. The `igniter-embed` `contractable` API below is a host
wrapper for migration, shadowing, discovery, and production observation.

`contractable` wraps host services without changing their public API. The
primary callable runs synchronously and its raw result is returned; an optional
candidate can run through a shadow adapter, normalize outputs, compare through
`DifferentialPack`, and record an observation through an app-supplied store.
When `async` is true, the default adapter uses a local Ruby thread so candidate
work does not block the primary response. It is not a durable production job
queue; provide an app adapter for ActiveJob, Sidekiq, or another backend when
durability matters.

When a primary or candidate is a core `Igniter::Contracts::Contractable`
service, embed invokes it through the core protocol and adopts its declared
`role`, `stage`, and metadata as wrapper defaults unless the wrapper explicitly
overrides them.

```ruby
QuoteShadow = Igniter::Embed.contractable(:quote) do |config|
  config.role :migration_candidate
  config.stage :shadowed
  config.primary LegacyQuote
  config.candidate ContractQuote
  config.normalize_primary QuoteNormalizer
  config.normalize_candidate QuoteNormalizer
  config.accept :shape, outputs: { total: Numeric, status: String }
  config.store QuoteObservationStore
end

result = QuoteShadow.call(amount: 100)
```

The same shape can be declared through host sugar. This keeps registration,
shadow migration intent, adapters, and event hooks in one inspectable
initializer:

```ruby
contracts = Igniter::Embed.host(:billing) do
  contracts do
    add :price_quote, Billing::PriceContract do
      migrate Billing::LegacyQuote, to: Billing::ContractQuote
      shadow async: false, sample: 1.0

      use :normalizer, Billing::QuoteNormalizer
      use :redaction, only: %i[amount customer_id]
      use :acceptance, policy: :shape, outputs: { total: Numeric }
      use :store, Billing::ObservationStore

      on :divergence do |event|
        Billing.logger.warn(event)
      end
    end
  end
end

runner = contracts.contractable(:price_quote)
runner.call(amount: 100, customer_id: "cust_1", token: "secret")
```

Generated contractable runners are host-local:

```ruby
contracts.contractable_names
contracts.fetch_contractable(:price_quote)
contracts.sugar_expansion.to_h
```

`on :failure` is an alias family for typed failure events:
`:primary_error`, `:candidate_error`, `:acceptance_failure`, and
`:store_error`. Divergence is intentionally separate and should be subscribed
to with `on :divergence`.

Capability attachment sugar exists for host-owned targets. It does not install
implicit built-ins:

```ruby
contracts = Igniter::Embed.host(:billing) do
  contracts do
    add :price_quote, Billing::PriceContract do
      migrate Billing::LegacyQuote, to: Billing::ContractQuote
      use :normalizer, Billing::QuoteNormalizer

      use :logging, contract: Billing::LogObservationContract
      use :reporting, ->(event) { Billing.reporter.record(event) }
      use :metrics, target: Billing::MetricsSink
      use :validation, callable: Billing::ObservationValidator
    end
  end
end
```

Each explicit target appears in `sugar_expansion` as either `kind: :contract`
or `kind: :callable_adapter`.

Primary-only observed services use the same surface:

```ruby
ObservedQuote = Igniter::Embed.contractable(:quote) do |config|
  config.role :observed_service
  config.primary LegacyQuote
  config.normalize_primary QuoteNormalizer
  config.store QuoteObservationStore
end
```
