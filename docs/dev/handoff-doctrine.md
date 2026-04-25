# Handoff Doctrine

Handoff is ownership transfer under policy with context, evidence, obligations,
and receipt.

This doctrine aligns existing Igniter handoff language across documentation
agents, application capsules, transfer receipts, post-transfer readiness,
operator workflows, and future AI/agent delegation. It is documentation-only.
It does not introduce a shared runtime object, package code, autonomous
delegation, cluster routing, host activation, web transport, or AI provider
integration.

## Why This Exists

Igniter already uses handoff in several places:

- package and research agents hand work between roles through track notes
- application capsules produce handoff manifests before transfer or host wiring
- transfer receipts close the applied-transfer review chain
- host activation readiness and activation plans describe future host
  responsibility without executing activation
- operator workflows already use ownership language such as assignee, queue,
  channel, action history, and handoff history

The goal is one shared mental model, not one shared framework.

## Conceptual Vocabulary

### Subject

The thing whose responsibility is being transferred or reviewed.

Current examples:

- a `docs/dev` track
- a capsule or capsule bundle
- a transfer result
- an activation readiness or activation plan
- a pending operator item
- a future AI/agent task

### Sender

The person, agent, host, process, or tool preparing the handoff.

Current examples:

- `[Agent Application / Codex]`
- `[Agent Web / Codex]`
- `[Research Horizon / Codex]`
- a source application host
- a transfer/apply report producer

### Recipient

The expected next owner, reviewer, queue, role, host, or decision maker.

Current examples:

- `[Architect Supervisor / Codex]`
- `[Agent Application / Codex]`
- `[Agent Web / Codex]`
- a receiving host
- an operator queue
- a future agent role

### Context

The minimal state needed to understand the handoff without rediscovery.

Current examples:

- linked track documents
- capsule identities, imports, exports, and mount intents
- supplied web surface metadata
- destination root and artifact path
- activation readiness decisions
- operator item status, queue, channel, and assignee

### Evidence

Proof that the sender reached the claimed boundary.

Current examples:

- changed files
- verification commands and results
- serialized report hashes
- readiness findings
- transfer receipt counts
- action history entries
- handoff history entries

### Obligations

What the recipient must decide, provide, review, or complete.

Current examples:

- accept, reject, narrow, or defer a proposal
- provide host exports or capabilities
- complete manual host wiring
- review mount intents
- approve, reply, complete, dismiss, or hand off an operator item
- decide whether a research idea should graduate into a narrow track

### Receipt

The acknowledgement or closure artifact after the recipient acts.

Current examples:

- supervisor acceptance notes
- transfer receipts
- activation readiness/plan review notes
- operator action history
- handoff history
- future review reports over explicit artifacts

### Trace

The ordered history that lets a human or agent explain how ownership moved.

Current examples:

- labeled handoff notes in track files
- transfer chain reports from handoff manifest through receipt
- operator action history
- handoff history

## Current Surface Mapping

### Docs-Agent Tracks

Docs-agent handoffs should keep the current compact shape:

```text
[Agent X / Codex]
Track: <track name>
Changed: <files or docs>
Accepted/Ready: <yes/no + why>
Verification: <commands and result>
Needs: <next agent or supervisor decision>
```

Mapping:

- subject: track
- sender: labeled agent
- recipient: `Needs`
- context: track links and dependencies
- evidence: changed files and verification
- obligations: requested decision or next agent work
- receipt: supervisor or next-agent response
- trace: appended track notes

### Application Capsule Handoff Manifests

`ApplicationHandoffManifest` remains the application-owned read-only answer to
"what is moving and what must the receiving host provide?"

Mapping:

- subject: capsule or bundle subject
- sender: source capsule/application context
- recipient: receiving host or reviewer
- context: capsules, imports, exports, mount intents, and surface metadata
- evidence: composition/assembly/report summaries
- obligations: unresolved imports, suggested host wiring, required decisions
- receipt: later readiness, transfer, or supervisor review artifact
- trace: handoff manifest plus downstream transfer chain

### Transfer Receipts

`ApplicationTransferReceipt` remains the read-only closure artifact over
explicit transfer reports.

Mapping:

- subject: transferred artifact/result
- sender: transfer apply/verification chain
- recipient: receiving host or reviewer
- context: artifact path, destination root, counts, and metadata
- evidence: applied verification and supplied upstream reports
- obligations: manual actions, findings, refusals, skipped operations
- receipt: the receipt itself
- trace: transfer inventory, readiness, bundle, intake, apply, verification,
  and receipt reports

### Host Activation Readiness And Plans

Host activation readiness and activation plans describe whether the receiving
host has supplied enough explicit decisions for future activation and what
future operations would be needed.

Mapping:

- subject: transferred capsule eligibility for future activation
- sender: receiving host review process
- recipient: host operator or future activation implementer
- context: receipt, handoff/assembly metadata, host decisions, mount intents
- evidence: blockers, warnings, decisions, manual actions, and plan operations
- obligations: missing host decisions or manual wiring
- receipt: supervisor acceptance or later host-owned activation review
- trace: readiness report, activation plan, and future explicit host action
  reports if they are ever accepted

### Operator Workflows

Operator handoff is an ownership transition over pending workflow state.

Mapping:

- subject: operator item, orchestration item, session, or future agent task
- sender: previous assignee, policy, agent, or runtime surface
- recipient: new assignee, queue, channel, or lane
- context: status, lifecycle, session identity, queue, channel, lane, assignee
- evidence: action history and runtime/orchestration snapshots
- obligations: approve, reply, complete, dismiss, hand off, or investigate
- receipt: action history entry and updated item state
- trace: action history and handoff history

## What This Doctrine Does Not Accept Yet

Not accepted:

- shared runtime handoff value object
- new package
- runtime agent execution
- autonomous delegation
- workflow engine behavior
- cluster routing integration
- host activation behavior
- route activation or mount binding
- web/browser transport
- AI provider calls
- hidden project discovery
- mutation of host wiring

Future work may propose one of these only through a narrow accepted `docs/dev`
track with package ownership, acceptance criteria, and verification.

## Graduation Criteria For Future Work

A future handoff-related idea may graduate only if it can be stated as one of:

- docs-only doctrine
- read-only report over existing explicit artifacts
- narrow package-local value object or facade
- isolated example pressure test

The first acceptable code-shaped graduation would likely be a package-local
read-only report, not a shared cross-package runtime object.

Good candidate:

- a future `igniter-application` report that normalizes handoff manifest,
  transfer receipt, and host activation readiness into one review envelope,
  only if repeated ceremony proves the need

Still deferred:

- a global `Handoff` object
- agent-driven delegation execution
- cluster route ownership transfer
- web form submission/resume transport

## Working Rule

Use handoff language when responsibility changes or review moves to a new owner.

Do not use handoff language as a shortcut for execution. A handoff can describe
future work, future activation, future routing, or future delegation, but it
does not perform those actions unless a later accepted implementation track
explicitly says so.

