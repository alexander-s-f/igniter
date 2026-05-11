# Track: Profile Source Syntax Pressure v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `profile-source-syntax-pressure-v0`
Status: done
Date: 2026-05-10

---

## Goal

Pressure-test possible profile source surfaces without authorizing parser
implementation or profile syntax.

This track is for Compiler/Grammar-facing pressure only. The current
recommendation remains descriptor-first.

---

## Added Proof

Added:

```text
igniter-lang/experiments/profile_source_syntax_pressure/profile_source_syntax_pressure.rb
igniter-lang/experiments/profile_source_syntax_pressure/out/profile_source_syntax_pressure_model.json
igniter-lang/experiments/profile_source_syntax_pressure/out/profile_source_syntax_pressure_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/profile_source_syntax_pressure/profile_source_syntax_pressure.rb
```

Result:

```text
PASS profile_source_syntax_pressure
```

The runner refreshes:

```text
profile_source_lowering_target
```

then models syntax candidates and forbidden constructs.

---

## Authority

```json
{
  "parser_implementation_authorized": false,
  "profile_source_syntax_authorized": false,
  "compiler_grammar_review_required": true
}
```

[D] No profile syntax is authorized by this track.

---

## Candidate Forms

### Descriptor Data Style

Status:

```text
preferred_before_parser_work
```

Strengths:

```text
already matches descriptor schema
avoids source parser churn
canonicalization and digest rules already modeled
```

[D] This is the recommended near-term path.

### Block Style

Status:

```text
pressure_only
```

Specimen:

```text
profile IgniterLang.Stage3SelfAssemblyProfile uses IgniterLangSelfAssemblyProfileSpec {
  slot core: CoreLanguagePack implementation core_language.self_assembly.v0
    owns core_language
    registry parser_rules: core.contract, core.input, core.output, core.compute

  slot temporal: TemporalPack implementation temporal.metadata_only.self_assembly.v0
    owns temporal
    requires core, fragment_registry, escape_boundary
    registry semanticir_handlers: temporal.temporal_access_node
}
```

Strengths:

```text
human-readable
maps directly to slots and registry blocks
keeps implementation selection separate from implementation body
```

Risks:

```text
new grammar surface
indent/block ambiguity
comma/newline and registry-list boundary rules
```

### Inline Pack Body Style

Status:

```text
rejected
```

Reason:

```text
Profile source may select implementation ids, not define pack implementations inline.
```

---

## Ambiguity Pressure

| ID | Risk | Route |
|---|---|---|
| `slot_header_vs_contract_header` | profile slot declarations must not parse like contract declarations | Compiler/Grammar |
| `implementation_id_token_shape` | implementation ids contain dots and versions; lexer/token policy must be explicit | Compiler/Grammar |
| `registry_entry_list_boundaries` | comma/newline/block termination must be deterministic | Compiler/Grammar |
| `profile_source_digest` | digest policy must decide source text vs lowered AST | Architect + Compiler/Grammar |

---

## Decision Matrix

Allow now:

```text
descriptor_data_style as proof-local input
block_style as pressure specimen only
```

Reject now:

```text
inline pack implementation bodies
runtime authority or approval clauses
implicit capability ownership
parser implementation work
```

Requires future authorization:

```text
profile source grammar
profile source diagnostics
profile source digest policy
profile syntax golden fixtures
```

---

## Slot Order Invariant

[D] Surface slot order is not authoritative.

Invariant:

```text
surface slot order = parsed sugar only
CompilerProfileSpec.slot_order = canonical descriptor slot order
descriptor slot order = future dispatch order
```

This preserves the Profile-over-Profile result: syntax may be ergonomic, but it
must lower into the same slot order proven by the descriptor/profile model.

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.lowering_target_passed` | Lowering target proof passed first. |
| `authority.syntax_not_authorized` | Parser and syntax remain unauthorized. |
| `candidate.block_style_pressure_only` | Human block form is pressure only. |
| `candidate.descriptor_data_preferred` | Descriptor data is preferred before parser work. |
| `candidate.inline_pack_body_rejected` | Inline implementation bodies are rejected. |
| `slot_order.surface_order_not_authoritative` | Surface slot order cannot override `CompilerProfileSpec.slot_order`. |
| `forbidden.runtime_and_pack_body_rejected` | Runtime approval and pack body constructs are forbidden. |
| `matrix.rejects_parser_implementation` | Parser implementation is explicitly rejected now. |
| `matrix.requires_future_grammar_authorization` | Grammar work requires future authorization. |
| `ambiguity.pressure_has_compiler_grammar_routes` | Ambiguities route to Compiler/Grammar. |
| `recommendation.descriptor_first` | Near-term recommendation stays descriptor-first. |

---

## Recommendation

[R] Continue with descriptor-first profile input for proof work.

[R] Route block-style syntax to Compiler/Grammar only after manifest/profile
authority questions are settled.

[R] If syntax is later authorized, it should lower into
`compiler_profile_descriptor` and reuse the existing forbidden-construct checks.

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: profile-source-syntax-pressure-v0
Status: done

[D] Decisions:
- Descriptor-data style is preferred before parser work.
- Block-style profile syntax is pressure-only.
- Surface slot order is parsed sugar; `CompilerProfileSpec.slot_order` remains canonical.
- Inline pack bodies, runtime authority, implicit ownership, and parser work are rejected now.

[S] Signals:
- Human-readable syntax is plausible but has clear ambiguity pressure.
- Existing lowering target gives Compiler/Grammar a clean future target.

[T] Tests:
- ruby igniter-lang/experiments/profile_source_syntax_pressure/profile_source_syntax_pressure.rb -> PASS

[R] Risks:
- Grammar authority is required before any parser implementation.
- Digest policy needs a formal source-text vs lowered-AST decision.

[Next]
- Update closure index and tracks index.
```
