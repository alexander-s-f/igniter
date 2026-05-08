# OSINT Claim Factcheck Correction Bridge Profile v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `osint-claim-factcheck-correction-bridge-profile-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Applied Pressure Agent]`

---

## Purpose

Map the executable OSINT-like traceability fixture and claim/evidence typing
rules into metadata-only bridge profiles for future package diagnostics.

This note does not authorize package edits, platform UI, real OSINT ingestion,
real analyst workflow automation, or production decisions.

---

## Source Signals

Approved signals:

- `tracks/osint-fractal-traceability-fixture-v0.md`
- `tracks/osint-fractal-traceability-pressure-v0.md`
- `tracks/claim-evidence-confidence-typing-v0.md`
- `experiments/osint_fractal_traceability_fixture/osint_fractal_traceability_fixture.rb`

The proof surface is synthetic only:

```text
SourceObservation
  -> Claim
  -> EvidenceLink
  -> ConfidenceAssessment
  -> ContradictionReport
  -> CorrectionReceipt
  -> FactCheckSnapshot
  -> AnalystDecision
  -> Report
```

Core rules preserved:

```text
repeated claim is not independent evidence
confidence is not truth
source/report output requires citation and redaction policy
known contradictions and corrections must remain evidence-linked
```

---

## Bridge Claim

[D] Future package diagnostics may carry OSINT-like fact-check metadata as
report-only profiles when every claim, evidence link, assessment, contradiction,
correction, snapshot, and analyst decision is contract-addressable and linked to
observation evidence.

[D] The first bridge surface should be generic claim/evidence/fact-check
diagnostic metadata. It must not expose domain-specific public classes that
imply real OSINT collection, targeting, enforcement, or action authorization.

---

## JSON Profile Examples

### CitationPolicy

```json
{
  "kind": "CitationPolicy",
  "policy_ref": "citation_policy/synthetic-public-summary@1",
  "profile": "public_summary_only",
  "required_fields": ["source_obs_id", "captured_at", "observed_time", "source_kind"],
  "raw_source_export": false,
  "quote_policy": "short_excerpt_or_summary",
  "requires_redaction_policy_ref": true
}
```

### RedactionPolicy

```json
{
  "kind": "RedactionPolicy",
  "policy_ref": "redaction_policy/no-sensitive-fields@1",
  "redacted_ref_kinds": [
    "person_like_ref",
    "organization_like_ref",
    "target_like_ref",
    "endpoint_like_ref",
    "credential_like_ref",
    "private_source_ref",
    "analyst_ref",
    "trace_ref"
  ],
  "raw_ref_export": false,
  "stable_safe_ref_required": true
}
```

### SourceObservationProfile

```json
{
  "kind": "SourceObservationProfile",
  "source_obs_id": "source_obs/synthetic-bulletin-a/20260506T0900Z",
  "source_kind": "synthetic_public_bulletin",
  "source_ref": "redacted:source/synthetic-bulletin-a",
  "captured_at": "2026-05-06T09:05:00Z",
  "observed_time": "2026-05-06T09:00:00Z",
  "payload_summary": "station fixture-east-17 status online",
  "provenance_status": "direct_synthetic_source",
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "report_only": true
}
```

### ClaimTraceProfile

```json
{
  "kind": "ClaimTraceProfile",
  "claim_ref": "claim/station-fixture-east-17/status-online/src-001",
  "subject_ref": "redacted:station/fixture-east-17",
  "predicate": "status",
  "object_value": "online",
  "as_of": "2026-05-06T09:00:00Z",
  "claim_kind": "source_claim",
  "source_links": ["source_obs/synthetic-bulletin-a/20260506T0900Z"],
  "provenance_class": "DirectSource",
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "rules": {
    "source_links_required": true,
    "repeated_claim_counts_as_independent_evidence": false
  }
}
```

### EvidenceLinkProfile

```json
{
  "kind": "EvidenceLinkProfile",
  "evidence_ref": "evidence_link/ev-002",
  "source_ref": "claim/station-fixture-east-17/status-online/src-002-repeat",
  "target_ref": "claim/station-fixture-east-17/status-online/inference-initial",
  "relation": "supports",
  "strength": "weak",
  "source_provenance": "DerivativeRepetition",
  "temporal_alignment": "same_window",
  "counts_as_independent_evidence": false,
  "diagnostic_guard": "evidence.repetition_not_independent_corroboration"
}
```

### ConfidenceAssessmentProfile

