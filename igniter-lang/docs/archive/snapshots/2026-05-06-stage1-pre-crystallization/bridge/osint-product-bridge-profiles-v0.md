# OSINT Product Bridge Profiles v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `osint-product-bridge-profiles-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Applied Pressure Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Purpose

Map the lawful personal/business OSINT assistant product pressure into
metadata-only bridge profiles for future `igniter-contracts` verification
metadata.

This profile doc is not a product runtime, collector, crawler, platform UI,
external action system, or real OSINT ingestion plan.

---

## Source Signals

Approved source signals:

- `tracks/personal-osint-assistant-product-pressure-v0.md`
- `tracks/personal-osint-assistant-product-fixture-v0.md`
- `tracks/osint-fractal-traceability-pressure-v0.md`
- `tracks/osint-fractal-traceability-fixture-v0.md`
- `tracks/claim-evidence-confidence-typing-v0.md`
- `bridge/osint-claim-factcheck-correction-bridge-profile-v0.md`
- `experiments/personal_osint_assistant_product_fixture/personal_osint_assistant_product_fixture.rb`

Current horizon:

```text
watchlist
  -> source observations
  -> claims / evidence links
  -> contradiction / correction / fact-check snapshot
  -> brief / alert / drift / timeline / audit report
  -> human review only
```

All public/user-visible outputs must carry evidence refs, citation policy,
redaction policy, temporal scope, and report-only semantics.

Executable proof signal:

```text
PASS personal_osint_assistant_product_fixture
brief: sections=contradiction_alerts,priority_changes,reputation_drift,source_reliability_changes,unresolved_claims evidence_required=true
alert: claims=2 evidence=3 action=review_sources
drift: window=2026-05-06T00:00:00Z..2026-05-06T18:00:00Z polarity=mild_negative
reliability: direct=2 derivative=2 corrections=1
audit: corrections=1 evidence=5 status=audit_ready_synthetic
```

---

## Common Profile Envelope

Every profile entry should fit this envelope:

```json
{
  "profile": "watchlist_profile_v0",
  "profile_version": "v0",
  "profile_kind": "WatchlistProfile",
  "subject_refs": ["redacted:vendor/fixture-payments"],
  "temporal_scope": {
    "as_of": "2026-05-06T09:40:00Z",
    "valid_from": "2026-05-06T00:00:00Z",
    "valid_to": "2026-05-07T00:00:00Z",
    "window_ref": "time_window/fixture-daily-20260506"
  },
  "evidence_refs": ["source_obs/vendor-status-note/20260506T1200Z"],
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "execution_authorized": false,
    "provider_call_authorized": false,
    "real_data_export_authorized": false,
    "external_action_authorized": false
  }
}
```

[D] `evidence_refs` must be non-empty for emitted brief, alert, drift,
reliability, timeline, report, and safe-action policy entries. A watchlist may
carry setup evidence such as user acceptance, policy receipt, or fixture
configuration refs; it is still not executable.

---

## VerificationReport Carrier Shape

Recommended first package carrier, after Architect approval:

```ruby
metadata: {
  custom_sections: {
    osint_product_profiles: [
      {
        profile: "watchlist_profile_v0",
        profile_kind: "WatchlistProfile",
        payload: { "...": "..." }
      }
    ]
  },
  redaction_policy: {
    profile: "public_metadata_v0",
    raw_ref_export: false,
    hash_source_refs: true,
    redacted_ref_kinds: [
      "owner",
      "subject",
      "person",
      "company",
      "source",
      "analyst",
      "trace"
    ]
  },
  semantics: {
    report_only: true,
    runtime_enforced: false,
    execution_authorized: false,
    provider_call_authorized: false,
    real_data_export_authorized: false,
    readiness_enforced: false,
    ledger_core: false
  }
}
```

Expected `carrier_manifest` shape:

```json
{
  "sections": [
    {
      "section_name": "osint_product_profiles",
      "count": 8,
      "profile_names": [
        "watchlist_profile_v0",
        "daily_brief_profile_v0",
        "evidence_linked_alert_profile_v0",
        "reputation_drift_report_profile_v0",
        "source_reliability_view_profile_v0",
        "claim_timeline_profile_v0",
        "audit_ready_report_profile_v0",
        "agent_safe_action_policy_profile_v0"
      ],
      "custom": true,
      "report_only": true,
      "runtime_enforced": false,
      "raw_ref_export": false
    }
  ]
}
```

[D] Use `custom_sections.osint_product_profiles` first. Do not add OSINT product
profiles to known carrier sections until the Architect approves a package
naming slice.

---

## JSON Profile Examples

### WatchlistProfile

```json
{
  "profile": "watchlist_profile_v0",
  "profile_kind": "WatchlistProfile",
  "watchlist_ref": "watchlist/personal-osint/fixture-acme-payments@1",
  "owner_ref": "redacted:user/fixture-owner-001",
  "subject_refs": ["redacted:brand/fixture-acme", "redacted:vendor/fixture-payments"],
  "collection_policy_ref": "collection_policy/lawful-public-synthetic@1",
  "alert_policy_ref": "alert_policy/evidence-linked-human-review@1",
  "safe_action_policy_ref": "safe_action_policy/no-private-intrusion-no-external-action@1",
  "temporal_scope": {
    "as_of": "2026-05-06T18:00:00Z",
    "valid_from": "2026-05-06T00:00:00Z",
    "valid_to": "2026-05-06T18:00:00Z"
  },
  "evidence_refs": ["watchlist/personal-osint/fixture-acme-payments@1"],
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "report_only": true,
  "runtime_enforced": false
}
```

### DailyBriefProfile

```json
{
  "profile": "daily_brief_profile_v0",
  "profile_kind": "DailyBriefProfile",
  "brief_ref": "daily_brief/personal-osint/20260506",
  "owner_ref": "redacted:user/fixture-owner-001",
  "watchlist_refs": ["watchlist/personal-osint/fixture-acme-payments@1"],
  "sections": {
    "priority_changes": ["claim/vendor-payments/api-v2-deprecation/corrected"],
    "contradiction_alerts": ["contradiction_alert/vendor-payments/api-v2-deprecation-date"],
    "reputation_drift": ["reputation_drift/vendor-payments/reliability/20260506"],
    "source_reliability_changes": ["source_reliability/vendor-payments/20260506"],
    "unresolved_claims": ["claim/vendor-payments/payment-latency/repeated"]
  },
  "snapshot_refs": ["factcheck/vendor-payments/asof-20260506T180000Z"],
  "temporal_scope": {
    "as_of": "2026-05-06T18:00:00Z",
    "window_ref": "time_window/daily/2026-05-06"
  },
  "evidence_refs": [
    "evidence_link/product-ev-001",
    "evidence_link/product-ev-005"
  ],
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "report_only": true,
  "runtime_enforced": false
}
```

### EvidenceLinkedAlertProfile

```json
{
  "profile": "evidence_linked_alert_profile_v0",
  "profile_kind": "EvidenceLinkedAlertProfile",
  "alert_ref": "contradiction_alert/vendor-payments/api-v2-deprecation-date",
  "alert_kind": "contradiction_detected",
  "watchlist_ref": "watchlist/personal-osint/fixture-acme-payments@1",
  "subject_ref": "redacted:vendor/fixture-payments",
  "headline_claim_ref": "claim/vendor-payments/api-v2-deprecation/corrected",
  "snapshot_ref": "factcheck/vendor-payments/asof-20260506T180000Z",
  "confidence_ref": "confidence/vendor-payments/deprecation-date/direct-source-with-caveat",
  "contradiction_refs": ["contradiction/vendor-payments/api-v2-deprecation-date"],
  "safe_action_policy_ref": "safe_action_policy/no-private-intrusion-no-external-action@1",
  "recommended_safe_action": "review_sources",
  "status": "ready_for_human_review",
  "temporal_scope": {
    "as_of": "2026-05-06T18:00:00Z",
    "valid_from": "2026-05-06T10:05:00Z"
  },
  "evidence_refs": [
    "evidence_link/product-ev-001",
    "evidence_link/product-ev-002",
    "evidence_link/product-ev-005"
  ],
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "report_only": true,
  "runtime_enforced": false
}
```

