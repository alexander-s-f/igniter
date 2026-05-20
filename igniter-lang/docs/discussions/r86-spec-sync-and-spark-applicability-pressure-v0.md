# r86-spec-sync-and-spark-applicability-pressure-v0

Card: S3-R86-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: applied-product-pressure
Track: r86-spec-sync-and-spark-applicability-pressure-v0
Route: UPDATE
Status: complete
Date: 2026-05-20

---

## Inputs Read

**Spec sync (C1)**:
- `igniter-lang/docs/tracks/prop038-strict-refusal-spec-chapter-sync-v0.md` (C1-P1)
- `igniter-lang/docs/spec/ch5-compiler-pipeline.md` (after C1 sync)
- `igniter-lang/docs/spec/ch7-runtime.md` (after C1 sync)
- `igniter-lang/docs/language-spec.md` (after C1 sync)

**Spark routing (C2/C0-O)**:
- `igniter-lang/docs/tracks/sparkcrm-igniter-adoption-readiness-map-v0.md` (C2-P1)
- `igniter-lang/docs/org/tracks/sparkcrm-inbox-disposition-and-pressure-routing-v0.md` (C0-O)
- `igniter-lang/docs/inbox/sparkcrm-ledger-igniter-applicability-analysis-2026-05-20.md`
- `igniter-lang/docs/inbox/README.md`

**Authority baseline**:
- `igniter-lang/docs/gates/prop038-strict-refusal-canon-sync-acceptance-decision-v0.md` (R85-C4-A)
- `igniter-lang/docs/gates/prop038-strict-refusal-live-implementation-acceptance-decision-v0.md` (R84-C1-A)

---

## Part A: Ch5/Ch7 Spec Chapter Sync

### A-1. Ch5 sync reflects R84/R85 exactly without widening authority

**Baseline** from R85-C4-A and R84-C1-A:

```text
internal strict requirement source
  -> orchestrator-level strict requirement decision path
  -> report-only compiler_profile_contract_validation evidence
  -> non-persisting strict terminal CompilerResult when selected
```

Closed: public API/CLI, loader/report, CompatibilityReport, RuntimeMachine/Gate 3,
runtime, production.

**Ch5 production pipeline diagram** (after sync):

```text
CompilationReport produced for decision/report evidence
  |
  ├─ PROP-038 internal strict terminal, if selected:
  |    non-persisting CompilerResult refused | configuration_error
  |    no sidecar, no report write, no .igapp, no assembler call
  |
  ▼ Stage 4: Assemble
```

The strict terminal branch is positioned before Assembly, correctly exits the
pipeline without persisting. The main pipeline continues to Assembly only when
strict terminal is NOT selected. Architecture is correct and matches R84. ✓

**Ch5 §5.2 stage interface table** (Internal strict terminal row):

```text
Input:  CompilationReport + nested compiler_profile_contract_validation evidence
Output: non-persisting CompilerResult refused | configuration_error
Skip:   absent internal strict requirement
```

Correct on all three fields. ✓

**Ch5 §5.2.1 authority text**:

```text
The strict source is an internal constructor/test seam only. It is not exposed
through the public Ruby API, CLI, environment, config, manifest, loader/report,
CompatibilityReport, RuntimeMachine, Gate 3, runtime, or production behavior.
```

Full closed-surface enumeration present and correct. ✓

**Ch5 §5.2.1 validator boundary**:

```text
CompilerProfileContractValidator output != refusal authority
compile_refusal_authorized: false remains nested report-only evidence
```

Matches R84 validator-non-authority property exactly. ✓

**Ch5 §5.2.1 non-persisting invariants**:

```text
report.pass_result == "ok"
compilation_report_path == null
igapp_path == null
no sidecar
no report write
no .igapp
no assembler call
```

Matches R84 accepted non-persisting terminal behavior exactly. ✓

**Ch5 §5.2.1 terminal key-set**:

13 keys listed: `kind`, `format_version`, `status`, `program_id`, `source_path`,
`source_hash`, `grammar_version`, `stages`, `igapp_path`, `contracts`,
`compilation_report_path`, `diagnostics`, `warnings`.

Matches the exact 13-key public key-set accepted by R84-C1-A. Count and content
verified. ✓

**Result: PASS**

---

### A-2. Ch7 correctly blocks runtime interpretation of strict refusal

