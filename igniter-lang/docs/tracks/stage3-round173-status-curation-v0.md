# Stage 3 Round 173 Status Curation v0

Card: S3-R173-C4-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: stage3-round173-status-curation-v0
Route: UPDATE
Status: done
Date: 2026-05-25

Depends on:
- S3-R173-C3-A

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md`
- `igniter-lang/docs/discussions/compiler-release-package-install-smoke-pressure-v0.md`
- `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json`
- `igniter-lang/docs/cards/S3/S3-R173.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/README.md`

---

## Smoke Execution Status

R173 C3-A accepts the package/install smoke evidence as PASS.

Accepted run:

```text
run_id: S3R173C1I_20260525T063543Z
package: igniter_lang
version: 0.1.0.pre.stage2
installed_cli: igc compile
built_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
status: PASS
failed_checks: 0
hold_reasons: 0
```

Accepted PKG matrix:

```text
PKG-0: PASS - gemspec syntax
PKG-1: PASS - gem build
PKG-2: PASS - isolated install and igc present
PKG-3: PASS - require "igniter_lang" without repo-relative -I / no path leak
PKG-4: PASS - installed igc compile, 5/5 positive corpus
PKG-5: PASS - installed igc compile refusal, 3/3 negative corpus
```

Durable summary:

```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json
```

---

## Installed-Gem / Package Readiness Status

Installed-gem/package readiness is recognized only for this bounded local smoke
scope:

```text
local package/install smoke readiness for igniter_lang 0.1.0.pre.stage2
```

Allowed wording:

```text
The current local igniter_lang package builds, installs into an isolated gem
home, loads without repo-relative -I, and the installed igc CLI compiles the
accepted positive corpus and refuses the accepted negative corpus.
```

This does not establish public release readiness, RubyGems availability,
production readiness, public demo readiness, Spark integration, Ruby Framework
compatibility, branch/conditional support, or all-grammar support.

---

## Public Claims Status

Public release and demo claims remain closed.

Not allowed:

- "Igniter-Lang is released."
- "Igniter-Lang is available on RubyGems."
- "Igniter-Lang is production ready."
- "Public demo ready."
- "Supports all grammar."
- "Supports branch/conditional if_expr."
- "Spark integrated."
- "Ruby Framework compatible."

---

## Version / Tag / Push / Publish Status

Version/tag/push/publish/sign/deploy remain closed.

```text
current_version: 0.1.0.pre.stage2
version_change_authorized: no
git_tag_authorized: no
push_authorized: no
publish_authorized: no
signing_authorized: no
deployment_authorized: no
```

No version file was edited, no gemspec edit was authorized, no tag was created,
no push was performed, no gem was published, and no signing/deployment occurred.

---

## Pressure Notes

R173 C2-X passed 14/14 checks with no blockers.

Accepted non-blocking notes:

- `refusal_kind` is recorded as `parse_error` for `type_mismatch.ig` and
  `unresolved_symbol.ig`, but their compiler result status is `oof`; PKG-5
  criteria still passed. Future smoke summaries should classify those two as
  `oof`.
- PKG-0 appears in the command matrix only, not the criteria block; PKG-0
  evidence is present and PASS.

---

## Current Next Route

Open installed-gem readiness marker/status next:

```text
Card: S3-R174-C1-I
Agent: [Igniter-Lang Status/Implementation Agent]
Role: status-curator
Track: compiler-release-installed-gem-readiness-marker-v0
Route: UPDATE
```

That marker should record the accepted bounded local package/install readiness,
the run id, package/version/SHA256, installed `igc compile` PASS, public
non-claims, version/tag/push/publish/sign/deploy closure, profile-source smoke
deferral, and the future `refusal_kind` hygiene note.

---

## Closed Surfaces

R173 C3-A does not authorize:

- public release or demo claims;
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
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

---

## Compact Round Summary

R173 runs and accepts the bounded local package/install smoke. The package
builds, installs in isolated temp state, loads without repo-relative `-I`, and
the installed `igc` compiles 5/5 positive corpus files and refuses 3/3 negative
corpus files. Installed-gem/package readiness is recognized only for the bounded
local smoke scope. Public release/demo claims, RubyGems availability, version/
tag/push/publish/sign/deploy, profile-source smoke, Spark, runtime, production,
and public compatibility claims remain closed.

---

## Round Receipt

```text
round: S3-R173
status: closed
status_curator_card: S3-R173-C4-S
decision: accept_package_install_smoke_PASS
run_id: S3R173C1I_20260525T063543Z
package: igniter_lang
version: 0.1.0.pre.stage2
built_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
installed_cli: igc compile
PKG-0: PASS
PKG-1: PASS
PKG-2: PASS
PKG-3: PASS
PKG-4: PASS_5_of_5
PKG-5: PASS_3_of_3
failed_checks: 0
hold_reasons: 0
installed_gem_package_readiness: accepted_for_local_package_install_smoke_only
public_claims_authorized: no
version_change_authorized: no
git_tag_authorized: no
publish_authorized: no
profile_source_smoke: deferred
spark_status: excluded_non_authorizing
ruby_ledger_hardening: independent_non_blocking
next_route: compiler-release-installed-gem-readiness-marker-v0
no_code_edited_by_status_curator: yes
```
