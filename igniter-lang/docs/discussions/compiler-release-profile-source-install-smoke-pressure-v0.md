# Compiler Release Profile-Source Install Smoke Pressure v0

Card: S3-R176-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: review-agent
Track: compiler-release-profile-source-install-smoke-pressure-v0
Route: UPDATE
Depends on: S3-R176-C1-I
Date: 2026-05-25

---

## Question

Does the S3-R176-C1-I profile-source install smoke evidence satisfy all
requirements from S3-R175-C4-A — PSS-0..PSS-8 all PASS, installed package
isolation proven, `$BIN_DIR/igc` used with no repo-local leakage, success case
proves expected manifest `compiler_profile_id`, PSS-3 preflight refusal writes no
`.igapp` and no compilation report, PSS-4 semantic refusal writes no `.igapp` and
does write a report with qualified `compiler_profile_source.*` diagnostics,
refusal-kind hygiene correct, non-claims all true, no temp artifacts retained in
repo beyond authorized summary, no public release/demo claim, no release
execution, no RubyGems publish, no version/tag/push/publish/sign/deploy, no
profile finalization/discovery/defaulting, no public API/CLI widening,
branch/conditional excluded, Spark absent?

---

## Evidence Read

- `igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json`
  (S3-R176-C1-I primary output)
- `igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-v0.md`
  (S3-R176-C1-I track doc)
- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-authorization-review-v0.md`
  (S3-R175-C4-A)
- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-criteria-v0.md`
  (S3-R175-C2-P1)
- `igniter-lang/docs/tracks/stage3-round175-status-curation-v0.md`
  (S3-R175-C5-S)

Additional read-only verification:

```bash
ls /private/tmp/igniter_lang_profile_source_install_smoke_S3R176C1I_20260525T101425Z/
ls /private/tmp/igniter_lang_profile_source_install_smoke_S3R176C1I_20260525T101425Z/out/
find experiments/compiler_release_profile_source_install_smoke_v0 -type f
```

---

## Check Review

### CHK-1: Summary status PASS is derived from PSS-0..PSS-8 criteria

**Result: PASS.**

Summary JSON top-level: `"status": "PASS"`.

Criteria block:

```text
PSS-0: PASS — isolated build/install/require proven; igc present; no repo path leak
PSS-1: PASS — installed $BIN_DIR/igc with explicit --compiler-profile-source PATH.json; no repo bin/igc; no inline JSON; no discovery
PSS-2: PASS — valid finalized profile source: exit 0; igapp written; compiler_profile_id matches
PSS-3: PASS — preflight refusal: non-zero exit; stderr-only one-line; no igapp; no report
PSS-4: PASS — semantic refusal: non-zero; compiler_result JSON; report present; qualified compiler_profile_source.* diagnostic; no igapp
PSS-5: PASS — no finalization/discovery/defaulting: all profile sources are caller-supplied temp file copies
PSS-6: PASS — refusal-kind labels match observed behavior
PSS-7: PASS — all non-claims present and true; no version/tag/push/publish/sign/deploy/release/public action
PSS-8: PASS — cleanup complete: GEM_HOME, BIN_DIR, fixtures, source, build removed; summary retained at durable path
```

All 9 criteria PASS. `failed_checks: []`, `hold_reasons: []`. Status derivation
is consistent with PSS-0..PSS-8 results. ✓

---

### CHK-2: Installed package isolation proven

**Result: PASS.**

PSS-0A: `ruby -c igniter_lang.gemspec` → exit 0, `Syntax OK`. ✓

PSS-0B: `gem build` → exit 0, gem artifact in temp build dir.
SHA256 matches accepted R173 gem: `sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a`. ✓

PSS-0C: `gem install --local --force --no-document --install-dir $GEM_HOME
--bindir $BIN_DIR` → exit 0; confirmed by command matrix:
`"igc_executable_present": true`, artifact:
`/private/tmp/igniter_lang_profile_source_install_smoke_S3R176C1I_20260525T101425Z/bin/igc`. ✓

