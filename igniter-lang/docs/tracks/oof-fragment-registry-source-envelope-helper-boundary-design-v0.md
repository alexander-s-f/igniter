# Track: OOF/Fragment Registry Source Envelope Helper Boundary Design v0

Card: LANG-R109-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Track: `oof-fragment-registry-source-envelope-helper-boundary-design-v0`
Status: done
Date: 2026-05-21

---

## Goal

Design whether source-envelope validation should remain proof-local or become a
bounded internal helper near `IgniterLang::OOFFragmentRegistry` in a future
implementation slice.

This track is design-only. It does not implement code and does not touch
loader/report, public API/CLI, compiler integration, specs/canon/proposals,
`oof_fragment_registry_data.rb`, `lib/igniter_lang.rb`, `.igapp`, runtime,
production, or Spark surfaces.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: owns future proof-local helper evidence.
- `[Igniter-Lang Architect Supervisor]`: owns any helper implementation
  authorization review.
- `[Igniter-Lang Bridge Agent]`: loader/report, CompatibilityReport, public
  API/CLI, and runtime surfaces remain closed.

---

## Evidence Read

- `docs/tracks/oof-fragment-registry-loader-supplied-data-source-design-v0.md`
  (LANG-R106-D1)
- `docs/tracks/oof-fragment-registry-supplied-data-source-proof-v0.md`
  (LANG-R107-P1)
- `docs/gates/oof-fragment-registry-source-envelope-validation-placement-decision-v0.md`
  (LANG-R108-A)
- `experiments/oof_fragment_registry_supplied_data_source_proof/oof_fragment_registry_supplied_data_source_proof.rb`
- `lib/igniter_lang/oof_fragment_registry.rb`

No tests or broad proof commands were run.

---

## Decision

Recommendation:

```text
Open a bounded internal helper implementation review.
Place the helper inside `lib/igniter_lang/oof_fragment_registry.rb`.
Do not create a separate helper file.
Do not expose or require it from `lib/igniter_lang.rb`.
Accepted source modes: proof_fixture and caller_supplied only.
```

Short form:

```text
placement: private/internal helper in OOFFragmentRegistry
not: experiment-only forever
not: separate internal file
not: public/loader/compiler integration
```

Rationale:

- R107 proved the source-envelope precheck is useful and safe when local.
- Duplicating that precheck across future proofs would create drift.
- Keeping it inside `oof_fragment_registry.rb` preserves the existing isolated
  validator boundary and avoids a new require path.
- A separate file would look like a new source-loading subsystem.
- The helper must remain internal evidence plumbing, not public data loading.

---

## Placement Comparison

| Placement | Decision | Strength | Risk | Notes |
| --- | --- | --- | --- | --- |
| Remain experiment-local | Acceptable fallback | Zero library change. | Repeated proof-local copies drift; future proofs may disagree on source modes. | Use only if Architect holds implementation. |
| Private/internal helper in `oof_fragment_registry.rb` | Recommended | Single internal authority next to nested registry validator; no new file. | Must avoid public API interpretation. | Best future implementation slice. |
| Separate internal file | Reject for now | Clean separation on paper. | New file invites require/discovery and looks like loader/source subsystem. | Reconsider only after source-authority design. |
| Reject helper entirely | Reject | Maximum closure. | Leaves accepted R107 proof as one-off evidence and loses reusable boundary. | Too conservative after R108. |

---

## Helper Boundary

Candidate future helper shape:

```ruby
IgniterLang::OOFFragmentRegistry#validate_source_envelope(source_envelope, installed_boundaries: nil)
```

Allowed behavior:

- validate source-envelope shape;
- accept only `source_mode: "proof_fixture"` and
  `source_mode: "caller_supplied"`;
- reject `profile_candidate`, `pack_descriptor_candidate`, and canon-status
  envelopes;
- call existing `validate(registry_hash, installed_boundaries:)` only after the
  source envelope passes;
- return an internal-only result hash;
- preserve all existing registry validation diagnostics and result shape.

Forbidden behavior:

- no file loading;
- no default/static registry lookup;
- no require from `lib/igniter_lang.rb`;
- no public API/CLI;
- no compiler pass lookup;
- no report/`CompilerResult`/CompatibilityReport fields;
- no `.igapp` mutation;
- no loader/refusal/runtime behavior.

Method visibility:

```text
internal method, not facade API
```

It may be callable by proof-local harnesses through direct require of
`lib/igniter_lang/oof_fragment_registry.rb`, matching R103/R107 isolation.

