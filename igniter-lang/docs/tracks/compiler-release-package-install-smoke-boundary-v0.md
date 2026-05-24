# Compiler Release Package Install Smoke Boundary v0

Card: S3-R172-C1-P1
Agent: [Package Smoke Boundary Analyst]
Role: release-readiness-agent
Track: compiler-release-package-install-smoke-boundary-v0
Route: UPDATE
Status: done
Date: 2026-05-24

Depends on:
- S3-R171-C3-A
- S3-R171-C1-I
- S3-R170-C4-A
- S3-R170-C2-P1
- S3-R170-C1-P1

---

## Purpose

Prepare the exact bounded local package/install smoke boundary after the
repo-local compiler RC marker was accepted.

This card does not run smoke, does not authorize implementation, does not edit
package metadata, does not change version files, and does not open public
release/demo claims.

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-v0.md`
- `igniter-lang/docs/tracks/compiler-release-execution-authorization-review-v0.md`
- `igniter-lang/docs/tracks/compiler-release-evidence-hash-docs-and-package-smoke-policy-v0.md`
- `igniter-lang/docs/tracks/compiler-release-target-versioning-and-execution-options-v0.md`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/lib/igniter_lang/version.rb`
- `igniter-lang/bin/release-gate`
- `igniter-lang/bin/igc`
- `igniter-lang/bin/igniter-lang`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json`
- `igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json`
- `rg "gem build|gem install|igc|release-gate|Gem::Specification|executables" igniter-lang`

---

## Current Facts

| Surface | Fact |
| --- | --- |
| Accepted marker | `repo_local_compiler_rc_marker` accepted by S3-R171-C3-A |
| Official evidence scope | `repo_local_compiler_rc` |
| Installed-gem readiness | not established |
| Package name | `igniter_lang` |
| Current version | `0.1.0.pre.stage2` |
| Version source | `igniter-lang/lib/igniter_lang/version.rb` |
| Gemspec executable list | `["igc"]` |
| Canonical installed executable | `igc` |
| Repo compatibility executable | `bin/igniter-lang`, not listed in gemspec executables |
| Public release/demo claims | closed |
| Version/tag/push/publish/sign/deploy | closed |
| Spark | excluded from this round |

The gemspec includes:

```ruby
spec.files = Dir.chdir(__dir__) do
  Dir["lib/**/*.rb", "bin/igc", "README.md"].select { |path| File.file?(path) }
end
spec.bindir = "bin"
spec.executables = ["igc"]
```

Therefore installed-gem smoke must use:

```text
igc compile SOURCE --out OUT.igapp
```

and must not use `igniter-lang compile` unless a later package inspection
changes the gemspec executable list.

---

## Exact Smoke Target

Recommended smoke target:

```text
local_package_install_smoke_current_version
```

Target meaning:

- build the current `igniter_lang` gem locally from `igniter-lang/igniter_lang.gemspec`;
- install that exact local gem into an isolated temporary gem home;
- verify `require "igniter_lang"` without repo-relative `-I`;
- verify installed `igc compile` on accepted positive corpus sources;
- verify installed `igc compile` refusal on accepted negative corpus sources;
- keep all outputs local/temp and non-public.

Out of target:

- RubyGems publish;
- public release/demo claim;
- version file edit;
- git tag or push;
- signing or deployment;
- package metadata rewrite;
- parser/compiler/runtime behavior change;
- branch/conditional `if_expr`;
- Spark.

---

## Package / Build Command Candidates

These are command candidates for a later C4-A-authorized execution card. They
are not run by this card.

Use a unique temp root:

```text
SMOKE_ROOT=/private/tmp/igniter_lang_package_install_smoke_${CARD}_${TIMESTAMP}
PKG_DIR=$SMOKE_ROOT/pkg
GEM_HOME_DIR=$SMOKE_ROOT/gem_home
BIN_DIR=$SMOKE_ROOT/bin
OUT_DIR=$SMOKE_ROOT/out
GEM_PATH_LOCAL=$PKG_DIR/igniter_lang-0.1.0.pre.stage2.gem
```

Candidate matrix:

| Step | Candidate command shape | Purpose |
| --- | --- | --- |
| PKG-0 syntax | `ruby -c igniter-lang/igniter_lang.gemspec` | Confirm gemspec syntax before build |
| PKG-1 build | `gem build igniter-lang/igniter_lang.gemspec --output $GEM_PATH_LOCAL` | Build local gem artifact in temp output |
| PKG-2 install | `gem install --local --force --no-document --install-dir $GEM_HOME_DIR --bindir $BIN_DIR $GEM_PATH_LOCAL` | Install into isolated gem home and bindir |
| PKG-3 require | `env GEM_HOME=$GEM_HOME_DIR GEM_PATH=$GEM_HOME_DIR ruby -e 'require "igniter_lang"; puts "load OK #{IgniterLang::VERSION}"'` | Verify installed require without repo-relative `-I` |
| PKG-4 executable exists | `test -x $BIN_DIR/igc` | Verify installed executable presence |
| PKG-5 positive compile | `env GEM_HOME=$GEM_HOME_DIR GEM_PATH=$GEM_HOME_DIR PATH=$BIN_DIR:$PATH $BIN_DIR/igc compile POSITIVE_SOURCE --out $OUT_DIR/POSITIVE.igapp` | Verify installed CLI positive compile |
| PKG-6 negative refusal | `env GEM_HOME=$GEM_HOME_DIR GEM_PATH=$GEM_HOME_DIR PATH=$BIN_DIR:$PATH $BIN_DIR/igc compile NEGATIVE_SOURCE --out $OUT_DIR/NEGATIVE_should_not_exist.igapp` | Verify installed CLI refusal |

Secondary command candidate:

```text
igniter-lang/bin/release-gate --out /private/tmp/igniter_lang_release_gate_r172
```

Use `release-gate` only if C4-A explicitly allows its repo-local summary write
to `igniter-lang/experiments/release_gate/release_gate.json`. For the narrowest
package/install smoke, prefer the direct temp-only `gem build` / `gem install`
matrix above.

---

## Isolated Install Strategy

The smoke should isolate install and executable lookup from the developer
environment:

- use `--install-dir $GEM_HOME_DIR`;
- use `--bindir $BIN_DIR`;
- set `GEM_HOME=$GEM_HOME_DIR`;
- set `GEM_PATH=$GEM_HOME_DIR`;
- call `$BIN_DIR/igc` directly;
- do not use `ruby -I igniter-lang/lib`;
- do not use Bundler load paths for the installed-gem checks;
- do not install into the user's default gem home;
- do not reuse `/private/tmp/igniter_lang_release_gate` from historical runs.

The source corpus may be read from the repo, but compiler code must be loaded
from the installed gem.

---

## Installed Executable Verification Strategy

`igc` is the canonical installed executable because `igniter_lang.gemspec`
declares:

```text
spec.executables = ["igc"]
```

Verification should include:

- `$BIN_DIR/igc` exists and is executable after install;
- `$BIN_DIR/igc compile ...` is used for every installed CLI check;
- no installed smoke command uses `igniter-lang compile`;
- no command uses repo-local `igniter-lang/bin/igc` for installed-gem proof;
- PKG-3 proves `require "igniter_lang"` from the isolated gem path.

---

## Corpus Source Selection Strategy

Use the accepted first-RC harness corpus as source fixtures. Do not introduce
new language fixtures in the smoke card.

Positive sources:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/boolean_gate.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/integer_arithmetic.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/multi_input_diverse.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/poc_derived.ig
```

