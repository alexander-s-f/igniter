# PORT-2026-05-20-LANG-SPARK-P3 Availability Fixture Readiness

Card: LANG-SPARK-P3
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Route: UPDATE
Parent: [Portfolio Architect Supervisor]
Depends on: SPARK-VOCAB-P3
Guidance: PG-2026-05-20-01
Status: recommend-open-design-only-fixture-route
Date: 2026-05-20
Authority: report packet only / non-canon / design-route recommendation only

---

## Executive Summary

Recommendation for Portfolio:

```text
open design-only fixture route
```

Spark VOCAB-P3 changes the Lang P2 hold posture. Spark now reports production
metrics-backed receipt evidence for the `primary_observed_only` availability
path and converges the current Spark-side vocabulary for aggregate availability
receipt pressure.

Igniter-Lang may open a sanitized fixture design route only for synthetic
aggregate metrics-backed examples.

This does not authorize fixture creation in this report, spec/proposal mutation,
compiler/runtime implementation, Spark production integration, public
API/CLI/report widening, or production behavior.

---

## Read Set

- `igniter-lang/docs/reports/port-2026-05-20-lang-spark-p2-availability-vocabulary-recheck.md`
- `igniter-lang/docs/org/indexes/spark-availability-receipt-vocabulary-intake-map-v0.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-20-SPARK-VOCAB-P3.md`
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`

---

## Decision Basis

P2 held Lang fixture design because Spark/Ruby had not converged on:

- a persisted redacted observation receipt with stable `observation_id`;
- input/output digest envelopes;
- reason-count container vocabulary;
- ratio naming;
- concrete idempotency policy.

P3 resolves that hold by narrowing the ready surface:

```text
ready surface = metrics-backed aggregate receipt vocabulary
not ready surface = richer observation/event receipt vocabulary
```

Spark-side convergence now says:

- production deploy-observe has real metrics-backed receipt evidence;
- generic metrics are enough for the current `primary_observed_only` path;
- `available_ratio` is the stable Spark-side ratio term;
- flat slot count tags are stable for the metrics path;
- `reason_counts` is deferred to a future richer receipt shape;
- `observation_id`, `event_id`, `input_digest`, `output_digest`, and
  idempotency are explicitly deferred for a future receipt store/event protocol.

Lang interpretation:

```text
fixture design is ready only if it is scoped to synthetic aggregate metrics
fixtures and explicitly excludes richer receipt-store fields.
```

---

## P3 Readiness Table

The original intake map remains useful as the P1/P2 historical intake map:

```text
igniter-lang/docs/org/indexes/spark-availability-receipt-vocabulary-intake-map-v0.md
```

No rewrite is made in this slice. The table below is the updated P3 readiness
view for Portfolio and should be used for the next route boundary.

| Area | P3 status | Lang fixture-design disposition |
| --- | --- | --- |
| Fixture route overall | ready with narrow boundary | Open design-only route for synthetic aggregate metrics-backed examples. |
| Abstract service ref | candidate | Use neutral synthetic service refs only; do not use Spark class names as public vocabulary. |
| Spark metric name | Spark-owned / source evidence only | Do not make it public Lang canon; may be cited as source evidence in design docs. |
| `status` values | stable for metrics | Fixture design may use `success` / `error` as aggregate metrics status candidates. |
| `receipt_kind` | candidate | Use synthetic `availability_slot_map_summary` only as fixture-design vocabulary, not canon. |
| `redaction_policy` | stable for metrics | Fixture design may include synthetic `availability_slot_map_summary_v1`. |
| `availability_bucket` | stable | Fixture design may include aggregate bucket values such as `available` / `unavailable`. |
| `dominant_unavailable_state` | stable | Fixture design may include aggregate state labels such as `past` / `day_off`. |
| `available_ratio` | stable Spark-side | Use as the fixture-design candidate for metrics-backed examples. Keep `availability_ratio` as an alias question only. |
| Flat slot counts | stable for metrics | Fixture design may use `total_slots`, `available_slots`, `scheduled_slots`, `off_schedule_slots`, `day_off_slots`, `past_slots`. |
| `reason_counts` container | deferred | Do not require it for metrics-backed fixtures. Reserve for richer receipt design later. |
| `observation_id` | deferred / absent by design | Do not include in current metrics-backed fixture design. |
| `event_id` | deferred | Do not include in current metrics-backed fixture design. |
| `input_digest` / `output_digest` | deferred | Do not include in current metrics-backed fixture design. |
| Idempotency policy | deferred | Do not model idempotent observation records in current fixture design. |
| Raw slot/customer/provider/user data | forbidden | Never include. |
| Per-technician reporting | forbidden | Never include. |
| Spark production behavior | closed | Fixture design must be synthetic and non-authoritative. |

---

## Exact Design-Only Boundary

Recommended next route:

```text
spark-availability-metrics-fixture-design-v0
```

Route type:

```text
design-only
synthetic examples only
no fixtures created by this recommendation packet
```

Allowed design scope:

- define one or more synthetic aggregate metrics-backed example shapes;
- use sanitized aggregate fields only:
  - `status`;
  - `receipt_kind`;
  - `redaction_policy`;
  - `availability_bucket`;
  - `dominant_unavailable_state`;
  - `available_ratio`;
  - `total_slots`;
  - `available_slots`;
  - `scheduled_slots`;
  - `off_schedule_slots`;
  - `day_off_slots`;
  - `past_slots`;
- mark Spark metric names, observed service names, and source names as
  Spark-owned source evidence only, not public Lang vocabulary;
- explicitly document that `observation_id`, `event_id`, input/output digests,
  `reason_counts`, and idempotency are deferred to a richer receipt-store route.

Not allowed:

- raw Spark ids, class names, or private fields as public vocabulary;
- raw slot boundaries or slot arrays;
- customer, provider, technician, company, user, contact, endpoint, credential,
  token, or infrastructure data;
- spec/proposal/canon mutation;
- compiler/runtime implementation;
- public API/CLI widening;
- loader/report or CompatibilityReport changes;
- RuntimeMachine/Gate 3, Ledger/TBackend, cache, signing, or production
  behavior;
- Spark code edits or production integration;
- Ruby Framework API generalization.

---

## Recommended Next Card

```text
Card: LANG-SPARK-P4-D
Agent: [Igniter-Lang Fixture/Spec Designer]
Role: fixture-spec-designer
Track: spark-availability-metrics-fixture-design-v0
Route: UPDATE
Parent: [Igniter-Lang Supervisor]
Depends on:
- LANG-SPARK-P3
- SPARK-VOCAB-P3
Guidance: PG-2026-05-20-01

