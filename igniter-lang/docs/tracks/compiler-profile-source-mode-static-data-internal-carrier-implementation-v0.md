# Compiler Profile Source-Mode Static-Data Internal Carrier Implementation v0

Card: S3-R154-C2-I  
Agent: `[Igniter-Lang Compiler/Grammar Expert]`  
Role: `compiler-grammar-expert`  
Route: UPDATE  
Depends on: S3-R154-C1-A, S3-R154-C2-S  
Track: `compiler-profile-source-mode-static-data-internal-carrier-implementation-v0`  
Status: done / PASS  
Date: 2026-05-23

---

## Neighbor Awareness

Affected neighbor roles:

- `[Igniter-Lang Research Agent]` - R153 proof artifacts remain evidence only;
  this card does not rewrite them.
- `[Igniter-Lang Bridge Agent]` - public/report/artifact/runtime/Spark/demo
  surfaces remain closed and still require fresh Portfolio-visible review before
  any widening.

---

## Implementation Boundary

Implemented the direct-require-only internal carrier:

```text
IgniterLang::InternalProfileStaticDataCarrier
```

File:

```text
igniter-lang/lib/igniter_lang/internal_profile_static_data_carrier.rb
```

Allowed require used:

```text
require_relative "internal_profile_assembly_source_packet"
```

The file is not required from `lib/igniter_lang.rb` and does not require parser,
classifier, TypeChecker, SemanticIR, assembler, CLI, report, runtime, Spark,
adapter, or production files.

---

## Carrier API

Authorized constants:

```text
KIND = "internal_profile_static_data_carrier"
FORMAT_VERSION = "0.1.0"
STATIC_DATA_STATUSES = ["proof_local_only", "internal_test_seam_only"]
```

Authorized constructor/test seam:

```text
IgniterLang::InternalProfileStaticDataCarrier.build(static_data:)
```

Authorized instance methods:

```text
#to_h
#valid_shape?
#diagnostics
#to_source_packet
#static_data_digest
```

`#to_source_packet` maps valid carrier input into
`IgniterLang::InternalProfileAssemblySourcePacket`. Invalid carriers return no
packet and expose only internal carrier diagnostics.

---

## Validation Policy

Accepted input requires:

- carrier kind and format version;
- `static_data_status` of `proof_local_only` or `internal_test_seam_only`;
- authority kind of `proof_only` or `design_accepted`;
- canon status of `non_canon` or `accepted_design`;
- present `profile_candidate`;
- non-empty `pack_descriptor_candidates`;
- all `closed_surface_assertions` values closed.

Rejected input includes:

- missing `profile_candidate`;
- empty or missing `pack_descriptor_candidates`;
- unsupported kind, format version, or static-data status;
- authority outside proof/design scope;
- canon or production-style canon status;
- any open closed-surface assertion;
- forbidden public/profile/report/artifact/runtime/Spark/demo fields.

Diagnostics are internal-only and use the authorized
`internal_profile_static_data_carrier.*` vocabulary.

---

## Output Constraints

`#to_h` returns only:

```text
kind
format_version
valid
static_data_status
authority
profile_candidate
pack_descriptor_candidates
excluded_namespaces
diagnostics
static_data_digest
closed_surface_assertions
```

Carrier output does not include compiler-profile identity/source fields,
public/report/runtime readiness fields, manifest identity, compatibility status,
Spark/demo readiness, or `finalized_internal`.

The proof runner writes sanitized evidence only. It does not persist full
packet, registry, or assembly reports because those older internal objects carry
their own closed-surface payload vocabulary.

---

## Proof Artifacts

Runner:

```text
igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof.rb
```

Outputs:

```text
igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/out/carrier_output.valid.sanitized.json
igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/out/carrier_output.invalid_cases.sanitized.json
igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/out/assembly_evidence.sanitized.json
igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/out/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof_summary.json
```

Synthetic data is created only inside this proof runner/output directory.

---

## Proof Matrix

| Requirement | Evidence |
| --- | --- |
| Valid synthetic/internal static data builds carrier | `valid_static_data.builds_carrier` |
| Carrier maps to `InternalProfileAssemblySourcePacket` | `carrier.maps_to_source_packet` |
| Packet validates through `OOFFragmentRegistry` | `packet.validates_through_oof_fragment_registry` |
| Assembly can reach `finalized_internal` only internally | `assembly.finalizes_only_internal_lifecycle` |
| Duplicate ownership rejected before finalization | `duplicate_ownership.rejected_before_finalized_internal` |
| Invalid status/authority/fields/open surfaces rejected | `invalid_cases.rejected` |
| Carrier output excludes forbidden vocabulary | `carrier_outputs.forbidden_tokens_absent` |
| R153 proof artifacts did not need rewrite | `r153_artifacts.not_required_to_rewrite` |
| Live closed surfaces remain closed | `live_closed_surfaces.remain_closed` |

---

## Required Command Matrix

```text
ruby -c igniter-lang/lib/igniter_lang/internal_profile_static_data_carrier.rb
ruby igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof.rb
ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly_source_packet.rb
ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly.rb
ruby -c igniter-lang/lib/igniter_lang/oof_fragment_registry.rb
```

Observed results:

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/internal_profile_static_data_carrier.rb` | PASS |
| `ruby igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof.rb` | PASS |
| `ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly_source_packet.rb` | PASS |
| `ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly.rb` | PASS |
| `ruby -c igniter-lang/lib/igniter_lang/oof_fragment_registry.rb` | PASS |

---

## Closed Surfaces

This card does not authorize:

- root require;
- classifier wiring or live classifier dispatch;
- `contract_fragment_for` replacement;
- parser, TypeChecker, SemanticIR, assembler, report, or `.igapp` work;
- `ClassifiedProgram` schema changes;
- public API/CLI;
- loader/report;
- `CompilationReport`, `CompilerResult`, or CompatibilityReport;
- manifest, sidecar, artifact hash, or golden migration;
- shared fixtures or generated indexes;
- embedded internal library static registry rows;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, production pressure, or demo work;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  or deployment work.

---

## Changed Files

```text
igniter-lang/lib/igniter_lang/internal_profile_static_data_carrier.rb
igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof.rb
igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/out/*.json
igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-internal-carrier-implementation-v0.md
```

No other files are in the intended write scope.

---

## Recommendation

Recommend acceptance review for S3-R154-C2-I if the required command matrix
passes and `git status --short` shows only the authorized write scope.

Next review should stay acceptance-only unless a fresh Portfolio-visible card
opens a wider source/input, compiler integration, public/report, artifact,
runtime, Spark, production, or demo surface.
