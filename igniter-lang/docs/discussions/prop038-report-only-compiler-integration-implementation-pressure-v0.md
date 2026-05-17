# Discussion: PROP-038 Report-Only Compiler Integration Implementation Pressure v0

Card: S3-R67-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: implementation-pressure
Mode: discussion
Initiator: user
Track: prop038-report-only-compiler-integration-implementation-pressure-v0

Depends on: S3-R67-C1-I delivered

Question:

Did the bounded Candidate A implementation stay inside the authorized paths? Is the
provider exclusively constructor-injected with no public API/CLI widening? Is
provider exception treated as nil? Does validation attach only an in-memory
`CompilationReport` field? Does invalid contract leave `pass_result`, `stages`,
assembler execution, compile status, public result, and refusal behavior
completely unchanged? Is `CompilerResult` and the public facade unchanged? Are
persisted reports, sidecars, and `.igapp` manifests free from validation
annotation side effects? Is `contract_digest` deferred? Is `compiler_integrated=false`
confirmed as "does not drive compile outcome" by machine assertion?

Context:
- R66-C3-A (gate): Authorized Candidate A only; internal provider on
  `CompilerOrchestrator` constructor; in-memory `CompilationReport` field;
  report-only, never refusal; 8 required proof cases; provider exceptions →
  nil; no `CompilerResult` change; NB-2 accepted —
  `compiler_integrated=false` means "does not drive compile outcome"
- R66-C2-X (pressure): Proceed; NB-1 (provider interface/exceptions — impl
  resolves); NB-2 (`compiler_integrated` semantics — C3-A confirmed Reading 1)
- R67-C1-I: Implementation Agent — edited `compiler_orchestrator.rb` and
  `compilation_report.rb`; created new proof experiment; proof 5 cases /
  20 checks / PASS; all 8 required cases pass

---

## Scope Check 1 — Write Scope Stayed Exactly Within Authorized Paths

The track reports exactly five files changed:

```text
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json
igniter-lang/docs/tracks/prop038-report-only-compiler-integration-implementation-v0.md
```

The gate authorized:

```text
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb       ✓
igniter-lang/lib/igniter_lang/compilation_report.rb          ✓
igniter-lang/experiments/prop038_report_only_compiler_integration/  ✓
igniter-lang/docs/tracks/<future-implementation-track>.md    ✓
```

The track explicitly confirms not changed:

```text
igniter-lang/lib/igniter_lang.rb              → not changed ✓
igniter-lang/lib/igniter_lang/cli.rb           → not changed ✓
igniter-lang/lib/igniter_lang/compiler_result.rb → not changed ✓
```

All five files are inside the authorized boundary. The three read-only files are
untouched. ✓

The orchestrator adds `require_relative "compiler_profile_contract_validator"` as
an internal dependency. The gate listed the validator as "may read but must not
edit" — this is an internal require within an authorized write target, not a
top-level facade change. The validator file itself is not changed. ✓

---

## Scope Check 2 — Provider Is Constructor-Injected; No Public API/CLI Widening

The constructor injection:

```ruby
def initialize(
  classifier: Classifier.new,
  typechecker: TypeChecker.new,
  emitter: SemanticIREmitter.new,
  assembler: Assembler.new,
  compiler_profile_contract_provider: nil
)
```

The public `compile(...)` method signature is unchanged. No keyword argument was
added to `compile`. No `--compiler-profile-contract` CLI flag was added. No
`IgniterLang.compile(... compiler_profile_contract: ...)` overload was added.
`igniter-lang/lib/igniter_lang.rb` and `igniter-lang/lib/igniter_lang/cli.rb` are
unchanged.

The proof harness demonstrates the internal-only injection pattern:

```ruby
orchestrator = IgniterLang::CompilerOrchestrator.new(
  compiler_profile_contract_provider: provider
)
orchestration = orchestrator.compile(source_path: SOURCE_PATH, out_path: out_path)
```

No public surface is touched. ✓

The gate prohibited eight orchestrator behaviors (path reading, inline JSON
parsing, profile discovery/defaulting/inference/finalization, deriving contract
from source, deriving source from contract, adding facade/CLI input). None of these
appear in the orchestrator implementation. The `compiler_profile_contract_validation`
private method receives only what the provider returns. ✓

---

## Scope Check 3 — Provider Exception Is Treated As Nil

The private `compiler_profile_contract_validation` method:

```ruby
def compiler_profile_contract_validation(source_path:, out_path:, parsed_program:, compiler_profile_source:)
  return nil unless @compiler_profile_contract_provider.respond_to?(:call)

  contract = @compiler_profile_contract_provider.call(
    source_path: source_path,
    out_path: out_path,
    parsed_program: parsed_program,
    compiler_profile_source: compiler_profile_source
  )
  return nil unless contract.is_a?(Hash)

  CompilerProfileContractValidator.validate(contract)
rescue
  nil
end
```

