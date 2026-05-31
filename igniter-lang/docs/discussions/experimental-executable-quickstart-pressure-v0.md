# Experimental Executable Quickstart Pressure v0

Card: S3-R223-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-executable-quickstart-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-05-31

Depends on:
- S3-R223-C1-A
- S3-R223-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-executable-quickstart-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/experimental-executable-quickstart-v0.md` (C2-I)
- `igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb` (implementation)
- `igniter-lang/examples/experimental_executable_quickstart_v0/add_quickstart.ig` (source fixture)
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/quickstart_result.json` (result)
- `igniter-lang/docs/tracks/stage3-round222-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-use-productization-route-decision-v0.md` (R222-C4-A)

---

## Verified Pipeline Result

From result JSON (`sha256:666952db1cf6018396dd2595690956cdf9337c4ca5f3d333f950f5218756731a`):

```text
source:           add_quickstart.ig
compile_status:   ok
igapp_exists:     true
load_status:      loaded          ← no adapter needed
adapter_used:     false
execution_status: ok
actual_sum:       42
expected_sum:     42
output_matches:   true
overall:          PASS
checks:           14/14
```

The pipeline is end-to-end executable: `.ig → compile → .igapp → delegated experimental runtime → sum = 42`.

---

## Risk Matrix

| Risk | Probability | Severity | C2-I fence | Residual |
| --- | --- | --- | --- | --- |
| Quickstart is compile-only, not actually executable | Zero | Critical | Pipeline JSON confirms `execution_status: ok`, `actual_sum: 42`; EXQ-3/EXQ-4 PASS; HOLD logic present in overall calculation | Zero |
| Delegated runtime wording implies public/Reference Runtime support | Low | High | Disclaimer present in quickstart.rb header (point-of-use), result JSON (10 disclaimer fields), track doc, and non-claim block; three-runtime distinction machine-readable in result JSON | Very low |
| Example-local adapter leaks internal compiler format knowledge | Low (adapter not triggered) | Medium | adapter_used: false; adapter code is present as fallback but was not invoked; entirely within example directory; no lib/** or CompiledProgram changes; honest about being example-local and non-canonical | Very low — code is example-local, not triggered |
| `lib/**`, RuntimeSmoke, CompilerResult, CompilationReport changed | Very low | High | EXQ-8/EXQ-9/EXQ-10 PASS; track doc closed-surface table confirms; no marker in any lib file | Very low |
| `.igapp` output escapes example-local scope | Very low | Medium | EXQ-5: `out_abs.include?("examples/experimental_executable_quickstart_v0/out")` PASS; `out_path: IGAPP_DIR` explicitly set to example-local path in compile call | Very low |
| Forbidden phrase scan misses positive claims | Very low | High | EXQ-11 PASS; split-concatenation fix for self-referential scanner correctly applied; scanner targets non-comment code lines only (correct behavior per C1-A: comments/negations acceptable) | Very low |
| Stable API / production / Reference Runtime / Spark authority created | Very low | Critical | EXQ-13 PASS; result JSON disclaimer: `not_production_runtime`, `not_reference_runtime`, `not_public_demo`, `not_spark_integration` all true; no lib/** changes | Very low |
| EXQ-14 "structural invariant" check is vacuous | Low (structural) | Low | EXQ-14 body returns `true`; HOLD logic IS correctly present in overall calculation (`elsif compile_status == "ok" && execution_status != "ok"→"HOLD"`); AN-1 below | Low — behavioral, not blocking |
| Counterfactual report/API or Option D reopened | Zero | High | Track doc confirms R221 closures preserved; no reference to counterfactual surfaces in any quickstart file | Zero |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Quickstart is actually executable | Result JSON: `execution_status: ok`, `actual_sum: 42 == expected_sum`; EXQ-3 PASS; EXQ-4 PASS; harness output confirms "Execution result: {'sum'=>42}" | End-to-end executable. Not compile-only. Pipeline ran the full `.ig → compile → .igapp → delegated runtime` chain. | ✅ PASS |
| Compile-only outcome would be HOLD | EXQ-14 structural invariant recorded; code: `elsif compile_status == "ok" && execution_status != "ok" → "HOLD"` present at lines 398-400; exit code 2 for HOLD | HOLD logic is structurally correct. EXQ-14 check body is `true` (structural declaration) rather than a behavioral test, but the invariant IS enforced by the overall calculation. See AN-1. | ✅ SAFE (see AN-1) |
| Delegated experimental runtime wording is clear and non-canonical | Disclaimer in quickstart.rb header (verbatim C1-A required wording, lines 11-25); three-runtime distinction present in both code and result JSON; result JSON disclaimer object has 10 boolean fields all true; non-claim block in track doc | Wording exceeds C1-A minimum requirements. Machine-readable disclaimer in result JSON enables downstream tooling to verify non-canonical status. Three-runtime distinction is at point of use, not only in release docs. | ✅ SAFE |
| Adapter/normalizer is example-local and honest about mismatch | adapter_used: false; adapter code present in quickstart.rb as defensive fallback (lines 150-240) but not triggered; `normalize_to_fixture_format` writes only to example-local `out/Add_normalized.igapp`; EXQ-6/EXQ-7 PASS | No adapter was needed; compiler-emitted PROP-019.1 `.igapp` loaded directly. Adapter code is example-local, correctly scoped, and includes explicit non-canonical wording. If triggered, it would write to `examples/…/out/` only. | ✅ SAFE |
| RuntimeSmoke, lib/**, bin/igc, CompilerResult, CompilationReport closed | EXQ-8: runtime_smoke.rb does not contain quickstart marker; EXQ-9: no lib file contains quickstart marker, bin/igc not in `$LOADED_FEATURES`; EXQ-10: compiler_result.rb and compilation_report.rb unchanged; track doc closed-surface table confirms all 10 surfaces | All closed surfaces confirmed. Checks use "marker not present" as proxy — adequate for example-local scope where no production behavior was changed. | ✅ SAFE |
| Output confined to example-local | EXQ-5 PASS: `out_abs.include?("examples/experimental_executable_quickstart_v0/out")`; compile call uses `out_path: IGAPP_DIR` where `IGAPP_DIR = .../examples/experimental_executable_quickstart_v0/out/Add.igapp` | Confirmed from both the check and the source code path setup. No `.igapp` output was written outside the example directory. | ✅ SAFE |
| Forbidden phrase scan sufficient | EXQ-11 PASS; scanner covers non-comment code lines of quickstart.rb; comment lines correctly excluded (C1-A: "Forbidden phrases may appear only in explicit negation / non-claim blocks"); self-referential fix applied (split concatenation for EXQ-11 and EXQ-12) | Scan scope is correctly bounded. The two fixes applied are technically sound. | ✅ SAFE |
| Slice materially improves time to experimental use | Previously: no examples directory (confirmed by find command in R222-C2-P1); now: full `.ig → compile → .igapp → delegated runtime → sum = 42` pipeline with point-of-use wording; developer can run `ruby quickstart.rb` from clone | High TTEU impact achieved. This is the highest-friction gap (absent examples) directly resolved. | ✅ YES |
| Implementation not too broad | Write scope: exactly two targets (example directory + track doc); 5 files written, all under example-local scope; no lib/**, no gemspec, no README changes; track doc confirms | Scope precisely matches C1-A authorization. | ✅ NOT TOO BROAD |
| Implementation not too timid | Full pipeline is executable, not compile-only; adapter code provides resilience for future format changes; machine-readable result JSON with disclaimer, three-runtime distinction, and proof matrix summary; forbidden phrase scan and structural HOLD logic present | The slice delivers genuine executable value, not another status artifact. | ✅ NOT TOO TIMID |

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Does C2-I satisfy executable quickstart intent? | Yes. Full end-to-end pipeline: `.ig → compile → .igapp → delegated experimental runtime → sum = 42`. 14/14 PASS. |
| Does this create public runtime, Reference Runtime, production, or stable API authority? | No. Machine-readable disclaimer in result JSON: `not_production_runtime`, `not_reference_runtime`, `not_public_demo` all true. Three-runtime distinction present at point of use and in JSON. |
| Was artifact-format mismatch handled honestly? | Yes, but was not needed. Adapter code is present as defensive example-local fallback, correctly labeled non-canonical, and was not triggered. `adapter_used: false`, `adapter_note: nil`, mismatch recorded as "none." |
| Should acceptance proceed, be conditional, hold, or redirect? | Accept unconditionally with one non-blocking note (AN-1: EXQ-14 structural declaration vs behavioral test). |
| What exact C4-A decision should prefer? | Accept C2-I proof. Recognize executable quickstart as first honest developer experience. Proceed to status curation. No new runtime/API/public authority. |

---

## Non-Blocking Acceptance Note

**AN-1 — EXQ-14 is a structural declaration, not a behavioral test.**

`check("EXQ-14.compile_only_would_be_hold_not_pass") { true }` documents the structural invariant but does not test the HOLD code path. The HOLD logic itself IS present and correct in the `overall` calculation. Since the current run succeeded (execution_status == "ok"), the HOLD branch was not taken and the check is vacuously satisfied.

C4-A should note this in the acceptance record: EXQ-14 is correctly classified as a structural invariant declaration for this run. Future quickstart iterations that need to demonstrate the HOLD path explicitly may add a separate test harness for the compile-only scenario.

This does not block acceptance. The invariant is enforced by the code; only the check declaration is weak.

---

## Verdict

```text
PASS

C2-I Experimental Executable Quickstart: 14/14 PASS — accept
No blockers
1 non-blocking acceptance note (AN-1: EXQ-14 structural declaration only)
C4-A HOLD: release; proceed to final acceptance decision
```

The quickstart is genuinely executable. No authority leaks. No public/runtime/Reference Runtime/production/Spark claims. All closed surfaces confirmed unchanged. Time-to-experimental-use materially improved.

---

## Recommendation for S3-R223-C4-A

```text
Card: S3-R223-C4-A (final acceptance)
Route: UPDATE
Mode: unconditional acceptance

Accept:
- C2-I Experimental Executable Quickstart proof (14/14 PASS)
- Full pipeline evidence: .ig → compile → .igapp → delegated experimental
  runtime → sum = 42 (a:19, b:23)
- Result digest:
    sha256:666952db1cf6018396dd2595690956cdf9337c4ca5f3d333f950f5218756731a

Note for acceptance record (AN-1):
- EXQ-14 check body is a structural declaration (returns true) rather than
  a behavioral test; the HOLD invariant is correctly enforced by the overall
  calculation; future iterations may add explicit HOLD-path testing

What this accepts:
- examples/experimental_executable_quickstart_v0/ as the first curated
  experimental developer experience
- Delegated experimental runtime as non-canonical example-local learning
  evidence only (not Reference Runtime, not production runtime)
- Three-runtime distinction as a binding quickstart boundary

What this does not accept:
- Any public runtime, Reference Runtime, or production runtime authority
- Any stable API guarantee before v1
- Any lib/** changes (none were made)
- RuntimeSmoke productization (remains closed)
- Counterfactual report/API or Option D (remain held)

Keep closed:
- stable API / production / Reference Runtime / Spark / release claims
- lib/** implementation
- RuntimeSmoke behavior/result shape
- CompilerResult / CompilationReport fields
- report/result/API surfaces
```
