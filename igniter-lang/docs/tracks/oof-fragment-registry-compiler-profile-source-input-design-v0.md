# Track: OOF/Fragment Registry Compiler Profile Source Input Design v0

Card: LANG-R124-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R123-H1, LANG-R122-I1
Track: `oof-fragment-registry-compiler-profile-source-input-design-v0`
Status: done
Date: 2026-05-21

---

## Goal

Design whether accepted internal `profile_candidate` and
`pack_descriptor_candidate` source envelopes may become a future compiler-pack
or compiler-profile source input, without opening compiler integration.

This is design-only. It does not authorize implementation.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: owns any next proof-only source-input model.
- `[Igniter-Lang Bridge Agent]`: must review before loader/report, public
  API/CLI, or CompatibilityReport surfaces move.
- `[Architect Supervisor / Codex]`: owns any future implementation
  authorization.

---

## Evidence Read

- `docs/gates/oof-fragment-registry-profile-pack-source-acceptance-authorization-review-v0.md`
  (LANG-R121-A)
- `docs/tracks/oof-fragment-registry-profile-pack-source-acceptance-proof-v0.md`
  (LANG-R122-I1)
- `docs/tracks/oof-fragment-registry-profile-pack-source-proof-refresh-v0.md`
  (LANG-R123-H1)
- `lib/igniter_lang/oof_fragment_registry.rb`
- `docs/dev/compiler-profile-architecture-direction.md`
- `docs/tracks/compiler-pack-boundary-report-v0.md`

No commands were run. No code was edited.

---

## Current Fixed Point

R121 authorized only a bounded internal helper implementation. R122 implemented
that helper acceptance. R123 refreshed stale proofs and made the R121/R122 matrix
green.

Current accepted helper state:

```text
SOURCE_ACCEPTED_MODES =
  proof_fixture
  caller_supplied
  profile_candidate
  pack_descriptor_candidate

SOURCE_HELD_MODES = []
```

Current semantic boundary:

```text
accepted source envelope
  = internal validation input to IgniterLang::OOFFragmentRegistry
  != compiler pass input
  != public API/CLI input
  != loader/report input
  != CompatibilityReport evidence
  != .igapp/manifest field
  != PROP-036 compiler_profile_id authority
  != PROP-038 validator/report authority
```

---

## Decision

Recommendation:

```text
Open a proof-only compiler-profile source-input model next.
Hold implementation review.
Do not route Bridge pressure yet unless the next proof proposes public/report/
loader/CompatibilityReport carriers.
```

Rationale:

- The helper now proves internal profile/pack source-envelope acceptance.
- The compiler-pack architecture direction needs a future source input for pack
  row provenance and profile-selected pack order.
- But the current helper accepts caller-supplied Hash envelopes through direct
  proof-local calls only; it does not define where compiler/profile input comes
  from.
- Moving directly to compiler integration would smuggle in source loading,
  lifecycle, report, profile identity, and dispatch questions that are still
  closed.

The next safe route is a proof-only model that treats helper-accepted envelopes
as candidate data for a future `CompilerProfile` assembly step, without touching
the current compiler pipeline.

---

## Boundary Options

| Option | Meaning | Authority required | Verdict |
| --- | --- | --- | --- |
| Internal compiler-profile source input | A proof-only `CompilerProfile` candidate carries selected pack descriptors, validates them through `OOFFragmentRegistry#validate_source_envelope`, and records internal validation evidence. | Proof card only at first; implementation held. | Recommend as next route. |
| Pack/profile descriptor source input | Lower-level proof model where individual pack descriptors are supplied first, then a profile aggregate chooses order/conflict policy. | Proof card only; later helper API design if proven. | Recommend as subshape inside the proof-only route. |
| Still helper-only hold | Stop at direct helper calls and do not model compiler/profile source input yet. | None. | Safe but too conservative after R123; use only if Architect wants pause. |
| Live compiler integration | Current compiler/orchestrator consumes profile/pack source envelopes during compile. | Separate implementation gate, compiler authority, proof matrix, likely Bridge review. | Reject for now. |
| Public/API/CLI source input | Ruby facade or CLI accepts OOF registry profile/pack source material. | Public API/CLI design, Bridge review, docs, implementation gate. | Closed. |
| Loader/report/CompatibilityReport source input | Loader/report layers consume OOF registry source evidence. | Bridge review plus report/loader authority. | Closed. |

---

## Recommended Source-Input Shape

The next proof-only model should define a source-input packet, not a compiler
implementation API:

```json
{
  "kind": "compiler_profile_oof_registry_source_input",
  "format_version": "0.1.0",
  "authority": {
    "authority_ref": "proof-or-design-ref",
    "authority_kind": "proof_only",
    "canon_status": "non_canon"
  },
  "profile_candidate": {
    "source_mode": "profile_candidate",
    "profile_ref": "compiler_profile_candidate/proof:...",
    "selected_pack_refs": [],
    "pack_order": [],
    "conflict_policy": {}
  },
  "pack_descriptor_candidates": [],
  "validation_target": "oof_fragment_registry_source_envelope_helper",
  "closed_surface_assertions": {
    "compiler_integration": false,
    "public_api_cli": false,
    "loader_report": false,
    "compatibility_report": false,
    "igapp_mutation": false,
    "prop036_manifest_change": false,
    "prop038_validator_report_change": false,
    "runtime_behavior": false
  }
}
```