### ReputationDriftReportProfile

```json
{
  "profile": "reputation_drift_report_profile_v0",
  "profile_kind": "ReputationDriftReportProfile",
  "report_ref": "reputation_drift/vendor-payments/reliability/20260506",
  "subject_ref": "redacted:vendor/fixture-payments",
  "baseline_snapshot_ref": "factcheck/vendor-payments/baseline-previous-day",
  "current_snapshot_ref": "factcheck/vendor-payments/asof-20260506T180000Z",
  "signal_deltas": [
    {
      "signal_kind": "service_reliability",
      "polarity": "mild_negative",
      "delta": "latency_signal_observed",
      "caveat": "evidence-limited and not independently confirmed"
    }
  ],
  "temporal_scope": {
    "as_of": "2026-05-06T18:00:00Z",
    "valid_from": "2026-05-06T00:00:00Z",
    "valid_to": "2026-05-06T18:00:00Z"
  },
  "evidence_refs": ["evidence_link/product-ev-003", "evidence_link/product-ev-004"],
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "report_only": true,
  "runtime_enforced": false
}
```

### SourceReliabilityViewProfile

```json
{
  "profile": "source_reliability_view_profile_v0",
  "profile_kind": "SourceReliabilityViewProfile",
  "view_ref": "source_reliability/vendor-payments/20260506",
  "subject_ref": "redacted:vendor/fixture-payments",
  "source_refs": [
    "redacted:source/synthetic-vendor-changelog",
    "redacted:source/synthetic-derivative-blog",
    "redacted:source/synthetic-status-note",
    "redacted:source/synthetic-community-repeat"
  ],
  "reliability_signals": {
    "direct_source_count": 2,
    "derivative_repetition_count": 1,
    "correction_count": 1,
    "contradiction_count": 1,
    "citation_completeness": "complete"
  },
  "rules": {
    "derivative_repetition_counts_as_independent": false,
    "confidence_is_truth": false
  },
  "temporal_scope": {
    "as_of": "2026-05-06T18:00:00Z",
    "window_ref": "time_window/daily/2026-05-06"
  },
  "evidence_refs": [
    "source_obs/vendor-changelog/20260506T1000Z",
    "source_obs/derivative-blog/20260506T1030Z",
    "source_obs/vendor-status-note/20260506T1200Z",
    "source_obs/community-repeat/20260506T1230Z"
  ],
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "report_only": true,
  "runtime_enforced": false
}
```

### ClaimTimelineProfile

```json
{
  "profile": "claim_timeline_profile_v0",
  "profile_kind": "ClaimTimelineProfile",
  "timeline_ref": "claim_timeline/vendor-payments/api-v2-deprecation/20260506",
  "subject_ref": "redacted:vendor/fixture-payments",
  "predicate": "api_v2_deprecation_date",
  "claim_refs_ordered_by_valid_time": [
    "claim/vendor-payments/api-v2-deprecation/2026-06-01-repeat",
    "claim/vendor-payments/api-v2-deprecation/2026-07-01",
    "claim/vendor-payments/api-v2-deprecation/corrected"
  ],
  "correction_refs": ["correction/vendor-payments/api-v2-deprecation-date"],
  "contradiction_refs": ["contradiction/vendor-payments/api-v2-deprecation-date"],
  "temporal_scope": {
    "as_of": "2026-05-06T18:00:00Z",
    "valid_from": "2026-05-06T10:05:00Z",
    "valid_to": "2026-07-01T00:00:00Z"
  },
  "evidence_refs": [
    "evidence_link/product-ev-001",
    "evidence_link/product-ev-002",
    "evidence_link/product-ev-005"
  ],
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "report_only": true,
  "runtime_enforced": false
}
```

