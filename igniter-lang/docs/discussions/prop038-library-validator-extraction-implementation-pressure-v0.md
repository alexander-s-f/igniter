# Discussion: PROP-038 Library Validator Extraction Implementation Pressure v0

Card: S3-R65-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: implementation-pressure
Mode: discussion
Initiator: user
Track: prop038-library-validator-extraction-implementation-pressure-v0

Depends on: S3-R65-C1-I delivered

Question:

Did the bounded Option B library validator extraction stay inside authorized paths?
Does the validator API match the authorized shape exactly? Are `compiler_integrated`
and `compile_refusal_authorized` hardcoded false in the return object? Is the
13-case parity matrix intact with no regression? Did the diagnostic vocabulary
remain exactly proof-parity — no expansion, no unauthorized codes? Is
`contract_digest` validation still deferred? Is descriptor digest still
shape-only? Was no top-level require added to the public facade? Are all
forbidden surfaces still closed?

Context:
- R64-C3-A (gate): Authorized bounded Option B extraction; closed all 8 blockers
  B1-B8; authorized one file path only
  (`igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb`);
  required `validate` only public; proof parity (13 cases, ≥23 checks, PASS);
  `compiler_integrated: false`, `compile_refusal_authorized: false` required in
  result; no top-level require; 10 authorized diagnostic codes; explicitly
  disallowed `unknown_owner_slot`/`unknown_rule_owner_slot`
- R64-C2-X (pressure): All 9 scope checks passed; NB-1 noted that `contract_digest`
  format not validated — correct proof parity, C3-A acknowledged when authorizing B2/B4
- R65-C1-I: Implementation Agent — created validator file, updated proof script to
  call it, proof summary reports 13 cases / 27 checks / PASS; API surface check
  reports validate_public=true, helper methods private

---

## Scope Check 1 — Write Scope Stayed Exactly Within Authorized Paths

The track reports exactly four files changed:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb
igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json
igniter-lang/docs/tracks/prop038-library-validator-extraction-implementation-v0.md
```

The gate authorized:

```text
igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb
igniter-lang/experiments/compiler_profile_contract_proof/
igniter-lang/docs/tracks/<future-implementation-track>.md
```

All four files are within the authorized boundary:
- The validator file is the exact authorized path ✓
- Both experiment files are inside the authorized experiment directory ✓
- The track document is the required delivery artifact ✓

The track explicitly states no production compiler code was changed. No changes to
parser, TypeChecker, SemanticIR, assembler, `.igapp`, CLI/API, loader/report,
CompatibilityReport, dispatch, RuntimeMachine, Gate 3, Ledger/TBackend,
BiHistory, stream/OLAP, cache, or production behavior. ✓

---

## Scope Check 2 — No Top-Level Require In The Public Facade

Direct inspection of `igniter-lang/lib/igniter_lang.rb`:

```text
grep "compiler_profile_contract_validator" igniter-lang/lib/igniter_lang.rb → NOT FOUND
```

The facade file does not require the validator. ✓

The proof script loads the validator via proof-local relative path:

```ruby
require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"
```

This resolves from the experiment directory:

```text
igniter-lang/experiments/compiler_profile_contract_proof/
  ../../lib/igniter_lang/compiler_profile_contract_validator
  = igniter-lang/lib/igniter_lang/compiler_profile_contract_validator
```

Path is correct. Loading is proof-local only. No public facade require. ✓

---

## Scope Check 3 — Validator API Matches Authorized Shape

From the validator source:

```ruby
module IgniterLang
  module CompilerProfileContractValidator
    def self.validate(contract, digest_reference_policy: DEFAULT_DIGEST_REFERENCE_POLICY)
