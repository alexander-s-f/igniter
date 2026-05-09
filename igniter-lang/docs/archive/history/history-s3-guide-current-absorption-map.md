# History-S3 Guide Current Absorption Map

Status: archived history report and absorption map
Date: 2026-05-09
Agent: [Igniter-Lang History Curator]
Role: history-curator
Stage: History-S3
Source posture: compare and classify only; no files moved or deleted

## Compact Claim

`playgrounds/docs/guide/` and `playgrounds/docs/current/` are mostly absorbed
into the public docs shape:

```text
playgrounds guide/current full memory
  -> docs/guide user-facing compact paths
  -> docs/dev public architecture boundaries
  -> package READMEs and examples for package-local truth
```

The playground copies remain valuable as full source and rationale, but they
should not be used as public onboarding or current task context unless a fresh
brief points there.

For Igniter-Lang specifically, these files are platform lineage and applied
pressure. They are not Igniter-Lang canon.

## Source Set

Playgrounds compared:

- `playgrounds/docs/guide/api-draft.md`
- `playgrounds/docs/guide/application-capsules-full.md`
- `playgrounds/docs/guide/enterprise-verification.md`
- `playgrounds/docs/guide/frontend-authoring.md`
- `playgrounds/docs/guide/frontend-components.md`
- `playgrounds/docs/guide/interactive-app-structure-full.md`
- `playgrounds/docs/guide/schema-rendering-authoring.md`
- `playgrounds/docs/guide/sdk.md`
- `playgrounds/docs/current/README.md`
- `playgrounds/docs/current/agent-node.md`
- `playgrounds/docs/current/agents-roadmap.md`
- `playgrounds/docs/current/agents.md`
- `playgrounds/docs/current/app-structure.md`
- `playgrounds/docs/current/cluster-roadmap.md`
- `playgrounds/docs/current/cluster-state.md`
- `playgrounds/docs/current/contracts-and-agents.md`
- `playgrounds/docs/current/ignite.md`
- `playgrounds/docs/current/product-track.md`
- `playgrounds/docs/current/stacks.md`

Current public comparison:

- `docs/guide/README.md`
- `docs/guide/api-and-runtime.md`
- `docs/guide/app.md`
- `docs/guide/application-capsules.md`
- `docs/guide/application-showcase-portfolio.md`
- `docs/guide/interactive-app-structure.md`
- `docs/guide/ai-and-tools.md`
- `docs/guide/cluster.md`
- `docs/guide/deployment-modes.md`
- `docs/dev/README.md`
- `docs/dev/current-runtime-snapshot.md`
- `docs/dev/application-target-plan.md`
- `docs/dev/application-web-integration.md`
- `docs/dev/igniter-web-target-plan.md`
- `docs/dev/ai-agents-target-plan.md`
- `docs/dev/cluster-target-plan.md`
- `docs/dev/document-rotation.md`

## Absorption Table

