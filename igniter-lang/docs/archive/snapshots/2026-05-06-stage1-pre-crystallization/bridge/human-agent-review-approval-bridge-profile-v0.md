# Human Agent Review Approval Bridge Profile v0

Role: `[Igniter-Lang Bridge Agent]`
Track: `igniter-lang/human-agent-review-approval-bridge-profile-v0`
Status: proposal
Date: 2026-05-06
Neighbors: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Applied Pressure Agent]`

## Purpose

Prepare metadata-only bridge profiles for human-agent review and acceptance.

This note does not authorize package edits, platform UI work, production
effects, provider calls, or prose-only acceptance.

## Current Horizon

- Agent prose is not an artifact of record.
- Human-readable review is not runtime verification.
- Acceptance means verified artifact plus current review projection plus
  receipt.
- Meaning changes require semantic diff evidence, not only text diff.
- Reviewer authority and projection freshness are part of acceptance evidence.

## Source Signals

[S] `human-agent-readable-contracts-fixture-v0` is executable and synthetic. It
proves:

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

[S] The proof passes review and acceptance checks:

```text
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
```

[S] `human-agent-readable-contracts-pressure-v0` fixes the guardrail:

```text
agent prose != artifact of record
human "looks good" != accepted semantic artifact
accepted text != trusted unless runtime verifies the contract artifact
```

## Bridge Claim

[D] Human-agent review can move toward platform work only as metadata-only
proposal, review, diff, correction, verification, and acceptance profiles:

```text
AgentProposalReceipt
  -> ReviewProjection
  -> MeaningDiffReport
  -> HumanCorrectionReceipt
  -> RuntimeVerificationReceipt
  -> AcceptanceReceipt
