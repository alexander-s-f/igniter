# Contract Class DSL

Igniter contracts have two equal authoring forms:

- block compilation for low-level embedding and generated graphs
- class DSL for human-edited application code

For a runnable path across contracts, examples, application showcases, and Lang,
start with [Getting Started](./getting-started.md).

Use the class form when a Rails/service/job author needs to read the contract as
business logic.

```ruby
class PriceContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country, type: :string

    compute :vat_rate, depends_on: [:country] do |country:|
      country == "UA" ? 0.2 : 0.0
    end

    compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
      order_total * (1 + vat_rate)
    end

    output :gross_total
  end
end

contract = PriceContract.new(order_total: 100, country: "UA")
contract.result.gross_total
contract.update_inputs(order_total: 150)
contract.output(:gross_total)
```

## Why This Form Exists

The block form is still the smallest kernel surface:

```ruby
compiled = Igniter::Contracts.compile do
  input :amount
  output :amount
end
```

The class form adds the shape app code usually wants:

- one contract per file
- a compact `define do ... end` body
- result readers such as `contract.result.gross_total`
- `update_inputs` for repeated local runs
- a stable class name that host layers can register, cache, reload, and call

This is not a separate runtime. `Igniter::Contract` compiles and executes
through `igniter-contracts`.

## Callable Steps

Use blocks for local logic and `call:` for existing service objects.

```ruby
class GrossTotal
  def self.call(order_total:, vat_rate:)
    order_total * (1 + vat_rate)
  end
end

class PriceContract < Igniter::Contract
  define do
    input :order_total
    input :vat_rate
    compute :gross_total, depends_on: %i[order_total vat_rate], call: GrossTotal
    output :gross_total
  end
end
```

Callable objects receive keyword arguments named after `depends_on`.

## Result Shape

The minimum reader surface is intentionally small:

```ruby
contract = PriceContract.new(order_total: 100, vat_rate: 0.2)

contract.success?
contract.failure?
contract.outputs
contract.output(:gross_total)
contract.result.gross_total
contract.to_h
```

Unknown result readers raise a clear `KeyError`.

## Embed Hosts

`igniter-embed` consumes contract classes without redefining the DSL:

```ruby
contracts = Igniter::Embed.configure(:shop) do |config|
  config.cache = true
  config.root "app/contracts"
  config.contract PriceContract, as: :price_quote
end

result = contracts.call(:price_quote, order_total: 100, country: "UA")
result.output(:gross_total)
```

Named contract classes can also be registered directly. The inferred name uses
the last class segment, removes a trailing `Contract`, and snake-cases it:

```ruby
contracts.register(Billing::PriceContract)
contracts.call(:price, order_total: 100, country: "UA")
```

The host layer owns naming, caching, reload hooks, and failure envelopes. The
contract class owns the business graph.

`config.root` identifies the host-local contract directory. It does not load
files by itself. Automatic discovery is opt-in:

```ruby
contracts = Igniter::Embed.configure(:shop) do |config|
  config.root "app/contracts"
  config.discover!
end
```

Discovery is useful for small scripts and experiments. For application boot,
prefer explicit `config.contract SomeContract, as: :name` until you want a
convention-driven loader.

Discovery only registers named contract classes. Anonymous classes are ignored,
explicit registrations win over discovered contracts with the same name, and
duplicate discovered names raise a discovery error so hosts do not silently pick
the wrong contract.

## Design Pressure

The class DSL removes most container ceremony from app-local contracts. The next
ergonomics target is reducing repeated fail-fast and host registration boilerplate
without hiding the business graph.

## Related

- [Getting Started](./getting-started.md)
- [Igniter Lang Foundation](./igniter-lang-foundation.md)
