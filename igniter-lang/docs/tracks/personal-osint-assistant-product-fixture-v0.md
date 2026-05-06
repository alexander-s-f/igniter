# Track: Personal OSINT Assistant Product Fixture v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/personal-osint-assistant-product-fixture-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`, `[Package Agent]`
Artifacts:
- `igniter-lang/experiments/personal_osint_assistant_product_fixture/personal_osint_assistant_product_fixture.rb`
- `igniter-lang/docs/tracks/personal-osint-assistant-product-pressure-v0.md`
- `igniter-lang/docs/tracks/osint-fractal-traceability-fixture-v0.md`

---

## Frame

This slice turns the personal/business OSINT assistant product pressure into an
executable synthetic proof.

Safety boundary:

- synthetic public/open-source style facts only
- no real sensitive data, people, organizations, targets, endpoints,
  credentials, private sources, or operational instructions
- no credential theft, private intrusion, doxxing, evasion, abuse, or
  operational targeting
- alerts and reports must be evidence-linked and policy-bearing

---

## What The Fixture Models

Positive path:

```text
Watchlist
  -> SourceObservation x4
  -> Claim x5
  -> EvidenceLink x5
  -> SourceReliabilityView
  -> ContradictionReport
  -> CorrectionReceipt
  -> FactCheckSnapshot
  -> DailyBrief
  -> ContradictionAlert
  -> ReputationDriftReport
  -> AuditReadyReport
```

Core guardrails:

```text
alert_without_evidence != product output
derivative_repetition != independent corroboration
reputation_drift_without_window != valid report
audit_report_without_corrections != reproducible report
```

---

## Golden Output Summary

Daily brief:

```text
sections:
  - contradiction_alerts
  - priority_changes
  - reputation_drift
  - source_reliability_changes
  - unresolved_claims
evidence_required: true
priority_changes:
  - Vendor API v2 deprecation date corrected to 2026-07-01
```

Contradiction alert:

```text
conflicting_claim_refs:
  - claim/vendor-payments/api-v2-deprecation/2026-07-01
  - claim/vendor-payments/api-v2-deprecation/2026-06-01-repeat
evidence_refs:
  - evidence_link/product-ev-001
  - evidence_link/product-ev-002
  - evidence_link/product-ev-005
recommended_safe_action: review_sources
status: ready_for_human_review
```

Reputation drift:

```text
window: 2026-05-06T00:00:00Z..2026-05-06T18:00:00Z
signal_kind: service_reliability
polarity: mild_negative
independent_direct_source_count: 1
derivative_repetition_count: 1
caveats:
  - evidence-limited
  - no escalation without independent confirmation
```

Source reliability view:

```text
direct_source_count: 2
derivative_repetition_count: 2
correction_count: 1
contradiction_count: 1
citation_completeness: complete
derivative_counts_as_independent: false
```

Audit-ready report:

```text
snapshot_ref: factcheck/vendor-payments/asof-20260506T180000Z
correction_refs:
  - correction/vendor-payments/api-v2-deprecation-date
evidence_link_refs: 5
reproducibility_status: audit_ready_synthetic
```

All user-visible outputs carry:

```text
citation_policy_ref: citation_policy/synthetic-public-summary@1
redaction_policy_ref: redaction_policy/no-sensitive-fields@1
```

---

## Negative Cases

[D] Alert without evidence links blocks:

```text
diagnostic: alert.evidence_links_missing
```

[D] Derivative repetition cannot be independent corroboration:

```text
diagnostic: source_reliability.derivative_not_independent
```

[D] Private-target intrusion request blocks:

```text
diagnostic: safety.private_target_intrusion_forbidden
```

[D] Reputation drift requires temporal window:

```text
diagnostic: reputation_drift.temporal_window_missing
```

[D] Audit-ready report must include known correction receipt:

```text
diagnostic: report.correction_receipt_omitted
```

---

## Proof Output

```text
ruby igniter-lang/experiments/personal_osint_assistant_product_fixture/personal_osint_assistant_product_fixture.rb
```

Output:

```text
PASS personal_osint_assistant_product_fixture
positive.watchlist: ok
positive.reliability_view: ok
positive.contradiction_and_correction: ok
positive.daily_brief_evidence_linked: ok
positive.alert_evidence_linked: ok
positive.reputation_drift_windowed: ok
positive.audit_ready_report: ok
positive.public_outputs_have_policies: ok
negative.alert_without_evidence_blocked: ok
negative.derivative_corroboration_blocked: ok
negative.private_intrusion_blocked: ok
negative.drift_without_window_blocked: ok
negative.report_omits_correction_blocked: ok
safety.synthetic_only: ok
brief: sections=contradiction_alerts,priority_changes,reputation_drift,source_reliability_changes,unresolved_claims evidence_required=true
alert: claims=2 evidence=3 action=review_sources
drift: window=2026-05-06T00:00:00Z..2026-05-06T18:00:00Z polarity=mild_negative
reliability: direct=2 derivative=2 corrections=1
audit: corrections=1 evidence=5 status=audit_ready_synthetic
```

