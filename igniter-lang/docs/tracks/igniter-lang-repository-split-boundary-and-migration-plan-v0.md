# Igniter Lang Repository Split Boundary and Migration Plan v0

Card: `S3-R255-C1-D`  
Skill: `IDD Agent Protocol`  
Agent: `[Portfolio Architect Supervisor]`  
Role: `portfolio-architect-supervisor`  
Track: `igniter-lang-repository-split-boundary-and-migration-plan-v0`  
Route: `UPDATE`  
Status: `design-ready / migration-held`  
Date: 2026-06-06

Depends on:

- `S3-R254-C5-S`

---

## Decision Frame

R254 accepted proof-local contract invocation forms SemanticIR lowering
evidence and explicitly preserved R255 as the next Main Line repository split
boundary. R255 now opens the design boundary for separating Igniter Lang from
the Igniter Ruby Framework before any physical migration.

Target future language repository:

```text
alexander-s-f/igniter-lang
```

This document is a boundary and migration-plan design only. It does not
authorize repository migration, `git subtree split`, `git filter-repo`, remote
push, release execution, package rename, CI/package changes, public claims,
framework-to-language authority transfer, or lab behavior as canon.

---

## Design Decision

Recommendation to C4-A:

```text
accept the repository split boundary as design-ready
treat igniter-lang/** as the candidate future igniter-lang repository root
keep physical migration and remote push closed
route a repository split dry-run / file-map proof before any migration execution
preserve Ruby Framework packages, examples, and app-facing docs outside language authority
keep playgrounds/igniter-lab/** as frontier evidence requiring later intake
renumber post-R255 technical lanes explicitly after the dry-run route
```

The split boundary is ready enough for facts review and pressure review. It is
not ready for physical execution. A dry-run/file-map proof should come first so
history preservation, generated artifact treatment, README/package references,
and cross-link strategy are audited before any remote repository is created or
pushed.

---

## Ownership Model

### Igniter Lang

Igniter Lang is the language research and compiler ecosystem:

- language specification and Covenant;
- proposals and proposal lifecycle;
- parser/classifier/typechecker/SemanticIR/compiler package;
- `.ig`, `.igapp`, fixtures, experiments, conformance-facing artifacts;
- `igc` compiler CLI and alpha `igniter_lang` package surfaces;
- tracks, discussions, gates, reports, reviews, handoff, roles, and operating
  docs needed to preserve language governance;
- release evidence and non-claim docs for the language package only.

### Igniter Ruby Framework

Igniter Ruby Framework is the application/framework/platform ecosystem:

- root Ruby framework gem and umbrella package map;
- packages under `packages/**`;
- framework runtime, application, web, agents, AI, cluster, hub, MCP adapter
  surfaces;
- Rails/framework examples and application-facing examples;
- root `docs/**`, root `README.md`, root `CHANGELOG.md`, root `Gemfile`,
  root `Rakefile`, root `igniter.gemspec`, `lib/igniter/**`, `spec/**`,
  `sig/**`, and framework package release surfaces.

### Lab / Frontier

`playgrounds/igniter-lab/**` is a frontier ecosystem and is not automatically
part of either future public authority surface. It contains valuable pressure
and experimental implementations, but it should remain outside the initial
language repo migration unless a later intake route explicitly moves a bounded
subset.

---

## Repository Ownership Matrix

