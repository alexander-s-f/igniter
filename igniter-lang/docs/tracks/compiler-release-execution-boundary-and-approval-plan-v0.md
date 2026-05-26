# Compiler Release Execution Boundary And Approval Plan v0

Card: S3-R184-C2-P1
Agent: [Package Agent / Release Target Analyst]
Role: package-agent
Track: compiler-release-execution-boundary-and-approval-plan-v0
Route: UPDATE
Status: done
Date: 2026-05-26

---

## Purpose

Define the exact release execution boundary, approval wording,
credential/2FA handling, abort criteria, and post-publish verification plan for:

```text
igniter_lang 0.1.0.alpha.1
```

This card does not execute a release, publish a gem, create or push tags, sign
or deploy, or make public release/demo claims.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round183-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-target-collision-and-git-state-preflight-v0.md`
- `igniter-lang/README.md`
- `igniter-lang/RELEASE_NOTES.md`
- `igniter-lang/igniter_lang.gemspec`

---

## Exact Release Target

| Field | Value |
| --- | --- |
| release target | `public_rubygems_alpha_prerelease_for_igniter_lang` |
| gem name | `igniter_lang` |
| version | `0.1.0.alpha.1` |
| executable | `igc` |
| expected tag | `igniter-lang-v0.1.0.alpha.1` |
| accepted smoke run | `S3R183C2I_20260526T143139Z` |
| accepted smoke artifact SHA256 | `sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6` |

Allowed release meaning after successful publish and verification:

```text
igniter_lang 0.1.0.alpha.1 is available on RubyGems as an alpha prerelease
compiler package with bounded CLI/API scope.
```

Still not allowed:

```text
stable release
production readiness
public demo readiness
all grammar support
branch/conditional if_expr support
profile finalization/discovery/defaulting
Spark integration
runtime/Ledger/TBackend/BiHistory readiness
```

---

## Rebuild vs Publish Existing Artifact

Stance:

```text
rebuild in the future execution card; do not publish the R183 temp smoke artifact
```

Reasons:

- R183 accepted the smoke artifact and SHA256, but temp cleanup was complete.
- The release execution card needs a durable release artifact path and command
  transcript.
- The rebuilt release artifact must be proven to match the accepted R183
  artifact SHA256 before `gem push`.

Hard rule:

```text
If the rebuilt artifact SHA256 differs from
sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6,
abort before tag push or gem push.
```

If a mismatch occurs, route to a new smoke/evidence review. Do not publish a
new hash under this approval.

---

## Tag Stance

Exact tag:

```text
igniter-lang-v0.1.0.alpha.1
```

Annotation message, exact candidate:

```text
igniter-lang 0.1.0.alpha.1 alpha prerelease

Evidence:
- R183 combined post-prep smoke PASS
- run: S3R183C2I_20260526T143139Z
- artifact_sha256: sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6

Scope:
- alpha prerelease compiler package
- installed executable: igc
- branch/conditional if_expr excluded
- profile finalization/discovery/defaulting excluded
- not stable, not production-ready, not public demo-ready
```

Recommended order:

1. Re-run collision checks.
2. Rebuild artifact.
3. Verify artifact SHA256 matches accepted R183 SHA256.
4. Create local annotated tag.
5. Publish gem.
6. Verify RubyGems availability and isolated install.
7. Push only the exact tag.

If C4-A wants to avoid any local tag before `gem push`, it may move local tag
creation to after post-publish verification. In either ordering, never push a
tag before the gem publish is verified.

---

## Required User Approval Wording

Before any future execution card runs release commands, the user must provide
approval equivalent to this exact text:

```text
I approve the bounded release execution for igniter_lang 0.1.0.alpha.1.
I approve rebuilding the gem, requiring the rebuilt SHA256 to match
sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6,
creating the annotated tag igniter-lang-v0.1.0.alpha.1, publishing the matching
gem to RubyGems with gem push, completing RubyGems MFA/2FA as the human owner
if prompted, running post-publish verification, and pushing only the exact tag
igniter-lang-v0.1.0.alpha.1 after publish verification.

