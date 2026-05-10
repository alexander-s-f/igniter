# Track: Startup Time Freshness Override Interface v0

Card: S3-R29-C2-P
Agent: `[Igniter-Lang Research Agent]`
Role: `research-agent`
Track: `startup-time-freshness-override-interface-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Purpose

Define the operator-facing override interface for the production durable audit
`startup_time` registry freshness bound.

This is design-only. It does not authorize production durable audit
implementation, production signing execution, registry implementation, Ledger,
Phase 2, or per-invocation online lookup.

---

## Inputs Read

- `production-durable-audit-blocker-amendment-and-validation-proofs-v0.md`
- `r28-durable-audit-and-prop031-pressure-v0.md`
- `stage3-round28-status-curation-v0.md`

---

## Current Fixed Point

R28 defines the default startup freshness rule:

- default maximum staleness: `86_400` seconds / 24 hours;
- measured once at process startup from registry index `generated_at`;
- missing/invalid immutable anchor fails closed with
  `audit.registry.startup_time_anchor_invalid`;
- stale registry index fails closed with
  `audit.registry.startup_time_staleness_exceeded`;
- per-invocation online lookup is not authorized.

R28 pressure identified one remaining design gap: how operators express a
tighter or looser startup freshness bound without turning the value into an
ambient env-var escape hatch.

---

## Decision

Recommended model:

```text
constant default
  + deployment manifest policy_ref
  + bundled authority-signed freshness policy document
  -> startup-only effective bound
