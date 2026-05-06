# Track: Human Agent Readable Contracts Pressure v0

Role: `[Igniter-Lang Applied Pressure Agent]`
Track: `igniter-lang/docs/tracks/human-agent-readable-contracts-pressure-v0.md`
Status: done
Slice state: done on 2026-05-06
Affected neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

## Frame

This track opens the human-agent symbiosis pressure lane for Igniter-Lang.

The first symbiosis case is review-native authoring:

```text
agent proposes a contract
  -> human reviews intent, risks, effect rights, assumptions, and evidence
  -> human corrects or accepts
  -> runtime verifies and records the accepted artifact
```

Safety boundary:

- synthetic IDs only;
- no real Spark data, customers, tenants, employees, orders, endpoints,
  provider payloads, tokens, credentials, or infrastructure details;
- agent prose is never the artifact of record;
- accepted contract, semantic image, meaning diff, and receipts are the
  artifact of record.

## Source Horizon

- `igniter-lang/docs/applied-pressure-directions.md`
- `igniter-lang/docs/tracks/spark-operation-action-lifecycle-pressure-v0.md`
- `igniter-lang/docs/tracks/sandbox-simulation-world-modeling-pressure-v0.md`
- `igniter-lang/docs/tracks/observable-spine-v0.md`
- `igniter-lang/docs/tracks/failure-observation-v0.md`
- `igniter-lang/docs/proposals/PROP-012-compilation-artifact-deployment-model-v0.md`
- `igniter-lang/docs/proposals/PROP-017-schema-evolution-contract-migration-v0.md`

## Compact Claim

[D] Igniter-Lang should support an authoring loop where an agent can help
write contracts, but the language makes review and acceptance explicit:

```text
IdeaDraft
  -> IntentContract
  -> AgentProposalObservation
  -> ReviewProjection
  -> MeaningDiff
  -> HumanCorrectionReceipt
  -> AcceptanceReceipt
  -> RuntimeVerificationReceipt
```

[D] The guardrail:

```text
agent prose != artifact of record
human "looks good" != accepted semantic artifact
accepted text != trusted unless runtime verifies the contract artifact
```

## Pressure Vocabulary

### IdeaDraft

An `IdeaDraft` is an informal, pre-contract statement of intent. It may contain
prose, ambiguity, and missing details.

```text
IdeaDraft = {
  draft_id,
  author_ref,
  created_at,
  prose_summary,
  target_domain,
  known_gaps,
  artifact_status: :not_record
}
```

### IntentContract

An `IntentContract` is the structured artifact proposed for review. It is not
accepted until reviewed and verified.

```text
IntentContract = {
  contract_id,
  contract_kind,
  subject_scope,
  inputs,
  outputs,
  assumptions,
  effect_rights,
  evidence_requirements,
  risk_declarations,
  schema_version
}
```

### AgentProposalObservation

An `AgentProposalObservation` records that an agent proposed an artifact and
links prose to the structured contract. It does not make the proposal trusted.

```text
AgentProposalObservation = {
  obs_id,
  agent_ref,
  idea_draft_ref,
  proposed_contract_ref,
  proposed_at,
  confidence_statement_policy,
  status: :proposal
}
```

### ReviewProjection

`ReviewProjection` is a human-readable semantic view over the proposed
contract, not a pretty rendering of source text.

```text
ReviewProjection = {
  projection_id,
  contract_ref,
  inspectable_sections:
    - intent
    - effect_rights
    - assumptions
    - evidence_requirements
    - risk_declarations
    - trust_boundaries
    - expected_receipts
}
```

### MeaningDiff

`MeaningDiff` compares two contract artifacts by semantic consequence.

```text
MeaningDiff = {
  diff_id,
  before_contract_ref,
  after_contract_ref,
  changed_intent,
  changed_effect_rights,
  changed_assumptions,
  changed_evidence_requirements,
  changed_outputs,
  risk_delta,
  requires_reverification: true
}
```

[D] A text diff can say one line changed. A `MeaningDiff` must say whether
effect rights, trust boundaries, assumptions, or outputs changed.

### HumanCorrectionReceipt

`HumanCorrectionReceipt` records a human review action that changes the
proposal.

