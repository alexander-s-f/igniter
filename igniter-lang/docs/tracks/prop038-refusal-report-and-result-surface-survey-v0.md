# PROP-038 Refusal Report And Result Surface Survey v0

Card: S3-R79-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop038-refusal-report-and-result-surface-survey-v0
Route: UPDATE
Status: done
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-live-refusal-implementation-boundary-design-decision-v0.md`

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - future status/refusal vocabulary and strict-source design.
- [Igniter-Lang Bridge Agent] - future CLI/API/report surface pressure; no bridge implementation changed.

---

## Scope

Read-only survey of current refusal/report/result surfaces so R79 can decide
the design boundary from code facts.

Read:

- `docs/gates/prop038-live-refusal-implementation-boundary-design-decision-v0.md`
- `docs/tracks/prop038-live-refusal-current-pipeline-surface-survey-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/compiler_result.rb`
- `lib/igniter_lang/compilation_report.rb`
- `lib/igniter_lang/cli.rb`
- `lib/igniter_lang.rb`
- `lib/igniter_lang/assembler.rb`
- `lib/igniter_lang/semanticir_emitter.rb`
- `lib/igniter_lang/diagnostics.rb`
- `bin/igc`
- `rg "def refusal|CompilerResult|compilation_report|public_result|pass_result|report_for_assembly|compiler_profile_contract|contract_digest" igniter-lang/lib igniter-lang/bin`
- `rg '"refused"|status: "refused"|status.*refused|\\brefused\\b' igniter-lang/lib igniter-lang/bin`

No code was edited. This survey does not propose code and does not authorize
implementation.

---

## Current Horizon

R78 accepted a design-only boundary: future work may design an internal
orchestrator strict source and status boundary, but live refusal remains closed.
Current live compiler behavior is still report-only for PROP-038 contract
validation. The current code has no live `refused` compiler status; the only
compiler refusal path is the existing `CompilerOrchestrator#refusal` helper,
which always writes a compilation report file.

---

## Refusal / Report / Result Surface Map

```text
SemanticIREmitter
  -> compilation_report(pass_result: ok | oof)
CompilerOrchestrator#compile
  -> CompilationReport.enrich(...)
  -> report_for_assembly = report
  -> report-only compiler_profile_contract_validation, only when pass_result == ok
  -> refusal(report, ...) when report["pass_result"] != "ok"
  -> Assembler.assemble_artifacts(report: report_for_assembly, ...)
  -> runtime_smoke failure can produce refusal after assembly
  -> CompilerResult.ok(...)
CompilerResult.public_result(...)
  -> removes internal "report"
CLI
  -> prints public result JSON
  -> returns true only when orchestration["status"] == "ok"
bin/igc
  -> exits 0 on true, 1 on false
```

### Report Producers

| Producer | Current pass/result vocabulary | Notes |
| --- | --- | --- |
| `SemanticIREmitter#typed_compilation_report` | `pass_result: "ok" | "oof"` | Type errors make typecheck `oof`, emit `skipped`, `semantic_ir_ref=nil`. |
| `CompilationReport.parse_failure` | `pass_result: "error"` | Parse failures use `program_id: "compilation_report/parse_error"`. |
| `CompilationReport.runtime_smoke_failure` | `pass_result: "error"` | Merges runtime diagnostics into an existing report after assembly/smoke. |
| `CompilationReport.internal_error` | `pass_result: "error"` | Used for assembler refusal and generic compiler errors. |
| `CompilationReport.with_compiler_profile_contract_validation` | preserves existing `pass_result` | Adds nested report-only validation field only; does not change stages or diagnostics. |

### Refusal Creation Points

| Surface | Trigger | Status returned by orchestration | Report write? |
| --- | --- | --- | --- |
| `parse_failure(...)` | `parse_errors` present | `error` | yes, through `#refusal` |
| Main compiler gate | `report["pass_result"] != "ok"` | default `oof` | yes, through `#refusal` |
| Runtime smoke gate | smoke exists and `trusted=false` | `runtime_smoke_failed` | yes, through `#refusal` |
| `AssemblyRefused` rescue | assembler raises | `assembler_refused` | yes, through `#refusal` |
| Generic rescue | unexpected compiler exception | `error` | yes, through `#refusal` |

