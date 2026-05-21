# Track: OOF/Fragment Registry Loader-Supplied Data Source Design v0

Card: LANG-R106-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Track: `oof-fragment-registry-loader-supplied-data-source-design-v0`
Status: done
Date: 2026-05-21

---

## Goal

Design a future loader/caller-supplied data-source boundary for OOF/Fragment
Registry data without static internal library data.

This is an optional design-only route for progressing beyond the isolated R103
validator. It does not implement loader behavior, compiler integration, public
API/CLI, spec/canon changes, reports, `.igapp` mutation, runtime, or production
behavior.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: owns future proof-local supplied-data cases.
- `[Igniter-Lang Architect Supervisor]`: owns any source-authority or
  implementation authorization.
- `[Igniter-Lang Bridge Agent]`: loader/report, CompatibilityReport, public
  API/CLI, and runtime surfaces remain closed unless separately opened.

---

## Evidence Read

- `docs/tracks/oof-fragment-registry-static-internal-data-design-v0.md`
  (LANG-R105-D1)
- `docs/gates/oof-fragment-registry-implementation-acceptance-decision-v0.md`
  (LANG-R104-A)
- `docs/tracks/oof-fragment-registry-implementation-boundary-proof-v0.md`
  (LANG-R103-I)
- `lib/igniter_lang/oof_fragment_registry.rb`
- `docs/tracks/compiler-pack-boundary-report-v0.md`
- `docs/dev/compiler-profile-architecture-direction.md`
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`

No tests or broad proof commands were run.

---

## Decision

Recommendation:

```text
Progress only as a staged source-boundary design.
Do not implement loader-supplied data yet.
Use proof-local caller-supplied registry hashes as the next safe evidence path.
Treat compiler-profile, manifest, pack descriptor, and loader/report sources as
future candidates behind separate gates.
```

Short form:

```text
current: validator accepts supplied hashes
next safe proof: proof-local supplied hash/path only
future live source: compiler-profile/pack/manifest/loader design after gates
```

Rationale:

- R103 proves `OOFFragmentRegistry#validate(registry_hash, installed_boundaries:)`
  works for supplied hashes.
- R105 rejects static internal library data.
- The remaining question is not "where do we store defaults?" but "which
  authority-bearing artifact may supply registry data later?"
- Loader/report, CompatibilityReport, `.igapp`, public API/CLI, and compiler
  integration remain closed.

---

## Source Candidate Map

| Candidate source | Current status | Fit | Primary risk | Recommendation |
| --- | --- | --- | --- | --- |
| Proof-local supplied JSON fixture | Open only inside experiment route | Best immediate source for more evidence. | Fixture may be mistaken for canon unless labeled. | Accept for proof-only route. |
| Proof-local caller-supplied Hash | Open inside experiments | Matches current validator API exactly. | Does not prove file-loading shape. | Accept for first supplied-data proof. |
| Internal test seam / constructor arg | Design candidate only | Could prove caller-supplied injection without public API. | Can look like hidden compiler integration if wired into orchestrator. | Hold until specific proof card. |
| Compiler profile contract field | Future design candidate | Aligns with PROP-038 strict registries and pack/profile direction. | PROP-038 diagnostics are not OOF; profile contract must not grant dispatch/runtime authority. | Defer to profile-contract source design. |
| Compiler profile descriptor / finalized source object | Future design candidate | Aligns with PROP-036 compiler profile identity. | Could imply mandatory profile or manifest changes. | Defer; needs PROP-036/038 coordination. |
| Pack descriptor artifact | Future design candidate | Natural owner for per-pack OOF/fragment rows. | Pack registry/dispatch is not implemented or authorized. | Defer until pack boundary proof opens. |
| `.igapp/manifest.json` | Future high-risk candidate | Could preserve artifact-level provenance after assembly. | Manifest mutation and loader/report behavior are closed; may confuse compile vs load authority. | Hold. |
| Loader/report sidecar | Future high-risk candidate | Could support inspection-time validation. | Loader/report and CompatibilityReport are closed. | Hold. |
| Environment/default path/config | Reject for now | Easy local plumbing. | Hidden public/config surface and accidental default authority. | Reject unless separate public config design opens. |
| Static `oof_fragment_registry_data.rb` | Rejected by R105 | Avoids file loading. | Mistaken as canon/default registry. | Keep rejected. |

---

## Recommended Staged Route

### Stage A — Proof-Local Supplied Data

