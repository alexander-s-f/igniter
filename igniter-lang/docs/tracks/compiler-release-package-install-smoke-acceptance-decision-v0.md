# Compiler Release Package/Install Smoke Acceptance Decision v0

Card: S3-R173-C3-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-package-install-smoke-acceptance-decision-v0
Route: UPDATE
Status: done
Date: 2026-05-25

Depends on:
- S3-R173-C1-I
- S3-R173-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md`
- `igniter-lang/docs/discussions/compiler-release-package-install-smoke-pressure-v0.md`
- `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-authorization-review-v0.md`
- `igniter-lang/docs/tracks/stage3-round172-status-curation-v0.md`

---

## Decision

Decision:

```text
accept package/install smoke closure
recognize local installed-gem/package readiness for the bounded smoke scope
keep public release/demo claims closed
keep version/tag/push/publish/sign/deploy closed
open installed-gem readiness marker next
```

The S3-R173-C1-I smoke evidence is accepted as PASS for this bounded scope:

```text
bounded_local_package_install_smoke
```

This establishes local package/install readiness evidence for the current
`igniter_lang` package version:

```text
0.1.0.pre.stage2
```

This does not establish public release readiness, RubyGems availability,
production readiness, or public demo readiness.

---

## Accepted Smoke Evidence

Accepted run:

| Field | Accepted value |
| --- | --- |
| smoke card | `S3-R173-C1-I` |
| smoke track | `compiler-release-package-install-smoke-v0` |
| run id | `S3R173C1I_20260525T063543Z` |
| status | `PASS` |
| package | `igniter_lang` |
| version | `0.1.0.pre.stage2` |
| built gem SHA256 | `sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a` |
| installed executable | `igc` |
| installed command | `igc compile` |
| repo-relative `-I` | `false` |
| repo path leak | `false` |
| failed checks | `0` |
| hold reasons | `0` |
| positive corpus | `5/5 PASS` |
| refusal corpus | `3/3 PASS` |

PKG results:

```text
PKG-0 PASS - gemspec syntax
PKG-1 PASS - gem build
PKG-2 PASS - isolated install and igc present
PKG-3 PASS - require "igniter_lang" without repo-relative -I / no path leak
PKG-4 PASS - installed igc compile, 5/5 positive corpus
PKG-5 PASS - installed igc compile refusal, 3/3 negative corpus
```

Durable summary:

```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json
```

---

## Pressure Verdict

S3-R173-C2-X verdict:

```text
proceed - no blockers; 14/14 checks PASS
```

All pressure checks passed:

- smoke status derived from PKG criteria;
- PKG-0..PKG-5 evidence exists;
- installed CLI uses `$BIN_DIR/igc compile`;
- no command uses `igniter-lang compile`;
- installed checks do not use repo-relative `-I` or repo `RUBYLIB`;
- positive corpus is 5/5 PASS and refusal corpus is 3/3 PASS;
- all non-claims are present;
- temp artifact policy followed;
- no version/gemspec/tag/push/publish/sign/deploy action occurred;
- no public release/demo claim opened;
- no profile-source smoke extension was run;
- no compiler/runtime code surface changed;
- Spark absent;
- Ruby non-blocking.

Accepted non-blocking notes:

- NB-1: `refusal_kind` is recorded as `parse_error` for `type_mismatch.ig` and
  `unresolved_symbol.ig`, but their compiler result status is `oof`. This is
  not a gate blocker because PKG-5 criteria require non-zero exit, no `.igapp`,
  and observed refusal, all of which passed. Future smoke summaries should
  classify those two as `oof`.
- NB-2: PKG-0 appears in the `command_matrix` only, not the `criteria` block.
  This is not a blocker because PKG-0 evidence is present and PASS.

---

## Readiness Recognition

Installed-gem/package readiness may now be recognized only for this bounded
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

## Explicit Answers

Is smoke evidence accepted?

```text
Yes. The package/install smoke evidence is accepted as PASS.
```

May installed-gem/package readiness be recognized?

```text
Yes, for local package/install smoke only. Public release readiness remains
closed.
```

Do public release/demo claims remain closed?

```text
Yes. Public release/demo claims remain closed.
```

Do version/tag/push/publish/sign/deploy remain closed?

```text
Yes. Version edits, tags, pushes, RubyGems publish, signing, and deployment
remain closed.
```

Does profile-source smoke remain deferred?

```text
Yes. No profile-source smoke extension was authorized or run.
```

Does Spark remain out of scope?

```text
Yes. Spark remains excluded and non-authorizing.
```

What next route should open?

```text
Open an installed-gem readiness marker/status route next.
```

---

## Next Dispatch Recommendation

Open installed-gem readiness marker/status next:

```text
Card: S3-R174-C1-I
Agent: [Igniter-Lang Status/Implementation Agent]
Role: status-curator
Track: compiler-release-installed-gem-readiness-marker-v0
Route: UPDATE

Goal:
Record the accepted local package/install smoke readiness marker, preserving
all public non-claims and closed surfaces.

Scope:
- Read:
  - igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md
  - igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json
- Write only:
  - igniter-lang/docs/tracks/compiler-release-installed-gem-readiness-marker-v0.md
  - igniter-lang/docs/current-status.md
  - igniter-lang/docs/tracks/README.md
  - igniter-lang/docs/cards/S3/S3.md
- Record:
  - local package/install readiness accepted;
  - package/version/SHA256/run id;
  - installed `igc compile` PASS;
  - public release/demo claims closed;
  - version/tag/push/publish/sign/deploy closed;
  - profile-source smoke deferred;
  - NB-1 refusal_kind correction carried as future smoke hygiene.
- Do not:
  - publish gems;
  - create tags;
  - edit versions;
  - make public claims;
  - edit compiler/runtime code.

Deliver:
- Marker/status track doc
- Updated current status/index entries
- Compact handoff
```

After the marker, the next strategic route may be one of:

- public release/docs non-claims planning;
- profile-source smoke extension authorization;
- public release hold / pause;
- return to compiler/language feature lane.

---

## Closed Surfaces

This decision does not authorize:

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
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, deployment, or demo work.

---

## Compact Receipt

```text
card: S3-R173-C3-A
track: compiler-release-package-install-smoke-acceptance-decision-v0
status: done
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
nb_refusal_kind_hygiene: type_mismatch_and_unresolved_symbol_should_be_oof_in_future_smoke
next_route: compiler-release-installed-gem-readiness-marker-v0
```
