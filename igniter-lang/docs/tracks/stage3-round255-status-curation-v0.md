# Stage 3 Round 255 Status Curation v0

Card: `S3-R255-C5-S`
Track: `stage3-round255-status-curation-v0`
Role: `status-curator`
Route: `SUMMARY`
Status: `done / accepted`
Date: 2026-06-06

## Summary

R255 accepted the Igniter Lang repository split boundary as design-ready and
migration-held. `igniter-lang/**` is accepted as the candidate future language
repository root, pending dry-run file-map proof. Root Ruby Framework surfaces
remain framework-owned. `playgrounds/igniter-lab/**` remains frontier evidence
only and is excluded from the initial language split unless a later bounded
intake route authorizes a subset.

The exact next Main Line dispatch is `S3-R256-C1-D`
`igniter-lang-repository-split-dry-run-file-map-proof-v0`.

R255 supersedes the earlier R254 post-R255 forms candidate at `S3-R256-C1-A`
for sequencing only. Forms import hiding/overriding proof is carried to
`S3-R257-C1-A` or next available. PROP-039 proof-local fixtures are carried to
`S3-R258-C1-A` or later.

No physical migration, history rewrite, remote push, package/CI/release change,
implementation, runtime, public claim, framework-to-language authority
transfer, or lab canon opens in R255.

## Outcome Table

| Card | Artifact | Status | Notes |
| --- | --- | --- | --- |
| S3-R255-C1-D | `igniter-lang-repository-split-boundary-and-migration-plan-v0.md` | design-ready / migration-held | Defines language/framework/lab ownership and recommends dry-run file-map proof. |
| S3-R255-C2-P1 | `igniter-lang-repository-split-current-surface-facts-v0.md` | facts-only / no migration authority | Inventories split surfaces and blockers; no migration or package authority. |
| S3-R255-C3-X | `igniter-lang-repository-split-boundary-pressure-v0.md` | conditional accept | Requires explicit supersession of earlier post-R255 forms `S3-R256-C1-A`. |
| S3-R255-C4-A | `igniter-lang-repository-split-boundary-decision-v0.md` | accepted / route-dry-run-file-map-proof-next | Accepts boundary, assigns R256 split dry-run, carries forms to R257 and PROP-039 to R258+. |
| S3-R255-C5-S | this track | done | Current status updated with compact route delta. |

## Repository Split Boundary Status

| Surface | Status |
| --- | --- |
| Boundary | Accepted as design-ready. |
| Candidate language root | `igniter-lang/**`, pending dry-run file-map proof. |
| Physical migration | Closed. |
| History rewrite / `git subtree split` / `git filter-repo` | Closed. |
| Remote push | Closed, including push to `alexander-s-f/igniter-lang`. |
| Package / CI / release changes | Closed. |
| Public claims | Closed. |

## Language / Framework Ownership Summary

| Surface | Status |
| --- | --- |
| `igniter-lang/README.md`, `AGENTS.md`, `RELEASE_NOTES.md` | Candidate language repo inclusion. |
| `igniter-lang/igniter_lang.gemspec` | Candidate inclusion; metadata review held for dry-run/docs/package follow-up. |
| `igniter-lang/bin/**`, `lib/**`, `source/**`, `fixtures/**`, `tests/**` | Candidate language repo inclusion after generated-output scan. |
| `igniter-lang/docs/spec/**`, `docs/proposals/**`, `docs/cards/**`, `docs/tracks/**`, `docs/gates/**`, `docs/discussions/**` | Candidate language governance/history inclusion. |
| `igniter-lang/docs/archive/**`, `docs/reports/**`, `docs/reviews/**`, `experiments/**` | Candidate inclusion, but dry-run must classify archive/generated/proof-output weight. |
| `igniter-lang/out/**`, logs, local build products, generated `.igapp` outputs | Exclude or quarantine unless dry-run proves durable authority. |
| Root `README.md`, `AGENTS.md`, root `docs/**`, `examples/**`, `lib/**`, `spec/**`, `sig/**` | Ruby Framework retention / cross-link context only. |
| `packages/**`, root `Gemfile`, `Rakefile`, `igniter.gemspec` | Ruby Framework / umbrella package retention. |

## Lab / Frontier Stance

`playgrounds/igniter-lab/**` remains frontier evidence only. It is not initial
language split content and does not become canon through R255. Any later lab
component migration requires a bounded intake route that classifies authority,
package shape, proof matrix, and closed surfaces.

## Dry-Run / Migration Status

| Surface | Status |
| --- | --- |
| Repository split dry-run / file-map proof | Opens next as `S3-R256-C1-D`. |
| Live migration | Closed. |
| Copying into target repos as accepted migration | Closed. |
| History rewrite / remote push | Closed. |
| Support-file plan | Required by dry-run: license, code of conduct, `.gitignore`, task files, CI, package metadata. |
| Generated artifact policy | Required by dry-run: `out/**`, `.igapp`, JSON summaries, logs, archive, experiment outputs. |
| Link rewrite / cross-link report | Required by dry-run. |

## Exact Next Dispatch

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

## Deferred Technical Lane Sequencing

R255 supersedes the earlier R254 post-R255 forms candidate at:

```text
S3-R256-C1-A
contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
```

for sequencing only.

Carry forms import hiding/overriding proof to:

```text
S3-R257-C1-A
contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
```

or next available.

Carry PROP-039 proof-local fixtures to:

```text
S3-R258-C1-A or later
experimental-managed-local-recursion-proof-fixture-authorization-review-v0
```

## Closed Surfaces

Closed:

- code edits and live implementation;
- proposal/spec/source mutation;
- repository migration;
- `git subtree split`, `git filter-repo`, history rewrite;
- remote creation or push;
- package rename, package metadata change, CI migration, release execution;
- public claims;
- framework-to-language authority transfer;
- lab canon or lab intake;
- runtime / API / CLI / package widening;
- public runtime support;
- Reference Runtime support;
- stable API;
- production readiness;
- Spark integration;
- public demo or public performance claims;
- official/reference status;
- alternative certification;
- portability guarantees.
