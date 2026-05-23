# Compiler Profile Source-Mode Static-Data Internal Carrier Implementation Pressure v0

Card: S3-R155-C1-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: internal-carrier-implementation-pressure
Track: compiler-profile-source-mode-static-data-internal-carrier-implementation-pressure-v0
Route: UPDATE
Depends on: S3-R154-C2-I
Date: 2026-05-23

---

## Question

Does the bounded `InternalProfileStaticDataCarrier` implementation (S3-R154-C2-I)
stay inside the S3-R154-C1-A write scope, implement the authorized class shape
exactly, validate and reject all required rejection cases, map correctly to
`InternalProfileAssemblySourcePacket` without producing `finalized_internal`,
exclude all forbidden PROP-036 and public/report/runtime/Spark/demo vocabulary
from carrier outputs, and keep all closed surfaces held?

---

## Evidence Read

- `igniter-lang/docs/gates/compiler-profile-source-mode-static-data-internal-carrier-implementation-authorization-review-v0.md`
  (S3-R154-C1-A)
- `igniter-lang/docs/tracks/stage3-round154-status-curation-v0.md`
  (S3-R154-C2-S)
- `igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-internal-carrier-implementation-v0.md`
  (S3-R154-C2-I track doc)
- `igniter-lang/lib/igniter_lang/internal_profile_static_data_carrier.rb`
  (carrier implementation)
- `igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof.rb`
  (proof runner)
- `igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/out/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof_summary.json`
  (proof summary)
- `git show --stat 8fa97a60` (implementation commit)
- `git show --stat 717c4946` (adjacent docs-only commit)

---

## Scope Checks

### SC1: Changed files inside S3-R154-C1-A authorized write scope

Authorized write scope:

```text
igniter-lang/lib/igniter_lang/internal_profile_static_data_carrier.rb
igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/**
igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-internal-carrier-implementation-v0.md
```

Implementation commit `8fa97a60` (7 files, 1582 insertions):

```text
docs/tracks/compiler-profile-source-mode-static-data-internal-carrier-implementation-v0.md   ← authorized
experiments/.../compiler_profile_source_mode_static_data_internal_carrier_implementation_proof.rb   ← authorized
experiments/.../out/assembly_evidence.sanitized.json   ← authorized
experiments/.../out/carrier_output.invalid_cases.sanitized.json   ← authorized
experiments/.../out/carrier_output.valid.sanitized.json   ← authorized
experiments/.../out/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof_summary.json   ← authorized
lib/igniter_lang/internal_profile_static_data_carrier.rb   ← authorized
```

All 7 files are within authorized scope. No lib data, proposals, shared
fixtures, `.igapp`, golden, or out-of-scope path is present in this commit.

A separate adjacent commit `717c4946` modified `docs/cards/S3/S3-R154.md`
(round dispatch tracking document). This is outside the strict authorized write
scope. It was committed before the implementation commit and is a lightweight
administrative dispatch doc. See NB-3.

**SC1: PASS**

---

### SC2: Class and file names match authorization exactly

Gate authorized:

```text
file:  igniter-lang/lib/igniter_lang/internal_profile_static_data_carrier.rb
class: IgniterLang::InternalProfileStaticDataCarrier
KIND        = "internal_profile_static_data_carrier"
FORMAT_VERSION  = "0.1.0"
STATIC_DATA_STATUSES = ["proof_local_only", "internal_test_seam_only"]
```

Implementation:

- file matches ✓
- class `IgniterLang::InternalProfileStaticDataCarrier` defined inside
  `module IgniterLang` ✓
- `KIND = "internal_profile_static_data_carrier"` ✓
- `FORMAT_VERSION = "0.1.0"` ✓
- `STATIC_DATA_STATUSES = ["proof_local_only", "internal_test_seam_only"].freeze` ✓

All 10 authorized diagnostic code constants present and matching the authorized
vocabulary:

```text
DIAG_INVALID_SHAPE
DIAG_UNSUPPORTED_KIND
DIAG_UNSUPPORTED_FORMAT_VERSION
DIAG_UNSUPPORTED_STATIC_DATA_STATUS
DIAG_INVALID_AUTHORITY
DIAG_MISSING_PROFILE_CANDIDATE
DIAG_MISSING_PACK_DESCRIPTOR_CANDIDATES
DIAG_SURFACE_OPEN
DIAG_FORBIDDEN_FIELD
DIAG_PACKET_BUILD_FAILED
```

**SC2: PASS**

---

