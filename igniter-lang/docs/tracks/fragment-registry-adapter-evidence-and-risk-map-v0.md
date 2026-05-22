# Fragment Registry Adapter Evidence And Risk Map v0

Card: S3-R145-C2-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: LANG-R144-P1 / `fragment-precedence-compatibility-adapter-proof-v0`  
Track: `fragment-registry-adapter-evidence-and-risk-map-v0`  
Status: done  
Date: 2026-05-22

---

## Role And Neighbor Awareness

Assigned track: map evidence, code touchpoints, fixtures, and risk surfaces
needed before any future fragment registry adapter implementation review.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` - owns classifier fragment semantics,
  adapter semantics, and any future implementation-candidate decision.
- `[Igniter-Lang Bridge Agent]` - must review before report/public/loader,
  CompatibilityReport, `.igapp`, runtime, production, or Spark surfaces open.

---

## Current Horizon

```text
R142 found that a single live shadow precedence order would drift current
classifier behavior.
R143 split declaration fragment presence from selected fragment.
R144 proved that proof-local adapter preserves all 23 observed classifier
goldens.
R145 maps what would need review before any implementation card.
```

---

## Read Set

- `docs/tracks/fragment-precedence-compatibility-adapter-proof-v0.md`
- `docs/tracks/fragment-precedence-resolution-design-v0.md`
- `docs/tracks/oof-fragment-registry-parity-proof-v0.md`
- `experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_summary.json`
- `experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_matrix.json`
- `experiments/fragment_precedence_parity_proof/out/fragment_precedence_parity_summary.json`
- `experiments/oof_fragment_registry_parity_proof/out/oof_fragment_registry_parity_summary.json`
- read-only search:

```bash
rg "fragment_class|stream|epistemic|temporal|oof|escape" igniter-lang/lib igniter-lang/experiments -g "*.rb" -g "*.json"
```

---

## Current Live Classifier Behavior Map

Current selected `fragment_class` behavior is centered in:

```text
igniter-lang/lib/igniter_lang/classifier.rb
```

Key current facts:

| Live behavior | Code touchpoint | Evidence |
| --- | --- | --- |
| Stream declarations are classified as `escape`, not selected `stream`. | `Classifier#classify_contract`, `when "stream"` assigns symbol/declaration `escape`. | `classifier_pass_proof/golden/stream_ingress_escape.classified.json`, `stream_fold_core.classified.json` |
| `fold_stream` result can be `core`; direct stream use or missing window creates OOF. | `fold_stream` and `compute` branches track stream refs and OOF-S2/S4. | `classifier_pass_proof` stream checks PASS |
| Temporal read declarations are `fragment_class: temporal`, with `node_fragment_class: temporal` and `value_fragment_class: core`. | `read` branch and `value_fragment_metadata`. | Temporal classifier goldens and R144 matrix |
| Mixed temporal + escape selects `temporal`. | `contract_fragment_for`: temporal check precedes escape. | `observed_temporal_precedence.classified.json` |
| Mixed epistemic + escape selects `escape`. | `contract_fragment_for`: escape check precedes epistemic. | `assumptions_proof/golden/assumption_basic.classified.json` |
| Epistemic-only selects `epistemic`. | `uses_assumptions` branch plus `contract_fragment_for`. | `epistemic_only_pure.classified.json` |
| Any diagnostics select `oof`. | `contract_fragment_for` returns `oof` unless diagnostics empty. | 7 observed OOF classified contracts in R144 |

Current selected fragment counts from R144:

| Fragment | Count |
| --- | ---: |
| `core` | 5 |
| `escape` | 7 |
| `temporal` | 3 |
| `oof` | 7 |
| `epistemic` | 1 |

---

## Proof-Local Adapter Behavior Map

R144 proof artifact:

```text
igniter-lang/experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_matrix.json
digest: 65e876f5ae23ce761c16b704
```

The adapter has two layers:

| Layer | Purpose | Live status |
| --- | --- | --- |
| `declaration_fragment_presence` | Records all surface signals: `core`, `escape`, `stream`, `epistemic`, `temporal`, `oof`. | Proof-local only |
| `selected_fragment_adapter` | Projects presence to current classifier-compatible `fragment_class`. | Proof-local only; `held_live_dispatch: true` |

Adapter selection rule:

```text
oof -> oof
temporal -> temporal
escape -> escape
stream -> escape
epistemic -> epistemic
else -> core
```

Important compatibility behavior:

| Current ambiguity | Adapter resolution | R144 result |
| --- | --- | --- |
| Stream surfaces want `stream` presence but selected fragment is currently `escape`. | Record `stream`; select `escape`. | PASS |
| Mixed epistemic + escape wants epistemic presence but selected fragment is currently `escape`. | Record `epistemic`; select `escape`. | PASS |
| Epistemic-only should stay `epistemic`. | No escape presence; select `epistemic`. | PASS |
| Temporal + escape should stay `temporal`. | Temporal outranks escape. | PASS |
| OOF must not become a capability. | Status-primary, blocked, non-loadable, non-capability. | PASS |

---

## Fixture / Golden Evidence Table

| Evidence source | What it proves | Status |
| --- | --- | --- |
| `fragment-precedence-parity-proof-v0` | Shadow fragment rows cover current observed fragment names; guarded non-fragments and OOF projection pass; single-order live precedence held. | HOLD with useful facts |
| `fragment-precedence-compatibility-adapter-proof-v0` | Adapter preserves all 23 current classified contracts exactly. | PASS |
| `classifier_pass_proof/golden/*.classified.json` | Core, stream, temporal, evidence, and OOF selected-fragment behavior. | PASS anchor |
| `contract_modifiers_proof/golden/*.classified.json` | Observed/effect/escape modifiers, temporal-over-escape, OOF-M1. | PASS anchor |
| `assumptions_proof/golden/*.classified.json` | Epistemic-only and epistemic+escape selected behavior. | PASS anchor |
| `oof-fragment-registry-parity-proof-v0` | OOF public code/alias/exclusion parity stays separate from fragment adapter. | PASS anchor |
| `oof_fragment_registry_policy_proof` | OOF projection and guarded non-fragment policies. | PASS anchor |

Evidence still missing for implementation review:

- byte-for-byte `ClassifiedProgram` parity after any live adapter code;
- exact decision whether `declaration_fragment_presence` becomes a field in
  `ClassifiedProgram`, report-only metadata, or registry-only data;
- downstream parity across TypeChecker, SemanticIR, assembler, `.igapp`, and
  reports if any new field is emitted;
- proof that adding presence metadata does not become runtime capability,
  loader readiness, or production authority.

---

## Code Touchpoint Map

| Surface | File / symbol | Why it matters | Future write risk |
| --- | --- | --- | --- |
| Classifier selected fragment | `lib/igniter_lang/classifier.rb`, `contract_fragment_for` | Current selected-fragment rules are encoded here. | Highest risk; changing order can drift goldens. |
| Declaration classification | `lib/igniter_lang/classifier.rb`, `classify_contract` branches for `stream`, `read`, `uses_assumptions`, `fold_stream`, `compute`, `output` | Source of declaration fragment signals and OOF diagnostics. | High; presence derivation could accidentally change existing `fragment_class`. |
| ClassifiedProgram schema | `classifier.rb` result contract/declaration hashes | Potential carrier for `declaration_fragment_presence`. | High; hidden schema drift can break TypeChecker goldens. |
| TypeChecker pass-through | `lib/igniter_lang/typechecker.rb`, `typed_contract` and `typed_decl` copy `fragment_class`, temporal metadata. | Downstream selected fragment consumer. | Medium/high; new fields need explicit pass-through or explicit exclusion. |
| SemanticIR emitter | `lib/igniter_lang/semanticir_emitter.rb`, contract `fragment_class`, typed nodes, stream/temporal/assumption nodes. | Emits fragment data into SemanticIR. | High if presence metadata reaches SemanticIR; report/IR goldens may drift. |
| Assembler manifest/index | `lib/igniter_lang/assembler.rb`, `fragment_summary_for`, `fragment_precedence`, `contract_index_for`, `requirements_for`. | Manifest `fragment_summary` and `contract_index` derive from contract `fragment_class`. | Critical; `.igapp` artifact hash and manifest can drift. |
| OOF/fragment registry validator | `lib/igniter_lang/oof_fragment_registry.rb` | Internal validator exists but is not root-required or compiler-integrated. | Medium; using it as authority would open a different surface. |
| Compiler orchestrator | `lib/igniter_lang/compiler_orchestrator.rb` | Pipeline composition boundary. | Medium; any adapter insertion point must be named and gated. |

---

## Hidden Mutation Risk Table