```text
HumanCorrectionReceipt = {
  receipt_id,
  reviewer_ref,
  before_contract_ref,
  after_contract_ref,
  meaning_diff_ref,
  correction_reason,
  corrected_at,
  status: :corrected
}
```

### AcceptanceReceipt

`AcceptanceReceipt` records human acceptance of a verified artifact.

```text
AcceptanceReceipt = {
  receipt_id,
  reviewer_ref,
  accepted_contract_ref,
  review_projection_ref,
  runtime_verification_ref,
  accepted_at,
  accepted_scope,
  status: :accepted
}
```

## Synthetic Spark-Like Example

The example uses the operation action lifecycle lane, but remains fully
synthetic.

The agent proposes a contract for a technician appointment cancel action. The
initial proposal incorrectly treats cancel request as an execution-like action
that may mutate schedule status. The human correction narrows it:

```text
appointment_cancel_request
  is request action
  creates pending OperationRequestReceipt
  does not mutate schedule/order state
  may create optional bridge receipt only with declared capability
```

## Fixture Identity

```text
fixture_id: human_agent_readable_contracts_minimal_v0
domain: synthetic_spark_like_operation_action
agent_ref: agent/fixture-codex-001
human_reviewer_ref: human/fixture-operator-001
company_ref: company/fixture-acme
schedule_ref: schedule/fixture-s-200
order_ref: order/fixture-o-200
contract_schema_version: intent_contract@0.1.0
review_time: 2026-05-06T14:00:00Z
```

## Proposed Artifact: v0

### IdeaDraft

```text
IdeaDraft = {
  draft_id: idea/appointment-cancel-action/draft-001
  author_ref: agent/fixture-codex-001
  created_at: 2026-05-06T13:50:00Z
  prose_summary: "Let technicians cancel appointments from the action menu."
  target_domain: synthetic_spark_like_operation_action
  known_gaps:
    - request_vs_execution_not_confirmed
    - bridge_capability_not_confirmed
    - schedule_mutation_policy_not_confirmed
  artifact_status: :not_record
}
```

### IntentContract v0

```text
IntentContract v0 = {
  contract_id: intent_contract/appointment-cancel/v0
  contract_kind: :operation_action
  action: appointment_cancel_request
  action_kind: :execution
  subject_scope:
    company_ref: company/fixture-acme
    subject_kind: :schedule
  effect_rights:
    - create_operation_request
    - mutate_schedule_status
    - create_external_bridge_record
  assumptions:
    - technician can manage own appointment
    - cancel request should mark schedule canceled
  evidence_requirements:
    - ActorObservation
    - ScheduleStateObservation
    - ActionPolicyProjection
  expected_receipts:
    - OperationExecutionReceipt
  risk_declarations:
    - may affect appointment lifecycle
}
```

### Agent Proposal Observation

```text
AgentProposalObservation = {
  obs_id: obs/agent-proposal/appointment-cancel/v0
  agent_ref: agent/fixture-codex-001
  idea_draft_ref: idea/appointment-cancel-action/draft-001
  proposed_contract_ref: intent_contract/appointment-cancel/v0
  proposed_at: 2026-05-06T13:51:00Z
  status: :proposal
}
```

## Review Projection

The human needs to inspect semantic surfaces, not only syntax.

```text
ReviewProjection = {
  projection_id: review/appointment-cancel/v0
  contract_ref: intent_contract/appointment-cancel/v0
  intent:
    action: appointment_cancel_request
    claimed_kind: :execution
    human_summary: "Technician cancel action"
  effect_rights:
    create_operation_request: requested
    mutate_schedule_status: requested
    create_external_bridge_record: requested
  assumptions:
    - cancel request should mark schedule canceled
  evidence_requirements:
    - actor scope
    - schedule state
    - action policy
  risks:
    - request action is granting mutation rights
    - bridge effect has no capability gate
    - expected receipt kind is execution, not request
}
```

Human inspection checklist:

| Surface | Human question | v0 answer |
|---------|----------------|-----------|
| Intent | What is this contract trying to do? | let technician request appointment cancellation |
| Risk | Can it change real state? | yes, incorrectly requests schedule mutation |
| Effect rights | What can it do? | create request, mutate schedule, create bridge |
| Assumptions | What is assumed? | request means canceled |
| Evidence | What must be checked? | actor/schedule/policy |
| Receipts | What proves it happened? | wrong receipt kind: execution |

