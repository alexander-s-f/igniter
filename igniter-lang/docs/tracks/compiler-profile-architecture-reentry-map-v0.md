# Compiler Profile Architecture Reentry Map v0

Card: S3-R151-C1-D
Agent: [Igniter-Lang Compiler/Profile Architect]
Role: compiler-profile-architect
Borrowed lens: compiler-profile-architecture
Route: UPDATE
Track: compiler-profile-architecture-reentry-map-v0
Depends on: S3-R150-C1-A, S3-R150-C2-S
Status: done
Date: 2026-05-23

---

## Decision Summary

The fragment registry adapter lane should remain paused.

The next compiler-mainline axis should be:

```text
compiler-profile-source-mode-static-data-boundary-design-v0
```

Mode:

```text
design-only
```

Reason:

The strongest next architectural value is to clarify how internal profile
assembly, profile/pack source modes, and static-data authority relate before
any adapter wiring, public/report artifact, CompatibilityReport, or runtime
surface opens.

No implementation is authorized by this map.

---

## Evidence Read

- `igniter-lang/docs/gates/compiler-mainline-strategic-vector-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round150-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/gates/fragment-registry-compatibility-adapter-helper-proof-hygiene-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/fragment-registry-compatibility-adapter-helper-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/prop036-cli-release-readiness-decision-v0.md`
- `igniter-lang/docs/gates/prop038-strict-refusal-canon-sync-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/internal-profile-assembly-boundary-implementation-authorization-review-v0.md`
- `igniter-lang/docs/gates/internal-profile-assembly-source-packet-implementation-authorization-review-v0.md`
- `igniter-lang/docs/gates/oof-fragment-registry-profile-pack-source-acceptance-authorization-review-v0.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-23-SPARK-SC-LEDGER-L3B.md`
- `/Users/alex/dev/projects/sparkcrm/.agents/spark-app/reports/PORT-2026-05-23-SPARK-ORDERS-ANALYTICS-MAP-P1.md`

---

## Architecture Axis Table

| Axis | Current authority status | Value unlocked | Implementation risk | Required prerequisite | Closed surfaces |
| --- | --- | --- | --- | --- | --- |
| Adapter continuation | Helper implementation accepted and proof-hygiene accepted; root require, classifier wiring, and live dispatch closed. | Could eventually bridge declaration-fragment presence and selected-fragment compatibility into a live route. | High: would move from internal helper to compiler authority. | Design-only authority map for carrier/owner before any wiring. | Root require, classifier wiring, live dispatch, parser, TypeChecker, SemanticIR, assembler, reports, `.igapp`, public/runtime/Spark. |
| Source-mode/static-data | Profile/pack source acceptance and internal profile assembly source packet/boundary are internally authorized/landed as proof/internal seams; no compiler/public carrier. | Clarifies the next profile architecture layer without jumping to public or runtime surfaces. | Medium: can accidentally become profile discovery/defaulting or manifest identity if wording is loose. | Design-only static-data/source-mode boundary with lifecycle and non-carrier rules. | Public API/CLI, loader/report, CompatibilityReport, `.igapp`, manifest, PROP-036 identity, PROP-038 authority, compiler pipeline, runtime, Spark. |
| PROP-036 compiler profile id/source | Bounded CLI `--compiler-profile-source PATH.json` release readiness was conditionally accepted after docs sync; discovery/defaulting/finalization remain closed. | Could later improve release/readiness and caller shape, but core transport already has a bounded surface. | Medium-high if it reopens public CLI/profile-source discovery. | Need architecture map before any new public carrier or loader/report status. | CLI widening, inline JSON, named/default profile lookup, finalization/discovery, loader/report, CompatibilityReport, `.igapp` golden migration. |
| PROP-038 contract/strict refusal | Internal-only strict refusal foundation accepted and canon-synced; public/runtime/production refusal remains closed. | Provides accepted internal refusal semantics that can inform architecture boundaries. | High if turned into public/refusal behavior, persisted reports, or runtime status too early. | Only docs/spec/proof routes unless a later gate opens public/report surfaces. | Public API/CLI, loader/report, CompatibilityReport, sidecars, `.igapp`, runtime, production, Gate 3. |
| Report/artifact/CompatibilityReport | Multiple report-only proofs exist; loader/report, CompatibilityReport sections, `.igapp` carriers, and golden migration remain closed. | Would make compiler/profile state inspectable/adoptable by downstream tools. | High: creates public-ish contract and artifact churn. | Design-only ownership and parity map after source-mode/static-data boundary. | Loader/report, CompatibilityReport, CompilerResult/CompilationReport widening, `.igapp`, `.ilk`, manifest, sidecar, golden mutation. |
| Applied Spark pressure | Spark L3B and Orders Analytics Map P1 are external applied pressure only. Spark authority remains unchanged. | Provides real-world pressure for evidence-layer framing, semantic divergence classification, and missing-evidence-first analytics. | High if raw Spark concepts become Lang vocabulary or fixtures too early. | Spark-side business classification and sanitized vocabulary/design gate before Lang fixtures/specs. | Spark code/data access, fixture creation, spec/proposal mutation, compiler changes, production integration, demo work. |

