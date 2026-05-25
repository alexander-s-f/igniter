# Compiler Release Next Vector Options v0

Card: S3-R174-C2-P1  
Agent: `[Compiler Release Vector Analyst]`  
Role: `release-readiness-agent`  
Track: `compiler-release-next-vector-options-v0`  
Route: UPDATE  
Status: done  
Date: 2026-05-25

---

## Purpose

Prepare the next release-vector options after accepted local package/install
smoke readiness, without authorizing execution, smoke reruns, public claims, or
implementation.

Current accepted state:

```text
local package/install smoke readiness: accepted for bounded local scope
package: igniter_lang
version: 0.1.0.pre.stage2
run_id: S3R173C1I_20260525T063543Z
installed command: igc compile
positive corpus: 5/5 PASS
refusal corpus: 3/3 PASS
public release/demo claims: closed
release execution: closed
version/tag/push/publish/sign/deploy: closed
profile-source smoke: deferred
branch_conditional_if_expr: excluded
```

This track is options analysis only.

---

## Evidence Read

- `compiler-release-package-install-smoke-acceptance-decision-v0.md`
- `stage3-round173-status-curation-v0.md`
- `compiler-release-readiness-package-acceptance-decision-v0.md`
- `compiler-release-execution-authorization-review-v0.md`
- `compiler-release-evidence-hash-docs-and-package-smoke-policy-v0.md`
- `compiler-release-readiness-summary-package-v0.md`
- `compiler-release-installed-gem-readiness-marker-v0.md` as current local
  marker context

---

## Option Table

| Option | Expected value | Required boundary | Blockers | Risks | Recommended sequencing |
| --- | --- | --- | --- | --- | --- |
| A. Public release/docs non-claims planning | Prepares public-facing wording without claiming release/demo readiness; converts non-claims into reviewed docs templates | Docs/design only; no publish, no tag, no version edit, no public announcement | Needs clear target type: public docs template vs actual public docs; must avoid implied availability | Premature wording can be mistaken for public claim; branch/conditional exclusion can be softened accidentally | Do after profile-source smoke decision or as a strictly non-public docs planning card |
| B. Profile-source smoke extension authorization review | Extends package/install confidence into the deferred profile-source lane before any public planning | Authorization review first; define corpus, pass/fail/hold, installed `igc` command scope; no execution in review | Need exact fixture/corpus source; must preserve PROP-036/PROP-038 non-mutation and no public API/CLI widening | Touches compiler-profile surface; could accidentally imply broader installed-gem readiness if not bounded | Best next route if release lane continues |
| C. Release execution authorization hold | Keeps all execution closed while preserving accepted readiness marker | Status/decision only; no new commands | None; this is a conservative hold | Momentum stalls; readiness evidence may go stale if feature lane moves | Use if Portfolio/user does not want release-vector movement now |
| D. Additional package/install smoke hygiene | Fixes evidence labeling/polish such as NB-1 `refusal_kind` mismatch in future smoke summaries | Design or proof-local smoke hygiene route; no release execution; no compiler semantics change unless separately authorized | Need decide whether hygiene is docs-only, runner-only, or rerun smoke; current accepted PASS must not be invalidated | Over-focusing on non-blocking notes can delay higher-value decision; rerun could create new evidence to adjudicate | Useful after C4-A if selected as low-risk cleanup; not required before next route |
| E. Return to compiler/language feature lane | Stops release vector and returns capacity to language/compiler work | Explicit redirect/hold decision; release claims remain closed | Need avoid interpreting package readiness as release launch | Accepted package evidence can become stale if code changes significantly | Good if product goal is more language substance before public motion |
| F. Pause | No next release card | Explicit pause receipt; no writes beyond status if needed | None | Context drift; future agents may reopen without remembering closures | Acceptable if user wants no release/readiness activity |

---

## Recommended Route

Recommended next route:

```text
profile-source smoke extension authorization review
```

Rationale:

- Package/install readiness is now accepted for the installed `igc compile`
  path, but profile-source smoke remains explicitly deferred.
- Public release/docs planning is safer after deciding whether profile-source
  behavior belongs in the next release-readiness story.
- This route can be design/authorization-only and does not require smoke
  execution in the next card.
