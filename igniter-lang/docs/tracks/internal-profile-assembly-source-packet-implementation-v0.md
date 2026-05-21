# Track: Internal Profile-Assembly Source Packet Implementation v0

Card: LANG-R129-I1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R128-A
Track: `internal-profile-assembly-source-packet-implementation-v0`
Status: done
Date: 2026-05-21

---

## Goal

Implement and prove an internal profile-assembly source packet object that can
carry the R125 packet model, map it to OOF/Fragment Registry helper envelopes,
and validate through `IgniterLang::OOFFragmentRegistry` from a proof harness.

This slice is internal-only. It does not authorize public API/CLI, loader/report,
CompatibilityReport, `.igapp`, PROP-036, PROP-038, compiler pipeline, runtime,
production, Spark, Ledger/TBackend, or Gate 3 behavior.

---

## Evidence Read

- `docs/gates/internal-profile-assembly-source-packet-implementation-authorization-review-v0.md`
  (LANG-R128-A)
- `docs/discussions/compiler-profile-source-input-lifecycle-bridge-pressure-v0.md`
  (LANG-R127-X)
- `docs/tracks/compiler-profile-source-input-lifecycle-owner-design-v0.md`
  (LANG-R126-D1)
- `docs/tracks/oof-fragment-registry-compiler-profile-source-input-proof-v0.md`
  (LANG-R125-P1)
- `experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/compiler_profile_oof_registry_source_input.packet.json`

---

## Implementation

Added:

```text
igniter-lang/lib/igniter_lang/internal_profile_assembly_source_packet.rb
```

Implemented internal class:

```ruby
IgniterLang::InternalProfileAssemblySourcePacket
```

Supported internal constructor/test seam:

```ruby
IgniterLang::InternalProfileAssemblySourcePacket.build(
  authority:,
  profile_candidate:,
  pack_descriptor_candidates:,
  lifecycle_state: "implementation_candidate",
  closed_surface_assertions: {},
  excluded_namespaces: nil
)
```

Supported methods:

```ruby
#to_h
#to_helper_envelopes
#validate_with(registry_validator:)
#lifecycle_state
```

Lifecycle wording:

| State | Meaning |
| --- | --- |
| `implementation_candidate` | Internal implementation boundary state for this packet object. |
| `finalized_internal` | Internal assembly state only after helper validation passes; not PROP-036 finalization, not `compiler_profile_id`, and not manifest/profile identity. |

The file is not required from `igniter-lang/lib/igniter_lang.rb`.

---

## Proof

Added proof harness:

```text
igniter-lang/experiments/internal_profile_assembly_source_packet_proof/internal_profile_assembly_source_packet_proof.rb
```

Result:

```text
PASS internal-profile-assembly-source-packet-implementation-v0
cases: 6/6
checks: 5/5
recommendation: INTERNAL_PROFILE_ASSEMBLY_SOURCE_PACKET_ACCEPTED
```

Generated proof-local outputs:

```text
igniter-lang/experiments/internal_profile_assembly_source_packet_proof/out/internal_profile_assembly_source_packet.to_h.json
igniter-lang/experiments/internal_profile_assembly_source_packet_proof/out/internal_profile_assembly_source_packet.helper_envelopes.json
igniter-lang/experiments/internal_profile_assembly_source_packet_proof/out/internal_profile_assembly_source_packet.validation.json
igniter-lang/experiments/internal_profile_assembly_source_packet_proof/out/internal_profile_assembly_source_packet_proof_summary.json
```

Proof cases:

| Case | Result |
| --- | --- |
| `build_creates_internal_profile_assembly_source_packet` | PASS |
| `to_h_preserves_r125_packet_model` | PASS |
| `to_helper_envelopes_is_deterministic` | PASS |
| `validate_with_oof_fragment_registry_passes` | PASS |
| `successful_validation_reports_finalized_internal_only` | PASS |
| `bad_authority_stays_internal_validation_failure` | PASS |

Proof checks:

| Check | Result |
| --- | --- |
| `new_file_not_required_from_igniter_lang_rb` | PASS |
| `compiler_pipeline_files_do_not_reference_packet` | PASS |
| `public_report_runtime_manifest_prop_surfaces_closed` | PASS |
| `lifecycle_states_are_internal_only` | PASS |
| `helper_mapping_uses_oof_fragment_registry_source_envelopes` | PASS |

---

## R128 Proof Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly_source_packet.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/internal_profile_assembly_source_packet_proof/internal_profile_assembly_source_packet_proof.rb` | PASS / `cases: 6/6`, `checks: 5/5` |
| `ruby igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/oof_fragment_registry_compiler_profile_source_input_proof.rb` | PASS / `cases: 9/9`, `checks: 6/6` |
| `ruby igniter-lang/experiments/oof_fragment_registry_profile_pack_source_acceptance_proof/oof_fragment_registry_profile_pack_source_acceptance_proof.rb` | PASS / `cases: 13/13`, `checks: 5/5` |
| `ruby igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/oof_fragment_registry_profile_pack_source_mode_proof.rb` | PASS / `cases: 9/9`, `checks: 7/7` |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/oof_fragment_registry_source_authority_precedence_proof.rb` | PASS / `cases: 9/9`, `checks: 9/9` |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_envelope_helper_proof/oof_fragment_registry_source_envelope_helper_proof.rb` | PASS / `cases: 9/9`, `checks: 10/10` |
| `ruby igniter-lang/experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | PASS / `27/27 checks PASS` |
| `ruby -c igniter-lang/lib/igniter_lang/oof_fragment_registry.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb` | PASS |
| `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS / `typechecker_golden_check` |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS / `source_to_semanticir_fixture_golden_check` |
| `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | PASS |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS |

---

## Surface Closure

Preserved:

- `igniter-lang/lib/igniter_lang.rb` was not edited and does not require the new
  internal packet file.
- Parser, classifier, TypeChecker, SemanticIR emitter, assembler, and
  orchestrator files do not reference the packet.
- No public API/CLI carrier was added.
- No loader/report or CompatibilityReport carrier was added.
- No `.igapp`, `.ilk`, manifest, sidecar, or golden mutation was added.
- No PROP-036 or PROP-038 behavior mutation was added.
- No `CompilationReport`, `CompilerResult`, diagnostics, or CLI change was made.
- No `oof_fragment_registry_data.rb` was created.
- Runtime, production, Spark, Ledger/TBackend, Gate 3, cache, and signing remain
  closed.

---

## Handoff

[D] Implemented `IgniterLang::InternalProfileAssemblySourcePacket` as an
internal profile-assembly source packet. It carries the R125 model, maps
deterministically to OOF/Fragment Registry helper envelopes, and validates
through `IgniterLang::OOFFragmentRegistry`.

[S] `implementation_candidate` is the internal implementation boundary state.
`finalized_internal` is only an internal assembly validation result state; it is
not PROP-036 finalization and not manifest/profile identity.

[T] PASS: full R128 proof matrix.

[R] Accept the internal packet implementation. Keep compiler integration,
public/report carriers, `.igapp`, PROP-036/PROP-038, runtime, production, and
Spark closed.

[Next] If progressing, route only a design/authorization review for how this
internal packet could participate in a future profile assembly boundary; do not
connect it to the current compiler pipeline without a new gate.
