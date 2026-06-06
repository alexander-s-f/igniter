# Igniter Lang Repository Split Physical-Migration Authorization Review v0

Card: `S3-R258-C1-A`  
Skill: `IDD Agent Protocol`  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `igniter-lang-repository-split-physical-migration-authorization-review-v0`  
Route: `UPDATE`  
Status: `authorization-review / migration-held / facts-refresh-required`  
Date: 2026-06-06

Depends on:

- `S3-R257-C5-S`

---

## Decision Frame

R255 accepted the repository split boundary. R256 accepted a dry-run file-map
proof as split-map evidence. R257 conditionally accepted support-file and
path-hygiene prep as migration-readiness evidence only.

R258 reviews whether a later bounded physical migration execution route may
open. This card does not run migration, authorize migration, populate target
repositories, rewrite history, push remotes, change packages or CI, create an
archive repo, make public claims, transfer Ruby Framework authority into
Igniter Lang, or accept lab behavior as canon.

Repository labels:

```text
source:igniter
target:alexander-s-f/igniter-lang
target:alexander-s-f/igniter-ruby
target:alexander-s-f/igniter-lab
candidate:igniter-archive
```

No `git subtree split`, `git filter-repo`, copy/populate, remote push, package,
CI, release, or archive-creation command was run.

---

## Authorization Review Verdict

Verdict:

```text
do not authorize physical migration now;
do not authorize remote push now;
do not authorize target repository population now;
authorize only R258 facts and pressure review to verify current blockers;
recommend C4-A hold migration execution unless C2/C3 proves the blockers are
fully dispositioned;
default C4-A recommendation: route additional split execution-prep /
current-index file-map materialization before any live migration authorization.
```

