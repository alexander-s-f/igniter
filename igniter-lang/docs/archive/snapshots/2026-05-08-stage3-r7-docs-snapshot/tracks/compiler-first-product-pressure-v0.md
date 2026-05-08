# Track: Compiler First Product Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/compiler-first-product-pressure-v0.md`
Status: done
Slice state: done on 2026-05-06
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track pressure-tests whether the minimal compiler subset can still support
real product value before broader language expansion.

The test is intentionally narrow:

```text
normalized observations in
  -> bounded contract
  -> evidence-linked product artifact out
```

Assumed v0 compiler subset:

- structural records and basic primitives;
- `input`, `compute`, `output`, `const`, `type`, pure non-recursive helpers;
- explicit `escape` boundary for bounded external reads;
- bounded `read ... Collection[T] from ... lifecycle`;
- bounded collection operations: `map`, `filter`, `group_by`, `fold`, `count`,
  `sum`, `avg`;
- `Option[T]` and `Result[T, E]`;
- output lifecycle metadata;
- no recursion, no unbounded loops, no arbitrary effects, no full logical
  inference engine.

[D] Compiler-first value is viable only if the product starts from normalized
facts and produces reviewable artifacts, not if v0 is expected to collect,
extract, infer, decide, and act end to end.

## Product Value Matrix

| Product lane | Smallest useful contract | v0 subset used | Product value delivered | Blocked product value | Verdict |
|--------------|--------------------------|----------------|-------------------------|-----------------------|---------|
| OSINT daily brief | Read bounded `Claim`, `SourceObservation`, `EvidenceLink`, and `CorrectionReceipt` for one watchlist and one `as_of`; emit `DailyBrief` with evidence refs and caveats | Bounded reads, record types, `filter`, `map`, `count`, output lifecycle | A daily review artifact over already-extracted claims; no item can appear without source/evidence refs | Source collection, LLM extraction, contradiction inference beyond precomputed flags, source reliability calibration, human acceptance workflow | Sufficient for a review-ready brief over normalized inputs; insufficient for an end-to-end OSINT assistant |
| Spark CRM lead / availability signal | Read bounded synthetic `LeadSignalObservation` and `AvailabilitySnapshot` for one company/date; emit accepted/rejected/duplicate counts and available technician count | Bounded reads, tenant/date inputs, `filter`, `count`, simple records, durable output | Operator digest that combines lead intake health and dispatch availability without exposing raw provider payloads | Exact `Decimal`, idempotency key semantics, tenant scope as type, timezone/date primitives, late-boundary reopen, executable operations | Sufficient for a read-only signal digest; insufficient for production lead intake or dispatch authority |
| Home-lab awareness alert | Read bounded `ServiceObservation`, `PackageObservation`, and public-style `AdvisoryClaim`; emit `AwarenessAlert` with owned telemetry refs and advisory refs | Bounded reads, `filter`, `map`, `count`, record assembly, evidence-linked output | Owned-system awareness alert from normalized telemetry plus public advisory facts | SemVer comparison, source reliability policy, remediation capability gates, connector policy, action receipts | Sufficient for normalized advisory/telemetry correlation; insufficient for automated remediation |

## Minimal Contract Sketches

These are pressure sketches, not a syntax freeze. They intentionally use the
smallest source shape that should lower toward SemanticIR without requiring a
new product DSL.

### OSINT Daily Brief

```text
contract DailyBriefFromClaims {
  input watchlist_id: String
  input as_of: String

  escape source_store

  read claims: Collection[Claim]
    from "claims/by_watchlist"
    lifecycle :window

  read evidence_links: Collection[EvidenceLink]
    from "evidence/by_watchlist"
    lifecycle :window

  read corrections: Collection[CorrectionReceipt]
    from "corrections/by_watchlist"
    lifecycle :durable

  compute sourced_claims = filter(claims, has_evidence_link)
  compute contradicted_count = count(filter(sourced_claims, is_contradicted))
  compute corrected_count = count(corrections)
  compute brief_items = map(sourced_claims, claim_to_brief_item)

  output brief: DailyBrief lifecycle :durable
}
```

Minimum useful output:

```text
DailyBrief {
  watchlist_id,
  as_of,
  item_count,
  contradicted_count,
  corrected_count,
  items: Collection[BriefItem],
  evidence_refs: Collection[EvidenceRef],
  caveats: Collection[String]
}
```

Failure if v0 allows:

- a `BriefItem` without `evidence_refs`;
- a repeated claim to count as independent evidence;
- `ConfidenceAssessment` to be used as a Boolean truth value;
- missing `as_of` on the output.

