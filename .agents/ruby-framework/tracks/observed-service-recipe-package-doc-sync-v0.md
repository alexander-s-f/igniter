# Observed-Service Recipe Package Doc Sync v0

Status: ready notes
Date: 2026-05-20
Card: RUBY-DOC-P1
Route: UPDATE
Track: observed-service-recipe-package-doc-sync-v0
Guidance: PG-2026-05-20-01

## Purpose

Prepare package-doc and release-readiness notes for the observed-service
receipt recipe without generalizing Ruby API, adding package code, publishing
gems, or opening shadow candidate implementation.

These notes are the sync boundary for later package documentation work. They
should not be treated as authorization to widen public API.

## Current Packages Already Support

### igniter-contracts

`igniter-contracts` already provides the lower-level embedded kernel and the
core `Contractable` service protocol.

Supported now:

- contract class DSL and embedded runtime execution;
- `compute using:` integration for contractable services;
- declared service `input` / `output` protocol boundaries;
- normalized service payloads with `outputs`, `observations`, `error`,
  `metadata`, and `success`;
- role, stage, and metadata carried through contractable service metadata;
- report-only receipt payload carriers in the Lang foundation surface.

Observed-service doc implication:

- Mention `igniter-contracts` only as the lower-level protocol foundation.
- Do not move the observed-service wrapper recipe into `igniter-contracts`;
  the wrapper belongs to `igniter-embed`.

### igniter-embed

`igniter-embed` already provides the host-local adoption surface used by the
recipe and Rails proof.

Supported now:

- `Igniter::Embed.contractable`;
- primary callable wrapping that returns the primary result unchanged;
- primary-only observed-service mode;
- migration/shadow configuration surfaces, with candidate omitted for this
  recipe;
- sampling through `shadow async:, sample:`;
- normalizer hooks;
- allow-list redaction hooks;
- event hooks including observation and failure families;
- canonical observation and event receipt emission;
- `record_observation` / `record_event` store adapter protocol;
- default async handoff descriptor for app-owned durable adapters.

Observed-service doc implication:

- `igniter-embed` is the only package README that should eventually receive a
  generic observed-service recipe section.
- Any future public wording should say "primary-only observed service" and
  "host-local store adapter", not "Spark adapter" or "production rollout".

### igniter-ledger

`igniter-ledger` already provides an optional receipt sink for Embed receipts.

Supported now:

- `Igniter::Ledger::ContractableReceiptSink`;
- observation receipt writes through `record_observation`;
- event receipt appends through `record_event`;
- lookup by `observation_id`;
- event listing by observation;
- status/error-oriented receipt queries;
- descriptor registration for observation store and event history;
- construction through either an embedded `LedgerStore` or a protocol client.

Observed-service doc implication:

- Keep Ledger phrasing optional.
- Do not document Ledger sidecar as Spark's source of truth.
- Do not require Ledger for the first Spark pilot; Spark may use an app-local
  table, outbox, metrics-backed proof table, or optional Ledger sink.

### igniter-ledger-client

`igniter-ledger-client` already provides the protocol-first boundary for
packages or host apps that need to talk to Ledger without reaching into Ledger
internals.

Supported now:

- local object dispatch wrapping;
- remote HTTP dispatch;
- write, append, read, query, replay, and metadata calls;
- read-only provenance/introspection helpers;
- transport/protocol error semantics;
- no runtime dependency on `igniter-ledger`.

Observed-service doc implication:

- Package-level receipt adapters should prefer `client:` over direct Ledger
  internals if a package adapter is opened later.
- This is not needed for the first Spark app-local pilot unless Spark chooses
  to route receipts through a Ledger protocol boundary.

## What Remains App-Local For Spark

Spark owns the first pilot implementation:

- exact operational service target;
- initializer placement and rollout flag;
- sample rate and environment gating;
- normalizer implementation;
- aggregate why-not vocabulary;
- redaction allow-list;
- digest strategy and version names;
- app-local store adapter;
- persistence target: receipt table, outbox, metrics-backed proof table, or
  optional Ledger sink;
- read-only admin/MCP lookup by `observation_id`;
- logging, metrics, and alerting on receipt pipeline failures;
- fixture sanitization before any cross-lane or public artifact.

Spark must keep these closed in the first pilot:

- raw slot maps;
- customer, provider, employee, or technician personal data;
- auth/session/request headers;
- provider payloads;
- real private identifiers in shared fixtures;
- any business decision sourced from receipts.

Ruby package docs should not include Spark class names, Spark internal target
names, or real Spark payload shapes. Use generic host-app names until Spark
provides a sanitized fixture vocabulary.

## What Should Wait For One Fixture / Design Cycle

Wait until Spark returns one sanitized persisted observation receipt and one
event receipt before opening:

- package README changes that advertise a complete observed-service recipe;
- public example fixture in `igniter-lang`;
- canonical availability vocabulary in package docs;
- receipt schema constants or typed receipt classes;
- Rails generator or Rails adoption kit;
- package-owned ActiveJob/Sidekiq adapter;
- package-level Spark adapter;
- generalized receipt table migration API;
- durable queue/outbox package API;
- shadow candidate implementation;
- comparison/acceptance policy docs for the Spark pilot;
- release claims that observed-service receipts are production-ready for Spark.

The design cycle should answer:

- Which Spark target is the pilot?
- Which receipt fields are stable enough for docs?
- Which redaction fields survive review?
- Is metrics-backed persistence enough for local proof only?
- Does broader rollout require a dedicated receipt table or outbox?
- Does Spark need LedgerClient, or is app-local storage sufficient for v0?

## Release-Readiness Notes

Package release-readiness can proceed as a review only after the Spark fixture
cycle, not before it.

Known release-readiness evidence already exists:

- root `bundle exec rake` passed in the Rails proof round;
- Ledger package specs passed in the Rails proof round;
- Rails proof app passed against path gems;
- clean installed-gem Rails proof smoke passed from built gems.

Known release note to preserve:

- `igniter-ledger` clean install currently needs crates.io/network access for
  native extension dependencies unless dependencies are vendored or prebuilt
  native artifacts are introduced.

Recommended future public-doc sync after Spark fixture:

- add one generic primary-only observed-service section to
  `packages/igniter-embed/README.md`;
- keep `packages/igniter-ledger/README.md` as optional receipt sink docs;
- mention `packages/igniter-ledger-client/README.md` only for protocol-boundary
  adapters;
- avoid Spark-specific names and raw fixture payloads;
- preserve the statement that primary behavior remains authoritative.

## Current Recommendation

Hold public package docs steady for now.

Next route: Spark fixture/design follow-up. After Spark returns one sanitized
receipt pair, open package-doc sync as a narrow docs change, then consider
release-readiness review.