### SC3: Root require remains closed

Live closed-surface checks from proof summary:

```text
root_require_direct_only:  PASS (path: lib/igniter_lang.rb)
root_require_not_opened:   PASS (path: lib/igniter_lang.rb)
```

The carrier file token `internal_profile_static_data_carrier` is absent from
`lib/igniter_lang.rb` — confirmed by two independent checks in the proof runner
that read the file live and test for the token.

**SC3: PASS**

---

### SC4: Carrier requires only `internal_profile_assembly_source_packet` (plus stdlib)

Carrier file requires:

```ruby
require "digest"
require "json"
require_relative "internal_profile_assembly_source_packet"
```

- `digest` and `json` are Ruby stdlib — no production dependency introduced ✓
- `require_relative "internal_profile_assembly_source_packet"` — exactly the
  one require authorized by the gate ✓
- No parser, classifier, TypeChecker, SemanticIR, assembler, CLI, report,
  runtime, Spark, adapter helper, or production file is required ✓

**SC4: PASS**

---

### SC5: No parser/classifier/pipeline/adapter files referenced

Live closed-surface checks from proof summary:

```text
pipeline_files_no_carrier_reference:  PASS (hits: [])
adapter_helper_not_called:            PASS
classified_program_schema_unchanged:  PASS
contract_fragment_for_preserved:      PASS
```

10 pipeline files scanned live for `InternalProfileStaticDataCarrier` and
`internal_profile_static_data_carrier`:

```text
lib/igniter_lang.rb
lib/igniter_lang/parser.rb
lib/igniter_lang/classifier.rb
lib/igniter_lang/typechecker.rb
lib/igniter_lang/semanticir_emitter.rb
lib/igniter_lang/assembler.rb
lib/igniter_lang/compiler_orchestrator.rb
lib/igniter_lang/compilation_report.rb
lib/igniter_lang/compiler_result.rb
lib/igniter_lang/cli.rb
```

Zero hits across all 10. `FragmentRegistryCompatibilityAdapter` is not present
in the carrier source. `classifier.rb` does not reference the carrier class.
`contract_fragment_for` definition remains intact.

**SC5: PASS**

---

### SC6: Authorized constants, constructor, and methods match authorization

Authorized constructor:

```ruby
IgniterLang::InternalProfileStaticDataCarrier.build(static_data:)
```

Present: `.build(static_data:)` calls `new(static_data)` — keyword argument
interface matches ✓

Authorized instance methods:

```text
#to_h                    ✓
#valid_shape?             ✓
#diagnostics              ✓
#to_source_packet         ✓
#static_data_digest       ✓
```

All five present. No additional public methods.

Accepted authority values:

```ruby
ACCEPTED_AUTHORITY_KINDS = ["proof_only", "design_accepted"].freeze   ✓
ACCEPTED_CANON_STATUSES  = ["non_canon", "accepted_design"].freeze     ✓
```

No method reads a file path, manifest, loader report, CompatibilityReport,
`.igapp`, sidecar, environment, runtime state, Spark data, or production state.
All methods are either pure computation or deep-copy operations.

**SC6: PASS**

---

### SC7: Input validation rejects all required rejection types

Required rejection cases verified by proof (all 6 invalid case results show
`"valid": false` with correct diagnostic codes):

| Case | Expected diagnostic | Observed |
| --- | --- | --- |
| `invalid_status` | `unsupported_static_data_status` | ✓ |
| `invalid_authority` | `invalid_authority` (authority_kind: "runtime", canon_status: "canon") | ✓ |
| `missing_profile_candidate` | `missing_profile_candidate` | ✓ |
| `missing_pack_descriptor_candidates` | `missing_pack_descriptor_candidates` | ✓ |
| `forbidden_fields` | `forbidden_field` (×3 for compiler_profile_id, igapp_path, runtime_ready) | ✓ |
| `open_surface_assertion` | `surface_open` | ✓ |

All 6 invalid cases also return `source_packet_returned: false` — no packet
is generated for an invalid carrier ✓

The `validate_static_data` method also covers:

- non-Hash `static_data` → `invalid_shape` ✓
- wrong `kind` → `unsupported_kind` ✓
- wrong `format_version` → `unsupported_format_version` ✓
- non-Hash `closed_surface_assertions` → `invalid_shape` ✓

These four paths are present in code but not named as standalone proof cases.
See NB-2.

**SC7: PASS**

---

### SC8: `#to_source_packet` returns only `InternalProfileAssemblySourcePacket` without producing `finalized_internal`

