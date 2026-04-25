# Agent Handoff Protocol

Status: research synthesis for `[Architect Supervisor / Codex]`.

Date: 2026-04-25.

This is not an implementation track. It maps existing Igniter handoff patterns
and proposes a tiny shared vocabulary that may later graduate into docs-only
doctrine or a read-only report.

## Thesis

Handoff is ownership transfer under policy with context, evidence, and receipt.

For Igniter, this is a deeper primitive than "assign this task." It connects:

- documentation agents coordinating architecture work
- application capsules moving between hosts
- operators taking responsibility for pending workflows
- future AI agents delegating, escalating, or returning work
- distributed runtimes moving responsibility across nodes without hiding why

The important constraint: handoff should first be an inspectable protocol, not
a runtime action engine.

## Existing Handoff Patterns

### 1. Docs-Agent Handoff

`docs/dev/tracks.md` already defines a compact agent handoff protocol:

- role label
- track
- changed files or docs
- accepted/ready status
- verification
- needs / next decision

Example shape:

```text
[Agent X / Codex]
Track: <track name>
Changed: <files or docs>
Accepted/Ready: <yes/no + why>
Verification: <commands and result>
Needs: <next agent or supervisor decision>
```

This is the cleanest current human/agent protocol in the repo. It is not
runtime code, but it already encodes the right social contract:

- who acted
- what scope they touched
- whether the result is ready
- what evidence exists
- who must decide next

### 2. Application Capsule Handoff

`ApplicationHandoffManifest` answers:

- what is moving
- which capsules are involved
- which imports/exports matter
- which requirements are unresolved
- what host wiring is suggested
- which mount intents and web surface metadata were supplied

It is explicitly read-only. It does not package, copy, discover, boot, mount,
route, execute contracts, or place anything on a cluster.

This gives handoff a portable artifact form: a receiving host, human, or agent
can inspect obligations before any mutation happens.

### 3. Transfer Receipt

`ApplicationTransferReceipt` answers:

- what was transferred
- whether the committed result was verified
- what was refused, skipped, or found inconsistent
- what manual actions remain
- how much web surface metadata was preserved

It closes a handoff loop. Where the handoff manifest is "before responsibility
moves," the receipt is "after reviewed transfer work, here is the audit state."

### 4. Operator Handoff

The current agent/operator docs describe `handoff` as an ownership transition:

- inbox items carry `assignee`, `queue`, and `channel`
- handoffs increment `handoff_count`
- handoffs append to `handoff_history`
- operator records carry `action_history`
- audit identity includes `actor`, `origin`, and `actor_channel`

This is the runtime-adjacent form of handoff, but it still has the same shape:
an accountable change of responsibility with history and policy context.

## Shared Semantics

Across these patterns, handoff has seven stable parts.

### 1. Subject

The thing being handed off.

Examples:

- architecture track
- capsule bundle
- transfer result
- pending operator item
- future agent task
- future runtime cell

### 2. Sender

The actor, agent, host, or process that prepared the handoff.

This should be explicit even when the sender is a tool or automation.

### 3. Recipient

The expected next owner, reviewer, queue, host, or agent role.

Recipient may be:

- a concrete actor
- a role
- a queue/lane
- a host
- a capability query in future cluster contexts

### 4. Context

The minimal state needed to understand the handoff without rediscovery.

Examples:

- linked track docs
- capsule names and imports/exports
- session id and pending actions
- route/placement explanation
- supplied web surface metadata

### 5. Evidence

Proof that the sender did the work or reached a boundary.

Examples:

- changed files
- verification commands
- report hashes
- transfer receipt counts
- audit history
- trace ids

### 6. Obligations

What the recipient must decide or provide.

Examples:

- review proposal
- supply host export
- resolve manual wiring
- approve/reply/complete
- choose route policy
- reject unsafe activation

### 7. Receipt

The receiving-side acknowledgement or closure artifact.

Examples:

- supervisor acceptance/rejection
- transfer receipt
- operator action history entry
- future handoff receipt value

