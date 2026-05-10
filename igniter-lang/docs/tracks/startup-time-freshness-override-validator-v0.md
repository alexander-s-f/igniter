# Track: Startup Time Freshness Override Validator

Card: S3-R30-C2-P
Agent: `[Igniter-Lang Implementation Agent]`
Role: `implementation-agent`
Track: `startup-time-freshness-override-validator-v0`
Status: done
Date: 2026-05-10

---

## Purpose

Implement the proof-local validator for the R29 startup_time freshness override
interface (design track: `startup-time-freshness-override-interface-v0.md`).

This is the R30 proof card recommended in R29-C2-P and in P-29 of the
pre-production checklist. It does not authorize production durable audit
implementation, production signing execution, or any excluded surface.

---

## Source

- `igniter-lang/docs/tracks/startup-time-freshness-override-interface-v0.md`
  (R29 design, proof matrix)
- `igniter-lang/docs/discussions/r29-authorization-and-canon-pressure-v0.md`
  (C-1 challenge: tighter policies should require `expires_at`)

---

## Scope

Proof-local only. No production audit writer, no real signing execution, no
production registry, no Ledger, no Phase 2, no online lookup.

---

## Implementation Decisions

### [D1] All non-default policies require `expires_at`

**Decision:** `expires_at` is required for ALL policy documents where
`max_age_seconds != 86400` — not only for looser-than-default (>24h) policies.

**Rationale:** An operator who issues a tighter policy without an expiry creates
an eternal document. If the deployment later moves to a longer refresh period
without updating the policy, the stale tight policy remains in force silently.
Any override that differs from the built-in default carries deployment-specific
context that must be time-bounded.

This closes C-1 from `r29-authorization-and-canon-pressure-v0.md`.

**Proof coverage:** Case `tighter_missing_expires_at` → refused with
`audit.registry.freshness_policy_bound_invalid`.

### [D2] Format/kind failures use `audit.registry.freshness_policy_format_invalid`

The R29 design spec does not define a failure code for unrecognized
`format_version` or wrong `kind`. This implementation introduces:

```
audit.registry.freshness_policy_format_invalid
```

Used when:
- `format_version` is not in `["0.1.0"]`
- `kind` is not `"production_audit_startup_freshness_policy"`
- `expires_at` is present but not valid ISO8601

Keeping this separate from `freshness_policy_signature_invalid` prevents
conflating structural document errors with cryptographic verification failures.

### [D3] Direct seconds bypass uses `audit.registry.direct_seconds_override_rejected`

The validator API does not accept a `direct_override_seconds` parameter. Any
caller passing a non-nil value gets an explicit refusal rather than silent
ignoring. This makes the API boundary machine-verifiable.

---

## Proof Matrix (28/28 PASS)

```
ruby igniter-lang/experiments/startup_freshness_override_proof/startup_freshness_override_proof.rb
```

### Accepted cases (6)

| # | Case | Effective bound | Code |
|---|------|----------------|------|
| 1 | `default_no_policy` | 86400s (24h) | `startup_time_default_bound_used` |
| 2 | `tighter_6h_valid` | 21600s (6h) | `startup_time_override_accepted` |
| 3 | `looser_48h_valid` | 172800s (48h) | `startup_time_override_accepted` |
| 4 | `min_bound_1h_valid` | 3600s (1h) — registry stale for 1h | `startup_time_staleness_exceeded` |
| 5 | `min_bound_1h_fresh_registry` | 3600s (1h) — fresh registry | `startup_time_override_accepted` |
| 6 | `max_bound_72h_valid` | 259200s (72h) | `startup_time_override_accepted` |

> Note: Case 4 (`min_bound_1h_valid`) correctly shows that a valid 1h policy
> with a 5h-old registry is refused — the registry is stale under the tighter
> bound. Case 5 (`min_bound_1h_fresh_registry`) shows acceptance with a
> 29-minute-old registry.

### Refused cases (22)

