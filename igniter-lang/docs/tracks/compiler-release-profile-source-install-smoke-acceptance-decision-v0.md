# Compiler Release Profile-Source Install Smoke Acceptance Decision v0

Card: S3-R176-C3-A  
Agent: [Portfolio Architect Supervisor]  
Role: portfolio-architect-supervisor  
Track: compiler-release-profile-source-install-smoke-acceptance-decision-v0  
Route: UPDATE  
Status: done  
Date: 2026-05-25

Depends on:
- S3-R176-C1-I
- S3-R176-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-v0.md`
- `igniter-lang/docs/discussions/compiler-release-profile-source-install-smoke-pressure-v0.md`
- `igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json`
- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-authorization-review-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-criteria-v0.md`
- `igniter-lang/docs/tracks/stage3-round175-status-curation-v0.md`

---

## Decision

Decision:

```text
accept profile-source install smoke closure
recognize bounded installed-package profile-source smoke readiness evidence
carry temp cleanup hygiene note as non-blocking
open profile-source installed readiness marker/status next
keep public release/demo claims closed
keep release execution closed
keep RubyGems publish closed
keep version/tag/push/publish/sign/deploy closed
keep profile finalization/discovery/defaulting closed
keep branch/conditional if_expr excluded
keep Spark out of scope
```

The S3-R176-C1-I smoke evidence is accepted as PASS for this bounded scope:

```text
bounded_installed_package_profile_source_smoke
```

The smoke proves that the installed `igniter_lang` package preserves the
already-landed `igc compile --compiler-profile-source PATH.json` transport for:

- valid finalized profile source success;
- CLI-owned malformed JSON preflight refusal;
- compiler/assembler-path semantic wrong-kind refusal.

This does not authorize public release/demo claims, release execution, RubyGems
publish, version/tag/push/publish/sign/deploy, profile discovery/defaulting/
finalization, or any public API/CLI widening.

---

## Accepted Evidence

| Field | Accepted value |
| --- | --- |
| smoke card | `S3-R176-C1-I` |
| smoke track | `compiler-release-profile-source-install-smoke-v0` |
| run id | `S3R176C1I_20260525T101425Z` |
| status | `PASS` |
| package | `igniter_lang` |
| version | `0.1.0.pre.stage2` |
| base run id | `S3R173C1I_20260525T063543Z` |
| built gem SHA256 | `sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a` |
| installed command | `igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json` |
| expected manifest profile id | `compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7` |
| refusal-kind hygiene | `pass` |
| failed checks | `0` |
| hold reasons | `0` |

Accepted PSS results:

```text
PSS-0 PASS - isolated build/install/require; no repo path leak
PSS-1 PASS - installed $BIN_DIR/igc and explicit --compiler-profile-source PATH.json
PSS-2 PASS - valid finalized profile source; .igapp; manifest profile id matches
PSS-3 PASS - malformed JSON preflight refusal; stderr-only; no .igapp; no report
PSS-4 PASS - wrong-kind semantic refusal; compiler_result JSON; report; qualified diagnostic
PSS-5 PASS - no finalization/discovery/defaulting
PSS-6 PASS - refusal-kind labels match behavior
PSS-7 PASS - all non-claims true
PSS-8 PASS - no repo artifact leak beyond authorized script and summary
```

Durable summary:

```text
igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json
```

---

## Success / Refusal Acceptance

### Success Case

Accepted:

```text
profile_source: finalized_profile_source.json
exit_status: 0
result_status: ok
igapp_written: true
manifest.compiler_profile_id:
  compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
expected_compiler_profile_id:
  compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
profile_id_match: true
```

This accepts the installed package transport for caller-supplied finalized
profile-source input only. It does not imply profile finalization, discovery, or
defaulting support.

### Preflight Refusal

Accepted:

```text
profile_source: malformed_profile_source.json
refusal_kind: profile_source_preflight
exit_status: 1
stdout_shape: empty
stderr_shape: one_line_text
stderr: "compiler profile source file must contain valid JSON"
igapp_written: false
compilation_report_written: false
```