Rules:

- The packet is proof-only data.
- It is not a method argument to `IgniterLang.compile`.
- It is not a CLI option.
- It is not read from `.igapp`, manifests, loader reports, or runtime state.
- It must be translated into the already accepted helper envelope shape before
  validation.
- Helper diagnostics stay internal to the proof result.

---

## Source Input Semantics

### Internal Compiler-Profile Source Input

This model would answer:

- which profile candidate selects the pack set;
- which pack descriptors contribute OOF/fragment/support rows;
- whether pack-row provenance and profile conflict policy validate;
- whether the derived registry validates through the existing helper.

It would not answer:

- which packs are installed in the real compiler;
- which parser/classifier/typechecker/IR handlers are dispatched;
- whether `.igapp` should carry this source;
- whether the profile has a public identity;
- whether reports should expose registry evidence;
- whether runtime can trust or execute anything.

### Pack/Profile Descriptor Source Input

This is the lower-level model inside the proof:

```text
pack_descriptor_candidate rows
  -> profile_candidate selected_pack_refs + pack_order + conflict_policy
  -> helper validation
  -> proof-local source-input result
```

Pack-row authority remains primary for row identity/provenance.
Profile-level authority remains primary for selected pack set, order, and
aggregate conflict policy.

---

## Evidence Required Before Compiler Integration

No compiler integration should be considered until all of the following exist:

| Evidence | Required result |
| --- | --- |
| Proof-only source-input model | PASS: profile/pack source-input packet maps deterministically to helper envelopes. |
| R121/R122/R123 matrix | PASS after the source-input proof. |
| No compiler pass usage | PASS: parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator do not call the source input. |
| No public carrier | PASS: no Ruby facade, CLI, docs/API, or config surface accepts source input. |
| No loader/report carrier | PASS: no `CompilationReport`, loader report, or CompatibilityReport field is created. |
| No manifest mutation | PASS: `.igapp`, `.ilk`, manifest, sidecar, and goldens unchanged. |
| PROP-036 separation | PASS: source input does not derive or mutate `compiler_profile_id`. |
| PROP-038 separation | PASS: source input does not alter validator/report/refusal behavior. |
| Failure taxonomy | PASS: missing pack, duplicate rows, bad authority, canon status, and excluded namespace failures remain internal proof diagnostics. |
| Source lifecycle decision | Design accepted: whether source packets are ephemeral proof data, finalized profile material, pack descriptor material, or still held. |

Only after that proof should an Architect review decide whether to design an
internal implementation boundary.

---

## Compiler Integration Preconditions

Before any implementation review for actual compiler integration, require:

1. A named source owner:

```text
CompilerProfile candidate finalization
or
CompilerPack descriptor finalization
or
explicitly held/no live source
```

2. A lifecycle state model:

```text
proof_only
design_accepted
implementation_candidate
finalized_internal
```

3. A carrier decision:

```text
internal constructor/test seam only
no public API/CLI
no loader/report
no CompatibilityReport
no .igapp/manifest
```

4. A pass-boundary decision:

```text
before compile
after SemanticIR
before assembly
profile assembly only
```

Current recommendation for first proof:

```text
profile assembly only, outside the current compiler pipeline
```

5. A non-authority statement:

```text
source input validates registry provenance only;
it does not install packs, dispatch compiler rules, emit reports, or authorize runtime.
```

---

## Closed Surfaces

This track keeps closed:

- implementation;
- compiler integration;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  `CompilationReport`, `CompilerResult`, diagnostics, and CLI changes;
- public API/CLI;
- loader/report;
- CompatibilityReport;
- `.igapp`, `.ilk`, manifest, sidecar, and golden mutation;
- PROP-036 behavior mutation;
- PROP-038 behavior mutation;
- `lib/igniter_lang.rb` require changes;
- `oof_fragment_registry_data.rb`;
- runtime, production, Spark, Ledger/TBackend, Gate 3, cache, and signing.

---

## Handoff

[D] Accepted internal source envelopes may become a future compiler-profile
source-input model only as proof-only data first. They are not yet compiler
integration inputs.

[S] The safest next boundary is a proof-only packet that maps selected
profile/pack descriptors to the existing helper envelopes and proves no public,
report, loader, manifest, PROP-036, PROP-038, compiler, or runtime surface opens.

[T] No commands run. Docs-only design track.

[R] Recommended route: proof-only next. Implementation review hold. Bridge
pressure is required only if a later route proposes public/API, loader/report,
CompatibilityReport, or `.igapp` carriers.

[Next] Proposed proof route:
`oof-fragment-registry-compiler-profile-source-input-proof-v0`.
