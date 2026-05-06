# Track: Personal OSINT Assistant Product Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/personal-osint-assistant-product-pressure-v0.md`
Status: done
Slice state: done on 2026-05-06
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track pressures Igniter-Lang with a lawful personal/business OSINT
assistant product vision.

The product is an evidence-backed awareness assistant for information overload:

- personal knowledge watchlists;
- brand and reputation monitoring;
- vendor, customer, and company monitoring;
- daily briefs, contradiction alerts, and audit-ready reports.

It is not an intrusion, evasion, doxxing, credential, or abuse tool.

Safety boundary:

- public, synthetic, or open-source style inputs only;
- no credential theft;
- no private target intrusion;
- no doxxing or deanonymization workflows;
- no evasion, scraping bypass, rate-limit abuse, exploit guidance, or
  operational targeting;
- no alert may be emitted without evidence links and citation/redaction policy.

## Source Horizon

- `igniter-lang/docs/tracks/osint-fractal-traceability-pressure-v0.md`
- `igniter-lang/docs/tracks/osint-fractal-traceability-fixture-v0.md`
- `igniter-lang/docs/tracks/human-agent-readable-contracts-pressure-v0.md`
- `igniter-lang/docs/tracks/sandbox-simulation-world-modeling-pressure-v0.md`
- `igniter-lang/docs/applied-pressure-directions.md`

## Product Claim

[D] A lawful personal OSINT assistant is a claim/evidence operating system for
overloaded humans:

```text
watchlist
  -> lawful source collection
  -> source observations
  -> claim extraction
  -> subject grouping
  -> contradiction / drift detection
  -> fact-check snapshot
  -> evidence-linked brief or alert
  -> human review / correction / acceptance
```

[D] The product value is not "it found something." The value is:

```text
what changed
why it matters
what evidence supports it
what contradicts it
how confident the assistant is
what caveats apply
what a human may safely do next
```

## Lawful-Safe Product Boundary

Allowed inputs:

- public web pages and public posts where access is authorized;
- public filings, public changelogs, public status pages, public docs;
- user-provided documents and knowledge bases;
- synthetic/open-source style fixture inputs;
- licensed APIs or feeds where the user has rights to process the data.

Rejected inputs and workflows:

- private account scraping or credential use outside explicit user-controlled
  connectors;
- credential theft, phishing, session hijacking, token extraction;
- private target intrusion, vulnerability exploitation, or bypass guidance;
- doxxing, stalking, deanonymization, or personal harassment;
- evasion of access controls, rate limits, robots policies, or paywalls;
- ungrounded allegations without evidence links and caveats;
- automated external action without human review and explicit capability
  receipt.

## Core Product Workflows

### 1. Watchlist Setup

```text
Watchlist = {
  watchlist_id,
  owner_ref,
  subject_refs,
  collection_policy_ref,
  citation_policy_ref,
  redaction_policy_ref,
  alert_policy_ref,
  safe_action_policy_ref
}
```

Watchlist examples:

- `brand/fixture-acme`;
- `vendor/fixture-payments`;
- `customer/fixture-enterprise`;
- `company/fixture-competitor`;
- `topic/fixture-ai-regulation`;
- `person/self-profile`.

### 2. Source Collection

```text
SourceCollectionRun = {
  run_id,
  watchlist_ref,
  source_scope,
  collection_time,
  collection_policy_ref,
  result_status,
  source_observation_refs
}
```

[D] Collection is lawful only when the source scope and collection policy are
explicit. Hidden collection method is OOF for this product lane.

### 3. Claim Extraction And Grouping

```text
SourceObservation
  -> ClaimExtractionRun
  -> Claim
  -> SubjectClaimCluster
```

Claim grouping must keep repeated claims separate from independent evidence:

```text
SubjectClaimCluster = {
  cluster_id,
  subject_ref,
  predicate,
  claim_refs,
  independent_source_count,
  repeated_claim_count,
  contradiction_refs
}
```

### 4. Reputation Signal Tracking

```text
ReputationSignal = {
  signal_id,
  subject_ref,
  signal_kind,
  polarity,
  claim_refs,
  evidence_refs,
  confidence_ref,
  valid_time,
  caveats
}
```

Signal kinds for the product:

- `service_reliability`;
- `customer_sentiment`;
- `vendor_risk`;
- `leadership_change`;
- `policy_or_terms_change`;
- `security_or_trust_claim`;
- `contradiction_detected`.

### 5. Fact-Check Snapshot

