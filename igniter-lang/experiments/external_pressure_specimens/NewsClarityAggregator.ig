-- Name: **NewsClarityAggregator**
-- Purpose: news aggregator + automatic fact-checking + review, which **brings clarity and honesty** to the information space.
--
-- The program is built as an **audited temporal system**:
--- Everything with evidence trailing
--- Misinformation risk scoring
--- Human override
--- Temporal History + BiHistory
--- Live news stream
--- Invariants and audited
--- Plus, somehow play up and illustrate our new research postulates and concepts.

--1. The model doesn't pretend to be the source of truth.
--2. Claims are extracted assertions, not facts.
--3. Evidence is separated from inference.
--4. Human override doesn't erase evidence, but adds append-only review.
--5. Stream/service loop is managed: heartbeat, checkpoint, cancellation.
--6. Effects are explicitly classified: observed / privileged.
--7. Receipt captures artifact_hash and link_manifest_hash.
--8. Honesty becomes part of the output.

--The most important line of the program, essentially:
--honesty_statement: "This report separates observation, inference, risk, uncertainty, and human review."
--This is the spirit of Igniter.

module Demo.NewsClarityAggregator

import stdlib.*
import stdlib.temporal.*
import stdlib.effects.*
import stdlib.review.*
import stdlib.streams.*

profile audited_truth_mesh {
  time: explicit
  lifecycle: :audit
  backend: :ledger
  consistency: :causal
  evidence: required

  effects: observed_only
  privileged: human_review_only
  recursion: fuel_bounded

  honesty: strict
  simulation_must_not_masquerade_as_reality: true
  no_hidden_consequences: true
}

type SourceRef {
  uri: String
  publisher: String
  captured_at: Timestamp
  trust_tier: Symbol
}

type Claim {
  text: String
  subject: String
  predicate: String
  object: String
}

type RealObservation {
  source: SourceRef
  captured_at: Timestamp
  content_hash: Hash
}

type ModelObservation {
  model: ModelRef
  prompt_hash: Hash
  output_hash: Hash
  confidence: Decimal[scale: 3]
  produced_at: Timestamp
}

type HumanReviewObservation {
  reviewer: HumanRef
  decision: Symbol
  reason: String
  decided_at: Timestamp
}

type EvidenceBundle {
  primary: Collection[RealObservation]
  corroborating: Collection[RealObservation]
  contradicting: Collection[RealObservation]
  model_observations: Collection[ModelObservation]
  human_reviews: Collection[HumanReviewObservation]
}

type RiskScore {
  value: Decimal[scale: 3]
  reasons: Collection[String]
}

type NewsArticle {
  id: String
  headline: String
  body: String
  published_at: Timestamp
  source: SourceRef
  claims: Collection[Claim]
  evidence: EvidenceBundle
}

type FactCheckResult {
  claim: Claim
  verdict: Symbol
  confidence: Decimal[scale: 3]
  risk: RiskScore
  explanation: String
  evidence: EvidenceBundle
}

type ClarityReport {
  article_id: String
  produced_at: Timestamp
  overall_risk: RiskScore
  clarity_score: Decimal[scale: 3]
  fact_checks: Collection[FactCheckResult]
  review_status: Symbol
  honesty_notes: Collection[String]
}

type HumanOverride {
  reviewer: HumanRef
  reason: String
  decision: Symbol
  decided_at: Timestamp
}

receipt ClarityDecisionReceipt {
  id by content_hash(report, evidence, artifact_hash, produced_at)

  report: ClarityReport
  evidence: EvidenceBundle
  human_override: Option[HumanOverride]

  artifact_hash: Hash
  link_manifest_hash: Hash
  produced_at: Timestamp

  honesty_statement: String
}

receipt ReviewReceipt {
  id by content_hash(report_id, reviewer, decision, decided_at)

  report_id: String
  reviewer: HumanRef
  decision: Symbol
  reason: String
  decided_at: Timestamp
}