**Ch7 §7.2.1** "PROP-038 Strict Refusal Is Not A Runtime Surface":

Runtime implications stated:

```text
- strict terminal paths produce no loadable .igapp;
- strict terminal paths write no sidecar and no compilation report artifact;
- strict terminal paths do not enter RuntimeMachine.load;
- strict terminal paths do not produce or consume a CompatibilityReport;
- CompilerProfileContractValidator output remains compiler evidence, not
  runtime authority;
- nested compile_refusal_authorized: false remains report-only evidence.
```

Each implication is a consequence of the R84 accepted non-persisting behavior.
No `.igapp` means `RuntimeMachine.load` has nothing to load. No
`CompatibilityReport` from strict terminal paths means no runtime gate-check path
exists. The causal chain is correct and complete. ✓

**Ch7 §7.2.1 closed surfaces**:

```text
public API/CLI strict source
loader/report strict source or status
CompatibilityReport strict source or status
RuntimeMachine/Gate 3 strict-refusal behavior
runtime/production strict-refusal behavior
```

All five forbidden surfaces explicitly named. ✓

**Forward guard**: "Any future runtime or loader/report interpretation of PROP-038
strict refusal requires a separate Architect decision." ✓ — correctly defers
instead of speculatively opening.

**Result: PASS**

---

### A-3. Conformance case C-11 is accurate

C-11 added to §5.7:

```text
C-11 PROP-038 internal strict terminal -> non-persisting CompilerResult,
     report.pass_result "ok", no sidecar/report/.igapp/assembler call
```

This states:

- `non-persisting CompilerResult` ✓ (R84 accepted `CompilerResult.strict_terminal`)
- `report.pass_result "ok"` ✓ (R84 accepted invariant)
- `no sidecar/report/.igapp/assembler call` ✓ (R84 accepted non-persisting behavior)

No deviation from accepted canon. ✓

**Result: PASS**

---

### A-4. language-spec.md index is accurate

After sync, `language-spec.md` shows:

```text
Ch5: accepted / R84 strict-refusal internal foundation synced
Ch7: accepted + proven ✅ / PROP-038 strict refusal is non-runtime
Notes: PROP-038 strict refusal is accepted only as an internal compiler foundation / non-runtime boundary
```

All three entries are accurate summary labels. Neither overstates ("internal only"
framing) nor understates ("accepted" not "proof-local"). ✓

**Result: PASS**

---

### A-5. C1 changed-doc list is within authorized scope

C1 changed exactly four docs:

```text
docs/spec/ch5-compiler-pipeline.md
docs/spec/ch7-runtime.md
docs/language-spec.md
docs/tracks/prop038-strict-refusal-spec-chapter-sync-v0.md
```

R85-C4-A authorized the `prop038-strict-refusal-spec-chapter-sync-v0` track as
the next route. That authorization scope covers spec chapter sync. No code,
proof, gates, or proposals were changed. ✓

C1 "Non-Authorization Preserved" explicitly lists: code implementation; new live
behavior; public API/CLI widening; loader/report behavior; CompatibilityReport;
RuntimeMachine/Gate 3; runtime behavior; production behavior. ✓

**Result: PASS**

---

### A-6. Ch5 drift D1 fix is safe

The previous Ch5 text implied "CompilationReport always written" — which would
have been false for strict terminal paths. C1 replaces this with:

```text
CompilationReport produced for decision/report evidence
```

This is semantically accurate and weaker than "always written." The
`CompilationReport` is still produced for the orchestrator's internal decision
path (the PROP-038 validator runs and evidence is nested), but the report is not
written/persisted in strict terminal cases. The corrected language captures
this distinction. ✓

**No new behavior is introduced** — the fix describes existing accepted behavior
that the old text incorrectly implied. ✓

**Result: PASS**

---

## Part B: Spark CRM Applicability Routing

### B-1. No production replacement readiness claimed

**C2 "Executive Readiness Verdict" — "Not ready now" block**:

```text
replace Spark ledgers
execute Spark decisions via Igniter-Lang runtime
bind production TBackend/Ledger as source of truth
```

These three items are the core replacement concerns. All three are explicitly
closed with no ambiguity. ✓

**C2 "Must Remain Closed" section**:

```text
production replacement of Spark SQL ledgers;
real Spark CRM data/endpoints/credentials/provider payloads/customer records/
  phone/email data/or infrastructure details in public fixtures/docs;
Igniter-Lang runtime executing production Spark ledger decisions;
production TBackend / Ledger binding for Spark;
using sidecar receipts as primary truth;
public .igapp operational policy deployment for Spark;
automatic migration of existing Spark ledgers to Igniter Ledger;
broad framework code changes without a dedicated implementation card.
```

Eight explicitly named closed items. ✓

**C2 Adoption Readiness Table — "Closed" rows**:

```text
Production replacement of Spark SQL ledgers → not authorized
Real Spark CRM data/endpoints/provider payloads → not authorized
Igniter-Lang runtime executing production Spark ledger decisions → not authorized
```

Consistent with the "Must Remain Closed" section. ✓

**C0-O**: "not Spark CRM production authority" ✓

**Result: PASS**

---

### B-2. Three-lane separation is maintained

**C0-O classification table** explicitly assigns each dimension to a lane:

| Dimension | Lane |
| --- | --- |
| Ruby framework adoption | `igniter-contracts` / `igniter-embed` contractable shadowing, receipts, redaction, async adapter, Rails host setup |
| Igniter Ledger | Sidecar/receipt pressure; not primary SQL ledger replacement authority |
| Igniter-Lang | Fixture/spec pressure for bitemporal availability, fractal price ledgers, active-at assignment, interval validity, compaction receipts |

No dimension is assigned to more than one lane. No dimension bleeds into
production execution. ✓

**C2 "Lane Map" section** provides four clearly scoped lanes:

1. **Spark CRM Safe-Now Work**: observation wrappers, redacted receipts, sampling,
   primary service remains authoritative.
2. **Igniter Ruby Framework / Contracts / Embed**: Rails initializer, Sidekiq
   adapter, redaction defaults, admin lookup.
3. **Igniter Ledger Sidecar Research**: receipt sink, idempotent append, sidecar
   schema, explicitly not source-of-truth.
4. **Igniter-Lang Fixtures / Spec Pressure**: synthetic `.ig` fixtures, interval
   validity, BiHistory, typed scope chains.

Lane 4 is correctly bounded to synthetic fixtures and spec pressure, not to
production runtime execution. ✓

The phase-ordering matters: Ruby framework adoption and Lang fixtures can proceed
now; Ledger sidecar is "next"; production runtime/replacement is "later" or
"closed." This ordering correctly reflects the actual readiness of each layer. ✓

**Result: PASS**

---

### B-3. No real Spark secrets, endpoints, customer payloads, or provider configs introduced

**Inbox source document** carries an explicit privacy note at the top:

```text
Privacy note: this report intentionally avoids secrets, provider endpoints,
credentials, customer payloads, and sensitive raw data.
```

The document content is consistent with this note. The document contains:

- File path names (`app/models/availability_ledger/ledger_entry.rb`) — code
  structure descriptions, not data.
- Business process descriptions (`Company working hours + technician day_off_config
  -> nightly Layer-1 snapshot per technician/date`) — structural semantics, not
  actual values.
- Formalized contract shapes — input/output field names and types, no real values.
- SQL temporal patterns (`effective_from <= at < effective_until`) — generic
  interval semantics, not data.
- Migration filename timestamp — not sensitive.

No API keys, credentials, customer records, phone numbers, email addresses, actual
prices, provider payloads, or infrastructure endpoints appear anywhere. ✓

**C2 readiness map** adds: "Do not inspect or publish real customer/provider
payloads in this track." ✓

**C0-O non-authorizations**: "no production data usage" ✓

**Result: PASS**

---

### B-4. Recommended pilots are bounded and reversible

**C2 recommended first pilot** (`sparkcrm-contractable-shadowing-pilot-v0`):

```text
Non-authorizations:
- no Spark ledger replacement;
- no production output changes;
- no real payload publication;
- no Igniter-Lang runtime execution;
- no primary Ledger DB migration.
```

The pilot wraps one existing finder service in observed/shadow mode. The primary
service continues to run unchanged. The shadow candidate is computed in parallel
and produces only redacted observation receipts. ✓

Reversibility check:

- "primary existing service remains authoritative" — removing the shadow wrapper
  restores the system exactly to its prior state. ✓
- "emit redacted observation receipt" — receipts are evidence artifacts, not
  system inputs. Removing them is zero-impact. ✓
- "missing receipt does not block business flow in pilot mode" — failure-open by
  design. ✓
