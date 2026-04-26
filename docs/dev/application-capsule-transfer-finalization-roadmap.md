# Application Capsule Transfer Finalization Roadmap

This track reopens the capsule transfer line after the interactive app POC work.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

## Summary

Current state:

- Capsule file transfer is complete through verified receipt.
- Host activation review is complete through dry-run and commit-readiness.
- Narrow Phase 3 ledger commit proof is accepted for file-backed activation
  acknowledgements only.
- Phase 4 ledger readback verification and separate activation receipt are
  accepted for the file-backed proof.
- Host runtime mutation, web route activation, contract execution, and cluster
  placement are still deliberately not implemented.

Today verified:

- `ruby examples/application/capsule_transfer_end_to_end.rb` passed.
- `ruby examples/application/capsule_host_activation_dry_run.rb` passed.
- `ruby examples/application/capsule_host_activation_commit_readiness.rb`
  passed.
- `git diff --check` passed.

## Accepted Transfer Chain

The accepted transfer chain is:

1. capsule declaration
2. handoff manifest
3. transfer inventory
4. transfer readiness
5. transfer bundle plan
6. bundle artifact writing
7. bundle verification
8. destination intake plan
9. transfer apply plan
10. dry-run apply
11. committed apply
12. applied verification
13. transfer receipt
14. transfer guide consolidation

Only committed transfer apply mutates the destination filesystem, and only by
creating reviewed directories and copying reviewed files.

Still out of transfer scope:

- host wiring automation
- loading constants
- provider/contract registration
- app boot
- web mount binding
- route activation
- browser/Rack traffic
- contract execution
- cluster placement

## Accepted Activation Review Chain

The accepted post-transfer activation review chain is:

1. post-transfer host integration review
2. host activation readiness
3. host activation plan
4. host activation plan verification
5. host activation dry-run
6. host activation commit-readiness
7. file-backed activation ledger commit
8. ledger readback verification
9. separate activation receipt

Current stop line:

- The accepted commit-shaped path is only the file-backed activation ledger
  proof.
- Activation receipt proves ledger acknowledgement/readback closure, not real
  host activation.
- Host runtime mutation, web mount activation, route binding, Rack/browser
  traffic, contract execution, and cluster placement remain closed.

## Finalization Phases

### Phase 1: Stabilize Current Transfer

Goal: make the already accepted transfer path boring and dependable.

Work:

- keep end-to-end transfer smoke green
- keep guide examples aligned with runnable examples
- ensure transfer receipt remains the closure artifact
- compress stale transfer history only when it helps active work

Acceptance:

- users can understand "capsule moved and verified" without reading dev tracks
- receipt clearly separates file transfer from runtime activation

### Phase 2: Activation Commit Boundary Review

Goal: decide whether Igniter is ready to implement any mutable activation
operation.

Work:

- define exact allowed application-owned commit operations
- keep host-owned/manual/web-owned work out of application commit
- require explicit host target/adapter evidence
- reject discovery, ambient constant loading, and implicit host mutation

Acceptance:

- a future implementation track can be scoped to a tiny commit surface
- or the supervisor explicitly pauses activation commit as too early

Current decision:

- Boundary review accepted only a narrow adapter-backed application-owned
  confirmation boundary as a possible future Phase 3.
- Evidence/receipt vocabulary and normative schema are accepted.
- Phase 3 is open only for a file-backed host activation ledger adapter scoped
  to an explicit temporary host root.

### Phase 3: Narrow Activation Commit

Goal: if Phase 2 accepts it, implement the smallest explicit activation commit.

Candidate allowed operations:

- confirm reviewed load path intent against an explicit host target adapter
- confirm reviewed provider/contract/lifecycle intent as host-target evidence

Still rejected:

- constructing host objects
- registering providers/contracts by discovery
- booting apps
- binding web mounts
- route activation
- rendering/Rack/browser traffic
- contract execution
- cluster placement

Acceptance:

- commit is explicit, adapter-backed, refusal-first, and auditable
- skipped host/web/manual work remains visible

Current decision:

- Accepted only as a file-backed activation ledger proof.
- The proof acknowledges reviewed application-owned confirmations but does not
  activate a real host.

### Phase 4: Activation Verification And Receipt

Goal: close activation the same way transfer closes: with readback and receipt.

Work:

- verify activation commit results against the reviewed plan
- produce an activation receipt
- keep activation receipt separate from transfer receipt

Acceptance:

- enterprise users can audit what moved and what became active as separate
  lifecycle events

Current decision:

- Accepted for the file-backed activation ledger proof.
- Activation receipt remains separate from transfer receipt and proves only the
  ledger-backed confirmation acknowledgement lifecycle.

### Phase 5: Web/Host Mount Activation Lane

Goal: let web or host-owned layers activate mount intents later, without
application owning web runtime behavior.

Work:

- define explicit mount adapter evidence
- keep `review_mount_intent` as metadata until a web/host track accepts more
- require separate web-owned verification and receipt if web activation exists

### Phase 6: Enterprise Orchestration

Goal: use capsule transfer and activation receipts as inputs to enterprise
deployment, marketplace, compliance, and agent workflows.

Possible consumers:

- CI/CD gates
- internal app marketplaces
- air-gapped delivery
- tenant/host onboarding
- regulated deployment audit
- agent-assisted migrations
- cluster placement planning
- runtime observability and receipts

## Why This Matters

Capsule transfer can become the enterprise portability foundation for Igniter.

It provides:

- portable app/capsule boundaries
- explicit import/export and host requirement contracts
- reviewable bundle artifacts
- refusal-first transfer apply
- receipts for audit and compliance
- separation between "files moved" and "runtime activated"
- a path for agent-supervised delivery without autonomous hidden mutation

This is the bridge from "copyable app directory" to enterprise-grade
application supply chain.

## Supervisor Decision

[Architect Supervisor / Codex]

Accepted next line:

- Return to capsule transfer through this finalization roadmap.
- Do not jump directly to activation commit.
- Activation Commit Boundary Review accepted only a narrow possible Phase 3.
- Activation Evidence And Receipt accepted the right vocabulary.
- Activation Evidence Schema accepted the normative schema and first real
  adapter candidate.
- Host Activation Ledger Adapter accepted the narrow Phase 3 proof.
- Host Activation Ledger Verification Receipt accepted Phase 4 closure for the
  file-backed proof.
- Activation Guide Consolidation accepted the public lifecycle and stop-line
  wording.
- Capsule transfer and ledger-backed activation are finalized-for-now.
- Next active work returns to practical showcase/application pressure.
