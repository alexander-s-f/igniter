# Track: OOF/Fragment Registry Source Envelope Helper Proof v0

Card: LANG-R111-I1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Track: `oof-fragment-registry-source-envelope-helper-proof-v0`
Status: done
Date: 2026-05-21

Authorized by: LANG-R110-A
(`docs/gates/oof-fragment-registry-source-envelope-helper-implementation-authorization-review-v0.md`)

---

## Goal

Implement and prove an internal source-envelope helper inside
`IgniterLang::OOFFragmentRegistry`, preserving the isolated validator boundary.

The helper adds `validate_source_envelope` as an instance method on
`OOFFragmentRegistry`. It validates source-envelope shape, gates on accepted
source modes, and calls the existing `validate` method only after source-envelope
validation passes. All behavior is internal-only.

---

## Evidence Read

- `docs/gates/oof-fragment-registry-source-envelope-helper-implementation-authorization-review-v0.md`
  (LANG-R110-A)
- `docs/tracks/oof-fragment-registry-source-envelope-helper-boundary-design-v0.md`
  (LANG-R109-D1)
- `docs/tracks/oof-fragment-registry-implementation-boundary-proof-v0.md`
  (LANG-R103-I)
- `lib/igniter_lang/oof_fragment_registry.rb`
- `experiments/oof_fragment_registry_supplied_data_source_proof/oof_fragment_registry_supplied_data_source_proof.rb`
- `experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json`

---

## Changed Files

```text
lib/igniter_lang/oof_fragment_registry.rb
  MODIFIED — source-envelope constants and validate_source_envelope method added

experiments/oof_fragment_registry_source_envelope_helper_proof/
  oof_fragment_registry_source_envelope_helper_proof.rb               NEW
  out/oof_fragment_registry_source_envelope_helper_proof_summary.json NEW

docs/tracks/oof-fragment-registry-source-envelope-helper-proof-v0.md  NEW (this file)
```

No other file changed. Explicitly out-of-scope files NOT created or modified:

```text
lib/igniter_lang/oof_fragment_registry_data.rb        OUT (not authorized, separate future card)
lib/igniter_lang.rb                                   UNCHANGED
lib/igniter_lang/oof_fragment_registry_source.rb      NOT CREATED (separate file forbidden)
lib/igniter_lang/oof_fragment_registry_helper.rb      NOT CREATED (separate file forbidden)
parser / classifier / TypeChecker / SemanticIR /
  assembler / orchestrator / report / result / CLI    UNCHANGED
docs/spec/                                            UNCHANGED
docs/proposals/                                       UNCHANGED
existing .igapp goldens                               UNCHANGED
```

---

## Implementation Summary

### `lib/igniter_lang/oof_fragment_registry.rb` — additions

**New constants (all internal, not public OOF codes):**

```ruby
SOURCE_ACCEPTED_MODES         = %w[proof_fixture caller_supplied].freeze
SOURCE_HELD_MODES             = %w[profile_candidate pack_descriptor_candidate].freeze
SOURCE_ACCEPTED_AUTHORITY_KINDS = %w[proof_only design_accepted].freeze
SOURCE_ACCEPTED_CANON_STATUSES  = %w[non_canon accepted_design].freeze

SOURCE_DIAG_WRONG_KIND                 = "oof_registry.source.validation.wrong_kind"
SOURCE_DIAG_UNSUPPORTED_FORMAT_VERSION = "oof_registry.source.validation.unsupported_format_version"
SOURCE_DIAG_UNSUPPORTED_SOURCE_MODE    = "oof_registry.source.validation.unsupported_source_mode"
SOURCE_DIAG_HELD_SOURCE_MODE           = "oof_registry.source.validation.held_source_mode"
SOURCE_DIAG_INVALID_AUTHORITY_KIND     = "oof_registry.source.validation.invalid_authority_kind"
SOURCE_DIAG_CANON_STATUS_FORBIDDEN     = "oof_registry.source.validation.canon_status_forbidden"
SOURCE_DIAG_MISSING_AUTHORITY          = "oof_registry.source.validation.missing_authority"
SOURCE_DIAG_MISSING_AUTHORITY_REF      = "oof_registry.source.validation.missing_authority_ref"
SOURCE_DIAG_MISSING_REGISTRY           = "oof_registry.source.validation.missing_registry"
SOURCE_DIAG_SURFACE_OPEN               = "oof_registry.source.validation.surface_open"
```

