# Differential Shadow Contractable Track

This public track defines the generic mechanism for comparing a synchronous
legacy implementation with a new Igniter contract-backed implementation in
real application traffic.

It also defines the broader `Contractable` concept: a host service can be made
observable, comparable, and ecosystem-addressable before it becomes a full
Igniter contract, and in some cases without ever needing to become one.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Implementation agents should report handoffs with:

```text
[Agent Embed / Codex]
[Agent Contracts / Codex]
[Agent Extensions / Codex]
```

Private application-specific services, models, and response shapes must stay in
private pressure-test docs. Public tasks here describe reusable package
behavior only.

## Decision

[Architect Supervisor / Codex] Accepted: this is a first-class Igniter
ecosystem capability, not a one-off Rails migration helper.

The first target pattern is **contractable shadow comparison**:

1. run the existing implementation synchronously and return its result to the
   caller
2. run the candidate contract-backed implementation as an optional shadow path
3. normalize both outcomes into comparable payloads
4. compare through `DifferentialPack`
5. persist a lightweight observation record when configured
6. never block the original request on the candidate path when async shadowing
   is enabled

[Architect Supervisor / Codex] Broader placement decision: `Contractable` is
the host-local bridge between opaque application services and the Igniter
contracts ecosystem. It can be used to observe, compare, migrate, or discover
business flows without changing the service's public API.

`Contractable` should therefore support multiple roles:

- `:migration_candidate`: capture a legacy service, compare it with a new
  `Igniter::Contract` implementation, and keep a handover report when the new
  contract takes over.
- `:observed_service`: make an already-good service observable and
  ecosystem-addressable without requiring a rewrite into graph DSL.
- `:discovery_probe`: wrap or instrument a service boundary to learn inputs,
  outputs, callers, timing, errors, and downstream flow before deciding what to
  extract or rewrite.

The first implementation can focus on shadow comparison, but the naming,
metadata, observation shape, and store payload must not make migration the only
valid purpose.

## Package Ownership

### `igniter-extensions`

Owns:

- `DifferentialPack`
- structured `Differential::Report`
- value comparison, tolerance, missing-output reporting, and runtime-error
  capture
- pack self-description through `PackManifest`

Does not own:

- Rails service wrapping
- app boot integration
- background job execution
- persistence adapter selection

### `igniter-embed`

Owns:

- host-local wrapping of legacy/candidate callables
- `Contractable` registration and role metadata
- production-safe shadow execution defaults
- adapter protocols for async execution and persistence
- bridge from arbitrary host service results to `DifferentialPack`
- lightweight observation of service calls without changing the service API

Does not own:

- core graph semantics
- user business comparison rules beyond supplied normalizers
- ActiveJob, Sidekiq, ActiveRecord, Redis, or Rails dependencies in base embed

### Host App

Owns:

- choosing the legacy primary and contract candidate
- choosing the `Contractable` role and lifecycle stage
- response normalization/redaction
- persistence adapter implementation
- async adapter implementation
- rollout policy, sampling, and alerting

## Contractable Lifecycle

`Contractable` is a lifecycle wrapper, not only a comparison runner.

Suggested stages:

1. `:captured` - the service is wrapped and observable; public API is unchanged.
2. `:profiled` - observations reveal inputs, outputs, errors, and call
   patterns.
3. `:shadowed` - a candidate implementation runs beside the primary.
4. `:accepted` - acceptance policies pass for the chosen rollout gate.
5. `:promoted` - the candidate becomes primary or the host app keeps the
   service as an observed non-contract boundary.
6. `:retired` - the old implementation is removed, with the migration report
   retained.

The lifecycle should be metadata and reporting first. Do not build a workflow
engine around it in the first slice.

## Contractable Roles

### Migration Candidate

Use when a legacy service may become a full `Igniter::Contract`.

Expected behavior:

- primary remains the legacy service
- candidate may be a contract-backed service or direct contract call
- comparison and acceptance policies produce a promotion report
- final state can point to the new contract as the durable implementation

### Observed Service

Use when the service is already good enough and does not need to become a graph.

Expected behavior:

- no candidate is required
- calls are observed, normalized, redacted, and persisted
- the service becomes visible to diagnostics, host maps, and future tooling
- public API stays unchanged

### Discovery Probe

Use when a large codebase needs flow reconstruction before refactoring.

Expected behavior:

- wrap or instrument service boundaries with minimal behavior change
- collect call metadata, normalized inputs/outputs, errors, timings, and
  optional caller/source metadata
- help identify domain flows and candidate contract boundaries
- avoid scattering ad hoc loggers through the codebase

## Target API Sketch

The public shape should bias toward one small host object rather than scattered
service wrappers.

Migration candidate:

```ruby
MarketingAvailabilityShadow = Igniter::Embed.contractable(:marketing_availability) do |c|
  c.role :migration_candidate
  c.stage :shadowed

  c.primary Api::Marketing::ExecutorService
  c.candidate Api::Marketing::ExecutorContractService

  c.async true
  c.sample 1.0
  c.store MarketingAvailabilityDiffStore

  c.normalize_primary { |result| MarketingAvailabilityNormalizer.call(result) }
  c.normalize_candidate { |result| MarketingAvailabilityNormalizer.call(result) }
end
```

Observed service:

```ruby
BillingQuote = Igniter::Embed.contractable(:billing_quote) do |c|
  c.role :observed_service
  c.stage :captured

  c.primary Billing::QuoteService
  c.normalize_primary BillingQuoteNormalizer
  c.store BillingObservationStore
end
```

Discovery probe:

```ruby
VendorLookupProbe = Igniter::Embed.contractable(:vendor_lookup) do |c|
  c.role :discovery_probe
  c.stage :profiled

  c.primary VendorLookupService
  c.observe calls: true, timing: true, errors: true
  c.redact_inputs VendorLookupRedactor
  c.store DomainFlowStore
end
```

Callers keep using the primary result:

```ruby
result = MarketingAvailabilityShadow.call(params)
```

When async shadowing is enabled, the primary result is returned immediately.
The candidate run, diff report, and persistence happen in the configured
background adapter.

## Contractable Runner Semantics

Required first slice:

- primary executes synchronously and its raw result is returned
- candidate executes only when configured and when shadowing is enabled for this
  call
- async defaults to `true`
- sync mode exists for tests and local debugging
- primary exceptions are not swallowed
- candidate exceptions are captured into the observation record and do not
  affect the primary response
- normalizers convert service/contract results into comparable hashes
- inputs are captured through a redaction hook before persistence
- store is optional; no configured store means the report may be emitted through
  callback/logging only
- role/stage metadata is included in observations
- observed-service mode works without a candidate

Suggested object vocabulary:

- `ContractableRunner`
- `ContractableConfig`
- `ContractableObservation`
- `ContractableStore`
- `ContractableAsyncAdapter`

The names can change, but the concepts should stay small.

## Persistence Boundary

Do not introduce heavy orchestration for the first slice. The store protocol can
be tiny:

```ruby
store.record(observation)
```

Observation payload should be serializable:

```ruby
{
  name: :marketing_availability,
  role: :migration_candidate,
  stage: :shadowed,
  mode: :shadow,
  async: true,
  sampled: true,
  started_at: "...",
  finished_at: "...",
  inputs: {},
  primary: { status: :ok, output: {} },
  candidate: { status: :ok, output: {} },
  report: {},
  match: false,
  error: nil,
  metadata: {}
}
```

Base embed may ship an in-memory store for tests. Rails/ActiveRecord persistence
should be an app adapter or optional require path, not a base dependency.

## Async Boundary

Base embed should not depend on a job backend. The async protocol can be:

```ruby
async_adapter.enqueue { candidate_and_diff_work.call }
```

For production Rails, the app can provide an ActiveJob/Sidekiq adapter later.
For the first package slice, a thread-backed adapter is acceptable only if it is
explicitly documented as local/simple and not a durable job guarantee.

## Pack Self-Description

[Architect Supervisor / Codex] Accepted direction: packs should be able to
"present themselves" for diagnostics and host tooling.

Use existing `PackManifest` as the first surface. Strengthen it only if needed:

- `name`
- `metadata[:category]`
- `metadata[:capabilities]`
- `metadata[:host_requirements]`
- `metadata[:persistence]`