store news_archive: History[NewsArticle] {
  source: "news_archive"
  lifecycle: :audit
}

store fact_checks: BiHistory[FactCheckResult] {
  source: "fact_checks"
  lifecycle: :durable
}

store clarity_reports: BiHistory[ClarityReport] {
  source: "clarity_reports"
  lifecycle: :audit
}

stream live_news: Stream[NewsArticle] {
  source: "news_ingest"
  mode: observed
  receipt_required: true
}

thresholds {
  high_misinfo_risk = 0.750
  review_required_risk = 0.600
  low_misinfo_risk = 0.150
}

observed contract CaptureArticle(raw: ExternalPayload, as_of: Timestamp)
  observes external NewsFeed
  receipt RealObservation
  failure CaptureFailure
  via audited_truth_mesh
{
  article = parse_news_article(raw)

  observation = RealObservation {
    source: article.source
    captured_at: as_of
    content_hash: content_hash(raw)
  }

  output article evidence [observation]
}

observed contract ExtractClaims(article: NewsArticle, as_of: Timestamp)
  observes model ClaimExtractor
  receipt ModelObservation
  failure ModelFailure
  via audited_truth_mesh
{
  model_result = ClaimExtractor.extract(article.body)

  model_observation = ModelObservation {
    model: ClaimExtractor.ref
    prompt_hash: model_result.prompt_hash
    output_hash: content_hash(model_result.claims)
    confidence: model_result.confidence
    produced_at: as_of
  }

  claims = model_result.claims

  invariant claims_are_not_truth: claims.all { it.text.present? }
    severity :error
    message "Extracted claims are model observations, not verified facts"

  output claims evidence [article, model_observation]
}

observed contract FindEvidence(claim: Claim, as_of: Timestamp)
  observes external PublicSources
  receipt EvidenceSearchReceipt
  failure EvidenceSearchFailure
  via audited_truth_mesh
{
  sources = search_public_sources(claim, as_of)

  real_observations = sources.map {
    RealObservation {
      source: it
      captured_at: as_of
      content_hash: content_hash(it.uri, it.publisher)
    }
  }

  bundle = EvidenceBundle {
    primary: real_observations.where { it.source.trust_tier == :primary }
    corroborating: real_observations.where { it.source.trust_tier == :corroborating }
    contradicting: real_observations.where { it.source.trust_tier == :contradicting }
    model_observations: []
    human_reviews: []
  }

  output bundle evidence [claim]
}

pure contract ScoreRisk(claim: Claim, evidence: EvidenceBundle)
  -> risk: RiskScore
  via audited_truth_mesh
{
  contradiction_weight = evidence.contradicting.count * 0.35
  corroboration_weight = evidence.corroborating.count * 0.20
  primary_weight = evidence.primary.count * 0.25

  raw_score = contradiction_weight - corroboration_weight - primary_weight
  normalized = clamp(raw_score, 0.0, 1.0)

  reasons = [
    "contradictions=#{evidence.contradicting.count}",
    "corroborations=#{evidence.corroborating.count}",
    "primary=#{evidence.primary.count}"
  ]

  risk = RiskScore {
    value: normalized
    reasons: reasons
  }

  output risk evidence [claim, evidence]
}

pure contract DecideVerdict(risk: RiskScore)
  -> verdict: Symbol
  via audited_truth_mesh
{
  verdict = match risk.value {
    > high_misinfo_risk => :likely_false
    < low_misinfo_risk  => :likely_true
    _                   => :uncertain
  }

  output verdict evidence [risk]
}

contract FactCheckClaim(claim: Claim, as_of: Timestamp)
  -> result: FactCheckResult
  via audited_truth_mesh
{
  evidence = FindEvidence(claim, as_of)
  risk = ScoreRisk(claim, evidence)
  verdict = DecideVerdict(risk)

  result = FactCheckResult {
    claim: claim
    verdict: verdict
    confidence: 1.0 - risk.value
    risk: risk
    explanation: explain_verdict(verdict, risk, evidence)
    evidence: evidence
  }

  invariant uncertainty_is_visible: result.verdict != :true
    severity :info
    message "System does not claim absolute truth; it reports evidence-weighted clarity"

  output result evidence [claim, evidence, risk]
}

