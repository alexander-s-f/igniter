# External Expert Synthesis Report

Status: Research Horizon synthesis.

Date: 2026-04-27.

Source: `docs/experts/`.

Audience: project owner and `[Architect Supervisor / Codex]`.

## Executive Read

The external expert corpus has converged on a strong thesis:

```text
Igniter is not only a Ruby graph/contract gem.
It is becoming a platform for long-lived, agent-native, interactive applications
with verifiable execution, portable capsules, and eventually a contract-native
language layer.
```

The reports are unusually coherent. They independently reinforce the same
pressure points:

- the contracts kernel is the mature differentiator
- application/web/agent authoring is the adoption bottleneck
- `Igniter.interactive_app` or equivalent facade is the critical DX move
- flows, durable sessions, SSE/live updates, and receipts are the next shared
  platform primitives
- capsule transfer is not deployment glue; it is an enterprise trust/supply-chain
  story
- the docs-agent workflow is already a working multi-agent protocol in prose
- Igniter-Lang is plausible, but grammar should follow proven Ruby DSL semantics
- science/robotics/space/medicine validate the model beyond enterprise SaaS

The main caution: the expert corpus is visionary and broad. It should not be
treated as accepted roadmap. Its value is in prioritization, vocabulary
pressure, and long-range orientation. Graduation still belongs to
`[Architect Supervisor / Codex]`.

## Corpus Map

The external expert work now falls into nine clusters.

### 1. Strategic Platform Reports

Files:

- `expert-review.md`
- `igniter-strategic-report.md`
- `igniter-implementation-delta.md`

Core claim:

- Igniter's unique niche is "agent-native interactive applications with
  compile-time validated business logic and verifiable supply chain."
- The architecture is strong; the missing surface is adoption-grade authoring.
- A public showcase is as important as another internal primitive.

Key recommendations:

- make `Igniter.interactive_app` real
- turn `examples/companion` or a similar app into a real flagship
- add first-class SSE/live update support
- close evidence/receipt and activation story
- write enterprise positioning once, clearly

Research Horizon read:

- This is the clearest product/strategy spine.
- It is also the strongest warning against endless design tracks without shipped
  examples.

### 2. Interactive App Authoring

Files:

- `interactive-app-dsl.md`
- `interactive-operator-dsl-proposals.md` as internal companion

Core claim:

- The developer should declare an app inventory: services, agents, surfaces,
  flows, endpoints, actions.
- Domain words should beat transport words.
- The compact form must expand to boring Ruby owned by packages.

Important vocabulary:

- `service`
- `agent`
- `surface`
- `zone`
- `stat`
- `collection`
- `chat`
- `flow`
- `step`
- `endpoint`
- `action`

Research Horizon read:

- This aligns strongly with the ActiveAdmin-like direction.
- The safest implementation path remains layered: Application owns services and
  environment, Web owns surfaces/flows/components, Agents own actor behavior,
  Host/Rack owns endpoint transport.

### 3. UI Kit And Plane

Files:

- `igniter-ui-kit.md`
- `igniter-plane.md`

Core claim:

- Interactive agent apps need visual primitives that standard UI kits do not
  provide: agent presence, proposals, evidence, delegation, decisions, temporal
  events, handoff.
- Igniter Plane is a future living graph canvas over Runtime Observatory.

Research Horizon read:

- UI Kit should be treated as `igniter-web` research input, not immediate package
  work.
- Plane should stay far-horizon until Runtime Observatory has read-only node/edge
  vocabulary and mock frames.
- The strongest near-term extraction is vocabulary, not canvas runtime.

### 4. Agent Protocol And Development Cycle

Files:

- `agent-track-pattern.md`
- `agent-cycle-optimization.md`
- `documentation-compression.md`
- `concept-emergence.md`

Core claim:

- The docs-agent system is already an agent runtime protocol in prose.
- Track files behave like contracts; agents are executors; Supervisor is the
  gate; handoffs are outputs.
- Documentation needs cache-like lifecycle rules: TTL, fingerprint,
  invalidation, eviction.
- Concept mining shows repeated patterns can be named and compressed.

Measured / concrete signals:

- `tracks.md`-style active/history reading can waste large context windows.
- Line-Up style handoffs and named constraint sets have immediate compression
  value.
- `no_sse`, `ownership_transfer`, `supervisor_acceptance`, and `no_mutation`
  appear as dominant atoms in the docs corpus.

Research Horizon read:

- This cluster is operationally important. It can reduce agent cost and latency
  before runtime agents exist.
- It should go through Supervisor because it touches `docs/dev` workflow.

### 5. Grammar, Compression, Semantic Gateway

Files:

- `compression-experiment.md`
- `semantic-gateway.md`
- related Research Horizon grammar/Line-Up docs

Core claim:

- Agent-to-agent handoff compression is economically justified when session
  length is high enough.
