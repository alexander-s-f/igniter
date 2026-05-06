# Track: OSINT Fractal Traceability Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/osint-fractal-traceability-pressure-v0.md`
Status: done
Slice state: done on 2026-05-06
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track opens the OSINT-like fractal traceability pressure lane for
Igniter-Lang.

The goal is not to build an OSINT product. The goal is to pressure the
language with source provenance, claim lifecycle, evidence links, confidence,
contradictions, corrections, citation policy, temporal validity, and
reproducible reports.

Safety boundary:

- synthetic public-source style scenario only;
- no real sensitive data, people, organizations, infrastructure targets,
  endpoints, credentials, private sources, or operational instructions;
- repeated claims are not trusted evidence;
- reports must preserve evidence and correction links.

## Source Horizon

- `igniter-lang/docs/applied-pressure-directions.md`
- `igniter-lang/docs/tracks/human-agent-readable-contracts-pressure-v0.md`
- `igniter-lang/docs/tracks/sandbox-simulation-world-modeling-pressure-v0.md`
- `igniter-lang/docs/tracks/observable-spine-v0.md`
- `igniter-lang/docs/tracks/failure-observation-v0.md`
- `igniter-lang/docs/proposals/PROP-005-bridge-observation-envelope-v0.md`

## Compact Claim

[D] OSINT-like pressure is fractal traceability:

```text
source
  -> claim
  -> inference
  -> contradiction
  -> correction
  -> report
  -> later audit
```

[D] The core guardrail:

```text
repeated_claim != trusted_evidence
summarized_claim != source_observation
confidence_score != truth
report_without_correction_links != reproducible analysis
```

## Synthetic Scenario

Two synthetic public bulletins report the status of a fictional service node
called `station/fixture-east-17`.

The first source says the station is `online` at 09:00 UTC. A derivative social
post repeats the same claim. A second independent source says the station is
`offline` at 09:20 UTC. The analyst initially infers `online`, then receives
the contradiction, corrects the claim to `conflicted`, and publishes a
fact-check snapshot with citation/redaction policy.

No real source, site, person, organization, infrastructure target, or endpoint
is involved.

## Pressure Vocabulary

### SourceObservation

```text
SourceObservation = {
  source_obs_id,
  source_kind,
  source_ref,
  captured_at,
  observed_time,
  payload_summary,
  citation_policy_ref,
  redaction_policy_ref,
  provenance_status
}
```

### Claim

```text
Claim = {
  claim_id,
  subject_ref,
  predicate,
  object_value,
  asserted_at,
  valid_time,
  claim_status,
  claim_kind,
  source_links
}
```

### EvidenceLink

```text
EvidenceLink = {
  link_id,
  source_ref,
  target_ref,
  relation,
  strength,
  temporal_alignment,
  citation_policy_ref,
  redaction_policy_ref
}
```

### ConfidenceAssessment

```text
ConfidenceAssessment = {
  assessment_id,
  target_ref,
  method_ref,
  evidence_refs,
  confidence_label,
  caveats,
  assessed_at
}
```

### ContradictionReport

```text
ContradictionReport = {
  contradiction_id,
  claim_refs,
  contradiction_kind,
  conflicting_fields,
  temporal_overlap,
  status
}
```

### FactCheckSnapshot

```text
FactCheckSnapshot = {
  snapshot_id,
  scope_ref,
  as_of,
  included_claim_refs,
  included_source_refs,
  included_contradiction_refs,
  confidence_refs,
  correction_refs,
  citation_policy_ref,
  redaction_policy_ref
}
```

### AnalystDecision

```text
AnalystDecision = {
  decision_id,
  analyst_ref,
  snapshot_ref,
  decision,
  rationale_refs,
  decided_at,
  status
}
```

### CorrectionReceipt

```text
CorrectionReceipt = {
  receipt_id,
  corrected_claim_ref,
  replacement_claim_ref,
  caused_by_ref,
  correction_reason,
  corrected_at,
  status
}
```

## Fixture Identity

```text
fixture_id: osint_fractal_traceability_minimal_v0
scenario_ref: scenario/synthetic-public-source-station-status@1
subject_ref: station/fixture-east-17
analysis_window: 2026-05-06T09:00:00Z..2026-05-06T10:00:00Z
as_of_initial: 2026-05-06T09:15:00Z
as_of_corrected: 2026-05-06T09:35:00Z
citation_policy_ref: citation_policy/synthetic-public-summary@1
redaction_policy_ref: redaction_policy/no-sensitive-fields@1
```

