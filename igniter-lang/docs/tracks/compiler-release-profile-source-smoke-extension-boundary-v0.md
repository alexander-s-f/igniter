# Compiler Release Profile-Source Smoke Extension Boundary v0

Card: S3-R175-C1-P1  
Agent: `[Profile Source Smoke Boundary Analyst]`  
Role: `release-readiness-agent`  
Track: `compiler-release-profile-source-smoke-extension-boundary-v0`  
Route: UPDATE  
Status: done / boundary-defined  
Date: 2026-05-25

Depends on:

- S3-R174-C4-A
- S3-R173-C3-A

---

## Purpose

Prepare the exact boundary for a possible installed-package profile-source smoke
extension after the local package/install smoke readiness marker was accepted.

This card does not run smoke, does not edit code, and does not authorize
execution. It defines the smallest next smoke shape that can test the accepted
bounded PROP-036 CLI transport inside the installed `igc` package context.

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-installed-readiness-and-next-vector-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-installed-gem-readiness-marker-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md`
- `igniter-lang/docs/tracks/compiler-release-evidence-hash-docs-and-package-smoke-policy-v0.md`
- `igniter-lang/docs/tracks/stage3-round173-status-curation-v0.md`
- `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json`
- `igniter-lang/docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `igniter-lang/docs/tracks/prop036-cli-profile-source-b3-b6-implementation-proof-v0.md`
- `igniter-lang/docs/tracks/compiler-profile-source-mode-static-data-internal-carrier-implementation-v0.md`
- `rg "compiler_profile_source|--compiler-profile-source|profile_source" igniter-lang/experiments igniter-lang/docs`

---

## Current Fixed Evidence

Accepted installed package/install readiness:

```text
scope: local_package_install_smoke_only
package: igniter_lang
version: 0.1.0.pre.stage2
run_id: S3R173C1I_20260525T063543Z
built_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
installed_cli: igc compile
positive_corpus: 5/5 PASS
refusal_corpus: 3/3 PASS
failed_checks: 0
hold_reasons: 0
```

Accepted wording remains bounded:

```text
The current local igniter_lang package builds, installs into an isolated gem
home, loads without repo-relative -I, and the installed igc CLI compiles the
accepted positive corpus and refuses the accepted negative corpus.
```

No stronger release, RubyGems, production, demo, Spark, branch/conditional, or
all-grammar claim is authorized.

---

## Exact Profile-Source Smoke Purpose

The profile-source smoke extension should answer one narrow package-readiness
question:

```text
After local gem build/install into an isolated GEM_HOME, does the installed
igc executable preserve the already-bounded PROP-036
--compiler-profile-source PATH.json behavior for caller-supplied finalized
profile-source input and expected profile-source refusals?
```

It should not test new language semantics, new profile finalization, profile
discovery/defaulting, loader/report interpretation, CompatibilityReport status,
runtime readiness, or production behavior.

---

## Installed Command Shape

Future execution, if authorized, should use the installed executable from the
isolated gem install:

```bash
env GEM_HOME=$GEM_HOME_DIR GEM_PATH=$GEM_HOME_DIR PATH=$BIN_DIR:$PATH \
  $BIN_DIR/igc compile SOURCE.ig \
  --out $OUT_DIR/NAME.igapp \
  --compiler-profile-source PROFILE_SOURCE.json
```

Required command constraints:

- call `$BIN_DIR/igc`, not repo-local `bin/igc`;
- no `ruby -I igniter-lang/lib`;
- no repo `RUBYLIB`;
- no `igniter-lang compile` alias;
- no inline JSON;
- no named profile lookup;
- no env/config/sidecar discovery;
- no source finalization during smoke.

---

## Fixture And Corpus Candidates

### Recommended Source Fixture

Use the accepted release harness source:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig
```

Reason: it is already part of the accepted package/install positive corpus and
keeps this extension focused on profile-source transport rather than language
coverage.

### Recommended Profile-Source Fixtures

Use existing fixtures/artifacts. No new committed fixture is required.

Primary valid fixture:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/finalized_profile_source.json
```

This fixture is equivalent in shape/content to the stable standalone artifact:

```text
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json
```

Recommended refusal fixtures:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/malformed_profile_source.json
igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/semantic_profile_source_wrong_kind.json
```

Optional expanded refusal inputs, only if the authorizing card wants broader
B3/B5 coverage:

```text
igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/out/inputs/unfinalized_source.json
igniter-lang/experiments/prop036_cli_profile_source_b3_b6_implementation_proof/out/inputs/runtime_authority_source.json
```

Recommendation: keep the first installed-package profile-source smoke minimal
and use the release-harness fixtures. Do not reach into older proof-output
fixtures unless the authorization explicitly asks for expanded semantic refusal
coverage.

---

## Expected Behavior

### Success Case

Recommended required positive case:

```text
add_baseline.ig
  + finalized_profile_source.json
  -> exit 0
  -> compiler_result status ok
  -> .igapp emitted under temp out dir
  -> manifest.compiler_profile_id equals
     compiler_profile_unified/sha256:a3829357ff3d34d23a82f5b7
