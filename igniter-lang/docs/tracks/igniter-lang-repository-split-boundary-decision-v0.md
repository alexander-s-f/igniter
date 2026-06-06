# Igniter Lang Repository Split Boundary Decision v0

Card: `S3-R255-C4-A`  
Skill: `IDD Agent Protocol`  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `igniter-lang-repository-split-boundary-decision-v0`  
Route: `UPDATE`  
Status: `accepted / route-dry-run-file-map-proof-next`  
Date: 2026-06-06

Depends on:

- `S3-R255-C1-D`
- `S3-R255-C2-P1`
- `S3-R255-C3-X`

---

## Decision

Decision:

```text
accept the Igniter Lang repository split boundary as design-ready
accept igniter-lang/** as the candidate future language repository root
keep Ruby Framework docs/examples/packages/code outside language authority
keep playgrounds/igniter-lab/** as frontier evidence only
keep physical migration, history rewrite, and remote push closed
route repository split dry-run / file-map proof next
supersede the earlier post-R255 forms candidate at S3-R256-C1-A
carry forms import hiding/overriding proof to S3-R257-C1-A or next available
carry PROP-039 proof-local fixtures to S3-R258-C1-A or later
```

S3-R255-C1-D and S3-R255-C2-P1 establish a clean enough boundary for the
repository split to move from design into dry-run planning. S3-R255-C3-X
returned `conditional-accept` only because post-R255 route numbering needed an
explicit supersession decision.

This decision accepts the boundary. It does not authorize physical migration,
`git subtree split`, `git filter-repo`, history rewrite, remote push, release,
package rename, gemspec/package/CI changes, public claims, framework-to-language
authority transfer, lab canon, or live implementation.

---

## Inputs Read

- `igniter-lang/docs/tracks/igniter-lang-repository-split-boundary-and-migration-plan-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-current-surface-facts-v0.md`
- `igniter-lang/docs/discussions/igniter-lang-repository-split-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round254-status-curation-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R255.md`
- `igniter-lang/docs/current-status.md`

No migration, package, CI, release, history rewrite, or remote commands were
run for this decision.

---

## Acceptance Record

| Topic | Status |
| --- | --- |
| Repository split boundary | Accepted as design-ready. |
| Future language repo inclusion | `igniter-lang/**` is accepted as candidate future root, pending dry-run file-map proof. |
| Framework repo retention | Root Ruby Framework docs, packages, examples, code, tests, signatures, task files, and gemspec surfaces remain framework-owned. |
| `igniter-lang/**` root status | Candidate root only; physical migration still held. |
| Non-`igniter-lang/**` surfaces | Not language repo content by default; support files require dry-run classification or later docs/package sync. |
| Lab/frontier | `playgrounds/igniter-lab/**` remains frontier evidence only and excluded from the initial language split. |
| Generated/proof artifacts | Require include/exclude/quarantine classification in the dry-run proof. |
| Archive/quarantine class | Accepted as a dry-run classification bucket for stale, generated, historical, or mixed-authority material. |
| Docs/cross-link policy | Language docs move with language root; root/framework docs become cross-links or remain framework authority. |
| Git/history preservation | Requires dry-run proof before any history-preserving or copy-based migration execution. |
| Dry-run split status | Opens next as the only accepted next Main Line route. |
| Physical migration | Closed. |
| Remote push | Closed, including pushes to `alexander-s-f/igniter-lang`. |
| Forms post-R255 status | Sequenced after split dry-run; earlier `S3-R256-C1-A` candidate superseded. |
| PROP-039 post-R255 status | Deferred to `S3-R258-C1-A` or later. |
| Public/stable/production/release claims | Closed. |
| Performance/certification/portability claims | Closed. |

---

## Ownership Decision Matrix

| Surface | Decision |
| --- | --- |
| `igniter-lang/README.md`, `AGENTS.md`, `RELEASE_NOTES.md` | Candidate language repo inclusion. |
| `igniter-lang/igniter_lang.gemspec` | Candidate inclusion, but metadata review held for dry-run/docs/package follow-up. |
| `igniter-lang/bin/**`, `lib/**`, `source/**`, `fixtures/**`, `tests/**` | Candidate language repo inclusion after generated-output scan. |
| `igniter-lang/docs/spec/**`, `docs/proposals/**`, `docs/cards/**`, `docs/tracks/**`, `docs/gates/**`, `docs/discussions/**` | Candidate inclusion as language governance/history surfaces. |
| `igniter-lang/docs/archive/**`, `docs/reports/**`, `docs/reviews/**`, `experiments/**` | Candidate inclusion, but dry-run must classify archive/generated/proof-output weight. |
| `igniter-lang/out/**`, logs, local build products, generated `.igapp` outputs | Exclude or quarantine unless dry-run proves durable authority. |
| Root `README.md`, `AGENTS.md`, `docs/**`, `examples/**`, `lib/**`, `spec/**`, `sig/**` | Framework repo retention, with cross-links if needed. |
| `packages/**`, root `Gemfile`, `Rakefile`, `igniter.gemspec` | Ruby Framework / umbrella package repo retention. |
| `playgrounds/igniter-lab/**` | Frontier repo/lab intake candidate only; not initial language split content. |
| Root support files such as `LICENSE.txt`, `CODE_OF_CONDUCT.md`, `.gitignore` | Dry-run must classify copy, rewrite, synthesize, or exclude. |

