# Ruby Framework Current State Analysis v0

Card: RUBY-FRAMEWORK-CURRENT-STATE-ANALYSIS
Agent: [Igniter Ruby Framework Supervisor]
Role: ruby-framework-supervisor
Track: ruby-framework-current-state-analysis-v0
Route: UPDATE
Status: done-analysis
Date: 2026-05-20

---

## Goal

Update the Ruby Framework lane state and analyze what the Igniter Ruby
framework has right now for Spark-compatible observed-service adoption.

This is an analysis round. It does not authorize implementation, Spark code
inspection, Spark code edits, Igniter package edits, shadow candidate rollout,
or production behavior changes.

## Portfolio Guidance Check

Active guidance read:

```text
PG-2026-05-20-01
```

Adopted constraint:

```text
primary_observed_only until one redacted receipt path is proven end-to-end
```

Implications for this lane:

- no shadow candidate implementation yet;
- no broad API generalization before one pilot works;
- no sidecar source-of-truth claims;
- no real Spark identifiers, private data, or raw payloads in shared artifacts.

## Evidence Read

- `.agents/ruby-framework/current-status.md`
- `.agents/ruby-framework/README.md`
- `.agents/ruby-framework/reports/README.md`
- `.agents/ruby-framework/tracks/spark-contractable-shadowing-pilot-scope-v0.md`
- `packages/igniter-contracts/README.md`
- `packages/igniter-embed/README.md`
- `packages/igniter-ledger/README.md`
- `packages/igniter-ledger-client/README.md`
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`

No private Spark CRM service code was inspected.

## Verification Run

```text
bundle exec rspec packages/igniter-contracts/spec packages/igniter-embed/spec packages/igniter-ledger-client/spec
269 examples, 0 failures
```

```text
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec/igniter/store/contractable_receipt_sink_spec.rb
27 examples, 0 failures
```

## Current Package State

### igniter-contracts

Status: usable embedded kernel and contractable service protocol.

What exists:

- host-embeddable contract/kernel/profile/runtime layer;
- class DSL for app-local contracts;
- `Igniter::Contracts::Contractable` for service objects;
- declared `input`, `output`, `role`, `stage`, and `meta`;
- normalized service result payload with `outputs`, `observations`, `error`,
  `metadata`, and success/failure semantics;
- additive `Igniter::Lang` report-only metadata and receipt payload carriers.

Adoption meaning:

- good lower-layer dependency for Rails app integration;
- enough to describe candidate/observed service shape;
- not responsible for Rails hosting, durable queues, storage pools, or Spark
  app policy.

### igniter-embed

Status: strongest near-term Spark adoption package.

What exists:

- host-local configuration and explicit registration;
- optional Rails reloader integration;
- `Igniter::Embed.contractable` wrapper;
- primary-only `observe` mode;
- `migrate ... to:` and `shadow` declaration for later candidate comparison;
- redaction, normalizer, acceptance, store, capability, and event hooks;
- canonical observation receipts;
- canonical event receipts;
- `record_observation` / `record_event` store adapter protocol;
- local thread async and async handoff descriptor.

Adoption meaning:

- enough for primary-observed-only Spark pilot without new package code;
- receipt persistence must be app-supplied and fail-open;
- local thread async is proof-only, not durable production posture.

### igniter-ledger

Status: optional sidecar receipt sink and broader pre-v1 ledger substrate.

What exists:

- immutable facts, histories, replay, causation, protocol descriptors, and
  operational storage surfaces;
- `ContractableReceiptSink` for Embed observation/event receipts;
- observation store keyed by `observation_id`;
- event history partitioned by `observation_id`;
- local store and LedgerClient-backed sink modes.

Adoption meaning:

- useful as optional sidecar proof or local receipt sink;
- should not be Spark source of truth;
- should not be required for first Spark observed-service pilot.

### igniter-ledger-client

Status: correct protocol boundary for future sidecar delivery.

What exists:

- stable client facade over Ledger Open Protocol operations;
- object dispatch and remote HTTP transports;
- result objects for write, append, read, query, replay, lineage, subscriptions,
  and snapshots;
- package guidance that adapters accept `client:` rather than reaching into
  Ledger internals.

Adoption meaning:

- preferred boundary once a Spark app adapter wants optional Ledger delivery;
- not needed for the first in-app receipt proof;
- future pooling/retry/backpressure remains outside the current proof.

## Current Readiness Verdict

```text
Ready now:
  Rails app-local primary-only observation design
  Embed receipt shape reuse
  app-owned redaction allow-list
  app-owned store adapter protocol
  optional Ledger sidecar proof

Not ready / not authorized:
  shadow candidate implementation
  high-volume production-adjacent rollout
  generalized Rails adoption kit as public API
  Spark production authority switch
  Ledger source-of-truth usage
```

## Answers To Active Portfolio Guidance

### 1. Can Spark emit useful why-not availability summaries without raw slot payloads?

Ruby Framework answer: likely yes, if Spark confirms the operational target can
normalize outputs to low-cardinality reason summaries.

Proposed safe output vocabulary:

- `available_count`;
- `unavailable_count`;
- `reason_codes`;
- `reason_counts`;
- `window_summary`;
- `scope_refs`;
- `input_digest`;
- `output_digest`;
- optional `explanation_summary`.

Spark must confirm this is feasible without raw slot/provider/customer payloads.

### 2. What is the minimal receipt shape Ruby can support without new package code?

Ruby Framework answer: existing Embed receipts are sufficient.

Minimum observation fields:

- `schema_version`;
- `receipt_kind`;
- `observation_id`;
- `name`;
- `role`;
- `stage`;
- `mode`;
- `sampled`;
- `status`;
- timestamps and duration;
- redacted `inputs`;
- normalized `primary`;
- optional `candidate`;
- optional `report`;
- `metadata`;
- `redaction`;
- `store_error`.

Minimum event fields:

- `event_id`;
- `observation_id`;
- `event`;
- `severity`;
- `summary`;
- optional `observation_ref`.

### 3. Which sanitized fixture vocabulary should Igniter-Lang wait for?

Ruby Framework answer: wait for Spark to confirm an availability receipt
vocabulary built around reason summaries, scope refs, time window summaries,
and input/output digests.

Do not open public fixture work around raw class names, raw ids, SQL shape, or
provider/customer payloads.

## Gaps

- No Spark redaction feasibility packet yet.
- No chosen concrete operational target from Spark yet.
- No app-owned durable queue/outbox adapter design yet.
- No admin lookup proof by `observation_id` yet.
- No implementation authorization card.
- R87 Architect decision is still pending in lane status.

## Recommended Next

Keep the Ruby Framework lane in hold/observe posture until:

1. R87 Architect decision lands; or
2. Spark confirms the concrete availability target and redaction feasibility.

If Spark confirms feasibility, next Ruby Framework work should be an
implementation-scope design card for primary-only observation only. It should
not include candidate execution.

