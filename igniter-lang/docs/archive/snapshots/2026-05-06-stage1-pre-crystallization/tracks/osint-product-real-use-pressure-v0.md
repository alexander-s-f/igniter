# Track: OSINT Product Real Use Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/osint-product-real-use-pressure-v0.md`
Status: done
Slice state: done on 2026-05-06
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track pressure-tests the OSINT assistant as a lawful real product
direction and as a general-purpose language vector.

The core thesis:

```text
OSINT assistant value = evidence-backed awareness under lawful collection,
not scraping volume, private intrusion, or free-form agent summaries.
```

Safety boundary:

- public, synthetic, licensed, or user-provided inputs only;
- no credential theft, private target intrusion, doxxing, deanonymization,
  evasion, exploit guidance, or operational abuse;
- no alert without evidence links;
- no high-impact action without human review and explicit capability receipt;
- no claim promoted to fact because it was repeated or summarized.

## Source Horizon

- `igniter-lang/docs/tracks/osint-fractal-traceability-pressure-v0.md`
- `igniter-lang/docs/tracks/osint-fractal-traceability-fixture-v0.md`
- `igniter-lang/docs/tracks/personal-osint-assistant-product-pressure-v0.md`
- `igniter-lang/docs/tracks/personal-osint-assistant-product-fixture-v0.md`
- `igniter-lang/docs/tracks/osint-logical-inference-contract-pressure-v0.md`
- `igniter-lang/docs/tracks/human-agent-readable-contracts-pressure-v0.md`

## Product Pressure Matrix

| Product lane | Data source types | Claim / evidence shape | Useful alerts | Safety boundaries | Required human review |
|--------------|-------------------|------------------------|---------------|-------------------|-----------------------|
| Personal knowledge assistant | User-provided notes, saved articles, public docs, subscribed newsletters, personal watchlists | `SourceObservation` from user-owned/public material; `Claim` about topic/person/company/project; `EvidenceLink` to citations; `FactCheckSnapshot` for briefs | Daily brief, changed claim, contradiction in saved sources, stale knowledge, missing citation | No private account scraping outside user-authorized connectors; no doxxing; no unverifiable personal allegations; no publishing | Required before external sharing, deletion, high-impact summarization, or claim correction |
| Brand / reputation monitoring | Public pages, public posts, reviews, public changelogs, press pages, public status notes, licensed feeds | `ReputationSignal` over claims/evidence; direct vs derivative source separation; temporal drift windows | Reputation drift, contradiction alert, negative signal spike, source reliability change, correction required | No harassment workflows; no private profile enrichment; no ungrounded allegations; no automated public response | Required before public response, legal/escalation reports, vendor/customer contact, or high-severity alert broadcast |
| Vendor / customer / company monitoring | Public vendor docs, public terms, public status pages, public filings, customer-provided docs, contract metadata supplied by user | `ClaimTimeline` for policy/version/status changes; `EvidenceLink` to source observations; `ConfidenceAssessment` with caveats | Terms change, deprecation date conflict, outage/latency signal, leadership/product change, risk caveat | No credential use; no private portals unless user-provided connector rights; no bypass; no inference of private customer state | Required before procurement action, account escalation, customer messaging, or risk scoring publication |
| Spark CRM vendor / lead signals | Synthetic Spark-style vendor lead events, public vendor status/docs, licensed marketing feeds, user-owned CRM facts | `LeadSignalObservation` plus public/vendor claims; `IdempotencyKey`; `HourlyRollup`; `ReputationSignal` for vendor quality; evidence-linked conversion caveats | Vendor lead quality drift, duplicate signal burst, bid/acceptance anomaly, vendor status contradiction | No real customer data in public reports; no raw provider payload exposure; no endpoint/credential leakage; no automated vendor accusation | Required before vendor routing policy changes, billing dispute, public report, or production workflow mutation |
| Home-lab / cluster awareness | User-owned telemetry, public package advisories, public release notes, local logs owned by user, synthetic cluster fixtures | `RealObservation` for user-owned telemetry; `SourceObservation` for public advisories; `Claim` about version/status/vulnerability; `FactCheckSnapshot` for remediation state | Package advisory relevant, version drift, service degradation, contradictory status, stale backup/snapshot | No third-party probing; no exploit steps; no scanning beyond owned systems; no credential extraction | Required before destructive remediation, external disclosure, network changes, or automated restart outside policy |

## Cross-Lane Workflow

All lanes share the same semantic spine:

```text
Watchlist
  -> CollectionPolicy
  -> SourceObservation / RealObservation
  -> ClaimExtractionRun
  -> Claim
  -> EvidenceLink
  -> SubjectClaimCluster
  -> ConfidenceAssessment
  -> ContradictionReport
  -> FactCheckSnapshot
  -> Alert / Brief / Report
  -> HumanReview / CorrectionReceipt / AcceptanceReceipt
```

