# Igniter Lang Repository Split Boundary Pressure v0

Card: `S3-R255-C3-X`  
Skill: IDD Agent Protocol  
Agent: External Pressure Reviewer  
Role: external-pressure-reviewer  
Track: `igniter-lang-repository-split-boundary-pressure-v0`  
Route: UPDATE  
Status: done / conditional-accept  
Date: 2026-06-06

Depends on:
- `S3-R255-C1-D`
- `S3-R255-C2-P1`

## Pressure Verdict

CONDITIONAL ACCEPT with exact follow-up.

The repository split boundary is design-ready. C1-D and C2-P1 keep
`igniter-lang/**` as the candidate language repo root, keep Ruby Framework
packages/docs/examples outside language authority, keep `playgrounds/igniter-lab/**`
as frontier evidence, and keep physical migration, remote push, package/CI,
release, public, stable, and lab-canon authority closed.

The condition is route/status hygiene: C4-A and C5-S must explicitly supersede
the earlier post-R255 `S3-R256-C1-A` forms candidate if they choose
`S3-R256-C1-D` for the repository split dry-run. Do not leave two active
different `S3-R256` meanings in current-status.

## Inputs Reviewed

- `igniter-lang/docs/tracks/igniter-lang-repository-split-boundary-and-migration-plan-v0.md`
- `igniter-lang/docs/tracks/igniter-lang-repository-split-current-surface-facts-v0.md`
- `igniter-lang/docs/tracks/stage3-round254-status-curation-v0.md`
- `igniter-lang/docs/cards/S3/S3-R255.md`
- `igniter-lang/docs/current-status.md`

## Pressure Checks

| Check | Verdict | Notes |
| --- | --- | --- |
| Language/framework ownership | PASS | `igniter-lang/**` is candidate language root; root `lib/**`, `packages/**`, root docs, examples, specs, sigs, and framework gem surfaces remain framework-owned. |
| Ruby Framework term leakage | PASS | Framework references are classified as framework or cross-link context, not language authority transfer. |
| Stranded language artifacts | PASS | Core language docs, specs, proposals, cards, tracks, gates, discussions, compiler package, source, fixtures, and tests are candidate inclusion surfaces. Reports/archive/experiments need dry-run classification, not immediate exclusion. |
| Lab/frontier classification | PASS | `playgrounds/igniter-lab/**` remains frontier evidence and nested/private lab surface; no automatic language canon migration. |
| Git/history/audit preservation | PASS | History preservation is recognized as high risk and gated on dry-run/file-map proof before subtree/filter-repo or remote push. |
| Physical migration over-authorization | PASS | Migration commands, history rewrite, remote push, CI/package/release changes, and public repo push remain closed. |
| Public/stable/package claims | PASS | No stable API, public runtime, Reference Runtime, production, release, performance, certification, portability, package rename, or gem release authority opens. |
| Generated artifact policy | PASS with follow-up | Generated outputs, logs, `.igapp`, summaries, archives, and `out/**` are flagged for include/exclude/quarantine classification in dry-run. |
| Route sequencing | CONDITIONAL PASS | C1-D recommends `S3-R256-C1-D` split dry-run, while R254 carried forms import hiding/overriding as `S3-R256-C1-A`. C4-A/C5-S must explicitly renumber/supersede to avoid collision. |

## Compact Risk List

1. Route collision risk: medium unless C4-A assigns `S3-R256-C1-D` to split
   dry-run and carries forms to `S3-R257-C1-A` or next available, explicitly
   superseding the R254 `S3-R256-C1-A` forms candidate.
2. History loss risk: high if migration executes without dry-run. Current
   boundary correctly holds migration and requires file-map/history proof first.
3. Support-file drift: medium. License, code of conduct, `.gitignore`, task
   files, CI, and gemspec metadata require explicit split classification before
   migration.
4. Generated artifact drift: medium. `out/**`, `.igapp`, JSON summaries, logs,
   archives, experiments outputs, and example outputs need include/exclude/
   quarantine reasons before any split.
5. Lab-canon drift: high if lab is moved wholesale. Current boundary correctly
   excludes lab from initial split and requires later bounded intake.
6. Public/package claim drift: low if C4-A repeats that package rename, CI,
   release, remote push, public repo claims, stable API, and runtime/public
   claims remain closed.

## Exact Recommendation To C4-A

Accept the boundary with this exact decision shape:

```text
ACCEPT the Igniter Lang repository split boundary as design-ready.
ACCEPT `igniter-lang/**` as the candidate future language repo root, subject to
dry-run file-map proof.
ACCEPT root Ruby Framework packages, root docs, root examples, root framework
code, root framework tests/signatures, framework gemspec, and app-facing docs as
framework-owned unless a later route explicitly cross-links or rewrites them.
ACCEPT `playgrounds/igniter-lab/**` as frontier evidence only; exclude it from
the initial language split unless a later bounded intake route authorizes a
specific subset.
HOLD physical migration, `git subtree split`, `git filter-repo`, history rewrite,
remote push, package rename, CI/package changes, release execution, public
claims, framework-to-language authority transfer, and lab canon.
OPEN NEXT:
  S3-R256-C1-D
  igniter-lang-repository-split-dry-run-file-map-proof-v0
CARRY forms import hiding/overriding proof to:
  S3-R257-C1-A or next available
CARRY PROP-039 proof-local fixtures to:
  S3-R258-C1-A or later
SUPERSEDE the earlier R254 post-R255 forms candidate at S3-R256-C1-A if R256 is
assigned to the repository split dry-run.
KEEP public/stable/production/release/performance/certification/portability,
Reference Runtime, runtime support, package/release, and lab-canon claims closed.
```

Required C5-S current-status wording:

```text
R255 accepted the repository split boundary as design-ready only: `igniter-lang/**`
is the candidate future language repo root pending dry-run file-map proof; root
Ruby Framework docs/packages/examples/code remain framework-owned; lab remains
frontier evidence only; physical migration, history rewrite, remote push,
package/CI/release changes, public claims, framework-to-language authority
transfer, and lab canon remain closed. Next Main Line route is S3-R256-C1-D
repository split dry-run / file-map proof. The prior post-R255 forms candidate
at S3-R256-C1-A is superseded for sequencing and carried to S3-R257-C1-A or
next available; PROP-039 proof-local fixtures carry to S3-R258-C1-A or later.
```

Redirect is not needed unless C4-A refuses the dry-run/file-map proof. Physical
migration must not open from R255 alone. Pause is not recommended.
