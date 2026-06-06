# Igniter Lang Repository Split Support-File / Path-Hygiene Decision v0

Card: `S3-R257-C4-A`  
Skill: `IDD Agent Protocol`  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `igniter-lang-repository-split-support-file-path-hygiene-decision-v0`  
Route: `UPDATE`  
Status: `conditional-accept / route-migration-authorization-review-gate-next`  
Date: 2026-06-06

Depends on:

- `S3-R257-C1-D`
- `S3-R257-C2-P1`
- `S3-R257-C3-X`

---

## Decision

Decision:

```text
conditionally accept the R257 support-file/path-hygiene prep as migration-readiness evidence
accept the C2-P1 facts packet as verified blocker evidence
accept the C3-X pressure verdict and required guard wording
open R258 only as a future physical-migration authorization review gate
keep live physical migration, target population, history rewrite, and remote push closed
keep candidate:igniter-archive as archive-quarantine bucket only
keep lab-frontier outside language authority
defer forms import hiding/overriding while split review continues
defer PROP-039 proof-local fixtures behind split/forms sequencing
```

R257 is complete enough to open the next governance gate: a physical-migration
authorization review. It is not complete enough to run migration, populate
target repositories, rewrite history, push remotes, change package/CI/release
surfaces, create an archive repo, or make public/stable claims.

The next route must be worded as a review gate only. Any later execution route
must be explicitly authorized after that review and must name exact commands,
write scopes, rollback posture, target baselines, generated-artifact handling,
and closed surfaces.

---

## Inputs Read

- `igniter-lang/docs/tracks/igniter-lang-repository-split-support-file-path-hygiene-prep-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-support-file-path-hygiene-facts-v0.md`
- `igniter-lang/docs/discussions/igniter-lang-repository-split-support-file-path-hygiene-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round256-status-curation-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-file-map-decision-v0.md`

No migration, history rewrite, target population, remote push, package, CI,
release, archive-repo, or public-claim command was run for this decision.

---

## Acceptance Record

| Topic | Status |
| --- | --- |
| Support-file/path-hygiene prep | Conditional accept as migration-readiness evidence only. |
| C2-P1 facts packet | Accepted as verified blocker evidence. |
| C3-X pressure verdict | Accepted; review-gate wording required. |
| Final bucket disposition status | Planning model accepted; final per-file map must be regenerated in R258. |
| `language-root` status | `igniter-lang/**` remains candidate future language repo root, minus exclude/quarantine/whitelist dispositions. |
| `ruby-framework` status | Root framework docs/code/packages/examples/tests remain outside language authority. |
| `lab-frontier` status | Lab remains frontier evidence only and excluded from initial language split. |
| `archive-quarantine` status | Bucket only; no public archive repo creation. |
| `exclude` / whitelist status | Exclude/quarantine default stands; whitelist remains empty unless R258 accepts explicit artifacts. |
| Support-file status | Not resolved; R258 must decide license, conduct, ignore, task/dependency, CI, and package metadata posture. |
| Generated artifact status | Not migration-ready; default exclude/quarantine, whitelist only by explicit decision. |
| Local path/local file-link hygiene | Still a public migration blocker; rewrite, quarantine, exclude, or explicit non-public disposition required. |
| Target baseline status | Targets remain planning containers; local ahead ignore-file commits are not push authority. |
| Migration-method prerequisite status | Method not selected; R258 must compare methods without live commands. |
| Physical migration status | Closed. |
| Remote push status | Closed. |
| Archive repo creation | Closed. |
| Forms post-R257 status | Deferred if split review continues; carry to `S3-R259-C1-A` or next available. |
| PROP-039 post-R257 status | Deferred behind split/forms; carry to `S3-R260-C1-A` or later. |
| Public/stable/production/release claims | Closed. |
| Performance/certification/portability claims | Closed. |

---

## Decision Summary Matrix

