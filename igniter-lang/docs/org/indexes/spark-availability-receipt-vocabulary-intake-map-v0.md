# Spark Availability Receipt Vocabulary Intake Map v0

Card: PORT-2026-05-20-LANG-P2
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Route: UPDATE
Parent: [Portfolio Architect Supervisor]
Guidance: PG-2026-05-20-01
Status: done
Date: 2026-05-20
Authority: intake map only / non-canon / non-fixture / non-implementation

---

## Purpose

Create the Igniter-Lang intake map for sanitized Spark availability receipt
vocabulary after Spark P1 and Ruby P1, without opening fixtures, specs,
proposals, compiler work, runtime work, or production authority.

This document is an intake index. It is not a language spec, fixture design,
proposal, implementation authorization, or public vocabulary decision.

---

## Read Set

- `igniter-lang/roles/base-role.md`
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
- `igniter-lang/docs/org/portfolio-reporting-protocol-v0.md`
- `igniter-lang/docs/tracks/stage3-round88-status-curation-v0.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-20-SPARK-P1.md`
- `.agents/ruby-framework/reports/port-2026-05-20-ruby-p1-minimal-receipt-shape.md`

Supporting context read:

- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/2026-05-20-spark-availability-receipt-feasibility.md`
- `igniter-lang/docs/org/portfolio-dispatches/spark-receipt-response-intake-dispatch-v0.md`

---

## Source Answers

### Spark P1

Spark answers:

```text
useful_without_raw_slot_payloads = yes
primary_observed_only = yes
fail_open_observability = yes
aggregate_redacted_enough_for_vocabulary_pressure = yes
non_authoritative_for_business_decisions = yes
safe_as_sanitized_fixture_pressure_after_redaction = yes
```

Spark has a primary-only observed availability path for the admin availability
debug view. It returns the primary availability result unchanged and records
aggregate/redacted metrics.

Important Spark limitation:

```text
metrics-backed persistence only; no dedicated durable receipt table yet
```

### Ruby P1

Ruby answers:

```text
new package code is not needed for the first Spark primary_observed_only pilot
```

Ruby can support the first pilot with existing package surfaces:

- `Igniter::Embed.contractable`;
- primary-only `observe` mode;
- normalizer hook;
- allow-list redaction hook;
- event hooks;
- store adapter protocol with `record_observation` / `record_event`.

Important Ruby limitation:

```text
Spark still needs an app-local adapter and receipt persistence decision
```

---

## Intake Classification Legend

| Mark | Meaning |
| --- | --- |
| `stable` | Stable enough as cross-lane intake vocabulary, not yet language canon. |
| `candidate` | Useful candidate, needs confirmation or proof before fixture use. |
| `Spark-owned` | Spark chooses or proves this shape in app-local receipts/metrics. |
| `Ruby-owned` | Ruby Framework owns support surface or receipt API shape. |
| `forbidden/private` | Must not enter public/shared Igniter-Lang fixtures/docs. |
| `not ready for fixtures` | Do not open fixture/spec work from this item yet. |

---

## Sanitized Vocabulary Intake

| Area | Intake item | Source | Classification | Notes |
| --- | --- | --- | --- | --- |
| Abstract service ref | abstract observed availability service identifier | Spark/Ruby | `candidate`, `Spark-owned`, `Ruby-owned`, `not ready for fixtures` | Spark exposes an internal metric name and Ruby uses a contractable name, but no final shared neutral service ref is decided. Avoid raw Spark class names in Lang fixtures. |
| Abstract service ref | `availability_slot_map` / `availability_slotmap_v0` style names | Ruby/R88 | `candidate`, `not ready for fixtures` | Useful implementation-facing candidate only. Not a decided fixture vocabulary item. |
| Observation id | `observation_id` | Ruby | `candidate`, `Ruby-owned`, `not ready for fixtures` | Ruby receipt shape supports it. Spark P1 has generic metrics read surface, but no dedicated receipt read by observation id yet. |
| Metric/read id | `ledger.availability.slot_map.observed` | Spark | `Spark-owned`, `forbidden/private`, `not ready for fixtures` | Spark-owned metric name. It may guide app-local lookup, but should not become public Lang fixture vocabulary. |
| Input digest | `input_digest` | Ruby | `candidate`, `Ruby-owned`, `not ready for fixtures` | Ruby supports this in the aggregate output payload. Spark P1 did not prove a concrete digest envelope yet. |
| Output digest | `output_digest` | Ruby | `candidate`, `Ruby-owned`, `not ready for fixtures` | Ruby supports this in the aggregate output payload. Spark P1 did not prove a concrete digest envelope yet. |
| Reason counts | `available` | Spark | `stable`, `Spark-owned` | Aggregate count only. Safe as sanitized candidate vocabulary after fixture-safe examples are defined. |
| Reason counts | `scheduled` | Spark | `stable`, `Spark-owned` | Aggregate count only. |
| Reason counts | `off_schedule` | Spark | `stable`, `Spark-owned` | Aggregate count only. |
| Reason counts | `day_off` | Spark | `stable`, `Spark-owned` | Aggregate count only. |
| Reason counts | `past` | Spark | `stable`, `Spark-owned` | Aggregate count only. |
| Reason counts | `total` | Spark | `stable`, `Spark-owned` | Aggregate count only. |
| Aggregate summary | `available_count` | Spark/Ruby | `stable`, `Spark-owned`, `Ruby-owned` | Spark emits it; Ruby supports it in availability outputs. |
| Aggregate summary | `unavailable_count` | Ruby | `candidate`, `Ruby-owned` | Ruby output shape names it. Spark emits total and available counts, so unavailable can be derived but is not a Spark allow-list field. |
| Aggregate summary | `available_ratio` / `availability_ratio` | Spark/Ruby | `candidate`, `Spark-owned`, `Ruby-owned` | Naming differs. Needs one neutral vocabulary choice before fixture work. |
| Aggregate summary | `availability_bucket` | Spark/Ruby | `stable`, `Spark-owned`, `Ruby-owned` | Aggregate category, not raw slot data. |
| Aggregate summary | `dominant_unavailable_state` | Spark/Ruby | `stable`, `Spark-owned`, `Ruby-owned` | Aggregate category, not raw slot data. |
| Reason labels | `reason_codes` | Ruby | `candidate`, `Ruby-owned`, `not ready for fixtures` | Ruby supports this shape. Spark P1 proves count labels, not a separate code vocabulary. |
| Reason labels | `reason_counts` | Ruby | `candidate`, `Ruby-owned`, `not ready for fixtures` | Ruby supports this shape. Map to Spark count labels before fixture work. |
| Window summary | `window_summary` | Ruby | `candidate`, `Ruby-owned`, `not ready for fixtures` | Needs Spark redaction confirmation; raw slot boundaries are forbidden. |
| Scope refs | `scope_refs` | Ruby | `candidate`, `Ruby-owned`, `not ready for fixtures` | Must remain redacted/synthetic; raw refs forbidden. |
| Sampling | `sampled` | Ruby | `candidate`, `Ruby-owned` | Ruby observation receipt field. Spark emits metrics when enabled; exact sampling field is not stabilized. |
| Sampling | `sampling decision/status` | R88/Ruby | `candidate`, `Ruby-owned`, `not ready for fixtures` | Useful concept, but field spelling and Spark evidence are not final. |
| Receipt status | `status` | Spark/Ruby | `candidate`, `Spark-owned`, `Ruby-owned` | Spark metric tags include status; Ruby receipt status exists. Exact shared values need mapping. |
| Receipt status | `:ok` | Ruby | `candidate`, `Ruby-owned` | Ruby observation status. |
| Receipt status | `:store_error` | Ruby | `candidate`, `Ruby-owned` | Ruby fail-open store status. |
| Receipt status | `:unsampled` | Ruby | `candidate`, `Ruby-owned` | Ruby sampling status. |
| Error event | `:primary_error` event | Ruby | `candidate`, `Ruby-owned`, `not ready for fixtures` | Ruby records primary errors as event receipts and re-raises. Do not collapse this into observation status without a mapping decision. |
| Fail-open | store/collector failure is swallowed for receipt path | Spark/Ruby | `stable`, `Spark-owned`, `Ruby-owned` | Stable behavior requirement. Not a fixture by itself. |
| Idempotency | idempotency key placeholder | Ruby | `candidate`, `Ruby-owned`, `not ready for fixtures` | Ruby says a placeholder is expected. Spark P1 does not prove a concrete idempotency policy yet. |
| Redaction policy | `redaction_policy` / `redaction` | Spark/Ruby | `candidate`, `Spark-owned`, `Ruby-owned` | Both lanes have redaction concepts. Needs naming/mapping before fixture vocabulary. |
| Source | `source` | Spark | `candidate`, `Spark-owned`, `not ready for fixtures` | Spark metric field; must avoid private class/file names. |
| Timing | `observed_at`, `started_at`, `finished_at`, `duration_ms` | Spark/Ruby | `candidate`, `Spark-owned`, `Ruby-owned`, `not ready for fixtures` | Spark has observed time; Ruby has receipt timing. Real dates/times must be fixture-safe examples only. |

---

## Forbidden / Private Vocabulary

These must not become public/shared Igniter-Lang fixture vocabulary:

- raw Spark class names as fixture vocabulary;
- raw slot boundaries;
- raw slot arrays or payloads;
- employee names;
- company names;
- customer data;
- order ids;
- schedule ids;
- off-schedule ids;
- vendor/provider payloads;
- raw technician/provider/user refs;
- raw dates/times from production;
- endpoints;
- credentials;
- tokens/secrets;
- infrastructure details;
- Spark metric names as language vocabulary.

Allowed handling:

- use synthetic examples;
- use redacted refs;
- use digest-addressed refs;
- use aggregate counts/categories only;
- keep Spark class names only as internal source context, not fixture/canon
  vocabulary.

---

## Fixture Readiness Assessment

```text
recommendation = hold / ask Spark-Ruby follow-up
```

Do not open sanitized fixture design yet.

Reason:

- Spark has proven useful aggregate/redacted availability summaries, but the
  first persistence/read path is metrics-backed and not a dedicated durable
  receipt table.
- Ruby confirms existing package surfaces are enough, but Spark still needs an
  app-local adapter and receipt persistence decision.
- `observation_id` lookup, concrete digest envelopes, idempotency policy, and
  shared redaction naming are not stable enough for fixture vocabulary.
- Ruby explicitly asks Igniter-Lang to wait for one persisted Spark receipt
  example before fixture expansion.

---

## Follow-Up Questions

Ask Spark:

1. Provide one sanitized persisted receipt example from the observed availability
   path.
2. Confirm whether `available_ratio` or `availability_ratio` should be the
   cross-lane neutral term.
3. Confirm whether unavailable count is emitted or only derived.
4. Confirm whether an `observation_id` exists in the current metrics path or
   requires a dedicated receipt/read surface.
5. Confirm whether input/output digests are present or future-only.

Ask Ruby Framework:

1. Provide a recipe doc for the app-local observed-service wrapper.
2. Clarify the minimal mapping from Spark metrics fields into Ruby observation
   receipt fields.
3. Clarify whether `reason_counts` should be the wrapper-level container around
   Spark state counts.
4. Clarify idempotency key placeholder expectations before Spark persists a
   dedicated receipt.

Ask Portfolio:

1. Keep `PG-2026-05-20-01` active until at least one persisted redacted Spark
   receipt example and Ruby recipe/doc response exist.
2. Do not open Igniter-Lang fixture design yet unless Portfolio accepts a hold
   with the missing items explicitly deferred.

---

## Closed Surfaces

This intake map does not authorize:

- Igniter-Lang fixture creation;
- spec/proposal updates;
- compiler/runtime edits;
- parser, TypeChecker, SemanticIR, assembler, `.igapp`, `.ilk`, signing,
  dispatch, RuntimeMachine/Gate 3, Ledger/TBackend, BiHistory, stream/OLAP,
  cache, or production widening;
- Spark CRM code inspection or edits from the Lang lane;
- Ruby Framework code edits from the Lang lane;
- Igniter Ledger sidecar implementation;
- treating Spark class names, raw ids, or private data as public Igniter-Lang
  vocabulary;
- treating this intake map as canon, implementation authority, or Portfolio
  closure by itself.
