# Counterfactual Audit Report API Exposure Facts Packet v0

Card: S3-R221-C2-P1
Skill: IDD Agent Protocol
Agent: Research Agent #1
Role: research-agent
Track: counterfactual-audit-report-api-exposure-facts-packet-v0
Route: UPDATE
Depends on: S3-R220-C4-A
Status: complete
Date: 2026-05-31

## IDD Classification

Mode: standard, compact facts packet.

Contract:

- collect current report/result/API exposure facts around Option B/C
  counterfactual audit evidence;
- separate evidence from authority;
- do not decide the next route;
- do not authorize implementation, field changes, public claims, or support
  wording.

Authority rule:

```text
result/report/API exposure is not proof authority
proof-owned evidence is not public/runtime/report support
```

## Inputs Read

- `stage3-round220-status-curation-v0.md`
- `counterfactual-audit-runtime-bridge-architecture-decision-v0.md`
- `counterfactual-audit-runtime-bridge-authority-facts-packet-v0.md`
- `counterfactual-audit-runtime-report-api-gate-survey-v0.md`
- `counterfactual-audit-report-api-boundary-survey-v0.md`
- `lib/igniter_lang/compiler_result.rb`
- `lib/igniter_lang/compilation_report.rb`
- `lib/igniter_lang/runtime_smoke.rb`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang.rb`
- `lib/igniter_lang/cli.rb`
- `bin/igc`

## Fixed Current State

R220 accepted:

- Runtime/Bridge architecture survey;
- Runtime/Bridge authority facts packet as current facts basis;
- report/API boundary survey may open next as read-only/design-only;
- Option D remains held;
- runtime/evaluator implementation remains closed;
- RuntimeSmoke remains proof-context only;
- `CompilerResult` and `CompilationReport` remain closed;
- dependency/cache, public/Spark/API/release, and production authority remain
  closed.

R221 C1-D survey exists and records report/API boundary facts. This C2 packet
does not accept or amend that survey. It extracts exact current exposure facts
for C3-X and C4-A.

## Surface Exposure Table

| Surface | Current exposure | Leakage risk | Closed status |
| --- | --- | --- | --- |
| `CompilerResult.ok` | Internal success result includes `kind`, `format_version`, `status`, `program_id`, `source_path`, `source_hash`, `grammar_version`, `stages`, `igapp_path`, `compilation_report_ref`, `semantic_ir_ref`, `contracts`, empty `diagnostics`, `warnings`, `runtime_smoke`, and private `report`. | New Option B/C fields would be positive result keys; `runtime_smoke` can carry proof output. | Closed to counterfactual fields and Option B/C payloads. |
| `CompilerResult.refusal` | Refusal result includes status, source metadata, `stages`, `igapp_path: nil`, `contracts: []`, `compilation_report_path`, diagnostics, warnings, and private `report`. | Projected failure could become persisted refusal/report evidence. | Closed to projected value/failure diagnostics. |
| `CompilerResult.strict_terminal` | Strict terminal result includes status, source metadata, `compilation_report_path: nil`, diagnostics, warnings, and private `report`. | PROP-038 terminal shape could be copied as counterfactual terminal authority. | PROP-038-only; no counterfactual authority. |
| `CompilerResult.public_result` | Removes only the `report` key from any result hash. | Any new top-level key becomes public/API/CLI-visible by default. | High-risk exposure point; no positive counterfactual fields. |
| `CompilationReport.parse_failure` | Report includes parse error stages, diagnostics, source metadata, and `semantic_ir_ref: nil`. | Counterfactual source evidence could be confused with parser/report diagnostics if inserted. | Closed to counterfactual data. |
| `CompilationReport.runtime_smoke_failure` | Merges `pass_result: error`, source path, and runtime-smoke diagnostics into an existing report. | `projected_failure` could be misclassified as actual runtime smoke failure. | Closed to projection failures and values. |
| `CompilationReport.internal_error` | Emits internal error report with diagnostics and unknown stages. | Projection engine failures could be promoted to compiler internal errors. | No counterfactual engine/report integration. |
| `CompilationReport.with_compiler_profile_contract_validation` | Adds nested `compiler_profile_contract_validation` with `report_only: true`. | Report-only precedent could tempt nested counterfactual report fields. | PROP-038-only precedent; not Option B/C authority. |
| `RuntimeSmoke.run` | Returns `load_status`, `contract_id`, `evaluate_status`, `outputs`, `compatibility_report_status`, and `trusted`, or blocked/error/trusted false. | Outputs and compatibility status can look like runtime/readiness support. | Proof-context only; no Option B/C projection payload. |
| `RuntimeSmoke.callback` | Produces a lambda accepted by `CompilerOrchestrator.compile(runtime_smoke:)`. | Callback can make proof evidence affect compile result or diagnostics. | No counterfactual callback route. |
| `CompilerOrchestrator.compile` | Calls optional runtime smoke after assembly; puts trusted smoke into `CompilerResult.ok`; failed smoke becomes `runtime_smoke_failed` refusal report. | Option B/C could be promoted via smoke into public result or persisted report. | Closed to Option B/C report/result paths. |
| Orchestrator ordinary refusal | Writes `*.compilation_report.json` sidecar for refusal. | Counterfactual projected failure could create sidecar persistence. | No counterfactual refusal report creation. |
| Orchestrator strict terminal | Returns `refused` or `configuration_error` without report path for PROP-038 strict digest cases. | Could be mistaken as accepted non-persisting counterfactual result model. | PROP-038-only; no counterfactual strict path. |
| `IgniterLang.compile` facade | Public Ruby-facing facade exposes `runtime_smoke:` callback and returns orchestrator result. | Caller-visible result could include new fields if added later. | No counterfactual API surface. |
| `IgniterLang::CLI.run` | `igc compile` prints `CompilerResult.public_result(orchestration["result"])` as JSON and exits success only when orchestration status is `ok`. | CLI directly exposes any new public-result key. | No counterfactual CLI flags, fields, or output. |
| `bin/igc` | Thin executable requiring `igniter_lang/cli`; exits `0/1` from CLI boolean. | Public executable could make accidental fields release-facing. | No counterfactual command or release claim. |
| CompatibilityReport | No current counterfactual lane report; RuntimeSmoke has `compatibility_report_status` string from proof resume. | Compatibility/readiness vocabulary could overstate projection evidence. | Closed to Option B/C. |
| Receipt/result sidecars | No current counterfactual sidecar in this lane. Ordinary refusal writes compilation report sidecar. | Sidecars imply persistence/report authority. | Closed. |
| Option C docs/status | Internal discoverability aid only. | Repetition can become pseudo-public or pseudo-canon. | Internal only; public docs/body spec remain closed. |

## Exact Current Result Shapes

`CompilerResult.ok` currently exposes these keys before `public_result`:

```text
kind
format_version
status
program_id
source_path
source_hash
grammar_version
stages
igapp_path
compilation_report_ref
semantic_ir_ref
contracts
diagnostics
warnings
runtime_smoke
report
```

After `public_result`, the only removed key is:

```text
report
```

Therefore `runtime_smoke` and any future top-level field are public-result
visible.

`CompilerResult.refusal` currently exposes:

```text
kind
format_version
status
program_id
source_path
source_hash
grammar_version
stages
igapp_path
contracts
compilation_report_path
diagnostics
warnings
report
```

After `public_result`, `compilation_report_path`, diagnostics, warnings, status,
and source metadata remain visible.

`CompilerResult.strict_terminal` currently exposes the same general public
surface as refusal, except:

```text
compilation_report_path: nil
```

The strict-terminal shape is tied to PROP-038 compiler-profile contract digest
behavior and is not counterfactual authority.

## Exact Current Report Shapes

`CompilationReport.parse_failure` currently creates:

- `kind: compilation_report`;
- `format_version`;
- `program_id: compilation_report/parse_error`;
- grammar/source fields;
- `pass_result: error`;
- `stages` with parse error and later stages skipped;
- parse diagnostics;
- `semantic_ir_ref: nil`.

`CompilationReport.runtime_smoke_failure` currently:

- preserves the incoming report;
- changes `pass_result` to `error`;
- sets source path;
- appends `Diagnostics.from_runtime_smoke(smoke)`.

`CompilationReport.internal_error` currently creates:

- `program_id: compilation_report/<rule>`;
- unknown stage statuses;
- internal error diagnostics.

`CompilationReport.with_compiler_profile_contract_validation` currently adds
nested validation data only when validation exists, with:

```text
compiler_profile_contract_validation.report_only: true
```

There is no counterfactual/projection report field in these shapes.

## RuntimeSmoke Exposure Facts

`RuntimeSmoke.run` success output currently includes:

```text
load_status
contract_id
evaluate_status
outputs
compatibility_report_status
trusted
```

Blocked output currently includes:

```text
load_status: blocked
error
trusted: false
```

Facts:

- RuntimeSmoke directly requires the proof RuntimeMachine compiled-program
  experiment.
- RuntimeSmoke is proof-backed and proof-context only.
- `RuntimeSmoke.callback` is a lambda that can be passed to
  `IgniterLang.compile` / `CompilerOrchestrator.compile`.
- Trusted smoke appears in `CompilerResult.ok.runtime_smoke`.
- Untrusted smoke becomes `CompilationReport.runtime_smoke_failure` and then an
  ordinary refusal report.

Risk:

- RuntimeSmoke is the highest-risk accidental carrier because it has both a
  public success-result slot and a failure-diagnostic path.

## Orchestrator Embedding Facts

Current sequence:

```text
parse
classify
typecheck
emit_typed
CompilationReport.enrich
optional compiler_profile_contract_validation
ordinary refusal if pass_result != ok
optional strict_terminal
assembler
optional runtime_smoke callback
CompilerResult.ok or runtime_smoke_failed refusal
```

Key facts:

- `report_for_assembly` is captured before compiler-profile contract validation
  is added, preserving assembler/report isolation for that path.
- Ordinary refusal writes a compilation report sidecar.
- Strict terminal returns a result with `compilation_report_path: nil`.
- Runtime smoke runs after assembly.
- Runtime smoke failure creates a `runtime_smoke_failed` refusal and report.

Counterfactual implication:

- Any future Option B/C callback, provider, report field, or result key would
  need a separate authority gate. None exists here.

## Public API / CLI Exposure Facts

Ruby facade:

```text
IgniterLang.compile(...)
```

Current relevant parameters:

```text
runtime_smoke:
compiler_profile_source:
orchestrator:
```

Current facts:

- The facade returns the orchestrator result hash.
- No counterfactual parameter exists.
- A caller can pass a runtime smoke callback, but current accepted authority
  keeps RuntimeSmoke proof-context only.

CLI:

```text
igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]
```

Current facts:

- CLI loads optional compiler profile source JSON.
- CLI calls `IgniterLang.compile`.
- CLI prints `CompilerResult.public_result(...)` as JSON.
- CLI exits `0` only if orchestration status is `ok`.
- No counterfactual flag, Option B path, Option D carrier, report/API field, or
  dry-run command exists.

Exposure risk:

- Because CLI prints `public_result`, any future public-result key would become
  CLI-visible unless fenced first.

## CompatibilityReport / Sidecar / Receipt Facts

Current facts in this lane:

- No counterfactual `CompatibilityReport` object exists.
- RuntimeSmoke output includes a string key named `compatibility_report_status`
  from proof RuntimeMachine resume status.
- No counterfactual receipt/result sidecar exists.
- Ordinary compiler refusal writes a compilation report sidecar.
- Proof RuntimeMachine observations and receipts exist under experiments, not
  as production/report authority.

Risk:

- Compatibility/readiness words and receipt-like proof packets can be confused
  with accepted readiness or durable audit. Current facts keep these closed for
  Option B/C.

## Docs / Status Exposure Facts

Current facts:

- Option C docs/status index is accepted as internal discoverability aid only.
- R220 current-status curation records Option B/C authority posture and closed
  surfaces.
- Public docs, body spec, PROP-032, release notes, Spark docs, and public
  support claims remain closed.

Risk:

- Internal status phrasing can become pseudo-public if copied into public docs
  without a separate gate.

## Exposure Hotspots

| Hotspot | Why it is risky | Fact to preserve |
| --- | --- | --- |
| `CompilerResult.public_result` | Deny-one filtering exposes all new keys except `report`. | No counterfactual result fields. |
| `CompilerResult.ok.runtime_smoke` | Success output can carry arbitrary smoke hash. | RuntimeSmoke is proof-context only and not an Option B/C carrier. |
| `CompilationReport.runtime_smoke_failure` | Converts smoke failure into diagnostics and refusal report. | `projected_failure != actual_runtime_failure`. |
| Ordinary refusal report path | Writes persisted `*.compilation_report.json`. | No counterfactual refusal report creation. |
| Strict terminal precedent | Has non-persisting result shape. | PROP-038-only; not counterfactual model authority. |
| CLI JSON output | Prints public result directly. | No public counterfactual CLI output. |
| Compatibility wording | Looks like readiness. | No Option B/C CompatibilityReport authority. |
| Option C docs/status | Can become canon by repetition. | Internal discoverability only. |

## Closed Surfaces

Remain closed:

- code implementation and `lib/**` changes;
- `CompilerResult` fields;
- `CompilationReport` fields;
- Diagnostics namespace changes;
- RuntimeSmoke behavior/result shape;
- CompilerOrchestrator callback behavior;
- public API/CLI flags or output shape;
- CompatibilityReport metadata;
- receipt/result sidecars;
- report/result/API field design;
- Option D carrier design or implementation;
- runtime/evaluator behavior;
- proof RuntimeMachine production use;
- dependency/cache authority;
- TBackend/effect/external IO non-refusal;
- compiler-emitted artifact authority;
- public docs/body spec/PROP-032 support claims;
- Spark authority or integration;
- release evidence, release execution, publish, tag, push, deploy;
- production behavior.

## Exact Facts Handoff For C3-X

C3-X should pressure these facts:

- Whether the current key lists for `CompilerResult.ok`, `refusal`,
  `strict_terminal`, and `public_result` are complete enough.
- Whether CLI exposure is correctly identified as `CompilerResult.public_result`
  printed as JSON.
- Whether RuntimeSmoke is correctly described as both public success payload
  risk and failure-diagnostic risk.
- Whether `CompilationReport.runtime_smoke_failure` is correctly fenced from
  `projected_failure`.
- Whether CompatibilityReport and receipt/result sidecars are accurately listed
  as absent/closed for this lane.
- Whether docs/status pseudo-public drift is sufficiently fenced.

This packet is not an implementation proposal.

## Exact Facts Handoff For C4-A

C4-A can use this packet as exposure facts only:

- current `CompilerResult.public_result` is deny-one and CLI-visible;
- current success results expose `runtime_smoke`;
- current smoke failure path writes ordinary refusal reports;
- no counterfactual report, result, receipt, CompatibilityReport, API, CLI, or
  sidecar surface exists;
- Option C docs/status is internal-only discoverability;
- public docs/body spec/release/Spark claims remain closed.

Held risk note:

```text
Any future positive counterfactual field must first address public key-set,
CLI visibility, RuntimeSmoke carrier risk, diagnostics/report persistence, and
non-actual projected value/failure wording.
```

## Command Matrix

| Command / read | Result |
| --- | --- |
| `git status --short` | PASS; workspace was clean before this packet. |
| `rg -n "counterfactual-audit.*report..." igniter-lang/docs/tracks -g "*.md"` | PASS; located R220/R221 inputs. |
| `sed -n` read of R220 status, Runtime/Bridge decision, Runtime/Bridge facts packet, runtime/report/API gate survey | PASS. |
| `sed -n` read of R221 report/API boundary survey | PASS; used as context, not authority change. |
| `sed -n` read of `compiler_result.rb`, `compilation_report.rb`, `runtime_smoke.rb`, `compiler_orchestrator.rb` | PASS. |
| `sed -n` read of `lib/igniter_lang.rb`, `lib/igniter_lang/cli.rb`, and `bin/igc` | PASS. |
| `rg -n "CompatibilityReport|compatibility_report|receipt|sidecar..." igniter-lang/lib igniter-lang/docs/tracks ...` | PASS; current lane sidecar/report risks mapped. |

No executable proof was required or run. No code/runtime/report/API/public
surface was changed.

## Compact Handoff

[D] This packet records current report/result/API exposure facts only. It does
not decide the next route.

[S] The highest exposure facts are: `CompilerResult.public_result` strips only
`report`, CLI prints that public result, and RuntimeSmoke can enter both success
payload and failure-diagnostic paths.

[T] No counterfactual report/result/API/receipt/CompatibilityReport/CLI surface
currently exists in this lane.

[R] For C3-X/C4-A: pressure public key-set, CLI visibility, RuntimeSmoke carrier
risk, and report persistence before any future positive field or sidecar route.

[Next] C3-X can pressure this facts packet; C4-A can decide whether to accept it
as the report/API exposure facts basis.
