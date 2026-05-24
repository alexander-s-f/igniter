# Compiler Release Readiness Map v0

Card: S3-R159-C1-D
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Track: compiler-release-readiness-map-v0
Route: UPDATE
Status: done
Date: 2026-05-24

---

## Summary

The accepted `poc-mvp-live-touch-v0` proof is strong enough to become
release-readiness seed evidence, but it is not yet release-candidate evidence.

First compiler release-candidate readiness should be defined around a small,
machine-readable acceptance boundary:

- positive compile coverage across a tiny coherent corpus;
- negative/refusal coverage across parse, typecheck, profile-source, and strict
  refusal surfaces;
- normalized `.igapp`, `compiler_result`, `compilation_report`, compile
  transcript, and proof-local runtime-trace comparison;
- CLI/API/load-path/package smoke;
- public documentation that states the exact release scope and preserves closed
  runtime, production, Spark, report, artifact, and deployment surfaces.

Analyzer/tracer/visualizer belongs next as design-only acceptance-harness shape
work, not as implementation and not as a release-blocking UI/tooling
requirement.

Recommended immediate next boundary:

```text
S3-R159-C2-X
Track: compiler-release-readiness-map-pressure-v0
Mode: pressure review only
```

If pressure accepts this map, the next compiler-release route should be a
design-only acceptance harness boundary, not implementation or release
execution.

---

## Evidence Read

- `igniter-lang/docs/tracks/fractal-supervisor-packet-synthesis-v0.md`
- `igniter-lang/docs/tracks/compiler-release-poc-acceptance-fractal-seed-v0.md`
- `igniter-lang/docs/tracks/poc-mvp-live-touch-v0.md`
- `igniter-lang/docs/gates/poc-mvp-live-touch-scope-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round157-status-curation-v0.md`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/poc_mvp_live_touch_summary.json`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/compile_transcript.json`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/runtime_trace.json`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/gates/prop036-cli-release-readiness-decision-v0.md`
- `igniter-lang/docs/tracks/prop036-cli-release-readiness-docs-sync-v0.md`
- `igniter-lang/docs/tracks/prop036-cli-release-confidence-smoke-v0.md`
- `igniter-lang/docs/tracks/compiler-package-boundary-v0.md`
- `igniter-lang/experiments/production_compiler_cli/production_compiler_cli_summary.json`
- `igniter-lang/docs/gates/prop038-strict-refusal-canon-sync-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-profile-internal-carrier-docs-spec-sync-v0.md`
- `igniter-lang/docs/tracks/stage2-close-candidate-v0.md`

---

## Current Release Evidence Classification

| Evidence | Current status | Release-readiness use | RC status |
| --- | --- | --- | --- |
| POC/MVP live touch | PASS: 4 synthetic `.ig` modules compile and produce trusted proof-local runtime traces | Seed evidence for acceptance corpus shape | Not RC evidence until normalized harness and negative corpus exist |
| POC `.igapp` outputs | Present under `experiments/poc_mvp_live_touch_v0/out/` | Artifact field survey and normalization seed | Lab-only until stable comparison policy exists |
| POC compile transcript | PASS: parse/classify/typecheck/emit/assemble ok for all 4 modules | Positive compile transcript seed | Needs schema/normalization policy before RC |
| POC runtime trace | PASS: RuntimeSmoke trusted for all 4 modules | Proof-local trace seed | Not production runtime evidence |
| `production_compiler_cli_proof` | PASS: CLI positive compile, unresolved-symbol refusal, direct API compile, load-path facade | Package/CLI/API/load-path anchor | Useful RC prerequisite, but must be rerun in an RC matrix |
| PROP-036 bounded CLI transport | Release-ready in exact `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json` scope after docs sync and R54 smoke | Accepted bounded public CLI surface | RC candidate may cite this exact scope only |
| PROP-038 strict refusal | Internal-only strict-refusal foundation accepted and canon-synced | Refusal-category input | Public/runtime refusal remains closed |
| `InternalProfileStaticDataCarrier` | Accepted as direct-require-only internal carrier/test seam | Internal architecture evidence | Not public API, report, artifact, or compiler pipeline evidence |
| Stage 2 package boundary | PASS: facade, CLI/API shape, load path, Stage 1 regression | Historical packageability anchor | Needs fresh RC-oriented smoke if used for release |

---

