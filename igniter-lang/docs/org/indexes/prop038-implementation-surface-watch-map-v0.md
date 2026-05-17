# PROP-038 Implementation Surface Watch Map v0

Status: active orientation map
Owner: [Org Architect Supervisor]
Date: 2026-05-17
Source card: `S3-R65-C0-O`
Authority: orientation only, not canon

---

## Purpose

Make the PROP-038 implementation surface visible for future agents without
broad rereads.

This map records:

- what the latest Architect decision authorized;
- which surfaces are allowed for the bounded C1-I implementation;
- which compiler/report/runtime/public surfaces remain closed;
- proof parity obligations;
- digest and diagnostic deferrals;
- handoff risks to check before any future authorization.

This map does not authorize implementation or change authority.

---

## Read Set

```text
igniter-lang/docs/gates/prop038-library-validator-extraction-design-decision-v0.md
igniter-lang/docs/tracks/prop038-library-validator-extraction-design-v0.md
igniter-lang/docs/discussions/prop038-library-validator-extraction-design-pressure-v0.md
igniter-lang/docs/proposals/PROP-038-compiler-profile-contract-v0.md
igniter-lang/docs/org/indexes/compiler-code-and-experiment-map-v0.md
igniter-lang/lib/igniter_lang/
igniter-lang/experiments/compiler_profile_contract_proof/
```

---

## Current Authority Snapshot

Latest relevant authority:

```text
igniter-lang/docs/gates/prop038-library-validator-extraction-design-decision-v0.md
```

Decision status:

```text
accepted-authorized-bounded-option-b-implementation
```

Authorized shape:

```text
internal
non-integrated
non-refusal
proof-parity only
```

Authorized next card:

```text
S3-R65-C1-I
Track: prop038-library-validator-extraction-implementation-v0
```

Core constraint:

```text
Create an internal CompilerProfileContractValidator and make the proof script
call it, without changing compiler behavior.
```

---

## Authorized C1-I Write Surfaces

The R64 Architect decision authorizes only these write surfaces for the bounded
implementation card:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
igniter-lang/experiments/compiler_profile_contract_proof/
igniter-lang/docs/tracks/prop038-library-validator-extraction-implementation-v0.md
```

Allowed value of each surface:

| Surface | Type | Allowed value | Watch point |
| --- | --- | --- | --- |
| `compiler_profile_contract_validator.rb` | implementation | New internal validator module only | Must not be required by top-level facade |
| `experiments/compiler_profile_contract_proof/` | proof | Existing proof script calls validator and preserves parity | No unrelated proof/golden expansion |
| implementation track doc | evidence | Exact command matrix and PASS/FAIL | Track is evidence, not further authority |

Expected internal API:

```ruby
IgniterLang::CompilerProfileContractValidator.validate(
  contract,
  digest_reference_policy: :prop038_24_plus
)
```

Expected result shape:

```json
{
  "kind": "compiler_profile_contract_validation_result",
  "format_version": "0.1.0",
  "valid": false,
  "diagnostics": [],
  "diagnostic_codes": [],
  "digest_reference_policy": "prop038_24_plus",
  "compiler_integrated": false,
  "compile_refusal_authorized": false
}
```

Observed at S3-R65-C0 read:

```text
No `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`
appeared in `rg --files igniter-lang/lib/igniter_lang`.

No `prop038-library-validator-extraction-implementation-v0.md` track appeared
in the tracks search.
```

Treat this as a point-in-time observation only. Re-check before using.

---

## Prohibited Surfaces

The R64 decision keeps these closed:

```text
compiler integration
report-only compiler behavior
compile refusal
parser changes
TypeChecker changes
SemanticIR changes
assembler or .igapp changes
CLI/API widening
profile discovery/defaulting/finalization in public surfaces
path loading
inline JSON parsing
public Ruby facade input widening
golden migration
loader/report
CompatibilityReport
IgniterLang::Diagnostics centralization
CompilerOrchestrator changes
CompilationReport changes
CompilerResult changes
.ilk
receipts
signing
dispatch migration
RuntimeMachine / Gate 3 widening
Ledger/TBackend
BiHistory
stream/OLAP
cache
production behavior
```

Production code files that must not be edited by the validator extraction:

```text
igniter-lang/lib/igniter_lang.rb
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/diagnostics.rb
igniter-lang/lib/igniter_lang/assembler.rb
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/parser.rb
igniter-lang/lib/igniter_lang/classifier.rb
igniter-lang/lib/igniter_lang/typechecker.rb
igniter-lang/lib/igniter_lang/semanticir_emitter.rb
igniter-lang/lib/igniter_lang/temporal_executor.rb
igniter-lang/lib/igniter_lang/temporal_access_runtime.rb
```

---

## Proof Parity Obligations

The implementation must preserve:

```text
same 13 cases
same expected diagnostic codes
same PASS status
same non-authorization flags
```

Required command matrix:

```text
ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
ruby -c igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
```

Expected proof summary:

```text
status=PASS
cases=13
checks>=23
compiler_integrated=false
compile_refusal_authorized=false
```

Read first:

```text
igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json
```

Then inspect proof script only if exact behavior or rerun is required:

```text
igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
```

---

## Digest Deferrals

Current authorized policy:

```text
digest_reference_policy: :prop038_24_plus
```

Allowed in this slice:

```text
descriptor_digest shape only:
  compiler_profile_descriptor/sha256:<24+ lowercase hex>

