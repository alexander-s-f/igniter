# Human Sugar DSL Doctrine

This doctrine defines how Igniter should expose APIs to both agents and humans.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

## Decision

[Architect Supervisor / Codex] Accepted: important Igniter surfaces may have
two valid, first-class authoring forms:

1. **Agent/Clean Form** - explicit, regular Ruby objects and configuration.
2. **Human Sugar DSL** - compact, intention-revealing DSL that removes ceremony.

These forms are not "real API" vs "shortcut". They are equal public forms when
both compile to the same underlying model and can replace each other without
changing runtime meaning.

This doctrine already exists in practice for contracts:

```ruby
Igniter::Contracts.compile do
  input :amount
  output :amount
end
```

and:

```ruby
class PriceContract < Igniter::Contract
  define do
    input :amount
    output :amount
  end
end
```

The next pressure point is Embed and Contractable host configuration, especially
Rails initializers.

## Why

The current explicit Embed configuration is correct but too ceremonial for
humans in a real Rails project. It exposes every seam at once:

- root
- contract registration
- contractable role/stage
- primary/candidate callables
- async behavior
- store
- redaction
- normalization
- acceptance policy

That shape is useful for agents and low-level package tests, but it is not the
best daily authoring surface for an application developer.

Humans should be able to express intent:

- "this service is a migration candidate"
- "this contract is the candidate"
- "run the old path synchronously"
- "shadow the new path"
- "redact these inputs"
- "accept the rollout if the candidate completed"

without manually wiring every object every time.

## Doctrine

### Agent/Clean Form

The clean form should stay:

- explicit
- easy to generate
- easy to diff
- easy to test
- free of host magic
- close to package internals

It is the form agents should prefer when changing package code or producing
minimal reproducible examples.

### Human Sugar DSL

The sugar form may use controlled magic when it clearly reduces repeated
boilerplate:

- infer names from classes
- infer role from `candidate` presence
- infer normalizer/store from named conventions when configured
- group related host concerns under one domain concept
- produce the same config objects as the clean form

Sugar is allowed only when it remains inspectable. A user should be able to ask:
"what clean config did this DSL expand into?"

## Non-Negotiables

- Sugar must compile into the same lower-level model as the clean form.
- Sugar must not hide package ownership boundaries.
- Sugar must not introduce Rails dependency into base `igniter-embed`.
- Sugar must not make global mutable state the main path.
- Sugar must be optional; the clean form remains supported.
- Error messages should point to the sugar line and the expanded clean meaning.
- Docs should show both forms when the surface is important enough.
- When Igniter steps into an application boundary, anything that can reasonably
  be represented as a contract should be represented as a contract.

## Target Shape For Embed

Current clean form:

```ruby
BillingContracts = Igniter::Embed.configure(:billing) do |config|
  config.cache = !Rails.env.development?
  config.root Billing.root.join("app/contracts")
  config.contract Billing::Contracts::PriceQuoteContract,
                  as: :price_quote
end
```

Candidate sugar direction:

```ruby
BillingContracts = Igniter::Embed.host(:billing) do
  root "app/contracts"
  cache !Rails.env.development?

  contract Billing::Contracts::PriceQuoteContract,
           as: :price_quote
end
```

The exact method name is not decided. `host`, `rails_host`, `app`, `embed`, or a
class-based form may win after implementation research.

## User Candidate Syntax: Host-Centered DSL

[Architect Supervisor / Codex] User-proposed direction accepted as a primary
candidate for Task 1 evaluation. This shape keeps the single host initializer,
but makes it read as a domain-oriented declaration instead of a list of low
level assignments:

```ruby
require "igniter/embed"

Igniter::Embed.configure(:billing) do |config|
  config.owner Billing
  config.path "app/contracts"
  # config.path ["app/contracts", "engines/billing/app/contracts"]

  config.contracts do
    add :price_quote, Billing::Contracts::PriceQuoteContract do |contract|
      contract.role :migration_candidate
      contract.stage :shadowed

      contract.use :logging
      contract.use :reporting
      contract.use :validation
      contract.use :metrics
      contract.use :normalizer, BillingQuoteNormalizer

      contract.on :failure do |result|
        result.failure.each do |error|
          Billing.logger.error(error)
          # notify_contract_observer(error)
        end
      end
    end
  end
end
```

This candidate has several good instincts:

- `owner` gives the host/app identity a first-class place.
- `path` is more natural for humans than `root`, though it should expand to the
  same host-local root/path configuration.
- `contracts do ... add ... end` groups contract registration and per-contract
  host behavior in one readable block.
- `contract.use` can become a compact capability/preset surface.
- `contract.on :failure` captures lifecycle hooks without forcing every
  business contract file to define host behavior.

Important constraint: `use` must not become arbitrary hidden magic. In Igniter
space, a named capability should prefer being a contract, not a flag or opaque
preset. For example:

```ruby
contract.use :normalizer, BillingQuoteNormalizer
```

should expand to an inspectable normalizer contract or callable contract adapter
that the clean form can name explicitly.

Likewise:

```ruby
contract.use :logging
contract.use :metrics
```

should map to named capability contracts with visible manifest metadata, not
implicit global behavior.

## Contractal Capability Doctrine

[Architect Supervisor / Codex] Accepted: `contract.use` should be designed as a
fractal contract composition surface.

The default rule is:

```text
if a host capability can be modeled as a contract, model it as a contract
```

That means logging, reporting, validation, metrics, normalization, redaction,
failure handling, and comparison acceptance should be evaluated first as
contracts or contract-backed adapters. Plain lambdas and host objects may remain
valid clean-form adapters, but the preferred Igniter-native representation is a
contract.