The proof also supports:

```text
ruby igniter-lang/experiments/personal_osint_assistant_product_fixture/personal_osint_assistant_product_fixture.rb --dump
```

to inspect generated synthetic observations.

---

## Gap Report

### Compiler / Grammar

[Next] Formalize `Watchlist` as a user artifact, projection horizon, contract,
or runtime-loaded configuration.

[Next] Type `SourceReliabilityView` as an aggregate over evidence history with
explicit direct-vs-derivative semantics.

[Next] Define `ReputationDriftReport` as a temporal comparison over snapshots
and reputation signals.

[Next] Make evidence-linked alert requirements type/classifier rules, not only
product policy.

[Q] How should alert severity, confidence, caveats, and safe action policy
compose?

### Bridge

[Next] Draft metadata-only bridge profiles for:

- `WatchlistProfile`
- `EvidenceLinkedAlertProfile`
- `DailyBriefProfile`
- `ReputationDriftReportProfile`
- `SourceReliabilityViewProfile`
- `ClaimTimelineProfile`
- `AuditReadyReportProfile`
- `AgentSafeActionPolicyProfile`

[Q] Bridge should make derivative repetition visually distinct from
corroboration in product UI/report surfaces.

### Package

[Next] Package work should treat this as a lawful, public-source-style
awareness product only. Any connector-backed collection must preserve
collection policy, citation/redaction policy, and safe action policy.

[Q] Which package layer owns enforcement for no private intrusion, no doxxing,
no evasion, and no external action without review?

---

## Boundaries

[X] Rejected: credential theft, phishing, private intrusion, doxxing, evasion,
abuse, operational targeting, or sensitive real-world data.

[X] Rejected: alerts without evidence links.

[X] Rejected: derivative repetition as independent corroboration.

[X] Rejected: reputation drift without a temporal window.

[X] Rejected: audit reports that omit known correction receipts.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/personal-osint-assistant-product-fixture-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent | Package Agent

[D] Decisions:
- Built a stdlib-only executable synthetic product fixture.
- Positive case emits Watchlist, SourceObservation, Claim, EvidenceLink,
  SourceReliabilityView, ContradictionReport, CorrectionReceipt,
  FactCheckSnapshot, DailyBrief, ContradictionAlert, ReputationDriftReport,
  and AuditReadyReport.
- Daily brief and contradiction alert are evidence-linked.
- Reputation drift is windowed and caveated.
- Source reliability separates direct sources from derivative repetitions.
- Audit-ready report includes snapshot, evidence links, contradiction,
  correction receipt, citation policy, and redaction policy.
- POSINT-1..POSINT-5 negative cases are covered.

[R] Recommendations:
- Compiler/Grammar: formalize Watchlist, SourceReliability, ReputationDrift,
  EvidenceLinkedAlert, and AgentActionLimit typing.
- Bridge: define product-facing profiles for daily brief, alerts, reliability
  view, drift, and audit-ready reports.
- Package: enforce safe collection and no external action without explicit
  human review/capability receipts.

[S] Signals:
- Product value depends on evidence links and correction receipts staying
  visible in user-facing summaries.
- Alert semantics are high-risk enough to deserve language-level rules.
- Citation/redaction policy must travel with all public outputs.

[T] Tests / Proofs:
- personal_osint_assistant_product_fixture.rb -> PASS

[Files] Changed:
- igniter-lang/experiments/personal_osint_assistant_product_fixture/personal_osint_assistant_product_fixture.rb
- igniter-lang/docs/tracks/personal-osint-assistant-product-fixture-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Watchlist as contract, projection horizon, user artifact, or runtime config?
- SourceReliability as aggregate report or source field?
- How should alert severity, confidence, and caveats compose?
- Which citation/redaction requirements belong in language vs bridge/package?

[X] Rejected:
- Private intrusion, doxxing, evasion, credential abuse, or operational
  targeting.
- Evidence-free alerts.
- Derivative repetition as corroboration.
- Reports omitting known corrections.

[Next] Proposed next slice:
- Compiler/Grammar Expert: Watchlist/Alert/SourceReliability and safe action
  type semantics.
- Bridge Agent: product profiles for daily brief, alert, drift, reliability,
  and audit-ready report.
- Package Agent: lawful connector/product boundary review.
```
