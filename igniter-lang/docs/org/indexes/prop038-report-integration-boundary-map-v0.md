# PROP-038 Report Integration Boundary Map v0

Status: active orientation map
Owner: [Org Architect Supervisor]
Date: 2026-05-17
Source card: `S3-R66-C0-O`
Authority: orientation only, not canon

---

## Purpose

Map the dangerous boundary between the accepted internal PROP-038 validator and
any future report-only compiler integration.

This document is an org-sidecar navigation aid. It does not authorize
integration, implementation, report behavior, compile refusal, public API/CLI
widening, persisted outputs, runtime behavior, or production behavior.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-library-validator-extraction-acceptance-decision-v0.md
igniter-lang/docs/tracks/prop038-library-validator-extraction-implementation-v0.md
igniter-lang/docs/discussions/prop038-library-validator-extraction-implementation-pressure-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
igniter-lang/docs/org/indexes/prop038-implementation-surface-watch-map-v0.md
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
```

---

## Accepted Internal Validator Surface

The accepted R65 surface is internal, non-integrated, non-refusal, and
proof-parity only.

Accepted validator:

```text
IgniterLang::CompilerProfileContractValidator
```

Accepted method:

```ruby
validate(contract, digest_reference_policy: :prop038_24_plus)
```

Accepted input:

```text
already-materialized Hash only
```

Accepted result shape:

```text
kind=compiler_profile_contract_validation_result
format_version=0.1.0
valid=<boolean>
diagnostics=<array>
diagnostic_codes=<array>
digest_reference_policy=prop038_24_plus
compiler_integrated=false
compile_refusal_authorized=false
```

Accepted diagnostic vocabulary remains the 10 proof-parity codes from R65.
Still not authorized:

```text
compiler_profile_contract.unknown_owner_slot
compiler_profile_contract.unknown_rule_owner_slot
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_mismatch
```

Current important invariant:

```text
valid=false is information, not compiler authority.
```

---

## Candidate Report-Only Touchpoints

These are orientation-only candidate touchpoints for a future design card. They
are not write permission.

| Surface | Current role | Why future agents may look here | Boundary risk |
| --- | --- | --- | --- |
| `CompilerOrchestrator#compile` | Pipeline coordinator; already transports PROP-036 `compiler_profile_source` to assembler | Natural insertion point if report-only validation needs pipeline context | Calling validator here can become compile refusal if `valid=false` changes `pass_result` |
| `CompilationReport.enrich` | Adds compiler diagnostics categories to existing reports | Natural report attachment point | Centralizing `compiler_profile_contract.*` into compiler diagnostics may imply authority |
| `CompilerResult.ok/refusal` | Caller-visible result wrapper | Natural result exposure point | Adding contract validation to public result can widen API or imply release-ready surface |
| `CompilerProfileContractValidator.validate` | Internal validator only | Already accepted validation primitive | Reusing it outside proof may turn proof-local validation into compiler behavior |
| `Diagnostics` | Central diagnostic helper used by compiler reports/results | Convenient formatting path | R65 explicitly keeps PROP-038 diagnostics local, not centralized |

Design-only report integration must answer where the validation result is placed
without changing the compiler's pass/refusal semantics.

---

## Forbidden Transitions

Future agents must not treat report-only integration as permission for:

```text
compile refusal based on compiler_profile_contract validity
changing report.pass_result
changing pipeline stages to error/oof because the contract is invalid
raising exceptions for invalid compiler_profile_contract
requiring the validator from the public facade
adding CLI/API input for compiler_profile_contract
loading contracts from paths, inline JSON, env, config, or sidecars
profile discovery/defaulting/finalization
assembler/.igapp mutation
golden migration without named authorization
loader/report present_verified behavior
CompatibilityReport behavior
IgniterLang::Diagnostics centralization
RuntimeMachine or Gate 3 widening
Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior
```

The safe mental model:

```text
report-only = attach observed validation data
report-only != decide compilation outcome
report-only != public input surface
report-only != persisted authority
```

---

## Unresolved Input Ownership Questions

