# Track: Human-Agent Readable Contracts Fixture v0

Status: done
Slice state: done on 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/human-agent-readable-contracts-fixture-v0`
Supervisor: `[Architect Supervisor / Codex]`
Neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`
Artifacts:
- `igniter-lang/experiments/human_agent_readable_contracts_fixture/human_agent_readable_contracts_fixture.rb`
- `igniter-lang/docs/tracks/human-agent-readable-contracts-pressure-v0.md`

---

## Frame

This slice turns human-agent readability pressure into an executable synthetic
proof around a Spark-like `appointment_cancel_request`.

Safety boundary:

- synthetic refs only
- no real Spark data
- no endpoints, provider configs, raw provider payloads, secrets, tokens,
  customers, phones, emails, or infrastructure details
- proof fixture only, not package adapter code

---

## What The Fixture Models

Positive path:

```text
IdeaDraft
  -> IntentContract v0
  -> AgentProposalObservation
  -> ReviewProjection v0
  -> HumanCorrectionReceipt
  -> IntentContract v1
  -> ReviewProjection v1
  -> MeaningDiff(v0 -> v1)
  -> RuntimeVerificationReceipt(v1)
  -> AcceptanceReceipt(v1)
```

Core decision:

```text
agent prose != artifact of record
human-readable review != runtime verification
acceptance = verified artifact + current review projection + receipt
```

---

## Positive Result

`IntentContract v0` is proposed, but not accepted:

```text
action: appointment_cancel_request
action_kind: execution
effect_rights:
  - create_operation_request
  - mutate_schedule_status
  - create_external_bridge_record
expected_receipts:
  - OperationExecutionReceipt
```

`IntentContract v1` is corrected:

```text
action: appointment_cancel_request
action_kind: request
effect_rights:
  - create_operation_request
denied_effect_rights:
  - mutate_schedule_status
  - create_external_bridge_record_without_capability
expected_receipts:
  - OperationRequestReceipt
  - optional ExternalBridgeReceipt only when capability-gated
```

`MeaningDiff` captures semantic changes:

```text
action_kind: execution -> request
removed effect rights:
  - mutate_schedule_status
  - create_external_bridge_record
added evidence:
  - duplicate_pending_request_check
risk_delta:
  schedule_mutation_risk: reduced
  bridge_escape_risk: gated
requires_reverification: true
```

Acceptance:

```text
accepted_contract_ref: intent_contract/appointment-cancel/v1
review_projection_ref: review/appointment-cancel/v1
runtime_verification_ref: runtime_verification/appointment-cancel/v1
status: accepted_for_fixture
production_effects_allowed: false
```

---

## Negative Cases

[D] Agent prose cannot be artifact of record:

```text
diagnostic: human_agent.prose_not_artifact_of_record
```

[D] Acceptance requires runtime verification:

```text
diagnostic: human_agent.acceptance_requires_runtime_verification
```

[D] Effect-right changes require `MeaningDiff`:

```text
diagnostic: meaning_diff.required_for_effect_right_change
```

[D] Acceptance must use a current review projection for the accepted contract:

```text
diagnostic: review_projection.contract_ref_mismatch
```

[D] New ESCAPE effect rights require capability requirements:

```text
diagnostic: effect_right.escape_capability_missing
```

---

## Proof Output

```text
ruby igniter-lang/experiments/human_agent_readable_contracts_fixture/human_agent_readable_contracts_fixture.rb
```

Output:

```text
PASS human_agent_readable_contracts_fixture
positive.v0_proposed_not_accepted: ok
positive.v1_corrected_request_only: ok
positive.meaning_diff_complete: ok
positive.correction_links_diff: ok
positive.runtime_verification: ok
positive.acceptance_links_current_review_and_verification: ok
negative.prose_without_contract_blocked: ok
negative.acceptance_without_verification_blocked: ok
negative.effect_right_change_requires_diff: ok
negative.stale_review_projection_blocked: ok
negative.escape_without_capability_blocked: ok
safety.synthetic_only: ok
v0: execution rights=create_operation_request,mutate_schedule_status,create_external_bridge_record
v1: request rights=create_operation_request
meaning_diff: action_kind=execution->request requires_reverification=true
acceptance: accepted_for_fixture verified_by=runtime_verification/appointment-cancel/v1
```