## What Is Acceptable Release Evidence Now

Acceptable as release-readiness evidence:

- The POC proves that existing compiler surfaces can compile a small coherent
  synthetic micro-app into inspectable `.igapp` artifacts.
- The POC proves that proof-local runtime traces can be recorded for compatible
  contracts without production runtime claims.
- The `production_compiler_cli_proof` proves the shared packageable spine:
  `require "igniter_lang" -> IgniterLang.compile -> CompilerOrchestrator ->
  parser/classifier/typechecker/emitter/assembler`.
- The same proof covers one positive CLI compile, one unresolved-symbol refusal,
  direct API compile, and load-path facade smoke.
- PROP-036 R52/R53/R54 evidence supports only the exact bounded CLI transport
  `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`.
- PROP-038 evidence supports internal strict-refusal foundation and internal
  report-only validation facts, not public refusal or production runtime.

Acceptable does not mean release-candidate complete. It means these artifacts
can seed the RC checklist and future acceptance harness.

---

## What Remains Local Proof-Lab Evidence Only

The following must not be promoted as RC evidence yet:

- POC runtime traces, because they are RuntimeSmoke/proof-local traces rather
  than production runtime behavior.
- POC `.igapp` outputs, because the stable comparison field set is not yet
  declared.
- Absolute artifact paths and hash values captured in POC and CLI proof output.
- Internal profile carrier and source-mode/static-data objects, because they
  remain direct-require-only test seams.
- Analyzer/tracer/visualizer concepts, because no design boundary or
  implementation authority exists yet.
- Spark-derived vocabulary, because it is sanitized applied pressure only.
- Ruby Framework package-doc alignment, because it waits for a stable Lang
  release-candidate export shape.

---

## Required Release-Candidate Evidence Checklist

| Category | Required before first compiler RC | Current coverage | Gap |
| --- | --- | --- | --- |
| Release scope declaration | Exact included/excluded compiler surfaces, CLI/API commands, artifacts, and non-claims | Fragmented across gates/tracks | Need one RC scope doc |
| Positive compile corpus | Small corpus with 3-5 coherent `.ig` modules plus minimal Add fixture | POC 4 modules PASS; Add proof PASS | Need one pinned RC corpus and rerunnable matrix |
| Negative/refusal corpus | Parse error, unresolved symbol, type mismatch, profile-source preflight refusal, semantic profile-source refusal, strict-refusal internal path if in scope | Unresolved symbol and PROP-036 profile-source refusals exist | Missing unified RC negative matrix |
| Artifact comparison policy | Stable fields, normalized fields, excluded fields, ordering policy | POC and CLI artifacts are machine-readable | Need declared normalization/exclusion rules |
| CLI smoke | No-flag compile, bounded profile-source compile, bad path, malformed JSON, semantic refusal | R54 5/5 PASS | Need fresh RC matrix run or accepted reuse policy |
| API smoke | `IgniterLang.compile` positive compile and expected result shape | `production_compiler_cli_proof` PASS | Need RC matrix inclusion |
| Load-path smoke | `ruby -I igniter-lang/lib -e 'require "igniter_lang"'` facade check | PASS in package proof | Need RC matrix inclusion |
| Package/install smoke | Package-local executable/install context if RC claims package installability | Stage 2 package-shaped only | Need gemspec/version/bin/install decision before package claims |
| Runtime/evaluation trace | Proof-local trace policy and non-production wording | POC RuntimeSmoke PASS | Need acceptance language that runtime trace is proof-local |
| Documentation boundary | Caller-facing CLI/API docs and public non-claims | PROP-036 docs synced; broader RC docs missing | Need RC docs boundary before public claims |
| Closed-surface scan | Public/report/runtime/Spark/deployment leakage checks | POC token scan clean; many gates preserve closures | Need RC-wide negative scan |
| Spark/Ruby pressure routing | Sanitized pressure only; no integration | Portfolio synthesis defines candidates | Need keep as fixture/design candidates only |

---

## Artifact Field Stability Map