## Source Observations

```text
SourceObservation src-001:
  source_obs_id: source_obs/synthetic-bulletin-a/20260506T0900Z
  source_kind: :synthetic_public_bulletin
  source_ref: source/synthetic-bulletin-a
  captured_at: 2026-05-06T09:05:00Z
  observed_time: 2026-05-06T09:00:00Z
  payload_summary: "station fixture-east-17 status online"
  citation_policy_ref: citation_policy/synthetic-public-summary@1
  redaction_policy_ref: redaction_policy/no-sensitive-fields@1
  provenance_status: :direct_synthetic_source

SourceObservation src-002:
  source_obs_id: source_obs/synthetic-social-repeat/20260506T0910Z
  source_kind: :synthetic_derivative_post
  source_ref: source/synthetic-social-repeat
  captured_at: 2026-05-06T09:12:00Z
  observed_time: 2026-05-06T09:10:00Z
  payload_summary: "repeats station fixture-east-17 online"
  citation_policy_ref: citation_policy/synthetic-public-summary@1
  redaction_policy_ref: redaction_policy/no-sensitive-fields@1
  provenance_status: :derivative_repetition

SourceObservation src-003:
  source_obs_id: source_obs/synthetic-bulletin-b/20260506T0920Z
  source_kind: :synthetic_public_bulletin
  source_ref: source/synthetic-bulletin-b
  captured_at: 2026-05-06T09:25:00Z
  observed_time: 2026-05-06T09:20:00Z
  payload_summary: "station fixture-east-17 status offline"
  citation_policy_ref: citation_policy/synthetic-public-summary@1
  redaction_policy_ref: redaction_policy/no-sensitive-fields@1
  provenance_status: :direct_synthetic_source
```

## Claim Chain

Initial direct claim:

```text
Claim claim-001:
  claim_id: claim/station-fixture-east-17/status-online/src-001
  subject_ref: station/fixture-east-17
  predicate: status
  object_value: online
  asserted_at: 2026-05-06T09:05:00Z
  valid_time: 2026-05-06T09:00:00Z
  claim_status: :asserted
  claim_kind: :source_claim
```

Repeated derivative claim:

```text
Claim claim-002:
  claim_id: claim/station-fixture-east-17/status-online/src-002-repeat
  subject_ref: station/fixture-east-17
  predicate: status
  object_value: online
  asserted_at: 2026-05-06T09:12:00Z
  valid_time: 2026-05-06T09:10:00Z
  claim_status: :asserted
  claim_kind: :repeated_claim
```

Contradicting direct claim:

```text
Claim claim-003:
  claim_id: claim/station-fixture-east-17/status-offline/src-003
  subject_ref: station/fixture-east-17
  predicate: status
  object_value: offline
  asserted_at: 2026-05-06T09:25:00Z
  valid_time: 2026-05-06T09:20:00Z
  claim_status: :asserted
  claim_kind: :source_claim
```

Analyst inference before contradiction:

```text
Claim claim-004:
  claim_id: claim/station-fixture-east-17/status-online/inference-initial
  subject_ref: station/fixture-east-17
  predicate: inferred_status
  object_value: online
  asserted_at: 2026-05-06T09:15:00Z
  valid_time: 2026-05-06T09:00:00Z..2026-05-06T09:15:00Z
  claim_status: :inferred
  claim_kind: :analyst_inference
```

Corrected claim after contradiction:

```text
Claim claim-005:
  claim_id: claim/station-fixture-east-17/status-conflicted/inference-corrected
  subject_ref: station/fixture-east-17
  predicate: assessed_status
  object_value: conflicted
  asserted_at: 2026-05-06T09:35:00Z
  valid_time: 2026-05-06T09:00:00Z..2026-05-06T09:35:00Z
  claim_status: :corrected
  claim_kind: :analyst_assessment
```

## Evidence Links

