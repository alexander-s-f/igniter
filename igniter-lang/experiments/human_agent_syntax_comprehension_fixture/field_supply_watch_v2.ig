module Lab.Fixtures.FieldSupplyWatchV2

profile audited_mesh {
  time: explicit
  lifecycle: :audit
  backend: :ledger
  consistency: :causal
  evidence: required
}

type EvidenceRef {
  id: String
  kind: Symbol
  hash: String
}

type Region {
  code: String
  name: String
  timezone: String
}

type ClinicRef {
  id: String
  region: Region
}

type SupplierRef {
  id: String
  region: Region
  trust: TrustLevel
}

type TrustLevel {
  tier: Symbol
  attestations: Collection[EvidenceRef]
}

type SupplyItem {
  sku: String
  name: String
  unit: Symbol
}

type Money {
  amount: Decimal[scale: 2]
  currency: Symbol
}

type SourceRef {
  uri: String
  kind: Symbol
  captured_at: Timestamp
}

type EvidenceBundle {
  primary: Collection[SourceRef]
  corroborating: Collection[SourceRef]
  contradictions: Collection[SourceRef]
}

type DemandSignal {
  clinic: ClinicRef
  item: SupplyItem
  requested_units: Integer
  urgency: Symbol
  reported_at: Timestamp
  evidence: EvidenceBundle
}

type InventorySnapshot {
  clinic: ClinicRef
  item: SupplyItem
  on_hand_units: Integer
  reserved_units: Integer
  as_of: Timestamp
}

type SupplierOffer {
  supplier: SupplierRef
  item: SupplyItem
  available_units: Integer
  unit_price: Money
  valid_until: Timestamp
  evidence: EvidenceBundle
}

type ShipmentPlan {
  supplier: SupplierRef
  clinic: ClinicRef
  item: SupplyItem
  units: Integer
  eta: Timestamp
  estimated_cost: Money
}

type RiskScore {
  value: Decimal[scale: 3]
  reasons: Collection[String]
}

packet FieldReport {
  clinic: ClinicRef
  item: SupplyItem
  requested_units: Integer
  urgency: Symbol
  source: SourceRef
}

event ReportReceived {
  report_id: String
  payload: FieldReport
  observed_at: Timestamp
}

event SupplierOfferUpdated {
  supplier: SupplierRef
  item: SupplyItem
  available_units: Integer
  unit_price: Money
  observed_at: Timestamp
  evidence: EvidenceBundle
}

type RegionalSupplyPosture {
  region: Region
  item: SupplyItem
  demand_units: Integer
  available_units: Integer
  shortage_units: Integer
  risk: RiskScore
  as_of: Timestamp
}

view regional_supply_posture: RegionalSupplyPosture {
  from BuildRegionalPosture
  lifecycle :audit
}

receipt DispatchDecisionReceipt {
  decision_id: String
  plan: ShipmentPlan
  risk: RiskScore
  caused_by: Collection[EvidenceRef]
  human_override: Option[HumanOverride]
  produced_at: Timestamp
}

type HumanOverride {
  reviewer: String
  reason: String
  accepted_risk: RiskScore
  decided_at: Timestamp
}

store reports: History[ReportReceived] {
  source: "field_reports"
  partition: report.payload.clinic.region.code
  lifecycle: :audit
}

store inventory: BiHistory[InventorySnapshot] {
  source: "inventory_snapshots"
  valid_axis: as_of
  transaction_axis: recorded_at
  lifecycle: :durable
}

store supplier_offers: History[SupplierOfferUpdated] {
  source: "supplier_offers"
  partition: supplier.region.code
  lifecycle: :audit
}

stream report_ingress: FieldReport {
  from "field_reports.live"
  window rolling 6.hours
}

metric regional_supply: Integer {
  dims {
    time: Timestamp
    region: String
    sku: String
    posture: Symbol
  }
  source RegionalSupplyPosture
  indexed [time, region, sku]
}

mesh SupplyAnalysisMesh {
  capability :osint_verify
  capability :route_plan
  trust all [:verified_peer, :regional_operator]
}

contract NormalizeReport(report: FieldReport, as_of: Timestamp) -> signal: DemandSignal using audited_mesh {
  let evidence = EvidenceBundle {
    primary: [report.source],
    corroborating: [],
    contradictions: []
  }

  let signal = DemandSignal {
    clinic: report.clinic,
    item: report.item,
    requested_units: report.requested_units,
    urgency: report.urgency,
    reported_at: report.source.captured_at,
    evidence: evidence
  }
}

