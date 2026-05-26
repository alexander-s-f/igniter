# Compiler Release Post-Publish Verification And Status Sync v0

Card: S3-R185-post-publish-sync
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-post-publish-verification-and-status-sync-v0
Route: UPDATE
Status: done / verified-published
Date: 2026-05-26

---

## Purpose

Record the post-publish verification result for:

```text
igniter_lang 0.1.0.alpha.1
```

This track syncs public/package docs after the gem became available on RubyGems.
It does not authorize a stable release, production readiness, public demo
readiness, signing, deployment, runtime widening, Spark integration, or
branch/conditional `if_expr` support.

---

## Verification Summary

RubyGems API verified:

```text
name:        igniter_lang
version:     0.1.0.alpha.1
created_at:  2026-05-26T17:36:51.838Z
project_uri: https://rubygems.org/gems/igniter_lang
yanked:      false
sha:         749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
```

SHA matches the accepted R183/R184 artifact SHA:

```text
sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6
```

Git tag status:

```text
local tag:  igniter-lang-v0.1.0.alpha.1 present
remote tag: refs/tags/igniter-lang-v0.1.0.alpha.1 present
remote tag object/commit id observed:
340c8d1ce37691996d89fa0d3b38eb02a3a27d56
```

Isolated install verification:

```text
gem install igniter_lang -v 0.1.0.alpha.1 --no-document --install-dir /private/tmp/.../gem_home --bindir /private/tmp/.../bin
result: Successfully installed igniter_lang-0.1.0.alpha.1
```

Isolated require verification:

```text
load OK 0.1.0.alpha.1
path=/private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/gem_home/gems/igniter_lang-0.1.0.alpha.1
```

Installed executable verification:

```text
/private/tmp/igniter_lang_release_verify_0_1_0_alpha_1/bin/igc exists and is executable
```

CLI usage check:

```text
env GEM_HOME=/private/tmp/.../gem_home GEM_PATH=/private/tmp/.../gem_home PATH=/private/tmp/.../bin:$PATH /private/tmp/.../bin/igc --help
output: Usage: igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]
```

Note: `igc --help` exits non-zero because the current CLI prints usage for
non-`compile` invocation. For this verification, the important facts are that
the installed binstub is present, executable, resolves the installed gem when
GEM_HOME/GEM_PATH/PATH are set to the isolated install, and exposes the expected
usage surface.

---

## Accepted Public Availability Wording

Allowed wording:

```text
igniter_lang 0.1.0.alpha.1 is available on RubyGems as an alpha prerelease
compiler package. It provides the installed igc CLI for bounded contract
compilation and the accepted --compiler-profile-source PATH.json transport.
```

Required non-claims remain attached:

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

---

## Closed Surfaces

Remain closed:

- stable release claim;
- production readiness claim;
- public demo readiness claim;
- all grammar support claim;
- branch/conditional `if_expr`;
- profile finalization/discovery/defaulting;
- named/generated profile lookup;
- inline JSON profile input;
- env/config/sidecar profile lookup;
- public API/CLI widening beyond accepted `igc compile` and
  `--compiler-profile-source PATH.json`;
- loader/report or CompatibilityReport readiness;
- runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache behavior;
- Spark integration or Spark public evidence claims;
- Ruby Framework compatibility claims;
- signing;
- deployment.

---

## Compact Status

```text
igniter_lang 0.1.0.alpha.1 is published and verified.

RubyGems:
  https://rubygems.org/gems/igniter_lang

SHA:
  sha256:749ee7879cf4b5cb80035e16facdc68dd63e2ebbbec9f13d3d8c23e56e6282d6

Tag:
  igniter-lang-v0.1.0.alpha.1 present locally and on origin

Install:
  isolated gem install PASS
  isolated require PASS
  installed igc executable present

Next:
  docs/status sync complete in README / RELEASE_NOTES / docs index /
  current-status.
```
