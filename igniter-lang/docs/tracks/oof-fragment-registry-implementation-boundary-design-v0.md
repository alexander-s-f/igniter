# Track: OOF/Fragment Registry Implementation Boundary Design v0

Card: LANG-R99-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Track: `oof-fragment-registry-implementation-boundary-design-v0`
Status: done
Date: 2026-05-20

---

## Goal

Design the implementation boundary for a possible future OOF/Fragment Registry
without implementing it.

This track is design-only. It does not edit specs, proposals, canon, compiler
code, runtime code, `.igapp` goldens, public API/CLI, loader/report,
CompatibilityReport, RuntimeMachine/Gate 3, Ledger/TBackend, cache, signing,
production behavior, or Spark fixture/spec material.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: future proof/parity harness ownership.
- `[Igniter-Lang Architect Supervisor]`: implementation authorization review.
- `[Igniter-Lang Bridge Agent]`: public API/CLI, loader/report,
  CompatibilityReport, and runtime surfaces remain closed.

---

## Evidence Read

- `docs/gates/pinv-tinv-lifecycle-classification-acceptance-decision-v0.md`
- `docs/tracks/pinv-tinv-lifecycle-and-registry-classification-design-v0.md`
- `docs/gates/oof-fragment-registry-policy-proof-acceptance-decision-v0.md`
- `docs/tracks/oof-fragment-registry-policy-proof-v0.md`
- `docs/tracks/oof-fragment-registry-ownership-and-canon-semantics-design-v0.md`
- `docs/discussions/oof-fragment-registry-design-pressure-v0.md`
- `docs/gates/oof-fragment-registry-shadow-proof-decision-v0.md`
- `experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json`
- `experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json`
- `experiments/oof_fragment_registry_policy_proof/out/oof_fragment_registry_policy_model.json`
- `lib/igniter_lang/` file inventory, read only.

No tests or broad proof commands were run.

---

## Boundary Verdict

Recommended posture:

```text
HOLD implementation authorization.
Allow only a future implementation-authorization review after pressure.
If opened later, first implementation slice must be an isolated internal
registry library with no compiler integration.
```

The future registry may be designed as a kernel/support service, not an
optional language pack:

```text
OOF registry service
Fragment registry service
support marker metadata
excluded namespace policy
```

It must not become:

- live pack dispatch;
- parser/classifier/TypeChecker/SemanticIR/assembler behavior;
- public diagnostic authority by itself;
- loader/report or CompatibilityReport evidence;
- runtime or production authority.

---

## Candidate Future Write Scope

If a later Architect decision opens the first implementation slice, the
preferred bounded write scope is:

| Area | Candidate path | Allowed future purpose | Must not do |
| --- | --- | --- | --- |
| Internal registry library | `lib/igniter_lang/oof_fragment_registry.rb` | Define pure data validation for registry hashes. | No compiler pass integration, no public API, no CLI, no report writes. |
| Optional internal data constants | `lib/igniter_lang/oof_fragment_registry_data.rb` | Hold frozen proof-derived sample data only if explicitly authorized. | No generated public canon and no automatic sync from specs. |
| Proof-local harness | `experiments/oof_fragment_registry_implementation_boundary_proof/` | Prove validation behavior and parity/non-authority invariants. | No live compiler output changes. |
| Proof summary | `experiments/oof_fragment_registry_implementation_boundary_proof/out/*summary.json` | Record PASS/FAIL and closed-surface assertions. | No `.igapp`, report, or golden mutation. |
| Track doc | `docs/tracks/oof-fragment-registry-implementation-boundary-proof-v0.md` | Handoff and matrix if proof opened. | No spec/canon/proposal edit. |

Explicitly excluded from the first implementation slice:

