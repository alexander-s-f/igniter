# Track: Internal Profile Assembly Boundary Implementation v0

Card: LANG-R133-I1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R132-A
Track: `internal-profile-assembly-boundary-implementation-v0`
Status: implemented-with-matrix-conflict
Date: 2026-05-22

---

## Neighbor Awareness

Affected neighbor roles:

- `[Igniter-Lang Research Agent]` — owns the prior proof-only boundary and
  packet proof evidence.
- `[Igniter-Lang Bridge Agent]` — public/report/loader/CompatibilityReport,
  `.igapp`, runtime, production, and Spark surfaces remain closed.
- `[Igniter-Lang Meta Expert]` — may need to record the R132 matrix conflict if
  the supervisor accepts this as a bounded implementation with stale proof debt.

This slice uses one role only:

```text
[Igniter-Lang Compiler/Grammar Expert]
```

---

## Goal

Implement a tiny internal profile assembly boundary object/result around:

```ruby
IgniterLang::InternalProfileAssemblySourcePacket
```

Authorized class:

```ruby
IgniterLang::InternalProfileAssembly
```

Authorized entrypoint:

```ruby
IgniterLang::InternalProfileAssembly.assemble(
  source_packet:,
  registry_validator: IgniterLang::OOFFragmentRegistry.new
)
```

---

## Implementation

Added:

```text
igniter-lang/lib/igniter_lang/internal_profile_assembly.rb
```

The object:

- consumes an `InternalProfileAssemblySourcePacket`-compatible internal object;
- requires input lifecycle `implementation_candidate`;
- maps through `#to_h`, `#to_helper_envelopes`, and `#validate_with`;
- uses `IgniterLang::OOFFragmentRegistry` only as an injected/default internal
  validator;
- returns an internal hash with `kind: internal_profile_assembly_result`;
- returns `finalized_internal` only when mapping and helper validation pass;
- keeps diagnostics internal to `internal_profile_assembly.*`;
- adds no root require and no compiler pipeline integration.

Successful result shape:

```json
{
  "kind": "internal_profile_assembly_result",
  "format_version": "0.1.0",
  "valid": true,
  "lifecycle_state": "finalized_internal",
  "input_lifecycle_state": "implementation_candidate",
  "packet_kind": "compiler_profile_oof_registry_source_input",
  "packet_digest": "sha256-prefix",
  "helper_envelopes_digest": "sha256-prefix",
  "profile_validation": {},
  "pack_descriptor_validations": [],
  "diagnostics": [],
  "finalized_internal_meaning": "internal assembly state only; not PROP-036 finalization, not compiler_profile_id, and not manifest/profile identity",
  "closed_surface_assertions": {
    "root_require": false,
    "compiler_pipeline_usage": false,
    "public_api_cli": false,
    "loader_report": false,
    "compatibility_report": false,
    "igapp_mutation": false,
    "manifest_mutation": false,
    "prop036_mutation": false,
    "prop038_mutation": false,
    "runtime_behavior": false,
    "production_behavior": false,
    "spark_surface": false
  }
}
```

`finalized_internal` remains internal assembly state only. It is not PROP-036
finalization, not `compiler_profile_id`, not manifest/profile identity, not
loader/report status, and not runtime/production readiness.

---

## Proof Experiment

Added:

```text
igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/
```

Executable:

```text
igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/internal_profile_assembly_boundary_implementation_proof.rb
```

Generated outputs:

```text
igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/out/internal_profile_assembly_boundary_implementation_proof_summary.json
igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/out/internal_profile_assembly_result.valid.json
igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/out/internal_profile_assembly_result.negatives.json
```

Proof result:

```text
PASS internal-profile-assembly-boundary-implementation-v0
cases: 7/7
checks: 5/5
recommendation: ACCEPT_CLOSURE
```

Case matrix:

| Case | Result |
| --- | --- |
| `valid_packet_assembles_to_finalized_internal` | PASS |
| `deterministic_result_and_digests` | PASS |
| `invalid_packet_object_does_not_finalize` | PASS |
| `bad_authority_remains_invalid_and_does_not_finalize` | PASS |
| `duplicate_row_ownership_does_not_finalize` | PASS |
| `excluded_namespace_claim_does_not_finalize` | PASS |
| `invalid_input_lifecycle_state_does_not_finalize` | PASS |

Check matrix:

| Check | Result |
| --- | --- |
| `root_require_remains_closed` | PASS |
| `compiler_pipeline_files_do_not_reference_assembly` | PASS |
| `public_report_runtime_manifest_prop_surfaces_closed` | PASS |
| `assembly_file_is_direct_require_only` | PASS |
| `case_matrix_expected_results` | PASS |

---

## R132 Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly.rb` | PASS / `Syntax OK` |
| `ruby -c igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/internal_profile_assembly_boundary_implementation_proof.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/internal_profile_assembly_boundary_implementation_proof.rb` | PASS / `cases: 7/7`, `checks: 5/5` |
| `ruby igniter-lang/experiments/internal_profile_assembly_boundary_proof/internal_profile_assembly_boundary_proof.rb` | FAIL / stale pre-implementation assertion `no_new_lib_assembly_boundary_file` |
| `ruby igniter-lang/experiments/internal_profile_assembly_source_packet_proof/internal_profile_assembly_source_packet_proof.rb` | PASS / `cases: 6/6`, `checks: 5/5` |
| `ruby igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/oof_fragment_registry_compiler_profile_source_input_proof.rb` | PASS / `cases: 9/9`, `checks: 6/6` |
| `ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly_source_packet.rb` | PASS / `Syntax OK` |
| `ruby -c igniter-lang/lib/igniter_lang/oof_fragment_registry.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb` | PASS |
| `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS / `PASS typechecker_golden_check` |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS / `PASS source_to_semanticir_fixture_golden_check` |
| `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | PASS |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS |

R132-A contains an internal matrix conflict: it both authorizes
`lib/igniter_lang/internal_profile_assembly.rb` and requires the R131 proof to
continue passing, while the R131 proof intentionally asserted
`no_new_lib_assembly_boundary_file`. That assertion is correct for R131
proof-only status but stale after R132 authorization. This track did not edit
the R131 proof because it is outside the LANG-R133-I1 write scope.

R134 maintenance resolved this matrix conflict by superseding the stale R131
assertion with `authorized_internal_assembly_file_exists_direct_require_only`.
The full R132/R133 matrix now passes; see
`internal-profile-assembly-boundary-proof-maintenance-v0.md`.

---

## Closed Surfaces

No root require was added.

No references were added to:

```text
parser
classifier
typechecker
semanticir_emitter
assembler
compiler_orchestrator
CompilationReport
CompilerResult
diagnostics
CLI
```

Still closed:

- public API/CLI;
- loader/report;
- CompatibilityReport;
- `.igapp`, `.ilk`, manifest, sidecar, or golden mutation;
- PROP-036 behavior mutation;
- PROP-038 behavior mutation;
- `oof_fragment_registry_data.rb`;
- runtime, production, Spark, Ledger/TBackend, Gate 3, cache, and signing.

---

## Changed Files

```text
igniter-lang/lib/igniter_lang/internal_profile_assembly.rb
igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/internal_profile_assembly_boundary_implementation_proof.rb
igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/out/internal_profile_assembly_boundary_implementation_proof_summary.json
igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/out/internal_profile_assembly_result.valid.json
igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/out/internal_profile_assembly_result.negatives.json
igniter-lang/docs/tracks/internal-profile-assembly-boundary-implementation-v0.md
```

---

## Recommendation

Implementation behavior:

```text
accept closure
```

Formal R132 matrix closure:

```text
hold until R132-A or R131 proof expectation is reconciled
```

Recommended next route:

```text
Architect decision: mark R131 no-new-lib-file assertion superseded for
post-R132 implementation runs, or authorize a tiny proof maintenance card for
internal_profile_assembly_boundary_proof.
```

---

## Handoff

[D] `IgniterLang::InternalProfileAssembly` now exists as a direct-require-only
internal boundary object and returns `internal_profile_assembly_result`.

[S] Valid packet + registry helper validation finalizes to `finalized_internal`.
Invalid packet object, invalid lifecycle, bad authority, duplicate ownership,
and excluded namespace claims do not finalize.

[T] New proof PASS: `cases: 7/7`, `checks: 5/5`. Broad compiler regressions
PASS. R132 matrix has one stale-proof FAIL in the older R131 proof because the
authorized file now exists.

[R] Accept implementation behavior; hold formal R132 matrix closure until the
stale R131 no-new-file assertion is superseded or maintained by an authorized
card.

[Next] Route a tiny authority/proof-maintenance decision for the R131 proof
matrix conflict, then close LANG-R133-I1 if accepted.
