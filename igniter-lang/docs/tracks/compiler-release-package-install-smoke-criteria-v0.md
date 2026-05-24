# Compiler Release Package/Install Smoke Criteria v0

Card: S3-R172-C2-P1
Agent: [Package Smoke Criteria Analyst]
Role: release-readiness-agent
Track: compiler-release-package-install-smoke-criteria-v0
Route: UPDATE
Status: done
Date: 2026-05-24

This is criteria only. It does not run package/install smoke, does not edit
code, does not build a release artifact, and does not authorize package/install
smoke execution.

---

## Inputs Read

- `docs/tracks/compiler-release-evidence-hash-docs-and-package-smoke-policy-v0.md`
- `docs/tracks/compiler-release-repo-local-rc-marker-acceptance-decision-v0.md`
- `docs/tracks/compiler-release-repo-local-rc-marker-v0.md`
- `experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json`
- `experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`
- `igniter_lang.gemspec` for executable inspection only

## Boundary Facts

| Fact | Value |
|------|-------|
| accepted marker | `repo_local_compiler_rc_marker` |
| accepted evidence scope | `repo_local_compiler_rc` |
| official evidence status | `PASS` |
| harness command matrix | 14/14 PASS by delegation |
| package/install smoke status | not authorized / not run |
| installed-gem/package readiness | not established |
| version change | not authorized; current `0.1.0.pre.stage2` |
| public claims | closed |
| package executable inspection | gemspec sets `spec.executables = ["igc"]` |

Required command correction:

```text
Installed CLI smoke command is `igc compile`.
Do not use `igniter-lang compile` unless a future package inspection proves that
the installed executable changed. Current package inspection proves `igc`.
```

## Compact Criteria Matrix

All PKG checks below are for a future bounded local package/install smoke only.
They do not imply RubyGems publication, public availability, production
readiness, release execution beyond the smoke, or installed-gem readiness until
an Architect/Portfolio decision accepts the smoke result.

| ID | Check | PASS | HOLD | FAIL |
|----|-------|------|------|------|
| PKG-1 | Build local gem | `gem build igniter_lang.gemspec` exits 0; exactly one `igniter_lang-<version>.gem` artifact is produced in the authorized temp build directory; version matches `IgniterLang::VERSION`; no repo file changes | build exits 0 but artifact location/name is ambiguous; multiple matching gems; temp dir or permission issue prevents artifact inspection | build exits non-zero; artifact has wrong gem name/version; build mutates version/git/source files |
| PKG-2 | Isolated local install | `gem install --local <built.gem>` into isolated `GEM_HOME` exits 0; `gem list igniter_lang -i --version <version>` succeeds inside that isolated env; installed executable `igc` is present | install exits 0 but `gem list` cannot confirm due GEM_HOME/PATH setup; executable exists but PATH export is missing; environment isolation cannot be proven | install exits non-zero; installed gem has wrong version/name; no `igc` executable is installed |
| PKG-3 | Require without repo `-I` | from outside the repo, `ruby -e 'require "igniter_lang"'` exits 0 using only isolated gem env; loaded spec path is inside isolated `GEM_HOME`; no repo-relative `-I` or `RUBYLIB` is used | `LoadError` after successful install, or loaded path cannot be proven isolated; adjudication should stop until packaging/load-path issue is fixed | non-LoadError initialization exception; loaded path resolves to repo checkout; require only passes with repo-relative `-I` |
| PKG-4 | Installed `igc compile` positive | installed `igc compile <positive.ig> --out <tmp>/<name>.igapp` exits 0 for every selected positive corpus source; stdout/result reports success; output `.igapp` exists and contains expected core artifacts | environment/PATH/temp-dir issue prevents invoking installed `igc`; positive corpus copy missing; output cannot be inspected due infrastructure issue | command uses `igniter-lang compile`; command exits non-zero; success result absent; output missing/corrupt; output is written outside authorized temp/output scope |
| PKG-5 | Installed `igc compile` refusal | installed `igc compile <negative.ig> --out <tmp>/<name>_should_not_exist.igapp` exits non-zero for every selected refusal corpus source; refusal is named/structured or stderr-qualified; no `.igapp` is written; no Ruby backtrace/crash | infrastructure crash/OOM/temp-dir issue; refusal output cannot be inspected; environment prevents separating CLI failure from setup failure | command uses `igniter-lang compile`; command exits 0; `.igapp` is written; refusal is silent/unnamed; compiler crashes with unhandled backtrace |