```

Direct env-var or local config value MUST NOT set the freshness seconds.

The default remains a constant in the implementation:

```json
{
  "default_max_age_seconds": 86400
}
```

An override is valid only when the deployment manifest points to a bundled,
content-addressed, authority-signed policy document:

```json
{
  "production_audit_registry": {
    "freshness_policy_ref": {
      "uri": "audit-policy://igniter-lang/phase1/startup-freshness/prod-us-east-v1",
      "content_hash": "sha256:...",
      "authority_ref": "architect-supervisor://igniter-lang/production-audit/freshness-policy/v1"
    }
  }
}
```

The referenced policy document carries the effective bound:

```json
{
  "kind": "production_audit_startup_freshness_policy",
  "format_version": "0.1.0",
  "authority_ref": "architect-supervisor://igniter-lang/production-audit/freshness-policy/v1",
  "policy_id": "prod-us-east-v1",
  "issued_at": "2026-05-10T00:00:00Z",
  "expires_at": "2026-06-09T00:00:00Z",
  "max_age_seconds": 21600,
  "reason": "tighter production deployment freshness requirement",
  "signature_ref": "sig://..."
}
```

The implementation may use an environment variable only as a location hint for a
manifest or policy bundle path, never as the authority for the bound itself:

```text
IGNITER_AUDIT_DEPLOYMENT_MANIFEST=/etc/igniter/audit-deployment-manifest.json
```

If this env var is absent, the runtime uses its configured manifest discovery
path and falls back to the built-in 24h bound when no signed policy is present.

---

## Allowed Override Range

| Bound | Decision |
|-------|----------|
| `>= 3600` and `< 86400` seconds | Allowed with valid signed policy and `expires_at`; this tightens the default. |
| `86400` seconds | Default; no policy required. |
| `> 86400` and `<= 259200` seconds | Allowed only with valid signed policy, non-empty reason, and policy expiry. This supports bounded air-gapped/offline deployments. |
| `< 3600` seconds | Refuse. Too tight for reliable startup operations without a separate design decision. |
| `> 259200` seconds | Refuse. More than 72h requires a new Architect decision, not an operator override. |

All accepted overrides MUST be integers in seconds.

Rationale:

- The default 24h value remains simple and safe.
- Tighter deployments can require 1h/6h/12h without code changes.
- Looser deployments can go up to 72h for bounded offline environments, but only
  with explicit signed policy evidence and expiry.
- Anything beyond 72h changes the risk posture enough to need governance review.

---

## Authorization Model

The override authority is the signed policy, not the operator shell and not the
runtime process.

Required validation:

1. Deployment manifest is present and parseable if an override is requested.
2. `freshness_policy_ref.content_hash` matches the bundled policy bytes.
3. Policy `format_version` is recognized.
4. Policy `kind` is `production_audit_startup_freshness_policy`.
5. Policy `authority_ref` exactly matches the manifest `authority_ref`.
6. Policy signature verifies against trusted verification metadata.
7. Policy is not expired at startup.
8. `max_age_seconds` is an integer inside the allowed range.
9. If `max_age_seconds != 86400`, policy has `expires_at`.
10. If `max_age_seconds > 86400`, policy has a non-empty `reason`.

The same process that rejected nil/no-op/stub signers in R28 should reject
local/test/stub policy authorities. A proof-local implementation can reuse the
signer-validation blocked-pattern idea, but production validation MUST use a real
trusted authority registry or equivalent verification metadata.

---

## Fail-Closed Behavior

Invalid override input never silently falls back to a looser bound.

| Case | Behavior | Code |
|------|----------|------|
| No override policy present | Use default 24h. | `audit.registry.startup_time_default_bound_used` observation |
| Override ref present but policy missing | Fail startup closed. | `audit.registry.freshness_policy_missing` |
| Policy hash mismatch | Fail startup closed. | `audit.registry.freshness_policy_hash_mismatch` |
| Policy signature invalid/missing | Fail startup closed. | `audit.registry.freshness_policy_signature_invalid` |
| Authority untrusted / local / stub | Fail startup closed. | `audit.registry.freshness_policy_authority_untrusted` |
| Policy expired | Fail startup closed. | `audit.registry.freshness_policy_expired` |
| Policy format/kind invalid, or `expires_at` not ISO8601 | Fail startup closed. | `audit.registry.freshness_policy_format_invalid` |
| `max_age_seconds` missing/non-integer/out of range, or non-default policy missing `expires_at` | Fail startup closed. | `audit.registry.freshness_policy_bound_invalid` |
| Direct seconds override attempted | Fail startup closed. | `audit.registry.direct_seconds_override_rejected` |
| Registry index older than effective bound | Fail startup closed. | `audit.registry.startup_time_staleness_exceeded` |
| Registry anchor invalid | Fail startup closed. | `audit.registry.startup_time_anchor_invalid` |

Failing startup means:

1. refuse to serve as production gate authority;
2. emit a startup refusal report with the code above;
3. exit non-zero or return an equivalent initialization failure;
4. do not instantiate production durable audit writer/signer surfaces.

---

## Observation Shape

Successful startup emits a report/observation:

```json
{
  "kind": "audit_registry_startup_freshness_check",
  "format_version": "0.1.0",
  "startup_time": "2026-05-10T12:00:00Z",
  "registry_generated_at": "2026-05-10T06:00:00Z",
  "registry_age_seconds": 21600,
  "effective_max_age_seconds": 86400,
  "default_max_age_seconds": 86400,
  "override": {
    "status": "default_used",
    "policy_ref": null
  },
  "decision": "accepted",
  "code": "audit.registry.startup_time_default_bound_used"
}
```

With a valid override:

```json
{
  "kind": "audit_registry_startup_freshness_check",
  "format_version": "0.1.0",
  "startup_time": "2026-05-10T12:00:00Z",
  "registry_generated_at": "2026-05-10T08:00:00Z",
  "registry_age_seconds": 14400,
  "effective_max_age_seconds": 21600,
  "default_max_age_seconds": 86400,
  "override": {
    "status": "accepted",
    "policy_ref": {
      "uri": "audit-policy://igniter-lang/phase1/startup-freshness/prod-us-east-v1",
      "content_hash": "sha256:...",
      "authority_ref": "architect-supervisor://igniter-lang/production-audit/freshness-policy/v1"
    }
  },
  "decision": "accepted",
  "code": "audit.registry.startup_time_override_accepted"
}
```

Refusal reports MUST include:

- `kind: "audit_registry_startup_freshness_refusal"`;
- `code`;
- `startup_time`;
- `default_max_age_seconds`;
- attempted `policy_ref` when present;
- `effective_max_age_seconds` only when a policy validated far enough to compute
  it;
- `registry_generated_at` and `registry_age_seconds` when available;
- `production_gate_authority_enabled: false`.

---

## No Online Lookup Compatibility

This model preserves the R28 no-online-lookup invariant:

- policy bytes are bundled or mounted before process startup;
- the manifest carries a content hash;
- signature and authority validation use local verification metadata available at
  startup;
- the check runs once at startup;
- per-invocation requests never fetch policy or registry state online.

If a deployment wants online refresh or live policy lookup, that is a separate
scope and MUST NOT be smuggled into this override interface.

---

## Rejected Alternatives

| Alternative | Decision | Reason |
|-------------|----------|--------|
| Constant only | Rejected | Too rigid for tighter compliance deployments and bounded offline/air-gapped deployments. |
| Local config field sets seconds directly | Rejected | Makes the freshness bound caller/operator mutable without authority evidence. |
| Env var sets seconds directly | Rejected | Too easy to misconfigure or inject; no durable authority/evidence chain. |
| Deployment manifest entry sets seconds directly | Rejected | Better than env var, but still lacks signed authority and content-addressed policy evidence. |
| Authority-signed policy only, no manifest | Rejected | Operators need a concrete deployment-facing pointer and content hash binding. |

Accepted composition:

```text
built-in default + deployment manifest pointer + authority-signed policy document
```

---

## Optional Proof Matrix For R30

Recommended proof-local validation cases:

| Case | Expected |
|------|----------|
| no policy | accepted with 24h default |
| valid tighter policy, 6h | accepted |
| valid looser policy, 48h, reason + expiry | accepted |
| missing policy file for manifest ref | refused |
| hash mismatch | refused |
| missing signature | refused |
| invalid signature | refused |
| local/test/stub authority | refused |
| expired policy | refused |
| bound below 1h | refused |
| bound above 72h | refused |
| non-integer bound | refused |
| tighter policy missing `expires_at` | refused with `freshness_policy_bound_invalid` |
| wrong `format_version` | refused with `freshness_policy_format_invalid` |
| wrong `kind` | refused with `freshness_policy_format_invalid` |
| stale registry under effective bound | refused with `startup_time_staleness_exceeded` |
| invalid registry anchor | refused with `startup_time_anchor_invalid` |
| env var or API attempts direct seconds | refused with `direct_seconds_override_rejected` |

No proof is added in this card because the requested deliverable is interface
design. The matrix above is intentionally small enough for a proof-local R30
implementation card.

---

## R30 Implementation Recommendation

R30 should implement only a proof-local validator first:

```text
DeploymentManifest
  -> FreshnessPolicyRef
  -> SignedFreshnessPolicy
  -> StartupFreshnessDecision