---

## Candidate Route Assessment

### Adapter Continuation

Disposition:

```text
remain paused
```

Why:

The adapter helper is useful and accepted, but the next adapter move would be a
semantic authority choice: whether selected-fragment projection should remain an
internal utility, become classifier-carried state, or feed report/artifact
parity. That decision needs broader profile architecture context first.

### Source-Mode / Static-Data Axis

Disposition:

```text
lead next
```

Why:

This axis sits between the accepted internal profile assembly work and future
compiler/profile authority. It can clarify:

- whether static internal profile data is a proof-only fixture, internal
  library data, or future profile assembly input;
- how source packets, profile candidates, pack descriptor candidates, and
  registry helpers relate;
- what remains internal-only versus what could later become loader/report or
  artifact-carried;
- how to avoid conflating `finalized_internal` with PROP-036
  `compiler_profile_id_source` or manifest identity.

This is the least risky and highest-leverage next design route.

### PROP-036 / PROP-038 Follow-Up

Disposition:

```text
do not lead next
```

Why:

PROP-036 has a bounded CLI transport and release-readiness path; the remaining
danger is public/profile-source widening. PROP-038 has an accepted internal
strict-refusal foundation and canon sync; the remaining danger is public/refusal
or report/runtime widening. Both should inform the source-mode/static-data
design, not lead as separate implementation or public-surface tracks now.

### Report / Artifact / CompatibilityReport

Disposition:

```text
do not open now
```

Why:

Report/artifact parity becomes useful only after source-mode/static-data
ownership is clean. Opening it first would force carrier shape decisions before
authority/lifecycle boundaries are stable.

### Applied Spark Pressure

Disposition:

```text
external pressure only
```

Why:

Spark L3B shows base service-call parity as an expected-match target and
override divergence as semantic business-design pressure. Orders Analytics Map
P1 shows strong call/order/service-call evidence, incomplete TradeVendor/bid
evidence, and a missing-evidence-first analytics path.

These are useful pressure signals for future evidence-layer design. They do not
authorize Spark access, fixture creation, spec mutation, compiler changes,
production integration, or demo work.

---

## Explicit Answers

### Should Adapter Continuation Remain Paused?

Yes.

Adapter continuation remains paused until a later design gate decides whether
the adapter belongs in classifier wiring, report/artifact parity, or internal
profile/source architecture. No automatic wiring follows from helper closure.

### Should Source-Mode / Static-Data Become The Next Mainline Axis?

Yes, as design-only.

This is the best next axis because it resolves the architecture gap between
internal profile assembly seams and any future compiler/profile carrier. It can
also absorb lessons from the adapter helper without opening live dispatch.

### Should PROP-036 / PROP-038 Follow-Up Lead Next?

No.

PROP-036 and PROP-038 should be inputs to the design route. They should not
lead as public/report/runtime follow-ups until source-mode/static-data
ownership is mapped.

### Should Spark Pressure Create Sanitized Fixture / Spec Pressure Now?

No.

