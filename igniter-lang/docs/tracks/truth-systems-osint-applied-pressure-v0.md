# Track: Truth Systems OSINT Applied Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/truth-systems-osint-applied-pressure-v0.md`
Status: done
Card: `S3-R14-C8-P`
Slice state: done on 2026-05-09
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Meta Expert]`

## Frame

This track turns the external `NewsClarityAggregator` idea into applied
pressure for Igniter-Lang.

The goal is domain usefulness, not grammar implementation.

Authority boundary:

- this track does not promote external pseudocode to canon;
- no implementation code is authorized or requested;
- all scenarios are synthetic/public-style;
- this is pressure over language/runtime/product/safety capabilities.

Source horizon:

- `playgrounds/docs/external/External Pressure Reviewer V2 Cross Test.md`
- `igniter-lang/docs/agent-orchestra-pattern.md`
- `igniter-lang/docs/applied-pressure-directions.md`
- `igniter-lang/docs/value-index.md`
- `igniter-lang/docs/tracks/osint-fractal-traceability-pressure-v0.md`
- `igniter-lang/docs/tracks/personal-osint-assistant-product-pressure-v0.md`
- `igniter-lang/docs/tracks/osint-product-real-use-pressure-v0.md`
- `igniter-lang/docs/tracks/claim-evidence-confidence-typing-v0.md`
- `igniter-lang/docs/tracks/human-agent-readable-contracts-pressure-v0.md`

Safety boundary:

- lawful public, licensed, user-provided, or synthetic inputs only;
- no private target intrusion, credential theft, doxxing, deanonymization,
  harassment, evasion, exploit guidance, or operational abuse;
- no report without evidence links, caveats, temporal scope, citation policy,
  and redaction policy;
- no automated public accusation or external action without human review and
  explicit authority receipt.

## Compact Claim

`NewsClarityAggregator` is useful pressure because it is not a generic
summarizer. It is a truth-system surface:

```text
source observations
  -> extracted claims
  -> evidence bundles
  -> contradictions and caveats
  -> human review
  -> temporal corrections
  -> clarity reports
  -> audit-ready receipts
```

[D] The product promise is not "the system knows truth." The promise is:

```text
what is claimed
who/what observed it
what supports it
what contradicts it
what changed over time
who reviewed it
what can safely be said now
```

## Product Pressure Scenario

Synthetic scenario:

```text
subject: public-service/fixture-city-transit-line
question: "Is the weekend route closure on May 20 or May 27?"
analysis_window: 2026-05-09T08:00:00Z..2026-05-09T12:00:00Z
as_of_initial: 2026-05-09T09:30:00Z
as_of_corrected: 2026-05-09T11:45:00Z
```

Synthetic source observations:

| Source | Kind | Claim | Provenance pressure |
|--------|------|-------|---------------------|
| `src-001` | synthetic public notice | closure is May 20 | direct source, older |
| `src-002` | derivative repost | closure is May 20 | derivative repetition, not independent corroboration |
| `src-003` | synthetic official update | closure is May 27 | direct source, newer, supersedes older notice |
| `src-004` | analyst note | user asks whether alert should be updated | human review trigger, not source evidence |

Expected clarity outcome:

| As of | Report state | User-facing clarity |
|-------|--------------|---------------------|
| `as_of_initial` | contested | "Two sources say May 20, but one is derivative. Needs review." |
| `as_of_corrected` | corrected | "Latest direct update says May 27; prior May 20 claim superseded." |

The fixture should not say "true" as a naked value. It should say which claim is
currently best supported, which claim was superseded, what evidence supports
that conclusion, and whether a human accepted the update.

## Applied Pressure Model

### Domain Entities

These are product/domain entities, not syntax commitments.

| Entity | Purpose | Core pressure |
|--------|---------|---------------|
| `NewsItemObservation` | Captured article/post/notice metadata and content hash | observation evidence, citation/redaction |
| `SourceProfile` | Publisher/source identity, collection policy, provenance class | source trust, lawful boundary |
| `SourceObservation` | Time-stamped observation of source content | trust unit, not raw result value |
| `Claim` | Typed assertion extracted from a source | claim lifecycle, temporal validity |
| `ClaimExtractionRun` | Agent/tool extraction event | ESCAPE boundary, model output not evidence |
| `EvidenceLink` | Relation from observation to claim or claim to claim | support/contradict/corroborate/supersede |
| `EvidenceBundle` | Grouped links around one claim or report item | independent vs derivative evidence |
| `SourceTrustAssessment` | Reliability/caveat view over a source | trust label is not truth |
| `ConfidenceAssessment` | Assessment over claim reliability | confidence is not truth/actionability |
| `ContradictionReport` | Explicit conflict over subject/predicate/time | correction and review trigger |
| `FactCheckSnapshot` | Reproducible as-of bundle of claims/evidence | audit and temporal replay |
| `ClarityReport` | Human-readable result with evidence, caveats, and status | product value surface |
| `HumanReviewPacket` | Review-native view over claim/evidence/risk | human-agent symbiosis |
| `AnalystDecision` | Human decision on contested or high-impact output | authority boundary |
| `HumanOverrideReceipt` | Human override with reason and scope | override is accountable, not truth |
| `CorrectionReceipt` | Supersedes/corrects prior claim/report | temporal correction |
| `ClarityDecisionReceipt` | Final report emission receipt | audit and accountability |

### Claim Lifecycle

News clarity needs claim lifecycle states:

```text
extracted
  -> source_linked
  -> assessed
  -> corroborated | contradicted | contested | unverifiable
  -> reviewed
  -> accepted | corrected | superseded | retracted
  -> archived