## Human Correction

The reviewer corrects the contract from execution to request lifecycle.

```text
IntentContract v1 = {
  contract_id: intent_contract/appointment-cancel/v1
  contract_kind: :operation_action
  action: appointment_cancel_request
  action_kind: :request
  subject_scope:
    company_ref: company/fixture-acme
    subject_kind: :schedule
  effect_rights:
    - create_operation_request
  denied_effect_rights:
    - mutate_schedule_status
    - create_external_bridge_record_without_capability
  assumptions:
    - technician can request cancellation for own manageable appointment
    - request creates pending review workflow
    - request does not cancel the schedule
  evidence_requirements:
    - ActorObservation
    - ScheduleStateObservation
    - ActionPolicyProjection
    - duplicate_pending_request_check
  expected_receipts:
    - OperationRequestReceipt
    - optional ExternalBridgeReceipt only when capability-gated
  risk_declarations:
    - duplicate pending request must be suppressed
    - schedule mutation requires separate execution contract
}
```

### MeaningDiff

```text
MeaningDiff = {
  diff_id: meaning_diff/appointment-cancel/v0-v1
  before_contract_ref: intent_contract/appointment-cancel/v0
  after_contract_ref: intent_contract/appointment-cancel/v1
  changed_intent:
    action_kind: [:execution, :request]
  changed_effect_rights:
    removed:
      - mutate_schedule_status
      - create_external_bridge_record
    added_denials:
      - create_external_bridge_record_without_capability
  changed_assumptions:
    removed:
      - cancel request should mark schedule canceled
    added:
      - request creates pending review workflow
      - request does not cancel the schedule
  changed_evidence_requirements:
    added:
      - duplicate_pending_request_check
  changed_expected_receipts:
    removed:
      - OperationExecutionReceipt
    added:
      - OperationRequestReceipt
      - optional ExternalBridgeReceipt only when capability-gated
  risk_delta:
    schedule_mutation_risk: reduced
    bridge_escape_risk: gated
  requires_reverification: true
}
```

### Human Correction Receipt

```text
HumanCorrectionReceipt = {
  receipt_id: human_correction/appointment-cancel/v0-v1
  reviewer_ref: human/fixture-operator-001
  before_contract_ref: intent_contract/appointment-cancel/v0
  after_contract_ref: intent_contract/appointment-cancel/v1
  meaning_diff_ref: meaning_diff/appointment-cancel/v0-v1
  correction_reason: request_action_must_not_mutate_schedule
  corrected_at: 2026-05-06T14:05:00Z
  status: :corrected
}
```

## Runtime Verification And Acceptance

Runtime verification checks the accepted contract shape before acceptance.

```text
RuntimeVerificationReceipt = {
  receipt_id: runtime_verification/appointment-cancel/v1
  verified_contract_ref: intent_contract/appointment-cancel/v1
  checks:
    parsed_program: :ok
    classified_program: :ok
    typed_program: :ok
    semantic_ir_no_unresolved_effects: :ok
    request_execution_boundary: :ok
    denied_effect_rights_enforced: :ok
    bridge_capability_requirement: :ok
  status: :verified
}
```

Acceptance:

```text
AcceptanceReceipt = {
  receipt_id: acceptance/appointment-cancel/v1
  reviewer_ref: human/fixture-operator-001
  accepted_contract_ref: intent_contract/appointment-cancel/v1
  review_projection_ref: review/appointment-cancel/v1
  runtime_verification_ref: runtime_verification/appointment-cancel/v1
  accepted_at: 2026-05-06T14:10:00Z
  accepted_scope:
    domain: synthetic_spark_like_operation_action
    production_effects_allowed: false
  status: :accepted_for_fixture
}
```

[D] Acceptance is a receipt over a verified artifact. It is not a chat message
or prose summary.

## Expected Result Table

| Stage | Artifact | Status | Artifact of record? |
|-------|----------|--------|---------------------|
| Agent idea | `IdeaDraft` | draft | no |
| Agent proposal | `IntentContract v0` + `AgentProposalObservation` | proposed | proposed artifact only |
| Human review | `ReviewProjection` | inspectable | no, projection over artifact |
| Human correction | `MeaningDiff` + `HumanCorrectionReceipt` | corrected | yes |
| Runtime verification | `RuntimeVerificationReceipt` | verified | yes |
| Human acceptance | `AcceptanceReceipt` over `IntentContract v1` | accepted_for_fixture | yes |

