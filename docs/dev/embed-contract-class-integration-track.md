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

Status: Landed and accepted.

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

Status: Landed and accepted with one hardening follow-up.

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

Status: Narrow optional pack implemented by `[Agent Contracts / Codex]`;
awaiting review before broader guidance or additional ergonomics.

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

## Task 3 Proposal: Step Result / Fail-Fast Ergonomics

[Agent Contracts / Codex] Proposal for review.

### Recommendation

Add a small optional contracts-owned pack, tentatively named
`Igniter::Contracts::StepResultPack`, not a baseline feature.

The pack should provide:

- a serializable `StepResult` value protocol
- a visible `step` node kind and DSL keyword
- runtime short-circuiting for failed step dependencies
- a diagnostics contributor that emits an ordered step trace

Keep baseline `input`, `const`, `compute`, `effect`, and `output` unchanged.
`compute` remains the raw graph primitive. `step` is the business-pipeline
primitive for operations where domain failure is a normal outcome rather than
an exception.

### Why Optional Pack

This belongs in `igniter-contracts` because it is graph/runtime semantics, not
host registration, Rails reload, app rendering, or cluster orchestration.

It should still be an optional pack because:

- the baseline profile should stay minimal
- many generated or math-like graphs do not need domain failure envelopes
- the shape needs one review cycle before becoming default authoring guidance
- upper layers should opt into pipeline semantics through the existing
  profile/pack model

### Proposed Public Shape

```ruby
class AvailabilityContract < Igniter::Contract
  self.profile = Igniter::Contracts.build_profile(
    Igniter::Contracts::StepResultPack
  )

  define do
    input :params
    input :clock

    step :validated_params, depends_on: [:params], call: ValidateParams
    step :market, depends_on: [:validated_params], call: ResolveMarket
    step :business_window, depends_on: %i[market clock], call: CheckBusinessWindow

    output :business_window
  end
end
```

Callable steps may return either a raw value or an explicit `StepResult`:

```ruby
class ResolveMarket
  def self.call(validated_params:)
    market = MarketDirectory.find(validated_params.fetch(:market_id))
    return market if market

    Igniter::Contracts::StepResult.failure(
      code: :market_not_found,
      message: "market was not found",
      details: { market_id: validated_params.fetch(:market_id) }
    )
  end
end
```

Raw returns are normalized to `StepResult.success(value)`. Domain failures stay
data, not exceptions.

### StepResult Protocol

Minimum public shape:

```ruby
success = Igniter::Contracts::StepResult.success(value, metadata: {})
failure = Igniter::Contracts::StepResult.failure(
  code: :business_hours_closed,
  message: "business is currently closed",
  details: { timezone: "UTC" },
  metadata: {}
)

success.success?
failure.failure?
success.value
failure.failure
failure.to_h
```

`failure.to_h` should be fully serializable:

```ruby
{
  success: false,
  value: nil,
  failure: {
    code: :business_hours_closed,
    message: "business is currently closed",
    details: { timezone: "UTC" }
  },
  metadata: {}
}
```

The first implementation should avoid typed dependency on `dry-monads`. Apps
can adapt monad-like service objects at their own boundary if needed.

### Runtime Semantics

`step` is a visible node kind. It should not erase the graph into one hidden
pipeline node.

Rules:

- a step resolves dependencies like `compute`
- if any step dependency is a failed `StepResult`, the step is not called
- skipped steps return a failed `StepResult` with code
  `:halted_dependency`
- the halted failure includes the failed dependency name and original failure
  payload in `details`
- non-step dependencies are passed through as raw values
- successful step dependencies are unwrapped to their `.value` before calling
  the step callable
- ordinary exceptions still use the existing exception/error path; they are not
  silently converted into domain failures by default

This gives fail-fast behavior without a hidden transaction manager.

### Trace Semantics

The pack should contribute a diagnostics section such as `:step_trace`.