finalization_payload_digest full shape:
  sha256:<64 lowercase hex>
```

Deferred:

```text
descriptor digest recomputation
contract_digest format validation
contract_digest mismatch validation
canonicalization rules for contract digest material
contract_digest_invalid diagnostic
contract_digest_mismatch diagnostic
```

Any future digest validation needs a separate gate covering:

```text
exact canonicalization rules
exact match or prefix-match policy
diagnostic code
proof case
```

---

## Diagnostic Deferrals And Watch Points

Diagnostics must remain local to:

```text
IgniterLang::CompilerProfileContractValidator
```

Do not centralize in:

```text
IgniterLang::Diagnostics
```

R64 authorized proof-parity diagnostics in the gate decision:

```text
compiler_profile_contract.wrong_kind
compiler_profile_contract.unsupported_format_version
compiler_profile_contract.descriptor_digest_invalid
compiler_profile_contract.finalization_payload_digest_invalid
compiler_profile_contract.missing_required_slot
compiler_profile_contract.duplicate_strict_key
compiler_profile_contract.rule_cycle
compiler_profile_contract.missing_rule_reference
compiler_profile_contract.runtime_authority_forbidden
compiler_profile_contract.dispatch_migration_forbidden
```

R64 explicitly does not authorize adding currently unproven diagnostics such as:

```text
compiler_profile_contract.unknown_owner_slot
compiler_profile_contract.unknown_rule_owner_slot
```

Orientation watch point:

```text
PROP-038 proposal text includes `unknown_owner_slot` and
`unknown_rule_owner_slot` in the diagnostic table, while the R64 extraction
decision excludes them from the first bounded extraction unless separately
authorized.

At S3-R65-C0 read, the current proof script / summary also showed these codes.
Future agents must verify the latest gate/track status before treating them as
allowed in the extraction.
```

This is an authority/context risk, not a decision by this map.

---

## Future Handoff Risks

| Risk | Why it matters | Required behavior |
| --- | --- | --- |
| proof output treated as authority | Proof can show behavior but not authorize widening | Check gate decision first |
| validator file becomes public facade | Top-level require would imply public support | Do not edit `igniter_lang.rb` in this slice |
| local diagnostics leak into compiler reports | Would imply report-layer integration | Keep diagnostics local |
| invalid contract refuses compilation | Would implement compile refusal | Return validation result only |
| digest validation expands | Would add unapproved canonicalization semantics | Defer to new gate |
| proof parity hides new diagnostics | Extra codes can creep in through existing proof script | Compare to R64 gate list |
| experiment edits become golden migration | Existing `.igapp`/golden surfaces remain closed | Do not migrate unrelated outputs |

---

## Suggested Future Checkpoints

Before accepting any C1-I implementation:

```text
1. Verify only the three authorized write surfaces changed.
2. Verify no top-level require was added to igniter-lang/lib/igniter_lang.rb.
3. Verify no CompilerOrchestrator, CompilationReport, CompilerResult,
   Diagnostics, Assembler, CLI, Parser, Classifier, TypeChecker,
   SemanticIR, RuntimeMachine, or temporal executor file changed.
4. Verify proof summary still reports PASS, cases=13, checks>=23.
5. Verify compiler_integrated=false and compile_refusal_authorized=false.
6. Verify contract_digest validation remains deferred.
7. Resolve or explicitly route the unknown_owner_slot / unknown_rule_owner_slot
   diagnostic mismatch before final acceptance if it remains visible.
```

---

## Return Summary

PROP-038 implementation surface is narrow and well-gated. The only authorized
C1-I implementation surface is an internal validator file plus the existing
proof experiment and a track doc. All compiler/report/runtime/public surfaces
remain closed.

The highest-risk watch point is diagnostic drift: PROP-038 text and current
proof artifacts mention `unknown_owner_slot` / `unknown_rule_owner_slot`, while
the R64 extraction decision excludes them from the first bounded extraction
unless separately authorized. Future acceptance should verify whether those
codes are intentionally authorized by later evidence or need to be removed from
the extraction parity set.
