# Track: Compiler Release Profile-Source Smoke Extension Criteria v0

Card: S3-R175-C2-P1
Agent: `[Profile Source Smoke Criteria Analyst]`
Role: release-readiness-agent
Track: `compiler-release-profile-source-smoke-extension-criteria-v0`
Route: UPDATE
Status: done
Date: 2026-05-25

---

## Role Note

`roles/release-readiness-agent.md` is not present in this checkout. This slice
uses the assigned role id from the card and follows `roles/base-role.md`,
`AGENTS.md`, current status, and the assigned release-readiness evidence.

---

## Goal

Define PASS/HOLD/FAIL criteria and result packet shape for a possible bounded
installed-package profile-source smoke extension.

This criteria card does not run smoke, edit code, or authorize execution.

---

## Sources Read

Required card inputs:

```text
docs/tracks/compiler-release-installed-readiness-and-next-vector-decision-v0.md
docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md
docs/tracks/compiler-release-package-install-smoke-v0.md
experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json
docs/tracks/compiler-release-evidence-hash-docs-and-package-smoke-policy-v0.md
docs/gates/prop036-cli-remaining-blockers-formal-closure-decision-v0.md
docs/gates/prop036-cli-release-readiness-decision-v0.md
docs/gates/prop038-compiler-profile-contract-acceptance-decision-v0.md
docs/tracks/compiler-profile-source-mode-static-data-internal-carrier-implementation-v0.md
```

Additional directly related R175 input:

```text
docs/tracks/compiler-release-profile-source-smoke-extension-boundary-v0.md
```

---

## Fixed Scope

The possible smoke extension may test only this already-landed bounded CLI
transport in an installed package context:

```text
$BIN_DIR/igc compile SOURCE.ig --out OUT.igapp --compiler-profile-source PATH.json
```

It must not test or imply:

```text
release execution
public release/demo claims
version/tag/push/publish/sign/deploy
profile finalization
profile discovery/defaulting
named/generated lookup
inline JSON
env/config/sidecar lookup
public API/CLI widening beyond --compiler-profile-source PATH.json
branch/conditional if_expr support
loader/report or CompatibilityReport behavior
runtime/Gate 3/Ledger/TBackend/BiHistory/stream/OLAP/cache/production behavior
Spark or Ruby Framework compatibility
```

---

## Criteria IDs

| ID | Name | Required for PASS | Purpose |
| --- | --- | --- | --- |
| PSS-0 | Package setup isolation | yes | Rebuild/install into isolated gem home and prove installed package is used |
| PSS-1 | Installed command shape | yes | Use installed `$BIN_DIR/igc compile` with explicit `--compiler-profile-source PATH.json` only |
| PSS-2 | Profile-source success | yes | Valid finalized profile source emits `.igapp` with expected `manifest.compiler_profile_id` |
| PSS-3 | Profile-source preflight refusal | yes | CLI-owned path/JSON preflight refuses with stderr-only shape and no artifacts |
| PSS-4 | Profile-source semantic refusal | yes | Parsed invalid source object refuses through compiler/assembler path, no `.igapp` |
| PSS-5 | No discovery/finalization/defaulting | yes | Prove smoke used only caller-supplied finalized file and did not infer profiles |
| PSS-6 | Refusal-kind hygiene | yes for PASS; HOLD if stale | Prevent repeat of R173 NB-1 stale refusal labels |
| PSS-7 | Non-claims and closed surfaces | yes | Preserve release/public/runtime/non-widening boundaries |
| PSS-8 | Artifact cleanup / retention | yes | Keep temp outputs temporary and retain only durable summary JSON |

---

## Installed Package Isolation Criteria

PSS-0 passes only if all are true:

```text
gem build exits 0
isolated gem install exits 0
installed igc executable exists under $BIN_DIR
require "igniter_lang" works without repo-relative -I
Gem.loaded_specs["igniter_lang"].full_gem_path is inside isolated GEM_HOME
GEM_HOME == isolated gem home
GEM_PATH == isolated gem home
RUBYLIB is absent or does not point to repo checkout
repo_relative_i_used == false
repo_path_leak_observed == false
```

HOLD if package mechanics are inconclusive:

```text
installed igc missing
isolated require fails after successful install
temp filesystem permission issue prevents smoke root use
fixture path moved by another track
```

FAIL if installed package isolation is bypassed:

```text
repo-relative -I used for installed checks
repo RUBYLIB used for installed checks
repo-local bin/igc used instead of $BIN_DIR/igc
Gem.loaded_specs path points to repo checkout
```

---

## Command Matrix Shape