The proof also supports:

```text
ruby igniter-lang/experiments/human_agent_readable_contracts_fixture/human_agent_readable_contracts_fixture.rb --dump
```

to inspect generated synthetic observations.

---

## Gap Report

### Compiler / Grammar

[Next] Formalize `MeaningDiff` as a semantic artifact over intent, assumptions,
effect rights, evidence requirements, expected receipts, risk declarations,
schema, and trust boundaries.

[Next] Type acceptance scope: fixture, staging, production, review-only, and
the reviewer authority required for each.

[Next] Define freshness/hash rules for `ReviewProjection` so acceptance cannot
bind a stale projection to a newer contract.

[Q] Is `MeaningDiff` generated from source, SemanticIR, SemanticImage, or all
three?

[Q] Can a `HumanCorrectionReceipt` add effect rights, or must that always
restart a proposal and verification cycle?

### Bridge

[Next] Draft metadata-only bridge profiles for:

- `AgentProposalObservation`
- `ReviewProjection`
- `MeaningDiffReport`
- `HumanCorrectionReceipt`
- `RuntimeVerificationReceipt`
- `AcceptanceReceipt`

[Q] Bridge should keep agent confidence and human prose as policy/prose unless
linked to verification evidence.

---

## Boundaries

[X] Rejected: real Spark data, endpoints, provider configs, raw provider
payloads, credentials, tokens, customers, phones, emails, or infrastructure
details.

[X] Rejected: agent prose as artifact of record.

[X] Rejected: casual human approval as acceptance receipt.

[X] Rejected: acceptance without runtime verification.

[X] Rejected: text diff alone when effect rights or trust boundaries changed.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/human-agent-readable-contracts-fixture-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Built a stdlib-only executable synthetic fixture.
- v0 is proposed but not accepted.
- Human correction produces v1 as request-only lifecycle.
- MeaningDiff captures action kind, effect rights, assumptions, evidence,
  expected receipt, and risk deltas.
- RuntimeVerificationReceipt verifies v1 before acceptance.
- AcceptanceReceipt links to v1, current ReviewProjection v1, and runtime
  verification.
- HA-1..HA-5 negative cases are covered.

[R] Recommendations:
- Compiler/Grammar: formalize MeaningDiff, acceptance scope, reviewer
  authority, and review projection freshness.
- Bridge: define proposal/review/diff/correction/verification/acceptance
  metadata profiles before package-facing UI work.

[S] Signals:
- Human review needs semantic surfaces, not only syntax.
- Effect-right changes are meaning changes even when text diffs are small.
- Acceptance is scoped, receipt-bearing, and verification-linked.

[T] Tests / Proofs:
- human_agent_readable_contracts_fixture.rb -> PASS

[Files] Changed:
- igniter-lang/experiments/human_agent_readable_contracts_fixture/human_agent_readable_contracts_fixture.rb
- igniter-lang/docs/tracks/human-agent-readable-contracts-fixture-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Is MeaningDiff over source, SemanticIR, SemanticImage, or all three?
- How should reviewer authority be typed?
- Can correction add effect rights or must it become a new proposal cycle?
- What is the minimal human-readable SemanticImage slice?

[X] Rejected:
- Real Spark data or endpoints.
- Prose-only contract acceptance.
- Acceptance without runtime verification.
- Effect-right changes without MeaningDiff.

[Next] Proposed next slice:
- Compiler/Grammar Expert: MeaningDiff and acceptance semantics.
- Bridge Agent: AgentProposal, ReviewProjection, MeaningDiff, and
  AcceptanceReceipt bridge profiles.
```
