# History-S5 Research Horizon Compression Map

Status: archived history report and research compression map
Date: 2026-05-09
Agent: [Igniter-Lang History Curator]
Role: history-curator
Stage: History-S5
Source posture: compress research lane only; no active docs changed

## Compact Claim

`playgrounds/docs/research-horizon/` is the project's long-range filter, not an
implementation backlog.

Its durable pattern is:

```text
research signal
  -> supervisor filter
  -> docs-only doctrine
  -> narrow read-only report
  -> package-local facade/value object
  -> implementation only after evidence
```

The strongest contribution of this lane is not any single proposal. It is the
discipline of separating observation, proposal, implementation readiness, and
mutation.

## Source Set

Primary source:

- `playgrounds/docs/research-horizon/`

Key files:

- `README.md`
- `supervisor-review.md`
- `agent-handoff-protocol.md`
- `interaction-kernel-report.md`
- `runtime-observatory-graph.md`
- `horizon-proposals.md`
- `current-state-report.md`
- `external-expert-scope-update.md`
- `external-expert-synthesis-report.md`
- `interactive-operator-dsl-proposals.md`
- `dsl-repl-authoring-research.md`
- `grammar-compressed-interaction.md`
- `grammar-compression-research-survey.md`
- `line-up-approximation-method.md`
- `contract-persistence-roadmap.md`
- `contract-persistence-development-track.md`
- `igniter-lang-implementation-delta-report.md`
- `insight-scout-log.md`

## Research Lane Map

| Line | Files | Category | Current reading |
| --- | --- | --- | --- |
| Research operating model | `README.md`, `supervisor-review.md` | accepted_canon, value | Research may propose and synthesize; it may not authorize implementation. Supervisor gate is the key invariant. |
| Handoff | `agent-handoff-protocol.md`, `supervisor-review.md` | accepted_canon, implemented, value | Graduated to docs-only Handoff Doctrine. Runtime handoff object remains rejected/deferred. |
| Interaction | `interaction-kernel-report.md`, `supervisor-review.md` | accepted_canon, implemented, value | Graduated to docs-only Interaction Doctrine. Shared interaction package/object remains rejected/deferred. |
| Observatory | `runtime-observatory-graph.md`, `supervisor-review.md` | accepted_canon, implemented, value | Graduated to docs-only Runtime Observatory Doctrine. Global graph/query/runtime object remains rejected/deferred. |
| Horizon proposals | `horizon-proposals.md` | research_unrealized, parked, value | Six proposal families: interaction, observatory, capability market, cells, handoff, planner. Not implementation tracks. |
| External expert synthesis | `external-expert-*.md` | value, parked | Useful corpus filter and priority readout. Expert reports are research inputs, not plan of record. |
| Interactive operator/app DSL | `interactive-operator-dsl-proposals.md`, `dsl-repl-authoring-research.md` | research_unrealized, parked, value | Strong authoring pressure. First safe slice was narrow host/rack ceremony, not broad public DSL. |
| Grammar/Line-Up compression | `grammar-compressed-interaction.md`, `grammar-compression-research-survey.md`, `line-up-approximation-method.md` | research_unrealized, parked, value | Plausible task-specific compression research. Not default handoff protocol. |
| Contract persistence | `contract-persistence-roadmap.md`, `contract-persistence-development-track.md` | implemented, parked, value | App-local/report-first persistence ladder. Current package docs/status must be checked for actual implementation state. |
| Igniter-Lang delta | `igniter-lang-implementation-delta-report.md` | superseded_history, value | Important historical bridge from Ruby DSL/reference backend to later Igniter-Lang work. Superseded by current Igniter-Lang docs. |
| Insight Scout log | `insight-scout-log.md` | value, parked | Useful signal diary. Read as research observations, not as task assignment. |

## Graduated Signals

These Research Horizon ideas already crossed into accepted process memory:

| Research signal | Graduation | What was accepted | What stayed rejected/deferred |
| --- | --- | --- | --- |
| Agent Handoff Protocol | Handoff Doctrine | Ownership transfer under policy with context, evidence, obligations, receipt. | Runtime handoff object, autonomous delegation, AI/provider integration, web transport, cluster routing. |
| Interaction Kernel | Interaction Doctrine | Interaction as affordance + pending state + policy/evidence; application/web/operator/capsule ownership remains separate. | `igniter-interactions`, shared runtime object, workflow engine, browser transport, runtime agent execution. |
| Runtime Observatory Graph | Runtime Observatory Doctrine | Bounded frames over explicit artifacts; nodes/edges/facets/evidence as vocabulary. | Global graph package, query language, graph DB, runtime discovery, mutation, activation, routing, AI execution. |

