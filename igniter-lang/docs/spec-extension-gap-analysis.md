# Spec Extension Gap Analysis

Status: reference · S3-R26
Date: 2026-05-10
Author: `[Igniter-Lang Meta Expert]`
Governance: META-EXPERT-013

This document records the delta between igniter-lang v0.1.0.pre.stage2
(Stage 1–2 closed) and the extended specification (ch10–ch13, proposed).

Source: external pressure review using three hypothetical application programs.
See `experiments/external_pressure_specimens/` for the programs.

---

## What Aligns (no gap)

| Construct | impl | spec |
|-----------|------|------|
| `contract { input, compute, output }` | ✅ parser.rb | ✅ ch2 |
| `type T { field: Type? }` | ✅ | ✅ ch3 |
| `History[T]`, `BiHistory[T]`, `Option[T]`, `Stream[T]` | ✅ ch9 | ✅ ch3 |
| `history_at(ref, as_of)`, `bihistory_at(ref, vt, tt)` | ✅ | ✅ ch9 |
| `invariant name: cond severity :level` | ✅ | ✅ ch9 |
| `module`, `import` | ✅ | ✅ ch2 |
| `escape capability` | ✅ | partial — spec uses different surface |
| `Decimal[N]`, `OLAPPoint[T, Dims]` | ✅ Stage 2 | not yet in ch10+ |
| `pipeline { step }`, `fold_stream @window_bounded` | ✅ Stage 2 | not yet in ch10+ |

---

## Gap-A: Contract Modifiers — CRITICAL

**Missing from impl:** optional modifier prefix before `contract`.

```igniter
pure         contract ScoreRisk(...)
observed     contract ExtractClaims(...)
effect       contract ChargeCustomer(...)
privileged   contract UnlockDoor(...)
irreversible contract DispatchEmergency(...)
```

**Impl change:** parser + classifier + typechecker + SemanticIR (≈50 lines).
**Backward compatible:** `contract Foo {}` = implicit `pure`. No existing programs break.
**Proposal:** PROP-031 (authored, awaiting regression proof).
**Spec:** ch10.

---

## Gap-B: `via profile` Binding — HIGH

**Missing from impl:** optional `via profile_name` clause on contract declaration.

```igniter
effect contract ChargeCustomer(...) via audited_billing { ... }
```

**Impl change:** parser + TypeChecker scope resolution + SemanticIR.
**Backward compatible:** `via` is optional.
**Proposal:** PROP-032 (not yet authored, gated on PROP-031).
**Spec:** ch11.

---

## Gap-C: Profile Declarations — HIGH

**Missing from impl:** `profile` as a top-level declaration with property enforcement.

```igniter
profile audited_billing {
  time: explicit
  lifecycle: :audit
  backend: :ledger
  evidence: required
  allowed_effects: [payment_gateway.charge]
}
```

**Impl change:** new top-level declaration + new compiler pass.
**Proposal:** PROP-034 (not yet authored, gated on PROP-031 + PROP-032).
**Spec:** ch11.

---

## Gap-D: Effect Surface — HIGH

**Missing from impl:** 7-field Effect Surface for effect/privileged/irreversible contracts.

```igniter
effect contract ChargeCustomer(...)
  affects  external PaymentGateway.ChargeEndpoint
  authority billing_operator
  reversibility :compensatable
  idempotency key content_hash(customer_id, amount, currency)
  receipt  ChargeReceipt
  failure  PaymentFailure
  compensation RefundCustomer
```

**Impl change:** parser (7 new clauses) + TypeChecker validation + SemanticIR.
**Proposal:** PROP-035 (not yet authored, gated on PROP-031).
**Spec:** ch12.

---

## Gap-E: `output ... evidence [refs]` — MEDIUM

**Missing from impl:** evidence provenance clause on output declarations.

```igniter
output claims evidence [article, model_observation]
```

**Impl change:** parser (optional clause) + SemanticIR (evidence_refs field).
**Backward compatible:** clause is optional.
**Proposal:** PROP-033 (not yet authored, gated on PROP-031).
**Spec:** ch10 §10.5 (field in contract_ir).

---

## Gap-F: Service Loops and Managed Recursion — MEDIUM / Stage 4

**Missing from impl:** `service contract` form, `loop item in stream`, `loop tick in clock.every(N.ms)`, `write store <- value evidence [refs]`.

```igniter
service contract Monitor(...)
  heartbeat every 10.seconds
  checkpoint every 1.minute
  cancellation required
  max_step_latency 2.seconds
  via emergency_service
{
  loop article in live_news max_steps 100_000 on_exhaustion :suspend {
    receipt = RunPipeline(article, now())
    write clarity_reports <- receipt.report evidence [receipt]
  }
}
```

**Impl change:** new loop class, new runtime semantics, new executor obligations.
**Proposal:** PROP-036+ (Stage 4 scope).
**Spec:** ch13.

---

## Gap-G: Additional Constructs (not yet in proposals)

| Construct | Example | Notes |
|-----------|---------|-------|
| `view V: T { from store, columns [...] }` | `view clarity_dashboard: ClarityReport { ... }` | Read-only projection layer; ch? |
| `placement P { mode, stages { X on :node } }` | `placement realtime_video_cluster { ... }` | Deployment topology; ch? |
| `observes external/model/robot X` | `observes model ClaimExtractor` | Shorthand for observed contracts; extends PROP-035 |

---

## Impl-Ahead (in impl, not yet in spec ch10+)

These features are implemented but not described in proposed chapters. They remain
valid and are not affected by the extension.

| Feature | Status |
|---------|--------|
| `olap_point { dimensions, measure }` | ✅ Stage 2, ch9 |
| `pipeline { step }` | ✅ Stage 1, ch5 |
| `fold_stream @window_bounded / @count_bounded(n)` | ✅ Stage 2, ch9 |
| `window { kind, size, on_close }` | ✅ Stage 2, ch9 |
| `trait`, `impl` | ✅ Stage 1, ch3 |

---

## Priority Ordering

| Priority | PROP | Gap | Stage |
|----------|------|-----|-------|
| 1 | PROP-031 | Gap-A (modifiers) | 3 Language Lane |
| 2 | PROP-032 | Gap-B (via profile) | 3 Language Lane |
| 3 | PROP-033 | Gap-E (evidence) | 3 Language Lane |
| 4 | PROP-034 | Gap-C (profile system) | 3 new Lane |
| 5 | PROP-035 | Gap-D (effect surface) | 3 new Lane |
| 6 | PROP-036+ | Gap-F (service loops) | 4 |
| — | TBD | Gap-G (view, placement) | 4+ |
