# PROP-036 CLI B1 Standalone Artifact Proof v0

Card: S3-R48-C1-I
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `prop036-cli-b1-standalone-artifact-proof-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` owns future changes to the
  compiler-profile-source validation contract.
- `[Igniter-Lang Bridge Agent]` may consume the standalone artifact as the
  future CLI `--compiler-profile-source PATH.json` payload shape.

## Goal

Close or precisely assess `PROP036-CLI-B1` by emitting and validating the
standalone `compiler_profile_source.stage3_proof.json` artifact under the R47
validation-chain requirement.

This track does not authorize CLI implementation.

## Inputs Read

```text
igniter-lang/docs/gates/prop036-b7-b8-docs-and-criteria-precision-review-v0.md
igniter-lang/docs/gates/prop036-cli-blocker-closure-criteria-decision-v0.md
igniter-lang/docs/tracks/prop036-cli-b1-standalone-source-artifact-closure-v0.md
igniter-lang/docs/tracks/minimal-compiler-profile-finalization-proof-v0.md
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/
```

## Implementation Boundary

Updated only the proof-local finalization experiment:

```text
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/
```

The update emits a standalone caller-like artifact:

```text
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json
```

and validates it by rereading the file and passing it through
`validate_source!`, the proof-local validation path documented as equivalent to
the assembler source contract.

## What Changed In The Proof

Added proof-owned output:

```text
out/compiler_profile_source.stage3_proof.json
```

Added B1 checks:

```text
B1.standalone_artifact_exists
B1.standalone_artifact_is_source_object
B1.standalone_artifact_matches_finalized_source
B1.standalone_artifact_validates_via_source_contract
B1.standalone_artifact_exact_forbidden_token_scan
```

The standalone artifact is top-level `compiler_profile_id_source` JSON. It is
not a summary wrapper and does not contain `finalized_source_example`.

## Required Summary Fields

The proof summary now records:

```text
standalone_artifact_path="igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json"
standalone_artifact_exists=true
standalone_artifact_valid=true
standalone_artifact_validation_path="finalization_and_assembler_source_contract"
standalone_artifact_exact_forbidden_token_hits=0
```

Independent verification:

```text
artifact.kind=compiler_profile_id_source
artifact.status=finalized
artifact.wrapper=false
```

## Command Matrix

| Command | Purpose | Result |
| --- | --- | --- |
| `ruby -c igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb` | Syntax check | PASS |
| `ruby igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb` | Emit + validate standalone artifact | PASS 27/27 |
| `ruby -rjson -e 'summary=JSON.parse(File.read("igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/minimal_compiler_profile_finalization_summary.json")); %w[standalone_artifact_path standalone_artifact_exists standalone_artifact_valid standalone_artifact_validation_path standalone_artifact_exact_forbidden_token_hits].each { |k| puts "#{k}=#{summary.fetch(k).inspect}" }; artifact=JSON.parse(File.read("igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json")); puts "artifact.kind=#{artifact.fetch("kind")}"; puts "artifact.status=#{artifact.fetch("status")}"; puts "artifact.wrapper=#{artifact.key?("finalized_source_example")}"'` | Verify required fields and artifact shape | PASS |
| `ruby igniter-lang/experiments/assembler_compiler_profile_id_field/assembler_compiler_profile_id_field.rb` | Neighbor source-contract regression | PASS 19/19 |

## Exact Proof Output

```text
MinimalCompilerProfileFinalizationProof: PASS
  27/27 checks PASS
  PASS F1.valid_descriptor_produces_source
  PASS F2.permuted_hash_keys_same_id
  PASS F3.implementation_identity_change_changes_id
  PASS F4.payload_does_not_contain_profile_id
  PASS F5.payload_id_inclusion_refused
  PASS F6.missing_source_refused
  PASS F7.malformed_descriptor_refused
  PASS F8.wrong_kind_refused
  PASS F9.slot_order_mismatch_in_finalization
  PASS V1.unfinalized_status_refused
  PASS V2.unsupported_namespace_refused
  PASS V3.malformed_id_refused
  PASS V4.digest_mismatch_refused
  PASS V5.slot_order_mismatch_in_validation
  PASS V6.runtime_authority_refused
  PASS V7.dispatch_migration_refused
  PASS INV1.profile_id_not_in_finalization_payload
  PASS INV2.status_is_finalized
  PASS INV3.no_runtime_authority
  PASS INV4.no_dispatch_migration
  PASS INV5.id_format_valid
  PASS INV6.produced_source_passes_validation
  PASS B1.standalone_artifact_exists
  PASS B1.standalone_artifact_is_source_object
  PASS B1.standalone_artifact_matches_finalized_source
  PASS B1.standalone_artifact_validates_via_source_contract
  PASS B1.standalone_artifact_exact_forbidden_token_scan
Summary: igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/minimal_compiler_profile_finalization_summary.json
```

## B1 Assessment

Recommendation: **B1 closed**.

Closure evidence:

- dedicated standalone artifact exists at the R46/R47 stable path;
- artifact top-level JSON is the source object itself;
- artifact is generated by the named finalization proof command;
- artifact validates through the `finalization_and_assembler_source_contract`
  validation path;
- exact forbidden-token hits over the standalone artifact: `0`;
- summary records all required fields;
- no CLI implementation or path-loading behavior was added.

## Remaining Non-Authorizations

Still closed:

```text
CLI flags
path loading
JSON parsing in CLI
loader/report
CompatibilityReport
golden migration
.ilk
receipts
signing
dispatch migration
RuntimeMachine
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

## Next Blockers

B1 is closed by this proof, but CLI implementation remains blocked by the
remaining `PROP036-CLI-B*` closure package, including B3/B4/B5/B6/B9 and any
Architect implementation authorization still required after closure.

## Handoff

```text
Card: S3-R48-C1-I
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop036-cli-b1-standalone-artifact-proof-v0
Status: done

[D] Decisions
- B1 is closed.
- Standalone artifact emitted at `igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json`.
- The artifact validates through `finalization_and_assembler_source_contract`, not just JSON/field shape.
- Exact forbidden-token hits over the standalone artifact: 0.

[S] Signals
- Proof now emits a caller-like top-level `compiler_profile_id_source` JSON payload.
- The proof summary records all R47-required standalone artifact fields.
- Assembler field proof remains green.

[T] Tests / Proofs
- `ruby -c igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb` PASS.
- `ruby igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb` PASS 27/27.
- Required summary field verification PASS.
- `ruby igniter-lang/experiments/assembler_compiler_profile_id_field/assembler_compiler_profile_id_field.rb` PASS 19/19.

[R] Recommendation
- Mark `PROP036-CLI-B1` closed.
- Continue holding CLI implementation until the remaining blockers close and an explicit Architect implementation decision lands.

[Files] Changed
- `igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb`
- `igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/minimal_compiler_profile_finalization_summary.json`
- `igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json`
- `igniter-lang/docs/tracks/prop036-cli-b1-standalone-artifact-proof-v0.md`

[Q] Open Questions
- Should the standalone artifact later be promoted from proof output to a golden-like fixture for CLI tests?

[X] Rejected
- Satisfying B1 with JSON well-formedness, field presence, or top-level shape only.
- Adding CLI flags/path loading/JSON parsing in CLI.

[Next] Proposed next slice
- Close B3/B6 refusal and scanner criteria, or run a blocker status consolidation for the remaining CLI package.
```
