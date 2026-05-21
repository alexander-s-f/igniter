# Ruby Release Execution Blocker Closure Plan v0

Status: prepared
Date: 2026-05-20
Card: RUBY-REL-P3
Route: UPDATE
Track: ruby-release-execution-blocker-closure-plan-v0
Guidance: PG-2026-05-20-01

## Purpose

Prepare a blocker closure plan for Ruby Framework release execution without
releasing, tagging, publishing, changing versions, or widening Ruby API.

This plan follows the RUBY-REL-P2 release-readiness review, which passed
technical gates but held release execution.

## Current Release State

Current package version:

```text
0.5.1
```

Existing local tag:

```text
v0.5.1
```

Tag status:

```text
HEAD: 926994944fda978f05c72ab63d19079dde1508b1
v0.5.1 tag object: e3e14c534c43b6a05c0e67383b42557209dfbe7a
v0.5.1 tagged commit: bd7244d3
```

Interpretation:

- `v0.5.1` already exists locally.
- `v0.5.1` does not point at current HEAD.
- Current HEAD includes release-readiness and observed-service documentation
  work after the existing `v0.5.1` tag.

Current working tree blocker:

```text
?? examples/rails_contracts_ledger/log/
```

Cause:

```text
examples/rails_contracts_ledger/log/.keep
```

The app `.gitignore` ignores log files but explicitly unignores `log/.keep`.

## Version / Tag Route Options

### Option A: Bump Version For New Release

Route:

```text
0.5.1 -> 0.5.2
tag v0.5.2 after final gates
publish 0.5.2 only after explicit release authorization
```

Pros:

- avoids retagging an existing release tag;
- cleanly represents new docs/review work after the old `v0.5.1` tag;
- safest Rubygems route if `0.5.1` already exists remotely;
- preserves audit trail.

Cons:

- requires a version bump commit;
- requires rebuilding and rerunning release gates after the bump.

Recommendation:

```text
recommended
```

### Option B: Treat Existing v0.5.1 As The Release

Route:

```text
no new tag
no new publish
record that v0.5.1 already exists
hold current docs/review work for a later version
```

Pros:

- no tag conflict;
- no publish risk;
- simplest if `v0.5.1` was already released intentionally.

Cons:

- current observed-service docs/release-readiness work is not included in that
  tag;
- no new package release happens from current HEAD.

Recommendation:

```text
acceptable if Portfolio wants no release now
```

### Option C: Retag or Reuse v0.5.1 For Current HEAD

Route:

```text
move/recreate v0.5.1 or publish 0.5.1 from current HEAD
```

Pros:

- keeps version number unchanged.

Cons:

- breaks tag immutability expectations;
- risky if `v0.5.1` exists remotely or on Rubygems;
- obscures audit history.

Recommendation:

```text
not recommended
```

Do not retag implicitly.

## Recommended Release Route

```text
bump to 0.5.2, rerun final gates, tag v0.5.2, then publish only after explicit
release authorization
```

This route is recommended because current HEAD is ahead of existing `v0.5.1`.

Release execution remains a separate route. This plan does not authorize the
version bump, tag, or publish.

## Rails Proof log/.keep Cleanup Options

### Option A: Track log/.keep

Route:

```text
git add examples/rails_contracts_ledger/log/.keep
```

Pros:

- matches the app `.gitignore` intent: ignore logs, keep directory placeholder;
- minimal change;
- makes working tree clean without changing ignore policy.

Cons:

- tracks a placeholder file in the example app.

Recommendation:

```text
recommended
```

### Option B: Ignore log/.keep

Route:

```text
remove or adjust the `!/log/.keep` exception in examples/rails_contracts_ledger/.gitignore
delete examples/rails_contracts_ledger/log/.keep
```

Pros:

- no placeholder tracked.

Cons:

- changes generated Rails app ignore convention;
- less useful if the example should keep an empty `log/` directory visible.

Recommendation:

```text
acceptable if the project prefers no placeholder files
```

### Option C: Remove log/.keep Only

Route:

```text
delete examples/rails_contracts_ledger/log/.keep
leave .gitignore unchanged
```

Pros:

- quick cleanup.

Cons:

- future Rails/test runs may recreate or leave the same untracked directory
  ambiguity;
- `.gitignore` still advertises `.keep` as a tracked placeholder.

Recommendation:

```text
not preferred
```

## Intentional Changes To Commit

Before release execution, the release branch should contain one intentional
commit set that includes the work already present in current HEAD plus any
blocker-closure changes chosen next.

Current git status shows only:

```text
?? examples/rails_contracts_ledger/log/
```

Release execution should still verify that the intended release commit includes:

- Rails proof app and its `.gitignore`;
- observed-service recipe and reports;
- `igniter-embed` observed-service docs sync;
- release-readiness review/prep reports;
- release blocker closure plan if retained as part of lane history;
- chosen cleanup for `examples/rails_contracts_ledger/log/.keep`;
- optional version bump commit if Option A is selected.

If Option A is selected, exact version bump files must be confirmed in the
release execution route. Expected minimum:

- `lib/igniter/version.rb`

Because all package gemspecs read `Igniter::VERSION`, a single version bump
should update the reviewed package versions.

## Ignored Gem Artifact Policy

Current `.gem` artifacts are ignored and untracked.

Recommended policy:

```text
remove stale ignored gem artifacts before final release build, then let the
release execution route rebuild fresh artifacts for publish
```

Rationale:

- avoids publishing stale artifacts from a prior review build;
- makes final build provenance clearer;
- keeps ignored local files from confusing release operators.

Do not remove artifacts as part of this plan unless separately authorized.

## Native Extension Release Note

Preserve this note in release execution:

```text
igniter-ledger clean install currently needs crates.io/network access unless
Rust dependencies are vendored or prebuilt native artifacts are introduced.
```

Evidence from RUBY-REL-P2:

- no-network clean install failed on crates.io DNS for `blake3`;
- network-enabled clean installed-gem Rails proof smoke passed.

## Exact User / Portfolio Decisions Needed

1. Release intent:

   ```text
   proceed with release execution / hold release
   ```

2. Version/tag route:

   ```text
   recommended: bump to 0.5.2 and tag v0.5.2
   alternatives: no release using existing v0.5.1 / explicitly authorize a
   non-recommended v0.5.1 retag route
   ```

3. `log/.keep` cleanup:

   ```text
   recommended: track examples/rails_contracts_ledger/log/.keep
   alternative: change ignore policy and remove .keep
   ```

4. Gem artifact cleanup:

   ```text
   recommended: remove stale ignored .gem artifacts before final release build
   ```

5. Native extension release note:

   ```text
   include the crates.io/network dependency note in release notes
   ```

6. Publish authorization:

   ```text
   only after final gates pass, tag strategy is resolved, Rubygems credentials
   are checked, and user/Portfolio explicitly authorizes publish
   ```

## Final Recommendation

```text
prepare 0.5.2 release execution route
```

Use the following closure sequence:

1. Track `examples/rails_contracts_ledger/log/.keep`.
2. Bump `lib/igniter/version.rb` from `0.5.1` to `0.5.2`.
3. Remove stale ignored `.gem` artifacts.
4. Rerun release gates from RUBY-REL-P2.
5. Build fresh gems.
6. Run clean installed-gem smoke.
7. Commit release execution changes.
8. Tag `v0.5.2`.
9. Publish only after explicit authorization.

Steps 2, 7, 8, and 9 require separate authorization and are not performed by
this plan.
