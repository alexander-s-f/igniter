# S3-R87-C1-RF1 - Spark Contractable Shadowing Pilot Scope v0

Card: S3-R87-C1-RF1
Agent: [Igniter Ruby Framework Adoption Agent]
Role: ruby-framework-adoption-agent
Track: spark-contractable-shadowing-pilot-scope-v0
Route: PROPOSED
Status: proposed
Date: 2026-05-20

---

## Goal

Design the first bounded Spark CRM contractable shadowing pilot for Igniter Ruby
framework adoption without implementing code.

## Context To Read

- `.agents/ruby-framework/current-status.md`
- `.agents/ruby-framework/spark-contractable-shadowing-adoption-plan-v0.md`
- `packages/igniter-contracts/README.md`
- `packages/igniter-embed/README.md`
- `packages/igniter-ledger/README.md`
- `packages/igniter-ledger-client/README.md`
- `igniter-lang/docs/gates/r86-spec-sync-and-spark-applicability-routing-decision-v0.md`
- `/Users/alex/dev/projects/sparkcrm/docs/agents/spark-ledger-igniter-friendly-roadmap.md`

## Scope

Compare and choose the first pilot design target:

- Option A: AvailabilityLedger-style slot map for why-not availability reasons.
- Option B: OrderPriceLedger-style finder for chain-winner price explanation.

The card should define a design-only pilot for the chosen target.

## Required Design Output

- recommended pilot target and rationale;
- primary service authority statement;
- observed-service first step;
- later shadow-candidate step, if applicable;
- redacted receipt shape;
- input digest policy;
- output digest or normalized-output policy;
- no raw customer/provider payload policy;
- sampling gate;
- async strategy and durable-adapter dependency;
- missing-receipt fail-open behavior;
- store-error fail-open behavior;
- optional Igniter Ledger sidecar boundary;
- proof/parity evidence required before implementation;
- exact implementation authorization checklist;
- closed-surface list.

## Framework Constraints

Use existing Ruby package surfaces only:

- core `Igniter::Contracts::Contractable` protocol when describing candidate
  service shape;
- `Igniter::Embed.contractable` observed-service and shadow semantics;
- Embed observation/event receipt schema as the receipt vocabulary;
- `record_observation` / `record_event` as the store adapter protocol;
- `Igniter::Ledger::ContractableReceiptSink` and `Igniter::LedgerClient` only
  as optional persistence boundaries.

Do not propose new package APIs unless the card explicitly labels them as
future pressure, not implementation scope.

## Acceptance Criteria

- The selected target is bounded enough for a low-risk observed-service pilot.
- Primary Spark behavior remains authoritative and unchanged.
- The receipt policy is redacted by construction.
- The plan can run with no candidate at first.
- The later candidate path has clear normalization and acceptance requirements.
- The design records that local thread async is not durable.
- High-volume rollout is blocked until a durable queue/outbox adapter exists.
- Optional Ledger sidecar use is read-only/reporting-oriented.
- The card contains no code changes and does not authorize code changes.

## Closed Surfaces

This card must not:

- inspect private Spark CRM code unless separately authorized;
- edit Spark CRM code;
- edit Igniter Ruby framework code;
- change Spark production behavior;
- authorize a Ledger source-of-truth switch;
- include real Spark payloads, credentials, PII, provider tokens, phone/email
  data, endpoint details, or raw infrastructure details;
- authorize Igniter-Lang runtime execution of Spark decisions;
- widen Igniter public API/CLI/compiler surfaces.

## Deliver

Create a design track document under:

```text
.agents/ruby-framework/tracks/spark-contractable-shadowing-pilot-scope-v0.md
```

The delivered document should include the chosen target, rationale, receipt
contract, rollout gates, and closed surfaces.