### Matrix-Level Result Rules

PASS:

- PKG-1 through PKG-5 are all PASS.
- `failed_checks` is empty.
- `hold_reasons` is empty.
- all non-claims are present in the result packet.

HOLD:

- any PKG row is HOLD; or
- the smoke cannot prove isolation from repo-relative `-I` / checkout paths; or
- the installed executable shape is ambiguous; or
- artifact cleanup/retention cannot be proven.

FAIL:

- any PKG row is FAIL; or
- any public/release/version/tag/publish/sign/deploy action occurs; or
- any smoke command uses `igniter-lang compile` instead of installed
  `igc compile`; or
- result packet omits required non-claims after execution.

## Required Corpus Criteria

Positive corpus should be copied from the accepted harness positive corpus into
the isolated smoke temp area before installed CLI invocation. Minimum required
set for this criteria packet:

```text
add_baseline.ig
boolean_gate.ig
integer_arithmetic.ig
multi_input_diverse.ig
poc_derived.ig
```

Refusal corpus should be copied from the accepted harness negative corpus into
the isolated smoke temp area. Minimum required set:

```text
parse_refusal.ig
type_mismatch.ig
unresolved_symbol.ig
```

Optional profile-source refusal checks may be added by the future authorization
card, but they must remain bounded to installed `igc compile` and must not open
loader/report/CompatibilityReport/public API widening.

## Required Summary / Result Packet Shape

Future smoke execution must write one machine-readable summary JSON with this
shape. Field names are normative for the future smoke result; example values are
illustrative.

```json
{
  "kind": "compiler_release_package_install_smoke_summary",
  "format_version": "0.1.0",
  "card": "S3-R172-C?-I",
  "track": "compiler-release-package-install-smoke-v0",
  "status": "PASS|HOLD|FAIL",
  "authorized_by": "S3-R172-C4-A",
  "executed_at_utc": "YYYY-MM-DDTHH:MM:SSZ",
  "release_scope": {
    "scope": "bounded_local_package_install_smoke",
    "source_marker": "repo_local_compiler_rc_marker",
    "source_evidence_scope": "repo_local_compiler_rc",
    "public_claims_authorized": false,
    "rubygems_publish_authorized": false,
    "production_runtime_authorized": false
  },
  "package": {
    "gem_name": "igniter_lang",
    "version": "0.1.0.pre.stage2",
    "built_gem_path": "<temp-or-retained-path>",
    "built_gem_sha256": "sha256:<hex>",
    "executable_expected": "igc",
    "executable_observed": "igc"
  },
  "environment": {
    "ruby_version": "<ruby -v>",
    "gem_home": "<isolated GEM_HOME>",
    "gem_path": "<isolated GEM_PATH>",
    "cwd_for_require": "<outside repo>",
    "repo_relative_i_used": false,
    "rubylib_points_to_repo": false
  },
  "criteria": {
    "PKG-1": {"status": "PASS|HOLD|FAIL", "summary": "..."},
    "PKG-2": {"status": "PASS|HOLD|FAIL", "summary": "..."},
    "PKG-3": {"status": "PASS|HOLD|FAIL", "summary": "..."},
    "PKG-4": {"status": "PASS|HOLD|FAIL", "summary": "..."},
    "PKG-5": {"status": "PASS|HOLD|FAIL", "summary": "..."}
  },
  "command_matrix": [
    {
      "id": "PKG-1",
      "kind": "gem_build",
      "cmd": "gem build igniter_lang.gemspec",
      "cwd": "igniter-lang",
      "exit_status": 0,
      "pass": true,
      "hold": false,
      "stdout_excerpt": "...",
      "stderr_excerpt": "...",
      "artifacts": ["igniter_lang-0.1.0.pre.stage2.gem"]
    }
  ],
  "positive_corpus": [
    {
      "name": "add_baseline",
      "source": "add_baseline.ig",
      "cmd_shape": "igc compile SOURCE --out OUT.igapp",
      "exit_status": 0,
      "igapp_written": true,
      "result_status": "ok",
      "pass": true
    }
  ],
  "refusal_corpus": [
    {
      "name": "parse_refusal",
      "source": "parse_refusal.ig",
      "cmd_shape": "igc compile SOURCE --out SHOULD_NOT_EXIST.igapp",
      "exit_status": 1,
      "igapp_written": false,
      "refusal_observed": true,
      "refusal_kind": "parse_error|oof|qualified_stderr|other_named_refusal",
      "pass": true
    }
  ],
  "failed_checks": [],
  "hold_reasons": [],
  "non_blocking_notes": [],
  "non_claims": {
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
  },
  "artifact_policy": {
    "temp_root": "/private/tmp/igniter_lang_package_install_smoke_<run_id>",
    "retained_summary_path": "igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/<run_id>/package_install_smoke_summary.json",
    "retain_command_logs": true,
    "retain_built_gem": false,
    "retain_positive_igapp_outputs": "authorization_defined",
    "cleanup_isolated_gem_home": true,
    "cleanup_temp_root": "after summary/log retention unless HOLD requires inspection"
  }
}
```