Spark pressure remains external. L3B and Orders P1 may shape priorities, but
they do not authorize Spark fixture creation, spec/proposal mutation, compiler
changes, Spark access, production integration, or demo work.

### Is Portfolio Review Needed Before Implementation Or Public/Report/Artifact Route?

Yes.

Portfolio review is not needed for the next design-only route itself. It is
required before any later route opens:

- implementation;
- public API/CLI widening;
- loader/report or CompatibilityReport;
- `.igapp`, manifest, sidecar, or golden migration;
- Spark-derived fixtures/specs;
- production/runtime/demo behavior.

---

## Recommended Next Route

Card:

```text
S3-R152-C1-D
```

Track:

```text
compiler-profile-source-mode-static-data-boundary-design-v0
```

Route:

```text
UPDATE
```

Mode:

```text
design-only
```

Goal:

Design the source-mode/static-data boundary for compiler profile architecture,
using the accepted internal profile assembly, source packet, OOF/Fragment
Registry source acceptance, PROP-036, PROP-038, and adapter helper closures as
evidence. Recommend the next proof/design route without authorizing
implementation.

Required read set:

- `igniter-lang/docs/tracks/compiler-profile-architecture-reentry-map-v0.md`
- `igniter-lang/docs/gates/internal-profile-assembly-boundary-implementation-authorization-review-v0.md`
- `igniter-lang/docs/gates/internal-profile-assembly-source-packet-implementation-authorization-review-v0.md`
- `igniter-lang/docs/gates/oof-fragment-registry-profile-pack-source-acceptance-authorization-review-v0.md`
- `igniter-lang/docs/gates/prop036-cli-release-readiness-decision-v0.md`
- `igniter-lang/docs/gates/prop038-strict-refusal-canon-sync-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/fragment-registry-compatibility-adapter-helper-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/gates/fragment-registry-compatibility-adapter-helper-proof-hygiene-acceptance-decision-v0.md`

Allowed write scope:

```text
igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-boundary-design-v0.md
```

Required design questions:

- define static-data authority versus profile/pack source-mode authority;
- define whether static data is proof fixture, internal library data, generated
  index, or future profile assembly input;
- preserve `finalized_internal` as internal-only and not PROP-036 identity;
- define how `profile_candidate` and `pack_descriptor_candidate` relate to
  internal profile assembly source packets;
- state how adapter helper evidence may be referenced without classifier
  wiring;
- identify what proof would be required before any implementation review;
- identify what Portfolio must review before public/report/artifact or Spark
  fixture/spec routes.

Not authorized:

- implementation;
- root require;
- classifier wiring or live dispatch;
- parser, TypeChecker, SemanticIR, assembler, report, `.igapp`;
- public API/CLI;
- loader/report;
- CompatibilityReport;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, golden migration;
- PROP-036 or PROP-038 mutation;
- Spark access, fixture/spec creation, production integration;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, demo work.

---

## Closed Surfaces

Still closed:

- implementation;
- root require from `igniter-lang/lib/igniter_lang.rb`;
- classifier wiring or live classifier dispatch;
- `contract_fragment_for` replacement;
- parser, TypeChecker, SemanticIR, assembler, report, `.igapp`;
- `ClassifiedProgram` schema changes;
- public API/CLI widening;
- loader/report;
- `CompilationReport`, `CompilerResult`, CompatibilityReport;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, golden mutation;
- PROP-036 or PROP-038 mutation;
- Spark access/integration, Spark fixture/spec creation;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment;
- demo lane, demo fixture, demo artifact, or manager-facing narrative.

---

## Compact Handoff

[D] Adapter lane remains paused. Next mainline axis is source-mode/static-data
boundary design.

[S] The chosen route harvests value from accepted internal profile assembly,
OOF/Fragment Registry source acceptance, PROP-036/PROP-038, and adapter helper
closure without opening live compiler authority.

[T] Design/report only. No code or tests run.

[R] Spark L3B and Orders P1 remain applied pressure only; Portfolio review is
needed before implementation, public/report/artifact, Spark fixture/spec,
runtime, production, or demo routes.

[Next] Run `compiler-profile-source-mode-static-data-boundary-design-v0`.
