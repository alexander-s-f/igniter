# PROP-038 Contract Digest Policy Map v0

Status: active orientation map
Owner: [Org Architect Supervisor]
Date: 2026-05-17
Source card: `S3-R68-C0-O`
Authority: orientation only, not canon

---

## Purpose

Give the main compiler/profile lane a compact map for PROP-038 digest policy.
The goal is to keep these ideas separate:

```text
descriptor digest
finalization payload digest
contract digest
shape validation
recomputation
mismatch validation
canonicalization
authority effect
```

This map does not authorize semantics, implementation, gate changes, proposal
changes, compile refusal, persisted artifacts, loader/report behavior,
CompatibilityReport behavior, runtime behavior, or production behavior.

---

## Read Set

```text
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
igniter-lang/docs/gates/prop038-library-validator-extraction-acceptance-decision-v0.md
igniter-lang/docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md
igniter-lang/docs/discussions/prop038-library-validator-extraction-design-pressure-v0.md
igniter-lang/docs/discussions/prop038-report-only-compiler-integration-implementation-pressure-v0.md
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
```

---

## Current Digest Fields And Owners

| Field | PROP-038 meaning | Current validator behavior | Current owner | Authority effect |
| --- | --- | --- | --- | --- |
| `descriptor_digest` | Reference to the compiler profile descriptor | Shape-only regex: `compiler_profile_descriptor/sha256:<24+ lowercase hex>` | Contract object carries string; validator checks shape | No runtime/loader/compile authority |
| `finalization_payload_digest` | Digest over canonicalized finalization payload material, excluding derived profile id | Full SHA-256 shape regex: `sha256:<64 lowercase hex>` | Contract object carries string; validator checks shape | No runtime/loader/compile authority |
| `contract_digest` | Reference to canonical contract object, excluding `contract_digest` itself | Deferred: no current validator check | Contract object declares field; no current enforcement | No authority effect yet |

Current implementation point:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
```

Current accepted policy:

```text
digest_reference_policy: :prop038_24_plus
descriptor_digest: shape-only, 24+ lowercase hex after namespaced prefix
finalization_payload_digest: shape-only, full 64 lowercase hex after sha256:
contract_digest: deferred
```

---

## Current Non-Authority Digest Rules

Accepted R65/R67 behavior:

```text
descriptor_digest shape validity != descriptor material verified
finalization_payload_digest shape validity != finalization payload recomputed
contract_digest present in proposal schema != currently validated
valid compiler_profile_contract != compile refusal
valid compiler_profile_contract != loader/report acceptance
valid compiler_profile_contract != CompatibilityReport readiness
valid compiler_profile_contract != runtime/production authority
```

R67 report-only integration may attach validation information to an internal
in-memory `CompilationReport` field, but invalid digest shape still does not
drive compiler outcome.

---

## Deferred Digest Questions

The following are still held unless a future Architect decision opens them:

```text
descriptor material ownership
descriptor canonical serialization
descriptor digest recomputation
descriptor digest mismatch diagnostics
contract object canonical material
contract canonical serialization
contract_digest format validation
contract_digest mismatch validation
short 24+ reference vs full 64 reference policy for durable/persisted contexts
where a persisted contract object would live
whether digest validation can affect report-only status, loader/report,
CompatibilityReport, receipts, .ilk, .igapp, runtime, or production behavior
```

Currently not authorized diagnostic codes:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_mismatch
```

Still not extracted/authorized in the current validator:

```text
compiler_profile_contract.unknown_owner_slot
compiler_profile_contract.unknown_rule_owner_slot
```

---

## Mixing Risks

### Shape Validation vs Recomposition

Shape validation answers:

```text
Does this string look like an accepted digest reference?
```

Recomputation answers:

```text
Does this digest match canonical material we own and can serialize?
```

Risk:

```text
A future card says "validate digest" but does not say which level.
```

Required clarification:

```text
shape_only | recompute | mismatch_check
```

### Descriptor Digest vs Contract Digest

Descriptor digest identifies descriptor material. Contract digest identifies the
contract object. They have different canonical material and different exclusion
rules.

