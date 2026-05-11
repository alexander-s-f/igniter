# Track: Compiler Profile PROP Numbering Decision v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-prop-numbering-decision-v0`
Status: done
Date: 2026-05-11

---

## Goal

Prepare an Architect-owned numbering/routing decision request for the
`compiler_profile_id` manifest PROP without assigning a number, creating a
proposal file, or mutating the proposal queue.

This track is a decision-request packet, not the decision itself.

---

## Added Proof

Added:

```text
igniter-lang/experiments/compiler_profile_prop_numbering_decision/compiler_profile_prop_numbering_decision.rb
igniter-lang/experiments/compiler_profile_prop_numbering_decision/out/compiler_profile_prop_numbering_decision_packet.json
igniter-lang/experiments/compiler_profile_prop_numbering_decision/out/compiler_profile_prop_numbering_decision_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_prop_numbering_decision/compiler_profile_prop_numbering_decision.rb
```

Result:

```text
PASS compiler_profile_prop_numbering_decision
```

The runner refreshes:

```text
compiler_profile_manifest_prop_promotion
```

and then reads the current proposal queue to build a decision request.

---

## Queue Observation

Observed:

```json
{
  "prop033_occupied_by": "`via profile binding`",
  "highest_explicit_prop_id_seen": "PROP-035",
  "next_free_id_if_queue_unchanged": "PROP-036",
  "official_prop_number_assigned_by_this_packet": false
}
```

[D] `PROP-036` is only a candidate if the queue remains unchanged. This track
does not assign it.

---

## Recommended Decision Path

```text
route: architect_or_compiler_grammar_numbering_decision
preferred_numbering_option: assign_next_free_id
candidate_id_if_queue_unchanged: PROP-036
do_not_reassign_without_architect: PROP-033, PROP-034, PROP-035
```

Reason:

```text
PROP-033 is already queued for via profile binding, and the promotion packet
intentionally does not mutate the queue.
```

---

## Manifest Semantics Recommendation

Recommended for Architect review:

```text
field: compiler_profile_id
profile_id_source_recommendation: unified_compiler_profile_id
ordered_rule_profile_id_role: supporting evidence / transition diagnostic
initial_rollout: legacy_optional
future_rollout: profile_required_after_migration_evidence
hash/signature: add compiler_profile_id before artifact hash and signing
expanded profile material: sidecar or receipt bundle first; not inline by default
```

[R] Use unified compiler profile identity as the target manifest authority
because it composes slots, implementation ids, registries, and ordered rules.
Keep ordered-rule profile id as evidence during migration unless Architect
chooses otherwise.

---

## Preserved Invariants

```text
compiler_profile_status.present_verified must not imply runtime_evaluation_readiness.ready
CompilationReceipt has no runtime execution authority
CompilerProfile has no runtime execution authority
CompilerProfileSpec.slot_order remains future dispatch order
surface slot order is not authoritative
bootstrap seed remains explicit
```

Required exactly-one slots:

```text
core
oof_registry
fragment_registry
escape_boundary
```

---

## Still Blocked

```text
assembler-compiler-profile-id-field-v0
loader-compiler-profile-status-report-v0
artifact-hash-profile-id-golden-migration-v0
compilation-receipt-manifest-link-v0
```

These implementation cards remain blocked until official numbering/routing and
manifest semantics are approved.

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.promotion_passed` | Promotion proof regenerated and passed. |
| `queue.prop033_occupied` | `PROP-033` is already occupied by `via profile binding`. |
| `queue.next_free_candidate_is_prop036` | `PROP-036` is next candidate if queue is unchanged. |
| `decision.no_official_number_assigned` | The packet assigns no official number. |
| `decision.route_is_architect_owned` | Routing remains Architect / Compiler-Expert owned. |
| `manifest.recommends_unified_profile_id` | Recommendation prefers unified compiler profile id. |
| `firewall.present_verified_not_runtime_ready` | Compatibility firewall is preserved. |
| `lanes.no_runtime_authority` | Receipt/profile lanes grant no runtime authority. |
| `slots.required_exactly_one_preserved` | Required slots stay exactly-one. |
| `slots.future_dispatch_order_preserved` | Slot order remains future dispatch source. |
| `bootstrap.explicit_seed_preserved` | Bootstrap seed remains explicit. |
| `blocked_cards_still_blocked` | Implementation cards are not opened early. |
| `scope.no_proposal_index_mutation` | Proposal index is read, not changed. |
| `scope.no_decision_claimed` | The packet is a request, not a decision. |

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: compiler-profile-prop-numbering-decision-v0
Status: done

[D] Decisions:
- Created an Architect-owned numbering decision request packet.
- Did not assign PROP-036 or any other official number.
- Did not create a proposal file or mutate the proposal index.
- Recommended unified_compiler_profile_id as target manifest authority.

[S] Signals:
- PROP-033 is occupied by via profile binding.
- PROP-036 is next free candidate if the queue remains unchanged.
- Authority, slot, and bootstrap invariants from promotion evidence are preserved.

[T] Tests:
- ruby igniter-lang/experiments/compiler_profile_prop_numbering_decision/compiler_profile_prop_numbering_decision.rb -> PASS

[R] Risks:
- Official numbering remains an Architect / Compiler-Expert decision.
- Manifest implementation cards remain blocked until proposal approval.

[Next]
- Update closure index and tracks index.
- Continue with compiler-profile-descriptor-error-taxonomy-sharpening-v0 or route this packet to Architect.
```
