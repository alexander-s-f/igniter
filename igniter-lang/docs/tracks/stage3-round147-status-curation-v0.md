# Stage 3 Round 147 Status Curation

Card: S3-R147-C2-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round147-status-curation-v0
Status: done
Date: 2026-05-22

---

## Summary

R147 is closed as a status-curation round.

The Lang Supervisor authorization review authorizes a bounded direct-require
internal helper implementation/proof route for the fragment registry
compatibility adapter.

Implementation is authorized next, but not landed by R147.

Current next-route pointer:

```text
fragment-registry-compatibility-adapter-helper-implementation-proof-v0
```

## Evidence Read

- `../gates/fragment-registry-compatibility-adapter-helper-implementation-authorization-review-v0.md`
- `../current-status.md`
- `stage3-round146-status-curation-v0.md`

## R147 Outcome

| Card | Output | Status |
|------|--------|--------|
| S3-R147-C1-A | Helper implementation authorization review | authorized-bounded-direct-require-helper-implementation |
| S3-R147-C2-S | Status curation | done |

Authorization outcome:

- helper implementation: authorized next;
- implementation landed: no;
- route type: bounded implementation plus proof;
- root require: forbidden;
- classifier wiring: forbidden;
- live classifier dispatch: forbidden;
- demo work: not opened.

## Exact Next Allowed Route

```text
Card: S3-R147-C2-I
Track: fragment-registry-compatibility-adapter-helper-implementation-proof-v0
Route: UPDATE
Mode: bounded implementation plus proof
```

Authorized write scope:

```text
igniter-lang/lib/igniter_lang/fragment_registry_compatibility_adapter.rb
igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/**
igniter-lang/docs/tracks/fragment-registry-compatibility-adapter-helper-implementation-proof-v0.md
```

No other files may be edited.

The helper file may be created only as direct-require-only:

```text
igniter-lang/lib/igniter_lang/fragment_registry_compatibility_adapter.rb
```

It must not be required from `igniter-lang/lib/igniter_lang.rb`.

## Required Helper Shape

The first implementation slice must preserve the R146 C1 shape exactly.

Allowed Ruby API:

```text
IgniterLang::FragmentRegistryCompatibilityAdapter.project(input_hash) -> result_hash
```

The method name may be `project` only. Any different method name, class/module
name, field name, or result shape requires a separate explicit delta review
before code is written.

The helper result remains internal-only. It must not become:

- a `ClassifiedProgram` field;
- compiler input;
- report output;
- CLI/API output;
- `.igapp`, manifest, sidecar, or artifact metadata.

## Required Proof Matrix

The implementation/proof route must run and record:

- helper implementation proof runner: PASS with pinned check count;
- `classifier_pass_proof.rb`: PASS with 21 named checks;
- `contract_modifiers_proof.rb`: PASS with 20 named checks;
- `assumptions_proof.rb`: PASS with 39 named checks;
- `source_to_semanticir_fixture.rb --check-golden`: PASS with 31 named checks;
- `igapp_assembler_proof.rb`: PASS with 17 named checks;
- TypeChecker proof if applicable to touched paths;
- `invariant_severity_proof.rb`: PASS with 34 named checks.

The implementation proof must record byte-for-byte parity evidence for
classifier, contract-modifier, assumptions, SemanticIR, and `.igapp` artifacts,
plus dynamic closed-surface checks and broad negative vocabulary scans.

## Closed Surfaces

R147 does not authorize:

- any edit outside the exact write scope;
- root require from `igniter-lang/lib/igniter_lang.rb`;
- classifier wiring or live classifier dispatch;
- `contract_fragment_for` replacement;
- parser, classifier, TypeChecker, SemanticIR, assembler, report, or `.igapp`
  edits outside the authorized proof route;
- `ClassifiedProgram` schema changes;
- public API/CLI widening;
- loader/report;
- `CompilationReport`, `CompilerResult`, or CompatibilityReport changes;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden mutation;
- PROP-036 or PROP-038 mutation;
- runtime, Spark, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, or deployment behavior.

Classifier wiring and live classifier dispatch remain explicitly forbidden for
the first implementation slice. A separate later gate is required to consider
any classifier wiring.

## Demo-Shadow Note

R147 preserves later demo usefulness as a note only. No demo lane, demo fixture,
demo artifact, Spark work, or production-facing scenario is opened by this
round.

## Mandatory C1-A Requirements for C2-I

The C1-A gate promotes two previously-flagged notes to mandatory proof
requirements for the implementation card:

1. **Dynamic closed-surface checks** — The implementation proof must verify the
   helper file's existence, the root-require state, and the classifier's
   non-reference to the helper through live filesystem/content reads, not
   hardcoded static `false` values.

2. **`assumptions_proof` in regression matrix** — The assumptions proof
   (39 named checks) must be run and its result recorded as part of the
   implementation proof matrix.

---

## Round Receipt

```text
round: S3-R147
line: compiler-mainline / fragment-registry-adapter
status: closed
closed_by: S3-R147-C2-S
  doc: igniter-lang/docs/tracks/stage3-round147-status-curation-v0.md
decision: authorized-bounded-direct-require-helper-implementation
helper_implementation_status: authorized_next_not_landed
next_route: fragment-registry-compatibility-adapter-helper-implementation-proof-v0
authorized_write_scope:
  igniter-lang/lib/igniter_lang/fragment_registry_compatibility_adapter.rb
  igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/**
  igniter-lang/docs/tracks/fragment-registry-compatibility-adapter-helper-implementation-proof-v0.md
root_require_authorized: no
classifier_wiring_authorized: no
live_classifier_dispatch_authorized: no
demo_work_authorized: no
```

---

## Handoff

[D] R147 authorizes only the bounded direct-require helper
implementation/proof route. Dynamic closed-surface checks and
`assumptions_proof` are mandatory per C1-A.

[S] The implementation is authorized next but not landed. The authorized helper
is internal-only and direct-require-only; root require and classifier wiring are
forbidden. API shape is pinned to R146 C1 (no refinement without delta review).

[T] Status docs only. No code or tests were run by this status-curation card.

[R] Do not open root require, classifier wiring, live dispatch, demo work,
public surfaces, reports, `.igapp`, runtime, Spark, production, or edits outside
the exact write scope from R147.

[Next] Run `fragment-registry-compatibility-adapter-helper-implementation-proof-v0`
as S3-R147-C2-I (implementation agent, bounded implementation plus proof).
