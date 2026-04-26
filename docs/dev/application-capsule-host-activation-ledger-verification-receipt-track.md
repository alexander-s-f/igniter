# Application Capsule Host Activation Ledger Verification Receipt Track

This track opens the Phase 4 slice over the accepted file-backed activation
ledger proof.

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
- [Host Activation Ledger Adapter Track](./application-capsule-host-activation-ledger-adapter-track.md)
- [Activation Evidence Schema Track](./application-capsule-activation-evidence-schema-track.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting the narrow Phase 3 ledger
adapter proof.

The next goal is not broader activation. The next goal is lifecycle closure:
verify committed ledger acknowledgements by readback and issue a separate
activation receipt.

## Goal

Implement readback verification and activation receipt for the ledger adapter:

- verify ledger commit result against evidence packet and adapter readback
- detect missing, unexpected, mismatched, or duplicate ledger records
- preserve skipped host/manual/web leftovers
- produce a separate activation receipt linked to the transfer receipt
- keep transfer receipt and activation receipt independent

## Scope

In scope:

- Ruby implementation in `packages/igniter-application`
- `ActivationVerificationReport`-shaped value/report object
- `ActivationReceipt`-shaped value/report object
- focused RSpec coverage
- compact runnable example or extension of the existing ledger example
- guide/dev note only if needed to explain receipt separation

Out of scope:

- new activation operations
- host runtime mutation beyond existing ledger records
- load path mutation
- constant loading/discovery
- provider/contract registration
- app boot
- web mount binding
- route activation
- rendering/Rack/browser traffic
- contract execution
- cluster placement
- mount receipt implementation
- enterprise orchestration implementation

## Task 1: Ledger Verification And Receipt

Owner: `[Agent Application / Codex]`

Acceptance:

- Add verification that reads adapter records by idempotency key and operation
  digest.
- Verification must compare packet id, operation digest, applied operation
  identities, adapter acknowledgement, idempotency key, and counts.
- Verification must report missing records, unexpected records, mismatched
  packet/digest/idempotency values, and unplanned operations.
- Add activation receipt generation over transfer receipt id, evidence packet
  id, commit result id, verification id, committed/valid/complete flags, counts,
  leftovers, adapter receipt refs, and audit metadata.
- Activation receipt must not merge into or replace transfer receipt.
- Invalid verification must prevent a complete/valid activation receipt.

## Task 2: Web Boundary Guard

Owner: `[Agent Web / Codex]`

Acceptance:

- Confirm verification/receipt does not implement mount receipt, mount commit,
  route binding, Rack/browser traffic, rendering, or component graph inspection.
- Confirm web leftovers remain carried as evidence only.
- Do not add web activation behavior.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb
ruby examples/application/capsule_host_activation_ledger_adapter.rb
```

Run broader smoke if public examples/catalog changed.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` implements ledger verification and activation
   receipt closure.
2. `[Agent Web / Codex]` guards the web/mount boundary.
3. `[Architect Supervisor / Codex]` decides whether Phase 4 is closed or needs
   another hardening slice.

[Agent Application / Codex]
track: `docs/dev/application-capsule-host-activation-ledger-verification-receipt-track.md`
status: landed
delta: added `ApplicationHostActivationLedgerVerification` to read adapter
  records by idempotency key and operation digest, compare packet/result
  identities, applied operation summaries, operation keys, adapter
  acknowledgement records, and counts.
delta: verification reports missing, unexpected, duplicate, mismatched
  packet/digest/idempotency, result identity, applied operation, and
  commit-receipt readback findings without adding host/web/runtime activation.
delta: added `ApplicationHostActivationReceipt` as a separate activation
  closure artifact linked to transfer receipt id, evidence packet id, commit
  result id, verification id, operation digest, adapter receipt refs, counts,
  host/manual/web leftovers, and audit metadata.
delta: receipt validity/completeness depends on valid complete verification and
  committed ledger result; it does not merge into or replace the transfer
  receipt.
delta: extended `examples/application/capsule_host_activation_ledger_adapter.rb`
  and catalog expectations to show ledger commit -> readback verification ->
  separate activation receipt.
verify: `ruby examples/application/capsule_host_activation_ledger_adapter.rb`
  passed.
verify: `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb`
  passed, 80 examples.
verify: `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_host_activation_ledger_verification.rb packages/igniter-application/lib/igniter/application/application_host_activation_receipt.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_host_activation_ledger_adapter.rb examples/catalog.rb`
  passed.
verify: `ruby examples/run.rb smoke` passed, 76 examples.
ready: `[Agent Web / Codex]` can confirm web/mount boundary, then
  `[Architect Supervisor / Codex]` can review Phase 4 closure.
block: none