This preserves the expected PSS-3 behavior: CLI-owned path/JSON preflight occurs
before compiler invocation and writes no compilation report.

### Semantic Refusal

Accepted:

```text
profile_source: semantic_profile_source_wrong_kind.json
refusal_kind: profile_source_semantic_refusal
exit_status: 1
stdout_shape: compiler_result_json
result_status: assembler_refused
stderr_shape: empty
igapp_written: false
compilation_report_written: true
observed_diagnostic:
  add_baseline: compiler_profile_source.wrong_kind: "not_a_compiler_profile_id_source"
```

This preserves the expected PSS-4 behavior: object-level semantic refusal occurs
inside the compiler/assembler path and writes a compilation report with qualified
`compiler_profile_source.*` diagnostics.

The PSS-3/PSS-4 report distinction is accepted as intentional.

---

## Pressure Verdict

S3-R176-C2-X verdict:

```text
proceed - no blockers; 19/19 checks PASS
```

Accepted pressure conclusions:

- PASS is correctly derived from PSS-0..PSS-8.
- Installed package isolation is proven.
- `$BIN_DIR/igc` was used, not repo-local `bin/igc`.
- No repo-relative `-I` or repo `RUBYLIB`.
- Success case proves expected `manifest.compiler_profile_id`.
- PSS-3 writes no `.igapp` and no compilation report.
- PSS-4 writes no `.igapp`, writes a report, and includes a qualified
  `compiler_profile_source.*` diagnostic.
- Refusal-kind hygiene is correct.
- All 24 non-claims are true.
- No repo artifacts leaked beyond the authorized script and summary JSON.
- Public release/demo, release execution, RubyGems publish, version/tag/push/
  publish/sign/deploy, profile finalization/discovery/defaulting, API/CLI
  widening, branch/conditional, Spark, runtime, and production remain closed.

---

## Accepted Non-Blocking Notes

### NB-1: Partial temp cleanup

The temp root remained under:

```text
/private/tmp/igniter_lang_profile_source_install_smoke_S3R176C1I_20260525T101425Z/
```

with an `out/` directory containing the temporary success `.igapp` and semantic
refusal compilation report.

Accepted disposition:

```text
non_blocking_hygiene
```

Reason:

- No generated `.igapp`, `.gem`, compilation report, fixture copy, gem home, or
  bindir was retained in the repo.
- The remaining files are in `/private/tmp`.
- PSS-8's repo-retention boundary is satisfied.

Future smoke scripts should either:

- fully remove the temp `out/` directory after writing the durable summary; or
- record cleanup as `partial_temp_out_retained` instead of `cleanup_temp_root:
  "after summary written"`.

This is not a blocker for accepting R176.

### NB-2: Prior non-claims count wording

The prior S3-R175-C3-X pressure review said "23-field non-claims block." The
actual accepted criteria, authorization, and implementation use 24 fields, all
true. This is a documentation count nuance only and does not affect R176.

---

## Readiness Recognition

Installed package profile-source smoke readiness may now be recognized only for
this bounded scope:

```text
bounded installed-package profile-source smoke readiness for igniter_lang
0.1.0.pre.stage2
```

Allowed wording:

```text
The current local igniter_lang package builds, installs into an isolated gem
home, loads without repo-relative -I, and the installed igc CLI preserves the
accepted --compiler-profile-source PATH.json transport for one valid finalized
profile-source case, one malformed JSON preflight refusal, and one semantic
wrong-kind refusal.
```

Not allowed:

- "Igniter-Lang is released."
- "Igniter-Lang is available on RubyGems."
- "Igniter-Lang is production ready."
- "Public demo ready."
- "Supports all grammar."
- "Supports branch/conditional if_expr."
- "Profile discovery/defaulting/finalization is supported."
- "Spark integrated."
- "Ruby Framework compatible."

---

## Explicit Answers

Is the smoke evidence accepted?

```text
Yes. The S3-R176-C1-I profile-source install smoke evidence is accepted as PASS.
```

May bounded profile-source installed readiness be recognized?

```text
Yes, for bounded installed-package profile-source smoke only.
```

Does release execution remain closed?

```text
Yes. Release execution remains closed.
```

