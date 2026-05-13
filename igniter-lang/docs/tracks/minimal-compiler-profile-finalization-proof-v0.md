# Track: Minimal CompilerProfile Finalization Proof v0

Card: S3-R42-C7-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `minimal-compiler-profile-finalization-proof-v0`
Route: UPDATE
Status: done
Date: 2026-05-13

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Architect Supervisor / Codex]`, `[Igniter-Lang Research Agent]`

---

## Goal

Implement the proof-local minimal CompilerProfile finalization layer authorized
by S3-R42-C6-A.

Prove that a frozen CompilerProfile descriptor can be finalized into a
`compiler_profile_id_source` object, that the derived id matches the
`compiler_profile_unified/sha256:<24+ lowercase hex chars>` shape, and that
all required refusal cases refuse correctly.

This track does not implement assembler field emission, modify `.igapp`
manifests or goldens, touch loader/report/CompatibilityReport, change compiler
dispatch, bind RuntimeMachine, or affect production behavior.

---

## Inputs Read

- `docs/gates/prop036-source-contract-implementation-authorization-review-v0.md` (C6-A)
- `docs/tracks/prop036-compiler-profile-id-source-contract-v0.md` (C4-P1)
- `docs/tracks/prop036-source-contract-code-surface-survey-v0.md` (C5-P1)
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `experiments/compiler_profile_spec_and_rule_unification/out/compiler_profile_spec_and_rule_unification_summary.json`
  (slot order and implementation ids for Stage3ProofCompilerProfileSpec)

---

## Proof Produced

```text
experiments/minimal_compiler_profile_finalization_proof/
  minimal_compiler_profile_finalization_proof.rb
  out/minimal_compiler_profile_finalization_summary.json
```

---

## Source Object Shape

The finalization layer emits a `compiler_profile_id_source` object:

```json
{
  "kind":                          "compiler_profile_id_source",
  "format_version":                "0.1.0",
  "status":                        "finalized",
  "profile_namespace":             "compiler_profile_unified",
  "compiler_profile_id":           "compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7",
  "descriptor_digest":             "compiler_profile_descriptor/sha256:<24-char hex>",
  "finalization_payload_digest":   "sha256:<64-char hex>",
  "profile_kind":                  "Stage3ProofCompilerProfileSpec",
  "slot_order": [
    "core", "oof_registry", "fragment_registry", "escape_boundary",
    "contract_modifiers", "temporal", "stream", "olap",
    "invariant", "assumptions", "evidence_observation", "pipeline"
  ],
  "slot_assignments": {
    "core":                 { "implementation_id": "core_language.proof_compiler_adapter.v0",           "pack_name": "CoreLanguagePack" },
    "oof_registry":         { "implementation_id": "oof_registry.shadow_descriptor_registry.v0",        "pack_name": "OOFRegistry" },
    "fragment_registry":    { "implementation_id": "fragment_registry.shadow_precedence_registry.v0",   "pack_name": "FragmentRegistry" },
    "escape_boundary":      { "implementation_id": "escape_boundary.current_monolith_adapter.v0",       "pack_name": "EscapeBoundaryPack" },
    "contract_modifiers":   { "implementation_id": "contract_modifiers.current_monolith_adapter.v0",    "pack_name": "ContractModifiersPack" },
    "temporal":             { "implementation_id": "temporal.metadata_only_guarded.v0",                  "pack_name": "TemporalPack" },
    "stream":               { "implementation_id": "stream.current_monolith_adapter.v0",                 "pack_name": "StreamPack" },
    "olap":                 { "implementation_id": "olap.current_monolith_adapter.v0",                   "pack_name": "OLAPPack" },
    "invariant":            { "implementation_id": "invariant.current_monolith_adapter.v0",              "pack_name": "InvariantPack" },
    "assumptions":          { "implementation_id": "assumptions.spec_shadow.v0",                         "pack_name": "AssumptionsPack" },
    "evidence_observation": { "implementation_id": "evidence_observation.current_monolith_adapter.v0",  "pack_name": "EvidenceObservationPack" },
    "pipeline":             { "implementation_id": "pipeline.current_parser_surface_shadow.v0",          "pack_name": "PipelinePack" }
  },
  "dispatch_migration_authorized": false,
  "runtime_authority_granted":     false
}
```

---

## Derived ID Rule

```text
1. Validate frozen descriptor (kind, no embedded compiler_profile_id,
   profile_spec.name == "Stage3ProofCompilerProfileSpec",
   profile_spec.slot_order == CANONICAL_SLOT_ORDER).

2. Build slot_assignments from pack_descriptors (slot → implementation_id + pack_name).

3. Compute descriptor_digest:
     stable_descriptor = descriptor without "descriptor_digest" key
     descriptor_digest = "compiler_profile_descriptor/sha256:" +
                         SHA256(canonical_json(stable_descriptor))[0,24]

