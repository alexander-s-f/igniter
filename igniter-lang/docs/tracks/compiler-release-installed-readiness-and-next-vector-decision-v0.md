# Compiler Release Installed Readiness and Next Vector Decision v0

Card: S3-R174-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-installed-readiness-and-next-vector-decision-v0
Route: UPDATE
Status: done
Date: 2026-05-25

Depends on:
- S3-R174-C1-S
- S3-R174-C2-P1
- S3-R174-C3-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-installed-gem-readiness-marker-v0.md`
- `igniter-lang/docs/tracks/compiler-release-next-vector-options-v0.md`
- `igniter-lang/docs/discussions/compiler-release-installed-gem-marker-and-next-vector-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round173-status-curation-v0.md`
- `igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json`

---

## Decision

Decision:

```text
accept installed-gem readiness marker
preserve local package/install smoke readiness as bounded only
open profile-source smoke extension authorization review next
keep release execution closed
keep public release/demo claims closed
keep RubyGems publish closed
keep version/tag/push/publish/sign/deploy closed
```

The S3-R174-C1-S readiness marker is accepted. It accurately records the R173
accepted smoke evidence and remains correctly limited to:

```text
local package/install smoke readiness for igniter_lang 0.1.0.pre.stage2
```

This is a strong package-readiness milestone, but it is not public release
readiness, RubyGems availability, production readiness, or public demo
readiness.

---

## Accepted Marker Facts

Accepted marker:

| Field | Accepted value |
| --- | --- |
| readiness scope | `local_package_install_smoke_only` |
| package | `igniter_lang` |
| version | `0.1.0.pre.stage2` |
| run id | `S3R173C1I_20260525T063543Z` |
| built gem SHA256 | `sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a` |
| installed command | `igc compile` |
| positive corpus | `5/5 PASS` |
| refusal corpus | `3/3 PASS` |
| failed checks | `0` |
| hold reasons | `0` |

Accepted wording remains:

```text
The current local igniter_lang package builds, installs into an isolated gem
home, loads without repo-relative -I, and the installed igc CLI compiles the
accepted positive corpus and refuses the accepted negative corpus.
```

No stronger wording is authorized.

---

## Pressure Verdict

S3-R174-C3-X verdict:

```text
proceed - no blockers; 9/9 checks PASS
```

Accepted pressure results:

- marker uses exact R173 run id, version, package, SHA256, and corpus counts;
- marker wording is bounded to local package/install smoke readiness;
- public release/demo, RubyGems, production, version/tag/push/publish/sign/
  deploy claims remain closed;
- profile-source smoke remains deferred or proposed only as an
  authorization-review route;
- NB-1 refusal-kind hygiene is carried without becoming a false blocker;
- next-vector options do not imply release execution;
- branch/conditional `if_expr` remains excluded;
- Spark remains absent;
- Ruby remains independent and non-blocking.

Non-blocking pressure notes accepted:

- Future decisions should cite the full authorization chain:
  `R170 -> R171 -> R172 -> R173 -> R174`.
- If non-public docs planning opens later, it must carry the seven not-allowed
  wording prohibitions from R173 as binding constraints.

---

## Next Vector

Selected next route:

```text
profile-source smoke extension authorization review
```

Reason:

- local package/install smoke for installed `igc compile` is now accepted;
- profile-source smoke remains explicitly deferred;
- profile-source behavior is the most obvious package/readiness confidence gap
  before any public docs or release wording should become primary;
- the next route can be authorization-review-only and does not need to execute
  smoke immediately;
- public release/demo claims remain safer if profile-source support is reviewed
  first.

Rejected for immediate next route:

| Route | Disposition |
| --- | --- |
| public release/docs non-claims planning | defer; useful later, but safer after profile-source smoke authorization review |
| additional package smoke hygiene | defer; NB-1 is hygiene, not blocker |
| release execution authorization hold | not chosen; continue release-readiness movement without execution |
| return to compiler/language feature lane | not chosen for this immediate release vector |
| pause | not chosen |

---

## Explicit Answers

Is the installed-gem readiness marker accepted?

```text
Yes. The marker is accepted as an exact bounded record of R173 local package/
install smoke readiness.
```

Does local package/install smoke readiness remain bounded?

```text
Yes. It remains bounded to local package/install smoke only.
```

Does release execution remain closed?

```text
Yes. Release execution remains closed across the full R170 -> R171 -> R172 ->
R173 -> R174 chain.
```

Do public release/demo claims remain closed?

```text
Yes. Public release/demo claims remain closed.
```

Does RubyGems publish remain closed?

```text
Yes. RubyGems publish remains closed.
```

Do version/tag/push/publish/sign/deploy remain closed?

```text
Yes. Version edits, tags, pushes, publishing, signing, and deployment remain
closed.
```

May profile-source smoke open next?

```text
Yes, as an authorization-review route only. This decision does not authorize
profile-source smoke execution.
```

Does branch/conditional `if_expr` remain excluded?

```text
Yes. Branch/conditional `if_expr` remains excluded from the current release
readiness scope.
```

Does Spark remain out of scope?

```text
Yes. Spark remains out of scope and non-authorizing for this release lane.
```

---

## Next Dispatch Recommendation

Open profile-source smoke extension authorization review:

```text
Card: S3-R175-C1-P1
Agent: [Profile Source Smoke Boundary Analyst]
Role: release-readiness-agent
Track: compiler-release-profile-source-smoke-extension-boundary-v0

