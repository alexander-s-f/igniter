# External Expert Scope Update

Status: Research Horizon scope update.

Date: 2026-04-25.

Source: `docs/experts/`.

Customer: project owner.

## Why This Exists

The external expert reports in `docs/experts/` are now part of the Research
Horizon input stream. They do not override `[Architect Supervisor / Codex]`,
and they do not create implementation tracks by themselves. They sharpen the
research scope and identify which ideas deserve supervisor filtering.

The strongest external signal is:

```text
Igniter is becoming an interactive agent application platform.
The missing bridge is compact application-level authoring that expands into
boring, inspectable package-owned Ruby.
```

## Updated Research Horizon Scope

Research Horizon now tracks six connected lanes:

1. Interactive agent application authoring.
2. Agent protocol / doc-agent runtime formalization.
3. Evidence-first architecture and graduated trust.
4. Context compression and Line-Up economics.
5. Runtime observability, Plane, and UI Kit interaction surfaces.
6. Plastic Runtime Cells as portable distributed agency units.

This updates the earlier scope without replacing it. Contracts, capsules,
web, cluster, mesh, and Human <-> AI Agent interfaces remain central. The new
emphasis is that these pieces should converge into an authorable interactive
agent environment.

## Expert Documents Reviewed

### `expert-review.md`

Core insight:

- Igniter has strong contracts/application/web/cluster primitives.
- The emerging product is not chat; it is a long-lived interactive agent
  environment.
- The current gap is first-class authoring glue.

Research Horizon adoption:

- Treat `interactive_app` / `operator_app` authoring as a primary research
  lane.
- Keep the app-level DSL application-first, not Rails/resource/CRUD-first.
- Preserve compile-time validation and clean-form expansion as non-negotiable.

### `interactive-app-dsl.md`

Core insight:

- The desired DSL declares services, agents, surfaces, flows, endpoints, and
  actions in one compact app inventory.
- Domain words should beat transport words.
- Every compact form must expand to package-owned clean form.

Research Horizon adoption:

- Use this as the strongest external companion to
  `interactive-operator-dsl-proposals.md`.
- Watch these vocabulary candidates: `service`, `agent`, `surface`, `zone`,
  `stat`, `collection`, `chat`, `flow`, `step`, `endpoint`, `action`.
- Keep package ownership explicit: application owns services/profile/env, web
  owns surfaces/flows/components, agents own actors/tools/wakeups, host owns
  endpoints/feeds.

### `igniter-ui-kit.md`

Core insight:

- Interactive agent apps need UI primitives for asynchronous agency, evidence,
  proposals, handoff, uncertainty, and temporal state.
- Existing UI kits do not model "agent colleague doing work over time."

Research Horizon adoption:

- Treat UI Kit as future `igniter-web` research, not current implementation.
- Connect it to Interaction Doctrine, Handoff Doctrine, and Runtime Observatory.
- Track visual primitives: `agent_presence`, `proposal_block`,
  `evidence_block`, `decision_point`, `delegation_block`, `timeline_event`.

### `igniter-plane.md`

Core insight:

- Igniter Plane is the interactive visual layer over the Runtime Observatory
  Graph: a navigable living graph of contracts, agents, sessions, services,
  events, data, peers, and decisions.

Research Horizon adoption:

- Treat Plane as a long-range visualization lane over Observatory, not a new
  runtime owner.
- Keep first graduation read-only: node/edge vocabulary and mock observation
  frames before any canvas runtime.
- Connect Plane to trust gradients, evidence quality, and temporal replay.

### `research-horizon-analysis.md`

Core insight:

- Research Horizon is strong because it separates research from implementation.
- Missing pieces: Plastic Runtime Cells synthesis, temporal/replay research,
  live system streams, cross-agent coordination protocols, and measurement of
  doc-agent performance.
- The docs-agent protocol is already a runtime protocol in disguise.

Research Horizon adoption:

- Name Evidence-First Architecture as a candidate doctrine.
- Add doctrine age / graduation pressure as a watch item.
- Treat the agent rebuild as a critical-path risk for validating handoff,
  interaction, observatory, UI Kit, and Plane work.
- Explore protocol semantic versioning, trust gradients, capability budgets,
  and temporal replay as agent context injection.

### `plastic-runtime-cells.md`

Core insight:

- A Runtime Cell is the smallest portable unit of agency: capsule + contracts +
  interfaces + credential policy + operator surface + optional placement.
- Plasticity operations are move, replicate, split, merge, hand off, retire.

Research Horizon adoption:

- Treat this as the missing synthesis for Horizon Proposal D.
- Do not implement cells yet.
- First possible graduation should be a research-horizon synthesis or docs-only
  doctrine that maps cells to existing capsule/activation/cluster artifacts.

### `compression-experiment.md`

Core insight:

- Line-Up compression on real Igniter handoff messages averaged 1.31x per
  message with 8/8 semantic preservation.
- Break-even appears around 8 messages per session.
- `forbid` / constraint lists are the best first compression target.
- Modality is the key gap: `must`, `should`, `may`, `forbid`.

Research Horizon adoption:

- Promote compression from theory to measured research.
- Next research move should be an extended 10-15 case corpus, not a parser.
- Add modality-qualified constraints to future Line-Up sketches.

### `agent-cycle-optimization.md`

Core insight:

- The current docs-agent cycle wastes context by reading large active/history
  track files.
- Highest-impact operational change is active/archive split for tracks.
- Micro handoffs, named constraint sets, parallel windows, graduated
  verification, and retirement protocol reduce token cost and latency.

Research Horizon adoption:

- Treat this as operational architecture for the docs-agent system.
- Do not modify `docs/dev/tracks.md` from Research Horizon without Supervisor.
- Recommend Supervisor review of active/archive split and compact handoff
  format.

### `agent-track-pattern.md`

Core insight:

- The docs-agent protocol is an Igniter contract graph running on language
  models as executors.
- Track, Task, Window, Signal, AgentRole, ConstraintSet, Handoff, and
  AcceptanceRecord can be formalized now.

Research Horizon adoption:

- Add Agent Track Pattern to the future runtime-agent research lane.
- Use it as the bridge between docs-agent workflow and future
  `igniter-agents`.
- Keep implementation graduation staged: structured docs first, index generator
  later, validator later, native track compiler much later.

## Updated Watch Areas

Immediate watch:

- ActiveAdmin-like interactive app authoring.
- Application Rack Host DSL as first narrow implementation slice.
- Evidence-First Architecture doctrine candidate.
- Agent Track Pattern and docs-agent context shrinkage.
- Grammar compression extended corpus and modality fix.

Near horizon:

- `flow` / `chat` / proactive agent declaration as future authoring primitives.
- UI Kit component vocabulary for agent presence, evidence, proposals, and
  decision points.
- Temporal replay as agent context injection.
- Trust gradients for evidence in Observatory/Plane.

Far horizon:

- Igniter Plane over Runtime Observatory.
- Plastic Runtime Cells as distributed agency units.
- Capability budgets for agent planning.
- Cross-agent coordination protocols: negotiation, consensus, broadcast,
  rendezvous.

## Supervisor-Facing Recommendations

Recommended for near review:

- Review `interactive-operator-dsl-proposals.md` together with
  `docs/experts/interactive-app-dsl.md`.
- Consider a narrow `Application Rack Host DSL Track` only after accepting the
  ActiveAdmin-like north-star vocabulary.
- Consider a docs-only `Evidence-First Architecture Doctrine`.
- Consider a docs-only `Agent Track Pattern` or `Agent Cycle Optimization`
  review before changing active track workflow.
- Accept compression experiment as research input and request an expanded
  corpus, not parser/runtime work.
- Treat `plastic-runtime-cells.md` as input for a missing Research Horizon
  synthesis.

Not recommended yet:

- Building Plane/canvas runtime.
- Building UI Kit as package code.
- Building Line-Up parser or grammar runtime.
- Building native Track compiler.
- Committing to a public `Igniter.interactive_app` API before package-owned
  clean-form expansion is proven.

## Research Horizon Operating Rule

When using `docs/experts/`:

- quote it as external input, not accepted architecture
- extract signals into Research Horizon documents
- route implementation implications through `[Architect Supervisor / Codex]`
- prefer docs-only synthesis before any package code
- preserve the evidence-first sequence: observe, inspect, review, then act

## Compact Handoff

```text
[Research Horizon / Codex]
Track: docs/research-horizon/external-expert-scope-update.md
Status: scope update / external expert intake
Changed:
- Added Research Horizon scope update based on docs/experts.
Core idea:
- Interactive agent app authoring is now the primary convergence lane.
- Doc-agent protocol is a runtime protocol in disguise.
- Evidence-first, compression, Plane/UI Kit, and Runtime Cells become explicit
  watch lanes.
Recommended graduation:
- Supervisor review for which expert proposals become docs-only tracks.
Risks:
- Treating expert proposals as accepted architecture too early.
- Vocabulary sprawl from adding every proposed term at once.
Needs:
- [Architect Supervisor / Codex] accept / reject / narrow / prioritize.
```
