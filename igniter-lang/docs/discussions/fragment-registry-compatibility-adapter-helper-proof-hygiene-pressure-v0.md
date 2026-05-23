# Discussion: Fragment Registry Compatibility Adapter Helper Proof Hygiene Pressure v0

Card: S3-R149-C2-X
Agent: `[Igniter-Lang External Pressure Reviewer]`
Role: external-pressure-reviewer
Borrowed lens: proof-hygiene-pressure
Track: fragment-registry-compatibility-adapter-helper-proof-hygiene-pressure-v0
Route: UPDATE
Status: complete — proceed
Date: 2026-05-23

Depends on: S3-R149-C1-P1
Authorized by: S3-R148-C2-A

---

## Scope

Pressure-review the proof-hygiene update (S3-R149-C1-P1) for the fragment
registry compatibility adapter helper implementation proof. Verify that:

1. write scope stayed inside R148-C2-A allowed paths;
2. helper implementation file was not edited;
3. CS4 is fixed with union method scan;
4. vocabulary scan count is clarified accurately;
5. closed-surface assertions now derive from live checks where practical;
6. pinned count assertions are machine-asserted or explicitly marked unavailable;
7. command matrix still passes;
8. no root require, classifier wiring, live dispatch, public/report/artifact/
   runtime/Spark/production surface opens.

---

## Evidence Read

- `igniter-lang/docs/gates/fragment-registry-compatibility-adapter-helper-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/fragment-registry-compatibility-adapter-helper-proof-hygiene-v0.md`
- `igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/fragment_registry_compatibility_adapter_helper_implementation_proof.rb`
- `igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/out/fragment_registry_compatibility_adapter_helper_implementation_proof_summary.json`
- `git show --name-status --oneline ad3ff50c` (hygiene commit)
- `git log --oneline -5 igniter-lang/lib/igniter_lang/fragment_registry_compatibility_adapter.rb`

---

## Scope Check 1 — Write Scope Stays Inside R148-C2-A Allowed Paths

R148-C2-A allowed write scope (exact):

```text
igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/fragment_registry_compatibility_adapter_helper_implementation_proof.rb
igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/out/fragment_registry_compatibility_adapter_helper_implementation_proof_summary.json
igniter-lang/docs/tracks/fragment-registry-compatibility-adapter-helper-proof-hygiene-v0.md
```

Hygiene commit `ad3ff50c` changed exactly:

```text
A  igniter-lang/docs/tracks/fragment-registry-compatibility-adapter-helper-proof-hygiene-v0.md
M  igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/fragment_registry_compatibility_adapter_helper_implementation_proof.rb
M  igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/out/fragment_registry_compatibility_adapter_helper_implementation_proof_summary.json
```

Outcome: **PASS** — 3 files changed, all inside authorized scope. No extra files.

---

## Scope Check 2 — Helper Implementation File Not Edited

Git log for `igniter-lang/lib/igniter_lang/fragment_registry_compatibility_adapter.rb`:

```text
f865dd9c Add S3-R147-C2-I: fragment registry compatibility adapter helper implementation
```

One commit only: the original R147 implementation. The hygiene commit `ad3ff50c`
does not appear. The helper lib file is unchanged.

Outcome: **PASS** — helper implementation file not edited.

---

## Scope Check 3 — CS4 Fixed With Union Method Scan

R148-C2-A required fix:

```ruby
all_singleton_methods =
  IgniterLang::FragmentRegistryCompatibilityAdapter.methods(false) +
  IgniterLang::FragmentRegistryCompatibilityAdapter.private_methods(false)

(all_singleton_methods & forbidden).empty?
```

Actual CS4 implementation in the updated proof runner (lines 254–260):

```ruby
checks << check("CS4.no_live_classifier_dispatch_method") do
  forbidden = [:dispatch, :classify, :wire, :register, :install]
  helper_methods =
    IgniterLang::FragmentRegistryCompatibilityAdapter.methods(false) +
    IgniterLang::FragmentRegistryCompatibilityAdapter.private_methods(false)
  (helper_methods.uniq & forbidden).empty?
end
```

The fix uses `+` (union) followed by `.uniq` then `&` — correct. The addition of
`.uniq` is safe and appropriate: it removes duplicate method names before the
intersection check without changing semantics.

Forbidden set: `[:dispatch, :classify, :wire, :register, :install]` — a
well-chosen set of dispatch-like names. The helper exposes `.project` (public
singleton via `methods(false)`) and `select_fragment`,
`rules_in_order_description` (private singletons via `private_methods(false)`).
None of these appear in the forbidden set. CS4 correctly passes.

The `closed_surface_assertions` entry `live_classifier_dispatch` is now derived
from `!pass?(status_by_name, "CS4.no_live_classifier_dispatch_method")`, which
means it is now a meaningful derivation rather than hardcoded `false`.

