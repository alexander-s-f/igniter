# Compiler Release Package/Install Smoke Pressure v0

Card: S3-R173-C2-X
Agent: [Package Install Smoke Pressure Reviewer]
Role: review-agent
Track: compiler-release-package-install-smoke-pressure-v0
Route: UPDATE
Depends on: S3-R173-C1-I
Date: 2026-05-25

---

## Question

Does the S3-R173-C1-I package/install smoke execution satisfy all requirements
from S3-R172-C4-A — smoke status derived from PKG criteria, all PKG-0..PKG-5
evidence present, installed CLI using `$BIN_DIR/igc compile`, no `igniter-lang
compile`, no repo-relative `-I`, correct corpus counts (5/5 positive, 3/3
refusal), non-claims present, temp artifact policy followed, no version/gemspec/
tag/push/publish/sign/deploy, no public release/demo claim, no profile-source
extension, no code surface changed, Spark absent, Ruby non-blocking?

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md`
  (S3-R173-C1-I)
- `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json`
  (durable summary JSON)
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-authorization-review-v0.md`
  (S3-R172-C4-A)
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-criteria-v0.md`
  (S3-R172-C2-P1)

---

## Check Review

### CHK-1: Smoke status is derived from PKG criteria

**Result: PASS.**

Top-level status in both the track doc and JSON is `"status": "PASS"`. The JSON
`criteria` block records all five PKG rows as `"status": "PASS"`. The matrix-level
derivation fields confirm the derivation:

```json
"failed_checks": [],
"hold_reasons": [],
"non_blocking_notes": []
```

Per C2-P1 matrix-level rules:
- PKG-1..PKG-5 all PASS ✓
- `failed_checks` is empty ✓
- `hold_reasons` is empty ✓
- required non-claims are present ✓

PASS is correctly derived — not hand-written. ✓

---

### CHK-2: PKG-0..PKG-5 evidence exists

**Result: PASS.**

All six PKG steps are recorded in the `command_matrix`:

| ID | Kind | Exit | Pass |
| --- | --- | --- | --- |
| PKG-0 | `gemspec_syntax_check` | 0 | `true` |
| PKG-1 | `gem_build` | 0 | `true` |
| PKG-2 | `gem_install_isolated` | 0 | `true` |
| PKG-3 | `require_no_repo_i` | 0 | `true` |
| PKG-4 × 5 | `installed_igc_compile_positive` | 0 | `true` |
| PKG-5 × 3 | `installed_igc_compile_refusal` | 1 | `true` |

Supporting evidence per step:

- **PKG-0**: `"stdout_excerpt": "Syntax OK"` — gemspec is syntactically valid.
- **PKG-1**: `stdout_excerpt` records "Successfully built RubyGem Name: igniter_lang
  Version: 0.1.0.pre.stage2"; `artifacts` array contains the built `.gem` path.
- **PKG-2**: `stdout_excerpt` records "Successfully installed igniter_lang-0.1.0.pre.stage2";
  `igc_executable_present: true`.
- **PKG-3**: `stdout_excerpt` records "load OK 0.1.0.pre.stage2 path=/private/tmp/...
  /gem_home/gems/igniter_lang-0.1.0.pre.stage2" — path is inside isolated gem home.
- **PKG-4**: Each of the 5 positive entries records `igapp_written: true` with a
  `stdout_excerpt` showing `"status": "ok"` in the compiler result JSON.
- **PKG-5**: Each of the 3 refusal entries records `igapp_written: false`,
  `refusal_observed: true`, exit 1.

See NB-2 for a minor structural note about PKG-0 appearing in `command_matrix`
only, not in the `criteria` block. ✓ (with NB-2)

---

### CHK-3: Installed CLI uses `$BIN_DIR/igc compile`

**Result: PASS.**

All 5 PKG-4 commands in the `command_matrix` use the full installed binary path:

```text
/private/tmp/igniter_lang_package_install_smoke_S3R173C1I_20260525T063543Z/bin/igc compile SOURCE --out OUT.igapp
```

All 3 PKG-5 commands use the same pattern. This is `$BIN_DIR/igc compile` exactly
as required by S3-R172-C4-A.

The `positive_corpus` and `refusal_corpus` arrays each record `cmd_shape: "igc
compile SOURCE --out OUT.igapp"` — consistently normalized.

