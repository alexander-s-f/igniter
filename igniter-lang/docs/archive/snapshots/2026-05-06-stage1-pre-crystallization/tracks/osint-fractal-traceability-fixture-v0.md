# Track: OSINT Fractal Traceability Fixture v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/osint-fractal-traceability-fixture-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`
Artifacts:
- `igniter-lang/experiments/osint_fractal_traceability_fixture/osint_fractal_traceability_fixture.rb`
- `igniter-lang/docs/tracks/osint-fractal-traceability-pressure-v0.md`

---

## Frame

This slice turns OSINT-like fractal traceability pressure into an executable
synthetic proof.

Safety boundary:

- synthetic public-source style facts only
- no real sensitive data, people, organizations, targets, endpoints,
  credentials, private sources, or operational instructions
- repeated claims are not independent evidence
- report output must preserve contradiction and correction links

---

## What The Fixture Models

Positive path:

```text
SourceObservation x3
  -> direct online Claim
  -> repeated online Claim
  -> direct offline Claim
  -> initial analyst inference Claim
  -> EvidenceLink x5
  -> initial ConfidenceAssessment
  -> ContradictionReport
  -> corrected Claim
  -> corrected ConfidenceAssessment
  -> CorrectionReceipt
  -> FactCheckSnapshot
  -> AnalystDecision
  -> Report
```

Core guardrails:

```text
repeated_claim != trusted independent evidence
confidence_score != truth
report_without_correction_links != reproducible analysis
```

---

## Positive Result

Sources:

```text
direct synthetic sources: 2
derivative repetitions: 1
```

Initial confidence:

```text
target: claim/station-fixture-east-17/status-online/inference-initial
confidence_label: low_to_medium
independent_direct_evidence_refs:
  - evidence_link/ev-001
derivative_evidence_refs:
  - evidence_link/ev-002
caveats:
  - one direct source
  - one derivative repetition
  - no independent corroboration
```

Contradiction:

```text
claim_refs:
  - claim/station-fixture-east-17/status-online/src-001
  - claim/station-fixture-east-17/status-offline/src-003
conflicting_fields:
  - object_value
status: open
```

Correction:

```text
corrected_claim_ref: claim/station-fixture-east-17/status-online/inference-initial
replacement_claim_ref: claim/station-fixture-east-17/status-conflicted/inference-corrected
caused_by_ref: contradiction/station-fixture-east-17/status-online-vs-offline
status: corrected
```

Report:

```text
headline_claim_ref: claim/station-fixture-east-17/status-conflicted/inference-corrected
contradiction_refs:
  - contradiction/station-fixture-east-17/status-online-vs-offline
correction_refs:
  - correction/station-fixture-east-17/online-to-conflicted
citation_policy_ref: citation_policy/synthetic-public-summary@1
redaction_policy_ref: redaction_policy/no-sensitive-fields@1
```

---

## Negative Cases

[D] Source claims require `SourceObservation` links:

```text
diagnostic: claim.source_observation_missing
```

[D] Derivative repetition cannot be counted as independent corroboration:

```text
diagnostic: evidence.repetition_not_independent_corroboration
```

[D] Reports must disclose known open contradictions:

```text
diagnostic: report.open_contradiction_not_disclosed
```

[D] Corrections must link old claim, replacement claim, and cause:

```text
diagnostic: correction.old_new_cause_links_missing
```

[D] Citation and redaction policy are mandatory:

```text
diagnostic: citation_redaction.policy_missing
```

---

## Proof Output

```text
ruby igniter-lang/experiments/osint_fractal_traceability_fixture/osint_fractal_traceability_fixture.rb
```

Output:

```text
PASS osint_fractal_traceability_fixture
positive.source_observations: ok
positive.claim_chain: ok
positive.source_claims_link_sources: ok
positive.repetition_not_independent: ok
positive.initial_confidence_caveated: ok
positive.contradiction_report: ok
positive.corrected_claim_and_confidence: ok
positive.correction_links_old_new_cause: ok
positive.snapshot_reproducible: ok
positive.report_discloses_contradiction: ok
negative.claim_without_source_blocked: ok
negative.repetition_independence_blocked: ok
negative.contradiction_omitted_blocked: ok
negative.correction_links_missing_blocked: ok
negative.citation_redaction_missing_blocked: ok
safety.synthetic_only: ok
sources: direct=2 derivative=1
initial_confidence: low_to_medium independent=1 derivative=1
corrected_confidence: high_conflict_detected claim=claim/station-fixture-east-17/status-conflicted/inference-corrected
report: headline=claim/station-fixture-east-17/status-conflicted/inference-corrected contradictions=1 corrections=1
```