This gives the ecosystem useful properties by default:

- capability behavior has inputs, outputs, metadata, and diagnostics
- capability execution can be observed and compared like any other contract
- host configuration stays composable instead of becoming a bag of callbacks
- migration reports can include not only business contract results but also the
  contracts that logged, normalized, validated, compared, or accepted them
- agents can reason about capabilities through the same model they use for
  business logic

Candidate interpretation:

```ruby
contract.use :logging
contract.use :metrics
contract.use :normalizer, BillingQuoteNormalizer
```

should be treated as sugar over something like:

```ruby
contract.capability :logging, Igniter::Embed::Capabilities::LoggingContract
contract.capability :metrics, Igniter::Embed::Capabilities::MetricsContract
contract.capability :normalizer, BillingQuoteNormalizer
```

The exact API is still open, but the architecture direction is not: `use`
should attach contractal capabilities where possible.

Potential clean expansion:

```ruby
container_config.owner = Billing
container_config.root = Billing.root.join("app/contracts")
container_config.contract Billing::Contracts::PriceQuoteContract,
                          as: :price_quote

contractable_config.role :migration_candidate
contractable_config.stage :shadowed
contractable_config.normalize_candidate BillingQuoteNormalizer
contractable_config.capability :logging, LoggingContract
contractable_config.capability :metrics, MetricsContract
```

Open questions for Task 1:

- Should `config.path` replace `config.root`, alias it, or stay sugar-only?
- Does `contracts.add` create only contract registration, or also a
  `Contractable` when `role` / `stage` / `use` / `on` are present?
- Should `contract.use :validation` map to `StepResultPack`, shape acceptance,
  contract diagnostics, or a host-level validation preset?
- Which `contract.use` capabilities must be first-class contracts in the first
  implementation, and which may remain callable adapters temporarily?
- Should `contract.on :failure` observe contract execution failures,
  contractable candidate failures, acceptance failures, or all of them through
  typed event names?
- How does this syntax expose `to_h` / clean expansion for debugging?

## Target Shape For Contractable

Current clean form:

```ruby
BillingPriceQuoteShadow = Igniter::Embed.contractable(:price_quote) do |config|
  config.role :migration_candidate
  config.stage :shadowed
  config.primary Billing::LegacyQuoteService
  config.candidate Billing::ContractQuoteService
  config.async true
  config.sample 1.0
  config.store BillingObservationStore
  config.redact_inputs ->(params) { params.slice(:account_id, :quote_id) }
  config.normalize_primary BillingQuoteNormalizer
  config.normalize_candidate BillingQuoteNormalizer
  config.accept :completed
end
```

Candidate sugar direction:

```ruby
BillingPriceQuoteShadow = Igniter::Embed.contractable(:price_quote) do
  migrate Billing::LegacyQuoteService,
          to: Billing::ContractQuoteService

  shadow async: true, sample: 1.0
  normalize with: BillingQuoteNormalizer
  redact_inputs :account_id, :quote_id
  accept :completed
  store BillingObservationStore
end
```

Observed-service sugar:

```ruby
BillingQuote = Igniter::Embed.contractable(:billing_quote) do
  observe Billing::QuoteService
  normalize with: BillingQuoteNormalizer
  redact_inputs :account_id, :quote_id
  store BillingObservationStore
end
```

Discovery-probe sugar:

```ruby
VendorLookupProbe = Igniter::Embed.contractable(:vendor_lookup) do
  discover VendorLookupService
  capture calls: true, timing: true, errors: true
  redact_inputs :vendor_id, :zip_code
  store DomainFlowStore
end
```

## Interchangeability Requirement

Every sugar block should be able to expose or produce its clean equivalent:

```ruby
runner = Igniter::Embed.contractable(:quote) do
  observe QuoteService
  normalize with: QuoteNormalizer
end

runner.config.to_h
```

or an equivalent structured representation.

This is important for:

- debugging
- agent handoff
- docs
- generated migrations
- production inspection

## Tasks

### Task 1: Sugar DSL Proposal

Owner: `[Agent Embed / Codex]`

Status: Next design slice.

Acceptance:

- propose exact sugar DSL for Embed host config and Contractable config
- include and evaluate the user-proposed `owner` / `path` / `contracts.add` /
  `contract.use` / `contract.on` candidate syntax
- show clean-form expansion for each sugar example
- support migration candidate, observed service, and discovery probe roles
- keep base embed Rails-free
- avoid global mutable registries as the primary path
- include inspection/debug output shape
- include error examples for ambiguous inference
- define what named capabilities such as `:logging`, `:reporting`,
  `:validation`, `:metrics`, and `:normalizer` expand into
- prefer contract-backed capabilities for `contract.use`; document any
  temporary callable-only capability as an exception
- define event semantics for `contract.on :failure`
- do not implement broad magic until the proposal is reviewed

### Task 2: Minimal Sugar Implementation

Owner: `[Agent Embed / Codex]` after Task 1 review.

Acceptance:

- sugar compiles into existing `Config` / `Contractable::Config` objects
- specs prove sugar and clean form produce equivalent observations
- docs show both forms
- examples include one migration candidate and one observed service

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Embed / Codex]` drafts Task 1 against the current Rails initializer
   pressure.
2. Keep clean form unchanged.
3. Design sugar as a layer over existing objects, not a parallel runtime.
4. If user-provided pseudocode arrives, include it as a candidate syntax and
   evaluate it against the doctrine above.

## Task 1 Proposal: Embed Host Sugar DSL

[Agent Embed / Codex] Proposal for review.

### Recommendation

Add a sugar layer over `Igniter::Embed.configure` rather than a new runtime.
The sugar should produce the same `Igniter::Embed::Config`,
`Igniter::Embed::Container`, and `Igniter::Embed::Contractable::Config` objects
that the clean form already uses.

Recommended public entrypoint:

```ruby
BillingContracts = Igniter::Embed.host(:billing) do
  owner Billing
  path "app/contracts"
  cache !Rails.env.development?

  contracts do
    add :price_quote, Billing::Contracts::PriceQuoteContract do
      migration from: Billing::LegacyQuoteService,
                to: Billing::ContractQuoteService

      shadow async: true, sample: 1.0
      use :normalizer, BillingQuoteNormalizer
      use :redaction, only: %i[account_id quote_id]
      use :acceptance, policy: :completed
      use :store, BillingObservationStore

      on :failure, contract: Billing::Contracts::ReportContractFailure
    end
  end
end
```

`Igniter::Embed.host` is sugar for `Igniter::Embed.configure`. It is not Rails
specific and must not depend on Rails. Host apps can still pass Rails-derived
values, such as `cache !Rails.env.development?`, from their initializer.

### Clean Expansion

The example above expands to the current clean form:

```ruby
BillingContracts = Igniter::Embed.configure(:billing) do |config|
  config.owner Billing
  config.root Billing.root.join("app/contracts")
  config.cache = !Rails.env.development?
  config.contract Billing::Contracts::PriceQuoteContract,
                  as: :price_quote
end

BillingPriceQuoteShadow = Igniter::Embed.contractable(:price_quote) do |config|
  config.role :migration_candidate
  config.stage :shadowed
  config.primary Billing::LegacyQuoteService
  config.candidate Billing::ContractQuoteService
  config.async true
  config.sample 1.0
  config.store BillingObservationStore
  config.redact_inputs ->(params) { params.slice(:account_id, :quote_id) }
  config.normalize_primary BillingQuoteNormalizer
  config.normalize_candidate BillingQuoteNormalizer
  config.accept :completed
  config.on :failure, Billing::Contracts::ReportContractFailure
end
```

The sugar layer should expose an inspection method:

```ruby
BillingContracts.sugar.to_h
```

or equivalent:

```ruby
BillingContracts.to_h.fetch(:sugar_expansion)
```

Minimum inspection payload:

```ruby
{
  host: :billing,
  owner: "Billing",
  root: "/app/contracts",
  contracts: [
    {
      name: :price_quote,
      class: "Billing::Contracts::PriceQuoteContract",
      contractable: {
        role: :migration_candidate,
        stage: :shadowed,
        primary: "Billing::LegacyQuoteService",
        candidate: "Billing::ContractQuoteService",
        async: true,
        sample: 1.0,
        normalizer: "BillingQuoteNormalizer",
        redaction: { only: %i[account_id quote_id] },
        acceptance: { policy: :completed },
        store: "BillingObservationStore",
        events: {
          failure: "Billing::Contracts::ReportContractFailure"
        }
      }
    }
  ]
}
```

### `owner` And `path`

`owner` gives the host identity a stable place:

```ruby
owner Billing
```

It should be metadata by default. If the owner responds to `root`, sugar may
resolve relative paths against it:

```ruby
path "app/contracts"
```

Clean expansion:

```ruby
config.owner Billing
config.root Billing.root.join("app/contracts")
```

If no owner root is available, `path` expands like current `root`:

```ruby
config.root File.expand_path("app/contracts")
```

`path` should be sugar-only or an alias over `root`; keep `root` as the clean
form because it already has documented host-local meaning.

### `contracts.add`

Recommended syntax:

```ruby
contracts do
  add :price_quote, Billing::Contracts::PriceContract
end
```

Clean expansion:

```ruby
config.contract Billing::Contracts::PriceContract, as: :price_quote
```

If the first argument is a class, infer the name exactly like
`Container#register(Class < Igniter::Contract)`:

```ruby
contracts do
  add Billing::Contracts::PriceContract
end
```

Clean expansion:

```ruby
config.contract Billing::Contracts::PriceContract, as: :price
```

Ambiguous or anonymous class examples should fail with sugar-specific context:

```ruby
contracts do
  add Class.new(Igniter::Contract)
end
```

Error:

```text
Igniter::Embed::SugarError: contracts.add could not infer a name for anonymous
contract class; use add :name, ContractClass
```

When an `add` block contains `migration`, `observe`, `discover`, `use`, `on`,
or other host behavior, sugar should create both:

- an explicit host contract registration
- a matching `Contractable` runner for the same name

### Contractable Role Sugar

Migration candidate:

```ruby
contracts do
  add :price_quote, Billing::Contracts::PriceContract do
    migration from: Billing::LegacyQuote,
              to: Billing::ContractQuote
    shadow async: true, sample: 0.25
  end
end
```

Clean expansion:

```ruby
config.contract Billing::Contracts::PriceContract, as: :price_quote

Igniter::Embed.contractable(:price_quote) do |config|
  config.role :migration_candidate
  config.stage :shadowed
  config.primary Billing::LegacyQuote
  config.candidate Billing::ContractQuote
  config.async true
  config.sample 0.25
end
```

Observed service:

```ruby
contracts do
  add :price_quote, Billing::Contracts::PriceContract do
    observe Billing::QuoteService
  end
end
```

Clean expansion:

```ruby
Igniter::Embed.contractable(:price_quote) do |config|
  config.role :observed_service
  config.stage :captured
  config.primary Billing::QuoteService
end
```

Discovery probe:

```ruby
contracts do
  add :vendor_lookup, VendorLookupContract do
    discover VendorLookupService
    capture calls: true, timing: true, errors: true
  end
end
```

Clean expansion:

```ruby
Igniter::Embed.contractable(:vendor_lookup) do |config|
  config.role :discovery_probe
  config.stage :profiled
  config.primary VendorLookupService
  config.metadata capture: { calls: true, timing: true, errors: true }
end
```

### `contract.use`

`use` is a capability attachment surface. Preferred interpretation:

```ruby
use :normalizer, BillingQuoteNormalizer
use :redaction, only: %i[account_id quote_id]
use :acceptance, policy: :shape, outputs: { total: Numeric }
use :store, BillingObservationStore
use :logging, contract: Billing::Contracts::LogContractObservation
use :reporting, contract: Billing::Contracts::ReportContractObservation
use :metrics, contract: Billing::Contracts::MeasureContractObservation
use :validation, contract: Billing::Contracts::ValidateContractObservation
```

Clean expansion:

```ruby
config.normalize_primary BillingQuoteNormalizer
config.normalize_candidate BillingQuoteNormalizer
config.redact_inputs ->(params) { params.slice(:account_id, :quote_id) }
config.accept :shape, outputs: { total: Numeric }
config.store BillingObservationStore
config.capability :logging, Billing::Contracts::LogContractObservation
config.capability :reporting, Billing::Contracts::ReportContractObservation
config.capability :metrics, Billing::Contracts::MeasureContractObservation
config.capability :validation, Billing::Contracts::ValidateContractObservation
```

Contractal capability direction:

- `:normalizer` maps to a normalizer contract when the value is a contract
  class; it may temporarily accept callable adapters because normalizers often
  already exist as service objects.
- `:redaction` maps to a redaction contract when provided; simple
  `only:`/`except:` sugar may temporarily compile to a callable adapter.
- `:acceptance` maps to the current contractable acceptance policy, with a
  future contract-backed acceptance capability allowed behind the same surface.
- `:store` maps to the store protocol. Persistence is a host boundary, so this
  remains a valid callable/object adapter unless the app explicitly supplies a
  contract-backed store.
- `:logging`, `:reporting`, `:metrics`, and `:validation` should be modeled as
  contract-backed capabilities before broad implementation. They should not
  silently become global callbacks.

First proposed contract-backed capability shape:

```ruby
use :metrics, contract: Igniter::Embed::Capabilities::MetricsContract
use :logging, contract: Igniter::Embed::Capabilities::LoggingContract
use :reporting, contract: Igniter::Embed::Capabilities::ReportingContract
use :validation, contract: Igniter::Embed::Capabilities::ValidationContract
```

Clean expansion:

```ruby
config.capability :metrics, Igniter::Embed::Capabilities::MetricsContract
config.capability :logging, Igniter::Embed::Capabilities::LoggingContract
config.capability :reporting, Igniter::Embed::Capabilities::ReportingContract
config.capability :validation, Igniter::Embed::Capabilities::ValidationContract
```

Do not implement broad built-in capability contracts in the first sugar slice.
Define the expansion shape now so the sugar does not collapse into opaque
callbacks.

### `contract.on`

Event hooks should be typed and explicit.

Recommended events:

- `:primary_success` - primary callable completed
- `:primary_error` - primary callable raised; primary error still bubbles
- `:candidate_success` - candidate callable completed
- `:candidate_error` - candidate callable or candidate normalizer failed
- `:divergence` - diff `match` is false
- `:acceptance_failure` - rollout policy rejected the candidate
- `:store_error` - store failed after the observation was built
- `:observation` - observation was built

Compatibility alias:

```ruby
on :failure do |event|
  # ...
end
```

`:failure` expands to `[:primary_error, :candidate_error,
:acceptance_failure, :store_error]`, not to value mismatch. Divergence has its
own event so teams can choose whether expected shadow differences should alert.

Event payloads should be structured and serializable:

```ruby
{
  host: :billing,
  name: :price_quote,
  role: :migration_candidate,
  stage: :shadowed,
  event: :candidate_error,
  observation: observation.to_h,
  report: observation.report&.to_h,
  error: { class: "RuntimeError", message: "candidate failed" },
  metadata: {}
}
```

Clean expansion:

```ruby
config.on_observation lambda { |observation|
  dispatch_event(:candidate_error, observation) if observation.dig(:candidate, :status) == :error
  dispatch_event(:divergence, observation) if observation[:match] == false
  dispatch_event(:acceptance_failure, observation) if observation[:accepted] == false
  dispatch_event(:store_error, observation) if observation.dig(:store, :status) == :error
}
```

Longer term, event handlers should also support contract-backed handlers:

```ruby
on :candidate_error, contract: NotifyOnCandidateError
```

### Error Examples

Ambiguous `path`:

```ruby
Igniter::Embed.host(:billing) do
  path ["app/contracts", nil]
end
```

Error:

```text
Igniter::Embed::SugarError: path entries must be strings or path-like objects
```

Missing normalizer for migration:

```ruby
contracts do
  add :price, PriceContract do
    migration from: LegacyPrice, to: ContractPrice
  end
end
```

Error:

```text
Igniter::Embed::SugarError: migration contractable :price requires
use :normalizer or explicit normalize_primary / normalize_candidate
```

Opaque capability:

```ruby
use :metrics
```

Before built-in metrics capability exists, error:

```text
Igniter::Embed::SugarError: use :metrics requires a contract-backed capability
or explicit adapter in this version
```

Ambiguous inferred contract name:

