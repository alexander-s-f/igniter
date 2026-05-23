# Compiler Profile Source-Mode Static-Data Boundary Design v0

Card: S3-R152-C1-D
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Borrowed lens: compiler-profile-architecture
Route: UPDATE
Track: compiler-profile-source-mode-static-data-boundary-design-v0
Depends on: S3-R151-C1-D, S3-R151-C2-S
Status: done
Date: 2026-05-23

---

## Design Summary

This design accepts source-mode/static-data as the next compiler/profile
architecture axis, but keeps it design-only.

Static data is not compiler authority yet. In this design it is only a bounded
design/proof candidate that may be modeled as proof-local synthetic data in a
future proof route. It is not internal library data, not a generated index, not
public profile discovery, not manifest identity, not report/artifact state, and
not runtime authority.

Profile/pack source-mode authority remains owned by the accepted internal
profile assembly model:

- pack descriptor candidates own pack-row identity, provenance, and row-local
  claims;
- profile candidates own selected pack set, selected pack order, and aggregate
  conflict policy;
- the internal profile-assembly source packet binds those authorities into
  helper envelopes;
- the internal profile assembly boundary may produce `finalized_internal` only
  as an internal assembly state.

No implementation is authorized by this design.

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-profile-architecture-reentry-map-v0.md`
- `igniter-lang/docs/tracks/stage3-round151-status-curation-v0.md`
- `igniter-lang/docs/gates/internal-profile-assembly-boundary-implementation-authorization-review-v0.md`
- `igniter-lang/docs/gates/internal-profile-assembly-source-packet-implementation-authorization-review-v0.md`
- `igniter-lang/docs/gates/oof-fragment-registry-profile-pack-source-acceptance-authorization-review-v0.md`
- `igniter-lang/docs/gates/prop036-cli-release-readiness-decision-v0.md`
- `igniter-lang/docs/gates/prop038-strict-refusal-canon-sync-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/fragment-registry-compatibility-adapter-helper-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/fragment-registry-compatibility-adapter-helper-proof-hygiene-acceptance-decision-v0.md`
- `igniter-lang/docs/current-status.md`

---

## Boundary Table

| Concept | Allowed status in this design | Forbidden implication | Next proof/design needed | Owner/authority lane |
| --- | --- | --- | --- | --- |
| Static profile data | Design/proof candidate only. May be represented in a future proof as synthetic proof-local data. | Not internal library data, not generated index, not public/default profile discovery, not manifest identity, not compiler input, not runtime authority. | Proof-only static-data/source-mode matrix that shows accepted and rejected carrier meanings without writing `lib/` data. | Igniter-Lang compiler/profile architecture. |
| Proof fixture static data | Allowed as future proof-local synthetic data inside an experiment only. | Not reusable fixture corpus, not Spark fixture, not spec/canon example, not product data. | Proof route with digest-addressed synthetic examples and closed-surface scans. | Igniter-Lang proof lane. |
| Internal library static data | Not authorized. It is a future candidate only after proof and implementation-authorization review. | Must not appear as `lib/` constants, root require, registry data file, or implicit compiler default. | Implementation-authorization review after proof proves exact data shape, owner, require stance, and non-public behavior. | Igniter-Lang architecture gate. |
| Generated index | Not authorized. It remains a future design candidate. | Not `.igapp`, manifest, sidecar, loader/report, CompatibilityReport, artifact hash, or golden migration. | Separate design-only generated-index ownership map before any proof or implementation. | Igniter-Lang artifact/report architecture with Portfolio review before opening. |
| Future profile assembly input | Allowed only as a design relationship: static data may later feed internal profile assembly through an internal profile-assembly source packet. | No direct parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator input. No public carrier. | Proof-only route proving packet mapping and lifecycle without compiler pipeline usage. | Internal profile assembly owner. |
| `profile_candidate` | Accepted internal OOF/Fragment Registry source mode. Owns selected pack set, selected pack order, and aggregate conflict policy. | Not public profile identity, not loader/report status, not manifest profile, not PROP-036 finalization. | Proof that a profile candidate can reference static proof data only through the internal packet boundary. | Profile-level authority inside internal profile assembly. |
| `pack_descriptor_candidate` | Accepted internal OOF/Fragment Registry source mode. Owns pack-row identity, provenance, and row-local claims. | Profile cannot override pack-row ownership conflicts. Duplicate row ownership rejects aggregate assembly. | Proof that selected pack descriptors remain row-authoritative when assembled from static proof data. | Pack descriptor authority inside internal profile assembly. |
| Internal profile-assembly source packet | Accepted internal constructor/test seam and carrier wording. Binds profile and pack authorities to helper envelopes. | Not public API/CLI input, not loader/report carrier, not CompatibilityReport carrier, not `.igapp`/manifest field. | Proof that any static-data source-mode model enters only through this packet shape. | Hybrid profile assembly owner. |
| `finalized_internal` | Internal assembly state after packet mapping and helper validation pass. | Not PROP-036 finalization, not `compiler_profile_id`, not `compiler_profile_id_source`, not manifest/profile identity, not runtime/production readiness. | Proof should assert the forbidden meanings remain absent in result fields and scans. | Internal profile assembly owner. |
| Adapter helper evidence | May be referenced as prior proof evidence and direct-require helper behavior. It may inform compatibility constraints. | No root require, no classifier wiring, no live classifier dispatch, no `ClassifiedProgram` schema field, no report/artifact projection. | If used in proof, reference helper output by direct require and digest evidence only. | Fragment registry adapter helper lane, currently paused. |
| PROP-036 `compiler_profile_source` | Existing bounded CLI transport for an already-finalized `compiler_profile_id_source` object. Input evidence only for this design. | Not static-data owner, not discovery/defaulting/finalization, not named profile lookup, not internal assembly identity. | Any public or CLI widening requires separate Portfolio-visible gate. | PROP-036 compiler profile source lane. |
| PROP-038 `compiler_profile_contract` | Accepted internal strict-refusal foundation and contract evidence input. | Not static-data owner, not public/runtime refusal widening, not persisted report/sidecar authority. | Future proof may check that static-data source-mode does not mutate contract/refusal behavior. | PROP-038 contract/strict-refusal lane. |
| Spark pressure | External applied pressure only. May shape future evidence questions. | No Spark access, raw ids/classes, fixture creation, spec mutation, compiler changes, production integration, or demo work. | Portfolio decision before any sanitized Spark fixture/spec-pressure route. | Spark lane owns Spark data/product authority; Lang only receives sanitized pressure. |

---

## Static-Data Authority

Static data authority is not accepted as a live authority surface.

For this design, "static data" means a possible future compiler/profile input
shape that could describe profile/pack registry facts without loading a live
compiler pipeline or public artifact. The design intentionally keeps the term
below implementation vocabulary.

Allowed now:

- use static data as an architectural design label;
- model synthetic static data in a future proof-only experiment;
- ask whether static data can be mapped into an internal profile-assembly
  source packet;
- use digest evidence in proof outputs.

Not allowed now:

- create shared fixture files;
- create `lib/` static registry data;
- create generated indexes;
- require any static data file from `igniter-lang/lib/igniter_lang.rb`;
- connect static data to parser, classifier, TypeChecker, SemanticIR,
  assembler, orchestrator, reports, `.igapp`, public API/CLI, runtime, Spark,
  production, or demo surfaces.

If static data ever becomes internal library data, that must be authorized by a
separate implementation-authorization review after a proof-only route proves
the exact data shape, owner, lifecycle, and closed-surface behavior.

---

## Source-Mode Authority

Source-mode authority is already partly accepted inside the internal
OOF/Fragment Registry helper and internal profile assembly seams.

The accepted split is:

```text
pack_descriptor_candidate
  owns row identity, provenance, and row-local claims

