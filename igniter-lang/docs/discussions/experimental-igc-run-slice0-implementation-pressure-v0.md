# Experimental igc run Slice 0 Implementation Pressure v0

Card: S3-R234-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-igc-run-slice0-implementation-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-02

Depends on:
- S3-R234-C1-A
- S3-R234-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md` (C2-I)
- `igniter-lang/experiments/experimental_igc_run_v0/out/summary.json` (verified, 20/20 checks)
- `igniter-lang/lib/igniter_lang/experimental_igc_run.rb` (inspected directly)
- `igniter-lang/lib/igniter_lang/cli.rb` (inspected for run dispatch)
- `igniter-lang/docs/tracks/stage3-round233-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-design-only-boundary-decision-v0.md`

Git diff confirmed changed files (last commit):

```text
lib/igniter_lang/cli.rb                          ← authorized
lib/igniter_lang/experimental_igc_run.rb         ← authorized (new)
experiments/experimental_igc_run_v0/**           ← authorized
docs/tracks/experimental-igc-run-slice0-...      ← authorized
```

NOT changed (confirmed):
```text
bin/igc / gemspec / README / runtime_smoke.rb /
compiler_result.rb / compilation_report.rb / igniter_lang.rb
```

---

## Compact Risk Table

| Risk | Assessment | Evidence | Residual |
| --- | --- | --- | --- |
| Implementation crept outside C1-A write scope | Zero | Git diff: only 2 lib files + experiments/** + track doc; bin/igc, gemspec, README, runtime_smoke.rb, compiler_result.rb, compilation_report.rb, igniter_lang.rb all untouched | Zero |
| `igc compile` backward-compatible | Zero | compile.regression command: exit 0, status: ok, all 5 stages ok, runtime_smoke: null | Zero |
| `--experimental` not enforced | Zero | IGR-1 PASS; command matrix: missing_experimental → exit 1, stderr: "igc run requires --experimental"; source: `raise RunFailure.new("missing_experimental", ...) unless options[:experimental]` | Zero |
| `.igbin` accepted | Zero | IGR-6 PASS; two rejection paths: (1) passport artifact_kind check → "passport artifact_kind must be igapp_dir"; (2) artifact path check → "igc run Slice 0 accepts .igapp directories only" | Zero |
| Passport validation not fail-closed | Zero | IGR-2..7 + IGR-20 PASS; all negative cases exit 1 with specific stderr messages; command JSON shows actual exit codes | Zero |
| `delegated-experimental:ivm-proof` resolution implicit | Zero | C2-I explicit: `PROOF_RUNTIME_PATH = REPO_ROOT.join("igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb")`; IGR-8 PASS: `--runtime reference` → "unsupported runtime selector for igc run Slice 0"; S3-R233-C3-X AN-3 closed | Zero |
| RuntimeSmoke referenced or invoked | Zero | grep of experimental_igc_run.rb for runtime_smoke/RuntimeSmoke → NO OUTPUT; IGR-11 PASS: check named `no_runtime_smoke_or_production_compiler_cli_in_result`; compile regression: `runtime_smoke: null` | Zero |
| `production-compiler-cli` in result output | Zero | IGR-11 PASS; grep of experimental_igc_run.rb for "production.compiler.cli" → NO OUTPUT; S3-R233-C3-X AN-1 closed | Zero |
| Result packet conflicts with CompilerResult / CompilationReport / receipt | Zero | IGR-10 PASS; result_kind: "experimental_igc_run_v0_result"; `stable_api: false`, `pre_v1: true`, `runtime_authority: "non-canonical / delegated experimental"` | Zero |
| non_claims incomplete in result packet | Zero | REQUIRED_NON_CLAIMS: 9 entries matching C1-A required set exactly: not stable API / not production ready / not public runtime support / not Reference Runtime support / not Spark integration / not release evidence / not public performance claim / not compiler passport emission / not igc run implementation | Zero |
| `lib/igniter_lang.rb` root require widened | Zero | Git diff: igniter_lang.rb NOT in changed files; experimental_igc_run.rb loaded via `require_relative` in CLI run path only (lazy), not root-required | Zero |
| Stable API / production / Spark / release / Reference Runtime / public performance claims | Zero | IGR-15 PASS; non_claims present in result packet; forbidden phrase scan passes | Zero |
| igc run returns wrong output | Zero | IGR-9 PASS; command matrix: `run.positive` exit 0, stdout empty; result.json `outputs.sum: 42`; inputs: `{a: 19, b: 23}` | Zero |

---

## Pressure-Test Findings

**Write scope compliance:** Exact match to C1-A. Two authorized lib files changed, experiments/** used for proof fixtures, track doc written. `bin/igc` correctly left unchanged — the existing entrypoint dispatches through `IgniterLang::CLI.run(ARGV)` which now handles `run` internally. No conditional was needed.

**`--experimental` guard:** Source confirms `raise RunFailure.new("missing_experimental", "igc run requires --experimental") unless options[:experimental]` — this is the first check inside the run path, before any passport or artifact processing. IGR-1 PASS with real exit-1 evidence in the command matrix.

**`.igbin` rejection depth:** Two independent rejection points: (1) passport `artifact_kind` validation rejects any non-`igapp_dir` kind, explicitly including `igbin_aot_binary`; (2) the artifact path itself is checked for being a directory. A `.igbin` file path fails closed before even opening the passport. IGR-6 PASS covers both cases (two separate commands in the summary).

**RuntimeSmoke absent:** Source inspection confirms `experimental_igc_run.rb` has no reference to `RuntimeSmoke`, `runtime_smoke`, or `"production-compiler-cli"`. The compile regression also shows `"runtime_smoke": null` — the compile path is unaffected. S3-R233-C3-X AN-1 fully closed.

**Runtime selector resolution:** `PROOF_RUNTIME_PATH` is a hardcoded constant pointing to the exact proof runtime path specified in C1-A. IGR-8 confirms `--runtime reference` is rejected. S3-R233-C3-X AN-3 fully closed.

**Passport validation completeness:** The summary JSON shows 13 distinct negative-case commands, each with a specific exit code and error message. The digest recomputation policy matches R232 (sorted directory tree → SHA256). Deferred output_contract is explicitly detected and rejected.

**Result packet:** `kind: "experimental_igc_run_v0_result"` is distinct from all CompilerResult, CompilationReport, CompatibilityReport, and receipt shapes. The packet includes `experimental: true`, `pre_v1: true`, `stable_api: false`. The non_claims array matches C1-A's required set exactly.

**Root require not widened:** `experimental_igc_run.rb` is loaded lazily via `require_relative "experimental_igc_run"` inside the CLI `run_artifact` method only. It is not added to `lib/igniter_lang.rb`. Users who `require "igniter_lang"` without invoking `igc run` do not load the experimental run helper.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Accept / conditional accept / hold / redirect? | Accept unconditionally. |
| Exact blocker list? | None. |
| Exact follow-up list? | None required for acceptance. Two informational carry-forwards below. |
| Can C4-A accept implementation closure? | Yes. All 20 IGR checks pass with real execution evidence. |

---

## Informational Carry-Forwards (Non-Blocking)

**CF-1 — `"not certified alternative implementation"` and `"not artifact portability guarantee"` absent from result non_claims.**

The R232 passport manifests carried 11 non-claims. The Slice 0 result packet carries 9 (matching the C1-A-specified set). The two missing items ("not certified alternative implementation," "not artifact portability guarantee") were not in C1-A's required set for the result packet. No action required. Noted for awareness in any future result packet schema version.

**CF-2 — `igc run` now appears in the USAGE string in `cli.rb`.**

The RUN_USAGE constant is visible in any Ruby file that loads `cli.rb`. This is correct and expected. Any future card that touches `cli.rb` should ensure the usage string continues to include `--experimental` and the delegated selector in the run usage line, so it does not imply a more general run capability.

---

## Verdict

```text
PASS — accept unconditionally

C2-I Experimental igc run Slice 0: 20/20 IGR PASS — accept
No blockers
2 informational carry-forwards (CF-1, CF-2) — non-blocking
C4-A HOLD: release; proceed to unconditional acceptance
```

The implementation is the tightest bounded experimental command delivered so far. Every negative case has a specific error message and was proven with actual command execution. No forbidden surfaces were touched. RuntimeSmoke is genuinely absent. The root require was not widened.

---

## Recommendation for S3-R234-C4-A

```text
Card: S3-R234-C4-A (final acceptance)
Route: UPDATE
Mode: unconditional acceptance

Accept:
- C2-I Experimental igc run Slice 0 implementation (20/20 IGR PASS)
- igc run command with mandatory --experimental
- .igbin rejected via two independent paths
- passport fail-closed validation (13 distinct error paths verified)
- runtime selector "delegated-experimental:ivm-proof" → explicit
  CompiledProgram.load_igapp / validate! / evaluate_contract
- result packet: experimental_igc_run_v0_result (not CompilerResult/
  CompilationReport/receipt)
- RuntimeSmoke absent from all run code paths (IGR-11 PASS)
- production-compiler-cli absent from result output (IGR-11 PASS)

Note for acceptance record (CF-1):
  Result packet carries 9 non-claims (C1-A required set); future schema
  versions may add not_certified_alternative_implementation and
  not_artifact_portability_guarantee for alignment with R232 manifests.

Note for acceptance record (CF-2):
  RUN_USAGE string in cli.rb includes --experimental; any future cli.rb
  edit must preserve the --experimental requirement in usage wording.

Keep closed:
- .igbin execution in igc run
- compiler passport emission
- RuntimeSmoke productization
- Reference Runtime
- public runtime / stable API / production / Spark / release claims
- gemspec / README / public docs (unchanged)
```
