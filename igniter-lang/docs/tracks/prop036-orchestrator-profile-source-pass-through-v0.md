# Track: Prop036 Orchestrator Profile Source Pass-Through v0

Card: S3-R43-C1-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `prop036-orchestrator-profile-source-pass-through-v0`
Route: UPDATE
Status: done
Date: 2026-05-13

Authorized by: S3-R42-C10-A (`docs/gates/prop036-orchestrator-wiring-authorization-review-v0.md`)

Affected neighbor roles: `[Architect Supervisor / Codex]`, `[Igniter-Lang Compiler/Grammar Expert]`

---

## Goal

Implement the bounded `CompilerOrchestrator#compile` pass-through of
`compiler_profile_source:` to `Assembler#assemble_artifacts`, as authorized by
S3-R42-C10-A.

The orchestrator is a transport boundary only. It does not derive, load,
discover, default, finalize, cache, or validate compiler profiles.

---

## Inputs Read

- `docs/gates/prop036-orchestrator-wiring-authorization-review-v0.md` (C10-A)
- `docs/tracks/assembler-compiler-profile-id-field-v0.md` (C9-I)
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/assembler.rb`

---

## Production Code Changed

```text
lib/igniter_lang/compiler_orchestrator.rb
```

**No other production files changed.**

---

## Implementation Summary

### Method Signature Changed

```ruby
# Before:
def compile(source_path:, out_path:, sample_input: nil, sample_input_resolver: nil, runtime_smoke: nil)

# After (backward-compatible — nil default preserves legacy behavior):
def compile(
  source_path:,
  out_path:,
  sample_input: nil,
  sample_input_resolver: nil,
  runtime_smoke: nil,
  compiler_profile_source: nil
)
```

### Pass-Through Added

```ruby
# PROP-036: compiler_profile_source is passed unchanged to the assembler.
# The orchestrator is a transport boundary only — it does not derive, load,
# discover, default, finalize, or validate profiles. Assembler validation
# remains authoritative. Nil preserves legacy_optional behavior.
assembled = @assembler.assemble_artifacts(
  case_name: case_name_for(source_path, parsed),
  report: report,
  semantic_ir: semantic_ir,
  target_dir: out_path,
  compiler_profile_source: compiler_profile_source
)
```

### Semantics

`compiler_profile_source: nil` (default):
- preserves current legacy behavior;
- omits `manifest.compiler_profile_id`;
- does not change existing default compilation output.

`compiler_profile_source: <finalized Hash>`:
- passed unchanged to `Assembler#assemble_artifacts`;
- assembler validation remains authoritative;
- on valid source: profiled `.igapp` with `manifest.compiler_profile_id`;
- on invalid source: surfaces through existing `assembler_refused` path.

### No Profile Logic in Orchestrator

The orchestrator defines no profile derivation methods. Forbidden method set
confirmed absent: `finalize_profile`, `derive_profile_id`, `load_profile`,
`discover_profile`, `default_profile`, `validate_profile`, `cache_profile`.

---

## Proof Produced

```text
experiments/prop036_orchestrator_profile_source_pass_through/
  prop036_orchestrator_profile_source_pass_through.rb
  out/prop036_orchestrator_profile_source_pass_through_summary.json
```

---

## Proof Matrix

### Proof cases

| Case | Input | Expected result | Observed |
| --- | --- | --- | --- |
| O1. legacy compile omits field | no source | `status=ok`, manifest omits `compiler_profile_id` | PASS |
| O2. profiled compile emits field | valid finalized source | `status=ok`, manifest includes matching `compiler_profile_id` | PASS |
| O3. profiled hash differs from legacy | compare O1 vs O2 hashes | `artifact_hash` differs (profile id in hash material) | PASS |
| O4. invalid source refused | `status="draft"` source | `status=assembler_refused` | PASS |
| O5. refusal includes profile source reason | O4 report/result | `compiler_profile_source` text in output | PASS |
| O6. no loader status values | O2 manifest JSON | none of: `absent_legacy`, `present_verified`, `mismatch`, `malformed`, `missing_required` | PASS |
| O7. no runtime authority | O2 manifest keys | none of: `runtime_authority`, `gate3_authorized`, `runtime_ready`, `evaluation_ready` | PASS |
| O8. no golden mutation | `igapp_assembler_proof/out/add.igapp` | golden artifact_hash format valid; proof writes only to OUT_DIR | PASS |