- `lib/igniter_lang/parser.rb`
- `lib/igniter_lang/classifier.rb`
- `lib/igniter_lang/typechecker.rb`
- `lib/igniter_lang/semanticir_emitter.rb`
- `lib/igniter_lang/assembler.rb`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/compilation_report.rb`
- `lib/igniter_lang/compiler_result.rb`
- `lib/igniter_lang/cli.rb`
- `lib/igniter_lang.rb`
- `docs/spec/`
- `docs/proposals/`
- existing `.igapp` fixtures/goldens

Reason: first implementation must prove registry validation as an isolated
library before any behavior-bearing compiler surface can depend on it.

---

## Implementation-Boundary Map

| Phase | Boundary | Status after this track | Notes |
| --- | --- | --- | --- |
| 0 | Design-only boundary | Complete in this track | No implementation. |
| 1 | Isolated internal validator library | Candidate only | Pure validation of supplied registry hashes; no compiler integration. |
| 2 | Proof-local parity harness | Candidate only | Runs the library against proof-local registry data and asserts no live output changes. |
| 3 | Compiler profile contract integration | Held | Requires separate authority; may connect to PROP-038 only after parity proof. |
| 4 | Compiler pass diagnostics lookup | Held | Would touch parser/classifier/typechecker/report behavior; not in first slice. |
| 5 | Public/spec/canon registry | Held | Requires proposal/spec/canon decision. |
| 6 | Loader/report or CompatibilityReport consumption | Closed | Bridge/runtime route only after separate decision. |

Recommended first future implementation target, if ever authorized:

```text
Phase 1 + Phase 2 only:
internal validator library + proof-local parity harness
```

---

## Registry Shape Boundary

Candidate top-level shape:

```json
{
  "kind": "oof_fragment_registry",
  "format_version": "0.1.0",
  "source_authority": {
    "authority_ref": "gate-or-proof-ref",
    "authority_kind": "proof_only | design_accepted | proposal | spec | gate",
    "canon_status": "non_canon | accepted_design | canon"
  },
  "oof_descriptors": [],
  "fragment_rows": [],
  "support_markers": {
    "invariant_support_markers": []
  },
  "excluded_namespaces": []
}
```

This shape is a candidate implementation boundary, not canon.

### `oof_descriptors`

Candidate descriptor fields:

```json
{
  "code": "OOF-IV1",
  "family": "invariant",
  "owner_pack_or_boundary": "InvariantPack",
  "source_stage": "parser",
  "compiler_layer": "parser",
  "severity": "error",
  "status_class": "blocking_oof",
  "public_code_stability": "stable_current",
  "message_stability": "stable_family_message",
  "aliases": [],
  "deprecated": false,
  "deprecated_by": null,
  "replacement_code": null,
  "source_refs": [],
  "current_status": "current",
  "emitted_by_compiler": true,
  "non_authority_notes": ""
}
```

Required validation:

- canonical `code` values are unique;
- aliases cannot collide across canonical descriptors;
- aliases require existing current replacement descriptors;
- deprecated descriptors name replacement or rationale;
- every descriptor has one owner;
- every descriptor declares source stage/layer;
- every descriptor declares public-code stability;
- excluded namespaces cannot appear as descriptors or aliases.

### `fragment_rows`

Candidate fragment row fields:

```json
{
  "name": "temporal",
  "owner_pack_or_boundary": "TemporalPack",
  "current_or_candidate": "current",
  "applies_to": ["node", "contract"],
  "classification_kind": "language_fragment",
  "value_flow_notes": "Temporal node may produce CORE-typed value.",
  "precedence_candidate": 90,
  "canonical_status": "non_canon_candidate",
  "loadable": true,
  "capability": true,
  "non_authority_notes": ""
}
```

Special required rows:

- `oof`: status-primary / secondary fragment projection; blocked,
  non-loadable, status-only, capability-free.
- `olap`: guarded non-fragment, no precedence, non-loadable.
- `progression`: guarded non-fragment, no precedence, non-loadable.

Forward candidate precedence remains:

```text
oof > temporal > stream > escape > epistemic > core
```

It is still non-canon and must not change compiler behavior.

### `support_markers.invariant_support_markers`

PINV/TINV live here if modeled.

Candidate row:

```json
{
  "code": "PINV-3",
  "family": "invariant_parser_support",
  "owner_pack_or_boundary": "InvariantPack",
  "source_stage": "parser",
  "compiler_layer": "parser",
  "lifecycle_state": "support_metadata_current",
  "public_code_stability": "non_public_support_marker",
  "related_oof_descriptors": ["OOF-IV1", "OOF-IV2", "OOF-I4"],
  "source_refs": [],
  "non_authority_notes": "Support marker only; not emitted as a public diagnostic."
}
```

Required validation:

- support marker codes do not collide with OOF descriptor codes;
- support markers are not OOF aliases;
- support markers are non-public;
- support markers cannot be emitted diagnostics;
- `PINV-*` and `TINV-*` stay out of `oof_descriptors`.

### `excluded_namespaces`

Candidate row:

```json
{
  "prefix": "compiler_profile_contract.",
  "reason": "PROP-038 contract-object diagnostics are not language OOF codes.",
  "forbidden_as": ["oof_descriptor", "oof_alias"],
  "owner_boundary": "CompilerProfileContractPack"
}
```

Required excluded prefixes:

- `compiler_profile_contract.`
- `compiler_profile_contract_refusal.`

Candidate future excluded prefixes:

- runtime/proof helper diagnostics such as `OOF-RUNTIME-SMOKE`;
- invariant runtime/proof observation categories such as `INV-WARN`,
  `INV-SOFT`, `INV-METRIC`, `INV-ERROR`.

---

## Source-Authority Gates

| Transition | Required authority | Proof required |
| --- | --- | --- |
| proof-only marker -> support metadata | Design or Architect acceptance | No public output; marker non-emission assertion. |
| support metadata -> public OOF descriptor | Proposal/spec/gate explicitly reclassifying it | Public diagnostic proof, migration plan, parity impact. |
| candidate OOF descriptor -> current OOF descriptor | Proposal/spec/gate plus implementation authorization | Live compiler emission proof and golden/report parity update plan. |
| compatibility alias -> removed/deprecated | Proposal/spec/gate | Backward compatibility and replacement proof. |
| guarded non-fragment -> fragment class | Proposal/spec/gate | Fragment precedence, SemanticIR, assembler, manifest, and runtime closure proof. |
| excluded namespace -> OOF namespace | Separate Architect decision | Vocabulary separation and public surface review. |

Implementation code must not promote any lifecycle state by itself.

---

## Parity Requirements

Any future implementation proof must show:

- parser outputs unchanged;
- classifier outputs unchanged;
- TypeChecker outputs unchanged;
- SemanticIR outputs unchanged;
- CompilationReport outputs unchanged;
- `.igapp` manifests and contract artifacts unchanged;
- public `CompilerResult` key sets unchanged;
- CLI/API behavior unchanged;
- no loader/report or CompatibilityReport fields added;
- no runtime calls or production behavior added;
- no diagnostic code renames, deletions, or wording changes;
- `compiler_profile_contract.*` and `compiler_profile_contract_refusal.*`
  remain outside OOF;
- `PINV-*` / `TINV-*` remain support metadata and are not emitted.

Recommended proof approach:

```text
Run isolated registry validator against proof-local data.
Run existing selected compiler golden/proof matrix before and after.
Assert byte-for-byte output parity for all selected artifacts.
Assert no new public files or sidecars are written.
```

Minimum future command matrix, if implementation is authorized:

| Command | Purpose |
| --- | --- |
| `ruby -c lib/igniter_lang/oof_fragment_registry.rb` | Syntax check isolated library. |
| `ruby experiments/oof_fragment_registry_implementation_boundary_proof/...rb` | Registry validation and closed-surface proof. |
| `ruby experiments/classifier_pass_proof/classifier_pass_proof.rb` | Classifier parity. |
| `ruby experiments/typechecker_proof/typechecker_proof.rb --check-golden` | TypeChecker golden parity. |
| `ruby experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | SemanticIR/report parity. |
| `ruby experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | `.igapp` parity. |
| `ruby experiments/invariant_severity_proof/invariant_severity_proof.rb` | PINV/TINV support metadata non-emission and invariant OOF parity. |
| `ruby experiments/prop038_report_only_compiler_integration/...rb` | PROP-038 nested diagnostic separation. |

The exact command list must be selected by the future implementation card based
on changed files.

---

## Blockers Before Authorization Review

Before any implementation authorization review, require:

- pressure review of this R99 implementation-boundary design;
- exact future file write scope;
- decision whether `support_markers` are implemented in the first slice or
  deferred while preserving R98 classification;
- proof-local fixture data updated to the R98 forward shape, or an explicit
  migration/non-migration note for R92 historical JSON;
- byte-for-byte parity plan and selected command matrix;
- source-authority transition rules accepted;
- absent optional pack behavior defined:
  - registry service is not optional;
  - absent pack descriptors are inactive, not silently missing from validation;
- validation result shape defined:
  - internal-only result object;
  - no top-level `report["diagnostics"]`;
  - no `CompilerResult` field;
  - no public API/CLI output;
- confirmation that `OOF registry service` remains support/kernel vocabulary,
  not `OOFRegistryPack` as optional language pack;
- Architect implementation authorization gate.

---

## Recommendation

Recommendation:

```text
Hold implementation authorization.
Open pressure review for this implementation-boundary design next.
```

Suggested next route:

```text
oof-fragment-registry-implementation-boundary-pressure-v0
```

Route type:

```text
pressure-only / docs-only
no implementation
```

After pressure, if no blockers remain, Architect may consider a narrowly scoped
implementation authorization review for:

```text
internal isolated registry validator + proof-local parity harness
```

No live compiler integration should be considered before that isolated slice
passes.

---

## Closed Surfaces

This design does not authorize:

- implementation;
- specs, proposals, or canon edits;
- compiler/runtime code changes;
- live OOF registry, Fragment registry, or support marker registry behavior;
- pack registry or live dispatch;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  report, or `CompilerResult` behavior changes;
- public diagnostic renames, deletions, promotions, aliases, or wording changes;
- public API/CLI widening;
- loader/report or CompatibilityReport changes;
- `.igapp`, `.ilk`, or golden mutation;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend, BiHistory, stream/OLAP production executors;
- cache, signing, deployment, or production behavior;
- Spark fixture/spec work or Spark production integration.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: LANG-R99-D1
Track: oof-fragment-registry-implementation-boundary-design-v0
Status: done

[D]
- Designed future implementation boundary only.
- Preferred first future slice: isolated internal registry validator plus
  proof-local parity harness.
- Kept compiler integration, specs/canon, public/report/runtime surfaces closed.

[S]
- Candidate registry shape has:
  oof_descriptors
  fragment_rows
  support_markers.invariant_support_markers
  excluded_namespaces
- PINV/TINV remain support metadata, not OOF descriptors or aliases.
- OOF registry service remains kernel/support vocabulary, not optional pack.

[T]
- Docs-only design.
- No tests or broad proofs run.

[R]
- Pressure review should test write-scope, parity, source-authority, absent-pack
  behavior, and validation result shape before any implementation gate.

[Next]
- Recommend `oof-fragment-registry-implementation-boundary-pressure-v0`.
```