- The measured break-even in the experiment is around 8 messages/session.
- Human-to-agent compression is different: the small local model is an
  interpreter, not just a compressor.
- Semantic Gateway turns natural language into structured intent packets, routes
  to agents, and shows a transparency preview before expensive calls.

Important insight:

- For agent-agent compression, `forbid` / constraint lists are the highest-value
  target.
- For human-agent interaction, the value is latency, relevance, routing, and
  misunderstanding prevention.

Research Horizon read:

- Keep Line-Up parser/runtime out of scope.
- Next research should be extended measured corpora and modality:
  `must`, `should`, `may`, `forbid`.
- Semantic Gateway is promising but should remain experimental until a reference
  app has real interaction pressure.

### 6. Capsules, Supply Chain, Runtime Cells

Files:

- `capsule-transfer-expert-report.md`
- `plastic-runtime-cells.md`

Core claim:

- Capsule transfer is a trust boundary and receipt chain, not just packaging.
- Transfer receipt and activation receipt must remain separate.
- A Runtime Cell is the minimal portable unit of agency: capsule + contracts +
  interfaces + credential policy + operator surface + optional placement.

Research Horizon read:

- Capsule transfer deserves enterprise positioning.
- Plastic Runtime Cells are a valid long-horizon synthesis, but not a code track.
- The first useful move is vocabulary and mapping to existing capsule/activation
  artifacts.

### 7. Product/Application Proposals

Files:

- `application-proposals.md`
- `application-proposals-non-tech.md`
- `application-proposals-logistics-hvac.md`

Core claim:

- Igniter can express valuable apps across developer, consumer/prosumer,
  creator, enterprise, logistics, and field-service markets.
- The common pattern is long-lived task lifecycle + human/agent decision points
  + receipt/audit trail + live surface.

Proposed examples:

- IT/developer: Dispatch, Lense, Scout, Aria, Chronicle
- non-technical: Forma, Meridian, Studio, Signal, Blueprint, Accord
- vertical: Convoy, Freight, Field, Nexus

Research Horizon read:

- Lense is the lowest-delta showcase according to the implementation delta.
- Dispatch, Scout, and Convoy demonstrate Igniter's distinctive agent/flow/live
  surface strengths more dramatically.
- Product proposals should be used to pressure the platform roadmap, not all
  implemented at once.

### 8. Science / Robotics / Space / Medicine Validation

Files:

- `igniter-science-critical.md`

Core claim:

- Igniter primitives generalize beyond enterprise: reproducible science,
  robotics safety loops, spacecraft telemetry/rules, and medical dosing/audit
  all want typed dependency graphs, invariants, history, temporal rules, and
  uncertainty propagation.

Platform insights:

- physical unit types
- invariant severity levels
- deadline contracts / WCET pressure
- uplink-able rule declarations
- certified graph export
- uncertainty propagation through contract graphs

Research Horizon read:

- This is the strongest validation that Igniter's model is more general than
  business workflow.
- It also warns that serious domains need formal verification, units,
  deadlines, and certified exports before they can be claimed responsibly.

### 9. Igniter-Lang Research Series

Files:

- `igniter-lang/`

Core claim:

- Igniter's contract model can be the semantic foundation of a contract-native
  language.
- The theoretical backing includes attribute grammars, concurrent constraint
  programming, stratified Datalog, category theory, refinement types, situation
  calculus, and bitemporal models.
- The current frontier is not a standalone grammar; it is Ruby DSL as reference
  implementation plus explicit backend interface.

Key ideas:

- Semantic Information Ratio: contract-native language should reduce host
  language boilerplate.
- `Backend` interface: `compile`, `execute`, `verify`, `export`.
- Future backends: Ruby now, Rust later for WCET/certification/formal export.
- Extension groups: `store`, `History[T]`, `BiHistory[T]`, `OLAPPoint`,
  `invariant` metadata, `rule`, physical units, `deadline`, `time_machine`.

Research Horizon read:

- This is frontier research, not near-term product surface.
- The best immediate adoption is "grammar after semantics" discipline.
- Ruby DSL friction should be logged as evidence before freezing a new grammar.

## Cross-Cutting Insights

### 1. The App Is The Product Boundary

Across all reports, the app-level declaration is the missing unifier. Contracts,
services, agents, surfaces, flows, endpoints, sessions, and receipts need to
read as one application inventory.

Implication:

- Continue the ActiveAdmin-like exploration, but keep clean-form expansion and
  package ownership explicit.

### 2. Evidence Is The Trust Substrate

Evidence appears everywhere:

- handoff evidence
- interaction evidence
- observatory evidence
- capsule transfer receipts
- activation evidence
- science reproducibility
- medical audit trail
- agent-reviewer pattern

Implication:

- `Evidence-First Architecture` deserves a dedicated doctrine candidate.

### 3. Live Systems Need Streams, Not Only Reports

