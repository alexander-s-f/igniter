# Round Report: ruby-framework RUBY-FIXTURE-P1 observed-service fixture doc readiness

Status: done
Date: 2026-05-20
Supervisor: [Ruby Framework Supervisor]
Route: UPDATE
Track: observed-service-fixture-doc-readiness-v0
Guidance: PG-2026-05-20-01
Scope: Evaluate Lang Spark availability fixtures as input for future `igniter-embed` observed-service docs sync.

## Executive Summary

- Evaluated the Lang Spark availability metrics fixtures against the Ruby
  observed-service recipe and package-doc notes.
- Verdict: package-doc sync can open after Spark feedback, but only as a narrow
  docs sync.
- The Lang fixtures are sufficient as sanitized aggregate normalizer examples.
- The Lang fixtures are not observation receipts, event receipts, store adapter
  evidence, idempotent receipt records, or public schema canon.
- No package docs, package code, Ruby API generalization, release, or shadow
  candidate work was opened.

## Decisions Needed From Portfolio

- [ ] None required to close this Ruby evaluation round.
- [ ] Optional: keep next route as Spark feedback, then narrow package-doc sync.

## Completed

- Checked active Portfolio guidance `PG-2026-05-20-01`.
- Read Lang P3 fixture readiness, P4 fixture design, P6 fixture creation, and
  fixture notes/files.
- Read Ruby observed-service recipe and package-doc notes.
- Wrote Ruby readiness note with exact blockers before package-doc sync.

## Changed Files

- `.agents/ruby-framework/tracks/observed-service-fixture-doc-readiness-v0.md`
- `.agents/ruby-framework/reports/ruby-fixture-p1-observed-service-doc-readiness.md`

## Evidence

- Lang fixture readiness:
  - `igniter-lang/docs/reports/port-2026-05-20-lang-spark-p3-availability-fixture-readiness.md`
  - `igniter-lang/docs/tracks/spark-availability-metrics-fixture-design-v0.md`
  - `igniter-lang/docs/tracks/spark-availability-synthetic-fixture-creation-v0.md`
- Lang fixtures:
  - `igniter-lang/experiments/spark_availability_metrics_fixture/fixtures/FIXTURE_NOTES.md`
  - `igniter-lang/experiments/spark_availability_metrics_fixture/fixtures/spark_availability_slot_map_summary_available.json`
  - `igniter-lang/experiments/spark_availability_metrics_fixture/fixtures/spark_availability_slot_map_summary_unavailable.json`
- Ruby recipe/docs:
  - `.agents/ruby-framework/recipes/observed-service-receipt-recipe-v0.md`
  - `.agents/ruby-framework/tracks/observed-service-recipe-package-doc-sync-v0.md`

## Readiness Answer

```text
docs sync can open after Spark feedback, but only as a narrow package-doc sync
```

The fixtures can support a sanitized `primary.outputs` normalizer example in
future `igniter-embed` docs. They cannot support a full receipt-envelope docs
claim because they intentionally omit `observation_id`, `event_id`, digests,
idempotency, `reason_counts`, store adapter evidence, and event receipts.

## Exact Blockers Before Package-Doc Sync

- Spark confirms the fixture payloads are acceptable as public-facing package
  doc examples.
- Spark/Ruby settle `available_ratio` vs `availability_ratio` wording.
- Ruby prevents `receipt_kind` collision between Embed receipt envelopes and
  Lang fixture-design vocabulary.
- Spark confirms whether `unknown` is safe before any error example is used.
- Spark confirms whether first docs sync stays metrics-only or waits for a
  dedicated observation/event receipt pair.
- Ruby chooses flat slot counts vs `reason_counts` mapping for docs.
- Docs explicitly preserve app-local ownership and optional Ledger stance.
- Deferred richer receipt fields stay absent from Spark fixture examples.

## Risks / Drift

- The biggest drift risk is mistaking metrics-backed aggregate fixtures for
  contractable observation receipts.
- `receipt_kind` is overloaded between the fixture payload and Embed receipt
  envelope unless docs call out the distinction.
- Public docs must avoid making Lang fixture-design vocabulary look like Ruby
  API.

## Cross-Lane Requests

To Spark CRM:

- Send a short feedback packet resolving the exact blockers listed above.

To Igniter-Lang:

- Keep the current fixture notes' non-canon and deferred-field warnings intact.

To Portfolio:

- Keep Ruby package API generalization closed until the narrow package-doc sync
  is explicitly opened.

## Recommended Next

`Spark feedback`, then `package-doc sync`.

Release-readiness review should remain after narrow docs sync and should not
start from the Lang fixtures alone.
