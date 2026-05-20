# spark-availability-metrics-fixture-design-pressure-v0

Card: LANG-SPARK-P5-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: cross-lane-boundary-pressure
Track: spark-availability-metrics-fixture-design-pressure-v0
Route: UPDATE
Status: complete

---

## Inputs Read

- `igniter-lang/docs/tracks/spark-availability-metrics-fixture-design-v0.md` (LANG-SPARK-P4-D)
- `igniter-lang/docs/reports/port-2026-05-20-lang-spark-p3-availability-fixture-readiness.md` (LANG-SPARK-P3)
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-20-SPARK-VOCAB-P3.md` (SPARK-VOCAB-P3)
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md` (PG-2026-05-20-01)
- `igniter-lang/docs/reports/port-2026-05-20-lang-spark-p2-availability-vocabulary-recheck.md` (LANG-SPARK-P2)
- `igniter-lang/docs/org/indexes/spark-availability-receipt-vocabulary-intake-map-v0.md`

---

## Scope Checks

### 1. No Spark class names, metric names, raw ids, or production values appear in public Lang fixture vocabulary

PG-2026-05-20-01 explicitly forbids: "Do not encode real Spark class names, raw
identifiers, or private data in public/shared Igniter-Lang fixtures."

SPARK-VOCAB-P3 identifies three Spark-owned names that must stay outside public
Lang canon:

| Name | SPARK-VOCAB-P3 status | Risk if exposed |
| --- | --- | --- |
| `ledger.availability.slot_map.observed` | stable Spark metric name | Spark-internal metric key; must not become Lang fixture vocabulary |
| `AvailabilityLedger::SlotMap` | stable Spark-local class | Spark class name; must not become Lang canon |
| `admin_company_availability` | stable Spark-local source | Spark source name; must not become public Lang fixture field |

Checking P4-D's three synthetic example shapes:

**Available Summary** — 12 fields: `status`, `receipt_kind`, `redaction_policy`,
`availability_bucket`, `dominant_unavailable_state`, `available_ratio`,
`total_slots`, `available_slots`, `scheduled_slots`, `off_schedule_slots`,
`day_off_slots`, `past_slots`. None of these is a Spark class name, metric key,
or internal source name.

**Unavailable Summary** — same 12 fields, different values.

**Metrics Error Summary** — same 12 fields, all numeric fields zero, bucket/state
set to `unknown`.

The Spark-owned names are absent from all three example shapes. P4-D's naming
decision section states explicitly: "Do not include Spark metric names, class
names, observed service names, or source names in public fixture payloads." The
forbidden/private vocabulary section lists these exclusions in full.

The `receipt_kind` value `availability_slot_map_summary` is a synthesized
descriptive string, not a Spark class name or metric key. It is correctly marked
as "fixture-design candidate / not canon."

Similarly, `redaction_policy` value `availability_slot_map_summary_v1` is a
sanitized policy label — SPARK-VOCAB-P3 reports it as the production-observed
redaction policy marker, which means it is a Spark-side data label, not a class
name or raw id. P4-D uses it as a sanitized aggregate label, which is within the
P3 allowed scope.

**Result: PASS**

---

### 2. Private fields — no employee refs, raw slot arrays, technician refs, or customer/provider/user data included

PG-2026-05-20-01 and SPARK-VOCAB-P3 explicitly forbid:
- employee refs (`employee_ref`)
- raw slot boundaries
- customer / provider / technician / company / user / contact data
- per-technician Portfolio reporting fields

Checking P4-D example shapes: none of the 12 allowed field names or their values
represent:
- entity identity (no `employee_ref`, `technician_id`, `company_id`, etc.);
- slot boundaries (no time ranges, slot arrays, or raw slot objects);
- user or contact data.

All numeric field values are aggregate counts (total/available/scheduled/off-
schedule/day-off/past slots). These carry no per-entity identity information.
The `available_ratio` is a derived aggregate float.

