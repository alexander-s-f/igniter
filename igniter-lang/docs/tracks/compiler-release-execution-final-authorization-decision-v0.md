# Compiler Release Execution Final Authorization Decision v0

Card: S3-R184-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-execution-final-authorization-decision-v0
Route: UPDATE
Status: done / authorized-next-execution-card
Date: 2026-05-26

Depends on:
- S3-R184-C1-P1
- S3-R184-C2-P1
- S3-R184-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-target-collision-and-git-state-preflight-v0.md`
- `igniter-lang/docs/tracks/compiler-release-execution-boundary-and-approval-plan-v0.md`
- `igniter-lang/docs/discussions/compiler-release-final-authorization-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round183-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-combined-post-prep-smoke-acceptance-decision-v0.md`
- `igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json`
- `igniter-lang/README.md`
- `igniter-lang/RELEASE_NOTES.md`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/lib/igniter_lang/version.rb`

---

## Decision

Decision:

```text
authorize a bounded release execution card next
do not execute release commands in this card
require exact explicit user approval before any future irreversible command
authorize RubyGems publish only inside the next execution card and only after
  collision re-checks, artifact rebuild, SHA match, and user approval
authorize exact tag creation/push only inside the next execution card and only
  under the approved ordering
accept pre-publish README/RELEASE_NOTES wording in the published artifact for
  this first alpha, because the rebuilt artifact must match accepted R183 SHA
require a separate post-publish docs/status sync after successful verification
keep public release/demo claims closed except exact post-verify availability wording
keep branch/conditional if_expr excluded
keep profile finalization/discovery/defaulting closed
keep Spark out of scope
```

This card authorizes the next execution card boundary. It does not itself
publish the gem, create a tag, push to git, sign, deploy, or make public claims.

---

## Acceptance Basis

R183 accepted combined post-prep smoke:

```text
run id:        S3R183C2I_20260526T143139Z
package:       igniter_lang
version:       0.1.0.alpha.1
status:        PASS
failed_checks: []
hold_reasons:  []
artifact SHA:  sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
```

C1-P1 preflight found no blocker:

```text
local tag collision:   none found
remote tag collision:  none found
RubyGems collision:    none found
relevant release files: no scoped git status output
README.md packaged:    yes
RELEASE_NOTES packaged: yes
```

C2-P1 execution plan is accepted as the binding execution boundary:

```text
target:          igniter_lang 0.1.0.alpha.1
tag:             igniter-lang-v0.1.0.alpha.1
artifact policy: rebuild in execution card; require SHA match with R183
publish policy:  gem push exact matching artifact only
tag policy:      push only refs/tags/igniter-lang-v0.1.0.alpha.1
2FA policy:      human RubyGems owner handles MFA/2FA; no secrets in docs/logs
verification:    RubyGems listing, isolated install, require version, igc present
```

C3-X pressure verdict:

```text
verdict: proceed with non-blocking notes
checks: 18/18 PASS
blockers: none
```

Non-blocking notes are accepted with binding execution-card handling:

- NB-1: optional post-publish CLI smoke must run from repo root or use an
  absolute corpus path.
- NB-2: execution card must record Ruby and gem versions beside the rebuilt SHA.
- NB-3: pre-publish packaged docs say "not yet published"; accepted for this
  alpha artifact, with post-publish docs/status sync required after verification.

---

## Required C2-P1 Checklist

| # | Item | Decision |
| --- | --- | --- |
| 1 | Authorize a future release execution card, not execution inside C4-A | yes |
| 2 | Target exactly `igniter_lang 0.1.0.alpha.1` | yes |
| 3 | Use expected tag `igniter-lang-v0.1.0.alpha.1` | yes |
| 4 | Rebuild the artifact in the execution card | yes |
| 5 | Require rebuilt SHA256 to match accepted R183 SHA | yes |
| 6 | Require exact user approval wording before irreversible commands | yes |
| 7 | Permit `gem push` only after collision checks and SHA match | yes |
| 8 | Permit pushing only `refs/tags/igniter-lang-v0.1.0.alpha.1` | yes |
| 9 | Forbid `git push --tags` | yes |
| 10 | Require RubyGems listing and isolated install verification | yes |
| 11 | Keep credential/MFA handling human-owner only | yes |
| 12 | Keep stable, production, demo, all-grammar, Spark, branch/conditional, runtime claims closed | yes |
| 13 | Decide README/RELEASE_NOTES wording update policy | yes: accept current artifact wording; route post-publish sync |