4. Build finalization payload (compiler_profile_id MUST NOT be in this payload):
     payload = {
       "profile_namespace"  => "compiler_profile_unified",
       "format_version"     => "0.1.0",
       "descriptor_digest"  => descriptor_digest,
       "profile_kind"       => "Stage3ProofCompilerProfileSpec",
       "slot_order"         => CANONICAL_SLOT_ORDER,   ← ordered, not sorted
       "slot_assignments"   => slot_assignments         ← Hash keys sorted by canonical_json
     }

5. canonical_json = JSON.generate(normalize(payload))
   where normalize sorts Hash keys lexicographically and recurses;
         Arrays are preserved element-order.

6. payload_hex = SHA256(canonical_json)
   finalization_payload_digest = "sha256:" + payload_hex
   compiler_profile_id = "compiler_profile_unified/sha256:" + payload_hex[0,24]
```

---

## Proof Matrix

### Finalization Layer

| Case | Input | Expected result |
| --- | --- | --- |
| F1. valid frozen descriptor | `PROOF_DESCRIPTOR` | finalized source object; id matches `compiler_profile_unified/sha256:[0-9a-f]{24,}` |
| F2. permuted Hash keys | same descriptor data, Hash keys in different order | **same** id (canonical JSON sorts Hash keys; Array element order unchanged) |
| F3. implementation identity changed | one pack's `implementation_id` altered | **different** id |
| F4. payload excludes profile id | structural check on payload key set | `"compiler_profile_id"` not a payload key |
| F5. embedded profile id in descriptor | descriptor with `"compiler_profile_id"` field | refuses `compiler_profile_source.payload_id_inclusion_forbidden` |
| F6. nil descriptor | `nil` | refuses `compiler_profile_source.missing` |
| F7. malformed descriptor | `"not_a_hash"` | refuses `compiler_profile_source.malformed` |
| F8. wrong kind | descriptor with `kind = "compiler_profile_unified"` | refuses `compiler_profile_source.wrong_kind` |
| F9. slot order mismatch in descriptor | `profile_spec.slot_order` with first two slots swapped | refuses `compiler_profile_source.slot_order_mismatch` |

### Validation Layer

| Case | Input | Expected result |
| --- | --- | --- |
| V1. unfinalized status | source with `status = "draft"` | refuses `compiler_profile_source.unfinalized` |
| V2. unsupported namespace | source with `profile_namespace = "compiler_profile_legacy"` | refuses `compiler_profile_source.unsupported_namespace` |
| V3. malformed id | source with `compiler_profile_id = "not-a-profile-id"` | refuses `compiler_profile_source.malformed_id` |
| V4. digest mismatch | source with wrong `finalization_payload_digest` | refuses `compiler_profile_source.id_digest_mismatch` |
| V5. slot order mismatch in source | source with first two slots swapped | refuses `compiler_profile_source.slot_order_mismatch` |
| V6. runtime authority | source with `runtime_authority_granted: true` | refuses `compiler_profile_source.runtime_authority_forbidden` |
| V7. dispatch migration | source with `dispatch_migration_authorized: true` | refuses `compiler_profile_source.dispatch_migration_forbidden` |

### Invariants

| Invariant | Expected |
| --- | --- |
| INV1. profile_id not in finalization payload | `"compiler_profile_id"` is not a key in the finalization payload structure |
| INV2. status is finalized | all produced sources have `status == "finalized"` |
| INV3. no runtime authority | all produced sources have `runtime_authority_granted == false` |
| INV4. no dispatch migration | all produced sources have `dispatch_migration_authorized == false` |
| INV5. id format valid | produced id matches `/\Acompiler_profile_unified\/sha256:[0-9a-f]{24,}\z/` |
| INV6. produced source validates | `validate_source!` accepts the produced source without error |

---

## Refusal Matrix

| Condition | Reason code |
| --- | --- |
| descriptor is nil | `compiler_profile_source.missing` |
| descriptor is not a Hash | `compiler_profile_source.malformed` |
| descriptor `kind` ≠ `"compiler_profile_descriptor"` | `compiler_profile_source.wrong_kind` |
| descriptor contains `"compiler_profile_id"` field | `compiler_profile_source.payload_id_inclusion_forbidden` |
| profile spec name ≠ `"Stage3ProofCompilerProfileSpec"` | `compiler_profile_source.unsupported_namespace` |
| `profile_spec.slot_order` ≠ `CANONICAL_SLOT_ORDER` | `compiler_profile_source.slot_order_mismatch` |
| unknown slot in `pack_descriptors` | `compiler_profile_source.slot_order_mismatch` |
| source `status` ≠ `"finalized"` | `compiler_profile_source.unfinalized` |
| source `profile_namespace` ≠ `"compiler_profile_unified"` | `compiler_profile_source.unsupported_namespace` |
| source `compiler_profile_id` malformed | `compiler_profile_source.malformed_id` |
| source `slot_order` ≠ `CANONICAL_SLOT_ORDER` | `compiler_profile_source.slot_order_mismatch` |
| `finalization_payload_digest` mismatch | `compiler_profile_source.id_digest_mismatch` |
| `compiler_profile_id` mismatch from payload | `compiler_profile_source.id_digest_mismatch` |
| `runtime_authority_granted: true` | `compiler_profile_source.runtime_authority_forbidden` |
| `dispatch_migration_authorized: true` | `compiler_profile_source.dispatch_migration_forbidden` |

No loader status values (`present_verified`, `mismatch`, `malformed`,
`missing_required`) are used in any refusal path.

---

## Command Matrix

```text
ruby igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb → PASS
ruby -c igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb → Syntax OK
```

Observed checks:

```text
F1.valid_descriptor_produces_source          → PASS
F2.permuted_hash_keys_same_id                → PASS
F3.implementation_identity_change_changes_id → PASS
F4.payload_does_not_contain_profile_id       → PASS
F5.payload_id_inclusion_refused              → PASS
F6.missing_source_refused                    → PASS
F7.malformed_descriptor_refused              → PASS
F8.wrong_kind_refused                        → PASS
F9.slot_order_mismatch_in_finalization       → PASS
V1.unfinalized_status_refused                → PASS
V2.unsupported_namespace_refused             → PASS
V3.malformed_id_refused                      → PASS
V4.digest_mismatch_refused                   → PASS
V5.slot_order_mismatch_in_validation         → PASS
V6.runtime_authority_refused                 → PASS
V7.dispatch_migration_refused                → PASS
INV1.profile_id_not_in_finalization_payload  → PASS
INV2.status_is_finalized                     → PASS
INV3.no_runtime_authority                    → PASS
INV4.no_dispatch_migration                   → PASS
INV5.id_format_valid                         → PASS
INV6.produced_source_passes_validation       → PASS
```

All 22/22 checks PASS.

---

## Non-Authorizations Preserved

```text
assembler_implementation:           false
igapp_manifest_mutation:            false
igapp_golden_migration:             false
ilk_changes:                        false
loader_report_status_implementation: false
compatibility_report_changes:       false
compilation_receipt_links:          false
signing:                            false
compiler_dispatch_migration:        false
runtime_machine_binding:            false
gate3_widening:                     false
ledger_tbackend_binding:            false
bihistory_live_execution:           false
stream_olap_production:             false
production_cache:                   false
production_deployment:              false
```

---

## Blockers Remaining Before Assembler Field Implementation

[R] `assembler-compiler-profile-id-field-v0` (C4-I) remains blocked until:

1. C3-A reconsiders and explicitly authorizes assembler field emission, naming:
   - `assembler-compiler-profile-id-field-v0` as the only implementation surface;
   - `assembler-only` type;
   - the `compiler_profile_id_source` object as the assembler authority source;
   - whether `compiler_profile_source:` is threaded through
     `Assembler#assemble_artifacts` directly, or whether `CompilerOrchestrator`
     derives the id string first and passes it as a keyword;
   - fixture/golden mutation policy;
   - artifact hash churn expectations.
