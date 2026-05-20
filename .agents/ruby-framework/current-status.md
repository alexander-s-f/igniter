# Igniter Ruby Framework Adoption Lane - Current Status

Route: INIT
Agent: [Igniter Ruby Framework Supervisor]
Role: ruby-framework-supervisor
Lane: ruby-framework
Track: spark-contractable-shadowing-adoption-plan-v0
Status: initialized-design-lane
Date: 2026-05-20

---

## Purpose

This lane coordinates Igniter Ruby framework adoption pressure for Spark-compatible
contractable shadowing and receipt infrastructure.

The lane is intentionally separate from Igniter-Lang compiler/spec work and from
Spark CRM implementation work. Its job is to shape the Ruby package adoption path
so Spark can observe current services, compare future candidates, and persist
redacted receipts without changing production authority.

## Source Material Read

- `AGENTS.md`
- `packages/igniter-contracts`
- `packages/igniter-embed`
- `packages/igniter-ledger`
- `packages/igniter-ledger-client`
- `igniter-lang/docs/gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md`
- `/Users/alex/dev/projects/sparkcrm/docs/agents/spark-ledger-igniter-friendly-roadmap.md`

## Adopted Ground Truth

R86 routes Spark CRM material as an active applied-pressure source, not canon and
not implementation authority.

Accepted near-term shape:

```text
existing Spark primary service
  -> observed-service or shadow contractable wrapper
  -> normalized comparison when candidate exists
  -> redacted observation/event receipts
  -> optional durable receipt sink
  -> proof before any production behavior change
```

## Package Boundary Map

`igniter-contracts` owns the embedded kernel and core `Contractable` service
protocol. It validates declared inputs/outputs at the protocol boundary and
normalizes service results into `outputs`, `observations`, `error`, `metadata`,
and `success`.

`igniter-embed` owns host-local contract registration and the contractable
wrapper for migration, observed-service mode, shadow mode, sampling, redaction,
async handoff descriptors, typed events, and canonical observation/event receipt
production.

`igniter-ledger` owns the durable Ledger substrate and
`ContractableReceiptSink`, which accepts Embed receipts via
`record_observation` / `record_event`, registers receipt descriptors, and can
write through either a local Ledger store or a LedgerClient.

`igniter-ledger-client` owns the protocol-first client boundary. Spark-facing or
package-level receipt adapters should prefer `client:` over coupling to Ledger
storage internals once the adoption path leaves local proof mode.

## Current Ruby Framework Readiness

- Core contractable services can declare role, stage, inputs, outputs, and
  metadata.
- Embed contractable wrappers preserve primary return values synchronously.
- Primary-only observed-service mode is supported.
- Shadow candidate mode is supported with normalization, differential reports,
  acceptance policies, sampling, async adapters, and typed events.
- Canonical receipt status values exist: `:ok`, `:diverged`,
  `:candidate_error`, `:acceptance_failed`, `:store_error`, and `:unsampled`.
- Event receipts link to observation receipts by `observation_id`.
- Ledger receipt sink can persist observations as keyed current facts and events
  as append-only history partitioned by `observation_id`.
- LedgerClient can carry the sink through the protocol boundary.

## Active Risks

- Embed's default async adapter is a local Ruby thread. Spark production-adjacent
  volume requires a durable app adapter before rollout beyond very low-volume
  sampling.
- Redaction must be designed per Spark target before any receipt leaves local
  proof fixtures. Raw customer/provider payloads, credentials, and PII are
  closed.
- The current Ruby package APIs are pre-v1 and can change. Adoption cards should
  prefer proofable boundaries over broad compatibility promises.
- Spark target names in this lane are internal applied-pressure material. Public
  docs must abstract or remove those names.

## Closed Surfaces

This lane does not authorize:

- Spark CRM code edits;
- Igniter Ruby framework code edits;
- Spark production behavior changes;
- replacement of Spark primary services;
- real Spark data, credentials, endpoints, provider payloads, customer records,
  phone/email data, or raw infrastructure details in artifacts;
- high-volume receipt rollout without a durable queue/outbox adapter;
- Ledger as Spark source of truth;
- `.igapp` operational deployment for Spark;
- Igniter-Lang runtime execution of Spark decisions;
- compiler, parser, TypeChecker, public CLI/API, or strict-refusal changes.

## Open Roadmap

Primary roadmap:

- `spark-contractable-shadowing-adoption-plan-v0`

First proposed card:

- `cards/s3-r87-c1-rf1-spark-contractable-shadowing-pilot-scope-v0.md`