There is no current live `status: "refused"` from the compiler. The string
`"refused"` appears in `Assembler#refuse_case`, which is an assembler proof
helper summary, and in an unrelated TemporalExecutor comment. The live
compiler/orchestrator status for assembler failure is `assembler_refused`.

---

## Existing Report-Write Behavior

`CompilerOrchestrator#refusal(report, source_path, out_path, status: "oof")`
does three things:

1. Computes `report_path`.
2. Writes the full report JSON to that path.
3. Returns orchestration output with `status`, `CompilerResult.refusal(...)`,
   `compilation_report`, and `report_path`.

Current path rule:

| `out_path` shape | Report path |
| --- | --- |
| ends with `.igapp` | replace suffix with `.compilation_report.json` |
| any other path | append `.compilation_report.json` |

Current write mechanics:

```text
FileUtils.mkdir_p(dirname(report_path))
File.write(report_path, JSON.pretty_generate(report) + "\n")
```

This means reusing `#refusal` for future PROP-038 live refusal would also reuse
the sidecar report write unless a later design explicitly changes the path.

Distinct current report writes:

| Report write | Path | When |
| --- | --- | --- |
| Compiler refusal sidecar | `<out>.compilation_report.json` or `<out without .igapp>.compilation_report.json` | Any current orchestrator refusal. |
| Successful `.igapp` artifact report | `<out>.igapp/compilation_report.json` | Successful assembler artifact write. |
| In-memory report-only annotation | no direct write by itself | PROP-038 validation field on successful report object. |

The successful `.igapp/compilation_report.json` is written by the assembler
from `report_for_assembly`, which is captured before PROP-038 report-only
annotation. Current `.igapp` report artifacts therefore do not include
`compiler_profile_contract_validation`.

---

## CompilerResult Surface

### `CompilerResult.ok(...)`

Current public/internal result fields:

```text
kind
format_version
status: "ok"
program_id
source_path
source_hash
grammar_version
stages + assemble: "ok"
igapp_path
compilation_report_ref
semantic_ir_ref
contracts
diagnostics: []
warnings
runtime_smoke
report
```

`report` is internal and later stripped by `public_result`.

### `CompilerResult.refusal(...)`

Current refusal result fields:

```text
kind
format_version
status
program_id: report["semantic_ir_ref"] or nil
source_path
source_hash
grammar_version
stages + assemble: "skipped"
igapp_path: nil
contracts: []
compilation_report_path
diagnostics: Diagnostics.errors(report["diagnostics"])
warnings: Diagnostics.warnings(report["diagnostics"])
report
```

Important coupling facts:

- `status` is passed in by `CompilerOrchestrator#refusal`; no whitelist lives in
  `CompilerResult`.
- `program_id` for refusals is not the report id. It is `semantic_ir_ref` when
  present, otherwise `nil`.
- refusal diagnostics are computed only from top-level `report["diagnostics"]`.
  Nested `compiler_profile_contract_validation.diagnostics` are ignored by the
  current constructor.
- `assemble` is always reported as `skipped` for `CompilerResult.refusal`,
  even when the refusal came after an assembler exception.

### `CompilerResult.public_result(...)`

Current behavior:

```text
result.reject { |key, _| key == "report" }
```

Only the internal `report` field is removed. If a future design adds new
top-level result fields, they will become public unless the public shaping logic
is explicitly changed.

---

## CLI Surface

Current command:

```text
igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]
```

Current CLI success/refusal behavior:

| Path | stdout | stderr | CLI return | process exit via `bin/igc` |
| --- | --- | --- | --- | --- |
| compiler returns `status: "ok"` | pretty public result JSON | none from CLI | `true` | `0` |
| compiler returns non-ok status | pretty public result JSON | none from CLI | `false` | `1` |
| CLI preflight `ArgumentError` | no result JSON | error message / usage | `false` | `1` |

