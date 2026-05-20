# Spark CRM Ledger x Igniter Applicability Analysis

Status: triaged / routed to S3-R86 applied-pressure track  
Date: 2026-05-20  
Scope: Spark CRM Ledger-related models/services + Igniter contracts/embed + Igniter Ledger + Igniter-Lang  
Privacy note: this report intentionally avoids secrets, provider endpoints, credentials, customer payloads, and sensitive raw data.

Disposition:
- Routed by Architect Supervisor into `S3-R86`.
- Next owner: `sparkcrm-igniter-adoption-readiness-map-v0`.
- Use as applied-pressure source only; not canon and not implementation
  authority.
- Intended pressure lanes: Igniter Ruby framework adoption, Igniter Ledger
  sidecar research, and Igniter-Lang sanitized fixtures/spec pressure.

## Executive Verdict

Spark CRM already contains a real business ledger architecture. It is not called Igniter, but structurally it is very close to Igniter's pressure model:

```text
business event / admin change / system sync
  -> recorder
  -> temporal ledger entry
  -> active-at finder / projection
  -> admin/debug surface
  -> analytics or operational decision
```

Igniter is applicable, but not as a replacement rewrite today.

Best fit now:

1. Use `igniter-contracts` + `igniter-embed` to wrap existing Spark CRM ledger services as observed/contractable business contracts.
2. Use `igniter-ledger` as a sidecar observation/receipt sink, not as the primary SQL ledger store yet.
3. Use `igniter-lang` to formalize Spark CRM ledger semantics as pressure fixtures/specs: bitemporal pricing, availability why-not, company assignment history, bid routing, compaction receipts.

The strongest business value is explainability:

- why this technician was unavailable;
- why this bid was used at call time;
- why this company price won over another rule;
- why a service-call price resolved to a specific chain;
- who/what changed assignment state and when;
- what was retained, compacted, or no longer explainable after retention.

## Spark CRM Ledger Inventory

### Availability Ledger

Source files:

- `app/models/availability_ledger/ledger_entry.rb`
- `app/models/availability_ledger/snapshot.rb`
- `app/services/availability_ledger/recorder.rb`
- `app/services/availability_ledger/slot_map.rb`
- `app/models/off_schedule/availability_ledger_callbacks.rb`
- `app/models/schedule/availability_ledger_callbacks.rb`
- `app/workers/availability_ledger/snapshot_worker.rb`
- `app/workers/availability_ledger/snapshot_orchestrator_worker.rb`
- `app/workers/availability_ledger/compact_worker.rb`
- `app/controllers/admin/companies/availabilities_controller.rb`

Business process:

```text
Company working hours + technician day_off_config
  -> nightly Layer-1 snapshot per technician/date

OffSchedule/Schedule lifecycle changes
  -> audit ledger entries: off_schedule, schedule, void

SlotMap query(employee, date, at)
  -> base snapshot at/before at OR fresh base computation
  -> subtract live OffSchedule records
  -> overlay live Schedule records
  -> classify slots: past, scheduled, available, off_schedule, day_off
```

Important details:

- Snapshots are point-in-time: latest committed snapshot at or before `at` wins.
- Ledger entries audit interval events, but `SlotMap` currently reads live `OffSchedule` and `Schedule` records directly for Layer 2.
- Callbacks are non-blocking: a ledger failure logs but does not block the main business flow.
- Weekly compaction deletes old availability ledger entries when committed snapshots exist, and marks old snapshots as compacted by nulling detailed windows.

Formalized contract shape:

```text
AvailabilityProjection(company, technician, date, at)
  input observations:
    TechnicianProfile
    CompanyWorkingHours
    DayOffConfigVersion
    AvailabilitySnapshot(at <= query_at)
    OffSchedule records created_at <= query_at
    Schedule records created_at <= query_at and status in planned/in_progress
  output:
    SlotMap
    AvailabilitySnapshotRef
    WhyNot reasons per slot
  diagnostics:
    timezone fallback
    missing snapshot
    live record drift
    compaction boundary
```

Igniter pressure:

- bitemporal split: valid day/slot vs transaction/known time;
- observation kind distinction: snapshot observation vs live ActiveRecord observation;
- compaction receipt with explanation rights;
- why-not diagnostics for `scheduled`, `off_schedule`, `day_off`, `past`;
- tenant/timezone guard.

### Bid Ledger

Source files:

- `app/models/bid_ledger/entry.rb`
- `app/models/bid_ledger/entry_zip_code.rb`
- `app/services/bid_ledger/recorder.rb`
- `app/services/bid_ledger/finder.rb`
- `app/services/bid_ledger/routing_rule_finder.rb`
- `app/services/bid_ledger/routing_parity_checker.rb`
- `app/models/trade_vendor.rb`
- `app/models/geo_bid_rule.rb`
- `app/workers/analytics/analytics_call_worker.rb`
- `lib/tasks/analytics/init_bid_ledger.rake`

Business process:

```text
TradeVendor or GeoBidRule bid changes
  -> BidLedger::Recorder
  -> close active entry for same vendor/scope
  -> create new active entry with effective_from

Analytics call enrichment
  -> find tracking/vendor/order context
  -> BidLedger::Finder(vendor, zip_code, at: call_start_time)
  -> store bid_at_time into analytics call record
```

Resolution order:

```text
zip_group entries matching zip
  + geo entries matching zip/city/county/state
  + vendor_trade fallback
  -> first rule returned by routing finder
```

Igniter pressure:

- time-travel value selection at call time;
- source record provenance;
- scope specificity and fallback explanation;
- bid Decimal/currency typing;
- idempotent backfill and duplicate prevention;
- parity checks between legacy routing and ledger routing.

### Order Price Ledger

Source files:

- `app/models/order_price_ledger/entry.rb`
- `app/models/order_price_ledger/chain_validator.rb`
- `app/services/order_price_ledger/recorder.rb`
- `app/services/order_price_ledger/finder.rb`
- `app/controllers/admin/companies/order_price_ledgers_controller.rb`
- `app/controllers/admin/companies/order_price_ledger_entries_controller.rb`
- `app/controllers/admin/ledgers/order_price_ledger_entries_controller.rb`

Business process:

```text
Manager/API/import/system changes price rule
  -> Recorder resolves company/scope/parent
  -> if same active price + same parent: no-op
  -> else supersede previous active rule
  -> create new active rule

Order pricing context
  -> load active entries for company at time
  -> build context: trade, job types, brands, brand segments, geo
  -> check each full parent chain
  -> winner = deepest chain, then geo specificity, priority, id
```

Core idea:

Each entry encodes one scope dimension. Business specificity is composed through parent chains:

```text
trade -> job_type -> brand
geo -> brand
default
```

Validator enforces:

- default must be root;
- no duplicate scope kind in chain;
- no brand + brand_segment contradiction;
- parent must belong to same company;
- no circular reference;
- max depth.

Igniter pressure:

- declarative state machine for active/superseded/voided;
- chain validity as contract invariants;
- explanation report for winner selection;
- Decimal money exactness;
- schema evolution for scope kinds;
- explicit company scope without ambient tenant dependency.

### Service Call Price Ledger

Source files:

- `app/models/service_call_price_ledger/entry.rb`
- `app/models/service_call_price_ledger/chain_validator.rb`
- `app/services/service_call_price_ledger/recorder.rb`
- `app/services/service_call_price_ledger/finder.rb`
- `app/controllers/admin/companies/sc_price_ledgers_controller.rb`
- `app/controllers/admin/companies/sc_price_ledger_entries_controller.rb`
- `app/controllers/admin/ledgers/sc_price_ledger_entries_controller.rb`

Business process mirrors Order Price Ledger, but the dimensions differ:

```text
default
trade
job_type
geo
callrail_channel
service_index
property_type
```

Resolution:

```text
active company entries at time
  -> match full parent chain against call/order context
  -> choose by chain depth, geo specificity, priority, id
```

Igniter pressure:

- reusable "fractal ledger" abstraction shared with OrderPriceLedger;
- dimension-specific scope key validation;
- state transition receipt;
- per-call price context evidence;
- service index and property type as typed domain dimensions.