```

This is a transport/package confidence check only. It does not imply runtime
readiness or production readiness.

### Refusal Cases

Recommended required refusal cases:

```text
bad path or malformed JSON preflight
  -> exit non-zero
  -> stdout empty or no compiler_result JSON
  -> stderr one-line preflight refusal
  -> no .igapp
  -> no compilation report

semantic wrong-kind source
  -> exit non-zero
  -> compiler_result / assembler refusal path allowed
  -> qualified compiler_profile_source.* diagnostic allowed
  -> no .igapp
```

Recommended first smoke should exercise **both success and refusal**. Success
alone would not prove the installed CLI preserves the existing B3/B5 refusal
boundary. Refusal alone would not prove the installed package carries the valid
profile-source manifest identity path.

---

## Temp Artifact And Output Policy

Future execution should create a unique temp root:

```text
/private/tmp/igniter_lang_profile_source_install_smoke_${CARD}_${TIMESTAMP}/
```

Allowed temp outputs:

- built `.gem`;
- isolated gem home;
- isolated bindir;
- copied source/profile fixtures;
- success `.igapp` output;
- refusal stdout/stderr captures;
- smoke-local summary JSON.

Recommended durable summary if execution is later authorized:

```text
igniter-lang/experiments/compiler_release_profile_source_install_smoke_v0/out/$RUN_ID/profile_source_install_smoke_summary.json
```

Do not commit:

- built `.gem`;
- gem home;
- bindir;
- temp copied corpus;
- generated `.igapp`;
- refusal output paths;
- profile-source copies.

If a durable summary is authorized, it should record paths and digests only.

---

## PASS / HOLD / FAIL Criteria

### PASS

All required cases pass:

- installed `$BIN_DIR/igc compile ... --compiler-profile-source PATH.json`
  positive case exits 0;
- positive `.igapp` exists in temp out dir;
- positive manifest contains expected `compiler_profile_id`;
- preflight refusal exits non-zero and writes no `.igapp`;
- semantic refusal exits non-zero and writes no `.igapp`;
- no repo-relative `-I`, no repo `RUBYLIB`, no repo path leak;
- no public/release/demo/version/tag/push/publish/sign/deploy action.

### HOLD

Hold rather than fail if package mechanics are inconclusive:

- installed `igc` missing after gem install;
- isolated `require "igniter_lang"` fails after package smoke setup;
- temp filesystem permission issue prevents writing under `/private/tmp`;
- profile-source fixture path cannot be read because the fixture was moved by a
  separate track.

### FAIL

Fail if bounded behavior regresses:

- valid finalized profile source exits non-zero;
- manifest omits or changes expected `compiler_profile_id`;
- preflight refusal writes `.igapp` or compilation report;
- semantic refusal writes `.igapp`;
- CLI performs discovery/defaulting/finalization;
- command uses repo-local `-I` or repo `RUBYLIB` for installed check.

---

## Explicit Answers

### Is profile-source smoke appropriate next?

Yes. It is the best next release-readiness vector after accepted installed
package/install smoke because the package smoke intentionally deferred
profile-source coverage and R174 selected this route for authorization review.

### Should it use installed `igc compile --compiler-profile-source PATH.json`?

Yes. The smoke should use the installed `$BIN_DIR/igc compile` command with an
explicit path:

```text
$BIN_DIR/igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

No repo-local `bin/igc`, no `ruby -I`, and no alternative input shape.

### Should it exercise success, refusal, or both?

Both. Minimum recommended set:

```text
1 success: add_baseline.ig + finalized_profile_source.json
1 preflight refusal: missing path or malformed_profile_source.json
1 semantic refusal: semantic_profile_source_wrong_kind.json
```

### May it reuse existing profile-source proof artifacts?

Yes, but prefer the release-harness fixtures:

```text
experiments/compiler_release_acceptance_harness_v0/fixtures/finalized_profile_source.json
experiments/compiler_release_acceptance_harness_v0/fixtures/malformed_profile_source.json
experiments/compiler_release_acceptance_harness_v0/fixtures/semantic_profile_source_wrong_kind.json
```

The stable standalone artifact
`minimal_compiler_profile_finalization_proof/out/compiler_profile_source.stage3_proof.json`
is sufficient for the valid case, but the release-harness fixture is the cleaner
first choice for package smoke.

No new committed smoke-local fixture is required.

### Is any public API/CLI widening required?

No. The accepted public CLI shape already exists:

```text
--compiler-profile-source PATH.json
```

The smoke must not add inline JSON, named lookup, env/config/sidecar lookup,
defaulting, discovery, finalization, or new flags.

### Is profile finalization/discovery/defaulting allowed?

No. The profile source must be caller-supplied and already finalized.

### Does branch/conditional `if_expr` remain excluded?

Yes. Branch/conditional `if_expr` remains excluded from this release-readiness
vector and must not be added to the smoke corpus or wording.

---

## Non-Claims

This boundary does not authorize:

- smoke execution;
- public release or demo claims;
- RubyGems publish;
- version edits;
- gemspec edits;
- git tag creation;
- git push;
- signing;
- deployment;
- public API/CLI widening;
- profile finalization, discovery, defaulting, named lookup, inline JSON, or
  env/config/sidecar lookup;
- loader/report or CompatibilityReport status;
- `.ilk`, receipts, dispatch migration, artifact hash/golden migration;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior;
- Spark fixture/spec/integration;
- branch/conditional `if_expr`;
- demo work.

---

## Risks

| Risk | Disposition |
| --- | --- |
| Valid profile-source fixture exists in multiple locations | Prefer release-harness fixture for smoke; standalone proof artifact remains acceptable backup. |
| Semantic refusal writes compilation report while preflight refusal should not | Accept this distinction; it matches existing B3/B5 behavior. |
| Re-running full package smoke plus profile-source cases increases runtime | Acceptable if execution card keeps temp outputs isolated and summary-only durable record. |
| Profile-source smoke could be misread as profile finalization support | Mitigate with explicit non-claims and use already-finalized fixture only. |
| Branch/conditional pressure may try to enter corpus | Keep excluded; no `if_expr` fixture in this smoke. |

---

## Compact Boundary Packet

```text
card: S3-R175-C1-P1
track: compiler-release-profile-source-smoke-extension-boundary-v0
status: boundary_defined

purpose:
  installed_package_profile_source_transport_confidence

installed_command:
  $BIN_DIR/igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json

recommended_required_cases:
  success:
    source: experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig
    profile_source: experiments/compiler_release_acceptance_harness_v0/fixtures/finalized_profile_source.json
    expected: exit_0 + .igapp + manifest.compiler_profile_id
  preflight_refusal:
    profile_source: bad_path_or_malformed_profile_source.json
    expected: nonzero + no .igapp + no compilation_report
  semantic_refusal:
    profile_source: semantic_profile_source_wrong_kind.json
    expected: nonzero + compiler_profile_source.* diagnostic + no .igapp

fixture_policy:
  reuse_existing_release_harness_fixtures: yes
  new_committed_fixture_required: no
  copy_to_temp_root_when_running: allowed

temp_policy:
  root: /private/tmp/igniter_lang_profile_source_install_smoke_${CARD}_${TIMESTAMP}
  durable_repo_artifact_if_authorized:
    experiments/compiler_release_profile_source_install_smoke_v0/out/$RUN_ID/profile_source_install_smoke_summary.json
  commit_temp_outputs: no

closed:
  smoke_execution: closed_by_this_card
  public_release_demo_claims: closed
  rubygems_publish: closed
  version_tag_push_publish_sign_deploy: closed
  public_api_cli_widening: closed
  profile_finalization_discovery_defaulting: closed
  branch_conditional_if_expr: excluded
  runtime_spark_production: closed

recommendation:
  authorize_next_bounded_execution_card: yes
  implementation_or_surface_widening: no
```

---

## Recommended Authorization Stance

Recommendation: **authorize a narrow execution card next**, not execution in
this card.

The next card may run a bounded installed-package profile-source smoke using
the command and fixture policy above. It should preserve all R173/R174
non-claims and should not request implementation, public release, RubyGems
publish, profile discovery/finalization, public API/CLI widening, runtime,
Spark, production, demo, or branch/conditional support.

Recommended next track name:

```text
compiler-release-profile-source-install-smoke-v0
```

---

## Handoff

```text
[Profile Source Smoke Boundary Analyst]
Track: igniter-lang/compiler-release-profile-source-smoke-extension-boundary-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent | Research Agent

[D] Decisions:
- Profile-source smoke is appropriate next as a bounded installed-package
  confidence extension.
- The command shape must be installed `$BIN_DIR/igc compile ... --compiler-profile-source PATH.json`.
- The first smoke should cover both success and refusal.
- Existing release-harness profile-source fixtures are sufficient; no new
  committed fixture is required.

[R] Recommendations:
- Authorize a narrow execution card next.
- Keep public release/demo, RubyGems, version/tag/push/publish/sign/deploy,
  runtime, Spark, production, and branch/conditional claims closed.

[S] Signals:
- R173 package/install smoke accepted PASS.
- R174 selected profile-source smoke authorization review as next vector.
- PROP-036 bounded CLI transport already exists; no CLI/API widening needed.

[T] Tests / Proofs:
- No smoke run by this card.
- No code edited.

[Files] Changed:
- `igniter-lang/docs/tracks/compiler-release-profile-source-smoke-extension-boundary-v0.md`

[Q] Open Questions:
- Should the execution card include both malformed JSON and bad-path preflight,
  or choose one minimum preflight refusal?
- Should expanded semantic refusals include unfinalized/runtime-authority inputs,
  or stay with wrong-kind for the first installed-package smoke?

[X] Rejected:
- No inline JSON, named lookup, env/config/sidecar lookup, discovery,
  defaulting, finalization, loader/report, CompatibilityReport, runtime,
  Spark, production, demo, or `if_expr` support.

[Next] Proposed next slice:
- `compiler-release-profile-source-install-smoke-v0` as a bounded execution
  card using existing release-harness fixtures and temp-only outputs.
```
