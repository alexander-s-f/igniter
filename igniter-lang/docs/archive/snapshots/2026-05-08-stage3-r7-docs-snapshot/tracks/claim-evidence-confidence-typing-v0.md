# Track: Claim Evidence Confidence Typing v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/claim-evidence-confidence-typing-v0
Status: done
Date: 2026-05-06
Pressure source: OSINT/world-modeling contracts, fact-check fixtures

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — fixture acceptance criteria in §Part 7.
- `[Igniter-Lang Bridge Agent]` — provenance and contradiction link shapes in §Part 8.

---

## Part 1: Claim — Core Semantic Type

**[D] `Claim` is a stdlib type (not a contract shape, not a trait).** It is a typed predicate about the world with provenance.

```text
Claim = {
  claim_id:      String              -- stable, content-addressed id
  subject_ref:   String              -- what the claim is about (entity id or URI)
  predicate:     Symbol              -- :located_at, :affiliated_with, :role, :active_since, etc.
  value:         Any                 -- the asserted value
  as_of:         Timestamp           -- temporal scope of the claim
  source_obs:    Collection[ObsId]   -- observations that assert this claim (>= 1)
  provenance:    SourceProvenance
  trust_class:   TrustClass          -- from observation-trust-classes-v0
  negated:       Bool                -- true = "claim asserts this is NOT the case"
}
lifecycle: :durable | :window (depends on as_of scope)
```

**[D] A Claim without at least one `source_obs` is OOF-CE1.** There is no sourceless claim in the type system.

**[D] `claim_id` is a content hash of `(subject_ref, predicate, value, as_of)`.** Two claims with identical fields but different sources share a `claim_id`. This is intentional: same claim, different provenance.

---

## Part 2: SourceProvenance Classes

**[D] Five provenance classes. They are not interchangeable for corroboration purposes.**

```text
SourceProvenance =
  | DirectSource    { url_ref: String, accessed_at: Timestamp, media_kind: Symbol }
  | DerivativeRepetition { original_ref: ObsId, derived_via: String }
  | Summary         { summarized_refs: Collection[ObsId], model_ref: String | nil }
  | ModelOutput     { model_ref: String, prompt_hash: String | nil, temperature: Float | nil }
  | Unknown         { note: String }

DirectSource:
  The claim was read directly from a primary source at access time.
  Qualifies as independent corroboration.

DerivativeRepetition:
  The claim was re-stated from another observation (article republication,
  wire-service syndication, social media share).
  Does NOT qualify as independent corroboration (OOF-CE2).

Summary:
  The claim was extracted from a summary of other observations.
  Does NOT qualify as independent corroboration unless all summarized_refs
  are DirectSource and originate from independent primary sources.

ModelOutput:
  The claim was produced by an AI/ML model (LLM, classifier, NER system).
  Does NOT qualify as independent corroboration.
  trust_class must be :synthetic or :forecast.

Unknown:
  Provenance cannot be established.
  Does NOT qualify as any corroboration.
  OOF-CE3 if used in a fact-check context requiring known provenance.
```

---

## Part 3: EvidenceLink Vocabulary

```text
EvidenceLink = {
  rel:      EvidenceLinkRel
  ref:      ObsId           -- the supporting or conflicting observation
  strength: EvidenceStrength
  note:     String | nil
}

EvidenceLinkRel =
  | :supports        -- observation supports the claim
  | :contradicts     -- observation contradicts the claim
  | :corroborates    -- observation independently confirms the claim
  | :contextualizes  -- observation provides context (not direct support)
  | :supersedes      -- observation replaces an earlier claim on the same subject/predicate
  | :corrections     -- observation corrects an identified error in the claim

EvidenceStrength =
  | :strong    -- direct, primary source, no known quality issues
  | :moderate  -- credible secondary source or derivative with known original
  | :weak      -- summary, model output, or low-quality source
  | :contested -- disputed by other evidence in the graph
```

**[D] `:corroborates` requires `SourceProvenance = DirectSource` and a different primary source than the corroborated claim.** A `DerivativeRepetition` using `:corroborates` is OOF-CE2.

---

## Part 4: ConfidenceAssessment

**[D] ConfidenceAssessment is a verdict about a Claim's reliability, not a truth assertion.**

```text
ConfidenceAssessment = Obs[:platform_observation, AssessmentRecord]
AssessmentRecord = {
  kind:            :confidence_assessment
  claim_id:        String
  claim_ref:       ObsId
  confidence_label: ConfidenceLabel
  method_ref:      String          -- which assessment method was applied
  evidence_refs:   Collection[EvidenceLink]
  caveats:         Collection[String]
  assessed_at:     Timestamp
  assessor_ref:    ObsId | nil     -- who or what assessed (nil = automated)
}
lifecycle: :window (assessments expire; world changes)

ConfidenceLabel =
  | :high          -- multiple strong, independent sources; no known contradictions
  | :medium        -- credible sources but not independently corroborated; or minor caveats
  | :low           -- weak provenance, model output only, or unresolved contradictions
  | :unverifiable  -- provenance is Unknown; cannot be assessed
  | :contested     -- active contradictions exist; no resolution
```

