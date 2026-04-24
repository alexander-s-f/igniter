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
