# Compiler Release Profile-Source Smoke Extension Authorization Review v0

Card: S3-R175-C4-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: compiler-release-profile-source-smoke-extension-authorization-review-v0  
Route: UPDATE  
Status: done  
Date: 2026-05-25

Depends on:
- S3-R175-C1-P1
- S3-R175-C2-P1
- S3-R175-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-boundary-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-criteria-v0.md`
- `igniter-lang/docs/discussions/compiler-release-profile-source-smoke-extension-authorization-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-installed-readiness-and-next-vector-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round174-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json`

Additional fixture existence check:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/finalized_profile_source.json
igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/malformed_profile_source.json
igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/semantic_profile_source_wrong_kind.json
```

---

## Decision

Decision:

```text
authorize bounded profile-source smoke execution next
execution is not run by this card
public release/demo claims remain closed
release execution remains closed
RubyGems publish remains closed
version/tag/push/publish/sign/deploy remain closed
profile finalization/discovery/defaulting remain closed
branch/conditional if_expr remains excluded
Spark remains out of scope
```

The S3-R175-C1-P1 boundary packet and S3-R175-C2-P1 criteria packet are
accepted. The S3-R175-C3-X pressure verdict is accepted:

```text
proceed - no blockers; 14/14 checks PASS
```

The next route may execute a bounded installed-package profile-source smoke
using the already-landed `--compiler-profile-source PATH.json` CLI transport.
This is a package-readiness confidence extension only. It is not release
execution and is not a public release/demo claim.

---

## Accepted Basis

Accepted R174/R173 marker facts:

| Field | Accepted value |
| --- | --- |
| base scope | `local_package_install_smoke_only` |
| package | `igniter_lang` |
| version | `0.1.0.pre.stage2` |
| base run id | `S3R173C1I_20260525T063543Z` |
| built gem SHA256 | `sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a` |
| installed CLI | `igc compile` |
| positive corpus | `5/5 PASS` |
| refusal corpus | `3/3 PASS` |
| failed checks | `0` |
| hold reasons | `0` |

Accepted R175 preparation:

- C1 defines a narrow installed-package profile-source smoke boundary.
- C2 defines PSS-0..PSS-8 PASS/HOLD/FAIL criteria and summary shape.
- C3 pressure passes 14/14 checks with 0 blockers.
- Existing release-harness fixtures are present and sufficient.
- No new committed fixture is required.

---

## Exact Next Execution Boundary

Authorized next card:

```text
Card: S3-R176-C1-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: compiler-release-profile-source-install-smoke-v0

Route: UPDATE
Depends on:
- S3-R175-C4-A

Goal:
Run a bounded installed-package profile-source smoke using the installed
`igc compile --compiler-profile-source PATH.json` transport and produce a
machine-readable summary.
```

### Allowed Write / Output Scope

Allowed durable repo outputs:

```text
igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/**
igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-v0.md
```

The durable summary path must be:

```text
igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/$RUN_ID/profile_source_install_smoke_summary.json
```

Allowed temp root:

```text
/private/tmp/igniter_lang_profile_source_install_smoke_$RUN_ID/
```

Allowed temp artifacts:

- built `.gem`;
- isolated gem home;
- isolated bindir;
- copied source/profile fixtures;
- success `.igapp` output;
- refusal stdout/stderr captures;
- smoke-local working JSON.

Do not retain in repo:

- built `.gem`;
- gem home;
- bindir;
- temp copied corpus;
- generated `.igapp`;
- refusal output files;
- profile-source copies;
- full command logs beyond summary excerpts.

---

## Command Matrix

Required command matrix:

| ID | Kind | Command shape | Expected |
| --- | --- | --- | --- |
| PSS-0A | gemspec syntax | `ruby -c igniter_lang.gemspec` | exit 0 |
| PSS-0B | gem build | `gem build igniter_lang.gemspec --output $BUILD_DIR/igniter_lang-$VERSION.gem` | exit 0; gem exists; SHA256 recorded |
| PSS-0C | isolated gem install | `gem install --local --force --no-document --install-dir $GEM_HOME --bindir $BIN_DIR $GEM_PATH_LOCAL` | exit 0; `$BIN_DIR/igc` exists |
| PSS-0D | require no repo load | `ruby -e 'require "igniter_lang"; ...'` from temp cwd | exit 0; gem path inside isolated GEM_HOME; no repo path leak |
| PSS-2 | profile-source success | `$BIN_DIR/igc compile add_baseline.ig --out $OUT/add_baseline_profiled.igapp --compiler-profile-source finalized_profile_source.json` | exit 0; `.igapp`; expected manifest id |
| PSS-3 | profile-source preflight refusal | `$BIN_DIR/igc compile add_baseline.ig --out $OUT/preflight_should_not_exist.igapp --compiler-profile-source malformed_profile_source.json` | non-zero; stderr-only; no `.igapp`; no report |
| PSS-4 | profile-source semantic refusal | `$BIN_DIR/igc compile add_baseline.ig --out $OUT/wrong_kind_should_not_exist.igapp --compiler-profile-source semantic_profile_source_wrong_kind.json` | non-zero; compiler_result JSON; report present; no `.igapp` |