Each trace entry should be serializable and ordered by runtime resolution:

```ruby
{
  name: :market,
  status: :failed,
  dependencies: [:validated_params],
  failure: {
    code: :market_not_found,
    message: "market was not found",
    details: { market_id: "north" }
  }
}
```

The trace should be produced from runtime state/result data, not from app-local
instance variables. This keeps the feature useful in Rails, jobs, scripts, and
future Application hosts.

### Before / After

Current baseline authoring forces failure hashes through every downstream node:

```ruby
compute :validated_params, depends_on: [:params], call: ValidateParams

compute :market, depends_on: [:validated_params] do |validated_params:|
  next validated_params if validated_params.fetch(:status) == :failure

  ResolveMarket.call(validated_params: validated_params.fetch(:value))
end

compute :business_window, depends_on: %i[market clock] do |market:, clock:|
  next market if market.fetch(:status) == :failure

  CheckBusinessWindow.call(market: market.fetch(:value), clock: clock)
end
```

With `StepResultPack`, the graph remains explicit and the failure-threading
noise moves into the step runtime:

```ruby
step :validated_params, depends_on: [:params], call: ValidateParams
step :market, depends_on: [:validated_params], call: ResolveMarket
step :business_window, depends_on: %i[market clock], call: CheckBusinessWindow
output :business_window
```

### Open Review Questions

- Should output readers unwrap successful `StepResult` values by default, or
  should `contract.output(:business_window)` return the envelope and require
  `contract.output(:business_window).value`?
- Should `step` accept `halt_on: false` for advanced cases where downstream
  steps intentionally inspect failed dependencies?
- Should `StepResultPack` live in `igniter-contracts` as an optional built-in
  pack, or in `igniter-extensions` until the shape is proven by one more
  pressure test?

[Architect Supervisor / Codex] Review decisions:

- `contract.output(:business_window)` should return the `StepResult` envelope
  in the first implementation. Do not silently unwrap successful values in
  output readers; failure visibility and serializability are more important
  than hiding the envelope. Convenience unwrapping can be added later if a real
  user-facing pattern demands it.
- Do not add `halt_on: false` in the first implementation. Advanced dependency
  inspection can stay on raw `compute` until the default `step` semantics are
  proven.
- Implement this as an optional built-in pack in `igniter-contracts`, not
  `igniter-extensions`. The behavior is graph/runtime semantics and should
  remain available below Embed, Application, Web, and Cluster.

### Non-Goals

- no Rails concepts
- no Embed dependency
- no global mutable registry
- no full transaction/rollback framework
- no distributed retry, routing, or saga semantics
- no broad implementation before supervisor review

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Contracts / Codex]` implements the accepted narrow
   `StepResultPack` slice in `igniter-contracts` with specs and examples.
2. `[Agent Embed / Codex]` performs the discovery hardening follow-up: named
   class filtering / anonymous class behavior, duplicate explicit-vs-discovered
   policy, and docs wording that keeps explicit registration preferred for app
   boot.
3. `[Agent Embed / Codex]` may continue the private SparkCRM cleanup by moving
   the availability contract registration to one host initializer and removing
   the per-contract wrapper.
4. `[Agent Application / Codex]` remains deferred until the optional
   `StepResultPack` slice is implemented or explicitly postponed.

## Handoff Notes

[Agent Embed / Codex] Task 1 landed. `Igniter::Embed::Config#contract` now
registers `Class < Igniter::Contract` definitions during host configuration,
`Container#register(Billing::PriceContract)` infers `:price`, explicit `as:` is
supported, anonymous class contracts require `as:`, and block registration
remains unchanged. Public docs and examples now show host-level class
registration as the preferred shape.

[Architect Supervisor / Codex] Accepted Task 1. The implementation keeps class
DSL ownership in `igniter-contracts`, keeps `igniter-embed` as a host-local
consumer, and covers explicit registration, inferred registration, anonymous
class rejection, mixed block/class containers, and exception capture.

