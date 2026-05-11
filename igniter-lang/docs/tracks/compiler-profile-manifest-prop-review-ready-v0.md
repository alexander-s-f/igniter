# Track: Compiler Profile Manifest PROP Review Ready v0

Card: impl-agent-handoff-to-research2-v0
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-manifest-prop-review-ready-v0`
Status: done
Date: 2026-05-10

---

## Goal

Turn the `compiler_profile_id` manifest draft into an Architect-review-ready
packet while preserving the authority boundaries called out by the Implementation
Agent handoff.

This track does not claim an official PROP number, does not mutate
`docs/proposals/README.md`, does not implement assembler/loader changes, does
not change `.igapp`/`.ilk`, and does not grant runtime execution authority.

---

## Added Proof

Added:

```text
igniter-lang/experiments/compiler_profile_manifest_prop_review_ready/compiler_profile_manifest_prop_review_ready.rb
igniter-lang/experiments/compiler_profile_manifest_prop_review_ready/out/compiler_profile_manifest_architect_review_packet.json
igniter-lang/experiments/compiler_profile_manifest_prop_review_ready/out/compiler_profile_manifest_prop_review_ready_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_manifest_prop_review_ready/compiler_profile_manifest_prop_review_ready.rb
```

Result:

```text
PASS compiler_profile_manifest_prop_review_ready
```

The runner refreshes:

```text
compiler_profile_manifest_prop_draft
profile_source_syntax_pressure
```

and composes additional evidence from slots, unified profile, CompatibilityReport,
receipt storage, and bootstrap descriptor kernel proofs.

---

## Review Status

```text
architect_review_ready_candidate
```

Numbering note:

```text
official_prop_number_claimed: false
```

Reason: `PROP-033` is already queued for `via profile binding`; Architect /
Compiler-Expert should assign or requeue before promotion.

---

## Authority Firewall

Preserved invariant:

```text
compiler_profile_status.present_verified
  must not imply
runtime_evaluation_readiness.ready
```

Machine field:

```json
{
  "present_verified_implies_runtime_ready": false
}
```

[D] Do not weaken this invariant in later PROP promotion.

---

## Receipt And Profile Lanes

```text
CompilerProfile = identifies compiler understanding authority
CompilationReceipt = explains build evidence
```

Both are explicit:

```json
{
  "receipt_runtime_execution_authority": false,
  "profile_runtime_execution_authority": false
}
```

[D] Receipt signatures may attest to build evidence. They do not grant runtime
execution.

---

## Slot Invariants

Required exactly-one slots:

```text
core
oof_registry
fragment_registry
escape_boundary
```

[D] These slots are non-removable in the current profile-over-profile model.

Ordering:

```text
CompilerProfileSpec.slot_order = canonical descriptor slot order
descriptor slot order = future dispatch order
surface slot order = not authoritative
```

Important ordering facts:

```text
contract_modifiers before temporal
assumptions after contract_modifiers
```

Implementation identity:

```text
implementation_id changes profile_id
```

---

## Bootstrap Traceability

The review packet keeps the bootstrap seed explicit:

```json
{
  "explicit_seed_required": true,
  "runtime_execution_authority": false
}
```

Current proof-local bootstrap profile id:

```text
bootstrap_compiler_profile/sha256:98222cdd7ce1497c90462165
```

[D] Self-assembly remains audit-traceable; the first validator is not hidden.

---

## Architect Review Questions

1. Which official PROP number should carry `compiler_profile_id` manifest
   semantics?
2. Should `compiler_profile_id` use ordered-rule profile id first or unified
   compiler profile id first?
3. When does `legacy_optional` move to `profile_required`?
4. Should expanded profile material live in a sidecar, receipt bundle, `.ilk`, or
   all three?
5. Which implementation card owns artifact hash/golden migration?

---

## Non-Authorizations

```text
No runtime execution authority.
No parser syntax authorization.
No assembler or loader implementation.
No .igapp/.ilk format mutation before PROP approval.
No production dispatch rewrite.
```

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.manifest_draft_passed` | Manifest draft proof passed. |
| `input.syntax_pressure_passed` | Syntax pressure proof passed. |
| `promotion.no_official_prop_number_claimed` | The packet does not claim a PROP number. |
| `firewall.present_verified_not_runtime_ready` | Critical authority firewall is intact. |
| `lanes.receipt_and_profile_no_runtime_authority` | Receipt and profile lanes grant no runtime authority. |
| `slots.required_exactly_one_nonremovable` | Required exactly-one slots are fixed. |
| `slots.contract_modifiers_before_temporal` | Slot order keeps modifiers before temporal. |
| `slots.assumptions_after_contract_modifiers` | Assumptions require and follow modifiers. |
| `slots.surface_order_not_authoritative` | Surface order cannot override profile spec order. |
| `slots.implementation_id_changes_profile` | Implementation changes alter profile identity. |
| `bootstrap.explicit_seed_traceable` | Bootstrap seed remains explicit and non-runtime. |
| `scope.non_authorizations_include_format_and_dispatch` | Format mutation and dispatch rewrite remain closed. |

---

## Handoff

```text
Card: impl-agent-handoff-to-research2-v0
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: compiler-profile-manifest-prop-review-ready-v0
Status: done

[D] Decisions:
- Manifest PROP draft is now Architect-review-ready candidate.
- Authority firewall is preserved exactly: present_verified does not imply runtime ready.
- Receipt and profile stay in separate authority lanes.
- core/oof_registry/fragment_registry/escape_boundary remain exactly_one.
- CompilerProfileSpec.slot_order is canonical descriptor/future dispatch order.
- Bootstrap seed remains explicit and audit-traceable.

[S] Signals:
- Implementation Agent handoff invariants are machine-checked.
- Review packet names open Architect questions and implementation cards.

[T] Tests:
- ruby igniter-lang/experiments/compiler_profile_manifest_prop_review_ready/compiler_profile_manifest_prop_review_ready.rb -> PASS

[R] Risks:
- Official PROP number and proposal promotion still require Architect/Compiler-Expert routing.
- Assembler/loader/golden migration remains blocked until PROP approval.

[Next]
- Update closure index and tracks index.
```