PSS-0D: `ruby -e 'require "igniter_lang"; ...'` from `/private/tmp` cwd →
exit 0; stdout:
`load OK 0.1.0.pre.stage2 path=/private/tmp/igniter_lang_profile_source_install_smoke_S3R176C1I_20260525T101425Z/gem_home/gems/igniter_lang-0.1.0.pre.stage2`

The load path is inside the isolated temp gem home, not the repo checkout. The
require test explicitly `abort`s if `full_gem_path` contains the repo path. ✓

Environment:

```text
GEM_HOME: /private/tmp/.../gem_home    (isolated)
GEM_PATH: /private/tmp/.../gem_home    (isolated)
BIN_DIR:  /private/tmp/.../bin         (isolated)
cwd_for_installed_checks: /private/tmp (no repo-relative load)
repo_relative_i_used: false
rubylib_points_to_repo: false
repo_path_leak_observed: false
```

All PSS-0 isolation requirements are mechanically proven. ✓

---

### CHK-3: `$BIN_DIR/igc` used; not repo-local `bin/igc`

**Result: PASS.**

All three smoke commands use the installed binary at the isolated temp path:

```text
PSS-2: /private/tmp/.../bin/igc compile SOURCE --out OUT.igapp --compiler-profile-source ...
PSS-3: /private/tmp/.../bin/igc compile SOURCE --out preflight_should_not_exist.igapp --compiler-profile-source ...
PSS-4: /private/tmp/.../bin/igc compile SOURCE --out wrong_kind_should_not_exist.igapp --compiler-profile-source ...
```

Track doc confirms: "`igniter-lang compile` was not used. Repo-local `bin/igc`
was not used." `executable_observed: "igc"` in summary package block. ✓

---

### CHK-4: No repo-relative `-I` or repo `RUBYLIB`

**Result: PASS.**

Summary JSON environment:

```json
"repo_relative_i_used": false,
"rubylib_points_to_repo": false,
"repo_path_leak_observed": false
```

PSS-0D command does not use `-I`; env shape is `GEM_HOME=$GEM_HOME GEM_PATH=$GEM_HOME`.
No `RUBYLIB` pointing to repo is present in any command's env shape. ✓

---

### CHK-5: Success case proves expected manifest `compiler_profile_id`

**Result: PASS.**

PSS-2 success case from summary:

```json
"manifest_compiler_profile_id": "compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7",
"expected_compiler_profile_id": "compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7",
"profile_id_match": true
```

The `manifest.compiler_profile_id` emitted by the installed package exactly
matches the value specified in `finalized_profile_source.json` and the expected
value from S3-R175-C4-A:

```text
compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
```

PSS-2 criteria also require:
- `exit_status == 0` ✓ (command matrix PSS-2: exit 0)
- `compiler_result.status == "ok"` ✓ (stdout excerpt: `"status": "ok"`)
- `stderr is empty` ✓ (stderr_excerpt: `""`)
- `.igapp exists under temp out dir` ✓ (artifact: `out/add_baseline_profiled.igapp`)

Full success case criteria satisfied. ✓

---

### CHK-6: PSS-3 preflight refusal writes no `.igapp` and no compilation report

**Result: PASS.**

PSS-3 refusal case:

```json
"refusal_kind": "profile_source_preflight",
"exit_status": 1,
"stdout_shape": "empty",
"stderr_shape": "one_line_text",
"igapp_written": false,
"compilation_report_written": false
```

Observed stderr: `"compiler profile source file must contain valid JSON"`

This is a single stable refusal line. No raw file contents echoed, no parser
backtrace, no loader-status/runtime-readiness tokens. Stdout is empty.

Command matrix PSS-3: `exit_status: 1`, `stdout_excerpt: ""`,
`stderr_excerpt: "compiler profile source file must contain valid JSON"`,
`artifacts: []` — no `.igapp`, no compilation report in the artifacts list.

Preflight refusal correctly precedes compiler invocation; no compilation report
is produced. The PSS-3/PSS-4 distinction (preflight has no report, semantic has
report) is correctly observed here. ✓

