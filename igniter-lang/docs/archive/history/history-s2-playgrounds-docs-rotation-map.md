# History-S2 Playgrounds Docs Rotation Map

Status: archived history report and rotation plan
Date: 2026-05-09
Agent: [Igniter-Lang History Curator]
Role: history-curator
Stage: History-S2
Source posture: inventory and recommendation only; no files moved or deleted

## Compact Claim

`playgrounds/docs/` is not one archive. It is the private memory layer for the
Ruby Igniter platform: current working summaries, agent tracks, accepted process
doctrines, legacy V1 references, expert reports, research horizon, guide drafts,
and one review artifact.

The useful compression is not "delete old docs". The useful compression is:

```text
public docs stay small
playgrounds keeps full memory
archive/history keeps compact maps
future rotations move only after exact approval
```

For Igniter-Lang agents, `playgrounds/docs/` should be read as source pressure
and platform lineage, not as current Igniter-Lang canon.

## Source Set

Primary source:

- `playgrounds/docs/`

Current public/control comparison:

- `docs/dev/document-rotation.md`
- `docs/dev/README.md`
- `docs/guide/README.md`
- `docs/research/README.md`
- `igniter-lang/docs/agent-context.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/archive/history/history-s1-snapshot-value-map.md`

Playgrounds files sampled:

- `playgrounds/docs/current/README.md`
- `playgrounds/docs/experts/README.md`
- `playgrounds/docs/experts/igniter-lang/README.md`
- `playgrounds/docs/research-horizon/README.md`
- `playgrounds/docs/research-horizon/current-state-report.md`
- `playgrounds/docs/research-horizon/horizon-proposals.md`
- `playgrounds/docs/dev/process/documentation-compression-doctrine.md`
- `playgrounds/docs/dev/process/legacy-reference.md`
- `playgrounds/docs/dev/tracks/tracks.md`
- `playgrounds/docs/dev/tracks/tracks-history.md`
- representative expert reports: `igniter-plane.md`, `plastic-runtime-cells.md`

Inventory note:

- The inventory excluded `.git/` and `.idea/` from classification.
- Non-hidden Markdown files counted by top-level area: `dev` 144, `experts` 53,
  `research-horizon` 18, `current` 11, `guide` 8, `concepts` 1, `review` 1.

## Area Map

| Area | Count signal | Classification | Current reading |
| --- | ---: | --- | --- |
| `current/` | 11 files | superseded_history, value | Private current snapshot for Ruby Igniter around agents, app/stack, ignite, cluster, product. Useful for platform lineage, but public current docs now live in `docs/`. |
| `dev/tracks/` | 89 files | superseded_history, implemented, parked | Detailed agent track memory. Most should stay private/cold; active public docs should carry only accepted result summaries. |
| `dev/legacy/` | 28 files | superseded_history, value | Explicit legacy V1 reference set. Read only by topic. Not an entrypoint. |
| `dev/process/` | 5 files | accepted_canon, value | Contains accepted process doctrines: compression, handoff, interaction, runtime observatory, constraints. These are strong durable values. |
| `dev/reference/` | 17 files | superseded_history, value | Deep reference/roadmap material. Some content has public descendants in `docs/dev/` and package docs. |
| `dev/full/` | 3 files | superseded_history, value | Full target plans; public compressed versions exist for application, cluster, embed. |
| `experts/` | 53 files | research_unrealized, value | External reports and expert synthesis. Strong source pressure, not accepted architecture without supervisor filtering. |
| `experts/igniter-lang/` | 27 files | research_unrealized, accepted_canon, value | Theory/foundation series. Some ideas landed in Igniter-Lang Stage 2; many remain research. Read through README/frontier plus archive history. |
| `research-horizon/` | 18 files | research_unrealized, parked, value | Long-range proposal lane with explicit supervisor gate. Not implementation authorization. |
| `guide/` | 8 files | superseded_history, implemented, value | Old/full guide drafts. Several have public compressed descendants in `docs/guide/`. |
| `concepts/` | 1 file | value | Pattern/concept memory. Low-risk cold reference. |
| `review/` | 1 file | value | External agent review input; already partially absorbed by Igniter-Lang review/history tracks. |

