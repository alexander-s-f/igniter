# Track: Profile Source Lowering Target v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `profile-source-lowering-target-v0`
Status: done
Date: 2026-05-10

---

## Goal

Define how future profile source syntax should lower into the
`compiler_profile_descriptor` schema without authorizing parser implementation.

This slice is a lowering target proof only. It does not implement parser syntax,
does not authorize profile source syntax, and does not change production
compiler dispatch, `.igapp`, or `.ilk`.

---

## Added Proof

Added:

```text
igniter-lang/experiments/profile_source_lowering_target/profile_source_lowering_target.rb
igniter-lang/experiments/profile_source_lowering_target/out/profile_source_lowering_model.json
igniter-lang/experiments/profile_source_lowering_target/out/lowered_profile_descriptor.json
igniter-lang/experiments/profile_source_lowering_target/out/profile_source_lowering_target_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/profile_source_lowering_target/profile_source_lowering_target.rb
```

Result:

```text
PASS profile_source_lowering_target
```

The runner refreshes:

```text
compiler_profile_descriptor_schema
```

then lowers a proof-local profile-source AST candidate into a descriptor.

---

## Source Status

Current proof flags:

```json
{
  "parser_implemented": false,
  "syntax_authorized": false,
  "descriptor_first": true
}
```

[D] Profile source syntax remains future work. This track only defines the shape
that future syntax must lower into.

---

## Lowering Rules

| Future source construct | Descriptor target |
|---|---|
| profile header | `profile_descriptor.kind` + `profile_source` |
| profile name | `profile_source` metadata |
| slot declaration | `pack_descriptor.slot` + `pack_descriptor.name` |
| implementation clause | `pack_descriptor.implementation_id` |
| owns capabilities clause | `pack_descriptor.provides_capabilities` |
| requires clause | `pack_descriptor.requires_slots` |
| registry block | `pack_descriptor.registries` |
| profile spec reference | `profile_descriptor.profile_spec` |

---

## Forbidden Constructs

| Construct | Rejection code |
|---|---|
| parser implementation required | `lowering.parser_implementation_out_of_scope` |
| syntax authority claim | `lowering.syntax_authority_out_of_scope` |
| inline implementation body | `lowering.implementation_body_out_of_scope` |
| runtime authority claim | `lowering.runtime_authority_claim_rejected` |
| missing implementation id | `lowering.missing_implementation_id` |
| duplicate slot | `lowering.duplicate_slot` |
| helper-only pack | `lowering.helper_only_pack_rejected` |

[D] Profile source may select implementations. It may not define implementation
bodies inline.

[D] Profile source may describe compiler understanding. It may not grant runtime
authority.

---

## Descriptor Output

The lowered descriptor:

```text
kind: compiler_profile_descriptor
schema_ref: preserved from compiler_profile_descriptor_schema
descriptor_digest: compiler_profile_descriptor/sha256:2b51501f50768ec98e8567e6
```

The digest intentionally differs from the previous canonical descriptor proof
because this proof models a different future profile-source AST and therefore a
different `profile_source.canonical_source_digest`.

The important compatibility checks are:

```text
same descriptor kind
same schema_ref
same pack slot set/order
descriptor digest uses compiler_profile_descriptor prefix
```

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.schema_passed` | Upstream descriptor schema proof passed. |
| `model.syntax_not_authorized` | Parser and syntax authorization remain false. |
| `model.every_lowering_rule_targets_descriptor` | Every modeled source construct lowers into descriptor fields. |
| `lowering.produces_descriptor_kind` | Lowering emits `compiler_profile_descriptor`. |
| `lowering.matches_expected_pack_slots` | Lowered pack slots match expected descriptor slots. |
| `lowering.schema_ref_preserved` | Lowered descriptor preserves schema ref. |
| `lowering.digest_is_descriptor_digest` | Lowered descriptor has descriptor digest prefix. |
| negative checks | Forbidden constructs reject with machine-readable codes. |

---

## Decisions

[D] Future profile syntax should be selection/configuration syntax, not inline
implementation syntax.

[D] `implementation` selects an implementation id. It does not contain code.

[D] Runtime authority claims are invalid at profile-source lowering time.

[D] Parser implementation remains out of scope until a Compiler/Grammar slice
authorizes syntax.

---

## Open Questions

[Q] Should profile source be human syntax, `.igprofile.json`, or both?

[Q] Should profile source digest include comments/formatting once syntax exists,
or only the lowered AST?

[Q] Should implementation selection support version ranges, exact ids only, or
signed implementation refs?

[Q] Should lowering produce diagnostics in the same shape as compiler
diagnostics?

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: profile-source-lowering-target-v0
Status: done

[D] Decisions:
- Future profile syntax lowers into compiler_profile_descriptor.
- Syntax/parser implementation remains unauthorized.
- Profile source selects implementation ids; it does not define implementation bodies.
- Runtime authority claims are rejected during lowering.

[S] Signals:
- Lowered descriptor preserves schema_ref and pack slot set/order.
- Forbidden constructs reject with machine-readable lowering error codes.
- Descriptor-first path can support future syntax without bypassing validation.

[T] Tests:
- ruby igniter-lang/experiments/profile_source_lowering_target/profile_source_lowering_target.rb -> PASS

[R] Risks:
- Profile syntax still needs Compiler/Grammar ownership.
- Source digest policy will need a formal choice once concrete syntax exists.
- Implementation refs may need signing/version constraints.

[Next]
- Draft `compiler-profile-chain-closure-index-v0`: one index over descriptor
  schema, lowering target, bootstrap kernel, self-assembly profile, receipt, and
  preflight proofs.
```
