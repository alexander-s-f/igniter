# Compiler Release Repo-Local RC Marker Acceptance Decision v0

Card: S3-R171-C3-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-repo-local-rc-marker-acceptance-decision-v0
Route: UPDATE
Status: done
Date: 2026-05-24

Depends on:
- S3-R171-C1-I
- S3-R171-C2-X

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-v0.md`
- `igniter-lang/docs/discussions/compiler-release-repo-local-rc-marker-pressure-v0.md`
- `igniter-lang/docs/tracks/compiler-release-execution-authorization-review-v0.md`
- `igniter-lang/docs/tracks/stage3-round170-status-curation-v0.md`

---

## Decision

Decision:

```text
accept repo-local compiler RC marker closure
open package/install smoke authorization review next
keep release execution beyond marker closed
keep public release/demo claims closed
keep installed-gem/package readiness not established
```

The S3-R171-C1-I marker is accepted as the repo-local compiler RC marker for
the accepted official first-RC evidence scope:

```text
repo_local_compiler_rc
```

Marker target:

```text
repo_local_compiler_rc_marker
```

This decision accepts the marker only. It does not authorize package/install
smoke execution, public release, RubyGems publish, version change, tag, push,
signing, deployment, or public demo/release claims.

---

## Accepted Marker Evidence

Accepted marker facts:

| Field | Accepted value |
| --- | --- |
| marker card | `S3-R171-C1-I` |
| marker track | `compiler-release-repo-local-rc-marker-v0` |
| marker target | `repo_local_compiler_rc_marker` |
| official evidence scope | `repo_local_compiler_rc` |
| evidence status | `PASS` |
| official evidence authorization | `S3-R167-C1-A` |
| official evidence acceptance | `S3-R168-C4-A` |
| marker authorization | `S3-R170-C4-A` |
| independent hash verification | `PASS` |
| hash value | `sha256:bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b` |
| version change | not authorized |
| current version | `0.1.0.pre.stage2` |
| git tag | not authorized |
| public claims | closed |
| installed-gem/package readiness | not established |
| package/install smoke | not authorized / not run |
| branch/conditional `if_expr` | excluded from first RC |
| code surfaces changed | no |

---

## Pressure Verdict

S3-R171-C2-X verdict:

```text
proceed - no blockers; 12/12 checks PASS
```

All pressure checks passed:

- independent hash verification run and passed;
- marker target is exactly `repo_local_compiler_rc_marker`;
- official evidence scope is `repo_local_compiler_rc`, status `PASS`;
- `branch_conditional_if_expr` remains excluded with S3-R164-C4-A basis;
- installed-gem/package readiness remains not established;
- public claims remain closed with comprehensive non-claims;
- no version change, tag, push, publish, signing, or deployment;
- package/install smoke was not run and not authorized;
- no code surfaces changed;
- Spark is absent and non-authorizing;
- Ruby Ledger hardening remains independent and non-blocking;
- EH-1..EH-7 from S3-R170-C4-A are addressed.

Accepted non-blocking note:

- NB-1: the secondary `rg` confirmation command from S3-R170-C4-A was not
  explicitly confirmed as run, but it was informational only. The required hash
  command ran and passed; the marker table records the same informational facts.

---

## Explicit Answers

Is the repo-local RC marker accepted?

```text
Yes. The repo-local compiler RC marker is accepted.
```

Does release execution beyond marker remain closed?

```text
Yes. Release execution beyond the marker remains closed.
```

Do public release/demo claims remain closed?

```text
Yes. Public release/demo claims remain closed.
```

Is installed-gem/package readiness established?

```text
No. Installed-gem/package readiness remains not established.
```

Does branch/conditional remain excluded?

```text
Yes. branch_conditional_if_expr remains excluded from first RC and remains a
post-RC language/compiler design lane.
```

May package/install smoke open next?

```text
Yes, but only as an authorization review. Package/install smoke execution is
not authorized by this decision.
```

---

## Next Dispatch Recommendation

Open package/install smoke authorization review next:

```text
Card: S3-R172-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-package-install-smoke-authorization-review-v0

Route: UPDATE

Goal:
Decide whether to authorize a bounded local package/install smoke for
Igniter-Lang after the repo-local compiler RC marker has been accepted.

Scope:
- Read:
  - igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-v0.md
  - igniter-lang/docs/tracks/compiler-release-execution-authorization-review-v0.md
  - igniter-lang/docs/tracks/compiler-release-evidence-hash-docs-and-package-smoke-policy-v0.md
  - igniter-lang/docs/tracks/compiler-release-target-versioning-and-execution-options-v0.md
- Decide:
  - authorize bounded local package/install smoke;
  - hold;
  - redirect to docs/non-claims polish;
  - pause.
- If authorizing smoke, define exact:
  - write/output scope;
  - temp artifact policy;
  - version/tagging stance;
  - package/build command matrix;
  - installed executable command shape using `igc compile`;
  - PASS/HOLD/FAIL criteria;
  - no-public-claims policy;
  - closed surfaces.
- Do not run package/install smoke in this card.
- Do not authorize RubyGems publish, public release/demo claims, version edits,
  tags, pushes, signing, or deployment.

Deliver:
- Decision doc in `igniter-lang/docs/tracks/` or `igniter-lang/docs/gates/`
- Compact decision summary
- Exact package/install smoke card boundary or hold reasons
```

Important carry-forward requirement:

```text
Installed-gem smoke must use `igc compile`, not `igniter-lang compile`, unless
package inspection proves a different executable is installed.
```

---

## Closed Surfaces

This decision does not authorize:

- package/install smoke execution;
- public release or demo claims;
- installed-gem/package readiness claim;
- version file edits;
- git tag creation;
- git push;
- gem build as release artifact;
- gem publish;
- signing;
- deployment;
- public API/CLI widening;
- branch/conditional implementation;
- parser, classifier, TypeChecker, SemanticIR, assembler changes;
- compiler/library behavior changes;
- loader/report, `CompilationReport`, `CompilerResult`, or CompatibilityReport
  widening;
- `.igapp`, `.ilk`, manifest, sidecar, artifact hash, or golden migration;
- PROP-036 or PROP-038 mutation;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework docs/release/tag/package/compatibility claims;
- runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache,
  signing, deployment, or demo work.

---

## Compact Receipt

```text
card: S3-R171-C3-A
track: compiler-release-repo-local-rc-marker-acceptance-decision-v0
status: done
decision: accept_repo_local_compiler_rc_marker
marker_target: repo_local_compiler_rc_marker
official_evidence_scope: repo_local_compiler_rc
marker_status: accepted
independent_hash_verified: yes_PASS
release_execution_beyond_marker: closed
public_claims: closed
installed_gem_package_readiness: not_established
package_install_smoke_authorized: no
version_change_authorized: no
current_version_remains: 0.1.0.pre.stage2
git_tag_authorized: no
branch_conditional_if_expr: excluded_from_first_rc
spark_status: excluded_non_authorizing
ruby_ledger_hardening: independent_non_blocking
next_route: compiler-release-package-install-smoke-authorization-review-v0
```
