# Discussion: PROP-038 Contract Digest Shape Policy Proof Pressure v0

Card: S3-R69-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: proof-pressure
Mode: discussion
Initiator: user
Track: prop038-contract-digest-shape-policy-proof-pressure-v0

Depends on: S3-R69-C1-P1 delivered

Question:

Are all 8 shape-policy proof cases present and passing? Is shape-only
validation not presented as recompute/integrity proof? Are diagnostics
exactly the two allowed shape-policy candidates? Is unsupported policy
handled distinctly from invalid digest shape? Did no live
validator/compiler implementation change? Is no compile-refusal behavior
created? Is no public API/CLI, `CompilerResult`, loader/report,
CompatibilityReport, RuntimeMachine, Gate 3, or production authority
implied? Does the summary JSON include the required non-authorization
booleans?

Context:
- R68-C3-A (gate): Accepts hybrid policy; authorizes proof-local
  `prop038-contract-digest-shape-policy-proof-v0`; holds implementation,
  compile refusal, and all production surfaces; requires 8 specific
  shape-policy cases and 6 regression checks
- R68-C2-X (pressure): Proceed; no blockers; no non-blocking notes
- R69-C1-P1: Research Agent — proof-local experiment only; models
  `validate_contract_digest_shape` inside experiment script; does not
  edit live validator, compiler, orchestrator, or any production file;
  8 cases / 19 checks / PASS

---

## Scope Check 1 — All 8 Shape-Policy Cases Are Present And Pass

The summary JSON contains exactly 8 cases. Cross-checking against the
R68-C3-A required case table:

| Required case | Expected | Actual | Pass |
| --- | --- | --- | --- |
| `valid_short_contract_digest` | valid | valid | ✓ |
| `valid_full_contract_digest` | valid | valid | ✓ |
| `missing_contract_digest` | `contract_digest_invalid` | `["compiler_profile_contract.contract_digest_invalid"]` | ✓ |
| `contract_digest_wrong_namespace` | `contract_digest_invalid` | `["compiler_profile_contract.contract_digest_invalid"]` | ✓ |
| `contract_digest_too_short` | `contract_digest_invalid` | `["compiler_profile_contract.contract_digest_invalid"]` | ✓ |
| `contract_digest_non_hex` | `contract_digest_invalid` | `["compiler_profile_contract.contract_digest_invalid"]` | ✓ |
| `contract_digest_uppercase_hex` | `contract_digest_invalid` | `["compiler_profile_contract.contract_digest_invalid"]` | ✓ |
| `unsupported_digest_policy` | `contract_digest_policy_unsupported` | `["compiler_profile_contract.contract_digest_policy_unsupported"]` | ✓ |

Summary-level assertion `shape_policy.cases_all_pass: true` confirms
the joint result. Individual case assertions
`shape_policy.valid_short_accepts_24_plus`,
`shape_policy.valid_full_accepts_64`,
`shape_policy.invalid_uses_contract_digest_invalid`,
`shape_policy.unsupported_policy_uses_policy_unsupported` each pass.

The R68-C3-A 8-case matrix is satisfied in full. ✓

---

## Scope Check 2 — Shape-Only Validation Is Not Presented As Recompute/Integrity Proof

Every case result carries:

```json
"shape_only": true,
"recompute_match_implemented": false
```

These are not decoration. The proof-local validator function
(`validate_contract_digest_shape`) contains no SHA-256 computation, no
canonicalization logic, and no declared-vs-recomputed comparison. Its
only logic is:

1. Check `policy == "prop038_24_plus"` — emit `contract_digest_policy_unsupported` if not.
2. Check `contract["contract_digest"].to_s.match?(CONTRACT_DIGEST_PATTERN)` — emit
   `contract_digest_invalid` if not.

`CONTRACT_DIGEST_PATTERN = /\Acompiler_profile_contract\/sha256:[0-9a-f]{24,}\z/`

