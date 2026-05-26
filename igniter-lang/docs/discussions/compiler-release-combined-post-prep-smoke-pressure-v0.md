# Compiler Release Combined Post-Prep Smoke Pressure v0

Card: S3-R183-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Track: compiler-release-combined-post-prep-smoke-pressure-v0

Depends on:
- S3-R183-C2-I
- S3-R183-C1-A

---

## Question

Does the combined post-prep smoke execution (C2-I) stay within the C1-A
authorized write/output scope, correctly build and install `igniter_lang
0.1.0.alpha.1`, prove the packaged artifact includes `README.md` and
`RELEASE_NOTES.md`, execute a sufficient positive/refusal/profile-source
corpus without repo-path leaks, record a fresh artifact SHA256, and preserve
all closed surfaces — with no release execution, publish, tag, push, sign,
deploy, or public claim?

---

## Context

Inputs independently read:

- `igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-v0.md` (C2-I)
- `igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-authorization-review-v0.md` (C1-A)
- `igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`
- `igniter-lang/RELEASE_NOTES.md`

Git commit structure verified:

```text
03a4ec9d — round-level card doc (S3-R183.md) — pre-C2-I round planning
dcdb0ae6 — C1-A authorization review track doc (17:26 UTC+3)
d4c3deab — C2-I: track doc + script + summary JSON (18:58 UTC+3)
```

C1-A was committed before C2-I execution. Authorization order is correct.

Fresh artifact SHA256: `sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6`

Prior invalidated SHA256 (`0.1.0.pre.stage2`):
`sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a`

---

## Checks

### 1. Write scope — C2-I repo files

C1-A authorized repo writes:

```text
igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/**
igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-v0.md
```

C2-I commit (d4c3deab) added exactly:

```text
igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-v0.md          ✓
igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/combined_post_prep_smoke_v0.rb  ✓
igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json  ✓
```

No other live files modified: gemspec, README, RELEASE_NOTES, version.rb, compiler/runtime
code, and public docs outside the C2-I track doc are all untouched.

Result: **PASS**

### 2. Version verified (CM-0)

CM-0: `ruby -I [repo]/lib -e 'require "igniter_lang/version"; puts IgniterLang::VERSION'`
Output: `0.1.0.alpha.1` — matches expected.

Note: CM-0 uses a repo-relative `-I` path for the pre-build version probe.
This is a source verification step (checking the VERSION constant before gem
build), not an installed-package isolation claim. Isolation is proved separately
by CM-7. The repo-relative `-I` in CM-0 is correct and expected behavior.

Result: **PASS**

### 3. Gemspec syntax check (CM-1)

Exit 0, `Syntax OK`. Gemspec correctly loads `lib/igniter_lang/version.rb`.

Result: **PASS**

### 4. Fresh gem build and SHA256 (CM-2 / CM-3)

Gem built to temp path:
`/private/tmp/igniter_lang_combined_post_prep_smoke_S3R183C2I_20260526T143139Z/build/igniter_lang-0.1.0.alpha.1.gem`

Exit 0. stdout: `Successfully built RubyGem Name: igniter_lang Version: 0.1.0.alpha.1`

SHA256 captured: `sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6`

This is a fresh artifact SHA256 for `0.1.0.alpha.1`. It supersedes the
invalidated `0.1.0.pre.stage2` SHA256. Built gem not retained in repo (temp only).

Result: **PASS**

### 5. Packaged file proof (CM-4)

`Gem::Package#contents` inspection confirmed:

| File | Present |
| --- | --- |
| `README.md` | ✓ |
| `RELEASE_NOTES.md` | ✓ |
| `bin/igc` | ✓ |
| `lib/igniter_lang/version.rb` | ✓ |

Full file list in JSON `artifact.all_files` matches exactly the
`Dir["lib/**/*.rb", "bin/igc", "README.md", "RELEASE_NOTES.md"]` gemspec glob
(24 files: 2 docs + 1 bin + 21 lib Ruby files).

README → RELEASE_NOTES link is no longer a packaged-file-pointing-at-absent-file
risk. R182-C2-I bundling is confirmed live in the actual built artifact.

Result: **PASS**

