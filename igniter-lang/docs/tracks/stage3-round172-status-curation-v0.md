# Stage 3 Round 172 Status Curation v0

Card: S3-R172-C5-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round172-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-24

Depends on:
- S3-R172-C4-A

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-authorization-review-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-boundary-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-criteria-v0.md`
- `igniter-lang/docs/discussions/compiler-release-package-install-smoke-authorization-pressure-v0.md`
- `igniter-lang/docs/cards/S3/S3-R172.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/README.md`

---

## Package / Install Smoke Authorization Status

R172 C4-A authorizes only the next bounded local package/install smoke execution
card:

```text
Card: S3-R173-C1-I
Track: compiler-release-package-install-smoke-v0
smoke_target: local_package_install_smoke_current_version
package: igniter_lang
version: 0.1.0.pre.stage2
installed_cli_required: igc compile
```

Authorized repo write scope:

```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/**
igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md
```

Authorized temp write scope:

```text
/private/tmp/igniter_lang_package_install_smoke_<run_id>/**
```

The durable summary JSON under
`igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/<run_id>/`
is explicitly authorized as evidence. Temp build/install artifacts are not
authorized as repo artifacts.

---

## Installed-Gem / Package Readiness Status

Installed-gem/package readiness remains not established.

R172 authorizes smoke execution only. Readiness may be claimed only after the
smoke produces PASS evidence and a later decision accepts that evidence.

---

## Release / Public Claims Status

Public release and demo claims remain closed.

Smoke PASS, if it lands later, must not be labeled as public release readiness,
RubyGems availability, production readiness, Spark integration, or Ruby
Framework compatibility.

---

## Version / Tag / Push / Publish Status

The current package version remains:

```text
0.1.0.pre.stage2
```

R172 C4-A does not authorize:

- version file edits;
- gemspec edits;
- git tag creation;
- git push;
- RubyGems publish;
- signing;
- deployment.

The smoke must build/install only the current local package in isolated temp
state and must not mutate release metadata.

---

## Command / Criteria Status

R172 C4-A adopts the C2-P1 criteria with binding refinements:

- installed CLI checks must use `igc compile`;
- `igniter-lang compile` is forbidden unless a later package inspection proves
  that executable is installed;
- optional profile-source checks are deferred;
- no `--compiler-profile-source` smoke extension is authorized in the baseline
  execution card;
- PASS requires PKG-0 through PKG-5 to pass, all 5 positive corpus files to
  compile via installed `$BIN_DIR/igc`, all 3 negative corpus files to refuse
  via installed `$BIN_DIR/igc`, no failed checks, no hold reasons, required
  non-claims present, and no repo-relative `-I`/repo `RUBYLIB` for installed
  checks.

---

## Current Next Route

Run the bounded smoke execution card next:

```text
Card: S3-R173-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: compiler-release-package-install-smoke-v0
Route: UPDATE
```

The next card may run only the authorized package/install smoke command matrix
and write only the authorized evidence outputs.

---

## Closed Surfaces

R172 C4-A does not authorize:

- public release or demo claims;
- installed-gem/package readiness acceptance;
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
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

---

## Compact Round Summary

R172 accepts the package/install smoke boundary and criteria, pressure passes
11/11 with no blockers, and C4-A authorizes only the next bounded local
package/install smoke execution card. This opens evidence gathering for
`local_package_install_smoke_current_version`; it does not establish installed
package readiness and does not open public claims, version/tag/publish/sign/
deploy, Spark, runtime, production, or profile-source smoke.

---

## Round Receipt

```text
round: S3-R172
status: closed
status_curator_card: S3-R172-C5-S
decision: authorize_bounded_local_package_install_smoke_next
next_card: S3-R173-C1-I
next_track: compiler-release-package-install-smoke-v0
smoke_target: local_package_install_smoke_current_version
package: igniter_lang
version: 0.1.0.pre.stage2
installed_cli_required: igc compile
profile_source_smoke: deferred
repo_summary_json_authorized: yes
repo_write_scope: experiments/compiler_release_package_install_smoke_v0/** plus docs track
temp_root: /private/tmp/igniter_lang_package_install_smoke_<run_id>
installed_gem_package_readiness: not_established_until_smoke_PASS_and_acceptance
public_claims_authorized: no
version_change_authorized: no
git_tag_authorized: no
publish_authorized: no
spark_status: excluded_non_authorizing
ruby_ledger_hardening: independent_non_blocking
no_code_edited_by_status_curator: yes
```
