# Compiler Release Acceptance Harness Design v0

Card: S3-R160-C1-D
Agent: [Igniter-Lang Supervisor]
Role: igniter-lang-supervisor
Track: compiler-release-acceptance-harness-design-v0
Route: UPDATE
Status: done
Date: 2026-05-24

---

## Summary

Design-only boundary for the first Igniter-Lang compiler release-candidate
acceptance harness.

The harness should be a local, machine-readable release-candidate evidence
packet that reruns a pinned positive/negative corpus, normalizes compiler and
`.igapp` artifacts, reports PASS/HOLD/FAIL, and proves closed surfaces stay
closed.

This card does not implement the harness, gather new RC evidence, mutate POC
outputs, mutate `.igapp` artifacts, authorize release execution, or authorize
public release/demo claims.

Recommended next route:

```text
S3-R160-C2-X
Track: compiler-release-acceptance-harness-design-pressure-v0
Mode: pressure review only
```

---

## Evidence Read

- `igniter-lang/docs/tracks/stage3-round159-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-and-ruby-hygiene-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-map-v0.md`
- `igniter-lang/docs/discussions/compiler-release-readiness-map-pressure-v0.md`
- `igniter-lang/docs/tracks/poc-mvp-live-touch-v0.md`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/poc_mvp_live_touch_summary.json`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/compile_transcript.json`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/runtime_trace.json`
- `igniter-lang/experiments/poc_mvp_live_touch_v0/out/*/*.igapp/*`
- `igniter-lang/docs/current-status.md`

---

## Harness Boundary

The future harness may be considered only as a local release-candidate
acceptance proof.

Allowed future purpose:

- read a pinned RC corpus;
- run existing compiler/API/CLI surfaces;
- inspect generated artifacts;
- normalize known run-local fields;
- produce one summary packet;
- prove refusal/no-write behavior;
- prove closed-surface scans.

Forbidden implication:

- no new compiler semantics;
- no parser/classifier/TypeChecker/SemanticIR/assembler change;
- no public API/CLI widening;
- no loader/report or CompatibilityReport route;
- no production runtime;
- no Spark integration;
- no Ruby Framework docs sync;
- no release execution;
- no public release/demo claim.

---

## Accepted Harness Inputs

| Input | Required status | Notes |
| --- | --- | --- |
| Positive `.ig` corpus | Pinned local files | Must include minimum language-feature diversity below; POC sources may seed, not blindly define the corpus. |
| Negative/refusal `.ig` corpus | Pinned local files | Must include parse/typecheck/refusal cases and expected no-write behavior. |
| Optional finalized profile-source JSON | Pinned local file | Used only for exact PROP-036 bounded CLI transport. |
| Malformed/profile-source refusal inputs | Pinned local files | Used for CLI preflight and semantic profile-source refusals. |
| Existing compiler CLI | Current bounded `igniter-lang/bin/igc` / `bin/igniter-lang` surface | No new flags. |
| Existing Ruby API | `IgniterLang.compile` | No signature widening. |
| Generated `.igapp` directories | Harness-local output only | Do not mutate POC outputs or tracked goldens. |
| Prior proofs | Provenance anchors only | Prior proof output may explain expectations but cannot substitute for RC reruns. |

Harness output, when later authorized, should live in a new harness-local
experiment directory, not inside `poc_mvp_live_touch_v0/out/`.

---

## Stable Artifact Fields

Stable enough for first RC acceptance comparison:

| Artifact | Stable required fields |
| --- | --- |
| Harness summary | `kind`, `format_version`, `status`, `decision`, `corpus`, `command_matrix`, `artifact_checks`, `closed_surface_scan`, `failed_checks`, `warnings_policy`, `non_claims` |
| Compile transcript | source id, module name, contract name, compile status, stage status map, diagnostics count, warnings count, output artifact ref |
| Runtime trace | source id, contract/module name, sample input shape, observed outputs, `trace_status`, proof-local trace marker |
| `compiler_result` success | `kind`, `format_version`, `status: ok`, grammar version, stage map, contract list, diagnostics array, warnings array, `.igapp` output presence |
| `compiler_result` refusal | `status`, failed/skipped stage map, diagnostics array with rule/severity/category/path, `.igapp` absence |
| `.igapp/manifest.json` | `kind`, format/schema/language/grammar versions, contract index shape, contracts list, fragment summary, diagnostics/warnings arrays |
| `.igapp/contracts/*.json` | contract id/name, input ports, output ports, compute node dependencies, type signature, fragment class |
| `.igapp/compilation_report.json` | `kind`, `format_version`, `pass_result`, stage map, diagnostics array, semantic IR ref shape |
| `.igapp/compatibility_metadata.json` | `kind`, format version, canonical artifact field, metadata presence only |

Compatibility metadata is accepted only as artifact metadata shape. It is not a
public CompatibilityReport.

---

## Normalized Artifact Fields

The harness design must normalize these before comparison:

| Field family | Normalization |
| --- | --- |
| Absolute paths | Convert to repo-relative paths or harness-output-relative paths. |
| Output directories | Compare shape and containment under harness output, not exact temp dir. |
| Command strings | Normalize repo root, Ruby executable path, and temp output path. |
| Hash/ref fields | Compare prefix and shape unless the later harness design pins recomputation. |
| Artifact refs | Compare namespace and length/pattern, not exact content, unless pinned. |
| Entry ordering | Sort where JSON object/array ordering is not semantically meaningful. |
| Diagnostic prose | Compare rule/severity/category/path first; full message text only if declared stable for that case. |
| Runtime trace reason | Require proof-local marker; exact prose may be normalized to an enum. |

---

## Excluded Or Non-Blocking Fields

Excluded from first RC exact comparison:

- exact `artifact_hash` values;
- exact `source_hash` values unless corpus and recomputation policy are pinned;
- exact `program_id`, `semantic_ir_ref`, `contract_ref`, and
  `compilation_report_ref` values beyond namespace/shape;
- `compiled_at` exact timestamp value;
- absolute local machine paths;
- full diagnostic English prose unless that case explicitly pins it;
- compatibility metadata note prose;
- interactive visualization/UI fields, because visualizer implementation is
  not part of first RC.

Any excluded field appearing with a new public/report/runtime authority meaning
should be a HOLD, not silently ignored.

---

## Positive RC Corpus Requirements

Minimum positive corpus:

- at least 5 compile units;
- at least 1 minimal Add-style baseline contract;
- at least 1 synthetic micro-app group derived from the POC domain;
- at least 1 contract with more than two inputs;
- at least 1 boolean gate/conjunction case;
- at least 1 integer arithmetic case;
- at least 1 accepted conditional/branch case if current accepted grammar and
  compiler surfaces support it without new semantics.

Binding NB-1 answer:

If a branch/conditional positive case cannot be included using already accepted
compiler behavior, the first RC harness result must be HOLD until the release
scope explicitly records either:

- branch/conditional coverage is included with existing behavior; or
- branch/conditional coverage is out of first RC scope and the Portfolio gate
  accepts that narrower language-feature boundary.

Module count alone is never sufficient.

---

## Negative And Refusal RC Corpus Requirements

Minimum negative/refusal corpus:

| Case | Required evidence |
| --- | --- |
| Parse refusal | non-zero/error result, parse stage failure, no `.igapp` |
| Unresolved symbol | typecheck refusal with diagnostic category/path, no `.igapp` |
| Type mismatch | typecheck refusal with diagnostic category/path, no `.igapp` |
| CLI profile-source bad path | preflight stderr, no stdout result, no report, no `.igapp` |
| CLI profile-source malformed JSON | preflight stderr, no stdout result, no report, no `.igapp` |
| Semantic profile-source refusal | compiler-result JSON with qualified `compiler_profile_source.*` diagnostic, report allowed per accepted behavior, no `.igapp` |
| PROP-038 strict refusal | required only if strict profile contract behavior is included in first RC scope; internal-only and non-persisting |
| Normalization failure specimen | harness-design specimen proving unstable fields do not falsely fail stable checks |
| Closed-surface leakage specimen | negative scan over source, outputs, and summary |

Warnings are handled by the warning policy below.

---

## Warnings Policy

Binding NB-4 answer:

Warnings are in scope as result-shape fields for first RC, but
warning-producing positive behavior is deferred.

First RC requirements:

- `warnings` arrays must be present where current compiler result/report shapes
  emit them;
- `warnings_count` must be present in harness transcript entries;
- positive corpus must have zero warnings unless a later gate explicitly adds a
  warning-producing fixture;
- any unexpected warning in the first RC corpus is HOLD;
- warning-preserving successful compile is deferred to a post-RC or later
  explicit route.

This keeps the result shape stable without inventing warning semantics or
forcing a warning fixture before release-candidate boundary is accepted.

---

## Command Matrix

Minimum future RC command matrix:

```text
ruby -c HARNESS_RUNNER
ruby HARNESS_RUNNER --mode acceptance
ruby -I igniter-lang/lib -e 'require "igniter_lang"; abort unless IgniterLang.respond_to?(:compile)'
igniter-lang/bin/igc compile POSITIVE_SOURCE --out HARNESS_OUT/POSITIVE.igapp
igniter-lang/bin/igc compile POSITIVE_SOURCE --out HARNESS_OUT/POSITIVE_PROFILE.igapp --compiler-profile-source FINALIZED_PROFILE_SOURCE.json
igniter-lang/bin/igc compile NEGATIVE_SOURCE --out HARNESS_OUT/NEGATIVE.igapp
IgniterLang.compile(POSITIVE_SOURCE, out: HARNESS_OUT/API_POSITIVE.igapp)
```

The future harness may expand this matrix, but it must not remove CLI, Ruby API,
load-path, positive compile, negative compile, and profile-source transport
coverage.

---

## `production_compiler_cli_proof` Policy

Binding NB-2 answer:

`production_compiler_cli_proof` may be cited as historical provenance and
expectation seed only. It is not sufficient RC evidence by itself.

For first RC evidence gathering:

- CLI/API/load-path checks must be rerun by the RC harness or by a same-round
  named RC smoke card;
- the old proof summary may be linked as an anchor for expected shape;
- any mismatch between fresh RC run and historical proof is HOLD until reviewed;
- reusing old output without rerun is not allowed for RC acceptance.

---

## Package / Install / Load-Path Stance

First RC may target one of two explicitly named scopes:

| Scope | Required package stance |
| --- | --- |
| Repo-local compiler RC | Require load-path smoke with `ruby -I igniter-lang/lib`; do not claim installed gem readiness. |
| Installed package RC | Require package artifact build, clean local install, require without repo-relative `-I`, installed executable compile/refusal smoke. |

Default for next route:

```text
repo-local compiler RC only
```

Installed package readiness remains held until a separate gate opens package
build/install evidence.

---

## PASS / HOLD / FAIL Result Packet Shape

Future harness summary should use this shape:

```json
{
  "kind": "compiler_release_acceptance_harness_summary",
  "format_version": "0.1.0",
  "track": "compiler-release-acceptance-harness-v0",
  "status": "PASS | HOLD | FAIL",
  "decision": "rc_evidence_ready | held_for_review | failed",
  "release_scope": {
    "scope": "repo_local_compiler_rc",
    "public_claims_authorized": false,
    "production_runtime_authorized": false
  },
  "corpus": {
    "positive": [],
    "negative": [],
    "feature_coverage": []
  },
  "command_matrix": [],
  "artifact_checks": [],
  "normalization": {
    "stable_fields": [],
    "normalized_fields": [],
    "excluded_fields": []
  },
  "warnings_policy": {
    "result_shape_in_scope": true,
    "warning_producing_fixture_required": false,
    "unexpected_warning_result": "HOLD"
  },
  "closed_surface_scan": {
    "token_list": [],
    "hits": [],
    "status": "PASS | HOLD | FAIL"
  },
  "non_claims": [],
  "failed_checks": [],
  "hold_reasons": [],
  "artifacts": {}
}
```

Decision rules:

| Status | Meaning |
| --- | --- |
| PASS | All required commands, corpus checks, artifact normalization checks, refusal checks, and closed-surface scans pass. |
| HOLD | Evidence is incomplete, unexpected warnings appear, feature diversity is insufficient, non-authorized vocabulary appears in docs/prose only, or normalization policy needs review. |
| FAIL | Required command fails, positive compile fails, refusal writes forbidden `.igapp`, public/runtime/Spark/deployment leakage appears in generated outputs, or the harness mutates forbidden surfaces. |

---

## Closed-Surface Scan Policy

Scan targets:

- RC positive and negative source corpus;
- generated `compiler_result` JSON;
- generated `.igapp` manifests and JSON artifacts;
- compile transcript;
- runtime trace if present;
- harness summary;
- release docs draft if included in a later route.

Binding NB-5 answer:

Minimum RC-wide negative scan token list:

```text
Spark
spark
sparkcrm
SparkCRM
ServiceCall
LeadChannel
OrdersAnalytics
service_call_price_shadow_evidence
service_call_override_divergence_policy
lead_channel_seed_review_decision
orders_analytics_evidence_coverage
production
Production
production_runtime
runtime_production
public_demo
demo_ready
release_ready
release_claim
deployment
deploy
signing
signature
RubyGems
gem_push
Ledger
TBackend
BiHistory
stream
OLAP
CompatibilityReport
CompilationReceipt
loader/report
sidecar
.ilk
cache
Gate 3
RuntimeMachine
contract_fragment_for
root require
```

Allowed-context exceptions must be explicit and narrow:

- `runtime_trace` may contain proof-local RuntimeSmoke wording.
- `CompatibilityReport` may appear only in non-claims/closed-surface wording,
  not as an emitted public artifact claim.
- Spark candidate names may appear only in the harness design/report sections
  that classify them as optional future fixture families.
- RubyGems may appear only in non-claims/closed-surface wording.

Any hit outside an allowed context is HOLD or FAIL depending on whether it is
documentation drift or generated artifact/runtime leakage.

---

## Release Documentation Non-Claims Template

Binding NB-3 answer:

Future first-RC docs must include this normative non-claims block or an
equivalent with the same meaning:

```text
This Igniter-Lang compiler release candidate is local compiler evidence only.
It demonstrates bounded parsing, classification, typechecking, SemanticIR
emission, assembly, CLI/API invocation, and proof-local artifact inspection for
the named RC corpus.

It is not a public production runtime, not Spark integration, not a public demo
claim, not deployment or signing readiness, not Ledger/TBackend readiness, and
not a CompatibilityReport or loader/report release. Runtime traces, when
present, are RuntimeSmoke proof-local evaluation evidence only. They do not
authorize production runtime behavior.

The only accepted CLI profile-source transport is the previously gated
`igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json` shape,
where PATH.json is an already-finalized compiler profile source object. The
release candidate does not add profile discovery, defaulting, finalization,
inline JSON, named profile lookup, or environment/config/sidecar lookup.
```

Public docs must also state whether the RC is repo-local only or installed
package evidence. Until package/install smoke is accepted, docs must say
repo-local only.

---

## Analyzer / Tracer / Visualizer Disposition

Analyzer/tracer/visualizer remains design-only.

Allowed in the harness design:

- define the machine-readable fields an analyzer would read;
- define trace-to-artifact linkage;
- define summary shape that could later be visualized;
- define stable/normalized/excluded fields.

Held:

- analyzer implementation;
- tracer implementation;
- visualizer implementation;
- public analyzer/tracer command;
- UI;
- release-blocking visualization requirement.

First RC blocks on structured acceptance evidence, not on visual tooling.

---

## Spark Sanitized Pressure

Spark pressure is optional future fixture-family input only:

| Candidate family | Allowed future use | Current status |
| --- | --- | --- |
| `service_call_price_shadow_evidence` | Synthetic expected-match fixture family | Future only |
| `service_call_override_divergence_policy` | Synthetic divergence/refusal design pressure | Future only |
| `lead_channel_seed_review_decision` | Synthetic review-decision specimen | Future only |
| `orders_analytics_evidence_coverage` | Synthetic coverage-category pressure | Future only |

No Spark fixture creation, spec mutation, compiler change, integration, raw
data access, production behavior, or primary-ledger replacement is opened.

---

## Ruby Framework Alignment

Ruby Framework is a future export-fixture consumer pressure only.

Current stance:

- no Ruby docs sync now;
- no Ruby package change now;
- no Ruby compiler compatibility claim now;
- Ruby package docs wait for a stable Lang release-candidate export shape;
- future Ruby wording must remain additive, report-only, metadata-only, and not
  runtime-enforced unless a later Lang gate explicitly changes that.

---

## Mandatory NB-1..NB-5 Answers

| Note | Binding design answer |
| --- | --- |
| NB-1: minimum language-feature diversity beyond module count | Require feature diversity: baseline Add, boolean gate, integer arithmetic, one contract with more than two inputs, and branch/conditional coverage if existing accepted behavior supports it. If branch/conditional cannot be included, RC result is HOLD unless Portfolio accepts narrower first-RC language scope. |
| NB-2: `production_compiler_cli_proof` reuse/rerun policy | Prior proof is provenance only. First RC must rerun CLI/API/load-path checks in the RC harness or same-round RC smoke. Existing output cannot substitute for RC evidence. |
| NB-3: normative non-claims wording template | Template included above. It must be copied or equivalently preserved in future RC docs. |
| NB-4: warnings in-scope or deferred | Warnings are in scope as result-shape fields and must be present/empty. Warning-producing successful compile is deferred. Unexpected warnings produce HOLD. |
| NB-5: RC-wide negative scan token list | Explicit token list declared above with allowed-context exceptions. Hits outside allowed contexts produce HOLD/FAIL. |

---

## Closed Surfaces

This design does not authorize:

- harness implementation;
- release evidence gathering;
- mutation of POC outputs or `.igapp` artifacts;
- release execution;
- public release or public demo claims;
- analyzer/tracer/visualizer implementation;
- public analyzer/tracer command or UI;
- public API/CLI widening;
- root require changes;
- parser, classifier, TypeChecker, SemanticIR, assembler changes;
- loader/report;
- `CompilationReport`, `CompilerResult`, or CompatibilityReport widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs sync, release, tag, package change, or compatibility
  claim;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

---

## Exact Next Requested Boundary

```text
Card: S3-R160-C2-X
Agent: [Igniter-Lang Pressure Reviewer]
Role: pressure-reviewer
Track: compiler-release-acceptance-harness-design-pressure-v0
Route: UPDATE

Goal:
Pressure-test `compiler-release-acceptance-harness-design-v0` for NB-1..NB-5
closure, artifact normalization ambiguity, corpus gaps, command matrix gaps,
package/install overclaim, non-claims wording drift, Spark/Ruby leakage, and
closed-surface scan completeness.

Allowed writes:
- `igniter-lang/docs/discussions/compiler-release-acceptance-harness-design-pressure-v0.md`

Do not implement the harness.
Do not gather new RC evidence.
Do not mutate POC outputs or `.igapp` artifacts.
Do not authorize release execution or public claims.
```

If pressure proceeds, the later C3-A decision may choose whether to open:

```text
compiler-release-acceptance-harness-proof-local-prototype-design-v0
```

or an implementation-authorization review. This C1-D recommends pressure review
first, not implementation.

---

## Compact Handoff

```text
[D] Designed the first compiler release acceptance harness boundary.

[S] Harness must rerun fresh RC evidence, normalize artifacts, require language
    feature diversity, keep warnings present/empty, and emit PASS/HOLD/FAIL.

[T] No code, POC output, `.igapp`, compiler, docs/spec/canon, Spark, Ruby,
    runtime, production, or release surface was changed by this card.

[R] Main risk is overclaim: first RC should default to repo-local compiler RC
    until package/install smoke is separately accepted.

[Next] S3-R160-C2-X pressure review only.
```
