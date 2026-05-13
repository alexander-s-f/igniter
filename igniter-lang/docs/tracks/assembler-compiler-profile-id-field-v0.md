# Track: Assembler Compiler Profile ID Field v0

Card: S3-R42-C9-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `assembler-compiler-profile-id-field-v0`
Route: UPDATE
Status: done
Date: 2026-05-13

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Architect Supervisor / Codex]`, `[Igniter-Lang Research Agent]`

---

## Goal

Implement the bounded PROP-036 assembler-only `compiler_profile_id` manifest
field as authorized by S3-R42-C8-A, with the source-contract blocker closed
by `minimal-compiler-profile-finalization-proof-v0` (22/22 PASS).

---

## Inputs Read

- `docs/gates/prop036-assembler-field-implementation-reconsideration-v0.md` (C8-A)
- `docs/tracks/minimal-compiler-profile-finalization-proof-v0.md` (C7-I)
- `experiments/minimal_compiler_profile_finalization_proof/out/minimal_compiler_profile_finalization_summary.json`
- `docs/tracks/prop036-source-contract-code-surface-survey-v0.md` (C5-P1)
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`

---

## Production Code Changed

```text
lib/igniter_lang/assembler.rb
```

**No other production files changed.** `CompilerOrchestrator` is unchanged.

---

## Implementation Summary

### Constants Added (class level)

```ruby
PROFILE_SOURCE_KIND       = "compiler_profile_id_source"
PROFILE_SOURCE_NAMESPACE  = "compiler_profile_unified"
PROFILE_SOURCE_ID_PATTERN = /\Acompiler_profile_unified\/sha256:[0-9a-f]{24,}\z/
PROFILE_SOURCE_SLOT_ORDER = %w[
  core oof_registry fragment_registry escape_boundary contract_modifiers
  temporal stream olap invariant assumptions evidence_observation pipeline
].freeze
```

### Method Signatures Changed

```ruby
# Before:
def assemble_case(case_name)
def assemble_artifacts(case_name:, report:, semantic_ir:, target_dir:)
def build_artifact(case_name, report, semantic_ir)          # private

# After (backward-compatible — nil default preserves legacy behavior):
def assemble_case(case_name, compiler_profile_source: nil)
def assemble_artifacts(case_name:, report:, semantic_ir:, target_dir:, compiler_profile_source: nil)
def build_artifact(case_name, report, semantic_ir, compiler_profile_source: nil)  # private
```

### New Private Method

```ruby
def validate_compiler_profile_source!(case_name, source)
```

Validates the `compiler_profile_id_source` object per C4-P1 + C8-A contracts.
Raises `AssemblyRefused` with `compiler_profile_source.*` reason text on any
invalid input. Does not emit loader status values.

### Hash Ordering in `build_artifact`

```ruby
# 1. validate_compiler_profile_source! runs first (raises if invalid)
compiler_profile_id = if compiler_profile_source
  validate_compiler_profile_source!(case_name, compiler_profile_source)
  compiler_profile_source.fetch("compiler_profile_id")
end

artifact_material = {
  "semantic_ir_program"    => semantic_ir,
  "contracts"              => contracts,
  ...
  "compatibility_metadata" => compatibility_metadata
}
# 2. compiler_profile_id injected BEFORE Canonical.hash is called
artifact_material["compiler_profile_id"] = compiler_profile_id if compiler_profile_id

# 3. artifact_hash computed over profiled material
artifact_hash = Canonical.hash(artifact_material)

# 4. top-level manifest field set from source (never from artifact_material after hash)
manifest["compiler_profile_id"] = compiler_profile_id if compiler_profile_id
```

Adding `compiler_profile_id` after `Canonical.hash` is structurally impossible
in this implementation.

### Legacy Behavior Preserved

When `compiler_profile_source: nil` (default):
- `artifact_material` does not contain `compiler_profile_id`;
- `artifact_hash` is computed over un-profiled material (same as before);
- `manifest.compiler_profile_id` is absent;
- no existing `.igapp` golden or fixture is changed.

---

## Proof Produced

```text
experiments/assembler_compiler_profile_id_field/
  assembler_compiler_profile_id_field.rb
  out/assembler_compiler_profile_id_field_summary.json
```

---

## Proof Matrix

### Assembly cases

| Case | Input | Expected result |
| --- | --- | --- |
| A1. legacy assembly | no source | `manifest.compiler_profile_id` absent |
| A2. profiled assembly | valid canonical source | top-level `manifest.compiler_profile_id` present and equals source id |
| A3. hash ordering proof | compare legacy vs profiled hashes | `artifact_hash` differs (profile_id is in hash material) |
| A4. profile id change changes hash | canonical vs altered source | `artifact_hash` differs across both assemblies |
| A5. post-hash annotation not produced | structural proof via A2+A3 | field present AND hash changed → only possible if field was in material before hash |

### Refusal cases (all raise `AssemblyRefused`)

| Case | Input | Reason code fragment |
| --- | --- | --- |
| R1. non-hash source | `"not_a_hash"` string | `compiler_profile_source.malformed` |
| R2. wrong kind | `kind = "compiler_profile_unified"` | `compiler_profile_source.wrong_kind` |
| R3. unfinalized status | `status = "draft"` | `compiler_profile_source.unfinalized` |
| R4. unsupported namespace | `profile_namespace = "compiler_profile_legacy"` | `compiler_profile_source.unsupported_namespace` |
| R5. malformed id | `compiler_profile_id = "not-a-profile-id"` | `compiler_profile_source.malformed_id` |
| R6. digest mismatch | wrong `finalization_payload_digest` | `compiler_profile_source.id_digest_mismatch` |
| R7. slot order mismatch | first two slots swapped | `compiler_profile_source.slot_order_mismatch` |
| R8. runtime authority true | `runtime_authority_granted: true` | `compiler_profile_source.runtime_authority_forbidden` |
| R9. dispatch migration true | `dispatch_migration_authorized: true` | `compiler_profile_source.dispatch_migration_forbidden` |