The track doc states explicitly: "Installed CLI command used for PKG-4/PKG-5:
`igc compile SOURCE --out OUT.igapp`". ✓

---

### CHK-4: No command uses `igniter-lang compile`

**Result: PASS.**

Scanning the full 12-entry `command_matrix` (PKG-0 through PKG-5):

- PKG-0: `ruby -c .../igniter_lang.gemspec` — no `igniter-lang compile`
- PKG-1: `gem build ...` — no `igniter-lang compile`
- PKG-2: `gem install ...` — no `igniter-lang compile`
- PKG-3: `ruby -e 'require "igniter_lang"; ...'` — no `igniter-lang compile`
- PKG-4 × 5: `$BIN_DIR/igc compile SOURCE --out OUT` — no `igniter-lang compile`
- PKG-5 × 3: `$BIN_DIR/igc compile SOURCE --out OUT` — no `igniter-lang compile`

Track doc explicitly states: "`igniter-lang compile` was not used."

This directly satisfies S3-R172-C4-A's explicit prohibition and the FAIL condition
from C2-P1: "command uses `igniter-lang compile`" → FAIL. ✓

---

### CHK-5: Installed checks do not use repo-relative `-I` or repo `RUBYLIB`

**Result: PASS.**

The JSON environment block records:

```json
"repo_relative_i_used": false,
"rubylib_points_to_repo": false
```

The PKG-3 command_matrix entry independently records:

```json
"repo_relative_i_used": false,
"repo_path_leak_observed": false
```

The PKG-3 `stdout_excerpt` provides active proof: the loaded gem path is
`/private/tmp/.../gem_home/gems/igniter_lang-0.1.0.pre.stage2` — inside the
isolated temp gem home, not the repo checkout at
`/Users/alex/dev/projects/igniter/igniter-lang`.

The PKG-3 command uses `cwd: "/private/tmp"` (outside the repo), and the command
contains no `-I` flag. PKG-4 and PKG-5 call `$BIN_DIR/igc` directly — no
`ruby -I` or `RUBYLIB` is present in any PKG-4/PKG-5 command.

The track doc Isolation Proof section confirms all three isolation properties. ✓

---

### CHK-6: Positive corpus count is 5/5 and negative corpus count is 3/3

**Result: PASS.**

**Positive corpus — 5/5:**

| Source | Exit | igapp written | Result status | Pass |
| --- | --- | --- | --- | --- |
| `add_baseline.ig` | 0 | `true` | `ok` | `true` |
| `boolean_gate.ig` | 0 | `true` | `ok` | `true` |
| `integer_arithmetic.ig` | 0 | `true` | `ok` | `true` |
| `multi_input_diverse.ig` | 0 | `true` | `ok` | `true` |
| `poc_derived.ig` | 0 | `true` | `ok` | `true` |

All 5 sources match the required positive corpus from C2-P1 and C4-A. All 5 exit
0, all 5 write a `.igapp`, all 5 produce `"status": "ok"` in the compiler result.

**Negative/refusal corpus — 3/3:**

| Source | Exit | igapp absent | Refusal observed | Pass |
| --- | --- | --- | --- | --- |
| `parse_refusal.ig` | 1 | `true` | `true` | `true` |
| `type_mismatch.ig` | 1 | `true` | `true` | `true` |
| `unresolved_symbol.ig` | 1 | `true` | `true` | `true` |

All 3 sources match the required negative corpus from C2-P1 and C4-A. All 3 exit
1, none write a `.igapp`, all report `refusal_observed: true`.

See NB-1 for a non-blocking metadata note on `refusal_kind` classification. ✓ (with NB-1)

---

### CHK-7: Non-claims are present for the resulting status

**Result: PASS.**

The JSON `non_claims` block contains exactly the 15 entries required by C2-P1 and
C4-A, all set to `true`:

```json
"no_public_release_claim": true,
"no_public_demo_claim": true,
"no_rubygems_publish": true,
"no_public_availability_claim": true,
"no_version_change": true,
"no_git_tag": true,
"no_push": true,
"no_signing": true,
"no_deploy": true,
"no_release_execution_beyond_smoke": true,
"no_production_runtime": true,
"no_spark_integration": true,
"no_ruby_framework_compatibility_claim": true,
"no_branch_conditional_claim": true,
"no_runtime_ledger_tbackend_bihistory_stream_olap_cache_claim": true
```