Negative sources:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/negative/parse_refusal.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/negative/type_mismatch.ig
igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/negative/unresolved_symbol.ig
```

Recommended minimum for C4-A authorization:

```text
all 5 positive sources
all 3 negative sources
```

Optional but useful if C4-A wants profile-source coverage:

```text
$BIN_DIR/igc compile \
  igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig \
  --out $OUT_DIR/add_baseline_with_profile.igapp \
  --compiler-profile-source \
  igniter-lang/experiments/compiler_release_acceptance_harness_v0/fixtures/finalized_profile_source.json
```

Do not include malformed or missing profile-source cases in the baseline
package/install smoke unless C2-P1 criteria explicitly adds them. They are
profile-input refusal checks, not package/install boundary checks.

---

## Temp Artifact / Output Policy

All build, install, executable, and `.igapp` outputs should live under one
unique `/private/tmp` smoke root.

Allowed temp outputs:

- built `.gem`;
- isolated gem home;
- isolated bindir;
- positive `.igapp` outputs;
- negative refusal stdout/stderr captures;
- optional smoke result JSON under the same temp root.

Recommended future result packet path if an execution card is authorized:

```text
$SMOKE_ROOT/out/package_install_smoke_summary.json
```

Recommended durable record:

- execution card writes only a track doc with the result summary and temp path;
- do not commit temp artifacts;
- do not add generated `.gem`, `.sha256`, gem home, bindir, or `.igapp` outputs
  to the repo;
- do not overwrite historical `igniter-lang/experiments/release_gate/release_gate.json`
  unless C4-A explicitly authorizes `release-gate`.

Cleanup stance:

- keeping `/private/tmp` artifacts until review is acceptable;
- cleanup may be done by a later explicitly scoped cleanup command;
- absence of cleanup must not be framed as release artifact retention.

---

## No-Version / No-Tag / No-Publish Stance

The smoke should preserve the current version:

```text
0.1.0.pre.stage2
```

No package metadata or version change is required before the local smoke.
Testing the current package as-is is the point of this boundary.

Closed actions:

- no edit to `igniter-lang/lib/igniter_lang/version.rb`;
- no edit to `igniter-lang/igniter_lang.gemspec`;
- no git tag;
- no git push;
- no `gem push`;
- no signing;
- no deployment;
- no public release/demo docs.

If the smoke passes, installed-gem/package readiness is still not a public
release claim until a later acceptance decision says so.

---

## Explicit Answers

Is local package/install smoke appropriate next?

```text
Yes, as a bounded local smoke authorization target after the accepted
repo-local RC marker. Execution must wait for C4-A.
```

Does the current version remain unchanged during smoke?

```text
Yes. The smoke should keep IgniterLang::VERSION at 0.1.0.pre.stage2.
```

Is `igc` the canonical installed executable?

```text
Yes. The gemspec lists only `igc` in spec.executables.
```

Is any package metadata/version change required first?

```text
No. No metadata or version change is required before bounded local smoke.
```

Do release/public claims remain closed?

```text
Yes. Public release/demo claims, RubyGems availability claims, and production
readiness claims remain closed.
```

---

## Risks

| Risk | Boundary response |
| --- | --- |
| Installed smoke is misread as public release readiness | Keep non-claims in result packet and C4-A decision |
| Wrong executable is tested | Require installed `$BIN_DIR/igc compile`; forbid `igniter-lang compile` |
| Repo-local load path leaks into installed smoke | Forbid `ruby -I igniter-lang/lib`; use isolated `GEM_HOME` and `GEM_PATH` |
| Developer gem home contamination | Use `--install-dir`, `--bindir`, and unique `/private/tmp` root |
| `release-gate` writes repo-local summary | Prefer direct temp-only matrix unless C4-A authorizes release-gate |
| Corpus drift | Use accepted first-RC harness corpus only |
| Version/publish confusion | Preserve `0.1.0.pre.stage2`; no tag, push, publish, signing, deployment |
| Negative refusal produces an artifact | Treat as criteria failure in C2-P1/C4-A matrix |

---

## Recommended C4-A Stance

Recommended stance for S3-R172-C4-A, assuming C2-P1 criteria and C3-X pressure
review do not find blockers:

```text
authorize bounded local package/install smoke execution next
target: local_package_install_smoke_current_version
version: unchanged at 0.1.0.pre.stage2
installed_cli: igc compile
package_metadata_changes_required_first: no
temp_outputs: unique /private/tmp smoke root only
public_claims: closed
version_tag_push_publish_sign_deploy: closed
installed_gem_readiness: not established until smoke PASS and later acceptance
```

Do not authorize public release, RubyGems publish, tag, push, signing,
deployment, package metadata edits, version edits, or compiler implementation
changes in C4-A.

---

## Compact Smoke Boundary Packet

```text
card: S3-R172-C1-P1
track: compiler-release-package-install-smoke-boundary-v0
status: done

