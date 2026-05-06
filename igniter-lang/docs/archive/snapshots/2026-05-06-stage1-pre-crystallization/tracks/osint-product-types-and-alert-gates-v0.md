# Track: OSINT Product Types and Alert Gates v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/osint-product-types-and-alert-gates-v0
Status: done
Date: 2026-05-06
Depends on: claim-evidence-confidence-typing-v0, observation-trust-classes-v0, meaning-diff-and-acceptance-semantics-v0

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — fixture acceptance criteria in §Part 6.
- `[Igniter-Lang Bridge Agent]` — profile shapes in §Part 7.

---

## Part 1: Core Product Types

### Watchlist

```text
Watchlist = {
  watchlist_id:     String
  name:             String
  subject_refs:     Collection[String]      -- entity ids or URIs being watched
  collection_policy_ref: ObsId             -- CollectionPolicy governing this list
  created_at:       Timestamp
  owner_ref:        ObsId
}
lifecycle: :durable
```

### CollectionPolicy

```text
CollectionPolicy = {
  policy_id:        String
  source_kinds:     Collection[SourceKind]  -- which source types are permitted
  max_staleness:    Duration                -- how old a source obs may be
  redaction_policy: RedactionPolicy
  citation_required: Bool                  -- must every alert cite a source? (always true in v0)
  safe_action_policy_ref: ObsId            -- SafeActionPolicy governing outbound actions
}
lifecycle: :durable

SourceKind = :web_page | :rss_feed | :api_endpoint | :document | :synthetic

RedactionPolicy = {
  pii_fields:       Collection[String]     -- field names to redact in output
  redaction_marker: String                 -- replacement string (e.g. "[REDACTED]")
  applies_to:       Collection[String]     -- which output types this applies to
}
```

**[D] `citation_required: true` is mandatory in v0 for all non-synthetic collection.** OOF-OS3 if citation_required is false in a non-synthetic CollectionPolicy.

### SourceReliability

```text
SourceReliability = {
  source_uri:       String
  reliability_label: ReliabilityLabel
  assessed_at:      Timestamp
  assessor_ref:     ObsId | nil
  basis:            Collection[ObsId]      -- evidence for the label
  valid_for:        Duration               -- freshness window
}
lifecycle: :window  (expires; sources change)

ReliabilityLabel =
  | :established    -- known, long-standing, verified publication
  | :credible       -- generally reliable but not established
  | :unverified     -- no reliability evidence available
  | :contested      -- disputed reliability (active disagreement)
  | :unreliable     -- known to produce low-quality or manipulated content
```

**[D] A SourceReliability without `basis` (empty Collection) is OOF-OS1 (evidence-less reliability label).**

---

## Part 2: Signal and Alert Types

### ReputationSignal

```text
ReputationSignal = Obs[:value_observation, SignalRecord]
SignalRecord = {
  kind:             :reputation_signal
  subject_ref:      String
  signal_type:      Symbol   -- :affiliation_change, :public_statement, :legal_action,
                             --  :role_change, :association, :media_mention
  claim_refs:       Collection[ObsId]    -- underlying Claim observations (>= 1)
  source_reliability_ref: ObsId         -- SourceReliability for the source
  as_of:            Timestamp
  temporal_window:  Duration             -- how long this signal is considered current
  trust_class:      TrustClass
}
lifecycle: :window  (signals expire; world moves on)
```

**[D] A ReputationSignal with empty `claim_refs` is OOF-OS2 (evidence-less signal).**

**[D] `temporal_window` is mandatory.** A signal without a declared temporal window has no defined expiry — OOF-OS4.

### EvidenceLinkedAlert

