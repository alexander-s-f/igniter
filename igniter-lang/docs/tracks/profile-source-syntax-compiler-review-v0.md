# Track: Profile Source Syntax Compiler Review v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `profile-source-syntax-compiler-review-v0`
Status: done
Date: 2026-05-11

---

## Goal

Create a research-stage starting point for Compiler/Grammar review of future
profile source syntax.

This track does not authorize parser implementation, does not approve profile
source syntax, does not edit grammar/spec, and does not change compiler dispatch,
`.igapp`, or `.ilk`.

---

## Added Proof

Added:

```text
igniter-lang/experiments/profile_source_syntax_compiler_review/profile_source_syntax_compiler_review.rb
igniter-lang/experiments/profile_source_syntax_compiler_review/out/profile_source_syntax_compiler_review_packet.json
igniter-lang/experiments/profile_source_syntax_compiler_review/out/profile_source_syntax_compiler_review_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/profile_source_syntax_compiler_review/profile_source_syntax_compiler_review.rb
```

Result:

```text
PASS profile_source_syntax_compiler_review
```

The runner refreshes:

```text
profile_source_syntax_pressure
compiler_profile_descriptor_error_taxonomy_sharpening
```

and composes them into a Compiler/Grammar-facing review packet.

---

## Research Baseline

Status:

```text
research_baseline_for_compiler_grammar_review
```

Current recommendation:

```text
descriptor_first_now
human syntax remains pressure_only
```

Authority:

```json
{
  "parser_implementation_authorized": false,
  "profile_source_syntax_authorized": false,
  "compiler_grammar_review_required": true
}
```

---

## Baseline Invariants

[D] Future profile source syntax must lower into:

```text
compiler_profile_descriptor
```

[D] Surface slot order is not authoritative:

```text
surface order = ergonomic input only
CompilerProfileSpec.slot_order = canonical descriptor order
descriptor order = future dispatch order
```

[D] These remain rejected:

```text
runtime authority claims
inline pack implementation bodies
implicit capability ownership
parser implementation work
```

---

## Candidate Review

| Candidate | Research verdict | Reason |
|---|---|---|
| descriptor data style | accept as research baseline | Already matches descriptor schema and avoids parser churn. |
| block-style profile syntax | keep as pressure specimen | Human-readable, but grammar and digest policy are unresolved. |
| inline pack body style | reject | Profile source selects implementation ids; it does not define implementations. |

---

## Compiler/Grammar Questions

| ID | Question |
|---|---|
| `slot_header_vs_contract_header` | Profile slot declarations must not parse like contract declarations. |
| `implementation_id_token_shape` | Implementation ids contain dots and versions; lexer/token policy must be explicit. |
| `registry_entry_list_boundaries` | Comma/newline/block termination must be deterministic. |
| `profile_source_digest` | Digest policy must decide source text vs lowered AST. |
| `syntax_diagnostics_pre_lowering` | Which syntax errors should exist before descriptor validation runs? |
| `surface_order_vs_profile_spec_order` | Should source order be accepted when it differs from `CompilerProfileSpec.slot_order`? |

[R] The research baseline answers the last question narrowly: source order may
vary for ergonomics, but lowered descriptor order must follow
`CompilerProfileSpec.slot_order`.

---

## Diagnostic Baseline

Profile syntax diagnostics should reuse descriptor taxonomy after lowering:

```text
descriptor_shape
  -> slot_assignment
  -> pack_semantics
  -> registry_ordering
```

Syntax-specific diagnostics are allowed only before lowering. Human diagnostic
text may vary; machine codes must remain stable.

---

## Accept / Reject / Narrow

Accept now:

```text
descriptor data/profile descriptor as the research baseline
lowering target = compiler_profile_descriptor
surface slot order is non-authoritative
```

Keep pressure-only:

```text
human block-style profile syntax
source text digest policy
profile syntax golden fixtures
```

Reject now:

```text
inline pack implementation bodies
runtime authority clauses
implicit capability ownership
parser implementation work
```

Requires Compiler/Grammar decision:

```text
profile header grammar
slot declaration grammar
implementation id lexical grammar
registry entry separators and block termination
source diagnostic shape before descriptor lowering
```

---

## Recommended Next Track

```text
profile-source-syntax-grammar-boundary-v0
```

Recommended verdict to test:

```text
accept descriptor-first baseline
keep block syntax pressure-only
do not start parser until Architect authorizes syntax work
```

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.syntax_pressure_passed` | Syntax pressure proof regenerated and passed. |
| `input.taxonomy_passed` | Descriptor diagnostic taxonomy proof regenerated and passed. |
| `scope.research_baseline_status` | Packet is a research baseline, not syntax approval. |
| `authority.syntax_not_authorized` | Parser and profile syntax remain unauthorized. |
| `baseline.lowering_target_descriptor` | Future syntax must lower into descriptor. |
| `baseline.surface_order_not_authoritative` | Surface slot order cannot override profile spec order. |
| `candidate.descriptor_data_accepted_as_baseline` | Descriptor data is accepted for research. |
| `candidate.block_style_pressure_only` | Block-style syntax remains pressure-only. |
| `candidate.inline_pack_body_rejected` | Inline pack bodies are rejected. |
| `diagnostics.reuses_descriptor_taxonomy` | Descriptor taxonomy remains diagnostic baseline. |
| `matrix.rejects_parser_work_now` | Parser implementation is explicitly rejected now. |
| `handoff.names_compiler_grammar_target` | Handoff target is Compiler/Grammar Expert. |
| `scope.no_runtime_or_format_authority` | No runtime or artifact format authority is introduced. |

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: profile-source-syntax-compiler-review-v0
Status: done

[D] Decisions:
- Descriptor-first profile input is the research baseline.
- Human block-style syntax remains pressure-only.
- Future syntax must lower into compiler_profile_descriptor.
- Surface slot order is non-authoritative; CompilerProfileSpec.slot_order remains canonical.
- Parser implementation remains rejected for this stage.

[S] Signals:
- Compiler/Grammar now has a concrete accept/reject/narrowing matrix.
- Descriptor diagnostic taxonomy can be reused after lowering.
- Open questions are narrowed to grammar, token, separator, digest, and pre-lowering diagnostic shape.

[T] Tests:
- ruby igniter-lang/experiments/profile_source_syntax_compiler_review/profile_source_syntax_compiler_review.rb -> PASS

[R] Risks:
- Architect authorization is still required before any parser/syntax implementation.
- Digest policy remains unresolved.
- Block-style syntax may still be rejected by Compiler/Grammar.

[Next]
- Update closure index and tracks index.
- Route `profile-source-syntax-grammar-boundary-v0` to Compiler/Grammar Expert.
```