P4-D's forbidden vocabulary list names all private categories explicitly, with
allowed handling rules ("use synthetic counts and categories; use aggregate
bucket/state labels; keep all examples detached from production identity").

**Result: PASS**

---

### 3. Deferred richer receipt fields remain deferred

SPARK-VOCAB-P3 and LANG-SPARK-P3 both require deferral of:

| Deferred field | Reason |
| --- | --- |
| `observation_id` | No stable receipt store; absent by design in metrics path |
| `event_id` | Same as `observation_id` |
| `input_digest` / `output_digest` | Future compare/shadow/replay vocabulary only |
| Idempotency policy | Metrics are duplicate-tolerant counters, not idempotent records |
| `reason_counts` container | Suitable for future dedicated observation receipts |
| Raw `window_summary` | Deferred/forbidden unless separately authorized |
| `scope_refs` | No raw refs or private ids in this route |

Checking P4-D example shapes: none of the three synthetic examples includes any
of these seven deferred fields, not even as null-valued placeholders.

P4-D's deferred-fields table lists all seven with explicit disposition notes.
The closed-surface list repeats "treating this design as canon, implementation
authority, or fixture creation authorization."

The design does not speculatively include partial deferred fields as "stubs" —
they are simply absent. This is the correct posture: deferred fields that appear
as `null` in fixtures create implicit schema pressure to fill them; absent fields
do not.

**Result: PASS**

---

### 4. `available_ratio` naming is correctly resolved; `availability_ratio` remains alias-only

PG-2026-05-20-01 question 1 asked whether Spark could provide useful why-not
summaries. SPARK-VOCAB-P3 stabilized `available_ratio` as the Spark-side deployed
metric tag, and noted `availability_ratio` as a Ruby/Lang-facing candidate alias
only.

P4-D follows this exactly:

> Use `available_ratio` for this metrics-backed fixture design.
> `availability_ratio` remains a Ruby/Lang-facing alias candidate only.
> Do not include both names in the same synthetic metrics fixture.

The three example shapes all use `available_ratio` only. `availability_ratio`
does not appear in any example payload.

The remaining pre-fixture blocker "final review that `available_ratio` does not
conflict with any Lang-facing alias policy" is correctly held for the fixture
creation authorization card, not for this design acceptance.

**Result: PASS**

---

### 5. Synthetic example values are detached from production identity

SPARK-VOCAB-P3 noted a production observation of 113 records at 100% success.
P4-D's synthetic examples use small representative counts (`total_slots: 4`,
`total_slots: 3`) that are clearly not production-scale numbers.

The SPARK-VOCAB-P3 recommended fixture example uses the same small synthetic
values (`total_slots: 4, available_slots: 3, day_off_slots: 1`) that appear in
P4-D's Available Summary. SPARK-VOCAB-P3 explicitly marks these as "sanitized
examples, not production data." P4-D's source-of-truth for these values is that
sanitized example, not a production data extract.

SPARK-VOCAB-P3 notes the production-observed values are: `count = 113,
success = 113, error_rate = 0.0%`. The P4-D examples bear no relation to those
production counts, confirming they are synthetic.

The error summary uses all-zero counts — this is clearly synthetic (a real
production observation with zero everything would not appear in routine deploy-
observe output).

**Result: PASS**

---

### 6. No fixture files are created; no spec/proposal/canon/code surfaces are touched

P4-D explicitly states: "This card does not create fixture files." The handoff
section confirms "no tests run" and "No specs, proposals, canon, code, runtime,
public surfaces, or fixtures edited."

The track delivers a single markdown design document in `docs/tracks/`. No
experiment runner, fixture file, spec chapter, proposal, compiler code, or runtime
surface is written or modified.

The closed-surface list covers: fixture file creation; spec/proposal/canon updates;
compiler/runtime edits; all named compiler/assembler/SemanticIR/runtime/Gate 3/
Ledger/TBackend/production surfaces; public API/CLI/CompatibilityReport; Spark
code inspection; Ruby Framework generalization.

**Result: PASS**

---

### 7. Pre-fixture blocker list is complete and will prevent premature fixture creation

P4-D lists 6 pre-fixture blockers and 5 additional pre-richer-receipt blockers.
The 6 required before any fixture creation:

1. pressure review of this design — satisfied by this card;
2. exact fixture file path and write scope;
3. decision on whether to include the metrics error summary or hold to success
   examples only;
4. confirmation that `unknown` is acceptable only as synthetic error-category
   vocabulary, not Spark production vocabulary;
5. final review that `available_ratio` does not conflict with any Lang-facing
   alias policy;
6. separate authorization for fixture file creation.

All 6 are concrete and independently actionable. Blocker 1 is satisfied here.
Blockers 3–5 require short answers (Spark-side or Lang-alias-policy clarification).
Blockers 2 and 6 require a fixture-creation authorization card.

No blocker is vague ("do more research") or structurally circular.

**Result: PASS**

---

## Non-Blocking Notes

### NB-1: `unknown` as error-state aggregate value needs one Spark-side confirmation

P4-D's error summary shape uses:

```json
{
  "availability_bucket": "unknown",
  "dominant_unavailable_state": "unknown"
}
```

SPARK-VOCAB-P3 reports `available` and `unavailable` as the two production-
observed `availability_bucket` values, and `past` / `day_off` as the two
observed `dominant_unavailable_state` values. `unknown` does not appear in the
SPARK-VOCAB-P3 production-observed value set — it is P4-D's synthetic addition
for a metrics-error case.

Two possibilities:
- `unknown` is a Spark-internal aggregate state value that happens to appear in
  production error paths but wasn't observed in the P3 sample.
- `unknown` is a purely synthetic value invented for this fixture design.

