# Discussion: Compiler Profile Source-Mode Static-Data Boundary Proof Pressure v0

Card: S3-R153-C2-X
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: external-pressure-reviewer
Borrowed lens: proof-authority-pressure
Track: compiler-profile-source-mode-static-data-boundary-proof-pressure-v0
Route: UPDATE
Status: complete — proceed
Date: 2026-05-23

Depends on: S3-R153-C1-P1
Authorized by: S3-R152-C3-A

---

## Scope

Pressure-review the source-mode/static-data boundary proof (S3-R153-C1-P1)
for proof-local containment, authority preservation, and negative-scan
completeness. Specific checks:

1. synthetic shape is non-trivial and proof-local only;
2. no shared fixtures, `lib/` data, generated indexes, spec/canon examples,
   Spark-derived data, or product data were created;
3. source-mode mapping respects pack/profile authority split;
4. duplicate ownership/conflict rejection is proven;
5. `finalized_internal` remains internal-only;
6. PROP-036 vocabulary negative scan covers the required tokens;
7. PROP-038 and adapter helper boundaries remain preserved;
8. closed-surface scans cover the named surfaces;
9. command matrix is reproducible and sufficient;
10. proof does not request implementation acceptance.

---

## Evidence Read

- `igniter-lang/docs/gates/compiler-profile-source-mode-static-data-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-boundary-proof-v0.md`
- `igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/compiler_profile_source_mode_static_data_boundary_proof.rb`
- `igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/compiler_profile_source_mode_static_data_boundary_proof_summary.json`
- `git show --name-status --oneline 4dfdc8b6` (proof commit)

---

## Scope Check 1 — Synthetic Shape Is Non-Trivial And Proof-Local Only

S3-R152-C3-A NB-1 (binding) required: one pack descriptor row, one profile
candidate reference to the selected pack, one pack-row ownership conflict or
duplicate ownership rejection case.

**Pack descriptor row:** `SyntheticCorePack` has `owned_oof_descriptors` with
code `OOF-SYN1` and `owned_fragment_rows` with name `"core"`. Both fields are
non-empty. ✅

**Profile candidate reference:** `synthetic_profile` selects `pack_refs` as
`selected_pack_refs` and `pack_order`. The check
`synthetic_shape.profile_references_selected_pack` verifies that selected refs
are a subset of pack refs and are non-empty. ✅

**Duplicate ownership conflict:** `duplicate_ownership_fixture` builds a second
pack (`SyntheticConflictPack`) that claims the same OOF descriptor code
(`OOF-SYN1`) and the same fragment row name (`"core"`). Summary JSON shows two
diagnostics:

```text
duplicate_diagnostics: [
  "oof_registry.source.validation.duplicate_row_ownership",
  "oof_registry.source.validation.duplicate_row_ownership"
]
```

One hit for the OOF descriptor row, one for the fragment row. The duplicate
assembly does not reach `finalized_internal`. ✅

Proof-local markers: `static_data_status: "proof_local_only"`,
`shared_fixture: false`, `spark_data_used: false`,
`product_data_used: false`, `authority_kind: "proof_only"`,
`canon_status: "non_canon"`. All confirmed in the `synthetic_static_data_fixture.json`
output. ✅

NB-1 fully satisfied.

Outcome: **PASS** — shape is non-trivial and proof-local.

---

## Scope Check 2 — No Shared Fixtures, `lib/` Data, Generated Indexes, or Unauthorized Data

Proof commit `4dfdc8b6` changed exactly 6 files:

```text
A  igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-boundary-proof-v0.md
A  igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/compiler_profile_source_mode_static_data_boundary_proof.rb
A  igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/compiler_profile_source_mode_static_data_boundary_proof_summary.json
A  igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/duplicate_ownership_rejection.json
A  igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/source_packet.helper_envelopes.json
A  igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/out/synthetic_static_data_fixture.json
```

All 6 files are inside the C3-A allowed write scope:

```text
igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/**
igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-boundary-proof-v0.md
```

No `lib/**`, shared fixture directory, `spec/`, `docs/proposals/`, golden
directory, or external experiment directory was changed. The
`non_authorizations_preserved` block machine-asserts all non-authorized surfaces
false, including `shared_fixtures: false` and `lib_data: false`.

