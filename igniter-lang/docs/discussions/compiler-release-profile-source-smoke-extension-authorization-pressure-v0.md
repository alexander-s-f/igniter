# Compiler Release Profile-Source Smoke Extension Authorization Pressure v0

Card: S3-R175-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: review-agent
Track: compiler-release-profile-source-smoke-extension-authorization-pressure-v0
Route: UPDATE
Depends on: S3-R175-C1-P1, S3-R175-C2-P1
Date: 2026-05-25

---

## Question

Do the S3-R175-C1-P1 profile-source smoke extension boundary and S3-R175-C2-P1
profile-source smoke extension criteria packets provide a sound authorization
basis for C4-A to decide whether a bounded installed-package profile-source smoke
execution card may open — specifically: correct installed command shape with no
repo-local leakage, three required cases (success + preflight + semantic refusal)
fully defined, existing release-harness fixtures reused, PSS-3/PSS-4 refusal
distinction correct, PSS-6 refusal-kind hygiene addressing R173 NB-1 without
becoming a false blocker, HOLD criteria correctly placed for inconclusive
mechanics, no profile finalization/discovery/defaulting, no public API/CLI
widening, complete non-claims block, temp artifact policy kept temp-only, branch/
conditional excluded, and all release/public/runtime/Spark/Ruby/version/tag/push/
publish/sign/deploy surfaces closed?

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-boundary-v0.md`
  (S3-R175-C1-P1)
- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-criteria-v0.md`
  (S3-R175-C2-P1)
- `igniter-lang/docs/tracks/compiler-release-installed-readiness-and-next-vector-decision-v0.md`
  (S3-R174-C4-A)
- `igniter-lang/docs/tracks/stage3-round174-status-curation-v0.md`
  (S3-R174-C5-S)
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md`
  (S3-R173-C3-A)

---

## Check Review

### CHK-1: C1-P1 purpose is correctly scoped to the R174-C4-A selected next vector

**Result: PASS.**

R174-C4-A selected next route: `profile-source smoke extension authorization
review`. Compact receipt: `next_route:
compiler-release-profile-source-smoke-extension-authorization-review`.

R174-C5-S records: `next_vector: profile_source_smoke_extension_authorization_review`
and confirms: "This is an authorization-review route only. It does not authorize
profile-source smoke execution."

C1-P1 purpose statement:

> "This card does not run smoke, does not edit code, and does not authorize
> execution. It defines the smallest next smoke shape that can test the accepted
> bounded PROP-036 CLI transport inside the installed `igc` package context."

C1-P1 compact boundary:
`purpose: installed_package_profile_source_transport_confidence`

C2-P1 purpose:

> "Define PASS/HOLD/FAIL criteria and result packet shape for a possible bounded
> installed-package profile-source smoke extension. This criteria card does not
> run smoke, edit code, or authorize execution."

Both cards are correctly positioned as authorization-review and boundary-definition
documents with no execution implication. The R174-C4-A route selection is
correctly reflected. ✓

---

### CHK-2: R174 accepted marker facts are correctly carried as starting evidence

**Result: PASS.**

C1-P1 Fixed Evidence block records all R174/R173 accepted fields verbatim:

| Field | C1-P1 value | R174-C4-A accepted value | Match |
| --- | --- | --- | --- |
| scope | `local_package_install_smoke_only` | `local_package_install_smoke_only` | ✓ |
| package | `igniter_lang` | `igniter_lang` | ✓ |
| version | `0.1.0.pre.stage2` | `0.1.0.pre.stage2` | ✓ |
| run_id | `S3R173C1I_20260525T063543Z` | `S3R173C1I_20260525T063543Z` | ✓ |
| built_gem_sha256 | `sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a` | same | ✓ |
| positive_corpus | `5/5 PASS` | `5/5 PASS` | ✓ |
| refusal_corpus | `3/3 PASS` | `3/3 PASS` | ✓ |
| failed_checks | `0` | `0` | ✓ |
| hold_reasons | `0` | `0` | ✓ |

The accepted wording carried in C1-P1 matches the R174-C4-A and R174-C5-S
verbatim:

```text
The current local igniter_lang package builds, installs into an isolated gem
home, loads without repo-relative -I, and the installed igc CLI compiles the
accepted positive corpus and refuses the accepted negative corpus.
```

C2-P1 `release_scope` packet:
`"source_marker": "local_package_install_smoke_only"` and
`"base_run_id": "S3R173C1I_20260525T063543Z"`.

All R174 facts correctly carried. ✓

---

### CHK-3: Installed command shape uses `$BIN_DIR/igc` with no repo-local leakage

**Result: PASS.**

C1-P1 Installed Command Shape:

```bash
env GEM_HOME=$GEM_HOME_DIR GEM_PATH=$GEM_HOME_DIR PATH=$BIN_DIR:$PATH \
  $BIN_DIR/igc compile SOURCE.ig \
  --out $OUT_DIR/NAME.igapp \
  --compiler-profile-source PROFILE_SOURCE.json