contract BuildClarityReport(article: NewsArticle, checks: Collection[FactCheckResult], as_of: Timestamp)
  -> report: ClarityReport
  via audited_truth_mesh
{
  avg_risk = checks.avg { it.risk.value }

  review_status = match avg_risk {
    > review_required_risk => :requires_human_review
    _                      => :auto_review_sufficient
  }

  honesty_notes = [
    "Model outputs are marked as ModelObservation",
    "Evidence is separated from inference",
    "Human override cannot erase prior evidence",
    "Uncertainty is preserved, not hidden"
  ]

  report = ClarityReport {
    article_id: article.id
    produced_at: as_of
    overall_risk: RiskScore {
      value: avg_risk
      reasons: checks.flat_map { it.risk.reasons }
    }
    clarity_score: 1.0 - avg_risk
    fact_checks: checks
    review_status: review_status
    honesty_notes: honesty_notes
  }

  invariant high_risk_requires_review:
    report.overall_risk.value < review_required_risk ||
    report.review_status == :requires_human_review
    severity :warn
    message "High-risk article must remain marked for human review"

  output report evidence [article, checks]
}

privileged contract HumanOverrideReview(
  report: ClarityReport,
  reviewer: HumanRef,
  decision: Symbol,
  reason: String,
  as_of: Timestamp
) -> receipt: ReviewReceipt
  authority fact_check_editor
  reversibility append_only
  receipt ReviewReceipt
  via audited_truth_mesh
{
  invariant reason_required: reason.present?
    severity :error
    message "Human override must explain itself"

  receipt = ReviewReceipt {
    report_id: report.article_id
    reviewer: reviewer
    decision: decision
    reason: reason
    decided_at: as_of
  }

  output receipt evidence [report]
}

contract RunArticlePipeline(article: NewsArticle, as_of: Timestamp)
  -> receipt: ClarityDecisionReceipt
  via audited_truth_mesh
{
  claims = ExtractClaims(article, as_of)

  checks = for claim in claims {
    FactCheckClaim(claim, as_of)
  }

  report = BuildClarityReport(
    article,
    checks,
    as_of
  )

  evidence = EvidenceBundle {
    primary: checks.flat_map { it.evidence.primary }
    corroborating: checks.flat_map { it.evidence.corroborating }
    contradicting: checks.flat_map { it.evidence.contradicting }
    model_observations: checks.flat_map { it.evidence.model_observations }
    human_reviews: []
  }

  receipt = ClarityDecisionReceipt {
    report: report
    evidence: evidence
    human_override: none
    artifact_hash: current_artifact_hash()
    link_manifest_hash: current_link_manifest_hash()
    produced_at: as_of
    honesty_statement: "This report separates observation, inference, risk, uncertainty, and human review."
  }

  output receipt evidence [article, claims, checks, report]
}

service contract LiveNewsClarityService(as_of: Timestamp)
  heartbeat every 10.seconds
  checkpoint every 1.minute
  cancellation required
  max_step_latency 2.seconds
  via audited_truth_mesh
{
  loop article in live_news
    invariant article_has_source: article.source.uri.present?
    max_steps 100_000
    on_exhaustion :suspend
  {
    receipt = RunArticlePipeline(article, now())

    write clarity_reports <- receipt.report
      evidence [receipt]
  }
}

view clarity_dashboard: ClarityReport {
  from clarity_reports
  order by produced_at desc

  columns [
    article_id,
    produced_at,
    clarity_score,
    overall_risk.value,
    review_status,
    honesty_notes
  ]

  filters [
    review_status,
    overall_risk.value,
    produced_at
  ]
}