| Current surface | Future status | Rationale |
| --- | --- | --- |
| `igniter-lang/README.md` | Include | Language workspace entrypoint; already states separate research workspace. |
| `igniter-lang/AGENTS.md` | Include | Language agent protocol and write boundary for the future repo. |
| `igniter-lang/igniter_lang.gemspec` | Include, review metadata in dry-run | Language alpha package surface; homepage/source URIs currently point into monorepo path. |
| `igniter-lang/bin/**` | Include | Language CLI tools (`igc`, `igniter-lang`, release gate). |
| `igniter-lang/lib/**` | Include | Language compiler/orchestrator/runtime-proof package code. |
| `igniter-lang/source/**` | Include | Language source corpus and expected parser artifacts. |
| `igniter-lang/fixtures/**` | Include | Language fixture artifacts and conformance pressure. |
| `igniter-lang/tests/**` | Include | Language/conformance tests. |
| `igniter-lang/docs/spec/**` | Include | Language specification authority and proposed chapters. |
| `igniter-lang/docs/proposals/**` | Include | Language proposal lifecycle. |
| `igniter-lang/docs/tracks/**` | Include, possibly archive/prune later | Durable Stage/round audit; needed for traceability. |
| `igniter-lang/docs/discussions/**` | Include | Pressure/review record; not canon but audit-relevant. |
| `igniter-lang/docs/gates/**` | Include | Language authority decisions. |
| `igniter-lang/docs/reports/**` | Include if language-facing | Report packets and cross-lane evidence; facts packet should classify any framework-only reports. |
| `igniter-lang/docs/archive/**` | Include in dry-run, consider shallow archive policy later | Preserves provenance; heavy but audit-relevant. |
| `igniter-lang/experiments/**` | Include initially | Proof corpus and historical evidence; dry-run may flag generated outputs. |
| `igniter-lang/out/**` | Exclude or quarantine unless proven required | Generated local output; should not become repo authority by default. |
| `igniter-lang/out_run.log` | Exclude or quarantine | Runtime/log artifact, not durable source. |
| `README.md` | Framework repo; cross-link only | Describes Igniter platform/packages, not language repo authority. |
| `AGENTS.md` | Framework repo; cross-link/adapter note only | Root instructions are framework repo instructions; future language repo uses `igniter-lang/AGENTS.md`. |
| `docs/**` | Framework repo; selective cross-links only | Root docs are framework/platform guide/dev docs. |
| `packages/**` | Framework repo | Ruby framework packages and gem surfaces. |
| `lib/igniter/**` / `lib/igniter.rb` | Framework repo | Ruby framework implementation. |
| `examples/**` | Framework repo | App/framework/Rails examples; not language canon. |
| `spec/**`, `sig/**` | Framework repo | Framework test/signature surfaces. |
| `igniter.gemspec` | Framework repo | Umbrella framework gem. |
| `Gemfile`, `Gemfile.lock`, `Rakefile` | Framework repo | Root framework build/test/release tools. |
| `playgrounds/igniter-lab/**` | Frontier, later intake only | Nested lab ecosystem; evidence only, no canon migration. |

---

## Cross-Link and Docs Policy

The future language repo should not copy root framework docs as authority.
Instead:

- keep `igniter-lang/README.md` as the language entrypoint;
- rewrite language README/public docs only in a later docs-sync route if needed;
- use cross-links or short bridge notes for framework relationship;
- keep root framework docs as framework authority;
- do not import Rails/framework examples into language spec/proposal docs;
- keep language package release notes scoped to `igniter_lang`, not the Ruby
  framework umbrella gem.

Cross-links are preferred when the target is conceptual or ecosystem context.
Copying is only appropriate for files owned by the language workspace or
material needed to run language package tests/proofs in isolation.

---

## Lab / Frontier Policy

`playgrounds/igniter-lab/**` is accepted as high-value frontier pressure, but it
must not move into the initial language repo split automatically.

Status:

- lab compiler / VM / stdlib / runtime / view / IDE / TBackend / apps evidence
  remains frontier evidence;
- generated lab proof packets remain evidence only;
- lab overclaim wording remains tolerated inside lab only if mainline records
  strict non-claims;
- any later migration of a lab component requires a bounded intake route that
  classifies authority, package shape, proof matrix, and closed surfaces.

The initial repository split should prefer a clean language core over moving
the entire frontier ecosystem into the new public repo.

---

## Generated Artifact and Audit Policy

The split must distinguish durable source/audit records from generated output:

| Artifact kind | Initial stance |
| --- | --- |
| Track docs, decisions, pressure reviews | Include; durable audit. |
| Proposal/spec docs | Include; language governance. |
| Experiments source/proof scripts | Include initially; later pruning may be separate. |
| Experiment result JSON needed by docs | Include only if already tracked and referenced; dry-run should classify. |
| `out/**`, logs, local build products | Exclude/quarantine by default. |
| `.DS_Store`, local IDE metadata, target/build/node_modules | Exclude. |
| Gem artifacts (`*.gem`) | Exclude from language split unless release evidence route requires archival copy. |

A dry-run proof should produce a file-map with inclusion/exclusion reasons
before any history rewrite or remote push.

---

## Git / History Preservation Stance

History preservation requires a dry-run proof first.

Recommended dry-run questions:

- Can `igniter-lang/**` become the new repository root while preserving history?
- Which root-level support files must be synthesized or copied into the split
  working tree?
- Which generated files are currently tracked and should be explicitly dropped
  or quarantined?
- Which links break when `igniter-lang/` becomes root?
- Which gemspec metadata needs a future docs/package review?
- Does the split preserve Stage 1/2/3 audit docs and route history?
- Does any root framework file need a cross-link note after split?

No migration command is authorized by this design route. The next route should
be a dry-run/file-map proof, not a live split.

