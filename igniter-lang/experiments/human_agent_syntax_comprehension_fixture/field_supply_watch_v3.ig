-- Syntax pressure specimen: Field Supply Watch v3.
-- This file is not current Igniter-Lang canon and is not expected to parse.
-- Non-canon pressure constructs in this file include:
-- profile, packet, event, receipt, view, metric, mesh, delegate, await_review,
-- threshold, external pure, id ... by content_hash, accumulate, evidence_refs.

module Lab.Fixtures.FieldSupplyWatchV3

profile audited_mesh {
  time: explicit
  lifecycle: :audit
  backend: :ledger
  consistency: :causal
  evidence: required
}

threshold review_required_risk: Decimal[scale: 3] = 0.700
threshold contradiction_risk: Decimal[scale: 3] = 0.850
threshold corroborated_risk: Decimal[scale: 3] = 0.180
threshold uncertain_risk: Decimal[scale: 3] = 0.420
threshold shortage_risk: Decimal[scale: 3] = 0.760
threshold stable_risk: Decimal[scale: 3] = 0.120

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

type RegionalSupplyPosture {
  region: Region
  item: SupplyItem
  demand_units: Integer
  available_units: Integer
  shortage_units: Integer
  risk: RiskScore
  as_of: Timestamp
}

type HumanOverride {
  reviewer: String
  reason: String
  accepted_risk: RiskScore
  decided_at: Timestamp
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

receipt DispatchDecisionReceipt {
  id decision_id by content_hash(plan, risk, produced_at)
  plan: ShipmentPlan
  risk: RiskScore
  caused_by: Collection[EvidenceRef]
  human_override: Option[HumanOverride]
  produced_at: Timestamp
}

view regional_supply_posture: RegionalSupplyPosture {
  from BuildRegionalPosture
  lifecycle :audit
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
  capability :route_plan
  trust all [:verified_peer, :regional_operator]
}

external pure count_matching_reports(
  reports: History[ReportReceived],
  clinic: ClinicRef,
  item: SupplyItem
) -> Integer

external pure count_contradictions(
  reports: History[ReportReceived],
  clinic: ClinicRef,
  item: SupplyItem
) -> Integer

external pure explain_demand_risk(
  corroboration: Integer,
  contradiction: Integer,
  urgency: Symbol
) -> Collection[String]

external pure sum_requested_units(
  reports: History[ReportReceived],
  region: Region,
  item: SupplyItem
) -> Integer

external pure sum_offer_units(
  offers: History[SupplierOfferUpdated],
  region: Region,
  item: SupplyItem
) -> Integer

external pure available_stock(
  stock: BiHistory[InventorySnapshot],
  region: Region,
  item: SupplyItem
) -> Integer

external pure rank_suppliers(
  offers: History[SupplierOfferUpdated],
  region: Region,
  item: SupplyItem,
  units: Integer
) -> Collection[SupplierRef]

external pure choose_plan(
  route_options: Collection[ShipmentPlan],
  units: Integer
) -> ShipmentPlan

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

  let demand_risk = if contradiction > 0 {
    contradiction_risk
  } else {
    if corroboration >= 2 { corroborated_risk } else { uncertain_risk }
  }

  let risk = RiskScore {
    value: demand_risk,
    reasons: explain_demand_risk(corroboration, contradiction, signal.urgency)
  }

  invariant demand_has_source: signal.evidence.primary.count > 0
    severity :error

  invariant uncertain_demand_needs_review: risk.value < review_required_risk || signal.urgency != :critical
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
    value: if shortage_units > 0 { shortage_risk } else { stable_risk },
    reasons: ["demand", demand_units, "available", available_units, "shortage", shortage_units]
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

  await_review dispatch_override when posture.risk.value >= review_required_risk {
    subject plan
    reason "high risk dispatch"
    required_role :regional_operator
  } -> override: Option[HumanOverride]

  let receipt = DispatchDecisionReceipt {
    plan: plan,
    risk: posture.risk,
    caused_by: evidence_refs(posture, offers, route_options),
    human_override: override,
    produced_at: as_of
  }

  invariant high_risk_requires_review: posture.risk.value < review_required_risk || override.is_some
    severity :error

  output plan: ShipmentPlan = plan
    evidence [posture, offers, route_options, override]
    lifecycle :durable

  output receipt: DispatchDecisionReceipt = receipt
    evidence [posture, offers, route_options, override]
    lifecycle :audit
}

contract MonitorSupply(region: Region, item: SupplyItem, as_of: Timestamp, knowledge_as_of: Timestamp) -> posture: RegionalSupplyPosture, dispatch: Option[ShipmentPlan], receipt: Option[DispatchDecisionReceipt] using audited_mesh {
  accumulate report_ingress window rolling 6.hours
    seed []
    into report_batch {
      step acc, report -> acc.add(NormalizeReport(report, as_of).signal)
    }

  let verified_signals = map(report_batch, signal -> VerifyDemand(signal, as_of).verified)

  let posture = BuildRegionalPosture(region, item, as_of, knowledge_as_of).posture

  let dispatch_needed = posture.shortage_units > 0 || posture.risk.value >= review_required_risk

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