```ruby
contracts do
  add Billing::Contracts::PriceQuoteContract
  add Billing::Contracts::PriceContract
end
```

Error:

```text
Igniter::Embed::SugarError: inferred contract name :price is already
registered; use add :price_quote, Billing::Contracts::PriceQuoteContract
```

Event handler without callable or contract:

```ruby
on :failure
```

Error:

```text
Igniter::Embed::SugarError: on :failure requires a block, callable, or
contract-backed handler
```

Duplicate behavior:

```ruby
use :normalizer, A
use :normalizer, B
```

Error:

```text
Igniter::Embed::SugarError: normalizer already configured for :price
```

### Inspection Shape

Sugar objects should be inspectable before and after build:

```ruby
host = Igniter::Embed.host(:billing) do
  # ...
end

host.sugar_expansion.to_h
```

Suggested top-level keys:

- `:host`
- `:owner`
- `:paths`
- `:contracts`
- `:contractables`
- `:capabilities`
- `:events`
- `:clean_config`

This lets agents convert sugar into clean form for reviews, migrations, and
debugging.

### Implementation Order

After review, implement in small slices:

1. `Igniter::Embed.host` with `owner`, `path`, `cache`, and `contracts.add`
   only.
2. `migration` / `observe` / `discover` sugar over existing
   `Igniter::Embed.contractable`.
3. callable adapter capabilities: `:normalizer`, `:redaction`, `:acceptance`,
   `:store`.
4. event hooks over observation payload.
5. contract-backed built-in capabilities for logging, reporting, metrics, and
   validation.

Stop before step 5 if the capability contract shape needs `[Agent Contracts /
Codex]` review.

## Expert Review For Embed Handoff

[Agent Contracts / Codex] Review for `[Architect Supervisor / Codex]` ->
`[Agent Embed / Codex]`.

Overall assessment: the track is directionally sound and well balanced. The
clean form is architecturally correct, but the human sugar form is necessary
for real app initializers. A Rails/application author should be able to read
the initializer as domain intent, not as container wiring.

### Review Recommendations

1. Treat sugar as a compiler into clean config.

   The first implementation should build the same lower-level `configure`,
   `contract`, and `contractable` objects that already exist. Do not create a
   second runtime for sugar. Every sugar example in the proposal should include
   the clean expansion it produces.

2. Make inspection a release requirement.

   Human sugar is acceptable only if users and agents can inspect it. The first
   usable slice should expose a structured expansion such as
   `host.sugar_expansion.to_h` or an equivalent object with host, contracts,
   contractables, capabilities, events, and clean config.

3. Keep `contracts.add` semantics explicit.

   `contracts.add` should mean contract registration by default. If the block
   adds `role`, `stage`, `migration`, `observe`, `discover`, `use`, or `on`,
   then the sugar may create a related `Contractable` config, but the expansion
   must show that clearly.

4. Split first-class contract capabilities from temporary adapters.

   The doctrine that "if it can be represented as a contract, represent it as a
   contract" is correct for Igniter. Still, the first Embed slice should not
   require every capability to become a polished built-in contract on day one.

   Recommended split:

   - first-class contract-backed candidates: normalizer, redaction, validation,
     acceptance, reporting
   - temporary host adapters: logging, metrics, notifications, failure hooks

   Temporary adapters should be named as temporary in docs and expansion output
   so they do not become invisible ambient behavior.

5. Keep `contract.use` below host magic and above raw callbacks.

   `contract.use :normalizer, BillingQuoteNormalizer` is a good human surface,
   but its expansion should name the exact adapter or contract-backed
   capability that will run. Avoid hidden global presets.

6. Keep events typed.

   `contract.on :failure` is readable, but it should expand to a typed event
   target. The proposal should clarify whether `:failure` means contract
   execution failure, candidate failure, normalization failure, acceptance
   failure, or a combined event family.

7. Delay contracts/extensions changes until Embed proves pressure.

   `[Agent Contracts / Codex]` should not preemptively move sugar capability
   primitives into `igniter-contracts` or `igniter-extensions`. Embed should
   first show which capability adapters become awkward enough to justify a
   lower-layer seam.

### Suggested Review Gate

Before broad implementation, `[Agent Embed / Codex]` should return a proposal
with sugar and clean expansion pairs for:

- plain contract registration
- migration candidate
- observed service
- discovery probe
- `contract.use :normalizer`
- `contract.use :redaction`
- `contract.use :acceptance`
- `contract.on :failure`

If a sugar example expands into a messy clean form, fix the clean model first
instead of hiding the roughness behind DSL.

### Foundation Boundary

This review supports the sugar direction, with one boundary: Embed may own host
ergonomics, but it must not redefine contracts semantics. Contracts and
extensions remain the source of graph/runtime semantics and reusable packs.
Embed composes them for host convenience.

## Supervisor Review

[Architect Supervisor / Codex] Accepted for the next implementation slice.

The proposal and `[Agent Contracts / Codex]` review converge on the right
architecture:

- sugar is a compiler into existing clean Embed and Contractable config, not a
  second runtime
- `Igniter::Embed.host` is acceptable as the human entrypoint for the first
  slice
- `owner`, `path`, `contracts.add`, `migration`, `observe`, `discover`, `use`,
  and typed `on` events are accepted as the proposal surface to implement in
  narrow steps
- inspection is not optional; the first usable slice must expose a structured
  sugar expansion suitable for agents and users
- `contracts.add` means contract registration by default, and only creates a
  related `Contractable` when host behavior appears in the block
- `contract.use` should keep the fractal contract direction: capability
  behavior should be contract-backed when practical, and callable adapters must
  be visible as temporary host-boundary adapters in inspection output
