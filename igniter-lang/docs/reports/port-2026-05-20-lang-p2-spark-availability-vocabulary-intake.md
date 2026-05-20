# Round Report: Igniter-Lang PORT-2026-05-20-LANG-P2

Status: done
Date: 2026-05-20
Supervisor: [Igniter-Lang Supervisor]
Scope: Create an intake map for sanitized Spark availability receipt vocabulary without opening fixtures/spec/compiler work.
Guidance: PG-2026-05-20-01

## Executive Summary

- Spark P1 answers `useful_without_raw_slot_payloads = yes` for aggregate why-not availability summaries.
- Ruby P1 answers that existing package surfaces can support a first `primary_observed_only` pilot; no new package code is needed now.
- Created an intake-only vocabulary map at `igniter-lang/docs/org/indexes/spark-availability-receipt-vocabulary-intake-map-v0.md`.
- Stable intake items are limited to aggregate availability counts/categories and fail-open behavior.
- Digest envelopes, observation id lookup, idempotency policy, shared redaction naming, and neutral service-ref vocabulary remain candidates, not fixture-ready.
- Recommendation: `hold / ask Spark-Ruby follow-up`; do not open Igniter-Lang fixture design yet.

## Decisions Needed From Portfolio

- [ ] Confirm `PG-2026-05-20-01` should remain active.
- [ ] Confirm next dispatch should ask Spark for a sanitized persisted receipt example and Ruby for a recipe/doc mapping before Lang fixture design opens.

## Completed

- Read Base Role, Portfolio guidance, Portfolio reporting protocol, and R88 closure packet.
- Read Spark P1 report packet:
  `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-20-SPARK-P1.md`.
- Read Ruby P1 report packet:
  `.agents/ruby-framework/reports/port-2026-05-20-ruby-p1-minimal-receipt-shape.md`.
- Extracted sanitized candidate vocabulary only.
- Classified each intake item as stable, candidate, Spark-owned, Ruby-owned,
  forbidden/private, or not ready for fixtures.
- Preserved fixture/spec/compiler/runtime closure.

## Changed Files

- `igniter-lang/docs/org/indexes/spark-availability-receipt-vocabulary-intake-map-v0.md`
- `igniter-lang/docs/reports/port-2026-05-20-lang-p2-spark-availability-vocabulary-intake.md`

## Evidence

Tracks / reports:

- `igniter-lang/docs/tracks/stage3-round88-status-curation-v0.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-20-SPARK-P1.md`
- `.agents/ruby-framework/reports/port-2026-05-20-ruby-p1-minimal-receipt-shape.md`

Guidance:

- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
- `PG-2026-05-20-01`

Tests/proofs:

- No code tests run by this Lang intake slice.
- Spark P1 and Ruby P1 report their own proof/test evidence.

## Risks / Drift

- Spark persistence is currently metrics-backed, not a dedicated durable receipt table.
- Spark P1 allows internal `employee_ref`; shared Lang fixtures must use synthetic/redacted refs only.
- Spark metric names and class names must remain source context, not public Lang vocabulary.
- Ruby supports `input_digest`, `output_digest`, and `observation_id`, but Spark P1 does not yet prove a concrete digest envelope or dedicated receipt lookup surface.
- `available_ratio` vs `availability_ratio` naming is not settled.
- Idempotency key policy is placeholder-level only.

## Cross-Lane Requests

To Ruby Framework:

- Produce the recommended recipe doc for the app-local observed-service wrapper.
- Clarify mapping from Spark aggregate metric fields into Ruby observation receipt fields.
- Clarify `reason_counts` container naming and idempotency placeholder expectations.

To Igniter-Lang:

- Hold fixture/spec work.
- Do not treat this map as canon or fixture authorization.

To Spark CRM:

- Provide one sanitized persisted receipt example from the observed availability path.
- Confirm observation id/digest availability, unavailable count handling, and neutral naming for ratio fields.
- Confirm whether the metrics-backed path is enough for the first admin-only pilot read surface.

To Portfolio:

- Keep guidance active or amend it after deciding the next dispatch.
- Do not open Lang fixture design until the persisted receipt example and Ruby recipe/mapping exist, unless explicitly accepting those gaps as deferred.

## Recommended Next

Recommendation:

```text
hold / ask Spark-Ruby follow-up
```

Suggested next dispatch:

- Spark: produce a sanitized persisted receipt example and answer digest /
  observation-id / ratio naming questions.
- Ruby Framework: produce `recipe-doc` for the app-local observed-service wrapper
  and field mapping.
- Portfolio: review whether those answers are enough to open a later sanitized
  fixture design card.

Closed:

- no Igniter-Lang fixtures;
- no spec/proposal updates;
- no compiler/runtime edits;
- no Spark/Ruby/Ledger code edits from the Lang lane;
- no production/runtime/sidecar widening.
