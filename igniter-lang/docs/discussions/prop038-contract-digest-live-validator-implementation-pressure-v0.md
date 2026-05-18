# Discussion: PROP-038 Contract Digest Live Validator Implementation Pressure v0

Card: S3-R74-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: implementation-pressure
Track: prop038-contract-digest-live-validator-implementation-pressure-v0

---

## Purpose

Pressure-review the PROP-038 live validator implementation before Architect
acceptance.

---

## Inputs Read

- `igniter-lang/docs/tracks/prop038-contract-digest-live-validator-implementation-v0.md` (S3-R74-C1-I)
- `igniter-lang/docs/gates/prop038-contract-digest-live-implementation-design-decision-v0.md` (S3-R73-C4-A)
- `igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb` (live changed file)
- `igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/out/prop038_contract_digest_shape_policy_proof_summary.json`
- `igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/out/prop038_contract_digest_recompute_match_proof_summary.json`
- `igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/out/prop038_contract_digest_report_only_integration_proof_summary.json`

---

## Scope Checks

### Check 1 — Changed files are inside the authorized write scope

**Pass.**

C1-I lists 10 changed files. Each is mapped to C4-A authorized scope:

| File | Authorization |
| --- | --- |
| `lib/igniter_lang/compiler_profile_contract_validator.rb` | Explicitly authorized |
| `experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | Explicitly authorized |
| `experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json` | Explicitly authorized |
| `experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | Authorized (directory) |
| `experiments/prop038_contract_digest_shape_policy_proof/out/...summary.json` | Authorized (directory) |
| `experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb` | Authorized (directory) |
| `experiments/prop038_contract_digest_recompute_match_proof/out/...summary.json` | Authorized (directory) |
| `experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb` | Authorized (directory) |
| `experiments/prop038_contract_digest_report_only_integration_proof/out/...summary.json` | Authorized (directory) |
| `docs/tracks/prop038-contract-digest-live-validator-implementation-v0.md` | Explicitly authorized |

No file in the C4-A disallow list was modified. Scan of
`lib/igniter_lang/compiler_orchestrator.rb` and `lib/igniter_lang.rb` for
`contract_digest` returns zero matches. Scan of `compiler_profile_contract_validator.rb`
for `IgniterLang::Diagnostics`, `require.*igniter`, `compiler_orchestrator`,
`compilation_report`, `compiler_result`, `cli` returns zero matches.

---

### Check 2 — Validator API and result shape remain unchanged

**Pass.**

Public API:

```ruby
def self.validate(contract, digest_reference_policy: DEFAULT_DIGEST_REFERENCE_POLICY)
```

Unchanged. The method signature is identical to the pre-implementation form. No
new public methods were added.

Result shape — eight keys exactly:

```text
compile_refusal_authorized
compiler_integrated
diagnostic_codes
diagnostics
digest_reference_policy
format_version
kind
valid
```

The summary `validator_result_keys` field lists these eight keys in sorted order
and `validator_result.no_new_top_level_fields` check passes. No new top-level
result keys were introduced.

Fixed flags confirmed:

```text
compiler_integrated=false
compile_refusal_authorized=false
```

Both are hard-coded in the `result` helper. Both appear as `false` in every
proof case result across all four proof summaries.

---

### Check 3 — All four diagnostics implemented with accepted names

**Pass.**

Implementation traces to accepted PROP-038 §10 names:

| Diagnostic Code | Emitted By | Condition |
| --- | --- | --- |
| `compiler_profile_contract.contract_digest_policy_unsupported` | `validate_contract_digest_shape` | `SUPPORTED_DIGEST_REFERENCE_POLICIES.include?(policy)` is false |
| `compiler_profile_contract.contract_digest_invalid` | `validate_contract_digest_shape` | `contract["contract_digest"].to_s.match?(CONTRACT_DIGEST_PATTERN)` is false |
| `compiler_profile_contract.contract_digest_mismatch` | `validate_contract_digest_match` | `computed_hex.start_with?(declared_hex)` is false |
| `compiler_profile_contract.contract_digest_recompute_unavailable` | `validate_contract_digest_match` rescue | any exception during canonicalization/recompute |