- lower-layer contracts/extensions seams should wait until Embed proves the
  capability shape under real initializer pressure

Implementation gate for `[Agent Embed / Codex]`: start with small sugar that
can be reviewed mechanically against clean expansion. Do not implement broad
built-in logging/reporting/metrics/validation contracts in this slice.

Accepted first implementation slice:

1. `Igniter::Embed.host` as sugar over `Igniter::Embed.configure`.
2. Host DSL: `owner`, `path`, `cache`, and `contracts.add`.
3. `contracts.add` name inference and explicit-name behavior matching
   `Container#register`.
4. Structured expansion output, for example `host.sugar_expansion.to_h`.
5. Focused specs proving sugar and clean forms produce equivalent config for
   plain contract registration.

Second implementation slice, only after the first is reviewed:

1. `migration`, `observe`, and `discover` sugar over
   `Igniter::Embed.contractable`.
2. Adapter-backed `use :normalizer`, `use :redaction`, `use :acceptance`, and
   `use :store` with visible expansion output.
3. Typed event hooks with `on :failure` as an alias family, not a vague single
   callback.

## Handoff Notes

[Agent Embed / Codex] Task 1 proposal drafted for review. The proposal keeps
the clean `configure` / `contractable` forms as the expansion target, accepts
`owner`, `path`, `contracts.add`, `use`, and `on` as the primary human sugar
shape, defines migration/observed/discovery role sugar, names the first
capability expansion contracts, and treats callable-only adapters as temporary
host-boundary exceptions.

[Agent Embed / Codex] First narrow implementation slice landed for review:
`Igniter::Embed.host`, `owner`, `path`, `cache`, and `contracts.add` compile to
the existing clean config/container objects, class-name inference is shared with
`Container#register`, and `host.sugar_expansion.to_h` exposes structured
inspection. Contractable role sugar, capability sugar, built-in capabilities,
and event hooks remain intentionally unimplemented until this slice is
accepted.

[Agent Embed / Codex] Second narrow implementation slice landed for review:
`migrate` / `migration`, `observe`, `discover`, `shadow`, and `capture` now
fill the existing `Contractable::Config` shape through a small sugar builder.
Host `contracts.add` blocks can generate matching contractable configs, and
`host.sugar_expansion.to_h` now includes those generated contractables.
`contract.use`, built-in capability contracts, and `on` event hooks remain out
of scope.

[Agent Embed / Codex] Third narrow implementation slice landed for review:
`use :normalizer`, `use :redaction`, `use :acceptance`, and `use :store` now
map to existing `Contractable::Config` adapter slots and remain visible in
`host.sugar_expansion.to_h`. Unsupported broad capability sugar such as
`:logging`, `:reporting`, `:metrics`, and `:validation`, plus `on` event hooks,
remain intentionally out of scope for this slice.

[Agent Embed / Codex] Fourth narrow implementation slice landed for review:
typed event hook sugar now maps `on :candidate_error`, `on :divergence`,
`on :acceptance_failure`, `on :store_error`, `on :observation`, and
`on :primary_error` onto observation/primary-error dispatch. `on :failure` is
implemented only as an alias family for typed failure events, and generated
event handlers are visible in `host.sugar_expansion.to_h`. Broad
logging/reporting/metrics/validation capability contracts remain out of scope.

[Agent Contracts / Codex] Expert review added. The sugar direction is accepted
as user-friendly and architecturally compatible if it compiles to inspectable
clean config, keeps `contracts.add` semantics explicit, distinguishes
contract-backed capabilities from temporary host adapters, uses typed events,
and delays lower-layer contracts/extensions seams until Embed proves pressure.

[Architect Supervisor / Codex] Proposal accepted for a narrow implementation
slice. `[Agent Embed / Codex]` should implement host-level sugar and inspection
first, then return for review before adding Contractable role sugar and
capability/event sugar.

[Architect Supervisor / Codex] First narrow implementation slice reviewed and
accepted. `Igniter::Embed.host`, `owner`, `path`, `cache`, `contracts.add`, and
`host.sugar_expansion.to_h` satisfy the first-slice gate. Verification:
`bundle exec rspec packages/igniter-embed/spec/igniter/embed/host_sugar_spec.rb`
passed with 6 examples, 0 failures; `bundle exec rspec
packages/igniter-embed/spec` passed with 32 examples, 0 failures.

Next handoff: `[Agent Embed / Codex]` may begin the second implementation
slice. Implement `migration`, `observe`, and `discover` sugar over existing
`Igniter::Embed.contractable`, plus expansion output for the generated
contractables. Keep `contract.use`, built-in capability contracts, and `on`
event hooks out of this slice unless a tiny adapter is required to express
normalization/redaction/acceptance/store in the expansion. If such adapter sugar
is added, it must remain visible in `sugar_expansion.to_h` as a host-boundary
adapter, not hidden global behavior.

[Architect Supervisor / Codex] Second narrow implementation slice reviewed and
accepted with one supervisor correction. `migrate` / `migration`, `observe`,
`discover`, `shadow`, and `capture` now fill the existing
`Contractable::Config` shape, and `host.sugar_expansion.to_h` includes
generated contractables. Supervisor correction: `contracts.add` blocks now
generate a contractable only when the block actually configures contractable
behavior; an empty block remains plain contract registration. Verification:
`bundle exec rspec packages/igniter-embed/spec/igniter/embed/host_sugar_spec.rb
packages/igniter-embed/spec/igniter/embed/contractable_spec.rb` passed with 20
examples, 0 failures; `bundle exec rspec packages/igniter-embed/spec` passed
with 38 examples, 0 failures.

