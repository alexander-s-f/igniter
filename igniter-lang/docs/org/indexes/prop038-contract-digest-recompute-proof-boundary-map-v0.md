# PROP-038 Contract Digest Recompute Proof Boundary Map v0

Status: active orientation map
Owner: [Org Architect Supervisor]
Date: 2026-05-18
Source card: `S3-R70-C0-O`
Authority: orientation only, not canon

---

## Purpose

Keep R70 recompute/canonicalization proof evidence separate from:

```text
live validator implementation
digest authority
compile refusal
public/report surfacing
persisted artifacts
loader/report or CompatibilityReport behavior
runtime or production behavior
```

This map does not authorize code, semantics, gates, proposals, implementation,
compile refusal, public output, report surfacing, loader/report behavior,
CompatibilityReport behavior, runtime behavior, or production behavior.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md
igniter-lang/docs/gates/prop038-contract-digest-validation-policy-decision-v0.md
igniter-lang/docs/tracks/prop038-contract-digest-validation-policy-design-v0.md
igniter-lang/docs/tracks/prop038-contract-digest-shape-policy-proof-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/out/prop038_contract_digest_shape_policy_proof_summary.json
```

---

## Current Authority Snapshot

Latest relevant authority:

```text
igniter-lang/docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md
```

Decision status:

```text
accepted-proof-local-shape-policy-closure
```

Next allowed route:

```text
prop038-contract-digest-recompute-match-proof-v0
```

Boundary:

```text
proof-local recompute/canonicalization model only
no live validator/compiler/orchestrator code edits
no report-only behavior change
no .igapp mutation outside proof-local generated output
no compile refusal
no public API/CLI, CompilerResult, loader/report, CompatibilityReport,
RuntimeMachine, Gate 3, runtime, or production behavior
```

---

## Canonicalization Inputs Accepted As Proof Candidates

R68 design directionally accepted this recompute material for future proof work:

```text
contract object excluding contract_digest
```

Candidate included top-level fields:

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

Important boundary:

```text
These are proof-candidate canonicalization inputs.
They are not live validator implementation authority.
They are not PROP-038 errata.
They are not persisted identity authority.
```

---

## Excluded Fields And Forbidden Ambient Inputs

Candidate excluded fields:

```text
contract_digest
validation result fields
report_only
compiler_integrated
compile_refusal_authorized
provider metadata
source_path
out_path
parsed_program
compiler_profile_source
```

Forbidden ambient inputs:

```text
filesystem descriptor material discovery
loader/report material
CompatibilityReport material
runtime state
Gate 3 state
Ledger/TBackend state
BiHistory state
stream/OLAP state
cache state
production config
wall-clock time
environment variables
CLI flags
public facade input
```

Proof-local recompute must be a pure function of the supplied contract material,
not of ambient project/runtime state.

---

## Order-Sensitive vs Order-Insensitive Material

Order-sensitive candidate material:

```text
slot_order
required_slot_schema.required_slots
required_slot_schema.optional_slots
required_slot_schema.all_slots
```

Reason:

```text
These arrays are treated as declared/profile-significant order in v0 proof
material.
```

Order-insensitive candidate material:

```text
object keys
slot_assignments object keys
strict_registries registry names
strict registry entries, sorted by [key, owner_slot, rule_ref]
ordered_rule_graph.rules, sorted by rule_id
rule before/after edge arrays, sorted unique by rule id
non_authority object keys
```

Reason:

```text
These structures carry identity through key/edge content, not source ordering.
```

R70 proof should keep canonicalization separate from semantic validation:

```text
canonicalization normalizes hash material
validation decides whether contract material is semantically valid
canonicalization must not silently repair invalid references
```

---

## Recompute-Match Candidate Cases

R68 design proposed Phase 2 proof cases:

```text
recompute_full_match
recompute_prefix_match
recompute_full_mismatch
recompute_prefix_mismatch
recompute_unavailable
canonical_excludes_contract_digest
canonical_includes_descriptor_digest_string
canonical_does_not_recompute_descriptor_material
canonical_slot_order_order_sensitive
canonical_object_key_order_insensitive
canonical_strict_registry_order_insensitive
canonical_rule_list_order_insensitive
canonical_rule_edge_set_order_insensitive
canonical_rule_reference_still_validated
```

These are proof-local cases. Passing them should not be read as:

```text
live validator now recomputes digest
contract_digest mismatch now affects compiler outcome
contract_digest is now durable/persisted authority
PROP-038 has been amended
```

---

## Mismatch Diagnostics Are Proof-Local Only

Candidate diagnostic names for recompute proof:

```text
compiler_profile_contract.contract_digest_recompute_unavailable
compiler_profile_contract.contract_digest_mismatch
```

Already shape-proof candidates:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
```

Current boundary:

```text
candidate diagnostics may appear in proof-local model/summary
candidate diagnostics must not be added to live validator yet
candidate diagnostics must not be appended to top-level report["diagnostics"]
candidate diagnostics must not be centralized in IgniterLang::Diagnostics
candidate diagnostics must not affect compiler pass_result/stages/status
```

If later implemented, intended nested location remains:

```text
report["compiler_profile_contract_validation"]["diagnostics"]
```

That future placement still requires separate implementation authority.

---

## Non-Authority Surfaces

Unless a later Architect gate explicitly opens them, R70 proof evidence must not
affect:

```text
CompilerProfileContractValidator live behavior
CompilerOrchestrator live behavior
CompilationReport live behavior
CompilerResult or public_result
public API / CLI
parser / classifier / TypeChecker / SemanticIR
assembler / .igapp artifacts
persisted success reports
sidecar JSON
loader/report
CompatibilityReport
IgniterLang::Diagnostics
receipts / .ilk / signing
dispatch migration
RuntimeMachine / Gate 3
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

Compact rule:

```text
recompute proof may demonstrate canonicalization mechanics;
it must not create digest authority.
```

---

## Proof Acceptance Questions

Before accepting any R70 recompute proof, check:

```text
1. Did it stay proof-local?
2. Did it avoid editing live validator/compiler/report/runtime files?
3. Did it use contract object excluding contract_digest as material?
4. Did it exclude validation result fields and ambient inputs?
5. Did it prove full and prefix match cases separately?
6. Did it prove mismatch cases separately?
7. Did it prove unavailable capability without implying refusal?
8. Did it prove object-key order insensitivity?
9. Did it prove slot_order sensitivity?
10. Did it prove registry/rule order normalization?
11. Did it prove descriptor_digest string inclusion without descriptor material
    recomputation?
12. Did it prove canonicalization does not hide invalid rule references?
13. Did it preserve shape-proof/R67 non-authority signals?
14. Did it avoid public output, persisted report, sidecar, .igapp mutation,
    loader/report, CompatibilityReport, runtime, and production surfaces?
```

---

## Future Route Separation

Recommended sequence remains:

```text
R69: shape-only proof accepted
R70: recompute/canonicalization proof-local evidence
later: Architect decision on recompute proof acceptance
later: possible PROP-038 errata after proof vocabulary stabilizes
later: possible live validator implementation authorization
later: possible report-only digest integration acceptance
much later: possible compile-refusal gate, if ever
```

No future agent should skip from R70 proof-local evidence directly to live
validator code, public surfacing, or refusal behavior.

---

## Return Summary

R70 may prove canonicalization and declared-vs-recomputed digest behavior only in
a proof-local model. The accepted candidate material is the contract object
excluding `contract_digest`; ambient runtime/project inputs are forbidden.

The compact rule:

```text
prove recompute mechanics locally; do not create digest authority
```