2. `legacy_optional` preserved.
3. `present_verified != runtime ready` preserved.
4. Loader/report/status, CompatibilityReport, receipt links, signing, `.ilk`,
   compiler dispatch migration, RuntimeMachine, Gate 3, Ledger, TBackend,
   BiHistory, stream/OLAP, production cache remain out of scope.
5. Implementation card defines `validate_compiler_profile_source!` behavior
   per the C4-P1 refusal table (this proof's `validate_source!` is the
   proof-local equivalent).

---

## Handoff

```text
Card: S3-R42-C7-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: minimal-compiler-profile-finalization-proof-v0
Status: done

[D] Decisions
- Finalization input: frozen compiler_profile_descriptor hash.
- Finalization output: compiler_profile_id_source object (C4-P1 shape).
- Derived id: compiler_profile_unified/sha256:<SHA256(canonical_json(payload))[0,24]>
- Payload keys: profile_namespace, format_version, descriptor_digest,
  profile_kind, slot_order, slot_assignments.
- compiler_profile_id is NOT in the finalization payload.
- All 10 C6-A refusal reason codes implemented and proved.
- validate_source! is the proof-local equivalent of the assembler's
  validate_compiler_profile_source!.

[S] Shipped / Signals
- Created experiments/minimal_compiler_profile_finalization_proof/
    minimal_compiler_profile_finalization_proof.rb
    out/minimal_compiler_profile_finalization_summary.json
- Added this track doc.
- No assembler, loader, goldens, manifests, or production code changed.

[T] Tests / Proofs
- ruby .../minimal_compiler_profile_finalization_proof.rb → PASS (22/22)
- ruby -c .../minimal_compiler_profile_finalization_proof.rb → Syntax OK

[R] Risks / Recommendations
- The proof-local finalization script is not yet wired into assembler.rb or
  compiler_orchestrator.rb. That wiring requires a separate assembler-field
  authorization from C3-A.
- The assembler implementation card must decide whether to thread the full
  compiler_profile_id_source object or just the derived compiler_profile_id
  string through assemble_artifacts. Both approaches are safe; the source
  object approach enables in-assembler validation.

[Next]
- C3-A may now reconsider assembler-compiler-profile-id-field-v0 using
  this finalization proof as the closed blocker.
```
