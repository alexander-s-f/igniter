# Compiler Release Package/Install Smoke Authorization Review v0

Card: S3-R172-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-package-install-smoke-authorization-review-v0
Route: UPDATE
Status: done
Date: 2026-05-24

Depends on:
- S3-R172-C1-P1
- S3-R172-C2-P1
- S3-R172-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-boundary-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-criteria-v0.md`
- `igniter-lang/docs/discussions/compiler-release-package-install-smoke-authorization-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-v0.md`
- `igniter-lang/docs/tracks/compiler-release-evidence-hash-docs-and-package-smoke-policy-v0.md`

---

## Decision

Decision:

```text
authorize bounded local package/install smoke execution next
do not authorize public release/demo claims
do not authorize version change, tag, push, publish, signing, or deployment
do not establish installed-gem/package readiness until smoke PASS is accepted later
```

The next card may run a local package/install smoke for the current
`igniter_lang` package version:

```text
0.1.0.pre.stage2
```

This authorization is for local smoke evidence only. It is not a RubyGems
release, public availability claim, production readiness claim, or installed-gem
readiness acceptance.

---

## Authorized Smoke Target

Authorized target:

```text
local_package_install_smoke_current_version
```

Target meaning:

- build the current `igniter_lang` gem locally from
  `igniter-lang/igniter_lang.gemspec`;
- install that exact local gem into an isolated temporary gem home;
- verify `require "igniter_lang"` without repo-relative `-I`;
- verify installed `igc compile` on the accepted positive corpus;
- verify installed `igc compile` refusal on the accepted negative corpus;
- write a machine-readable smoke summary and a track doc;
- keep all generated build/install artifacts local, temporary, and non-public.

Not authorized:

- version file edits;
- gemspec edits;
- git tag creation;
- git push;
- RubyGems publish;
- public release/demo/readme claims;
- signing;
- deployment;
- package metadata rewrite;
- compiler/runtime behavior changes.

---

## Execution Card Boundary

Authorized next card:

```text
Card: S3-R173-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: compiler-release-package-install-smoke-v0
Route: UPDATE
```

Allowed repo write scope:

```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/**
igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md
```

Allowed temp write scope:

```text
/private/tmp/igniter_lang_package_install_smoke_<run_id>/**
```

Required durable repo outputs:

```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/<run_id>/package_install_smoke_summary.json
igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md
```

Optional repo output if useful:

```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/package_install_smoke_v0.rb
```

The summary JSON under `experiments/.../out/<run_id>/` is explicitly authorized
as evidence. Temp build artifacts are not authorized as repo artifacts.

Do not edit:

- `igniter-lang/lib/igniter_lang/version.rb`;
- `igniter-lang/igniter_lang.gemspec`;
- compiler/parser/classifier/TypeChecker/SemanticIR/assembler/runtime code;
- public docs or release notes.

---

## Command Matrix

The execution card must run a bounded matrix equivalent to the following. It may
wrap these commands in a proof script, but the result packet must record the
exact command forms actually run.

Setup:

```text
SMOKE_ROOT=/private/tmp/igniter_lang_package_install_smoke_<run_id>
BUILD_DIR=$SMOKE_ROOT/build
GEM_HOME_DIR=$SMOKE_ROOT/gem_home
BIN_DIR=$SMOKE_ROOT/bin
CORPUS_DIR=$SMOKE_ROOT/corpus
OUT_DIR=$SMOKE_ROOT/out
GEM_PATH_LOCAL=$BUILD_DIR/igniter_lang-0.1.0.pre.stage2.gem
```

Required commands:

```text
PKG-0: ruby -c igniter-lang/igniter_lang.gemspec
PKG-1: gem build igniter-lang/igniter_lang.gemspec --output $GEM_PATH_LOCAL
PKG-2: gem install --local --force --no-document --install-dir $GEM_HOME_DIR --bindir $BIN_DIR $GEM_PATH_LOCAL
PKG-3: env GEM_HOME=$GEM_HOME_DIR GEM_PATH=$GEM_HOME_DIR ruby -e 'require "igniter_lang"; abort "repo path leak" if Gem.loaded_specs.fetch("igniter_lang").full_gem_path.include?("/Users/alex/dev/projects/igniter/igniter-lang"); puts "load OK #{IgniterLang::VERSION}"'
PKG-4: $BIN_DIR/igc compile <positive_source> --out $OUT_DIR/<positive_name>.igapp
PKG-5: $BIN_DIR/igc compile <negative_source> --out $OUT_DIR/<negative_name>_should_not_exist.igapp
```

PKG-4 must run for every required positive corpus source.
PKG-5 must run for every required negative corpus source.

Installed CLI command shape:

```text
igc compile SOURCE --out OUT.igapp
```

Forbidden installed CLI command shape:

```text
igniter-lang compile SOURCE
```

Using `igniter-lang compile` in the installed smoke matrix is a FAIL unless a
later package inspection proves `igniter-lang` is an installed executable.
Current package inspection proves only `igc`.

---

## Corpus

Required positive corpus:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/boolean_gate.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/integer_arithmetic.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/multi_input_diverse.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/poc_derived.ig
```

Required negative corpus:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/negative/parse_refusal.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/negative/type_mismatch.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/negative/unresolved_symbol.ig
```

Optional profile-source checks are deferred.

No `--compiler-profile-source` smoke extension is authorized in the baseline
execution card. If profile-source package smoke is desired, open a separate
extension authorization after the baseline smoke is accepted.

---

## PASS / HOLD / FAIL Criteria

Adopt the criteria from
`compiler-release-package-install-smoke-criteria-v0.md` with these binding
rules:

PASS:

- PKG-0 succeeds;
- PKG-1 through PKG-5 are all PASS;
- all 5 positive corpus files compile via installed `$BIN_DIR/igc`;
- all 3 negative corpus files refuse via installed `$BIN_DIR/igc`;
- `failed_checks` is empty;
- `hold_reasons` is empty;
- required non-claims are present in the summary JSON;
- no repo-relative `-I` or repo `RUBYLIB` is used for installed checks.

HOLD:

- any PKG row is HOLD;
- isolation cannot be proven;
- installed executable shape is ambiguous;
- artifact inspection is inconclusive;
- temp cleanup/retention cannot be proven.

FAIL:

- any PKG row is FAIL;
- any smoke command uses `igniter-lang compile`;
- any public/release/version/tag/publish/sign/deploy action occurs;
- positive corpus fails to compile;
- negative corpus exits successfully or writes `.igapp`;
- result packet omits required non-claims.

FAIL takes precedence over HOLD.

---

## Required Result Packet Shape

The execution card must write one JSON summary:

```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/<run_id>/package_install_smoke_summary.json
```

Required top-level fields:

```text
kind: compiler_release_package_install_smoke_summary
format_version: 0.1.0
card: S3-R173-C1-I
track: compiler-release-package-install-smoke-v0
status: PASS|HOLD|FAIL
authorized_by: S3-R172-C4-A
release_scope.scope: bounded_local_package_install_smoke
release_scope.source_marker: repo_local_compiler_rc_marker
release_scope.source_evidence_scope: repo_local_compiler_rc
release_scope.public_claims_authorized: false
release_scope.rubygems_publish_authorized: false
release_scope.production_runtime_authorized: false
package.gem_name: igniter_lang
package.version: 0.1.0.pre.stage2
package.executable_expected: igc
package.executable_observed: igc
environment.repo_relative_i_used: false
criteria.PKG-1..PKG-5
command_matrix
positive_corpus
refusal_corpus
failed_checks
hold_reasons
non_claims
artifact_policy
```

The `card` field must be `S3-R173-C1-I`. Do not leave any `C?-I` placeholder.

Required non-claims:

- no public release claim;
- no public demo claim;
- no RubyGems publish;
- no public availability claim;
- no version change;
- no git tag;
- no push;
- no signing;
- no deploy;
- no release execution beyond smoke;
- no production runtime;
- no Spark integration;
- no Ruby Framework compatibility claim;
- no branch/conditional claim;
- no runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache claim.

---

## Temp Artifact Policy

All build/install outputs must live under:

```text
/private/tmp/igniter_lang_package_install_smoke_<run_id>/
```

Retain in repo:

- summary JSON under `experiments/compiler_release_package_install_smoke_v0/out/<run_id>/`;
- optional proof script under `experiments/compiler_release_package_install_smoke_v0/`;
- track doc.

Do not retain in repo:

- built `.gem`;
- isolated `GEM_HOME`;
- isolated bindir;
- copied corpus;
- positive `.igapp` outputs, unless the summary records paths and the files are
  kept under `/private/tmp` only;
- refusal output paths.

Cleanup:

- clean isolated `GEM_HOME`, bindir, copied corpus, and build outputs after the
  summary/log evidence is written, unless HOLD requires temporary inspection;
- if temp artifacts are retained for HOLD inspection, the track doc must record
  the exact temp path and reason.

---

## Explicit Answers

May package/install smoke execution open next?

```text
Yes. A bounded local package/install smoke execution card may open next.
```

Is installed-gem/package readiness established now?

```text
No. Installed-gem/package readiness remains not established until smoke PASS is
accepted by a later decision.
```

Do public release/demo claims remain closed?

```text
Yes. Public release/demo claims remain closed.
```

Do version/tag/push/publish/sign/deploy remain closed?

```text
Yes. All remain closed.
```

Is `igc compile` required?

```text
Yes. Installed CLI smoke must use `igc compile`.
```

Does Spark remain out of scope?

```text
Yes. Spark remains excluded and non-authorizing.
```

---

## Next Dispatch Recommendation

Run the bounded smoke execution card next:

```text
Card: S3-R173-C1-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: compiler-release-package-install-smoke-v0
Route: UPDATE

Goal:
Run the bounded local package/install smoke for the current `igniter_lang`
package version, using isolated temp install and installed `igc compile`.

Scope:
- Read:
  - igniter-lang/docs/tracks/compiler-release-package-install-smoke-authorization-review-v0.md
  - igniter-lang/docs/tracks/compiler-release-package-install-smoke-boundary-v0.md
  - igniter-lang/docs/tracks/compiler-release-package-install-smoke-criteria-v0.md
  - igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-acceptance-decision-v0.md
- Write only:
  - igniter-lang/experiments/compiler_release_package_install_smoke_v0/**
  - igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md
- Run only:
  - the authorized package/install smoke command matrix.
- Do not:
  - edit version files;
  - edit gemspec;
  - create tags;
  - push;
  - publish gems;
  - sign or deploy;
  - run profile-source smoke checks;
  - make public release/demo claims;
  - edit compiler/parser/TypeChecker/SemanticIR/assembler/runtime code.

Deliver:
- smoke script and/or execution evidence under
  `igniter-lang/experiments/compiler_release_package_install_smoke_v0/`;
- summary JSON under
  `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/<run_id>/package_install_smoke_summary.json`;
- track doc in `igniter-lang/docs/tracks/`;
- compact PASS/HOLD/FAIL result.
```

---

## Closed Surfaces

This decision does not authorize:

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
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, deployment, or demo work.

---

## Compact Receipt

```text
card: S3-R172-C4-A
track: compiler-release-package-install-smoke-authorization-review-v0
status: done
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
```
