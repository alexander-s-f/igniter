# Compiler Release Combined Post-Prep Smoke v0

Card: S3-R183-C2-I
Agent: [Package Agent / Implementation Agent]
Role: package-agent
Track: compiler-release-combined-post-prep-smoke-v0
Route: UPDATE
Status: done
Date: 2026-05-26

Depends on:
- S3-R183-C1-A

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-authorization-review-v0.md`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`
- `igniter-lang/RELEASE_NOTES.md`
- `igniter-lang/lib/igniter_lang/version.rb`
- Prior smoke scripts (R173, R176) for corpus / fixture reference only

---

## Smoke Execution

Script:

```text
igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/combined_post_prep_smoke_v0.rb
```

Run ID:

```text
S3R183C2I_20260526T143139Z
```

Temp root:

```text
/private/tmp/igniter_lang_combined_post_prep_smoke_S3R183C2I_20260526T143139Z/
```

Durable summary:

```text
igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json
```

---

## Top-Level Result

```text
status:        PASS
failed_checks: 0
hold_reasons:  0
```

---

## Artifact

```text
gem_name:          igniter_lang
version:           0.1.0.alpha.1
version_match:     true
built_gem_sha256:  sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
ruby_version:      ruby 3.2.2 (2023-03-30 revision e51014f9c0) [arm64-darwin25]
```

Prior invalidated SHA256 (0.1.0.pre.stage2):
`sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a`

---

## Command Matrix

| ID | Kind | Exit | Pass |
| --- | --- | --- | --- |
| CM-0 | version check — `ruby -I lib -e '...; puts IgniterLang::VERSION'` → `0.1.0.alpha.1` | 0 | ✅ |
| CM-1 | gemspec syntax — `ruby -c igniter_lang.gemspec` | 0 | ✅ |
| CM-2 | gem build → `igniter_lang-0.1.0.alpha.1.gem` | 0 | ✅ |
| CM-3 | artifact SHA256 captured | — | ✅ |
| CM-4 | packaged files: README.md ✅ RELEASE_NOTES.md ✅ bin/igc ✅ version_rb ✅ | — | ✅ |
| CM-5 | isolated gem install; `igc` present at `$BIN_DIR/igc` | 0 | ✅ |
| CM-6 | `igc` present and executable | — | ✅ |
| CM-7 | `require "igniter_lang"` from `/private/tmp`; no repo path leak | 0 | ✅ |
| CM-8 | positive compile corpus: 5/5 | 0 each | ✅ |
| CM-9 | refusal corpus: 3/3 | 1 each | ✅ |
| CM-10 | valid finalized profile-source success | 0 | ✅ |
| CM-11 | malformed JSON profile-source preflight refusal | 1 | ✅ |
| CM-12 | semantic wrong-kind profile-source refusal | 1 | ✅ |
| CM-13 | repo path leak scan — no leaks | — | ✅ |

CLI command shape used: `$BIN_DIR/igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]`

Repo-local `bin/igc` not used. No repo-relative `-I`. No repo `RUBYLIB`.

---

## Packaged File Proof (CM-4)

Built artifact `igniter_lang-0.1.0.alpha.1.gem` was inspected via `Gem::Package#contents`.

Required files confirmed present:

```text
README.md:         ✅ present
RELEASE_NOTES.md:  ✅ present
bin/igc:           ✅ present
lib/igniter_lang/version.rb: ✅ present
```

---

## Isolation Proof (CM-7)

```text
GEM_HOME:                    /private/tmp/.../gem_home  (isolated)
GEM_PATH:                    /private/tmp/.../gem_home  (isolated)
repo_relative_i_used:        false
rubylib_points_to_repo:      false
repo_path_leak_observed:     false
```

CM-7 verified that `Gem.loaded_specs["igniter_lang"].full_gem_path` is inside
the isolated temp gem home, not the repo checkout.

---

## CM-8: Positive Corpus Results

| Source | Exit | igapp | Status | Pass |
| --- | --- | --- | --- | --- |
| `add_baseline.ig` | 0 | ✅ | ok | ✅ |
| `boolean_gate.ig` | 0 | ✅ | ok | ✅ |
| `integer_arithmetic.ig` | 0 | ✅ | ok | ✅ |
| `multi_input_diverse.ig` | 0 | ✅ | ok | ✅ |
| `poc_derived.ig` | 0 | ✅ | ok | ✅ |

5/5 PASS

---

## CM-9: Refusal Corpus Results

