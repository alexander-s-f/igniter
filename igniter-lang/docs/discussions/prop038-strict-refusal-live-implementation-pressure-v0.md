# prop038-strict-refusal-live-implementation-pressure-v0

Card: S3-R83-C3-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: implementation-pressure
Track: prop038-strict-refusal-live-implementation-pressure-v0
Route: UPDATE
Status: complete

---

## Inputs Read

- `igniter-lang/docs/tracks/prop038-strict-refusal-live-implementation-v0.md` (C2-I)
- `igniter-lang/docs/gates/prop038-strict-refusal-live-implementation-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/gates/prop038-strict-refusal-live-implementation-scope-decision-v0.md` (S3-R82-C4-A)
- `igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/out/prop038_strict_refusal_live_implementation_proof_summary.json`

Independent verification:

```bash
ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb  # → Syntax OK
ruby -c igniter-lang/lib/igniter_lang/compiler_result.rb        # → Syntax OK
ruby -c igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/prop038_strict_refusal_live_implementation_proof.rb  # → Syntax OK
```

---

## Scope Checks

### 1. Write scope = C1-A authorized scope exactly

C2-I lists exactly five changed files:

- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`
- `igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/prop038_strict_refusal_live_implementation_proof.rb`
- `igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/out/prop038_strict_refusal_live_implementation_proof_summary.json`
- `igniter-lang/docs/tracks/prop038-strict-refusal-live-implementation-v0.md`

C1-A authorized write scope covers exactly:
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`
- `igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/`
- `igniter-lang/docs/tracks/prop038-strict-refusal-live-implementation-v0.md`

Track records explicitly: `"No public API/CLI files were edited."`

**Result: PASS**

---

### 2. Strict source is internal-only / test-seam only

C2-I introduced only a constructor seam:

```ruby
compiler_profile_contract_strict_requirement: nil
```

Track records `IgniterLang.compile` signature unchanged. Track "Non-Authorizations
Preserved" section explicitly lists: public API/CLI widening; `IgniterLang.compile`
signature; env/config/manifest/loader/report/CompatibilityReport strict source.

Proof summary: `non_persisting_evidence` and case names confirm strict terminal
paths reachable only through the constructor seam. No public facade, CLI flag,
env lookup, or manifest source exists.

**Result: PASS**

---

### 3. Validator result is evidence, not authority

Proof summary check `strict_mismatch.validator_not_authority_marker_preserved: true`
PASS.

The `strict_digest_mismatch_refused` case shows the validator result contains
`"compile_refusal_authorized": false` even when the orchestrator returns `refused`.
Authority resides in the orchestrator-level strict requirement decision path, not
in any validator flag.

**Result: PASS**

---

### 4. `compile_refusal_authorized: false` remains nested read-only evidence

From the `strict_digest_mismatch_refused` case in the proof summary:

```json
"compiler_profile_contract_validation": {
  "compile_refusal_authorized": false,
  "report_only": true,
  ...
}
```

Both `compile_refusal_authorized: false` and `report_only: true` are nested inside
`compiler_profile_contract_validation`. Neither appears as a top-level public
result key. Check `strict_mismatch.validator_not_authority_marker_preserved` PASS.

**Result: PASS**

---

### 5. `report.pass_result: "ok"` invariant for strict terminal paths

Proof summary shows:

- `strict_digest_mismatch_refused` case: `"report_pass_result": "ok"`
- `strict_malformed_configuration_error` case: `"report_pass_result": "ok"`

These are asserted as named checks. Track summary restates the invariant. Matches
C1-A policy requirement.

**Result: PASS**

---

### 6. `configuration_error` and `refused` share exact public key-set

Proof summary top-level check:

```text
public_terminal_keysets.refused == public_terminal_keysets.configuration_error
```

Case-level check `configuration_error.keyset_same_as_refused: true` PASS.

Both terminal statuses expose exactly the 13-key public allowlist accepted by
S3-R81/R82:

```text
kind, format_version, status, program_id, source_path, source_hash,
grammar_version, stages, igapp_path, contracts, compilation_report_path,
diagnostics, warnings
```

Differences between `refused` and `configuration_error` are values and
diagnostics, not keys. Matches C1-A requirement.

**Result: PASS**

---

### 7. No sidecar / report / `.igapp` for strict terminal paths

Proof summary `non_persisting_evidence`:

```json
"strict_refused": {
  "report_path_key_present": false,
  "report_path_written": false,
  "igapp_written": false,
  "manifest_written": false
},
"configuration_error": {
  "report_path_key_present": false,
  "report_path_written": false,
  "igapp_written": false,
  "manifest_written": false
}
```

Named checks `strict_mismatch.no_sidecar_report` and `configuration_error.no_sidecar_report`
PASS.

Track Non-Persisting Evidence section reproduces both JSON blocks and confirms
`compilation_report_path: null` in public result shape.

**Result: PASS**

---

### 8. `CompilerOrchestrator#refusal` not called for strict terminal paths