```

Failure if missing:

- a model-extracted statement looks like a fact;
- repeated reposts inflate corroboration;
- old claims survive without supersession;
- confidence labels become truth labels;
- humans cannot see what changed.

### Evidence Bundle Semantics

`EvidenceBundle` should preserve:

- direct support links;
- contradiction links;
- contextual links;
- supersession/correction links;
- derivative repetition count;
- independent source count;
- citation and redaction policies;
- temporal alignment between source observation and claim validity.

[D] Derivative repetition must never count as independent corroboration.

### Source Trust

Source trust pressure is not a global ranking. It is contextual:

```text
SourceProfile
  + collection policy
  + provenance class
  + observed content
  + historical correction behavior
  + human caveats
  -> SourceTrustAssessment
```

Required distinction:

- direct source;
- derivative repetition;
- summary;
- model output;
- unknown provenance.

Trust labels must remain caveated assessments, not evidence by themselves.

### Temporal Correction

Truth systems require history:

```text
claim at as_of_initial
  != claim as corrected at as_of_corrected
```

Required temporal artifacts:

- `ClaimTimeline`;
- `FactCheckSnapshot` at `as_of`;
- `ClarityReport` as emitted at `as_of`;
- `CorrectionReceipt` linking prior and replacement claim/report;
- `UpdateReceipt` linking prior and replacement snapshots;
- `BiHistory` pressure where valid time and recorded/corrected time diverge.

The old report must remain explainable. A corrected report must not rewrite the
prior emitted report silently.

### Human Review And Override

High-risk or contested outputs require a human review artifact:

```text
ClarityReportCandidate
  -> HumanReviewPacket
  -> AnalystDecision
  -> AcceptanceReceipt | CorrectionReceipt | HumanOverrideReceipt