---

## Accepted And Rejected Source Modes

Accepted modes for any future helper:

| Source mode | Status | Constraints |
| --- | --- | --- |
| `proof_fixture` | accepted | Must be non-canon; proof/track authority only. |
| `caller_supplied` | accepted | Internal caller in proof or future authorized internal seam only; not public API/CLI. |

Rejected/held modes:

| Source mode | Status | Diagnostic |
| --- | --- | --- |
| `profile_candidate` | held/rejected in helper | `oof_registry.source.validation.held_source_mode` |
| `pack_descriptor_candidate` | held/rejected in helper | `oof_registry.source.validation.held_source_mode` |
| any canon-status envelope | rejected | `oof_registry.source.validation.canon_status_forbidden` |
| `static_internal_data` or default/config path | rejected | `oof_registry.source.validation.unsupported_source_mode` |
| unknown mode | rejected | `oof_registry.source.validation.unsupported_source_mode` |

Rejected modes must remain internal-only and must not become loader/report,
public API/CLI, or compiler diagnostics.

---

## Internal Result Shape

Candidate helper result:

```json
{
  "kind": "oof_fragment_registry_source_validation",
  "format_version": "0.1.0",
  "valid": true,
  "source_mode": "proof_fixture",
  "registry_present": true,
  "source_diagnostics": [],
  "registry_validation": {
    "kind": "oof_fragment_registry_validation",
    "valid": true,
    "diagnostics": []
  },
  "closed_surface_assertions": {
    "static_data_file": false,
    "lib_igniter_lang_rb_require": false,
    "compiler_pass_integration": false,
    "public_api_cli": false,
    "top_level_report_diagnostics": false,
    "compiler_result_field": false,
    "loader_report": false,
    "compatibility_report": false,
    "runtime_behavior": false,
    "igapp_mutation": false,
    "specs_canon_proposals": false
  }
}
```

Rules:

- `valid` is true only when source-envelope validation passes and nested
  registry validation passes.
- `source_diagnostics` contain only source-envelope helper diagnostics.
- nested registry failures remain under `registry_validation.diagnostics`.
- no public/result/report/runtime keys may appear.
- closed-surface assertions must remain false.

For invalid source envelopes, `registry_validation` may be `null` because the
nested registry must not be trusted before source envelope validation passes.

---

## Diagnostic Vocabulary

Candidate helper diagnostics:

| Code | Meaning |
| --- | --- |
| `oof_registry.source.validation.wrong_kind` | Source envelope is not a Hash or has wrong `kind`. |
| `oof_registry.source.validation.unsupported_format_version` | Source envelope format version is unsupported. |
| `oof_registry.source.validation.unsupported_source_mode` | Source mode is unknown or explicitly unsupported. |
| `oof_registry.source.validation.held_source_mode` | Source mode is known but held: `profile_candidate` or `pack_descriptor_candidate`. |
| `oof_registry.source.validation.invalid_authority_kind` | Authority kind is outside proof/design scope for this helper. |
| `oof_registry.source.validation.canon_status_forbidden` | Canon-status source envelope is forbidden. |
| `oof_registry.source.validation.missing_authority` | Authority object is missing or malformed. |
| `oof_registry.source.validation.missing_authority_ref` | Authority object lacks `authority_ref`. |
| `oof_registry.source.validation.missing_registry` | Nested `registry` hash is missing. |
| `oof_registry.source.validation.surface_open` | Closed-surface assertions are not all false. |

These are internal helper diagnostics. They are not language OOF codes, not
public diagnostics, and not central `IgniterLang::Diagnostics` entries.

---

## Exact Future Write Scope

If a later Architect gate authorizes implementation, the candidate write scope
should be:

```text
lib/igniter_lang/oof_fragment_registry.rb
experiments/oof_fragment_registry_source_envelope_helper_proof/**
docs/tracks/oof-fragment-registry-source-envelope-helper-proof-v0.md
```

Allowed changes:

- add internal helper method and constants to `oof_fragment_registry.rb`;
- add proof-local helper harness and outputs;
- add proof handoff track.

Explicitly forbidden:

- `lib/igniter_lang/oof_fragment_registry_data.rb`;
- `lib/igniter_lang.rb`;
- separate helper file such as `oof_fragment_registry_source.rb`;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  compilation report, compiler result, CLI, diagnostics;
- `docs/spec/`;
- `docs/proposals/`;
- existing `.igapp` outputs or goldens;
- loader/report, CompatibilityReport, runtime, production, Spark surfaces.