contract VerifyDemand(signal: DemandSignal, as_of: Timestamp) -> verified: DemandSignal, risk: RiskScore using audited_mesh {
  read recent_reports: History[ReportReceived] from reports
    range signal.reported_at - 24.hours .. as_of

  let corroboration = count_matching_reports(recent_reports, signal.clinic, signal.item)
  let contradiction = count_contradictions(recent_reports, signal.clinic, signal.item)

  let risk = RiskScore {
    value: if contradiction > 0 { 0.850 } else { if corroboration >= 2 { 0.180 } else { 0.420 } },
    reasons: explain_demand_risk(corroboration, contradiction, signal.urgency)
  }

  invariant demand_has_source: signal.evidence.primary.count > 0
    severity :error

  invariant uncertain_demand_needs_review: risk.value < 0.700 || signal.urgency != :critical
    severity :warn
    overridable_with HumanOverride

  output verified: DemandSignal = signal
    evidence [recent_reports]

  output risk: RiskScore = risk
    evidence [recent_reports]
}

contract BuildRegionalPosture(region: Region, item: SupplyItem, as_of: Timestamp, knowledge_as_of: Timestamp) -> posture: RegionalSupplyPosture using audited_mesh {
  read demand_events: History[ReportReceived] from reports
    range as_of - 6.hours .. as_of

  read stock: BiHistory[InventorySnapshot] from inventory
    at { vt: as_of, tt: knowledge_as_of }

  read offers: History[SupplierOfferUpdated] from supplier_offers
    range as_of .. as_of + 72.hours

  let demand_units = sum_requested_units(demand_events, region, item)
  let available_units = sum_offer_units(offers, region, item) + available_stock(stock, region, item)
  let shortage_units = max(0, demand_units - available_units)

  let risk = RiskScore {
    value: if shortage_units > 0 { 0.760 } else { 0.120 },
    reasons: explain_posture(demand_units, available_units, shortage_units)
  }

  let posture = RegionalSupplyPosture {
    region: region,
    item: item,
    demand_units: demand_units,
    available_units: available_units,
    shortage_units: shortage_units,
    risk: risk,
    as_of: as_of
  }

  output posture: RegionalSupplyPosture = posture
    evidence [demand_events, stock, offers]
    lifecycle :audit
}

contract PlanDispatch(posture: RegionalSupplyPosture, as_of: Timestamp) -> plan: ShipmentPlan, receipt: DispatchDecisionReceipt using audited_mesh {
  read offers: History[SupplierOfferUpdated] from supplier_offers
    range as_of .. as_of + 72.hours

  let candidate_suppliers = rank_suppliers(offers, posture.region, posture.item, posture.shortage_units)

  delegate route_options to SupplyAnalysisMesh capability :route_plan {
    input posture
    input candidate_suppliers
    admit peer.trust at_least :regional_operator
    retry max 3
    timeout 30.seconds
  }

  let plan = choose_plan(route_options, posture.shortage_units)

  await_review dispatch_override when posture.risk.value >= 0.700 {
    subject plan
    reason "high risk dispatch"
    required_role :regional_operator
  } -> override: Option[HumanOverride]

  let receipt = DispatchDecisionReceipt {
    decision_id: content_hash(plan, posture, as_of),
    plan: plan,
    risk: posture.risk,
    caused_by: evidence_refs(posture, offers, route_options),
    human_override: override,
    produced_at: as_of
  }

  invariant high_risk_requires_review: posture.risk.value < 0.700 || override.is_some
    severity :error

  output plan: ShipmentPlan = plan
    evidence [posture, offers, route_options, override]
    lifecycle :durable

  output receipt: DispatchDecisionReceipt = receipt
    evidence [posture, offers, route_options, override]
    lifecycle :audit
}

contract MonitorSupply(region: Region, item: SupplyItem, as_of: Timestamp, knowledge_as_of: Timestamp) -> posture: RegionalSupplyPosture, dispatch: Option[ShipmentPlan], receipt: Option[DispatchDecisionReceipt] using audited_mesh {
  fold_stream report_ingress window rolling 6.hours
    seed []
    into report_batch {
      step acc, report -> acc.add(NormalizeReport(report, as_of).signal)
    }

  let verified_signals = map(report_batch, signal -> VerifyDemand(signal, as_of).verified)

  let posture = BuildRegionalPosture(region, item, as_of, knowledge_as_of).posture

  let dispatch_needed = posture.shortage_units > 0 || posture.risk.value >= 0.700

  let decision = if dispatch_needed {
    some(PlanDispatch(posture, as_of))
  } else {
    none
  }

  write regional_supply at {
    time: as_of,
    region: region.code,
    sku: item.sku,
    posture: if dispatch_needed { :shortage } else { :stable }
  } = posture.shortage_units

  output posture: RegionalSupplyPosture = posture
    evidence [verified_signals]
    lifecycle :audit

  output dispatch: Option[ShipmentPlan] = decision.map(d -> d.plan)
    evidence [posture]
    lifecycle :durable

  output receipt: Option[DispatchDecisionReceipt] = decision.map(d -> d.receipt)
    evidence [posture]
    lifecycle :audit
}