```

Where `DEFAULT_DIGEST_REFERENCE_POLICY = :prop038_24_plus`.

This matches the authorized signature exactly:

```ruby
validate(contract, digest_reference_policy: :prop038_24_plus)
```

The API surface check reported by the track:

```text
validate_public=true
diagnostic_public=false
result_public=false
cycle_public=false
```

The three private helpers (`diagnostic`, `result`, `find_rule_cycle`) are in
`class << self; private`. No helper method is reachable as a public call. Only
`validate` is callable as `VALIDATOR.validate(...)`.

The proof script assigns the module as a constant:

```ruby
VALIDATOR = IgniterLang::CompilerProfileContractValidator
```

And calls it:

```ruby
validation = VALIDATOR.validate(contract)
```

The proof script also references three module-level constants:

```ruby
VALIDATOR::REQUIRED_SLOTS
VALIDATOR::OPTIONAL_SLOTS
VALIDATOR::ALL_SLOTS
```

These are Ruby module constants — public by definition and not subject to method
visibility. The gate's "expose only `validate`" directive refers to public methods.
Constants are inherently accessible and are used here to build the canonical
contract in `build_contract`, which avoids duplicating slot lists between the
validator and its sole authorized caller. This is correct behavior for a
proof-local caller relationship. ✓

---

## Scope Check 4 — Return Object Preserves Non-Integration Flags

From the validator source:

```ruby
def result(diagnostics, policy)
  {
    "kind" => RESULT_KIND,
    "format_version" => FORMAT_VERSION,
    "valid" => diagnostics.empty?,
    "diagnostics" => diagnostics,
    "diagnostic_codes" => diagnostics.map { |diagnostic| diagnostic.fetch("code") },
    "digest_reference_policy" => policy,
    "compiler_integrated" => false,
    "compile_refusal_authorized" => false
  }
end
```

Both non-integration flags are hardcoded `false` literals. They cannot become
true without changing the validator source. They are present on every result,
regardless of whether the contract is valid or invalid. ✓

The proof summary records the result shape:

```json
"validator_result_shape": {
  "kind": "compiler_profile_contract_validation_result",
  "format_version": "0.1.0",
  "digest_reference_policy": "prop038_24_plus",
  "compiler_integrated": false,
  "compile_refusal_authorized": false
}
```

The proof also machine-asserts these fields directly:

```text
checks[3]: validator_result.compiler_integrated_false  → pass: true
checks[4]: validator_result.compile_refusal_authorized_false → pass: true
```

Machine-asserted at the validator-call level. ✓

---

## Scope Check 5 — 13-Case Parity Matrix Is Intact; No Regression

Proof summary `validator_case_matrix` contains 13 rows, all `"pass": true`:

| Case | Expected | Actual | Pass |
| --- | --- | --- | --- |
| `valid_contract` | valid | valid | ✓ |
| `missing_required_slot` | `missing_required_slot` | `missing_required_slot` | ✓ |
| `duplicate_strict_key` | `duplicate_strict_key` | `duplicate_strict_key` | ✓ |
| `duplicate_fragment_class_owner` | `duplicate_strict_key` | `duplicate_strict_key` | ✓ |
| `rule_cycle` | `rule_cycle` | `rule_cycle` | ✓ |
| `missing_rule_reference` | `missing_rule_reference` | `missing_rule_reference` | ✓ |
| `missing_after_rule_reference` | `missing_rule_reference` | `missing_rule_reference` | ✓ |
| `wrong_kind` | `wrong_kind` | `wrong_kind` | ✓ |
| `unsupported_format_version` | `unsupported_format_version` | `unsupported_format_version` | ✓ |
| `descriptor_digest_invalid` | `descriptor_digest_invalid` | `descriptor_digest_invalid` | ✓ |
| `finalization_payload_digest_invalid` | `finalization_payload_digest_invalid` | `finalization_payload_digest_invalid` | ✓ |
| `runtime_authority_forbidden` | `runtime_authority_forbidden` | `runtime_authority_forbidden` | ✓ |
| `dispatch_migration_forbidden` | `dispatch_migration_forbidden` | `dispatch_migration_forbidden` | ✓ |

R63 had 13 cases / 23 checks. R65 has 13 cases / 27 checks. The +4 checks are
new machine assertions for the validator result shape:

```text
validator_result.kind
validator_result.digest_reference_policy
validator_result.compiler_integrated_false
validator_result.compile_refusal_authorized_false
```

These did not exist in R63 because the validator was proof-local and had no
return object to assert against. They are correct additions for the library
extraction. The gate required `checks>=23`; 27 satisfies that. Zero regressions.
All 13 `validator_case_matrix` rows pass. ✓

---

## Scope Check 6 — Diagnostic Vocabulary Did Not Expand

The gate authorized exactly 10 diagnostic codes:

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

The validator source constructs diagnostics via:

```ruby
def diagnostic(code, message, path = nil)
  {
    "code" => "compiler_profile_contract.#{code}",
    ...
  }