```text
FactCheckSnapshot = {
  snapshot_id,
  watchlist_ref,
  subject_ref,
  as_of,
  source_observation_refs,
  claim_refs,
  evidence_link_refs,
  confidence_refs,
  contradiction_refs,
  correction_refs,
  citation_policy_ref,
  redaction_policy_ref
}
```

### 6. Evidence-Linked Alert

```text
EvidenceLinkedAlert = {
  alert_id,
  watchlist_ref,
  subject_ref,
  alert_kind,
  headline_claim_ref,
  snapshot_ref,
  evidence_refs,
  contradiction_refs,
  confidence_ref,
  caveats,
  safe_action_policy_ref,
  status: :ready_for_human_review
}
```

[D] Alerting without evidence links is OOF for this product. The assistant may
say "watch this" only with source, claim, confidence, caveat, and temporal
context.

### 7. Correction / Update Receipt

```text
UpdateReceipt = {
  receipt_id,
  prior_snapshot_ref,
  replacement_snapshot_ref,
  changed_claim_refs,
  correction_refs,
  caused_by_refs,
  updated_at,
  status
}
```

## Synthetic Product Scenario

Fixture product: personal/business watchlist assistant for `brand/fixture-acme`
and `vendor/fixture-payments`.

Synthetic public-style inputs:

```text
src-001: public changelog says vendor API v2 deprecation delayed to 2026-07-01
src-002: derivative blog repeats old claim that v2 deprecates on 2026-06-01
src-003: public status note reports intermittent payment latency on 2026-05-06
src-004: community forum repeats latency report without new details
```

Extracted claims:

```text
claim-001: vendor/fixture-payments deprecates api/v2 on 2026-07-01
claim-002: vendor/fixture-payments deprecates api/v2 on 2026-06-01
claim-003: vendor/fixture-payments had intermittent latency on 2026-05-06
claim-004: vendor/fixture-payments latency report repeated by derivative source
```

Expected product outputs:

```text
DailyBrief:
  - vendor API deprecation date changed / contradicted
  - latency signal observed
  - derivative repetitions separated from independent evidence

ContradictionAlert:
  - deprecation date conflict: 2026-07-01 vs 2026-06-01
  - cite src-001 and src-002
  - confidence: direct source supersedes derivative old claim, caveat retained

ReputationDrift:
  - vendor reliability signal: mild negative, evidence-limited
  - no escalation without independent confirmation

AuditReadyReport:
  - source observations
  - claim timeline
  - contradiction report
  - correction/update receipt
  - citation/redaction policy
```

## User Value Surfaces

### Daily Brief

```text
DailyBrief = {
  brief_id,
  owner_ref,
  watchlist_refs,
  as_of,
  sections:
    - priority_changes
    - contradiction_alerts
    - reputation_drift
    - source_reliability_changes
    - unresolved_claims
  snapshot_refs,
  evidence_required: true
}
```

### Reputation Drift

```text
ReputationDriftReport = {
  report_id,
  subject_ref,
  window,
  baseline_snapshot_ref,
  current_snapshot_ref,
  signal_deltas,
  caveats,
  status
}
```

### Contradiction Alert

```text
ContradictionAlert = {
  alert_id,
  contradiction_ref,
  subject_ref,
  conflicting_claim_refs,
  evidence_refs,
  temporal_overlap,
  recommended_safe_action: :review_sources
}
```

### Source Reliability View

```text
SourceReliabilityView = {
  view_id,
  source_refs,
  reliability_signals:
    - direct_source_count
    - derivative_repetition_count
    - correction_count
    - contradiction_count
    - citation_completeness
}
```

### Claim Timeline

```text
ClaimTimeline = {
  timeline_id,
  subject_ref,
  claim_refs_ordered_by_valid_time,
  correction_refs,
  contradiction_refs,
  as_of
}
```

### Audit-Ready Report

```text
AuditReadyReport = {
  report_id,
  snapshot_ref,
  analyst_or_user_decision_ref,
  source_observation_refs,
  evidence_link_refs,
  correction_refs,
  citation_policy_ref,
  redaction_policy_ref,
  reproducibility_status
}
```

## Agent-Safe Action Limits

The assistant may:

- collect allowed public/user-provided source observations;
- extract and group claims;
- detect contradictions;
- produce evidence-linked briefs and alerts;
- suggest safe review actions;
- draft correction receipts for human review.

The assistant may not:

- contact targets;
- publish allegations;
- trigger business actions;
- enrich private identities;
- attempt access to private systems;
- bypass source access controls;
- convert confidence into truth;
- escalate an alert without evidence links and human review.

## Language Pressure

- `Claim` lifecycle must include asserted, inferred, contradicted, corrected,
  superseded, and unresolved states.
- `SourceReliability` must distinguish direct, derivative, stale, corrected,
  contradicted, and unknown sources.
- `ConfidenceAssessment` must carry caveats and method refs.
- `TemporalValidity` must be mandatory for claims, signals, and reports.
- `CitationPolicy` and `RedactionPolicy` must travel with public outputs.
- `HumanReview` and `AcceptanceReceipt` must gate high-impact alerts and
  report publishing.
- `AgentActionLimit` must be contract-addressable and capability-gated.
- `Alert` must be an evidence-linked object, not a free-form model summary.

## Negative Cases

### POSINT-1: Alert Without Evidence Links

```text
alert_kind: reputation_risk
headline: "Vendor is unreliable"
evidence_refs: []
```

Expected:

```text
status: :blocked
diagnostic: alert.evidence_links_missing
```

### POSINT-2: Derivative Repetition Counted As Corroboration

```text
direct_source_count: 1
derivative_repetition_count: 3
confidence_label: :high_independent_confirmation
```

Expected:

```text
status: :blocked
diagnostic: source_reliability.derivative_not_independent
```

### POSINT-3: Private Target Intrusion Request

```text
requested_action: collect_private_account_data
authorization_ref: null
```

Expected:

```text
status: :blocked
diagnostic: safety.private_target_intrusion_forbidden
```

### POSINT-4: Reputation Drift Without Temporal Window

```text
subject_ref: vendor/fixture-payments
window: null
```

Expected:

```text
status: :blocked
diagnostic: reputation_drift.temporal_window_missing
```

### POSINT-5: Report Omits Correction Receipt

```text
known_correction_ref: correction/vendor-deprecation-date
report.correction_refs: []
```

Expected:

```text
status: :blocked
diagnostic: report.correction_receipt_omitted
```

## What Current Igniter-Lang Handles

- OSINT traceability fixtures already cover source observations, claims,
  evidence links, contradictions, corrections, snapshots, and reports.
- Human-agent review fixtures cover proposal, review, correction, acceptance,
  and runtime verification.
- Simulation trust classes provide language precedent for separating output
  kinds and refusing to promote synthetic output to fact.
- CORE / ESCAPE / OOF can classify allowed collection, forbidden private
  intrusion, missing provenance, and unsafe alerts.
- TBackend-style histories can store claim timelines and update receipts.

## Where It Breaks Or Lacks Capability

- Product workflows need first-class `Watchlist`, `AlertPolicy`,
  `AgentActionLimit`, and `SafeActionPolicy` types.
- Source reliability is not yet a typed aggregate over evidence history.
- Reputation drift requires temporal comparison semantics over claim/signal
  snapshots.
- Alert severity and confidence must be typed separately.
- Citation/redaction policy needs bridge/package enforcement, not only docs.
- High-impact assistant outputs need human review and acceptance semantics
  before publication or external action.

## Concrete Research Fixture Request

Please implement a standalone product fixture proof:

```text
track_request: personal_osint_assistant_product_fixture_v0
suggested_dir: igniter-lang/experiments/personal_osint_assistant_product_fixture/
inputs:
  - Watchlist for brand/fixture-acme and vendor/fixture-payments
  - four synthetic public-style SourceObservation records
  - extracted Claim records for deprecation date and latency signal
  - EvidenceLink records distinguishing direct and derivative sources
  - SourceReliabilityView
  - ContradictionReport for deprecation date conflict
  - ReputationSignal records
  - FactCheckSnapshot
  - UpdateReceipt / CorrectionReceipt
  - DailyBrief
  - ContradictionAlert
  - ReputationDriftReport
  - AuditReadyReport
  - negative cases POSINT-1..POSINT-5
outputs:
  - golden daily brief
  - golden contradiction alert with evidence links
  - golden reputation drift report
  - golden source reliability view
  - golden claim timeline
  - golden audit-ready report
  - golden safety diagnostics
checker:
  - rejects alerts without evidence links
  - rejects derivative repetition as independent corroboration
  - rejects private-target intrusion requests
  - rejects reputation drift without temporal window
  - rejects report that omits known correction receipt
  - verifies all public outputs carry citation/redaction policy
safety:
  - synthetic public/open-source style facts only
  - no credential theft, private intrusion, doxxing, evasion, abuse,
    operational targeting, or sensitive real-world data
```

