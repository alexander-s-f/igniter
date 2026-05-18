# PROP-038 Contract Digest Live Validator Implementation Boundary Map v0

Status: active-orientation
Owner: [Org Architect Supervisor]
Source card: `S3-R74-C0-O`
Date: 2026-05-18
Authority: orientation only / non-authority

This map helps R74 agents distinguish the authorized validator-only
implementation slice from compiler/orchestrator integration, compile refusal,
public/report surfacing, persisted artifacts, and production authority.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-contract-digest-live-implementation-design-decision-v0.md
igniter-lang/docs/gates/prop038-contract-digest-errata-acceptance-decision-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
igniter-lang/docs/tracks/stage3-round73-status-curation-v0.md
```

---

## Current Authority Snapshot

R73 accepted the live implementation design and authorized exactly one bounded
internal validator implementation route:

```text
prop038-contract-digest-live-validator-implementation-v0
```

Authorized owner:

```text
IgniterLang::CompilerProfileContractValidator
```

Authorized shape:

```text
one bounded internal validator slice
```

Validator API must remain:

```ruby
validate(contract, digest_reference_policy: :prop038_24_plus)
```

Validator result shape must remain:

```text
existing result fields only
```

This org map is not the authorization. Authority remains in the R73 gate
decision.

---

## Exact C1-I Write Scope

R74-C1-I may edit only:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json
igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/
igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/
igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/
igniter-lang/docs/tracks/prop038-contract-digest-live-validator-implementation-v0.md
```

Stop condition:

```text
If implementation needs any file outside this list, stop and request a widened
Architect decision.
```

Proof-local summaries and expected matrices may be updated only inside the
authorized experiment directories.

---

## Allowed Validator Behavior

Allowed inside the validator only:

```text
add contract_digest shape validation
support exactly digest_reference_policy: :prop038_24_plus
recompute canonical contract digest under R70/R72 canonicalization rules
compare declared digest prefix against recomputed full SHA-256 hex
emit the four accepted contract_digest diagnostics
keep canonicalization helpers private/internal
avoid mutating caller-supplied contract material
```

Accepted diagnostics:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

Allowed standard-library requires:

```ruby
require "digest"
require "json"
```

These must remain Ruby standard library usage and must not create gem
dependencies.

---

## Canonicalization Rules To Preserve

Canonical material:

```text
contract object excluding contract_digest
```

Included fields:

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

Excluded fields:

```text
contract_digest
validation result fields
report_only
compiler_integrated
compile_refusal_authorized
provider metadata
source_path / out_path
parsed_program
compiler_profile_source
```

Ordering behavior:

```text
object keys sort recursively
slot_order remains order-sensitive
strict registry names and entries are order-insensitive
ordered-rule list order is order-insensitive
before/after edge arrays are sorted unique sets
descriptor_digest is included as a string field value
descriptor material is not fetched or recomputed
```

Hazard: `descriptor_digest` and `contract_digest` are separate identities.
The validator may include the descriptor digest string in canonical contract
material, but it must not fetch or recompute descriptor material.

---

## Proof Matrix Requirements

Validator proof must include at least:

```text
existing 13-case validator parity remains PASS

shape-policy:
  valid_short_contract_digest
  valid_full_contract_digest
  missing_contract_digest
  contract_digest_wrong_namespace
  contract_digest_too_short
  contract_digest_non_hex
  contract_digest_uppercase_hex
  unsupported_digest_policy

recompute:
  recompute_full_match
  recompute_prefix_match
  recompute_full_mismatch
  recompute_prefix_mismatch
  recompute_unavailable

canonicalization:
  canonical_excludes_contract_digest
  canonical_includes_descriptor_digest_string
  canonical_does_not_recompute_descriptor_material
  canonical_slot_order_order_sensitive
  canonical_object_key_order_insensitive
  canonical_strict_registry_order_insensitive
  canonical_rule_list_order_insensitive
  canonical_rule_edge_set_order_insensitive
  canonical_rule_reference_still_validated

guards:
  validation does not mutate caller contract material
  no new top-level validator result fields
  compiler_integrated=false
  compile_refusal_authorized=false
```

Report-only integration proof must show:

```text
digest diagnostics appear only under
  compiler_profile_contract_validation.diagnostics
digest diagnostics do not append to top-level report["diagnostics"]
compile status unchanged
pass_result unchanged
stages unchanged
public result unchanged
assembler execution unchanged
.igapp unchanged
refusal-report behavior unchanged
nil/non-Hash/provider-error paths remain no-field/no-refusal
CompilerResult unchanged
```

---

## Required Command Matrix

```bash
ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby -c igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
ruby -c igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
ruby -c igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
```

Optional broader proof commands are confidence checks only. If they become
necessary because a disallowed compiler path was touched, implementation should
stop for new authorization.

---

## Surfaces That Remain Closed

Closed in R74:

```text
compiler/orchestrator integration
compile refusal
public API or CLI widening
CompilerResult changes
persisted success reports or sidecars
parser / TypeChecker / SemanticIR changes
assembler or .igapp mutation
loader/report behavior
CompatibilityReport behavior
IgniterLang::Diagnostics centralization
.ilk
receipts
signing
dispatch migration
RuntimeMachine
Gate 3 widening
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

Closed fixture/artifact moves:

```text
.igapp manifest or golden mutation
existing compiler golden migration
persisted success report or sidecar creation
loader/report fixture mutation
CompatibilityReport fixture mutation
```

---

## Pressure Hazards For C2-X

C2-X should pressure-test:

```text
1. Write-scope drift:
   Did C1-I touch any file outside the exact authorized list?

2. API drift:
   Did validate(contract, digest_reference_policy: :prop038_24_plus) change?

3. Result-shape drift:
   Did the validator add new top-level result fields?

4. Diagnostic drift:
   Are only the four accepted contract_digest diagnostics added?

5. Policy drift:
   Is :prop038_24_plus the only supported digest reference policy?

6. Canonicalization drift:
   Do included/excluded fields and ordering rules match R70/R72?

7. Descriptor fetch drift:
   Did implementation fetch/recompute descriptor material instead of using the
   descriptor_digest string value?

8. Mutation drift:
   Does validation leave caller-supplied contract material unchanged?

9. Report/public leakage:
   Did any diagnostic leak into top-level diagnostics, public result,
   CompilerResult, persisted reports, .igapp, loader/report, or
   CompatibilityReport?

10. Refusal creep:
    Did digest validation change compile outcome or refusal-report behavior?

11. Dependency creep:
    Were only Ruby standard-library `digest` and `json` required?

12. Proof incompleteness:
    Did all required command and proof matrices run and record PASS?

13. Helper-name authority creep:
    Are helper names treated as private implementation detail, not canon?

14. Half-policy risk:
    Did the implementation accidentally enforce shape without recompute, or
    recompute without preserving report-only/no-refusal invariants?
```

---

## One-Line Handoff

Implement digest validation inside the validator only; do not let it become
compiler authority.