| # | Case | Code |
|---|------|------|
| 6 | `policy_file_missing` | `freshness_policy_missing` |
| 7 | `hash_mismatch` | `freshness_policy_hash_mismatch` |
| 8 | `signature_missing` | `freshness_policy_signature_invalid` |
| 9 | `signature_stub` | `freshness_policy_signature_invalid` |
| 10 | `authority_local` | `freshness_policy_authority_untrusted` |
| 11 | `authority_test` | `freshness_policy_authority_untrusted` |
| 12 | `authority_stub` | `freshness_policy_authority_untrusted` |
| 13 | `authority_ref_mismatch` | `freshness_policy_authority_untrusted` |
| 14 | `expired_policy` | `freshness_policy_expired` |
| 15 | `bound_below_1h` (3599s) | `freshness_policy_bound_invalid` |
| 16 | `bound_above_72h` (259201s) | `freshness_policy_bound_invalid` |
| 17 | `non_integer_bound_string` | `freshness_policy_bound_invalid` |
| 18 | `non_integer_bound_float` | `freshness_policy_bound_invalid` |
| 19 | `looser_missing_reason` | `freshness_policy_bound_invalid` |
| 20 | `looser_missing_expires_at` | `freshness_policy_bound_invalid` |
| 21 | `tighter_missing_expires_at` **[D1]** | `freshness_policy_bound_invalid` |
| 22 | `stale_registry_under_tighter_bound` | `startup_time_staleness_exceeded` |
| 23 | `stale_registry_under_default_bound` | `startup_time_staleness_exceeded` |
| 24 | `anchor_invalid_nil` | `startup_time_anchor_invalid` |
| 25 | `wrong_format_version` **[D2]** | `freshness_policy_format_invalid` |
| 26 | `wrong_kind` **[D2]** | `freshness_policy_format_invalid` |
| 27 | `direct_seconds_env_rejected` **[D3]** | `direct_seconds_override_rejected` |

### Cross-cutting invariant checks (5 additional)

| Check | Result |
|-------|--------|
| All accepted cases carry `audit_registry_startup_freshness_check` report kind | ok |
| All refused cases carry `audit_registry_startup_freshness_refusal` report kind | ok |
| Default case uses 86400s exactly | ok |
| Tighter-6h case uses 21600s exactly | ok |
| Looser-48h case uses 172800s exactly | ok |
| D1: `tighter_missing_expires_at` is refused | ok |
| D3: `direct_seconds_env_rejected` is refused | ok |
| No case enables `production_gate_authority` | ok |
| No production signing required | ok |
| No Ledger accessed | ok |
| No Phase 2 accessed | ok |
| No online lookup | ok |

**Total: 28/28 cases PASS, 12/12 invariant checks PASS.**

---

## Failure Codes Implemented

| Code | Origin | Condition |
|------|--------|-----------|
| `audit.registry.startup_time_default_bound_used` | R29 design | No policy; default 24h in use |
| `audit.registry.startup_time_override_accepted` | R29 design | Valid policy accepted |
| `audit.registry.freshness_policy_missing` | R29 design | Manifest ref present, policy bytes nil |
| `audit.registry.freshness_policy_hash_mismatch` | R29 design | SHA256 of policy bytes ≠ manifest content_hash |
| `audit.registry.freshness_policy_signature_invalid` | R29 design | signature_ref absent, empty, or blocked pattern |
| `audit.registry.freshness_policy_authority_untrusted` | R29 design | Authority is local/test/stub, or manifest ≠ policy authority_ref |
| `audit.registry.freshness_policy_expired` | R29 design | startup_time ≥ policy expires_at |
| `audit.registry.freshness_policy_bound_invalid` | R29 design | Non-integer, out-of-range, >24h missing reason, non-default missing expires_at [D1] |
| `audit.registry.startup_time_staleness_exceeded` | R29 design | registry_age > effective_max_age_seconds |
| `audit.registry.startup_time_anchor_invalid` | R29 design | registry_generated_at nil or invalid ISO8601 |
| `audit.registry.freshness_policy_format_invalid` | **[D2] new** | Unrecognized format_version or wrong kind |
| `audit.registry.direct_seconds_override_rejected` | **[D3] new** | direct_override_seconds non-nil in API call |

---

## Validation Step Order

```
1. Direct seconds bypass guard [D3]
2. If no policy_ref: check registry freshness against default 24h
3. Policy file present?            → freshness_policy_missing
4. SHA256 hash match?              → freshness_policy_hash_mismatch
5. Parse JSON
6. format_version recognized?      → freshness_policy_format_invalid [D2]
7. kind correct?                   → freshness_policy_format_invalid [D2]
8. authority_ref matches manifest? → freshness_policy_authority_untrusted
9. authority_ref not blocked?      → freshness_policy_authority_untrusted
10. signature_ref valid?           → freshness_policy_signature_invalid
11. Policy not expired?            → freshness_policy_expired
12. max_age_seconds is Integer?    → freshness_policy_bound_invalid
13. max_age_seconds in [3600..259200]? → freshness_policy_bound_invalid
14. Non-default → expires_at present? [D1] → freshness_policy_bound_invalid
15. >24h → reason present?         → freshness_policy_bound_invalid
16. Check registry freshness against effective bound
    → startup_time_anchor_invalid | startup_time_staleness_exceeded | accepted
```