Implementation:

```ruby
def to_source_packet
  return nil unless valid_shape?
  IgniterLang::InternalProfileAssemblySourcePacket.build(
    ...
    lifecycle_state: IgniterLang::InternalProfileAssemblySourcePacket::IMPLEMENTATION_CANDIDATE,
    ...
  )
rescue StandardError => e
  record_packet_build_failure(e)
  nil
end
```

Key properties:

- Returns `nil` for invalid carriers ✓
- Uses `IMPLEMENTATION_CANDIDATE` lifecycle state, not `finalized_internal` ✓
- Returns an `InternalProfileAssemblySourcePacket` instance ✓
- `rescue StandardError => e` captures packet build failures safely ✓

Proof machine-asserted:

```text
carrier.maps_to_source_packet:             PASS
  valid_packet.is_a?(InternalProfileAssemblySourcePacket) &&
  valid_packet.lifecycle_state == "implementation_candidate"

assembly.finalizes_only_internal_lifecycle: PASS
  valid_assembly.fetch("lifecycle_state") == "finalized_internal" &&
  !valid_carrier.to_h.to_s.include?("finalized_internal")
```

Carrier output does not contain `"finalized_internal"` — only the internal
assembly layer produces that state. The carrier itself produces
`"implementation_candidate"`.

**SC8: PASS**

---

### SC9: Carrier outputs exclude PROP-036 and public/report/runtime/Spark/demo authority fields

`#to_h` output keys are a fixed structure:

```text
kind, format_version, valid, static_data_status, authority,
profile_candidate, pack_descriptor_candidates, excluded_namespaces,
diagnostics, static_data_digest, closed_surface_assertions
```

Forbidden fields passed in the `forbidden_fields` invalid test case
(`compiler_profile_id`, `igapp_path`, `runtime_ready`) are NOT passed through
to `#to_h` output — the output structure is fixed and does not carry through
top-level keys from input.

Proof scan result:

```text
carrier_output_forbidden_hits: []
```

Scan covers all carrier outputs (valid carrier, duplicate carrier, all 6
invalid case carriers) serialized to JSON against the 21-token negative
scan list. Zero hits across all outputs.

Negative scan token list (21 tokens):

```text
PROP-036 tokens (9):
  compiler_profile_id, compiler_profile_id_source, compiler_profile_source,
  profile_source, profile finalization, manifest identity,
  default profile, named profile, profile discovery

Public/report/runtime tokens (12):
  igapp_path, compilation_report_path, loader_report, compatibility_report,
  compiler_result, manifest, sidecar, artifact_hash,
  runtime_ready, production_ready, spark_ready, demo_ready
```

**SC9: PASS**

---

### SC10: Proof runner PASS result and command matrix sufficient

Proof summary:

```text
status:       PASS
checks_total: 9
checks_pass:  9
checks_fail:  0
```

Command matrix (5/5 PASS):

```text
ruby -c lib/igniter_lang/internal_profile_static_data_carrier.rb       PASS
ruby ...internal_carrier_implementation_proof.rb                        PASS
ruby -c lib/igniter_lang/internal_profile_assembly_source_packet.rb     PASS
ruby -c lib/igniter_lang/internal_profile_assembly.rb                   PASS
ruby -c lib/igniter_lang/oof_fragment_registry.rb                       PASS
```

These 5 commands match the C1-A required command matrix exactly. All results
are PASS as observed and expected.

Recommendation from summary: `"accept closure"`.

**SC10: PASS**

---

### SC11: R153 proof artifacts were not rewritten

Proof machine-asserted:

```text
r153_artifacts.not_required_to_rewrite: PASS
r153_artifacts_rewritten: false
```

The proof runner verifies that:
- the R153 summary JSON file exists at its original path ✓
- no output files in the current output array point into the R153 output
  directory ✓

**SC11: PASS**

---

### SC12: No shared fixtures, generated indexes, forbidden artifact paths, or out-of-scope files

Proof output surface checks:

```text
no_forbidden_artifact_paths:  PASS (no .igapp, .ilk, .golden suffixes)
experiment_only_outputs:      PASS (all 4 output paths inside authorized OUT_DIR)
```

Output files:

```text
.../out/carrier_output.valid.sanitized.json                 ← authorized ✓
.../out/carrier_output.invalid_cases.sanitized.json         ← authorized ✓
.../out/assembly_evidence.sanitized.json                    ← authorized ✓
.../out/...proof_summary.json                               ← authorized ✓
```

