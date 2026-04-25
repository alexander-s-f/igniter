# Runtime Observatory Graph

Status: research synthesis for `[Architect Supervisor / Codex]`.

Date: 2026-04-25.

This document proposes a research-only read-only adapter concept. It does not
create a query language, package, runtime object, graph database, cluster
routing behavior, host activation behavior, browser transport, or AI provider
integration.

## Thesis

Igniter is accumulating many explicit runtime and review artifacts:

- contract execution reports
- flow session snapshots
- web surface manifests
- handoff manifests
- transfer receipts
- activation readiness and plans
- operator/orchestration read models
- cluster plans and mesh traces
- governance, placement, remediation, and observation reports

Each artifact is useful locally. The next research question is whether a
read-only observatory graph can adapt these existing artifacts into one
inspectable field without replacing package ownership or inventing a new
runtime.

The goal is situational awareness.

## What This Is

Runtime Observatory Graph is a conceptual adapter over explicit artifacts.

It answers questions like:

- what is pending?
- who owns it?
- what evidence supports it?
- what policy constrains it?
- what surface can show it?
- what session or receipt proves current state?
- what is blocked?
- what is ready only for review?
- what must not execute?

It should start as a report shape or doctrine, not a database or query
language.

## What This Is Not

Not accepted:

- generalized observation query language
- MeshQL replacement
- graph database
- new package
- shared runtime object
- cluster routing or placement
- host activation
- browser/web transport
- AI provider calls
- autonomous agent execution
- hidden project discovery
- mutation of any source artifact

## Existing Inputs

### Handoff Artifacts

From Handoff Doctrine:

- subject
- sender
- recipient
- context
- evidence
- obligations
- receipt
- trace

Observation role:

Handoff artifacts describe ownership transitions and review obligations.

### Interaction Artifacts

From Interaction Doctrine:

- subject
- participant
- affordance
- pending state
- surface context
- session context
- policy context
- evidence
- outcome

Observation role:

Interaction artifacts describe what participants can do, provide, inspect, or
observe.

### Application Capsule Review Chain

Inputs:

- capsule reports
- composition readiness
- assembly plans
- handoff manifests
- transfer inventory/readiness/bundle/apply/receipt reports
- host activation readiness/plans/verification

Observation role:

Capsule artifacts describe portability, readiness, blockers, manual actions,
and future host responsibility without activation.

### Operator And Orchestration Read Models

Inputs:

- operator query records
- orchestration overview/summary
- action history
- handoff history
- runtime/session lifecycle fields
- lane/queue/channel/assignee metadata

Observation role:

Operator artifacts describe accountable pending work and allowed review
actions.

### Cluster And Mesh Artifacts

Inputs from current cluster direction:

- peer observations
- capability queries
- placement decisions
- rebalance plans
- lease/failover/remediation plans
- mesh execution traces
- governance trail/checkpoints
- route/placement/admission explanations

Observation role:

Cluster artifacts describe capability fit, trust, topology, policy, workload,
governance, and distributed plan evidence.

## Tiny Vocabulary

These are conceptual terms, not proposed class names.

### Observation Node

A normalized view of an explicit source artifact or sub-artifact.

Examples:

- flow session
- pending input
- operator item
- capsule transfer receipt
- activation plan operation
- mesh attempt
- placement decision

### Observation Edge

A relationship between observed nodes.

Examples:

- `owns`
- `blocks`
- `requires`
- `evidenced_by`
- `shown_on`
- `derived_from`
- `handoff_to`
- `resumes`
- `routes_to`
- `forbids`

### Observation Facet

A filterable dimension.

Examples:

- kind
- owner
- status
- lifecycle
- policy
- capability
- trust
- route
- surface
- pending
- risk
- requires_human
- executable
- review_only

### Observation Frame

A bounded snapshot for one review or decision context.

Examples:

- "operator overview for one execution"
- "capsule transfer closure"
- "activation readiness and plan"
- "cluster placement decision"
- "research handoff review"

### Observation Evidence

The source proof behind an observation.

Examples:

- source document
- report hash
- event history
- action history
- verification command
- mesh trace
- receipt count

## Candidate Read-Only Shape

A future report could be:

```ruby
{
  frame: {},
  nodes: [],
  edges: [],
  facets: {},
  evidence: [],
  blockers: [],
  warnings: [],
  metadata: {}
}
```

This is a report shape, not a runtime object.

Rules:

- consume explicit artifacts or hashes only
- preserve source references
- do not mutate
- do not execute
- do not infer hidden project state
- do not inspect web internals from application
- do not route or activate

