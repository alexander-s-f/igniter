# SparkCRM Igniter Adoption Readiness Map v0

Card: S3-R86-C2-P1  
Agent: [Igniter-Lang Research Agent]  
Role: research-agent  
Route: UPDATE  
Status: done  
Date: 2026-05-20

## Neighbor Roles

Affected neighbor roles:

- Bridge Agent: Spark CRM adoption pressure needs metadata/redaction/receipt profiles before real app integration.
- Compiler/Grammar Expert: Spark fixtures continue to pressure tenant scope, pipeline observations, Decimal, interval validity, BiHistory, and receipt syntax.
- Igniter Ruby framework maintainers: immediate adoption value is in `igniter-contracts` / `igniter-embed`, not Igniter-Lang runtime replacement.

## Scope

Read-only except for this track doc.

Read:

- `docs/inbox/sparkcrm-ledger-igniter-applicability-analysis-2026-05-20.md`
- `docs/applied-pressure-directions.md`
- `docs/value-index.md`
- `docs/current-status.md`
- Spark-related active tracks found by `rg "Spark|sparkcrm" igniter-lang/docs/tracks igniter-lang/docs/archive -g "*.md"`
- Selected active Spark tracks:
  - `spark-technician-availability-fixture-v0.md`
  - `spark-lead-signal-boundary-fixture-v0.md`
  - `spark-operation-action-lifecycle-fixture-v0.md`
  - `sparkcrm-bihistory-fixture-v0.md`
  - `spark-crm-real-business-candidate-map-v0.md`
  - `spark-tenant-and-pipeline-formalization-v0.md`
  - `sparkcrm-history-pressure-v0.md`
  - `spark-pipeline-grammar-v0.md`

No private Spark CRM code was inspected. No Spark CRM code, Igniter Ruby framework code, Igniter Ledger code, or Igniter-Lang compiler/runtime code was edited.

## Current Horizon

- Spark CRM already has ledger-shaped business truth: temporal entries, active-at finders, projections, admin/debug views, and compaction.
- Igniter is applicable now as observation, contractable shadowing, receipts, and explanation pressure.
- Igniter should not replace Spark SQL ledgers today.
- Igniter Ledger is best as sidecar receipt sink / sanitized mirror first, not primary store.
- Igniter-Lang should continue turning Spark pressure into fixtures/specs before production runtime use.

## Executive Readiness Verdict

```text
Adoption mode now:
  observe existing Spark services
  -> shadow/compare candidate contracts
  -> emit redacted receipts
  -> optionally sink receipts to sidecar Ledger
  -> use Igniter-Lang fixtures to formalize semantics

Not ready now:
  replace Spark ledgers
  execute Spark decisions via Igniter-Lang runtime
  bind production TBackend/Ledger as source of truth
```

Recommendation: route.

The first pilot should be:

```text
sparkcrm-contractable-shadowing-pilot-v0
```

Pilot target:

```text
OrderPriceLedger::Finder or AvailabilityLedger::SlotMap
  -> primary existing service
  -> contractable observed wrapper
  -> redacted receipt
  -> optional shadow candidate
  -> divergence / why receipt
  -> no production behavior change
```

## Adoption Readiness Table

| Horizon | What can happen | Owner lane | Guard |
| --- | --- | --- | --- |
| Now | Contractable shadowing of existing Spark ledger finders/services. | Igniter Ruby framework / Spark app integration plan | No replacement. Primary service remains Spark. |
| Now | Observed wrappers around recorder flows to emit action/finder receipts. | Igniter Ruby framework / Bridge | Receipts are observation evidence, not source of truth. |
| Now | Redacted receipt vocabulary for price, bid, assignment, availability, compaction. | Bridge + Research | No raw provider/customer payloads. |
| Now | Synthetic fixture/spec pressure for availability, lead signal, operation lifecycle, BiHistory correction. | Igniter-Lang | Synthetic facts only. |
| Next | Rails-first contractable adoption kit: initializer, redaction defaults, admin lookup by observation id. | Igniter Ruby framework | App-local integration; no public Spark data. |
| Next | Sidekiq/ActiveJob durable observation adapter for contractable receipts. | Igniter Ruby framework | Async receipt durability without blocking business transaction. |
| Next | Sidecar `ContractableReceiptSink` into Igniter Ledger. | Igniter Ledger sidecar research | Sidecar only; not primary Spark ledger DB. |
| Next | Fractal price ledger fixture for order/service-call chain resolution. | Igniter-Lang | Synthetic chain/dimension facts; no Rails port. |
| Next | Effective interval / active-at fixture and spec delta. | Igniter-Lang + Compiler/Grammar | Explicit interval semantics, not ambient SQL assumptions. |
| Later | Sanitized mirror of selected ledger facts into Igniter Ledger. | Ledger sidecar + Bridge | Idempotent append and redaction required. |
| Later | `.igapp` as reviewable operational policy artifact. | Igniter-Lang + Ruby integration | Requires production runtime/TBackend readiness first. |
| Closed | Production replacement of Spark SQL ledgers. | none | Not authorized. |
| Closed | Real Spark CRM data/endpoints/provider payloads in public docs or fixtures. | none | Not authorized. |
| Closed | Igniter-Lang runtime executing production Spark ledger decisions. | none | TBackend/runtime production binding remains restricted. |