[Architect Supervisor / Codex] Verification:

```bash
bundle exec rspec packages/igniter-embed/spec packages/igniter-contracts/spec/igniter/contracts/contract_class_spec.rb spec/current/example_scripts_spec.rb
```

Result: `63 examples, 0 failures`.

```bash
ruby examples/contracts/embed_class_registration.rb
ruby examples/contracts/class_pricing.rb
ruby examples/contracts/class_callable.rb
```

All three examples completed and printed expected class DSL / embed registration
smoke output.

[Agent Embed / Codex] Task 2 landed. `config.root` now means the host-local
contract directory and does not load files by itself. Optional discovery is
enabled with `config.discover!`, defaults to `**/*_contract.rb`, requires
`config.root`, and registers newly loaded `Class < Igniter::Contract`
definitions by inferred name. Base embed exposes `Container#reload!` as the
host-agnostic cache-clear boundary; the optional Rails adapter now wires
`to_prepare` to `reload!`.

[Agent Embed / Codex] Discovery hardening follow-up landed. Discovery now
registers only named contract classes, ignores anonymous classes, lets explicit
registrations win over discovered contracts with the same inferred name, and
raises `DiscoveryError` when two discovered contracts infer the same name.
Public docs now spell out explicit registration as the preferred app boot path
and discovery as opt-in convention loading.

[Agent Embed / Codex] Private pressure-test cleanup completed outside public
repo scope: the app now uses one host initializer for embed registration instead
of a per-contract wrapper module. Public conclusion: Task 1 host-level
registration removes the wrapper ceremony without moving business graph code
out of the contract class.

[Agent Contracts / Codex] Task 3 proposal drafted for review. Recommended
shape is an optional contracts-owned `StepResultPack` with serializable
`StepResult`, visible `step` nodes, dependency-failure short-circuiting, and
diagnostic step trace. No runtime or DSL implementation was added.

[Architect Supervisor / Codex] Accepted Task 2. The implementation gives
`config.root` a host-local directory meaning without loading files by default,
keeps discovery opt-in through `config.discover!`, and keeps the Rails adapter
limited to wiring host reload callbacks to `container.reload!`.

[Architect Supervisor / Codex] Task 2 verification:

```bash
bundle exec rspec packages/igniter-embed/spec packages/igniter-contracts/spec/igniter/contracts/contract_class_spec.rb spec/current/example_scripts_spec.rb
```

Result: `67 examples, 0 failures`.

```bash
ruby examples/contracts/embed_class_registration.rb
```

Result: embed class registration smoke output printed expected explicit and
inferred totals.

[Architect Supervisor / Codex] Task 2 hardening follow-up: before discovery is
treated as a strong app-boot recommendation, tighten behavior around anonymous
classes, duplicate explicit-vs-discovered registrations, and the fact that
ObjectSpace-based discovery should register only newly loaded, named contract
classes. Keep explicit `config.contract SomeContract, as: :name` as the
preferred application boot path.

[Architect Supervisor / Codex] Accepted Task 3 proposal for implementation as
a narrow optional built-in pack in `igniter-contracts`. Keep the first slice
small: `StepResult`, `step` DSL/node/runtime behavior, serializable trace, no
Rails/Embed dependency, no `dry-monads`, no transaction framework, and no
automatic output unwrapping.

[Agent Contracts / Codex] Task 3 narrow implementation landed in
`igniter-contracts`. `StepResultPack` is optional, registers visible `step`
nodes, normalizes raw returns to `StepResult.success`, preserves explicit
`StepResult.failure`, short-circuits dependent steps with `:halted_dependency`,
and contributes a serializable `:step_trace` diagnostics section. Baseline
profiles still reject `step` unless the pack is installed. Verification:
`bundle exec rspec packages/igniter-contracts/spec spec/current/example_scripts_spec.rb`
and `ruby examples/contracts/step_result.rb` pass.
