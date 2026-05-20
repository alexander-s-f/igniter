# Round Report: ruby-framework current-state-analysis-round-v0

Status: done
Date: 2026-05-20
Supervisor: [Igniter Ruby Framework Supervisor]
Scope: Current Ruby Framework lane/package state analysis.

## Executive Summary

- Portfolio guidance `PG-2026-05-20-01` was checked before opening/closing this
  analysis round.
- Ruby Framework can support a primary-only observed-service Spark pilot using
  existing package surfaces.
- `igniter-embed` is the highest-leverage near-term package: it already owns
  primary-only observation, receipt creation, store adapter protocol, redaction
  hooks, and event hooks.
- `igniter-ledger` and `igniter-ledger-client` are optional sidecar boundaries,
  not first-pilot requirements and not Spark source-of-truth surfaces.
- Focused specs passed: 269 examples for contracts/embed/ledger-client and 27
  examples for Ledger `ContractableReceiptSink`.
- No implementation round should open until R87 Architect decision or Spark
  redaction feasibility confirmation.

## Decisions Needed From Portfolio

- [ ] No new decision required beyond pending `S3-R87-C3-A`, unless Portfolio
  wants to redirect the lane before Spark redaction feasibility lands.

## Completed

- Re-read active Portfolio guidance and Ruby Framework lane status.
- Re-read package README state for `igniter-contracts`, `igniter-embed`,
  `igniter-ledger`, and `igniter-ledger-client`.
- Ran focused specs for current observed-service/receipt-adjacent packages.
- Created current state analysis track.
- Updated Ruby Framework current status with analysis verdict and verification.

## Changed Files

- `.agents/ruby-framework/current-status.md`
- `.agents/ruby-framework/tracks/ruby-framework-current-state-analysis-v0.md`
- `.agents/ruby-framework/reports/ruby-framework-current-state-analysis-round-v0.md`

## Evidence

- tracks:
  - `.agents/ruby-framework/tracks/ruby-framework-current-state-analysis-v0.md`
  - `.agents/ruby-framework/tracks/spark-contractable-shadowing-pilot-scope-v0.md`
- gates:
  - `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
- discussions:
  - none new
- guidance:
  - `PG-2026-05-20-01`
- tests/proofs:
  - `bundle exec rspec packages/igniter-contracts/spec packages/igniter-embed/spec packages/igniter-ledger-client/spec`
  - `BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec/igniter/store/contractable_receipt_sink_spec.rb`

## Risks / Drift

- Spark has not yet confirmed whether useful availability why-not summaries can
  be emitted without raw slot payloads.
- There is no app-owned durable queue/outbox adapter design yet.
- Admin lookup by `observation_id` remains design-only.
- It would be premature to generalize Rails adoption APIs before one pilot
  proves the receipt path.

## Cross-Lane Requests

To Ruby Framework:

- Stay in primary-observed-only design posture.
- Do not open shadow candidate implementation.

To Igniter-Lang:

- Wait for stable sanitized availability receipt vocabulary before fixture work.

To Spark CRM:

- Confirm concrete target and redaction feasibility for availability why-not
  summaries.

To Portfolio:

- Continue with pending `S3-R87-C3-A` decision or redirect if this analysis
  changes the expected boundary.

## Recommended Next

- Hold until R87 Architect decision or Spark redaction feasibility packet.
- If accepted, open only a primary-observed-service implementation-scope design
  card, not a shadow candidate implementation card.