### Spark Lead / Availability Signal

```text
contract SparkLeadAvailabilitySignal {
  input company_id: String
  input service_date: String
  input as_of: String

  escape spark_store

  read lead_signals: Collection[LeadSignalObservation]
    from "spark/lead_signals"
    lifecycle :window

  read availability: Collection[AvailabilitySnapshot]
    from "spark/availability_snapshots"
    lifecycle :window

  compute accepted_count = count(filter(lead_signals, is_accepted))
  compute rejected_count = count(filter(lead_signals, is_rejected))
  compute duplicate_count = count(filter(lead_signals, is_duplicate))
  compute available_tech_count = count(filter(availability, has_available_slot))

  output digest: SparkSignalDigest lifecycle :durable
}
```

Minimum useful output:

```text
SparkSignalDigest {
  company_id,
  service_date,
  as_of,
  accepted_count,
  rejected_count,
  duplicate_count,
  available_tech_count,
  observation_refs: Collection[ObservationRef],
  diagnostic_refs: Collection[DiagnosticRef]
}
```

Failure if v0 allows:

- missing or mixed company scope;
- lead money modeled with `Float` where `Decimal` is required;
- duplicate signals counted as accepted leads;
- schedule/availability status read without `as_of`.

### Home-Lab Awareness Alert

```text
contract HomeLabAwarenessAlert {
  input lab_id: String
  input as_of: String

  escape homelab_store

  read services: Collection[ServiceObservation]
    from "homelab/services"
    lifecycle :window

  read packages: Collection[PackageObservation]
    from "homelab/packages"
    lifecycle :window

  read advisories: Collection[AdvisoryClaim]
    from "public/advisories"
    lifecycle :window

  compute degraded_services = filter(services, is_degraded)
  compute relevant_advisories = filter(advisories, matches_installed_package)
  compute alert_count = count(degraded_services) + count(relevant_advisories)

  output alert: AwarenessAlert lifecycle :durable
}
```

Minimum useful output:

```text
AwarenessAlert {
  lab_id,
  as_of,
  alert_count,
  service_refs: Collection[ObservationRef],
  advisory_refs: Collection[EvidenceRef],
  safe_action: SafeActionPolicy
}
```

Failure if v0 allows:

- public advisory treated as proof of local compromise;
- owned telemetry and public claim merged into one trust class;
- remediation action emitted without capability and human review policy;
- alert without cited advisory or telemetry refs.

## Sufficient / Insufficient Verdict

[D] The v0 subset is sufficient for read-only, bounded, normalized,
evidence-linked product surfaces.

It can support:

- OSINT daily brief from pre-extracted claims;
- Spark CRM lead/availability signal digest from synthetic normalized facts;
- home-lab awareness alert from owned telemetry and public-style advisory
  claims.

[D] The v0 subset is insufficient for end-to-end product autonomy.

It does not yet support:

- source collection or connector implementation;
- LLM extraction as artifact of record;
- robust contradiction/proof search;
- tenant/time policy strong enough for production operations;
- exact financial/accounting semantics;
- executable actions, remediation, vendor routing, or public communication.

[D] This is a good compiler-first product floor. The demo should be:

```text
pre-normalized observations
  -> .ig contract
  -> ParsedProgram
  -> SemanticIR-like proof
  -> evidence-linked product artifact
  -> blocked negative cases
```

## Prioritized Missing Primitives

### P0: Blocks All Three Lanes

1. Bounded collection join/correlation by key.
   `filter` and `map` are not enough once alerts must connect claims to
   evidence, lead signals to availability, or advisories to installed packages.

2. Required evidence/reference fields on product outputs.
   The compiler or semantic checker must reject product artifacts that drop
   observation/evidence references.

3. Typed temporal primitives.
   `String` dates are enough for fixture sketches, but not for real `as_of`,
   valid-time overlap, windows, and stale-read diagnostics.

4. Pure helper definitions and predicate typing over records.
   Product contracts need small functions like `has_evidence_link`,
   `is_duplicate`, and `matches_installed_package` without becoming opaque host
   code.

### P1: Blocks Two Lanes Or Production Readiness

5. Observation trust class and source/reality distinction in source-level types.
   OSINT and home-lab both break if public claims, synthetic facts, forecasts,
   and owned telemetry collapse into one value class.

6. Citation/redaction policy on user-visible artifacts.
   OSINT and Spark reports must not leak private or provider-specific details.

7. Result/diagnostic output for blocked artifacts.
   A blocked alert/brief/digest should produce a typed diagnostic, not vanish or
   degrade into prose.

