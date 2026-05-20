# PORT-2026-05-20-LANG-SPARK-P2 Availability Vocabulary Recheck

Card: PORT-2026-05-20-LANG-SPARK-P2
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Route: UPDATE
Parent: [Portfolio Architect Supervisor]
Guidance: PG-2026-05-20-01
Status: hold
Date: 2026-05-20
Authority: report packet only / non-canon / non-fixture / non-implementation

---

## Executive Summary

Recommendation:

```text
hold / ask Spark-Ruby follow-up
```

Spark P2 improves the evidence: there is now a local synthetic persisted metrics
row for the availability observed path and generic metrics readback is enough
for first deploy-observe.

Ruby P2 improves the adoption guidance: the observed-service receipt recipe is
documented and no new Ruby package code is required for the first app-local
primary-observed-only pilot.

Igniter-Lang fixture design remains held. The P2 evidence still does not provide
one persisted redacted observation receipt with stable `observation_id`,
stable digest envelopes, resolved ratio naming, stable reason-count container
vocabulary, or concrete idempotency policy.

No intake-map rewrite is made in this slice because the classifications from
`spark-availability-receipt-vocabulary-intake-map-v0.md` remain directionally
correct: useful pressure exists, but fixture vocabulary is not ready.

---

## Read Set

- `igniter-lang/roles/base-role.md`
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
- `igniter-lang/docs/org/indexes/spark-availability-receipt-vocabulary-intake-map-v0.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-20-SPARK-P2.md`
- `.agents/ruby-framework/reports/port-2026-05-20-ruby-p2-observed-service-recipe.md`
- `.agents/ruby-framework/recipes/observed-service-receipt-recipe-v0.md`
- supporting Rails proof files:
  - `examples/rails_contracts_ledger/README.md`
  - `examples/rails_contracts_ledger/test/integration/availability_observation_test.rb`
  - `examples/rails_contracts_ledger/app/services/availability_slot_map_normalizer.rb`
  - `examples/rails_contracts_ledger/app/services/spark_contractable_receipt_store.rb`

---

## Explicit Answers

| Question | Answer | Notes |
| --- | --- | --- |
| Is there one persisted redacted receipt example? | `partial / no for Lang fixture readiness` | Spark P2 has one local synthetic persisted metric row and readback through generic metrics. It is not yet a persisted redacted observation receipt with `observation_id` and event receipt. Ruby proof app has a Rails example receipt path, but Spark P2 itself has metrics-backed persistence. |
| Is `observation_id` stable or still absent? | `still absent in Spark P2 metrics path` | Ruby recipe and Rails proof support `observation_id`; Spark P2 metric example does not include it. Dedicated receipt lookup remains later unless generic metrics prove insufficient. |
| Are input/output digest envelopes stable? | `candidate, not stable cross-lane` | Ruby recipe and Rails proof use `input_digest` / `output_digest`; Spark P2 metric example does not include digest envelope fields. |
| Are reason-count names stable? | `partially stable counts, container not stable` | Spark P2 metric tags include `available_slots`, `scheduled_slots`, `off_schedule_slots`, `day_off_slots`, `past_slots`, and `total_slots`. Ruby recipe recommends `reason_codes` and `reason_counts`. Mapping is not fixture-ready. |
| Is `available_ratio` vs `availability_ratio` resolved? | `no` | Spark P2 metric uses `available_ratio`; Ruby P2 recipe recommends `availability_ratio`. Do not choose a Lang fixture term yet. |
| Is idempotency policy still placeholder? | `yes` | Ruby recipe recommends duplicate-tolerant / idempotent storage by `observation_id` / `event_id`; Spark P2 does not define a concrete idempotency key policy. |
| Is fixture design ready or still held? | `still held` | P2 evidence is enough for deploy-observe pressure, not enough for Igniter-Lang fixture/spec/compiler work. |

---

## P2 Evidence Delta

### Spark P2

Accepted signal:

```text
read_surface_status = generic_metrics_enough
recommendation = deploy-observe
```

Spark now shows:

- metric name: `ledger.availability.slot_map.observed`;
- local synthetic persisted metric with `source=portfolio_p2_synthetic`;
- readback through `Metrics::Query`;
- redacted aggregate tags for status, observed service, receipt kind, redaction
  policy, fixture marker, availability bucket, dominant unavailable state, and
  slot count fields.

Lang interpretation:

```text
deploy-observe pressure improved
fixture vocabulary readiness not reached
```

Reason:

- the evidence is metrics-backed, not an observation receipt;
- no `observation_id` field appears in the Spark P2 example;
- no input/output digest envelope appears in the Spark P2 example;
- ratio and reason container naming still need cross-lane convergence.

### Ruby P2

Accepted signal:

```text
new package code required for first pilot = no
recipe-doc = done
```

Ruby now documents:

- primary-only observed-service setup;
- normalizer and redaction hook expectations;
- store adapter protocol;
- fail-open receipt capture;
- observation and event receipt shapes;
- app-local Spark boundary;
- package API generalization closed.

Lang interpretation:

```text
Ruby shape is ready as implementation guidance, but not enough alone to open
Igniter-Lang fixtures.
```

Reason:

- Ruby recipe asks Spark to provide one persisted redacted observation receipt
  and one event receipt;
- Spark P2 provides a synthetic metrics row instead of that observation/event
  pair;
- Ruby's `availability_ratio` recommendation conflicts with Spark's
  `available_ratio` metric tag.

---

## Intake Map Disposition

Existing map:

```text
igniter-lang/docs/org/indexes/spark-availability-receipt-vocabulary-intake-map-v0.md
```

Disposition:

```text
no rewrite in this slice
```

Reason:

- P2 confirms useful Spark deploy-observe pressure, but does not change the
  fixture-readiness conclusion.
- Items previously marked `candidate` / `not ready for fixtures` remain so.
- Stable aggregate count labels remain usable as pressure only, not canon.
- Private Spark metric names remain Spark-owned and forbidden as public
  Igniter-Lang vocabulary.

If Portfolio wants an updated index later, it should be a new versioned map that
keeps Spark metric names in source-evidence sections and introduces neutral
Lang-facing candidate names only after Spark/Ruby converge.

---

## Follow-Up Requests

To Spark CRM:

1. Continue `deploy-observe` using the generic metrics read surface.
2. After deploy-observe, provide either:
   - one persisted redacted observation receipt with `observation_id`; or
   - an explicit decision that the first path remains metrics-only.
3. Confirm the neutral ratio term: `available_ratio` or `availability_ratio`.
4. Confirm whether reason counts should be exposed as slot-count tags only or as
   a `reason_counts` container in a receipt payload.
5. Confirm whether input/output digests will be emitted in the Spark path.

To Ruby Framework:

1. Keep package API generalization closed.
2. Clarify whether `availability_ratio` is a recommendation or a required
   wrapper-level vocabulary term.
3. Clarify the minimum idempotency statement for metrics-backed Spark receipts:
   duplicate-tolerant by metric tags, observation-id based, event-id based, or
   not specified until a dedicated receipt store exists.

To Portfolio:

1. Keep `PG-2026-05-20-01` active.
2. Do not open Igniter-Lang sanitized fixture design yet.
3. Route Spark follow-up after deploy-observe, or ask Spark/Ruby to converge the
   ratio/reason/digest/idempotency vocabulary before Lang fixture design.

---

## Preserved Closed Surfaces

This report does not authorize:

- Igniter-Lang fixture creation;
- spec/proposal updates;
- compiler/runtime edits;
- parser, TypeChecker, SemanticIR, assembler, `.igapp`, `.ilk`, signing,
  dispatch, RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP,
  cache, or production widening;
- Spark CRM code inspection or edits from the Lang lane;
- Ruby Framework code edits from the Lang lane;
- Igniter Ledger sidecar implementation;
- treating Spark metric names, class names, raw ids, or private data as public
  Igniter-Lang vocabulary;
- treating this report as canon, implementation authority, or fixture
  authorization.

---

## Compact Status

```text
Status: hold
Claim: Spark P2 and Ruby P2 improve deploy-observe and recipe readiness, but do
  not make Igniter-Lang fixture vocabulary ready.
Evidence: Spark P2 synthetic persisted metric/readback; Ruby P2 recipe doc;
  prior Lang P2 intake map.
Changed files: this report only.
Risks / drift: metrics-backed evidence may be mistaken for observation-receipt
  readiness; ratio and reason vocabulary remain split.
Cross-lane requests: Spark/Ruby converge observation_id, digest, reason, ratio,
  and idempotency vocabulary after deploy-observe.
Next: hold Lang fixtures; ask Spark-Ruby follow-up.
```