## Negative Cases

### HA-1: Agent Prose Treated As Contract

Input:

```text
source: agent prose
accepted_contract_ref: null
```

Expected:

```text
status: :blocked
diagnostic: human_agent.prose_not_artifact_of_record
```

### HA-2: Acceptance Without Runtime Verification

Input:

```text
accepted_contract_ref: intent_contract/appointment-cancel/v1
runtime_verification_ref: null
```

Expected:

```text
status: :blocked
diagnostic: human_agent.acceptance_requires_runtime_verification
```

### HA-3: Text Diff Hides Meaning Change

Input:

```text
text_diff: "changed action_kind field"
meaning_diff_ref: null
effect_rights_changed: true
```

Expected:

```text
status: :blocked
diagnostic: meaning_diff.required_for_effect_right_change
```

### HA-4: Human Accepts Stale Projection

Input:

```text
review_projection_ref: review/appointment-cancel/v0
accepted_contract_ref: intent_contract/appointment-cancel/v1
```

Expected:

```text
status: :blocked
diagnostic: review_projection.contract_ref_mismatch
```

### HA-5: Correction Grants New Escape Without Capability

Input:

```text
meaning_diff_ref: meaning_diff/grants-bridge-effect
added_effect_rights:
  - create_external_bridge_record
capability_requirement: null
```

Expected:

```text
status: :blocked
diagnostic: effect_right.escape_capability_missing
```

## What Current Igniter-Lang Handles

- Contract-addressable observations can represent proposal, correction,
  verification, and acceptance receipts.
- Existing RuntimeMachine and `.igapp` work already gives a verification
  spine: parse/classify/type/lower/load/evaluate.
- CORE / ESCAPE / OOF can classify effect rights and block bridge effects
  without capability.
- SemanticImage and CompatibilityReport provide precedent for human-readable
  semantic review surfaces.
- Schema migration and replacement image work already treats accepted semantic
  change as receipt-bearing, not casual text replacement.

## Where It Breaks Or Lacks Capability

- `MeaningDiff` is not formalized: text diffs do not answer whether intent,
  assumptions, risks, evidence, or effect rights changed.
- Acceptance semantics are not typed: accepted for fixture, staging,
  production, and review-only are different.
- Human reviewer identity and authority are not yet a language-level scope.
- Review projections need freshness and contract-ref matching rules.
- Agent proposal confidence needs policy: confidence prose must not become
  evidence unless linked to checks.
- There is no settled artifact shape for a human-readable SemanticImage slice.

## Concrete Research Fixture Request

Please implement a standalone fixture proof:

```text
track_request: human_agent_readable_contracts_fixture_v0
suggested_dir: igniter-lang/experiments/human_agent_readable_contracts_fixture/
inputs:
  - IdeaDraft for appointment_cancel_request
  - IntentContract v0 with incorrect execution/mutation rights
  - AgentProposalObservation
  - ReviewProjection v0
  - IntentContract v1 corrected to request-only lifecycle
  - MeaningDiff v0 -> v1
  - HumanCorrectionReceipt
  - RuntimeVerificationReceipt
  - AcceptanceReceipt
  - negative cases HA-1..HA-5
outputs:
  - golden proposal packet
  - golden review projection
  - golden meaning diff
  - golden correction receipt
  - golden acceptance receipt
  - golden negative diagnostics
checker:
  - rejects prose without contract artifact
  - rejects acceptance without runtime verification
  - rejects effect-right changes without MeaningDiff
  - rejects stale review projection acceptance
  - rejects new ESCAPE effect rights without capability requirement
safety:
  - synthetic facts only
  - no Spark data, endpoints, provider payloads, credentials, tokens, customer
    data, or infrastructure names
```

Proof acceptance:

- `IntentContract v0` is proposed but not accepted;
- human correction produces `IntentContract v1`;
- `MeaningDiff` captures action kind, effect rights, assumptions, evidence,
  expected receipt, and risk deltas;
- acceptance links to runtime verification and current review projection;
- agent prose is never accepted as artifact of record.

