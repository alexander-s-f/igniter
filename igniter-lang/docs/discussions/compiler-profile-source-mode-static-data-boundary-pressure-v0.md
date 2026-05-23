# Discussion: Compiler Profile Source-Mode Static-Data Boundary Pressure v0

Card: S3-R152-C2-X
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: external-pressure-reviewer
Borrowed lens: source-mode-authority-pressure
Track: compiler-profile-source-mode-static-data-boundary-pressure-v0
Route: UPDATE
Status: complete — proceed
Date: 2026-05-23

Depends on: S3-R152-C1-D
Authorized by: S3-R151-C1-D (via reentry map)

---

## Scope

Pressure-review the source-mode/static-data boundary design (S3-R152-C1-D)
for authority drift, public-carrier leakage, and premature implementation
implications. Specific checks:

1. static-data is not silently promoted to loader/report, manifest, or
   CompatibilityReport authority;
2. `finalized_internal` is not conflated with PROP-036 identity;
3. `compiler_profile_source` is not widened into discovery/defaulting;
4. `compiler_profile_contract` is not widened into runtime/refusal authority;
5. adapter helper evidence is not treated as classifier wiring authority;
6. Spark pressure does not become fixture/spec/compiler authorization;
7. next route is appropriately bounded.

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-boundary-design-v0.md`
- `igniter-lang/docs/tracks/compiler-profile-architecture-reentry-map-v0.md`
- `igniter-lang/docs/gates/prop036-cli-release-readiness-decision-v0.md`
- `igniter-lang/docs/gates/prop038-strict-refusal-canon-sync-acceptance-decision-v0.md`

---

## Scope Check 1 — Static Data Not Promoted to Loader/Report, Manifest, or CompatibilityReport Authority

The design defines static data as "a possible future compiler/profile input
shape that could describe profile/pack registry facts without loading a live
compiler pipeline or public artifact." It is explicitly kept below
implementation vocabulary.

Boundary table row for "Static profile data": forbidden implication states
"Not internal library data, not generated index, not public/default profile
discovery, not manifest identity, not compiler input, not runtime authority."

Static-data authority section enumerates "Not allowed now":

```text
create shared fixture files
create lib/ static registry data
create generated indexes
require any static data file from igniter-lang/lib/igniter_lang.rb
connect static data to parser, classifier, TypeChecker, SemanticIR, assembler,
  orchestrator, reports, .igapp, public API/CLI, runtime, Spark, production,
  or demo surfaces
```

Boundary table row for "Future profile assembly input" explicitly blocks
"No direct parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator
input. No public carrier."

The closed surfaces section independently names loader/report, CompilationReport,
CompilerResult, CompatibilityReport, `.igapp`, `.ilk`, manifest, sidecar,
artifact hash, and golden mutation as separately closed by this design.

Outcome: **PASS** — static data is not promoted to any of the named authority
surfaces. Prohibition is stated three times independently (boundary table,
static-data authority section, closed surfaces list), making promotion
materially harder to miss in a future proof.

---

## Scope Check 2 — `finalized_internal` Not Conflated With PROP-036 Identity

The design dedicates an explicit lifecycle boundary section. Accepted meaning:

```text
internal profile-assembly object accepted after packet mapping and helper
validation pass
```

Forbidden meanings are enumerated:

```text
PROP-036 profile finalization
compiler_profile_id
compiler_profile_id_source
public profile identity
manifest identity
profile discovery/defaulting/finalization
loader/report status
CompatibilityReport readiness
runtime, production, Spark, or demo readiness
```

The boundary table row for `finalized_internal` restates the PROP-036 separation
directly: "Not PROP-036 finalization, not `compiler_profile_id`, not
`compiler_profile_id_source`, not manifest/profile identity, not
runtime/production readiness."

The required proof section requires: "`finalized_internal` cannot be confused
with PROP-036 identity or manifest identity" and "Proof should assert this
distinction directly, not rely on narrative wording alone." This pre-commits the
proof to machine-assert the separation rather than relying on narrative intent.

Verification against PROP-036 gate (`prop036-cli-release-readiness-decision-v0`):
The PROP-036 gate accepts `compiler_profile_id` as manifest-carried identity and
`--compiler-profile-source PATH.json` as the bounded CLI transport for
already-finalized `compiler_profile_id_source`. `finalized_internal` does not
appear in that gate. The C1 design correctly treats PROP-036 vocabulary as
foreign to the internal assembly lifecycle.

Outcome: **PASS** — `finalized_internal` separation from PROP-036 identity is
multi-layered and includes a requirement for machine assertions in the proof.

---

## Scope Check 3 — `compiler_profile_source` Not Widened Into Discovery/Defaulting

The C1 design includes a dedicated PROP-036 section stating:

```text
PROP-036 compiler_profile_source remains an input transport boundary, not a
static-data authority boundary.
```

Accepted public surface cited verbatim from the PROP-036 gate:

```text
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

Explicit negations in the C1 design:

```text
The CLI does not discover, default, infer, normalize, or finalize profile sources.
This design does not widen that public surface.
Neither PROP-036 nor PROP-038 may be mutated by this design.
```