The bare `rescue` covers the entire method body including both the provider call
and the validator call. In Ruby, bare `rescue` is equivalent to
`rescue StandardError` — it catches all common runtime exceptions without
swallowing fatal signals (`SystemExit`, `SignalException`, `NoMemoryError`).
This satisfies the gate:

```text
rescue provider exceptions and treat them as nil
Reason: provider failure must not become compile refusal
```

The proof machine-asserts this behavior:

```text
exception_provider.legacy_no_validation_field → pass: true
exception_provider.status_ok → pass: true
provider_exception.no_refusal_report_written → pass: true
```

The `exception_provider` always raises (`raise "synthetic provider failure"`).
All three checks confirm the exception is silently absorbed as nil, the compile
status is ok, and no refusal report is written. ✓

The broader `rescue` covering the validator call is correct for report-only
behavior: if the validator itself raised for any reason, the annotation failure
should also not become a compile failure. ✓

---

## Scope Check 4 — Validation Attaches Only An In-Memory CompilationReport Field

The `CompilationReport.with_compiler_profile_contract_validation` helper:

```ruby
def with_compiler_profile_contract_validation(report:, validation:)
  return report unless validation
  report.merge(
    "compiler_profile_contract_validation" => validation.merge("report_only" => true)
  )
end
```

`report.merge(...)` returns a NEW Hash — it does not mutate the existing report
object. The pre-annotation report object is preserved in `report_for_assembly`.

The orchestrator's insertion sequence:

```ruby
report_for_assembly = report                       # capture pre-annotation

if report.fetch("pass_result") == "ok"
  validation = compiler_profile_contract_validation(...)
  report = CompilationReport.with_compiler_profile_contract_validation(
    report: report, validation: validation
  )
end

return refusal(report, ...) unless report.fetch("pass_result") == "ok"

assembled = @assembler.assemble_artifacts(
  ...
  report: report_for_assembly,                     # pre-annotation report to assembler
  ...
)
```

The assembler receives `report_for_assembly` (the pre-annotation object). The
annotated `report` is used only for:
1. the post-annotation refusal check (which still cannot fire because annotation
   does not change `pass_result`);
2. the `CompilerResult.ok(report: report)` call (where the internal report is
   carried but stripped by `public_result`).

No file write is triggered by the annotation. The only file writes are inside
`refusal(...)` (which writes a `.compilation_report.json`) and the assembler
(which writes `.igapp` artifacts) — both receive the pre-annotation report. ✓

---

## Scope Check 5 — Invalid Contract Does Not Alter Any Compile Outcome

This is the pivotal invariant. The proof machine-asserts it from seven independent
angles for the `invalid_contract` case:

| Check | Asserted property | Pass |
| --- | --- | --- |
| `invalid_contract.compile_status_ok` | `orchestration["status"] == "ok"` | ✓ |
| `invalid_contract.pass_result_unchanged` | `report["pass_result"]` matches baseline | ✓ |
| `invalid_contract.stages_unchanged` | `report["stages"]` matches baseline | ✓ |
| `invalid_contract.diagnostics_unchanged` | `report["diagnostics"]` matches baseline | ✓ |
| `invalid_contract.assembler_executed` | `.igapp/manifest.json` exists | ✓ |
| `invalid_contract.igapp_manifest_unchanged` | `manifest.json` content matches baseline | ✓ |
| `invalid_contract.no_refusal_report_written` | `.compilation_report.json` not written | ✓ |
| `invalid_contract.public_result_unchanged` | `public_result_comparable` matches baseline | ✓ |

Eight independent checks (across five distinct observable surfaces) confirm that
an invalid contract contract produces exactly the same externally visible outcome
as the `baseline_no_provider` case.

The `baseline_no_provider` comparison pattern is particularly robust: the proof
compiles the same source four times (valid, invalid, nil, exception provider) and
compares every observable surface against the no-provider baseline. This cannot
accidentally pass if any external behavior changes. ✓

The gate's five hard rules are all machine-asserted:

```text
invalid ... must not change pass_result        → invalid_contract.pass_result_unchanged ✓
invalid ... must not change stages             → invalid_contract.stages_unchanged ✓
invalid ... must not block assembly            → invalid_contract.assembler_executed ✓
invalid ... != compile refusal                 → invalid_contract.no_refusal_report_written ✓
invalid ... => report field only               → invalid_contract.attaches_validation_false ✓
```

