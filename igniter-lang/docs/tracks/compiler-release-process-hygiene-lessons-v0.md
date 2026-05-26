# Compiler Release Process Hygiene Lessons v0

Card: S3-R186-C1-P1
Agent: [Package Agent / Release Hygiene Analyst]
Role: package-agent
Track: compiler-release-process-hygiene-lessons-v0
Route: UPDATE
Status: done
Date: 2026-05-26

---

## Purpose

Extract future release-process lessons from R185 and propose a compact release
hygiene rule packet.

This card does not execute release commands, publish or yank gems, create or
push tags, or edit release docs/code.

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-execution-igniter-lang-0-1-0-alpha-1-v0.md`
- `igniter-lang/docs/discussions/compiler-release-execution-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-execution-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round185-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-execution-boundary-and-approval-plan-v0.md`
- `igniter-lang/docs/cards/S3/S3-R185.md`

---

## R185 Lessons

R185 succeeded and was accepted. The process also surfaced reusable hygiene
lessons:

| Source note | Lesson |
| --- | --- |
| C3-A NB-1 | Future approvals should include explicit version and SHA acknowledgement, not compressed approval wording. |
| C3-A NB-2 | Future docs-sync cards should explicitly state whether install commands may be added. |
| C3-A NB-3 | Future prerelease RubyGems listing commands must include `--pre`. |
| C1-I / C2-X | Rebuild artifact in the execution card and require SHA match before publish. |
| C1-I / C2-X | Push only the exact tag ref after publish verification; never broad-push tags. |
| C1-I / C2-X | Human MFA/2FA must remain outside docs/logs/chat and be completed interactively. |
| C1-I / C2-X | Do not auto-yank; route an incident/yank review if verification fails after publish. |

---

## Rule Packet

### HR-1: Future User Approval Wording

Future release execution cards must require explicit approval that names:

- package;
- version;
- expected rebuilt SHA256;
- tag name;
- `gem push`;
- human RubyGems MFA/2FA;
- exact tag push;
- non-claims.

Required approval shape:

```text
I approve the bounded release execution for <gem_name> <version>.
I approve rebuilding the gem and requiring the rebuilt SHA256 to match
<expected_sha256>.
I approve creating the annotated tag <tag>, publishing the matching gem to
RubyGems with gem push, completing RubyGems MFA/2FA as the human owner if
prompted, running post-publish verification, and pushing only the exact tag
<tag> after publish verification.

I understand RubyGems publish for a version is public and not practically
reversible. I understand this does not authorize production, stable, public
demo, all-grammar, branch/conditional, profile discovery/defaulting/finalization,
Spark, runtime, signing, or deployment claims.
```

Future pressure reviews should treat compressed approval such as:

```text
I approve - proceed
```

as a non-blocking note at best only if every other gate passed and human MFA was
completed. For future releases, prefer a HOLD before irreversible commands if
approval does not name package, version, SHA, tag, and publish scope.

### HR-2: Prerelease RubyGems Listing Command

For alpha/beta/rc/prerelease gems, RubyGems listing checks must include
`--pre`:

```bash
gem list --remote --all --exact <gem_name> --pre
```

Without `--pre`, prerelease versions may be hidden or inconsistently surfaced.
This applies to collision checks and post-publish verification.

### HR-3: Post-Publish Docs Sync Install Command Rule

If a post-publish docs/status sync may add install commands, the authorization
card must say so explicitly.

Allowed command wording should be exact-version and bounded:

```bash
gem install <gem_name> -v <version>
```

For prereleases, docs should keep alpha/beta/rc wording attached and must not
imply stable or production readiness.

If install command wording is not explicitly authorized, docs-sync cards should
limit themselves to availability/status wording and avoid adding commands.

### HR-4: RubyGems MFA/2FA Handling

Release cards must preserve:

- no credentials, API keys, OTP seeds, recovery codes, or MFA secrets in chat,
  docs, logs, summaries, or command transcripts;
- human RubyGems owner completes MFA/2FA interactively;
- failed auth/MFA aborts publish flow;
- no repeated publish retries without renewed user confirmation.

### HR-5: SHA Gate

Release execution must rebuild the artifact and verify SHA before publish:

```text
rebuilt_sha256 == accepted_smoke_sha256
```

Required receipt fields:

- accepted SHA;
- rebuilt SHA;
- SHA match boolean;
- Ruby version;
- RubyGems/gem version;
- build cwd;
- artifact path.

If SHA differs, abort before `gem push` and route new smoke/evidence review.

### HR-6: Exact Tag Push

Tag push must be exact:

```bash
git push origin refs/tags/<tag>
```

Forbidden:

```bash
git push --tags
git push --force
remote tag deletion
```

Recommended order:

1. create local annotated tag after SHA match;
2. publish gem;
3. verify RubyGems listing/install;
4. push exact tag only.

Never push the tag before publish verification unless C4-A explicitly chooses a
different order and records why.

### HR-7: No Auto-Yank / Incident Review

Never auto-yank a published gem in the same execution flow.

If publish succeeds and verification later fails:

```text
stop, preserve evidence, open incident/yank authorization review
```

Yank, remote tag deletion, force push, and corrective public claims require
separate explicit authorization.

### HR-8: Release Artifact Rebuild Policy

Do not publish a prior smoke temp artifact as the release artifact.

Future release execution cards should:

- rebuild into a release-specific `/private/tmp` directory;
- capture artifact path;
- verify SHA against accepted smoke SHA;
- publish only the rebuilt, SHA-matching artifact;
- keep the prior smoke artifact as evidence, not as the release payload.

### HR-9: Required Receipt Fields

Future release execution receipts must include:

```text
card
track
status
execution_timestamp_utc
gem_name
version
tag
rubygems_url
approval_text_observed
approval_exact_enough
ruby_version
gem_version
preflight_matrix
collision_checks
artifact_path
accepted_sha256
rebuilt_sha256
sha_match
build_cwd
gem_push_status
mfa_completed_by_human
rubygems_listing_command
rubygems_listing_status
rubygems_api_status_if_checked
isolated_install_status
require_version_status
installed_executable_status
post_publish_cli_smoke_status
tag_push_command
tag_push_status
forbidden_commands_used
docs_sync_required
incident_or_yank_route_required
closed_surfaces_preserved
```

---

## Compact Future-Release Checklist

```text
PRE-AUTH:
  - package/version/tag named
  - accepted smoke SHA named
  - collision checks planned with --pre for prereleases
  - exact user approval wording included
  - MFA/2FA boundary included
  - no-yank policy included