| Playground source | Current public home | Category | Reading now |
| --- | --- | --- | --- |
| `guide/api-draft.md` | `docs/guide/api-and-runtime.md`, `docs/guide/contract-class-dsl.md`, package READMEs | superseded_history, value | Old public API draft. Keep as rationale for small/explicit/inspectable API, but do not use as current API. |
| `guide/application-capsules-full.md` | `docs/guide/application-capsules.md`, `docs/dev/application-target-plan.md` | implemented, superseded_history, value | Largely absorbed into compact capsule guide. Playground file is full source. |
| `guide/enterprise-verification.md` | `docs/guide/application-showcase-portfolio.md`, examples smoke paths, current package docs | superseded_history, value | Verification posture remains valuable; exact command matrix may be stale. |
| `guide/frontend-authoring.md` | `docs/dev/igniter-web-target-plan.md`, `docs/dev/application-web-integration.md`, current package/examples | research_unrealized, parked, value | Arbre/Home Lab authoring pressure. Not current public frontend API. |
| `guide/frontend-components.md` | `docs/dev/igniter-web-target-plan.md`, examples, future package docs | research_unrealized, parked, value | Component vocabulary pressure. Keep as design source, not current API. |
| `guide/interactive-app-structure-full.md` | `docs/guide/interactive-app-structure.md`, `docs/guide/application-showcase-portfolio.md` | implemented, superseded_history, value | Absorbed into compact public guide. Full version is cold detail. |
| `guide/schema-rendering-authoring.md` | no direct public guide equivalent | parked, research_unrealized, value | Schema rendering remains a future/adjacent authoring lane. Needs current owner before promotion. |
| `guide/sdk.md` | `docs/guide/ai-and-tools.md`, `docs/dev/ai-agents-target-plan.md`, package READMEs | superseded_history, parked, value | Broad SDK frame superseded by package ownership and optional surfaces. |
| `current/README.md` | `docs/dev/current-runtime-snapshot.md`, `docs/dev/document-rotation.md` | superseded_history, value | Good private snapshot of platform direction; no longer first read. |
| `current/contracts-and-agents.md` | `docs/dev/current-runtime-snapshot.md`, `docs/dev/ai-agents-target-plan.md`, `docs/guide/ai-and-tools.md` | accepted_canon, superseded_history, value | Core value preserved: contracts fundamental, agents first-class. Details should be checked against public docs/packages. |
| `current/agents.md` | `docs/dev/ai-agents-target-plan.md`, package READMEs | superseded_history, implemented, value | Package split and ownership absorbed; old entrypoint details may drift. |
| `current/agent-node.md` | `docs/dev/ai-agents-target-plan.md`, current runtime/package docs | superseded_history, implemented, value | Agent node/session/reply semantics are important lineage, but public surface lives elsewhere. |
| `current/agents-roadmap.md` | `docs/dev/ai-agents-target-plan.md`, `docs/dev/current-runtime-snapshot.md` | superseded_history, parked, value | Huge landed/next list. Keep as audit trail, not active roadmap. |
| `current/app-structure.md` | `docs/guide/app.md`, `docs/guide/application-capsules.md`, `docs/dev/application-target-plan.md` | implemented, superseded_history, value | Absorbed into app/capsule public path. |
| `current/stacks.md` | `docs/guide/app.md`, `docs/guide/deployment-modes.md`, `docs/dev/application-target-plan.md` | superseded_history, value | One-connection-point value preserved; details are private platform history. |
| `current/cluster-state.md` | `docs/guide/cluster.md`, `docs/dev/cluster-target-plan.md`, `docs/dev/current-runtime-snapshot.md` | implemented, superseded_history, value | Capability/trust/diagnostics direction absorbed compactly. Exact landed claims need package verification. |
| `current/cluster-roadmap.md` | `docs/dev/cluster-target-plan.md`, `docs/guide/cluster.md` | parked, superseded_history, value | Roadmap pressure only. Do not treat as active cluster task list. |
| `current/ignite.md` | `docs/guide/deployment-modes.md`, `docs/guide/app.md`, `docs/dev/current-runtime-snapshot.md` | parked, superseded_history, value | Ignite is platform lineage; current public docs keep deployment mode compact. |
| `current/product-track.md` | `docs/guide/application-showcase-portfolio.md`, `docs/dev/current-runtime-snapshot.md` | implemented, value | Companion/product pressure remains current as proof direction, but product track details are private. |

## Accepted Or Implemented Signals Preserved

The playground guide/current set already contributed these durable signals:

- Public docs should start with compact guide/dev/package entrypoints.
- Application capsules are the copyable app boundary.
- App-local code and metadata should stay inside the owning app.
- Web is an optional surface, not the application host.
- Transfer/activation are review-first and evidence-bearing.
- Interactive application structure is a convention, not a public framework API.
- Showcases prove success/refusal, snapshot parity, evidence artifacts, and
  mutation boundaries.
- AI and agents belong in package-owned surfaces, not hidden app-local loops.
- Cluster is capability/trust/diagnostic driven and sits above local runtime.
- Public docs should avoid implying production server/auth/cluster/LLM behavior
  from example surfaces.

## Values Preserved

- **Small public surface**: public docs explain current behavior, not every
  reasoning path.
- **Locality**: app-owned behavior belongs inside the app until repetition
  proves a package API.
- **Review-first mutation**: transfer, activation, ignition, and agent actions
  need explicit reports/receipts.
- **Optional web**: rendering does not own app state or runtime behavior.
- **Examples as proof, not promises**: showcase apps are evidence, not stable
  compatibility contracts.
- **Package ownership**: AI, agents, application, web, cluster, and MCP should
  keep separate responsibilities.
- **No hidden production claim**: server mode, browser review, auth, persistence,
  live transport, cluster placement, and LLM behavior must be explicit.
- **Product pressure matters**: Companion/Home Lab pressure should guide package
  extraction, but not harden private details too early.

## Cold Or Superseded Signals

Do not use these as current public truth:

- `guide/api-draft.md` method list as accepted public API.
- `guide/sdk.md` as a broad SDK architecture. Current direction is package-owned
  optional surfaces.
- `guide/frontend-authoring.md` and `guide/frontend-components.md` as public
  `igniter-web` API.