No `.igapp`, `.ilk`, `.golden`, `.igapp`, manifest, sidecar, artifact hash,
shared fixture, generated index, spec, proposal, Spark data, or product data
file is present in the commit or output directory.

**SC12: PASS**

---

## Non-Blocking Notes

### NB-1: `FORBIDDEN_FIELDS` adds broadened surface terms beyond gate enumeration

The gate lists specific PROP-036 tokens and specific public/report/runtime
tokens. The implementation adds 8 extra broadened exact-key terms:

```ruby
FORBIDDEN_FIELDS = %w[
  ...
  public discovery loader report artifact runtime spark production demo
].freeze
```

These are strictly more restrictive than the gate requires. The exact-key
matching (`FORBIDDEN_FIELDS.include?(key.to_s)`) means `"report"` as a key
name would reject any nested hash field literally named `"report"`. This could
be over-broad if future trusted internal data structures legitimately use a
field named `"report"`. For the current bounded internal-only carrier, this
is correct and conservative. C2-A may optionally note the broadened scope.

### NB-2: Three validation paths not covered as named proof cases

Code paths present in `validate_static_data` but not exercised as named
invalid cases in the proof:

```text
- non-Hash static_data → DIAG_INVALID_SHAPE
- wrong kind → DIAG_UNSUPPORTED_KIND
- wrong format_version → DIAG_UNSUPPORTED_FORMAT_VERSION
- non-Hash closed_surface_assertions → DIAG_INVALID_SHAPE
```

The 6 named proof cases exercise the most important rejection paths. These
3–4 additional paths are present in code and have the correct structure but
are not machine-asserted. Acceptable for the current slice; a future proof
expansion or refactoring could add them.

### NB-3: Adjacent admin commit modified `docs/cards/S3/S3-R154.md` outside strict write scope

Commit `717c4946` (immediately before the implementation commit `8fa97a60`)
modified `igniter-lang/docs/cards/S3/S3-R154.md`, which is not in the C1-A
authorized write scope. The file is a lightweight round dispatch tracking
document (not a lib file, not a proposal, not a shared fixture, not a gated
resource). The implementation commit itself (`8fa97a60`) stays completely
within scope. C2-A should note that the dispatch doc update is an
administrative record; it does not introduce any implementation content or
surface change.

---

## Verdict

**proceed — 12/12 scope checks PASS; no blockers.**

The implementation stays inside the exact C1-A write boundary. The class name,
file name, constants, constructor, methods, and diagnostic vocabulary all match
the authorization. Root require is live-verified closed. The carrier maps to
`InternalProfileAssemblySourcePacket` using `IMPLEMENTATION_CANDIDATE` lifecycle
state and does not itself produce `finalized_internal`. All 6 required rejection
types are machine-asserted. Carrier outputs are clean across a 21-token negative
scan. The proof runner passes 9/9 checks with all 5 required commands PASS. R153
artifacts are untouched.

---

## Acceptance Recommendation for C2-A

**Accept the S3-R154-C2-I implementation.**

Accept with acknowledgment of three non-blocking notes:

1. The broadened `FORBIDDEN_FIELDS` list (NB-1) is stricter than required and
   correct for the current scope.
2. Validation coverage could be extended to named proof cases for
   `unsupported_kind`, `unsupported_format_version`, and non-Hash guards (NB-2),
   but this is not required before acceptance.
3. The adjacent `docs/cards/S3/S3-R154.md` update (NB-3) is an administrative
   record; the implementation commit itself is clean.

Do not open any new surfaces from this acceptance. Any further widening (root
require, compiler pipeline integration, public API/CLI, loader/report,
CompatibilityReport, manifest, shared fixtures, generated indexes, PROP-036 or
PROP-038 mutation, Spark, runtime, production, or demo work) requires a fresh
Portfolio-visible review.

---

## Closed Surfaces Confirmed

Confirmed closed at this stage:

```text
root require
classifier wiring / live classifier dispatch
contract_fragment_for replacement
parser / TypeChecker / SemanticIR / assembler / report / .igapp edits
ClassifiedProgram schema changes
public API / CLI
loader / report
CompilationReport / CompilerResult / CompatibilityReport
manifest / sidecar / artifact hash / golden migration
shared fixtures / generated indexes
embedded internal library static registry rows
PROP-036 / PROP-038 mutation
Spark access / fixtures / specs / integration / production pressure / demo
runtime / production / Ledger/TBackend / BiHistory / stream/OLAP / cache / signing / deployment
```