```json
{
  "kind": "ConfidenceAssessmentProfile",
  "assessment_ref": "confidence/station-fixture-east-17/initial-online",
  "target_ref": "claim/station-fixture-east-17/status-online/inference-initial",
  "confidence_label": "low_to_medium",
  "method_ref": "method/synthetic-source-trace-v0",
  "evidence_refs": ["evidence_link/ev-001", "evidence_link/ev-002"],
  "independent_direct_evidence_refs": ["evidence_link/ev-001"],
  "derivative_evidence_refs": ["evidence_link/ev-002"],
  "caveats": [
    "one direct source",
    "one derivative repetition",
    "no independent corroboration"
  ],
  "truth_value": null,
  "confidence_is_truth": false,
  "assessed_at": "2026-05-06T09:30:00Z"
}
```

### ContradictionReportProfile

```json
{
  "kind": "ContradictionReportProfile",
  "contradiction_ref": "contradiction/station-fixture-east-17/status-online-vs-offline",
  "claim_refs": [
    "claim/station-fixture-east-17/status-online/src-001",
    "claim/station-fixture-east-17/status-offline/src-003"
  ],
  "contradiction_kind": "same_subject_predicate_conflicting_value",
  "conflicting_fields": ["object_value"],
  "temporal_overlap": true,
  "status": "open",
  "resolution_ref": null,
  "blocks_high_confidence": true
}
```

### CorrectionReceiptProfile

```json
{
  "kind": "CorrectionReceiptProfile",
  "receipt_ref": "correction/station-fixture-east-17/online-to-conflicted",
  "corrected_claim_ref": "claim/station-fixture-east-17/status-online/inference-initial",
  "replacement_claim_ref": "claim/station-fixture-east-17/status-conflicted/inference-corrected",
  "caused_by_ref": "contradiction/station-fixture-east-17/status-online-vs-offline",
  "correction_reason": "direct synthetic sources disagree",
  "corrected_at": "2026-05-06T09:35:00Z",
  "status": "corrected",
  "links": [
    { "rel": "corrections", "ref": "claim/station-fixture-east-17/status-online/inference-initial" },
    { "rel": "replaces", "ref": "claim/station-fixture-east-17/status-conflicted/inference-corrected" },
    { "rel": "caused_by", "ref": "contradiction/station-fixture-east-17/status-online-vs-offline" }
  ]
}
```

### FactCheckSnapshotProfile

```json
{
  "kind": "FactCheckSnapshotProfile",
  "snapshot_ref": "factcheck/station-fixture-east-17/asof-20260506T093500Z",
  "scope_ref": "scenario/synthetic-public-source-station-status@1",
  "as_of": "2026-05-06T09:35:00Z",
  "included_claim_refs": [
    "claim/station-fixture-east-17/status-online/src-001",
    "claim/station-fixture-east-17/status-online/src-002-repeat",
    "claim/station-fixture-east-17/status-offline/src-003",
    "claim/station-fixture-east-17/status-online/inference-initial",
    "claim/station-fixture-east-17/status-conflicted/inference-corrected"
  ],
  "included_evidence_refs": ["evidence_link/ev-001", "evidence_link/ev-002", "evidence_link/ev-003", "evidence_link/ev-004", "evidence_link/ev-005"],
  "included_contradiction_refs": ["contradiction/station-fixture-east-17/status-online-vs-offline"],
  "confidence_refs": [
    "confidence/station-fixture-east-17/initial-online",
    "confidence/station-fixture-east-17/corrected-conflicted"
  ],
  "correction_refs": ["correction/station-fixture-east-17/online-to-conflicted"],
  "source_summary_hash": "sha256:<fixture-derived>",
  "rule_version": "claim-evidence-confidence-v0",
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "status": "reproducible_snapshot",
  "carries_confidence_label_directly": false
}
```

### AnalystDecisionProfile

```json
{
  "kind": "AnalystDecisionProfile",
  "decision_ref": "analyst_decision/station-fixture-east-17/report-conflicted",
  "analyst_ref": "redacted:analyst/fixture-001",
  "snapshot_ref": "factcheck/station-fixture-east-17/asof-20260506T093500Z",
  "decision": "report_conflicted_not_resolved",
  "rationale_refs": [
    "contradiction/station-fixture-east-17/status-online-vs-offline",
    "confidence/station-fixture-east-17/corrected-conflicted"
  ],
  "decided_at": "2026-05-06T09:40:00Z",
  "review_authority_ref": "redacted:authority/synthetic-reviewer-role",
  "status": "recorded",
  "may_authorize_action": false
}
```