Risk:

```text
Using descriptor canonicalization rules for contract_digest.
```

Required clarification:

```text
digest_subject=descriptor | finalization_payload | contract
```

### Short Reference vs Full Digest

Current proof/report-only lane accepts 24+ lowercase hex for namespaced digest
references, while finalization payload requires a full 64-character SHA-256.

Risk:

```text
Proof-era 24+ policy leaks into durable/persisted/signing contexts.
```

Required clarification:

```text
reference_length_policy=proof_24_plus | durable_full64
```

### Mismatch Validation vs Authority

Mismatch validation can be informational or refusing. Those are different
authority levels.

Risk:

```text
contract_digest_mismatch accidentally changes pass_result, report status,
CompatibilityReport, loader/report, or runtime readiness.
```

Required clarification:

```text
authority_effect=informational | report_only | refusal | loader_ready | runtime_ready
```

---

## Surfaces That Must Remain Non-Authority

Unless later Architect approval explicitly opens them, digest checks must not
affect:

```text
compiler pass_result
compiler stages
CompilerResult.status
CompilerResult.public_result
assembler execution
.igapp manifest/artifacts
persisted success .compilation_report.json
sidecar JSON
loader/report status
CompatibilityReport
receipts
.ilk
signing
dispatch migration
RuntimeMachine / Gate 3
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

The safe current rule:

```text
digest result may inform internal validation data;
digest result must not decide compiler/runtime authority.
```

---

## Suggested Labels For C1-P1

C1-P1 may consider using labels like these to keep policy dimensions explicit:

```text
digest_subject:
  descriptor
  finalization_payload
  contract

validation_level:
  shape_only
  recompute
  mismatch_check

reference_length_policy:
  proof_24_plus
  full64

canonical_material_owner:
  caller_supplied
  provider_supplied
  compiler_derived
  artifact_derived
  unresolved

canonicalization_status:
  unspecified
  proposed
  accepted
  implemented

authority_effect:
  none
  internal_report_only
  public_report
  compile_refusal
  loader_report
  compatibility_report
  runtime_authority
  production_authority
```

For the current accepted lane, the compact label would be:

```text
descriptor_digest:
  digest_subject=descriptor
  validation_level=shape_only
  reference_length_policy=proof_24_plus
  canonical_material_owner=unresolved
  canonicalization_status=unspecified
  authority_effect=internal_report_only at most

finalization_payload_digest:
  digest_subject=finalization_payload
  validation_level=shape_only
  reference_length_policy=full64
  canonical_material_owner=caller_supplied
  canonicalization_status=not_recomputed
  authority_effect=internal_report_only at most

contract_digest:
  digest_subject=contract
  validation_level=deferred
  reference_length_policy=unresolved
  canonical_material_owner=unresolved
  canonicalization_status=unspecified
  authority_effect=none
```

These labels are suggestions only, not governance or specification.

---

## Future Gate Questions

Before any contract digest policy implementation, a future gate should answer:

```text
1. Is the next step shape-only, recomputation, or mismatch validation?
2. Which digest subject is in scope?
3. What exact canonical material is hashed?
4. Which fields are excluded from the canonical material?
5. Who owns or supplies canonical material?
6. Is 24+ lowercase hex still accepted, or is full64 required?
7. Which diagnostic codes are authorized?
8. Is the result informational, internal report-only, public report, or refusal?
9. Are persisted artifacts, sidecars, loader/report, CompatibilityReport,
   receipts, .ilk, signing, runtime, or production still closed?
10. What proof cases demonstrate non-authority or the newly authorized authority?
```

---

## Return Summary

PROP-038 currently has three digest fields but only two are actively shape-checked:
`descriptor_digest` and `finalization_payload_digest`. `contract_digest`
validation, recomputation, mismatch diagnostics, and canonicalization rules remain
deferred.

The core risk is vocabulary collapse: "validate digest" can mean string shape,
canonical recomputation, mismatch comparison, persisted identity, or authority.
Future cards should name the digest subject, validation level, canonical material
owner, reference length policy, and authority effect before any implementation.