Do not build a separate store registry just for this track. A small
self-description convention is enough unless implementation proves otherwise.

## Relationship To `DifferentialPack`

`DifferentialPack` is the comparison engine. Contractable shadowing is the host
runner around it.

Use `DifferentialPack` for:

- report shape
- mismatch/divergence semantics
- tolerance
- candidate runtime-error capture

Extend or wrap it only where service-vs-contract comparison needs:

- precomputed primary/candidate normalized payloads
- observation metadata
- persistence callback
- async execution boundary
- acceptance/matching policy for rollout decisions

## Tasks

### Task 1: Public Design Spike

Owner: `[Agent Embed / Codex]`, with `[Agent Extensions / Codex]` input if
available.

Status: Next design slice.

Acceptance:

- inspect existing `DifferentialPack` API and confirm what can be reused as-is
- propose exact `igniter-embed` API for contractable shadow running
- include `Contractable` roles and lifecycle metadata in the API
- define normalizer, async adapter, and store protocols
- define minimal observation shape
- define failure semantics for primary and candidate errors
- no Rails dependency in base embed
- no new hard dependency from `igniter-extensions` to `igniter-embed`
- include a public example using generic services, not private app names

### Task 2: Minimal Package Implementation

Owner: `[Agent Embed / Codex]` after Task 1 review.

Acceptance:

- host can wrap a primary callable and candidate callable
- host can wrap a primary-only observed service without a candidate
- observations include role and lifecycle stage
- primary result is returned synchronously
- candidate can run sync for tests or async through adapter
- comparison uses `DifferentialPack` or a narrow adapter over it
- acceptance policy can distinguish exact match, candidate completed, and
  expected output shape
- observation can be persisted through `store.record`
- candidate failures do not break primary response
- tests cover match, divergence, candidate exception, no-store mode, and async
  adapter enqueue behavior
- tests cover observed-service mode with no candidate

### Task 3: Differential Pack Fit Check

Owner: `[Agent Extensions / Codex]` or `[Agent Embed / Codex]` if extensions
work stays in the same thread.

Acceptance:

- decide whether `DifferentialPack.compare` needs a pre-normalized outputs path
  or whether embed can build compatible execution-result-like values
- preserve existing graph-vs-graph examples and specs
- avoid adding host concepts to `DifferentialPack`
- update pack manifest metadata if self-description needs more capability
  details

### Task 4: Private Rails Pressure Test

Owner: `[Agent Embed / Codex]`

Status: Private app task; public conclusions only.

Acceptance:

- run legacy primary synchronously
- run contract candidate as shadow, async by default
- compare normalized results
- persist divergences or all observations through a lightweight app store
- original response behavior stays unchanged
- private service names and response details remain outside public docs

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Embed / Codex]` implements Task 2 with the Task 1 design plus the
   accepted matcher/acceptance policy below and the broader `Contractable`
   role/lifecycle model above.
2. Reuse `DifferentialPack` as the comparison engine and add rollout
   acceptance as a contractable-layer policy, not as a replacement for the diff
   report.
3. Keep primary synchronous and candidate async-by-default.
4. Keep persistence as a tiny app-supplied store protocol in the first slice.

## Task 1 Design: Exact Contractable API

[Agent Embed / Codex] Proposed exact first-slice API.

### Host API

```ruby
PriceQuoteShadow = Igniter::Embed.contractable(:price_quote) do |c|
  c.role :migration_candidate
  c.stage :shadowed

  c.primary LegacyPriceQuote
  c.candidate ContractPriceQuote

  c.async true
  c.async_adapter LocalShadowAdapter
  c.sample 1.0
  c.store PriceQuoteObservationStore

  c.normalize_primary PriceQuoteNormalizer
  c.normalize_candidate PriceQuoteNormalizer
  c.redact_inputs PriceQuoteInputRedactor

  c.metadata component: "billing", rollout: "contract-v2"
end