```text
EvidenceLinkedAlert = Obs[:value_observation, AlertRecord]
AlertRecord = {
  kind:             :evidence_linked_alert
  subject_ref:      String
  alert_type:       Symbol   -- :new_association, :claim_conflict, :reputation_drift,
                             --  :watchlist_hit, :policy_flag
  severity:         AlertSeverity
  actionability:    AlertActionability
  confidence:       ConfidenceLabel        -- from claim-evidence-confidence-typing-v0
  signal_refs:      Collection[ObsId]      -- ReputationSignals supporting this alert (>= 1)
  claim_refs:       Collection[ObsId]      -- Claim observations (>= 1)
  citation_refs:    Collection[CitationRef] -- source citations (>= 1 if citation_required)
  redacted:         Bool
  generated_at:     Timestamp
  valid_until:      Timestamp              -- explicit expiry required
}
lifecycle: :window

AlertSeverity       = :critical | :high | :medium | :low | :informational
AlertActionability  = :requires_review | :informational_only | :auto_safe | :blocked
```

**Four-way semantic separation:**

```text
confidence   -- reliability of the evidence (ConfidenceLabel; NOT a truth value)
severity     -- potential impact if the claim is accurate
truth        -- NOT represented; Igniter-Lang does not assert truth
actionability -- what may be done with this alert (gated by SafeActionPolicy)
```

**[D] An EvidenceLinkedAlert with empty `signal_refs` or empty `claim_refs` is OOF-OS2.**
**[D] An EvidenceLinkedAlert without `citation_refs` when `citation_required: true` is OOF-OS3.**
**[D] An EvidenceLinkedAlert without `valid_until` is OOF-OS4.**

---

## Part 3: Drift and Brief Types

### ReputationDriftReport

```text
ReputationDriftReport = Obs[:snapshot_observation, DriftRecord]
DriftRecord = {
  kind:             :reputation_drift_report
  subject_ref:      String
  baseline_ref:     ObsId           -- prior snapshot (ReputationSnapshot)
  current_ref:      ObsId           -- current snapshot
  drift_window:     Duration        -- time span covered by this report (mandatory)
  changed_signals:  Collection[SignalDelta]
  unchanged_signals: Collection[ObsId]
  contradiction_refs: Collection[ObsId]  -- open ContradictionReports in window
  drift_score:      Integer          -- 0..100 normalized; NOT a confidence label
  generated_at:     Timestamp
}
lifecycle: :compacted

SignalDelta = {
  signal_type: Symbol
  before_refs: Collection[ObsId]
  after_refs:  Collection[ObsId]
  delta_kind:  :appeared | :disappeared | :strengthened | :weakened | :contradicted
}
```

**[D] `drift_window` is mandatory on ReputationDriftReport.** OOF-OS5 if absent.
**[D] `drift_score` is NOT a ConfidenceLabel and NOT a truth value.** It is a normalized integer summary for display. OOF-CE4 (from claim-evidence-confidence-typing-v0) applies if it is used as Bool or as confidence in a policy check.

### DailyBrief

```text
DailyBrief = Obs[:snapshot_observation, BriefRecord]
BriefRecord = {
  kind:             :daily_brief
  brief_date:       Date
  watchlist_ref:    ObsId
  alerts:           Collection[ObsId]    -- EvidenceLinkedAlerts generated in window
  drift_reports:    Collection[ObsId]    -- ReputationDriftReports in window
  new_claims:       Collection[ObsId]    -- Claims first seen in window
  source_summary_hash: String            -- reproducibility surface
  generated_at:     Timestamp
  review_required:  Bool                 -- true if any alert is :requires_review
}
lifecycle: :compacted
```

**[D] A DailyBrief is review-only if `review_required: true`.** It may not authorize actions until an AcceptanceReceipt at `:fixture+` scope covers the brief (from meaning-diff-and-acceptance-semantics-v0).

---

## Part 4: Action Gates

### AgentActionLimit

```text
AgentActionLimit = {
  max_external_calls_per_brief: Integer  -- hard cap on outbound API calls
  max_alerts_per_subject:       Integer  -- per subject per day
  cooldown_window:              Duration -- minimum gap between alerts on same subject
  prohibited_action_kinds:      Collection[Symbol]
}
```

