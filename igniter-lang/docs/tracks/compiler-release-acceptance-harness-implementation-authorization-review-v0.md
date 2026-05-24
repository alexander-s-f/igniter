# Compiler Release Acceptance Harness Implementation Authorization Review v0

Card: S3-R161-C1-A  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Route: UPDATE  
Track: `compiler-release-acceptance-harness-implementation-authorization-review-v0`  
Status: done  
Date: 2026-05-24

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round160-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-acceptance-harness-design-v0.md`
- `igniter-lang/docs/discussions/compiler-release-acceptance-harness-design-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-and-ruby-hygiene-decision-v0.md`
- `igniter-lang/docs/tracks/poc-mvp-live-touch-v0.md`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/poc_mvp_live_touch_summary.json`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/compile_transcript.json`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/runtime_trace.json`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/*/*.igapp/compatibility_metadata.json`

---

## Decision

Decision:

```text
authorize bounded proof-local harness runner implementation
do not authorize RC evidence gathering
do not authorize release execution
do not authorize public claims
```

The authorized implementation may prove the harness runner shape and produce
harness-local proof outputs. Those outputs are not official release-candidate
evidence.

---

## Mandatory R160 Notes

The five R160 implementation-gate notes are answered as follows.

| Note | Decision |
| --- | --- |
| NB-1: multi-input diversity | The positive corpus multi-input case must exercise input diversity. It must include either mixed input types, a computed node depending on more than two inputs, or an accepted conditional/branch. A simple three-integer summation is insufficient. |
| NB-2: normalization failure specimen | Use both interpretations if feasible: a fixture-based normalization specimen and a two-run stability check. If only one can be implemented without widening scope, choose fixture-based normalization and record the two-run check as a follow-up. |
| NB-3: `compatibility_metadata.json` | Current POC `.igapp` outputs include `compatibility_metadata.json` for all four modules. Harness may treat this artifact as required for generated positive `.igapp` outputs. It must check shape only: `kind`, `format_version`, `canonical_artifact`, and metadata presence. It must not treat this as a public CompatibilityReport. |
| NB-4: `claimed_surfaces` | Required in `release_scope`. The summary must enumerate positive scope, not only non-claims. |
| NB-5: FAIL/HOLD precedence | FAIL takes precedence over HOLD when both triggers appear in one run. The summary may include both `failed_checks` and `hold_reasons`, but top-level `status` must be `FAIL`. |

---

## Authorized Write Scope

Only the following paths may be created or edited:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/**
igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-proof-v0.md
```

No other files may be edited.

The implementation must not mutate:

- `igniter-lang/experiments/poc_mvp_live_touch_v0/**`;
- existing `.igapp` outputs;
- tracked goldens;
- compiler source files;
- CLI/API files;
- root require files;
- docs/spec/proposals/canon files outside the proof track above.

---

## Required Runner Shape

Required runner path:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb
```

Allowed local structure:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/README.md
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/**
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/negative/**
igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/**
igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/**
```

Runner mode:

```text
--mode acceptance
```

The runner must use existing compiler CLI/API/load-path surfaces only. It must
not add public commands, flags, APIs, require paths, or runtime surfaces.

---

## Corpus Fixture Policy

Positive corpus:

- at least five compile units;
- at least one Add-style baseline;
- at least one POC-derived synthetic micro-app group;
- at least one boolean gate/conjunction case;
- at least one integer arithmetic case;
- at least one input-diverse multi-input case as defined above;
- include accepted branch/conditional coverage only if existing accepted
  grammar/compiler behavior supports it without new semantics.

If branch/conditional coverage cannot be included without new semantics, the
runner must report a HOLD reason, not silently treat module count as sufficient.

Negative/refusal corpus:

- parse refusal;
- unresolved symbol refusal;
- type mismatch refusal;
- CLI profile-source bad path;
- CLI profile-source malformed JSON;
- semantic `compiler_profile_source.*` refusal;
- normalization failure specimen;
- closed-surface leakage scan.

PROP-038 strict refusal remains conditional. Do not include it unless it can be
done with existing internal-only behavior and without public API/CLI widening.

Profile-source fixtures:

- may include a harness-local finalized profile-source JSON fixture for the
  exact PROP-036 bounded CLI transport;
- may include malformed/bad-path fixtures for preflight refusal tests;
- must not implement profile discovery, defaulting, finalization, inline JSON,
  named profile lookup, env/config lookup, or sidecar lookup.

---

## Output Directory And Artifact Policy

All generated outputs must live under:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/**
```

Required output:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json
```

Allowed generated outputs:

- harness-local `.igapp` directories;
- command transcripts;
- normalized artifact snapshots;
- proof-local trace/linkage JSON;
- stderr/stdout captures for refusal/preflight cases.

Generated outputs must not be called official release-candidate evidence. They
are proof-local harness implementation evidence only.

---

## Required Summary Shape

The machine-readable summary must include:

```text
kind
format_version
track
status
decision
release_scope.scope
release_scope.claimed_surfaces
release_scope.public_claims_authorized: false
release_scope.production_runtime_authorized: false
corpus
command_matrix
artifact_checks
normalization
warnings_policy
closed_surface_scan
non_claims
failed_checks
hold_reasons
artifacts
```

Required `release_scope.claimed_surfaces` minimum:

```text
repo_local_compiler_cli_positive_compile
repo_local_compiler_cli_refusal
repo_local_compiler_api_positive_compile
repo_local_load_path_smoke
proof_local_runtime_smoke
```

If a surface is not exercised by the proof-local runner, it must not appear in
`claimed_surfaces`.

Status precedence:

```text
FAIL > HOLD > PASS
```

---

## Command Matrix

Required proof commands:

```text
ruby -c igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb
ruby igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb --mode acceptance
```

The runner itself must exercise or record command outcomes for:

```text
ruby -I igniter-lang/lib -e 'require "igniter_lang"; abort unless IgniterLang.respond_to?(:compile)'
igniter-lang/bin/igc compile POSITIVE_SOURCE --out HARNESS_OUT/POSITIVE.igapp
igniter-lang/bin/igc compile POSITIVE_SOURCE --out HARNESS_OUT/POSITIVE_PROFILE.igapp --compiler-profile-source FINALIZED_PROFILE_SOURCE.json
igniter-lang/bin/igc compile NEGATIVE_SOURCE --out HARNESS_OUT/NEGATIVE.igapp
IgniterLang.compile(POSITIVE_SOURCE, out: HARNESS_OUT/API_POSITIVE.igapp)
```

If an existing CLI/API command shape differs in the current repo, the
implementation may adapt to the existing accepted command shape and must record
the delta in the proof track. It may not add new command shapes.

---

## Proof Matrix

The implementation proof must verify:

- runner syntax check passes;
- runner execution completes;
- all generated outputs remain under the harness experiment directory;
- summary shape contains all required fields;
- `release_scope.claimed_surfaces` is present and accurate;
- FAIL-over-HOLD precedence is implemented;
- multi-input case exercises input diversity;
- normalization specimen policy is implemented and reported;
- `compatibility_metadata.json` is found and checked as metadata shape only;
- warnings arrays/counts are present/empty or produce HOLD if unexpected;
- negative/refusal cases assert no forbidden `.igapp` writes;
- closed-surface scan executes with the R160 token list and exceptions;
- no public API/CLI/root require/compiler pipeline files changed;
- Spark/Ruby terms appear only in allowed non-claim/future-pressure contexts.

---

## Explicit Answers

Does this implementation gather RC evidence?

```text
No. It proves the harness runner and produces proof-local harness outputs only.
```

May generated outputs be called release-candidate evidence?

```text
No. They are proof-local harness implementation evidence until a later gate
opens official RC evidence gathering.
```

Does analyzer/tracer/visualizer open?

```text
No public analyzer/tracer/visualizer opens. Internal machine-readable
summary/artifact linkage is allowed only as harness proof output.
```

Do Spark/Ruby become authorizing inputs?

```text
No. Spark remains sanitized future fixture/design pressure only. Ruby remains
held until stable Lang RC export fixture exists.
```

---

## Closed Surfaces

This authorization does not open:

- official RC evidence gathering;
- release execution;
- public release or public demo claims;
- public analyzer/tracer/visualizer implementation or command/UI;
- public API/CLI widening;
- root require changes;
- parser, classifier, TypeChecker, SemanticIR, or assembler changes;
- loader/report;
- `CompilationReport`, `CompilerResult`, or `CompatibilityReport` widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration
  outside harness-local generated output;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

---

## Exact C2-I Boundary

```text
Card: S3-R161-C2-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: compiler-release-acceptance-harness-implementation-proof-v0
Route: UPDATE
Depends on:
- S3-R161-C1-A
- S3-R161-C2-S
```

Allowed write scope:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/**
igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-proof-v0.md
```

The implementation must follow this authorization decision exactly. If the
runner requires code/library changes outside the allowed scope, C2-I must stop
and return a hold/blocker instead of widening scope.