Current preflight errors include unsupported command/args, missing
`--compiler-profile-source` path, missing file, non-file path, unreadable file,
malformed JSON, and JSON that is not an object.

The CLI does not expose:

- strict mode;
- compiler profile contract provider/path;
- digest policy;
- refusal authorization;
- public report attachment;
- CompatibilityReport or loader/report behavior.

---

## PROP-038 Report-Only Placement

Current placement in `CompilerOrchestrator#compile`:

1. Parse/classify/typecheck/emit.
2. Enrich compilation report.
3. Capture `report_for_assembly = report`.
4. If `pass_result == "ok"`, call the optional contract provider.
5. If provider returns a `Hash`, validate with `CompilerProfileContractValidator`.
6. Attach `compiler_profile_contract_validation` with `report_only: true`.
7. Check `report["pass_result"] != "ok"` for existing refusal.
8. Assemble using `report_for_assembly`, not the annotated report.

Consequences:

- invalid PROP-038 validation does not currently set `pass_result`;
- no top-level diagnostics are added by contract validation;
- assembler artifacts remain unchanged by the report-only field;
- public CLI output remains unchanged because `public_result` strips `report`.

---

## Coupling Risk Table

| Risk | Why it matters | Surface to test before implementation |
| --- | --- | --- |
| Reusing `CompilerOrchestrator#refusal` silently writes a sidecar report. | R78 accepted this as unresolved tension; future no-persistence design cannot reuse it unchanged. | report path presence/absence and JSON shape. |
| Adding live `refused` status changes public CLI JSON and exit behavior. | CLI returns false for any non-ok status and `bin/igc` exits 1; public result will expose new status. | CLI stdout/status/exit golden. |
| Nested validation diagnostics are currently ignored by `CompilerResult.refusal`. | A future PROP-038 refusal may need wrapper or evidence diagnostics visible in public result. | public result diagnostics and hidden report content. |
| Promoting nested diagnostics to top-level changes success warnings/errors too. | `CompilerResult.ok` warnings derive from top-level report diagnostics. | valid/invalid report-only integration regression. |
| Changing `pass_result` for strict mismatch affects the existing main refusal gate. | This would skip assembly and write a sidecar report through the existing path. | assembly-not-run and report-write tests. |
| Moving or changing `report_for_assembly` can mutate `.igapp` artifacts. | Current artifact hash/material includes `compilation_report`; annotated reports would affect output. | manifest/hash/compilation_report artifact diff. |
| Provider nil/non-Hash/exception currently fails open. | A strict fail-closed policy would turn provider plumbing into user-visible compile failures. | provider nil/non-Hash/error cases. |
| Assembler refusal and PROP-038 refusal could share visible failure status accidentally. | Current assembler failures use `assembler_refused` and `ASSEMBLER-REFUSAL` diagnostics. | profile-source failure remains assembler/refusal boundary. |
| Runtime smoke refusal happens after assembly. | PROP-038 strict refusal is expected pre-assembly by R78 design guidance. | strict mismatch does not write `.igapp`; runtime smoke ordering unaffected. |
| `public_result` strips only `report`. | Any new result field becomes public by default. | public result key whitelist/diff. |
| Refusal `program_id` is `semantic_ir_ref`, not report id. | Strict refusal before/after SemanticIR affects whether `program_id` is nil. | result identity shape for strict refusal. |
| CLI preflight errors are not compiler refusals. | Future strict source parsing in CLI, if ever authorized, must distinguish preflight stderr from compiler JSON refusal. | bad strict-source input CLI behavior. |

---

## Future Test Surface Candidates

These are non-authority candidates for a later implementation review.