[D] The product becomes general-purpose because the same claim/evidence
pipeline works for personal knowledge, business reputation, vendor/customer
monitoring, Spark-like operational signals, and owned infrastructure.

## Unique Igniter-Lang Leverage

### Versus Normal App Code

Normal app code can implement tables, jobs, and notifications. Igniter-Lang is
useful if it gives semantic guarantees app code usually does not:

- every alert is contract-addressable;
- every claim links to evidence;
- repeated claims cannot accidentally count as independent corroboration;
- temporal validity is not optional;
- correction receipts preserve what changed and why;
- human review and acceptance are typed artifacts;
- unsafe action boundaries are checked before execution.

### Versus Workflow Engines

Workflow engines move tasks between steps. Igniter-Lang should explain meaning:

- why a claim was extracted;
- why a contradiction exists;
- why a confidence label has caveats;
- why an alert is blocked;
- why a report is reproducible at `as_of`;
- which source/evidence/correction chain supports each output.

### Versus Rules Engines

Rules engines can fire conditions. Igniter-Lang should add:

- observation provenance;
- temporal scope;
- typed claims and predicates;
- bounded logical inference with proof traces;
- ConfidenceAssessment as evidence-linked output;
- correction and review receipts;
- CORE / ESCAPE / OOF trust boundaries.

### Versus LLM-Only Agents

LLM-only agents are good at reading and summarizing, but weak as artifact of
record. Igniter-Lang should make the LLM an assistant, not the source of truth:

- model summary is not evidence;
- extracted claims must link to source observations;
- generated alerts must pass contract checks;
- confidence prose must be backed by evidence/caveats;
- human acceptance is a receipt, not a chat approval;
- reports must be reproducible without trusting the model's memory.

## What Language Must Provide

Igniter-Lang must provide:

- `SourceObservation`, `RealObservation`, `SyntheticObservation`,
  `ForecastObservation`, and `CounterfactualObservation` trust distinctions.
- `Claim` as a typed semantic value with subject, predicate, object,
  status, valid time, and source links.
- `EvidenceLink` with relation, strength, temporal alignment, citation policy,
  and redaction policy.
- `ConfidenceAssessment` that carries method, evidence refs, caveats, and
  never becomes truth by itself.
- `ContradictionReport` over typed predicates and temporal overlap.
- `FactCheckSnapshot` as reproducible as-of bundle over claims/evidence.
- `CorrectionReceipt` and `UpdateReceipt` for changed claims and reports.
- `Watchlist`, `CollectionPolicy`, `AlertPolicy`, and `SafeActionPolicy`
  shapes.
- `EvidenceLinkedAlert` as a typed artifact, not a free-form summary.
- `HumanReview`, `AnalystDecision`, and `AcceptanceReceipt` for high-impact
  outputs.
- Bounded inference/proof trace semantics for Prolog/Datalog-like reasoning.
- Citation/redaction policy as mandatory on user-visible outputs.
- CORE / ESCAPE / OOF classification for collection, inference, and actions.

## What Belongs Outside Language

These should not be language core:

- crawling/scraping/browser automation implementation;
- connector credentials, OAuth, API clients, and feed billing;
- provider-specific payload schemas;
- rate-limit management and robots/paywall policy enforcement details;
- UI layout for briefs, dashboards, and timelines;
- ranking heuristics tuned to a product market;
- LLM prompt text and provider model selection;
- data storage engine implementation;
- legal policy content and jurisdiction-specific compliance advice;
- public response workflows, outreach, vendor/customer messaging;
- exploit scanning, private system probing, or any abuse workflow.

[D] These can be ESCAPE adapters, product code, policies, or bridge profiles,
but they are not language semantics.

## Product-Lane Breakpoints

### Personal Knowledge Assistant

Breaks when:

- old notes are treated as current fact;
- user memory and public source conflict without contradiction report;
- generated summary omits citation;
- source provenance is lost during clustering.

Language demand:

- `ClaimTimeline`, temporal validity, citation policy, contradiction report.

### Brand / Reputation Monitoring

Breaks when:

- sentiment spike is reported without source reliability view;
- derivative reposts inflate severity;
- allegations are summarized without caveats;
- public response is drafted as if facts are resolved.

Language demand:

- `SourceReliabilityView`, repeated-claim guard, human review gate.

### Vendor / Customer / Company Monitoring

Breaks when:

- stale deprecation date beats newer source;
- policy change has no valid-time;
- vendor outage claim is conflated with user-owned telemetry;
- risk score hides caveats.

Language demand:

- typed predicates, temporal precedence, real/source observation distinction.

### Spark CRM Vendor / Lead Signals