Current Igniter research is strong on read-only reports. Expert work stresses
live updates: agents wake, sessions wait, flows change, exceptions arrive, users
need immediate feedback.

Implication:

- SSE/live update primitives should become a first-class pressure point after
  the application facade seam is stable.

### 4. Docs-Agent Workflow Is A Prototype Runtime

The project's docs process already has:

- roles
- tracks
- gates
- handoffs
- constraints
- verification
- archives
- parallel windows

Implication:

- The future `igniter-agents` design can validate against this living protocol
  before inventing new abstractions.

### 5. Vocabulary Sprawl Is The Main Tax

The expert corpus adds many useful terms, but also increases naming pressure:
surface, screen, board, flow, wizard, route, endpoint, stream, feed, cell, capsule,
receipt, evidence, track, handoff, Line-Up, Plane, UI Kit, Lang.

Implication:

- Supervisor should eventually choose a core vocabulary set and mark the rest as
  advanced or research-only.

## Priority Readout

### Immediate Candidate Decisions

These are strong enough for near supervisor review:

- Accept the external expert corpus as research input.
- Decide whether ActiveAdmin-like app authoring remains the north star.
- Choose whether `Application Rack Host DSL` is the first narrow implementation
  slice.
- Decide whether to create an `Evidence-First Architecture` doctrine.
- Decide whether to formalize `Agent Track Pattern` docs-only before optimizing
  `docs/dev` workflow.
- Decide whether grammar compression gets an expanded corpus experiment.

### Near-Term Platform Pressure

These appear repeatedly across product and expert reports:

- `Igniter.interactive_app` / `operator_app` facade
- `flow` / `step` DSL
- durable session store
- SSE endpoint and live snapshot push
- receipt type system
- proactive agent wakeup
- named action/result semantics

### Long-Horizon Research

Keep research-only for now:

- Igniter Plane canvas runtime
- full UI Kit package implementation
- Plastic Runtime Cells as runtime object
- Line-Up parser/grammar runtime
- native Agent Track compiler
- standalone Igniter-Lang grammar
- Rust backend / certified export

## Recommended Supervisor Queue

1. **Interactive App Authoring Review**
   Review `docs/research-horizon/interactive-operator-dsl-proposals.md` together
   with `docs/experts/interactive-app-dsl.md` and
   `docs/experts/igniter-implementation-delta.md`.

2. **Evidence-First Doctrine Decision**
   Decide whether to open a docs-only doctrine track for Evidence-First
   Architecture.

3. **Docs-Agent Protocol Optimization Decision**
   Review `agent-track-pattern.md`, `agent-cycle-optimization.md`, and
   `documentation-compression.md` before any `docs/dev` process changes.

4. **Compression Experiment Expansion**
   Approve or reject a 10-15 case Line-Up corpus expansion with modality fields.

5. **Plastic Cells Synthesis**
   Decide whether Research Horizon should create an internal synthesis based on
   `plastic-runtime-cells.md`.

6. **Reference App Choice**
   Choose which app acts as the showcase pressure test: Lense for lowest delta,
   Dispatch/Scout for agent workflow drama, or Companion if it remains the
   flagship.

## Risks

- **Roadmap inflation**: the expert corpus proposes more than one team can build
  quickly.
- **Vocabulary inflation**: useful names can become user-facing API too early.
- **Research debt**: docs-only doctrines can accumulate without implementation
  pressure.
- **Showcase delay**: without a real app, the architecture remains invisible.
- **Premature language work**: Igniter-Lang is plausible, but grammar before
  stable DSL semantics would freeze the wrong shape.
- **Overclaiming critical domains**: robotics/medicine/space require units,
  deadlines, uncertainty, certification, and formal export before serious claims.

## Research Horizon Position

Research Horizon should adopt the expert corpus as a strong external lens, not
as a plan of record.

The updated stance:

```text
Use expert work to find convergence.
Use Supervisor to narrow convergence into tracks.
Use examples to validate tracks.
Use clean-form expansion to keep the system honest.
```

The most valuable strategic synthesis is:

```text
Igniter's short-term adoption depends on interactive app authoring and a real
showcase.

Igniter's long-term defensibility depends on evidence-first execution,
capsule/receipt supply chain, and contract-language semantics.
```

## Compact Handoff

```text
[Research Horizon / Codex]
Track: docs/research-horizon/external-expert-synthesis-report.md
Status: synthesis / needs supervisor filter
Changed:
- Added consolidated report over docs/experts.
Core idea:
- Expert corpus converges on Igniter as agent-native interactive app platform.
- Near-term bottleneck is app authoring + showcase + live flows.
- Long-term moat is evidence-first contracts, capsules, and language semantics.
Recommended graduation:
- Supervisor should choose which expert proposals become docs-only or package
  tracks.
Risks:
- Roadmap/vocabulary inflation and premature implementation of frontier ideas.
Needs:
- [Architect Supervisor / Codex] accept / reject / prioritize / narrow.
```