Do public release/demo claims remain closed?

```text
Yes. Public release/demo claims remain closed.
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

Does public API/CLI widening remain closed?

```text
Yes. The only accepted CLI shape remains
`--compiler-profile-source PATH.json`.
```

Does profile finalization/discovery/defaulting remain closed?

```text
Yes. R176 uses caller-supplied finalized files only.
```

Does branch/conditional `if_expr` remain excluded?

```text
Yes. Branch/conditional `if_expr` remains excluded from this release-readiness
scope.
```

Does Spark remain out of scope?

```text
Yes. Spark remains out of scope and non-authorizing for this round.
```

---

## Next Route Decision

Selected next route:

```text
profile-source installed readiness marker/status
```

Reason:

- R176 establishes profile-source transport evidence as a bounded installed
  package smoke.
- A marker/status route should record the exact accepted state before public
  docs/non-claims planning or release-execution authorization review.
- The accepted state is nuanced and must not be overclaimed.

Rejected for immediate next route:

| Route | Disposition |
| --- | --- |
| public release/docs non-claims planning | defer until profile-source readiness marker is recorded |
| release execution authorization hold | defer; record marker first |
| additional package smoke hygiene | not required; NB-1 is non-blocking hygiene |
| return to compiler/language feature lane | not chosen for immediate release vector |
| pause | not chosen |

---

## Next Dispatch Recommendation

```text
Card: S3-R177-C1-S
Agent: [Status Curator]
Role: status-curator
Track: compiler-release-profile-source-installed-readiness-marker-v0

Route: UPDATE
Depends on:
- S3-R176-C3-A

Goal:
Record the accepted bounded installed-package profile-source smoke readiness
marker, preserving all public non-claims and closed surfaces.

Scope:
- Read:
  - igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-v0.md
  - igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json
  - igniter-lang/docs/tracks/stage3-round176-status-curation-v0.md if present
- Write only:
  - igniter-lang/docs/tracks/compiler-release-profile-source-installed-readiness-marker-v0.md
  - igniter-lang/docs/current-status.md
  - igniter-lang/docs/tracks/README.md
  - igniter-lang/docs/cards/S3/S3.md
- Record:
  - bounded profile-source installed smoke accepted;
  - run id, package/version, SHA256;
  - PSS-0..PSS-8 PASS;
  - PSS-2/PSS-3/PSS-4 accepted behavior;
  - NB-1 temp cleanup hygiene note;
  - public release/demo claims closed;
  - release execution closed;
  - RubyGems publish closed;
  - version/tag/push/publish/sign/deploy closed;
  - profile finalization/discovery/defaulting closed;
  - branch/conditional if_expr excluded.
- Do not:
  - run smoke;
  - publish gems;
  - create tags;
  - edit versions;
  - make public claims;
  - edit compiler/runtime code.

Deliver:
- Marker/status track doc
- Updated current status/index entries
- Compact handoff
```

---

## Compact Decision Summary

```text
card: S3-R176-C3-A
track: compiler-release-profile-source-install-smoke-acceptance-decision-v0
decision: accept_smoke_closure
scope: bounded_installed_package_profile_source_smoke
run_id: S3R176C1I_20260525T101425Z
package: igniter_lang
version: 0.1.0.pre.stage2
sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
command: installed_igc_compile_with_--compiler-profile-source_PATH_json
PSS-0..PSS-8: PASS
success_case: PASS_manifest_profile_id_matches
preflight_refusal: PASS_no_igapp_no_report
semantic_refusal: PASS_report_present_qualified_compiler_profile_source_diag
refusal_kind_hygiene: pass
failed_checks: 0
hold_reasons: 0
pressure: proceed_19_of_19_no_blockers
nb_1: partial_temp_out_cleanup_non_blocking
public_release_demo_claims: closed
release_execution: closed
rubygems_publish: closed
version_tag_push_publish_sign_deploy: closed
profile_finalization_discovery_defaulting: closed
public_api_cli_widening: closed
branch_conditional_if_expr: excluded
spark: out_of_scope
next_route: profile_source_installed_readiness_marker
```

