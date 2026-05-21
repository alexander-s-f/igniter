# Track: OOF/Fragment Registry Authorization Blocker Closure Design v0

Card: LANG-R101-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Track: `oof-fragment-registry-authorization-blocker-closure-design-v0`
Status: done
Date: 2026-05-20

---

## Goal

Close or explicitly route the 9 remaining blockers from R100 before any
OOF/Fragment Registry implementation authorization review.

This track is design/closure only. It does not implement code, edit specs,
proposals, canon, compiler behavior, runtime behavior, public API/CLI,
loader/report, CompatibilityReport, `.igapp` artifacts, goldens, or production
surfaces.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: owns any future proof-local parity harness.
- `[Igniter-Lang Architect Supervisor]`: owns any implementation authorization
  review.
- `[Igniter-Lang Bridge Agent]`: public API/CLI, loader/report,
  CompatibilityReport, and runtime surfaces remain closed.

---

## Evidence Read

- `docs/tracks/oof-fragment-registry-implementation-boundary-design-v0.md`
  (LANG-R99-D1)
- `docs/discussions/oof-fragment-registry-implementation-boundary-pressure-v0.md`
  (LANG-R100-X)
- `docs/tracks/pinv-tinv-lifecycle-and-registry-classification-design-v0.md`
  (LANG-R97-D1)
- `docs/gates/pinv-tinv-lifecycle-classification-acceptance-decision-v0.md`
  (LANG-R98-A)
- Current proof command paths under `experiments/`, read only.

No tests or broad proof commands were run.

---

## Closure Verdict

Recommendation:

```text
Authorization review may open for the exact bounded first slice defined here.
Implementation remains unauthorized until a separate Architect gate accepts it.
```

The R100 pressure review closed the pressure-review blocker and left 9 blockers.
This track closes or routes those 9 blockers enough to let an authorization
review card evaluate the exact slice.

The future first slice, if authorized, is:

```text
isolated internal registry validator
+ proof-local boundary/parity harness
+ docs handoff
```

It is not:

- compiler integration;
- public OOF registry behavior;
- pack dispatch;
- spec/canon/proposal mutation;
- loader/report, CompatibilityReport, runtime, or production behavior.

---

## Exact First-Slice Write Scope

If a later Architect gate authorizes implementation, the first slice may write
only these paths:

| Path | Status | Purpose | Constraint |
| --- | --- | --- | --- |
| `lib/igniter_lang/oof_fragment_registry.rb` | In first slice | Internal pure validator for supplied registry hashes. | Do not require from `lib/igniter_lang.rb`; no compiler pass integration; no public API/CLI. |
| `experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | In first slice | Proof-local harness for registry validation, inactive rows, and closed-surface assertions. | No live compiler output changes except proof-owned `out/`. |
| `experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/*.json` | In first slice | Forward-shape proof-local registry cases. | Fixtures are not canon and do not mutate R92 historical JSON. |
| `experiments/oof_fragment_registry_implementation_boundary_proof/out/*` | In first slice | Proof-owned summary/output. | No `.igapp`, report, or public sidecar mutation outside the proof directory. |
| `docs/tracks/oof-fragment-registry-implementation-boundary-proof-v0.md` | In first slice | Implementation proof handoff if a future card opens. | Track only; no spec/proposal/canon edit. |

Explicitly out of the first slice:

- `lib/igniter_lang/oof_fragment_registry_data.rb`
- `lib/igniter_lang.rb`
- parser, classifier, TypeChecker, SemanticIR emitter, assembler,
  orchestrator, compilation report, compiler result, CLI;
- `docs/spec/`;
- `docs/proposals/`;
- existing `.igapp` outputs or goldens;
- loader/report, CompatibilityReport, RuntimeMachine, production code.

---

## First-Slice Registry Shape

The first slice should validate the full forward bucket shape:

```json
{
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
```

Decision:

```text
support_markers.invariant_support_markers are IN the first slice.
```

Reason:

- R98 accepted `PINV-*` / `TINV-*` as support metadata, not OOF descriptors.
- A first registry validator that omits `support_markers` would fail to prove
  the most important R98 separation invariant.
- Including the bucket does not create live support-marker behavior if the
  result remains internal-only and proof-local.

Required first-slice validations:

- `PINV-*` / `TINV-*` rows may appear only under
  `support_markers.invariant_support_markers`;
- support markers cannot appear in `oof_descriptors`;
- support markers cannot be OOF aliases;
- support markers must be non-public and non-emitted;
- support marker codes cannot collide with public OOF descriptor codes;
- related public OOF descriptor references must point to descriptor rows or be
  explicitly marked as deferred candidate references.

---

## `oof_fragment_registry_data.rb` Decision

Decision:

```text
`lib/igniter_lang/oof_fragment_registry_data.rb` is OUT of the first slice.
```

Reason:

- Static library data can be misread as canon registry content.
- The first slice only needs to validate supplied hashes and proof-local
  fixtures.
- Keeping data in `experiments/.../fixtures/*.json` preserves the line between
  proof evidence and accepted compiler/runtime data.

Route:

```text
If static internal data constants are later desired, open a separate design or
authorization card after the isolated validator proof passes.
```

---

## R92 Historical JSON Treatment

Decision:

```text
Do not migrate or rewrite R92 historical JSON.
```

R92 shadow artifacts remain historical proof evidence, including their older
shape where `PINV-*` / `TINV-*` appeared under
`oof_descriptors.shadow_registry.json`.

The future first-slice proof must instead add new forward-shape fixtures under:

```text
experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/
```

Those fixtures should include a note such as:

```json
{
  "historical_source_refs": [
    "experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json"
  ],
  "migration_policy": "non_migration_historical_artifact",
  "forward_shape_authority": "LANG-R98-A plus LANG-R101-D1"
}
```

The proof may read R92 JSON as comparison evidence, but it must not mutate it
and must not treat the R92 bucket placement as the forward shape.

---

## Internal-Only Validation Result Shape

Candidate internal result object:

```json
{
  "kind": "oof_fragment_registry_validation",
  "format_version": "0.1.0",
  "valid": true,
  "registry_service_present": true,
  "checked_sections": [
    "oof_descriptors",
    "fragment_rows",
    "support_markers.invariant_support_markers",
    "excluded_namespaces"
  ],
  "diagnostics": [],
  "inactive_rows": [],
  "closed_surface_assertions": {
    "compiler_integration": false,
    "public_api_cli": false,
    "top_level_report_diagnostics": false,
    "compiler_result_field": false,
    "loader_report": false,
    "compatibility_report": false,
    "runtime_behavior": false,
    "igapp_mutation": false
  }
}
```

Internal diagnostic code candidates, if needed by the proof:

- `oof_registry.validation.missing_section`
- `oof_registry.validation.duplicate_code`
- `oof_registry.validation.alias_collision`
- `oof_registry.validation.excluded_namespace_collision`
- `oof_registry.validation.support_marker_public`
- `oof_registry.validation.support_marker_emitted`
- `oof_registry.validation.owner_boundary_absent`
- `oof_registry.validation.lifecycle_promotion_attempt`

These are validator-internal proof diagnostics, not language OOF codes and not
central `IgniterLang::Diagnostics` entries.

Forbidden result effects:

- no top-level `report["diagnostics"]` append;
- no `CompilerResult` key;
- no public API/CLI output;
- no `.igapp` field;
- no loader/report or CompatibilityReport field;
- no runtime or production action.

---

## Absent-Pack Inactive-Descriptor Proof Case

The first-slice proof must include at least one synthetic absent-owner case.

Required proof shape:

```json
{
  "case": "absent_owner_inactive_rows",
  "installed_boundaries": ["CorePack", "InvariantPack"],
  "registry": {
    "oof_descriptors": [
      {
        "code": "OOF-SYN1",
        "owner_pack_or_boundary": "SyntheticAbsentPack"
      }
    ],
    "fragment_rows": [
      {
        "name": "synthetic_absent_fragment",
        "owner_pack_or_boundary": "SyntheticAbsentPack"
      }
    ],
    "support_markers": {
      "invariant_support_markers": [
        {
          "code": "PINV-SYN",
          "owner_pack_or_boundary": "SyntheticAbsentPack"
        }
      ]
    }
  }
}
```

Required assertions:

- the registry service itself is present and non-optional;
- rows owned by absent boundaries are reported in `inactive_rows`;
- inactive rows are not silently skipped;
- inactive rows are not emitted;
- inactive rows do not create compiler/report/public output;
- shape-valid inactive rows do not cause public compile refusal.

This proof case must cover OOF descriptors, fragment rows, and support markers
because support markers are included in the first slice.

---

## Pinned Command Matrix

Any future implementation authorization card for the first slice must require
at least this exact command matrix:

| Command | Required reason |
| --- | --- |
| `ruby -c lib/igniter_lang/oof_fragment_registry.rb` | Syntax check isolated internal library. |
| `ruby experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | Registry validation, support-marker separation, inactive-row, and closed-surface proof. |
| `ruby experiments/classifier_pass_proof/classifier_pass_proof.rb` | Classifier parity; no OOF classification drift. |
| `ruby experiments/typechecker_proof/typechecker_proof.rb --check-golden` | TypeChecker golden parity. |
| `ruby experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | Source-to-SemanticIR and CompilationReport golden parity. |
| `ruby experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | `.igapp` assembler parity. |
| `ruby experiments/invariant_severity_proof/invariant_severity_proof.rb` | Invariant OOF parity and `PINV-*` / `TINV-*` non-emission. |
| `ruby experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PROP-038 diagnostic separation and report-only nested field parity. |

This is a floor, not a ceiling. If a future implementation touches any path
outside the exact first-slice write scope, the authorization review must add
the corresponding proof commands or reject the widened scope.

---

## Source-Authority Rule for Authorization Review

The authorization gate must explicitly accept these source-authority rules:

| Rule | Review requirement |
| --- | --- |
| Implementation code cannot promote lifecycle state. | Gate must say the validator is evidence only. |
| `PINV-*` / `TINV-*` remain support metadata. | Gate must preserve R98 classification. |
| Support metadata cannot become public OOF without proposal/spec/gate. | Gate must keep public diagnostic promotion closed. |
| Guarded non-fragments remain non-fragments. | Gate must keep OLAP/progression fragment promotion closed. |
| Excluded namespaces remain excluded. | Gate must keep `compiler_profile_contract.*` outside OOF. |

This track closes the design wording. Architect acceptance remains a gate-owned
step, not something this design can self-authorize.

---

## Vocabulary Reaffirmation

Canonical implementation-boundary vocabulary for the next review:

```text
OOF registry service
Fragment registry service
support marker metadata
excluded namespace policy
```

Do not use as first-slice authority vocabulary:

```text
OOFRegistryPack
optional OOF pack
live OOF pack dispatch
public registry pack
```

Reason:

- the service is kernel/support vocabulary;
- absent pack rows can be inactive, but the registry service is not optional;
- the first slice validates data, it does not install a pack system.

---

## Blocker Table

| R100 blocker | Decision | Status after LANG-R101-D1 |
| --- | --- | --- |
| 1. Exact future file write scope. | First slice may write only `lib/igniter_lang/oof_fragment_registry.rb`, proof-local experiment fixtures/runner/out, and proof track. | Closed for review. |
| 2. Decide whether `oof_fragment_registry_data.rb` is in or out. | Out of first slice; static data constants require later card. | Closed for review; held out of slice. |
| 3. Decide whether `support_markers.invariant_support_markers` are in first slice. | In first slice schema and proof, internal-only. | Closed for review. |
| 4. R92 historical JSON migration/non-migration note. | Non-migration; retain historical JSON as-is, add new forward-shape fixtures. | Closed for review. |
| 5. Byte-for-byte parity plan and pinned command matrix. | Exact 8-command minimum matrix pinned above. | Closed for review. |
| 6. Source-authority transition rules accepted by Architect. | Rules are restated; gate must explicitly accept them. | Routed to authorization review acceptance bar. |
| 7. Absent optional pack behavior machine-asserted. | Required synthetic absent-owner case defined for descriptors, fragments, and support markers. | Closed for review. |
| 8. Validation result shape defined. | Internal-only result object and forbidden effects defined. | Closed for review. |
| 9. `OOF registry service` vocabulary confirmation and Architect gate. | Vocabulary reaffirmed; actual authorization remains separate gate. | Routed to authorization review. |

---

## Implementation-Boundary Map

| Boundary | May open in first implementation authorization? | Notes |
| --- | ---: | --- |
| Internal validator library | Yes, if Architect authorizes. | Isolated, not required from public entrypoint. |
| Proof-local fixtures/runner/out | Yes, if Architect authorizes. | Owns R98 forward shape and inactive-row proof. |
| `oof_fragment_registry_data.rb` | No. | Separate later decision only. |
| Compiler pass integration | No. | Parser/classifier/typechecker/SemanticIR remain unchanged. |
| Report/CompilerResult/public API/CLI | No. | Internal result only. |
| `.igapp` / assembler / loader/report / CompatibilityReport | No. | Parity only. |
| Runtime/production/Gate 3/Ledger/TBackend/cache | No. | Closed. |
| Spec/proposal/canon updates | No. | Closed for this route. |

---

## Recommendation

Recommendation:

```text
Authorization review may open for the exact first slice defined here.
Implementation remains held until an Architect gate explicitly authorizes it.
```

Suggested next route:

```text
oof-fragment-registry-implementation-authorization-review-v0
```

The review should accept, reject, or revise this exact boundary. It should not
silently widen the write scope.

---

## Closed Surfaces

This closure design does not authorize:

- implementation;
- `oof_fragment_registry_data.rb`;
- specs, proposals, or canon edits;
- compiler/runtime behavior changes;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  report, or `CompilerResult` behavior changes;
- public diagnostic renames, promotions, aliases, or wording changes;
- public API/CLI widening;
- loader/report or CompatibilityReport changes;
- `.igapp`, `.ilk`, or golden mutation;
- live pack registry or dispatch;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend, BiHistory, stream/OLAP production executors;
- cache, signing, deployment, or production behavior;
- Spark fixture/spec work or Spark production integration.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: LANG-R101-D1
Track: oof-fragment-registry-authorization-blocker-closure-design-v0
Status: done

[D]
- Closed or routed the 9 R100 blockers.
- Pinned exact first-slice write scope and command matrix.
- Kept `oof_fragment_registry_data.rb` out of the first slice.
- Kept `support_markers.invariant_support_markers` in the first slice schema.

[S]
- R92 historical JSON is retained as historical/non-migrated.
- Future proof uses new R98-shaped fixtures.
- Validation result shape is internal-only with no report/public/runtime effects.
- `OOF registry service` remains kernel/support vocabulary, not optional pack.

[T]
- Docs-only design.
- No tests or broad proofs run.

[R]
- Authorization review may open for this exact boundary.
- Implementation remains unauthorized until a separate Architect gate accepts it.

[Next]
- Recommend `oof-fragment-registry-implementation-authorization-review-v0`.
```