---

## Artifact And Rebuild Policy

The future execution card must rebuild the gem into `/private/tmp` and compare
the rebuilt artifact SHA256 to:

```text
sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
```

Hard rule:

```text
If the rebuilt artifact SHA256 differs, abort before local tag creation,
RubyGems publish, or tag push. Route to a new smoke/evidence review.
```

The R183 temp artifact must not be published directly. It was smoke evidence,
not the durable release artifact.

---

## User Approval Boundary

The future execution card must stop before any irreversible command unless the
user gives approval equivalent to:

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

Partial approval authorizes only the named subset. It does not authorize
`git tag`, `gem push`, or `git push`.

---

## Allowed Future Execution Boundary

Next card:

```text
Card: S3-R185-C1-I
Agent: [Package Agent]
Role: package-agent
Track: compiler-release-execution-igniter-lang-0-1-0-alpha-1-v0
Route: UPDATE
Depends on:
- S3-R184-C4-A

Goal:
Execute the bounded RubyGems alpha prerelease for igniter_lang 0.1.0.alpha.1
only after exact user approval, immediate collision re-checks, artifact rebuild,
and SHA match with accepted R183 smoke evidence.
```

Allowed execution actions:

- re-run full and scoped `git status --short`;
- re-run local tag, remote tag, and RubyGems exact-version collision checks;
- confirm `IgniterLang::VERSION == "0.1.0.alpha.1"`;
- confirm gemspec name is `igniter_lang`;
- confirm gemspec includes `README.md` and `RELEASE_NOTES.md`;
- rebuild `igniter_lang-0.1.0.alpha.1.gem` into `/private/tmp`;
- record Ruby version and gem version;
- verify rebuilt SHA256 equals the accepted R183 SHA;
- create local annotated tag `igniter-lang-v0.1.0.alpha.1`;
- run `gem push` only for the matching rebuilt artifact;
- allow the human owner to complete RubyGems MFA/2FA interactively;
- verify RubyGems listing includes `0.1.0.alpha.1`;
- verify isolated install from RubyGems;
- verify `require "igniter_lang"` reports `0.1.0.alpha.1`;
- verify installed `igc` exists and is executable;
- optionally run one post-publish CLI smoke using repo-root cwd or absolute
  source path;
- push only `refs/tags/igniter-lang-v0.1.0.alpha.1` after publish verification;
- write a release execution result doc and machine-readable receipt if the
  execution card defines one locally.

Allowed command families are limited to the C2-P1 plan:

```text
git status
git tag --list
git ls-remote --tags
gem list --remote --all --exact igniter_lang
gem build igniter-lang/igniter_lang.gemspec --output /private/tmp/...
ruby Digest::SHA256 verification
git tag -a igniter-lang-v0.1.0.alpha.1 -m <approved annotation>
gem push /private/tmp/.../igniter_lang-0.1.0.alpha.1.gem
gem install igniter_lang -v 0.1.0.alpha.1 --no-document --install-dir ...
ruby -e 'require "igniter_lang"; ...'
test -x .../bin/igc
git push origin refs/tags/igniter-lang-v0.1.0.alpha.1
```

---

## Abort Criteria

Abort before `gem push` if:

- exact user approval is missing or narrower than required;
- relevant release files are dirty;
- full worktree status reveals release-relevant ambiguity;
- `IgniterLang::VERSION` is not `0.1.0.alpha.1`;
- gemspec name is not `igniter_lang`;
- gemspec does not include `README.md` and `RELEASE_NOTES.md`;
- local tag already exists;
- remote tag already exists;
- RubyGems already lists `igniter_lang 0.1.0.alpha.1`;
- gem build fails;
- rebuilt SHA256 differs from accepted R183 SHA;
- local annotated tag creation fails;
- RubyGems credentials, ownership, or MFA are unavailable;
- network access is unavailable for required collision checks;
- any command targets a different package, version, tag, or artifact.

