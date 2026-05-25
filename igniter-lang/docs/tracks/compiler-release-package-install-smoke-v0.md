# Compiler Release Package Install Smoke v0

Card: S3-R173-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: compiler-release-package-install-smoke-v0
Route: UPDATE
Status: done
Date: 2026-05-25

Depends on:
- S3-R172-C4-A
- S3-R171-C3-A

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-authorization-review-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-boundary-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-criteria-v0.md`
- `igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round172-status-curation-v0.md`
- `igniter-lang/docs/cards/S3/S3-R173.md`

---

## Smoke Execution

Script:

```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/package_install_smoke_v0.rb
```

Run ID:

```text
S3R173C1I_20260525T063543Z
```

Temp root:

```text
/private/tmp/igniter_lang_package_install_smoke_S3R173C1I_20260525T063543Z
```

Durable summary:

```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json
```

---

## Top-Level Result

```text
status: PASS
failed_checks: 0
hold_reasons: 0
```

---

## PKG Check Results

| ID | Check | Status |
| --- | --- | --- |
| PKG-0 | gemspec syntax check | PASS |
| PKG-1 | build local gem | PASS |
| PKG-2 | isolated local install; `igc` executable present | PASS |
| PKG-3 | `require "igniter_lang"` without repo `-I`; no path leak | PASS |
| PKG-4 | installed `igc compile` — 5/5 positive corpus | PASS |
| PKG-5 | installed `igc compile` refusal — 3/3 negative corpus | PASS |

---

## Command Matrix Summary

| Step | Command Shape | Exit | Pass |
| --- | --- | --- | --- |
| PKG-0 | `ruby -c igniter_lang.gemspec` | 0 | ✅ |
| PKG-1 | `gem build igniter_lang.gemspec --output $BUILD_DIR/igniter_lang-0.1.0.pre.stage2.gem` | 0 | ✅ |
| PKG-2 | `gem install --local --force --no-document --install-dir $GEM_HOME --bindir $BIN_DIR $GEM_PATH_LOCAL` | 0 | ✅ |
| PKG-3 | `ruby -e 'require "igniter_lang"; ...'` (GEM_HOME=$GEM_HOME_DIR, cwd=/private/tmp) | 0 | ✅ |
| PKG-4 | `$BIN_DIR/igc compile add_baseline.ig --out $OUT/add_baseline.igapp` | 0 | ✅ |
| PKG-4 | `$BIN_DIR/igc compile boolean_gate.ig --out $OUT/boolean_gate.igapp` | 0 | ✅ |
| PKG-4 | `$BIN_DIR/igc compile integer_arithmetic.ig --out $OUT/integer_arithmetic.igapp` | 0 | ✅ |
| PKG-4 | `$BIN_DIR/igc compile multi_input_diverse.ig --out $OUT/multi_input_diverse.igapp` | 0 | ✅ |
| PKG-4 | `$BIN_DIR/igc compile poc_derived.ig --out $OUT/poc_derived.igapp` | 0 | ✅ |
| PKG-5 | `$BIN_DIR/igc compile parse_refusal.ig --out $OUT/parse_refusal_should_not_exist.igapp` | 1 | ✅ |
| PKG-5 | `$BIN_DIR/igc compile type_mismatch.ig --out $OUT/type_mismatch_should_not_exist.igapp` | 1 | ✅ |
| PKG-5 | `$BIN_DIR/igc compile unresolved_symbol.ig --out $OUT/unresolved_symbol_should_not_exist.igapp` | 1 | ✅ |

Installed CLI command used for PKG-4/PKG-5: `igc compile SOURCE --out OUT.igapp`

`igniter-lang compile` was not used.

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
GEM_HOME:             /private/tmp/.../gem_home   (isolated)
GEM_PATH:             /private/tmp/.../gem_home   (isolated)
repo_relative_i_used: false
rubylib_points_to_repo: false
repo_path_leak_observed: false
```

PKG-3 verified that `Gem.loaded_specs["igniter_lang"].full_gem_path` is inside
the isolated temp gem home, not the repo checkout. No `ruby -I igniter-lang/lib`
was used for installed checks. The installed `$BIN_DIR/igc` binary was called
directly for PKG-4 and PKG-5.

