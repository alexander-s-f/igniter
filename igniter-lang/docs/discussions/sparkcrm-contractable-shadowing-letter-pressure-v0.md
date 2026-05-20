# sparkcrm-contractable-shadowing-letter-pressure-v0

Card: S3-R88-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: cross-lane-boundary-pressure
Track: sparkcrm-contractable-shadowing-letter-pressure-v0
Route: UPDATE
Status: complete

---

## Inputs Read

- `igniter-lang/docs/org/letters/sparkcrm-contractable-shadowing-pilot-scope-letter-v0.md` (C1-P1)
- `igniter-lang/docs/org/tracks/sparkcrm-letter-guidance-alignment-v0.md` (C0-O)
- `igniter-lang/roles/base-role.md`
- `igniter-lang/docs/org/portfolio-guidance-log-v0.md`
- `igniter-lang/docs/gates/sparkcrm-contractable-shadowing-pilot-scope-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round87-status-curation-v0.md`

---

## Scope Checks

### 1. Letter is communication / handoff / request only

The letter's "Decision Requested" section opens with:

> No implementation decision is requested by this letter.

The "Status" section records `draft` and explains:

> This letter is a communication packet. It is not sent, received, answered, or
> accepted until a later lane/supervisor action records that transition.

The five requested responses in "Decision Requested" are explicitly review/confirmation
only, with each sub-section ending in "Please do not implement from this letter."

All requests to recipient lanes are structured as questions, not directives.

**Result: PASS**

---

### 2. Letter is not a decision, Portfolio close report, implementation authorization, or canon

The "Explicit Non-Authorization" section closes with:

> treating this letter as a decision, report packet, canon, implementation
> authority, or Portfolio closure packet.

This directly mirrors the R87-C3-A letter boundary:

```text
letter = communication / handoff / request
letter != decision
letter != Portfolio close report
letter != implementation authorization
letter != canon
```

The C0-O alignment track also restated this boundary explicitly. The letter's
"Requested Next Action" section confirms Portfolio should "receive as context;
no decision requested unless later response creates a cross-lane conflict."

**Result: PASS**

---

### 3. `primary_observed_only` remains the only active adoption mode

The "Compact Payload" section identifies the accepted first mode as
`primary_observed_only` and states:

> Portfolio guidance `PG-2026-05-20-01` keeps the adoption path in
> `primary_observed_only` until one redacted receipt path is proven end-to-end.

The shadow candidate mode (`primary_observed_plus_shadow_candidate`) does not
appear in the letter. The body correctly limits scope to the observation/diagnostic
layer: "The pilot may observe and emit redacted diagnostics if later implemented,
but it must not change production output, user-visible behavior, or Spark
source-of-truth state."

PG-2026-05-20-01 directive is met: adoption path stays in `primary_observed_only`.

**Result: PASS**

---

### 4. No shadow candidate implementation is opened

The "Explicit Non-Authorization" section includes:

> shadow candidate implementation

Neither the Compact Payload, any request section, nor the Active Guidance
Answers section proposes or implies opening shadow candidate implementation.
The letter does not discuss implementation sequencing for the shadow mode,
proof matrix, or authorization path.

**Result: PASS**

---

### 5. No Ruby Framework API generalization implied before one pilot works

The "Request To Igniter Ruby Framework" section is scoped to minimum and
app-local concerns:

- "What is the minimal observed-service wrapper needed for a single
  `primary_observed_only` Spark pilot?"
- "What minimal receipt API can support one pilot without generalizing the
  package surface prematurely?"
- "Which parts must be app-local for the first pilot rather than package-level?"

The non-authorization section includes:

> Ruby Framework API generalization before one pilot works

PG-2026-05-20-01 direction is respected: "Ruby Framework defines the minimal
observed-service wrapper and receipt API" — the letter asks for exactly that
minimum scope without opening a generalized API design.

**Result: PASS**

---

### 6. No real Spark class names beyond accepted names promoted into public/shared fixture vocabulary

The only Spark class name in the letter is `AvailabilityLedger::SlotMap`. This
name was explicitly accepted as the first pilot target in R87-C3-A:

> Accepted first pilot target: `AvailabilityLedger::SlotMap`

The letter uses it to identify the subject of the request, not to introduce new
vocabulary or fixture labels. The letter is a cross-lane request, not a fixture
document or shared spec.

`OrderPriceLedger::Finder` is not mentioned anywhere in the letter (it appears
only in the R87 gate as a deferred later candidate).

No additional Spark class names, model names, or internal identifiers beyond the
accepted target appear in the letter body.

**Result: PASS**

---

### 7. No raw identifiers, private data, endpoints, credentials, customer/provider payloads, phone/email data, or infrastructure details exposed

The letter explicitly avoids raw payloads. In "Request To Spark CRM", question 3
specifically asks whether summaries can be limited to:

> reason counts, abstract service ref, observation id, input/output digests,
> evidence ref digests, sampling status, and fail-open write status

This enumeration asks for redacted/digest-addressed data — no raw customer,
provider, technician, company, user, schedule, phone/email, endpoint, credential,
or infrastructure data.

The "Explicit Non-Authorization" section explicitly lists:

> real Spark data, raw identifiers, endpoints, credentials, provider payloads,
> customer records, technician/user raw records, phone/email data, or
> infrastructure details in public/shared docs, fixtures, receipts, reports, or
> sidecar examples

Question 4 in the Spark request asks whether "business date, technician/provider
references, company/tenant references, schedule/off-schedule refs, or debug
lookup" represent Spark-owned constraints. This is a constraint question directed
to Spark — it does not expose or encode any such data. The phrasing correctly
asks Spark to report constraints before any implementation, not to confirm data
structure designs.

**Result: PASS**

---

### 8. Igniter Ledger sidecar remains optional/later and not source-of-truth

The "Request To Igniter Ledger Sidecar" section asks Spark to confirm four
items, every one of which asserts the optional/later, non-authoritative stance:

- "the sidecar receipt sink remains optional/later"
- "no Ledger sidecar is required for the first low-volume pilot"
- "sidecar receipts must not become Spark source of truth"
- "no production TBackend/Ledger binding, replay, read-through, or Spark state
  reconstruction is opened by this letter"

The potential later sidecar research scope ("redacted receipt append, observation
lookup by id, idempotent append, and retention/compaction explanation research")
is correctly framed as future-only and not opened by this letter.

The non-authorization section includes:

> Igniter Ledger sidecar implementation; treating sidecar receipts as source of
> truth

PG-2026-05-20-01 direction is met: "Igniter Ledger sidecar remains optional/later."

**Result: PASS**

---

### 9. Igniter-Lang fixture work remains waiting on stable receipt vocabulary

The "Request To Igniter-Lang" section is unambiguous:

> Igniter-Lang should wait.

It correctly lists what must happen before fixture work opens:

- Spark confirmation that useful why-not summaries can be emitted without raw
  slot payloads;
- Ruby Framework answer on the minimal observed-service wrapper and receipt API;
- stable redacted receipt vocabulary;
- confirmation of abstract service ref and idempotency key policy;
- a separate Architect route before opening any fixture/spec work.

The "Active Guidance Answers" section restates this in the "What Igniter-Lang
Must Wait For" sub-section.

The non-authorization section includes:

> Igniter-Lang fixtures before stable receipt vocabulary and a separate route

PG-2026-05-20-01 direction is met: "Igniter-Lang waits for stable receipt
vocabulary before opening fixtures."

**Result: PASS**

---

## Non-Blocking Notes

### NB-1: `availability_slotmap_v0` abstract service ref presented as recommendation

The Compact Payload section lists:

> Recommended implementation-facing abstract service ref, to be confirmed later:
> `availability_slotmap_v0`

This is presented in a code block alongside the accepted target. The qualifier
"to be confirmed later" correctly prevents it from being read as a decided name.
This matches the R87-C3-A precondition language ("Define the `service_ref`
abstraction convention"). However, presenting it in a code block inside
a cross-lane letter gives it slight visual weight as if it were an accepted label.

Not a blocker. C3-S may note that `availability_slotmap_v0` remains a pending
confirmation, not a decided vocabulary item, if Portfolio asks about the
abstract service ref status.

---

## Summary

| Check | Result |
| --- | --- |
| 1. Letter is communication / handoff / request only | PASS |
| 2. Not a decision, Portfolio close report, implementation authorization, or canon | PASS |
| 3. `primary_observed_only` remains the only active adoption mode | PASS |
| 4. No shadow candidate implementation opened | PASS |
| 5. No Ruby Framework API generalization implied before one pilot works | PASS |
| 6. No real Spark class names beyond accepted names in public/shared fixture vocabulary | PASS |
| 7. No raw identifiers, private data, endpoints, credentials, or customer/provider payloads exposed | PASS |
| 8. Igniter Ledger sidecar remains optional/later and not source-of-truth | PASS |
| 9. Igniter-Lang fixture work remains waiting on stable receipt vocabulary | PASS |

```text
checks: 9/9
blockers: 0
non-blocking notes: 1 (availability_slotmap_v0 presented in code block — recommendation only, not decided name)
```

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 1
```

---

## Recommendation for C3-S

The letter is well-formed, tightly scoped, and consistent with:

- PG-2026-05-20-01 active guidance;
- R87-C3-A accepted scope and letter boundary;
- C0-O guidance alignment checklist;
- Base Role cross-lane rule ("letter = communication / handoff / request").

All five active guidance constraints are preserved. The non-authorization
section is comprehensive and mirrors both the guidance log and the R87 gate.

C3-S may proceed with status curation using the standard
`stage3-round88-status-curation-v0.md` packet.

C3-S should note in the status curation:

1. The letter is `draft`; the `draft → sent` transition requires a later
   supervisor/user action. The R88 close packet should record current status as
   `draft` rather than implying the letter has been routed.
2. The three active guidance questions (Spark redaction feasibility; Ruby minimal
   receipt API; Igniter-Lang fixture vocabulary to wait for) remain open and
   unanswered — correctly so. C3-S should preserve them as open items in the
   cross-lane requests section.
3. NB-1: `availability_slotmap_v0` is a recommendation pending Spark confirmation,
   not a decided abstract service ref. The status curation may note this if the
   Portfolio report section covers abstract service ref status.

No implementation is authorized by this review.
