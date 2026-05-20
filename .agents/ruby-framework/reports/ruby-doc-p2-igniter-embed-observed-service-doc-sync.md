# Round Report: ruby-framework RUBY-DOC-P2 igniter-embed observed-service doc sync

Status: done
Date: 2026-05-20
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: igniter-embed-observed-service-doc-sync-v0
Guidance: PG-2026-05-20-01
Scope: Narrow `igniter-embed` observed-service docs sync using Lang fixtures only as sanitized normalizer output examples.

## Executive Summary

- Added a narrow observed-service docs section to `packages/igniter-embed/README.md`.
- Used the accepted Lang availability fixture payload only as a sanitized
  `primary.outputs` / normalizer aggregate example.
- Preserved Embed receipt envelope vocabulary separately:
  `:contractable_observation` and `:contractable_event`.
- Explicitly stated that `"availability_slot_map_summary"` is fixture/example
  output vocabulary, not an Embed receipt kind.
- No Ruby API generalization, package code, release-readiness claim, release,
  Spark adapter, Rails generator, durable queue API, or shadow candidate work
  was opened.

## Decisions Needed From Portfolio

- [ ] None required to close this docs-only Ruby round.

## Completed

- Checked active Portfolio guidance `PG-2026-05-20-01`.
- Read Ruby fixture doc readiness and Lang fixture notes.
- Updated `igniter-embed` package docs only.
- Wrote this report packet and local track note.

## Changed Files

- `packages/igniter-embed/README.md`
- `.agents/ruby-framework/tracks/igniter-embed-observed-service-doc-sync-v0.md`
- `.agents/ruby-framework/reports/ruby-doc-p2-igniter-embed-observed-service-doc-sync.md`

## Evidence

- Ruby readiness:
  - `.agents/ruby-framework/tracks/observed-service-fixture-doc-readiness-v0.md`
  - `.agents/ruby-framework/recipes/observed-service-receipt-recipe-v0.md`
- Lang fixture notes:
  - `igniter-lang/experiments/spark_availability_metrics_fixture/fixtures/FIXTURE_NOTES.md`
  - `igniter-lang/experiments/spark_availability_metrics_fixture/fixtures/spark_availability_slot_map_summary_available.json`
  - `igniter-lang/experiments/spark_availability_metrics_fixture/fixtures/spark_availability_slot_map_summary_unavailable.json`
- Package doc changed:
  - `packages/igniter-embed/README.md`

## Risks / Drift

- The inserted aggregate payload contains a nested `receipt_kind` field from
  the fixture vocabulary. The docs now explicitly say this is not the top-level
  Embed receipt kind.
- Future docs should avoid turning `available_ratio` or
  `availability_slot_map_summary` into public Ruby API without a separate
  decision.
- Release-readiness remains unopened.

## Cross-Lane Requests

To Spark CRM:

- Treat the docs example as sanitized aggregate normalizer shape only, not as a
  dedicated Spark receipt/event store claim.

To Igniter-Lang:

- Keep fixture-design vocabulary marked non-canon unless separately promoted.

To Portfolio:

- Keep Ruby API generalization and release-readiness review closed until
  explicitly opened.

## Recommended Next

`hold` for Ruby docs unless Portfolio opens release-readiness review or Spark
returns a richer dedicated observation/event receipt pair.