**[D] `confidence_label` is NOT a truth value.** `:high` does not mean true. `:low` does not mean false. This distinction is enforced at classifier level — OOF-CE4 governs misuse.

**[D] A ConfidenceAssessment with zero `evidence_refs` is OOF-CE5.** Every assessment must cite at least one EvidenceLink.

---

## Part 5: ContradictionReport

```text
ContradictionReport = Obs[:platform_observation, ContraRecord]
ContraRecord = {
  kind:               :contradiction_report
  subject_ref:        String
  predicate:          Symbol
  claim_a_ref:        ObsId           -- first conflicting claim
  claim_b_ref:        ObsId           -- second conflicting claim
  conflicting_fields: Collection[String]  -- which fields disagree
  temporal_overlap:   Bool            -- do their as_of ranges overlap?
  status:             ContraStatus
  resolution_ref:     ObsId | nil     -- CorrectionReceipt if resolved
}
lifecycle: :durable (contradiction evidence is permanent)

ContraStatus =
  | :open       -- contradiction detected; not yet resolved
  | :resolved   -- resolution_ref points to CorrectionReceipt
  | :deferred   -- acknowledged but resolution requires more evidence
  | :superseded -- one claim was superseded (not directly wrong)
```

**[D] An unresolved ContradictionReport with `status: :open` blocks `confidence_label: :high` for any claim involved.** The classifier enforces this at Pass 1.

**[D] A `CorrectionReceipt` is mandatory before a ContradictionReport may reach `status: :resolved`.**

```text
CorrectionReceipt = Obs[:platform_observation, CorrectionRecord]
CorrectionRecord = {
  kind:            :correction
  contradiction_ref: ObsId
  corrected_claim_ref: ObsId       -- the claim being superseded/retracted
  replacement_ref: ObsId | nil     -- new Claim if correction adds one
  authority_ref:   ObsId           -- who issued the correction
  reason:          String
}
lifecycle: :audit
links:
  { rel: :corrections, ref: corrected_claim_ref }
  { rel: :caused_by,   ref: contradiction_ref }
```

---

## Part 6: FactCheckSnapshot

```text
FactCheckSnapshot = Obs[:snapshot_observation, SnapRecord]
SnapRecord = {
  kind:             :fact_check_snapshot
  subject_ref:      String
  snapshot_id:      String           -- content-addressed
  claims:           Collection[ObsId]  -- all claims at snapshot time
  assessments:      Collection[ObsId]  -- all ConfidenceAssessments at snapshot time
  contradictions:   Collection[ObsId]  -- open ContradictionReports at snapshot time
  as_of:            Timestamp
  rule_version:     String
  source_summary_hash: String        -- hash(all claim_ids + assessment_ids)
}
lifecycle: :compacted
```

**[D] FactCheckSnapshot is reproducible** if `source_summary_hash` and `rule_version` are stable. A snapshot with the same hash under the same rule version must produce identical output — OOF-CE6 if it does not.

**[D] FactCheckSnapshot does NOT carry a ConfidenceLabel directly.** It is the audit surface over which downstream contracts may compute a label. Computing a label inside a snapshot is premature aggregation.

---

## Part 7: OOF Rules and SemanticIR Gates

### OOF Rules

```text
OOF-CE1: Sourceless claim.
  Claim.source_obs is empty.
  -> Compile error (Pass 1): at least one ObsId required.

OOF-CE2: Derivative repetition used as independent corroboration.
  EvidenceLink with rel: :corroborates and SourceProvenance = DerivativeRepetition.
  -> Classify error (Pass 0): :corroborates requires DirectSource provenance.

OOF-CE3: Unknown provenance in fact-check context.
  SourceProvenance = Unknown used where known provenance is required.
  -> Classify warning in general context; Classify error in audit fact-check context.

OOF-CE4: confidence_label used as truth value.
  A ConfidenceAssessment.confidence_label fed to a boolean compute node or policy check
  without an explicit truth_mapping contract.
  -> Classify error (Pass 1 type check): ConfidenceLabel is not Bool.

OOF-CE5: ConfidenceAssessment with zero evidence_refs.
  -> Compile error (Pass 1): evidence_refs must be non-empty.

OOF-CE6: FactCheckSnapshot non-reproducible.
  Two snapshots with equal source_summary_hash and rule_version produce different output.
  -> Runtime OOF: determinism violation. Emit SnapshotReproducibilityFailure obs.

OOF-CE7: Resolved contradiction missing CorrectionReceipt.
  ContradictionReport.status = :resolved but resolution_ref is nil.
  -> Compile error (Pass 1): resolution_ref required when status is :resolved.

OOF-CE8: High confidence with open contradiction.
  ConfidenceAssessment.confidence_label = :high when any evidence_ref
  links to a claim that has an open ContradictionReport.
  -> Classify error (Pass 1): :high requires no open contradictions.
```