### Company Assignment Ledger

Source files:

- `app/models/company_assignment_ledger/entry.rb`
- `app/services/company_assignment_ledger/recorder.rb`
- `app/models/concerns/records_company_assignments.rb`
- `db/migrate/20260519193000_create_company_assignment_ledger_entries.rb`

Business process:

```text
assignable added to company
  -> activate assignment
  -> close current entry if needed
  -> create active entry

assignable removed from company
  -> deactivate assignment
  -> close current entry
  -> create inactive entry

query active_at(time)
  -> status active and effective window contains time
```

This ledger turns join-table membership into temporal business truth.

Igniter pressure:

- association history as first-class contract;
- current assignment uniqueness;
- active-at membership;
- assignment source kind: admin_ui/system/sync/backfill;
- callback reliability and reconciliation.

## Cross-Cutting Spark CRM Ledger Model

Spark CRM ledgers share a common semantic spine:

```text
Scope
  company/vendor/employee/assignable/context dimensions

Temporal validity
  effective_from / effective_until / date / recorded_at / snapshotted_at

Lifecycle
  active / superseded / voided / inactive / committed / compacted

Actor/source
  source_kind / created_by / reference / metadata

Projection
  active_at finder / slot map / winner selection / analytics enrichment

Diagnostics
  admin ledgers, time-travel availability screen, parity checker, metadata
```

This is extremely compatible with Igniter's core direction:

```text
contract + explicit time + observation evidence
  -> projection
  -> receipt
  -> explainability
  -> retention/compaction
```

## Applicability Dimension 1: Igniter Ruby Contracts / Embed

Relevant packages:

- `packages/igniter-contracts`
- `packages/igniter-embed`

Current useful surfaces:

- `Igniter::Contract` class DSL;
- `compute using:` contractable services;
- normalized service payloads with `outputs`, `observations`, `error`, `success`;
- `Igniter::Embed.host/configure`;
- contract registration and host-local execution;
- contractable shadowing;
- primary/candidate comparison;
- observation receipts;
- redaction;
- acceptance policies;
- app-supplied store adapter;
- async adapter hook for Sidekiq/ActiveJob.

Best immediate Spark CRM use:

### 1. Shadow existing ledger finders

Wrap existing services as primary and a contract/rewritten candidate as shadow:

- `OrderPriceLedger::Finder`
- `ServiceCallPriceLedger::Finder`
- `BidLedger::Finder`
- `AvailabilityLedger::SlotMap`

Value:

- compare candidate outputs without changing production behavior;
- capture divergence receipts;
- detect context shapes that break assumptions;
- keep sensitive fields redacted.

### 2. Wrap recorder flows as observed services

Observed primary-only wrappers can produce receipts for:

- price rule creation/supersession;
- bid rule update;
- assignment activation/deactivation;
- availability event mirroring.

Value:

- action receipts without replacing AR transactions;
- structured metadata for admin/debug pages;
- safer future migrations.

### 3. Formalize Spark marketing executor pipeline

The existing Spark marketing flow already wants step receipts:

```text
validate
find_trade
find_vendor
find_zip_code
set_current_time
check_business_hours
find_geo_bids
find_exclusions
find_availability_mode
find_locations
check_availability
generate_results
```

Igniter Embed is well suited for a shadow migration here because the current value is diagnostics and parity, not a rewrite.

Risks / gaps:

- `igniter-contracts` metadata is partly report-only; not all declarations are enforced.
- `igniter-embed` async default is local thread; Spark should provide Sidekiq adapter for durable observations.
- Store adapters must enforce redaction; raw params/provider data should not be exported.
- Contractable receipt persistence should be treated as observation, not source of truth.

Verdict:

```text
Applicability: HIGH now
Mode: shadow/observed wrappers, not replacement
Business risk: low if redaction and sampling are strict
```

## Applicability Dimension 2: Igniter Ledger Package

Relevant package:

- `packages/igniter-ledger`

Current useful surfaces:

- immutable content-addressed facts;
- `write` for current store state;
- `append` for histories;
- transaction time and valid time;
- causation chains;
- schema version;
- producer/derivation metadata;
- current reads and `as_of` reads;
- history and partitioned history;
- descriptors;
- access paths, relations, projections, derivations, scatters;
- retention and compaction receipts;
- changefeed/replay;
- open protocol;
- `ContractableReceiptSink` for `igniter-embed` observations/events.

Best immediate Spark CRM use:

### 1. Sidecar observation sink

Use `ContractableReceiptSink` for Igniter Embed contractable receipts:

```text
Spark service call
  -> embed contractable receipt
  -> Igniter Ledger sidecar
  -> query divergences / errors / observations
```

This avoids replacing Spark SQL ledgers and still gives Igniter a real production-adjacent learning surface.

### 2. Experimental mirror of selected ledger facts

Mirror a sanitized subset of facts:

- price rule created/superseded;
- bid selected for analytics call;
- availability slot-map projection receipt;
- assignment activated/deactivated.

Do not mirror raw provider/customer data.

### 3. Compaction and explanation pressure

Spark Availability Ledger already has compaction. Igniter Ledger has retention/compaction receipts and boundary research. This is a direct fit for designing:

```text
AvailabilityBoundaryReceipt
  source facts
  snapshot value hash
  compaction cutoff
  retained explanation refs
  purged detail refs
```

Risks / gaps:

- Igniter Ledger is pre-v1; APIs and storage formats may change.
- It does not own SQL schema generation or Rails ORM semantics.
- It should not replace Spark's ActiveRecord ledgers now.
- It needs a robust Postgres/Rails adapter or outbox bridge before production write-path use.
- `append` event retries may duplicate without source idempotency.
- Spark's temporal model uses `effective_from/effective_until`; Igniter Ledger has `valid_time` but needs stronger interval/window semantics for these ledgers.

Verdict:

```text
Applicability: MEDIUM now as sidecar; HIGH later as protocol/receipt substrate
Mode: observation sink + sanitized mirror + pressure fixtures
Do not use now as primary Spark ledger DB
```

## Applicability Dimension 3: Igniter-Lang

Relevant workspace:

- `igniter-lang`

Current status:

- Stage 2 closed with parser/classifier/typechecker/SemanticIR/assembler/runtime proof surfaces.
- `History[T]`, `BiHistory[T]`, streams, OLAPPoint and TBackend descriptor proofs exist.
- Stage 3 is open.
- Production Ledger/BiHistory adapter binding remains restricted/blocked.
- Runtime Phase 1 live-read is authorized only for narrow proof-local scope: `History[T]`, valid time, explicit `as_of`, memory or explicit non-Ledger Phase 1 backend.

Existing Spark-oriented source fixtures:

- `source/availability_projection.ig`
- `source/tenant_availability_projection.ig`
- `source/vendor_lead_pipeline.ig`
- `source/decimal_contract.ig`

Best immediate Spark CRM use:

### 1. Formal specifications, not production execution

Use Igniter-Lang to write `.ig` fixtures for:

- Availability SlotMap with bitemporal correction;
- BidLedger routing selection;
- OrderPriceLedger chain winner explanation;
- ServiceCallPriceLedger chain winner explanation;
- CompanyAssignment active-at membership;
- Availability compaction boundary receipt.

### 2. Language pressure from real business

Spark ledgers create concrete pressure for:

- interval validity, not just single `valid_time`;
- status transitions;
- active-at resolution;
- hierarchical scope chains;
- Decimal/currency;
- tenant explicitness;
- source_kind and actor references;
- compaction/explanation rights;
- diagnostics as outputs.

### 3. Future `.igapp` as operational policy artifact

Long-term, Spark could compile a pricing or availability contract into `.igapp` as a reviewable business artifact. But that requires production TBackend binding and runtime enforcement to be ready first.

Risks / gaps:

- Igniter-Lang should not be used to execute Spark CRM production ledger decisions today.
- Current `.ig` fixtures are proof/pressure, not replacement logic.
- Business ledgers need interval validity and bitemporal known-time corrections beyond current minimal History read.
- Need formal bridge between ActiveRecord facts and TBackend descriptors.

