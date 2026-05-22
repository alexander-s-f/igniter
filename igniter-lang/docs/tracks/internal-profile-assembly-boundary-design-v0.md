# Track: Internal Profile Assembly Boundary Design v0

Card: LANG-R130-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R129-I1, LANG-R128-A
Track: `internal-profile-assembly-boundary-design-v0`
Status: done
Date: 2026-05-21

---

## Goal

Design how `IgniterLang::InternalProfileAssemblySourcePacket` may participate
in a future internal profile assembly boundary without connecting to the current
compiler pipeline.

This is design-only. It does not authorize implementation.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: owns any proof-only assembly boundary model.
- `[Igniter-Lang Bridge Agent]`: owns pressure before public/report/loader/
  CompatibilityReport/`.igapp` carriers can move.
- `[Architect Supervisor / Codex]`: owns any future implementation
  authorization.

---

## Evidence Read

- `docs/gates/internal-profile-assembly-source-packet-implementation-authorization-review-v0.md`
  (LANG-R128-A)
- `docs/tracks/internal-profile-assembly-source-packet-implementation-v0.md`
  (LANG-R129-I1)
- `lib/igniter_lang/internal_profile_assembly_source_packet.rb`

No commands were run. No code was edited.

---

## Current Fixed Point

R129 implemented:

```ruby
IgniterLang::InternalProfileAssemblySourcePacket
```

It supports:

```ruby
.build(...)
#to_h
#to_helper_envelopes
#validate_with(registry_validator:)
#lifecycle_state
```

R129 proof result:

```text
PASS internal-profile-assembly-source-packet-implementation-v0
cases: 6/6
checks: 5/5
```

Current status:

```text
packet exists as internal constructor/test seam
packet is not required from lib/igniter_lang.rb
packet is not consumed by parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator
```

---

## Decision

Recommended boundary state:

```text
proof-only internal profile assembly boundary next
implementation review held
```

Rationale:

- R129 proves the packet object, not an assembly object.
- A profile assembly boundary needs its own responsibilities, input contract,
  output result shape, and failure vocabulary before implementation.
- Connecting directly to the current compiler pipeline would violate R128/R129
  closure and collapse profile assembly into compile-time dispatch without proof.

Recommended next route:

```text
internal-profile-assembly-boundary-proof-v0
```

Bridge pressure should come after that proof if the proof proposes any carrier
or result shape that could be mistaken for public/report/loader/`.igapp`
metadata. No implementation review should open directly from this track.

---

## Boundary Responsibilities

The future internal profile assembly boundary would be responsible for:

| Responsibility | Meaning |
| --- | --- |
| Accept internal packet | Receive an `InternalProfileAssemblySourcePacket` object from an internal constructor/test seam only. |
| Validate lifecycle | Require `implementation_candidate` input state and treat `finalized_internal` as internal assembly result state only. |
| Validate helper mapping | Call `#to_helper_envelopes` and ensure mapping is deterministic. |
| Validate OOF registry provenance | Call `#validate_with(registry_validator:)` using `IgniterLang::OOFFragmentRegistry`. |
| Preserve owner split | Pack descriptors own row provenance; profile candidate owns selected pack set/order/conflict policy. |
| Produce assembly result | Return an internal result object/hash summarizing validation, lifecycle, packet digest, helper validation, and closed surfaces. |
| Keep non-authority | Make clear this validates profile assembly metadata only; it does not install packs or dispatch compiler passes. |

The boundary must not:

- read files, paths, manifests, loader reports, CompatibilityReports, or runtime
  state;
- require itself from `lib/igniter_lang.rb`;
- call parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator;
- write reports, `.igapp`, `.ilk`, sidecars, goldens, diagnostics, or
  `CompilerResult` fields.

---

## Boundary State Options

| Option | Meaning | Verdict |
| --- | --- | --- |
| `proof_only` | Model an assembly function/result in an experiment using the R129 packet and OOF registry validator. | Recommend next. |
| `design_accepted` | Architect accepts this boundary design as a target but no code exists. | Current track may route to this after review. |
| `implementation_candidate` later | A future card may implement a small internal assembly object after proof and Bridge pressure. | Hold for now. |
| Held | Stop after R129 packet implementation. | Safe fallback, but R129 handoff explicitly routed boundary design next. |

Current recommended status:

```text
design track complete
assembly boundary implementation held
proof-only model next
```

---

## Internal Consumer

The first consumer should be proof-only:

```text
InternalProfileAssemblyBoundaryProof
  consumes InternalProfileAssemblySourcePacket
  consumes IgniterLang::OOFFragmentRegistry
  returns internal profile assembly result
```

Future internal implementation candidate, if later authorized, could be:

```ruby
IgniterLang::InternalProfileAssembly
```

or:

```ruby
IgniterLang::InternalProfileAssembly::Boundary
```

No name is authorized here. The next proof should test the concept without
adding a new lib file.

Rejected consumers for now:

| Consumer | Reason |
| --- | --- |
| `IgniterLang.compile` / Ruby facade | Would open public API behavior. |
| CLI | Would open path loading and public error semantics. |
| `CompilerOrchestrator` | Would connect to current compiler pipeline. |
| Parser/classifier/TypeChecker/SemanticIR/assembler | Wrong layer; profile assembly metadata is not a pass input yet. |
| `CompilationReport` / `CompilerResult` | Would open report/public result carriers. |
| Loader/report / CompatibilityReport | Would create external evidence/readiness semantics. |
| `.igapp` manifest | Would mutate artifact identity and PROP-036 boundaries. |

---

## Assembly Result Shape

The proof-only result should be an internal hash:

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
    "prop036_mutation": false,
    "prop038_mutation": false,
    "runtime_behavior": false,
    "production_behavior": false,
    "spark_surface": false
  }
}
```

Result rules:

- `valid: true` only if packet validation and all helper validations pass.
- `lifecycle_state: "finalized_internal"` means internal assembly result only.
- `diagnostics` are internal proof diagnostics, not language OOF codes and not
  centralized diagnostics.
- `packet_digest` and `helper_envelopes_digest` are proof-local determinism
  evidence, not manifest identity.
- The result must not be persisted, reported, assembled, or exposed publicly.

---

## Required Proof Cases Before Implementation Review

The proof-only boundary should cover:

| Case | Expected |
| --- | --- |
| valid packet assembles to `finalized_internal` result | PASS |
| deterministic packet/result digest | PASS |
| bad authority remains `implementation_candidate` and invalid | PASS |
| missing selected pack ref rejected | PASS |
| duplicate row ownership rejected | PASS |
| excluded namespace claim rejected | PASS |
| packet does not become compiler input | PASS |
| root require remains closed | PASS |
| public/report/runtime/manifest/PROP surfaces remain closed | PASS |

Minimum command matrix for the proof:

```text
ruby -c igniter-lang/experiments/internal_profile_assembly_boundary_proof/internal_profile_assembly_boundary_proof.rb
ruby igniter-lang/experiments/internal_profile_assembly_boundary_proof/internal_profile_assembly_boundary_proof.rb
ruby igniter-lang/experiments/internal_profile_assembly_source_packet_proof/internal_profile_assembly_source_packet_proof.rb
ruby igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/oof_fragment_registry_compiler_profile_source_input_proof.rb
ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly_source_packet.rb
```

Broad compiler regressions can be deferred unless the proof touches compiler
files, which it should not.

---

## Closed Surfaces

This track keeps closed:

- implementation;
- root require from `igniter-lang/lib/igniter_lang.rb`;
- current compiler pipeline usage;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  `CompilationReport`, `CompilerResult`, diagnostics, and CLI changes;
- public API/CLI;
- loader/report;
- CompatibilityReport;
- `.igapp`, `.ilk`, manifest, sidecar, and golden mutation;
- PROP-036 behavior mutation;
- PROP-038 behavior mutation;
- `oof_fragment_registry_data.rb`;
- runtime, production, Spark, Ledger/TBackend, Gate 3, cache, and signing.

---

## Recommendation

Recommended next route:

```text
proof-only
```

Suggested card:

```text
internal-profile-assembly-boundary-proof-v0
```

Implementation review:

```text
hold
```

Bridge pressure:

```text
defer until proof result shape exists, then run if any carrier ambiguity appears
```

---

## Handoff

[D] The future profile assembly boundary should remain proof-only next. It may
consume `InternalProfileAssemblySourcePacket` internally and produce an
`internal_profile_assembly_result`, but it must not connect to the current
compiler pipeline.

[S] `finalized_internal` should be the result lifecycle state of successful
internal assembly only. It is not PROP-036 finalization, not `compiler_profile_id`,
and not manifest/profile identity.

[T] No commands run. Docs-only design track.

[R] Recommended next route: proof-only
`internal-profile-assembly-boundary-proof-v0`. Implementation review hold.

[Next] Build a proof-local assembly boundary/result shape around the existing
packet and OOF registry validator, with closed-surface assertions.
