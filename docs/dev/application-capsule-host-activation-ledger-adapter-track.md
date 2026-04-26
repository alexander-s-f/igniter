# Application Capsule Host Activation Ledger Adapter Track

This track opens the first narrow Phase 3 implementation slice for capsule host
activation.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

Constraints:

- `:activation_safety` from [Constraint Sets](./constraints.md)
- [Activation Evidence Schema Track](./application-capsule-activation-evidence-schema-track.md)
- [Capsule Transfer Finalization Roadmap](./application-capsule-transfer-finalization-roadmap.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting the evidence schema.

The goal is not to activate a real host. The goal is to prove the accepted
schema with a real, explicit adapter that writes and reads activation evidence
without runtime magic.

## Goal

Implement the smallest application-owned activation commit proof:

- explicit `ApplicationHostTargetAdapter` boundary
- file-backed activation ledger adapter scoped to an explicit temporary host
  root
- refusal-first validation before adapter calls
- idempotent acknowledgements keyed by idempotency key and operation digest
- readback evidence for future verification and activation receipt work

## Scope

In scope:

- Ruby implementation in `packages/igniter-application`
- value objects or simple reports needed by the ledger adapter
- file-backed ledger records under an explicit target root
- support for reviewed application-owned confirmation operations:
  `confirm_load_path`, `confirm_provider`, `confirm_contract`,
  `confirm_lifecycle`
- refusal reporting for invalid evidence
- compact smoke/example coverage
- guide/dev note only if needed to make the example understandable

Out of scope:

- host runtime mutation beyond writing the explicit ledger artifact
- load path mutation
- constant loading/discovery
- provider/contract registration
- app boot
- web mount binding
- route activation
- rendering/Rack/browser traffic
- contract execution
- cluster placement
- activation receipt implementation
- mount evidence implementation
- enterprise orchestration implementation

## Task 1: Application Ledger Adapter

Owner: `[Agent Application / Codex]`

Acceptance:

- Add an explicit application host target adapter abstraction or local adapter
  protocol that does not use registry lookup or ambient discovery.
- Add a file-backed ledger adapter scoped to a caller-supplied temporary host
  root.
- Accept only evidence matching the normative schema fields from the previous
  track.
- Refuse before adapter calls for missing required fields, unsupported schema
  version, non-true commit decision, stale identity, digest mismatch,
  non-executable dry-run, committed dry-run evidence, dry-run refusals, missing
  adapter capability, unsupported operation type, receipt sink absence, or
  implicit destination/discovery input.
- Write per-operation acknowledgement records for application-owned
  confirmations only.
- Support readback by idempotency key and operation digest.
- Reusing the same idempotency key with the same digest must be a safe duplicate
  acknowledgement; reusing the same key with a different digest must refuse.
- Preserve skipped host/manual/web operations as skipped evidence, not applied
  work.

## Task 2: Web Boundary Guard

Owner: `[Agent Web / Codex]`

Acceptance:

- Review the implementation surface and confirm it does not implement mount
  evidence, mount commit, route binding, Rack/browser traffic, rendering, or
  component graph inspection.
- If needed, add only documentation comments or tests that protect the boundary.
- Do not add web activation behavior.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
bundle exec rspec <focused application specs>
ruby <focused example if added>
```

Broaden verification if shared runtime files are touched.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` implements the file-backed ledger adapter and
   focused evidence/refusal/idempotency coverage.
2. `[Agent Web / Codex]` reviews the web boundary and keeps mount activation out
   of this slice.
3. `[Architect Supervisor / Codex]` verifies whether the implementation proves
   Phase 3 without exceeding the accepted activation boundary.

[Agent Application / Codex]
track: `docs/dev/application-capsule-host-activation-ledger-adapter-track.md`
status: landed
delta: added an explicit file-backed host activation ledger adapter in
  `igniter-application`, scoped to a caller-supplied root and exposed through
  `Igniter::Application.file_backed_host_activation_ledger_adapter`.
delta: added activation operation digest and ledger commit result objects with
  refusal-first validation for schema version, required packet fields,
  explicit `commit_decision: true`, receipt sink, stale nested evidence
  identity, digest mismatch, committed/non-executable/refused dry-run evidence,
  readiness blockers, missing adapter methods, unsupported operation types, and
  forbidden live/discovery/implicit destination fields.
delta: commit writes only per-operation acknowledgement JSON records for
  application-owned confirmations (`confirm_load_path`, `confirm_provider`,
  `confirm_contract`, `confirm_lifecycle`) under `activation-ledger/`; skipped
  host/manual/web evidence remains skipped and is not treated as applied work.
delta: idempotency semantics are implemented with readback by idempotency key
  and operation digest; same key plus same digest is a safe duplicate, while
  same key plus different digest refuses without writing new records.
delta: added focused RSpec coverage and a runnable catalog example
  `examples/application/capsule_host_activation_ledger_adapter.rb`; guide docs
  now describe the narrow ledger commit proof and its non-activation boundary.
verify: `ruby examples/application/capsule_host_activation_ledger_adapter.rb`
  passed.
verify: `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed, 78 examples.
verify: `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_host_activation_operation_digest.rb packages/igniter-application/lib/igniter/application/file_backed_host_activation_ledger_adapter.rb packages/igniter-application/lib/igniter/application/application_host_activation_ledger_commit.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_host_activation_ledger_adapter.rb examples/catalog.rb`
  passed.
verify: `ruby examples/run.rb smoke` passed, 76 examples.
ready: `[Agent Web / Codex]` can review the boundary and confirm no mount
  commit, route binding, Rack/browser traffic, rendering, or component graph
  inspection entered this slice; `[Architect Supervisor / Codex]` can review
  Phase 3 ledger proof for acceptance.
block: none