Verdict:

```text
Applicability: HIGH as language pressure/spec; LOW-MEDIUM as production runtime today
Mode: fixtures, formal contracts, CompatibilityReport expectations
```

## Key Insights

### Insight 1: Spark CRM already has fractal ledgers

OrderPriceLedger and ServiceCallPriceLedger independently encode the same pattern:

```text
one entry = one dimension
parent chain = composed specificity
finder = rule evaluator
validator = semantic guard
winner = explainable projection
```

This is a real business version of a declarative state/rule system. Igniter should learn this shape.

### Insight 2: Availability Ledger splits source-of-truth and audit mirror

Availability ledger entries are audit records, but `SlotMap` still reads live `OffSchedule` and `Schedule` records. This is pragmatic and probably correct for current Spark CRM, but the formal model must name it:

```text
Layer 1 snapshot = projected base truth
Layer 2 live AR reads = operational source truth
Ledger entries = audit/evidence mirror
```

Igniter pressure: distinguish `OperationalReadObservation` from `LedgerFactObservation`.

### Insight 3: Spark needs bitemporal language, not just history

Several fields carry different time meanings:

- `effective_from/effective_until`: domain validity;
- `recorded_at/created_at/updated_at`: known/transaction time;
- `date`: business calendar day;
- `snapshotted_at`: projection production time;
- `call.start_time`: event time used for bid lookup;
- `at`: replay/debug query time.

Igniter-Lang should model this explicitly. Spark CRM is a strong proof source for `BiHistory[T]` and interval-validity pressure.

### Insight 4: Non-blocking callbacks are good UX but weak audit guarantees

Availability and bid callbacks log failures without breaking the primary flow. That protects operations, but the ledger can miss events unless reconciliation/backfill catches them.

Igniter ecosystem pressure:

- outbox pattern;
- retryable receipt write;
- reconciliation diagnostics;
- missing-ledger-event reports;
- source-record parity checks.

### Insight 5: The biggest immediate business value is "why"

Spark CRM admin already has ledger views and time-travel availability. Igniter can amplify this into structured explanations:

- why this price entry won;
- why this bid was selected;
- why this technician slot is unavailable;
- why this assignment is active;
- why a previous decision remains explainable after later corrections.

### Insight 6: Decimal and scope keys are not small details

Pricing and bids need exact Decimal/currency/unit semantics. Scope keys are currently strings with validators. Igniter can help by turning string conventions into typed scope dimensions and schema compatibility checks.

## Delta: What Igniter Must Add To Be Truly Useful For Spark CRM

### Delta A: Rails-first contractable adoption kit

Needed:

- Rails initializer pattern for `Igniter::Embed.host(:sparkcrm)`;
- Sidekiq async observation adapter;
- redaction defaults for IDs/phones/provider/customer data;
- ActiveSupport notification integration;
- admin-friendly observation lookup by `observation_id`.

Value:

- immediate migration safety without changing business behavior.

### Delta B: Effective interval support

Current Spark ledgers are not just point history. They use closed/open intervals:

```text
effective_from <= at < effective_until
```

Needed in Igniter:

- interval-valid facts;
- active-at selection;
- no-overlap invariant;
- supersession receipt;
- void receipt;
- correction receipt.

### Delta C: Hierarchical scope-chain contract

Order/service-call pricing needs:

- typed dimensions;
- parent-chain constraints;
- contradiction detection;
- max-depth;
- winner explanation;
- specificity scoring.

This is a reusable "fractal scope ledger" primitive.

### Delta D: Production-safe Ledger adapter path

Needed before Spark can use Igniter Ledger beyond sidecar:

- Postgres-backed or Rails-transaction-friendly backend;
- idempotent append with external idempotency key;
- transactional outbox bridge;
- schema descriptors for existing SQL ledgers;
- retention/compaction boundary receipts.

### Delta E: Availability explanation receipts

Needed:

- `AvailabilityProjectionReceipt`;
- per-slot evidence refs;
- why-not reasons;
- snapshot id/hash;
- live AR refs or ledger fact refs;
- timezone fallback diagnostic;
- compaction boundary note.