- It preserves all current closures while reducing the largest obvious gap
  between package readiness and public-facing planning.

Recommended C4-A stance:

```text
conditional accept: open profile-source smoke extension authorization review next
```

Conditions:

- Do not authorize execution in C4-A unless a separate implementation/smoke card
  is explicitly dispatched.
- Keep public release/demo claims closed.
- Keep version/tag/push/publish/sign/deploy closed.
- Keep branch/conditional `if_expr` excluded.
- Carry NB-1 as smoke hygiene, not a blocker.

Backup route:

```text
public release/docs non-claims planning, docs/design only
```

Use the backup only if Portfolio wants wording preparation before extending
profile-source smoke. The backup must be explicitly non-public and non-claiming.

---

## Explicit Answers

May public release/demo claims open now?

```text
No. Public release/demo claims remain closed. Accepted local package/install
smoke readiness is not public release readiness, RubyGems availability,
production readiness, or public demo readiness.
```

May release execution open now?

```text
No. Release execution remains closed. R170 authorized only a bounded repo-local
marker path, and R173/R174 readiness recognition does not authorize version
edit, tag, push, publish, signing, deployment, or public release action.
```

Should profile-source smoke precede public release planning?

```text
Yes, if the release vector continues. Profile-source smoke remains the most
obvious deferred package/install confidence gap. It should at least receive an
authorization review before public release/docs planning is treated as the
primary next route.
```

Must NB-1 refusal kind hygiene block the next route?

```text
No. NB-1 is accepted as future smoke hygiene, not a blocker. PKG-5 passed
because the installed CLI returned non-zero, produced no `.igapp`, and observed
refusal for the negative corpus. Future smoke summaries should classify
`type_mismatch.ig` and `unresolved_symbol.ig` as `oof`.
```

Is package/install readiness enough to move toward public docs?

```text
Enough for non-public docs planning only, not for public docs publication or
public claims. Any public-facing wording still needs a target-specific docs
and non-claims review, including branch/conditional exclusion and explicit
availability limits.
```

Does branch/conditional `if_expr` remain excluded?

```text
Yes. `branch_conditional_if_expr` remains excluded from the first RC/release
readiness scope and remains a post-RC language/compiler design lane.
```

---

## Candidate Next Card

Recommended next card shape:

```text
Card: S3-R174-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-next-vector-decision-v0
Route: UPDATE

Goal:
Decide the next release vector after accepted local package/install smoke
readiness.

Recommended decision:
Open profile-source smoke extension authorization review next, without running
smoke or authorizing release execution.

Scope:
- Read this options track.
- Read C3 pressure review if present.
- Decide next route:
  - profile-source smoke extension authorization review;
  - public release/docs non-claims planning;
  - additional smoke hygiene;
  - release execution hold;
  - return to compiler/language feature lane;
  - pause.
- Preserve public release/demo claims closed.
- Preserve release execution closed.
- Preserve version/tag/push/publish/sign/deploy closed.
- Preserve branch/conditional `if_expr` exclusion.

Deliver:
- Decision track/gate doc.
- Exact next dispatch or hold reason.
```

---

## Closed Surfaces

This options track does not authorize:

- public release or demo claims;
- release execution;
- version file edits;
- gemspec edits;
- git tag creation;
- git push;
- RubyGems publish;
- signing;
- deployment;
- package/install smoke rerun;
- profile-source smoke execution;
- public API/CLI widening;
- branch/conditional implementation;
- parser, classifier, TypeChecker, SemanticIR, assembler, or compiler/library
  behavior changes;
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
card: S3-R174-C2-P1
track: compiler-release-next-vector-options-v0
status: done
analysis_only: yes
smoke_run: no
code_changed: no
release_execution_authorized: no
public_claims_authorized: no
recommended_next_route: profile_source_smoke_extension_authorization_review
backup_route: public_release_docs_non_claims_planning_design_only
NB_1_refusal_kind_hygiene_blocks_next_route: no
package_install_readiness_sufficient_for_public_claims: no
package_install_readiness_sufficient_for_non_public_docs_planning: yes
branch_conditional_if_expr: excluded
C4_A_stance: conditional_accept_open_profile_source_smoke_authorization_review
```