C2-P1 requires "non_claims must be present for PASS, HOLD, and FAIL." All 15
required non-claims are present for this PASS result.

The track doc also carries all 15 non-claims in prose form. ✓

---

### CHK-8: Temp artifact policy is followed

**Result: PASS.**

The JSON `artifact_policy` block and the track doc Artifact Policy section record
consistent, compliant choices:

| Artifact | Required policy | Observed |
| --- | --- | --- |
| summary JSON | retain under `experiments/.../out/<run_id>/` | retained ✓ |
| command logs / stdout | retain | `retain_command_logs: true` ✓ |
| built `.gem` | do not retain; record SHA256 | `retain_built_gem: false`; SHA256 in `package.built_gem_sha256` ✓ |
| isolated `GEM_HOME` | cleanup after PASS | `cleanup_isolated_gem_home: true`; "cleaned (PASS cleanup)" ✓ |
| isolated bindir | cleanup after PASS | "cleaned (PASS cleanup)" ✓ |
| copied corpus | cleanup after PASS | "cleaned (PASS cleanup)" ✓ |
| positive `.igapp` outputs | temp only; do not retain in repo | "temp only (not retained in repo)" ✓ |
| refusal output paths | must not exist | "absent (verified PASS)" ✓ |

The `temp_root` is `SMOKE_ROOT=/private/tmp/igniter_lang_package_install_smoke_S3R173C1I_20260525T063543Z` — a unique per-run path under `/private/tmp`.

The `retained_summary_path` in the JSON is the repo `experiments/` path, consistent
with C4-A's explicitly authorized write scope:
```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/**
```

This directly resolves C3-X NB-1 (the durable record scope question): the summary
JSON is committed under `experiments/` as authorized; temp build artifacts are not
committed. ✓

---

### CHK-9: No version/gemspec/tag/push/publish/sign/deploy action occurred

**Result: PASS.**

Track doc non-claims: `no_version_change: true`, `no_git_tag: true`, `no_push: true`,
`no_signing: true`, `no_deploy: true`.

Track doc text: "No version file was edited. No git tag was created. No push was
performed. No gem was published. No signing. No deployment. No code surfaces
changed."

Compact receipt: `version_change_authorized: no`, `git_tag_authorized: no`,
`no_version_file_edited: yes`, `no_tag_created: yes`, `no_push_performed: yes`,
`no_gem_published: yes`.

JSON: `package.version: "0.1.0.pre.stage2"` — unchanged. `release_scope.rubygems_publish_authorized: false`.

The gemspec path in PKG-0 and PKG-1 is read-only (syntax check and `gem build`)
— no edit to `igniter_lang.gemspec` is implied or claimed. ✓

---

### CHK-10: No public release/demo claim was opened

**Result: PASS.**

Track doc: "This smoke is local evidence only. It does not establish installed-gem/
package readiness until a later acceptance decision says so."

Compact receipt: `installed_gem_package_readiness: not_established (requires
acceptance decision)`, `public_claims_authorized: no`.

JSON `release_scope.public_claims_authorized: false`, `scope:
"bounded_local_package_install_smoke"` — the scope label itself bounds the result.

Closed Surfaces section lists "installed-gem/package readiness claim" and "public
release or demo claims" explicitly. ✓

---

### CHK-11: No profile-source smoke extension was run

**Result: PASS.**

C4-A explicitly closes profile-source: "Optional profile-source checks are
deferred. No `--compiler-profile-source` smoke extension is authorized in the
baseline execution card."

Scanning the full `command_matrix` (12 entries): no entry contains
`--compiler-profile-source`. The `positive_corpus` array contains exactly 5
entries, none with a profile-source flag. No PKG-6 row exists.

Track doc Closed Surfaces: "profile-source smoke extension" is the first item. ✓

---

### CHK-12: No compiler/runtime code surface changed

**Result: PASS.**

Compact receipt: `no_code_edited: yes`.

Track doc Closed Surfaces: "parser, classifier, TypeChecker, SemanticIR, assembler
changes; compiler/library behavior changes."