Required command constraints:

```text
use installed $BIN_DIR/igc
do not use repo-local bin/igc
do not use ruby -I igniter-lang/lib
do not use repo RUBYLIB
do not use igniter-lang compile alias
do not use inline JSON
do not use named/generated profile lookup
do not use env/config/sidecar discovery
do not perform profile-source finalization during smoke
```

---

## Profile-Source Fixture / Corpus

Required source:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig
```

Required profile-source fixtures:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/finalized_profile_source.json
igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/malformed_profile_source.json
igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/semantic_profile_source_wrong_kind.json
```

The stable standalone artifact may be used only as a backup valid source if the
release-harness finalized fixture becomes unavailable:

```text
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json
```

No branch/conditional `if_expr` corpus may be added.

---

## Expected Success / Refusal Behavior

### PSS-2 Success

Required:

```text
exit_status == 0
stdout parses as compiler_result JSON
compiler_result.status == "ok"
stderr is empty
.igapp exists under temp out dir
manifest.json exists
manifest.compiler_profile_id ==
  compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
manifest.compiler_profile_id equals profile source compiler_profile_id
```

### PSS-3 Preflight Refusal

Required:

```text
exit_status != 0
stdout == ""
stderr has one stable refusal line
stderr does not echo raw file contents
stderr does not include parser backtrace
OUT.igapp is absent
OUT.compilation_report.json is absent
profile-source report JSON is absent
refusal_kind == "profile_source_preflight"
```

### PSS-4 Semantic Refusal

Required:

```text
exit_status != 0
stdout parses as compiler_result JSON
compiler_result.status is non-ok
stderr is empty
OUT.igapp is absent
OUT.compilation_report.json is present
diagnostics or report include qualified compiler_profile_source.* vocabulary
refusal_kind == "profile_source_semantic_refusal"
```

The PSS-3/PSS-4 report distinction is expected:

```text
PSS-3 preflight refusal writes no compilation report because CLI-owned path/JSON
validation precedes compiler invocation.

PSS-4 semantic refusal writes a compilation report because the profile-source
object passed preflight and failed inside the compiler/assembler path with a
qualified compiler_profile_source.* diagnostic.
```

This distinction must not be treated as an inconsistency in the follow-up
acceptance review.

---

## Required Summary / Result Packet

The durable summary must include the C2-P1 shape, with concrete card references:

```json
{
  "kind": "compiler_release_profile_source_install_smoke_summary",
  "format_version": "0.1.0",
  "card": "S3-R176-C1-I",
  "track": "compiler-release-profile-source-install-smoke-v0",
  "status": "PASS|HOLD|FAIL",
  "authorized_by": "S3-R175-C4-A",
  "run_id": "S3R176...",
  "executed_at_utc": "...",
  "release_scope": {},
  "package": {},
  "environment": {},
  "criteria": {},
  "command_matrix": [],
  "profile_source_inputs": [],
  "success_cases": [],
  "refusal_cases": [],
  "refusal_kind_hygiene_status": "pass|hold|fail",
  "failed_checks": [],
  "hold_reasons": [],
  "non_blocking_notes": [],
  "non_claims": {},
  "artifact_policy": {}
}
```

Required `release_scope`:

```json
{
  "scope": "bounded_installed_package_profile_source_smoke",
  "source_marker": "local_package_install_smoke_only",
  "base_run_id": "S3R173C1I_20260525T063543Z",
  "public_claims_authorized": false,
  "rubygems_publish_authorized": false,
  "production_runtime_authorized": false,
  "release_execution_authorized": false,
  "profile_source_smoke_execution_only_if_authorized": true
}
```

Required non-claims:

```json
{
  "no_release_execution": true,
  "no_public_release_claim": true,
  "no_public_demo_claim": true,
  "no_rubygems_publish": true,
  "no_public_availability_claim": true,
  "no_version_change": true,
  "no_gemspec_metadata_change": true,
  "no_git_tag": true,
  "no_push": true,
  "no_signing": true,
  "no_deploy": true,
  "no_profile_finalization": true,
  "no_profile_discovery": true,
  "no_profile_defaulting": true,
  "no_named_profile_lookup": true,
  "no_inline_json": true,
  "no_env_config_sidecar_lookup": true,
  "no_public_api_cli_widening_beyond_profile_source_path": true,
  "no_loader_report_compatibility_report_claim": true,
  "no_runtime_ledger_tbackend_bihistory_stream_olap_cache_claim": true,
  "no_production_runtime": true,
  "no_spark_integration": true,
  "no_ruby_framework_compatibility_claim": true,
  "no_branch_conditional_claim": true
}
```

