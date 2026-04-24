# Differential Shadow Contractable Track

This public track defines the generic mechanism for comparing a synchronous
legacy implementation with a new Igniter contract-backed implementation in
real application traffic.

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

The target pattern is **contractable shadow comparison**:

1. run the existing implementation synchronously and return its result to the
   caller
2. run the candidate contract-backed implementation as an optional shadow path
3. normalize both outcomes into comparable payloads
4. compare through `DifferentialPack`
5. persist a lightweight observation record when configured
6. never block the original request on the candidate path when async shadowing
   is enabled

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
- production-safe shadow execution defaults
- adapter protocols for async execution and persistence
- bridge from arbitrary host service results to `DifferentialPack`

Does not own:

- core graph semantics
- user business comparison rules beyond supplied normalizers
- ActiveJob, Sidekiq, ActiveRecord, Redis, or Rails dependencies in base embed

### Host App

Owns:

- choosing the legacy primary and contract candidate
- response normalization/redaction
- persistence adapter implementation
- async adapter implementation
- rollout policy, sampling, and alerting

## Target API Sketch

The public shape should bias toward one small host object rather than scattered
service wrappers:

```ruby
MarketingAvailabilityShadow = Igniter::Embed.contractable(:marketing_availability) do |c|
  c.primary Api::Marketing::ExecutorService
  c.candidate Api::Marketing::ExecutorContractService

  c.async true
  c.sample 1.0
  c.store MarketingAvailabilityDiffStore

  c.normalize_primary { |result| MarketingAvailabilityNormalizer.call(result) }
  c.normalize_candidate { |result| MarketingAvailabilityNormalizer.call(result) }
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
- candidate executes only when shadowing is enabled for this call
- async defaults to `true`
- sync mode exists for tests and local debugging
- primary exceptions are not swallowed
- candidate exceptions are captured into the observation record and do not
  affect the primary response
- normalizers convert service/contract results into comparable hashes
- inputs are captured through a redaction hook before persistence
- store is optional; no configured store means the report may be emitted through
  callback/logging only

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

## Tasks

### Task 1: Public Design Spike

Owner: `[Agent Embed / Codex]`, with `[Agent Extensions / Codex]` input if
available.

Status: Next design slice.

Acceptance:

- inspect existing `DifferentialPack` API and confirm what can be reused as-is
- propose exact `igniter-embed` API for contractable shadow running
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
- primary result is returned synchronously
- candidate can run sync for tests or async through adapter
- comparison uses `DifferentialPack` or a narrow adapter over it
- observation can be persisted through `store.record`
- candidate failures do not break primary response
- tests cover match, divergence, candidate exception, no-store mode, and async
  adapter enqueue behavior

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

1. `[Agent Embed / Codex]` starts Task 1 and treats this as a generic
   contractable shadow-running design, not only a private Rails migration.
2. Reuse `DifferentialPack` as the comparison engine unless the design spike
   proves a precise missing seam.
3. Keep primary synchronous and candidate async-by-default.
4. Keep persistence as a tiny app-supplied store protocol in the first slice.