Proof summary shows `strict_digest_mismatch_refused` case:
`"refusal_called": false`

And `strict_malformed_configuration_error` case: `"refusal_called": false`

Named checks `strict_mismatch.refusal_not_called` and
`configuration_error.refusal_not_called` PASS.

Track explicitly states: "The proof also guards that `CompilerOrchestrator#refusal`
is not called for strict terminal paths."

**Result: PASS**

---

### 9. Ordinary paths unchanged

Five ordinary failure path groups in proof:

- `parse_error_baseline`, `parse_error_with_strict_requirement`: `status: "failed"`,
  `report_path_written: true`
- `oof_baseline`, `oof_with_strict_requirement`: `status: "refused"`,
  `report_path_written: true`
- `assembler_refused_preserved`: `status: "refused"`, `report_path_written: true`
- `runtime_smoke_failed_preserved`: `status: "failed"`, `report_path_written: true`
- `internal_error_preserved`: `status: "internal_error"`, `report_path_written: true`

Each ordinary failure path has `report_path_written: true` (sidecars preserved),
confirming `CompilerOrchestrator#refusal` was called normally for those paths.

Track Preservation Evidence section lists all nine preservation categories. Proof
summary `failed_checks: []` — all 46 checks PASS.

**Result: PASS**

---

### 10. Public API / CLI / facade / loader / production closed

Track "Non-Authorizations Preserved" section enumerates 11 explicitly closed
surfaces including: public API/CLI widening; `IgniterLang.compile` signature;
env/config/manifest/loader/report/CompatibilityReport strict source; persisted
reports or sidecars; `.igapp` mutation; parser, TypeChecker, SemanticIR, assembler,
diagnostics centralization.

C1-A "Explicit Non-Authorizations" section lists 20+ explicitly closed items.
Proof `non_authorizations_preserved` checks confirm no forbidden surface touched.

No `igniter_lang.rb`, `cli.rb`, or `bin/igc` file appears in the changed file list.

**Result: PASS**

---

## Non-Blocking Notes

### NB-1: `assembler_calls` counter absent for non-strict success paths

For cases such as `strict_valid_contract_allows` and
`no_strict_source_mismatch_report_only`, the proof summary does not record an
explicit `assembler_calls` counter. Assembly is confirmed indirectly via
`igapp_written: true` and `manifest_written: true` for these cases.

For strict terminal paths, the explicit counter `assembler_calls: 0` is present
and machine-asserted. The non-strict success paths confirm assembly happened
through artifact presence — this is a minor instrumentation asymmetry rather than
a gap in the proof.

Not a blocker for this implementation slice. A future assembler-call counter for
all paths would improve proof uniformity but is not required before closure.

---

## Summary

| Check | Result |
| --- | --- |
| 1. Write scope exactly within C1-A boundary | PASS |
| 2. Strict source internal-only / constructor seam | PASS |
| 3. Validator result is evidence not authority | PASS |
| 4. `compile_refusal_authorized: false` nested read-only | PASS |
| 5. `report.pass_result: "ok"` invariant for strict terminal paths | PASS |
| 6. `configuration_error` and `refused` share exact 13-key public key-set | PASS |
| 7. No sidecar / report / `.igapp` for strict terminal paths | PASS |
| 8. `#refusal` not called for strict terminal paths | PASS |
| 9. Ordinary parse / OOF / assembler / runtime-smoke / internal-error paths unchanged | PASS |
| 10. Public API / CLI / facade / loader / production surfaces closed | PASS |

```text
checks: 10/10
blockers: 0
non-blocking notes: 1 (assembler_calls counter absent for non-strict success paths — minor instrumentation asymmetry, non-blocking)
```

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 1
```

---

## Recommendation for Status Curation / Next Architect Step

The bounded internal-only PROP-038 strict-refusal live implementation (C2-I) is
clean. All 10 scope checks pass. All 46 proof checks pass. All 11 required command
matrix commands pass. The implementation satisfies every constraint specified in
the C1-A authorization gate.

The following are mechanically confirmed:

- Internal-only constructor seam; `IgniterLang.compile` signature unchanged.
- Orchestrator is authority; validator `compile_refusal_authorized: false` is nested
  evidence only.
- `report.pass_result: "ok"` invariant holds for both `refused` and
  `configuration_error` strict terminal paths.
- Exact 13-key public allowlist shared by both terminal statuses.
- Non-persisting: no sidecar, no report, no `.igapp` for strict terminal paths.
- `CompilerOrchestrator#refusal` not called for strict terminal paths.
- All ordinary failure path preservation confirmed.
- All forbidden surfaces remain closed.

Recommend Architect proceed with:

1. Pressure-review closure / status curation for this implementation slice.
2. Decide whether the implementation slice is accepted as the live PROP-038
   strict-refusal foundation, or whether additional acceptance criteria apply
   before the S3 round closes.
3. No public API/CLI widening, persisted report, or loader/report surface question
   is open from this review — those remain closed per C1-A.