```

Required constraints enumerated in C1-P1:

```text
call $BIN_DIR/igc, not repo-local bin/igc
no ruby -I igniter-lang/lib
no repo RUBYLIB
no igniter-lang compile alias
no inline JSON
no named profile lookup
no env/config/sidecar discovery
no source finalization during smoke
```

C2-P1 command matrix confirms `PSS-1` criterion: use installed `$BIN_DIR/igc
compile` with explicit `--compiler-profile-source PATH.json` only. The PSS-1
FAIL condition is: "repo CLI, inline JSON, named lookup, discovery/defaulting."

C2-P1 `environment` packet requires:
`"repo_relative_i_used": false`,
`"rubylib_points_to_repo": false`,
`"repo_path_leak_observed": false`.

PSS-0 FAIL conditions include:
- `repo-relative -I used for installed checks`
- `repo RUBYLIB used for installed checks`
- `repo-local bin/igc used instead of $BIN_DIR/igc`
- `Gem.loaded_specs path points to repo checkout`

All isolation requirements are correctly and consistently specified. ✓

---

### CHK-4: Three required cases defined correctly — 1 success + 1 preflight + 1 semantic

**Result: PASS.**

C1-P1 Explicit Answers:

```text
Should it exercise success, refusal, or both?
Both. Minimum recommended set:
  1 success: add_baseline.ig + finalized_profile_source.json
  1 preflight refusal: missing path or malformed_profile_source.json
  1 semantic refusal: semantic_profile_source_wrong_kind.json
```

C2-P1 defines the same three-case set at PSS-2 (success), PSS-3 (preflight
refusal), and PSS-4 (semantic refusal), with independent criteria per case.

C2-P1 compact criteria matrix:

| ID | PASS |
| --- | --- |
| PSS-2 | valid profile source success and expected manifest id |
| PSS-3 | preflight refusal stderr-only/no artifacts |
| PSS-4 | semantic refusal compiler_result/report/no `.igapp` |

C2-P1 also makes explicit: "If a future authorization chooses success-only
profile-source smoke, the result cannot be PASS under this criteria. It must be
HOLD with `hold_reason: profile_source_refusal_cases_not_exercised`." This
correctly gates partial-coverage attempts.

C1-P1 Recommended authorization stance: "Recommendation: first smoke should
exercise both success and refusal. Success alone would not prove the installed
CLI preserves the existing B3/B5 refusal boundary. Refusal alone would not prove
the installed package carries the valid profile-source manifest identity path."

Three-case requirement is correctly mandated in both cards. ✓

---

### CHK-5: Fixture policy reuses existing release-harness fixtures without new committed fixture

**Result: PASS.**

C1-P1 recommends:

```text
Primary valid fixture:
  experiments/compiler_release_acceptance_harness_v0/fixtures/finalized_profile_source.json
Recommended refusal fixtures:
  experiments/compiler_release_acceptance_harness_v0/fixtures/malformed_profile_source.json
  experiments/compiler_release_acceptance_harness_v0/fixtures/semantic_profile_source_wrong_kind.json