Proof acceptance:

- daily brief contains only evidence-linked items;
- contradiction alert links conflicting claims and source observations;
- reputation drift is caveated and windowed;
- source reliability separates direct sources from derivative repetitions;
- audit-ready report includes snapshot, timeline, corrections, citations, and
  redaction policy;
- unsafe collection/action requests are blocked.

## Compiler Questions

1. Should `Watchlist` be a contract, projection horizon, user artifact, or
   RuntimeMachine loadable configuration?
2. Should `SourceReliability` be a typed report over source history or a field
   on `SourceObservation`?
3. How should `ReputationSignal` compose `Claim`, `EvidenceLink`,
   `ConfidenceAssessment`, and temporal validity?
4. What type rule prevents `Alert.severity` from being derived directly from
   `ConfidenceAssessment` without caveats?
5. Should `AgentActionLimit` be modeled as a capability contract, policy
   descriptor, or both?
6. What is the type boundary between lawful collection ESCAPE and forbidden
   private intrusion OOF?
7. Should citation/redaction policy be required on all user-visible outputs by
   type, classifier rule, or bridge/package enforcement?
8. How do human review/acceptance receipts compose with automated daily
   briefs versus high-impact alerts?

## Bridge / Package Candidates

- `WatchlistProfile` for user-owned subjects, collection policy, alert policy,
  citation policy, and redaction policy.
- `EvidenceLinkedAlertProfile` for alerts with headline claim, snapshot,
  evidence refs, caveats, and safe action limits.
- `DailyBriefProfile` for grouped evidence-backed summaries.
- `ReputationDriftReportProfile` for temporal signal deltas and caveats.
- `SourceReliabilityViewProfile` for direct/repeated/corrected/contradicted
  source history.
- `ClaimTimelineProfile` for ordered claims, corrections, contradictions, and
  validity windows.
- `AuditReadyReportProfile` for exportable report bundles with reproducible
  evidence chains.
- `AgentSafeActionPolicyProfile` for package-level enforcement of no private
  intrusion, no doxxing, no evasion, and no external action without review.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/personal-osint-assistant-product-pressure-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Framed a lawful personal/business OSINT assistant as an evidence-backed
  awareness product, not an intrusion or abuse tool.
- Defined product workflows for watchlists, source observations, claim
  extraction, grouping, contradiction detection, reputation drift,
  fact-check snapshots, update receipts, and evidence-linked alerts.
- Required citation/redaction policy and evidence links on all user-visible
  outputs.
- Fixed agent-safe action limits as product semantics, not UI disclaimers.

[R] Recommendations:
- Research Agent should implement the product fixture over synthetic public
  style inputs and POSINT-1..POSINT-5 negatives.
- Compiler/Grammar Expert should formalize Watchlist, SourceReliability,
  ReputationSignal, Alert, and AgentActionLimit typing.
- Bridge Agent should draft package-facing profiles for watchlists, alerts,
  daily briefs, source reliability views, and audit-ready reports.

[S] Signals:
- This product vision makes OSINT traceability practical: daily value depends
  on claim lifecycle, temporal validity, evidence links, and corrections.
- Alert semantics are a language pressure point because alerts can cause harm
  when not evidence-linked and caveated.
- Human-agent review semantics should gate high-impact alerts and external
  actions.

[T] Tests / Proofs:
- Not run; documentation/specification slice only.
- Requested Research Agent proof:
  `igniter-lang/experiments/personal_osint_assistant_product_fixture/`.

[Files] Changed:
- igniter-lang/docs/tracks/personal-osint-assistant-product-pressure-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Watchlist as contract vs projection horizon vs user artifact?
- SourceReliability as aggregate report vs source field?
- How should alert severity, confidence, and caveats compose?
- Which citation/redaction requirements belong in language vs bridge/package?

[X] Rejected:
- Credential theft, private target intrusion, doxxing, evasion, or operational
  abuse as product workflows.
- Alerts without evidence links.
- Derivative repetition as independent corroboration.
- Automated high-impact external action without human review and capability
  receipt.

[Next] Proposed next slice:
- Research Agent: implement `personal_osint_assistant_product_fixture_v0`.
- Compiler/Grammar Expert: formalize Watchlist/Alert/SourceReliability and
  agent-safe action limits.
- Bridge Agent: draft product bridge profiles for daily brief, alerts,
  reliability view, and audit-ready reports.
```