---

## Diagnostics To Preserve

Fixture diagnostics:

```text
claim.source_observation_missing
evidence.repetition_not_independent_corroboration
report.open_contradiction_not_disclosed
correction.old_new_cause_links_missing
citation_redaction.policy_missing
```

Typing gates:

```text
OOF-CE1 sourceless claim
OOF-CE2 derivative repetition used as independent corroboration
OOF-CE4 confidence_label used as truth or Bool
OOF-CE5 confidence assessment with zero evidence refs
OOF-CE6 non-reproducible fact-check snapshot
OOF-CE7 resolved contradiction missing CorrectionReceipt
OOF-CE8 high confidence with open contradiction
```

---

## Package Touchpoint Recommendation

[R] First package touchpoint, after explicit Architect approval:
`packages/igniter-contracts` generic report-only verification metadata.

Recommended shape:

```text
Igniter::Lang::VerificationReport
  + optional metadata section:
    claim_factcheck_profiles
```

Benefits:

- Keeps the first package surface close to existing report-only verification.
- Avoids public Spark/OSINT-specific classes.
- Allows package tests to assert metadata shape and evidence links without
  implementing compiler semantics or runtime enforcement.

Risks:

- A generic report section could be mistaken for validated truth if naming is
  too strong.
- Redaction/citation policy fields must be mandatory or the bridge weakens the
  fixture's safety boundary.
- The package must not infer independent corroboration from repeated claims.

[R] Do not make Ledger the first touchpoint. Ledger may later store these
profiles as a `TBackend` adapter, but it is not the language core and should
not define fact-check semantics.

[R] Do not make application readiness or platform UI the first touchpoint.
This profile is a diagnostic carrier, not an operator workflow.

---

## Non-Authorization Semantics

All profiles in this note carry:

```json
{
  "report_only": true,
  "runtime_enforced": false,
  "may_authorize_production_action": false,
  "may_trigger_external_collection": false,
  "may_identify_real_person_or_target": false
}
```

[X] Rejected: real sensitive data, real people, real organizations, targets,
endpoints, credentials, private sources, or operational instructions.

[X] Rejected: repeated claim as independent evidence.

[X] Rejected: confidence as truth.

[X] Rejected: production fact-check engine, crawler, OSINT collector,
enforcement workflow, or analyst automation.

[X] Rejected: package edits without explicit Architect approval.

---

## Architect Decision Required

[Q] Should the first package slice add these as a generic
`claim_factcheck_profiles` metadata section on `VerificationReport`, or should
it wait for a standalone immutable metadata class name approved by the
Architect?

[Next] Package Agent may start only after Architect approval, and only on a
metadata/report-only package slice with required evidence links, citation
policy refs, redaction policy refs, and explicit `runtime_enforced: false`.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/osint-claim-factcheck-correction-bridge-profile-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Applied Pressure Agent | Bridge Agent

[D] Decisions:
- Mapped OSINT fixture semantics into generic metadata-only report profiles.
- Preserved repeated-claim != independent evidence and confidence != truth.
- Required citation/redaction policy refs across source, claim, evidence,
  snapshot, report, and decision surfaces.

[R] Recommendations:
- First package touchpoint should be packages/igniter-contracts
  VerificationReport report-only metadata, after Architect approval.
- Keep Ledger as a possible future TBackend adapter, not a semantic owner.
- Keep UI/application readiness out of the first package slice.

[S] Signals:
- SourceObservationProfile, ClaimTraceProfile, EvidenceLinkProfile,
  ConfidenceAssessmentProfile, ContradictionReportProfile,
  FactCheckSnapshotProfile, AnalystDecisionProfile, and
  CorrectionReceiptProfile have compact JSON profile examples.
- The bridge explicitly blocks real OSINT collection, real sensitive data,
  production action, and confidence-as-truth semantics.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/osint_fractal_traceability_fixture/osint_fractal_traceability_fixture.rb

[Files] Changed:
- igniter-lang/docs/bridge/osint-claim-factcheck-correction-bridge-profile-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should the package section name be claim_factcheck_profiles, or should
  Architect require a standalone immutable metadata class first?

[X] Rejected:
- No package edits.
- No public OSINT-specific package classes.
- No migration/runtime engine, collector, UI workflow, analyst automation,
  Ledger-as-core, or production authorization behavior.

[Next] Proposed next slice:
- Architect-reviewed generic claim/fact-check VerificationReport metadata
  carrier plan for packages/igniter-contracts.
```
