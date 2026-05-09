-- Syntax pressure specimen: News Clarity Aggregator v1.
-- This file is not current Igniter-Lang canon and is not expected to parse.
-- Extracted from the External Pressure Reviewer V2 cross-test.
-- Non-canon pressure constructs in this file include:
-- profile, threshold, packet, event, receipt, store, metric, external pure,
-- for, method fold/map with fn(...), view, BiHistory at { vt, tt },
-- and human_override invariant override syntax.

module Lab.Fixtures.NewsClarityAggregatorV1

profile audited_truth_mesh {
  time: explicit
  lifecycle: :audit
  backend: :ledger
  consistency: :causal
  evidence: required
}

threshold high_misinfo_risk:    Decimal[scale: 3] = 0.750
threshold medium_misinfo_risk:  Decimal[scale: 3] = 0.450
threshold low_misinfo_risk:     Decimal[scale: 3] = 0.150
threshold review_required_risk: Decimal[scale: 3] = 0.600

type EvidenceRef {
  id: String
  kind: Symbol
  hash: String
  captured_at: Timestamp
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

type EvidenceBundle {
  primary: Collection[SourceRef]
  corroborating: Collection[SourceRef]
  contradictions: Collection[SourceRef]
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
  explanation: String
  evidence: EvidenceBundle
  risk: RiskScore
}

type RiskScore {
  value: Decimal[scale: 3]
  reasons: Collection[String]
}

type HumanOverride {
  reviewer: String
  reason: String
  accepted_risk: RiskScore
  decided_at: Timestamp
}

type ClarityReport {
  article_id: String
  overall_risk: RiskScore
  fact_checks: Collection[FactCheckResult]
  clarity_score: Decimal[scale: 3]
  produced_at: Timestamp
}

packet IncomingNews {
  article: NewsArticle
  observed_at: Timestamp
}

event NewsReceived {
  article_id: String
  payload: IncomingNews
  observed_at: Timestamp
}

event FactCheckCompleted {
  report: ClarityReport
  observed_at: Timestamp
}

receipt ClarityDecisionReceipt {
  id decision_id by content_hash(report, risk, produced_at)
  report: ClarityReport
  risk: RiskScore
  caused_by: Collection[EvidenceRef]
  human_override: Option[HumanOverride]
  produced_at: Timestamp
}

store news_archive: History[NewsReceived] {
  source: "news_ingest"
  partition: article.source.publisher
  lifecycle: :audit
}

store fact_checks: BiHistory[FactCheckResult] {
  source: "fact_checks"
  valid_axis: as_of
  transaction_axis: recorded_at
  lifecycle: :durable
}

store clarity_reports: History[FactCheckCompleted] {
  source: "clarity_reports"
  lifecycle: :audit
}

stream live_news_stream: IncomingNews {
  from "news.live_feed"
  window rolling 1.hour
}

metric global_clarity_index: Decimal[scale: 3] {
  dims {
    time: Timestamp
    publisher: String
    topic: String
  }
  source ClarityReport
  indexed [time, publisher]
}

external pure extract_claims(article: NewsArticle) -> Collection[Claim]
external pure find_corroboration(claim: Claim, as_of: Timestamp) -> EvidenceBundle
external pure calculate_misinfo_risk(evidence: EvidenceBundle, claim: Claim) -> RiskScore
external pure generate_explanation(verdict: Symbol, evidence: EvidenceBundle) -> String

contract IngestAndNormalize(article: NewsArticle, as_of: Timestamp)
  -> normalized: NewsArticle
  using audited_truth_mesh {

  let claims = extract_claims(article)

  let normalized = NewsArticle {
    id: article.id,
    headline: article.headline,
    body: article.body,
    published_at: article.published_at,
    source: article.source,
    claims: claims,
    evidence: EvidenceBundle {
      primary: [article.source],
      corroborating: [],
      contradictions: []
    }
  }

  invariant has_at_least_one_claim: normalized.claims.count > 0
    severity :error

  output normalized: NewsArticle = normalized
    evidence [article]
}

contract PerformFactCheck(normalized: NewsArticle, as_of: Timestamp)
  -> fact_checks: Collection[FactCheckResult]
  using audited_truth_mesh {

  read recent_checks: BiHistory[FactCheckResult] from fact_checks
    at { vt: as_of, tt: as_of }

  let results = []

  for claim in normalized.claims {
    let bundle = find_corroboration(claim, as_of)
    let risk = calculate_misinfo_risk(bundle, claim)

    let verdict = if risk.value > high_misinfo_risk { :false }
                  else if risk.value < low_misinfo_risk { :true }
                  else { :misleading }

    let check = FactCheckResult {
      claim: claim,
      verdict: verdict,
      confidence: 1.0 - risk.value,
      explanation: generate_explanation(verdict, bundle),
      evidence: bundle,
      risk: risk
    }

    results = results + [check]
  }

  output fact_checks: Collection[FactCheckResult] = results
    evidence [recent_checks]
}

contract BuildClarityReport(article: NewsArticle, checks: Collection[FactCheckResult], as_of: Timestamp)
  -> report: ClarityReport, risk: RiskScore
  using audited_truth_mesh {

  let overall_risk = RiskScore {
    value: checks.fold(0.0, fn(acc, c) => acc + c.risk.value) / checks.count,
    reasons: checks.map(fn(c) => c.explanation)
  }

  let clarity_score = 1.0 - overall_risk.value

  let report = ClarityReport {
    article_id: article.id,
    overall_risk: overall_risk,
    fact_checks: checks,
    clarity_score: clarity_score,
    produced_at: as_of
  }

  invariant high_risk_needs_review: overall_risk.value < review_required_risk || human_override.is_some
    severity :warn
    overridable_with HumanOverride

  output report: ClarityReport = report
    evidence [checks]
  output risk: RiskScore = overall_risk
    evidence [checks]
}

contract RunNewsClarityPipeline(incoming: IncomingNews, as_of: Timestamp)
  -> receipt: ClarityDecisionReceipt
  using audited_truth_mesh {

  let normalized = IngestAndNormalize(incoming.article, as_of)
  let checks = PerformFactCheck(normalized, as_of)
  let (report, risk) = BuildClarityReport(normalized, checks, as_of)

  let receipt = ClarityDecisionReceipt {
    report: report,
    risk: risk,
    caused_by: [normalized.evidence, checks.evidence],
    human_override: none,
    produced_at: as_of
  }

  output receipt: ClarityDecisionReceipt = receipt
}

view global_clarity_dashboard: ClarityReport {
  from RunNewsClarityPipeline
  lifecycle :audit
}