Note on O8: The orchestrator pipeline (classify→typecheck→emit→assemble) produces a
different `artifact_hash` than a direct `Assembler#assemble_case` call — the two paths
differ in artifact material composition. O8 proves only that this proof did not write
into any existing golden directory.

### Invariants

| Invariant | Expected | Observed |
| --- | --- | --- |
| INV1. artifact_hash format valid | all assembled igapps have `sha256:<64-hex>` format | PASS |
| INV2. backward-compatible nil default | `compile` has `compiler_profile_source:` keyword param | PASS |
| INV3. orchestrator is transport only | no profile derivation methods defined | PASS |

All 11/11 PASS.

---

## Command Matrix

```text
ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
                              → Syntax OK
ruby igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/prop036_orchestrator_profile_source_pass_through.rb
                              → PASS (11/11)
```

---

## Non-Authorizations Preserved

```text
profile_derivation_in_orchestrator:      false
profile_discovery_env_config_files:      false
default_profile_injection:               false
loader_report_status_implementation:     false
existing_igapp_golden_migration:         false
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

## Remaining Blockers Before CLI/API Exposure, Golden Migration, or Loader/Report Work

1. **CLI/API exposure**: `CompilerOrchestrator#compile` now accepts
   `compiler_profile_source:`, but no CLI flag, API parameter, or configuration
   layer surfaces it. A caller must have a finalized source object from an
   out-of-band finalization layer. A future card must define how callers obtain
   finalized source objects and how they supply them.

2. **Loader/report implementation**: `loader-compiler-profile-status-report-v0`
   is a separate surface. The five status values (`absent_legacy`,
   `present_verified`, `mismatch`, `malformed`, `missing_required`) remain
   unimplemented. No loader status is emitted anywhere in the current pipeline.

3. **Golden migration**: `artifact-hash-profile-id-golden-migration-v0` requires
   an explicit fixture list and expected hash churn. No existing `.igapp` golden
   is migrated here.

4. **CompatibilityReport**: compiler-profile section remains unimplemented.

5. **CompilationReceipt manifest links**: out of scope.

6. **`.ilk` profile references**: out of scope.

7. **Signing and production verification**: out of scope.

8. **Compiler dispatch migration**: out of scope.

9. **Default profile injection**: explicitly not authorized; orchestrator must
   not inject a default profile when `compiler_profile_source: nil`. The
   `legacy_optional` policy is the only authorized nil behavior.

---

## Handoff

```text
Card: S3-R43-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: prop036-orchestrator-profile-source-pass-through-v0
Status: done

[D] Decisions
- compiler_profile_source: nil keyword added to compile (backward-compatible).
- Orchestrator passes source unchanged to Assembler#assemble_artifacts.
- Assembler validation remains authoritative.
- Nil source preserves legacy_optional behavior (manifest.compiler_profile_id absent).
- Valid source: profiled .igapp output when assembler validation succeeds.
- Invalid source: surfaces as assembler_refused through existing rescue path.
- Orchestrator defines no profile derivation, loading, or discovery methods.

[S] Shipped / Signals
- lib/igniter_lang/compiler_orchestrator.rb: compile signature + assemble_artifacts call updated.
- experiments/prop036_orchestrator_profile_source_pass_through/ proof script + summary JSON.
- docs/tracks/prop036-orchestrator-profile-source-pass-through-v0.md (this doc).
- No other production files changed.

[T] Tests / Proofs
- ruby -c lib/igniter_lang/compiler_orchestrator.rb → Syntax OK
- ruby .../prop036_orchestrator_profile_source_pass_through.rb → PASS (11/11)

[R] Risks / Recommendations
- No caller today supplies a compiler_profile_source to CompilerOrchestrator.
  Profiled compilation is only exercisable via proof scripts or direct orchestrator
  instantiation. CLI/API exposure requires a separate card.
- The legacy_optional policy remains active: nil source is the default.
  Any future profile_required rollout requires a separate Architect decision.

[Next]
- Architect may authorize CLI/API exposure (how callers supply finalized source objects).
- Architect may authorize golden migration (naming exact fixtures and expected hash churn).
- Loader/report card remains separately blocked.
- CompatibilityReport compiler-profile section remains separately blocked.
```
