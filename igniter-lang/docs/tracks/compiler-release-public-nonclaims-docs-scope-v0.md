# Compiler Release Public Nonclaims Docs Scope v0

Card: S3-R178-C1-P1  
Agent: [Research Agent]  
Role: research-agent  
Track: compiler-release-public-nonclaims-docs-scope-v0  
Route: UPDATE  
Status: done  
Date: 2026-05-25

Depends on:
- S3-R177-C3-A

Affected neighbors:
- Bridge Agent: future public wording, release-note placement, and non-claim
  preservation.
- Compiler/Grammar Expert: feature-surface wording, especially grammar and
  `if_expr` exclusions.
- Research Agent: release evidence indexing and future docs-polish pressure.

---

## Current Horizon

The accepted evidence supports a repo-local compiler RC and bounded local
installed-package smoke. The installed `igc` profile-source smoke passed for one
valid finalized profile-source case plus malformed-JSON and wrong-kind refusals.
This is evidence/readiness only, not release execution or public release claims.
RubyGems publish, public demo claims, production runtime claims, Spark, and
branch/conditional `if_expr` remain closed.

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-profile-source-installed-readiness-marker-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/stage3-round177-status-curation-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-summary-package-v0.md`
- `igniter-lang/docs/tracks/official-first-rc-evidence-acceptance-and-next-release-vector-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-repo-local-rc-marker-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-package-install-smoke-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-profile-source-install-smoke-acceptance-decision-v0.md`

---

## Safe Wording Proposal

This wording is a proposal for a later docs/release-claims authorization route.
It is not currently authorized as public release copy.

Short form:

```text
Igniter-Lang compiler RC evidence is ready for local review. The current local
igniter_lang package builds and installs in an isolated environment, loads
without repo-relative -I, and the installed igc CLI compiles the accepted
positive corpus, refuses the accepted negative corpus, and preserves the
accepted --compiler-profile-source PATH.json transport for one finalized
profile-source success case plus malformed-JSON and wrong-kind refusals.

This is local evidence/readiness only. It is not a RubyGems release, not a
production runtime claim, and not a public demo claim.
```

Evidence-specific wording:

```text
Repo-local compiler RC evidence: PASS.
Local package install smoke: PASS.
Bounded installed profile-source smoke: PASS.
Release execution and public release/demo claims remain closed.
```

Longer release-note candidate:

```text
The current Igniter-Lang compiler RC has accepted local evidence for the
repo-local CLI/API compile path, isolated package build/install/load, and the
installed igc CLI's explicit --compiler-profile-source PATH.json transport.
The bounded smoke covers accepted positive and negative compiler corpus behavior
plus one finalized profile-source success, one malformed JSON preflight refusal,
and one semantic wrong-kind refusal.