EXECUTION:
  - exact approval observed
  - full and scoped git status clean enough
  - local tag absent
  - remote tag absent
  - RubyGems exact version absent, using --pre for prerelease
  - artifact rebuilt in /private/tmp
  - rebuilt SHA matches accepted SHA
  - local annotated tag created
  - gem push exact artifact only
  - human MFA completed
  - RubyGems listing verified with --pre
  - isolated install verified
  - require version verified
  - installed executable verified
  - optional CLI smoke uses absolute path or explicit cwd
  - exact tag ref pushed only after verification

POST:
  - docs/status sync route explicitly authorized
  - install command wording allowed or omitted explicitly
  - no stable/production/demo/all-grammar/Spark/runtime claims
  - no auto-yank; incident review if anything fails after publish
```

---

## Exact Rule Updates Recommended For Release Cards

### Release Authorization Cards

Add this required line:

```text
Approval must name package, version, expected SHA256, tag, gem push, human
MFA/2FA, exact tag push, and non-claims. Compressed approval is not sufficient
for future releases.
```

Add this prerelease listing rule:

```text
For prerelease versions, RubyGems listing and collision checks must use:
gem list --remote --all --exact <gem_name> --pre
```

Add this docs sync rule:

```text
If post-publish docs/status sync may add install commands, this must be
explicitly authorized. Otherwise install command additions are out of scope.
```

### Release Execution Cards

Add this SHA gate:

```text
Abort before gem push unless rebuilt_sha256 == accepted_smoke_sha256.
Record Ruby version, gem version, build cwd, artifact path, accepted SHA,
rebuilt SHA, and match status.
```

Add this tag rule:

```text
Push only refs/tags/<tag>. Never run git push --tags.
```

Add this incident rule:

```text
If gem push succeeds but verification fails, do not yank automatically. Open a
separate incident/yank authorization review.
```

### Release Pressure Reviews

Add these checks:

```text
approval_exact_enough: package/version/SHA/tag/publish named
prerelease_listing_uses_pre: true for alpha/beta/rc versions
docs_sync_install_command_authorized: true/false with citation
sha_gate_recorded: accepted SHA, rebuilt SHA, match
exact_tag_ref_push_only: true
no_auto_yank: true
receipt_required_fields_present: true
```

---

## Non-Blocking Cleanup Suggestions

1. Add a small reusable release receipt template under a future docs/process or
   tracks template card.
2. Update future S3 release card skeletons to include `--pre` on prerelease
   RubyGems checks.
3. Add an approval snippet block to future C0-U sections so the user can approve
   with exact package/version/SHA/tag wording.
4. Add an explicit post-publish docs-sync option selector:
   `availability wording only` vs `availability wording plus install command`.
5. Consider a machine-readable release receipt JSON in future executions if the
   release route repeats.

These are non-blocking. R185 remains accepted and requires no incident/yank/tag
remediation.

---

## Closed Surfaces

This card does not authorize:

- release execution;
- RubyGems publish;
- gem yank;
- git tag creation;
- git push;
- signing or deployment;
- release docs/code edits;
- production readiness claims;
- stable release claims;
- public demo claims;
- all grammar support claims;
- branch/conditional `if_expr`;
- profile finalization/discovery/defaulting;
- Spark integration;
- runtime behavior changes.