---

### CHK-7: PSS-4 semantic refusal writes no `.igapp`, writes report, has qualified diagnostic

**Result: PASS.**

PSS-4 refusal case:

```json
"refusal_kind": "profile_source_semantic_refusal",
"exit_status": 1,
"stdout_shape": "compiler_result_json",
"result_status": "assembler_refused",
"stderr_shape": "empty",
"qualified_diagnostic_prefix": "compiler_profile_source.",
"qualified_diagnostic_observed": "add_baseline: compiler_profile_source.wrong_kind: \"not_a_compiler_profile_id_source\"",
"qualified_diagnostic_source": "stdout_compiler_result",
"igapp_written": false,
"compilation_report_written": true
```

Verification:

- `exit_status: 1` — non-zero ✓
- `stdout parses as compiler_result JSON` — stdout excerpt confirms `"kind": "compiler_result"`, `"status": "assembler_refused"` ✓
- `compiler_result.status is non-ok` — `assembler_refused` is non-ok ✓
- `stderr is empty` — `stderr_shape: "empty"` ✓
- `OUT.igapp is absent` — `igapp_written: false` ✓
- `OUT.compilation_report.json is present` — `compilation_report_written: true`;
  artifact: `wrong_kind_should_not_exist.compilation_report.json` ✓
- `diagnostics include qualified compiler_profile_source.* vocabulary` —
  `compiler_profile_source.wrong_kind` observed ✓
- `no bare loader-status/runtime-readiness token` — none observed ✓

The expected qualified vocabulary `compiler_profile_source.wrong_kind` from
S3-R175-C2-P1 is present. The `assembler_refused` result status is non-ok,
correctly reflecting the profile-source object failed inside the compiler/
assembler path. ✓

---

### CHK-8: Refusal-kind hygiene is correct

**Result: PASS.**

```text
refusal_kind_hygiene_status: "pass"
```

Hygiene notes in summary:

```text
PSS-3: refusal_kind = profile_source_preflight (CLI-owned path/JSON preflight)
PSS-4: refusal_kind = profile_source_semantic_refusal (compiler/assembler path)
Labels are derived from observed exit/artifact/diagnostic behavior
```

This matches the S3-R175-C2-P1 PSS-6 required label table:

| Case type | Required | Observed | Match |
| --- | --- | --- | --- |
| CLI path/JSON preflight | `profile_source_preflight` | `profile_source_preflight` | ✓ |
| Semantic wrong-kind refusal | `profile_source_semantic_refusal` | `profile_source_semantic_refusal` | ✓ |

R173 NB-1 stale `parse_error` label is not reproduced here. The new specific
refusal-kind vocabulary correctly describes the CLI-preflight vs.
compiler/assembler-path distinction. ✓

---

### CHK-9: Non-claims are all true

**Result: PASS.**

All 24 non-claims fields in the summary JSON are `true`:

```text
no_release_execution                                        true
no_public_release_claim                                     true
no_public_demo_claim                                        true
no_rubygems_publish                                         true
no_public_availability_claim                                true
no_version_change                                           true
no_gemspec_metadata_change                                  true
no_git_tag                                                  true
no_push                                                     true
no_signing                                                  true
no_deploy                                                   true
no_profile_finalization                                     true
no_profile_discovery                                        true
no_profile_defaulting                                       true
no_named_profile_lookup                                     true
no_inline_json                                              true
no_env_config_sidecar_lookup                                true
no_public_api_cli_widening_beyond_profile_source_path       true
no_loader_report_compatibility_report_claim                 true
no_runtime_ledger_tbackend_bihistory_stream_olap_cache_claim true
no_production_runtime                                       true
no_spark_integration                                        true
no_ruby_framework_compatibility_claim                       true
no_branch_conditional_claim                                 true
```

The C2-P1 criterion: "Any false value in `non_claims` is FAIL." All 24 are
true; no FAIL triggered. ✓

---

### CHK-10: No temp artifacts retained in repo beyond authorized summary and script