profile_candidate
  owns selected pack set, selected pack order, and aggregate conflict policy

internal profile-assembly source packet
  binds profile/pack authorities into helper envelopes

internal profile assembly
  validates the packet and may produce finalized_internal
```

`profile_candidate` and `pack_descriptor_candidate` do not make static data
public. They are internal source modes. They may be used by a future proof to
ask whether static proof data can be safely mapped into the accepted packet and
helper boundaries.

The profile remains unable to override pack-row conflicts. Duplicate row
ownership must reject aggregate assembly before any registry validation is
treated as successful.

---

## Lifecycle Boundary

`finalized_internal` remains internal-only.

Accepted meaning:

```text
internal profile-assembly object accepted after packet mapping and helper
validation pass
```

Forbidden meanings:

- PROP-036 profile finalization;
- `compiler_profile_id`;
- `compiler_profile_id_source`;
- public profile identity;
- manifest identity;
- profile discovery/defaulting/finalization;
- loader/report status;
- CompatibilityReport readiness;
- runtime, production, Spark, or demo readiness.

Any future proof must assert this distinction directly, not rely on narrative
wording alone.

---

## Adapter Helper Reference Boundary

The fragment registry compatibility adapter helper is accepted as a
direct-require-only internal helper. The adapter lane remains paused.

This source-mode/static-data design may reference adapter helper evidence in
two ways:

- as prior compatibility evidence for selected-fragment projection and guarded
  non-fragment handling;
- as optional proof-local direct-require evidence if a future proof needs to
  compare static source-mode expectations against helper output.

It must not reference the adapter as classifier authority.

Still closed:

- root require;
- classifier wiring;
- live classifier dispatch;
- `contract_fragment_for` replacement;
- `ClassifiedProgram` fields;
- SemanticIR/report/`.igapp` parity route;
- public/report/artifact/runtime/Spark/production behavior.

---

## PROP-036 And PROP-038 Input Boundary

PROP-036 `compiler_profile_source` remains an input transport boundary, not a
static-data authority boundary.

The accepted PROP-036 surface is still only:

```text
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

`PATH.json` is an already-finalized `compiler_profile_id_source` object. The
CLI does not discover, default, infer, normalize, or finalize profile sources.
This design does not widen that public surface.

