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