I understand RubyGems publish for a version is public and not practically
reversible. I understand this does not authorize production, stable, public demo,
all-grammar, branch/conditional if_expr, profile discovery/defaulting/finalization,
Spark, runtime, signing, or deployment claims.
```

Partial approval is not enough for publish. If the user approves only preflight
or rebuild, the execution card must stop before `git tag`, `gem push`, and
`git push`.

---

## Credential And 2FA Boundary

RubyGems credential handling:

- Do not ask the user to paste RubyGems credentials, API keys, OTP seeds, or
  recovery codes into chat or docs.
- Do not write credentials into repo files, temp summaries, logs, shell history,
  or command transcripts.
- The human RubyGems owner must complete any MFA/2FA prompt interactively.
- If MFA/2FA cannot be completed, abort before treating publish as attempted.
- If `gem push` fails due to authentication, authorization, ownership, MFA, or
  network failure, record the failure and stop.
- Do not retry publish repeatedly without fresh user confirmation.

The execution card may run `gem push` only after explicit approval and only for
the verified artifact path.

---

## Allowed Future Execution Commands

These commands are candidates for a future C4-A-authorized execution card only.
They are not authorized by this plan card.

Preflight:

```bash
git status --short
git status --short -- igniter-lang/igniter_lang.gemspec igniter-lang/lib/igniter_lang/version.rb igniter-lang/README.md igniter-lang/RELEASE_NOTES.md
git tag --list 'igniter-lang-v0.1.0.alpha.1'
git ls-remote --tags origin 'igniter-lang-v0.1.0.alpha.1'
gem list --remote --all --exact igniter_lang
```

Build and hash:

```bash
mkdir -p /private/tmp/igniter_lang_release_0_1_0_alpha_1
gem build igniter-lang/igniter_lang.gemspec --output /private/tmp/igniter_lang_release_0_1_0_alpha_1/igniter_lang-0.1.0.alpha.1.gem
ruby -rdigest -e 'path = "/private/tmp/igniter_lang_release_0_1_0_alpha_1/igniter_lang-0.1.0.alpha.1.gem"; expected = "sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6"; actual = "sha256:" + Digest::SHA256.file(path).hexdigest; abort "release artifact SHA mismatch: #{actual}" unless actual == expected; puts actual'
```

Tag, publish, and push:

```bash
git tag -a igniter-lang-v0.1.0.alpha.1 -m "<annotation from this plan>"
gem push /private/tmp/igniter_lang_release_0_1_0_alpha_1/igniter_lang-0.1.0.alpha.1.gem
git push origin refs/tags/igniter-lang-v0.1.0.alpha.1
```

Post-publish verification:

```bash
gem list --remote --all --exact igniter_lang
gem install igniter_lang -v 0.1.0.alpha.1 --no-document --install-dir /private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/gem_home --bindir /private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/bin
env GEM_HOME=/private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/gem_home GEM_PATH=/private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/gem_home ruby -e 'require "igniter_lang"; abort IgniterLang::VERSION unless IgniterLang::VERSION == "0.1.0.alpha.1"; puts "load OK #{IgniterLang::VERSION}"'
test -x /private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/bin/igc
```

Optional post-publish CLI smoke:

```bash
env GEM_HOME=/private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/gem_home GEM_PATH=/private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/gem_home PATH=/private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/bin:$PATH /private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/bin/igc compile igniter-lang/experiments/compiler_release_acceptance_harness_v0/corpus/positive/add_baseline.ig --out /private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/add_baseline.igapp
```

---

## Forbidden Commands

Forbidden unless a later card explicitly authorizes them:

```text
gem push any gem other than igniter_lang-0.1.0.alpha.1.gem
gem yank
git push --tags
git push --force
git tag -d igniter-lang-v0.1.0.alpha.1
git push origin :refs/tags/igniter-lang-v0.1.0.alpha.1
rake release
version file edits
gemspec edits
README or RELEASE_NOTES edits
signing commands
deployment commands
production runtime commands
```

Also forbidden:

- publishing from a dirty relevant release-file state;
- publishing if exact local or remote tag already exists;
- publishing if RubyGems already lists `igniter_lang 0.1.0.alpha.1`;
- broad tag push via `git push --tags`;
- public wording that claims stable, production, demo, all-grammar, Spark,
  runtime, or branch/conditional support.

---

## Abort Criteria

Abort before `gem push` if any of the following occurs:

- explicit user approval is missing or narrower than required;
- relevant release files are dirty;
- full worktree status reveals release-relevant ambiguity that C4-A did not
  authorize;
- `IgniterLang::VERSION` is not `0.1.0.alpha.1`;
- gemspec does not name `igniter_lang`;
- gemspec does not include `README.md` and `RELEASE_NOTES.md`;
- local tag already exists;
- remote tag already exists;
- RubyGems already lists `igniter_lang 0.1.0.alpha.1`;
- gem build fails;
- rebuilt artifact SHA256 differs from the accepted R183 SHA256;
- local annotated tag creation fails;
- RubyGems credentials, ownership, or MFA are unavailable;
- network access is unavailable for required collision checks;
- any command attempts to publish, tag, or push a different version.

Abort after `gem push` but before tag push if:

- RubyGems publish returns success but remote listing does not show
  `0.1.0.alpha.1`;
- isolated install from RubyGems fails;
- installed `require "igniter_lang"` does not report `0.1.0.alpha.1`;
- installed `igc` is absent or not executable.

If gem push succeeds and later verification fails, do not retry blindly and do
not yank automatically. Open a failure/yank authorization review.

---

## Public Wording After Publish

Allowed only after publish and post-publish verification:

```text
igniter_lang 0.1.0.alpha.1 is available on RubyGems as an alpha prerelease
compiler package. It provides the installed igc CLI for bounded contract
compilation and the accepted --compiler-profile-source PATH.json transport.
```

Must remain attached:

```text
not stable
not production-ready
not public demo-ready
not all grammar support
branch/conditional if_expr excluded
profile finalization/discovery/defaulting closed
Spark out of scope
runtime/Ledger/TBackend/BiHistory not claimed
```

If C4-A wants README/RELEASE_NOTES to stop saying "not yet published", it should
authorize a narrow post-publish docs/status update after verification. That docs
update must not happen before publish verification.

---

## Rollback / Failure Note Policy

RubyGems publish is public and not practically reversible for the version.

Failure handling:

- If failure happens before `gem push`, record the failed step and leave public
  state unchanged.
- If local tag exists but is not pushed and publish fails, record that a local
  cleanup may be needed. Do not delete it unless the execution card authorized
  local cleanup.
- If `gem push` succeeds but tag push fails, do not rerun publish. Record gem
  publication success and route exact tag-push remediation.
- If `gem push` succeeds but package verification fails, do not yank
  automatically. Open a bounded incident/yank authorization review.
- If a remote tag is pushed but later evidence is disputed, do not delete remote
  tags without explicit authorization.

Allowed failure note wording:

```text
Release execution attempted for igniter_lang 0.1.0.alpha.1. Step <ID> failed.
No production, stable, demo, all-grammar, Spark, branch/conditional, or runtime
readiness claim is made.
```

---

## Exact C4-A Approval Checklist

C4-A must explicitly answer yes/no for each item:

1. Authorize a future release execution card, not execution inside C4-A.
2. Target exactly `igniter_lang 0.1.0.alpha.1`.
3. Use expected tag `igniter-lang-v0.1.0.alpha.1`.
4. Rebuild the artifact in the execution card.
5. Require rebuilt SHA256 to match
   `sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6`.
6. Require exact user approval wording before irreversible commands.
7. Permit `gem push` only after collision checks and SHA match.
8. Permit pushing only `refs/tags/igniter-lang-v0.1.0.alpha.1`.
9. Forbid `git push --tags`.
10. Require post-publish RubyGems listing and isolated install verification.
11. Confirm credential/MFA handling is human-owner only.
12. Keep stable, production, demo, all-grammar, Spark, branch/conditional, and
    runtime claims closed.
13. Decide whether post-publish README/RELEASE_NOTES wording update is needed
    after verification.

---

## Future Execution-Card Boundary Proposal

Proposed next execution card:

```text
Card: S3-R184-C4-I
Agent: [Package Agent]
Role: package-agent
Track: compiler-release-execution-igniter-lang-0-1-0-alpha-1-v0
Route: UPDATE
Depends on:
- S3-R184-C3-X
- S3-R184-C4-A