C4-A authorized write scope is:
```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/**
igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md
```

No `lib/`, `bin/igc`, version file, or gemspec appears in the write scope or in
the track doc's inputs/outputs. ✓

---

### CHK-13: Spark remains absent

**Result: PASS.**

Track doc Closed Surfaces: "Spark access, fixtures, integration, or production
pressure."

Non-claims: `no_spark_integration: true`. Compact receipt: `spark_status:
excluded_non_authorizing`.

Spark does not appear in any command, corpus file, or authorizing context. ✓

---

### CHK-14: Ruby remains non-blocking

**Result: PASS.**

Track doc Closed Surfaces: "Ruby Framework docs/release/tag/package/compatibility
claims." Non-claims: `no_ruby_framework_compatibility_claim: true`. Compact
receipt: `ruby_ledger_hardening: independent_non_blocking`. ✓

---

## Non-Blocking Notes

### NB-1: `refusal_kind` is `"parse_error"` for `type_mismatch.ig` and `unresolved_symbol.ig`, but the compiler result status is `"oof"`

The JSON `refusal_corpus` records all three refusal cases as `refusal_kind: "parse_error"`. However, examining the `command_matrix` `stdout_excerpt` for two of the three cases:

- `parse_refusal.ig`: stdout shows `"status": "error"` → correctly classified as a
  parse-stage error; `"parse_error"` is accurate.
- `type_mismatch.ig`: stdout shows `"status": "oof"` → an OOF (Out Of Feature)
  error at the typecheck stage; `"parse_error"` is **inaccurate** for this case.
- `unresolved_symbol.ig`: stdout shows `"status": "oof"` → same; `"parse_error"` is
  **inaccurate**.

Per C2-P1's normative result packet schema, the `refusal_kind` field accepts
`"parse_error|oof|qualified_stderr|other_named_refusal"`. The correct value for
these two cases is `"oof"`.

**This is not a blocker.** The PKG-5 PASS criteria are fully satisfied:
- exit status 1 (non-zero) for both cases ✓
- `.igapp` not written for both cases ✓
- `refusal_observed: true` for both cases ✓

The PKG-5 PASS criteria do not include `refusal_kind` correctness as a gate
condition — the gate is on exit status, `.igapp` absence, and `refusal_observed`.

C3-A should acknowledge the mislabeling for the audit record. Future smoke rounds
should correctly classify OOF refusals (TypeChecker-stage OOF errors) as `"oof"`,
not `"parse_error"`, in the `refusal_kind` field.

---

### NB-2: PKG-0 appears in `command_matrix` only, not in the `criteria` block

The JSON `criteria` block covers PKG-1..PKG-5 (consistent with C2-P1, which
defines only PKG-1..PKG-5 in its criteria matrix). PKG-0 (gemspec syntax check)
is a C1-P1 addition; it appears in the `command_matrix` with `exit_status: 0` and
`pass: true`.

S3-R172-C4-A's PASS definition requires "PKG-0 succeeds" as an independent
condition. PKG-0 does succeed and the evidence is present in the command_matrix.

**This is not a blocker.** The PASS determination is correct. If future smoke
rounds want PKG-0 in the `criteria` block for consistency, this can be added. For
now, the command_matrix entry is sufficient evidence.

---

## Verdict

**proceed — no blockers; 14/14 checks PASS.**

| Check | Result |
| --- | --- |
| CHK-1: smoke status derived from PKG criteria | PASS |
| CHK-2: PKG-0..PKG-5 evidence exists | PASS |
| CHK-3: installed CLI uses `$BIN_DIR/igc compile` | PASS |
| CHK-4: no command uses `igniter-lang compile` | PASS |
| CHK-5: no repo-relative `-I` or repo `RUBYLIB` | PASS |
| CHK-6: positive 5/5 and refusal 3/3 | PASS |
| CHK-7: non-claims present for PASS status | PASS |
| CHK-8: temp artifact policy followed | PASS |
| CHK-9: no version/gemspec/tag/push/publish/sign/deploy | PASS |
| CHK-10: no public release/demo claim | PASS |
| CHK-11: no profile-source extension was run | PASS |
| CHK-12: no compiler/runtime code surface changed | PASS |
| CHK-13: Spark absent | PASS |
| CHK-14: Ruby non-blocking | PASS |