8. Stable aggregate semantics in source-to-SemanticIR.
   `count`, `sum`, `group_by`, and `fold` need deterministic result shape and
   `aggregated_from` links.

### P2: Lane-Specific, Do Not Broaden v0 For These Alone

9. `Decimal[scale]` and idempotency key semantics for Spark lead/bid pressure.

10. Tenant scope as a type-level or checked scoped-read primitive for Spark.

11. SemVer/package version comparison for home-lab awareness.

12. Human review and capability-gated action receipts for remediation,
    production routing, vendor escalation, or public response.

## What Not To Add Yet

[X] Do not add full Prolog-style inference to the compiler-first product floor.
Use typed precomputed contradiction facts or bounded Datalog-like proof fixtures
later.

[X] Do not put source collection, crawling, API clients, credentials, or provider
payload schemas in the language core.

[X] Do not turn v0 into a workflow/action engine. Read-only evidence-linked
outputs are enough to prove first product value.

[X] Do not add arbitrary loops or recursive search. Bounded collection
operations preserve the compiler-first discipline.

## Concrete Next Requests

### Research Agent

Create `compiler-first-product-fixture-v0` with three tiny normalized input
sets and expected outputs:

- OSINT: one watchlist, three claims, two source observations, two evidence
  links, one correction, one contradicted precomputed flag.
- Spark: one company/date, three lead signals, one duplicate, one rejected, one
  availability snapshot with one available technician.
- Home-lab: one lab, two service observations, two installed packages, one
  matching public-style advisory claim.

Each fixture should prove:

- positive product artifact emitted with evidence/observation refs;
- negative artifact blocked when evidence refs are empty;
- negative stale or missing `as_of` blocked;
- negative mixed scope blocked where scope exists.

### Compiler/Grammar Expert

Answer these formal questions:

1. Is bounded join/correlation part of stdlib v0, or should it be expressed as
   `group_by` + `map` lowering?
2. Can source-level types declare required evidence/ref fields that semantic
   gates can enforce without sample-value execution?
3. What is the minimal typed time surface: `Date`, `Time`, `Interval`,
   `ValidTime`, or only `as_of` plus lifecycle?
4. Are pure predicate helpers guaranteed in PROP-015 for compiler-first product
   contracts, and how are their record-field dependencies represented in
   SemanticIR?
5. Should `ObservationRef`, `EvidenceRef`, and trust class be stdlib structural
   records or first-class language types?

### Bridge Agent

Prepare metadata-only bridge candidates:

- `ProductArtifactReport` for daily briefs, signal digests, and awareness
  alerts;
- `EvidenceReferenceReport` for required evidence/observation refs;
- `BlockedArtifactDiagnostic` for no-evidence, stale-time, mixed-scope, and
  trust-class failures;
- `CompilerFirstProductProfile` mapping source fixture output to report
  metadata without UI or connector implementation.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/compiler-first-product-pressure-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Compiler-first product value is viable for read-only, bounded, normalized,
  evidence-linked artifacts.
- The v0 product floor should be normalized observations in and reviewable
  product artifact out.
- Do not broaden v0 into collection, extraction, inference, or action
  automation yet.

[R] Recommendations:
- Research Agent should build a three-lane compiler-first fixture with OSINT,
  Spark, and home-lab normalized inputs plus blocked negatives.
- Compiler/Grammar Expert should prioritize bounded joins, required refs,
  typed time, and pure predicate helper semantics.
- Bridge Agent should prepare metadata-only product artifact and blocked
  diagnostic profiles.

[S] Signals:
- All three lanes can deliver product value without full language expansion if
  input facts are normalized.
- All three lanes become weak if outputs can omit evidence/observation refs.
- Spark-specific Decimal/idempotency/tenant pressure is real but should not
  dominate the compiler-first floor.

[T] Tests / Proofs:
- Documentation-only pressure slice; no executable tests run.

[Files] Changed:
- igniter-lang/docs/tracks/compiler-first-product-pressure-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Is join/correlation a v0 stdlib primitive or a lowering pattern?
- What is the smallest typed time surface for product artifacts?
- Which output evidence gates can be static and which require fixture/runtime
  checking?

[X] Rejected:
- No full Prolog inference in the compiler-first floor.
- No connector, credential, crawler, provider payload, or action runtime in
  language core.
- No arbitrary loops or recursive search.

[Next] Proposed next slice:
- compiler-first-product-fixture-v0: executable normalized fixtures for OSINT
  daily brief, Spark signal digest, and home-lab awareness alert with positive
  artifacts and blocked negative cases.
```