PROP-038 `compiler_profile_contract` remains an internal strict-refusal and
contract-evidence foundation. It can inform proof constraints for future
source-mode/static-data work, but it does not become static-data authority,
public refusal authority, persisted report authority, or runtime behavior.

Neither PROP-036 nor PROP-038 may be mutated by this design.

---

## Required Proof Before Implementation Review

Before any implementation-authorization review for static-data/source-mode
work, a proof-only route must show:

- static data represented only as synthetic proof-local data;
- no shared fixture corpus, Spark fixture, spec/canon example, or product data;
- a clear matrix for proof fixture, internal library data, generated index, and
  future profile assembly input statuses;
- `profile_candidate` and `pack_descriptor_candidate` mapping into an internal
  profile-assembly source packet without public carrier leakage;
- pack-row authority remains primary for row identity and provenance;
- profile authority remains limited to selected pack set/order/conflict policy;
- duplicate row ownership rejects aggregate assembly;
- `finalized_internal` cannot be confused with PROP-036 identity or manifest
  identity;
- PROP-036 and PROP-038 files and vocabulary are not mutated;
- adapter helper evidence, if used, is proof-local and not classifier wiring;
- root require, classifier wiring, live dispatch, report/artifact, public
  API/CLI, runtime, Spark, production, and demo surfaces remain closed;
- proof outputs include digest evidence and negative closed-surface scans.

---

## Recommended Next Route

Recommended card:

```text
S3-R153-C1-P1
```

Track:

```text
compiler-profile-source-mode-static-data-boundary-proof-v0
```

Mode:

```text
proof-only
```

Why:

The design boundary is now clear enough to test the model with synthetic
proof-local data, but not clear enough to authorize `lib/` static data, generated
indexes, compiler integration, public/report carriers, or artifact mutation.

Allowed future proof write scope:

```text
igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/**
igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-boundary-proof-v0.md
```

The proof may create synthetic data only inside the proof experiment. It must
not create shared fixtures, edit `lib/`, edit specs/proposals/canon, or mutate
compiler/runtime/report/artifact surfaces.

Required proof matrix should include:

| Proof area | Required result |
| --- | --- |
| Static-data status matrix | Proof fixture accepted as proof-local only; internal library data, generated index, public/default discovery, report/artifact, runtime, and Spark statuses rejected. |
| Source-mode mapping | `profile_candidate` and `pack_descriptor_candidate` map to internal profile-assembly source packet semantics without public carrier leakage. |
| Authority preservation | Pack-row authority and profile-level authority preserve the accepted split; duplicate ownership rejects aggregate assembly. |
| Lifecycle preservation | `finalized_internal` remains internal-only and never becomes PROP-036 identity, manifest identity, or public finalization. |
| PROP checks | PROP-036 and PROP-038 docs/code/proposal files remain unmodified. |
| Adapter evidence | Any adapter helper use is proof-local, direct-require-only, and does not create classifier wiring. |
| Closed-surface scans | Root require, classifier wiring, live dispatch, report/artifact, CompatibilityReport, `.igapp`, public API/CLI, runtime, Spark, production, and demo vocabulary remain absent outside authorized proof outputs. |

No implementation-authorization review should open until this proof passes and
a later gate accepts it.

---

## Portfolio Review Requirement

Portfolio review is not required before the recommended proof-only route if it
stays inside the proof boundary above.

Portfolio review is required before any later route opens:

- implementation;
- internal library static data;
- generated index work;
- root require;
- classifier wiring or live classifier dispatch;
- parser, TypeChecker, SemanticIR, assembler, report, or `.igapp` work;
- public API/CLI widening;
- loader/report or CompatibilityReport;
- manifest, sidecar, golden, or artifact hash mutation;
- PROP-036 or PROP-038 mutation;
- Spark-derived fixture/spec pressure;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo behavior.

---

## Closed Surfaces

This design does not authorize:

- implementation;
- root require from `igniter-lang/lib/igniter_lang.rb`;
- classifier wiring or live classifier dispatch;
- `contract_fragment_for` replacement;
- parser, TypeChecker, SemanticIR, assembler, report, or `.igapp` edits;
- `ClassifiedProgram` schema changes;
- public API/CLI widening;
- loader/report;
- `CompilationReport`, `CompilerResult`, or CompatibilityReport changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation;
- shared fixtures;
- generated indexes;
- internal library static data;
- PROP-036 or PROP-038 mutation;
- Spark access/integration or Spark fixture/spec creation;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo behavior.

---

## Handoff

[D] Source-mode/static-data boundary design is complete.

[S] Static data is design/proof candidate only. Profile/pack source modes and
internal profile assembly remain the authority layer. PROP-036 and PROP-038 are
inputs, not owners. Adapter helper evidence may inform proofs without reopening
classifier wiring.

[T] Documentation track only. No code or tests were run.

[R] Do not open implementation, `lib/` static data, generated indexes,
classifier wiring, public/report/artifact surfaces, Spark fixtures/specs,
runtime, production, or demo work from this design.

[Next] Run `compiler-profile-source-mode-static-data-boundary-proof-v0` as
S3-R153-C1-P1, proof-only.
