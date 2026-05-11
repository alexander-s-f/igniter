# Track: Compiler Profile Manifest PROP Architect Routing v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-manifest-prop-architect-routing-v0`
Status: done
Date: 2026-05-11

---

## Goal

Route the `compiler_profile_id` manifest PROP packet to Architect decision
without assigning a proposal number, creating a proposal file, mutating the
proposal queue, or unblocking implementation.

This track is routing evidence only.

---

## Added Proof

Added:

```text
igniter-lang/experiments/compiler_profile_manifest_prop_architect_routing/compiler_profile_manifest_prop_architect_routing.rb
igniter-lang/experiments/compiler_profile_manifest_prop_architect_routing/out/compiler_profile_manifest_prop_architect_routing_packet.json
igniter-lang/experiments/compiler_profile_manifest_prop_architect_routing/out/compiler_profile_manifest_prop_architect_routing_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_manifest_prop_architect_routing/compiler_profile_manifest_prop_architect_routing.rb
```

Result:

```text
PASS compiler_profile_manifest_prop_architect_routing
```

The runner refreshes:

```text
compiler_profile_prop_numbering_decision
```

and then builds an Architect-facing routing packet.

---

## Routing Target

```json
{
  "primary_owner": "[Architect Supervisor / Codex]",
  "secondary_review_owner": "[Igniter-Lang Compiler/Grammar Expert]",
  "requested_action": "assign_or_route_official_prop_number",
  "research_agent_decision_authority": false
}
```

[D] Research prepares the route. Architect owns the official numbering/routing
decision.

---

## Queue State

Observed:

```text
PROP-033 occupied by `via profile binding`
highest explicit PROP id seen: PROP-035
candidate id if queue unchanged: PROP-036
```

[D] `PROP-036` is a candidate only. This track does not assign it.

Alternate Architect routes remain possible:

```text
Requeue via profile binding and assign compiler_profile_id manifest semantics to PROP-033.
Keep this as a non-numbered draft until proposal queue is reconciled.
```

---

## Payload Ready For Review

```text
title: compiler_profile_id manifest semantics
field: compiler_profile_id
profile_id_source_recommendation: unified_compiler_profile_id
initial_rollout: legacy_optional
future_rollout: profile_required_after_migration_evidence
hash/signature: compiler_profile_id participates in artifact hash and must be added before signing
```

Prepared proposal sections:

```text
status
problem
field_shape
hash_and_signature_policy
loader_policy
compatibility_report_policy
compilation_receipt_relationship
slot_order_and_profile_identity
bootstrap_and_audit_traceability
migration_order
implementation_cards
```

---

## Architect Decisions Requested

```text
Assign official PROP number or choose requeue path.
Confirm unified_compiler_profile_id as manifest authority source.
Approve legacy_optional -> profile_required migration policy.
Approve hash/signature ordering.
Choose expanded profile material storage surface.
Decide whether implementation cards may open after proposal approval.
```

---

## Must Preserve

```text
compiler_profile_status.present_verified must not imply runtime_evaluation_readiness.ready
receipt_runtime_execution_authority: false
profile_runtime_execution_authority: false
required exactly-one slots: core, oof_registry, fragment_registry, escape_boundary
future dispatch order source: CompilerProfileSpec.slot_order
surface slot order authoritative: false
bootstrap seed explicit: true
```

---

## Still Blocked

```text
assembler-compiler-profile-id-field-v0
loader-compiler-profile-status-report-v0
artifact-hash-profile-id-golden-migration-v0
compilation-receipt-manifest-link-v0
```

[D] This routing packet does not unblock implementation cards.

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.numbering_decision_passed` | Numbering decision request regenerated and passed. |
| `routing.ready_for_architect` | Packet is ready for Architect routing. |
| `routing.primary_owner_architect` | Architect is primary owner. |
| `routing.research_has_no_decision_authority` | Research does not decide numbering. |
| `queue.prop033_occupied_and_candidate_prop036` | Queue observation matches current proposal index. |
| `proposal.payload_has_compiler_profile_id_field` | Payload carries `compiler_profile_id`. |
| `proposal.recommends_unified_profile_id` | Recommendation prefers unified compiler profile id. |
| `firewall.present_verified_not_runtime_ready` | Runtime readiness firewall is preserved. |
| `blocked.implementation_cards_remain_blocked` | Implementation cards stay blocked. |
| `scope.no_prop_number_assigned` | No PROP number assigned. |
| `scope.no_proposal_queue_mutation` | Proposal index unchanged. |
| `scope.no_runtime_authority` | No runtime authority introduced. |

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: compiler-profile-manifest-prop-architect-routing-v0
Status: done

[D] Decisions:
- Created Architect-facing routing packet for compiler_profile_id manifest PROP.
- Did not assign PROP-036 or any other official number.
- Did not create or edit proposal files.
- Did not unblock implementation cards.

[S] Signals:
- PROP-033 is occupied by via profile binding.
- PROP-036 is the candidate if queue remains unchanged.
- Payload is ready for Architect review with unified_compiler_profile_id recommendation.

[T] Tests:
- ruby igniter-lang/experiments/compiler_profile_manifest_prop_architect_routing/compiler_profile_manifest_prop_architect_routing.rb -> PASS

[R] Risks:
- Architect may choose a different numbering/requeue route.
- Implementation remains blocked until proposal approval.

[Next]
- Update closure index and tracks index.
- Route packet to Architect Supervisor / Codex for official decision.
```