## Route Evaluation

### Contractable Shadowing Of Existing Ledger Services

Verdict: best first route.

Good targets:

- `OrderPriceLedger::Finder`
- `ServiceCallPriceLedger::Finder`
- `BidLedger::Finder`
- `AvailabilityLedger::SlotMap`

Why:

- existing service remains primary;
- candidate contract can run as shadow;
- divergence receipts create immediate diagnostic value;
- explainability improves without changing production behavior;
- redaction can be enforced at receipt boundary.

First pilot should choose one service with high explainability value and bounded inputs. `AvailabilityLedger::SlotMap` is strongest for why-not reasons; `OrderPriceLedger::Finder` is strongest for scope-chain winner explanation.

### Sidekiq / Durable Observation Adapter Need

Verdict: required before production-adjacent adoption is trustworthy.

Reason:

- Spark ledger callbacks often protect UX by not blocking primary flow.
- Igniter receipt writes should follow the same operational caution but still be durable and retryable.
- Local thread async is not enough for Rails production confidence.

Needed shape:

```text
ContractableReceipt
  -> app outbox or Sidekiq job
  -> durable receipt sink
  -> retry/idempotency key
  -> redaction policy
  -> admin lookup ref
```

This belongs to Igniter Ruby framework / embed, not Igniter-Lang compiler.

### Sidecar Receipt Sink, Not Primary Spark Ledger DB

Verdict: yes, sidecar only.

Igniter Ledger can learn from Spark and store observation receipts, but it should not own Spark's primary ledger rows now.

Allowed sidecar uses:

- contractable receipts;
- divergence receipts;
- finder resolution receipts;
- sanitized mirror facts;
- compaction/explanation receipts.

Closed:

- replacing ActiveRecord ledgers;
- making Igniter Ledger the transactional source of truth;
- replaying Spark business state from sidecar receipts as production truth.

### Bitemporal / Effective-Interval Delta

Verdict: important next language pressure.

Existing Spark ledger patterns use:

```text
effective_from <= at < effective_until
created_at / recorded_at / updated_at as known/transaction time
snapshotted_at as projection production time
```

Igniter-Lang already has History/BiHistory proof surfaces, but Spark needs interval-valid active-at semantics:

- interval facts, not only point facts;
- no-overlap invariant;
- supersession/void/correction receipts;
- active-at finder semantics;
- valid-time interval + transaction-time known-at split;
- compaction boundary preserving explanation rights.

Best next fixture: fractal price ledger or company assignment active-at membership.

### Why / Explainability Receipts

Verdict: biggest immediate value.

Spark readiness should optimize for "why" before "replace":

- why this technician was unavailable;
- why this bid was selected at call time;
- why this price rule won;
- why this assignment was active;
- why a later correction does not rewrite an original decision;
- why a compaction still preserves enough explanation.

Receipt vocabulary should be shared across Ruby framework, Ledger sidecar, and Lang fixtures.

## Lane Map

### Spark CRM Safe-Now Work

Can start with a separately authorized app-local pilot:

- wrap one finder/service with `igniter-contracts` contractable observed execution;
- run primary-only first, then optional shadow candidate;
- emit redacted receipt with source service, input digest, output digest, decision reason, and observation id;
- expose an admin/debug observation link;
- sample or gate carefully;
- keep Spark service output authoritative.

Do not inspect or publish real customer/provider payloads in this track.

### Igniter Ruby Framework / Contracts / Embed

Needs:

- Rails initializer pattern for `Igniter::Embed.host(:sparkcrm)`;
- Sidekiq/ActiveJob async observation adapter;
- redaction defaults;
- app-supplied store/receipt sink contract;
- contractable shadowing ergonomics;
- primary/candidate comparison receipts;
- admin lookup helper by observation id;
- ActiveSupport notification hooks.

This is the highest-leverage near-term engineering lane.

### Igniter Ledger Sidecar Research

Needs:

- `ContractableReceiptSink` proof against a Spark-shaped observed service;
- idempotent append with external idempotency key;
- sidecar schema for receipts and sanitized mirror facts;
- retention/compaction receipt shapes;
- no source-of-truth claims;
- no Ledger replay as Spark production state.

### Igniter-Lang Fixtures / Spec Pressure

Existing proof base:

- technician availability fixture: TenantScope, ScopedFactRead, StepObservation, why-not reasons.
- lead signal boundary fixture: idempotency, Decimal totals, boundary close/retention, duplicate suppression.
- operation action lifecycle fixture: visible policy vs executable authority, request/execution receipts.
- SparkCRM BiHistory fixture: decision-time trusted snapshot vs later correction.
- tenant/pipeline formalization: fail-fast pipeline sugar and explicit tenant scope.

Next useful fixtures:

- `sparkcrm-fractal-price-ledger-fixture-v0`
- `sparkcrm-availability-ledger-why-not-fixture-v0`
- `sparkcrm-ledger-bitemporal-delta-v0`
- `sparkcrm-company-assignment-active-at-fixture-v0`
- `sparkcrm-compaction-explanation-receipt-fixture-v0`