Route: UPDATE

Goal:
Prepare the exact boundary for a possible installed-package profile-source
smoke extension after local package/install smoke readiness was accepted.

Scope:
- Read:
  - igniter-lang/docs/tracks/compiler-release-installed-readiness-and-next-vector-decision-v0.md
  - igniter-lang/docs/tracks/compiler-release-installed-gem-readiness-marker-v0.md
  - igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/compiler-release-package-install-smoke-v0.md
  - igniter-lang/docs/tracks/compiler-release-evidence-hash-docs-and-package-smoke-policy-v0.md
  - igniter-lang/docs/tracks/stage3-round173-status-curation-v0.md
  - igniter-lang/experiments/compiler_release_package_install_smoke_v0/out/S3R173C1I_20260525T063543Z/package_install_smoke_summary.json
- Define:
  - exact profile-source smoke purpose;
  - installed `igc compile` command shape;
  - fixture/corpus candidates;
  - expected success/refusal behavior;
  - summary/result packet shape;
  - PASS/HOLD/FAIL criteria;
  - temp artifact policy;
  - non-claims;
  - risks and recommendation.
- Preserve:
  - no smoke execution in this card;
  - no release execution;
  - no public release/demo claims;
  - no version/tag/push/publish/sign/deploy;
  - no public API/CLI widening;
  - no branch/conditional support claim.

Deliver:
- Track doc in `igniter-lang/docs/tracks/`
- Compact boundary packet
- Recommended authorization stance
```

Recommended companion cards:

```text
S3-R175 = [C1-P1, C2-P1] -> C3-X -> C4-A -> C5-S
```

Where:

- `C1-P1` defines profile-source smoke boundary;
- `C2-P1` defines profile-source smoke criteria/result packet;
- `C3-X` pressure-reviews the authorization boundary;
- `C4-A` decides whether execution may open;
- `C5-S` curates status.

---

## Closed Surfaces

This decision does not authorize:

- profile-source smoke execution;
- public release or demo claims;
- RubyGems publish;
- version file edits;
- gemspec/package metadata edits;
- git tag creation;
- git push;
- signing;
- deployment;
- release execution;
- public API/CLI widening;
- branch/conditional implementation or support claim;
- parser, classifier, TypeChecker, SemanticIR, assembler changes;
- compiler/library behavior changes;
- loader/report, `CompilationReport`, `CompilerResult`, or CompatibilityReport
  widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing,
  deployment, or demo work.

---

## Compact Receipt

```text
card: S3-R174-C4-A
track: compiler-release-installed-readiness-and-next-vector-decision-v0
status: done
decision: accept_installed_gem_readiness_marker
readiness_scope: local_package_install_smoke_only
package: igniter_lang
version: 0.1.0.pre.stage2
run_id: S3R173C1I_20260525T063543Z
built_gem_sha256: sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a
installed_cli: igc compile
positive_corpus: 5/5_PASS
refusal_corpus: 3/3_PASS
pressure: proceed_9_of_9
release_execution: closed
public_release_demo_claims: closed
rubygems_publish: closed
version_tag_push_publish_sign_deploy: closed
profile_source_smoke: authorization_review_may_open_next_execution_closed
branch_conditional_if_expr: excluded
spark: out_of_scope_non_authorizing
ruby: independent_non_blocking
next_route: compiler-release-profile-source-smoke-extension-authorization-review
```