The static-data status matrix independently confirms `internal_library_data:
rejected`, `generated_index: rejected`, `spark: rejected` with `result: PASS`.

Outcome: **PASS** — no unauthorized data surfaces created.

---

## Scope Check 3 — Source-Mode Mapping Respects Pack/Profile Authority Split

The proof builds an `IgniterLang::InternalProfileAssemblySourcePacket` and maps
both source modes to `oof_fragment_registry_source` envelopes:

```text
profile_candidate          -> profile_envelope  (source_mode: profile_candidate)
pack_descriptor_candidate  -> pack_descriptor_envelopes[]  (source_mode: pack_descriptor_candidate)
source_input_kind:         compiler_profile_oof_registry_source_input
public_carrier_leakage:    false
```

The authority split is verified by separate machine checks:

- `authority.pack_row_authority_preserved`: each pack's owned rows all share
  the same `owner_pack_or_boundary` as the pack itself. ✅
- `authority.profile_level_authority_preserved`: the profile's
  `row_authority_policy` is `"pack_descriptor_rows_aggregated_by_profile"`,
  `selected_pack_refs` equals `pack_order` (order ownership confirmed), and the
  `conflict_policy` rejects all 6 duplicate/conflict types
  (`duplicate_oof_descriptor`, `duplicate_fragment_row`,
  `duplicate_support_marker`, `duplicate_alias_owner`,
  `missing_selected_pack_ref`, `excluded_namespace`). ✅

The carrier leakage check scans the static fixture, helper envelopes, and
summary-safe assembly projection for the `PUBLIC_CARRIER_KEYS` set
(`igapp_path`, `compilation_report_path`, `report`, `compatibility_report`,
`runtime_ready`, `evaluation_ready`, `compiler_result`, `loader_report`,
`manifest`, `artifact_hash`) outside `closed_surface_assertions` sections. The
`strip_closed_surface_assertions` helper removes those sections before scanning,
preventing false positives. `source_mode.no_public_carrier_leakage: PASS`. ✅

Outcome: **PASS** — source-mode mapping correctly respects the accepted
authority split.

---

## Scope Check 4 — Duplicate Ownership/Conflict Rejection Is Proven

The `duplicate_ownership_fixture` method builds a genuine conflict by:

1. copying the valid fixture;
2. creating `SyntheticConflictPack` that claims the same OOF descriptor code
   `OOF-SYN1` as `SyntheticCorePack`;
3. copying the same fragment row name `"core"` from the first pack.

The summary shows two `oof_registry.source.validation.duplicate_row_ownership`
diagnostics — one per conflicting row type (OOF descriptor and fragment row).

Three separate machine checks verify the rejection:

- `synthetic_shape.duplicate_ownership_rejected`: `duplicate_validation.valid == false`,
  diagnostic present, `duplicate_assembly.lifecycle_state != "finalized_internal"`. ✅
- `authority.profile_cannot_override_duplicate_pack_rows`: profile conflict policy
  cannot override the pack-row ownership rejection. ✅
- `authority_preservation.duplicate_ownership_rejected: true` in summary. ✅

Outcome: **PASS** — duplicate ownership rejection is proven with two independent
conflicting rows and three machine-checked assertions.

---

## Scope Check 5 — `finalized_internal` Remains Internal-Only

The positive packet reaches `finalized_internal` (confirmed by
`lifecycle.finalized_internal_internal_only: PASS`). Eight forbidden-meaning
entries are machine-asserted with `value: false`:

```text
prop036_identity: false
manifest_identity: false
public_finalization: false
loader_report_status: false
runtime_readiness: false
production_readiness: false
spark_readiness: false
demo_readiness: false
```

The check logic is:
`assembly_result.lifecycle_state == "finalized_internal" && value == false`.

Outcome: **PASS** — `finalized_internal` confirmed as internal lifecycle state
with all forbidden meanings explicitly false.

---

## Scope Check 6 — PROP-036 Vocabulary Negative Scan Covers Required Tokens

S3-R152-C3-A NB-3 (binding) required exactly 9 tokens. The proof runner's
`PROP036_TOKENS` constant contains exactly those 9 tokens:

```ruby
PROP036_TOKENS = [
  "compiler_profile_id",
  "compiler_profile_id_source",
  "compiler_profile_source",
  "profile_source",
  "profile finalization",
  "manifest identity",
  "default profile",
  "named profile",
  "profile discovery"
].freeze
```

The scan is performed on an explicitly constructed `forbidden_prop036_scan_payload`
containing: the fixture kind/status/flags, the static-data status matrix, the
lifecycle matrix, and the closed-surface scan outputs. The result is zero hits
across all 9 tokens.

The scan uses `JSON.pretty_generate(canonicalize(payload))` with
`String#include?` for each token — plain substring matching. The
`explicit_token_list_only: true` marker confirms the scan uses exactly the
required list and no implicit extensions.

Summary result: `prop036_negative_scan.hits: [], status: PASS`. ✅

NB-3 fully satisfied.

Outcome: **PASS** — all 9 required PROP-036 tokens covered; zero hits in the
forbidden payload.

---

## Scope Check 7 — PROP-038 And Adapter Helper Boundaries Preserved

### PROP-038

The `prop038.preserved_not_widened` check verifies:

1. `static_fixture.excluded_namespaces` matches
   `IgniterLang::OOFFragmentRegistry::REQUIRED_EXCLUDED_PREFIXES` exactly — a
   live module-constant check, not a hardcoded string. The constant contains
   `"compiler_profile_contract."` and `"compiler_profile_contract_refusal."`,
   correctly inherited from the accepted seam. ✅
2. `prop038_mutation: open == false` (stated closed-surface assertion). ✅
3. `persisted_report_behavior: open == false` (stated). ✅
4. `runtime_refusal_authority: open == false` (stated). ✅
5. `strict_refusal_behavior_mutated: false` (stated). ✅

### Adapter helper

All five adapter evidence entries confirm `open: false` via live file checks
where applicable:

- `root_require_adapter_reference`: live read of `lib/igniter_lang.rb` for
  `"fragment_registry_compatibility_adapter"`. ✅
- `classifier_adapter_reference`: live read of `lib/igniter_lang/classifier.rb`
  for both `FragmentRegistryCompatibilityAdapter` and
  `fragment_registry_compatibility_adapter`. ✅
- `classifiedprogram_field_projection`: live read of classifier.rb for
  `selected_fragment_projection` and `declaration_fragment_presence`. ✅
- `contract_fragment_for_replaced`: `open == false` means `classifier.rb`
  still contains `def contract_fragment_for` (method has not been replaced). ✅
- `live_dispatch_adapter_method_claimed`: stated; the proof does not require or
  call the adapter helper. ✅

Outcome: **PASS** — PROP-038 excluded namespaces live-verified; adapter helper
surfaces confirmed closed via live file reads.

---

## Scope Check 8 — Closed-Surface Scans Cover Named Surfaces

The `scan_closed_surfaces` method covers 24 surfaces. Breakdown by check type:

**Live file/tree scans:**

| Surface | Check method |
| --- | --- |
| `root_require` | Implicit via adapter scan; root require confirmed clean |
| `classifier_wiring` | Live: classifier.rb adapter references absent |
| `parser` | Live: PROOF_TOKEN in `lib/igniter_lang/parser.rb` |
| `typechecker` | Live: PROOF_TOKEN in `lib/igniter_lang/typechecker.rb` |
| `semanticir` | Live: PROOF_TOKEN in `lib/igniter_lang/semanticir_emitter.rb` |
| `assembler` | Live: PROOF_TOKEN in `lib/igniter_lang/assembler.rb` |
| `report` | Live: PROOF_TOKEN in `compilation_report.rb` and `compiler_result.rb` |
| `public_api_cli` | Live: PROOF_TOKEN in `lib/igniter_lang/cli.rb` |
| `igapp` | Live: tree scan of `fixtures/` for PROOF_TOKEN |
| `golden_migration` | Live: tree scan of `experiments/` for `PROOF_TOKEN_golden` |
| `spark` | Live: tree scan of `experiments/` for `spark_PROOF_TOKEN` |

**Stated (hardcoded `open: false`):**

`live_dispatch`, `loader_report`, `compatibility_report`, `manifest`, `sidecar`,
`artifact_hash`, `runtime`, `production`, `demo`, `prop036_mutation`,
`prop038_mutation`, `persisted_report_behavior`, `runtime_refusal_authority`.