---

## Regression

| Proof | Result |
|-------|--------|
| `startup_freshness_override_proof` | **28/28 PASS** (new) |
| `volatile_fields_lint` | PASS — 5 artifacts (was 4; new summary adds 1 valid `_volatile_fields`) |
| `contract_modifiers_proof` | PASS (unchanged) |
| `production_durable_audit_compliance_posture_proof` | 14/14 PASS (unchanged) |
| `production_durable_audit_signer_validation_proof` | 18/18 PASS (unchanged) |

---

## Scope Boundaries

- No production durable audit writer created or modified.
- No production signing execution.
- No production registry implementation.
- No Ledger or Phase 2 access.
- No online lookup or per-invocation fetch.
- Proof-local authority fixtures only; production would require real
  authority registry verification.
- `gate3_authorized: false` in all outputs; no gate authority enabled.

---

## Pre-Production Checklist

| Item | Status |
|------|--------|
| P-29: startup_time override proof-local validator | ✅ **closed** — 28/28 PASS |

---

## Handoff

```text
Card: S3-R30-C2-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: startup-time-freshness-override-validator-v0
Status: done

[D] Decisions
- D1: All non-default policies require expires_at (not only >24h).
  Closes C-1 from S3-R29-X1-S.
- D2: Unrecognized format_version / wrong kind → audit.registry.freshness_policy_format_invalid.
  New code; keeps structural and cryptographic errors distinct.
- D3: direct_override_seconds non-nil → audit.registry.direct_seconds_override_rejected.
  API guard; no silent fallback to raw seconds.

[S] Shipped / Signals
- igniter-lang/experiments/startup_freshness_override_proof/startup_freshness_override_proof.rb
- igniter-lang/experiments/startup_freshness_override_proof/out/startup_freshness_override_proof_summary.json
- igniter-lang/docs/tracks/startup-time-freshness-override-validator-v0.md

[T] Tests / Proofs
- ruby igniter-lang/experiments/startup_freshness_override_proof/startup_freshness_override_proof.rb
  → PASS 28/28 cases, 12/12 invariant checks
- volatile_fields_lint → PASS 5 artifacts (was 4)
- contract_modifiers_proof → PASS (no regression)
- compliance_posture_proof → 14/14 PASS (no regression)
- signer_validation_proof → 18/18 PASS (no regression)

[R] Risks / Recommendations
- D1 (all non-default require expires_at) is stricter than the R29 design spec.
  If the Architect disagrees, the change is isolated to one validation step in
  validate_policy (step 14). The proof case (tighter_missing_expires_at) would
  need to be updated to expected_decision: :accepted.
- D2 (freshness_policy_format_invalid) is a new code not in the R29 design spec.
  The Compiler/Grammar Expert or Architect may choose to absorb it into an
  existing code. The validation step is isolated.
- Proof-local authority validation accepts any non-blocked authority_ref. In
  production, this step MUST verify against a real trusted authority registry or
  equivalent verification metadata. The proof comment makes this explicit.
- The proof uses a fixed PROOF_STARTUP_TIME constant for determinism. A
  production implementation would use the real process startup timestamp.

[Q] Open questions
- Q1: Should the R29 design spec (`startup-time-freshness-override-interface-v0.md`)
  be amended to document D1 (tighter policies require expires_at) and D2 (new
  format_invalid code)? The design track is Research Agent territory; this is
  flagged as a follow-up, not a blocker.
- Q2: Should the two new codes (D2, D3) be added to the failure code table in
  `startup-time-freshness-override-interface-v0.md`? Suggested for the next
  Research Agent or Meta Expert round-close pass.

[Next] Suggested next slice
- R30: V-3 temporal+observed proof golden in contract_modifiers_proof (P-30)
- R30: P28 enforcement gap table — Compiler/Grammar Expert OQ-1 response
- R30: META-EXPERT-013 §VI + PROP Governance Filter reconciliation (P-31)
- R30: PROP-032 (assumptions block) draft — Gap-H HIGH priority (P-32)
- R30: Architect production durable audit implementation authorization (P-28)
```