Breaks when:

- lead rollup metrics are mixed with vendor reputation claims;
- customer data leaks into public report;
- duplicate lead burst becomes vendor accusation without review;
- production routing policy changes from unaccepted alert.

Language demand:

- data class separation, redaction policy, acceptance receipt before action.

### Home-Lab / Cluster Awareness

Breaks when:

- public advisory is treated as proof of local compromise;
- owned telemetry and public claim are not distinguished;
- remediation action executes without capability/human gate;
- exploit details leak into report.

Language demand:

- observation kind boundary, safe action policy, no exploit/intrusion lane.

## Negative Cases

### REALUSE-1: LLM Summary Without Evidence

```text
brief_item: "Vendor appears unreliable."
evidence_refs: []
source_observation_refs: []
```

Expected:

```text
status: :blocked
diagnostic: product_output.evidence_missing
```

### REALUSE-2: Derivative Virality Inflates Reputation Severity

```text
direct_source_count: 1
derivative_repetition_count: 25
severity: :critical
```

Expected:

```text
status: :blocked
diagnostic: reputation.derivative_repetition_inflated_severity
```

### REALUSE-3: Public Advisory Treated As Local Compromise

```text
source_claim: package has vulnerability
derived_claim: owned_cluster_compromised
real_observation_refs: []
```

Expected:

```text
status: :blocked
diagnostic: inference.source_claim_not_real_observation
```

### REALUSE-4: Alert Triggers Business Action

```text
alert_ref: alert/vendor-risk
action: change_vendor_routing_policy
acceptance_receipt_ref: null
```

Expected:

```text
status: :blocked
diagnostic: action.high_impact_review_required
```

### REALUSE-5: Private Intrusion Connector

```text
collection_policy: private_account_collection
authorization_ref: null
```

Expected:

```text
status: :blocked
diagnostic: collection.private_intrusion_forbidden
```

## Product Direction Assessment

[D] This is a strong real product direction because information overload is
already a daily pain, and the product can start safely with:

- user-owned notes/docs;
- public source watchlists;
- vendor/company changelogs and status pages;
- owned home-lab telemetry;
- synthetic Spark-like operational fixtures.

[D] Igniter-Lang has unique leverage if the product promise is:

```text
not "AI summary"
but "evidence-linked, temporally valid, correction-aware, review-gated brief"
```

[R] Avoid starting with high-risk personal monitoring. Start with:

1. personal knowledge watchlists;
2. vendor/company public change monitoring;
3. owned home-lab awareness;
4. brand/reputation monitoring with strict caveats;
5. Spark CRM vendor/lead signal sandbox.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/osint-product-real-use-pressure-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Mapped five lawful product lanes for OSINT assistant pressure: personal
  knowledge, brand/reputation, vendor/customer/company, Spark CRM vendor/lead
  signals, and home-lab/cluster awareness.
- Identified Igniter-Lang's unique leverage over app code, workflow engines,
  rules engines, and LLM-only agents.
- Separated language responsibilities from product/adapters/connectors/UI/legal
  policy concerns.
- Reaffirmed evidence-linked alerts and human review for high-impact actions.

[R] Recommendations:
- Research Agent should convert this into a compact product fixture matrix with
  one positive and one blocked alert per lane.
- Compiler/Grammar Expert should prioritize typed Alert, Watchlist,
  SourceReliability, SafeActionPolicy, and observation-kind boundaries.
- Bridge Agent should map product bridge profiles for brief, alert, reliability
  view, timeline, and audit-ready report.

[S] Signals:
- The strongest product wedge is evidence-linked daily awareness, not broad
  autonomous investigation.
- Igniter-Lang matters where reproducibility, correction, temporal validity,
  evidence links, and review gates are product guarantees.
- LLMs remain useful as extractors/summarizers, but not as artifact of record.

[T] Tests / Proofs:
- Not run; documentation/product-pressure slice only.

[Files] Changed:
- igniter-lang/docs/tracks/osint-product-real-use-pressure-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Which product lane should become the first user-facing prototype?
- Should SafeActionPolicy live in language, bridge, or product layer?
- How strict should citation/redaction policy be for private user-owned notes?
- How much source reliability should be computed in CORE vs product heuristics?

[X] Rejected:
- Credential theft, private target intrusion, doxxing, deanonymization,
  evasion, exploit guidance, or operational abuse.
- LLM summaries as evidence.
- Alerts without evidence links.
- High-impact business/infrastructure action without human review receipt.

[Next] Proposed next slice:
- Research Agent: `osint-product-real-use-fixture-v0`.
- Compiler/Grammar Expert: `osint-alert-watchlist-safe-action-formalization-v0`.
- Bridge Agent: `osint-product-brief-alert-report-bridge-profile-v0`.
```