result = PriceQuoteShadow.call(order_id: "order-1")
```

`Igniter::Embed.contractable(name) { ... }` returns a
`ContractableRunner`.

Required config:

- `primary callable`
- `candidate callable`
- `normalize_primary callable`
- `normalize_candidate callable`

Optional config:

- `role symbol`, default `:migration_candidate` when a candidate is configured,
  otherwise `:observed_service`
- `stage symbol`, default `:captured`
- `async true | false`, default `true`
- `async_adapter adapter`, default `Igniter::Embed::Contractable::InlineAsync`
  for sync mode and `ThreadAsync` only when explicitly selected
- `sample float_or_callable`, default `1.0`
- `store object`, optional
- `redact_inputs callable`, default returns `{}` unless explicitly configured
- `metadata hash_or_callable`, default `{}`
- `on_observation callable`, optional callback after observation is built
- `clock callable`, default `Time`

Callable invocation rules:

- primary is called synchronously and its raw result is returned
- candidate is called only when sampled
- services can be plain callables responding to `.call(...)`
- classes are treated as callables if they respond to `.call`; otherwise embed
  may instantiate `new` and call the instance in implementation, but explicit
  `.call` is preferred for app services
- primary exceptions are allowed to bubble to the caller and no observation is
  required
- candidate exceptions are captured into the observation and never change the
  primary return value

### Normalizer Protocol

Normalizer objects receive the raw service result and must return comparable
outputs:

```ruby
normalized = PriceQuoteNormalizer.call(result)
```

Accepted return shape:

```ruby
{
  status: :ok,
  outputs: {
    status: "accepted",
    amount: 120.0,
    currency: "USD"
  },
  metadata: {
    source_status: "success"
  }
}
```

Rules:

- `:outputs` is the only value sent into `DifferentialPack`
- `:status` should be `:ok`, `:failure`, or `:error`
- `:metadata` is optional and persisted in the observation
- normalizers are responsible for redaction and app-specific shape decisions
- normalizer exceptions are captured as side-specific `:error` outcomes

### Acceptance / Matcher Policy

[Architect Supervisor / Codex] Accepted addition after user review:
contractable comparison needs two related but separate answers:

1. `report.match?` from `DifferentialPack`: are the normalized primary and
   candidate outputs equal under the diff engine?
2. `accepted?` from contractable policy: is the candidate acceptable for the
   current rollout gate?

This lets production shadow mode start with coarse safety gates and tighten
toward exact equivalence over time.

First implementation should support three built-in policies:

```ruby
PriceQuoteShadow = Igniter::Embed.contractable(:price_quote) do |c|
  c.primary LegacyPriceQuote
  c.candidate ContractPriceQuote

  c.normalize_primary QuoteNormalizer
  c.normalize_candidate QuoteNormalizer

  c.accept :exact
end
```

```ruby
c.accept :completed
```

```ruby
c.accept :shape, outputs: {
  status: String,
  amount: Numeric,
  currency: String
}
```

Semantics:

- `:exact`: accepted only when `DifferentialPack` reports a match.
- `:completed`: accepted when the candidate ran and normalized without raising,
  regardless of output equality.
- `:shape`: accepted when candidate outputs satisfy an expected type/structure
  contract. For hash outputs, validate keys and nested value predicates without
  requiring exact values.

Observation should persist both values:

```ruby
{
  match: false,
  accepted: true,
  acceptance: {
    policy: :shape,
    failures: []
  }
}
```

Future matcher vocabulary should fit behind the same policy surface:

```ruby
c.accept :shape, outputs: {
  status: one_of("success", "failure"),
  amount: between(0, 10_000),
  currency: in(%w[USD EUR UAH])
}
```

Do not implement the full matcher DSL in the first slice. Design the internal
shape so `exact`, `completed`, and `shape` do not block later predicates such
as `one_of`, `in`, `between`, `optional`, `array_of`, or custom callables.

Placement decision:

- policy evaluation belongs in `igniter-embed` contractable runner because it
  is host rollout semantics
- reusable predicate primitives may later move into `igniter-contracts` or
  `igniter-extensions` if they prove useful outside shadow comparison
- `DifferentialPack` should continue to produce the objective diff report
  rather than deciding rollout acceptance

### Async Adapter Protocol

Base embed must not assume a durable job backend.

Protocol:

```ruby
adapter.enqueue(name:, inputs:, metadata:) do
  candidate_and_diff_work.call