### 6. Isolated gem install (CM-5)

Install command: `gem install --local --force --no-document --install-dir $GEM_HOME --bindir $BIN_DIR $GEM_PATH`

All paths in `/private/tmp/igniter_lang_combined_post_prep_smoke_S3R183C2I_20260526T143139Z/`.
Exit 0. `Successfully installed igniter_lang-0.1.0.alpha.1 / 1 gem installed`.

GEM_HOME and GEM_PATH both set to isolated temp directory. No system gem path
contamination or repo checkout path in install command.

Result: **PASS**

### 7. Installed igc present and invokable (CM-6)

`igc` present at `$BIN_DIR/igc` (isolated temp). Executable bit set.
`igc_exists: true, igc_executable: true`.

Result: **PASS**

### 8. require without repo-relative -I (CM-7)

```text
cwd: /private/tmp
GEM_HOME: isolated temp
GEM_PATH: isolated temp
cmd: ruby -e 'require "igniter_lang"; spec = Gem.loaded_specs.fetch("igniter_lang");
     abort "REPO PATH LEAK: ..." if spec.full_gem_path.include?("[repo]/igniter-lang");
     puts "load OK ..."'
```

Exit 0. stdout: `load OK 0.1.0.alpha.1 path=/private/tmp/.../gem_home/gems/igniter_lang-0.1.0.alpha.1`

`repo_relative_i_used: false`
`rubylib_points_to_repo: false`
`repo_path_leak_observed: false`

`Gem.loaded_specs["igniter_lang"].full_gem_path` is inside the isolated temp
gem home, not the repo checkout.

Result: **PASS**

### 9. Positive compile corpus (CM-8)

5/5 required. All run via `$BIN_DIR/igc compile SOURCE --out OUT.igapp` from
`/private/tmp` with no repo-relative `-I`.

| Source | Exit | igapp | Status | Pass |
| --- | --- | --- | --- | --- |
| `add_baseline.ig` | 0 | ✓ | ok | ✓ |
| `boolean_gate.ig` | 0 | ✓ | ok | ✓ |
| `integer_arithmetic.ig` | 0 | ✓ | ok | ✓ |
| `multi_input_diverse.ig` | 0 | ✓ | ok | ✓ |
| `poc_derived.ig` | 0 | ✓ | ok | ✓ |

Corpus has better language-feature diversity than the original 4 POC contracts
(boolean ops, integer arithmetic, multi-input, POC-derived). Positive igapp
outputs are temp-only, not retained in repo.

Result: **PASS**

### 10. Refusal corpus (CM-9)

3/3 required. All `igapp_absent: true`. All exit 1.

| Source | Refusal kind | igapp absent | Pass |
| --- | --- | --- | --- |
| `parse_refusal.ig` | `parse_refusal` | ✓ | ✓ |
| `type_mismatch.ig` | `oof` | ✓ | ✓ |
| `unresolved_symbol.ig` | `oof` | ✓ | ✓ |

`type_mismatch` and `unresolved_symbol` correctly labeled `oof` — R173 NB-1
hygiene applied forward per C1-A instruction. No `igapp` written for any
refusal case.

Result: **PASS**

### 11. Profile-source success (CM-10)

Command: `$BIN_DIR/igc compile add_baseline.ig --out add_baseline_profiled.igapp --compiler-profile-source finalized_profile_source.json`
Exit: 0, status: ok, igapp_written: true.

```text
manifest.compiler_profile_id: compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
expected_compiler_profile_id: compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
profile_id_match:             true
```

Manifest profile ID matches the R176-accepted profile ID exactly. Finalized
profile source accepted, `.igapp` written. No profile finalization, discovery,
or defaulting. No ambient profile lookup.

Result: **PASS**

### 12. Profile-source preflight refusal (CM-11)

Malformed JSON input. Expected: stderr-only, no igapp, no compilation report.

```text
exit_status:         1
stdout_shape:        empty
stderr_shape:        one_line_text
stderr:              "compiler profile source file must contain valid JSON"
igapp_absent:        true
report_absent:       true
refusal_kind:        profile_source_preflight
```

PSS-3 criteria met: CLI-owned preflight refusal, no artifact output, no report.