Outcome: **PASS** — CS4 correctly fixed, check is now functional.

---

## Scope Check 4 — Vocabulary Scan Count Clarified Accurately

R148-C2-A required clarification: `19 total / 18 checked / 1 authorized skipped`.

Updated `run_vocab_scan` method (lines 405–431) computes:

- `lib_files` = all `lib/igniter_lang/*.rb` files (19 total)
- `authorized_skipped_files` = files matching `HELPER_FILE.to_s` (1)
- `checked_files` = `lib_files - authorized_skipped_files` (18)

Summary JSON `vocab_scan` field:

```json
{
  "total_files": 19,
  "checked_files": 18,
  "authorized_skipped_files": 1,
  "authorized_skipped_paths": ["lib/igniter_lang/fragment_registry_compatibility_adapter.rb"],
  "scan_count_label": "19 total / 18 checked / 1 authorized skipped",
  "scanned_files": 18,
  "scanned_terms": 4,
  "hits": [],
  "status": "CLEAN"
}
```

`scanned_files` now equals `checked_files.length` (18), resolving the R148
NB-2 discrepancy where `scanned_files` was previously reported as 19. The
`scan_count_label` exactly matches the R148-C2-A required wording. The skipped
path is recorded explicitly.

Outcome: **PASS** — vocabulary scan count clarified accurately and fully.

---

## Scope Check 5 — Closed-Surface Assertions Derive From Live Checks

Updated `closed_surface_assertions` method (lines 601–619) derives 13 entries
from live check results using `pass?()`:

| Assertion | Derived from check |
| --- | --- |
| `helper_file_exists_at_authorized_path` | `CS1` — live filesystem read |
| `root_require_references_helper` | `!CS2` — live file content read |
| `classifier_references_helper` | `!CS3` — live file content read |
| `live_classifier_dispatch` | `!CS4` — now meaningful (union scan fixed) |
| `classifiedprogram_field_added` | `!CS7` — live file content read |
| `compilation_report_or_compiler_result_changed` | `!CS8` — live file content read |
| `assembler_or_semanticir_reference_added` | `!CS9` — live file content read |
| `cli_reference_added` | `!CS10` — live file content read |
| `unauthorized_vocab_hits_outside_helper` | `!NEG1` — live vocab scan |
| `regression_matrix_failed` | `!PARITY.regression_all_commands_passed` |
| `igapp_parity_evidence_missing` | `!PARITY.igapp_result_summary_stable` |
| `source_to_semanticir_parity_evidence_missing` | `!PARITY.semanticir_golden_stable` |
| `assumptions_parity_evidence_missing` | `!PARITY.assumptions_golden_stable` |

All 13 derive from live check results. No hardcoded `false` values remain.

Outcome: **PASS** — closed-surface assertions are live-derived where practical.

---

## Scope Check 6 — Pinned Counts Machine-Asserted or Marked Unavailable

`PINNED_COUNTS` constant maps each regression command to its expected count.
`exposed_ok_count` counts lines matching `/:\s+ok\s*$/` from command output.
`command_count_assertion` produces:

- `PASS / machine_asserted: true` when observed count matches expected;
- `FAIL / machine_asserted: true` when observed count mismatches expected;
- `UNAVAILABLE / machine_asserted: false` when no `: ok` lines are found.

The status assignment (`exit_ok && count_assertion[:status] != "FAIL"`)
correctly fails a command if count mismatches but passes if count is
UNAVAILABLE — meaning exit-code-only verification when counting is not
possible. All 6 current commands expose countable output, so UNAVAILABLE
is not triggered in this run.

Summary JSON regression matrix — all 6 commands:

| Command | Expected | Observed | Assertion |
| --- | ---: | ---: | --- |
| `classifier_pass_proof` | 21 | 21 | PASS / machine\_asserted: true |
| `contract_modifiers_proof` | 20 | 20 | PASS / machine\_asserted: true |
| `assumptions_proof` | 39 | 39 | PASS / machine\_asserted: true |
| `source_to_semanticir_fixture --check-golden` | 31 | 31 | PASS / machine\_asserted: true |
| `igapp_assembler_proof` | 17 | 17 | PASS / machine\_asserted: true |
| `invariant_severity_proof` | 34 | 34 | PASS / machine\_asserted: true |

Outcome: **PASS** — all 6 pinned counts machine-asserted against observed output.

---

## Scope Check 7 — Command Matrix Still Passes

Summary JSON: `status: PASS`, `checks_total: 44`, `checks_pass: 44`,
`checks_fail: 0`.

All regression matrix entries: `status: PASS`, `exit_code: 0`. All
check-count assertions: `status: PASS`. The main proof check (44/44) and
the full regression matrix pass without regression.