```

C1-P1 fixture policy: "No new committed smoke-local fixture is required."

C2-P1 confirms the same three fixtures and adds: "No new committed fixture is
required. Future execution may copy fixtures into the temp smoke root and record
fixture digests."

The recommended source corpus is `add_baseline.ig` from the accepted release
harness, which is already part of the R173 accepted positive corpus. This
correctly keeps the extension focused on profile-source transport rather than
language coverage.

C1-P1 also names the standalone backup:
`experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json`
as a sufficient alternative for the valid case, with the release-harness fixture
as the cleaner first choice. This is a reasonable tiered policy.

Fixture policy correctly avoids new committed fixtures. ✓

---

### CHK-6: PSS-3 vs PSS-4 refusal distinction is correct and intentional

**Result: PASS.**

The two refusal cases differ in one key dimension: `compilation_report_written`.

PSS-3 (preflight refusal) requires:

```text
exit_status != 0
stdout == ""
stderr has one stable refusal line
OUT.igapp is absent
OUT.compilation_report.json is absent
profile-source report JSON is absent
```

PSS-4 (semantic refusal) requires:

```text
exit_status != 0
stdout parses as compiler_result JSON
compiler_result.status is non-ok
OUT.igapp is absent
OUT.compilation_report.json is present
diagnostics or report include qualified compiler_profile_source.* vocabulary
```

This distinction is correct. It mirrors the existing B3/B5 behavior documented
in PROP-036:

- B3 (preflight): CLI owns path/JSON validation before any compiler invocation
  — the compiler is never called, so no compilation report is produced.
- B5/B6 (semantic/wrong-kind): the object passes preflight but fails inside the
  compiler/assembler path — a compilation report is produced.

C1-P1 Risks table explicitly acknowledges this:

> "Semantic refusal writes compilation report while preflight refusal should not
> — Accept this distinction; it matches existing B3/B5 behavior."

C2-P1 result packet examples confirm the distinction in machine-readable form:
PSS-3 entry: `"compilation_report_written": false`;
PSS-4 entry: `"compilation_report_written": true`.

The distinction is correct, intentional, and documented. ✓

---

### CHK-7: PSS-6 refusal-kind hygiene correctly addresses R173 NB-1 without becoming a false blocker

**Result: PASS.**

R173 NB-1 (from S3-R173-C2-X):

```text
refusal_kind: "parse_error" for type_mismatch.ig and unresolved_symbol.ig
should be "oof" — PKG-5 criteria satisfied because exit non-zero, no .igapp,
refusal observed.
```

C2-P1 PSS-6 refusal-kind hygiene criterion:

| Case type | Required `refusal_kind` |
| --- | --- |
| CLI profile-source path/JSON preflight | `profile_source_preflight` |
| Semantic profile-source wrong-kind refusal | `profile_source_semantic_refusal` |
| Source parse refusal, if included | `source_parse_error` |
| Type mismatch / unresolved symbol, if included | `oof` |

C2-P1 hygiene derivation rule:

```text
refusal_kind_hygiene_status == "pass" -> eligible for PASS
behavior passes but refusal_kind labels are stale -> HOLD, not FAIL
behavior itself violates refusal expectations -> FAIL
```

This correctly:
- prevents stale labels from becoming a behavioral failure (HOLD not FAIL);
- requires correct labels for PASS;
- keeps the PSS-6 criterion as "required for PASS; HOLD if stale" — exactly
  matching the R173 NB-1 precedent where behavior was correct but label was not.

The profile-source smoke introduces two new specific refusal-kind values
(`profile_source_preflight`, `profile_source_semantic_refusal`) rather than
reusing `parse_error`, which directly prevents a repeat of the R173 NB-1
mislabeling.

C2-P1 requires `refusal_kind_hygiene_status` and `refusal_kind_hygiene_notes`
fields in the summary JSON, making hygiene machine-visible.

R173 NB-1 is correctly addressed without becoming a gate blocker. ✓

---

### CHK-8: HOLD criteria correctly placed for inconclusive package mechanics

**Result: PASS.**

C1-P1 HOLD criteria:

```text
installed igc missing after gem install
isolated require "igniter_lang" fails after package smoke setup
temp filesystem permission issue prevents writing under /private/tmp
profile-source fixture path cannot be read because the fixture was moved
```

C2-P1 PSS-0 HOLD criteria:

```text
installed igc missing
isolated require fails after successful install
temp filesystem permission issue prevents smoke root use
fixture path moved by another track
```

C2-P1 summary-level HOLD:

```text
installed igc missing after install
isolated require fails due to package mechanics
fixture moved or unreadable
summary omits required fields
success-only or partial-refusal smoke attempted
refusal_kind labels stale but exit/artifact behavior is correct
cleanup verification inconclusive
```

These are correctly categorized as HOLD (not FAIL) because they represent
inconclusive mechanics or incomplete coverage, not behavioral regression.
The FAIL conditions are correctly reserved for:

```text
valid finalized profile source exits non-zero
manifest compiler_profile_id missing or mismatched
preflight refusal writes .igapp or compilation report
semantic refusal writes .igapp
CLI performs discovery/defaulting/finalization
repo-local -I or repo RUBYLIB used for installed check
non_claims any false
version/tag/push/publish/sign/deploy action observed
```

The HOLD/FAIL boundary is correctly drawn and matches prior package smoke
precedent from S3-R172-C2-P1. ✓

---

### CHK-9: No profile finalization, discovery, or defaulting in any case

**Result: PASS.**

C1-P1 explicit prohibition:

> "It should not test new language semantics, new profile finalization, profile
> discovery/defaulting, loader/report interpretation, CompatibilityReport status,
> runtime readiness, or production behavior."

C1-P1 required constraints: "no env/config/sidecar discovery", "no source
finalization during smoke".

C2-P1 PSS-5 criterion: "Prove smoke used only caller-supplied finalized file and
did not infer profiles."

PSS-5 FAIL: "any finalization/discovery/defaulting observed."

C2-P1 fixture policy requires each `profile_source_inputs` entry to have:
`"finalization_performed_by_smoke": false`,
`"discovery_or_defaulting_used": false`.

C2-P1 Fixed Scope section explicitly prohibits:

```text
profile finalization
profile discovery/defaulting
named/generated lookup
inline JSON
env/config/sidecar lookup
```

Profile finalization/discovery/defaulting is correctly excluded from all cases. ✓

---

### CHK-10: No public API/CLI widening beyond `--compiler-profile-source PATH.json`

**Result: PASS.**

C1-P1 Explicit Answers:

> "Is any public API/CLI widening required? No. The accepted public CLI shape
> already exists: `--compiler-profile-source PATH.json`. The smoke must not add
> inline JSON, named lookup, env/config/sidecar lookup, defaulting, discovery,
> finalization, or new flags."

C2-P1 Fixed Scope:

```text
public API/CLI widening beyond --compiler-profile-source PATH.json
```

is explicitly in the prohibited list.

C2-P1 non_claims block includes:
`"no_public_api_cli_widening_beyond_profile_source_path": true`

This is the exact accepted public CLI shape from PROP-036 B6 closure. No
additional flags, no inline input shapes, no new discovery modes. ✓

---

### CHK-11: Non-claims block is complete and correct (23 fields; any false is FAIL)

**Result: PASS.**

C2-P1 `non_claims` JSON block contains exactly 23 fields:

```json
no_release_execution
no_public_release_claim
no_public_demo_claim
no_rubygems_publish
no_public_availability_claim
no_version_change
no_gemspec_metadata_change
no_git_tag
no_push
no_signing
no_deploy
no_profile_finalization
no_profile_discovery
no_profile_defaulting
no_named_profile_lookup
no_inline_json
no_env_config_sidecar_lookup
no_public_api_cli_widening_beyond_profile_source_path
no_loader_report_compatibility_report_claim
no_runtime_ledger_tbackend_bihistory_stream_olap_cache_claim
no_production_runtime
no_spark_integration
no_ruby_framework_compatibility_claim
no_branch_conditional_claim
```

C2-P1 enforcement: "Any false value in `non_claims` is FAIL."

This non-claims set correctly covers all surfaces closed by R173-C3-A, R174-C4-A,
and the profile-source specific prohibitions (finalization, discovery, defaulting,
named lookup, inline JSON, env/config/sidecar, loader/report, and
CompatibilityReport).

The `no_branch_conditional_claim` entry is present, preserving the S3-R164-C4-A
Portfolio decision on `if_expr` exclusion from the first-RC scope. ✓

---

### CHK-12: Temp artifact policy keeps outputs temporary; only summary JSON retained in repo

**Result: PASS.**

C1-P1 Temp Artifact And Output Policy:

```text
Temp root: /private/tmp/igniter_lang_profile_source_install_smoke_${CARD}_${TIMESTAMP}/