end
```

The `code` argument appears exactly 10 times in the `validate` method:

```text
"wrong_kind"
"unsupported_format_version"
"descriptor_digest_invalid"
"finalization_payload_digest_invalid"
"missing_required_slot"
"duplicate_strict_key"
"missing_rule_reference"
"rule_cycle"
"runtime_authority_forbidden"
"dispatch_migration_forbidden"
```

That is exactly the authorized 10. No `unknown_owner_slot`, no
`unknown_rule_owner_slot`, no `contract_digest_invalid`, no
`contract_digest_mismatch`. ✓

The track explicitly states:

```text
unknown_owner_slot and unknown_rule_owner_slot were not extracted into the library
validator because the R65 authority explicitly disallowed adding those currently
unproven diagnostics to this implementation.
```

This correctly echoes the gate:

```text
This implementation does not authorize adding currently unproven PROP-038
diagnostics such as unknown_owner_slot or unknown_rule_owner_slot.
```

Diagnostic vocabulary is proof-parity only. ✓

---

## Scope Check 7 — `contract_digest` Validation Remains Deferred

The validator source contains no reference to `"contract_digest"` as a field
being validated. There is no pattern match against `contract_digest`. There is
no diagnostic code for `contract_digest_invalid` or `contract_digest_mismatch`.

The track explicitly states:

```text
Keeps contract_digest format/mismatch validation deferred.
```

The proof summary's `remaining_blockers_before_compiler_integration` correctly
carries forward:

```text
"contract_digest format and mismatch diagnostics if the contract digest becomes enforced"
```

R64-C2-X NB-1 (contract_digest format not validated) remains correctly deferred.
R64-C3-A accepted this as proof parity. The implementation does not introduce or
resolve this gap. ✓

---

## Scope Check 8 — Descriptor Digest Remains Shape-Only

The validator source:

```ruby
DESCRIPTOR_DIGEST_PATTERN = /\Acompiler_profile_descriptor\/sha256:[0-9a-f]{24,}\z/
```

Used as:

```ruby
diagnostics << diagnostic("descriptor_digest_invalid", ...) unless contract["descriptor_digest"].to_s.match?(DESCRIPTOR_DIGEST_PATTERN)
```

This is a regex shape check: it validates that the `descriptor_digest` string
matches the format `compiler_profile_descriptor/sha256:<24+ lowercase hex>`.

No descriptor material is loaded, computed, or resolved. The validator does not:
- read external files;
- look up descriptor objects;
- recompute any digest;
- call any canonicalization logic on descriptor content.

The `finalization_payload_digest` pattern:

```ruby
FINALIZATION_PAYLOAD_DIGEST_PATTERN = /\Asha256:[0-9a-f]{64}\z/
```

Correctly enforces the full 64-character SHA-256 format, matching the
`:prop038_24_plus` policy tiering from the gate. ✓

The validator's only external require is:

```ruby
require "set"
```

This is Ruby standard library (`Set` class used for DFS cycle detection). No
external gems, no production dependencies, no compiler classes required. ✓

---

## Scope Check 9 — No Forbidden Surface Opened

**Compiler integration:** The validator does not require or reference
`CompilerOrchestrator`, `CompilationReport`, `CompilerResult`, or any
compiler-layer class. ✓

**Report-only behavior:** The validator produces no compiler report. ✓

**Compile refusal:** `compile_refusal_authorized` is hardcoded false. An invalid
contract returns a validation result, not an exception or refusal. ✓

**Public API / CLI widening:** No CLI flag added. No facade require added. No
`IgniterLang.compile` call. ✓

**Path loading / JSON parsing:** The validator accepts a pre-materialized Hash.
No file reads. No `JSON.parse`. ✓

**`IgniterLang::Diagnostics`:** Not referenced. Diagnostics are local to the
validator module. ✓

**`.igapp`, receipts, `.ilk`, sidecars:** No write operations in the validator. ✓

**Dispatch / RuntimeMachine / Gate 3 / production:** Not referenced. ✓

The proof summary `non_authorizations_preserved` machine-asserts all 15 flags:

```json
{
  "live_compiler_dispatch": false,
  "compiler_integrated": false,
  "compile_refusal_authorized": false,
  "igapp_artifacts": false,
  "goldens": false,
  "cli_api": false,
  "loader_report": false,
  "compatibility_report": false,
  "runtime_machine": false,
  "gate3": false,
  "ledger_tbackend": false,
  "bihistory": false,
  "stream_olap_production": false,
  "cache": false,
  "production_behavior": false
}
```

All 15 flags false. Machine-asserted. ✓

---

[Agree]

1. **Write scope is exactly the authorized boundary.** Four files, all within
   the gate-specified paths. No production code touched. No facade widened.

2. **No top-level require.** The public facade is unchanged.
   `compiler_profile_contract_validator` is not present in
   `igniter-lang/lib/igniter_lang.rb`.

3. **Validator API is exactly the authorized shape.** `def self.validate(contract,
   digest_reference_policy: :prop038_24_plus)` is the only public method. Three
   helper methods (`diagnostic`, `result`, `find_rule_cycle`) are private via
   `class << self; private`. API surface check machine-confirms this.

4. **Non-integration flags are hardcoded false literals in the result builder.**
   Cannot become true without changing the source. Machine-asserted by two
   proof checks. The proof chain cannot pass with these flags true.

5. **13-case parity matrix is intact with zero regressions.** All 13 rows of
   the `validator_case_matrix` pass. 27 checks / PASS / 0 failures. +4 new
   checks correctly assert the extracted validator's result shape —
   assertions that could not exist before the extraction.

6. **Diagnostic vocabulary is exactly proof-parity.** Exactly 10 authorized codes
   appear in the validator source. `unknown_owner_slot`,
   `unknown_rule_owner_slot`, and any `contract_digest_*` code are absent.

7. **`contract_digest` correctly deferred.** No check, no pattern, no diagnostic
   code for contract digest validation. Correctly carried forward in remaining
   blockers list. R64 NB-1 is maintained.

8. **Descriptor digest is shape-only.** Regex pattern on the string value only.
   No file loading, no descriptor material, no recomputation. `require "set"` is
   the sole external require (Ruby stdlib for DFS cycle detection).

9. **All 15 non-authorization flags machine-asserted false.** The proof
   enforcement mechanism for non-integration and non-refusal continues to work.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect acceptance decision.

---

## Verdict

**Proceed.**

All nine scope checks pass. The bounded Option B extraction is complete. The
library validator exists at the authorized file path, exposes only `validate`,
returns the authorized string-key result shape with `compiler_integrated: false`
and `compile_refusal_authorized: false`, validates exactly the 10 proof-parity
diagnostic codes, defers `contract_digest` validation, keeps descriptor digest
shape-only, does not appear in the public facade, and leaves all 15
non-authorization flags machine-asserted false. The 13-case parity matrix is
intact with 27 checks / PASS / 0 regressions. The R58–R65 proof chain
(`R58 → R60 → R63 → R65`) is complete for current authorized scope.

No blockers. No non-blocking notes.

---

[Route]

**Verdict: proceed.**

No blockers. No non-blocking notes.

**Recommended Architect decision (C3-A):**

1. Accept the R65 bounded Option B extraction. The library validator is
   implemented inside the authorized boundary. All gate requirements are
   satisfied. Proof parity is preserved and strengthened by four new
   machine assertions on the validator result shape.

2. Close R65 Option B extraction. The proof chain is now:
   ```text
   R58 (proof) → R60 (coverage) → R63 (missing-after) → R65 (library extraction)
   ```
   Option B is complete.

3. The next meaningful lane, if any, is design for report-only compiler
   integration (Options C/D). This requires a dedicated design card to resolve:
   - contract input ownership without public API or CLI widening;
   - report/output location;
   - orchestrator insertion point;
   - fixture/golden policy;
   - descriptor digest input material and canonicalization for integrated/persisted
     behavior;
   - contract_digest format and mismatch diagnostics if enforced in that context;
   - dedicated gate for report-only authorization vs. compile refusal.
   All seven remaining blockers before compiler integration are correctly carried
   in the proof summary's `remaining_blockers_before_compiler_integration` list.

4. Do not open compiler integration, compile refusal, public API/CLI widening,
   new diagnostic vocabulary, digest recomputation, or production behavior from
   this acceptance.