end
```

Return value is ignored by the caller. Implementations may run inline, spawn a
local thread, enqueue ActiveJob, enqueue Sidekiq, or write to an app queue. Base
embed should ship only simple adapters suitable for tests/local use and document
that they are not durable production queues.

### Store Protocol

Persistence remains host-owned.

Protocol:

```ruby
store.record(observation)
```

`record` receives the full observation hash and may persist all observations,
only divergences, or only errors. Store errors should be captured into
`observation[:store_error]` and surfaced through `on_observation` or logging;
they should not affect the primary result.

### Observation Payload

Minimal serializable payload:

```ruby
{
  name: :price_quote,
  role: :migration_candidate,
  stage: :shadowed,
  mode: :shadow,
  async: true,
  sampled: true,
  started_at: "2026-04-24T12:00:00Z",
  finished_at: "2026-04-24T12:00:00Z",
  duration_ms: 12.4,
  inputs: { order_id: "redacted" },
  primary: {
    status: :ok,
    outputs: { status: "accepted", amount: 120.0 },
    metadata: {}
  },
  candidate: {
    status: :ok,
    outputs: { status: "accepted", amount: 120.0 },
    metadata: {},
    error: nil
  },
  report: {
    match: true,
    summary: "match",
    details: {}
  },
  match: true,
  error: nil,
  store_error: nil,
  metadata: { component: "billing" }
}
```

When the candidate raises:

```ruby
candidate: {
  status: :error,
  outputs: {},
  metadata: {},
  error: { type: "RuntimeError", message: "candidate exploded", details: {} }
}
```

### DifferentialPack Fit

`DifferentialPack` can already compare precomputed primary/candidate execution
results, but it currently expects `ExecutionResult`-like objects with
`outputs.to_h`. Embed can adapt normalized service outputs with a tiny internal
value object:

```ruby
ExecutionLike = Struct.new(:outputs, keyword_init: true)
OutputsLike = Struct.new(:payload, keyword_init: true) do
  def to_h = payload
end
```

No `DifferentialPack` seam is required for Task 1/2 unless implementation
proves this adapter awkward. Keep `igniter-extensions` free of host concepts.

[Architect Supervisor / Codex] Accepted with amendment: `DifferentialPack`
remains the objective comparison engine, but contractable runner must add an
acceptance policy layer. Do not overload `Differential::Report#match?` to mean
"safe enough for rollout".

### Public Example Shape

Use generic services in docs/examples:

```ruby
class LegacyPriceQuote
  def self.call(order_id:)
    { status: "accepted", amount: 120.0 }
  end
end

class ContractPriceQuote
  def self.call(order_id:)
    PriceContract.new(order_id: order_id).to_h
  end
end

PriceQuoteShadow = Igniter::Embed.contractable(:price_quote) do |c|
  c.role :migration_candidate
  c.primary LegacyPriceQuote
  c.candidate ContractPriceQuote
  c.normalize_primary QuoteNormalizer
  c.normalize_candidate QuoteNormalizer
  c.store ObservationStore
end
```

Observed service example:

```ruby
PriceQuoteObserved = Igniter::Embed.contractable(:price_quote) do |c|
  c.role :observed_service
  c.primary LegacyPriceQuote
  c.normalize_primary QuoteNormalizer
  c.store ObservationStore
end
```

### Private Pressure-Test Result

[Agent Embed / Codex] Private service pressure test applied the proposed
callable boundary by adding class-level `.call(...)` entrypoints to both legacy
primary and contract candidate services. The private host initializer now has a
guarded `Igniter::Embed.contractable(...)` declaration that will activate once
the package API lands, without changing current primary response behavior.

[Architect Supervisor / Codex] Task 1 accepted with matcher amendment. Proceed
to Task 2 implementation using `:exact`, `:completed`, and `:shape` as the
first built-in acceptance policies.

[Architect Supervisor / Codex] Additional user insight accepted: `Contractable`
is the general bridge for making legacy or existing services observable and
Igniter-addressable. Shadow diff is one role, not the whole concept. Task 2 must
support primary-only observed services and role/stage metadata even if full
discovery/profiling tooling remains a later slice.