---

## Migration Risk Matrix

| Risk | Severity | Mitigation |
| --- | --- | --- |
| Ruby Framework concepts become language authority | High | Treat root/packages/examples/docs as framework-owned; cross-link only. |
| Language package links still point to monorepo paths | Medium | Dry-run should inventory README/gemspec/source URI changes; no package changes yet. |
| Generated outputs enter new repo as canon | Medium | File-map proof must classify generated/log/out artifacts. |
| Lab frontier becomes public language canon | High | Keep `playgrounds/igniter-lab/**` out of initial split; require later intake. |
| History/audit loss during split | High | Require dry-run proof before `subtree`/`filter-repo`. |
| Post-R255 technical route collision | Medium | C4-A/C5-S must assign exact post-R255 route numbers. |
| Public release/production overclaim | High | Preserve no-stable/no-production/no-public-runtime wording. |
| CI/package breakage after root shift | Medium | Dry-run should identify required minimal root files before execution. |

---

## Next-Route Options

| Option | Status | Notes |
| --- | --- | --- |
| Repository split dry-run / file-map proof | Recommended | Safest next Main Line route before any migration execution. |
| Repository split docs/status boundary sync | Secondary | Useful if C2/C3 finds wording drift; should not replace dry-run if migration is desired. |
| Forms import hiding/overriding proof | Valid post-R255 technical lane | R254 carried it as next forms lane; can open after split boundary sequencing is resolved. |
| PROP-039 proof-local fixture authorization | Valid later lane | R253 deferred it to R256 or later; preserve without collision. |
| Physical migration / remote push | Hold | Not safe until dry-run proof and C4-A authorization review. |
| Pause | Valid if facts/pressure find severe ownership blockers. |

---

## Explicit Answers

### Is the repository split boundary design-ready?

Yes. It is design-ready as a boundary and migration-plan surface.

### Should `igniter-lang/**` become the future repo root?

Yes, as the candidate future repo root. A dry-run proof must validate required
support files, link rewrites, generated artifact exclusions, and package
metadata before physical migration.

### Do any non-`igniter-lang/**` surfaces belong in the future language repo?

Not by default. Root framework files should remain framework-owned. If a
support file such as license, CI, or shared governance text is needed, it should
be copied or rewritten through a dry-run/docs-sync route with explicit
provenance rather than treated as language authority automatically.

### Does `playgrounds/igniter-lab/**` move?

No. It remains frontier/lab evidence and needs later intake for any bounded
component migration.

### Do Ruby Framework docs/examples/packages remain outside language authority?

Yes. Root docs, packages, Rails/framework examples, framework gemspec, and
application-facing docs remain outside language authority.

### Should docs be copied, linked, or rewritten?

Language-owned docs under `igniter-lang/docs/**` should move with the language
repo. Framework docs should be cross-linked only. Public language README and
package docs may need later rewrite to remove monorepo path assumptions, but
that is a docs/package-sync route, not this design route.

### Does git/history preservation require a dry-run proof first?

Yes. A dry-run file-map proof is required before any physical migration.

### May physical migration open next?

No. Physical migration must wait.

### Does remote push to `alexander-s-f/igniter-lang` remain closed?

Yes. Remote push remains closed.

### Should forms import hiding/overriding or PROP-039 fixtures open before migration execution?

They may open before migration execution, but they should not displace the
repository split dry-run if the project wants migration readiness next.
Recommended sequencing:

```text
S3-R256-C1-D repository split dry-run / file-map proof
S3-R257-C1-A forms import hiding/overriding proof authorization review
S3-R258-C1-A or later PROP-039 proof-local fixture authorization review
```

C4-A may adjust exact route numbers, but it should keep all post-R255 lanes
explicit and avoid reusing stale R253/R256 collision language.

### Do public/stable/production/release/performance/certification/portability claims remain closed?

Yes. All remain closed.

---

## Exact C4-A Recommendation

Recommend that C4-A:

```text
ACCEPT: repository split boundary as design-ready
HOLD: physical migration, remote push, package/CI/release changes
OPEN NEXT: S3-R256-C1-D repository split dry-run / file-map proof
CARRY: forms import hiding/overriding proof to S3-R257-C1-A or next available
CARRY: PROP-039 proof-local fixtures to S3-R258-C1-A or later
CLOSED: public/stable/production/release/performance/certification/portability claims
```

If C2-P1 or C3-X finds major ownership ambiguity, C4-A should conditionally
accept the boundary and route a docs/status boundary sync before dry-run
execution. It should not authorize physical migration from R255 alone.