| Artifact area | Stable enough for acceptance candidate | Normalize before comparison | Exclude or treat as non-blocking |
| --- | --- | --- | --- |
| POC summary | `kind`, `format_version`, `status`, source count, check ids/status, command matrix status | command text paths | absolute paths, run-local output paths |
| Compile transcript | module/contract names, stage statuses, diagnostics/warnings counts, expected/observed outputs | source paths to repo-relative paths, entry ordering | timestamp-like fields if introduced later |
| Runtime trace | contract/module name, sample input, observed outputs, trusted status | source/module paths | proof-local trace reason prose unless pinned |
| `compiler_result` success | `kind`, `format_version`, `status`, grammar version, stage map, contracts, empty diagnostics/warnings | `source_path`, `igapp_path`, report refs to relative/ref-shape | exact hashes unless corpus and hashing policy are pinned |
| `compiler_result` refusal | `status`, failed/skipped stage map, diagnostic rule/severity/category/path, no `.igapp` | path fields | full diagnostic message text unless made part of refusal contract |
| `.igapp` manifest | manifest kind/version, contracts, contract index shape, semantic/ref shape, diagnostics/warnings status, fragment summary | path/ref/hash fields to shape checks | exact artifact hash before hash policy is pinned |
| Contract artifact | contract id, ports, compute nodes, dependencies, type signature | source contract refs | field ordering unless canonicalized |
| Compilation report | report kind/version, pass result, stage map, diagnostics, semantic IR ref shape | path/hash/ref fields | report-only profile/strict details unless route includes them |

Hash fields are useful evidence, but first RC should compare hash shape and
recomputability policy separately from exact hash values unless the corpus,
writer, and normalization policy are pinned in the same acceptance harness.

---

## Positive POC Coverage

The POC corpus covers four independent synthetic contracts:

- channel signal scoring;
- order readiness gating;
- economics shadow margin;
- fulfillment attention trace.

Observed positive coverage:

- 4/4 source modules compiled successfully.
- 4/4 compile transcripts show `parse`, `classify`, `typecheck`, `emit`, and
  `assemble` as `ok`.
- 4/4 proof-local runtime traces are trusted.
- Outputs are simple and inspectable: integer addition-like scores and boolean
  conjunction.
- Negative token scan stayed clean for Spark, production, public demo, release
  claim, deployment/signing, Ledger/TBackend, BiHistory, stream, and OLAP terms.

This is good POC coverage, not broad language coverage.

---

## Missing Negative And Refusal Coverage

Before first RC, the acceptance corpus needs at least:

- parse refusal for invalid syntax;
- unresolved symbol refusal;
- type mismatch refusal;
- warning-preserving successful compile, if warnings are part of public result
  shape;
- CLI bad-path preflight refusal for `--compiler-profile-source`;
- CLI malformed-JSON preflight refusal for `--compiler-profile-source`;
- semantic `compiler_profile_source.*` refusal;
- internal PROP-038 strict-refusal case if strict profile contract behavior is
  included in the RC scope;
- refusal no-write assertion: no `.igapp` where refusal should block assembly;
- no public/report/runtime/deployment leakage scan;
- normalization failure case for acceptance harness design.

The current missing center is not "more positive demos"; it is refusal and
artifact comparison discipline.

---

## Package, Install, Load-Path, And CLI Smoke Required

Minimum RC smoke matrix:

```text
ruby -I igniter-lang/lib -e 'require "igniter_lang"; abort unless IgniterLang.respond_to?(:compile)'
igniter-lang/bin/igc compile SOURCE --out OUT.igapp
igniter-lang/bin/igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
igniter-lang/bin/igc compile BAD_SOURCE --out BAD.igapp
IgniterLang.compile(SOURCE, out: OUT.igapp)
```

If the RC claims gem/package installability, add a separate package/install
matrix:

```text
build package artifact
install into clean local gem/home context
require "igniter_lang" without repo-relative -I path
installed executable compiles the positive corpus
installed executable refuses the negative corpus
```

Until that package/install matrix exists, the release candidate may claim a
repo-local compiler release boundary, but not installed gem release readiness.

---

## Documentation Boundary Before Public Claims

Before any public compiler release claim, docs must state:

- exact CLI/API surfaces included in the RC;
- exact `.igapp` artifact status and what is not stable yet;
- proof-local runtime trace status;
- refusal behavior and refusal artifact write policy;
- profile-source transport-only semantics for PROP-036;
- PROP-038 internal-only strict-refusal status;
- no Spark integration, no production runtime, no deployment/signing/cache, no
  Ledger/TBackend, no public CompatibilityReport route;
- analyzer/tracer/visualizer status as design/tooling direction only if named.