### Loader status

| Case | Expected |
| --- | --- |
| L1. no loader status values | manifest JSON contains none of: `absent_legacy`, `present_verified`, `mismatch`, `malformed`, `missing_required` |

### Invariants

| Invariant | Expected |
| --- | --- |
| INV1. legacy hash stable | legacy `artifact_hash` has `sha256:<64-hex>` format |
| INV2. manifest field matches source | `manifest.compiler_profile_id == source.compiler_profile_id` |
| INV3. artifact hash format valid | all three assemblies have valid `sha256:<64-hex>` artifact_hash |
| INV4. no golden mutation | existing igapp_assembler_proof golden hash unchanged |

---

## Command Matrix

```text
ruby igniter-lang/lib/igniter_lang/assembler.rb  → Syntax OK   (ruby -c)
ruby igniter-lang/experiments/assembler_compiler_profile_id_field/assembler_compiler_profile_id_field.rb
                                                 → PASS (19/19)
ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb
                                                 → PASS (existing proof, no regression)
```

Observed checks:

```text
A1.legacy_assembly_omits_field        → PASS
A2.profiled_assembly_emits_field      → PASS
A3.hash_ordering_proof                → PASS
A4.profile_id_change_changes_hash     → PASS
A5.post_hash_annotation_not_produced  → PASS
R1.non_hash_source_refused            → PASS
R2.wrong_kind_refused                 → PASS
R3.unfinalized_status_refused         → PASS
R4.unsupported_namespace_refused      → PASS
R5.malformed_id_refused               → PASS
R6.digest_mismatch_refused            → PASS
R7.slot_order_mismatch_refused        → PASS
R8.runtime_authority_refused          → PASS
R9.dispatch_migration_refused         → PASS
L1.no_loader_status_values            → PASS
INV1.legacy_hash_stable               → PASS
INV2.manifest_field_matches_source    → PASS
INV3.artifact_hash_format_valid       → PASS
INV4.no_golden_mutation               → PASS
```

All 19/19 PASS.

---

## Non-Authorizations Preserved

```text
compiler_orchestrator_changes:           false
existing_igapp_golden_migration:         false
loader_report_status_implementation:     false
compatibility_report_changes:            false
ilk_changes:                             false
compilation_receipt_links:               false
signing:                                 false
compiler_dispatch_migration:             false
runtime_machine_binding:                 false
gate3_widening:                          false
ledger_tbackend_binding:                 false
bihistory_live_execution:                false
stream_olap_production:                  false
production_cache:                        false
production_deployment:                   false
```

---

## Remaining Blockers Before Orchestrator Wiring or Golden Migration

[R] These remain separate future decisions:

1. **Orchestrator wiring**: `CompilerOrchestrator#compile` currently passes no
   `compiler_profile_source:` to `assemble_artifacts`. A future card must define
   how the orchestrator obtains a finalized source object (from where, when) and
   passes it. That card requires its own Architect authorization.

2. **Loader/report implementation**: `loader-compiler-profile-status-report-v0`
   is a separate surface. The five status values (`absent_legacy`,
   `present_verified`, `mismatch`, `malformed`, `missing_required`) remain
   unimplemented.

3. **Golden migration**: `artifact-hash-profile-id-golden-migration-v0` requires
   an explicit fixture list and expected hash churn. No existing `.igapp` golden
   is migrated here.

4. **CompatibilityReport**: compiler-profile section remains unimplemented.

5. **CompilationReceipt manifest links**: out of scope.

6. **`.ilk` profile references**: out of scope.

7. **Signing and production verification**: out of scope.

8. **Compiler dispatch migration**: out of scope.

---

## Handoff

```text
Card: S3-R42-C9-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: assembler-compiler-profile-id-field-v0
Status: done

[D] Decisions
- compiler_profile_source: nil keyword added to assemble_case,
  assemble_artifacts, and build_artifact (private).
- validate_compiler_profile_source! validates source shape per C4-P1/C8-A.
- compiler_profile_id injected into artifact_material BEFORE Canonical.hash.
- manifest.compiler_profile_id emitted only when valid source is supplied.
- Legacy nil-source behavior: no field, no hash change, no golden mutation.
- CompilerOrchestrator unchanged.

[S] Shipped / Signals
- lib/igniter_lang/assembler.rb: 4 constants + 3 method signature changes
  + 1 new private validate_compiler_profile_source! method.
- experiments/assembler_compiler_profile_id_field/ proof script + summary JSON.
- docs/tracks/assembler-compiler-profile-id-field-v0.md (this doc).
- No other production files changed.

[T] Tests / Proofs
- ruby .../assembler_compiler_profile_id_field.rb → PASS (19/19)
- ruby -c lib/igniter_lang/assembler.rb            → Syntax OK
- ruby .../igapp_assembler_proof.rb                → PASS (no regression)

[R] Risks / Recommendations
- CompilerOrchestrator has no path to supply a compiler_profile_source yet.
  Until orchestrator wiring is authorized and implemented, profiled assembly
  is only exercisable via direct Assembler API or proof scripts.
- The legacy_optional policy remains active: nil source is the default.
  Any future profile_required rollout requires a separate Architect decision.

[Next]
- Architect may authorize orchestrator wiring
  (CompilerOrchestrator → Assembler#assemble_artifacts with compiler_profile_source).
- Architect may authorize golden migration
  (naming exact fixtures and expected hash churn).
- Loader/report card remains separately blocked.
```