### Must Remain Closed

- production replacement of Spark ledgers;
- real Spark data, endpoints, credentials, provider payloads, customer records, phone/email data, or infrastructure details in public fixtures/docs;
- Igniter-Lang production execution of Spark decisions;
- production TBackend / Ledger binding for Spark;
- using sidecar receipts as primary truth;
- public `.igapp` operational policy deployment for Spark;
- automatic migration of existing Spark ledgers to Igniter Ledger;
- broad framework code changes without a dedicated implementation card.

## Roadmap Horizon

### Step 0: Hygiene And Boundary

Define redaction policy, observation id format, and "receipt is not source of truth" language.

### Step 1: Contractable Shadowing Pilot

Recommended card:

```text
sparkcrm-contractable-shadowing-pilot-v0
```

Scope:

- choose one bounded service: `AvailabilityLedger::SlotMap` or `OrderPriceLedger::Finder`;
- primary existing service remains authoritative;
- emit redacted observation receipt;
- optionally compute shadow candidate;
- record divergence receipt;
- no production output change.

Acceptance sketch:

- no raw provider/customer payloads;
- no replacement path;
- receipt has input/output digest, reason summary, source refs, redaction status;
- missing receipt does not block business flow in pilot mode;
- admin/debug lookup can find receipt by id.

### Step 2: Durable Observation Adapter

Add Sidekiq/ActiveJob adapter and idempotent receipt enqueue semantics.

### Step 3: Sidecar Receipt Sink

Wire contractable receipt output into Igniter Ledger sidecar in isolation.

### Step 4: Lang Fixtures For Hard Semantics

Add fractal price ledger and effective-interval fixtures to pressure typed dimensions, active-at, no-overlap, supersession, and winner explanation.

### Step 5: Bridge Descriptor Design

Map existing SQL ledger shapes to metadata-only descriptors; decide mirror vs read-through later.

### Step 6: Reviewable Policy Artifact

Only after prior proof: consider `.igapp` as a reviewable business policy artifact, not runtime authority.

## Recommended First Pilot Card

```text
Card: sparkcrm-contractable-shadowing-pilot-v0
Agent: [Igniter Ruby Framework / Bridge]
Track: sparkcrm-contractable-shadowing-pilot-v0

Goal:
Wrap one existing Spark CRM ledger finder/service with an Igniter contractable
observed execution path in shadow/primary-observed mode, emitting redacted
receipts and no production behavior changes.

Suggested targets:
- Option A: AvailabilityLedger::SlotMap for why-not availability reasons.
- Option B: OrderPriceLedger::Finder for chain winner explanation.

Non-authorizations:
- no Spark ledger replacement;
- no production output changes;
- no real payload publication;
- no Igniter-Lang runtime execution;
- no primary Ledger DB migration.
```

## Recommendation

Recommendation for C4-A: route.

Route the first adoption slice to a bounded contractable shadowing pilot. Keep Igniter-Lang in fixture/spec pressure mode and Igniter Ledger in sidecar receipt research mode. Hold any replacement, runtime execution, production TBackend binding, or primary ledger migration.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: sparkcrm-igniter-adoption-readiness-map-v0
Status: done
Neighbors: Bridge Agent | Compiler/Grammar Expert

[D] Decisions:
- Spark CRM is ready for Igniter observation/shadowing, not replacement.
- First pilot should be contractable shadowing of one existing ledger finder/service.
- Igniter Ledger should start as sidecar receipt sink only.
- Igniter-Lang should continue fixture/spec pressure for interval validity, BiHistory, typed scope chains, Decimal, retention, and why receipts.

[R] Recommendations:
- Route `sparkcrm-contractable-shadowing-pilot-v0`.
- Prefer `AvailabilityLedger::SlotMap` for why-not value or `OrderPriceLedger::Finder` for scope-chain explanation value.
- Require Sidekiq/ActiveJob durable observation adapter before serious production-adjacent receipt volume.

[S] Signals:
- Spark ledgers already match the Igniter spine: scope + time + source/actor + projection + diagnostics.
- Biggest immediate value is explainability, not runtime replacement.
- Effective intervals and bitemporal known-time split are the strongest language deltas.

[T] Tests / Proofs:
- Read-only document synthesis only.
- No tests run; no code changed.

[Files] Changed:
- igniter-lang/docs/tracks/sparkcrm-igniter-adoption-readiness-map-v0.md

[Q] Open Questions:
- Which first pilot target has better operational leverage: availability why-not or price winner explanation?
- Should the durable observation adapter be implemented before or during the first pilot?
- What exact redaction policy should Bridge require for observation receipts?

[X] Rejected:
- Real Spark CRM code inspection in this slice.
- Spark CRM code edits.
- Igniter Ruby framework implementation.
- Production replacement of Spark ledgers.
- Igniter-Lang runtime execution of Spark decisions.
- Igniter Ledger as primary Spark ledger DB.

[Next] Proposed next slice:
- `sparkcrm-contractable-shadowing-pilot-v0`
```