**Result: PASS (with NB-1 for incomplete temp root cleanup).**

Read-only filesystem verification:

Repo artifacts (from `find experiments/compiler_release_profile_source_install_smoke_v0 -type f`):

```text
experiments/compiler_release_profile_source_install_smoke_v0/profile_source_install_smoke_v0.rb
experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json
```

Both are within the C4-A authorized write scope:
`igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/**`. ✓

No `.igapp`, `.gem`, compilation report, fixture copies, gem home, or bindir
are present in the repo. ✓

However (see NB-1 below): the temp root at
`/private/tmp/igniter_lang_profile_source_install_smoke_S3R176C1I_20260525T101425Z/`
still exists. It contains an `out/` subdirectory with:

- `add_baseline_profiled.igapp` (the PSS-2 success output, a directory)
- `wrong_kind_should_not_exist.compilation_report.json` (PSS-4 semantic refusal report)

These artifacts are in `/private/tmp/` only — they are NOT in the repo. The
PSS-8 FAIL condition ("temp artifacts committed or durable repo outputs include
generated `.igapp` or gem artifacts") is not triggered.

The gem home, bin dir, fixture copies, source copies, and build dir within the
temp root have been cleaned. Only the `out/` subdirectory remains. The summary
`artifact_policy.cleanup_temp_root: "after summary written"` is inaccurate for
the `out/` subdirectory — cleanup was partial. (See NB-1.)

Core PSS-8 requirement: no repo artifacts beyond authorized outputs — satisfied. ✓

---

### CHK-11: No public release/demo claim

**Result: PASS.**

Track doc states:

> "This smoke is installed-package profile-source confidence evidence only. It
> does not establish installed-gem/package readiness or public release readiness
> until a later acceptance decision."

Compact receipt: `public_claims_authorized: no`.
Non-claims: `no_public_release_claim: true`, `no_public_demo_claim: true`,
`no_public_availability_claim: true`. ✓

---

### CHK-12: No release execution

**Result: PASS.**

Compact receipt: `no_push_performed: yes`, `no_gem_published: yes`.
`release_scope.release_execution_authorized: false`.
`non_claims.no_release_execution: true`. ✓

---

### CHK-13: No RubyGems publish

**Result: PASS.**

`release_scope.rubygems_publish_authorized: false`.
`non_claims.no_rubygems_publish: true`. ✓

---

### CHK-14: No version/tag/push/publish/sign/deploy

**Result: PASS.**

Compact receipt:
```text
version_change_authorized: no
git_tag_authorized: no
no_tag_created: yes
no_push_performed: yes
no_gem_published: yes
```

Non-claims:
```text
no_version_change: true
no_gemspec_metadata_change: true
no_git_tag: true
no_push: true
no_signing: true
no_deploy: true
```
✓

---

### CHK-15: No profile finalization/discovery/defaulting

**Result: PASS.**

PSS-5: `"no finalization/discovery/defaulting: all profile sources are caller-supplied temp file copies; no named lookup; no inline JSON; no env/config/sidecar"`

All three `profile_source_inputs` entries:
```json
"finalization_performed_by_smoke": false,
"discovery_or_defaulting_used": false
```

Fixtures were copied from the repo source path to the isolated temp root and
used directly. No finalization, defaulting, named lookup, inline JSON, or
env/config/sidecar lookup was performed. ✓

---

### CHK-16: No public API/CLI widening

**Result: PASS.**

All smoke commands use only the accepted CLI shape:
`igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`

No additional flags, no inline JSON input, no named lookup, no alternative
discovery modes. PSS-1 explicitly verified: "no inline JSON; no discovery."

`non_claims.no_public_api_cli_widening_beyond_profile_source_path: true`. ✓

---

### CHK-17: branch/conditional `if_expr` remains excluded

**Result: PASS.**

Source corpus: `add_baseline.ig` — an arithmetic function source with no
`if_expr`.
Compact receipt: `branch_conditional_if_expr: excluded_from_first_rc`.
Non-claims: `no_branch_conditional_claim: true`. ✓

---

### CHK-18: Spark remains absent

**Result: PASS.**

`spark_status: excluded_non_authorizing`.
Non-claims: `no_spark_integration: true`.
No Spark fixture, fixture path, or integration reference appears in any field
of the summary or track doc. ✓

---

### CHK-19: Built gem SHA256 consistent with R173 accepted evidence

**Result: PASS.**

Summary package:
`"built_gem_sha256": "sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a"`

This is identical to the R173 accepted gem SHA256. This is expected — no code
was edited between R173 and R176. The same gem was rebuilt from the same
unmodified source tree. The SHA256 matching R173 is additional confirmation that
no code changes occurred. ✓

---

## Non-Blocking Notes

### NB-1: Temp root not fully cleaned — `out/` subdirectory with igapp and compilation report remains

Read-only verification confirmed that the temp root
`/private/tmp/igniter_lang_profile_source_install_smoke_S3R176C1I_20260525T101425Z/`
still exists and contains an `out/` subdirectory with:

- `add_baseline_profiled.igapp` (the PSS-2 success output directory)
- `wrong_kind_should_not_exist.compilation_report.json` (the PSS-4 semantic refusal report)

The `artifact_policy.cleanup_temp_root: "after summary written"` is inaccurate
for the `out/` subdirectory — cleanup was performed on gem home, bin dir,
fixture copies, source copies, and build dir, but not on the `out/` directory.

This is not a blocker because:
- No repo artifacts; both files are in `/private/tmp/` only;
- `positive_igapp_outputs: "temp only; not retained in repo"` — true;
- PSS-8 FAIL condition ("temp artifacts committed or durable repo outputs include
  generated `.igapp` or gem artifacts") is not triggered.

C3-A should note this as a hygiene item for future smoke rounds: the smoke
script should explicitly clean the `out/` subdirectory after writing the durable
summary, or the `artifact_policy.cleanup_temp_root` value should be more precise
(e.g., `"partial — out/ not cleaned"`).

---

### NB-2: Prior S3-R175-C3-X pressure review stated "23-field non-claims block"; actual count is 24

The S3-R175-C3-X pressure review (now committed) described the C2-P1 non-claims
block as having "23 fields." The actual C2-P1 specification, S3-R175-C4-A
authorization, and S3-R176-C1-I implementation all have 24 fields. The track doc
states "All 24 required non-claims are true." This is a count discrepancy in the
prior review document only — all 24 fields are present and true in the
implementation. No blocker; documentation nuance from prior review.

---

## Verdict

**proceed — no blockers; 19/19 checks PASS.**

| Check | Result |
| --- | --- |
| CHK-1: Summary PASS derived from PSS-0..PSS-8 | PASS |
| CHK-2: Installed package isolation proven | PASS |
| CHK-3: `$BIN_DIR/igc` used; not repo-local | PASS |
| CHK-4: No repo-relative `-I` or repo `RUBYLIB` | PASS |
| CHK-5: Success case proves expected manifest `compiler_profile_id` | PASS |
| CHK-6: PSS-3 writes no `.igapp` and no compilation report | PASS |
| CHK-7: PSS-4 writes no `.igapp`; writes report; qualified `compiler_profile_source.*` diagnostic | PASS |
| CHK-8: Refusal-kind hygiene correct | PASS |
| CHK-9: Non-claims all true (24 fields) | PASS |
| CHK-10: No repo artifacts beyond authorized summary and script | PASS |
| CHK-11: No public release/demo claim | PASS |
| CHK-12: No release execution | PASS |
| CHK-13: No RubyGems publish | PASS |
| CHK-14: No version/tag/push/publish/sign/deploy | PASS |
| CHK-15: No profile finalization/discovery/defaulting | PASS |
| CHK-16: No public API/CLI widening | PASS |
| CHK-17: branch/conditional `if_expr` excluded | PASS |
| CHK-18: Spark absent | PASS |
| CHK-19: Built gem SHA256 consistent with R173 accepted gem | PASS |

The smoke execution evidence is coherent, mechanically detailed, and correctly
bounded. Installed package isolation is proven by four independent checks (PSS-0A
through PSS-0D). The success, preflight, and semantic refusal cases all satisfy
the S3-R175-C4-A required behavior. Refusal-kind labels are correct and address
R173 NB-1. Non-claims are complete (24 fields). No unauthorized surfaces were
touched.

---

## Acceptance Recommendation for C3-A

**Accept the S3-R176-C1-I smoke evidence as PASS.**

C3-A should:

1. **Accept the smoke evidence** as a PASS for all 9 PSS criteria;
2. **Record the accepted evidence** as:

```text
scope: bounded_installed_package_profile_source_smoke
package: igniter_lang
version: 0.1.0.pre.stage2
run_id: S3R176C1I_20260525T101425Z
base_run_id: S3R173C1I_20260525T063543Z
built_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
installed_command: igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
PSS-0..PSS-8: all PASS
manifest_compiler_profile_id: compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
refusal_kind_hygiene_status: pass
failed_checks: 0
hold_reasons: 0
```

3. **Carry NB-1** (partial temp cleanup — `out/` subdirectory remains in
   `/private/tmp/` with igapp and compilation report) as a hygiene note for
   future smoke rounds; not a blocker;
4. **Note NB-2** (prior S3-R175-C3-X review said "23-field" rather than "24-field"
   non-claims; implementation is correct);
5. **Keep all closed surfaces closed**: public release/demo, RubyGems, version/
   tag/push/publish/sign/deploy, profile finalization/discovery/defaulting,
   API/CLI widening, branch/conditional, Spark, runtime, production;
6. Decide the next release-readiness vector.

---

## Closed Surfaces Confirmed

This pressure review does not open:

```text
public release or demo claims
release execution
RubyGems publish
version file edits
gemspec/package metadata edits
git tag creation
git push
signing or deployment
public API/CLI widening
profile finalization/discovery/defaulting
branch/conditional if_expr
Spark, Ruby Framework, runtime, production
```

---

## Compact Pressure Verdict

```text
card:                          S3-R176-C2-X
track:                         compiler-release-profile-source-install-smoke-pressure-v0
status:                        done
verdict:                       proceed
blockers:                      0
checks_passed:                 19/19
summary_status_match:          PASS (PSS-0..PSS-8 all PASS; 0 failed; 0 hold)
installed_isolation_proven:    yes (PSS-0A..0D; gem path inside isolated temp; no repo leak)
bin_dir_igc_used:              yes (installed /private/tmp/.../bin/igc; not repo bin/igc)
no_repo_i_or_rubylib:          yes (repo_relative_i_used=false; rubylib_points_to_repo=false)
pss2_manifest_id:              compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7 (matches expected)
pss3_no_igapp_no_report:       yes (stdout=empty; stderr=one-line; igapp_written=false; report_written=false)
pss4_report_qualified_diag:    yes (compiler_result JSON; assembler_refused; compiler_profile_source.wrong_kind; igapp_written=false; report_written=true)
refusal_kind_hygiene:          pass (profile_source_preflight; profile_source_semantic_refusal; no stale labels)
non_claims_all_true:           yes (24 fields; all true)
no_repo_artifacts_leaked:      yes (only summary JSON + script in repo)
public_release_demo_claims:    closed
release_execution:             closed
rubygems_publish:              closed
version_tag_push_publish_sign_deploy: closed
profile_finalization_discovery: closed
api_cli_widening:              closed
branch_conditional_if_expr:    excluded
spark:                         absent; non_authorizing
sha256_consistent_with_r173:   yes (same gem; no code changes)
nb_1:                          partial temp cleanup — out/ subdir remains in /private/tmp/ (not in repo; not a blocker; hygiene note)
nb_2:                          prior S3-R175-C3-X review stated "23-field" — actual is 24; implementation correct
next_route:                    compiler-release-profile-source-install-smoke-acceptance-decision-v0 (C3-A)
```