Boundary table row for PROP-036 `compiler_profile_source`: "Not static-data
owner, not discovery/defaulting/finalization, not named profile lookup, not
internal assembly identity. Any public or CLI widening requires separate
Portfolio-visible gate."

Cross-check against the PROP-036 gate (`prop036-cli-release-readiness-decision-v0`):
The gate accepts only `PATH.json` as an already-finalized
`compiler_profile_id_source` object; explicitly rejects inline JSON, named
profile lookup, environment/config/sidecar discovery, and CLI finalization. The
C1 design adds nothing to that surface and does not purport to.

Outcome: **PASS** — `compiler_profile_source` public surface is unchanged and
correctly scoped as input-transport-only evidence.

---

## Scope Check 4 — `compiler_profile_contract` Not Widened Into Runtime/Refusal Authority

The C1 design states: "PROP-038 `compiler_profile_contract` remains an internal
strict-refusal and contract-evidence foundation. It can inform proof constraints
for future source-mode/static-data work, but it does not become static-data
authority, public refusal authority, persisted report authority, or runtime
behavior."

Boundary table row for PROP-038: "Not static-data owner, not public/runtime
refusal widening, not persisted report/sidecar authority. Future proof may check
that static-data source-mode does not mutate contract/refusal behavior."

Required proof section includes: "PROP-036 and PROP-038 files and vocabulary are
not mutated."

Cross-check against the PROP-038 gate (`prop038-strict-refusal-canon-sync-acceptance-decision-v0`):
The canon sync acceptance records that public/runtime/production refusal remains
closed; validator output remains evidence not authority; strict terminal paths are
non-persisting; and public API/CLI, loader/report, CompatibilityReport,
RuntimeMachine/Gate 3, runtime, and production remain closed. The C1 design does
not reopen any of those surfaces.

Outcome: **PASS** — `compiler_profile_contract` is correctly referenced as
evidence input only; refusal and runtime authority remain closed.

---

## Scope Check 5 — Adapter Helper Evidence Not Treated as Classifier Wiring Authority

The C1 design includes a dedicated adapter helper reference boundary section.
Allowed uses:

```text
as prior compatibility evidence for selected-fragment projection and guarded
non-fragment handling

as optional proof-local direct-require evidence if a future proof needs to
compare static source-mode expectations against helper output
```

Explicit prohibition: "It must not reference the adapter as classifier authority."

Still closed under adapter helper evidence:

```text
root require
classifier wiring
live classifier dispatch
contract_fragment_for replacement
ClassifiedProgram fields
SemanticIR/report/.igapp parity route
public/report/artifact/runtime/Spark/production behavior
```

The required proof section further requires: "adapter helper evidence, if used,
is proof-local, direct-require-only, and does not create classifier wiring."

The reentry map (`compiler-profile-architecture-reentry-map-v0.md`) records the
adapter lane as "remain paused" with explicit rationale: the next adapter move
would be a semantic authority choice requiring broader profile architecture
context. That disposition is correctly inherited by the C1 design.

Outcome: **PASS** — adapter helper evidence is bounded as prior evidence only;
classifier wiring authority is explicitly closed at the design and proof levels.

---

## Scope Check 6 — Spark Pressure Does Not Become Fixture/Spec/Compiler Authorization

Boundary table row for Spark pressure: "External applied pressure only. May
shape future evidence questions. No Spark access, raw ids/classes, fixture
creation, spec mutation, compiler changes, production integration, or demo work.
Portfolio decision before any sanitized Spark fixture/spec-pressure route."

The closed surfaces section includes: "Spark access/integration or Spark
fixture/spec creation."

The portfolio review requirement section lists "Spark-derived fixture/spec
pressure" as explicitly requiring Portfolio review before opening.

The reentry map (`compiler-profile-architecture-reentry-map-v0.md`) records the
Spark disposition as "external pressure only" with the same prohibition list,
and correctly justifies this as information for future evidence framing without
authorizing any Spark-side work.

Outcome: **PASS** — Spark pressure is correctly held as external; no fixture,
spec, compiler, or production route is opened.

---

## Scope Check 7 — Next Route Appropriately Bounded

Recommended next route:

```text
Card: S3-R153-C1-P1
Track: compiler-profile-source-mode-static-data-boundary-proof-v0
Mode: proof-only
```

Allowed write scope is exact:

```text
igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/**
igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-boundary-proof-v0.md
```

The proof matrix is clearly bounded with 7 required areas covering static-data
status matrix, source-mode mapping, authority preservation, lifecycle
preservation, PROP checks, adapter evidence, and closed-surface scans.

The design explicitly states: "No implementation-authorization review should
open until this proof passes and a later gate accepts it."

Portfolio review requirement is explicit and comprehensive — it gates:
implementation, internal library static data, generated index work, root require,
classifier wiring, public API/CLI widening, loader/report, CompatibilityReport,
manifest, sidecar, golden, artifact hash mutation, PROP-036/PROP-038 mutation,
Spark-derived fixtures/specs, runtime, production, Ledger/TBackend, BiHistory,
stream/OLAP, cache, signing, deployment, and demo behavior.

The proof write scope correctly excludes:

```text
edits to lib/
shared fixtures
spec/proposal/canon edits
compiler/runtime/report/artifact surfaces
golden mutation
```

Outcome: **PASS** — the next route is proof-only with exact write scope, a
concrete proof matrix, and explicit Portfolio gates before any implementation or
public-surface route opens.

---

## Non-Blocking Notes

### NB-1 — Static-Data Shape Not Pre-Committed in Design

The design uses "static data" as an architectural label without pre-committing
to a field schema. The proof matrix says "static data represented only as
synthetic proof-local data" and "a clear matrix for proof fixture, internal
library data, generated index, and future profile assembly input statuses." This
correctly defers shape commitment to the proof route.

The risk is that a proof implementer might choose an overly narrow synthetic
shape that does not actually exercise the authority boundaries this design is
intended to guard. For example, a proof using only an empty hash `{}` as static
data would pass all checks trivially.

C3-A should consider requiring the S3-R153-C1-P1 proof card to commit to a
minimal synthetic static-data shape in its read-set or design questions before
running. A shape that exercises at least one pack descriptor row, one profile
candidate reference, and one pack-row ownership conflict would provide more
meaningful boundary testing. Not a blocker for the design; an instruction for
the proof card.

### NB-2 — Prior Internal Profile Assembly Gates Not Independently Verified

The C1 design references
`internal-profile-assembly-boundary-implementation-authorization-review-v0.md`
and `internal-profile-assembly-source-packet-implementation-authorization-review-v0.md`
as prior accepted authority. These are in the C1 design read set and are cited
as the basis for the `pack_descriptor_candidate` / `profile_candidate` /
internal profile-assembly source packet / `finalized_internal` vocabulary.

This pressure review does not independently verify those gate documents. The C1
design does not make new authority claims about those seams; it inherits them as
prior closed work. The design's scope is design-only and does not open
implementation, which limits the risk of incorrect inheritance.

If a future proof depends on those seams as proof infrastructure, the proof
should restate the relevant closed-surface assertions from those gates explicitly,
rather than inheriting them by reference.

### NB-3 — Proof Negative Scan for PROP-036 Vocabulary Is Required But Not Specified Precisely

The required proof section says "`finalized_internal` cannot be confused with
PROP-036 identity or manifest identity" and "Proof should assert this distinction
directly, not rely on narrative wording alone."

The C1 design does not specify which PROP-036 vocabulary tokens the negative scan
must check in proof outputs and result fields. The proof implementer must decide
whether to scan for `compiler_profile_id`, `compiler_profile_id_source`,
`finalized`, `profile_source`, and similar PROP-036 terms. If the scan is too
narrow (e.g., checking only `compiler_profile_id`), the prohibition may be
satisfied nominally while a `compiler_profile_source` echo slips through.

Recommendation for S3-R153-C1-P1: the proof card should name the exact PROP-036
vocabulary tokens that must be absent from proof result fields and closed-surface
scans. The R152-C1-D `finalized_internal` forbidden-meanings list is a good
starting point for the token set.

---

## Verdict

**proceed** — 7/7 scope checks PASS. No blockers.

The source-mode/static-data boundary design correctly:

- holds static data as design/proof candidate with no loader/report, manifest,
  or CompatibilityReport authority;
- separates `finalized_internal` from PROP-036 identity with multi-layer
  prohibition and a pre-commitment to machine assertions in the proof;
- preserves the PROP-036 `compiler_profile_source` public surface unchanged and
  explicitly blocks discovery/defaulting/finalization;
- holds `compiler_profile_contract` as internal evidence input only;
- limits adapter helper reference to compatibility evidence and proof-local
  direct-require use without classifier wiring;
- keeps Spark as external pressure only behind a Portfolio gate;
- routes to a proof-only card with exact write scope, a concrete proof matrix,
  and no implementation authorization.

Three non-blocking notes about static-data shape commitment, prior gate
inheritance, and PROP-036 vocabulary scan precision should inform the S3-R153
proof card but do not require changes to the C1 design.

---

## Acceptance Recommendation for C3-A

**Accept** the boundary design.

The C1 design is correctly bounded: it clarifies architecture without opening
implementation, public carriers, report/artifact authority, runtime surfaces, or
Spark access. All seven pressure-check categories hold clean.

C3-A should:

- accept `compiler-profile-source-mode-static-data-boundary-design-v0.md` as
  the S3-R152-C1-D design record;
- authorize S3-R153-C1-P1 proof-only route with write scope exactly as specified
  in the C1 design;
- require the proof card to commit to a minimal but non-trivial synthetic
  static-data shape before running (NB-1 guidance);
- require the proof card to name explicit PROP-036 vocabulary tokens for its
  negative scan (NB-3 guidance);
- keep all closed surfaces held: implementation, root require, classifier wiring,
  live dispatch, public API/CLI, loader/report, CompatibilityReport, `.igapp`,
  manifest, sidecar, PROP-036/PROP-038 mutation, Spark fixtures/specs, runtime,
  production, and Portfolio-gated surfaces;
- not authorize implementation or any public/report/artifact/runtime/Spark
  surface from this design acceptance.
