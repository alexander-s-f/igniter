# Internal Profile Assembly Boundary Proof Maintenance v0

Card: LANG-R134-H1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: LANG-R133-I1, LANG-R132-A, LANG-R131-P1  
Track: `internal-profile-assembly-boundary-proof-maintenance-v0`  
Status: done  
Date: 2026-05-22

---

## Role And Neighbor Awareness

Assigned track: maintenance refresh for the R131 internal profile assembly
boundary proof after R132/R133 authorized the internal lib boundary file.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` - R133 implementation owner; no
  implementation behavior changed in this maintenance slice.
- `[Igniter-Lang Bridge Agent]` - public API/CLI, loader/report,
  CompatibilityReport, manifest, runtime, production, and Spark surfaces remain
  closed.

---

## Current Horizon

```text
R131 proved a proof-only internal_profile_assembly_result boundary.
R132 authorized a tiny internal lib implementation.
R133 created lib/igniter_lang/internal_profile_assembly.rb and found one stale R131 matrix assertion.
R134 supersedes only that stale pre-implementation assertion and reruns the matrix.
```

---

## Read Set

- `docs/gates/internal-profile-assembly-boundary-implementation-authorization-review-v0.md`
- `docs/tracks/internal-profile-assembly-boundary-implementation-v0.md`
- `docs/tracks/internal-profile-assembly-boundary-proof-v0.md`
- `lib/igniter_lang/internal_profile_assembly.rb`
- `experiments/internal_profile_assembly_boundary_proof/internal_profile_assembly_boundary_proof.rb`
- `experiments/internal_profile_assembly_boundary_implementation_proof/internal_profile_assembly_boundary_implementation_proof.rb`

---

## Maintenance Delta

The stale R131 check:

```text
no_new_lib_assembly_boundary_file
```

is superseded by:

```text
authorized_internal_assembly_file_exists_direct_require_only
```

Reason: R132/R133 explicitly authorized and implemented
`lib/igniter_lang/internal_profile_assembly.rb`. The maintained proof now
expects that file to exist, verifies it has no `require_relative`, verifies no
`internal_profile_assembly_boundary.rb` sibling exists, and keeps root require
and compiler pipeline usage closed.

Additional strengthening:

- compiler pipeline checks now cover both `InternalProfileAssemblySourcePacket`
  and `InternalProfileAssembly`;
- root require checks now cover both `internal_profile_assembly_source_packet`
  and `internal_profile_assembly`;
- proof summary records the R132 authority ref and the superseded assertion.

No implementation behavior changed.

---

## Updated Proof Result

```text
PASS internal-profile-assembly-boundary-proof-v0
cases: 6/6
checks: 5/5
recommendation: ACCEPT_R133_CLOSURE
```

Updated check list:

| Check | Result |
| --- | --- |
| `packet_does_not_become_compiler_input` | PASS |
| `root_require_remains_closed` | PASS |
| `authorized_internal_assembly_file_exists_direct_require_only` | PASS |
| `public_report_runtime_manifest_prop_surfaces_closed` | PASS |
| `case_matrix_expected_results` | PASS |

---

## Full R132/R133 Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly.rb` | PASS / `Syntax OK` |
| `ruby -c igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/internal_profile_assembly_boundary_implementation_proof.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/internal_profile_assembly_boundary_implementation_proof.rb` | PASS / `cases: 7/7`, `checks: 5/5`, `recommendation: ACCEPT_CLOSURE` |
| `ruby igniter-lang/experiments/internal_profile_assembly_boundary_proof/internal_profile_assembly_boundary_proof.rb` | PASS / `cases: 6/6`, `checks: 5/5`, `recommendation: ACCEPT_R133_CLOSURE` |
| `ruby igniter-lang/experiments/internal_profile_assembly_source_packet_proof/internal_profile_assembly_source_packet_proof.rb` | PASS / `cases: 6/6`, `checks: 5/5` |
| `ruby igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/oof_fragment_registry_compiler_profile_source_input_proof.rb` | PASS / `cases: 9/9`, `checks: 6/6` |
| `ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly_source_packet.rb` | PASS / `Syntax OK` |
| `ruby -c igniter-lang/lib/igniter_lang/oof_fragment_registry.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb` | PASS |
| `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS / `PASS typechecker_golden_check` |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS / `PASS source_to_semanticir_fixture_golden_check` |
| `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | PASS |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS |

---

## Closed Surfaces Preserved

Still closed:

- no root require from `lib/igniter_lang.rb`;
- no parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator usage;
- no public API/CLI;
- no loader/report;
- no CompatibilityReport;
- no `.igapp`, manifest, sidecar, or golden mutation from this maintenance;
- no PROP-036 or PROP-038 behavior mutation;
- no runtime, production, Spark, Ledger/TBackend, cache, or signing behavior.

---

## Changed Files

```text
igniter-lang/experiments/internal_profile_assembly_boundary_proof/internal_profile_assembly_boundary_proof.rb
igniter-lang/experiments/internal_profile_assembly_boundary_proof/out/internal_profile_assembly_boundary_proof_summary.json
igniter-lang/docs/tracks/internal-profile-assembly-boundary-proof-v0.md
igniter-lang/docs/tracks/internal-profile-assembly-boundary-proof-maintenance-v0.md
```

---

## Recommendation

```text
accept R133 closure
```

The previous formal matrix conflict is resolved. R133 behavior remains bounded
to the authorized internal lib file, and all protected external surfaces remain
closed.

---

## Handoff

[D] The R131 stale `no_new_lib_assembly_boundary_file` assertion is superseded
by `authorized_internal_assembly_file_exists_direct_require_only`.

[S] The authorized R133 file exists and remains isolated: direct-require-only,
no root require, no compiler pipeline usage, and no public/report/runtime
carrier.

[T] Full R132/R133 matrix PASS, including R133 implementation proof, maintained
R131 proof, classifier/typechecker/SemanticIR/assembler regressions, and
PROP-038 report-only integration.

[R] Accept R133 closure.

[Next] If implementation progresses, route only through a new authorization
card that names the next carrier surface explicitly.