### SafeActionPolicy

```text
SafeActionPolicy = {
  policy_id:          String
  allowed_actions:    Collection[SafeActionKind]
  requires_review:    Collection[SafeActionKind]  -- must not execute without review
  prohibited:         Collection[SafeActionKind]
  agent_action_limit: AgentActionLimit
}

SafeActionKind =
  | :read_only_query        -- CORE; no external mutation
  | :citation_lookup        -- ESCAPE; read-only external fetch
  | :alert_emission         -- RuntimeObservation; no external effect
  | :external_notification  -- ESCAPE; must have AcceptanceReceipt at :staging+
  | :external_write         -- ESCAPE; OOF-OS6 without MeaningDiff + full acceptance
```

**[D] `:external_write` without a valid AcceptanceReceipt at `:staging+` scope covering the write action is OOF-OS6.**
**[D] `:external_notification` without AcceptanceReceipt at `:staging+` is OOF-OS6.**

---

## Part 5: OOF Rules and SemanticIR Gates

### OOF Rules

```text
OOF-OS1: Evidence-less SourceReliability label.
  SourceReliability.basis is empty.
  -> Compile error (Pass 1).

OOF-OS2: Evidence-less alert or signal.
  EvidenceLinkedAlert.signal_refs or claim_refs is empty.
  ReputationSignal.claim_refs is empty.
  -> Compile error (Pass 1).

OOF-OS3: Citation missing when citation_required.
  EvidenceLinkedAlert.citation_refs is empty and
  CollectionPolicy.citation_required is true.
  -> Compile error (Pass 1).

OOF-OS4: Missing temporal window or valid_until.
  ReputationSignal.temporal_window absent.
  EvidenceLinkedAlert.valid_until absent.
  -> Compile error (Pass 1).

OOF-OS5: ReputationDriftReport without drift_window.
  -> Compile error (Pass 1).

OOF-OS6: Unsafe external action without acceptance.
  SafeActionKind :external_write or :external_notification executed
  without AcceptanceReceipt at :staging+ scope.
  -> Runtime gate: blocked.

OOF-OS7: Derivative repetition used as independent corroboration.
  (Inherits OOF-CE2 from claim-evidence-confidence-typing-v0.)
  ReputationSignal or EvidenceLinkedAlert cites only
  DerivativeRepetition sources as corroborating evidence.
  -> Classify error (Pass 0).

OOF-OS8: Confidence used as truth in alert gate.
  EvidenceLinkedAlert.confidence (ConfidenceLabel) used as Bool
  in a policy check or action gate.
  -> Compile error (Pass 1). (Inherits OOF-CE4.)

OOF-OS9: Missing redaction on PII-containing alert.
  EvidenceLinkedAlert.redacted is false when RedactionPolicy.pii_fields
  are present in the alert payload.
  -> Compile error (Pass 1).
```

### SemanticIR Gates

```text
G-OS1: EvidenceLinkedAlert.signal_refs and claim_refs must be non-empty.
G-OS2: EvidenceLinkedAlert.valid_until must be present.
G-OS3: ReputationSignal.claim_refs must be non-empty.
G-OS4: ReputationSignal.temporal_window must be present.
G-OS5: ReputationDriftReport.drift_window must be present.
G-OS6: SourceReliability.basis must be non-empty.
G-OS7: ConfidenceLabel must not be used as Bool (G-CE5 inherited).
G-OS8: External action kinds require AcceptanceReceipt at :staging+ scope.
```

---

## Part 6: Research Agent Acceptance Criteria

Reference fixture: `osint-personal-assistant-fixture-v0`

