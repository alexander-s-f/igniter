# Round Report: ruby-framework PORT-2026-05-20-RUBY-P1 minimal-receipt-shape

Status: done
Date: 2026-05-20
Supervisor: [Igniter Ruby Framework Supervisor]
Scope: Close Ruby Framework answer to `PG-2026-05-20-01` question: minimal observed-service wrapper / receipt API.

## Executive Summary

- Ruby can support the first Spark `primary_observed_only` pilot with existing
  package surfaces; no new package code is required for the first pilot.
- The minimum Ruby package surface is `Igniter::Embed.contractable` in
  primary-only `observe` mode, allow-list input redaction, a normalizer, events,
  and a store adapter implementing `record_observation` / `record_event`.
- Spark's feasibility report confirms availability why-not summaries can be
  aggregate-only without raw slot payloads.
- Ledger sidecar remains optional; Spark can persist app-local receipts first.
- Clean installed-gem smoke passed against the Rails proof app after installing
  built gems into a temporary gem home.
- Next Ruby recommendation: `recipe-doc`, then `release-readiness-review`; do
  not open shadow candidate implementation yet.

## Decisions Needed From Portfolio

- [ ] Confirm that Ruby Framework has answered `PG-2026-05-20-01` question 2.
- [ ] Confirm whether the next Ruby lane route should be `recipe-doc` or
  `release-readiness-review`.

## Completed

- Read Base Role, active Portfolio guidance, reporting protocol, Ruby reports,
  and Spark availability feasibility report.
- Reconciled Spark feasibility with the Rails proof app and current Embed
  receipt vocabulary.
- Ran clean installed-gem smoke against a temp copy of the Rails proof app.
- Defined minimum receipt shape and surface boundaries below.

## Minimal Observed-Service Wrapper

The first Spark pilot can use this shape without new package generalization:

```ruby
Igniter::Embed.contractable(:availability_slot_map) do
  observe SparkPrimaryService
  shadow async: false, sample: sample_rate
  use :normalizer, AvailabilitySummaryNormalizer
  use :redaction, only: %i[request_ref company_ref service_area_ref trade_ref window_ref]
  use :store, SparkReceiptStore

  on :observation, SparkNotifications
  on :failure, SparkNotifications
end
```

Constraints:

- returns the original primary result unchanged;
- no candidate callable;
- no shadow comparison;
- no Ledger source-of-truth dependency;
- receipt capture is fail-open for primary behavior.

## Minimal Receipt Shape Ruby Supports Now

Observation receipt:

```text
schema_version
receipt_kind: :contractable_observation
observation_id
name
role: :observed_service
stage
mode: :observe
async
sampled
status
started_at
finished_at
duration_ms
inputs
primary
candidate: nil
report: nil
match: nil
accepted: nil
acceptance: nil
error
store_error
metadata
redaction
```

Primary payload:

```text
status
outputs
metadata
error
```

For the availability pilot, `outputs` should be aggregate and redacted:

```text
available_count
unavailable_count
availability_ratio
availability_bucket
dominant_unavailable_state
reason_codes
reason_counts
window_summary
scope_refs
input_digest
output_digest
```

Event receipt:

```text
schema_version
receipt_kind: :contractable_event
event_id
observation_id
event
name
occurred_at
severity
summary
observation_ref
metadata
```

Required statuses:

```text
:ok
:store_error
:unsampled
```

Primary errors are not observation statuses in the current Embed surface. Embed
records `:primary_error` as an event receipt and re-raises the primary error.
For the first Spark pilot, this is acceptable because primary behavior remains
authoritative.

## Already Available Package Surface

- `Igniter::Embed.contractable`
- `observe` primary-only mode
- `shadow async:, sample:` sampling/adapter knobs
- normalizer hook
- allow-list redaction hook via `use :redaction, only:`
- event hooks including `:observation` and `:failure`
- canonical observation and event receipt shapes
- `record_observation` / `record_event` store adapter protocol
- optional `Igniter::Ledger::ContractableReceiptSink`
- optional `Igniter::LedgerClient` protocol boundary

## Expected Spark App-Local Adapter / Wrapper

Spark owns:

- concrete service target selection;
- redaction allow-list;
- aggregate summary normalizer;
- app-local store adapter;
- metrics or durable receipt table choice;
- admin/MCP lookup surface;
- sampling and rollout flag;
- fail-open handling and alerting.