```text
EvidenceLink ev-001:
  source_ref: source_obs/synthetic-bulletin-a/20260506T0900Z
  target_ref: claim/station-fixture-east-17/status-online/src-001
  relation: :supports
  strength: :direct
  temporal_alignment: :same_observed_time

EvidenceLink ev-002:
  source_ref: source_obs/synthetic-social-repeat/20260506T0910Z
  target_ref: claim/station-fixture-east-17/status-online/src-002-repeat
  relation: :repeats
  strength: :derivative
  temporal_alignment: :later_repetition

EvidenceLink ev-003:
  source_ref: source_obs/synthetic-bulletin-b/20260506T0920Z
  target_ref: claim/station-fixture-east-17/status-offline/src-003
  relation: :supports
  strength: :direct
  temporal_alignment: :same_observed_time

EvidenceLink ev-004:
  source_ref: claim/station-fixture-east-17/status-online/src-001
  target_ref: claim/station-fixture-east-17/status-online/inference-initial
  relation: :supports_inference
  strength: :single_direct_source
  temporal_alignment: :within_analysis_window

EvidenceLink ev-005:
  source_ref: claim/station-fixture-east-17/status-offline/src-003
  target_ref: contradiction/station-fixture-east-17/status-online-vs-offline
  relation: :contradicts
  strength: :direct_conflict
  temporal_alignment: :overlapping_window
```

[D] `ev-002` is a repetition link, not independent corroboration.

## Confidence And Contradiction

Initial confidence:

```text
ConfidenceAssessment conf-001:
  target_ref: claim/station-fixture-east-17/status-online/inference-initial
  evidence_refs:
    - ev-001
    - ev-002
  confidence_label: :low_to_medium
  caveats:
    - one direct source
    - one derivative repetition
    - no independent corroboration
  assessed_at: 2026-05-06T09:15:00Z
```

Contradiction:

```text
ContradictionReport = {
  contradiction_id: contradiction/station-fixture-east-17/status-online-vs-offline
  claim_refs:
    - claim/station-fixture-east-17/status-online/src-001
    - claim/station-fixture-east-17/status-offline/src-003
  contradiction_kind: :mutually_exclusive_status
  conflicting_fields:
    - object_value
  temporal_overlap: 2026-05-06T09:00:00Z..2026-05-06T09:35:00Z
  status: :open
}
```

Corrected confidence:

```text
ConfidenceAssessment conf-002:
  target_ref: claim/station-fixture-east-17/status-conflicted/inference-corrected
  evidence_refs:
    - ev-001
    - ev-003
    - ev-005
  confidence_label: :high_conflict_detected
  caveats:
    - direct sources disagree
    - status cannot be resolved without newer independent evidence
  assessed_at: 2026-05-06T09:35:00Z
```

## Correction And Snapshot

```text
CorrectionReceipt = {
  receipt_id: correction/station-fixture-east-17/online-to-conflicted
  corrected_claim_ref: claim/station-fixture-east-17/status-online/inference-initial
  replacement_claim_ref: claim/station-fixture-east-17/status-conflicted/inference-corrected
  caused_by_ref: contradiction/station-fixture-east-17/status-online-vs-offline
  correction_reason: direct_source_contradiction
  corrected_at: 2026-05-06T09:35:00Z
  status: :corrected
}
```

```text
FactCheckSnapshot = {
  snapshot_id: factcheck/station-fixture-east-17/asof-20260506T093500Z
  scope_ref: station/fixture-east-17
  as_of: 2026-05-06T09:35:00Z
  included_claim_refs:
    - claim/station-fixture-east-17/status-online/src-001
    - claim/station-fixture-east-17/status-online/src-002-repeat
    - claim/station-fixture-east-17/status-offline/src-003
    - claim/station-fixture-east-17/status-conflicted/inference-corrected
  included_source_refs:
    - source_obs/synthetic-bulletin-a/20260506T0900Z
    - source_obs/synthetic-social-repeat/20260506T0910Z
    - source_obs/synthetic-bulletin-b/20260506T0920Z
  included_contradiction_refs:
    - contradiction/station-fixture-east-17/status-online-vs-offline
  confidence_refs:
    - conf-002
  correction_refs:
    - correction/station-fixture-east-17/online-to-conflicted
  citation_policy_ref: citation_policy/synthetic-public-summary@1
  redaction_policy_ref: redaction_policy/no-sensitive-fields@1
  status: :reproducible_snapshot
}
```

## Analyst Decision

```text
AnalystDecision = {
  decision_id: analyst_decision/station-fixture-east-17/report-conflicted
  analyst_ref: analyst/fixture-001
  snapshot_ref: factcheck/station-fixture-east-17/asof-20260506T093500Z
  decision: :report_conflicted_not_resolved
  rationale_refs:
    - contradiction/station-fixture-east-17/status-online-vs-offline
    - conf-002
  decided_at: 2026-05-06T09:40:00Z
  status: :recorded
}
```