### Delta F: Compatibility/migration reports for business rules

Spark pricing rule schemas will evolve. Needed:

- scope-kind schema version;
- migration receipt;
- compatibility diagnostic;
- blocked migration when scope semantics drift.

## Pressure Vector For Igniter Ecosystem

### P0: Contractable shadowing of Spark ledger services

Target:

- `OrderPriceLedger::Finder`
- `ServiceCallPriceLedger::Finder`
- `BidLedger::Finder`
- `AvailabilityLedger::SlotMap`

Deliverable:

- observed wrapper;
- redacted receipt;
- divergence/event store;
- admin link to observation.

Why first:

It gives business value immediately and keeps production behavior untouched.

### P1: Spark Ledger Receipt Vocabulary

Define common receipt shapes:

- `LedgerRecordReceipt`
- `SupersessionReceipt`
- `VoidReceipt`
- `FinderResolutionReceipt`
- `ChainValidationReceipt`
- `AvailabilityProjectionReceipt`
- `CompactionBoundaryReceipt`

Why:

Spark ledgers already have actions; they need normalized, comparable receipts.

### P2: Fractal Scope Ledger fixture

Extract OrderPriceLedger and ServiceCallPriceLedger into one synthetic fixture:

```text
dimensions
chain
validator
active-at facts
winner selection
explanation report
```

Why:

This is the clearest business pressure for typed scope composition.

### P3: Availability bitemporal correction fixture

Use one company, one technician, one date:

- base snapshot;
- off schedule;
- schedule;
- later correction;
- original dispatch decision remains explainable.

Why:

This tests `BiHistory`, compaction, and explanation rights against real operations.

### P4: Igniter Ledger sidecar proof

Wire `ContractableReceiptSink` to a small Spark-style observed service in isolation.

Why:

Proves `igniter-embed` + `igniter-ledger` integration without touching primary SQL ledgers.

### P5: Postgres/TBackend bridge design

Design only at first:

- map existing SQL ledger rows to fact descriptors;
- decide whether facts are mirrored or read-through;
- define schema version and producer;
- define retention and purge boundaries.

Why:

This is the bridge between real Spark data and future Igniter runtime.

## Suggested Next Cards

If this should proceed in rounds, send these one by one:

1. `sparkcrm-ledger-contractable-shadow-plan-v0`  
   Produce a concrete plan for wrapping `OrderPriceLedger::Finder` and `AvailabilityLedger::SlotMap` with `igniter-embed` contractable observation receipts.

2. `sparkcrm-fractal-price-ledger-fixture-v0`  
   Create an Igniter-Lang fixture spec for OrderPriceLedger/ServiceCallPriceLedger chain resolution with expected winner explanations.

3. `sparkcrm-availability-ledger-why-not-fixture-v0`  
   Create a fixture for SlotMap explaining `available`, `scheduled`, `off_schedule`, `day_off`, and `past`.

4. `sparkcrm-ledger-sidecar-receipt-sink-v0`  
   Design a sanitized `igniter-ledger` sidecar receipt sink for Spark contractable observations.

5. `sparkcrm-ledger-bitemporal-delta-v0`  
   Formalize valid time vs known time across all Spark ledgers and map required Igniter-Lang deltas.

## Conclusion

Igniter is relevant to Spark CRM because Spark CRM already has contract-shaped business truth. The project has independently evolved toward:

- temporal records;
- active-at replay;
- explicit source kinds;
- actor metadata;
- scoped rule chains;
- snapshots;
- compaction;
- admin diagnostics.

The correct path is incremental:

```text
Observe existing services
  -> capture receipts
  -> compare/shadow candidates
  -> formalize fixtures in Igniter-Lang
  -> mirror sanitized facts into Igniter Ledger
  -> only later consider runtime/ledger replacement or compiled .igapp policy
```

Near-term business value is high for diagnostics, shadow migration, and explainability. Production replacement value is not ready yet, and trying to replace Spark's SQL ledgers now would be premature.

The most important pressure for the Igniter ecosystem is to become useful to real Rails businesses without asking them to rewrite their source of truth first.