```

Acceptance should require:

- a deterministic Ruby proof command;
- machine-readable summary JSON;
- all negative cases above;
- no production durable audit writer/signer implementation;
- no online lookup;
- no Ledger;
- no production authority registry implementation beyond proof-local trusted
  authority fixtures.

Only after that proof passes should Architect decide whether this interface is
ready to be part of a production durable audit implementation authorization.

---

## R31 Amendment: Validator Alignment D1/D2/D3

R30 landed the proof-local validator and clarified three design points. This
R31 amendment makes the R29 design match the proof.

### [D1] All Non-Default Policies Require `expires_at`

[D] Any signed freshness policy with:

```text
max_age_seconds != 86400
```

must carry `expires_at`.

This applies to both tighter policies (`< 86400`) and looser policies
(`> 86400`). The previous R29 wording only required expiry for policies looser
than the default. The validator correctly refuses an eternal tighter policy:

```text
tighter_missing_expires_at -> audit.registry.freshness_policy_bound_invalid
```

The default 24h path still needs no policy document and no `expires_at`.

### [D2] Structural Policy Format Failures Have A Dedicated Code

[D] Structural document failures use:

```text
audit.registry.freshness_policy_format_invalid
```

This code covers:

- unrecognized `format_version`;
- wrong `kind`;
- present but non-ISO8601 `expires_at`.

These are not signature failures. Keeping the code separate prevents structural
JSON/schema errors from being confused with cryptographic verification errors.

### [D3] Direct Seconds Override Is Explicitly Rejected

[D] Any direct seconds bypass is refused with:

```text
audit.registry.direct_seconds_override_rejected
```

This includes direct API parameters, direct env-var seconds values, and local
config seconds values. Env vars may point to a manifest or policy bundle path;
they may not carry authority for the freshness bound.

### Proof-Local Boundary Preserved

[D] This amendment does not authorize:

- production durable audit writer implementation;
- production signing execution;
- production authority registry;
- Ledger;
- Phase 2;
- online lookup;
- per-invocation policy fetch.

The design remains proof-local until a separately approved production
implementation card lands.

---

## Handoff

```text
Card: S3-R29-C2-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: startup-time-freshness-override-interface-v0
Status: done

[D] Decisions
- Default startup_time freshness bound remains 24h / 86_400s.
- Override model is deployment manifest policy_ref + bundled authority-signed policy document.
- Direct env-var/config seconds overrides are rejected.
- Allowed range is 1h..72h; >24h requires signed reason + expiry; >72h requires new governance.
- Invalid override fails closed and does not fall back to a looser bound.

[S] Shipped / Signals
- Added operator-facing override design track.
- Defined observation/refusal shapes and error codes.
- Preserved no per-invocation online lookup.

[T] Tests / Proofs
- Design-only card; no proof script added.
- R30 proof matrix is specified.

[R] Risks / Recommendations
- Production implementation remains unauthorized.
- R30 should add a proof-local validator before any production durable audit implementation request.
- Authority verification must be real in production; proof-local trusted authorities are only fixtures.

[Next] Suggested next slice
- Implement `startup_time_freshness_override_validation_proof-v0` with the matrix in this track.
```