The future smoke summary should record a `command_matrix` array. Each entry
must include:

```text
id
kind
cmd_shape
cwd
env_shape
exit_status
pass
hold
stdout_excerpt
stderr_excerpt
artifacts
```

Required command matrix:

| ID | Kind | Command shape | Expected |
| --- | --- | --- | --- |
| PSS-0A | gemspec_syntax_check | `ruby -c igniter_lang.gemspec` | exit 0 |
| PSS-0B | gem_build | `gem build igniter_lang.gemspec --output $BUILD_DIR/igniter_lang-$VERSION.gem` | exit 0; gem artifact exists; SHA256 recorded |
| PSS-0C | gem_install_isolated | `gem install --local --force --no-document --install-dir $GEM_HOME --bindir $BIN_DIR $GEM_PATH_LOCAL` | exit 0; `$BIN_DIR/igc` exists |
| PSS-0D | require_no_repo_i | `ruby -e 'require "igniter_lang"; ...'` from temp cwd | exit 0; gem path inside isolated GEM_HOME; no repo path leak |
| PSS-2 | installed_profile_source_success | `$BIN_DIR/igc compile add_baseline.ig --out $OUT/add_baseline_profiled.igapp --compiler-profile-source finalized_profile_source.json` | exit 0; `.igapp`; manifest id expected |
| PSS-3 | installed_profile_source_preflight_refusal | `$BIN_DIR/igc compile add_baseline.ig --out $OUT/preflight_should_not_exist.igapp --compiler-profile-source malformed_profile_source.json` or missing path | non-zero; stdout empty; stderr one-line; no report; no `.igapp` |
| PSS-4 | installed_profile_source_semantic_refusal | `$BIN_DIR/igc compile add_baseline.ig --out $OUT/wrong_kind_should_not_exist.igapp --compiler-profile-source semantic_profile_source_wrong_kind.json` | non-zero; compiler_result JSON; report path allowed/expected; no `.igapp` |

Command constraints:

```text
no repo-local bin/igc
no ruby -I igniter-lang/lib
no repo RUBYLIB
no igniter-lang compile alias
no inline JSON
no named/generated profile lookup
no env/config/sidecar discovery
no source finalization during smoke
```

---

## Fixture Policy

Recommended required source:

```text
experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig
```

Recommended profile-source fixtures:

```text
experiments/compiler_release_acceptance_harness_v0/fixtures/finalized_profile_source.json
experiments/compiler_release_acceptance_harness_v0/fixtures/malformed_profile_source.json
experiments/compiler_release_acceptance_harness_v0/fixtures/semantic_profile_source_wrong_kind.json
```

The stable standalone artifact may be used as a backup valid source:

```text
experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json
```

No new committed fixture is required. Future execution may copy fixtures into
the temp smoke root and record fixture digests.

---

## Success Case Criteria

PSS-2 passes only if all are true:

```text
exit_status == 0
stdout parses as compiler_result JSON
compiler_result.status == "ok"
stderr is empty
success .igapp exists under temp out dir
manifest.json exists
manifest.compiler_profile_id ==
  compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
manifest.compiler_profile_id equals profile source compiler_profile_id
no branch/conditional source used
```

PSS-2 fails if:

```text
valid finalized profile source exits non-zero
manifest omits compiler_profile_id
manifest compiler_profile_id differs from expected source id
stdout is not compiler_result JSON
success output is written outside temp root
```

---

## Refusal / Negative Case Criteria

The first profile-source smoke should include both refusal classes.

### PSS-3: Preflight Refusal

PSS-3 passes only if all are true:

```text
exit_status != 0
stdout == ""
stderr has one stable refusal line
stderr does not echo raw file contents
stderr does not include parser backtrace
stderr does not include bare loader-status/runtime-readiness tokens
OUT.igapp is absent
OUT.compilation_report.json is absent
profile-source report JSON is absent
```

Accepted preflight variants:

```text
malformed_profile_source.json
missing profile-source path
```

The summary must record which variant was used.

### PSS-4: Semantic Refusal

PSS-4 passes only if all are true:

```text
exit_status != 0
stdout parses as compiler_result JSON
compiler_result.status is non-ok
stderr is empty
OUT.igapp is absent
OUT.compilation_report.json is present
diagnostics or report include qualified compiler_profile_source.* vocabulary
no bare loader-status/runtime-readiness token is used as status
```

Expected semantic refusal fixture:

```text
semantic_profile_source_wrong_kind.json
```

Expected qualified vocabulary:

```text
compiler_profile_source.wrong_kind
```

If a future authorization chooses success-only profile-source smoke, the result
cannot be PASS under this criteria. It must be HOLD with:

```text
hold_reason: profile_source_refusal_cases_not_exercised
```

---

## NB-1 Refusal-Kind Hygiene Handling

R173 accepted a non-blocking note: `type_mismatch.ig` and
`unresolved_symbol.ig` were recorded as `parse_error` even though their compiler
result status was `oof`.

For this smoke, result packets must use refusal-kind labels that match observed
behavior:

| Case type | Required `refusal_kind` |
| --- | --- |
| CLI profile-source path/JSON preflight | `profile_source_preflight` |
| Semantic profile-source wrong-kind/unfinalized/runtime-authority refusal | `profile_source_semantic_refusal` |
| Source parse refusal, if included | `source_parse_error` |
| Type mismatch / unresolved symbol, if included | `oof` |

Derivation:

```text
refusal_kind_hygiene_status == "pass" -> eligible for PASS
behavior passes but refusal_kind labels are stale -> HOLD, not FAIL
behavior itself violates refusal expectations -> FAIL
```

Summary JSON must include:

```text
refusal_kind_hygiene_status
refusal_kind_hygiene_notes
```

This prevents stale labels from becoming a false behavioral failure while still
keeping the future release-readiness packet clean enough for acceptance.

---

## Required Summary / Result Packet Shape

Recommended durable path if execution is later authorized:

```text
igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/$RUN_ID/profile_source_install_smoke_summary.json
```

Required top-level fields:

```json
{
  "kind": "compiler_release_profile_source_install_smoke_summary",
  "format_version": "0.1.0",
  "card": "S3-R175-C?-I",
  "track": "compiler-release-profile-source-install-smoke-v0",
  "status": "PASS|HOLD|FAIL",
  "authorized_by": "S3-R175-C?-A",
  "run_id": "S3R175...",
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

Required `package`:

```json
{
  "gem_name": "igniter_lang",
  "version": "0.1.0.pre.stage2",
  "built_gem_path": "/private/tmp/.../igniter_lang-0.1.0.pre.stage2.gem",
  "built_gem_sha256": "sha256:<64 hex>",
  "executable_expected": "igc",
  "executable_observed": "igc"
}
```

Required `environment`:

```json
{
  "ruby_version": "...",
  "gem_version": "...",
  "smoke_root": "/private/tmp/igniter_lang_profile_source_install_smoke_$RUN_ID",
  "gem_home": "/private/tmp/.../gem_home",
  "gem_path": "/private/tmp/.../gem_home",
  "bin_dir": "/private/tmp/.../bin",
  "cwd_for_installed_checks": "/private/tmp",
  "repo_relative_i_used": false,
  "rubylib_points_to_repo": false,
  "repo_path_leak_observed": false
}
```

Required `profile_source_inputs` entry shape:

```json
{
  "name": "finalized_profile_source",
  "source_path": "igniter-lang/experiments/.../finalized_profile_source.json",
  "copied_to_temp": true,
  "sha256": "sha256:<64 hex>",
  "input_kind": "valid_finalized|invalid_json|semantic_wrong_kind",
  "finalization_performed_by_smoke": false,
  "discovery_or_defaulting_used": false
}
```

Required `success_cases` entry shape:

```json
{
  "id": "PSS-2",
  "source": "add_baseline.ig",
  "profile_source": "finalized_profile_source.json",
  "cmd_shape": "igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json",
  "exit_status": 0,
  "result_status": "ok",
  "igapp_written": true,
  "manifest_compiler_profile_id": "compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7",
  "expected_compiler_profile_id": "compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7",
  "pass": true
}
```

Required `refusal_cases` entry shape:

```json
{
  "id": "PSS-3",
  "source": "add_baseline.ig",
  "profile_source": "malformed_profile_source.json",
  "refusal_kind": "profile_source_preflight",
  "exit_status": 1,
  "stdout_shape": "empty",
  "stderr_shape": "one_line_text",
  "igapp_written": false,
  "compilation_report_written": false,
  "pass": true
}
```

```json
{
  "id": "PSS-4",
  "source": "add_baseline.ig",
  "profile_source": "semantic_profile_source_wrong_kind.json",
  "refusal_kind": "profile_source_semantic_refusal",
  "exit_status": 1,
  "stdout_shape": "compiler_result_json",
  "result_status": "non_ok",
  "qualified_diagnostic_prefix": "compiler_profile_source.",
  "igapp_written": false,
  "compilation_report_written": true,
  "pass": true
}
```

---

## Required Non-Claims Fields

`non_claims` must include all:

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

## Artifact Cleanup / Retention Policy

Allowed temp root:

```text
/private/tmp/igniter_lang_profile_source_install_smoke_$RUN_ID/
```

Allowed temp artifacts:

```text
built .gem
isolated gem home
isolated bindir
copied source/profile fixtures
success .igapp output
refusal stdout/stderr captures
smoke-local working JSON
```

Durable repo artifact, if execution is later authorized:

```text
experiments/compiler_release_profile_source_install_smoke_v0/out/$RUN_ID/profile_source_install_smoke_summary.json
```

Do not retain in repo:

```text
built .gem
gem home
bindir
temp copied corpus
generated .igapp
refusal output files
profile-source copies
full command logs beyond summary excerpts
```

PSS-8 passes only if:

```text
retained_summary_path exists
retain_built_gem == false
cleanup_isolated_gem_home == true
cleanup_temp_root == "after summary written" or equivalent
positive_igapp_outputs == "temp only; not retained in repo"
profile_source_copies == "temp only; not retained in repo"
```

HOLD if cleanup cannot be verified due to interrupted run. FAIL if temp
artifacts are committed or durable repo outputs include generated `.igapp` or
gem artifacts.

---

## PASS / HOLD / FAIL Derivation

### PASS

Status is PASS only when:

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

Status is HOLD when behavior is inconclusive or criteria are incomplete without
evidence of behavioral regression:

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

HOLD must include one or more machine-readable `hold_reasons`.

### FAIL

Status is FAIL when bounded behavior regresses or a closed surface opens:

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

FAIL must include one or more machine-readable `failed_checks`.

---

## Compact Criteria Matrix

| ID | PASS | HOLD | FAIL |
| --- | --- | --- | --- |
| PSS-0 | isolated build/install/require proven | package mechanics inconclusive | repo path leak or repo-local load used |
| PSS-1 | installed `$BIN_DIR/igc` with explicit path flag only | command evidence incomplete | repo CLI, inline JSON, named lookup, discovery/defaulting |
| PSS-2 | valid profile source success and expected manifest id | success case omitted | valid profile source fails or id mismatch |
| PSS-3 | preflight refusal stderr-only/no artifacts | preflight case omitted | preflight writes `.igapp` or report |
| PSS-4 | semantic refusal compiler_result/report/no `.igapp` | semantic case omitted | semantic refusal writes `.igapp` or lacks qualified diagnostic |
| PSS-5 | no finalization/discovery/defaulting | evidence incomplete | any finalization/discovery/defaulting observed |
| PSS-6 | refusal labels match behavior | stale labels only | behavior violates refusal shape |
| PSS-7 | all non-claims true | non-claim field missing | any closed-surface claim/action observed |
| PSS-8 | only summary retained | cleanup verification inconclusive | temp artifacts committed/retained in repo |

---

## Non-Authorization

This track does not authorize:

```text
smoke execution
code edits
release execution
public release/demo claims
RubyGems publish
version edits
gemspec/package metadata edits
git tag creation
git push
signing
deployment
profile finalization
profile discovery/defaulting
public API/CLI widening
branch/conditional support claim
loader/report or CompatibilityReport behavior
parser/classifier/typechecker/SemanticIR/assembler changes
compiler/library behavior changes
PROP-036 or PROP-038 mutation
RuntimeMachine/Gate 3/Ledger/TBackend/BiHistory/stream/OLAP/cache/production behavior
Spark or Ruby Framework claims
```

---

## Handoff

```text
Card: S3-R175-C2-P1
Agent: [Profile Source Smoke Criteria Analyst]
Role: release-readiness-agent
Track: compiler-release-profile-source-smoke-extension-criteria-v0
Status: done

[D] Decisions
- Define PSS-0..PSS-8 as the criteria set for a possible profile-source install
  smoke extension.
- PASS requires installed package isolation, success case, both refusal classes,
  refusal-kind hygiene, non-claims, and temp-only artifacts.
- HOLD is used for inconclusive package mechanics or stale refusal labels with
  otherwise correct behavior.
- FAIL is used for bounded behavior regressions or closed-surface leaks.

[S] Signals
- R173/R174 installed package readiness is accepted only for local package/
  install smoke.
- Profile-source smoke is a confidence extension for the already-landed
  `--compiler-profile-source PATH.json` transport, not a release/public claim.

[T] Tests / Proofs
- No smoke run.
- No code edited.

[R] Recommendation
- If C4-A authorizes execution, require the summary packet shape in this track.
- Preserve branch/conditional exclusion and all release/public/runtime non-claims.

[Next]
- Pressure-review C1 boundary + C2 criteria before any execution decision.
```
