# Compiler Release Acceptance Harness v0

Card: S3-R161-C2-I  
Track: compiler-release-acceptance-harness-implementation-proof-v0  
Authorization: S3-R161-C1-A, S3-R161-C2-S

Bounded proof-local compiler release acceptance harness runner.
Generated outputs are proof-local harness implementation evidence only.
Not official RC evidence. Not a public release claim.

## Required Proof Commands

```bash
# Syntax check
ruby -c igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb

# Acceptance run
ruby igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb --mode acceptance
```

## Layout

```
corpus/positive/     5 .ig compile units (add_baseline, boolean_gate, integer_arithmetic,
                     multi_input_diverse, poc_derived)
corpus/negative/     3 .ig refusal specimens (parse_refusal, type_mismatch, unresolved_symbol)
fixtures/            finalized_profile_source.json, malformed_profile_source.json,
                     semantic_profile_source_wrong_kind.json
out/                 Generated outputs (harness-local; not RC evidence)
```

## Expected Status

HOLD — branch/conditional if_expr is not supported by TypeChecker (OOF-TY0); requires
new semantics per C1-A NB-1. Multi-input diversity satisfied via mixed types
(Integer + Bool) in multi_input_diverse.ig. All other checks PASS.