Next handoff: `[Agent Embed / Codex]` may begin the third slice for visible
adapter capability sugar. Implement only `use :normalizer`, `use :redaction`,
`use :acceptance`, and `use :store` as explicit host-boundary adapters with
structured expansion output. Do not implement broad built-in logging,
reporting, metrics, validation capability contracts, or `on` event hooks in
this slice.

[Architect Supervisor / Codex] Third narrow implementation slice reviewed and
accepted with one supervisor correction. `use :normalizer`, `use :redaction`,
`use :acceptance`, and `use :store` now map to existing
`Contractable::Config` adapter slots and remain visible in
`host.sugar_expansion.to_h`. Unsupported broad capability sugar such as
`:metrics` remains rejected in this slice. Supervisor correction:
`use :acceptance` without `policy:` now raises `Igniter::Embed::SugarError`
instead of leaking a low-level `KeyError`. Verification: `bundle exec rspec
packages/igniter-embed/spec/igniter/embed/host_sugar_spec.rb
packages/igniter-embed/spec/igniter/embed/contractable_spec.rb` passed with 25
examples, 0 failures; `bundle exec rspec packages/igniter-embed/spec` passed
with 43 examples, 0 failures.

Next handoff: `[Agent Embed / Codex]` may begin the fourth slice for typed
event hook sugar. Implement `on` only as explicit typed event dispatch over
existing observation data. `on :failure` may exist only as a documented alias
family for typed failure events. Keep broad built-in logging/reporting/metrics/
validation capability contracts out of this slice.

[Architect Supervisor / Codex] Fourth narrow implementation slice reviewed and
accepted. Typed `on` event hook sugar maps to explicit event handlers over
existing observation data. `on :failure` is an alias family for typed failure
events and does not include `:divergence`. `:divergence` stays separately
observable. Event handlers are visible in `host.sugar_expansion.to_h`, and
broad logging/reporting/metrics/validation capability contracts remain out of
scope. Verification: `bundle exec rspec
packages/igniter-embed/spec/igniter/embed/host_sugar_spec.rb
packages/igniter-embed/spec/igniter/embed/contractable_spec.rb` passed with 30
examples, 0 failures; `bundle exec rspec packages/igniter-embed/spec` passed
with 48 examples, 0 failures.

Next handoff: pause broad DSL expansion and pressure-test the accepted sugar in
the private SparkCRM initializer. Promote only generic findings back to this
public track: initializer readability, expansion adequacy, missing event names,
adapter friction, and whether capability contracts need a lower-layer seam.
After that pressure test, ask `[Agent Contracts / Codex]` to review the shape
for first-class contract-backed capabilities before implementing built-in
logging/reporting/metrics/validation capability contracts.

[Agent Embed / Codex] Private Rails initializer pressure test completed.
Generic findings:

- The accepted sugar is materially easier to scan than the clean form for a
  real initializer because host registration, migration/shadow role, adapters,
  and failure hooks sit in one declaration.
- `host.sugar_expansion.to_h` is adequate for review and agent handoff: it
  exposes host metadata, registered contracts, generated contractables,
  adapters, and event handlers.
- The main friction is runner materialization. `contracts.add` can generate a
  contractable config, but the host does not yet expose an ergonomic runner
  accessor or runner registry for that generated config.
- The current event set was sufficient in this pressure pass; no missing event
  name was found.
- Normalizer/redaction/acceptance/store adapter sugar was sufficient as visible
  host-boundary adapter sugar. First-class logging/reporting/metrics/validation
  capability contracts should still go to `[Agent Contracts / Codex]` before
  implementation.

[Agent Embed / Codex] Generated contractable runner materialization landed.
Hosts can now call `host.contractable(:name)` / `host.fetch_contractable(:name)`
to get a cached runner built from a generated `Contractable::Config`, and
`host.contractable_names` exposes the generated runner registry. The runner
accessor is visible in `host.sugar_expansion.to_h`, closing the private
initializer friction found in the pressure test.

## Contracts Review: Capability Contracts

[Agent Contracts / Codex] Review after `[Agent Embed / Codex]` private
initializer pressure test.

### Decision

Do not add a new `igniter-contracts` or `igniter-extensions` seam yet.

The pressure test shows that the accepted sugar and visible host-boundary
adapters are enough for normalizer, redaction, acceptance, and store concerns.
`DifferentialPack` also remains reusable through the existing embed-side
adapter, so no pre-normalized outputs seam is needed now.

First-class logging/reporting/metrics/validation should be designed as
contract-backed capabilities, but the first implementation should still live in
`igniter-embed` as host composition over existing contracts primitives. Promote
lower-layer packs only after repeated capability implementations reveal common
graph/runtime semantics.

### Capability Contract Shape

The preferred shape is explicit contract classes, not hidden global presets:

```ruby
class LogContractFailure < Igniter::Contract
  define do
    input :event
    input :observation
    input :context

    compute :log_entry, depends_on: %i[event observation context] do |event:, observation:, context:|
      {
        event: event,
        contractable: observation.fetch(:name),
        context: context
      }
    end

    output :log_entry
  end
end
```

Sugar may attach that capability:

```ruby
contract.use :logging, LogContractFailure
```

Clean expansion should show:

```ruby
contractable_config.capability :logging,
                               kind: :contract,
                               target: LogContractFailure,
                               events: [:failure]
```

If a host supplies a callable instead of a contract, inspection must name it as
a host-boundary adapter:

```ruby
contractable_config.capability :logging,
                               kind: :callable_adapter,
                               target: BillingLogger
```