```

[D] These profiles may record review and scoped acceptance. They must not
execute effects, create provider calls, mutate application state, or treat chat
prose as the accepted artifact.

## JSON Profile Examples

### AgentProposalReceipt

```json
{
  "receipt_id": "agent_proposal/appointment-cancel/v0",
  "profile": "agent_proposal_receipt_v0",
  "agent_ref": "redacted:agent:fixture-codex-001",
  "idea_draft_ref": "idea/appointment-cancel-action/draft-001",
  "idea_draft_hash": "sha256:redacted-draft-hash",
  "proposed_artifact_ref": "intent_contract/appointment-cancel/v0",
  "proposed_artifact_hash": "sha256:redacted-contract-v0-hash",
  "proposed_at": "2026-05-06T13:51:00Z",
  "status": "proposal",
  "prose_policy": {
    "agent_prose_artifact_of_record": false,
    "prose_summary_ref": "redacted:prose-summary:draft-001",
    "confidence_statement_policy": "non_evidence_without_checks"
  },
  "evidence_links": {
    "idea_draft_observation_ref": "obs/idea-draft-v0",
    "proposed_artifact_observation_ref": "obs/intent-contract-v0",
    "produced_in": "session/human-agent-readable-contracts-fixture-v0"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "review_only": true,
    "proposal_trusted": false,
    "may_authorize_acceptance": false,
    "may_authorize_production_action": false,
    "package_edit_authorized": false,
    "ledger_core": false
  }
}
```

### ReviewProjection

```json
{
  "projection_id": "review/appointment-cancel/v1",
  "profile": "review_projection_v0",
  "contract_ref": "intent_contract/appointment-cancel/v1",
  "contract_hash": "sha256:redacted-contract-v1-hash",
  "generated_at": "2026-05-06T14:00:00Z",
  "freshness": {
    "fresh_for_contract_ref": "intent_contract/appointment-cancel/v1",
    "fresh_for_contract_hash": "sha256:redacted-contract-v1-hash",
    "expires_at": "2026-05-06T15:00:00Z",
    "stale_after_contract_change": true
  },
  "inspectable_sections": [
    "intent",
    "effect_rights",
    "assumptions",
    "evidence_requirements",
    "risk_declarations",
    "trust_boundaries",
    "expected_receipts"
  ],
  "intent": {
    "action": "appointment_cancel_request",
    "claimed_kind": "request",
    "human_summary": "Technician cancel action"
  },
  "effect_rights": {
    "create_operation_request": "requested",
    "mutate_schedule_status": "denied",
    "create_external_bridge_record_without_capability": "denied"
  },
  "evidence_requirements": [
    "ActorObservation",
    "ScheduleStateObservation",
    "ActionPolicyProjection",
    "duplicate_pending_request_check"
  ],
  "expected_receipts": [
    "OperationRequestReceipt",
    "optional ExternalBridgeReceipt only when capability-gated"
  ],
  "risks": [
    "request action cannot mutate schedule",
    "optional bridge effect is capability-gated",
    "duplicate pending request requires suppression"
  ],
  "evidence_links": {
    "projects": "intent_contract/appointment-cancel/v1",
    "artifact_observation_ref": "obs/intent-contract-v1"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "review_only": true,
    "artifact_of_record": false,
    "may_authorize_acceptance_without_verification": false,
    "may_authorize_production_action": false,
    "package_edit_authorized": false,
    "ledger_core": false
  }
}
```

### MeaningDiffReport

```json
{
  "diff_id": "meaning_diff/appointment-cancel/v0-v1",
  "profile": "meaning_diff_report_v0",
  "before_artifact_ref": "intent_contract/appointment-cancel/v0",
  "before_artifact_hash": "sha256:redacted-contract-v0-hash",
  "after_artifact_ref": "intent_contract/appointment-cancel/v1",
  "after_artifact_hash": "sha256:redacted-contract-v1-hash",
  "changed_intent": {
    "action_kind": ["execution", "request"]
  },
  "changed_effect_rights": {
    "removed": [
      "mutate_schedule_status",
      "create_external_bridge_record"
    ],
    "added_denials": [
      "create_external_bridge_record_without_capability"
    ]
  },
  "changed_assumptions": {
    "removed": [
      "cancel request should mark schedule canceled"
    ],
    "added": [
      "request creates pending review workflow",
      "request does not cancel the schedule"
    ]
  },
  "changed_evidence_requirements": {
    "added": ["duplicate_pending_request_check"]
  },
  "changed_expected_receipts": {
    "removed": ["OperationExecutionReceipt"],
    "added": [
      "OperationRequestReceipt",
      "optional ExternalBridgeReceipt only when capability-gated"
    ]
  },
  "risk_delta": {
    "schedule_mutation_risk": "reduced",
    "bridge_escape_risk": "gated"
  },
  "requires_reverification": true,
  "evidence_links": {
    "before": "obs/intent-contract-v0",
    "after": "obs/intent-contract-v1"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "review_only": true,
    "text_diff_sufficient": false,
    "may_authorize_acceptance_without_verification": false,
    "may_authorize_production_action": false,
    "package_edit_authorized": false,
    "ledger_core": false
  }
}
```

### HumanCorrectionReceipt

```json
{
  "receipt_id": "human_correction/appointment-cancel/v0-v1",
  "profile": "human_correction_receipt_v0",
  "reviewer_ref": "redacted:reviewer:fixture-operator-001",
  "reviewer_authority_ref": "authority/reviewer/fixture-scope@1",
  "authority_check_ref": "obs/reviewer-authority-check-001",
  "before_artifact_ref": "intent_contract/appointment-cancel/v0",
  "before_artifact_hash": "sha256:redacted-contract-v0-hash",
  "after_artifact_ref": "intent_contract/appointment-cancel/v1",
  "after_artifact_hash": "sha256:redacted-contract-v1-hash",
  "meaning_diff_ref": "meaning_diff/appointment-cancel/v0-v1",
  "correction_reason": "request_action_must_not_mutate_schedule",
  "corrected_at": "2026-05-06T14:05:00Z",
  "status": "corrected",
  "evidence_links": {
    "materializes": "meaning_diff/appointment-cancel/v0-v1",
    "review_projection_ref": "review/appointment-cancel/v0",
    "reviewer_authority_check_ref": "obs/reviewer-authority-check-001"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "review_only": true,
    "correction_adds_effect_rights_authorized": false,
    "requires_reverification": true,
    "may_authorize_production_action": false,
    "package_edit_authorized": false,
    "ledger_core": false
  }
}
```

### RuntimeVerificationReceipt

```json
{
  "receipt_id": "runtime_verification/appointment-cancel/v1",
  "profile": "runtime_verification_receipt_v0",
  "verified_artifact_ref": "intent_contract/appointment-cancel/v1",
  "verified_artifact_hash": "sha256:redacted-contract-v1-hash",
  "verified_at": "2026-05-06T14:08:00Z",
  "verification_context": {
    "runtime_ref": "runtime/synthetic-fixture",
    "schema_version": "intent_contract@0.1.0",
    "scope": "fixture"
  },
  "checks": {
    "parsed_program": "ok",
    "classified_program": "ok",
    "typed_program": "ok",
    "semantic_ir_no_unresolved_effects": "ok",
    "request_execution_boundary": "ok",
    "denied_effect_rights_enforced": "ok",
    "bridge_capability_requirement": "ok"
  },
  "status": "verified",
  "evidence_links": {
    "verifies": "obs/intent-contract-v1",
    "observed_under": "runtime/synthetic-fixture"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "verification_only": true,
    "acceptance_authorized": false,
    "may_authorize_production_action": false,
    "package_edit_authorized": false,
    "ledger_core": false
  }
}
```

### AcceptanceReceipt

```json
{
  "receipt_id": "acceptance/appointment-cancel/v1",
  "profile": "acceptance_receipt_v0",
  "reviewer_ref": "redacted:reviewer:fixture-operator-001",
  "reviewer_authority_ref": "authority/reviewer/fixture-scope@1",
  "authority_check_ref": "obs/reviewer-authority-check-001",
  "accepted_artifact_ref": "intent_contract/appointment-cancel/v1",
  "accepted_artifact_hash": "sha256:redacted-contract-v1-hash",
  "review_projection_ref": "review/appointment-cancel/v1",
  "review_projection_contract_ref": "intent_contract/appointment-cancel/v1",
  "review_projection_contract_hash": "sha256:redacted-contract-v1-hash",
  "review_projection_freshness_ref": "obs/review-projection-freshness-v1",
  "runtime_verification_ref": "runtime_verification/appointment-cancel/v1",
  "runtime_verification_status": "verified",
  "accepted_at": "2026-05-06T14:10:00Z",
  "accepted_scope": {
    "scope": "fixture",
    "domain": "synthetic_spark_like_operation_action",
    "allowed_scopes": ["fixture", "staging", "production", "review_only"],
    "production_effects_allowed": false
  },
  "status": "accepted_for_fixture",
  "evidence_links": {
    "accepts": "obs/intent-contract-v1",
    "reviewed_as": "obs/review-projection-v1",
    "verified_by": "obs/runtime-verification-v1",
    "authorized_by": "obs/reviewer-authority-check-001"
  },
  "semantics": {
    "report_only": true,
    "runtime_enforced": false,
    "acceptance_scope_only": true,
    "may_authorize_production_action": false,
    "may_execute_effects": false,
    "may_call_provider": false,
    "package_edit_authorized": false,
    "ledger_core": false
  }
}
```

## Acceptance Scope

```json
{
  "fixture": {
    "meaning": "Accepted for synthetic fixture proof only.",
    "production_effects_allowed": false
  },
  "staging": {
    "meaning": "Accepted for non-production integration rehearsal.",
    "requires": ["staging_reviewer_authority", "runtime_verification", "fresh_review_projection"],
    "production_effects_allowed": false
  },
  "production": {
    "meaning": "Accepted as production artifact candidate, not production action.",
    "requires": ["production_reviewer_authority", "runtime_verification", "fresh_review_projection", "deployment_policy"],
    "production_effects_allowed": "only by separate deployment/action receipt"
  },
  "review_only": {
    "meaning": "Accepted as reviewed analysis only.",
    "production_effects_allowed": false
  }
}
```

[D] Production-scope acceptance of an artifact is not operational execution.
Production effects require a separate action, capability, deployment, or
runtime receipt.

## Reviewer Identity And Redaction Policy

[D] Reviewer identity must be evidence-linked, authority-scoped, and redacted
by default.

Rules:

- package payloads default to `raw_reviewer_ref_export: false`
- reviewer refs use redacted or hash-wrapped identifiers
- authority is represented by `reviewer_authority_ref` plus
  `authority_check_ref`, not by raw role prose
- freshness must link to the accepted artifact hash and current review
  projection hash
- reviewer emails, names, HR identifiers, provider identities, customer data,
  endpoints, tokens, secrets, and infrastructure details are not allowed in
  public diagnostic payloads
- agent prose may be summarized, but the accepted artifact must be the
  structured artifact hash plus receipt links

Example policy:

```json
{
  "profile": "human_agent_review_public_metadata_v0",
  "redacted_ref_kinds": ["reviewer", "agent", "human", "company", "schedule", "order", "provider", "customer"],
  "raw_reviewer_ref_export": false,
  "raw_agent_ref_export": false,
  "hash_source_refs": true,
  "allow_synthetic_refs_in_research": true
}
```

## Diagnostic Codes To Preserve

- `human_agent.prose_not_artifact_of_record`
- `human_agent.acceptance_requires_runtime_verification`
- `meaning_diff.required_for_effect_right_change`
- `review_projection.contract_ref_mismatch`
- `effect_right.escape_capability_missing`
- `reviewer.authority_missing`
- `review_projection.freshness_expired`

## Package Touchpoint Recommendation

[R] First package touchpoint, if Architect approves:

```text
packages/igniter-contracts/
  Igniter::Lang::VerificationReport
  optional generic review / acceptance receipts payload section