If `unknown` mirrors a real Spark production state name, it may carry semantic
connotations from Spark's internals into Lang fixture vocabulary. If it is
purely synthetic, it is safe.

P4-D blocker 4 correctly holds this question. Resolution requires one sentence
from the Spark side: "Spark does not emit `unknown` as a production state label"
(safe to use as synthetic) or "Spark emits `unknown` for [condition]" (may
require a different synthetic token to avoid conflation). This is a fast
clarification, not a blocker for design acceptance.

---

### NB-2: The error shape design question should be resolved before fixture creation, not after

P4-D blocker 3 says "decision on whether to include the metrics error summary or
hold to success examples only." This is left open. For the fixture creation card,
the cost of getting this wrong is low (the error summary can be excluded or
amended after the fact), but having an explicit stance before the fixture file
is written saves a revision cycle.

The recommended approach: hold the metrics error summary from the initial fixture
creation and add it in a follow-up if Spark confirms the error state semantics
(including `unknown` — see NB-1). Starting with only the `available` and
`unavailable` success cases is the safest minimum fixture.

Not a blocker for design acceptance. The fixture creation authorization card
should pick a side.

---

### NB-3: `receipt_kind` value `availability_slot_map_summary` is fixture-design candidate only — future canon decision should not be inferred from fixture inclusion

P4-D correctly marks `receipt_kind` as "fixture-design candidate / not canon."
SPARK-VOCAB-P3 also marks it as "candidate." The value `availability_slot_map_summary`
is a synthesized descriptive string that neither Spark nor Lang has promoted to
a stable schema term.

There is a low risk that future fixture consumers infer canon from repeated use.
The fixture creation card should include a visible prose note in the fixture
file (or an adjacent README/track doc section) restating that `receipt_kind` and
its value are fixture-design vocabulary, pending a future decision by the Spark
and Lang teams on whether this becomes a stable term.

Not a blocker. One comment in the fixture file's header section is sufficient.

---

## Summary

| Check | Result |
| --- | --- |
| 1. No Spark class names, metric names, or raw ids in public fixture vocabulary | PASS |
| 2. No private fields (employee refs, raw slots, entity data) | PASS |
| 3. Deferred richer receipt fields remain absent (not nulled) | PASS |
| 4. `available_ratio` resolved correctly; `availability_ratio` remains alias-only | PASS |
| 5. Synthetic values detached from production identity | PASS |
| 6. No fixture files created; no spec/code/canon surfaces touched | PASS |
| 7. Pre-fixture blocker list is complete and actionable | PASS |

```text
checks: 7/7
blockers: 0
non-blocking notes: 3
  NB-1: `unknown` as error-state aggregate value — one Spark-side confirmation
        needed before including it in fixtures; hold error shape or confirm first
  NB-2: error summary inclusion question should be decided before fixture creation,
        not left open; recommended stance: start with success cases only
  NB-3: `receipt_kind` value should carry a visible non-canon note in fixture file
        header to prevent canon inference from repeated use
```

---

## Verdict

```text
proceed — fixture creation may open
blockers: none
non-blocking notes: 3
```

---

## Exact Next Route Boundary

Fixture creation may open under the following conditions:

**Required before fixture creation card opens:**

1. This pressure review accepted (satisfied here).
2. A narrow fixture-creation authorization card defines:
   - exact file path and write scope;
   - decision on error summary inclusion (NB-2; recommended: start with success
     cases only until `unknown` is confirmed, per NB-1);
   - confirmation that `available_ratio` does not conflict with any pending
     Lang-facing alias policy;
   - explicit `receipt_kind` non-canon annotation requirement (NB-3).
3. One Spark-side sentence confirming `unknown` is not a production state name
   (or an alternative synthetic token if it is).

**The fixture creation card must not:**

- introduce Spark class names, metric names, source names, raw ids, employee
  refs, or any private Spark vocabulary into fixture payloads;
- include deferred richer receipt fields (`observation_id`, `event_id`,
  `input_digest`, `output_digest`, `reason_counts`, idempotency) even as nulls;
- create more than a small focused synthetic fixture set;
- imply canonical status for `receipt_kind` or `available_ratio` without a
  separate authorization;
- edit specs, proposals, canon, compiler/runtime code, public API/CLI,
  CompatibilityReport, loader/report, runtime, Gate 3, Ledger, cache, signing,
  or production surfaces;
- authorize Spark code changes, Ruby Framework generalization, or
  Igniter Ledger sidecar work.

**Recommended fixture creation scope (if opened):**

- Two success-case fixture shapes: `available` bucket and `unavailable` bucket.
- Hold the error summary until `unknown` vocabulary is confirmed (NB-1 + NB-2).
- One docs-adjacent prose note: `receipt_kind` is fixture-design vocabulary, not
  Lang canon (NB-3).
- File location: to be determined by the fixture creation authorization card.