Result: **PASS**

### 13. Profile-source semantic refusal (CM-12)

Wrong-kind JSON input. Expected: compiler_result JSON on stdout, report written,
no igapp, qualified `compiler_profile_source.*` diagnostic.

```text
exit_status:           1
stdout_shape:          compiler_result_json
result_status:         assembler_refused
stderr_shape:          empty
igapp_absent:          true
report_present:        true
qualified_diag_prefix: compiler_profile_source.
observed_diag:         add_baseline: compiler_profile_source.wrong_kind: "not_a_compiler_profile_id_source"
diagnostic_source:     stdout_compiler_result
```

PSS-4 criteria met: refusal is orchestrator/assembler-level, not CLI preflight.
Report written. Diagnostic is qualified under `compiler_profile_source.*` namespace.
No igapp written.

Result: **PASS**

### 14. Repo path leak scan (CM-13)

Scanned: all stdout/stderr/report surfaces for all 14 command steps, against
LANG_ROOT `/Users/alex/dev/projects/igniter/igniter-lang`.

```text
leaked_surfaces: []
repo_path_leak:  false
```

The `cmd` field in the JSON contains full paths for traceability (expected).
Runtime outputs (stdout, stderr, report) are clean.

Result: **PASS**

### 15. Temp artifact cleanup

```text
cleanup:        complete
retained_paths: []
temp_root:      /private/tmp/igniter_lang_combined_post_prep_smoke_S3R183C2I_20260526T143139Z/
```

No partial cleanup; all temp roots removed after durable summary written.
No `.gem` artifact left in repo. No `.igapp` retained. No prior R176 temp
cleanup remnant (`out/` subdir from R176 NB-1) is repeated here.

Result: **PASS**

### 16. Non-claims and closed surfaces

Summary JSON `non_claims` block: 24 fields, all `true`.

Key confirmations:

```text
no_release_execution: true
no_rubygems_publish: true
no_public_release_claim: true
no_git_tag: true
no_push: true
no_signing: true
no_deploy: true
no_profile_finalization: true
no_profile_discovery: true
no_profile_defaulting: true
no_branch_conditional_claim: true
no_spark_integration: true
no_version_change: true
no_gemspec_metadata_change: true
```

C2-I track doc compact receipt: `no_code_edited: yes`, `no_version_file_edited: yes`,
`no_tag_created: yes`, `no_push_performed: yes`, `no_gem_published: yes`.

`public_release_readiness: not_established (requires separate acceptance decision)`.

`closed_surfaces` array lists 20 named surfaces, consistent with C1-A.

Result: **PASS**

---

## Verdict

```text
proceed with non-blocking notes — 16/16 checks PASS
blockers: none
non-blocking notes: 3
```

---

## Non-Blocking Notes

**NB-1: CM-0 uses repo-relative `-I` — expected, not an isolation claim**

CM-0 command: `ruby -I [repo]/lib -e 'require "igniter_lang/version"; puts IgniterLang::VERSION'`

This is a pre-build source version probe, not an installed-package behavior
claim. The isolation proof is CM-7, which runs from `/private/tmp` with no
repo path in load path. The pattern is correct and consistent with prior smoke
rounds (R173 CM-0 used the same shape). C4-A need not take action.

**NB-2: SHA256 self-attested via Digest::SHA256 (no independent shasum command)**

CM-3 captures `sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6`
via `Digest::SHA256.hexdigest` in the smoke script. No separate `shasum -a 256`
command appears in the evidence matrix.

This is consistent with R173 NB-1 and R168 NB-1 patterns. Prior rounds carried
this as informational only and were accepted by C4-A. If C4-A wants a separate
hash check confirmation command added in future smoke rounds, this is the
right moment to set the precedent. No action required for acceptance.

**NB-3: Commit `dcdb0ae6` message mislabels C1-A content as C2-I**

Commit `dcdb0ae6` message: "add S3-R183-C2-I combined post-prep smoke execution
track doc" — but the file it added is `compiler-release-combined-post-prep-smoke-authorization-review-v0.md`
(the C1-A authorization review, not the C2-I track doc).