---

## Proof Matrix

Any helper implementation review should require at least:

| Command | Purpose |
| --- | --- |
| `ruby -c lib/igniter_lang/oof_fragment_registry.rb` | Syntax check updated internal validator/helper. |
| `ruby experiments/oof_fragment_registry_source_envelope_helper_proof/oof_fragment_registry_source_envelope_helper_proof.rb` | Helper-specific source mode, canon-status, result-shape, and closed-surface proof. |
| `ruby experiments/oof_fragment_registry_supplied_data_source_proof/oof_fragment_registry_supplied_data_source_proof.rb` | R107 supplied-data proof remains valid or is explicitly superseded by helper proof. |
| `ruby experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | R103 nested registry validator proof remains valid. |
| `ruby experiments/classifier_pass_proof/classifier_pass_proof.rb` | Classifier parity; no OOF classification drift. |
| `ruby experiments/typechecker_proof/typechecker_proof.rb --check-golden` | TypeChecker parity. |
| `ruby experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | SemanticIR/report parity. |
| `ruby experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | `.igapp` parity. |
| `ruby experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PROP-038 separation from OOF remains intact. |

Required helper proof cases:

- valid `proof_fixture` source validates nested registry;
- valid `caller_supplied` source validates nested registry;
- wrong kind rejected internally;
- missing registry rejected internally;
- `profile_candidate` rejected/held internally;
- `pack_descriptor_candidate` rejected/held internally;
- canon status rejected internally;
- `surface_open` rejected internally;
- invalid nested registry reports nested registry diagnostics without public
  surface keys;
- no `oof_fragment_registry_data.rb`;
- no `lib/igniter_lang.rb` require;
- no compiler pass require;
- no public/report/runtime keys.

---

## Blockers Before Implementation

Before any helper implementation authorization, require:

- Architect decision accepting helper placement inside
  `lib/igniter_lang/oof_fragment_registry.rb`;
- exact method name and result shape accepted;
- accepted source modes pinned to `proof_fixture` and `caller_supplied`;
- held/rejected behavior pinned for `profile_candidate`,
  `pack_descriptor_candidate`, and canon-status envelopes;
- proof matrix accepted;
- closed-surface assertions preserved;
- explicit rejection of separate helper file and static data file;
- confirmation that helper implementation does not imply source-authority,
  loader/report, public API/CLI, compiler integration, `.igapp`, runtime, or
  production behavior.

---

## Recommendation

Recommendation:

```text
Open bounded helper implementation authorization review.
Candidate implementation: internal helper inside `oof_fragment_registry.rb`.
Keep current behavior proof-local until that gate accepts.
```

Suggested next route:

```text
oof-fragment-registry-source-envelope-helper-implementation-authorization-review-v0
```

Route type:

```text
authorization review only
no implementation unless accepted
```

Fallback if Architect holds implementation:

```text
keep source-envelope validation proof-local
```

---

## Closed Surfaces

This design does not authorize:

- source-envelope helper implementation;
- loader/report behavior;
- public API/CLI input or output;
- compiler integration;
- specs, proposals, or canon edits;
- `lib/igniter_lang/oof_fragment_registry_data.rb`;
- static registry constants;
- `lib/igniter_lang.rb` require changes;
- separate helper/source file;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  `CompilationReport`, `CompilerResult`, diagnostics, or CLI changes;
- `.igapp`, `.ilk`, or golden mutation;
- live pack registry or dispatch;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP production
  executors, cache, signing, deployment, production behavior, or Spark work.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: LANG-R109-D1
Track: oof-fragment-registry-source-envelope-helper-boundary-design-v0
Status: done

[D]
- Compared helper placement options.
- Recommended bounded internal helper in `lib/igniter_lang/oof_fragment_registry.rb`.
- Rejected separate helper file and static data file for this route.

[S]
- Accepted helper modes: `proof_fixture`, `caller_supplied`.
- Held/rejected modes: `profile_candidate`, `pack_descriptor_candidate`,
  canon-status envelopes.
- Helper result remains internal-only and nests existing registry validation.

[T]
- Docs-only design.
- No tests or broad proofs run.

[R]
- Recommend helper implementation authorization review.
- Current behavior remains proof-local until a gate accepts implementation.
- Loader/report, public API/CLI, compiler integration, specs/canon, `.igapp`,
  runtime, production, Spark, and data-file surfaces remain closed.

[Next]
- `oof-fragment-registry-source-envelope-helper-implementation-authorization-review-v0`.
```