Report output:

```text
Report = {
  report_id: report/station-fixture-east-17/status-asof-20260506T094000Z
  headline_claim_ref: claim/station-fixture-east-17/status-conflicted/inference-corrected
  snapshot_ref: factcheck/station-fixture-east-17/asof-20260506T093500Z
  analyst_decision_ref: analyst_decision/station-fixture-east-17/report-conflicted
  public_summary: "Synthetic sources conflict on station status as of 09:35 UTC."
  citation_policy_ref: citation_policy/synthetic-public-summary@1
  redaction_policy_ref: redaction_policy/no-sensitive-fields@1
}
```

## Negative Cases

### OSINT-1: Repetition Treated As Independent Evidence

Input:

```text
evidence_refs:
  - ev-001
  - ev-002
confidence_label: :high
reason: "two sources agree"
```

Expected:

```text
status: :blocked
diagnostic: evidence.repetition_not_independent_corroboration
```

### OSINT-2: Claim Without SourceObservation

Input:

```text
claim_kind: :source_claim
source_links: []
```

Expected:

```text
status: :blocked
diagnostic: claim.source_observation_missing
```

### OSINT-3: Temporal Validity Missing

Input:

```text
claim_id: claim/status-online/no-valid-time
valid_time: null
```

Expected:

```text
status: :blocked
diagnostic: claim.temporal_validity_missing
```

### OSINT-4: Contradiction Ignored In Report

Input:

```text
report_claim: station online
known_contradiction_ref: contradiction/station-fixture-east-17/status-online-vs-offline
correction_refs: []
```

Expected:

```text
status: :blocked
diagnostic: report.open_contradiction_not_disclosed
```

### OSINT-5: Citation Policy Missing

Input:

```text
factcheck_snapshot_ref: factcheck/missing-citation-policy
citation_policy_ref: null
```

Expected:

```text
status: :blocked
diagnostic: citation.policy_missing
```

## Overlap With Human-Agent And Simulation Lanes

Human-agent overlap:

- `ReviewProjection` and `FactCheckSnapshot` both need human-readable semantic
  surfaces.
- `MeaningDiff` and `CorrectionReceipt` both record semantically meaningful
  change, not just text edits.
- `AcceptanceReceipt` and `AnalystDecision` both require scoped authority and
  traceable rationale.

Simulation overlap:

- `ForecastObservation` and `CounterfactualObservation` are not
  `SourceObservation`.
- Model output can generate a claim candidate, but it cannot become trusted
  source evidence without explicit trust kind and validation.
- `ModelValidityReport` and `ConfidenceAssessment` both must separate
  reproducible computation from real-world truth.

## What Current Igniter-Lang Handles

- Observation packets and links can represent sources, claims, contradictions,
  corrections, reports, and analyst decisions.
- Explicit time already fits captured time, observed time, valid time, and
  as-of snapshot time.
- CORE / ESCAPE / OOF can block missing provenance, missing citation policy,
  and use of repeated claims as independent evidence.
- Human-agent receipts and simulation trust classes provide adjacent patterns
  for correction and trust boundaries.

## Where It Breaks Or Lacks Capability

- `Claim` is not yet a first-class semantic value with status, predicate,
  temporal validity, and evidence requirements.
- `EvidenceLink` strength and relation are not typed or checked.
- Confidence is not formally separated from truth.
- Contradiction detection requires equality/conflict rules over typed claim
  predicates.
- Citation and redaction policy are not yet required by observation/report
  types.
- Fact-check snapshots need reproducibility rules similar to SemanticImage but
  over claims/evidence instead of runtime state.

## Concrete Research Fixture Request

Please implement a standalone fixture proof:

```text
track_request: osint_fractal_traceability_fixture_v0
suggested_dir: igniter-lang/experiments/osint_fractal_traceability_fixture/
inputs:
  - three synthetic SourceObservation records
  - direct online Claim
  - repeated online Claim
  - direct offline Claim
  - initial analyst inference Claim
  - EvidenceLink records ev-001..ev-005
  - initial ConfidenceAssessment
  - ContradictionReport
  - corrected Claim
  - corrected ConfidenceAssessment
  - CorrectionReceipt
  - FactCheckSnapshot
  - AnalystDecision
  - Report
  - negative cases OSINT-1..OSINT-5
outputs:
  - golden evidence chain
  - golden contradiction report
  - golden correction receipt
  - golden fact-check snapshot
  - golden analyst decision
  - golden negative diagnostics
checker:
  - validates every source claim has SourceObservation link
  - validates repeated claim is not independent corroboration
  - validates temporal validity fields
  - validates contradiction appears in snapshot/report
  - validates correction links old claim, replacement claim, and contradiction
  - validates citation/redaction policy presence
safety:
  - synthetic public-source style facts only
  - no real sensitive data, targets, endpoints, credentials, private sources,
    or operational instructions
```