| Area | Decision | Required in R258 review gate |
| --- | --- | --- |
| Support files | Prep accepted, final policy not accepted. | Decide copy/synthesize/rewrite/defer for license, conduct, ignore, tasks, dependencies, CI, package metadata. |
| Path/link hygiene | Risk accepted as known blocker. | Produce rewrite/quarantine/exclude plan for local paths, local file links, monorepo-relative links, and `igniter-lang/` prefixed references. |
| Generated artifacts | Default exclude/quarantine accepted. | Regenerate per-file disposition; whitelist must be explicit or empty. |
| Archive/quarantine | Bucket accepted. | Keep as bucket unless a later route opens archive repo decision. |
| Target baselines | Planning facts accepted. | Decide preserve, replace, push later, or regenerate target ignore-file baselines. |
| History/audit | Preserve audit intent, not all generated artifacts. | Compare copy-first, subtree split, filter-repo, archive/quarantine, and hold. |
| Package/release | Closed. | Review metadata wording only if R258 includes it; do not change package surfaces. |

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R258-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: igniter-lang-repository-split-physical-migration-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R257-C5-S
```

Route type:

```text
future migration authorization review gate / no live migration by default
```

Required R258 boundary:

- allowed write scope:
  - `igniter-lang/docs/tracks/igniter-lang-repository-split-physical-migration-authorization-review-v0.md`
  - optional bounded review artifacts under
    `igniter-lang/docs/tracks/repository-split-physical-migration-authorization-review-v0/`
- read scope:
  - R255-R257 split decision, prep, facts, pressure, and status artifacts;
  - source tracked-file inventory;
  - candidate language-root, framework, lab-frontier, archive-quarantine, and
    exclude surfaces;
  - target repositories as read-only baseline facts;
- required review outputs:
  - regenerated current-index per-file disposition map;
  - final mutually exclusive buckets, with whitelist explicitly empty or
    accepted;
  - support-file decisions;
  - path/link rewrite, quarantine, or exclusion plan;
  - generated-artifact exclude/quarantine/whitelist policy;
  - target baseline decision;
  - migration-method comparison;
  - archive/quarantine bucket stance;
  - explicit closed-surface scan;
  - exact recommendation to authorize, conditionally authorize, hold, or
    redirect a later execution route.

R258 must explicitly state:

```text
R258 is an authorization review gate only.
It does not authorize physical migration, history rewrite, target population,
remote push, package/CI/release changes, archive repo creation, public/stable
claims, framework-to-language authority transfer, or lab canon.
```

If C5-S does not want to continue split authorization review, fallback:

```text
Card: S3-R258-C1-D
Track: igniter-lang-repository-split-additional-file-map-hygiene-prep-v0
Route type: additional prep / facts refresh / no live migration
```

If split work pauses instead:

```text
Card: S3-R258-C1-A
Track: contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
Route type: proof-local technical authorization review
```

Default sequencing if split review continues:

```text
S3-R258: split physical-migration authorization review gate only
S3-R259 or next available: forms import hiding/overriding proof authorization review
S3-R260 or later: PROP-039 proof-local fixture continuation
```

---

## Explicit Answers

### Is support-file/path-hygiene prep accepted?

Yes, conditionally. It is accepted as migration-readiness evidence and blocker
evidence, not as migration execution authority.

### Is it sufficient to open a future migration authorization review?

Yes. It is sufficient to open a future physical-migration authorization review
as a gate only.

### May physical migration open next or must it wait?

Live physical migration must wait. Only the authorization review gate may open
next.

### Does remote push remain closed?

Yes. Remote push remains closed.

### Does archive repo creation remain closed?

Yes. `candidate:igniter-archive` remains an archive-quarantine bucket only.

### May target local baselines be pushed?

No. Target local baselines remain planning facts. R258 must decide their stance;
it must not push them by default.

### Does forms import hiding/overriding open next?

No, not while split review continues. Carry it to `S3-R259-C1-A` or the next
available technical route.

### Do PROP-039 proof fixtures remain deferred?

Yes. Carry PROP-039 proof-local fixtures to `S3-R260-C1-A` or later.

### Are public/stable/production/release/performance/certification/portability claims closed?

Yes. All remain closed.

---

## Compact Decision Summary

```text
CONDITIONAL ACCEPT: R257 support-file/path-hygiene prep evidence.
ACCEPT: C2 facts and C3 pressure blockers.
OPEN NEXT: S3-R258-C1-A physical-migration authorization review gate only.
HOLD: live migration, target population, history rewrite, remote push.
KEEP CLOSED: package/CI/release, archive repo creation, public/stable claims.
KEEP: lab-frontier non-canonical; framework surfaces outside language authority.
DEFER: forms to R259/next available if split continues.
DEFER: PROP-039 to R260 or later.
```
