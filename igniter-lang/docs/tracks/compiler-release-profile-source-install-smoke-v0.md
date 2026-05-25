# Compiler Release Profile-Source Install Smoke v0

Card: S3-R176-C1-I
Agent: [Implementation Agent]
Role: implementation-agent
Track: compiler-release-profile-source-install-smoke-v0
Route: UPDATE
Status: done
Date: 2026-05-25

Depends on:
- S3-R175-C4-A

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-authorization-review-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-boundary-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-criteria-v0.md`
- `igniter-lang/docs/tracks/stage3-round175-status-curation-v0.md`
- `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/finalized_profile_source.json`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/malformed_profile_source.json`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/semantic_profile_source_wrong_kind.json`

---

## Smoke Execution

Script:

```text
igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/profile_source_install_smoke_v0.rb
```

Run ID:

```text
S3R176C1I_20260525T101425Z
```

Temp root:

```text
/private/tmp/igniter_lang_profile_source_install_smoke_S3R176C1I_20260525T101425Z/
```

Durable summary:

```text
igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json
```

---

## Top-Level Result

```text
status: PASS
failed_checks: 0
hold_reasons: 0
refusal_kind_hygiene_status: pass
```

---

## PSS Criteria Results

| ID | Name | Status |
| --- | --- | --- |
| PSS-0 | Package setup isolation (build / install / require / path) | ✅ PASS |
| PSS-1 | Installed command shape (`$BIN_DIR/igc` + explicit path flag only) | ✅ PASS |
| PSS-2 | Profile-source success; expected `manifest.compiler_profile_id` | ✅ PASS |
| PSS-3 | Profile-source preflight refusal (malformed JSON) | ✅ PASS |
| PSS-4 | Profile-source semantic refusal (wrong-kind object) | ✅ PASS |
| PSS-5 | No discovery / finalization / defaulting | ✅ PASS |
| PSS-6 | Refusal-kind hygiene | ✅ PASS |
| PSS-7 | Non-claims and closed surfaces | ✅ PASS |
| PSS-8 | Artifact cleanup / retention | ✅ PASS |

---

## Command Matrix

| ID | Kind | Exit | Pass |
| --- | --- | --- | --- |
| PSS-0A | gemspec syntax check — `ruby -c igniter_lang.gemspec` | 0 | ✅ |
| PSS-0B | gem build → `igniter_lang-0.1.0.pre.stage2.gem` | 0 | ✅ |
| PSS-0C | isolated gem install; `igc` present at `$BIN_DIR/igc` | 0 | ✅ |
| PSS-0D | `require "igniter_lang"` from `/private/tmp`; no repo path leak | 0 | ✅ |
| PSS-2 | `$BIN_DIR/igc compile add_baseline.ig --out add_baseline_profiled.igapp --compiler-profile-source finalized_profile_source.json` | 0 | ✅ |
| PSS-3 | `$BIN_DIR/igc compile add_baseline.ig --out preflight_should_not_exist.igapp --compiler-profile-source malformed_profile_source.json` | 1 | ✅ |
| PSS-4 | `$BIN_DIR/igc compile add_baseline.ig --out wrong_kind_should_not_exist.igapp --compiler-profile-source semantic_profile_source_wrong_kind.json` | 1 | ✅ |

Installed CLI command shape used: `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`

`igniter-lang compile` was not used. Repo-local `bin/igc` was not used.

---

## Package Facts

```text
gem_name:             igniter_lang
version:              0.1.0.pre.stage2
executable_expected:  igc
executable_observed:  igc
built_gem_sha256:     sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
ruby_version:         ruby 3.2.2 (2023-03-30 revision e51014f9c0) [arm64-darwin25]
gem_version:          4.0.10
```

---

## Isolation Proof

```text
GEM_HOME:                    /private/tmp/.../gem_home  (isolated)
GEM_PATH:                    /private/tmp/.../gem_home  (isolated)
repo_relative_i_used:        false
rubylib_points_to_repo:      false
repo_path_leak_observed:     false
```

PSS-0D verified that `Gem.loaded_specs["igniter_lang"].full_gem_path` is inside
the isolated temp gem home, not the repo checkout.

---

## PSS-2: Profile-Source Success

```text
profile_source:               finalized_profile_source.json
exit_status:                  0
result_status:                ok
igapp_written:                true
manifest.compiler_profile_id: compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
expected_compiler_profile_id: compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
profile_id_match:             true
```

The `manifest.compiler_profile_id` emitted by the installed package matches the
value declared in `finalized_profile_source.json` and the expected value from the
criteria doc.

---

## PSS-3: Preflight Refusal

```text
profile_source:               malformed_profile_source.json
preflight_variant:            malformed_json
refusal_kind:                 profile_source_preflight
exit_status:                  1
stdout_shape:                 empty
stderr_shape:                 one_line_text
stderr:                       "compiler profile source file must contain valid JSON"
igapp_written:                false
compilation_report_written:   false
```

Correct PSS-3/PSS-4 distinction: preflight refusal is CLI-owned path/JSON
validation before compiler invocation. No compilation report is written.

---

## PSS-4: Semantic Refusal

```text
profile_source:               semantic_profile_source_wrong_kind.json
refusal_kind:                 profile_source_semantic_refusal
exit_status:                  1
stdout_shape:                 compiler_result_json
result_status:                assembler_refused
stderr_shape:                 empty
igapp_written:                false
compilation_report_written:   true
qualified_diagnostic_prefix:  compiler_profile_source.
observed_diagnostic:          add_baseline: compiler_profile_source.wrong_kind: "not_a_compiler_profile_id_source"
diagnostic_source:            stdout_compiler_result
```

Correct PSS-3/PSS-4 distinction: semantic refusal passes CLI preflight and fails
inside the compiler/assembler path with a qualified `compiler_profile_source.*`
diagnostic. Compilation report is written; no igapp is written.

---

## Refusal-Kind Hygiene (PSS-6)

```text
refusal_kind_hygiene_status: pass
```

Labels derived from observed exit/artifact/diagnostic behavior:

| Case | Observed behavior | refusal_kind |
| --- | --- | --- |
| PSS-3 malformed JSON | exit 1; stderr-only; no report | `profile_source_preflight` |
| PSS-4 wrong-kind object | exit 1; compiler_result JSON; report present | `profile_source_semantic_refusal` |

NB-1 from R173 (stale `parse_error` label) is not reproduced here. Refusal
labels match observed behavior.

---

## Profile-Source Inputs

All profile sources were loaded from existing repo fixtures and copied to the
isolated temp root. No finalization, discovery, defaulting, named lookup, inline
JSON, or env/config/sidecar lookup was performed.

| Name | Input kind | SHA256 |
| --- | --- | --- |
| `finalized_profile_source.json` | `valid_finalized` | (recorded in summary JSON) |
| `malformed_profile_source.json` | `invalid_json` | (recorded in summary JSON) |
| `semantic_profile_source_wrong_kind.json` | `semantic_wrong_kind` | (recorded in summary JSON) |

---

## Artifact Policy

```text
temp_root:                /private/tmp/igniter_lang_profile_source_install_smoke_S3R176C1I_20260525T101425Z/
retained_summary_path:    igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json
built_gem_retained:       no (temp only; SHA256 recorded)
isolated_gem_home:        cleaned (PASS cleanup)
bin_dir:                  cleaned (PASS cleanup)
fixture_temp_copies:      cleaned (PASS cleanup)
source_temp_copies:       cleaned (PASS cleanup)
build_dir:                cleaned (PASS cleanup)
positive_igapp_outputs:   temp only; not retained in repo
```

---

## Non-Claims

All 24 required non-claims are true:

```text
no_release_execution:                                   true
no_public_release_claim:                                true
no_public_demo_claim:                                   true
no_rubygems_publish:                                    true
no_public_availability_claim:                           true
no_version_change:                                      true
no_gemspec_metadata_change:                             true
no_git_tag:                                             true
no_push:                                                true
no_signing:                                             true
no_deploy:                                              true
no_profile_finalization:                                true
no_profile_discovery:                                   true
no_profile_defaulting:                                  true
no_named_profile_lookup:                                true
no_inline_json:                                         true
no_env_config_sidecar_lookup:                           true
no_public_api_cli_widening_beyond_profile_source_path:  true
no_loader_report_compatibility_report_claim:            true
no_runtime_ledger_tbackend_bihistory_stream_olap_cache_claim: true
no_production_runtime:                                  true
no_spark_integration:                                   true
no_ruby_framework_compatibility_claim:                  true
no_branch_conditional_claim:                            true
```

This smoke is installed-package profile-source confidence evidence only. It does
not establish installed-gem/package readiness or public release readiness until a
later acceptance decision.

---

## Closed Surfaces

This card does not authorize:

- installed-gem/package readiness claim;
- public release or demo claims;
- release execution;
- RubyGems publish;
- version file edits;
- gemspec/package metadata edits;
- git tag creation;
- git push;
- signing;
- deployment;
- profile finalization / discovery / defaulting;
- named/generated profile lookup;
- inline JSON profile input;
- env/config/sidecar profile lookup;
- public API/CLI widening beyond `--compiler-profile-source PATH.json`;
- branch/conditional implementation;
- parser, classifier, TypeChecker, SemanticIR, assembler changes;
- compiler/library behavior changes;
- loader/report, `CompilationReport`, `CompilerResult`, or CompatibilityReport
  widening beyond temp smoke output;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, deployment, or demo work.

No compiler/library code was edited. No version file was edited. No tag was
created. No push was performed. No gem was published.

---

## Compact Receipt

```text
card:                          S3-R176-C1-I
track:                         compiler-release-profile-source-install-smoke-v0
status:                        PASS
run_id:                        S3R176C1I_20260525T101425Z
gem_name:                      igniter_lang
version:                       0.1.0.pre.stage2
executable_used:               igc compile --compiler-profile-source PATH.json
repo_relative_i_used:          false
repo_path_leak_observed:       false
PSS-0:                         PASS (isolated build/install/require)
PSS-1:                         PASS (installed $BIN_DIR/igc + explicit path flag)
PSS-2:                         PASS (valid finalized source; igapp; compiler_profile_id matches)
PSS-3:                         PASS (preflight refusal; stderr-only; no igapp; no report)
PSS-4:                         PASS (semantic refusal; compiler_result JSON; report; qualified diag)
PSS-5:                         PASS (no finalization/discovery/defaulting)
PSS-6:                         PASS (refusal-kind labels match behavior)
PSS-7:                         PASS (all non-claims true; closed surfaces intact)
PSS-8:                         PASS (only summary retained in repo)
refusal_kind_hygiene_status:   pass
failed_checks:                 0
hold_reasons:                  0
manifest_compiler_profile_id:  compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
PSS-3_refusal_kind:            profile_source_preflight
PSS-4_refusal_kind:            profile_source_semantic_refusal
installed_gem_package_readiness: not_established (requires separate acceptance decision)
public_claims_authorized:      no
version_change_authorized:     no
git_tag_authorized:            no
branch_conditional_if_expr:    excluded_from_first_rc
spark_status:                  excluded_non_authorizing
no_code_edited:                yes
no_version_file_edited:        yes
no_tag_created:                yes
no_push_performed:             yes
no_gem_published:              yes
summary_json:                  igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json
```
