# Ruby 0.5.2 Release Execution Preflight v0

Status: prepared for user authorization
Date: 2026-05-21
Card: RUBY-REL-P4
Route: UPDATE
Track: ruby-0-5-2-release-execution-preflight-v0
Guidance: PG-2026-05-20-01

## Purpose

Prepare the exact `0.5.2` release execution preflight for user authorization
without performing release actions.

This preflight does not:

- bump version;
- tag;
- publish;
- remove files;
- widen Ruby API;
- claim Spark production readiness.

## Current State

Known release state:

```text
current version: 0.5.1
existing local tag: v0.5.1
proposed release version: 0.5.2
proposed new tag: v0.5.2
```

Current git status signal:

```text
?? examples/rails_contracts_ledger/log/
```

Known cause:

```text
examples/rails_contracts_ledger/log/.keep
```

`v0.5.2` was not present in the tag check run for this preflight.

## Preflight Checklist

Pre-authorization checks:

- [ ] User/Portfolio confirms release intent.
- [ ] User/Portfolio confirms `0.5.2` route.
- [ ] User/Portfolio authorizes tracking
  `examples/rails_contracts_ledger/log/.keep`.
- [ ] User/Portfolio authorizes removing stale ignored `.gem` artifacts before
  final build.
- [ ] User/Portfolio accepts the `igniter-ledger` native extension network
  dependency release note.
- [ ] User/Portfolio confirms publish will require a second explicit
  authorization after final gates pass.

Release execution steps after authorization:

- [ ] Track `examples/rails_contracts_ledger/log/.keep`.
- [ ] Bump `lib/igniter/version.rb` to `0.5.2`.
- [ ] Remove stale ignored `.gem` artifacts.
- [ ] Rerun root gate.
- [ ] Rerun Ledger package specs.
- [ ] Rerun Rails proof path-gem test.
- [ ] Rebuild all release gems.
- [ ] Run clean installed-gem smoke with network available for
  `igniter-ledger` native extension dependencies.
- [ ] Confirm docs boundaries:
  - no Spark production-readiness claim;
  - `availability_slot_map_summary` remains aggregate output vocabulary only;
  - Embed receipt kinds remain `:contractable_observation` and
    `:contractable_event`;
  - Ledger remains optional and not source of truth.
- [ ] Commit release execution changes.
- [ ] Tag `v0.5.2`.
- [ ] Publish only after explicit user authorization.

## Exact Proposed Commands / Actions

### 1. Track Rails Proof log Placeholder

Action:

```bash
git add examples/rails_contracts_ledger/log/.keep
```

Reason:

- the Rails proof app `.gitignore` explicitly unignores `log/.keep`;
- tracking it resolves the current untracked log directory without changing
  ignore policy.

### 2. Bump Version

Action:

```text
Edit lib/igniter/version.rb:
VERSION = "0.5.2"
```

Implementation method:

```text
Use apply_patch to change only the version string.
```

Reason:

- all reviewed package gemspecs read `Igniter::VERSION`;
- one version bump updates the release package set.

### 3. Remove Stale Ignored Gem Artifacts

Action, from repo root:

```bash
rm -f igniter-0.5.1.gem
rm -f packages/igniter-contracts/igniter-contracts-0.5.1.gem
rm -f packages/igniter-embed/igniter-embed-0.5.1.gem
rm -f packages/igniter-extensions/igniter-extensions-0.5.1.gem
rm -f packages/igniter-ledger-client/igniter-ledger-client-0.5.1.gem
rm -f packages/igniter-ledger/igniter-ledger-0.5.1.gem
rm -f pkg/igniter-0.5.1.gem
```

Reason:

- these artifacts are ignored and untracked;
- removing stale artifacts before final build avoids publishing a review-build
  artifact by mistake.

### 4. Rerun Release Gates

Root gate:

```bash
bundle exec rake
```

Ledger package specs:

```bash
BUNDLE_GEMFILE=packages/igniter-ledger/Gemfile bundle exec rspec packages/igniter-ledger/spec
```

Rails proof path-gem test:

```bash
cd examples/rails_contracts_ledger
bin/rails test
```

Expected gates:

```text
root specs and RuboCop pass
Ledger package specs pass
Rails proof test passes
```

### 5. Rebuild Gems

From repo root:

```bash
gem build igniter.gemspec
```

From package directories:

```bash
cd packages/igniter-contracts
gem build igniter-contracts.gemspec

cd ../igniter-extensions
gem build igniter-extensions.gemspec

cd ../igniter-embed
gem build igniter-embed.gemspec

cd ../igniter-ledger-client
gem build igniter-ledger-client.gemspec

cd ../igniter-ledger
gem build igniter-ledger.gemspec
```

Expected artifacts:

```text
igniter-0.5.2.gem
packages/igniter-contracts/igniter-contracts-0.5.2.gem
packages/igniter-extensions/igniter-extensions-0.5.2.gem
packages/igniter-embed/igniter-embed-0.5.2.gem
packages/igniter-ledger-client/igniter-ledger-client-0.5.2.gem
packages/igniter-ledger/igniter-ledger-0.5.2.gem
```

### 6. Clean Installed-Gem Smoke

Run from repo root with network available for the `igniter-ledger` native
extension dependency graph:

```bash
tmp_app="/private/tmp/igniter_rails_gem_smoke_0_5_2_$(date +%s)"
tmp_gem_home="/private/tmp/igniter_gem_home_0_5_2_$(date +%s)"
mkdir -p "$tmp_app" "$tmp_gem_home"
cp -R examples/rails_contracts_ledger/. "$tmp_app"
ruby -e 'path = ARGV.fetch(0); text = File.read(path); text = text.gsub(/gem "igniter-contracts".*$/, "gem \"igniter-contracts\", \"0.5.2\""); text = text.gsub(/gem "igniter-embed".*$/, "gem \"igniter-embed\", \"0.5.2\""); text = text.gsub(/gem "igniter-extensions".*$/, "gem \"igniter-extensions\", \"0.5.2\""); text = text.gsub(/gem "igniter-ledger".*$/, "gem \"igniter-ledger\", \"0.5.2\""); text = text.gsub(/gem "igniter-ledger-client".*$/, "gem \"igniter-ledger-client\", \"0.5.2\""); File.write(path, text)' "$tmp_app/Gemfile"
GEM_HOME="$tmp_gem_home" GEM_PATH="$tmp_gem_home:$GEM_PATH" gem install --local ./packages/igniter-contracts/igniter-contracts-0.5.2.gem ./packages/igniter-extensions/igniter-extensions-0.5.2.gem ./packages/igniter-embed/igniter-embed-0.5.2.gem ./packages/igniter-ledger-client/igniter-ledger-client-0.5.2.gem --no-document
GEM_HOME="$tmp_gem_home" GEM_PATH="$tmp_gem_home:$GEM_PATH" gem install ./packages/igniter-ledger/igniter-ledger-0.5.2.gem --no-document
cd "$tmp_app"
GEM_HOME="$tmp_gem_home" GEM_PATH="$tmp_gem_home:$GEM_PATH" bundle install --local
GEM_HOME="$tmp_gem_home" GEM_PATH="$tmp_gem_home:$GEM_PATH" bin/rails test
```

Expected result:

```text
1 runs, 24 assertions, 0 failures, 0 errors, 0 skips
```

### 7. Confirm Boundaries

Commands:

```bash
rg -n "production[- ]ready|production readiness|Spark production|release-ready|source of truth|availability_slot_map_summary|contractable_observation|contractable_event" packages/igniter-embed/README.md packages/igniter-ledger/README.md packages/igniter-ledger-client/README.md packages/igniter-contracts/README.md
git status --short
git tag -l 'v0.5.2'
git ls-files '*.gem'
```

Expected:

- no Spark production-readiness claim;
- `availability_slot_map_summary` appears only as aggregate output vocabulary;
- Embed receipt kinds remain explicit and separate;
- no tracked `.gem` artifacts;
- `v0.5.2` absent before tagging.

### 8. Commit

Recommended commit command:

```bash
git add lib/igniter/version.rb examples/rails_contracts_ledger/log/.keep
git add .agents/ruby-framework/current-status.md
git add .agents/ruby-framework/tracks/ruby-0-5-2-release-execution-preflight-v0.md
git add .agents/ruby-framework/reports/ruby-rel-p4-0-5-2-release-execution-preflight.md
git commit -m "chore(release): prepare 0.5.2"
```

If release execution creates an additional report, include that report in the
same or a follow-up commit according to Portfolio guidance.

### 9. Tag

Only after gates pass and commit is complete:

```bash
git tag -a v0.5.2 -m "Version 0.5.2"
```

Do not run this until explicitly authorized.

### 10. Publish

Publish order after explicit user authorization:

```bash
gem push packages/igniter-contracts/igniter-contracts-0.5.2.gem
gem push packages/igniter-extensions/igniter-extensions-0.5.2.gem
gem push packages/igniter-embed/igniter-embed-0.5.2.gem
gem push packages/igniter-ledger-client/igniter-ledger-client-0.5.2.gem
gem push packages/igniter-ledger/igniter-ledger-0.5.2.gem
gem push igniter-0.5.2.gem
```

Do not run these until:

- user explicitly authorizes publish;
- Rubygems credentials/MFA/ownership are confirmed;
- final clean installed-gem smoke passes;
- `v0.5.2` tag is created intentionally.

## Native Extension Network Note

Preserve this release note:

```text
igniter-ledger clean install currently needs crates.io/network access unless
Rust dependencies are vendored or prebuilt native artifacts are introduced.
```

Reason:

- RUBY-REL-P2 no-network clean install failed while resolving crates.io for
  `blake3`;
- network-enabled clean installed-gem smoke passed.

## Explicit User Decisions Needed

1. Authorize or reject `0.5.2` release execution preflight.
2. Confirm version bump to `0.5.2`.
3. Confirm tracking `examples/rails_contracts_ledger/log/.keep`.
4. Confirm stale ignored `.gem` artifact removal before final build.
5. Confirm network-enabled clean installed-gem smoke is allowed for
   `igniter-ledger`.
6. Confirm whether publish should remain a second separate authorization after
   gates pass.
7. Confirm whether to push git tag/commit to remote as part of release
   execution, or keep push separate.

## Recommendation

```text
authorize preflight execution through commit and tag preparation, keep publish
as a second explicit authorization
```

Recommended execution boundary:

- perform cleanup, version bump, gates, builds, smoke, commit, and tag only
  after authorization;
- do not publish until the user explicitly says to publish after reviewing the
  final release execution report.
