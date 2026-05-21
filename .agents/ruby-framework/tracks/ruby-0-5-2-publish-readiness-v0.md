# Ruby 0.5.2 Publish Readiness v0

Status: PASS, waiting for explicit publish authorization
Date: 2026-05-21
Card: RUBY-PUBLISH-P1
Route: UPDATE
Track: ruby-0-5-2-publish-readiness-v0
Guidance: PG-2026-05-20-01

## Purpose

Prepare the final publish authorization packet for Ruby Framework `0.5.2`
without publishing gems.

## Remote Commit / Tag State

Remote branch:

```text
origin/master = b8965575dd7cf6412e292c67b9d7dbf2cb4b4091
```

Local branch state at check time:

```text
master...origin/master [ahead 2]
```

Local commits ahead of `origin/master` are Lang docs/design commits and are not
required for gem publish because the release tag is already pushed.

Remote tag:

```text
v0.5.2 -> ce113ff36ca456e48348197b3dc6698d7815037d
```

Local tag:

```text
v0.5.2 -> ce113ff36ca456e48348197b3dc6698d7815037d
```

Conclusion:

```text
remote release tag is present and matches local release commit
```

## Gem Artifacts

Fresh `0.5.2` artifacts exist locally:

```text
igniter-0.5.2.gem
packages/igniter-contracts/igniter-contracts-0.5.2.gem
packages/igniter-extensions/igniter-extensions-0.5.2.gem
packages/igniter-embed/igniter-embed-0.5.2.gem
packages/igniter-ledger-client/igniter-ledger-client-0.5.2.gem
packages/igniter-ledger/igniter-ledger-0.5.2.gem
```

Artifact status:

- all listed `.gem` files are ignored by `.gitignore: *.gem`;
- no `.gem` artifacts are tracked by git.

## Docs / Spark Boundary

Confirmed package docs do not claim Spark production readiness.

Relevant boundary remains intact:

- `availability_slot_map_summary` is sanitized aggregate output vocabulary,
  not an Embed receipt kind;
- Embed observation receipt kind remains `:contractable_observation`;
- Embed event receipt kind remains `:contractable_event`;
- Ledger sinks are optional adapters and not source of truth;
- no Spark adapter, shadow candidate implementation, or Spark rollout is
  authorized by this publish readiness packet.

## Rubygems Credentials / MFA / Ownership Checklist

Before running any `gem push`, confirm:

- [ ] Rubygems API key is available in the local environment.
- [ ] Rubygems account has MFA enabled/ready for push if prompted.
- [ ] Rubygems ownership allows pushing:
  - `igniter`;
  - `igniter-contracts`;
  - `igniter-extensions`;
  - `igniter-embed`;
  - `igniter-ledger-client`;
  - `igniter-ledger`.
- [ ] No `0.5.2` version already exists remotely for any package.
- [ ] User gives explicit publish authorization phrase below.

This packet does not verify credentials by publishing. Credential/ownership
failures should be treated as publish execution blockers, not as reasons to
retry unsafe commands.

## Exact Gem Push Order

Publish dependencies first:

```bash
gem push packages/igniter-contracts/igniter-contracts-0.5.2.gem
gem push packages/igniter-extensions/igniter-extensions-0.5.2.gem
gem push packages/igniter-embed/igniter-embed-0.5.2.gem
gem push packages/igniter-ledger-client/igniter-ledger-client-0.5.2.gem
gem push packages/igniter-ledger/igniter-ledger-0.5.2.gem
gem push igniter-0.5.2.gem
```

Reason:

- `igniter-extensions` depends on `igniter-contracts`;
- `igniter-embed` depends on `igniter-contracts` and `igniter-extensions`;
- `igniter-ledger` and `igniter-ledger-client` are independent from the Embed
  dependency chain for publish ordering;
- the umbrella `igniter` gem should publish after package gems.

## Native Extension Release Note

Preserve this note for `igniter-ledger`:

```text
igniter-ledger clean install currently needs crates.io/network access unless
Rust dependencies are vendored or prebuilt native artifacts are introduced.
```

## Explicit Approval Phrase Required

Publish remains closed until the user says exactly:

```text
Approve publishing Ruby Framework 0.5.2 gems to Rubygems in the listed order. I understand this will run gem push. Do not push git branches or tags.
```

Any narrower approval should be treated as a partial publish route and require
an updated packet.

## PASS / HOLD

```text
PASS for publish readiness
HOLD for publish execution until explicit approval phrase
```