---

## Migration Risk And Dry-Run Prerequisites

| Risk / prerequisite | Required next evidence |
| --- | --- |
| History or audit loss | Dry-run tracked-file map and migration-method recommendation. |
| Ruby Framework authority leakage | Explicit file-map classification into language, ruby framework, lab/frontier, archive/quarantine, or exclude. |
| Lab canon drift | Confirm `playgrounds/igniter-lab/**` stays excluded from initial split unless later intake authorizes a subset. |
| Generated artifact drift | Enumerate `out/**`, `.igapp`, logs, summaries, archives, local artifacts, and classify include/exclude/quarantine. |
| Broken links after `igniter-lang/` becomes root | Link scan and rewrite/cross-link report. |
| Package metadata drift | Inventory `igniter_lang.gemspec`, README, release notes, and package URL references; do not edit yet unless later authorized. |
| Support-file gap | Decide dry-run handling for license, code of conduct, `.gitignore`, task files, and CI. |
| Route-number collision | C5-S must record that old `S3-R256-C1-A` forms candidate is superseded for sequencing. |

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R256-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: igniter-lang-repository-split-dry-run-file-map-proof-v0
Route: UPDATE
Depends on:
- S3-R255-C5-S
```

Route type:

```text
dry-run proof / file-map proof / no live migration
```

Expected allowed write scope:

- `igniter-lang/docs/tracks/igniter-lang-repository-split-dry-run-file-map-proof-v0.md`
- proof-local generated file-map outputs under a bounded docs/track or temporary
  proof output location if C1-D authorizes them

Expected read scope:

- current source repository checkout, referred to as `source:igniter/**`
- target local repositories as read-only destination facts, referred to by
  public repository labels:
  - `target:alexander-s-f/igniter-lang`
  - `target:alexander-s-f/igniter-ruby`
  - `target:alexander-s-f/igniter-lab`

Expected file-map buckets:

- `language-root`: future `igniter-lang` repo candidate content;
- `ruby-framework`: future `igniter-ruby` repo or current framework retention;
- `lab-frontier`: future `igniter-lab` candidate content, not canon;
- `archive-quarantine`: historical/stale/mixed/generated material;
- `exclude`: local/editor/build/release artifacts.

Closed in R256 unless a later card explicitly changes it:

- live migration;
- `git subtree split`;
- `git filter-repo`;
- history rewrite;
- copying into target repos as accepted migration;
- remote push;
- package rename;
- gemspec/package/CI changes;
- release execution;
- public claims;
- framework-to-language authority transfer;
- lab canon.

---

## Post-R255 Route Sequencing

The earlier R254 status curation named:

```text
S3-R256-C1-A
contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
```

as a post-R255 forms candidate. This R255 decision supersedes that route number
for sequencing only. The route remains valid, but it moves after split dry-run:

```text
S3-R257-C1-A
contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
```

or the next available route if C5-S assigns another number.

PROP-039 proof-local fixtures remain deferred:

```text
S3-R258-C1-A or later
experimental-managed-local-recursion-proof-fixture-authorization-review-v0
```

---

## Explicit Answers

### Is the repository split boundary accepted?

Yes. It is accepted as design-ready and migration-held.

### May `igniter-lang/**` be treated as the candidate future repo root?

Yes. `igniter-lang/**` is the candidate future root for the language repo,
pending dry-run file-map proof.

### May physical migration open next?

No. Physical migration must wait for dry-run proof and a later explicit
migration authorization review.

### Should dry-run split planning/proof open next?

Yes. The exact next route should be `S3-R256-C1-D`
`igniter-lang-repository-split-dry-run-file-map-proof-v0`.

### Does remote push to `alexander-s-f/igniter-lang` remain closed?

Yes. Remote push remains closed.

### Do Ruby Framework docs/examples/packages remain outside language authority?

Yes. They remain framework-owned unless a later route authorizes a specific
cross-link or rewrite.

### Do lab artifacts remain frontier evidence only?

Yes. Lab artifacts remain frontier evidence only and do not become canon through
the repository split boundary.

### Does forms import hiding/overriding open next?

No. It remains valid but is sequenced after split dry-run. The prior
`S3-R256-C1-A` forms candidate is superseded for numbering and carried to
`S3-R257-C1-A` or the next available route.

### Do PROP-039 proof fixtures remain deferred?

Yes. They remain deferred to `S3-R258-C1-A` or later.

### Do public/stable/production/release/performance/certification/portability claims remain closed?

Yes. They remain closed, together with public runtime, Reference Runtime,
official/reference status, alternative certification, package/release, and
lab-canon claims.

---

## Compact Decision Summary

```text
ACCEPT: repository split boundary
ROOT: igniter-lang/** is candidate future language repo root
HOLD: physical migration, history rewrite, remote push, package/CI/release
KEEP: Ruby Framework surfaces outside language authority
KEEP: lab/frontier evidence outside initial language split
OPEN NEXT: S3-R256-C1-D repository split dry-run / file-map proof
SUPERSEDE: old S3-R256-C1-A forms route number
CARRY: forms import hiding/overriding to S3-R257-C1-A or next available
CARRY: PROP-039 proof fixtures to S3-R258-C1-A or later
CLOSED: public/stable/production/release/performance/certification/portability claims
```