Goal:
Execute the bounded RubyGems alpha prerelease for igniter_lang 0.1.0.alpha.1
only if C4-A authorizes it and the user gives exact approval.

Allowed:
- re-run target collision checks;
- rebuild the gem into /private/tmp;
- verify SHA256 matches accepted R183 SHA256;
- create annotated tag igniter-lang-v0.1.0.alpha.1;
- gem push the matching artifact;
- complete RubyGems MFA as human owner;
- verify RubyGems listing, isolated install, require version, and installed igc;
- push only refs/tags/igniter-lang-v0.1.0.alpha.1 after publish verification;
- write execution result track doc.

Forbidden:
- version/gemspec/docs edits;
- broad tag push;
- publish different artifact/version;
- gem yank;
- signing/deployment;
- production/stable/demo/all-grammar/Spark/runtime claims.
```

---

## Compact Release Execution Plan

```text
target: igniter_lang 0.1.0.alpha.1
tag: igniter-lang-v0.1.0.alpha.1
artifact_policy: rebuild, require SHA match with R183
accepted_sha256: sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
approval: exact user approval required before tag/publish/push
credentials: human RubyGems owner handles MFA/2FA; no secrets in chat/docs/logs
publish: gem push exact rebuilt artifact only
tag_push: push exact tag only, never git push --tags
post_publish: RubyGems listing, isolated install, require version, installed igc
public_wording_after_verify: alpha prerelease availability only
rollback: no automatic yank; route incident/yank authorization if needed
release_execution_in_this_card: no
```

---

## Closed Surfaces

This card does not authorize:

- release execution;
- gem build;
- RubyGems publish;
- git tag creation;
- git push;
- signing or deployment;
- version edits;
- gemspec edits;
- README or RELEASE_NOTES edits;
- public release/demo claims;
- production readiness claims;
- stable release claims;
- all grammar support claims;
- branch/conditional `if_expr`;
- profile finalization/discovery/defaulting;
- Spark integration;
- compiler/runtime behavior changes.