- `guide/schema-rendering-authoring.md` as a current guide.
- `current/agents-roadmap.md` as active roadmap.
- `current/ignite.md` as frozen deployment API.
- `current/cluster-roadmap.md` as accepted task order.
- Any playground command matrix without checking current examples and package
  README files.

## Research Still Alive

| Research/value line | Source | Suggested future treatment |
| --- | --- | --- |
| Arbre/frontend authoring lane | `guide/frontend-authoring.md`, `guide/frontend-components.md` | Keep as design pressure for `igniter-web` or home-lab; promote only through current target plan/package docs. |
| Schema rendering authoring | `guide/schema-rendering-authoring.md` | Park until a current package/app owner asks for schema-driven views. |
| Agent node/session lifecycle | `current/agent-node.md`, `current/agents*.md` | Keep as lineage for future agent package/runtime work. |
| Ignite deployment lifecycle | `current/ignite.md`, `current/stacks.md` | Keep as platform history; revive only through current deployment/cluster docs. |
| Product pressure loop | `current/product-track.md` | Continue using Companion public first, Home Lab private second. |
| Capability mesh roadmap | `current/cluster-state.md`, `current/cluster-roadmap.md` | Preserve as cluster lineage; validate through package docs/tests before claims. |

## Rotation Recommendations

No files should move in this stage.

Future approved cleanup can use this order:

1. Add a small `playgrounds/docs/guide/README.md` that says the directory is
   full/cold source and points to current `docs/guide/`.
2. Add a small `playgrounds/docs/current/README.md` note or status line making
   "private platform snapshot, not public current" unmistakable. The existing
   README still reads like an active entrypoint.
3. Do not delete Markdown in `guide/` or `current/` yet. They preserve useful
   full rationale behind compact public docs.
4. If a later deletion pass is desired, start with per-file compare for:
   `application-capsules-full.md`, `interactive-app-structure-full.md`, and
   `api-draft.md`, because they have the clearest public descendants.
5. Keep `frontend-*`, `schema-rendering-authoring.md`, and `ignite.md` as
   research/platform lineage until current owners decide their fate.

## Future Agent Read Rule

For current Ruby Igniter work:

1. `docs/guide/README.md`
2. `docs/dev/README.md`
3. package README for the touched package
4. only then, exact playground source if a current doc asks for history

For Igniter-Lang work:

1. `igniter-lang/docs/agent-context.md`
2. `igniter-lang/docs/current-status.md`
3. `igniter-lang/docs/value-index.md`
4. archive history reports
5. exact playground file only for source pressure

## Stage-Close Handoff

Compact claim:

- `playgrounds/docs/guide` and `playgrounds/docs/current` are mostly absorbed
  into compact public `docs/guide` and `docs/dev` entrypoints. Keep playground
  copies as private full memory; do not use them as current public truth.

Source set:

- `playgrounds/docs/guide/`
- `playgrounds/docs/current/`
- `docs/guide/`
- `docs/dev/`
- `docs/dev/document-rotation.md`

Categories applied:

- `accepted_canon`
- `implemented`
- `superseded_history`
- `research_unrealized`
- `rejected`
- `parked`
- `value`

Values preserved:

- compact public docs
- app locality
- review-first mutation
- optional web
- examples as proof not promises
- package ownership
- no hidden production claim
- product pressure loop

Accepted/implemented signals:

- application capsules
- interactive app convention
- showcase proof loop
- app/web boundary
- AI/agent package ownership direction
- cluster target boundary
- document rotation policy

Superseded/rejected signals:

- old API draft as accepted public API
- broad SDK umbrella as current architecture
- frontend/component guide as public API
- schema rendering guide as current guide
- roadmap files as active assignments
- ignite draft as frozen deployment API

Research still alive:

- Arbre/frontend authoring
- schema rendering
- richer agent lifecycle
- ignite deployment lifecycle
- product pressure loop
- capability mesh roadmap

Duplicate/rotation recommendations:

- add small playground guide/current index notes before any deletion
- keep all Markdown for now
- later compare clear descendants first:
  `application-capsules-full.md`, `interactive-app-structure-full.md`,
  `api-draft.md`

Unresolved questions:

- Should `playgrounds/docs/current/README.md` be changed in a later approved
  stage so it no longer says "active current-state" without qualification?
- Should the frontend authoring lane graduate into `docs/dev/igniter-web-*` or
  remain Home Lab/private research?
- Should schema rendering be preserved as a future package track or archived as
  unrealized research?

Changed files:

- `igniter-lang/docs/archive/history/history-s3-guide-current-absorption-map.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

- `History-S4: expert reports value extraction`, focused on
  `playgrounds/docs/experts/` outside `experts/igniter-lang/`.