| Candidate | Expected reason to test |
| --- | --- |
| Legacy no-provider compile success | Proves report-only default remains unchanged. |
| Provider invalid digest under report-only | Proves current invalid validation still compiles and assembles. |
| Strict source absent | Proves no source means no live refusal. |
| Strict source malformed/unsupported | Proves whether design chooses configuration error, report-only, or refusal. |
| Strict digest mismatch | Proves future `refused` status, diagnostics, report behavior, and no assembly if authorized. |
| Provider nil/non-Hash/exception | Proves fail-open/fail-closed policy. |
| Existing OOF source | Proves semantic OOF still uses current `oof` path. |
| Parser error source | Proves parse failure remains `error`, not PROP-038 refusal. |
| Bad `compiler_profile_source` | Proves assembler/source transport failures remain `assembler_refused`. |
| Runtime smoke failure | Proves post-assembly smoke failure remains separate. |
| Public result shape | Proves which keys are exposed after `public_result`. |
| Refusal sidecar path | Proves whether future strict refusal writes no report, existing report, or distinct report. |
| `.igapp` artifact absence/diff | Proves assembly skipped or artifact unchanged. |
| CLI stdout/stderr/exit | Proves caller-facing behavior, especially non-ok JSON vs preflight stderr. |

---

## Questions For C3-X / C4-A

[Q] Should a future PROP-038 live refusal reuse `CompilerOrchestrator#refusal`,
or is the current mandatory report write incompatible with the desired boundary?

[Q] If live status is `refused`, is that only orchestration/result status, or
does `report["pass_result"]` also gain a new value?

[Q] Should `CompilerResult.refusal` be reused for strict refusal, or should a
new constructor/result shape exist to avoid overloading OOF/error/refusal?

[Q] What should `program_id` be for strict refusal: `semantic_ir_ref`, report
id, compiler profile contract id, or nil?

[Q] Should public diagnostics include a top-level wrapper such as
`compiler_profile_contract_refusal.contract_digest_mismatch`, or should public
results reference nested validation evidence?

[Q] If strict source/provider fails, should the compiler fail open like current
report-only behavior or fail closed as a configuration error/refusal?

[Q] Should future strict refusal write the same `<out>.compilation_report.json`
sidecar, write a distinct PROP-038 report, or return non-persisted evidence?

[Q] Must the assembler continue receiving pre-validation `report_for_assembly`,
or should a future refused compile prevent calling assembler entirely?

[Q] If a CLI strict source is later authorized, should bad source input be CLI
preflight stderr or compiler-result JSON refusal?

---

## Command Matrix

| Command | Purpose | Result |
| --- | --- | --- |
| `rg "def refusal|CompilerResult|compilation_report|public_result|pass_result|report_for_assembly|compiler_profile_contract|contract_digest" igniter-lang/lib igniter-lang/bin` | Discover directly relevant code surfaces. | PASS |
| `rg '"refused"|status: "refused"|status.*refused|\\brefused\\b' igniter-lang/lib igniter-lang/bin` | Confirm current live compiler has no `refused` status. | PASS |
| `sed` / `nl -ba` reads of named files | Read-only source survey. | PASS |

No proof suite was run because this card is a read-only surface survey and does
not change code or generated artifacts.

---

## Handoff

Card: S3-R79-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop038-refusal-report-and-result-surface-survey-v0
Status: done

[D] Decisions

- Current refusal/report/result surfaces were mapped as code facts only.
- No implementation path, live refusal behavior, public widening, or report
  policy was authorized.

[S] Shipped / Signals

- Added this track document with refusal creation points, existing report-write
  behavior, `CompilerResult` surface, CLI behavior, report-only placement,
  coupling risks, and future test candidates.

[T] Tests / Proofs

- Read-only source survey completed with `rg` and targeted file reads.
- No proof suite was run; no code or generated artifacts changed.

[R] Risks / Recommendations

- The main unresolved design tension is whether future strict refusal reuses
  `CompilerOrchestrator#refusal`, since that path always writes a sidecar
  compilation report.
- Any future `refused` status must explicitly define public result shape,
  report persistence, top-level vs nested diagnostics, and assembler skip
  behavior.

[Next] Suggested next slice

- C3-X/C4-A should use this map to choose the strict-source/status/report
  design boundary before any implementation card opens.
