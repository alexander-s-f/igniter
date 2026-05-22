# Internal Profile Assembly Boundary Proof v0

Card: LANG-R131-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: LANG-R130-D1, LANG-R129-I1  
Track: `internal-profile-assembly-boundary-proof-v0`  
Status: done  
Date: 2026-05-22

---

## Role And Neighbor Awareness

Assigned track: proof-only internal profile assembly boundary/result shape
around `IgniterLang::InternalProfileAssemblySourcePacket` and
`IgniterLang::OOFFragmentRegistry`.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` — owns future implementation
  semantics if this boundary is promoted.
- `[Igniter-Lang Bridge Agent]` — public/report/loader/CompatibilityReport,
  runtime, production, and package surfaces remain closed.

This track originally created only an experiment-local boundary proof. R134
maintenance supersedes the pre-R132 "no lib assembly boundary file" assertion:
R132/R133 authorized `lib/igniter_lang/internal_profile_assembly.rb` as an
internal-only direct-require file. The remaining closure is unchanged: no root
require, no compiler pipeline usage, and no public/report/runtime carrier.

---

## Current Horizon

```text
R129 implemented InternalProfileAssemblySourcePacket as an internal constructor/test seam.
R130 designed a proof-only assembly boundary that returns internal_profile_assembly_result.
R131 proves the boundary/result shape without compiler integration.
R134 maintains R131 after R132/R133 authorized the internal lib boundary file.
```

---

## Read Set

- `docs/tracks/internal-profile-assembly-boundary-design-v0.md`
- `docs/tracks/internal-profile-assembly-source-packet-implementation-v0.md`
- `docs/gates/internal-profile-assembly-source-packet-implementation-authorization-review-v0.md`
- `lib/igniter_lang/internal_profile_assembly_source_packet.rb`
- `experiments/internal_profile_assembly_source_packet_proof/internal_profile_assembly_source_packet_proof.rb`
- `lib/igniter_lang/oof_fragment_registry.rb`

---

## Proof Output

Executable proof:

```text
igniter-lang/experiments/internal_profile_assembly_boundary_proof/internal_profile_assembly_boundary_proof.rb
```

Generated proof-local outputs:

```text
igniter-lang/experiments/internal_profile_assembly_boundary_proof/out/internal_profile_assembly_boundary_proof_summary.json
igniter-lang/experiments/internal_profile_assembly_boundary_proof/out/internal_profile_assembly_boundary_model.json
igniter-lang/experiments/internal_profile_assembly_boundary_proof/out/internal_profile_assembly_result.valid.json
igniter-lang/experiments/internal_profile_assembly_boundary_proof/out/internal_profile_assembly_result.negatives.json
```

Result:

```text
PASS internal-profile-assembly-boundary-proof-v0
cases: 6/6
checks: 5/5
recommendation: ACCEPT_R133_CLOSURE
model_id: internal_profile_assembly_boundary/sha256:f2e95b73af499d03e59a8c6e
packet_digest: daa67b3f2faf5216175ded43
result_digest: a55d3660932252ea78201c4d
```

---

## Result Shape Proven

The proof-local boundary consumes:

```text
IgniterLang::InternalProfileAssemblySourcePacket
IgniterLang::OOFFragmentRegistry
```

It produces:

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
  "closed_surface_assertions": {}
}
```

`finalized_internal` is an internal assembly result state only. It is not
PROP-036 finalization, not `compiler_profile_id`, not manifest/profile identity,
and not runtime or production readiness.

---

## Case Matrix

| Case | Expected | Result | Purpose |
| --- | --- | --- | --- |
| `valid_packet_assembles_to_finalized_internal` | accepted | PASS | Valid packet maps through helper validation and yields `finalized_internal`. |
| `deterministic_packet_and_result_digest` | accepted | PASS | Rebuilt packet and result digests are deterministic. |
| `bad_authority_remains_invalid_and_does_not_finalize` | rejected | PASS | Bad authority stays invalid and lifecycle remains `implementation_candidate`. |
| `missing_selected_pack_ref_rejected` | rejected | PASS | Missing selected pack ref is rejected via helper diagnostics. |
| `duplicate_row_ownership_rejected` | rejected | PASS | Duplicate row ownership is rejected via helper diagnostics. |
| `excluded_namespace_claim_rejected` | rejected | PASS | `compiler_profile_contract.*` claim is rejected. |

---

## Proof Checks

| Check | Result |
| --- | --- |
| `packet_does_not_become_compiler_input` | PASS |
| `root_require_remains_closed` | PASS |
| `authorized_internal_assembly_file_exists_direct_require_only` | PASS |
| `public_report_runtime_manifest_prop_surfaces_closed` | PASS |
| `case_matrix_expected_results` | PASS |

No failed cases or checks.

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/internal_profile_assembly_boundary_proof/internal_profile_assembly_boundary_proof.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/internal_profile_assembly_boundary_proof/internal_profile_assembly_boundary_proof.rb` | PASS / `cases: 6/6`, `checks: 5/5` |
| `ruby igniter-lang/experiments/internal_profile_assembly_source_packet_proof/internal_profile_assembly_source_packet_proof.rb` | PASS / `cases: 6/6`, `checks: 5/5` |
| `ruby igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/oof_fragment_registry_compiler_profile_source_input_proof.rb` | PASS / `cases: 9/9`, `checks: 6/6` |
| `ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly_source_packet.rb` | PASS / `Syntax OK` |
| `ruby -c igniter-lang/lib/igniter_lang/oof_fragment_registry.rb` | PASS / `Syntax OK` |

---

## Closed Surfaces

The result asserts these surfaces remain closed:

```text
root_require: false
compiler_pipeline_usage: false
public_api_cli: false
loader_report: false
compatibility_report: false
igapp_mutation: false
manifest_mutation: false
prop036_mutation: false
prop038_mutation: false
runtime_behavior: false
production_behavior: false
spark_surface: false
```

The proof also checks:

- no `InternalProfileAssemblySourcePacket` or `InternalProfileAssembly` usage in
  parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator files;
- `lib/igniter_lang.rb` does not require `internal_profile_assembly` or
  `internal_profile_assembly_source_packet`;
- the authorized `lib/igniter_lang/internal_profile_assembly.rb` file exists as
  a direct-require-only internal file, and no
  `lib/igniter_lang/internal_profile_assembly_boundary.rb` file exists;
- public/report/runtime/manifest/PROP-adjacent files do not reference
  `internal_profile_assembly_result`.

---

## Recommendation

R134 maintenance recommendation:

```text
accept R133 closure
Bridge pressure deferred unless a future carrier is proposed
```

Reason:

- internal-only result shape is concrete and deterministic;
- required failure modes remain internal and non-finalizing;
- packet does not become compiler input;
- root require and external surfaces remain closed.

---

## Handoff

[D] `InternalProfileAssemblySourcePacket` can be consumed by a proof-only
boundary that returns `internal_profile_assembly_result`.

[S] Valid packet -> `finalized_internal`. Invalid authority, missing selected
pack, duplicate row ownership, and excluded namespace claims remain invalid and
do not finalize.

[T] PASS:
`ruby igniter-lang/experiments/internal_profile_assembly_boundary_proof/internal_profile_assembly_boundary_proof.rb`
-> `cases: 6/6`, `checks: 5/5`.

[R] Accept proof. Hold implementation review. Bridge pressure remains deferred
until a future card proposes a public/report/loader/manifest carrier.

[Next] If progressing, the next card should decide whether to request an
implementation review for a tiny internal assembly boundary, or hold until
compiler-pack/profile migration planning is clearer.