## What Already Became Current Public Memory

The public docs already encode the intended boundary:

- `docs/dev/README.md` says private research, expert analysis, handoff history,
  and agent working tracks live under `playgrounds/docs/`.
- `docs/dev/document-rotation.md` says public docs should stay small and
  `playgrounds/docs/` keeps full memory.
- `docs/guide/README.md` says legacy deep references are private working
  material under `playgrounds/docs/`.
- `docs/research/README.md` keeps compact public research protocols and records
  which research/roadmap material has moved to package docs or playgrounds.

Direct basename overlaps found between `playgrounds/docs` and current public
docs:

- `application-target-plan.md`
- `cluster-target-plan.md`
- `embed-target-plan.md`
- `README.md`

Interpretation:

- The three target plans have public compressed descendants in `docs/dev/`.
- The playground copies should be treated as historical/full source, not active
  public truth.

## What Igniter-Lang Already Absorbed

From `experts/igniter-lang/`, archive snapshots, and History-S1:

| Source pressure | Absorbed current signal | Remaining boundary |
| --- | --- | --- |
| `History[T]`, `BiHistory[T]` | Stage 2 accepted proof-local types and axes. | Production TBackend binding deferred. |
| `stream` contracts | Stage 2 accepted stream surface and lowering. | Production stream execution remains future work. |
| OLAP Point | Stage 2 accepted parser/type/SemanticIR proof. | Distributed OLAP execution remains research. |
| Invariant severity | Stage 2 accepted parser/type/SemanticIR proof. | Persistence/deferred OOF handling remains research. |
| Temporal/datalog identities | Current design lens and value-index signal. | Does not authorize new syntax without proposal and tests. |
| Agent proposal / handoff / review pressure | Human-agent review and bridge pressure in current Igniter-Lang docs. | Runtime agent protocol is not Igniter-Lang canon yet. |
| Syntax density and comprehension pressure | Current ergonomics and syntax-pressure tracks. | Experimental syntax specimens remain non-canon. |

## Values To Preserve From Playgrounds

- **Documentation as cache**: active docs should be compact; history stays cold
  but findable.
- **Agent handoff discipline**: role, track, changed files, verification, next
  owner, and compact status are durable process primitives.
- **Research needs a supervisor gate**: expert reports and horizon proposals are
  pressure until accepted by a narrow track.
- **Read-only/report-only first**: many successful platform moves started as
  reports, readiness checks, or plans before mutation.
- **Private memory protects public docs**: public docs should explain current
  behavior; private docs can keep the full reasoning trail.
- **Human-agent readability matters**: docs, syntax, and runtime reports should
  be legible to both humans and agents.
- **Capsule/transfer/activation discipline**: portability is reviewable evidence,
  not hidden loading or deployment magic.
- **Runtime observability over hidden action**: observation graphs, operator
  inboxes, receipts, and audit trails are the recurring safe substrate.

## Superseded Or Cold Signals

These should not be used as current canon without checking public/current docs:

- `playgrounds/docs/current/*` as active Ruby Igniter state.
- `playgrounds/docs/dev/full/*` as the current target plan.
- `playgrounds/docs/dev/tracks/*` as current task assignment unless linked from
  a fresh user brief.
- `playgrounds/docs/dev/legacy/*` as implementation guidance.
- Full guide drafts in `playgrounds/docs/guide/*` when `docs/guide/*` has a
  current compressed descendant.
- Expert DSL proposals as accepted APIs.
- Research Horizon proposals as implementation authorization.
- Old MeshQL, ignite, cluster, and agent roadmap material as active priority.

## Research Still Alive

The strongest non-Igniter-Lang research/value lines in `playgrounds/docs`:

| Line | Where | Current status |
| --- | --- | --- |
| Runtime Observatory Graph | `research-horizon/runtime-observatory-graph.md`, `dev/process/runtime-observatory-doctrine.md` | Doctrine/value accepted; runtime object/query language not accepted. |
| Interaction Kernel | `research-horizon/interaction-kernel-report.md`, `dev/process/interaction-doctrine.md` | Doctrine/value accepted; package/object not accepted. |
| Agent Handoff Protocol | `research-horizon/agent-handoff-protocol.md`, `dev/process/handoff-doctrine.md` | Process doctrine accepted; runtime protocol deferred. |
| Plastic Runtime Cells | `experts/plastic-runtime-cells.md`, `research-horizon/horizon-proposals.md` | Research synthesis; useful after capsule/host/cluster stability. |
| Igniter Plane | `experts/igniter-plane.md` | Valuable UI metaphor; should wait for observatory substrate. |
| Constraint-aware planner | `research-horizon/horizon-proposals.md` | Good future agent architecture; start as report shape if revived. |
| Capability market routing | `research-horizon/horizon-proposals.md` | Interesting diagnostics lane; high overbuild risk. |
| Application proposal catalog | `experts/application-proposals*.md` | Product idea archive; use as ideation, not roadmap. |
| Documentation compression tooling | `experts/documentation-compression.md`, `dev/process/documentation-compression-doctrine.md` | Manual doctrine accepted; automation deferred. |
| Concept emergence mining | `experts/concept-emergence.md` | Research value; not active process tooling. |

## Rotation Recommendations

No movement in this stage. This is the proposed approval packet for a future
one-time cleanup.

| Path | Recommendation | Approval needed? | Reason |
| --- | --- | --- | --- |
| `playgrounds/docs/.DS_Store` | Delete. | Yes, destructive cleanup. | Finder artifact; no documentation value. |
| `playgrounds/docs/.idea/` | Consider external/local-only cleanup. | Yes. | IDE metadata, not durable docs. |
| `playgrounds/docs/.git/` | Decide deliberately before any move. | Yes, high caution. | Nested repository metadata may be intentional history. Do not touch casually. |
| `playgrounds/docs/current/` | Keep for now; later rename/mark as `platform-current-archive` or rotate deeper. | Yes. | It is no longer the public active entrypoint, but still valuable platform lineage. |
| `playgrounds/docs/dev/tracks/` | Keep as private track history; optionally split active `tracks.md` from closed track files. | Yes. | 89 files is large but this is exactly the private memory role. |
| `playgrounds/docs/dev/legacy/` | Keep; add/keep index discipline. | No immediate move. | Already explicitly scoped as legacy/deep reference. |
| `playgrounds/docs/dev/full/` | Keep as full historical targets; public `docs/dev/*target-plan.md` remains current. | No immediate move. | These are useful before/after comparisons. |
| `playgrounds/docs/dev/process/` | Keep near top of playgrounds; do not deep-archive. | No. | Contains durable accepted process doctrines. |
| `playgrounds/docs/dev/reference/` | Keep; later classify per file if public docs start duplicating details. | Later. | Mixed deep reference set; not safe to bulk rotate. |
| `playgrounds/docs/experts/` | Keep as research source. | No immediate move. | Strong expert pressure and theory source. |
| `playgrounds/docs/experts/igniter-lang/` | Keep; read through History-S1/S2 first. | No immediate move. | Key source for Igniter-Lang foundations. |
| `playgrounds/docs/research-horizon/` | Keep as research lane. | No immediate move. | Already has supervisor-gate posture. |
| `playgrounds/docs/guide/` | Later compare each file against `docs/guide/` and mark absorbed/kept. | Yes for moves/deletes. | Likely old/full drafts; not safe to delete without per-file check. |
| `playgrounds/docs/review/` | Keep as small evidence source. | No. | One useful review artifact. |

## Suggested Read Rules

For Ruby Igniter platform work:

1. Start with `docs/guide/README.md`, `docs/dev/README.md`, and package READMEs.
2. Use `docs/dev/document-rotation.md` to decide whether public or private docs
   are the right home.
3. Enter `playgrounds/docs/dev/tracks/` only through a specific track link or
   explicit assignment.
4. Use `playgrounds/docs/current/` only for historical platform direction.

For Igniter-Lang work:

1. Start with `igniter-lang/docs/agent-context.md`.
2. Read `igniter-lang/docs/current-status.md` and `igniter-lang/docs/value-index.md`.
3. Read archive history reports before expert sources:
   - `origins-arbor-to-igniter-lang.md`
   - `history-s1-snapshot-value-map.md`
   - `history-s2-playgrounds-docs-rotation-map.md`
4. Enter `playgrounds/docs/experts/igniter-lang/` only for exact theory/source
   evidence.

## Proposed Future Cleanup Packet

When the user approves an actual cleanup stage, do it as one explicit packet:

```text
Playgrounds-Rotation-1
```

Scope:

- remove only agreed metadata artifacts (`.DS_Store`, maybe `.idea/`);
- do not touch nested `.git/` unless the user explicitly decides its fate;
- add small indexes where they reduce future reads;
- do not delete content-bearing Markdown in the first cleanup pass;
- produce before/after file counts and run link/diff checks.

## Stage-Close Handoff

Compact claim:

- `playgrounds/docs` is the private memory layer, not a dump to purge. Its main
  value is full reasoning history behind public compact docs. The next move
  should be metadata cleanup and index tightening, not Markdown deletion.

Source set:

- `playgrounds/docs/`
- `docs/dev/document-rotation.md`
- `docs/dev/README.md`
- `docs/guide/README.md`
- `docs/research/README.md`
- `igniter-lang/docs/archive/history/history-s1-snapshot-value-map.md`

Categories applied:

- `accepted_canon`
- `implemented`
- `superseded_history`
- `research_unrealized`
- `rejected`
- `parked`
- `value`

Values preserved:

- documentation as cache
- compact public docs plus private full memory
- supervisor-gated research
- read-only/report-first progression
- handoff discipline
- human-agent readability
- capsule/activation evidence discipline
- observability before action

Accepted/implemented signals:

- public/private doc split
- document rotation policy
- process doctrines for compression, handoff, interaction, and runtime
  observatory
- public compressed target plans for application, cluster, and embed
- Igniter-Lang Stage 2 absorption of History/BiHistory, stream, OLAPPoint, and
  invariant severity from expert pressure

Superseded/rejected signals:

- playground current docs as default active context
- legacy V1 docs as implementation truth
- expert DSL/report proposals as accepted APIs
- research-horizon proposals as automatic roadmap
- old full target plans over current public target plans

Research still alive:

- Runtime Observatory Graph
- Interaction Kernel
- runtime Agent Handoff Protocol
- Plastic Runtime Cells
- Igniter Plane
- constraint-aware planner
- capability market diagnostics
- product/application proposal catalog
- documentation compression automation
- concept-emergence mining

Duplicate/rotation recommendations:

- keep Markdown content for now
- consider metadata cleanup only with approval
- keep process doctrines near top
- use `history/*` reports as first archive map
- later run per-file comparison for `playgrounds/docs/guide/`

Unresolved questions:

- Should `playgrounds/docs/.git/` be preserved as an intentional nested history
  repo, or removed after external backup?
- Should `playgrounds/docs/current/` be renamed to make its historical status
  unambiguous?
- Should the four process doctrines be linked from a small top-level
  `playgrounds/docs/README.md` if one is created later?

Changed files:

- `igniter-lang/docs/archive/history/history-s2-playgrounds-docs-rotation-map.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

- `History-S3: guide/current absorption map`, focused on comparing
  `playgrounds/docs/guide/` and `playgrounds/docs/current/` to current
  `docs/guide/` and `docs/dev/`.
