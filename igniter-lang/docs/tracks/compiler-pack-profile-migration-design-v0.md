# Track: Compiler Pack/Profile Migration Design v0

Card: LANG-R138-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R137-D1, LANG-R136-P1
Track: `compiler-pack-profile-migration-design-v0`
Status: done
Date: 2026-05-22

---

## Goal

Perform CP1 profile/pack migration design: define future `CompilerProfile`,
`CompilerPack`, and internal adapter responsibilities and migration order
without implementing anything.

This track does not authorize root require, compiler pipeline adapter, public
API/CLI, loader/report, CompatibilityReport, `.igapp`, PROP-036, PROP-038,
runtime, production, or Spark behavior.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]` — owns proof-only migration maps and parity
  harnesses if this design is pressure-tested.
- `[Igniter-Lang Bridge Agent]` — owns pressure before external carriers open.
- `[Igniter-Lang Meta Expert]` — may route this as CP1 evidence, not as
  implementation authority.

---

## Evidence Read

- `docs/tracks/compiler-pack-profile-migration-checkpoint-design-v0.md`
  (LANG-R137-D1)
- `docs/tracks/internal-profile-assembly-carrier-map-v0.md` (LANG-R136-P1)
- `docs/dev/compiler-profile-architecture-direction.md`
- `docs/tracks/compiler-pack-boundary-report-v0.md`

No code was edited. No proof commands were required for this design-only slice.

---

## Current Fixed Point

The accepted internal evidence chain remains:

```text
InternalProfileAssemblySourcePacket
  -> InternalProfileAssembly.assemble(...)
  -> internal_profile_assembly_result
  -> internal_profile_assembly_carrier_map
```

This chain is evidence only. It is not a live `CompilerProfile`, not
`compiler_profile_id`, not `.igapp`, not `CompilationReport`, and not runtime
readiness.

The current proof compiler remains monolithic:

```text
CompilerOrchestrator
  Parser
  Classifier
  TypeChecker
  SemanticIREmitter.emit_typed
  CompilationReport.enrich
  optional compiler_profile_contract_validation report-only annotation
  optional internal-only strict terminal
  Assembler
