# Round Report: ruby-framework spark-contractable-shadowing-adoption-round-v0

Status: done
Date: 2026-05-20
Supervisor: [Igniter Ruby Framework Supervisor]
Scope: Design-only first Spark contractable observation/shadowing pilot scope.

## Executive Summary

- Ruby Framework lane recommends an Availability-style slot-map / why-not
  availability pilot as the first observed-service target.
- OrderPrice-style chain-winner explanation remains the second pilot family
  after receipt capture and normalizer quality are proven.
- The pilot keeps Spark primary output authoritative and unchanged.
- The design uses existing `Igniter::Embed.contractable`,
  `record_observation`, `record_event`, and optional LedgerClient/receipt sink
  surfaces only.
- Receipt capture, store errors, and durable enqueue failures must fail open.
- High-volume or production-adjacent rollout is blocked until Spark has an
  app-owned durable queue/outbox adapter.

## Decisions Needed From Portfolio

- [ ] Accept or adjust the Ruby Framework recommendation that Availability-style
  why-not availability observation is the first pilot target.
- [ ] Confirm the closed surfaces remain correct: no Spark code edits, no
  Igniter package edits, no production authority change, no Ledger source of
  truth.

## Completed

- Read Spark app letter requesting Rails-first contractable observation needs.
- Read R86 readiness/gate material and Ruby Framework lane adoption docs.
- Created the design track:
  `.agents/ruby-framework/tracks/spark-contractable-shadowing-pilot-scope-v0.md`.
- Updated Ruby Framework lane current status with the latest track and report
  packet.

## Changed Files

- `.agents/ruby-framework/current-status.md`
- `.agents/ruby-framework/tracks/spark-contractable-shadowing-pilot-scope-v0.md`
- `.agents/ruby-framework/reports/ruby-framework-spark-contractable-shadowing-adoption-round-v0.md`

## Evidence

- tracks:
  - `.agents/ruby-framework/tracks/spark-contractable-shadowing-pilot-scope-v0.md`
  - `.agents/ruby-framework/spark-contractable-shadowing-adoption-plan-v0.md`
  - `igniter-lang/docs/tracks/sparkcrm-igniter-adoption-readiness-map-v0.md`
- gates:
  - `igniter-lang/docs/gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md`
- discussions:
  - `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/letters/outgoing/2026-05-20-igniter-ruby-framework-spark-contractable-needs.md`
- tests/proofs:
  - Not run; docs-only design round.

## Risks / Drift

- Spark implementation pressure may push toward reading private service code
  before the design boundary is accepted.
- In-process receipt persistence can couple latency/failure to live flows unless
  Spark uses fail-open behavior and durable enqueue.
- Output normalization for availability must avoid leaking raw slot/provider or
  customer detail.
- Local Ruby thread async remains non-durable and should not be treated as
  production-adjacent reliability.

## Cross-Lane Requests

To Ruby Framework:

- Hold this as design-only until a separate implementation-scope card is
  authorized.

To Igniter-Lang:

- Use the availability why-not receipt vocabulary as fixture pressure only after
  Portfolio/Spark confirms the target.

To Spark CRM:

- Confirm concrete target, redaction allow-list, store adapter location, durable
  enqueue posture, admin lookup boundary, test/proof plan, and rollback flag.

To Portfolio:

- Accept, adjust, or redirect the first pilot target recommendation and boundary.

## Recommended Next

- Send the design track to Spark App Supervisor as the Ruby Framework answer to
  the Rails-first contractable observation needs letter.
- Open an implementation-scope card only after Spark confirms the concrete
  target and redaction/store/durable/admin boundaries.

