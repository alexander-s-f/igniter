# Horizon Proposals

Audience: project owner first; later candidates for `[Architect Supervisor /
Codex]` review.

Status: research proposals, not accepted implementation tracks.

## North Star

Igniter can become a distributed agent application substrate:

- contracts define executable truth
- application capsules define portable boundaries
- web surfaces define human interaction affordances
- operator planes define accountable workflow control
- cluster plans define explainable distributed movement
- AI agents participate through typed sessions, tools, policies, and handoffs

The long-range opportunity is not "AI inside apps." It is a decentralized
Human <-> AI Agent interface where humans, agents, services, and nodes all act
through inspectable contracts.

## Proposal A: Interaction Kernel

Thesis:

Create a small cross-package interaction contract that sits above contracts and
below web/agents/operator UI. It should describe pending work in a form that
humans, agents, and cluster operators can all inspect.

Candidate vocabulary:

- `InteractionIntent`
- `InteractionRequest`
- `InteractionResponse`
- `InteractionPolicy`
- `InteractionTrace`
- `ParticipantRef`

Why now:

- application already has `FlowSessionSnapshot`, `FlowEvent`, `PendingInput`,
  `PendingAction`, and `ArtifactReference`
- web already emits pending interaction metadata
- operator surfaces already need common action language
- future agents need something richer than chat messages

Concrete first slice:

- read-only normalizer from application flow snapshots and web surface
  interactions into a shared interaction report
- no execution, browser transport, AI runtime, or cluster routing
- use it first in docs/examples and maybe `examples/companion`

Architect review question:

Should this live in `igniter-application`, `igniter-extensions`, or a future
`igniter-interactions` package? My bias: start in application as a report shape,
promote only after two packages consume it.

## Proposal B: Runtime Observatory Graph

Thesis:

Represent runtime state as a queryable observation graph rather than separate
status hashes per layer. This graph would unify sessions, capsule state,
operator actions, cluster plans, mesh attempts, tool loops, and agent events.

Candidate vocabulary:

- `ObservationNode`
- `ObservationEdge`
- `ObservationFacet`
- `ObservationFrame`
- `ObservationQuery`

Why this matters:

- agents need situational awareness before acting
- operators need explainability without reading every subsystem's custom report
- cluster diagnostics already produce rich traces
- app capsule transfer reports already contain reviewable state

Concrete first slice:

- build a read-only report adapter over existing application/session/operator
  and cluster plan reports
- expose dimensions such as `kind`, `owner`, `status`, `capability`, `route`,
  `policy`, `risk`, `pending`, and `requires_human`
- do not invent a full MeshQL yet

Research insight:

This is the bridge between graph theory and AI operations. An agent should be
able to ask: "What nodes are blocked, who owns them, what policies constrain
them, and what action has the highest expected value?"

## Proposal C: Capability Market And Game-Theoretic Routing

Thesis:

Cluster routing can evolve from capability matching into a local capability
market where peers publish capacity, trust posture, cost, latency, data
locality, credential ownership, and risk. Routing becomes an explainable
decision under constraints rather than a simple peer lookup.

Candidate vocabulary:

- `CapabilityOffer`
- `CapabilityDemand`
- `RouteBid`
- `UtilityFunction`
- `RiskBudget`
- `SettlementTrace`

Why this fits Igniter:

- `CapabilityQuery`, `PeerProfile`, policy objects, and decision explanations
  already exist
- credential policy already biases toward local secret ownership
- future AI agents will need principled node/tool selection

Concrete first slice:

- extend route explanation docs/examples with a utility-score report
- no economic/payment implementation
- no consensus requirement
- score route options by capability fit, locality, trust, load, and credential
  policy

Risk:

Avoid turning this into over-engineered scheduling. Start as diagnostics over
existing route candidates.

## Proposal D: Plastic Runtime Cells

Thesis:

Use "cell" as a conceptual unit for portable, self-describing runtime capacity:
a capsule plus contracts, declared interfaces, credential policy, operator
surface, and optional cluster placement constraints.

Candidate vocabulary:

- `RuntimeCell`
- `CellBoundary`
- `CellInterface`
- `CellPolicy`
- `CellMutationPlan`
- `CellHealth`

Why this is interesting:

- application capsules already handle portability and transfer
- cluster owns placement, ownership, and failover planning
- web surfaces can travel as optional interaction layers
- AI agents need bounded workspaces they can inspect and modify safely

Concrete first slice:

- research doc mapping existing capsule reports to a future cell model
- identify missing fields: policy, owner, lifecycle, allowed mutations,
  observability, trust/admission requirements
- no implementation until capsule transfer and host integration stabilize

Long-range vision:

A system can split into cells, move cells, replicate cells, or invite agents
into cells under explicit constraints. This is distributed plasticity with
audit trails.

## Proposal E: Agent Handoff Protocol

Thesis:

Turn the existing documentation handoff protocol into a runtime-facing handoff
contract for agents and humans.

Current inspiration:

`docs/dev/tracks.md` already requires:

- role label
- track
- changed files
- accepted/ready status
- verification
- needs / next decision

Candidate runtime shape:

- `HandoffRequest`
- `HandoffManifest`
- `HandoffReceipt`
- `HandoffDecision`
- `HandoffTrace`

Why this matters:

- application capsule transfer already has handoff manifests and receipts
- operator workflow already supports handoff language
- AI agents need structured delegation and review
- Architect Supervisor review already works as a governance checkpoint

Concrete first slice:

- write a proposal that maps docs-agent handoff, application capsule handoff,
  and operator handoff into one vocabulary
- keep implementation deferred

Insight:

Handoff is the primitive that connects distributed systems and AI collaboration.
It is ownership transfer under policy with context, evidence, and receipt.

## Proposal F: Constraint-Aware Agent Planner

Thesis:

Before rebuilding `igniter-ai` and `igniter-agents`, define the planner shape
as a constraint solver over contracts, tools, sessions, policies, and runtime
observations.

Candidate inputs:

- goal
- available contracts/tools/skills
- session state
- operator policies
- credential constraints
- cluster route candidates
- risk budget

Candidate outputs:

- plan graph
- required approvals
- tool calls
- route demands
- expected blockers
- fallback strategies
- explanation

Concrete first slice:

- no AI provider integration
- define a static `PlanProposal` report shape for `examples/companion`
- let a human or simple rule engine produce it first

Why this is powerful:

The AI model should not be the architecture. The architecture should provide a
structured game board where AI can propose moves and humans/systems can inspect
constraints before execution.

## Proposed Priority

Near term:

1. Agent Handoff Protocol research synthesis
2. Interaction Kernel read-only report
3. Runtime Observatory Graph read-only adapter

Mid term:

4. Constraint-Aware Agent Planner in `examples/companion`
5. Capability Market diagnostics over cluster routing

Later:

6. Plastic Runtime Cells after capsule host integration is stable

## Candidate Handoff To Architect Supervisor

Do not send automatically. Use only after owner approval.

```text
[Research Horizon / Codex]
Track: Research Horizon proposals
Changed: docs/research-horizon/README.md,
docs/research-horizon/current-state-report.md,
docs/research-horizon/horizon-proposals.md
Accepted/Ready: ready for conceptual review, not implementation
Verification: documentation-only; no test run required
Needs: [Architect Supervisor / Codex] review of which, if any, proposal should
graduate into docs/dev as a narrow track. Recommended first review: Agent
Handoff Protocol or Interaction Kernel.
```

