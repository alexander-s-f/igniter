# Round Report: ruby-framework RUBY-DOC-P1 observed-service package-doc sync

Status: done
Date: 2026-05-20
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: observed-service-recipe-package-doc-sync-v0
Guidance: PG-2026-05-20-01
Scope: Prepare package-doc/release-readiness notes for observed-service recipe without API generalization or package code.

## Executive Summary

- Prepared package-doc/release-readiness notes for the observed-service recipe.
- Confirmed current package support is sufficient for the first Spark
  `primary_observed_only` pilot.
- Kept Spark-specific implementation, persistence, rollout, redaction, and
  fixtures app-local.
- Deferred public package README sync until one Spark fixture/design cycle
  produces a sanitized persisted observation receipt and event receipt.
- No package code, gem publishing, release, or shadow candidate work was opened.

## Decisions Needed From Portfolio

- [ ] None required to close this docs-only Ruby round.
- [ ] Optional: keep the next route as Spark fixture/design follow-up before
  package-doc sync or release-readiness review.

## Completed

- Checked active Portfolio guidance `PG-2026-05-20-01`.
- Read the observed-service recipe and P2 report.
- Reviewed current package README surfaces for `igniter-contracts`,
  `igniter-embed`, `igniter-ledger`, and `igniter-ledger-client`.
- Searched package/spec surfaces for current contractable receipt support.
- Wrote package-doc/release-readiness notes under the Ruby Framework track.

## Changed Files

- `.agents/ruby-framework/tracks/observed-service-recipe-package-doc-sync-v0.md`
- `.agents/ruby-framework/reports/ruby-doc-p1-observed-service-package-doc-sync.md`

## Evidence

- guidance:
  - `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
  - active guidance `PG-2026-05-20-01`
- recipe/report inputs:
  - `.agents/ruby-framework/recipes/observed-service-receipt-recipe-v0.md`
  - `.agents/ruby-framework/reports/port-2026-05-20-ruby-p2-observed-service-recipe.md`
  - `.agents/ruby-framework/reports/port-2026-05-20-ruby-p1-minimal-receipt-shape.md`
- package docs reviewed:
  - `packages/igniter-contracts/README.md`
  - `packages/igniter-embed/README.md`
  - `packages/igniter-ledger/README.md`
  - `packages/igniter-ledger-client/README.md`

## Current Package Support

- `igniter-contracts`: embedded kernel and core `Contractable` service
  protocol.
- `igniter-embed`: host-local `contractable` wrapper, primary-only observed
  mode, normalizer/redaction hooks, receipt emission, events, and store adapter
  protocol.
- `igniter-ledger`: optional `ContractableReceiptSink` for observation/event
  receipt persistence and lookup.
- `igniter-ledger-client`: optional protocol boundary for receipt delivery
  without depending on Ledger internals.

## Spark App-Local Boundary

Spark retains ownership of target selection, feature flag/sample rate,
normalizer, redaction, persistence, lookup, monitoring, and sanitized fixture
production.

Ruby should not add a Spark adapter, Rails generator, durable queue adapter, or
receipt schema generalization before the first fixture/design cycle completes.

## Risks / Drift

- Public package docs already contain shadow/migration examples; any future
  observed-service docs must avoid implying Spark is ready for shadow
  candidates.
- Ledger docs already show `ContractableReceiptSink`; future docs must keep it
  optional and not a source of truth.
- Release-readiness review should preserve the known `igniter-ledger` native
  extension network dependency note.

## Cross-Lane Requests

To Spark CRM:

- Return one sanitized persisted observation receipt and one event receipt
  before Ruby opens public package README sync.

To Portfolio:

- Keep package API generalization closed until the Spark fixture/design cycle
  completes.

To Igniter-Lang:

- Continue waiting for stable sanitized receipt vocabulary before fixture work.

## Recommended Next

`Spark follow-up`.

After Spark returns the sanitized receipt pair and design answers, open a narrow
`package-doc sync` round. `release-readiness-review` should remain after that.