```

Human override pressure:

- override must name scope and reason;
- override must link to evidence and report candidate;
- override must not erase contradiction evidence;
- override does not make a claim true;
- override can authorize publication, downgrade, suppression, or request for
  more evidence.

### Agent Roles And Borrowed Lenses

`Agent Orchestra Pattern` maps cleanly onto this product:

| Role | Borrowed lens | Authority |
|------|---------------|-----------|
| Collector Agent | source-provenance lens | may produce source observations, not verdicts |
| Claim Extraction Agent | comprehension-pressure lens | may propose claims, not trust them |
| Evidence Agent | OSINT traceability lens | may link evidence and contradictions |
| Fact-Check Agent | product-pressure lens | may draft report candidates |
| Safety/Redaction Reviewer | safety lens | may block unsafe report surfaces |
| Human Analyst | review/authority lens | may accept, correct, override, or request more evidence |
| Meta/Supervisor | route lens | may route pressure into track/proposal/runtime slices |

[D] Borrowed lenses should be recorded on agent observations. A lens changes
the questions an agent asks, not the authority the agent has.

## Workflow Pressure

### 1. Intake

Input:

- public/synthetic article or notice;
- source metadata;
- capture time;
- collection policy;
- citation/redaction policy.

Output:

- `SourceObservation`;
- `NewsItemObservation`;
- `SourceProfile` or source profile reference.

Required diagnostics:

- `source.collection_policy_missing`;
- `source.provenance_unknown_in_factcheck_context`;
- `source.redaction_policy_missing`.

### 2. Claim Extraction

Input:

- `SourceObservation`;
- extraction model/tool result.

Output:

- `ClaimExtractionRun`;
- `Claim` values with `source_obs` refs;
- extraction caveats.

Required diagnostics:

- `claim.source_obs_missing`;
- `claim.model_output_promoted_to_evidence`;
- `claim.temporal_scope_missing`.

### 3. Evidence Assembly

Input:

- claims by subject/predicate;
- source observations;
- provenance classes.

Output:

- `EvidenceBundle`;
- `EvidenceLink` collection;
- `ContradictionReport` when predicates conflict over overlapping valid time.

Required diagnostics:

- `evidence.derivative_counted_as_corroboration`;
- `evidence.link_relation_invalid`;
- `contradiction.open_blocks_high_confidence`.

### 4. Automated Assessment

Input:

- evidence bundle;
- contradiction reports;
- source trust assessments.

Output:

- `ConfidenceAssessment`;
- report candidate;
- caveats.

Required diagnostics:

- `confidence.used_as_truth`;
- `confidence.assessment_without_evidence`;
- `risk.high_requires_human_review`.

### 5. Human Review

Input:

- report candidate;
- contradiction report;
- evidence bundle;
- caveats and risk.

Output:

- `HumanReviewPacket`;
- `AnalystDecision`;
- `AcceptanceReceipt`, `CorrectionReceipt`, or `HumanOverrideReceipt`.

Required diagnostics:

- `review.required_but_missing`;
- `override.reason_missing`;
- `acceptance.runtime_verification_missing`;
- `report.publication_authority_missing`.

### 6. Clarity Report

Output should include:

- headline claim state: supported, contested, superseded, unverifiable;
- evidence bundle summary;
- contradiction summary;
- source trust caveats;
- temporal validity;
- correction/update links;
- review status;
- safe next action guidance.

It should not include:

- hidden source collection details;
- raw private/sensitive data;
- claims without evidence;
- confidence as truth;
- publication/action authority unless explicitly granted.

## Required Igniter-Lang Capabilities

| Capability | Why this use case pressures it | Failure if absent |
|------------|--------------------------------|-------------------|
| Evidence bundles | Clarity reports must show support, contradiction, and caveats together | reports become prose summaries |
| Claim lifecycle | Claims change from extracted to contested/corrected/superseded | old or unreviewed claims look current |
| Source trust | Direct vs derivative vs model output must differ | virality becomes "truth" |
| Temporal corrections | Later corrections must not erase prior reports | audit trail becomes unreliable |
| Human review / override | High-risk contested claims need accountable human decision | agents over-authorize conclusions |
| Receipts | Publication, correction, override, and report emission need accountability | no durable proof of what happened |
| Observations | Trust unit must be observation evidence, not raw value/result | model outputs become ambient facts |
| Agent roles / lenses | Multi-agent fact checking needs bounded authority | role drift and canon leak |
| Audit and accountability | Reports must be reproducible and reviewable | no explanation under later challenge |
| Citation/redaction policy | User-facing reports need lawful safe evidence surfaces | unsafe disclosure or unusable citations |

## Why Igniter-Lang Is A Good Fit

Igniter-Lang is unusually well aligned because the product is epistemic:

- It treats observation evidence as the unit of trust.
- It can make every report, claim, correction, and review contract-addressable.
- Explicit time supports `as_of` fact-check snapshots and later corrections.
- CORE/ESCAPE/OOF maps cleanly to source collection, LLM extraction, and
  user-facing report gates.
- Receipts model human review, override, correction, and publication decisions.
- Semantic images and compatibility reports give a path to reproducible audit.
- Agent Orchestra concepts map to product roles without giving agents hidden
  authority.

The strongest fit:

```text
News clarity is not a content pipeline.
It is an evidence-and-authority pipeline.
```

That is exactly the kind of system an Epistemic Contract Language should make
harder to fake and easier to inspect.

## What Is Missing

Missing or underdeveloped capabilities:

1. First-class `EvidenceBundle` semantics.
   Current tracks have EvidenceLink and snapshots, but product reports need a
   reusable bundle shape with independent/derivative separation.

2. Source trust profile and reliability history.
   Need a way to represent source reliability with caveats and temporal drift
   without treating source reputation as truth.

3. Clarity report artifact type.
   `FactCheckSnapshot` is evidence state. `ClarityReport` is the human-facing
   product artifact that summarizes clarity, uncertainty, and review status.

4. Human review authority policy.
   Need explicit rules for when human review is required, what authority it
   grants, and what it cannot override.

5. Temporal correction over reports.
   Need report replacement/update receipts and possibly `BiHistory` for claims
   where valid time and correction time diverge.

6. Agent lens provenance.
   Agent outputs should record role, borrowed lens, context level, and authority
   so later audit can understand why the output exists.

7. Citation/redaction as mandatory output policy.
   A report without citation/redaction policy should be blocked from user-facing
   surfaces.

8. Product safety gates.
   Need explicit blocks for private data, doxxing, allegations without evidence,
   automated outreach, and unsafe publication.

## Light Spark CRM Comparison

Spark CRM and NewsClarityAggregator pressure the same spine from different
domains.

| Spark CRM pressure | News clarity pressure | Shared language demand |
|--------------------|-----------------------|------------------------|
| lead/vendor signals | source/news observations | observation evidence with provenance |
| schedule/off_schedule drift | claim/source correction | temporal correction and history |
| availability snapshot | fact-check snapshot | reproducible as-of projection |
| why-not reason | report caveat/contradiction | explainable diagnostics |
| operation request/execution receipt | review/override/publication receipt | typed receipts and authority boundary |
| tenant/company scope | watchlist/source/citation scope | scoped facts and safe output policy |
| duplicate lead suppression | derivative repetition suppression | idempotency/independence discipline |

[S] Spark asks "why did the system act this way?" News clarity asks "why should
a human believe or not believe this report?" Both require evidence, time,
receipts, and review.

## Negative Cases

### TRUTH-1: Summary Without Evidence

```text
clarity_report.item = "The closure is definitely May 20."
evidence_refs = []
```

Expected:

```text
status: blocked
diagnostic: clarity_report.evidence_missing
```

### TRUTH-2: Derivative Repetition Counted As Corroboration

```text
direct_source_count = 1
derivative_repetition_count = 12
confidence_label = high
```

Expected:

```text
status: blocked
diagnostic: evidence.derivative_counted_as_corroboration
```

### TRUTH-3: Confidence Used As Truth

```text
if confidence_label == high then publish_as_true
```

Expected:

```text
status: blocked
diagnostic: confidence.used_as_truth
```

### TRUTH-4: Human Override Without Reason

```text
override.status = accepted
override.reason = nil
```

Expected:

```text
status: blocked
diagnostic: override.reason_missing
```

### TRUTH-5: Correction Rewrites Prior Report

```text
prior_report_ref = clarity_report/initial
replacement_report_ref = clarity_report/initial
correction_receipt = missing
```

Expected:

```text
status: blocked
diagnostic: correction.prior_report_rewritten
```

### TRUTH-6: Agent Role Claims Authority

```text
agent_role = claim_extraction_agent
output = accepted_public_report
human_review_ref = nil
```

Expected:

```text
status: blocked
diagnostic: agent.authority_boundary_violation
```

## Suggested Next Slices

### Language

- `truth-systems-evidence-bundle-semantics-v0`
  Define `EvidenceBundle`, independent corroboration, derivative repetition,
  contradiction links, citation/redaction requirements, and OOF gates.

- `truth-systems-clarity-report-type-v0`
  Define `ClarityReport` as a human-facing product artifact over
  `FactCheckSnapshot`, with caveats, review status, and update refs.

- `truth-systems-human-review-authority-v0`
  Formalize `HumanReviewPacket`, `AnalystDecision`, `HumanOverrideReceipt`,
  publication authority, and what override can/cannot mean.

### Runtime

- `truth-systems-factcheck-fixture-v0`
  Synthetic executable fixture with direct source, derivative repetition,
  contradiction, corrected report, human review, and blocked negatives.

- `truth-systems-temporal-correction-proof-v0`
  Prove prior clarity report remains audit-readable after correction/update
  receipt and replacement snapshot.

- `truth-systems-agent-lens-observation-proof-v0`
  Record role, borrowed lens, context level, authority, and handoff route on
  agent-produced observations.

### Product

- `news-clarity-aggregator-product-map-v0`
  Convert this pressure model into product screens/workflows: daily clarity
  brief, contested claim panel, source reliability view, correction timeline,
  and review queue.

- `news-clarity-report-fixture-v0`
  One synthetic report over the transit closure scenario with initial contested
  report and corrected accepted report.

- `news-clarity-human-review-flow-v0`
  Define the review-native surface: what a human sees, corrects, accepts, and
  what receipt is produced.

### Safety

- `truth-systems-lawful-source-policy-v0`
  Product safety policy for public/licensed/user-provided sources, prohibited
  private collection, and output redaction.

- `truth-systems-high-impact-report-gates-v0`
  Require human review and authority receipts for allegations, public-facing
  claims, escalation, outreach, or external action.

- `truth-systems-adversarial-source-pressure-v0`
  Pressure derivative networks, coordinated repetition, source spoofing, and
  model-output laundering without adding unsafe collection behavior.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/truth-systems-osint-applied-pressure-v0.md
Status: done

[D] Decisions
- Treat NewsClarityAggregator as truth-system pressure, not canonical syntax.
- Product value is evidence-backed clarity, not automated truth assertion.
- Human review, temporal correction, source provenance, and report receipts are
  core to the use case.

[S] Shipped / Signals
- Defined domain entities, workflows, required language/runtime capabilities,
  negative cases, Spark comparison, and missing capabilities.
- Routed next slices into language, runtime, product, and safety lanes.
- Preserved safety boundary: synthetic/public-style inputs only and no
  automated high-impact action without review/authority receipt.

[T] Tests / Proofs
- Documentation-only applied pressure slice; no executable tests run.

[R] Risks / Recommendations
- Risk: without EvidenceBundle semantics, reports collapse into prose summaries.
- Risk: without agent lens/authority provenance, multi-agent fact checking can
  produce role drift and false authority.
- Recommendation: implement a synthetic fact-check fixture before any product
  UI or connector work.

[Next] Suggested next slice
- `truth-systems-factcheck-fixture-v0`: synthetic direct/derivative source,
  contradiction, correction, human review, clarity report, and blocked negative
  cases.
```