The authorization sequence is still correct — `dcdb0ae6` (C1-A) was committed
at 17:26, and `d4c3deab` (C2-I execution) was committed at 18:58, same day.
C1-A was authorized before C2-I ran. No scope or safety impact. Commit message
hygiene only.

---

## [Agree]

- C2-I write scope is exact: 3 files (track doc + script + summary JSON), all
  within C1-A authorized `experiments/**` and track doc path.
- Fresh gem artifact `sha256:749ee7879...` is correctly captured and supersedes
  the invalidated `sha256:dba3f004...` for `0.1.0.pre.stage2`.
- Artifact proves `README.md` and `RELEASE_NOTES.md` are packaged — completing
  the R182 bundling precondition end-to-end.
- CM-7 isolation proof is strong: `Gem.loaded_specs["igniter_lang"].full_gem_path`
  is inside isolated temp, with explicit abort on repo path detection.
- CM-11 / CM-12 profile-source refusal distinction is correct:
  - preflight (malformed JSON): stderr-only, no igapp, no report ✓
  - semantic (wrong-kind): compiler_result JSON, report present, qualified
    `compiler_profile_source.*` diagnostic, no igapp ✓
- Manifest profile ID `compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7`
  matches the R176-accepted profile ID exactly.
- R173 NB-1 hygiene (`oof` label for type_mismatch/unresolved_symbol) correctly
  applied forward per C1-A instruction.
- All 16 C1-A PASS criteria satisfied.
- All 24 non-claims true. All release/publish/tag/push/sign/deploy surfaces
  closed. `public_release_readiness: not_established`.

## [Challenge]

None. The evidence is mechanically complete and independently verified from
the JSON artifact. All required command matrix entries are present with correct
shapes and exit statuses.

## [Missing]

None for this card. The next evidence step (if C4-A accepts this smoke) is a
separate acceptance-decision card that may update the smoke readiness markers
for `0.1.0.alpha.1`. That acceptance card must still hold all publish/release
gates closed.

## [Sharper Question]

Does C4-A plan to accept the fresh smoke evidence and update the package/install
and profile-source installed readiness markers for `0.1.0.alpha.1` in a single
acceptance decision card, or are they separate? (Not a blocker — informational
for sequencing.)

## [Route]

```text
proceed
```

C4-A may accept S3-R183-C2-I smoke evidence and update post-prep smoke readiness
markers for `igniter_lang 0.1.0.alpha.1`. Acceptance still does not open
release execution, RubyGems publish, public claims, or tag/push/sign/deploy.

---

## Compact Pressure Verdict

```text
card:               S3-R183-C3-X
track:              compiler-release-combined-post-prep-smoke-pressure-v0
verdict:            proceed with non-blocking notes
checks:             16/16 PASS
blockers:           none
non-blocking notes: 3

key findings:
  - Write scope exact: track doc + script + JSON output only (d4c3deab)
  - Version: 0.1.0.alpha.1 confirmed (CM-0)
  - Fresh SHA256: sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
  - README.md + RELEASE_NOTES.md confirmed in built artifact (CM-4)
  - Isolation: full_gem_path in isolated temp, no repo-path load (CM-7)
  - Positive corpus: 5/5 PASS with improved diversity (CM-8)
  - Refusal corpus: 3/3 PASS; type_mismatch/unresolved_symbol labeled oof (CM-9)
  - Profile-source success: igapp written; manifest profile_id matches R176 (CM-10)
  - Preflight refusal: stderr-only, no igapp, no report (CM-11 / PSS-3 ✓)
  - Semantic refusal: compiler_result JSON, report present, qualified diag, no igapp (CM-12 / PSS-4 ✓)
  - Repo path leak scan: CLEAN (CM-13)
  - Temp cleanup: complete, no retained paths
  - Non-claims: 24/24 true; public_release_readiness: not_established
  - All closed surfaces preserved

NB-1: CM-0 repo-relative -I is pre-build version probe only — expected
NB-2: SHA256 self-attested (no independent shasum cmd) — consistent with R173/R168 precedent
NB-3: Commit dcdb0ae6 message mislabels C1-A content — no scope/safety impact

next_route: C4-A acceptance decision for post-prep smoke evidence for
            igniter_lang 0.1.0.alpha.1
```
