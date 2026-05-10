# Track: Compiler Pack Boundary Report v0

Card: S3-R31-C7-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-pack-boundary-report-v0`
Status: done
Date: 2026-05-10

---

## Goal

Prove a candidate pack decomposition for the future profile-assembled
`igniter-lang` compiler without implementing `CompilerKernel`, changing compiler
implementation, changing `.igapp` format, or authorizing migration.

---

## Sources Read

- `docs/agent-context.md`
- `docs/current-status.md`
- `docs/operating-model.md`
- `roles/research-agent.md`
- `docs/dev/compiler-profile-architecture-direction.md`
- `docs/inbox/profile-baseline-pack-pattern-analysis.md`
- `docs/tracks/compiler-profile-architecture-direction-v0.md`
- `packages/igniter-contracts/lib/igniter/contracts/assembly/*.rb`
- `packages/igniter-contracts/lib/igniter/contracts/packs/*.rb`
- `packages/igniter-extensions/lib/igniter/extensions/*_pack.rb`
- `lib/igniter_lang/parser.rb`
- `lib/igniter_lang/classifier.rb`
- `lib/igniter_lang/typechecker.rb`
- `lib/igniter_lang/semanticir_emitter.rb`
- `lib/igniter_lang/assembler.rb`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `docs/proposals/PROP-022-history-type-constructor-v0.md`
- `docs/proposals/PROP-023-stream-input-surface-v0.md`
- `docs/proposals/PROP-024-olap-point-primitive-v0.md`
- `docs/proposals/PROP-025-invariant-severity-levels-v0.md`
- `docs/proposals/PROP-028-temporal-fragment-class-v0.md`
- `docs/proposals/PROP-031-contract-modifiers-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`

---

## Current Shape

The current compiler remains a proof compiler:

```text
CompilerOrchestrator
  Parser
  Classifier
  TypeChecker
  SemanticIREmitter.emit_typed
  Assembler
```

The profile-assembled target should not be a direct mechanical split of these
classes. The contracts assembly pattern shows the safer target:

```text
CompilerKernel
  installs CompilerPacks
  validates registries and dependencies
  freezes into CompilerProfile
CompilerEnvironment
  runs compiler passes using the profile
```

The pack boundary should therefore be capability-owned, not file-owned. A pack
owns grammar rules, classifier rules, type rules, SemanticIR lowering, assembler
hooks, OOF descriptors, and fragment-class contributions for one language
capability. The kernel owns ordering, duplicate-key checks, dependency checks,
profile fingerprinting, and frozen registry snapshots.

---

## Candidate Pack Map

| Candidate pack | Owned parser responsibilities | Owned classifier responsibilities | Owned typechecker / SemanticIR responsibilities | Owned assembler / profile responsibilities | OOF / fragment ownership | Dependencies / variants |
|---|---|---|---|---|---|---|
| `CoreLanguagePack` | Module envelope, type declarations, trait/impl/contract_shape, contract body basics, `input`, `compute`, `output`, literals, refs, field access, core calls/operators, basic type refs. | Core symbol table, dependency graph, unresolved symbol detection, core contract fragment default. | Primitive type IR, expression inference, output type checks, core compute/output nodes, typed report basics. | Base `.igapp` layout, `manifest.json`, `semantic_ir_program.json`, `compilation_report.json`, `requirements.json`, core contract files. | Owns `core`; owns base `oof` handling and generic `OOF-P0`, `OOF-P1`, `OOF-P2`, `OOF-TY0` unless superseded by a narrower pack. | Mandatory baseline. Variants: proof compiler adapter first, native pack later. |
| `OOFRegistryPack` | None directly; supplies parse-diagnostic schema. | Registers OOF descriptors and stage ownership. | Registers typecheck OOF descriptors and alias handling. | Allows reports/manifests to reference OOF metadata without hardcoded tables. | Owns the OOF descriptor registry and the `oof` fragment-class policy; individual packs own their codes. | Mandatory support pack, similar to diagnostics contributors in `igniter-contracts`. May be folded into `CoreLanguagePack` for first migration. |
| `FragmentRegistryPack` | None directly. | Supplies fragment vocabulary and precedence. | Supplies node/value/contract fragment validation. | Supplies fragment summary, max-fragment computation, and manifest fragment validation hooks. | Current/proposed classes: `core`, `escape`, `stream`, `temporal`, `epistemic`, `oof`. | Mandatory support pack. Must resolve PROP-028/PROP-032 precedence before native dispatch. |
| `EscapeBoundaryPack` | `escape`, `read`, lifecycle/scoped/cardinality/schema/tenant metadata. | Escape declaration classification and pure-contract interaction surface. | Read metadata passthrough, escape-boundary validation when not temporal. | Base requirements from `escape_boundaries`, capability/effect summaries. | Owns `escape` as the coarse external-boundary class; generic escape OOFs. | Depends on Core + FragmentRegistry. Variants: metadata-only, effect-surface-aware after later PROP. |
| `TemporalPack` | `History[T]`, `BiHistory[T]` type refs already parsed by generic type parser; future coordinate syntax remains pending. | Detect temporal reads; split node fragment `temporal` from bound value `core`; select `history_read` / `bihistory_read`. | `history_at`, `bihistory_at`, temporal axes, coordinate refs, temporal access nodes, cache-key contract metadata as proof information only. | Temporal contract index, temporal nodes, temporal requirements, compatibility guard metadata for inspection-only artifacts. | Owns `temporal`; owns `OOF-H1`, `OOF-H2`, `OOF-H3`, `OOF-H4`, `OOF-BT1`..`OOF-BT4`, compatibility aliases `OOF-TM1`, `OOF-TM3`..`OOF-TM6`. | Depends on Core, EscapeBoundary, FragmentRegistry, OOFRegistry. Variants: proof-local no-executor, guarded RuntimeMachine, future Ledger/TBackend-backed. |
| `StreamPack` | `stream`, `window`, `fold_stream`, stream bound annotations `@window_bounded`, `@count_bounded`. | Stream ingress classification, fold_stream producer tracking, direct stream use rejection, missing-window checks. | Fold body CORE restriction, fold result type, stream/window/fold SemanticIR nodes. | Stream node files, stream windows in requirements, stream capability/effect summaries. | Owns `stream_input` capability; owns stream-specific use of `stream` and/or `escape`; owns `OOF-S1`..`OOF-S5`. | Depends on Core, EscapeBoundary, FragmentRegistry. Variants: metadata-only, finite replay proof, production ingress/window runner. |
| `OLAPPack` | Top-level `olap_point`, `OLAPPoint[T, dims_record]`, slice records, source/indexed/granularity clauses. | Registers OLAPPoint symbols; prevents accidental direct core treatment of analytical storage. | `olap_env`, declaration validation, slice/rollup inference, `olap_point_decl`, `olap_access_node`. | Future OLAP requirements and analytical artifact hooks; current assembler has no dedicated OLAP artifact. | Currently mostly `core`/`escape` adjacent; candidate owns `OOF-O1`..`OOF-O5` and warning `OOF-O2`. | Depends on Core; semantically depends on Temporal theorem from PROP-022 but should not require Temporal runtime. Variants: local analytical proof, distributed scatter/gather later. |
| `InvariantPack` | `invariant`, `predicate`, `severity`, `label`, `message`, `overridable_with`. | Invariant dependency refs, source metadata, author fields. | Predicate Bool checks, severity validation, output effect propagation, invariant SemanticIR nodes and invariant coverage report section. | Invariant coverage in compilation report; future requirement/audit hooks. | Does not own a separate fragment class today; contributes core nodes and OOFs. Owns `OOF-IV1`, `OOF-IV2`, `OOF-IV3`, `OOF-I1`..`OOF-I5` as they land. | Depends on Core; optional dependency on Temporal/BiHistory when override audit becomes enforced. Variants: compile-only, runtime observation, audited override. |
| `ContractModifiersPack` | Optional contract modifier prefix: `pure`, `observed`, `effect`, `privileged`, `irreversible`. | Modifier propagation, modifier-to-fragment widening, `pure` plus escape violation. | OOF-M1 propagation and typed modifier passthrough. | Manifest pass-through of `modifier`; no validation yet. | Owns `OOF-M1`; does not own a fragment class, but contributes fragment-widening rules. | Depends on Core, EscapeBoundary, FragmentRegistry. Variants: parser/pass-through, strict Effect Surface after PROP-035. |
| `AssumptionsPack` | Future `assumptions {}` block, `assumption NAME`, `uses assumptions NAME`, optional output evidence refs. | Assumption registry, contract `assumption_refs`, `uses_assumptions` classification, undeclared-assumption OOF. | Strength range check, OOF-A1 propagation, typed `assumption_refs`. | Future SemanticIR `assumption_registry`, contract `assumption_refs`, receipt propagation; no runtime resolution. | Owns proposed `epistemic`; owns `OOF-A1`; future evidence OOFs belong to a later evidence pack. | Depends on Core, ContractModifiers, FragmentRegistry, OOFRegistry. Variants: draft/spec-only, proof-local, native pack after PROP-032 implementation authorization. |
| `EvidenceObservationPack` | No new base grammar currently; observes evidence-oriented current fixtures. | Current classifier checks for ConfidenceLabel-as-Bool and EvidenceLinkedAlert gates. | Current emitter/typechecker checks evidence alert validity and confidence label misuse. | Future ObsPacket/report contributors. | Owns current `OOF-CE4`, `OOF-OS2`, `OOF-OS4`. | Depends on Core. Open whether this remains one pack or splits into Evidence + Observation Surface. |
| `PipelinePack` | Top-level `pipeline`, `step`, illegal body placement gates, scoped read parser gates. | Future pipeline symbol registration and step ref validation. | Future pipeline typed flow checks. | Future pipeline package/manifest hooks. | Owns `OOF-PG1`, `OOF-PG2`, `OOF-PG3`, `OOF-PG5`. | Depends on Core. Candidate is current-surface cleanup, not in the requested PROPs but present in parser. |

---

## Fragment Class Ownership

| Fragment class | Candidate owner | Current evidence | Open issue |
|---|---|---|---|
| `core` | `CoreLanguagePack` | Base contracts, inputs, computes, outputs. | None. |
| `escape` | `EscapeBoundaryPack` | `escape`, non-temporal `read`, current stream ingress classification, modifier widening. | Whether `escape` remains a class or becomes a legacy/coarse compatibility class once `stream`, `temporal`, and `epistemic` are first-class. |
| `stream` | `StreamPack` plus `FragmentRegistryPack` | Assembler has stream nodes and `fragment_precedence` includes `stream`; classifier currently marks stream declarations as `escape`. | Need a unified rule: stream ingress may be external, but contract class should likely become `stream`, not generic `escape`, when StreamPack is installed. |
| `temporal` | `TemporalPack` | PROP-028, classifier temporal reads, TypeChecker temporal access nodes, SemanticIR temporal nodes, assembler temporal requirements. | Parser coordinate syntax remains pending; runtime execution remains guarded. |
| `epistemic` | `AssumptionsPack` | PROP-032 draft proposes it; no implementation yet. | Unified precedence with `stream` and `escape` is unresolved. Candidate order: `oof > temporal > stream > escape > epistemic > core`, pending Architect/Compiler-Expert decision. |
| `oof` | `OOFRegistryPack` | Classifier/typechecker/emitter all block or omit IR on OOF. | Decide whether `oof` is a fragment class, status, or both in the future profile model. |

---

## OOF Code Ownership

| Code family | Candidate owner | Current / proposed stage owner |
|---|---|---|
| `OOF-P0`, `OOF-P1`, `OOF-P2`, `OOF-TY0` | `CoreLanguagePack` | Parser/emitter/typechecker generic parse/type errors. |
| `OOF-PG1`, `OOF-PG2`, `OOF-PG3`, `OOF-PG5` | `PipelinePack` | Parser today. |
| `OOF-H*`, `OOF-BT*`, `OOF-TM*` | `TemporalPack` | TypeChecker today, with compatibility aliases. |
| `OOF-S1`, `OOF-S5` | `StreamPack` | Parser today. |
| `OOF-S2`, `OOF-S4` | `StreamPack` | Classifier today. |
| `OOF-S3` | `StreamPack` | TypeChecker today. |
| `OOF-O1`..`OOF-O5` | `OLAPPack` | Parser owns current `OOF-P0` OLAP clause errors; TypeChecker owns `OOF-O3`..`OOF-O5` and warning `OOF-O2`. The report recommends migrating parser-local OLAP parse errors to OLAPPack-owned descriptors, not necessarily renaming public codes. |
| `OOF-IV*`, `OOF-I*` | `InvariantPack` | Parser and TypeChecker today. |
| `OOF-M1` | `ContractModifiersPack` | Classifier detects; TypeChecker propagates. |
| `OOF-A1` | `AssumptionsPack` | Proposed Classifier detect; TypeChecker propagate. |
| `OOF-CE4`, `OOF-OS2`, `OOF-OS4` | `EvidenceObservationPack` | Classifier/emitter today. |
| `OOF-DM3` | `CoreLanguagePack` or future `NumericTypesPack` | Parser today for Decimal scale. |

---

## Dependency Shape

```text
CoreLanguagePack
  OOFRegistryPack
  FragmentRegistryPack
  EscapeBoundaryPack
    TemporalPack
    StreamPack
  OLAPPack
  InvariantPack
  ContractModifiersPack
    AssumptionsPack
  EvidenceObservationPack
  PipelinePack
```

This is not an install-order guarantee. It is a dependency sketch. The eventual
kernel needs explicit `before`, `after`, and `requires_pack` semantics because
classifier/typechecker rule precedence matters.

---

## Replaceable Implementation Variants

| Pack | Replaceable variants |
|---|---|
| Core | `ProofCompilerAdapter`, `NativeCorePack`, later optimized parser/typechecker implementations. |
| Temporal | `MetadataOnlyTemporalPack`, `GuardedRuntimeTemporalPack`, `LedgerTBackendTemporalPack`. |
| Stream | `MetadataOnlyStreamPack`, `FiniteReplayStreamPack`, `ProductionIngressStreamPack`. |
| OLAP | `LocalFixtureOLAPPack`, `SegmentedOLAPPack`, `DistributedScatterGatherOLAPPack`. |
| Invariant | `CompileOnlyInvariantPack`, `RuntimeObservationInvariantPack`, `AuditedOverrideInvariantPack`. |
| Contract modifiers | `PassThroughModifiersPack`, `EffectSurfaceStrictPack`. |
| Assumptions | `SpecOnlyAssumptionsPack`, `ProofAssumptionsPack`, `NativeEpistemicPack`. |
| Evidence / observation | `FixtureEvidencePack`, `ObsPacketEvidencePack`, later receipt/lineage-enforced implementation. |

The profile fingerprint must distinguish the implementation variant, not only
the capability name. Two profiles that both provide `temporal` but use different
TBackend semantics are not interchangeable.

---

## Migration Order

No migration is authorized by this report. If POC closure later authorizes the
first slice, the lowest-risk order is:

1. Create a shadow `CompilerPackManifest` / `CompilerProfile` proof that describes
   the existing monolithic compiler without dispatching through packs.
2. Register OOF descriptors and fragment-class descriptors as data, generated from
   the existing hardcoded behavior, while keeping output identical.
3. Add a profile compatibility summary to proof outputs only; do not add
   `compiler_profile_id` to `.igapp` manifests yet.
4. Split `CoreLanguagePack` as a facade over the current parser/classifier/
   typechecker/emitter/assembler methods, still no behavior routing changes.
5. Extract the first real optional pack only after the shadow profile catches
   duplicate keys, missing owners, precedence conflicts, and fixture drift.

Recommended first real optional pack after the shadow profile: `ContractModifiersPack`.
It is small, recent, and already has explicit cross-stage ownership (`modifier`
field plus `OOF-M1`). It tests parser/classifier/typechecker/SemanticIR pass
registration without entangling runtime execution, TBackend, stream windows, or
OLAP scatter/gather.

---

## Migration Risk Table

| Risk | Severity | Why it matters | Mitigation |
|---|---:|---|---|
| Parser rule precedence drift | High | Optional grammar from multiple packs can change parse outcomes or diagnostics. | Ordered parser-rule registry with deterministic conflict errors before native migration. |
| Fragment precedence conflict | High | PROP-028, current assembler, and PROP-032 use related but not identical vocabularies. | Central `FragmentRegistryPack`; no pack computes max class independently. |
| OOF code drift | High | Golden fixtures and reports depend on stable public codes and stages. | OOF descriptor registry with owner/stage; prove old and new reports match byte-for-byte before switching. |
| Type environment cross-pack coupling | High | Temporal, OLAP, invariants, stream, assumptions all use shared symbol/type env. | Keep a typed accumulator protocol in kernel; packs contribute handlers, not private env mutations. |
| SemanticIR shape drift | Critical | `.igapp` and proof fixtures depend on exact JSON shape. | Shadow profile first; no `.igapp` format changes; compare canonical JSON outputs. |
| Assembler hook leakage | Critical | Artifact requirements, contract index, compatibility metadata can silently authorize runtime behavior. | Assembler core owns artifact shape; packs contribute metadata hooks that cannot change top-level format without explicit PROP. |
| Runtime authority confusion | Critical | A pack that says it provides `temporal` must not imply live TBackend execution. | Separate capability name, implementation variant, runtime authorization, and guard policy in profile metadata. |
| Dependency cycles | Medium | Pack installs may require each other through grammar/type/assembler hooks. | Reuse `igniter-contracts` style dependency and circular-dependency validation. |
| Profile fingerprint adoption timing | Medium | Adding `compiler_profile_id` too early changes manifests and compatibility checks. | Keep profile id out of `.igapp` until an explicit manifest PROP. |
| Over-splitting support packs | Medium | OOF/fragment/diagnostics packs may add ceremony before behavior is stable. | First implement as shadow registries; only split code after proven value. |

---

## Recommended First Migration Slice After POC Closure

Recommended card:

```text
Track: compiler-pack-shadow-profile-proof-v0
Goal: Produce a frozen shadow CompilerProfile for the current monolithic compiler.
Scope:
- Define pack manifests as data for Core, OOFRegistry, FragmentRegistry,
  EscapeBoundary, Temporal, Stream, OLAP, Invariant, ContractModifiers,
  EvidenceObservation, and Pipeline.
- Do not dispatch compiler passes through packs.
- Do not change SemanticIR, CompilationReport, or .igapp shape.
- Prove profile data matches existing OOF codes, fragment classes, and artifact hooks.
Acceptance:
- Existing Stage 3 close/prelive regression chain remains PASS.
- Shadow profile summary is emitted only by a proof runner or track artifact.
- Byte-for-byte compiler outputs remain unchanged.
```

Reason: this validates pack decomposition and ownership before any pass routing.
It gives the Architect and Compiler Expert concrete registry data to review
while avoiding a rewrite under active Stage 3 pressure.

---

## Open Questions

[Q1] What is the canonical unified fragment precedence once `stream`, `escape`,
`temporal`, and `epistemic` all coexist? Candidate: `oof > temporal > stream >
escape > epistemic > core`, but this needs Architect/Compiler-Expert decision.

[Q2] Is `escape` a permanent fragment class, or a compatibility bucket that
should eventually split into observed/effect/privileged/irreversible/runtime
boundary classes?

[Q3] Should `OOFRegistryPack` and `FragmentRegistryPack` be real installed packs,
or kernel services populated by packs?

[Q4] Should the first profile fingerprint include implementation variant IDs
such as `TemporalPack::MetadataOnly`, or only capability names?

[Q5] Who owns assembler extension points: a general `ArtifactAssemblyPack`, the
core assembler, or each language pack via constrained hooks?

[Q6] Should current evidence/confidence behavior become an
`EvidenceObservationPack`, or wait for the upcoming output evidence / receipt
PROP sequence?

[Q7] Should `PipelinePack` be included in the first shadow profile despite not
being part of the requested PROP list, because parser OOF-PG codes already exist?

[Q8] When should `.igapp` gain `compiler_profile_id`, and is that a manifest PROP
or a compiler-pack migration PROP?

[Q9] For OLAP, should `History[T] ≡ OLAPPoint[T, {time: DateTime}]` be expressed
as a dependency from Temporal to OLAP, from OLAP to Temporal, or as a theorem in a
shared analytical model pack?

[Q10] For assumptions, is `epistemic` strictly a fragment class, or should it be
a separate accountability axis orthogonal to effect/runtime fragments?

---

## Handoff

```text
[Igniter-Lang Research Agent]
Card: S3-R31-C7-P
Track: compiler-pack-boundary-report-v0
Status: done

[D] Decisions:
- Future pack boundaries should be capability-owned, not file-owned.
- The current compiler should first be described by a shadow profile; pass routing
  should not move until ownership and precedence are proven.
- Support registries for OOF descriptors and fragment classes are mandatory
  whether implemented as packs or kernel services.
- ContractModifiersPack is the recommended first real optional pack after a
  shadow profile because it is bounded and cross-stage.

[S] Signals:
- Pack decomposition can cover current parser/classifier/typechecker/SemanticIR/
  assembler responsibilities without changing `.igapp`.
- PROP boundaries do not map perfectly to pack boundaries; EvidenceObservation,
  Pipeline, OOFRegistry, and FragmentRegistry are needed to account for current code.
- Fragment precedence is the highest-risk design point before implementation.

[T] Tests / Proofs:
- Documentation-only no-code report.
- No compiler implementation changed.

[R] Risks:
- Parser/classifier precedence, OOF stage ownership, and assembler hooks can drift
  outputs if migrated directly.
- Runtime capability names must not imply live executor authority.
- Adding profile IDs to `.igapp` before an explicit manifest PROP would create
  format drift outside this report.

[Next]
- Route `compiler-pack-shadow-profile-proof-v0` after POC closure.
- Ask Architect / Compiler-Expert to resolve fragment precedence, OOF registry
  shape, and assembler hook ownership before any native pack migration.
```
