# Embed Contract Class Integration Track

This public track coordinates the work that follows the new
`Igniter::Contract` class DSL and its consumption by `igniter-embed`.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Implementation agents should report handoffs with:

```text
[Agent Embed / Codex]
[Agent Contracts / Codex]
[Agent Application / Codex]
```

Private application-specific pressure tests may keep concrete app names,
domain models, and business-flow details outside the public repository. Public
tasks here must remain generic enough to be useful for any Rails app, job,
script, or future `igniter-application` host.

## Current Accepted State

[Architect Supervisor / Codex] Accepted:

- `igniter-contracts` owns the canonical `Igniter::Contract` class DSL.
- `igniter-contracts` exposes two equal authoring forms:
  - low-level block compilation: `Igniter::Contracts.compile { ... }`
  - class DSL: `class PriceContract < Igniter::Contract; define do ... end; end`
- `igniter-embed` consumes class contracts without redefining `define`,
  `result`, `update_inputs`, or `call:`.
- `igniter-embed` can register and execute both block definitions and
  `Class < Igniter::Contract` definitions.
- `docs/guide/contract-class-dsl.md` and examples under
  `examples/contracts/class_*.rb` are the public guide surface.

Verified:

```bash
bundle exec rspec packages/igniter-embed/spec packages/igniter-contracts/spec/igniter/contracts/contract_class_spec.rb spec/current/example_scripts_spec.rb
```

Result: `59 examples, 0 failures`.

```bash
ruby examples/contracts/class_pricing.rb
ruby examples/contracts/class_callable.rb
```

Both examples complete and print expected class DSL smoke output.

## Task 1: Zero-Ceremony Embed Registration

Owner: `[Agent Embed / Codex]`

Status: Next implementation slice.

Goal:

Let hosts register contract classes from one host-level configuration point,
without per-contract wrapper modules or hand-written container ceremony in each
business contract file.

Target shape:

```ruby
Contracts = Igniter::Embed.configure(:billing) do |config|
  config.cache = true
  config.root "app/contracts"
  config.contract Billing::PriceContract, as: :price_quote
end
```

Also evaluate whether this can be safe and unsurprising:

```ruby
Contracts.register(Billing::PriceContract)
Contracts.call(:price, order_total: 100)
```

Acceptance:

- `Igniter::Embed::Config#contract` or an equivalent public API exists for
  registering `Class < Igniter::Contract` during configuration.
- `Container#register(Class < Igniter::Contract)` either infers a stable
  snake-case name or requires `as:` with a clear Igniter-owned error.
- Explicit `as:` is supported even if inference is also supported.
- Host-level configuration remains explicit enough for reload/cache semantics.
- No Rails dependency is introduced into base `igniter-embed`.
- Specs cover explicit names.
- Specs cover inferred names if inference is implemented.
- Specs prove block registrations still work unchanged.
- Public README or guide docs show the preferred host registration shape.

Design constraints:

- Do not move class DSL ownership into `igniter-embed`.
- Do not add global mutable registries as the primary user path.
- Do not require `igniter-application`.
- Keep the API useful for Rails, jobs, scripts, and future Application hosts.

## Task 2: Host Discovery And Reload Boundary

Owner: `[Agent Embed / Codex]`

Status: Follow-up after Task 1.

Goal:

Define the smallest host-local discovery/reload boundary needed for contract
class files while keeping base embed host-agnostic.

Acceptance:

- `config.root` has a documented meaning.
- If automatic discovery is introduced, it is opt-in.
- Reload clears compiled graph cache without owning Rails itself.
- `require "igniter/embed/rails"` remains optional.
- Tests can exercise reload/cache behavior with a fake reloader.
- Public docs distinguish explicit registration from optional discovery.

## Task 3: Step Result / Fail-Fast Ergonomics Proposal

Owner: `[Agent Contracts / Codex]`

Status: Design slice, not broad implementation yet.

Goal:

Design the smallest contracts-owned primitive that removes repetitive manual
step-result and failure-threading boilerplate from business pipelines without
hiding the graph.

Candidate shapes to evaluate:

```ruby
step :validated_params, depends_on: [:params], call: ValidateParams
step :trade, depends_on: [:validated_params], call: FindTrade
halt_on_failure
```

or:

```ruby
compute :trade, depends_on: [:validated_params], halt_on: :failure do |validated_params:|
  FindTrade.call(validated_params:)
end
```

Acceptance:

- Proposal uses a real business pipeline shape as the evaluation case, but
  keeps private domain details out of public docs.
- Primitive remains useful outside Rails and outside Embed.
- Failure payloads are explicit and serializable.
- Step trace can be produced without app-local instance variables.
- No `dry-monads` dependency is introduced.
- The proposal does not become a full transaction framework.
- The proposal identifies whether implementation belongs in baseline
  `igniter-contracts` or a small optional pack.
- The proposal includes before/after authoring examples.

## Task 4: Application Consumption Check

Owner: `[Agent Application / Codex]`

Status: Deferred until Tasks 1-3 clarify the shape.

Goal:

Confirm that `igniter-application` can consume `Class < Igniter::Contract`
without going through `igniter-embed`.

Acceptance:

- Application can register or expose contract classes through public
  `igniter-contracts` APIs.
- Application does not depend on `igniter-embed`.
- Any host-specific cache/reload behavior remains outside `igniter-contracts`.
- A small example or spec proves the class DSL works in an Application context.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Embed / Codex]` implements Task 1.
2. `[Agent Embed / Codex]` updates public docs and examples for the preferred
   registration shape.
3. `[Agent Contracts / Codex]` may draft Task 3 in parallel, but should not
   implement broad fail-fast semantics until Task 1 shows how much ceremony
   remains after host registration sugar.