Allowed temp outputs:
  built .gem; isolated gem home; isolated bindir; copied source/profile fixtures;
  success .igapp output; refusal stdout/stderr captures; smoke-local summary JSON

Durable summary if authorized:
  experiments/compiler_release_profile_source_install_smoke_v0/out/$RUN_ID/
    profile_source_install_smoke_summary.json

Do not commit:
  built .gem; gem home; bindir; temp copied corpus; generated .igapp;
  refusal output paths; profile-source copies
```

C2-P1 PSS-8 passes only if:

```text
retained_summary_path exists
retain_built_gem == false
cleanup_isolated_gem_home == true
positive_igapp_outputs == "temp only; not retained in repo"
profile_source_copies == "temp only; not retained in repo"
```

C2-P1 do-not-retain list adds: `full command logs beyond summary excerpts`.

The durable artifact policy correctly mirrors the R173 precedent:
- one durable summary JSON in `experiments/.../out/$RUN_ID/`;
- all ephemeral build/install/output artifacts temp-only.

This was clarified in R172-C3-X NB-1 (C4-A must define authorized repo write
scope) and confirmed by R173-C2-X CHK-8 that the experiments summary path
was properly authorized. C1-P1 and C2-P1 correctly follow this precedent. ✓

---

### CHK-13: branch/conditional `if_expr` excluded from corpus and claims

**Result: PASS.**

C1-P1 Explicit Answers:

> "Does branch/conditional `if_expr` remain excluded? Yes. Branch/conditional
> `if_expr` remains excluded from this release-readiness vector and must not be
> added to the smoke corpus or wording."

C1-P1 compact boundary: `branch_conditional_if_expr: excluded`

C2-P1 Fixed Scope prohibited list: `branch/conditional if_expr support`

C2-P1 non_claims: `"no_branch_conditional_claim": true`

C2-P1 PSS-2 success case note: `"no branch/conditional source used"`

The recommended source is `add_baseline.ig`, which is an arithmetic/function
corpus file with no `if_expr`. No branch/conditional fixture is referenced in
either card.

Branch/conditional `if_expr` is excluded consistently across both cards, the
corpus, the command matrix, and the non-claims block. ✓

---

### CHK-14: Release/public/runtime/Spark/Ruby/version/tag/push/publish/sign/deploy surfaces closed

**Result: PASS.**

C1-P1 Non-Claims block closes:

```text
smoke execution; public release or demo claims; RubyGems publish; version edits;
gemspec edits; git tag creation; git push; signing; deployment;
public API/CLI widening; profile finalization/discovery/defaulting/named lookup/
inline JSON/env/config/sidecar lookup; loader/report/CompatibilityReport;
RuntimeMachine/Gate 3/Ledger/TBackend/BiHistory/stream/OLAP/cache/production;
Spark fixture/spec/integration; branch/conditional if_expr; demo work
```

C1-P1 compact boundary:

```text
smoke_execution: closed_by_this_card
public_release_demo_claims: closed
rubygems_publish: closed
version_tag_push_publish_sign_deploy: closed
public_api_cli_widening: closed
profile_finalization_discovery_defaulting: closed
branch_conditional_if_expr: excluded
runtime_spark_production: closed
```

C2-P1 Non-Authorization section closes the same list and additionally closes:

```text
PROP-036 or PROP-038 mutation
RuntimeMachine/Gate 3/Ledger/TBackend/BiHistory/stream/OLAP/cache/production
Spark or Ruby Framework claims
```

C2-P1 `release_scope` packet:

```json
"public_claims_authorized": false,
"rubygems_publish_authorized": false,
"production_runtime_authorized": false,
"release_execution_authorized": false
```

All release/public/runtime surfaces closed across both cards. The full R170 →
R171 → R172 → R173 → R174 authorization chain closure is correctly preserved. ✓

---

## Non-Blocking Notes

### NB-1: C2-P1 result packet `card` and `authorized_by` fields use placeholder designations

C2-P1 required result packet top-level fields:

```json
"card": "S3-R175-C?-I",
"authorized_by": "S3-R175-C?-A"
```

Both use placeholder `C?` rather than specific card designations. This is the
same pattern as R172-C2-P1 (`C?-I`) which was flagged as NB-3 in S3-R172-C3-X
and correctly resolved: S3-R172-C4-A assigned the actual card designation
(`S3-R173-C1-I`) when authorizing execution.

This is not a blocker. C4-A should assign the execution card designation
(`C?-I` → specific card ID) and the authorization card back-reference
(`C?-A` → itself) when issuing the execution authorization, exactly as
S3-R172-C4-A resolved the analogous gap.

C4-A should also confirm: "The durable summary file for execution, when
authorized, will record `card: <assigned-card-id>` and `authorized_by:
S3-R175-C4-A`."

---

### NB-2: C4-A should explicitly acknowledge the PSS-3/PSS-4 compilation report distinction

The PSS-3/PSS-4 distinction (`compilation_report_written: false` vs
`compilation_report_written: true`) is correct and matches existing B3/B5
behavior documented in PROP-036. However, since this is the first installed-
package profile-source smoke, C4-A's authorization decision should explicitly
acknowledge that this difference is expected — not a discrepancy between the
two refusal cases.

This prevents a future acceptance card from flagging "PSS-3 report absent,
PSS-4 report present" as a behavioral inconsistency rather than the intentional
preflight vs. semantic refusal boundary.

Recommended C4-A language: "The PSS-3 preflight refusal writes no compilation
report (CLI-owned path validation precedes compiler invocation). The PSS-4
semantic refusal writes a compilation report with a qualified
`compiler_profile_source.*` diagnostic. This distinction is expected per PROP-036
B3/B6 behavior."

---

## Verdict

**proceed — no blockers; 14/14 checks PASS.**

| Check | Result |
| --- | --- |
| CHK-1: C1-P1 purpose correctly scoped to R174-C4-A next vector | PASS |
| CHK-2: R174 accepted marker facts correctly carried as starting evidence | PASS |
| CHK-3: Installed command uses `$BIN_DIR/igc` with no repo-local leakage | PASS |
| CHK-4: Three required cases defined correctly in both cards | PASS |
| CHK-5: Fixture policy reuses existing release-harness fixtures; no new committed fixture | PASS |
| CHK-6: PSS-3 vs PSS-4 compilation report distinction correct and intentional | PASS |
| CHK-7: PSS-6 refusal-kind hygiene addresses R173 NB-1 without false blocker | PASS |
| CHK-8: HOLD criteria correctly placed for inconclusive package mechanics | PASS |
| CHK-9: No profile finalization, discovery, or defaulting | PASS |
| CHK-10: No public API/CLI widening beyond `--compiler-profile-source PATH.json` | PASS |
| CHK-11: Non-claims block complete and correct (23 fields; any false is FAIL) | PASS |
| CHK-12: Temp artifact policy keeps outputs temporary; only summary JSON retained | PASS |
| CHK-13: branch/conditional `if_expr` excluded from corpus and claims | PASS |
| CHK-14: Release/public/runtime/Spark/Ruby/version/tag/push/publish/sign/deploy closed | PASS |

Both packets are correctly scoped. C1-P1 defines a sound installed-command
boundary with exact fixture candidates and PASS/HOLD/FAIL criteria. C2-P1
defines PSS-0 through PSS-8 with a machine-readable result packet schema,
23-field non-claims block, and refusal-kind hygiene rules that prevent a
repeat of R173 NB-1.

---

## Acceptance Recommendation for C4-A

**Accept both preparation cards. Decide whether to authorize bounded execution.**

C4-A should:

1. **Accept the C1-P1 boundary packet** as a sound definition of the installed-
   package profile-source smoke command, fixture, and PASS/HOLD/FAIL shape;
2. **Accept the C2-P1 criteria packet** as the normative PSS-0..PSS-8 criteria
   set for any execution card that may follow;
3. **Decide whether execution may open**: if yes, dispatch a bounded execution
   card with the exact command shape and fixture policy from C1-P1/C2-P1; if no,
   record hold with reason;
4. **Carry NB-1**: assign explicit card designations for `card` and `authorized_by`
   fields in the execution card's result packet (exactly as R172-C4-A resolved
   the analogous placeholder gap);
5. **Carry NB-2**: explicitly acknowledge the PSS-3/PSS-4 compilation report
   distinction as expected behavior in the authorization text;
6. Keep public release/demo claims, version/tag/push/publish/sign/deploy,
   profile finalization/discovery/defaulting, public API/CLI widening,
   branch/conditional `if_expr`, Spark, Ruby Framework, and runtime surfaces
   closed.

---

## Closed Surfaces Confirmed

This pressure review does not open:

```text
smoke execution
public release or demo claims
RubyGems publish
version file edits
gemspec/package metadata edits
git tag creation
git push
signing or deployment
profile-source smoke execution
profile finalization, discovery, defaulting, named lookup, inline JSON,
  env/config/sidecar lookup
