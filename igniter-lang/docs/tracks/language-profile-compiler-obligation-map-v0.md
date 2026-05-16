# Language Profile Compiler Obligation Map v0

Card: S3-R55-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/language-profile-compiler-obligation-map-v0
Route: UPDATE
Status: done
Date: 2026-05-16

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - owns formal slot semantics, OOF ownership, and future dispatch rules.
- [Igniter-Lang Bridge Agent] - will matter later if compiler-profile status enters loader/report or package-facing surfaces.

---

## Scope

Map how accepted and active language surfaces determine compiler profile slots,
and how those slots should pressure compiler obligations before any new
infrastructure or CLI work.

Read:

- `docs/proposals/PROP-028-temporal-fragment-class-v0.md`
- `docs/proposals/PROP-031-contract-modifiers-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `docs/current-status.md`
- `docs/tracks/README.md`
- `docs/spec/`
- selected profile evidence summaries under `experiments/compiler_profile_*`,
  `experiments/contract_modifiers_*`, `experiments/assumptions_proof/`, and
  `experiments/prop037_*`

No code was changed.

---

## Current Horizon

```text
Stage 3 package surface for PROP-036 is release-ready in exact bounded CLI scope.
Profile identity is now transportable and manifest-visible, but not dispatching the compiler.
Accepted/active language surfaces already imply profile slots and obligations.
The next risk is not "can callers pass a profile source?" but "does the compiler prove the profile covers the surfaces it compiled?"
Runtime, loader/report, CompatibilityReport, dispatch migration, and golden migration remain separate authorizations.
```

---

## Profile Slot Baseline

Current proof profile slot order from `compiler_profile_slots_model` and
PROP-036:

```text
core
oof_registry
fragment_registry
escape_boundary
contract_modifiers
temporal
stream
olap
invariant
assumptions
evidence_observation
pipeline
```

Required exactly-one foundation slots:

```text
core
oof_registry
fragment_registry
escape_boundary
```

Optional surface slots:

```text
contract_modifiers
temporal
stream
olap
invariant
assumptions
evidence_observation
pipeline
```

Important current fact: `compiler_profile_id` identifies compiler
understanding. It does not grant runtime execution authority.

---

## Language Surface -> Slot -> Obligation Map

| Language surface / proposal | Relevant compiler profile slots | Current compiler components | Evidence | Missing compiler obligation | Gap kind |
| --- | --- | --- | --- | --- | --- |
| CORE contracts: input/compute/output, records, monomorphic stdlib | `core`, `oof_registry`, `fragment_registry`, `pipeline` | Parser, Classifier, TypeChecker, SemanticIREmitter, Assembler, CompilerOrchestrator | Stage 1 close, Stage 2 close, `source_to_semanticir_fixture`, `igapp_assembler_proof` | Report that the active profile's `core` slot owns the exact parser/classifier/typechecker/emitter rules used for the compile | reporting / governance |
| OOF diagnostics and stage ownership | `oof_registry`, `fragment_registry`, surface-specific slots | Classifier + TypeChecker diagnostics, CompilationReport | Stage 1/2 proofs; PROP-031 OOF-M1; PROP-032 OOF-A1; PROP-037 OOF-PR proof | Profile should enumerate which OOF namespace/rule owners are installed before compile result is trusted as "understood" | semantic / reporting |
| Fragment lattice: CORE / ESCAPE / STREAM / TEMPORAL / EPISTEMIC / OOF | `fragment_registry`, `escape_boundary`, `stream`, `temporal`, `assumptions` | Classifier, TypeChecker, SemanticIR fragment fields | Ch4; PROP-028; PROP-032; contract modifier proof | Profile obligation should prove fragment precedence table used by compiler matches profile slot identity | semantic / implementation |
| PROP-028 TEMPORAL: History/BiHistory temporal reads | `temporal`, `fragment_registry`, `escape_boundary`, `oof_registry`, `pipeline` | Classifier, TypeChecker, SemanticIREmitter, Assembler, runtime load guard | `temporal_runtime_load_guard`; runtime smoke; current-status says TEMPORAL assembly/load guard PASS | Profile should require `temporal` slot when SemanticIR contains temporal nodes, and should report missing/unsupported temporal slot before claiming profile-covered compilation | implementation / reporting |
| PROP-028 temporal cache-key metadata | `temporal`, `fragment_registry` | Assembler manifest contract_index; cache proof-local fixtures | temporal manifest/cache tracks; executor cache-key proof | Profile should bind `cache_key_schema_hint` and axis metadata ownership to the temporal slot, not to ad hoc contract file inspection | reporting / implementation |
| PROP-031 contract modifiers | `contract_modifiers`, `oof_registry`, `fragment_registry`, `escape_boundary` | Parser, Classifier, TypeChecker, SemanticIREmitter | `contract_modifiers_proof` PASS; `contract_modifiers_pack_native_boundary` PASS | Profile should require `contract_modifiers` slot when parser accepts modifier keywords or when SemanticIR emits `modifier`; pure-default normalization must be part of slot identity | implementation |
| PROP-031 effect/privileged/irreversible modifiers | `contract_modifiers`, `escape_boundary`, future Effect Surface/Profile slots | Parser/Classifer/SemanticIR descriptive only | PROP-031 experiment-pass; no Effect Surface/Profile enforcement | Compiler must not overclaim enforcement beyond OOF-M1; profile should distinguish "modifier syntax understood" from "effect authority enforced" | governance / reporting |
| PROP-032 assumptions block | `assumptions`, `fragment_registry`, `oof_registry`, `evidence_observation`, `pipeline` | Parser, Classifier, TypeChecker, SemanticIREmitter | `assumptions_proof` PASS; PROP-032 experiment-pass | Profile should require `assumptions` slot when `assumption_registry`, `uses_assumptions`, `assumption_refs`, or `epistemic` fragment appear | implementation / reporting |
| PROP-032 evidence propagation of assumption refs | `assumptions`, `evidence_observation` | SemanticIREmitter, CompilationReport; runtime receipts excluded | PROP-032 proof; current-status excludes PROP-033/runtime receipts | Profile should explicitly report that assumption refs are compile-time provenance only unless a future receipt/evidence slot is active | reporting / governance |
| Stage 2 stream T / fold_stream | `stream`, `fragment_registry`, `escape_boundary`, `oof_registry` | Parser, Classifier, TypeChecker, SemanticIREmitter, Assembler smoke | Stage 2 close; runtime smoke full coverage | Profile should require `stream` slot for `stream_input_node`, window metadata, and fold rules; missing stream slot should block profile-covered compile before assembly | implementation |
| Stage 2 OLAPPoint | `olap`, `fragment_registry`, `oof_registry` | Parser, TypeChecker, SemanticIREmitter | Stage 2 close; runtime smoke full coverage | Profile should require `olap` slot for `olap_access_node`/typed dimension handling; distributed execution remains excluded | implementation / reporting |
| Stage 2 invariant severity | `invariant`, `oof_registry`, `evidence_observation` | Parser, TypeChecker, SemanticIREmitter; proof runtime observations | Stage 2 close; invariant proof PASS | Profile should distinguish compile-time invariant lowering from production invariant persistence | reporting / governance |
| PROP-036 compiler_profile_id manifest identity | all slots as fingerprint inputs; manifest field carries unified profile id | Assembler, CompilerOrchestrator, facade, CLI transport | minimal finalization proof; assembler field proof; orchestrator/Ruby/CLI transport; R54 caller smoke PASS | Loader/report status, CompatibilityReport section, golden migration, receipt links, and dispatch migration remain unimplemented/blocked | reporting / implementation / governance |
| PROP-037 progression descriptor metadata | `pipeline`, `stream`, `evidence_observation`, `oof_registry`; possible future `progression` slot | Descriptor proof-local validators; no parser/TypeChecker/SemanticIR implementation | descriptor shape proof; descriptor OOF-PR proof; CompatibilityReport readiness proof | Decide whether progression metadata belongs in existing `pipeline` slot or requires a new `progression` slot before compiler dispatch or manifest ownership | semantic / governance |
| PROP-037 service liveness obligations | `pipeline`, possible future `progression`, `evidence_observation` | Proposal-only; report-only CompatibilityReport proof | PROP-037 accepted proposal-only | Compiler obligation is descriptor/report visibility only; scheduler/materializer/checkpoint/durable queue/runtime execution remain closed | governance / reporting |
| Ch11 profile/via system, future PROP-033/035 | future profile binding surface; interacts with `contract_modifiers`, `evidence_observation`, `pipeline` | Spec proposed only | Ch11 proposed; no implementation | Do not treat compiler profile slots as user-facing `profile via` syntax yet. Need separate grammar/TypeChecker proposal before language profiles constrain source contracts | semantic / governance |

---

## Thesis Test

Thesis:

```text
language surface -> profile identity -> compiler obligations -> infrastructure pressure
```

### Result

The thesis is directionally correct, but the current system has a missing middle
artifact.

Today:

```text
language surface appears in source/SemanticIR
  -> monolithic compiler handles it
  -> optional compiler_profile_id can be transported into manifest
  -> profile identity says "some unified profile understood this"