The proof also supports:

```text
ruby igniter-lang/experiments/osint_fractal_traceability_fixture/osint_fractal_traceability_fixture.rb --dump
```

to inspect generated synthetic observations.

---

## Gap Report

### Compiler / Grammar

[Next] Formalize `Claim` as a semantic value or stdlib contract shape with
predicate, temporal validity, evidence requirements, status, and source links.

[Next] Type `EvidenceLink.relation` and `EvidenceLink.strength`, including the
rule that `repeats/derivative` cannot satisfy independent corroboration.

[Next] Define contradiction rules over typed predicates so conflicts are not
natural-language guesses.

[Next] Require citation and redaction policies on source observations,
evidence links, snapshots, and reports.

[Q] Is `ConfidenceAssessment` a value, report, or observation over evidence?

[Q] Can `FactCheckSnapshot` reuse SemanticImage-style reproducibility concepts,
or does it need its own surface?

### Bridge

[Next] Draft metadata-only bridge profiles for:

- `ClaimTraceProfile`
- `EvidenceLinkProfile`
- `ConfidenceAssessmentProfile`
- `ContradictionReportProfile`
- `FactCheckSnapshotProfile`
- `CorrectionReceiptProfile`

[Q] Bridge should preserve derivative/repeat evidence visibly so report UIs do
not accidentally present repetition as corroboration.

---

## Boundaries

[X] Rejected: real sensitive data, real people, organizations, targets,
endpoints, credentials, private sources, or operational instructions.

[X] Rejected: repeated claims as independent evidence.

[X] Rejected: confidence as truth.

[X] Rejected: reports that omit known contradictions or correction receipts.

[X] Rejected: source/report output without citation and redaction policy.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/osint-fractal-traceability-fixture-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Built a stdlib-only executable synthetic fixture.
- Positive case emits three SourceObservation records, five Claims, five
  EvidenceLinks, initial and corrected ConfidenceAssessment records,
  ContradictionReport, CorrectionReceipt, FactCheckSnapshot, AnalystDecision,
  and Report.
- Repeated online claim is preserved as derivative evidence but not counted as
  independent corroboration.
- Contradiction forces corrected conflicted assessment.
- Report includes contradiction and correction refs plus citation/redaction
  policy.
- OSINT-1..OSINT-5 negative cases are covered.

[R] Recommendations:
- Compiler/Grammar: formalize Claim, EvidenceLink, ConfidenceAssessment,
  contradiction, and citation/redaction policy requirements.
- Bridge: define claim trace, confidence, contradiction, snapshot, and
  correction receipt bridge profiles.

[S] Signals:
- Confidence is assessment over evidence and caveats, not truth.
- FactCheckSnapshot is SemanticImage-like but over claims/evidence.
- Repetition must remain visible without becoming corroboration.

[T] Tests / Proofs:
- osint_fractal_traceability_fixture.rb -> PASS

[Files] Changed:
- igniter-lang/experiments/osint_fractal_traceability_fixture/osint_fractal_traceability_fixture.rb
- igniter-lang/docs/tracks/osint-fractal-traceability-fixture-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Is Claim core type or stdlib contract shape?
- How much predicate typing is needed for contradiction detection?
- Should confidence be ordinal, probabilistic, or method-specific?
- Can FactCheckSnapshot reuse SemanticImage concepts?

[X] Rejected:
- Real sensitive data or operational targets.
- Repeated claims as independent evidence.
- Reports omitting contradictions or corrections.
- Missing citation/redaction policy.

[Next] Proposed next slice:
- Compiler/Grammar Expert: Claim/Evidence/Confidence typing.
- Bridge Agent: fact-check snapshot and correction receipt profiles.
```