- "sample or gate carefully" — partial rollout is safe. ✓

The contractable shadowing pattern is the lowest-risk adoption path available:
read-only shadow, no production output change, observation evidence only. ✓

**C2 "Sidecar Receipt Sink, Not Primary Spark Ledger DB" section** correctly
limits Igniter Ledger to non-authoritative sidecar use:

```text
Closed:
- replacing ActiveRecord ledgers;
- making Igniter Ledger the transactional source of truth;
- replaying Spark business state from sidecar receipts as production truth.
```

The sidecar pattern is reversible: removing the sidecar sink does not affect
primary Spark ledger operations. ✓

**Result: PASS**

---

### B-5. Inbox document has a clear disposition

**Inbox README** shows the document status as `promoted-track`:

```text
promoted-track | [Org Architect Supervisor] |
Routed by sparkcrm-inbox-disposition-and-pressure-routing-v0 as active
applied-pressure source; suggested next track
sparkcrm-igniter-adoption-readiness-map-v0; not canon or implementation authority
```

Status is `promoted-track` (not `new` or `triaged`). Destination is named.
Authority is denied. ✓

**Inbox document itself** carries its disposition at the top:

```text
Status: triaged / routed to S3-R86 applied-pressure track
Disposition: Routed by Architect Supervisor into S3-R86.
Next owner: sparkcrm-igniter-adoption-readiness-map-v0.
Use as applied-pressure source only; not canon and not implementation authority.
```

The source document is self-describing. No zombie state. ✓

**C0-O lifecycle recommendation**: "active applied-pressure source; keep source
non-canon and non-authoritative" ✓

The inbox cleanup rule is satisfied: every active item has a disposition status
and a destination link.

**Result: PASS**

---

### B-6. Spark routing does not import Igniter-Lang compiler authority

A specific risk in combined compiler/product rounds is that language/compiler
spec decisions become entangled with product adoption work. No such entanglement
occurs here:

- C1 (compiler spec sync) does not reference Spark CRM at all.
- C2 (Spark readiness map) does not reference Ch5/Ch7 spec content or attempt
  to extract compiler implementation authority from the spec.
- C0-O (inbox routing) addresses only applied-pressure lifecycle, not compiler
  canon.

The two workstreams (PROP-038 spec sync vs Spark CRM applied-pressure routing)
are parallel and non-entangled. ✓

C2 explicitly scopes Igniter-Lang to: "Formal specifications, not production
execution ... Use Igniter-Lang to write `.ig` fixtures." ✓

C2's "Verdict" for Igniter-Lang: "Applicability: HIGH as language pressure/spec;
LOW-MEDIUM as production runtime today" — uses language pressure framing, not
runtime or implementation framing. ✓

**Result: PASS**

---

## Summary

| Check | Scope | Result |
| --- | --- | --- |
| A-1. Ch5 sync reflects R84/R85 exactly | Compiler | PASS |
| A-2. Ch7 correctly blocks runtime interpretation | Runtime | PASS |
| A-3. Conformance case C-11 accurate | Compiler | PASS |
| A-4. language-spec.md index accurate | Index | PASS |
| A-5. C1 changed docs within authorized scope | Scope | PASS |
| A-6. Ch5 drift D1 fix is safe and non-widening | Compiler | PASS |
| B-1. No production replacement readiness claimed | Product | PASS |
| B-2. Three-lane separation maintained | Product | PASS |
| B-3. No real secrets/payloads/endpoints introduced | Privacy | PASS |
| B-4. Recommended pilots bounded and reversible | Product | PASS |
| B-5. Inbox document has clear disposition | Lifecycle | PASS |
| B-6. Spark routing does not import compiler authority | Boundary | PASS |

```text
checks: 12/12 PASS
blockers: 0
non-blocking notes: 4
```

---

## Non-Blocking Notes

### NB-1: Proposed pilot card is a recommendation, not an authorization

C2 proposes `sparkcrm-contractable-shadowing-pilot-v0` as the next card.

This is a recommendation from the readiness map, not an authorization. The card
is not opened by C2. C4-A decides whether to route it, hold it, or redirect.

The proposal is technically sound. Its scope, non-authorizations, and acceptance
sketch are well-defined. If C4-A routes it, it should explicitly name the
authorization boundary including: which service (Option A or B), redaction
requirements, sampling gate, and receipt non-authority guard.

Not a blocker. C4-A gates the authorization.