Input and result digests are identical to R147:

```text
input_digest:  47e938fdea0e46e067a2c88b  (matches R146 C1 and R147)
result_digest: c109ef1b1b124fd825172327  (matches R147 live result)
```

Helper behavior is confirmed unchanged.

Outcome: **PASS** — 44/44 PASS, regression matrix 6/6 PASS.

---

## Scope Check 8 — No Closed Surfaces Opened

Static assertions from the updated summary `closed_surface_assertions`:

```text
helper_file_exists_at_authorized_path:      true  (live)
root_require_references_helper:             false (live: CS2)
classifier_references_helper:               false (live: CS3)
live_classifier_dispatch:                   false (live: CS4 — now functional)
classifiedprogram_field_added:              false (live: CS7)
compilation_report_or_compiler_result_changed: false (live: CS8)
assembler_or_semanticir_reference_added:    false (live: CS9)
cli_reference_added:                        false (live: CS10)
unauthorized_vocab_hits_outside_helper:     false (live: NEG1)
regression_matrix_failed:                  false (live: PARITY)
igapp_parity_evidence_missing:             false (live: PARITY)
source_to_semanticir_parity_evidence_missing: false (live: PARITY)
assumptions_parity_evidence_missing:       false (live: PARITY)
```

Parity evidence digests unchanged from R147:

```text
igapp_result_summary_digest:     f8b4426843a85b6a03d6629a
semanticir_golden_digest:        f3f7fa48455bed3adb2e8777  (23 files)
assumptions_golden_digest:       156da071b981e15cc32fea13  (12 files)
contract_modifiers_golden_digest: 319721cd4d9e10f0a23c4fa1 (23 files)
invariant_severity_digest:       b47e6cf8f64de68cd911c516
```

No golden mutations. No lib/compiler/report/artifact changes outside the
authorized experiment directory.

Outcome: **PASS** — all closed surfaces confirmed closed.

---

## Non-Blocking Notes

### NB-1 — `prop036_mutated` / `prop038_mutated` Absent From New Assertions

The R147 summary's `closed_surface_assertions` included `prop036_mutated: false`
and `prop038_mutated: false` (hardcoded). These fields are absent from the
hygiene summary. The underlying protection is now covered more robustly:
NEG1 (broad vocab scan) and regression matrix parity evidence collectively
rule out unauthorized PROP-036/PROP-038 mutation. The field names are gone
but the protection is stronger.

This is a cosmetic reshaping of the assertions dictionary, not a weakening.
No action required. C3-A may note this as expected.

### NB-2 — `UNAVAILABLE` Fallback in Count Assertion Is Undocumented for Future Proof Patterns

If a future regression command does not emit lines matching `/:\s+ok\s*$/`,
`exposed_ok_count` returns `nil`, `command_count_assertion` returns
`UNAVAILABLE / machine_asserted: false`, and the command still passes on
exit code alone. This is reasonable behavior for this context but could
silently degrade count enforcement for future commands with different output
formats.

Not triggered in the current run (all 6 commands expose countable output).
No action required for this slice. Future proof patterns should note this
fallback when adopting the same helper.

### NB-3 — Proof Runner `CARD` Constant Stays `S3-R147-C2-I`

The proof runner's `CARD = "S3-R147-C2-I"` constant and the summary JSON
`"card": "S3-R147-C2-I"` correctly identify the proof as testing the R147
implementation. The hygiene card S3-R149-C1-P1 appears only in the track
doc header. This is the expected arrangement — the runner tests and belongs
to the R147 implementation slice.

No action required.

---

## Verdict

**proceed** — 8/8 scope checks PASS. No blockers.

All four R148-C2-A required hygiene items landed correctly:

1. CS4 union scan fixed — check is now functional;
2. vocabulary scan count clarified as `19 total / 18 checked / 1 authorized
   skipped`;
3. `closed_surface_assertions` fully derived from live CS/NEG/PARITY checks;
4. all 6 pinned regression counts machine-asserted against observed output.

Helper implementation behavior is unchanged. All closed surfaces remain closed.
Write scope is exact. Input and result digests are stable.

---

## Acceptance Recommendation for C3-A

**Accept** the hygiene closure.

The proof harness for the fragment registry compatibility adapter helper
implementation is now functionally complete for its bounded direct-require-only
scope. The four defects identified in S3-R148-C1-X are fully resolved.

C3-A should:

- Accept commit `ad3ff50c` as the proof-hygiene closure for S3-R149-C1-P1;
- confirm that no further proof work is required for this slice unless a
  future card opens a new surface;
- keep classifier wiring, root require, and live classifier dispatch closed
  pending a separate later gate;
- not authorize any implementation, compiler, report, artifact, runtime,
  Spark, or production work from this acceptance.