The package/install smoke evidence is complete, correctly scoped, and correctly
closed. The isolation proof is machine-verified. The command forms are correct.
The non-claims are comprehensive and bound to the correct scope. The temp artifact
policy is consistent with C4-A authorization.

The C3-X NB-1 (durable record scope) raised in the prior authorization pressure
review is resolved: the summary JSON is committed under `experiments/` as C4-A
authorized; temp artifacts are not committed.

The C3-X NB-2 (optional profile-source scope) is resolved: profile-source is
explicitly deferred in C4-A and confirmed absent in the smoke execution.

The C3-X NB-3 (card placeholder) is resolved: `card: "S3-R173-C1-I"` is correct
in the JSON (no `C?-I` placeholder).

---

## Acceptance Recommendation for C3-A

**Accept the package/install smoke evidence as PASS. Establish installed-gem/
package readiness for the `repo_local_compiler_rc` scope based on this smoke.**

C3-A should:

1. **Record the smoke PASS** with run ID `S3R173C1I_20260525T063543Z` and the
   built gem SHA256 `sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a`;
2. **Accept the `refusal_kind` mislabeling** (NB-1) as non-blocking: the two
   cases labeled `"parse_error"` are actually `"oof"` — the PKG-5 gate criteria
   are still satisfied. Record this as an evidence annotation for future reference.
3. **Establish installed-gem/package readiness** for the bounded local smoke
   scope, carefully worded: smoke PASS evidence is accepted; this does not imply
   public release readiness, RubyGems availability, or production runtime.
4. Keep public release/demo claims, version/tag/push/publish/sign/deploy, Spark,
   and Ruby Framework surfaces closed.

---

## Closed Surfaces Confirmed

This pressure review does not open:

```text
public release or demo claims
installed-gem readiness beyond smoke PASS evidence acceptance
RubyGems publish
version file edits
git tag creation
git push
signing or deployment
profile-source smoke extension
public API/CLI widening
branch/conditional implementation
parser, classifier, TypeChecker, SemanticIR, assembler changes
compiler/library behavior changes
loader/report, CompilationReport, CompilerResult, CompatibilityReport widening
.igapp, .ilk, manifest, sidecar, artifact hash, or golden migration
PROP-036 or PROP-038 mutation
Spark access, fixtures, specs, integration, or production pressure
Ruby Framework docs/release/tag/package/compatibility claims
runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, deployment, or demo work
```

---

## Compact Receipt

```text
card:                              S3-R173-C2-X
track:                             compiler-release-package-install-smoke-pressure-v0
status:                            done
verdict:                           proceed
blockers:                          0
checks_passed:                     14/14
smoke_status:                      PASS (derived from PKG criteria)
run_id:                            S3R173C1I_20260525T063543Z
gem_name:                          igniter_lang
version:                           0.1.0.pre.stage2
executable_used:                   igc compile ($BIN_DIR/igc)
igniter_lang_compile_used:         no
repo_relative_i_used:              false
repo_path_leak_observed:           false
positive_corpus:                   5/5 PASS
refusal_corpus:                    3/3 PASS
non_claims:                        15 present for PASS status
temp_artifact_policy:              followed; gem not retained; gem home/bin/corpus cleaned
no_version_gemspec_tag_push_publish_sign_deploy: confirmed
no_public_release_demo_claim:      confirmed
no_profile_source_extension:       confirmed
no_code_surface_changed:           confirmed
spark:                             absent; non-authorizing
ruby_ledger_hardening:             independent_non_blocking
c3x_nb1_durable_record:            resolved (summary JSON in experiments/ as authorized)
c3x_nb2_profile_source:            resolved (explicitly deferred in C4-A; not run)
c3x_nb3_card_placeholder:          resolved (card field is S3-R173-C1-I)
nb_1:                              refusal_kind "parse_error" for type_mismatch/unresolved_symbol should be "oof"; PKG-5 criteria satisfied; non-blocking
nb_2:                              PKG-0 in command_matrix only, not criteria block; non-blocking
next_route:                        compiler-release-package-install-smoke-acceptance-decision-v0 (C3-A)
```