### NB-2: Ch6 spec gap acknowledged but not closed

C1 identifies a remaining gap:

```text
Ch6 SemanticIR / CompilationReport chapter may later mention nested
compiler_profile_contract_validation evidence. Optional future sync only;
R86 did not need Ch6 because strict terminal authority is orchestrator/result,
not SemanticIR.
```

This is a correct assessment. Ch6 deals with SemanticIR shape, not with the
orchestrator-level strict terminal decision path. The gap is real but optional:
agents would need to route from Ch6 to trigger it, and the current architecture
keeps strict terminal authority entirely in the orchestrator layer above SemanticIR.

If a future card explores the relationship between `CompilationReport` internals
and the `compiler_profile_contract_validation` evidence blob, Ch6 may then need
a note. Not required for the current round.

Not a blocker.

### NB-3: Internal Spark CRM class names appear in the readiness map

C2 names internal Spark CRM Ruby classes and service names:
`OrderPriceLedger::Finder`, `AvailabilityLedger::SlotMap`, `BidLedger::Finder`,
etc. These are code structure references used to identify pilot candidates.

The privacy note in the inbox document covers this level of architectural
description as acceptable (the note excludes secrets, credentials, payloads, and
sensitive data — not architectural class names). For internal applied-pressure
documentation this is appropriate.

If the readiness map document were ever shared externally or published, these
internal class names should be abstracted or removed. C4-A should note that the
readiness map is internal applied-pressure material only, not a public document.

Not a blocker for this round.

### NB-4: Durable observation adapter is prerequisite for production-adjacent receipt volume

C2 notes: "Sidekiq/durable observation adapter need: required before
production-adjacent adoption is trustworthy." The current `igniter-embed` async
default is local-thread, which is not sufficient for Rails production confidence.

C2 places this adapter in the "Next" horizon, after the initial pilot. The
ordering is correct — the first pilot can be gated/sampled to keep volume low
while the durable adapter is built.

C4-A should be aware that authorizing the pilot without also authorizing or
planning the durable adapter creates a path-dependency: any expansion of the pilot
beyond very-low-volume sampling requires the adapter first.

Not a blocker for the pilot routing decision, but C4-A should explicitly note the
dependency if routing the pilot.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 4 (all correctly scoped, none require action before C4-A)
```

---

## Recommendation For C4-A

**On C1 (Ch5/Ch7 spec sync)**:

The sync is clean. Ch5 and Ch7 now accurately describe R84's accepted internal
compiler terminal path without widening any surface. The production pipeline
diagram, stage interface table, §5.2.1 authority section, §7.2.1 non-runtime
section, and C-11 conformance case are all faithful translations of R84 canon
into spec language. C1 closes the Ch5/Ch7 gap identified in R85-C3-X NB-1.

Recommend: accept spec sync.

**On C2/C0-O (Spark CRM applied-pressure routing)**:

The routing is sound. The inbox document is correctly disposed as a
`promoted-track` applied-pressure source. The readiness map correctly separates
three lanes, denies production replacement readiness, and recommends a bounded
reversible first pilot. No canon, no implementation authority, no secrets, no
production entanglement.

Recommend: accept inbox disposition; route Spark applied-pressure lane.

**On the proposed first pilot**:

The `sparkcrm-contractable-shadowing-pilot-v0` card is a safe first step if C4-A
chooses to route it. Key guards C4-A should name explicitly:

```text
- primary service remains authoritative;
- no real customer/provider payloads in receipts;
- sampling gate required before volume expands;
- missing receipt must not block business flow;
- durable adapter must precede high-volume rollout;
- Igniter Ledger sidecar is optional; not required for the pilot itself.
```

**What C4-A should not authorize**:

```text
- Spark ledger replacement of any kind;
- Igniter-Lang runtime execution of Spark decisions;
- Igniter Ledger as primary Spark DB;
- real payload data in any documentation;
- public API/CLI, loader/report, CompatibilityReport, RuntimeMachine,
  Gate 3 widening, or production behavior;
- new compiler implementation.
```

**Remaining closed surfaces from R84**:

The full PROP-038 closed-surface list (public API/CLI, loader/report,
CompatibilityReport, RuntimeMachine/Gate 3, runtime, production) remains closed.
Neither C1 nor C2 touches any of these surfaces. C4-A inherits the full R84
closure and should explicitly confirm it.