All four codes use the existing local `diagnostic(code, message, path)` helper
which prepends `"compiler_profile_contract."` to `code`. No codes outside the
accepted four were introduced. The `non_authorization.compile_refusal_not_authorized`
check passes in every summary.

---

### Check 4 — Canonicalization matches R70/R72

**Pass.**

**Field allowlist:** `CANONICAL_CONTRACT_FIELDS` constant lists exactly the
accepted 13 fields — `kind`, `format_version`, `profile_namespace`,
`profile_kind`, `compiler_profile_id`, `descriptor_digest`,
`finalization_payload_digest`, `required_slot_schema`, `slot_order`,
`slot_assignments`, `strict_registries`, `ordered_rule_graph`, `non_authority`.

**`contract_digest` exclusion:** `canonical_contract_material` builds a fresh
Hash from only `CANONICAL_CONTRACT_FIELDS`. Since `contract_digest` is not in
the list, it is excluded by construction — not by a delete or filter step.
The recompute summary `canonical_excludes_contract_digest` case confirms:
two contracts differing only in `contract_digest` produce the same canonical
hex (`0ece9bff...` in both). ✓

**`descriptor_digest` as string value only:**
- `canonicalize_for_digest(contract["descriptor_digest"])` passes the string
  through (String case returns the value unchanged).
- No descriptor material is fetched.
- Summary confirms: `descriptor_material_accessed=false`,
  `descriptor_digest_included_as_string=true`. ✓

**`slot_order` order-sensitive:**
- `slot_order` is processed by `canonicalize_for_digest(contract["slot_order"])`
  which maps an Array through recursion. Array elements are not sorted — their
  order is preserved.
- Summary `canonical_slot_order_order_sensitive` case: changing slot order
  changes the canonical hex (`0ece9bff...` → `d929485c...`). ✓

**Object key order-insensitive:**
- `canonicalize_for_digest` on any Hash sorts keys: `value.keys.sort_by(&:to_s).to_h`.
- Summary `canonical_object_key_order_insensitive` case: reordering top-level
  keys gives the same canonical hex. ✓

**Strict registry names and entries order-insensitive:**
- `canonical_strict_registries` sorts registry names with `.keys.sort_by(&:to_s)`.
- Entries sorted by `[key, owner_slot, rule_ref]`.
- Summary `canonical_strict_registry_order_insensitive` case: reordering
  registries and entries gives the same canonical hex. ✓

**Ordered-rule list order-insensitive:**
- `canonical_ordered_rule_graph` sorts rules by `rule_id`.
- Summary `canonical_rule_list_order_insensitive` case: reordering rules gives
  the same canonical hex. ✓

**`before`/`after` edge arrays as sorted unique sets:**
- `canonical_rule` processes `before` and `after` with
  `Array(rule[key]).map(&:to_s).uniq.sort`.
- Summary `canonical_rule_edge_set_order_insensitive` case: two contracts with
  different edge array orders produce the same canonical hex. ✓

**Missing edge arrays normalized to `[]`:**
- `canonical_rule` adds `before: []` and `after: []` for rules lacking these
  keys. This ensures two contracts differing only in explicit vs. absent empty
  edge arrays produce the same canonical material. ✓

**Recompute summary `canonicalization.included_fields` block** lists all 13
accepted fields in correct order and the `excluded_fields` list matches PROP-038
§9.6 exactly.

---

### Check 5 — Validator does not mutate caller contract

**Pass.**

`canonical_contract_material` creates a fresh Hash via `CANONICAL_CONTRACT_FIELDS.to_h`:
no in-place mutation methods (`.merge!`, `.delete`, `.update`, `[]=`) are applied
to the caller-supplied `contract` object.

The `validate_contract_digest_shape` and `validate_contract_digest_match`
helpers only read from `contract` via `[]` and `.to_s`.

Summary confirms:
- `contract_mutation_guard.valid_contract_unchanged=true`;
- `contract_mutation_guard.case_contracts_unchanged=true`;
- `shape_policy.live_validator_no_mutation` check: pass;
- `live_validator_no_contract_mutation` check (recompute proof): pass.