All 24 entries report `open: false`, and the single summary check
`closed_surfaces.remain_closed: PASS` verifies the aggregate.

The C3-A required surface list (20 specific surfaces plus PROP-036/038 mutation
checks) is fully covered. Key compiler pipeline files are checked live. The
stated entries cover semantic/architectural surfaces that lack dedicated files to
scan, which is consistent with prior proof patterns.

Outcome: **PASS** — all required surfaces covered; live scans confirm key
pipeline files are clean.

---

## Scope Check 9 — Command Matrix Is Reproducible And Sufficient

The command matrix contains the single self-command:

```text
ruby igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/compiler_profile_source_mode_static_data_boundary_proof.rb
```

The track doc explains: "Running broader proofs would rewrite outputs outside
this card's allowed write scope."

This is a valid scope-compliance constraint. Regression commands such as
`igapp_assembler_proof` or `classifier_pass_proof` would write to their own
`out/` directories, which are outside
`experiments/compiler_profile_source_mode_static_data_boundary_proof/**`.
Running them would violate the C3-A write scope.

The proof runner validates behavior directly by loading live lib files:

```ruby
require_relative "../../lib/igniter_lang/oof_fragment_registry"
require_relative "../../lib/igniter_lang/internal_profile_assembly_source_packet"
require_relative "../../lib/igniter_lang/internal_profile_assembly"
```

This provides direct behavioral coverage of the three internal seams under test.
The closed-surface scans verify that no proof token leaked into lib/ files. The
adapter evidence checks verify that lib/ files are clean for adapter vocabulary.

Reproducibility: the command is deterministic (no time-based or environment
inputs). The digests are stable SHA-256 truncations of canonicalized JSON.

Outcome: **PASS** — narrow scope is justified; self-command is sufficient and
reproducible for this proof.

---

## Scope Check 10 — Proof Does Not Request Implementation Acceptance

Track doc recommendation: "C3-A may accept this proof. Do not request
implementation acceptance from this proof. A later route would need a new gate
before opening any shared fixture, `lib/` static data, generated index, compiler
integration, public/report carrier, artifact, runtime, Spark, production, or
demo surface."

Summary JSON: `"recommendation": "accept proof"` — not `"accept implementation"`.

The `[Next]` handoff says: "If C3-A accepts, decide whether the next route is
more proof pressure or a separate implementation-authorization review for a
still-internal carrier" — correctly deferred.

Outcome: **PASS** — no implementation acceptance requested.

---

## Non-Blocking Notes

### NB-1 — Lifecycle Matrix Values Are Statically Declared Constants

The `lifecycle_preservation_matrix` method hardcodes `false` as the value for
each forbidden meaning:

```ruby
[
  ["prop036_identity", false],
  ["manifest_identity", false],
  ...
].map do |name, value|
  {
    "name" => name,
    "value" => value,
    "result" => assembly_result.fetch("lifecycle_state") == "finalized_internal" && value == false ? "PASS" : "FAIL"
  }
end
```

Since `value` is always `false` by construction, the PASS condition reduces to:
`assembly_result.lifecycle_state == "finalized_internal"`. The matrix confirms
that the assembly DID reach `finalized_internal` and that the proof author
explicitly declared all 8 forbidden meanings as `false`, but it does not
dynamically inspect the assembly result object for PROP-036-related fields.

This is weaker than a dynamic check but not incorrect. If `InternalProfileAssembly`
were to start returning `prop036_identity: true` as a result field, the matrix
would not catch it — the catch comes from the broader closed-surface scans and
PROP-036 negative scan. The static declarations serve as documented intent.

C3-A may accept this pattern for this slice. Future proof iterations that test
the boundary more aggressively (e.g., when assembly result fields expand) should
derive the lifecycle assertions dynamically from the actual result object.

### NB-2 — PROP-036 Scan Targets Forbidden Payload Only; Summary Field `profile_source_mode` Contains Substring Hit

The PROP-036 scan is run against a dedicated `forbidden_prop036_scan_payload`
object, not the full summary JSON. The summary's `source_mode_mapping` section
contains the field name `"profile_source_mode"`, which includes the substring
`"profile_source"` — one of the required 9 scan tokens.