## Tiny Vocabulary

The smallest shared vocabulary should stay conceptual at first:

- `HandoffSubject`
- `HandoffParty`
- `HandoffContext`
- `HandoffEvidence`
- `HandoffObligation`
- `HandoffReceipt`
- `HandoffTrace`

If a future value object is justified, the first concrete report could be:

```ruby
HandoffReport = {
  subject:,
  sender:,
  recipient:,
  context:,
  evidence:,
  obligations:,
  receipt:,
  trace:,
  metadata:
}
```

This should not imply execution. It is an inspection envelope.

## Research Vocabulary vs Implementation Readiness

Research vocabulary may say:

- a handoff has parties, subject, context, evidence, obligations, and receipt
- a handoff can be requested, accepted, rejected, delegated, or closed
- a handoff trace should be append-only where it reflects accountability
- AI agents should read handoffs as structured context, not prose-only prompts

Implementation should not yet add:

- runtime agent execution
- autonomous delegation
- cluster routing
- host activation
- web submission transport
- new package boundaries
- generalized workflow engine behavior

## First Graduation Option: Docs-Only Doctrine

Recommendation: graduate first as docs-only doctrine.

Why:

- the repo already has several handoff surfaces
- the main value right now is alignment of language
- implementation pressure is not yet repeated enough for a shared value object
- premature code could create a parallel workflow model beside application,
  operator, and capsule transfer reports

Possible target:

- `docs/dev/handoff-doctrine.md`
- referenced from `docs/dev/tracks.md`
- short mapping across docs-agent handoffs, capsule handoff manifests, transfer
  receipts, and operator handoffs

Acceptance could be documentation-only:

- no new code
- no new package
- no execution semantics
- must state that handoff is descriptive unless a package-local track says
  otherwise

## Second Graduation Option: Read-Only Application Report

Consider only after docs doctrine if application work needs repeated ceremony.

Candidate:

- `Igniter::Application.handoff_report(...)`
- consumes explicit existing values/hashes only
- can normalize `ApplicationHandoffManifest`, `ApplicationTransferReceipt`, and
  future host activation readiness into one review envelope

Constraints:

- no mutation
- no activation
- no route/mount/boot/load
- no cluster placement
- no agent runtime
- no web dependency

This would be useful if host activation readiness, capsule transfer, and
operator/product docs repeatedly need the same summary shape.

## Future AI/Operator Delegation Needs

Future AI agents will need handoff to answer:

- What am I being asked to own?
- Who gave me this work?
- What evidence should I trust?
- What policies constrain my next move?
- What human decision is required?
- What must I return as a receipt?

Future operators will need handoff to answer:

- Why is this in my queue?
- What changed before it arrived?
- What can I safely do?
- What happens if I reject or delegate?
- What audit trail will remain?

Future clusters will need handoff to answer:

- Which node or host owns this work now?
- Was the movement planned or reactive?
- Which trust/admission rules allowed it?
- What state must not be copied, such as credentials?
- What trace proves the decision path?

These are compatible with the existing architecture only if handoff remains
structured and inspectable before it becomes executable.

## Recommended Supervisor Decision

[Research Horizon / Codex] recommendation:

Approve a docs-only `Handoff Doctrine` as the first graduation candidate.

Do not approve a shared runtime object yet.

Reason:

The concept is clearly cross-cutting, but each existing package already has a
valid local artifact. The next useful move is language alignment and
graduation criteria, not another object graph.

## Candidate Handoff Back To Architect Supervisor

```text
[Research Horizon / Codex]
Track: Agent Handoff Protocol synthesis
Changed: docs/research-horizon/agent-handoff-protocol.md
Accepted/Ready: ready for supervisor review as research, not implementation
Verification: documentation-only; no tests run
Needs: [Architect Supervisor / Codex] decide whether to graduate the concept as
docs-only Handoff Doctrine. Recommendation: docs-only first; defer shared
runtime/application value objects until repeated implementation pressure
appears.
```

