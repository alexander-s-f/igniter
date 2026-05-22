# Stage 3 Round 145 Status Curation

Card: S3-R145-C5-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round145-status-curation-v0
Status: done
Date: 2026-05-22

---

## Summary

R145 is closed as a status-curation round.

The Architect decision accepts the fragment registry adapter implementation
boundary as design/proof foundation only. Implementation remains held. Live
classifier dispatch remains held.

Current next-route pointer:

```text
fragment-registry-compatibility-adapter-internal-helper-boundary-proof-v0
```

That route is proof/design only. It may model a direct-require-only internal
helper API/result boundary in `experiments/` and a track doc, but it may not
create a lib helper file or wire the classifier.

## Evidence Read

- `fragment-registry-adapter-implementation-boundary-design-v0.md`
- `fragment-registry-adapter-evidence-and-risk-map-v0.md`
- `../discussions/fragment-registry-adapter-boundary-pressure-v0.md`
- `../gates/fragment-registry-adapter-implementation-boundary-decision-v0.md`
- `../current-status.md`

## R145 Outcome

| Card | Output | Status |
|------|--------|--------|
| S3-R145-C1-P1 | Adapter implementation-boundary design | done |
| S3-R145-C2-P1 | Adapter evidence and risk map | done |
| S3-R145-C3-X | Boundary pressure review | proceed-with-notes; 6/6 checks PASS; no blockers |
| S3-R145-C4-A | Architect decision | accepted-design-proof-route-next-implementation-held |
| S3-R145-C5-S | Status curation | done |

Accepted boundary:

- selected-fragment compatibility semantics are classifier-local;
- declaration-fragment vocabulary and rows may be owned by pack-as-owner
  vocabulary and/or fragment registry service data;
- `FragmentRegistryPack`, if used, means pack-as-owner vocabulary rows, not a
  service identity or optional language pack;
- profile/pack metadata may reference proof evidence or digests only;
- reports do not own adapter semantics.

Held boundary:

- implementation must wait;
- live classifier dispatch remains held;
- no `Classifier` wiring, `contract_fragment_for` replacement, or
  `classified_contract` schema change is authorized;
- SemanticIR/report/`.igapp` parity may be required as negative evidence later,
  but no SemanticIR/report/`.igapp` carrier or mutation opens now.

## Pressure Notes Resolved

- NB-1 vocabulary: use "fragment registry service" for service identity;
  `FragmentRegistryPack` only means pack-as-owner vocabulary rows if it appears.
- NB-2 first-slice divergence: next route is proof/design-only internal helper
  boundary, not registry-data implementation and not live classifier-adjacent
  implementation.
- NB-3 classifier parity: next proof/design route and any later implementation
  review must include classifier regression even if the helper remains unwired.

## Closed Surfaces

R145 does not authorize:

- implementation;
- live classifier dispatch;
- `Classifier` edits or `contract_fragment_for` replacement;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` edits;
- `classified_contract` schema changes;
- declaration-fragment presence in `ClassifiedProgram`;
- public diagnostics;
- public API/CLI widening;
- loader/report;
- `CompilationReport`, `CompilerResult`, or CompatibilityReport changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation;
- PROP-036 or PROP-038 mutation;
- runtime, Spark, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, or deployment behavior.

## Demo-Shadow Note

R145 preserves later demo usefulness as a note only. No demo lane, demo fixture,
demo artifact, Spark work, or production-facing scenario is opened by this
round.

## Current Next Route

```text
Card: S3-R146-P1
Track: fragment-registry-compatibility-adapter-internal-helper-boundary-proof-v0
Route: UPDATE
Mode: proof/design only
```

Allowed write scope, per C4-A:

```text
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/**
igniter-lang/docs/tracks/fragment-registry-compatibility-adapter-internal-helper-boundary-proof-v0.md
```

Required posture:

- no lib helper file;
- no classifier wiring;
- no parser/TypeChecker/SemanticIR/assembler/report/`.igapp` mutation;
- negative scans for root require, classifier wiring, report, `.igapp`, public,
  runtime, and Spark surfaces;
- full classifier regression even though no live helper is wired.

## Handoff

[D] R145 accepted the adapter boundary as design/proof foundation and opened
only the proof/design internal-helper boundary route.

[S] Selected-fragment compatibility is classifier-local; registry/service data
owns vocabulary rows; reports do not own adapter semantics.

[T] Status docs only. No code or tests were run by this status-curation card.

[R] Do not open implementation, live classifier dispatch, demo work, public
surfaces, reports, `.igapp`, runtime, Spark, or production from R145.

[Next] Run `fragment-registry-compatibility-adapter-internal-helper-boundary-proof-v0`
as proof/design only.