## Classification Table

| Signal | Category | Current reading |
| --- | --- | --- |
| Supervisor gate | accepted_canon, implemented | The primary research safety mechanism. Keep it. |
| Research as separate lane | accepted_canon, implemented | Research can synthesize and request review; it cannot start implementation. |
| Smallest concrete move filter | accepted_canon, value | Every proposal should identify docs-only/read-only/package-local/execution boundary. |
| Handoff vocabulary | accepted_canon, implemented | Accepted as doctrine/process vocabulary. Runtime object deferred. |
| Interaction vocabulary | accepted_canon, implemented | Accepted as doctrine/process vocabulary. Shared package deferred. |
| Observatory vocabulary | accepted_canon, implemented | Accepted as doctrine/process vocabulary. Runtime graph deferred. |
| Evidence-first architecture | value, parked | Repeated cross-cutting philosophy. Could become named doctrine later. |
| Interaction Kernel package | rejected, parked | Do not create without fresh package pressure. |
| Global Observatory Graph | rejected, parked | Start with one bounded read-only frame if revived. |
| Capability market | research_unrealized, parked | Interesting route diagnostics idea; high overbuild risk. |
| Plastic Runtime Cells | research_unrealized, parked, value | Good long-term noun; no runtime cell manager until capsule/activation/cluster pressure proves need. |
| Constraint-aware planner | research_unrealized, parked, value | Good agent architecture: AI proposes moves on structured board. Start as static report shape only. |
| ActiveAdmin-like DSL | research_unrealized, value | UX north star. First moves must preserve clean-form expansion and package ownership. |
| Top-level `interactive_app` facade | parked, research_unrealized | Not first public API; assemble later from proven lower-level DSLs. |
| DSL/REPL authoring | research_unrealized, value | Good future authoring lane; do not implement until examples/clean-form pressure stabilizes. |
| Grammar compression / Line-Up | research_unrealized, parked, value | Theoretically plausible. Needs measured corpus and semantic score before adoption. |
| Contract persistence ladder | implemented, value, parked | Report-first/store-history pressure is durable; check current `docs/research` and package docs for latest truth. |
| Igniter-Lang foundation pack proposal | superseded_history, value | Historical bridge to later Igniter-Lang compiler/language work. |
| Insight Scout log | value | Useful signal journal, not current context. |

## Values Preserved

- **Research is not authorization**: no package/code/work track without
  supervisor/current acceptance.
- **Doctrine before runtime**: shared vocabulary can land before shared objects.
- **Read-only before action**: reports and frames should precede mutation.
- **Bounded frames beat global models**: one activation/operator/track frame is
  safer than a universal graph.
- **Ownership boundaries matter**: research must not flatten application, web,
  cluster, agent, capsule, and language ownership.
- **Clean-form expansion**: compact DSLs must explain the explicit boring form.
- **Evidence survives compression**: every compressed concept needs source
  evidence, obligations, and forbidden actions.
- **AI is not the architecture**: agents should act on structured protocols,
  not invent hidden runtime behavior.

## Superseded Or Rejected Signals

Do not revive these without a new current decision:

- creating implementation tracks directly from Research Horizon;
- shared runtime handoff object;
- shared runtime interaction object;
- `igniter-interactions` package;
- global observatory graph package/query language;
- graph database or hidden runtime discovery;
- browser/web transport implied by interaction docs;
- host activation or route activation implied by observatory docs;
- autonomous agent execution from handoff/observatory proposals;
- public `interactive_app` facade as first DSL move;
- grammar/Line-Up as required handoff format;
- standalone Igniter-Lang grammar/Rust backend from old delta report;
- treating `insight-scout-log.md` as task assignment.

## Research Still Alive

