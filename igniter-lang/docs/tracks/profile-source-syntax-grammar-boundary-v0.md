# Track: Profile Source Syntax Grammar Boundary v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `profile-source-syntax-grammar-boundary-v0`
Status: done
Date: 2026-05-11

---

## Goal

Create a Compiler/Grammar-owned decision boundary for future profile source
syntax, while keeping this slice in research mode.

This track does not accept grammar, does not authorize profile syntax, does not
open parser implementation, and does not edit spec, `.igapp`, or `.ilk`.

---

## Added Proof

Added:

```text
igniter-lang/experiments/profile_source_syntax_grammar_boundary/profile_source_syntax_grammar_boundary.rb
igniter-lang/experiments/profile_source_syntax_grammar_boundary/out/profile_source_syntax_grammar_boundary_packet.json
igniter-lang/experiments/profile_source_syntax_grammar_boundary/out/profile_source_syntax_grammar_boundary_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/profile_source_syntax_grammar_boundary/profile_source_syntax_grammar_boundary.rb
```

Result:

```text
PASS profile_source_syntax_grammar_boundary
```

The runner refreshes:

```text
profile_source_syntax_compiler_review
```

and converts the research baseline into a decision boundary for
Compiler/Grammar.

---

## Role Boundary

```json
{
  "prepared_by": "[Igniter-Lang Research Agent]",
  "decision_owner": "[Igniter-Lang Compiler/Grammar Expert]",
  "architect_authorization_required_before_parser_work": true,
  "research_agent_may_accept_syntax": false,
  "syntax_accepted_by_this_packet": false
}
```

[D] Research can prepare the boundary. Compiler/Grammar owns grammar acceptance.
Architect authorization is still required before parser implementation.

---

## Fixed Research Constraints

```text
descriptor_first_now: true
human_syntax_pressure_only: true
lowering_target: compiler_profile_descriptor
surface_slot_order_authoritative: false
canonical_slot_order_source: CompilerProfileSpec.slot_order
parser_implementation_authorized: false
profile_source_syntax_authorized: false
runtime_authority_claims_allowed: false
inline_pack_bodies_allowed: false
implicit_capability_ownership_allowed: false
```

---

## Compiler/Grammar Verdict Options

| Option | Meaning |
|---|---|
| `accept_baseline_only` | Accept descriptor-first research baseline and keep human syntax pressure-only. |
| `narrow_block_syntax_pressure` | Keep human syntax alive but narrow allowed grammar shape before a proposal. |
| `reject_human_syntax_for_now` | Use descriptor data only and close human syntax pressure until a later stage. |
| `defer_for_architect_digest_policy` | Defer syntax decision until source digest authority is decided. |

[R] Research recommendation:

```text
accept_baseline_only
```

Reason:

```text
Descriptor-first path is already proofable; human syntax lacks grammar and digest decisions.
```

---

## Minimum Conditions For Future Syntax

Future syntax must:

```text
lower into compiler_profile_descriptor
preserve CompilerProfileSpec.slot_order as canonical descriptor/future dispatch order
reject runtime authority claims
reject inline pack implementation bodies
require explicit capability ownership
reuse descriptor diagnostic taxonomy after lowering
have pre-lowering syntax diagnostic machine codes
have explicit source digest policy before golden fixtures
```

---

## Questions Carried Forward

```text
slot_header_vs_contract_header
implementation_id_token_shape
registry_entry_list_boundaries
profile_source_digest
syntax_diagnostics_pre_lowering
surface_order_vs_profile_spec_order
```

These belong to Compiler/Grammar review, not Research acceptance.

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.compiler_review_passed` | Research review packet regenerated and passed. |
| `role.decision_owner_is_compiler_grammar` | Grammar decision owner is Compiler/Grammar Expert. |
| `role.research_does_not_accept_syntax` | Research packet accepts no syntax. |
| `authority.parser_work_still_requires_architect` | Parser work still needs Architect authorization. |
| `constraints.lowering_target_descriptor` | Lowering target remains descriptor. |
| `constraints.surface_order_not_authoritative` | Surface slot order remains non-authoritative. |
| `constraints.no_runtime_or_inline_pack_bodies` | Runtime authority and inline implementation bodies remain rejected. |
| `verdict_options.include_accept_narrow_reject_defer` | Boundary exposes all four verdict paths. |
| `future_conditions.include_digest_and_diagnostics` | Digest and diagnostic prerequisites are explicit. |
| `recommendation.accept_baseline_only` | Research recommends accepting baseline only. |
| `scope.no_parser_card_opened` | No parser implementation card is opened. |

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: profile-source-syntax-grammar-boundary-v0
Status: done

[D] Decisions:
- Created a Compiler/Grammar-owned decision boundary.
- Research does not accept syntax and does not open parser work.
- Descriptor-first remains the research baseline.
- Future syntax must lower into compiler_profile_descriptor.

[S] Signals:
- Recommended research verdict is accept_baseline_only.
- Human block syntax can be narrowed, rejected, or deferred by Compiler/Grammar.
- Digest policy and pre-lowering diagnostic machine codes are required before golden fixtures.

[T] Tests:
- ruby igniter-lang/experiments/profile_source_syntax_grammar_boundary/profile_source_syntax_grammar_boundary.rb -> PASS

[R] Risks:
- Compiler/Grammar may reject human syntax entirely.
- Source digest policy still needs Architect + Compiler/Grammar decision.
- Parser implementation remains closed.

[Next]
- Update closure index and tracks index.
- If continuing in Research, plan descriptor validator implementation readiness.
```