public API/CLI widening
branch/conditional implementation or support claim
parser, classifier, TypeChecker, SemanticIR, assembler changes
compiler/library behavior changes
loader/report, CompilationReport, CompilerResult, CompatibilityReport widening
.igapp, .ilk, manifest, sidecar, artifact hash, or golden migration
PROP-036 or PROP-038 mutation
RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  production behavior
Spark access, fixtures, specs, integration, or production pressure
Ruby Framework docs/release/tag/package/compatibility claims
runtime, production, demo, or deployment work
```

---

## Compact Pressure Verdict

```text
card:                          S3-R175-C3-X
track:                         compiler-release-profile-source-smoke-extension-authorization-pressure-v0
status:                        done
verdict:                       proceed
blockers:                      0
checks_passed:                 14/14
boundary_purpose_scoped:       yes (installed_package_profile_source_transport_confidence)
r174_facts_carried:            yes (marker, wording, run_id, SHA256, corpus counts verified)
installed_command_shape:       correct ($BIN_DIR/igc; no repo bin/igc; no repo -I/RUBYLIB)
three_required_cases:          yes (success + preflight_refusal + semantic_refusal)
fixture_policy:                existing_release_harness_fixtures; no_new_committed_fixture
pss3_pss4_distinction:         correct (preflight=no_report; semantic=report_present; matches B3/B5)
pss6_refusal_kind_hygiene:     r173_nb1_addressed; hold_not_fail_for_stale_labels
hold_criteria_correct:         yes (inconclusive_mechanics = HOLD; behavioral_regression = FAIL)
no_finalization_discovery:     yes (all cases use caller-supplied finalized file only)
no_api_cli_widening:           yes (only accepted --compiler-profile-source PATH.json)
non_claims_complete:           yes (23 fields; any_false_is_fail)
temp_artifact_policy:          temp_only; durable_summary_json_only
branch_conditional_if_expr:    excluded
release_public_runtime:        closed
rubygems_spark_ruby:           closed
nb_1:                          C2-P1 card/authorized_by placeholders (C?-I/C?-A); C4-A assigns before dispatch (same pattern as R172-C4-A resolved)
nb_2:                          C4-A should explicitly acknowledge PSS-3/PSS-4 compilation_report distinction as expected B3/B5 behavior
next_route:                    compiler-release-profile-source-install-smoke-authorization-decision-v0 (C4-A)
```
