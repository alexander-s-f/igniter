# Ruby 0.5.2 Push Readiness v0

Status: ready, waiting for explicit push authorization
Date: 2026-05-21
Card: RUBY-PUSH-P1
Route: UPDATE
Track: ruby-0-5-2-push-readiness-v0
Guidance: PG-2026-05-20-01

## Purpose

Prepare the push commit/tag route for the local `0.5.2` release commit without
publishing gems and without pushing until the user explicitly authorizes it.

## State Checked

Working tree:

```text
clean before this push-readiness packet was written
```

Current branch:

```text
master
```

Remote:

```text
origin https://github.com/alexander-s-f/igniter.git
```

Branch state:

```text
master...origin/master [ahead 4]
```

Release commit:

```text
ce113ff36ca456e48348197b3dc6698d7815037d
```

Release tag:

```text
v0.5.2 -> ce113ff36ca456e48348197b3dc6698d7815037d
```

## Commits To Push

Pushing `master` to `origin/master` will push these four local commits:

```text
ce113ff3 chore(release): prepare 0.5.2
00d2b395 [LANG-R103-I] Implement OOF/Fragment Registry internal validator + boundary proof (27/27 PASS)
19ba09ea docs(igniter-lang, ruby-framework): add release preflight and OOF implementation authorization updates
c1e3f5c2 docs(ruby-framework, igniter-lang): add release blocker closure plans and OOF registry design updates
```

The tag push will push:

```text
v0.5.2
```

## Exact Push Commands

Recommended branch push:

```bash
git push origin master
```

Recommended tag push:

```bash
git push origin v0.5.2
```

Alternative single command:

```bash
git push origin master v0.5.2
```

Use the two-command route for clearer failure handling.

## Boundaries

Allowed only after explicit user approval:

- push `master` to `origin/master`;
- push tag `v0.5.2` to `origin`.

Still not allowed by this push readiness card:

- `gem push`;
- Rubygems publish;
- changing versions;
- creating/moving tags;
- force push;
- Spark production-readiness claim.

## Current Local Docs Note

This push-readiness packet itself creates local docs changes:

```text
.agents/ruby-framework/tracks/ruby-0-5-2-push-readiness-v0.md
.agents/ruby-framework/reports/ruby-push-p1-0-5-2-push-readiness.md
.agents/ruby-framework/current-status.md
```

Before push execution, choose one:

- commit these readiness docs and include them in the branch push; or
- leave them local and do not include them in the branch push.

## Approval Needed

Exact approval needed:

```text
Approve pushing local master to origin/master and pushing tag v0.5.2 to origin.
I understand this pushes the four commits listed above. Do not publish gems.
```

If readiness docs should also be pushed, approve committing them before the
branch push.

If only the release commit/tag should be pushed, do not approve this direct
`master` push. A separate branch/cherry-pick route would be needed.

## Recommendation

```text
ready to push branch and tag after explicit approval
```

Publish remains a separate authorization after push.