This is a regex shape test, not an integrity test. The pattern enforces:
namespace prefix, algorithm prefix, and character class + minimum
length. It does not compare against any computed hash.

The summary top-level:

```json
"recompute_match_implemented": false
```

And the non-authorization block:

```json
"recompute_match_proof_implementation": false
```

The track document states explicitly: "This is shape-only. It does not
recompute the contract digest and does not prove declared-vs-recomputed
integrity."

No path from a shape-only result to an integrity guarantee exists in
this proof. ✓

---

## Scope Check 3 — Diagnostics Are Exactly The Two Allowed Shape-Policy Candidates

The two proof-local diagnostic codes:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
```

Every diagnostic object across all 8 cases uses one of these two codes
exclusively. No `contract_digest_mismatch`,
`contract_digest_recompute_unavailable`, or any other code appears.

The prefix `compiler_profile_contract.` is correct under the four-layer
vocabulary separation established through R57-R67:
`compiler_profile_source.*` / `compiler_profile_obligation.*` /
`compiler_profile_contract.*` / loader/report status. Neither code
crosses a namespace boundary.

The diagnostic object shape:

```json
{
  "code": "compiler_profile_contract.contract_digest_invalid",
  "message": "contract_digest must be compiler_profile_contract/sha256:<24+ lowercase hex>",
  "path": "contract_digest"
}
```

is consistent with the validator's diagnostic shape established in R65.

The `path` field correctly distinguishes which field the error pertains
to: `"contract_digest"` for shape failures, `"digest_reference_policy"`
for policy failures. This is the correct disambiguation. ✓

---

## Scope Check 4 — Unsupported Policy Is Handled Distinctly From Invalid Digest Shape

The proof validator short-circuits on policy check before testing the
digest shape:

```ruby
if policy != SUPPORTED_POLICY
  diagnostics << diagnostic("contract_digest_policy_unsupported", ...)
elsif !contract["contract_digest"].to_s.match?(CONTRACT_DIGEST_PATTERN)
  diagnostics << diagnostic("contract_digest_invalid", ...)
end
```

The `if/elsif` structure guarantees mutual exclusivity:

- An unsupported policy always produces `contract_digest_policy_unsupported`
  with `path: "digest_reference_policy"`.
- An invalid digest shape under a supported policy always produces
  `contract_digest_invalid` with `path: "contract_digest"`.
- A valid digest under a supported policy produces no diagnostic.

These three outcomes are disjoint. The `unsupported_digest_policy` case
uses a known-valid digest value (`valid_short`) with an unsupported
policy (`"prop038_full_sha256"`), confirming that the policy error takes
priority over any shape check. The consumer cannot conflate "I don't
support this policy" with "the value is malformed."

The `prop038_full_sha256` policy is correctly treated as unsupported
here, consistent with the R68-C1-P1 design note: "Do not introduce
`prop038_full_sha256` in code before a separate policy/proof gate." ✓

---

## Scope Check 5 — No Live Validator Or Compiler Implementation Changed

The proof script:

1. `require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"` —
   this loads the live validator into the Ruby process for regression
   sampling only. It does not modify the file.

2. Calls `IgniterLang::CompilerProfileContractValidator.validate(canonical_contract, ...)` —
   exercising the existing API, not extending it.

3. Defines `validate_contract_digest_shape` as a proof-local function
   (top-level method in the script, not a module/class extension to the
   live validator).

The summary machine-asserts both flags:

```json
"live_validator_changed": false,
"compiler_integration_changed": false
```

And the non-authorization block:

```json
"non_authorization.live_validator_changed_false": true,
"non_authorization.compiler_integration_changed_false": true
```

Regression confirms the live validator still operates as accepted:
`regression.validator_summary_pass: true` (13 cases / PASS),
`regression.report_only_integration_pass: true` (5 cases / 20 checks /
PASS). The syntax check `ruby -c lib/igniter_lang/compiler_profile_contract_validator.rb`
passes, confirming the file is unchanged.

The only files created or modified by this proof are:

```text
experiments/prop038_contract_digest_shape_policy_proof/
  prop038_contract_digest_shape_policy_proof.rb
  out/prop038_contract_digest_shape_policy_proof_summary.json
docs/tracks/prop038-contract-digest-shape-policy-proof-v0.md
```

All three are within the R68-C3-A authorized write boundary. ✓

---

## Scope Check 6 — No Compile-Refusal Behavior Created

Every case result carries:

```json
"compile_refusal_authorized": false
```

Summary top-level:

```json
"compile_refusal_authorized": false
```

Non-authorization assertion:

```json
"non_authorization.compile_refusal_not_authorized": true
```

The four R68-C3-A regression checks for refusal guard all pass:

```text
regression.live_validator_compile_refusal_false → true
regression.integration_compile_refusal_false    → true
regression.no_igapp_mutation_from_proof         → true
regression.no_refusal_report_creation_from_proof → true
```

The `regression.integration_compile_refusal_false` check reads both the
`valid_contract` and `invalid_contract` cases from the R67 integration
summary and asserts their `validation.compile_refusal_authorized` is
false. This confirms the accepted report-only integration behavior
remains undisturbed.

`regression.no_refusal_report_creation_from_proof` scans the output
directory for filenames containing `"refusal"` — none found. ✓

---

## Scope Check 7 — No Public API/CLI, CompilerResult, Loader/Report, CompatibilityReport, RuntimeMachine, Gate 3, Or Production Authority Implied

The `non_authorizations_preserved` block contains 10 keys, all false:

```json
"live_validator_implementation": false,
"recompute_match_proof_implementation": false,
"compile_refusal": false,
"public_api_cli_widening": false,
"compiler_result_changes": false,
"persisted_success_reports_or_sidecars": false,
"parser_typechecker_semanticir_assembler_igapp": false,
"loader_report_or_compatibility_report": false,
"diagnostics_centralization": false,
"runtime_gate3_ledger_tbackend_bihistory_stream_olap_cache_production": false
```

The 10 keys match the full R57-R67 hold inventory. No hold is missing.

The proof script writes to `experiments/.../out/` only. It does not
touch `lib/`, `cli.rb`, `compiler_result.rb`, `compilation_report.rb`,
`compiler_orchestrator.rb`, or any `.igapp` artifact path.

The track document's non-authorization section enumerates each held
surface individually. The recommendation for C3-A is:

```text
accept
```

with an explicit note: "Do not authorize implementation or compile
refusal from this proof." ✓

---

## Scope Check 8 — Summary JSON Includes Required Non-Authorization Booleans

The summary JSON includes non-authorization booleans at two levels:

**Top-level flags** (5):

```json
"live_validator_changed": false,
"compiler_integration_changed": false,
"recompute_match_implemented": false,
"compile_refusal_authorized": false,
"implementation_authorized": false
```

**`non_authorizations_preserved` block** (10 keys):

```json
{
  "live_validator_implementation": false,
  "recompute_match_proof_implementation": false,
  "compile_refusal": false,
  "public_api_cli_widening": false,
  "compiler_result_changes": false,
  "persisted_success_reports_or_sidecars": false,
  "parser_typechecker_semanticir_assembler_igapp": false,
  "loader_report_or_compatibility_report": false,
  "diagnostics_centralization": false,
  "runtime_gate3_ledger_tbackend_bihistory_stream_olap_cache_production": false
}
```

The authority reference is correctly populated:

```json
"authority_ref": "igniter-lang/docs/gates/prop038-contract-digest-validation-policy-decision-v0.md"
```

This cites the R68-C3-A gate decision, not the track or pressure
document. The `recommendation_for_c3_a` field is present:

```json
"recommendation_for_c3_a": "accept"
```

The non-authorization block coverage matches the R65 and R67 patterns,
extended with `recompute_match_proof_implementation` to explicitly guard
the Phase 2 boundary. ✓

---

[Agree]