---

### Check 6 — All required commands pass

**Pass.**

C4-A required command matrix (9 commands) as recorded in C1-I:

| Command | Result |
| --- | --- |
| `ruby -c compiler_profile_contract_validator.rb` | PASS — Syntax OK |
| `ruby -c compiler_profile_contract_proof.rb` | PASS — Syntax OK |
| `ruby compiler_profile_contract_proof.rb` | PASS |
| `ruby -c prop038_contract_digest_shape_policy_proof.rb` | PASS — Syntax OK |
| `ruby prop038_contract_digest_shape_policy_proof.rb` | PASS |
| `ruby -c prop038_contract_digest_recompute_match_proof.rb` | PASS — Syntax OK |
| `ruby prop038_contract_digest_recompute_match_proof.rb` | PASS |
| `ruby -c prop038_contract_digest_report_only_integration_proof.rb` | PASS — Syntax OK |
| `ruby prop038_contract_digest_report_only_integration_proof.rb` | PASS |

Proof summary counts verified against C1-I track report:

```text
compiler_profile_contract_proof_summary.json  status=PASS cases=13 checks=30 failed=0 ✓
shape_policy_proof_summary.json               status=PASS cases=8  checks=20 failed=0 ✓
recompute_match_proof_summary.json            status=PASS cases=14 checks=16 failed=0 ✓
report_only_integration_proof_summary.json    status=PASS cases=12 checks=21 failed=0 ✓
```

---

### Check 7 — Report-only/no-refusal invariants hold

**Pass.**

The report-only integration proof `report_only_invariants` block confirms all
nine R71-accepted invariants:

```text
diagnostics_nested_under: "compiler_profile_contract_validation.diagnostics" ✓
top_level_report_diagnostics_unchanged: true ✓
pass_result_unchanged: true ✓
stages_unchanged: true ✓
compile_status_ok_when_source_compiles: true ✓
public_result_unchanged: true ✓
assembler_execution_unchanged: true ✓
igapp_manifest_unchanged: true ✓
refusal_report_written: false ✓
```

`compile_refusal_false.*` checks pass at three layers in the integration
summary: proof-local, live validator, and R67 report-only integration.

Nil and exception provider paths confirmed: `provider_nil_preserves_legacy_behavior`
and `provider_exception_preserves_legacy_behavior` both pass.

`all_four_codes` diagnostic coverage check in integration proof passes:
`required_codes` and `observed_codes` match exactly.

---

### Check 8 — Forbidden surfaces remain untouched

**Pass.**

The C1-I non-authorizations preserved section explicitly lists — and all four
proof summary `non_authorizations_preserved` blocks confirm — that the following
are all false/unchanged:

- compiler/orchestrator integration;
- compile refusal;
- public API/CLI widening;
- `CompilerResult` changes;
- persisted success reports or sidecars;
- parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation;
- loader/report or CompatibilityReport behavior;
- `IgniterLang::Diagnostics` centralization;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
  production behavior.

Physical scan confirms zero references to `IgniterLang::Diagnostics`, no new
`require` for non-stdlib paths, no reference to `compiler_orchestrator`,
`compilation_report`, or `cli` in the changed validator file. No `contract_digest`
matches found in `compiler_orchestrator.rb` or `lib/igniter_lang.rb`.

Standard-library additions: `require "digest"` and `require "json"` only.
Both are Ruby stdlib and introduce no gem dependency. ✓

---

### Check 9 — No top-level diagnostics or IgniterLang::Diagnostics centralization introduced

**Pass.**

All four new codes go through the existing private `diagnostic(code, message, path)` helper:

```ruby
def diagnostic(code, message, path = nil)
  {
    "code" => "compiler_profile_contract.#{code}",
    "message" => message,
    "path" => path
  }
end
```

No reference to `IgniterLang::Diagnostics` appears anywhere in the changed
validator file.

