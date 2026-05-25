# Compiler Release Profile-Source Installed Readiness Marker v0

Card: S3-R177-C1-S
Agent: [Status Curator]
Role: status-curator
Track: compiler-release-profile-source-installed-readiness-marker-v0
Route: UPDATE
Status: done
Date: 2026-05-25

Depends on:
- S3-R176-C3-A

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-v0.md`
- `igniter-lang/docs/tracks/stage3-round176-status-curation-v0.md`
- `igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json`
- `igniter-lang/docs/cards/S3/S3-R176.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/README.md`
- `igniter-lang/docs/cards/S3/S3.md`

---

## Marker

Accepted bounded marker:

```text
marker: bounded_profile_source_installed_smoke_readiness
scope: bounded_installed_package_profile_source_smoke
status: accepted
accepted_by: S3-R176-C3-A
run_id: S3R176C1I_20260525T101425Z
package: igniter_lang
version: 0.1.0.pre.stage2
built_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
summary:
  igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/S3R176C1I_20260525T101425Z/profile_source_install_smoke_summary.json
```

Allowed wording:

```text
The current local igniter_lang package builds, installs into an isolated gem
home, loads without repo-relative -I, and the installed igc CLI preserves the
accepted --compiler-profile-source PATH.json transport for one valid finalized
profile-source case, one malformed JSON preflight refusal, and one semantic
wrong-kind refusal.
```

This wording is the full extent of the marker. It is not public release
readiness, public docs readiness, RubyGems availability, production readiness,
or a demo claim.

---

## Accepted PSS Results

```text
PSS-0: PASS - isolated build/install/require; no repo path leak
PSS-1: PASS - installed $BIN_DIR/igc and explicit --compiler-profile-source PATH.json
PSS-2: PASS - valid finalized profile source; .igapp; manifest profile id matches
PSS-3: PASS - malformed JSON preflight refusal; stderr-only; no .igapp; no report
PSS-4: PASS - wrong-kind semantic refusal; compiler_result JSON; report; qualified diagnostic
PSS-5: PASS - no finalization/discovery/defaulting
PSS-6: PASS - refusal-kind labels match behavior
PSS-7: PASS - all non-claims true
PSS-8: PASS - no repo artifact leak beyond authorized script and summary
```

Top-level smoke result:

```text
status: PASS
failed_checks: 0
hold_reasons: 0
refusal_kind_hygiene_status: pass
pressure: proceed_19_of_19_no_blockers
```

---

## Accepted Case Behaviors

### PSS-2 Success

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

### PSS-3 Preflight Refusal

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

PSS-3 is CLI-owned path/JSON preflight before compiler invocation. It writes no
`.igapp` and no compilation report.

### PSS-4 Semantic Refusal

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

PSS-4 passes CLI preflight and fails inside the compiler/assembler path with a
qualified `compiler_profile_source.*` diagnostic. It writes a compilation
report and no `.igapp`.

---

## Hygiene Notes

NB-1 from R176 is preserved as non-blocking hygiene:

```text
partial_temp_out_cleanup_non_blocking
```

The temp `out/` directory remained under `/private/tmp`, but no generated
`.igapp`, `.gem`, compilation report, fixture copy, gem home, or bindir was
retained in the repo. Future smoke scripts should either fully remove temp
`out/` after writing the durable summary or record partial cleanup precisely.

---

## Not Allowed Wording

Do not claim:

- "Igniter-Lang is released."
- "Igniter-Lang is available on RubyGems."
- "Igniter-Lang is production ready."
- "Public demo ready."
- "Public release/docs readiness is complete."
- "Supports all grammar."
- "Supports branch/conditional if_expr."
- "Profile discovery/defaulting/finalization is supported."
- "Spark integrated."
- "Ruby Framework compatible."

---

## Closed Surfaces

Remain closed:

```text
public release/demo claims
public release/docs readiness
release execution
RubyGems publish
version edits
gemspec/package metadata edits
git tag creation
git push
publishing
signing
deployment
profile finalization/discovery/defaulting
named/generated profile lookup
inline JSON profile input
env/config/sidecar profile lookup
public API/CLI widening beyond --compiler-profile-source PATH.json
loader/report or CompatibilityReport claim
runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache/production behavior
branch/conditional if_expr support
Spark integration or production pressure
Ruby Framework compatibility claim
runtime, production, deployment, signing, or demo work
```

---

## Compact Handoff

```text
[Status Curator]
Track: compiler-release-profile-source-installed-readiness-marker-v0
Status: done

[D] Decisions:
- Bounded profile-source installed smoke readiness marker recorded from
  S3-R176-C3-A accepted PASS evidence.
- Allowed wording is the exact bounded installed-package profile-source smoke
  statement from S3-R176-C3-A.
- Public release/docs readiness, release execution, RubyGems publish, public
  claims, version/tag/push/publish/sign/deploy, profile finalization/discovery/
  defaulting, branch/conditional if_expr, Spark, runtime, and production remain
  closed.

[R] Recommendation:
- Continue R177 with pressure review of this marker before any next release
  vector decision.

[S] Signals:
- Run S3R176C1I_20260525T101425Z PASS.
- PSS-0..PSS-8 PASS, failed_checks 0, hold_reasons 0.
- NB-1 temp cleanup hygiene is non-blocking.

[T] Tests / Proofs:
- No smoke run by this card.
- No code edited.

[Files] Changed:
- igniter-lang/docs/tracks/compiler-release-profile-source-installed-readiness-marker-v0.md
- igniter-lang/docs/current-status.md
- igniter-lang/docs/tracks/README.md
- igniter-lang/docs/cards/S3/S3.md
- igniter-lang/docs/cards/S3/S3-R176.md

[Next] Proposed next slice:
- compiler-release-profile-source-installed-readiness-marker-pressure-v0
```