target:
  local_package_install_smoke_current_version

facts:
  package: igniter_lang
  version: 0.1.0.pre.stage2
  executable: igc
  installed_command: igc compile SOURCE --out OUT.igapp
  installed_gem_readiness: not_established
  public_claims: closed

command_candidates:
  - ruby -c igniter-lang/igniter_lang.gemspec
  - gem build igniter-lang/igniter_lang.gemspec --output $GEM_PATH_LOCAL
  - gem install --local --force --no-document --install-dir $GEM_HOME_DIR --bindir $BIN_DIR $GEM_PATH_LOCAL
  - env GEM_HOME=$GEM_HOME_DIR GEM_PATH=$GEM_HOME_DIR ruby -e 'require "igniter_lang"; puts "load OK #{IgniterLang::VERSION}"'
  - test -x $BIN_DIR/igc
  - env GEM_HOME=$GEM_HOME_DIR GEM_PATH=$GEM_HOME_DIR PATH=$BIN_DIR:$PATH $BIN_DIR/igc compile POSITIVE_SOURCE --out $OUT_DIR/POSITIVE.igapp
  - env GEM_HOME=$GEM_HOME_DIR GEM_PATH=$GEM_HOME_DIR PATH=$BIN_DIR:$PATH $BIN_DIR/igc compile NEGATIVE_SOURCE --out $OUT_DIR/NEGATIVE_should_not_exist.igapp

corpus:
  positive: all 5 accepted harness positive sources
  negative: all 3 accepted harness negative sources
  optional_profile_source: add_baseline.ig with finalized_profile_source.json

temp_policy:
  root: /private/tmp/igniter_lang_package_install_smoke_${CARD}_${TIMESTAMP}
  repo_generated_artifacts: none
  durable_record: future execution track doc only

stance:
  no_version_change: true
  no_tag: true
  no_push: true
  no_publish: true
  no_signing: true
  no_deployment: true
  no_public_release_demo_claim: true

recommendation:
  C4-A should authorize the bounded local smoke execution next if C2/C3 pass,
  while keeping installed-gem readiness and public release claims closed until
  smoke evidence is separately accepted.
```

---

## Closed Surfaces

This card does not authorize:

- package/install smoke execution;
- public release or demo claims;
- installed-gem/package readiness claim;
- version file edits;
- gemspec edits;
- git tag creation;
- git push;
- gem publish;
- signing;
- deployment;
- package metadata rewrites;
- public API/CLI widening;
- branch/conditional `if_expr`;
- parser, classifier, TypeChecker, SemanticIR, assembler, runtime, or compiler
  behavior changes;
- Spark access, fixtures, integration, or production pressure;
- Ruby Framework compatibility claim;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, production runtime, or demo
  work.