Required summary invariants:

- `status` must be derived from the PKG row statuses, not hand-written.
- `command_matrix` must include the exact commands run and must show installed
  `igc compile` for PKG-4 and PKG-5.
- `repo_relative_i_used` must be `false` for PKG-3 through PKG-5.
- `non_claims` must be present for PASS, HOLD, and FAIL.
- `failed_checks` and `hold_reasons` must identify the PKG IDs they come from.

## Artifact Cleanup / Retention Policy

Default future smoke temp layout:

```text
/private/tmp/igniter_lang_package_install_smoke_<run_id>/
  build/
  gem_home/
  corpus/
  out/
```

Retention rules:

| Artifact | Default | Reason |
|----------|---------|--------|
| summary JSON | retain under authorized experiment `out/<run_id>/` | primary evidence packet |
| command logs / stdout / stderr excerpts | retain | needed for pressure review |
| built `.gem` | do not retain by default; record SHA256 | avoid mistaking smoke artifact for releasable artifact |
| isolated `GEM_HOME` | cleanup after result packet | environment-only, not evidence |
| copied corpus | cleanup after result packet unless HOLD needs inspection | source corpus already exists in accepted harness |
| positive `.igapp` outputs | authorization-defined; if retained, label smoke-only | useful evidence but can be confused with release artifacts |
| refusal output paths | must not exist for PASS; record absence | verifies refusal behavior |

If a HOLD occurs because artifact inspection is impossible, keep the temp root
until pressure review records whether to rerun or clean it. If PASS or FAIL is
decided, cleanup should remove isolated install state and temp build/output
state after the retained summary/log packet is written.

## Closed Surfaces / Non-Authorization

This criteria packet does not authorize:

- running package/install smoke;
- gem build as a release artifact;
- gem publish or RubyGems availability claims;
- public release or demo claims;
- version file edits;
- git tag, push, signing, or deployment;
- package metadata changes;
- compiler/parser/classifier/TypeChecker/SemanticIR/assembler/runtime code
  changes;
- loader/report, CompatibilityReport, `.igapp`, `.ilk`, manifest, sidecar,
  artifact-hash, or golden migration widening;
- Spark, Ruby Framework compatibility, production runtime, Ledger/TBackend,
  BiHistory, stream/OLAP, cache, signing, or deployment claims.

## Compact Handoff

```text
Card: S3-R172-C2-P1
Track: compiler-release-package-install-smoke-criteria-v0
Status: done

Criteria:
  PKG-1 build local gem
  PKG-2 isolated local install
  PKG-3 require "igniter_lang" without repo-relative -I
  PKG-4 installed `igc compile` positive corpus
  PKG-5 installed `igc compile` refusal corpus

Command correction:
  installed CLI command is `igc compile`; current gemspec executable is `igc`.

Result:
  PASS only if PKG-1..PKG-5 all PASS and required non-claims are present.
  HOLD for environment/isolation/artifact-inspection ambiguity.
  FAIL for build/install/compiler/refusal regressions, wrong command name,
  omitted non-claims, or any public/version/tag/publish/sign/deploy action.

Next:
  C3-X pressure review, then C4-A authorization decision may decide whether a
  later bounded smoke execution card opens.
```