The integration proof `nested_diagnostics.only` check passes and
`top_level_diagnostics_unchanged` is confirmed true. The combined multi-
diagnostic case shows both `contract_digest_invalid` and `contract_digest_recompute_unavailable`
live under `report["compiler_profile_contract_validation"]["diagnostics"]` while
`report["diagnostics"]` remains `[]`.

---

## Additional Implementation Observations

### Diagnostic ordering matches C1-P1 design

The implementation produces diagnostics in the accepted design order:
1. `wrong_kind` / `unsupported_format_version` / `descriptor_digest_invalid` /
   `finalization_payload_digest_invalid`;
2. `contract_digest_policy_unsupported` or `contract_digest_invalid` (shape phase);
3. structural diagnostics: `missing_required_slot`, `duplicate_strict_key`,
   `missing_rule_reference`, `rule_cycle`, `runtime_authority_forbidden`,
   `dispatch_migration_forbidden`;
4. `contract_digest_mismatch` or `contract_digest_recompute_unavailable`
   (recompute phase).

The base proof `validator_case_matrix` shows all existing structural error cases
now also carry `contract_digest_mismatch` as the second code — correct behavior
because test contracts for existing cases have a `contract_digest` that was
computed for a different (valid) contract state. ✓

### Recompute guard

`validate_contract_digest_match` is called only when
`contract_digest_recomputable` is `true`. That flag is set by
`validate_contract_digest_shape` which returns `false` on policy-unsupported or
digest-shape-invalid. The guard prevents `recompute_unavailable` from stacking
on top of `contract_digest_invalid` in a single live validator call. ✓

### Recompute runs when structural diagnostics exist

`contract_digest_recomputable` depends only on the shape/policy phase, not on
whether structural diagnostics have accumulated. So a contract with both a
`rule_cycle` and a mismatched `contract_digest` correctly emits both
`compiler_profile_contract.rule_cycle` and `compiler_profile_contract.contract_digest_mismatch`.
This matches the R70-accepted behavior: canonicalization is orthogonal to rule-
reference validity. ✓

### `before`/`after` normalization for absent arrays

`canonical_rule` explicitly sets `before: []` and `after: []` when those keys
are absent. This prevents two canonically equal rules from hashing differently
based on whether an empty edge array was explicitly present in the source
contract. ✓

---

## Non-Blocking Notes

None.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: none
```

---

## Recommendation For C3-A

Recommendation:

```text
accept
```

Reason:

- all 10 changed files are within C4-A authorized write scope;
- validator API and result shape (8 keys) are unchanged; no new public methods;
- `compiler_integrated=false` and `compile_refusal_authorized=false` are
  hard-coded and machine-confirmed across all four proof summaries;
- all four accepted `contract_digest_*` diagnostic codes are implemented with
  exact PROP-038 names through the existing private `diagnostic` helper;
- canonicalization matches R70/R72 in all seven dimensions: 13-field allowlist,
  `contract_digest` excluded by construction, `descriptor_digest` string-value
  only, `slot_order` order-sensitive, object keys/registry entries/rule list/
  edge arrays all correctly handled;
- validator does not mutate caller contract — confirmed by mutation guard in all
  four proof summaries;
- all 9 required commands PASS;
- all 9 report-only invariants are confirmed by the integration proof
  `report_only_invariants` block;
- all `non_authorizations_preserved` blocks confirm no forbidden surfaces were
  touched;
- physical scan confirms no `IgniterLang::Diagnostics` reference, no new
  non-stdlib requires, no contract_digest changes in any disallowed file.

---

## Handoff

```text
Card: S3-R74-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: prop038-contract-digest-live-validator-implementation-pressure-v0
Status: done

[D] Decisions
- All 9 scope checks pass.
- All 4 contract_digest_* diagnostics implemented correctly and named exactly.
- Canonicalization verified in all 7 dimensions against R70/R72.
- Report-only invariants confirmed across all 4 proof summaries.

[S] Signals
- Implementation is clean and contained within the validator boundary.
- No forbidden surface was touched or implied.
- The proof chain is now live: R69+R70+R71 design proof maps directly to
  working implementation.

[T] Tests / Proofs
- Review-only. No code or experiments were run or edited.

[R] Recommendation
- C3-A: accept; no conditions.
```
