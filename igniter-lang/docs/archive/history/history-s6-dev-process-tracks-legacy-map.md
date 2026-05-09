# History-S6 Dev Process Tracks Legacy Map

Status: archived history report and dev-doc map  
Date: 2026-05-09  
Agent: [Igniter-Lang History Curator]  
Role: history-curator  
Stage: History-S6  
Source posture: classify private dev memory only; no files moved or deleted

## Compact Claim

`playgrounds/docs/dev/` is private development memory, not the public current
documentation surface.

Its durable shape is already clear:

- `process/` holds accepted working doctrines and constraint vocabulary.
- `tracks/tracks.md` is the private active routing table.
- `tracks/tracks-history.md` and individual track files are warm/cold evidence,
  not default reading.
- `legacy/`, `reference/`, and `full/` preserve old target shapes and deep
  reference material that must be read only by topic.

Future agents should not read the whole dev tree. They should start from the
current public docs for product/API truth, and from `tracks/tracks.md` only when
they are doing private multi-agent development work.

## Source Set

- `playgrounds/docs/dev/process/constraints.md`
- `playgrounds/docs/dev/process/documentation-compression-doctrine.md`
- `playgrounds/docs/dev/process/handoff-doctrine.md`
- `playgrounds/docs/dev/process/interaction-doctrine.md`
- `playgrounds/docs/dev/process/legacy-reference.md`
- `playgrounds/docs/dev/process/runtime-observatory-doctrine.md`
- `playgrounds/docs/dev/tracks/tracks.md`
- `playgrounds/docs/dev/tracks/tracks-history.md`
- `playgrounds/docs/dev/tracks/agent-track-lifecycle-doctrine.md`
- `playgrounds/docs/dev/full/application-target-plan.md`
- `playgrounds/docs/dev/full/cluster-target-plan.md`
- `playgrounds/docs/dev/full/embed-target-plan.md`
- `playgrounds/docs/dev/reference/architecture-index.md`
- `playgrounds/docs/dev/reference/roadmap.md`
- `igniter-lang/docs/archive/history/history-s3-guide-current-absorption-map.md`
- `igniter-lang/docs/archive/history/history-s5-research-horizon-compression-map.md`

## Area Classification

| Area | Category | Read as | Curation call |
| --- | --- | --- | --- |
| `process/` | accepted_canon, values | Private operating doctrine | Keep close; it explains how agents should constrain, compress, hand off, and rotate context. |
| `tracks/tracks.md` | accepted_canon, implemented | Private active routing index | Keep as the first private dev entrypoint; do not replace with all-track reading. |
| `tracks/tracks-history.md` | superseded_history, values | Accepted long context | Read only for audit, lineage, or a named track dependency. |
| `tracks/*.md` | implemented, superseded_history, parked | Evidence and handoff history | Do not treat as active assignments unless linked from `tracks.md` or the current user brief. |
| `legacy/` | superseded_history, values | V1 deep reference | Keep cold; read by exact topic after public docs and process guidance. |
| `reference/` | superseded_history, research_unrealized, values | Deep planning/reference material | Use only when a current task names a topic or when reconstructing lineage. |
| `full/` | superseded_history, values | Full old target plans | Public compressed descendants should be preferred for current implementation decisions. |

## Process Doctrines

| Document | Classification | Durable value |
| --- | --- | --- |
| `constraints.md` | accepted_canon, implemented | Named boundary sets make agent work repeatable without re-litigating scope each turn. |
| `documentation-compression-doctrine.md` | accepted_canon, values | Docs act as cache; context should rotate from active to warm/cold/speculative layers. |
| `handoff-doctrine.md` | accepted_canon, implemented | Handoff is a docs protocol and compact fact shape, not a runtime object yet. |
| `interaction-doctrine.md` | accepted_canon, implemented | Interaction is a docs protocol; shared package extraction remains intentionally deferred. |
| `runtime-observatory-doctrine.md` | accepted_canon, implemented | Observability stays read-only, bounded, and non-mutating unless promoted later. |
| `legacy-reference.md` | accepted_canon, values | Legacy docs are supporting reference, not the first source of current truth. |

Accepted constraint names worth preserving:

- `:interactive_poc_guardrails`
- `:companion_ready_to_go_poc`
- `:context_rotation`
- `:activation_safety`
- `:research_only`
- `:embed_shadow_safety`
- `:human_sugar_parallel_form`

## Track Memory Map

The `tracks/` folder is intentionally dense. Its dominant clusters are:

| Cluster | Signal | Classification |
| --- | --- | --- |
| Application capsule and activation chain | Transfer, receipts, host activation, inspection, guide consolidation | implemented, superseded_history, values |
| Application web/operator POC | Skeleton, task creation, feedback, read models, signal inbox, action logs | implemented, values |
| Showcase applications | Lense, Chronicle, Scout, Dispatch, portfolio synthesis | implemented, accepted_canon as proof path, superseded_history as track detail |
| Embed and contracts | Contract class integration, differential shadow contractable, persistence capability | implemented, research still alive where future seams remain possible |
| Igniter-Lang | Foundation pack, metadata manifest, foundation guide finalization | implemented as additive/report-only lineage; not runtime-enforcing canon |
| Enterprise verification | Readiness, public entry hygiene, verification receipts | implemented, values |
| Agent/process tracks | Agent-native sessions, lifecycle doctrine, handoff/interaction doctrine | values, research still alive, partly accepted as docs protocol |
| Runtime observatory | Doctrine and activation frame | values, research still alive, intentionally non-mutating |

The active index states the key read rule: drill into only the linked active
track and its direct dependencies, then return compact status.

## Accepted Or Implemented Signals

- Multi-agent work stabilized around track lifecycle: signal, bounded track,
  constraint set, execution, compact handoff, supervisor acceptance, compression.
- Constraint sets became reusable process vocabulary.
- Documentation compression became accepted operating discipline.
- Handoff, interaction, and runtime observatory became docs-level protocols.
- Application capsule transfer and activation vocabulary landed as proof and
  receipt language, while production host activation stayed scoped out.
- Application showcase portfolio became the richer app onboarding/proof path.
- Companion/product pressure remains the live product-facing proof line.
- Igniter-Lang stayed additive: Ruby wrapper/report surface, metadata manifest,
  and guide layer, not an enforcing runtime semantics layer.
- Application, Embed, and Cluster target plans were compressed into public dev
  target docs; the full versions remain lineage.

## Superseded Or Rejected As Canon

- Reading all track files as active context is superseded by `tracks/tracks.md`.
- Treating `tracks-history.md` as the current task list is superseded.
- Treating V1 legacy docs as current implementation truth is superseded.
- Using `reference/architecture-index.md` as the current package graph without
  checking public dev docs is superseded.
- Re-promoting old giant `Application`, `Cluster`, stack, mesh, or global app
  shapes as canon is rejected unless a new accepted track revalidates them.
- Turning handoff, interaction, or observatory doctrine into runtime objects is
  parked until repeated product pressure proves the need.
- Igniter-Lang metadata manifests should not become hidden runtime enforcement
  based on these old tracks.

## Values To Preserve

- **Context efficiency:** read narrow, return compact facts, rotate completed
  context out of active memory.
- **Named constraints:** reusable boundary names are valuable even before code.
- **Supervisor acceptance:** acceptance/rejection/defer decisions are first-class
  outputs.
- **Docs as prototype:** process docs can prove a future Igniter-native shape
  before framework code exists.
- **Human sugar plus agent-clean form:** authoring should stay pleasant while
  preserving explicit machine-readable boundaries.
- **Receipts over vibes:** proofs, manifests, and verification receipts are the
  durable language for application transfer and activation.
- **Application pressure over abstraction:** new seams should be promoted from
  real app pressure, not from old architecture desire.

## Research Still Alive

- Agent-native task contracts, track compilation, and memory layers may later
  become Igniter-native agent/LLM primitives.
- Runtime observatory activation frames remain a promising read-only diagnostic
  shape.
- Companion/product pressure may justify future contract persistence or app
  operator affordances.
- Human Sugar DSL remains an important parallel authoring form if it continues
  to map cleanly onto explicit contract shapes.
- Embed shadow/discovery/adapters remain active pressure zones where lower-layer
  seams may or may not be needed.
- Credential distribution, DTO record foundation, and debug-pack/reference
  ideas remain candidate tracks, but must be checked against current docs before
  promotion.