This evidence does not publish the package, authorize release execution, widen
the public API/CLI, or claim production runtime readiness. Branch/conditional
if_expr, profile discovery/defaulting/finalization, Spark integration, and
RubyGems availability remain outside this scope.
```

---

## Required Non-Claims

| Claim surface | Required status / wording | Reason |
| --- | --- | --- |
| Release execution | Closed until explicit authorization. | R169/R177 accept evidence only. |
| Public release claims | Closed until explicit authorization. | Current cards are markers and smoke evidence, not release copy. |
| Public demo claims | Closed. | No demo authorization or demo evidence was accepted. |
| RubyGems availability | No claim. | Package was built/installed locally only. |
| RubyGems publish | Closed. | No publish route is authorized. |
| Version/tag/push/sign/deploy | Closed. | No release operation is authorized by the evidence. |
| Production readiness | No claim. | Proofs are bounded local compiler/package smoke. |
| RuntimeMachine production execution | No claim. | Runtime smoke remains proof/local where present. |
| Public API/CLI widening | No claim beyond accepted current surfaces. | Only existing `--compiler-profile-source PATH.json` transport is evidenced. |
| Profile finalization | Closed. | Smoke uses an already-finalized artifact; it does not finalize profiles. |
| Profile discovery/defaulting | Closed. | Explicit path transport only. |
| Named/generated profile lookup | Closed. | Not covered by smoke evidence. |
| Inline JSON profile source | Closed. | R45/R54 route selected explicit path, not inline JSON. |
| Env/config/sidecar profile lookup | Closed. | Explicit path only. |
| Loader/report or CompatibilityReport readiness | No claim. | Not part of accepted release smoke scope. |
| Branch/conditional `if_expr` | Excluded. | First RC explicitly excludes branch/conditional support. |
| All grammar support | No claim. | Accepted corpus is bounded. |
| Spark integration | Out of scope. | No Spark code/data/production surface is authorized. |
| Ruby Framework compatibility | No claim. | Earlier readiness packages explicitly keep this closed. |

---

## Excluded Feature Table

| Feature / surface | Public-docs treatment | Safe alternative |
| --- | --- | --- |
| Branch/conditional `if_expr` | Must be explicitly excluded. | "Branch/conditional `if_expr` remains post-RC." |
| Full grammar support | Must not be claimed. | "Accepted positive/negative corpus." |
| Profile finalization/discovery/defaulting | Must not be claimed. | "Explicit `--compiler-profile-source PATH.json` with already-finalized source." |
| Inline JSON profile source | Must not be claimed. | "Path-based JSON transport only." |
| Named/generated profile lookup | Must not be claimed. | "No discovery/defaulting." |
| RubyGems publish | Must not be claimed. | "Local isolated gem install smoke." |
| Public release | Must not be claimed. | "Release evidence accepted / ready for review." |
| Public demo | Must not be claimed. | "No demo claim." |
| Runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache production behavior | Must not be claimed. | "Compiler/package smoke only." |
| Loader/report or CompatibilityReport readiness | Must not be claimed. | "No loader/report readiness claim." |
| Spark integration or Spark readiness | Must not be claimed. | "Spark out of scope." |
| Ruby Framework compatibility | Must not be claimed. | "Igniter-Lang compiler evidence only." |

---

## Phrase Shapes To Avoid

Avoid these phrases unless a later authorization explicitly changes the scope:

- "Igniter-Lang is released."
- "Igniter-Lang is available on RubyGems."
- "The compiler/package is production ready."
- "Public demo ready."
- "Release ready" without "local evidence" or "review" qualifier.
- "Supports all grammar."
- "Supports branch/conditional `if_expr`."
- "Profile discovery/defaulting/finalization is supported."
- "Compiler profile lookup is automatic."
- "Runtime ready" or "CompatibilityReport ready."
- "Spark integrated."
- "Ruby Framework compatible."
- "Published package" or "install from RubyGems."

Preferred phrase shapes:

- "repo-local compiler RC evidence"
- "local package install smoke"
- "bounded installed profile-source smoke"
- "accepted local evidence"
- "ready for release-authorization review"
- "not a release, publish, production, or demo claim"

---

## Release-Scope Label Candidates

Recommended labels:

- `repo_local_compiler_rc_evidence`
- `local_package_install_smoke_readiness`
- `bounded_profile_source_installed_smoke_readiness`
- `local_compiler_rc_readiness_evidence`

Avoid labels:

- `public_release_ready`
- `rubygems_ready`
- `production_ready`
- `demo_ready`
- `full_compiler_support`
- `spark_ready`

---

## Later Docs Polish Boundary

Recommended next docs route:

```text
compiler-release-public-nonclaims-docs-polish-v0
```

Suggested allowed work for that later route, only if explicitly authorized:

- draft a public-facing release-note paragraph from this boundary packet;
- add a visible non-claims block near the wording;
- scan the target docs for forbidden phrase shapes before and after edits;
- preserve exact labels for repo-local RC evidence, local package install smoke,
  and bounded profile-source installed smoke;
- keep release execution, RubyGems publish, tags, signing, deployment, public
  demo claims, production runtime claims, Spark, and `if_expr` closed.

Recommended placement order:

1. Start with another track doc or release-note draft for pressure review.
2. Only then consider public docs such as README or user-facing release notes.
3. Keep README changes out of scope until a separate docs-publication card opens.

---

## Recommendation

Recommendation:

```text
accept public non-claims boundary as a planning packet;
do not publish or place public wording yet;
open a later docs-polish card only after release-claims authorization is clear.
```

The safest next step is a docs-polish route that treats this file as the source
of constraints, not as public release copy.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/compiler-release-public-nonclaims-docs-scope-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Drafted safe wording as future-authorized wording only, not current public copy.
- Preserved release execution, public release/demo claims, RubyGems publish,
  version/tag/push/sign/deploy, profile discovery/defaulting/finalization,
  branch/conditional if_expr, Spark, and production runtime surfaces as closed.
- Classified accepted evidence as repo-local RC evidence plus local package
  install/profile-source installed smoke readiness.

[R] Recommendations:
- Use `local_compiler_rc_readiness_evidence` or the narrower accepted marker
  labels in later docs.
- Open a separate docs-polish route before editing README or user-facing docs.
- Keep a visible non-claims block adjacent to any future public wording.

[S] Signals:
- R177 accepts bounded profile-source installed smoke readiness.
- R169/R173/R176 keep release execution and public claims closed.
- Profile-source smoke proves explicit path transport only, not discovery or
  finalization.

[T] Tests / Proofs:
- Documentation-only card; no executable proof required.

[Files] Changed:
- igniter-lang/docs/tracks/compiler-release-public-nonclaims-docs-scope-v0.md

[Q] Open Questions:
- Which later public-docs location should receive wording first, if any:
  release-note draft, README, or a dedicated docs/release page?

[X] Rejected:
- No README/public docs edits.
- No release execution.
- No RubyGems publish.
- No public demo/production/Spark/runtime claim.

[Next] Proposed next slice:
- compiler-release-public-nonclaims-docs-polish-v0, gated on explicit docs/public
  wording authorization.
```