| Source | Exit | igapp absent | Refusal kind | Pass |
| --- | --- | --- | --- | --- |
| `parse_refusal.ig` | 1 | ✅ | `parse_refusal` | ✅ |
| `type_mismatch.ig` | 1 | ✅ | `oof` | ✅ |
| `unresolved_symbol.ig` | 1 | ✅ | `oof` | ✅ |

3/3 PASS

Note: `type_mismatch.ig` and `unresolved_symbol.ig` are labeled `oof` in this
smoke (forward-carrying R173 NB-1 learning — these are OOF-type refusals, not
parse errors).

---

## CM-10: Profile-Source Success

```text
profile_source:               finalized_profile_source.json
exit_status:                  0
result_status:                ok
igapp_written:                true
manifest.compiler_profile_id: compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
expected_compiler_profile_id: compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
profile_id_match:             true
```

---

## CM-11: Preflight Refusal

```text
profile_source:               malformed_profile_source.json
refusal_kind:                 profile_source_preflight
exit_status:                  1
stdout_shape:                 empty
stderr_shape:                 one_line_text
stderr:                       "compiler profile source file must contain valid JSON"
igapp_written:                false
compilation_report_written:   false
```

---

## CM-12: Semantic Refusal

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

---

## CM-13: Repo Path Leak Scan

```text
surfaces_scanned:   stdout/stderr/report for all 14 command steps
leaked_surfaces:    []
repo_path_leak:     false
```

---

## Artifact Policy

```text
temp_root:                /private/tmp/igniter_lang_combined_post_prep_smoke_S3R183C2I_20260526T143139Z/
durable_summary:          igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json
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

This smoke is post-prep local evidence only for `igniter_lang 0.1.0.alpha.1`.
It does not establish public release readiness or authorize publish until a
later acceptance decision.

---

## Closed Surfaces

This card does not authorize:

- release execution;
- RubyGems publish;
- git tag creation;
- git push;
- version/tag/push/publish/sign/deploy;
- public release/demo claims;
- production readiness claims;
- stable release claims;
- all grammar support claims;
- branch/conditional `if_expr`;
- profile finalization/discovery/defaulting;
- public API/CLI widening;
- loader/report or CompatibilityReport readiness;
- runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache behavior;
- Spark integration;
- Ruby Framework compatibility claims;
- compiler/runtime behavior changes.

No compiler/library code was edited. No version file was edited. No tag was
created. No push was performed. No gem was published.

---

## Compact Receipt

```text
card:                          S3-R183-C2-I
track:                         compiler-release-combined-post-prep-smoke-v0
status:                        PASS
run_id:                        S3R183C2I_20260526T143139Z
gem_name:                      igniter_lang
version:                       0.1.0.alpha.1
built_gem_sha256:              sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
prior_sha256_superseded:       sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
packaged_readme:               true
packaged_release_notes:        true
packaged_bin_igc:              true
isolated_install:              PASS
repo_path_leak:                false
repo_relative_i_used:          false
CM-0:                          PASS (version=0.1.0.alpha.1, match=true)
CM-1:                          PASS (gemspec syntax OK)
CM-2:                          PASS (gem build)
CM-3:                          PASS (SHA256 captured)
CM-4:                          PASS (README + RELEASE_NOTES + bin/igc in artifact)
CM-5:                          PASS (isolated install)
CM-6:                          PASS (igc executable)
CM-7:                          PASS (require; no leak)
CM-8:                          PASS (5/5 positive corpus)
CM-9:                          PASS (3/3 refusal corpus; type_mismatch + unresolved_symbol labeled oof)
CM-10:                         PASS (profile-source success; manifest.compiler_profile_id matches)
CM-11:                         PASS (preflight refusal; stderr-only; no igapp; no report)
CM-12:                         PASS (semantic refusal; compiler_result JSON; report; qualified diag)
CM-13:                         PASS (no repo path leaks)
failed_checks:                 0
hold_reasons:                  0
manifest_compiler_profile_id:  compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
CM-11_refusal_kind:            profile_source_preflight
CM-12_refusal_kind:            profile_source_semantic_refusal
cleanup:                       complete
public_release_readiness:      not_established (requires separate acceptance decision)
public_claims_authorized:      no
release_execution_authorized:  no
tag_push_publish_authorized:   no
no_code_edited:                yes
no_version_file_edited:        yes
no_tag_created:                yes
no_push_performed:             yes
no_gem_published:              yes
summary_json:                  igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json
```