Proof acceptance:

- chain from source to report is reproducible;
- repeated claim is tracked but not upgraded to independent evidence;
- contradiction forces corrected assessment;
- report includes contradiction and correction links;
- temporal validity and citation/redaction policies are mandatory.

## Compiler/Grammar Expert Questions

1. Should `Claim` be a core semantic type, a stdlib type, or a contract shape
   over ordinary observations?
2. How should predicates be typed so contradictions can be detected without
   natural-language guessing?
3. Is `ConfidenceAssessment` a value, a report, or an observation over
   evidence links?
4. Should confidence be an enum, probability interval, ordinal label, or
   method-specific opaque value with required caveats?
5. What type rule prevents repeated/derivative claims from satisfying
   independent corroboration requirements?
6. Should `EvidenceLink.relation` and `strength` be closed enums in v0 or
   schema-defined vocabularies?
7. How should citation/redaction policy be required: observation envelope
   field, report field, or both?
8. Can `FactCheckSnapshot` reuse SemanticImage/CompatibilityReport concepts,
   or does it need a distinct reproducibility surface?

## Bridge Agent Candidates

- `ClaimTraceProfile` for source -> claim -> inference lineage.
- `EvidenceLinkProfile` with relation, strength, temporal alignment, citation,
  and redaction fields.
- `ConfidenceAssessmentProfile` that separates confidence method, caveats, and
  evidence refs from truth status.
- `ContradictionReportProfile` for conflicting claim refs, fields, temporal
  overlap, and resolution status.
- `FactCheckSnapshotProfile` for reproducible report bundles.
- `CorrectionReceiptProfile` for claim replacement, cause, analyst/reviewer,
  and report update links.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/osint-fractal-traceability-pressure-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Opened the OSINT-like fractal traceability lane with a fully synthetic
  public-source style scenario.
- Defined Claim, SourceObservation, EvidenceLink, ConfidenceAssessment,
  ContradictionReport, FactCheckSnapshot, AnalystDecision, and
  CorrectionReceipt.
- Fixed the guardrail that repeated claims are not independent trusted
  evidence.
- Required temporal validity plus citation/redaction policy in snapshots and
  reports.

[R] Recommendations:
- Research Agent should implement the fixture and checker for source->claim->
  contradiction->correction->report lineage.
- Compiler/Grammar Expert should formalize Claim/Evidence/Confidence typing
  and contradiction rules over typed predicates.
- Bridge Agent should draft fact-check snapshot, contradiction, confidence,
  and correction receipt bridge profiles.

[S] Signals:
- OSINT-like pressure generalizes observation evidence into claim lifecycle.
- Confidence is not truth; it is an assessment over evidence and caveats.
- Fact-check snapshots resemble SemanticImage for claims/evidence.
- Citation/redaction policy must travel with public reports.

[T] Tests / Proofs:
- Not run; documentation/specification slice only.
- Requested Research Agent proof:
  `igniter-lang/experiments/osint_fractal_traceability_fixture/`.

[Files] Changed:
- igniter-lang/docs/tracks/osint-fractal-traceability-pressure-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Is Claim a core semantic type or a stdlib contract shape?
- How much predicate typing is needed for contradiction detection?
- Should confidence be ordinal, probabilistic, or method-specific?
- Can FactCheckSnapshot reuse SemanticImage concepts?

[X] Rejected:
- Treating repeated claims as independent evidence.
- Trusting claims without SourceObservation links.
- Publishing reports that omit known contradictions or correction receipts.
- Using real sensitive data or operational targets in this lane.

[Next] Proposed next slice:
- Research Agent: implement `osint_fractal_traceability_fixture_v0`.
- Compiler/Grammar Expert: formalize Claim/Evidence/Confidence typing.
- Bridge Agent: draft fact-check and correction receipt bridge candidates.
```