Because the scan payload does not include `source_mode_mapping`, this substring
does not register as a hit. This is a defensible design choice: `profile_source_mode`
is internal proof vocabulary describing the mapping, not a PROP-036 authority
surface. The `forbidden_prop036_scan_payload` is explicitly constructed to cover
result claims and closed-surface outputs, not internal field names.

However, C3-A should acknowledge this scoping explicitly: the PROP-036 scan
confirms that PROP-036 authority tokens are absent from the claimed result fields
(status matrix, lifecycle matrix, closed-surface outputs). It does not assert
that PROP-036 substrings are absent from all field names in the full summary.
Internal vocabulary containing "profile_source" as a substring is an expected
and acceptable internal term.

### NB-3 — Stated Closed-Surface Assertions Are Not Live-Derived for Semantic Surfaces

Thirteen of the 24 closed-surface entries are stated (`open: false` hardcoded)
rather than live-derived from file reads or tree scans. These include
`loader_report`, `compatibility_report`, `manifest`, `sidecar`, `artifact_hash`,
`runtime`, `production`, `demo`, `prop036_mutation`, `prop038_mutation`,
`persisted_report_behavior`, and `runtime_refusal_authority`.

For surfaces that have no dedicated scannable file (loader/report is a behavior,
not a lib file), stated assertions are acceptable. The key compiler pipeline
files are all live-scanned. This is consistent with the pattern accepted in prior
proof rounds.

Future proofs that introduce more complex interactions — such as when
CompatibilityReport or loader/report carrier shapes are under consideration —
should derive those assertions from live checks rather than stated values.

---

## Verdict

**proceed** — 10/10 scope checks PASS. No blockers.

The proof correctly:

- exercises a non-trivial synthetic shape (one pack, one OOF descriptor row, one
  fragment row, one duplicate conflict case with two diagnostic hits);
- stays within exact C3-A write scope (6 files, all in authorized directories);
- proves `profile_candidate` / `pack_descriptor_candidate` mapping to internal
  source-packet envelopes without public carrier leakage;
- proves duplicate row ownership rejects aggregate assembly before
  `finalized_internal`;
- confirms `finalized_internal` with 8 explicitly enumerated forbidden meanings
  all false;
- covers all 9 required PROP-036 vocabulary tokens in the forbidden payload
  scan (zero hits);
- live-verifies PROP-038 excluded namespaces against the module constant;
- live-scans all key compiler pipeline files for the proof token;
- justifies the narrow command matrix (single self-command) as the correct
  scope-compliance choice;
- does not request implementation acceptance.

Three non-blocking notes about lifecycle matrix static values, PROP-036 scan
scope, and stated closed-surface assertions are informational for C3-A and
future proof design.

---

## Acceptance Recommendation for C3-A

**Accept** the proof.

The S3-R153-C1-P1 proof correctly demonstrates the source-mode/static-data
boundary with synthetic proof-local data. All three NB items from S3-R152-C2-X
(NB-1 non-trivial shape, NB-2 prior gate inheritance, NB-3 PROP-036 token set)
are satisfied as required by S3-R152-C3-A.

C3-A should:

- accept commit `4dfdc8b6` as the proof closure for S3-R153-C1-P1;
- acknowledge NB-2 scoping explicitly: the PROP-036 scan targets the forbidden
  payload only, not the full summary; `profile_source_mode` as an internal field
  name is acceptable vocabulary and does not constitute PROP-036 authority
  leakage;
- note NB-1 (lifecycle matrix static values) as a proof pattern improvement for
  future cards, not a defect in this slice;
- keep all closed surfaces held: implementation, root require, classifier wiring,
  live dispatch, shared fixtures, `lib/` static data, generated indexes, public
  API/CLI, loader/report, CompatibilityReport, manifest, sidecar, artifact hash,
  PROP-036/PROP-038 mutation, Spark, runtime, production, and demo work;
- decide the next route explicitly — either additional proof pressure or a
  separate gate for implementation-authorization review of a still-internal
  carrier, as recommended by the proof handoff;
- require Portfolio review before any implementation, public/report/artifact,
  Spark fixture/spec, runtime, production, or demo route opens.
