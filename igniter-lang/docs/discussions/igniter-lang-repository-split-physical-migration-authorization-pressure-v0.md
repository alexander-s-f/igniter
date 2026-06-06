# S3-R258-C3-X External Pressure Verdict

Track: igniter-lang-repository-split-physical-migration-authorization-pressure-v0  
Role: external-pressure-reviewer  
Route: UPDATE  
Date: 2026-06-06  
Depends on: S3-R258-C1-A, S3-R258-C2-P1

## Pressure Verdict

Verdict: CONDITIONAL ACCEPT, with migration execution held.

R258-C1-A does not over-authorize live physical migration. It correctly holds physical migration, target population, history rewrite, remote push, package/CI/release changes, archive repo creation, public claims, framework-to-language authority transfer, and lab canon. R258-C2-P1 reinforces that the current authorization evidence is blocker evidence, not execution authority.

The authorization review should be accepted only as a hold/redirect decision: the next split route should be additional current-index file-map and support-policy prep, not a migration execution authorization route.

## Compact Risk List

- Premature execution authority: controlled by C1-A and C2-P1, but C4-A must not promote the hypothetical future execution route named in C1-A as immediate authority.
- Route-number collision: C1-A briefly names `S3-R259-C1-A` as a candidate later execution authorization route, while its exact recommendation is `S3-R259-C1-D` additional prep. C4-A should retire the execution-route candidate for now and open only the prep route if split continues.
- Support-file decisions: unresolved. License, code of conduct, language `.gitignore`, task/dependency files, CI posture, `.rubocop.yml`, and `igniter_lang.gemspec` metadata still require copy/synthesize/rewrite/defer decisions.
- Path/link hygiene: unresolved public blocker. C2-P1 reports 487 broad hit files, 484 under `igniter-lang/**`, and 132 markdown local absolute path/local file-link candidates.
- Generated artifacts: still default exclude/quarantine. No whitelist artifact is accepted; `.igapp`, `out/**`, logs, JSON summaries, and archive snapshots must not become living source by copy.
- Current-index drift: C1-A snapshot was 5471 total / 3987 under `igniter-lang/**`; C2-P1 refreshed to 5472 / 3988. A regenerated per-file disposition artifact is mandatory before any execution authorization.
- Target baseline risk: all three target repos remain planning containers with local `.gitignore` commits ahead of origin. This is not push authority or baseline selection.
- Archive/quarantine: remains a bucket only. No archive repository creation or population authority.
- Framework-to-language transfer: root Ruby framework files, packages, examples, specs, and support files remain outside language authority unless explicitly accepted later.
- Lab-canon drift: lab remains frontier evidence only and outside the initial language split.
- Package/release overclaim: `igniter_lang.gemspec` remains monorepo-oriented; package metadata review is not package/release authority.
- Public/stable/runtime claims: closed, including production, performance, certification, portability, Reference Runtime, `.igapp`/`.igbin` execution, and public demo claims.

## Pressure Checks

- C1-A over-authorizes live migration: no.
- Later execution route bounded enough: not yet. C1-A states the shape of a possible later route, but C2-P1 proves blockers remain. Do not open execution authorization next.
- Support-file decisions explicit: named but not decided.
- Path/link blockers public blockers: yes, still active.
- Generated artifact disposition safe: safe as default exclude/quarantine, incomplete as final map.
- Target baselines planning facts: yes.
- Archive/quarantine bucket: yes.
- Lab frontier only: yes.
- Framework surfaces outside language authority: yes.
- Package/CI/release/public claims closed: yes.
- Forms/PROP-039 sequencing: clear only if C4-A assigns R259 to split prep; then carry forms to R260 or next available and PROP-039 to R261 or later.

## Exact Recommendation To C4-A

Accept R258-C1-A and R258-C2-P1 as conditional authorization-review and blocker evidence.

Do not authorize:

- physical migration;
- copy/populate target repositories;
- history rewrite;
- `git subtree split`;
- `git filter-repo`;
- remote push;
- target baseline push;
- package, CI, release, version, tag, sign, or deploy changes;
- archive repo creation;
- public/stable/production/performance/certification/portability claims;
- framework-to-language authority transfer;
- lab canon.

Open next only as:

`S3-R259-C1-D igniter-lang-repository-split-current-index-file-map-and-support-policy-prep-v0`

Route type:

```text
additional prep / current-index file-map materialization / support-policy decision prep / no live migration
```

Required C4-A wording:

> R259 is not a migration execution route and not a migration execution authorization route. It may materialize a current-index per-file disposition artifact, support-file policy, path/link disposition plan, generated-artifact whitelist/exclude/quarantine policy, target-baseline decision proposal, and migration-method comparison. It must not copy/populate target repositories, rewrite history, push remotes, change package/CI/release surfaces, create an archive repo, or make public claims.

R259 should require:

- regenerated current-index per-file disposition artifact;
- mutually exclusive buckets: `language-root`, `ruby-framework`, `lab-frontier`, `archive-quarantine`, `exclude`, and explicit whitelist empty-or-accepted;
- support-file copy/synthesize/rewrite/defer policy;
- path/link rewrite, quarantine, exclude, or non-public disposition plan;
- generated-artifact exclude/quarantine/whitelist policy;
- target baseline proposal for all three target repositories;
- migration-method comparison with exact future command boundaries and forbidden commands;
- rollback/audit receipt shape for any later execution route;
- post-prep C4/C5 decision before execution authorization is reconsidered.

Sequencing recommendation:

- R259: split current-index file-map/support-policy prep, no live migration;
- R260 or next available: forms import hiding/overriding proof authorization review if split prep continues;
- R261 or later: PROP-039 proof-local fixture continuation.

If C4-A pauses split work instead of opening R259 prep, route forms next:

`S3-R259-C1-A contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0`