Allowed future proof-only write scope if opened by Architect:

```text
experiments/oof_fragment_registry_supplied_data_source_proof/**
docs/tracks/oof-fragment-registry-supplied-data-source-proof-v0.md
```

Purpose:

- feed registry hashes to `OOFFragmentRegistry#validate`;
- prove accepted source-envelope metadata;
- prove invalid source envelopes remain internal-only diagnostics;
- assert no compiler/report/public/runtime outputs change.

Stage A must not:

- edit `lib/igniter_lang/oof_fragment_registry.rb` unless explicitly authorized;
- create `oof_fragment_registry_data.rb`;
- require the validator from `lib/igniter_lang.rb`;
- touch compiler passes or public API/CLI;
- write `.igapp`, report, or CompatibilityReport fields.

### Stage B — Source Authority Shape

Design-only follow-up after Stage A, if needed:

```text
oof-fragment-registry-source-authority-shape-v0
```

Questions:

- is registry source authority per whole registry, per row, or both?
- does the authority reference a gate, proposal/spec, compiler profile
  contract, pack descriptor, or generated proof artifact?
- how are historical proof references kept separate from current source
  authority?
- how does absent-owner/inactive-row behavior interact with source authority?

### Stage C — Profile/Pack Candidate Source

Only after source-authority shape is accepted:

```text
oof-fragment-registry-profile-pack-source-design-v0
```

Candidate source:

```text
compiler_profile_contract or compiler profile descriptor supplies registry rows
```

Required safeguards:

- `compiler_profile_contract.*` diagnostics remain excluded from OOF;
- profile contract validity is evidence, not dispatch authority;
- no pack registry/dispatch migration;
- no public API/CLI or manifest mutation;
- no loader/report or CompatibilityReport behavior.

### Stage D — Loader/Report Consumption

Not recommended now.

Would require Bridge/Architect authority and answer:

- whether load-time validation is inspection-only or refusal-bearing;
- how validation evidence is represented;
- whether CompatibilityReport gets a field;
- how invalid or missing registry data interacts with legacy `.igapp`;
- whether loader refusal is distinct from compile refusal.

---

## Supplied Registry Envelope Candidate

For future proof-only use, prefer an envelope around the existing registry hash:

```json
{
  "kind": "oof_fragment_registry_source",
  "format_version": "0.1.0",
  "source_mode": "proof_fixture | caller_supplied | profile_candidate | pack_descriptor_candidate",
  "authority": {
    "authority_ref": "LANG-R106-D1",
    "authority_kind": "proof_only | design_accepted | gate | proposal | spec",
    "canon_status": "non_canon | accepted_design | canon"
  },
  "registry": {
    "kind": "oof_fragment_registry",
    "format_version": "0.1.0",
    "source_authority": {},
    "oof_descriptors": [],
    "fragment_rows": [],
    "support_markers": {
      "invariant_support_markers": []
    },
    "excluded_namespaces": []
  }
}
```

Envelope rules:

- proof fixtures must set `authority.canon_status: "non_canon"`;
- `source_mode: "profile_candidate"` is design-only until a profile gate opens;
- `source_mode: "pack_descriptor_candidate"` is design-only until pack boundary
  authority opens;
- the validator still validates only the nested registry hash unless a later
  card authorizes source-envelope validation;
- the envelope must not be emitted in compilation reports or public results.

---

## Source Authority Requirements

Any future supplied-data source must declare:

| Field | Meaning |
| --- | --- |
| `source_mode` | Proof fixture, caller supplied, profile candidate, pack descriptor candidate, or later accepted source. |
| `authority_ref` | Gate/track/proposal/spec reference for the source content. |
| `authority_kind` | `proof_only`, `design_accepted`, `gate`, `proposal`, or `spec`. |
| `canon_status` | `non_canon`, `accepted_design`, or `canon`. |
| `row_authority_policy` | Whole-registry authority or per-row authority. |
| `historical_source_refs` | Optional proof/history refs, never current authority by themselves. |
| `closed_surface_assertions` | Public/report/runtime/compiler integration remain false unless separately opened. |

Required separation:

```text
historical_source_refs != source_authority
valid registry source != compiler integration
valid registry source != public diagnostic authority
valid registry source != loader/report readiness
valid registry source != runtime/production readiness
```

---

## Internal Validation Flow Candidate

Design-only flow:

```text
supplied registry source
  -> source envelope precheck (future proof/design)
  -> registry hash
  -> OOFFragmentRegistry#validate(...)
  -> internal validation result
  -> proof summary only
```

Forbidden in this route:

```text
supplied registry source
  -> compiler pass lookup
  -> public diagnostics/report fields
  -> .igapp manifest
  -> loader/refusal/runtime behavior
```

The current validator result remains internal:

- no top-level `report["diagnostics"]`;
- no `CompilerResult` field;
- no public API/CLI output;
- no `.igapp` field;
- no loader/report or CompatibilityReport field.

---

## Future Proof Matrix

If Stage A opens, require at least:

| Command | Purpose |
| --- | --- |
| `ruby experiments/oof_fragment_registry_supplied_data_source_proof/oof_fragment_registry_supplied_data_source_proof.rb` | Validate proof-local supplied source envelopes and registry hashes. |
| `ruby experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | Ensure R103 validator proof still passes. |
| `ruby experiments/classifier_pass_proof/classifier_pass_proof.rb` | Classifier parity. |
| `ruby experiments/typechecker_proof/typechecker_proof.rb --check-golden` | TypeChecker parity. |
| `ruby experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | SemanticIR/report parity. |
| `ruby experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | `.igapp` parity. |
| `ruby experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PROP-038 separation remains intact. |

Required assertions:

- no static `oof_fragment_registry_data.rb`;
- no `lib/igniter_lang.rb` require;
- no compiler pass require;
- proof fixture source is labeled non-canon;
- invalid source envelope does not write reports or public results;
- valid supplied registry source does not imply compiler integration;
- `compiler_profile_contract.*` remains excluded from OOF;
- `PINV-*` / `TINV-*` remain support markers.

---

## Blockers Before Any Implementation

Before any supplied-data implementation authorization, require:

- Architect decision naming the exact stage: Stage A proof-only, Stage B design,
  Stage C profile/pack candidate, or Stage D loader/report;
- exact write scope;
- decision whether the source envelope is validated by a new helper or only by
  proof-local code;
- source-authority field acceptance;
- parity command matrix;
- proof that no static data file is created;
- proof that public API/CLI, compiler passes, reports, `.igapp`,
  CompatibilityReport, runtime, and production remain unchanged;
- Bridge review if the route mentions loader/report or CompatibilityReport as
  anything more than a closed future candidate.

---

## Recommendation

Recommendation:

```text
Hold live loader/caller integration.
If progress is desired, open Stage A proof-only supplied-data source proof.
Do not open compiler integration, public API/CLI, specs/canon, reports,
CompatibilityReport, `.igapp`, runtime, or production behavior.
```

Suggested next route:

```text
oof-fragment-registry-supplied-data-source-proof-v0
```

Route type:

```text
proof-only
experiment-local
no implementation outside experiment unless separately authorized
```

---

## Closed Surfaces

This design does not authorize:

- loader implementation;
- caller/public API/CLI registry input;
- `lib/igniter_lang/oof_fragment_registry_data.rb`;
- static internal registry data constants;
- compiler integration;
- specs, proposals, or canon edits;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  report, `CompilerResult`, or CLI behavior changes;
- public diagnostic renames, promotions, aliases, or wording changes;
- loader/report or CompatibilityReport changes;
- `.igapp`, `.ilk`, or golden mutation;
- live pack registry or dispatch;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend, BiHistory, stream/OLAP production executors;
- cache, signing, deployment, or production behavior;
- Spark fixture/spec/data/code work or Spark production integration.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: LANG-R106-D1
Track: oof-fragment-registry-loader-supplied-data-source-design-v0
Status: done

[D]
- Designed future loader/caller-supplied registry data-source boundary without
  static lib data.
- Recommended staged route: proof-local supplied data first; profile/pack and
  loader/report sources remain future candidates behind gates.

[S]
- Current accepted state: R103 validator accepts supplied hashes.
- R105 rejected static internal data.
- R106 defines a non-canon source envelope candidate and source-authority fields.
- Live loader/caller/compiler integration remains closed.

[T]
- Docs-only design.
- No tests or broad proofs run.

[R]
- If progress is desired, open proof-only
  `oof-fragment-registry-supplied-data-source-proof-v0`.
- Do not open loader/report, public API/CLI, compiler integration, specs/canon,
  `.igapp`, runtime, or production behavior from this track.

[Next]
- Optional proof-only next route:
  `oof-fragment-registry-supplied-data-source-proof-v0`.
```