```

Needed before infrastructure widening:

```text
language surface appears in source/SemanticIR
  -> surface maps to required profile slots
  -> compiler proves active profile has those slots
  -> compiler emits report-only obligation coverage
  -> only then should loader/report, CompatibilityReport, dispatch, or golden migration be considered
```

The important pressure is not that profile identity exists. It is that profile
identity should become accountable for the compiler obligations triggered by the
language surfaces in a given program.

---

## Key Observations

[D] A finalized `compiler_profile_id_source` is currently an authority source
for manifest identity, not a coverage proof for every language surface used by a
program.

[S] The slot model already contains the right coarse categories for Stage 2/3
surfaces: `contract_modifiers`, `temporal`, `stream`, `olap`, `invariant`,
`assumptions`, and `pipeline`.

[S] `ContractModifiersPack` is the clearest pack-native precedent: it names
parser rules, classifier rules, TypeChecker propagation, SemanticIR fields, and
OOF ownership. Future surface packs should look like that before dispatch.

[S] PROP-037 is the first pressure that may not fit the current slot set cleanly.
`pipeline` can carry descriptor/report obligations for now, but a future
`progression` slot may be needed before parser/SemanticIR implementation.

[R] Do not jump from CLI/profile transport to loader/report or dispatch. First
prove a report-only obligation map from compiled artifacts to required profile
slots.

---

## Ranked Next-Track Recommendation

### 1. Best next bounded track: `compiler-profile-obligation-coverage-proof-v0`

Goal:

```text
Given ParsedProgram/ClassifiedProgram/TypedProgram/SemanticIRProgram plus a
finalized compiler_profile_id_source, produce a report-only
CompilerProfileObligationReport.
```

It should:

- detect surfaces used by the program: core, modifier, temporal, stream, olap,
  invariant, assumptions, progression descriptors when present;
- map each surface to required profile slots;
- verify the source's `slot_order` and `slot_assignments` contain those slots;
- report `covered`, `missing_slot`, `unsupported_surface`, or
  `profile_not_supplied`;
- prove that missing a required slot blocks "profile-covered compile" status but
  does not imply runtime readiness;
- keep assembler/loader/CompatibilityReport/dispatch unchanged.

Why this is first:

- directly tests the thesis;
- turns language surfaces into explicit profile obligations;
- stays report-only and proof-local;
- gives later loader/report and dispatch work a concrete input instead of asking
  them to infer semantics from manifests.

### 2. Then: `loader-report-compiler-profile-status-v0`

Reason:

- PROP-036 already defines loader/report status vocabulary.
- This should come after obligation coverage exists, so loader/report does not
  confuse "profile id matches" with "profile covered every language surface".

### 3. Then: `compatibility-report-compiler-profile-section-v0`

Reason:

- CompatibilityReport can consume compiler profile status and obligation coverage
  as report-only evidence.
- Must preserve the hard invariant: profile present/verified never means runtime
  readiness.

### 4. Then: `profile-driven-compiler-dispatch-proof-v0`

Reason:

- Dispatch is the behavior-changing step.
- It should wait until the obligation report proves which slots are needed and
  pack-native boundaries exist for more than ContractModifiersPack.

### 5. Later: `artifact-hash-profile-id-golden-migration-v0`

Reason:

- Golden migration should happen only after profile status and obligation
  semantics stabilize.
- Otherwise goldens risk encoding a field before its coverage meaning is
  settled.

---

## Explicit Non-Authorizations Preserved

This card does not authorize or implement:

- compiler dispatch migration;
- loader/report compiler-profile status;
- CompatibilityReport compiler-profile section;
- golden migration;
- RuntimeMachine behavior;
- Gate 3 widening;
- Ledger/TBackend;
- BiHistory live execution;
- stream/OLAP production execution;
- production cache;
- production behavior;
- CLI widening beyond the bounded `--compiler-profile-source PATH.json`
  transport;
- profile discovery/defaulting/finalization.

---

## Handoff

```text
Card: S3-R55-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/language-profile-compiler-obligation-map-v0
Status: done

[D] Decisions
- Treated profile slots as compiler-understanding obligations, not runtime
  authority.
- Identified report-only obligation coverage as the missing middle layer between
  language surfaces and infrastructure pressure.
- Kept PROP-037 progression as pipeline-slot compatible for descriptor/report
  proof, with a possible future progression slot question.

[S] Signals
- Accepted/active surfaces already map cleanly to most existing profile slots.
- ContractModifiersPack is the strongest native pack precedent.
- PROP-036 transport/manifest identity is not enough to prove surface coverage.

[T] Tests / Checks
- Docs-only map; no code tests run.
- Evidence was read from current status, proposal index, spec chapters, and
  profile/proof summaries.

[R] Recommendation
- Open `compiler-profile-obligation-coverage-proof-v0` next.
- Defer loader/report, CompatibilityReport, dispatch, and golden migration until
  obligation coverage is proven.

[Next]
- [Next] Compiler/Grammar Expert: confirm whether progression stays under
  `pipeline` for descriptor-only obligations or needs an explicit future
  `progression` slot before implementation.
- [Next] Research/Implementation later: build a proof-local
  CompilerProfileObligationReport over existing Stage 2/3 fixtures.
```