| Risk | Trigger | Impact | Required guard |
| --- | --- | --- | --- |
| Selected fragment drift | Adapter implemented as new linear precedence instead of R143 two-layer projection. | Stream and epistemic/escape goldens change. | Byte-for-byte classifier parity proof. |
| Schema drift | `declaration_fragment_presence` added to every contract without explicit migration. | TypeChecker/Emitter/goldens may drift. | Dedicated classified schema delta proof or keep data report-only. |
| Report leakage | Presence metadata appears in public diagnostics or CompilationReport unexpectedly. | Public/report surface opens. | Negative scan and report key-set proof. |
| `.igapp` drift | Presence metadata reaches SemanticIR/assembler manifest or artifact hash. | Artifact hash, manifest, contract files drift. | Assembler/semanticir parity matrix before any write. |
| OOF capability confusion | `oof` treated as loadable/capability fragment. | Failure status becomes executable surface. | Keep OOF policy guard: blocked, non-loadable, non-capability. |
| Guarded non-fragment promotion | `olap` or `progression` becomes fragment class by registry import. | Opens unapproved fragment surfaces. | Guarded non-fragment proof and validator checks. |
| PROP-036/038 leakage | Profile/source/contract diagnostics used as fragment authority. | Compiler-profile boundaries blur. | Namespace and report-only separation proof. |
| Runtime authority confusion | Fragment presence interpreted as RuntimeMachine capability. | Runtime/live behavior opens. | Bridge review and explicit no-runtime assertions. |

---

## Candidate Implementation Slices If Later Authorized

These are non-authority observations, not implementation requests.

| Candidate slice | Minimal write scope | Required proof |
| --- | --- | --- |
| Registry-data-only adapter | No classifier changes; update only proof-local/internal registry data if authorized. | Validate data remains non-live; root require/public/report surfaces closed. |
| Report-only adapter | Add derived presence to an internal/report-only artifact without changing selected fragment. | Report key-set, negative leakage scan, no `.igapp`/SemanticIR drift. |
| Live classifier adapter | Add an internal adapter in classifier while preserving selected `fragment_class`. | Byte-for-byte classified goldens; TypeChecker/Emitter/Assembler regression; no public/report/runtime drift. |
| SemanticIR/report/`.igapp` parity work | If presence becomes an artifact field. | SemanticIR, CompilationReport, manifest, contract_index, artifact_hash parity or accepted explicit delta. |

---

## Missing Evidence By Route

### Live Classifier Adapter

Missing:

- exact authorized file/write scope;
- byte-for-byte `ClassifiedProgram` parity including all selected goldens;
- explicit carrier decision for `declaration_fragment_presence`;
- TypeChecker, SemanticIR, assembler, production CLI, Stage close regression;
- proof that OOF/guarded non-fragment policies remain enforced.

### Report-Only Adapter

Missing:

- report field placement;
- public result/diagnostics key-set proof;
- negative vocabulary/leakage scan;
- proof that `pass_result`, stages, refusal paths, and `.igapp` emission are
  unchanged.

### Registry-Data-Only Adapter

Missing:

- source-of-truth decision for registry data;
- proof that registry data is not root-required and not compiler-dispatched;
- exact relationship to `OOFFragmentRegistry` internal helper;
- parity check against R144 matrix.

### SemanticIR / Report / `.igapp` Parity

Missing:

- decision whether presence metadata belongs in SemanticIR at all;
- artifact hash impact analysis;
- manifest `fragment_summary` / `contract_index` expected shape;
- assembler proof that selected fragment remains the current artifact driver;
- negative proof that no runtime/CompatibilityReport readiness is implied.

---

## Recommended Safe Next Slice

Recommended route:

```text
fragment_registry_adapter_implementation_boundary_design_v0
```

Suggested scope:

- no code implementation;
- choose one of three implementation surfaces:
  `registry-data-only`, `report-only`, or `live-classifier-adapter`;
- name exact files that may be written in the next implementation card, if any;
- define required byte-for-byte parity matrix;
- keep public/report/runtime surfaces closed unless separately approved.

Preferred first implementation direction, if Architect later opens it:

```text
registry-data-only or proof-local helper first
```

Reason: it preserves the R144 evidence without immediately introducing
ClassifiedProgram schema or artifact drift.

---

## Closed Surfaces

This map does not authorize:

- code changes;
- classifier edits;
- live fragment registry dispatch;
- public diagnostics;
- report or `CompilationReport` fields;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation;
- PROP-036 behavior mutation;
- PROP-038 behavior mutation;
- public API/CLI widening;
- loader/report or CompatibilityReport;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP production
  executors, cache, signing, deployment, production behavior, or Spark work.

---

## Handoff

[D] R145 maps implementation-review evidence for a future fragment registry
adapter. R144 is sufficient proof-local adapter parity, but not implementation
authority.

[S] The primary future risk is hidden drift from treating the adapter as a new
linear precedence rule or from leaking presence metadata into reports,
SemanticIR, `.igapp`, or runtime capability surfaces.

[T] Read-only survey only. No tests were required; no code or golden files were
changed.

[R] Next safe slice is a design-only implementation-boundary review choosing
between registry-data-only, report-only, or live-classifier-adapter routes.

[Next] Ask Compiler/Grammar + Architect to choose the implementation surface
before any code-writing card is opened.