```

No dispatch migration is open.

---

## Candidate CompilerProfile Responsibilities

A future `CompilerProfile` should be a frozen internal compiler-surface
snapshot, not a public runtime capability.

Candidate responsibilities:

| Responsibility | Meaning |
| --- | --- |
| Installed pack set | Records which compiler packs are selected and in what canonical order. |
| Pass contribution index | Records declared parser/classifier/TypeChecker/SemanticIR/assembler contributions without executing them by default. |
| OOF descriptor index | Records diagnostic ownership metadata and aliases without changing emitted diagnostics. |
| Fragment registry view | Records fragment rows and precedence candidates without independently computing max fragment class yet. |
| Capability vocabulary | Records compiler capability labels separately from runtime capability/readiness. |
| Dependency closure | Records pack dependency satisfaction and conflicts. |
| Digest inputs | Defines deterministic material for future profile identity proofs. |
| Non-authority metadata | States that the profile is not `.igapp`, not `compiler_profile_id` unless PROP-036 later authorizes derivation, and not runtime readiness. |

Out of scope:

- public API/CLI source shape;
- manifest identity;
- loader/report or CompatibilityReport fields;
- RuntimeMachine capability;
- production execution;
- strict-refusal authority.

Design constraint:

```text
CompilerProfile may summarize compiler surface, but may not drive live pass
dispatch until a later adapter implementation and parity gate explicitly open.
```

---

## Candidate CompilerPack / Pack Descriptor Responsibilities

A future `CompilerPack` should be a declarative contribution unit.

Candidate responsibilities:

| Responsibility | Meaning |
| --- | --- |
| Stable pack ref | Names pack identity independent of implementation class. |
| Slot name | Maps to a profile slot such as `core_language`, `temporal`, `stream`, or support boundary. |
| Provided surfaces | Declares parser/classifier/TypeChecker/SemanticIR/assembler contributions as metadata. |
| OOF ownership | Declares owned public OOF descriptors, aliases, and support markers. |
| Fragment ownership | Declares fragment rows or guarded non-fragment rows. |
| Dependencies | Declares required packs, ordering constraints, and incompatible packs. |
| Capability labels | Declares compiler capability labels separately from runtime execution capability. |
| Proof anchors | Names proof fixtures/goldens that establish current behavior. |
| Implementation variant | Separates proof-local, memory, ledger-backed, audited, or production variants from stable pack capability name. |

Pack descriptors should not:

- mutate parser/classifier/typechecker/emitter/assembler behavior by being
  present;
- register live handlers without an implementation gate;
- imply runtime executor availability;
- write `.igapp` or manifest metadata;
- alter PROP-036 or PROP-038 behavior.

---

## Internal Adapter Decision

Options:

| Adapter option | Meaning | Verdict |
| --- | --- | --- |
| Pure projection | Project `internal_profile_assembly_result` / carrier map into a future profile/pack migration model without changing behavior. | Best first proof/design candidate. |
| Validation wrapper | Re-run profile/pack registry validation and expose validity as an internal result. | Later candidate; risks duplicating `InternalProfileAssembly` unless scoped tightly. |
| Pack assembly accumulator | Mutable kernel-like object that installs pack descriptors and finalizes a profile. | Hold; too close to live CompilerKernel implementation. |
| Held | Stop after R136 carrier map. | Safe fallback if no migration proof is desired. |

Decision:

```text
Future internal adapter should be pure projection first, and remain
direct-require-only if ever implemented.
```

The adapter should not:

- root require itself;
- read files or manifests;
- call compiler passes;
- register handlers;
- produce `compiler_profile_id`;
- write reports, `.igapp`, sidecars, or goldens;
- expose public API/CLI behavior.

Candidate proof-only name:

```text
internal_profile_migration_projection
```

Do not implement it in this card.

---

## Pass-Boundary Ownership

| Boundary | Future candidate owner | Migration stance |
| --- | --- | --- |
| Parser | `CoreLanguagePack` plus optional parser rule contributors | Design only; parser precedence is high risk. Require shadow rule registry and parse-golden parity before live dispatch. |
| Classifier | `CoreLanguagePack`, `OOFRegistryPack`, `FragmentRegistryPack`, optional pack classifiers | Design only. Preserve OOF/fragment behavior; no pack computes max class until fragment registry parity is proven. |
| TypeChecker | `CoreLanguagePack` plus optional type rule contributors | Design only. Require typed accumulator protocol and golden parity before handler extraction. |
| SemanticIR | `CoreLanguagePack` plus optional lowering contributors | High-risk. Require byte-for-byte SemanticIR and CompilationReport parity before any live emitter adapter. |
| Assembler | `CoreLanguagePack` assembler plus constrained pack artifact hooks | Closed. Preserve `report_for_assembly` isolation and no `.igapp` mutation. |
| OOF registry | `OOFRegistryPack` support boundary | Can be shadow/proof data first. Must not centralize or change public diagnostics yet. |
| Fragment registry | `FragmentRegistryPack` support boundary | Can be shadow/proof data first. Must preserve current precedence and guarded non-fragments. |

Support boundaries:

| Boundary | Owner stance |
| --- | --- |
| `CompilerProfileContractPack` | Support/evidence boundary only; not language pack dispatch authority. |
| Strict terminal | Orchestrator/status boundary; not pack validator authority. |
| Runtime smoke | Runtime proof harness, not compiler pack ownership. |
| Public API/CLI | Closed unless Bridge + implementation gate open it. |

---

## Migration Order

Recommended order before any live compiler pipeline adapter:

1.  Freeze a proof-only profile/pack migration model.
2.  Prove the pure projection from `internal_profile_assembly_carrier_map` to
    the migration model.
3.  Prove OOF and fragment registry parity as data, with no diagnostic output
    changes.
4.  Prove pass-boundary ownership maps for parser/classifier/TypeChecker/
    SemanticIR/assembler against current fixtures.
5.  Design an internal direct-require-only adapter surface if still needed.
6.  Request implementation authorization for exactly one internal adapter file,
    not root-required.
7.  Run parity/regression matrix after implementation.
8.  Only after parity, consider separate Bridge pressure for public/report/
    `.igapp` carriers.

Do not begin with:

- root require;
- compiler pipeline adapter;
- public API/CLI;
- loader/report;
- CompatibilityReport;
- `.igapp` or manifest mutation.

---

## Rollback And Hold Points

| Hold point | Trigger | Action |
| --- | --- | --- |
| HP1 projection ambiguity | Projection cannot distinguish profile evidence from `compiler_profile_id`. | Hold; route PROP-036 clarification before proof. |
| HP2 pack ownership ambiguity | A pass contribution has multiple plausible pack owners. | Hold; produce ownership pressure table before implementation. |
| HP3 fragment precedence ambiguity | Fragment registry proof cannot preserve current classifier behavior. | Hold; no classifier adapter. |
| HP4 OOF code drift | Registry data changes emitted diagnostic code/message/stage. | Hold; no OOF registry migration. |
| HP5 SemanticIR/report drift | Projection or adapter changes SemanticIR or CompilationReport goldens. | Hold; no pipeline adapter. |
| HP6 PROP-038 leakage | Profile migration tries to use validator diagnostics as authority. | Hold; route PROP-038 separation review. |
| HP7 external carrier pressure | Public/report/manifest/runtime carrier is requested. | Hold implementation; route Bridge pressure first. |

Rollback default:

```text
Return to R136 carrier-map evidence-only state.
```

---

## PROP-036 Separation

This design preserves:

- no implicit `compiler_profile_id` derivation;
- no manifest identity mutation;
- no `.igapp` schema mutation;
- no source contract widening;
- no loader/report status behavior.

Future profile digests may be designed as proof material, but they must not be
called or used as `compiler_profile_id` without PROP-036 authority.

---

## PROP-038 Separation

This design preserves:

- no validator API/result-shape changes;
- no report-only behavior mutation;
- no strict-refusal behavior mutation;
- no nested diagnostics movement;
- no `CompilerResult` or public key-set changes;
- no compile refusal changes.

Compiler profile migration may reference PROP-038 as a support boundary, but it
must not treat `compiler_profile_contract.*` diagnostics as OOF descriptors or
as pack dispatch authority.

---

## Closed Surfaces

Still closed:

- code implementation;
- root require;
- compiler pipeline adapter;
- parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator changes;
- public API/CLI;
- loader/report;
- CompatibilityReport;
- `.igapp`, `.ilk`, manifest, sidecar, and golden mutation;
- PROP-036 behavior mutation;
- PROP-038 behavior mutation;
- runtime, production, Spark, Ledger/TBackend, Gate 3, cache, signing, and
  deployment behavior.

---

## Recommended Next Route

Recommendation:

```text
proof next
```

Suggested next card:

```text
internal-profile-migration-projection-proof-v0
```

Goal:

```text
Proof-only projection from internal_profile_assembly_carrier_map to a
profile/pack migration model, with anti-confusion checks for CompilerProfile,
compiler_profile_id, PROP-036, PROP-038, .igapp, report, and runtime readiness.
```

Bridge pressure is not first unless an external carrier is requested. Live
implementation review should remain held until the projection proof and
ownership/parity maps are accepted.

---

## Handoff

[D] CP1 design completed: future `CompilerProfile` is a frozen compiler-surface
snapshot; future `CompilerPack` is a declarative contribution unit; the first
adapter candidate should be pure projection, not validation wrapper or pack
assembly accumulator.

[S] Pass-boundary ownership remains design-only. Parser/classifier/TypeChecker/
SemanticIR/assembler migration requires OOF, fragment, and golden parity before
any live dispatch.

[T] No tests were run; this was a design-only track with no code changes.

[R] Recommend proof-only `internal-profile-migration-projection-proof-v0`.
Hold implementation review and Bridge pressure unless an external carrier is
proposed.

[Next] Architect can open projection proof, request ownership pressure for a
specific pass boundary, or hold at CP1 design.