```text
Positive path:
  1. Watchlist with two subject_refs.
  2. CollectionPolicy: citation_required: true, SourceKind: [:web_page, :rss_feed].
  3. SourceReliability for two sources (basis non-empty).
  4. Three Claim observations (DirectSource provenance, trust_class: :real).
  5. Two ReputationSignals, each citing >= 1 Claim, temporal_window declared.
  6. One ContradictionReport (Claim-A vs Claim-B on same predicate).
  7. EvidenceLinkedAlert:
       signal_refs: [signal-1, signal-2]
       claim_refs: [claim-1, claim-2]
       citation_refs: [source-1, source-2]
       confidence: :medium (not :high; contradiction is open)
       severity: :high, actionability: :requires_review
       valid_until: now + 7 days
  8. ReputationDriftReport: drift_window: 30 days, contradiction_refs: [ContradictionReport].
  9. DailyBrief: review_required: true (alert is :requires_review).

Negative cases:
  N1: EvidenceLinkedAlert with empty signal_refs -> OOF-OS2.
  N2: EvidenceLinkedAlert with no citation_refs -> OOF-OS3.
  N3: EvidenceLinkedAlert without valid_until -> OOF-OS4.
  N4: ConfidenceLabel :high with open contradiction -> OOF-CE8 (inherited).
  N5: DerivativeRepetition source used as :corroborates -> OOF-OS7/CE2.
  N6: confidence_label used as Bool gate -> OOF-OS8/CE4.
  N7: :external_notification without AcceptanceReceipt -> OOF-OS6.
```

---

## Part 7: Bridge Implications

```text
BR-OS1: EvidenceLinkedAlert packets must carry citation_refs in all adapter outputs.
  Stripping citations -> OOF-OS3 downstream.

BR-OS2: RedactionPolicy must be applied before any bridge adapter forwards
  alert packets to external surfaces (dashboards, APIs).
  Unredacted PII in outbound packet -> OOF-OS9.

BR-OS3: AlertActionability must be forwarded to action routing layer.
  Alerts with actionability: :blocked or :requires_review must not be
  auto-routed to external_write endpoints.

BR-OS4: SafeActionPolicy.prohibited must be enforced at the bridge routing layer.
  A bridge adapter may not route a prohibited action kind to any endpoint
  regardless of upstream instruction.
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/osint-product-types-and-alert-gates-v0
Status: done

[D] Decisions:
- Four-way semantic separation: confidence / severity / truth (absent) / actionability.
  Truth is not represented. Igniter-Lang does not assert truth — only evidence and confidence.
- EvidenceLinkedAlert requires signal_refs, claim_refs, citation_refs (all non-empty).
- ReputationSignal requires claim_refs and temporal_window.
- ReputationDriftReport requires drift_window.
- SourceReliability requires non-empty basis.
- drift_score is an Integer (0..100), NOT a ConfidenceLabel, NOT a Bool.
- citation_required: true is mandatory in v0 for non-synthetic collection (OOF-OS3).
- SafeActionPolicy gates :external_write and :external_notification behind
  AcceptanceReceipt at :staging+ (OOF-OS6).
- DailyBrief with review_required:true is review-only until accepted (from meaning-diff-v0).
- 9 OOF rules: OOF-OS1..9 (3 inherited from claim-evidence-confidence-typing-v0).
- 8 SemanticIR gates: G-OS1..8.

[Files] Changed:
- igniter-lang/docs/tracks/osint-product-types-and-alert-gates-v0.md [NEW]
- igniter-lang/docs/README.md  [updated]
- igniter-lang/docs/agent-motion.md  [updated]

[Next]:
- [Research Agent]: osint-personal-assistant-fixture-v0 per §Part 6.
- [Bridge Agent]: implement BR-OS1..4 adapter profile for alert routing.
- [Compiler/Grammar Expert]: osint-grammar-v0
  Add Watchlist, CollectionPolicy, EvidenceLinkedAlert, SafeActionPolicy as
  recognized stdlib type names. Add temporal_window and valid_until as
  recognized read/output modifiers.
```