## Rotation Recommendations

No files should be moved or deleted in this stage.

Recommended future cleanup, only after approval:

| Target | Recommendation | Reason |
| --- | --- | --- |
| `playgrounds/docs/dev/` | Add a small `README.md` or index | The folder currently has clear internal structure but no top-level entrypoint. |
| `tracks/` | Keep `tracks.md` hot, keep `tracks-history.md` warm, keep individual tracks cold | This preserves evidence without forcing context explosion. |
| Application track cluster | Optionally group closed application/capsule/web tracks later | The cluster is large enough to obscure live handoffs. |
| `legacy/` | Keep intact and cold | It is already marked as supporting reference by `legacy-reference.md`. |
| `full/` | Mark as historical/full source if future index is added | Current public compressed target plans should be preferred. |
| `reference/architecture-index.md` and `reference/roadmap.md` | Add historical/current-check warning if edited later | Both contain valuable lineage but can mislead as current package truth. |

## Future Agent Read Rule

For current public/product/API decisions:

1. Read `igniter-lang/docs/agent-context.md`.
2. Read `igniter-lang/docs/current-status.md`.
3. Read current public guide/dev docs.
4. Use archive history only when lineage matters.

For private multi-agent dev work:

1. Read `playgrounds/docs/dev/tracks/tracks.md`.
2. Read the named active track.
3. Read `playgrounds/docs/dev/process/constraints.md`.
4. Read only explicitly linked dependencies.
5. Return compact status.

For legacy reconstruction:

1. Start from current public docs.
2. Use `playgrounds/docs/dev/process/legacy-reference.md`.
3. Read exact `legacy/`, `reference/`, or `full/` files by topic.
4. Classify findings as accepted, implemented, superseded, parked, rejected, or
   value before promoting anything.

## Stage-Close Handoff

Compact claim:

`playgrounds/docs/dev/` is best preserved as layered private development memory:
process doctrines and active track index close to hand, track history and legacy
reference cold, full plans as lineage only.

Source set:

- `playgrounds/docs/dev/process/`
- `playgrounds/docs/dev/tracks/`
- `playgrounds/docs/dev/legacy/`
- `playgrounds/docs/dev/reference/`
- `playgrounds/docs/dev/full/`
- current archive history reports for S3 and S5

Categories applied:

- accepted_canon
- implemented
- superseded_history
- research_unrealized
- rejected / parked
- values

Values preserved:

- context rotation
- named constraints
- compact handoffs
- supervisor acceptance
- docs-as-prototype
- receipts and verification
- application pressure before abstraction

Accepted/implemented signals:

- track lifecycle doctrine
- constraints/process doctrines
- active track index read discipline
- application capsule proof vocabulary
- showcase portfolio proof path
- additive Igniter-Lang report surface
- target-plan compression into current dev docs

Superseded/rejected signals:

- all-track reading as default
- V1 docs as current truth
- old architecture index as current package graph
- old giant application/cluster/stack shapes as canon
- runtime-enforced Igniter-Lang manifests
- premature runtime objects for handoff/interaction/observatory

Research still alive:

- agent-native track/task contracts
- runtime observatory activation frames
- Companion/product contract persistence pressure
- Human Sugar DSL
- Embed shadow/discovery/adapters
- credential/DTO/debug-pack ideas after current-doc check

Duplicate/rotation recommendations:

- add a top-level `playgrounds/docs/dev/README.md` later if approved
- keep `tracks.md` as hot entrypoint
- keep `tracks-history.md` warm and individual tracks cold
- optionally group closed application/capsule/web tracks later
- keep `legacy/` intact and cold
- label `full/` and selected `reference/` docs as historical if touched later

Unresolved questions:

- Which closed track clusters should remain searchable in-place versus move to a
  deeper archive repository?
- Should the track lifecycle doctrine eventually become an Igniter-native agent
  package, or remain a docs protocol until more product proof exists?
- Which Companion contract-persistence signals are strong enough for the next
  accepted track?

Changed files:

- `igniter-lang/docs/archive/history/history-s6-dev-process-tracks-legacy-map.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

History-S7 should extract a compact value map from `playgrounds/docs/dev/legacy/`
itself: which V1 ideas survived into current architecture, which are permanently
superseded, and which remain research seeds.