---

## Corpus Results

### Positive corpus (5/5 PASS)

| Source | Exit | igapp written | Pass |
| --- | --- | --- | --- |
| `add_baseline.ig` | 0 | ✅ | ✅ |
| `boolean_gate.ig` | 0 | ✅ | ✅ |
| `integer_arithmetic.ig` | 0 | ✅ | ✅ |
| `multi_input_diverse.ig` | 0 | ✅ | ✅ |
| `poc_derived.ig` | 0 | ✅ | ✅ |

### Refusal corpus (3/3 PASS)

| Source | Exit | igapp absent | Refusal observed | Pass |
| --- | --- | --- | --- | --- |
| `parse_refusal.ig` | 1 | ✅ | ✅ | ✅ |
| `type_mismatch.ig` | 1 | ✅ | ✅ | ✅ |
| `unresolved_symbol.ig` | 1 | ✅ | ✅ | ✅ |

---

## Artifact Policy

```text
temp_root:              /private/tmp/igniter_lang_package_install_smoke_S3R173C1I_20260525T063543Z/
retained_summary_path:  igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json
built_gem_retained:     no  (temp only; SHA256 recorded)
isolated_gem_home:      cleaned (PASS cleanup)
bin_dir:                cleaned (PASS cleanup)
corpus_temp_copy:       cleaned (PASS cleanup)
positive_igapp_outputs: temp only (not retained in repo)
refusal_output_paths:   absent (verified PASS)
```

---

## Non-Claims

```text
no_public_release_claim:                               true
no_public_demo_claim:                                  true
no_rubygems_publish:                                   true
no_public_availability_claim:                          true
no_version_change:                                     true
no_git_tag:                                            true
no_push:                                               true
no_signing:                                            true
no_deploy:                                             true
no_release_execution_beyond_smoke:                     true
no_production_runtime:                                 true
no_spark_integration:                                  true
no_ruby_framework_compatibility_claim:                 true
no_branch_conditional_claim:                           true
no_runtime_ledger_tbackend_bihistory_stream_olap_cache_claim: true
```

This smoke is local evidence only. It does not establish installed-gem/package
readiness until a later acceptance decision says so.

No version file was edited. No git tag was created. No push was performed. No
gem was published. No signing. No deployment. No code surfaces changed.

---

## Closed Surfaces

This card does not authorize:

- installed-gem/package readiness claim;
- public release or demo claims;
- RubyGems publish;
- version file edits;
- gemspec edits;
- git tag creation;
- git push;
- signing;
- deployment;
- profile-source smoke extension;
- public API/CLI widening;
- branch/conditional implementation;
- parser, classifier, TypeChecker, SemanticIR, assembler changes;
- compiler/library behavior changes;
- loader/report, `CompilationReport`, `CompilerResult`, or CompatibilityReport
  widening;
- `.ilk`, manifest, sidecar, artifact hash, or golden migration;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, deployment, or demo work.

---

## Compact Receipt

```text
card:                          S3-R173-C1-I
track:                         compiler-release-package-install-smoke-v0
status:                        PASS
run_id:                        S3R173C1I_20260525T063543Z
gem_name:                      igniter_lang
version:                       0.1.0.pre.stage2
executable_used:               igc compile
repo_relative_i_used:          false
PKG-0:                         PASS (gemspec syntax)
PKG-1:                         PASS (gem build)
PKG-2:                         PASS (isolated install; igc present)
PKG-3:                         PASS (require no repo -I; no path leak)
PKG-4:                         PASS (5/5 positive corpus)
PKG-5:                         PASS (3/3 refusal corpus)
failed_checks:                 0
hold_reasons:                  0
installed_gem_package_readiness: not_established (requires acceptance decision)
public_claims_authorized:      no
version_change_authorized:     no
git_tag_authorized:            no
branch_conditional_if_expr:    excluded_from_first_rc
spark_status:                  excluded_non_authorizing
ruby_ledger_hardening:         independent_non_blocking
no_code_edited:                yes
no_version_file_edited:        yes
no_tag_created:                yes
no_push_performed:             yes
no_gem_published:              yes
summary_json:                  igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json
```