Goal:
Design sanitized synthetic Igniter-Lang fixture examples for the Spark
availability metrics-backed receipt vocabulary converged in P3, without
creating fixtures or mutating specs/proposals/compiler/runtime code.

Scope:
- Read this P3 Lang report and Spark VOCAB-P3.
- Design only synthetic aggregate examples.
- Use no raw Spark ids/classes/private data as public vocabulary.
- Keep Spark-owned metric/source/service names as source evidence only.
- Exclude `observation_id`, `event_id`, input/output digests, idempotency, and
  `reason_counts` from the current metrics-backed fixture design unless marked
  explicitly deferred.
- Do not edit specs/proposals/canon.
- Do not implement compiler/runtime behavior.
- Do not change public API/CLI, loader/report, CompatibilityReport, runtime,
  Gate 3, Ledger/TBackend, cache, signing, or production behavior.

Deliver:
- design track in `igniter-lang/docs/tracks/`
- synthetic example table or draft shape
- forbidden/private vocabulary list
- deferred richer receipt fields
- recommendation: create fixtures next / hold / ask Spark-Ruby follow-up
```

---

## Remaining Blockers Before Fixture Creation

No blocker remains before a design-only route.

Blockers before actual fixture creation remain:

- design route must choose exact synthetic examples and fixture file boundary;
- Spark-owned metric/class/source names must be excluded from public Lang
  vocabulary or clearly isolated as source evidence;
- `available_ratio` vs `availability_ratio` alias policy must be stated for
  fixture docs;
- richer receipt-store fields must remain deferred;
- pressure review should confirm no private vocabulary leakage;
- separate authorization must open actual fixture file creation.

Blockers before richer receipt fixtures remain:

- stable `observation_id` / `event_id`;
- input/output digest envelopes;
- idempotency policy;
- `reason_counts` payload container;
- dedicated receipt/event store or protocol evidence.

---

## Portfolio Recommendation

```text
open design-only fixture route
```

Reason:

- PG-2026-05-20-01 asked Lang to wait for stable receipt vocabulary.
- Spark VOCAB-P3 stabilizes the current metrics-backed aggregate receipt
  vocabulary enough for synthetic fixture design.
- The route can stay bounded by excluding richer receipt-store fields and all
  protected production/private surfaces.

Portfolio does not need to authorize implementation for the next step. It only
needs to accept the narrow design-only fixture route boundary if it wants Lang
to proceed.

---

## Preserved Closed Surfaces

This report does not authorize:

- fixture creation;
- spec/proposal/canon updates;
- compiler/runtime edits;
- parser, classifier, TypeChecker, SemanticIR, assembler, `.igapp`, `.ilk`,
  signing, dispatch, RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory,
  stream/OLAP, cache, or production widening;
- public API/CLI, loader/report, or CompatibilityReport changes;
- Spark CRM code inspection or edits from the Lang lane;
- Ruby Framework code edits or API generalization;
- Igniter Ledger sidecar implementation;
- treating Spark metric names, class names, raw ids, or private data as public
  Igniter-Lang vocabulary;
- treating this report as canon, implementation authority, or fixture creation
  authorization.

---

## Compact Status

```text
Status: recommend-open-design-only-fixture-route
Claim: Spark VOCAB-P3 converges aggregate metrics-backed receipt vocabulary
  enough for Lang synthetic fixture design.
Ready: status, receipt_kind, redaction_policy, availability_bucket,
  dominant_unavailable_state, available_ratio, flat slot counts.
Deferred: observation_id, event_id, input/output digests, idempotency,
  reason_counts container, dedicated receipt store/MCP.
Changed files: this report only.
Next: open `spark-availability-metrics-fixture-design-v0` design-only.
```