---

## Scope Check 6 — CompilerResult And Public Facade Remain Unchanged

`igniter-lang/lib/igniter_lang/compiler_result.rb`: explicitly not changed (track).

The proof asserts `public_result_unchanged` for all four provider variants:

```json
"public_result_unchanged": {
  "valid_contract": true,
  "invalid_contract": true,
  "nil_provider": true,
  "exception_provider": true
}
```

The `comparable_public_result` helper strips `igapp_path` (which varies by output
directory) before comparison, giving a stable equality check for the rest of the
public result shape. All four variants match the baseline exactly. ✓

The path through the code: `CompilerResult.ok(report: report)` carries the
annotated report internally, but `CompilerResult.public_result` strips the
`"report"` key. Because the `compiler_profile_contract_validation` field lives
inside `report`, it is stripped from public output together with the rest of the
internal report. ✓

`igniter-lang/lib/igniter_lang.rb` and `igniter-lang/lib/igniter_lang/cli.rb` are
not changed. ✓

---

## Scope Check 7 — No Persisted Output; `.igapp` Manifest Stable

**No persisted success report:**
The orchestrator's `write_json` call appears only inside `refusal(...)`. The happy
path (successful compilation) does not call `write_json`. An invalid contract does
not trigger `refusal(...)`. The annotation helper `with_compiler_profile_contract_validation`
does not write any file. ✓

**No sidecar:**
No new sidecar file writer exists in the implementation. The only new code paths
are in `compiler_profile_contract_validation` (private method returning Hash or
nil) and `CompilationReport.with_compiler_profile_contract_validation` (pure Hash
merge). Neither writes files. ✓

**`.igapp` manifest unchanged:**
The assembler receives `report_for_assembly` (pre-annotation). The proof directly
compares `manifest.json` content against the baseline for all four provider
variants:

```json
"igapp_manifest_unchanged": {
  "valid_contract": true,
  "invalid_contract": true,
  "nil_provider": true,
  "exception_provider": true
}
```

All four match baseline. No `.igapp` artifact is affected by contract validation
annotation. ✓

**`non_authorizations_preserved` machine assertion:**

The proof summary records 16 non-authorization flags, all false:

```json
{
  "compile_refusal": false,
  "public_api_cli_widening": false,
  "persisted_success_report": false,
  "sidecar": false,
  "igapp_manifest_mutation": false,
  "loader_report": false,
  "compatibility_report": false,
  "diagnostics_centralization": false,
  "compiler_result_change": false,
  "runtime_machine": false,
  ...
}
```

Compared to R65's 15 flags, R67 adds three integration-specific flags
(`persisted_success_report`, `sidecar`, `igapp_manifest_mutation`) that directly
correspond to the Candidate B–D options held in R66-C1-P1. The flag set correctly
evolves to match the new integration surface. ✓

---

## Scope Check 8 — `contract_digest` Deferred; No New Diagnostic Vocabulary

The `compiler_orchestrator.rb` and `compilation_report.rb` do not introduce any
new `compiler_profile_contract.*` diagnostic codes. The validator is called as-is:

```ruby
CompilerProfileContractValidator.validate(contract)
```

No new diagnostic is added in the orchestrator. No `contract_digest_invalid`,
`contract_digest_mismatch`, `unknown_owner_slot`, or any other unauthorized
diagnostic appears.

The validator's diagnostic vocabulary remains the same 10 proof-parity codes
accepted in R65. ✓

---

## Scope Check 9 — `compiler_integrated=false` Confirmed As "Does Not Drive Compile Outcome"

R66-C2-X NB-2 asked C3-A to confirm that `compiler_integrated=false` means "does
not drive compile outcome" and that the proof should machine-assert the outcome
interpretation.

R66-C3-A accepted NB-2 and stated:

```text
Proof must assert the outcome interpretation: invalid contract validation does
not change compile status, stages, assembler execution, public result, or
refusal behavior.
```

The proof does exactly this. Two proof checks directly address the semantics:

```text
invalid_contract.compiler_integrated_false   → pass: true
invalid_contract.compile_refusal_authorized_false → pass: true
```

Combined with the seven outcome checks from Scope Check 5, the `compiler_integrated=false`
field is confirmed by behavioral assertion: the field is false AND the compile
outcome is demonstrably unaffected. The semantic meaning "does not drive compile
outcome" is machine-backed, not just declared. ✓

The `valid_provider` lambda in the proof also validates the calling convention
by raising if any expected argument is absent or unexpected:

```ruby
valid_provider = lambda do |source_path:, out_path:, parsed_program:, compiler_profile_source:|
  raise "missing source_path" unless source_path
  raise "missing out_path" unless out_path
  raise "missing parsed_program" unless parsed_program
  raise "unexpected compiler_profile_source" unless compiler_profile_source.nil?
  canonical_contract
end
```

The fact that the `valid_contract` case produces `valid: true` (not nil via
exception) confirms the orchestrator passes all four expected keyword arguments
to the provider in the correct form. ✓

---

[Agree]

1. **Write scope is exactly the authorized boundary.** Five files; all within
   the gate-specified paths. The three read-only files are untouched. The validator
   `require_relative` inside `compiler_orchestrator.rb` is an authorized internal
   dependency, not a public facade change.

2. **Constructor injection is the only provider entry point.** `compile(...)` is
   unchanged. CLI and public facade are unchanged. No path loading, JSON parsing,
   profile discovery, or derivation. ✓

3. **Provider exception handling is correct and broader than required.** The bare
   `rescue` covers both the provider call and the validator call. This is the right
   policy for report-only behavior: any failure in the validation pipeline must not
   become a compile failure. R66-C2-X NB-1 is closed by implementation.

4. **In-memory annotation is structurally enforced, not just asserted.**
   `report_for_assembly = report` is captured before the annotation block;
   assembler receives the pre-annotation object. The `report.merge(...)` pattern
   creates a new Hash without mutating `report_for_assembly`. No file write is
   triggered by annotation.

5. **Invalid contract leaves all compile outcomes unchanged — machine-asserted
   from eight independent angles.** The baseline-comparison proof pattern is the
   strongest possible test: not only does it assert individual properties, it
   compares the entire observable output surface against the no-provider case.

6. **`compiler_integrated=false` semantics are now behaviorally confirmed.**
   The field stays false AND the compile outcome is unchanged — together these
   satisfy R66-C3-A NB-2 resolution. Reading 1 ("does not drive compile outcome")
   is machine-backed.

7. **All 8 required proof cases pass. 20 total checks, 0 failures.** The 12
   additional checks beyond the 8 required provide comprehensive coverage of
   the invariants that matter most: `pass_result`, `stages`, `diagnostics`,
   assembler execution, `.igapp` manifest, public result, and both non-integration
   flags.

8. **16 `non_authorizations_preserved` flags machine-asserted false.** The flag
   set correctly evolves from R65's 15 flags to include three report-integration-
   specific flags (`persisted_success_report`, `sidecar`, `igapp_manifest_mutation`).

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A Architect acceptance decision.

---

## Verdict

**Proceed.**

All nine scope checks pass. The bounded Candidate A report-only compiler integration
is complete. The provider is constructor-injected with no public API/CLI widening.
Provider exceptions are rescued as nil. The annotation attaches only an in-memory
`CompilationReport` field via a structurally enforced pre-annotation capture pattern.
Invalid contracts leave all eight observable compile surfaces unchanged —
machine-asserted by baseline comparison across five provider variants. `CompilerResult`
and the public facade are unchanged. No file is written by the annotation path.
`contract_digest` remains deferred. `compiler_integrated=false` is behaviorally
confirmed as "does not drive compile outcome" by joint assertion of the flag value
and the compile-outcome invariants. All 16 non-authorization flags are machine-asserted
false.

No blockers. No non-blocking notes.

---

[Route]

**Verdict: proceed.**

No blockers. No non-blocking notes.

**Recommended Architect decision (C3-A):**

1. Accept the bounded Candidate A report-only compiler integration. All gate
   requirements are satisfied. The proof is comprehensive with 20 checks across
   five provider variants and a baseline-comparison pattern that cannot
   accidentally pass if external behavior changes.

2. Close the R66 implementation authorization. The Candidate A scope is complete.

3. The `compiler_integrated=false` semantic question (NB-2) is resolved by
   implementation: proof checks `invalid_contract.compiler_integrated_false` and
   `invalid_contract.compile_status_ok` together confirm Reading 1.

4. The provider interface question (NB-1) is resolved by implementation: duck-typed
   `respond_to?(:call)`, keyword argument call convention, bare `rescue → nil`.

5. The next lane, if any, requires a separate design card. Candidates remaining:
   - B (persisted success report) — hold pending output/golden policy;
   - C (sidecar) — hold pending sidecar policy;
   - contract-digest validation — hold pending digest diagnostic design;
   - compile refusal — held; requires dedicated gate.
   None of these open from this acceptance.

6. Do not open compile refusal, persisted reports, sidecar, public API/CLI
   widening, `CompilerResult` change, `.igapp` mutation, loader/report,
   CompatibilityReport, `IgniterLang::Diagnostics`, runtime, Gate 3, or
   production behavior from this acceptance.