1. **All 8 required shape-policy cases are present, named correctly,
   and pass.** Every case in the R68-C3-A required matrix is covered
   with the expected diagnostic code or valid result.

2. **Shape-only is cleanly separated from integrity proof.** `shape_only:
   true` and `recompute_match_implemented: false` appear in every result.
   The proof-local validator is a regex test with no hash computation.

3. **Diagnostic vocabulary is exactly the two authorized candidates.**
   `contract_digest_invalid` and `contract_digest_policy_unsupported`
   only; correct namespace; correct `path` field disambiguation.

4. **Policy failure and shape failure are mutually exclusive and
   correctly ordered.** The `if/elsif` guard ensures the consumer
   always knows which failure occurred; `prop038_full_sha256` is treated
   as unsupported, consistent with the R68 design directive.

5. **No live validator or compiler implementation changed.** The proof
   script loads the live validator for regression sampling only;
   `validate_contract_digest_shape` is proof-local; both syntax and
   regression checks confirm the live files are unchanged.

6. **Compile-refusal path remains closed.** Four regression assertions
   guard against refusal creep: live validator flag, integration flag,
   `.igapp` scan, refusal-file scan. All pass.

7. **Non-authorization surface coverage is complete.** 10-key
   `non_authorizations_preserved` block matches the R57-R67 hold
   inventory plus the new `recompute_match_proof_implementation` guard.

8. **Summary JSON structure is correct.** Two-tier non-authorization
   coverage (top-level flags + block), correct `authority_ref` citing
   the R68-C3-A gate, `recommendation_for_c3_a` field present.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A acceptance decision.

---

## Verdict

**Proceed.**

All eight scope checks pass. The 8-case shape-policy matrix matches the
R68-C3-A required table exactly, with every case naming the correct
diagnostic code and the summary asserting `cases_all_pass: true`.
Shape-only validation is rigorously distinguished from integrity proof
by the absence of any hash computation in the proof-local validator and
by `shape_only: true` / `recompute_match_implemented: false` in every
result. Diagnostics are exactly the two authorized codes under
`compiler_profile_contract.*`, with correct `path` disambiguation
between policy and shape failures. Unsupported policy is handled
before shape validation in a mutual-exclusion guard. The live validator
and compiler integration are confirmed unchanged by syntax check,
regression execution (13 cases / PASS and 20 checks / PASS), and
machine-asserted flags. Compile-refusal is blocked on four distinct
regression checks. The 10-key non-authorization block covers the full
R57-R67 hold inventory. Summary JSON authority reference cites the
R68-C3-A gate correctly.

No blockers. No non-blocking notes.

---

[Route]

**Verdict: proceed.**

No blockers. No non-blocking notes.

**Recommended Architect decision (C3-A):**

1. Accept the proof-local Phase 1 shape-policy closure. All 8 required
   cases pass. All 6 required regression checks pass. 19 total checks /
   0 failures.

2. Confirm that the proof-local `validate_contract_digest_shape`
   function is not a live validator change — it is a proof model only.
   No implementation authorization follows from this acceptance.

3. Authorize the next proof-local route only if continuing Phase 2:
   ```text
   prop038-contract-digest-recompute-match-proof-v0
   ```
   Scope: exercise Phase 2 recompute-match matrix (14 cases from
   R68-C1-P1); proof-local only; produce summary JSON under experiment
   directory; do not edit live validator, compiler, orchestrator, or
   any production file.

4. Hold live validator implementation. Hold recompute-match
   implementation. Hold compile refusal. The four-condition prerequisite
   chain from R68-C3-A condition 5 remains in effect.

5. Hold PROP-038 errata. Diagnostic vocabulary stabilizes only after
   Phase 2 proof is accepted.

6. All surfaces held by R68-C3-A remain closed: implementation, compile
   refusal, public API/CLI, `CompilerResult`, persisted reports,
   sidecars, assembler/`.igapp`, loader/report, CompatibilityReport,
   `IgniterLang::Diagnostics`, RuntimeMachine, Gate 3, and production
   behavior.