### Capability Categories

Recommended first classification:

- `:normalizer`
  adapter is already sufficient; later contract-backed normalization can use a
  contract with `input :raw_result` and `output :outputs`.
- `:redaction`
  adapter is already sufficient; later contract-backed redaction can use
  `input :inputs` and `output :redacted_inputs`.
- `:acceptance`
  keep current policy adapters first. Contract-backed acceptance may later use
  `input :report`, `input :candidate`, and `output :accepted`.
- `:store`
  keep as host adapter. Persistence is not a contracts concern.
- `:logging`
  valid capability contract candidate, but side effects must go through host
  adapters or explicit `effect` adapters.
- `:reporting`
  valid capability contract candidate. Prefer serializable report outputs over
  direct rendering.
- `:metrics`
  valid capability contract candidate only if it outputs metric events; actual
  emission remains host/adapter-owned.
- `:validation`
  valid capability contract candidate. Prefer `StepResult`-style explicit
  success/failure outputs when validation is domain-level.

### Event Inputs

Capability contracts should receive typed event data, not vague callbacks.

Minimum event families:

- `:observation`
- `:candidate_error`
- `:acceptance_failure`
- `:store_error`
- `:primary_error`
- `:divergence`

`on :failure` may remain sugar over failure-family events, but the expansion
must list the concrete event names.

### Lower-Layer Promotion Rule

Promote a capability from Embed composition into `igniter-extensions` only when
all of these are true:

- at least two host use cases need the same capability semantics
- the capability can be expressed without Rails/app/persistence dependencies
- its inputs and outputs are serializable
- it improves diagnostics or graph/runtime reuse below Embed
- it can ship as an explicit pack with useful `PackManifest` metadata

Do not promote logging, reporting, metrics, or validation merely because the DSL
spelling is attractive. The first durable abstraction should be the capability
contract attachment shape, not a bundle of built-in behaviors.

### Handoff To Embed

`[Agent Embed / Codex]` may implement the next sugar slice as:

- `contract.use :logging, SomeContractOrCallable`
- `contract.use :reporting, SomeContractOrCallable`
- `contract.use :metrics, SomeContractOrCallable`
- `contract.use :validation, SomeContractOrCallable`

Constraints:

- require an explicit target in the first slice; do not add implicit built-ins
- show `kind: :contract` vs `kind: :callable_adapter` in
  `host.sugar_expansion.to_h`
- keep actual side effects host-owned
- do not add contracts/extensions packs until a repeated pattern proves the
  promotion rule above

## Supervisor Review After Pressure Test

[Architect Supervisor / Codex] Accepted.

The private SparkCRM pressure test confirms the core human sugar shape:

- one host initializer is materially easier to read than separate clean-form
  registrations and wrapper declarations
- `host.sugar_expansion.to_h` is now good enough for review, agent handoff, and
  debugging of host registration, generated contractables, adapters, and event
  handlers
- the current typed event set is sufficient for the tested Rails initializer
- normalizer/redaction/acceptance/store adapter sugar is sufficient as visible
  host-boundary adapter sugar

The main accepted finding is runner materialization friction: `contracts.add`
can generate `Contractable::Config`, but the host still needs an ergonomic way
to fetch or build the generated runner by name. This should be fixed before
expanding into broad capability sugar, because it affects the daily Rails
initializer use case directly.

`[Agent Contracts / Codex]` review is also accepted:

- no new `igniter-contracts` or `igniter-extensions` seam is needed now
- first-class logging/reporting/metrics/validation may be contract-backed, but
  the next implementation should still live in `igniter-embed` as host
  composition
- lower-layer promotion requires repeated host use cases, serializable inputs
  and outputs, app-free semantics, diagnostics/runtime reuse value, and explicit
  `PackManifest` metadata

Next implementation priority:

1. `[Agent Embed / Codex]` adds generated contractable runner materialization:
   an ergonomic host-level accessor/registry for generated contractables.
2. Keep the accessor inspectable through `sugar_expansion.to_h`.
3. Add focused specs proving generated contractables can be fetched/built and
   executed equivalently to clean `Igniter::Embed.contractable` runners.
4. Only after that, `[Agent Embed / Codex]` may add explicit-target capability
   attachment for `use :logging`, `use :reporting`, `use :metrics`, and
   `use :validation`.
5. Capability attachment must require an explicit target in the first slice and
   show `kind: :contract` vs `kind: :callable_adapter` in expansion output.

[Architect Supervisor / Codex] Generated contractable runner materialization
reviewed and accepted. Hosts can fetch a cached generated runner with
`host.contractable(:name)` / `host.fetch_contractable(:name)`, inspect
available generated runners with `host.contractable_names`, and see the runner
accessor in `host.sugar_expansion.to_h`. This closes the SparkCRM initializer
friction found in the pressure test. Verification: `bundle exec rspec
packages/igniter-embed/spec/igniter/embed/host_sugar_spec.rb
packages/igniter-embed/spec/igniter/embed/contractable_spec.rb` passed with 32
examples, 0 failures; `bundle exec rspec packages/igniter-embed/spec` passed
with 50 examples, 0 failures.

Next handoff: `[Agent Embed / Codex]` may implement explicit-target capability
attachment for `use :logging`, `use :reporting`, `use :metrics`, and
`use :validation`. This slice must not add implicit built-ins. It should accept
only explicit targets, classify each target as `kind: :contract` or
`kind: :callable_adapter`, keep side effects host-owned, and expose the
capability attachments in `host.sugar_expansion.to_h`. No
`igniter-contracts`/`igniter-extensions` seam is needed for this slice.
