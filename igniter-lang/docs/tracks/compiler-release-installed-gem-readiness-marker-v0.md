# Compiler Release Installed Gem Readiness Marker v0

Card: S3-R174-C1-S
Agent: [Igniter-Lang Status Curator]
Role: status-curator
Track: compiler-release-installed-gem-readiness-marker-v0
Route: UPDATE
Status: done
Date: 2026-05-25

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md`
- `igniter-lang/docs/tracks/stage3-round173-status-curation-v0.md`
- `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json`
- `igniter-lang/docs/cards/S3/S3-R174.md`

---

## Readiness Marker

Local package/install readiness is accepted only for the bounded smoke scope:

```text
readiness_scope: local_package_install_smoke_only
package: igniter_lang
version: 0.1.0.pre.stage2
run_id: S3R173C1I_20260525T063543Z
built_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
installed_cli: igc compile
```

Accepted wording:

```text
The current local igniter_lang package builds, installs into an isolated gem
home, loads without repo-relative -I, and the installed igc CLI compiles the
accepted positive corpus and refuses the accepted negative corpus.
```

This marker records accepted local evidence only. It does not make public
release, RubyGems availability, production, demo, Spark, Ruby Framework
compatibility, all-grammar, or branch/conditional support claims.

---

## Accepted Smoke Evidence

Source decision:

```text
track: compiler-release-package-install-smoke-acceptance-decision-v0
decision: accept_package_install_smoke_PASS
```

Accepted run facts:

```text
run_id: S3R173C1I_20260525T063543Z
status: PASS
failed_checks: 0
hold_reasons: 0
repo_relative_i_used: false
repo_path_leak_observed: false
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

Corpus result:

```text
positive_corpus: 5/5 PASS
refusal_corpus: 3/3 PASS
```

Durable summary:

```text
igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json
```

---

## Public Non-Claims

The following remain closed:

- public release/demo claims;
- RubyGems publish and public availability claims;
- production readiness;
- version edits;
- gemspec/package metadata edits;
- git tag creation;
- git push;
- signing;
- deployment;
- profile-source smoke extension;
- public API/CLI widening;
- branch/conditional `if_expr` support;
- all-grammar support;
- Spark integration;
- Ruby Framework compatibility;
- runtime, Ledger/TBackend, BiHistory, stream/OLAP, cache, production, and demo
  claims.

---

## Future Smoke Hygiene

Carry the R173 C3-A NB-1 as future smoke hygiene:

```text
type_mismatch.ig refusal_kind should classify as oof
unresolved_symbol.ig refusal_kind should classify as oof
```

This does not block the accepted readiness marker because PKG-5 criteria passed:
non-zero exit, observed refusal, and no `.igapp` output.

---

## Compact Handoff

```text
card: S3-R174-C1-S
track: compiler-release-installed-gem-readiness-marker-v0
status: done
readiness_scope: local_package_install_smoke_only
package: igniter_lang
version: 0.1.0.pre.stage2
run_id: S3R173C1I_20260525T063543Z
built_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
installed_cli: igc compile
positive_corpus: 5/5_PASS
refusal_corpus: 3/3_PASS
failed_checks: 0
hold_reasons: 0
public_release_demo_claims: closed
rubygems_publish: closed
version_tag_push_publish_sign_deploy: closed
profile_source_smoke: deferred
future_smoke_hygiene: type_mismatch_and_unresolved_symbol_refusal_kind_should_be_oof
next_expected_cards: S3-R174-C2-P1 -> S3-R174-C3-X -> S3-R174-C4-A -> S3-R174-C5-S
no_code_edited: yes
```