Ruby Framework package docs should wait for a stable Lang RC export fixture.
They should not pre-document a compiler bridge as runtime-enforced or packaged
until Lang publishes the export shape.

---

## Analyzer / Tracer / Visualizer Placement

Disposition:

```text
design-only acceptance-harness candidate
implementation deferred
not release-blocking as UI/tooling
```

Release-blocking requirement:

- define machine-readable acceptance inputs;
- define normalized comparisons;
- define PASS/HOLD/FAIL summary fields;
- define how traces and artifacts are linked.

Not release-blocking for first RC:

- interactive visualizer;
- public analyzer command;
- tracer UI;
- report/loader/CompatibilityReport integration.

---

## Spark Sanitized Pressure Candidates

Spark remains applied pressure only. The following are accepted only as future
sanitized fixture/design candidates:

| Candidate | Release-map treatment | Forbidden implication |
| --- | --- | --- |
| `service_call_price_shadow_evidence` | Possible synthetic fixture family for expected-match evidence | No Spark raw data, no primary-ledger replacement, no production binding |
| `service_call_override_divergence_policy` | Semantic pressure candidate for divergence/refusal/diagnostic design | No automatic compiler requirement |
| `lead_channel_seed_review_decision` | Possible synthetic review-decision specimen | No Spark IDs/classes as public Lang vocabulary |
| `orders_analytics_evidence_coverage` | Possible coverage-category input for future acceptance harness | No Spark access, fixture creation, or spec mutation now |

No Spark fixture/spec/compiler/runtime work is opened by this map.

---

## Ruby Framework Alignment

Ruby Framework alignment is future export-fixture pressure only.

Current stance:

- Ruby `0.5.2` remains published/closed.
- Ruby package docs should wait for a stable Lang release-candidate export
  shape.
- Future Ruby docs must describe Lang compiler bridge behavior as additive,
  report-only, metadata-only, and not runtime-enforced unless a later Lang gate
  explicitly changes that.

---

## Closed Surfaces Preserved

This map does not authorize:

- code implementation;
- release execution;
- public demo or release claims;
- analyzer/tracer/visualizer implementation;
- public API/CLI widening;
- root require changes;
- parser, classifier, TypeChecker, SemanticIR, assembler changes;
- loader/report;
- `CompilationReport`, `CompilerResult`, or CompatibilityReport widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework package docs or release changes;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

---

## Recommended Next Boundary

Immediate next card:

```text
Card: S3-R159-C2-X
Agent: [Igniter-Lang Pressure Reviewer]
Role: pressure-reviewer
Track: compiler-release-readiness-map-pressure-v0
Route: UPDATE

Goal:
Pressure-test `compiler-release-readiness-map-v0` for overclaim, missing
negative/refusal evidence, artifact field instability, package/install gaps,
Spark/Ruby leakage, and public/runtime/deployment surface widening.

Allowed writes:
- `igniter-lang/docs/discussions/compiler-release-readiness-map-pressure-v0.md`

Do not implement code.
Do not authorize release execution.
Do not authorize public claims, analyzer/tracer/visualizer implementation,
Spark integration, Ruby docs sync, runtime, production, signing, or deployment.
```

If C2 pressure proceeds and C3 accepts the map, recommended follow-up:

```text
compiler-release-acceptance-harness-design-v0
```

Mode:

```text
design-only
```

Goal:

```text
Define the normalized acceptance harness inputs, stable artifact fields,
negative/refusal corpus, command matrix, and PASS/HOLD/FAIL packet shape for a
first compiler release candidate.
```

No implementation or release execution should open until that design is
accepted by a separate gate.

---

## Compact Handoff

```text
[D] R159 C1-D completed a design/report-only compiler release-readiness map.

[S] POC/MVP live touch is accepted as release-readiness seed evidence, not RC
    evidence. Existing CLI/API/load-path/package proofs are useful anchors, but
    must be pulled into one RC acceptance matrix.

[T] No code was changed. No commands were run as release proofs by this card.

[R] Main blockers before first compiler RC:
    - no unified acceptance harness design;
    - no normalized artifact comparison policy;
    - no unified negative/refusal corpus;
    - no fresh RC package/install/load-path/CLI smoke matrix;
    - no RC documentation boundary.

[Next] S3-R159-C2-X pressure review of this map.
```