## Example: Activation Review Frame

Inputs:

- transfer receipt
- handoff manifest
- host activation readiness
- host activation plan

Possible nodes:

- capsule
- host
- manual action
- load path confirmation
- provider confirmation
- mount-intent review
- blocker
- receipt

Possible edges:

- capsule `requires` host export
- activation plan `derived_from` readiness
- mount-intent operation `shown_on` web surface metadata
- blocker `forbids` execution
- receipt `evidenced_by` applied verification

Important:

This does not activate the host. It only lets a human or agent see the review
field.

## Example: Operator Runtime Frame

Inputs:

- flow/session snapshot
- operator query records
- orchestration overview
- action history

Possible nodes:

- session
- pending input
- pending action
- operator item
- lane
- assignee
- latest action

Possible edges:

- pending action `shown_on` operator surface
- operator item `resumes` session
- handoff history `handoff_to` queue
- action history `evidenced_by` actor/origin/channel

Important:

This does not handle the operator item. It only exposes the current field.

## Example: Cluster Placement Frame

Inputs:

- capability query
- peer observations
- placement decision
- rejected candidates
- mesh trace
- governance checkpoint

Possible nodes:

- workload demand
- peer
- capability
- trust decision
- placement decision
- rejected candidate
- governance evidence

Possible edges:

- workload `requires` capability
- peer `offers` capability
- trust policy `allows` peer
- placement decision `chooses` peer
- rejected candidate `blocked_by` policy
- decision `evidenced_by` governance checkpoint

Important:

This does not route work. It only adapts route/placement evidence into an
observable shape.

## Relationship To Existing Cluster Observation Work

Cluster already has observation/query concepts such as `NodeObservation`,
`ObservationQuery`, and MeshQL-like surfaces in historical/current cluster
docs.

Runtime Observatory Graph should not replace or rename those.

Difference:

- cluster observation is cluster-owned and peer/capability focused
- Runtime Observatory Graph is cross-surface and report-oriented
- it adapts application, operator, capsule, and cluster artifacts for review
- it should not create a generalized parser or distributed query language

## Relationship To Handoff And Interaction Doctrine

Handoff:

- explains ownership movement

Interaction:

- explains affordances and pending state

Observatory:

- explains how many artifacts relate in one review frame

The Observatory Graph can contain handoff and interaction nodes, but it should
not redefine them.

## Why This Matters For Agents

Future agents need situational awareness before acting.

A useful agent should ask:

- what is the current field?
- what is blocked?
- what is review-only?
- what is executable?
- what evidence supports the state?
- what policy forbids action?
- who owns the next decision?

The observatory graph gives this without granting execution authority.

## Recommended Sequence

1. Keep this as research now.
2. If accepted, graduate to docs-only doctrine or a very narrow report track.
3. The first report should adapt one bounded frame only.
4. Do not start with a cross-project graph model.

Best first bounded frames:

- activation review frame
- operator runtime frame
- research/track handoff frame

Avoid first:

- global runtime graph
- cluster-wide query language
- agent autonomy
- execution-bearing planner

## Risks

### Risk: Reinventing MeshQL

Avoid by making this an adapter/report over explicit artifacts, not a parser.

### Risk: Creating A God Observability Package

Avoid by starting package-local or docs-only.

### Risk: Flattening Package Ownership

Avoid by preserving source artifact boundaries and evidence refs.

### Risk: Giving Agents Authority Too Early

Avoid by keeping observation separate from action.

### Risk: Losing Evidence

Avoid by making every node/edge traceable to source report or event history.

## Recommended Supervisor Decision

[Research Horizon / Codex] recommendation:

Accept Runtime Observatory Graph as research. If graduating, prefer docs-only
doctrine first or one narrow read-only report frame. Do not approve a global
graph package, query language, runtime behavior, cluster integration, host
activation, web transport, or AI/agent execution.

## Candidate Handoff Back To Architect Supervisor

```text
[Research Horizon / Codex]
Track: Runtime Observatory Graph read-only adapter synthesis
Changed: docs/research-horizon/runtime-observatory-graph.md
Accepted/Ready: ready for supervisor review as research, not implementation
Verification: documentation-only; no tests run
Needs: [Architect Supervisor / Codex] decide whether to keep as research,
graduate as docs-only doctrine, or narrow into one read-only report frame.
Recommendation: accept as research; if graduating, choose docs-only doctrine or
one bounded frame such as activation review or operator runtime.
```