Abort after successful `gem push` but before tag push if:

- RubyGems listing does not show `0.1.0.alpha.1`;
- isolated install from RubyGems fails;
- installed `require "igniter_lang"` does not report `0.1.0.alpha.1`;
- installed `igc` is absent or not executable.

No automatic yank is authorized. Any post-publish incident must route to a
separate incident/yank authorization review.

---

## Public Wording And Non-Claims

Public release/demo claims remain closed in this decision card.

After successful publish and post-publish verification, exact allowed wording:

```text
igniter_lang 0.1.0.alpha.1 is available on RubyGems as an alpha prerelease
compiler package. It provides the installed igc CLI for bounded contract
compilation and the accepted --compiler-profile-source PATH.json transport.
```

This wording must remain attached to non-claims:

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

README/RELEASE_NOTES policy:

```text
For the publish artifact, accept current pre-publish wording to preserve the
R183 SHA match requirement. After successful publish verification, open a narrow
docs/status sync route to replace "not yet published" wording with the exact
allowed alpha availability wording. That follow-up is docs/status only and does
not alter the already-published gem artifact.
```

---

## Explicit Answers

### Is release execution authorized now or only in a later card?

Only in a later execution card. This card authorizes the next execution card
boundary and user-approval gate.

### May RubyGems publish open?

Yes, inside the next execution card only, after exact user approval, collision
re-checks, rebuild, and SHA match.

### May tag/push/sign/deploy open?

Tag creation and exact tag push may open inside the next execution card under
the accepted boundary. Signing and deployment remain closed.

### Are public release/demo claims closed or narrowed?

Public release/demo claims remain closed. After publish verification, only the
exact alpha availability wording above is allowed.

### Does branch/conditional `if_expr` remain excluded?

Yes.

### Does profile finalization/discovery/defaulting remain closed?

Yes.

### Is Spark in scope?

No. Spark remains out of scope and non-authorizing context only.

---

## Closed Surfaces

Remain closed:

- release execution inside this card;
- publishing any package other than `igniter_lang-0.1.0.alpha.1.gem`;
- publishing if rebuilt SHA differs from accepted R183 SHA;
- `git push --tags`;
- force push;
- gem yank;
- tag deletion or remote tag deletion;
- signing;
- deployment;
- production readiness claims;
- stable release claims;
- public demo readiness claims;
- all grammar support claims;
- branch/conditional `if_expr`;
- profile finalization/discovery/defaulting;
- named/generated profile lookup;
- inline JSON profile input;
- env/config/sidecar profile lookup;
- public API/CLI widening;
- loader/report or CompatibilityReport readiness;
- runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache behavior;
- Spark integration or Spark public evidence claims;
- Ruby Framework compatibility claims;
- compiler/runtime behavior changes.

---

## Compact Summary

```text
S3-R184-C4-A: authorized-next-execution-card.

Target:
  igniter_lang 0.1.0.alpha.1

Evidence:
  R183 combined post-prep smoke PASS
  run: S3R183C2I_20260526T143139Z
  accepted SHA: sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6

Preflight:
  no local tag collision
  no remote tag collision
  no RubyGems version collision
  relevant release files clean by scoped git status

Authorization:
  open S3-R185-C1-I release execution card
  require exact user approval before irreversible commands
  rebuild artifact and require SHA match before tag/publish
  gem push may run only for exact matching artifact
  push only exact tag after publish verification

Docs:
  current packaged "not yet published" wording accepted for this alpha artifact
  post-publish docs/status sync required after verification

Still closed:
  execution in this card, public demo/stable/production claims, if_expr,
  profile finalization/discovery/defaulting, Spark, runtime, signing, deployment.
```