The repository split direction remains accepted, and `igniter-lang/**` remains
the candidate future language repo root. The execution route is not ready yet:
support-file policy is unresolved, path/link hygiene remains a public blocker,
generated artifacts still require exclude/quarantine/whitelist disposition, the
target baseline commits are planning facts only, and the current tracked-file
index has moved since R257.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round257-status-curation-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-support-file-path-hygiene-decision-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-support-file-path-hygiene-prep-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-support-file-path-hygiene-facts-v0.md`
- `igniter-lang/docs/discussions/igniter-lang-repository-split-support-file-path-hygiene-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round256-status-curation-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-file-map-decision-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-file-map-proof-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-boundary-decision-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/cards/S3/S3-R258.md`
- source tracked-file inventory;
- source support files;
- target repositories as read-only baseline facts.

---

## Current Index Snapshot

Fresh read-only checks for this authorization review:

| Fact | Current value | Authorization meaning |
| --- | ---: | --- |
| Total tracked files | 5471 | Current-index file map must be regenerated before any execution route. |
| `igniter-lang/**` tracked files | 3987 | Candidate language root remains coherent, but counts moved after R257. |
| `packages/**` tracked files | 833 | Ruby Framework / umbrella package surface remains outside language authority. |
| tracked `playgrounds/**` files | 1 | Lab remains separate frontier; source root tracks only the playground index. |
| `igniter-lang/out/**` tracked files | 386 | Exclude by default. |
| tracked `.igapp` paths under `igniter-lang/**` | 894 | Exclude or archive-quarantine; never living source by copy. |
| tracked JSON files under `igniter-lang/**` | 1412 | Path-based disposition required. |
| `igniter-lang/docs/archive/**` tracked files | 587 | Archive-quarantine by default unless explicitly accepted as public history. |

R257 C2-P1 recorded `5466` total tracked files and `3982` under
`igniter-lang/**`. The R258 snapshot is now `5471` and `3987`. This confirms
that a later execution route must start from a regenerated current-index
per-file disposition artifact.

---

## Support-File Authorization Matrix

| Surface | Current fact | R258 authorization stance |
| --- | --- | --- |
| `LICENSE.txt` | Present at source root, missing under `igniter-lang/`. | Copy or synthesize policy required before population. |
| `CODE_OF_CONDUCT.md` | Present at source root, missing under `igniter-lang/`. | Copy, synthesize, or defer policy required. |
| `.gitignore` | Present at source root, missing under `igniter-lang/`. | Language-specific ignore must be written or target baseline accepted later. |
| `Gemfile`, `Gemfile.lock`, `Rakefile` | Present at source root, missing under `igniter-lang/`. | Framework-owned by default; language task/dependency policy unresolved. |
| `.rubocop.yml` | Present at source root, missing under `igniter-lang/`. | Rewrite/defer decision required if language repo keeps Ruby lint tasks. |
| root `README.md`, `AGENTS.md` | Present at source root. | Framework/cross-project surfaces; do not copy as language authority by default. |
| `igniter-lang/README.md`, `AGENTS.md` | Present. | Candidate language root support surfaces. |
| `igniter-lang/igniter_lang.gemspec` | Present. | Include as source candidate, but package metadata/release authority remains closed. |
| CI files | No accepted language CI migration. | CI remains closed unless a later route opens it. |

Support-file policy is not sufficient for live migration. A later prep route
must explicitly decide copy/synthesize/rewrite/defer for the missing language
root support files.

---

## Path / Link Hygiene Blocker Matrix

| Risk class | Current signal | R258 stance |
| --- | ---: | --- |
| tracked local absolute path or local file-link hits under `igniter-lang/**` | 508 files | Public migration blocker. Rewrite, quarantine, exclude, or explicitly non-public. |
| tracked local absolute path or local file-link hits across source repo | 559 files | Cross-repo split hygiene risk. |
| markdown files under `igniter-lang/**` | 2248 files | Link rewrite needs bounded policy. |
| markdown files under `igniter-lang/**` with `igniter-lang/`, root monorepo paths, or local file-link markers | 1924 files | Too broad for ad hoc rewrite; needs route-owned rewrite/disposition plan. |

Path/link hygiene blockers remain active. They do not block further planning,
but they do block public target population and remote push.

---

## Generated Artifact Disposition Matrix

| Artifact class | Default disposition | Authorization rule |
| --- | --- | --- |
| `igniter-lang/out/**` | `exclude` | Do not migrate as living source. |
| generated `.igapp` | `exclude` or `archive-quarantine` | Never public canon by copy. |
| logs / `out_run` | `exclude` | Local/proof execution output. |
| JSON summaries | path-based | Durable proof source may be whitelisted only by explicit decision. |
| `docs/archive/**` | `archive-quarantine` | Historical value possible; not current authority by default. |
| build/local metadata | `exclude` | No default migration. |
| durable proof scripts/fixtures | `language-root` or explicit whitelist | Only when source-like and path-clean. |

Explicit whitelist status:

```text
empty by default;
not accepted in this card;
must be materialized and accepted by a later C4-A before execution.
```

---

## Target Baseline Decision Matrix

Read-only target facts:

| Target | Current local status | Tracked files | R258 stance |
| --- | --- | --- | --- |
| `target:alexander-s-f/igniter-lang` | `main...origin/main [ahead 1]` | `.gitignore`, `README.md` | Planning container only; no push/population authority. |
| `target:alexander-s-f/igniter-ruby` | `main...origin/main [ahead 1]` | `.gitignore`, `README.md` | Planning container only; no push/population authority. |
| `target:alexander-s-f/igniter-lab` | `main...origin/main [ahead 1]` | `.gitignore`, `README.md` | Planning container only; lab migration separate. |

Target baseline decision:

```text
hold now;
later route must decide preserve, replace, push later, regenerate, or discard
the local .gitignore baseline commits before target population.
```

Remote push remains closed.

---

## Migration-Method Risk Matrix

| Method | R258 status | Conditions before use |
| --- | --- | --- |
| Copy-first | Possible later, not authorized. | Current-index map, support files, exclude/quarantine list, target baseline decision, rollback receipt. |
| Subtree split | Possible later, not authorized. | Path-clean `igniter-lang/**`, generated-output disposition, history/audit policy. |
| Filter-repo | Highest-risk, not authorized. | Temp clone only, exact command plan, rollback plan, no target pollution, explicit approval. |
| Archive/quarantine | Required as disposition, not repo creation. | Archive bucket list and public/private stance. |
| Hold | Current safe default. | Use until blockers are dispositioned. |

Preferred next preparation method:

```text
copy-first dry-run plan from a regenerated current-index file map;
do not run copy-first as accepted migration;
do not run subtree split or filter-repo in R258.
```

---

## Future Execution-Route Conditions

A later execution authorization route may be considered only after C4-A accepts
all of these conditions:

- regenerated current-index per-file disposition artifact;
- mutually exclusive buckets:
  - `language-root`;
  - `ruby-framework`;
  - `lab-frontier`;
  - `archive-quarantine`;
  - `exclude`;
  - explicit whitelist, empty or accepted;
- support-file policy for license, code of conduct, `.gitignore`, task files,
  dependency files, CI posture, README, AGENTS, status, and package metadata;
- path/link rewrite, quarantine, exclude, or non-public disposition plan;
- generated artifact whitelist/exclude/quarantine policy;
- target baseline decision for all three local target repositories;
- exact permitted commands and exact forbidden commands;
- rollback/audit receipt shape;
- post-execution review gate;
- package/CI/release/public-claim non-claims.

Candidate later execution authorization route, only if C4-A chooses to continue
the split lane after blockers are dispositioned:

```text
Card: S3-R259-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: igniter-lang-repository-split-physical-migration-execution-authorization-review-v0
Route type: future execution authorization review / no execution by default
```

However, the current R258 C1-A recommendation is not to open that route
immediately unless C2-P1 and C3-X prove the blockers are already resolved.

---

## Closed Surfaces

Closed in R258:

- physical migration;
- history rewrite;
- `git subtree split`;
- `git filter-repo`;
- copying files into target repositories as accepted migration;
- target repository population;
- remote push;
- target baseline push;
- package rename;
- gemspec/package/CI changes;
- release execution;
- archive repo creation;
- public claims;
- framework-to-language authority transfer;
- lab canon or lab intake;
- runtime/API/CLI/package widening;
- `igc run` widening;
- `.igapp` or `.igbin` execution authority;
- compiler passport emission;
- RuntimeSmoke productization;
- public runtime support;
- Reference Runtime support;
- stable API;
- production readiness;
- Spark integration;
- public demo or public performance claims;
- official/reference status;
- alternative certification;
- portability guarantees.

---

## Explicit Answers

### Is R258 review complete enough to open a later migration execution route?

Not yet. It is complete enough to open R258 C2-P1 facts verification and C3-X
pressure review. A later execution authorization route should remain held until
the current-index file map, support-file policy, path/link disposition,
generated-artifact policy, and target baseline decision are accepted.

### Is physical migration authorized now?

No.

### Is remote push authorized now?

No.

### Is target repository population authorized now?

No.

### Is support-file policy sufficient?

No. License, code of conduct, language `.gitignore`, task/dependency files, CI
posture, and package metadata need explicit disposition.

### Do path/link hygiene blockers remain?

Yes. The current scan still finds tracked local path or local file-link hits
and broad monorepo-link rewrite risk under `igniter-lang/**`.

### Do generated artifacts remain excluded or quarantined by default?

Yes.

### Is an explicit whitelist empty or accepted?

The whitelist is empty by default and not accepted in this card.

### May target local baseline commits be pushed, replaced, preserved, regenerated, or held?

Held now. A later route must choose preserve, replace, push later, regenerate,
or discard for each target baseline.

### Does `candidate:igniter-archive` remain a bucket?

Yes. It remains an archive-quarantine bucket only. Archive repo creation remains
closed.

### Do forms import hiding/overriding remain deferred?

Yes while split authorization review continues. If C4-A pauses split work,
forms may open as the next technical route.

### Do PROP-039 proof-local fixtures remain deferred?

Yes.

---

## Exact C4-A Recommendation

Recommend C4-A:

```text
CONDITIONAL ACCEPT: R258 authorization review as blocker evidence.
ACCEPT: split direction remains valid; igniter-lang/** remains candidate root.
HOLD: physical migration execution authorization.
HOLD: target population and remote push.
REQUIRE: current-index per-file disposition artifact.
REQUIRE: support-file policy and path/link disposition.
REQUIRE: generated-artifact whitelist/exclude/quarantine decision.
REQUIRE: target baseline decision.
OPEN NEXT IF SPLIT CONTINUES:
  S3-R259-C1-D
  igniter-lang-repository-split-current-index-file-map-and-support-policy-prep-v0
  route type: additional prep / file-map materialization / no live migration
FALLBACK IF SPLIT PAUSES:
  S3-R259-C1-A or next available
  contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
KEEP DEFERRED:
  PROP-039 proof-local fixtures to S3-R260 or later.
```

Future execution-route wording, if C4-A later opens it:

```text
future execution authorization review only;
no live migration by default;
no remote push by default;
exact commands, target baseline, rollback, audit receipts, and post-execution
review required before any execution.
```