| Research line | Why alive | Suggested treatment |
| --- | --- | --- |
| Evidence-First Architecture | Repeated philosophy across transfer, activation, observatory, handoff, docs. | Consider docs-only doctrine only if it reduces duplication. |
| Bounded Observatory frame | Supervisor explicitly requested activation-review frame next. | Start with one read-only frame, not global graph. |
| Constraint-aware PlanProposal | Clean way to make AI propose inspectable moves. | Static report shape before any AI provider integration. |
| DSL/REPL authoring | Useful for human and agent authoring workflow. | Compare clean form, compact DSL, generated report, promotion path. |
| Interactive app authoring | Repeated product/app pressure. | Keep narrow: app/rack ceremony first, no broad public DSL. |
| Grammar compression | Strong research basis and metrics. | Expand corpus before protocol adoption. |
| Contract persistence | Important store/history pressure. | Follow current package docs; research-horizon copy is historical. |
| Plastic Runtime Cells | Good composition model over capsules/contracts/policy/surfaces/placement. | Defer until capsule host activation and cluster pressure are stable. |
| Capability market | Useful route explanation extension. | Diagnostics only; avoid economics/runtime scheduling. |

## Rotation Recommendations

No files should be moved or deleted in this stage.

Future approved cleanup can:

1. Keep `README.md` and `supervisor-review.md` as the main orientation pair.
2. Mark `agent-handoff-protocol.md`, `interaction-kernel-report.md`, and
   `runtime-observatory-graph.md` as "graduated to docs-only doctrine" in an
   index, but keep sources.
3. Mark `contract-persistence-*` as historical unless it still matches current
   `docs/research` and package docs.
4. Mark `igniter-lang-implementation-delta-report.md` as superseded by current
   `igniter-lang/` docs.
5. Keep compression/Line-Up docs as research, not process rules.
6. Keep `insight-scout-log.md` cold; summarize new durable values elsewhere
   instead of letting it become required reading.

## Future Agent Read Rule

Default:

1. Read current public/project docs first.
2. Read archive history reports for compressed context.
3. Read `playgrounds/docs/research-horizon/README.md` and
   `supervisor-review.md` only if the task asks about research lineage.
4. Read exact research files only when a current task names that concept.

Fast path by question:

- handoff: `agent-handoff-protocol.md` plus current Handoff Doctrine if present;
- interaction: `interaction-kernel-report.md` plus current Interaction Doctrine;
- observatory: `runtime-observatory-graph.md` plus current Observatory Doctrine;
- app DSL: `interactive-operator-dsl-proposals.md`,
  `dsl-repl-authoring-research.md`;
- compression: grammar/Line-Up files;
- persistence: `contract-persistence-*`, then current package docs;
- broad horizon: `horizon-proposals.md` and `supervisor-review.md`.

## Stage-Close Handoff

Compact claim:

- Research Horizon is a disciplined filter. Its accepted durable outputs are
  docs-only handoff, interaction, and observatory doctrines. Its remaining
  proposals are valuable research/pressure, not current roadmap.

Source set:

- `playgrounds/docs/research-horizon/`
- `playgrounds/docs/experts/` cross-reference through S4 only

Categories applied:

- `accepted_canon`
- `implemented`
- `superseded_history`
- `research_unrealized`
- `rejected`
- `parked`
- `value`

Values preserved:

- research is not authorization
- doctrine before runtime
- read-only before action
- bounded frames before global models
- ownership boundaries
- clean-form expansion
- evidence survives compression
- AI is not the architecture

Accepted/implemented signals:

- Research Horizon lane
- supervisor gate
- Handoff Doctrine
- Interaction Doctrine
- Runtime Observatory Doctrine
- compact handoff shape

Superseded/rejected signals:

- research docs as implementation tracks
- shared runtime handoff/interaction/observatory objects
- global graph/query package
- autonomous agent execution from research docs
- broad public `interactive_app` facade as first move
- grammar compression as default process
- old Igniter-Lang delta as current plan

Research still alive:

- Evidence-First Architecture
- bounded observatory frame
- PlanProposal / constraint-aware planner
- DSL/REPL authoring
- interactive app authoring
- grammar compression
- contract persistence lineage
- Plastic Runtime Cells
- capability market diagnostics

Duplicate/rotation recommendations:

- keep all research-horizon Markdown for now
- add graduated/source status markers later if approved
- treat `contract-persistence-*` and Igniter-Lang delta as historical unless
  current docs confirm them
- keep Insight Scout cold

Unresolved questions:

- Should Evidence-First Architecture become a named doctrine?
- Should the next research promotion be bounded observatory frame or app DSL
  authoring?
- Should old contract persistence research be cross-linked to current package
  docs or moved deeper?

Changed files:

- `igniter-lang/docs/archive/history/history-s5-research-horizon-compression-map.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

- `History-S6: dev tracks/process legacy map`, focused on
  `playgrounds/docs/dev/`.
