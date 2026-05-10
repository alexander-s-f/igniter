# Startup Freshness Design Amendment D1/D2/D3 v0

Card: S3-R31-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/startup-freshness-design-amendment-d1-d2-d3-v0
Status: done
Date: 2026-05-10

## Goal

Amend the startup freshness design track so it matches the R30 proof-local
validator behavior.

Inputs read:

```text
igniter-lang/docs/tracks/startup-time-freshness-override-interface-v0.md
igniter-lang/docs/tracks/startup-time-freshness-override-validator-v0.md
```

## Amendment

Updated:

```text
igniter-lang/docs/tracks/startup-time-freshness-override-interface-v0.md
```

Added section:

```text
R31 Amendment: Validator Alignment D1/D2/D3
```

## Design Now Matches Proof Checklist

| Validator decision | Design doc status |
| --- | --- |
| D1: all non-default freshness policies require `expires_at` | Matched. Allowed range and validation checklist now require `expires_at` for both tighter and looser policies. |
| D2: structural format/kind failures use `audit.registry.freshness_policy_format_invalid` | Matched. Failure table and amendment define the dedicated format-invalid code. |
| D3: direct seconds bypass uses `audit.registry.direct_seconds_override_rejected` | Matched. Direct API/env/config seconds are explicitly refused with this code. |

## D1 Detail

The previous R29 design required `expires_at` only for policies looser than the
default 24h bound.

The R30 validator proved the stricter rule:

```text
max_age_seconds != 86400 -> expires_at required
```

The design now documents:

```text
tighter_missing_expires_at -> audit.registry.freshness_policy_bound_invalid
```

The built-in default remains unchanged:

```text
default_max_age_seconds: 86400
```

No policy document is required when the default is used.

## D2 Detail

The design now separates structural document failures from signature failures:

```text
audit.registry.freshness_policy_format_invalid
```

Covered conditions:

```text
wrong format_version
wrong kind
expires_at present but not ISO8601
```

This keeps JSON/schema shape errors distinct from:

```text
audit.registry.freshness_policy_signature_invalid
```

## D3 Detail

The design now names the direct seconds bypass refusal:

```text
audit.registry.direct_seconds_override_rejected
```

Direct seconds can come from API params, env vars, or local config. All are
refused. Env vars may only point to a manifest or policy bundle path.

## Proof-Local Boundary

No scope was widened.

This slice does not authorize:

```text
Ledger
Phase 2
online lookup
production signing execution
production durable audit writer
production authority registry
per-invocation policy fetch
```

The design remains proof-local until a separately approved implementation card
lands.

## Verification

```text
git diff --check -- \
  igniter-lang/docs/tracks/startup-time-freshness-override-interface-v0.md \
  igniter-lang/docs/tracks/startup-freshness-design-amendment-d1-d2-d3-v0.md
```

No executable proof was rerun in this card. The amendment aligns design text to
the already-landed R30 validator proof:

```text
startup_freshness_override_proof -> PASS 28/28 cases, 12/12 invariant checks
```

## Changed Files

```text
igniter-lang/docs/tracks/startup-time-freshness-override-interface-v0.md
igniter-lang/docs/tracks/startup-freshness-design-amendment-d1-d2-d3-v0.md
```

## Handoff

```text
Card: S3-R31-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/startup-freshness-design-amendment-d1-d2-d3-v0
Status: done

[D] Decisions
- Amended the R29 startup freshness interface design to match R30 validator behavior.
- D1: all non-default policies require `expires_at`.
- D2: format/kind/invalid `expires_at` structure uses `freshness_policy_format_invalid`.
- D3: direct seconds bypass uses `direct_seconds_override_rejected`.

[S] Shipped / Signals
- Updated the allowed range, authorization checklist, failure-code table, proof matrix, and amendment section.
- Added this R31 track doc with a design/proof alignment checklist.

[T] Tests / Proofs
- `git diff --check` for touched docs -> PASS.
- No executable proof rerun; R30 validator proof remains the source evidence.

[R] Risks / Recommendations
- Keep the boundary proof-local. No Ledger, Phase 2, online lookup, production signing execution, or production durable audit writer is authorized here.
- Future production implementation should use the amended D1/D2/D3 rules exactly.

[Next]
- Production implementation work may consume this design only if separately authorized by Architect.
```