R65 acceptance explicitly says any future report-only design must resolve input
ownership before implementation.

Open questions for that future design:

```text
Who supplies the compiler_profile_contract Hash?
Is it derived from an already-supplied compiler_profile_source, or separate?
Is it allowed to be nil/missing?
Does missing contract mean no report field, informational skipped field, or a diagnostic?
Is the contract trusted material, caller material, generated material, or proof fixture material?
Where is the source of truth recorded without public API/CLI widening?
Can report-only validation exist without loader/report or CompatibilityReport claims?
```

Current risk:

```text
The compiler already accepts `compiler_profile_source:` as PROP-036 transport.
Do not silently reinterpret that input as a PROP-038 compiler_profile_contract.
```

---

## Digest And Canonicalization Risks

Current accepted validator behavior:

```text
descriptor_digest: shape-only
finalization_payload_digest: full SHA-256 shape
contract_digest: deferred
descriptor material recomputation: not performed
canonicalization rules: not enforced
```

Future report-only integration becomes dangerous if it persists, compares, or
publishes contract validity because then digest semantics may become authority.

Before any report integration implementation, a design decision should answer:

```text
Will report-only integration validate `contract_digest` at all?
If yes, what exact canonical material is hashed?
Is the accepted digest format `compiler_profile_contract/sha256:<24+>` or full 64?
Are mismatch diagnostics allowed?
Does the report store validation input, validation result, digest references, or all three?
Does a stale or mismatched digest remain informational or become refusal?
```

Until answered, keep:

```text
contract_digest_invalid: not authorized
contract_digest_mismatch: not authorized
```

---

## Validation Result vs Compiler Authority

The extracted validator returns:

```text
valid
diagnostics
diagnostic_codes
compiler_integrated=false
compile_refusal_authorized=false
```

Potential confusion:

```text
valid=false
```

could be mistaken as:

```text
compiler pass_result != ok
CompilerResult.refusal
CompilationReport error
assembler refusal
public CLI failure
```

That is currently wrong. The accepted meaning is:

```text
valid=false means the contract object failed validator checks.
It does not authorize the compiler to refuse a source program.
```

Future report-only design should preserve a distinct field name, for example:

```text
compiler_profile_contract_validation
```

and avoid overloading existing compiler diagnostics or pass/fail fields unless a
later Architect decision explicitly authorizes that behavior.

---

## Safe Future Design Checklist

Before any report-only integration implementation card, require a separate
design decision that names:

```text
1. exact input owner and source path in memory;
2. exact insertion point, if any, in CompilerOrchestrator;
3. exact report field location and shape;
4. whether CompilerResult exposes the field or keeps it internal;
5. nil/missing contract behavior;
6. invalid contract behavior;
7. digest/canonicalization policy;
8. diagnostic vocabulary, including whether unknown owner-slot codes remain deferred;
9. fixture/golden policy;
10. proof matrix and command matrix;
11. non-refusal assertions;
12. non-public-surface assertions.
```

No implementation should begin from this map alone.

---

## Navigation Order For Future Agents

Use this order to avoid broad rereads:

```text
1. Gate: prop038-library-validator-extraction-acceptance-decision-v0
2. Track: prop038-library-validator-extraction-implementation-v0
3. Watch: prop038-implementation-surface-watch-map-v0
4. Code: compiler_profile_contract_validator.rb
5. Code: compiler_orchestrator.rb only if a card names report integration
6. Code: compilation_report.rb / compiler_result.rb only if a card names report output
7. Proposal: PROP-038 for schema vocabulary, not implementation permission
```

---

## Return Summary

R65 closed the internal validator extraction, not report integration. The next
dangerous boundary is any attempt to put `CompilerProfileContractValidator`
output into `CompilationReport`, `CompilerResult`, or `CompilerOrchestrator`.

The most important guardrail is this distinction:

```text
validation result = information about a compiler_profile_contract object
compiler authority = permission to change pass_result/refusal/public behavior
```

Those remain separate unless a future Architect decision explicitly narrows the
boundary and authorizes implementation.