### AuditReadyReportProfile

```json
{
  "profile": "audit_ready_report_profile_v0",
  "profile_kind": "AuditReadyReportProfile",
  "report_ref": "audit_ready_report/vendor-payments/20260506",
  "snapshot_ref": "factcheck/vendor-payments/asof-20260506T180000Z",
  "analyst_or_user_decision_ref": "review_decision/vendor-payments/report-ready@20260506",
  "source_observation_refs": [
    "source_obs/vendor-changelog/20260506T1000Z",
    "source_obs/derivative-blog/20260506T1030Z",
    "source_obs/vendor-status-note/20260506T1200Z",
    "source_obs/community-repeat/20260506T1230Z"
  ],
  "evidence_link_refs": [
    "evidence_link/product-ev-001",
    "evidence_link/product-ev-002",
    "evidence_link/product-ev-003",
    "evidence_link/product-ev-004",
    "evidence_link/product-ev-005"
  ],
  "claim_timeline_refs": ["claim_timeline/vendor-payments/api-v2-deprecation/20260506"],
  "correction_refs": ["correction/vendor-payments/api-v2-deprecation-date"],
  "reproducibility_status": "audit_ready_synthetic",
  "temporal_scope": {
    "as_of": "2026-05-06T18:00:00Z",
    "window_ref": "time_window/daily/2026-05-06"
  },
  "evidence_refs": [
    "factcheck/vendor-payments/asof-20260506T180000Z",
    "correction/vendor-payments/api-v2-deprecation-date"
  ],
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "report_only": true,
  "runtime_enforced": false
}
```

### AgentSafeActionPolicyProfile

```json
{
  "profile": "agent_safe_action_policy_profile_v0",
  "profile_kind": "AgentSafeActionPolicyProfile",
  "policy_ref": "safe_action_policy/no-private-intrusion-no-external-action@1",
  "allowed_actions": [
    "group_claims",
    "detect_contradictions",
    "draft_evidence_linked_brief",
    "draft_alert_for_human_review",
    "draft_correction_receipt_for_human_review"
  ],
  "blocked_actions": [
    "contact_target",
    "publish_allegation",
    "trigger_business_action",
    "enrich_private_identity",
    "access_private_system",
    "bypass_access_control",
    "convert_confidence_to_truth"
  ],
  "required_before_external_action": [
    "human_review_receipt",
    "acceptance_receipt",
    "capability_gate_receipt"
  ],
  "temporal_scope": {
    "as_of": "2026-05-06T18:00:00Z",
    "valid_from": "2026-05-06T00:00:00Z"
  },
  "evidence_refs": ["safe_action_policy/no-private-intrusion-no-external-action@1"],
  "citation_policy_ref": "citation_policy/synthetic-public-summary@1",
  "redaction_policy_ref": "redaction_policy/no-sensitive-fields@1",
  "report_only": true,
  "runtime_enforced": false
}
```

---

## Diagnostics To Preserve

Product pressure diagnostics:

```text
alert.evidence_links_missing
source_reliability.derivative_not_independent
safety.private_target_intrusion_forbidden
reputation_drift.temporal_window_missing
report.correction_receipt_omitted
```

Inherited OSINT diagnostics:

```text
claim.source_observation_missing
evidence.repetition_not_independent_corroboration
report.open_contradiction_not_disclosed
correction.old_new_cause_links_missing
citation_redaction.policy_missing
```

---

## Package Adoption Notes

[R] First package adoption should use existing `VerificationReport` metadata
carrier behavior:

```text
VerificationReport#metadata[:custom_sections][:osint_product_profiles]
  -> carrier_manifest section
  -> profile_names
  -> report_only/runtime_enforced/raw_ref_export flags
```

Required package-local acceptance shape, if approved later:

- accepts `custom_sections.osint_product_profiles` as an array of hashes;
- manifests all eight `profile` names;
- preserves `metadata[:semantics][:report_only] == true`;
- preserves `metadata[:semantics][:runtime_enforced] == false`;
- rejects `raw_ref`, `raw_source_ref`, or `raw:` string prefixes;
- preserves `redaction_policy.raw_ref_export == false`;
- does not create public OSINT-specific runtime classes.

[R] Do not add known `MetadataCarrierManifest::KNOWN_SECTIONS` entries yet.
Use a custom section until the Architect decides whether product profile
sections deserve stable package names.

[R] Do not route these profiles through Ledger, readiness checks, provider
bridges, or operation receipts. Ledger may later store emitted metadata as a
`TBackend` adapter, but it must not define product semantics.

---

## Non-Authorization

[X] No real OSINT ingestion, collection runtime, crawler, scraper, connector,
provider bridge, browser automation, or external action.

[X] No doxxing, deanonymization, credential handling, private target intrusion,
access-control bypass, rate-limit evasion, exploit workflow, or operational
targeting.

[X] No alert, drift report, brief, or audit report may be represented without
evidence refs, citation policy, redaction policy, and temporal scope.

[X] No confidence-as-truth and no derivative repetition as independent
corroboration.

[X] No package edits in this slice.

---

## Architect Decision Required

[Q] Should OSINT product profiles remain under
`custom_sections.osint_product_profiles`, or should a future package slice add
stable known sections such as `brief_profiles`, `alert_profiles`, and
`audit_report_profiles`?

[Next] Package Agent may proceed only after explicit Architect approval, and
only on metadata carrier tests/docs for `igniter-contracts`; no product runtime,
external collection, external action, UI, or Ledger integration is authorized.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/osint-product-bridge-profiles-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Applied Pressure Agent | Bridge Agent

[D] Decisions:
- Drafted report-only profiles for Watchlist, DailyBrief,
  EvidenceLinkedAlert, ReputationDriftReport, SourceReliabilityView,
  ClaimTimeline, AuditReadyReport, and AgentSafeActionPolicy.
- Aligned adoption with VerificationReport custom metadata carrier shape:
  custom_sections.osint_product_profiles plus carrier_manifest.
- Required evidence refs, citation policy, redaction policy, temporal scope,
  report_only, and runtime_enforced false for every profile.

[R] Recommendations:
- First package adoption should use custom_sections.osint_product_profiles.
- Keep known carrier sections and standalone public classes blocked until
  Architect approves package naming.
- Keep product runtime, external collection, external actions, UI, provider
  bridges, readiness checks, and Ledger integration out of scope.

[S] Signals:
- Product profiles can be represented as opaque metadata without weakening the
  CORE / ESCAPE / OOF boundary.
- The current metadata carrier already has the right enforcement shape:
  report-only semantics, raw-ref rejection, and manifest profile names.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/personal_osint_assistant_product_fixture/personal_osint_assistant_product_fixture.rb
- Read-only inspected packages/igniter-contracts VerificationReport carrier
  shape for alignment.

[Files] Changed:
- igniter-lang/docs/bridge/osint-product-bridge-profiles-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should OSINT product profiles remain one custom section, or become stable
  known carrier sections after package review?

[X] Rejected:
- No package edits.
- No real OSINT ingestion, product runtime, external collection, external
  action, public OSINT-specific package classes, UI, provider bridge,
  readiness check, or Ledger-as-core.

[Next] Proposed next slice:
- Architect-reviewed igniter-contracts metadata carrier adoption note/test plan
  for custom_sections.osint_product_profiles.
```