Any false value in `non_claims` is FAIL.

---

## PASS / HOLD / FAIL Criteria

### PASS

PASS only if:

```text
PSS-0..PSS-8 all PASS
failed_checks == []
hold_reasons == []
non_claims all true
refusal_kind_hygiene_status == "pass"
success and both refusal classes are exercised
no command violates installed-package isolation constraints
no command widens CLI/API input shape
```

### HOLD

HOLD when evidence is inconclusive or incomplete without behavioral regression:

```text
installed igc missing after install
isolated require fails due package mechanics
temp filesystem permission issue
fixture moved or unreadable due unrelated track
summary omits required fields
success-only profile-source smoke attempted
preflight-only or semantic-only refusal attempted
refusal_kind labels stale but exit/artifact behavior is correct
cleanup verification inconclusive
```

### FAIL

FAIL when bounded behavior regresses or a closed surface opens:

```text
valid finalized profile source exits non-zero
manifest compiler_profile_id missing or mismatched
preflight refusal writes .igapp or OUT.compilation_report.json
semantic refusal writes .igapp
CLI performs discovery/defaulting/finalization
inline JSON/named lookup/env/config/sidecar path used
repo-local -I or repo RUBYLIB used for installed check
repo path leak observed
non_claims any false
version/tag/push/publish/sign/deploy action observed
public release/demo claim emitted
branch/conditional support claim emitted
runtime/production/Spark surface touched
```

---

## Explicit Answers

May profile-source smoke execution open next?

```text
Yes. A bounded installed-package profile-source smoke execution may open next as
S3-R176-C1-I.
```

Is execution authorized now?

```text
Execution is authorized for the next execution card boundary defined above.
This S3-R175-C4-A card itself does not run smoke.
```

Do public release/demo claims remain closed?

```text
Yes. Public release/demo claims remain closed.
```

Does release execution remain closed?

```text
Yes. Release execution remains closed.
```

Does RubyGems publish remain closed?

```text
Yes. RubyGems publish remains closed.
```

Do version/tag/push/publish/sign/deploy remain closed?

```text
Yes. Version edits, tags, pushes, publishing, signing, and deployment remain
closed.
```

Does profile finalization/discovery/defaulting remain closed?

```text
Yes. The smoke must use only caller-supplied finalized profile-source files.
No finalization, discovery, defaulting, named lookup, inline JSON, or env/config/
sidecar lookup is authorized.
```

Does branch/conditional `if_expr` remain excluded?

```text
Yes. Branch/conditional `if_expr` remains excluded from corpus, claims, and
release-readiness scope.
```

Does Spark remain out of scope?

```text
Yes. Spark remains out of scope and non-authorizing for this round.
```

---

## Closed Surfaces

This decision does not authorize:

```text
public release or demo claims
release execution
RubyGems publish
version file edits
gemspec/package metadata edits
git tag creation
git push
signing or deployment
public API/CLI widening beyond --compiler-profile-source PATH.json
inline JSON profile-source input
named/generated profile lookup
env/config/sidecar profile lookup
profile finalization/discovery/defaulting
branch/conditional if_expr implementation or support claim
parser, classifier, TypeChecker, SemanticIR, assembler changes
compiler/library behavior changes
loader/report, CompilationReport, CompilerResult, or CompatibilityReport widening
.igapp, .ilk, manifest, sidecar, artifact hash, or golden migration beyond temp smoke output
PROP-036 or PROP-038 mutation
RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, production behavior
Spark access, fixtures, specs, integration, or production pressure
Ruby Framework docs/release/tag/package/compatibility claims
runtime, production, demo, or deployment work
```

---

## Compact Decision Summary

```text
card: S3-R175-C4-A
track: compiler-release-profile-source-smoke-extension-authorization-review-v0
decision: authorize_bounded_profile_source_smoke_execution_next
next_card: S3-R176-C1-I
next_track: compiler-release-profile-source-install-smoke-v0
pressure: proceed_14_of_14_no_blockers
base_readiness: local_package_install_smoke_only
base_run: S3R173C1I_20260525T063543Z
package: igniter_lang
version: 0.1.0.pre.stage2
command: installed_$BIN_DIR/igc_compile_with_--compiler-profile-source_PATH_json
cases_required: success + preflight_refusal + semantic_refusal
fixtures: existing_release_harness_fixtures
summary_required: experiments/compiler_release_profile_source_install_smoke_v0/out/$RUN_ID/profile_source_install_smoke_summary.json
public_release_demo_claims: closed
release_execution: closed
rubygems_publish: closed
version_tag_push_publish_sign_deploy: closed
profile_finalization_discovery_defaulting: closed
branch_conditional_if_expr: excluded
spark: out_of_scope
```