### SemanticIR Gates

```text
G-CE1: Claim.source_obs must be non-empty (>= 1 ObsId).
G-CE2: ConfidenceAssessment.evidence_refs must be non-empty.
G-CE3: ContradictionReport.resolution_ref must be present when status = :resolved.
G-CE4: :corroborates EvidenceLink must carry DirectSource provenance.
G-CE5: ConfidenceLabel must not be used as a Bool in compute or policy nodes.
G-CE6: FactCheckSnapshot.source_summary_hash must be a deterministic function of claims + assessments.
```

---

## Part 8: Research Agent Acceptance Criteria

Reference fixture: `osint-fact-check-fixture-v0`

```text
Positive path:
  1. Three Claim observations on same (subject, predicate):
     Claim-A: DirectSource from publication-1
     Claim-B: DirectSource from publication-2  (independent)
     Claim-C: DerivativeRepetition of Claim-A from publication-3
  2. EvidenceLinks:
     Claim-B :corroborates Claim-A (strength: :strong, DirectSource) -> valid
     Claim-C :corroborates Claim-A (strength: :moderate, DerivativeRepetition) -> OOF-CE2
  3. ConfidenceAssessment for Claim-A:
     confidence_label: :high (two DirectSource, no contradictions)
     evidence_refs: [Claim-A link, Claim-B link]
  4. ContradictionReport: Claim-A vs Claim-D (conflicting :located_at value)
     status: :open -> ConfidenceAssessment drops to :contested (OOF-CE8 if :high)
  5. CorrectionReceipt: Claim-D retracted, authority confirmed.
  6. ContradictionReport updated to :resolved with resolution_ref.
  7. FactCheckSnapshot: captures all claims, assessments, contradiction (now resolved).

Negative cases:
  N1: Sourceless Claim -> OOF-CE1.
  N2: DerivativeRepetition claim used as :corroborates -> OOF-CE2.
  N3: ConfidenceLabel :high fed to bool policy check -> OOF-CE4.
  N4: ConfidenceAssessment with empty evidence_refs -> OOF-CE5.
  N5: ContradictionReport.status = :resolved, resolution_ref nil -> OOF-CE7.
  N6: ConfidenceLabel :high with open contradiction -> OOF-CE8.
```

## Part 9: Bridge Implications

```text
BR-Claim: Claim.source_obs and provenance class must be forwarded in all
  adapter observation packets. Stripping source_obs -> OOF-CE1 downstream.

BR-Contradiction: ContradictionReport packets must be routed to review surfaces
  only. They must NOT be consumed by action authorization endpoints.
  (Same rule as ComparisonReport from observation-trust-classes-v0.)

BR-ConfidenceLabel: ConfidenceLabel must be serialized as a Symbol, not a Float
  or Integer score. No implicit numeric mapping. Downstream dashboards that
  require a score must apply their own truth_mapping contract explicitly.
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/claim-evidence-confidence-typing-v0
Status: done

[D] Decisions:
- Claim is a stdlib type (not a contract shape, not a trait-bound type).
  claim_id is content-addressed over (subject_ref, predicate, value, as_of).
- Five SourceProvenance classes. Only DirectSource qualifies as independent corroboration.
  DerivativeRepetition used as :corroborates -> OOF-CE2.
- EvidenceLinkRel vocabulary: supports, contradicts, corroborates, contextualizes,
  supersedes, corrections.
- ConfidenceLabel is NOT a truth value. ConfidenceLabel used as Bool -> OOF-CE4.
- ConfidenceAssessment requires >= 1 evidence_ref (OOF-CE5).
- :high confidence label blocked when any linked claim has an open ContradictionReport (OOF-CE8).
- ContradictionReport: status :resolved requires CorrectionReceipt in resolution_ref (OOF-CE7).
- FactCheckSnapshot: lifecycle :compacted; does NOT carry a ConfidenceLabel directly.
  Reproducible if source_summary_hash and rule_version are stable.
- 8 OOF rules: OOF-CE1..8. 6 SemanticIR gates: G-CE1..6.

[Files] Changed:
- igniter-lang/docs/tracks/claim-evidence-confidence-typing-v0.md [NEW]
- igniter-lang/docs/README.md  [updated]
- igniter-lang/docs/agent-motion.md  [updated]

[Next]:
- [Research Agent]: osint-fact-check-fixture-v0
  Implement per §Part 8 criteria.
- [Compiler/Grammar Expert]: claim-grammar-v0
  Add Claim, ConfidenceAssessment, ContradictionReport as recognized type names
  in the grammar. Define EvidenceLinkRel as a Symbol enum in stdlib.
```