## Compiler/Grammar Expert Questions

1. Is `MeaningDiff` a compiler artifact, runtime artifact, bridge artifact, or
   language-level contract over two SemanticImages?
2. What is the minimal semantic diff domain: intent, inputs, outputs,
   assumptions, effect rights, evidence requirements, risk declarations,
   schema, and trust boundaries?
3. Should acceptance be typed by scope, for example `accepted_for_fixture`,
   `accepted_for_staging`, `accepted_for_production`, or represented by policy
   fields on one `AcceptanceReceipt`?
4. Can `ReviewProjection` be generated from SemanticIR / SemanticImage, or
   does it require source-level author annotations?
5. What formal rule blocks acceptance when the reviewed projection does not
   match the accepted contract hash?
6. Should human reviewer authority be a capability, tenant scope, actor scope,
   or a separate review authority contract?
7. How should agent confidence statements be typed so they remain prose policy
   unless backed by verification evidence?
8. Can a `HumanCorrectionReceipt` introduce new effect rights, or must it
   always force a fresh proposal and verification cycle?

## Bridge Agent Candidates

- `AgentProposalReceipt` bridge profile for proposed artifacts, author agent,
  draft link, proposed contract hash, and confidence policy.
- `ReviewProjection` bridge profile for human-readable intent, assumptions,
  effect rights, evidence requirements, risks, and trust boundaries.
- `MeaningDiffReport` bridge profile that maps semantic changes into review UI
  without relying on text diff.
- `HumanCorrectionReceipt` bridge profile for reviewer identity, correction
  reason, before/after artifact refs, and required reverification.
- `AcceptanceReceipt` bridge profile for accepted artifact hash, verification
  receipt, reviewer authority, accepted scope, and effective time.

## Handoff

```text
[Igniter-Lang Applied Pressure Agent]
Track: igniter-lang/docs/tracks/human-agent-readable-contracts-pressure-v0.md
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Opened the human-agent symbiosis lane around review-native contract
  authoring.
- Defined IdeaDraft, IntentContract, ReviewProjection, MeaningDiff,
  AgentProposalObservation, HumanCorrectionReceipt, and AcceptanceReceipt.
- Used a synthetic Spark-like appointment cancel request contract to show
  agent proposal, human correction, runtime verification, and acceptance.
- Treated agent prose as non-record; artifact of record is the verified
  contract plus meaning diff and receipts.

[R] Recommendations:
- Research Agent should implement the minimal fixture and checker for proposal,
  review projection, meaning diff, correction, verification, acceptance, and
  negative cases.
- Compiler/Grammar Expert should formalize MeaningDiff and acceptance
  semantics before source syntax expands around review flows.
- Bridge Agent should draft review/approval receipt profiles for UI and
  package-facing diagnostics.

[S] Signals:
- Human review needs semantic surfaces: intent, risk, effect rights,
  assumptions, and evidence, not just syntax.
- MeaningDiff is a language pressure point because effect-right changes can be
  tiny text edits with huge semantic consequences.
- Acceptance must be scoped and verification-linked.

[T] Tests / Proofs:
- Not run; documentation/specification slice only.
- Requested Research Agent proof:
  `igniter-lang/experiments/human_agent_readable_contracts_fixture/`.

[Files] Changed:
- igniter-lang/docs/tracks/human-agent-readable-contracts-pressure-v0.md
- igniter-lang/docs/README.md

[Q] Open Questions:
- Is MeaningDiff over source, SemanticIR, SemanticImage, or all three?
- How should acceptance scope and reviewer authority be typed?
- Can correction introduce new effect rights, or must it become a new
  proposal cycle?
- What is the minimal human-readable SemanticImage slice?

[X] Rejected:
- Treating agent prose as artifact of record.
- Treating casual human approval text as acceptance receipt.
- Accepting a contract without runtime verification.
- Relying on text diff when effect rights or trust boundaries changed.

[Next] Proposed next slice:
- Research Agent: implement `human_agent_readable_contracts_fixture_v0`.
- Compiler/Grammar Expert: formalize MeaningDiff and acceptance semantics.
- Bridge Agent: draft AgentProposal, ReviewProjection, MeaningDiff, and
  AcceptanceReceipt bridge candidates.
```