Spark's current feasibility report says the first local persistence path is
metrics-backed, not a dedicated durable receipt table. Ruby accepts that as a
first app-local proof, but a durable receipt table/outbox remains required
before broader rollout.

## Proof-Only / Example-Only Material

- `examples/rails_contracts_ledger` is a recipe and proof app, not Spark code.
- The example's in-memory Ledger sink is not a production store.
- Localhost server/curl smoke is proof-only.
- Built `.gem` files are smoke artifacts and were not published.

## Closed Broad Package Generalization

Closed for this route:

- new Rails adoption kit API;
- new package-level Spark adapter;
- package-owned ActiveJob/Sidekiq adapter;
- mandatory Ledger sidecar;
- shadow candidate implementation;
- public API widening before one pilot works;
- treating sidecar receipts as source of truth.

## Required Proof Before Pilot Recommendation

Before recommending a Spark pilot beyond local/admin proof:

- Spark confirms the exact target and sampling gate.
- Spark confirms no raw slot/customer/provider payloads in receipt outputs.
- Spark confirms redaction allow-list and digest versions.
- Spark shows one persisted redacted receipt example.
- Ruby proof remains green against current gems.
- Store failure and receipt loss behavior is fail-open and observable.
- Admin/MCP lookup by `observation_id` is scoped read-only.

Before release recommendation:

- root `bundle exec rake` passes.
- Ledger package specs pass.
- Rails proof app passes against path gems.
- Clean installed-gem smoke passes from built gems.
- Release checklist explicitly notes native extension install behavior for
  `igniter-ledger`.

## Clean Install / Use Smoke

Result: pass.

Procedure:

- built local gems were installed into a temporary gem home;
- temp copy of `examples/rails_contracts_ledger` was changed from path gems to
  versioned gems;
- `bundle install --local` completed;
- `bin/rails test` passed.

Evidence:

```text
Successfully installed igniter-contracts-0.5.1
Successfully installed igniter-extensions-0.5.1
Successfully installed igniter-embed-0.5.1
Successfully installed igniter-ledger-client-0.5.1
Successfully installed igniter-ledger-0.5.1
1 runs, 24 assertions, 0 failures, 0 errors, 0 skips
```

Important release note:

```text
igniter-ledger native extension build needs crates.io access unless vendored or
prebuilt native artifacts are introduced.
```

The first offline clean install attempt failed because Cargo could not resolve
`index.crates.io` for the native extension dependency graph. Retrying with
network access succeeded.

## Clear Answer

New package code is not needed for the first Spark `primary_observed_only`
pilot.

Spark needs an app-local adapter and receipt persistence decision. Ruby
Framework should not generalize the package API until one real redacted receipt
path is proven end-to-end.

## Changed Files

- `.agents/ruby-framework/reports/port-2026-05-20-ruby-p1-minimal-receipt-shape.md`

## Evidence

- tracks:
  - `.agents/ruby-framework/tracks/ruby-framework-current-state-analysis-v0.md`
- gates:
  - `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
- discussions:
  - `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/2026-05-20-spark-availability-receipt-feasibility.md`
- guidance:
  - `PG-2026-05-20-01`
- tests/proofs:
  - clean installed-gem Rails proof smoke described above

## Risks / Drift

- Spark's first persistence path is metrics-backed, not a dedicated durable
  receipt store.
- `employee_ref` in Spark feasibility remains internal and must be sanitized
  before public/shared fixtures.
- `igniter-ledger` native extension install currently depends on network access
  to crates.io in a clean gem install.
- Broad package API generalization is still premature.

## Cross-Lane Requests

To Ruby Framework:

- Produce a concise recipe doc from the Rails proof and this minimum shape.
- Do not open shadow candidate implementation.

To Igniter-Lang:

- Wait for one persisted Spark receipt example before fixture expansion.

To Spark CRM:

- Provide a persisted redacted receipt example and confirm whether metrics-backed
  receipt storage is sufficient for the first admin-only pilot.

To Portfolio:

- Decide whether next Ruby route is `recipe-doc` or `release-readiness-review`.

## Recommended Next

Recommendation: `recipe-doc`.

Reason: package code is sufficient, clean install smoke is green, and the
remaining cross-lane need is a reusable app-local recipe. After recipe-doc,
move to `release-readiness-review`.
