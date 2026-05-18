# PROP-038 Contract Digest Errata Canon Sync Boundary Map v0

Status: active orientation map
Owner: [Org Architect Supervisor]
Date: 2026-05-18
Source card: `S3-R72-C0-O`
Authority: orientation only, not canon

---

## Purpose

Keep R72 PROP-038 errata/design authoring distinct from:

```text
live validator implementation
compiler authority
compile refusal
public/report surfacing
persisted artifacts
loader/report or CompatibilityReport behavior
runtime or production behavior
```

This map does not authorize code, semantics beyond orientation, gates,
proposals, implementation, compile refusal, public output, persisted output,
loader/report behavior, CompatibilityReport behavior, runtime behavior, or
production behavior.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md
igniter-lang/docs/gates/prop038-contract-digest-recompute-match-proof-decision-v0.md
igniter-lang/docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
igniter-lang/docs/tracks/stage3-round71-status-curation-v0.md
```

---

## Current Authority Snapshot

Latest relevant authority:

```text
igniter-lang/docs/gates/prop038-contract-digest-report-only-integration-proof-decision-v0.md
```

Decision status:

```text
accepted-proof-local-report-only-integration-closure
```

Next allowed route:

```text
prop038-contract-digest-errata-authoring-v0
```

Allowed:

```text
update or draft PROP-038 errata/design text
cite R69/R70/R71 proof summaries and gate decisions
define diagnostic vocabulary and report-only placement
describe canonicalization/recompute policy as design language
```

Not allowed:

```text
code implementation
live validator/compiler behavior
compile refusal
public API/CLI widening
.igapp mutation
loader/report or CompatibilityReport behavior
RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
production behavior
```

---

## Accepted Proof Chain For Design Purposes

The proof-local `contract_digest` chain is accepted as complete for design
purposes:

| Phase | Round | Result | Design value |
| --- | --- | --- | --- |
| Shape policy | R69 | 8 cases / 19 checks PASS | stable shape and policy candidate names |
| Recompute/canonicalization | R70 | 14 cases / 15 checks PASS | stable canonical material and mismatch candidate names |
| Report-only integration | R71 | 12 cases / 21 checks PASS | stable nested report-only transport of all four codes |

This chain is sufficient for PROP-038 errata/design authoring.

This chain is not:

```text
live validator implementation authorization
compile refusal authorization
public API/CLI authorization
loader/report or CompatibilityReport authorization
production authority
```

---

## Exact Digest Vocabulary To Sync

Errata/design text may sync the four-code `contract_digest_*` vocabulary:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

Recommended meanings:

| Code | Meaning | Proof phase |
| --- | --- | --- |
| `contract_digest_invalid` | Missing or malformed `compiler_profile_contract/sha256:<24+ lowercase hex>` reference | R69 shape |
| `contract_digest_policy_unsupported` | Selected digest reference policy is unsupported | R69 shape |
| `contract_digest_mismatch` | Declared digest does not match recomputed canonical contract digest | R70 recompute |
| `contract_digest_recompute_unavailable` | Recompute policy selected but canonicalization/recompute capability is unavailable | R70 recompute |

Boundary:

```text
These are accepted for errata/design vocabulary.
They are not yet accepted for live validator implementation.
```

---

## Canonicalization Text Boundary

Errata/design text may describe canonicalization policy as design language:

```text
contract_digest identifies the canonical contract object
canonical material is the contract object excluding contract_digest
descriptor_digest participates as a string field value
descriptor material is not fetched or recomputed
```

Accepted included fields for design wording:

```text
kind
format_version
profile_namespace
profile_kind
compiler_profile_id
descriptor_digest
finalization_payload_digest
required_slot_schema
slot_order
slot_assignments
strict_registries
ordered_rule_graph
non_authority
```

Accepted excluded fields for design wording:

```text
contract_digest
validation result fields
report_only
compiler_integrated
compile_refusal_authorized
provider metadata
source/out paths
parsed program
compiler profile source transport
```

Hazard:

```text
Do not write canonicalization text as if live code already implements it.
```

---

## Report-Only Text Boundary

Errata/design text may state that future digest diagnostics, if implemented
under the accepted report-only shape, belong under:

```text
report["compiler_profile_contract_validation"]["diagnostics"]
```

and not under:

```text
top-level report["diagnostics"]
IgniterLang::Diagnostics
CompilerResult.public_result
CLI output
loader/report status
CompatibilityReport
```

The text should preserve:

```text
digest diagnostics do not change compile status
digest diagnostics do not change pass_result
digest diagnostics do not change stages
digest diagnostics do not block assembler execution
digest diagnostics do not mutate .igapp
digest diagnostics do not write refusal reports
digest diagnostics do not change public result
```

---

## Still-Closed Surfaces

R72 errata/design authoring must preserve closure of:

```text
live validator/compiler implementation
compile refusal
public API/CLI widening
CompilerResult changes
persisted success reports or sidecars
parser / TypeChecker / SemanticIR
assembler / .igapp mutation
loader/report behavior
CompatibilityReport behavior
IgniterLang::Diagnostics centralization
receipts / .ilk / signing
dispatch migration
RuntimeMachine / Gate 3 widening
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

Compact rule:

```text
sync canon text; do not imply implementation.
```

---

## Recommended C1/C2 Review Hazards

### C1 Authoring Hazards

Check that the errata/design text does not:

```text
change PROP-038 status into implementation-ready
claim the live validator checks contract_digest today
claim digest mismatch can refuse compilation
move diagnostics into top-level report["diagnostics"]
centralize diagnostics in IgniterLang::Diagnostics
surface digest diagnostics in CompilerResult/public CLI
imply loader/report or CompatibilityReport behavior
imply runtime/production readiness
silently require full64 where proof policy still accepts 24+ references
erase the shape-only vs recompute-match distinction
```

### C2 Pressure Hazards

Pressure review should ask:

```text
Does the errata cite R69/R70/R71 evidence precisely?
Does it mark the proof chain as design-supporting, not implementation authority?
Are all four diagnostic meanings correct and namespace-local?
Is canonical material described without ambient inputs?
Is report-only placement nested and non-refusal?
Are live implementation, public surfaces, loader/report, CompatibilityReport,
runtime, Gate 3, and production still closed?
Does the text stay compact enough to reduce context load rather than add more
archaeology?
```

---

## Future Route Separation

Recommended sequence:

```text
R72: PROP-038 errata/design authoring and pressure
later: Architect decision on errata acceptance
later: possible design-only live validator implementation route
later: possible bounded implementation authorization
later: possible report-only live implementation acceptance
much later: possible compile-refusal gate, if ever
```

No future agent should treat R72 errata/design authoring as live implementation
or product/demo capability.

---

## Return Summary

R72 may sync PROP-038 text with the accepted R69/R70/R71 proof chain. It should
add or amend vocabulary/canonicalization/report-only design language, while
keeping live implementation, refusal, public/report surfacing, runtime, and
production authority closed.

The compact rule:

```text
canon-sync the proof; do not ship the behavior
```
