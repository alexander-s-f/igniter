# Interaction Kernel Read-Only Report

Status: research synthesis for `[Architect Supervisor / Codex]`.

Date: 2026-04-25.

This report is research-only. It does not propose a new package, shared runtime
object, browser transport, workflow engine, agent execution, cluster placement,
or AI provider integration.

## Thesis

Igniter already has the beginning of an interaction kernel, but it is currently
distributed across application, web, operator, and capsule review surfaces.

The immediate opportunity is not to centralize it in code. The immediate
opportunity is to name the read-only interaction envelope that lets humans,
agents, web surfaces, and operators inspect the same workflow state without any
layer owning the others.

The smallest useful shape is a report, not a runtime.

## What "Interaction Kernel" Means Here

Interaction Kernel means a conceptual read-only layer for describing:

- what a human or agent is being asked for
- what actions are available
- what streams/chats/artifacts are relevant
- what session or surface owns the active state
- what policy or host boundary constrains the next move
- what evidence exists for review
- what is still only candidate metadata

It is "kernel" only in the language sense: a small stable vocabulary that other
surfaces can align around. It is not accepted as an implementation package.

## Existing Signals

### Application Flow Sessions

`igniter-application` owns concrete active interaction state through:

- `FlowSessionSnapshot`
- `FlowEvent`
- `PendingInput`
- `PendingAction`
- `ArtifactReference`
- `Environment#start_flow`
- `Environment#resume_flow`

Accepted constraints:

- application owns session durability
- values serialize with stable `to_h`
- no `igniter-web` dependency is required
- this is not a flow engine
- no browser transport, real agent runtime, distributed sessions, or cluster
  placement is implied

Interpretation:

Application is the source of active pending state for local app workflows.

### Web Surface Interactions

`igniter-web` owns candidate interaction metadata through:

- `SurfaceManifest#interactions`
- pending inputs from `ask`
- pending actions from `action`
- streams from `stream`
- chats from `chat`
- `Igniter::Web.flow_pending_state(...)`
- `Igniter::Web.flow_surface_projection(...)`

Accepted constraints:

- web can describe candidate pending interactions as plain hashes
- application does not inspect web screen graphs
- `SurfaceManifest` does not execute contracts
- `ask` does not imply browser form transport
- surface metadata can be supplied to application capsule reports as opaque
  context

Interpretation:

Web describes possible interaction affordances; application decides which are
active in a concrete session snapshot.

### Operator And Orchestration Surfaces

Current agent/operator docs and active roadmap describe:

- runtime/session query surfaces over `AgentSession`
- operator queries joining live sessions and inbox records
- orchestration actions such as `wake`, `approve`, `reply`, `complete`, and
  `handoff`
- lanes, queues, channels, assignees, lifecycle state, and action history
- orchestration runtime summaries and transition overviews

Accepted constraints from current docs:

- query surfaces are read-only where possible
- operator workflow is explicit and auditable
- handoff is ownership-aware, not a string alias
- richer distributed query language should wait

Interpretation:

Operator surfaces are the accountability plane for interactions that need
human or policy-mediated follow-up.

### Capsule And Activation Review Surfaces

Application capsule transfer and host activation tracks already provide
interaction-adjacent review artifacts:

- handoff manifests
- transfer receipts
- host activation readiness
- host activation plans
- supplied web surface metadata
- mount intents
- manual actions
- blockers and warnings

Accepted constraints:

- these are read-only review/planning artifacts
- host activation is not executed
- web mount intents are metadata only
- no loading, booting, route activation, browser traffic, contract execution,
  discovery, or cluster placement is implied

Interpretation:

Capsule and activation reports describe whether an interaction surface can
travel, be reviewed, and later be made eligible for host-owned activation.

## Proposed Tiny Vocabulary

The smallest conceptual vocabulary:

- `InteractionSubject`
- `Participant`
- `Affordance`
- `PendingState`
- `SurfaceContext`
- `SessionContext`
- `PolicyContext`
- `Evidence`
- `Outcome`

These names are research vocabulary, not proposed class names.

### InteractionSubject

The thing the interaction concerns.

Examples:

- flow session
- screen
- capsule
- operator item
- activation plan
- future agent task

### Participant

A human, agent, host, service, or operator role involved in the interaction.

Examples:

- user
- operator
- application host
- web surface
- future AI agent
- queue or lane

### Affordance

Something available to do or observe.

Examples:

- `ask`
- `action`
- `stream`
- `chat`
- artifact
- approval
- manual action
- mount-intent review

### PendingState

The active request for input, action, approval, reply, or review.

Examples:

- `PendingInput`
- `PendingAction`
- operator inbox item
- activation blocker
- manual host wiring action

### SurfaceContext

Where the interaction can be presented or inspected.

Examples:

- `SurfaceManifest`
- web surface metadata
- mounted operator console
- activation plan review output

### SessionContext

The durable or restorable state that makes an interaction concrete.

Examples:

- `FlowSessionSnapshot`
- `FlowEvent`
- `AgentSession`
- execution id plus node/token identity

### PolicyContext

The constraints governing allowed next moves.

Examples:

- required input
- allowed operator actions
- queue/lane policy
- host activation readiness blockers
- credential locality policy in future distributed work

### Evidence

The proof or trace behind current interaction state.

Examples:

- event history
- action history
- transfer receipt counts
- activation plan operations
- surface projection reports
- diagnostics

### Outcome

The result after an interaction is answered, rejected, completed, or delegated.

Examples:

- appended `FlowEvent`
- operator action result
- updated session snapshot
- receipt
- readiness/plan verification finding

## Candidate Read-Only Report Shape

If this graduates later, the first acceptable shape should be read-only and
package-local. A conceptual report could look like:

```ruby
{
  subject: {},
  participants: [],
  affordances: [],
  pending_state: [],
  surface_context: {},
  session_context: {},
  policy_context: {},
  evidence: [],
  outcomes: [],
  metadata: {}
}
```

This report should consume explicit existing artifacts or hashes only.

Possible inputs:

- `FlowSessionSnapshot`
- `SurfaceManifest#to_h`
- `Igniter::Web.flow_pending_state(...)`
- application flow declarations
- capsule handoff/receipt/readiness/plan reports
- operator/orchestration read models

Forbidden behavior:

- executing contracts
- resuming flows
- mutating sessions
- inspecting web screen graphs from application
- binding mounts
- activating routes
- loading constants
- booting hosts
- calling AI providers
- routing to cluster peers

## Boundary Recommendation

Do not create `igniter-interactions` now.

Recommended order:

1. keep this as research vocabulary
2. if accepted, graduate to docs-only doctrine first
3. only later consider a read-only report in the package where repeated
   ceremony appears

Likely first code home if pressure appears:

- `igniter-application`, because it already owns active flow snapshots,
  capsule review artifacts, host activation review artifacts, and generic
  mounts

But this should happen only if it helps non-web, non-agent consumers too.
Otherwise the right first adapter remains web-owned, as with
`Igniter::Web.flow_pending_state(...)`.

## Relationship To Handoff Doctrine

Handoff Doctrine answers:

- who owns responsibility now?
- who receives it next?
- what evidence and obligations move with it?

Interaction Kernel answers:

- what can a participant do or provide?
- where is the active pending state?
- what surface/session/policy/evidence makes the interaction inspectable?

The two concepts are adjacent but not identical.

Handoff is an ownership transition.
Interaction is an affordance plus pending state.

Some interactions produce handoffs. Some handoffs require interactions. They
should not collapse into one model.

## Relationship To Runtime Observatory Graph

Runtime Observatory Graph should wait.

Interaction Kernel can become one input to a future observation graph, but the
project does not yet need a generalized query language. The safer sequence is:

1. handoff doctrine
2. interaction doctrine or read-only report
3. observation graph over proven report shapes

This preserves the current project habit: prove small read-only artifacts
before generalized runtime abstractions.

## Risks

### Risk: Creating A Parallel Workflow Engine

Avoid this by keeping the first graduation docs-only or read-only.

### Risk: Pulling Web Concepts Into Application

Avoid this by preserving current boundary:

- web owns screen graphs and candidate surface interactions
- application owns active flow snapshots and generic mounts
- application accepts supplied web metadata as opaque context

### Risk: Making Chat The Core Model

Avoid this by treating chat as one affordance beside ask, action, stream,
artifact, approval, and manual review.

### Risk: Premature New Package

Avoid this by promoting only after at least two package-local surfaces need the
same report shape and cannot solve it through adapters.

## Recommended Supervisor Decision

[Research Horizon / Codex] recommendation:

Accept the Interaction Kernel synthesis as research and graduate only to a
docs-only doctrine if a next step is desired.

Do not approve a shared value object, new package, runtime behavior, browser
transport, AI/provider integration, or cluster routing.

If a read-only report is desired later, start package-local in
`igniter-application` only after repeated ceremony appears around flow
snapshots, capsule reports, activation review, and operator surfaces.

## Candidate Handoff Back To Architect Supervisor

```text
[Research Horizon / Codex]
Track: Interaction Kernel read-only report synthesis
Changed: docs/research-horizon/interaction-kernel-report.md
Accepted/Ready: ready for supervisor review as research, not implementation
Verification: documentation-only; no tests run
Needs: [Architect Supervisor / Codex] decide whether to keep this as research,
graduate it as docs-only doctrine, or defer until more implementation pressure
appears. Recommendation: accept as research; docs-only doctrine is safe, but
shared runtime/report objects should wait.
```