**New public method:**

```ruby
def validate_source_envelope(source_envelope, installed_boundaries: nil)
```

**New private helpers:**

```ruby
def source_diag(code, message)       # source-envelope diagnostic factory
def build_source_result(...)         # builds internal source-validation result hash
```

**Validation sequence:**

1. Envelope must be a Hash with `kind: "oof_fragment_registry_source"`.
2. `format_version` must be `"0.1.0"`.
3. `source_mode` checked: accepted → proceed; held → `held_source_mode`; other → `unsupported_source_mode`.
4. `authority` object: presence, `authority_ref`, `authority_kind` (must be proof/design), `canon_status` (must not be `"canon"`).
5. `registry` key must be a Hash; otherwise `missing_registry`.
6. `closed_surface_assertions` in envelope must all be false; otherwise `surface_open`.
7. If any source diagnostics → return with `registry_validation: nil` (nested validator NOT called).
8. If source envelope passes → call existing `validate(registry, installed_boundaries:)` and embed result.
9. `valid: true` only when both source envelope and nested registry are valid.

**Result shape:**

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

For invalid source envelopes: `registry_validation: null`.

---

## Helper Proof Matrix — 9/9 PASS, 10/10 PASS

### Case matrix

| Case | Description | Result |
| --- | --- | --- |
| SE1. valid_proof_fixture_source_validates_nested_registry | proof_fixture mode passes; nested registry validated | PASS |
| SE2. valid_caller_supplied_source_validates_nested_registry | caller_supplied mode passes; nested registry validated | PASS |
| SE3. wrong_kind_rejected_internally | kind ≠ oof_fragment_registry_source → wrong_kind | PASS |
| SE4. missing_registry_rejected_internally | registry key absent → missing_registry | PASS |
| SE5. profile_candidate_held_internally | source_mode profile_candidate → held_source_mode | PASS |
| SE6. pack_descriptor_candidate_held_internally | source_mode pack_descriptor_candidate → held_source_mode | PASS |
| SE7. canon_status_rejected_internally | authority.canon_status = "canon" → canon_status_forbidden | PASS |
| SE8. open_closed_surface_assertion_rejected_internally | closed_surface_assertions has true value → surface_open | PASS |
| SE9. invalid_nested_registry_reports_diagnostics_without_public_surface_keys | source valid; nested invalid; diagnostics present; no public surface keys | PASS |

### Structural checks

| Check | Result |
| --- | --- |
| CS1. oof_fragment_registry_data_rb_absent | PASS |
| CS2. lib_igniter_lang_rb_does_not_require_registry | PASS |
| CS3. compiler_passes_do_not_require_helper | PASS |
| CS4. all_case_results_have_no_public_surface_keys | PASS |
| CS5. all_helper_results_closed_surface_assertions_false | PASS |
| CS6. no_separate_helper_file | PASS |
| CS7. validate_source_envelope_is_instance_method_of_OOFFragmentRegistry | PASS |
| CS8. validate_source_envelope_not_in_igniter_lang_rb_public_surface | PASS |
| CS9. nested_registry_not_called_when_source_envelope_invalid | PASS |
| CS10. result_kind_is_oof_fragment_registry_source_validation | PASS |

---

## Pinned 9-Command Proof Matrix

| Command | Result | Notes |
| --- | --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/oof_fragment_registry.rb` | PASS (Syntax OK) | |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_envelope_helper_proof/oof_fragment_registry_source_envelope_helper_proof.rb` | PASS (9/9 cases, 10/10 checks) | |
| `ruby igniter-lang/experiments/oof_fragment_registry_supplied_data_source_proof/oof_fragment_registry_supplied_data_source_proof.rb` | PASS (7/7 cases, 9/9 checks) | Requires `-Eutf-8` flag or UTF-8 locale; R103 summary contains UTF-8 checkmarks (✓); proof passes with `RUBYOPT="-Eutf-8"`. Pre-existing environment issue (C/US-ASCII locale), unrelated to this card. |
| `ruby igniter-lang/experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | PASS (27/27) | |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb` | PASS | |
| `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS | |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS | |
| `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | PASS | |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS | |

---

## Closed-Surface Assertions

```text
static_data_file:              false (oof_fragment_registry_data.rb does not exist)
lib_igniter_lang_rb_require:   false (lib/igniter_lang.rb unchanged)
compiler_pass_integration:     false
public_api_cli:                false
top_level_report_diagnostics:  false
compiler_result_field:         false
loader_report:                 false
compatibility_report:          false
runtime_behavior:              false
igapp_mutation:                false
specs_canon_proposals:         false
```

---

## R107 Encoding Note

`experiments/oof_fragment_registry_supplied_data_source_proof/oof_fragment_registry_supplied_data_source_proof.rb`
reads the R103 summary JSON, which contains UTF-8 checkmarks (✓) written by the
R103 proof. In environments with `C` / `US-ASCII` locale (no UTF-8), `File.read`
returns US-ASCII strings and JSON parse raises `Encoding::InvalidByteSequenceError`.

This is a pre-existing environment issue unrelated to this card. The proof passes
when run with `ruby -Eutf-8:utf-8` (or `RUBYOPT="-Eutf-8"`). The issue is confined
to the JSON summary reading step; neither the validator implementation nor any
registry fixture contains non-ASCII characters. The R107 proof outcome is
`PASS` (verified with `-Eutf-8`).

---

## Remaining Blockers

1. **`oof_fragment_registry_data.rb`**: static internal data constants remain
   separately blocked; require a new Architect card.
2. **Compiler pass integration**: OOF registry lookup from parser/classifier/
   TypeChecker requires a separate authorization card.
3. **Public API/CLI**: any public surface requires a separate Bridge/Architect card.
4. **Loader/report or CompatibilityReport**: separately closed.
5. **`profile_candidate` and `pack_descriptor_candidate` source modes**: held in
   this helper. Promotion to accepted requires separate proof and Architect review.

---

## Handoff

```text
Card: LANG-R111-I1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: oof-fragment-registry-source-envelope-helper-proof-v0
Status: done

[D]
- Added validate_source_envelope method and source-envelope constants to
  lib/igniter_lang/oof_fragment_registry.rb.
- Accepted modes: proof_fixture, caller_supplied.
- Held/rejected: profile_candidate, pack_descriptor_candidate (held_source_mode).
- Rejected: canon-status envelopes (canon_status_forbidden), open surface assertions
  (surface_open), wrong kind (wrong_kind), missing registry (missing_registry).
- Nested registry validator called only after source envelope passes.
- registry_validation: null when source envelope is invalid.
- All closed_surface_assertions: false in every helper result.

[S]
- 9/9 helper proof cases PASS.
- 10/10 structural checks PASS.
- 9/9 pinned command matrix PASS.
- All closed-surface assertions: false.

[T]
- ruby -c lib/igniter_lang/oof_fragment_registry.rb                          → Syntax OK
- ruby experiments/.../oof_fragment_registry_source_envelope_helper_proof.rb → PASS 9/9 cases 10/10 checks
- Full 9-command parity matrix                                                → PASS (see matrix)

[R]
- validate_source_envelope is callable only from proof-local harnesses via
  direct require of lib/igniter_lang/oof_fragment_registry.rb.
- No caller outside proof scripts uses the helper today.
- Compiler integration, public API, oof_fragment_registry_data.rb, and
  profile_candidate/pack_descriptor_candidate source modes remain separately blocked.

[Next]
- Architect may authorize oof_fragment_registry_data.rb (static internal constants).
- Architect may authorize compiler pass lookup integration (separate bounded slice).
- profile_candidate/pack_descriptor_candidate promotion requires separate proof and
  Architect authorization.
```