```

Recommended first package surface:

```text
Igniter::Lang::ReviewAcceptanceProfile
```

or, for the smallest package change:

```text
VerificationReport#metadata[:review_projections]
VerificationReport#metadata[:meaning_diff_reports]
VerificationReport#metadata[:review_receipts]
VerificationReport#metadata[:acceptance_receipts]
```

Why first:

- `igniter-contracts` already carries report-only Lang metadata and diagnostic
  precedent.
- Review, diff, verification, and acceptance can stay generic and
  non-authorizing.
- It avoids package UI, operational execution, provider adapters, and
  Ledger-as-core coupling.

Not first:

- Platform UI: blocked by this bridge profile.
- `packages/igniter-application`: may later consume review metadata, but
  should not own the generic review/acceptance semantics first.
- `packages/igniter-ledger` / Ledger clients: may later transport receipt refs
  as a TBackend adapter, but must not become language core.
- Spark-specific package namespaces: blocked.

## Explicit Non-Authorization Rules

[D] Every profile in this note is metadata-only unless a later Architect
approval says otherwise:

```json
{
  "report_only": true,
  "runtime_enforced": false,
  "may_authorize_production_action": false,
  "may_execute_effects": false,
  "may_call_provider": false,
  "package_edit_authorized": false,
  "ledger_core": false
}
```

[X] This bridge does not authorize:

- package edits
- platform UI work
- accepting agent prose as artifact of record
- casual human approval without `AcceptanceReceipt`
- acceptance without runtime verification
- accepting stale review projection for a newer artifact
- effect-right or trust-boundary changes without `MeaningDiffReport`
- new ESCAPE effect rights without capability requirements
- production effects, provider calls, deployment, or operation execution
- treating Ledger as language core

## Package Agent Approval / Blocker Note

[R] Package Agent may start only after explicit Architect Supervisor approval.
The approved package slice should be generic, metadata-only, report-only, and
non-authorizing.

[X] Package Agent is blocked from:

- editing packages from this bridge slice
- adding platform review UI
- creating Spark-specific public package classes
- implementing artifact acceptance workflows as runtime enforcement
- turning `AcceptanceReceipt` into operation execution or deployment
- storing raw reviewer/agent/customer/provider refs by default
- treating prose summaries as accepted artifacts
- treating Ledger as language core

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/human-agent-review-approval-bridge-profile-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert | Bridge Agent | Applied Pressure Agent

[D] Decisions:
- Mapped executable human-agent readable contracts fixture into metadata-only bridge profiles.
- Defined JSON profiles for AgentProposalReceipt, ReviewProjection, MeaningDiffReport, HumanCorrectionReceipt, RuntimeVerificationReceipt, and AcceptanceReceipt.
- Added acceptance scopes: fixture, staging, production, review-only.
- Required reviewer authority and freshness links for acceptance.
- Preserved explicit rule: agent prose is not artifact of record.
- Added non-authorization rules for package edits, platform UI, production effects, provider calls, and Ledger-as-core.

[R] Recommendations:
- First package touchpoint, after Architect approval, should be packages/igniter-contracts as a generic report-only review/acceptance carrier.
- Prefer VerificationReport metadata sections for smallest surface, or Igniter::Lang::ReviewAcceptanceProfile if a standalone class is approved.
- Keep platform UI and application execution as later consumers only.

[S] Signals:
- human_agent_readable_contracts_fixture.rb passes proposal, correction, diff, verification, acceptance, prose-blocking, stale projection, and ESCAPE-capability checks.
- Acceptance is scoped, receipt-bearing, verification-linked, and freshness-linked.
- Effect-right changes are meaning changes even when text diffs are small.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/human_agent_readable_contracts_fixture/human_agent_readable_contracts_fixture.rb -> PASS.

[Files] Changed:
- igniter-lang/docs/bridge/human-agent-review-approval-bridge-profile-v0.md
- igniter-lang/docs/bridge/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/agent-motion.md

[Q] Open Questions:
- Should first package work use VerificationReport metadata sections or a standalone ReviewAcceptanceProfile class?
- Is MeaningDiff over source, SemanticIR, SemanticImage, or all three?
- Can HumanCorrectionReceipt add effect rights, or must it always restart proposal and verification?

[X] Rejected:
- Package edits in this slice.
- Agent prose as artifact of record.
- Acceptance without runtime verification.
- Stale ReviewProjection acceptance.
- Effect-right changes without MeaningDiffReport.
- Production effects, provider calls, deployment, operation execution, and Ledger-as-core.

[Next] Proposed next slice:
- Architect-reviewed package plan for generic review/acceptance receipt carriers in igniter-contracts.
```
