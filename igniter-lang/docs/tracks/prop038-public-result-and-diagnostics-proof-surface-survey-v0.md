# PROP-038 Public Result And Diagnostics Proof Surface Survey v0

Card: S3-R80-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop038-public-result-and-diagnostics-proof-surface-survey-v0
Route: UPDATE
Status: done
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-internal-orchestrator-strict-source-status-decision-v0.md`

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - future strict-refusal result shape and diagnostic exposure design.
- [Igniter-Lang Bridge Agent] - future public API/CLI exposure pressure; no bridge implementation changed.

---

## Scope

Read-only survey of current public result, diagnostics, refusal report, and
proof surfaces needed to validate a future strict-refusal result-shape /
non-persisting path design.

Read:

- `docs/gates/prop038-internal-orchestrator-strict-source-status-decision-v0.md`
- `docs/tracks/prop038-refusal-report-and-result-surface-survey-v0.md`
- `docs/tracks/internal-orchestrator-strict-source-and-status-design-v0.md`
- `lib/igniter_lang/compiler_result.rb`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/compilation_report.rb`
- `lib/igniter_lang/diagnostics.rb`
- `lib/igniter_lang/cli.rb`
- `bin/igc`
- `experiments/prop038_*`
- `experiments/compiler_profile_contract_proof/`
- `experiments/production_compiler_cli/`
- `rg "public_result|Diagnostics\\.errors|Diagnostics\\.warnings|diagnostics|compilation_report_path|report_path|CompilerResult\\.refusal|CompilerResult\\.ok|program_id" igniter-lang/lib igniter-lang/experiments igniter-lang/bin`

No code was edited. This survey does not propose code and does not authorize
implementation.

---

## Current Horizon

R79 accepted only a design route for strict-refusal result shape and a
non-persisting orchestrator path. Live refusal is still closed. Current public
results are shaped by `CompilerResult.public_result`, which only removes the
internal `report` key. Current PROP-038 validation diagnostics remain nested in
the internal report and are not public unless a later design explicitly exposes
them.

---

## Public Result Key-Set Surface Map

### Current Constructor Shapes

`CompilerResult.ok(...)` builds an internal result with:

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

`CompilerResult.refusal(...)` builds an internal result with:

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

`CompilerResult.public_result(result)` does exactly:

```ruby
result.reject { |key, _value| key == "report" }
```

There is no whitelist. Any future top-level result field other than `report`
will become public by default.

### Observed Public CLI Key Sets

From `experiments/production_compiler_cli/production_compiler_cli_summary.json`:

Successful compile public keys:

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
```

Current OOF/refusal public keys:

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
```

Current refusal key implications:

- `compilation_report_path` is public only because the current refusal path
  writes a sidecar report.
- `runtime_smoke` is public only on success shape.
- public results do not include `report`.
- public results do not include `compiler_profile_contract_validation`.
- public results do not include PROP-038 wrapper evidence today.

---

## Diagnostics Exposure Map

### Top-Level Compiler Diagnostics

Current top-level report diagnostics are normalized by `Diagnostics.enrich(...)`
and then split by:

```ruby
Diagnostics.errors(report["diagnostics"])
Diagnostics.warnings(report["diagnostics"])
```

`Diagnostics.errors` returns every diagnostic whose `severity` is not
`"warning"`. `Diagnostics.warnings` returns only `severity == "warning"`.

`CompilerResult.refusal(...)` exposes only those top-level diagnostics and
warnings.

`CompilerResult.ok(...)` exposes:

```text
diagnostics: []
warnings: Diagnostics.warnings(report["diagnostics"])
```

### Nested PROP-038 Validation Diagnostics

Current PROP-038 contract validation is attached only as:

```text
report["compiler_profile_contract_validation"]["diagnostics"]
report["compiler_profile_contract_validation"]["diagnostic_codes"]
```

The placement is created by:

```text
CompilationReport.with_compiler_profile_contract_validation(...)
```

Current isolation facts:

- nested validation diagnostics are not appended to `report["diagnostics"]`;
- nested validation diagnostics are not consumed by `Diagnostics.errors`;
- nested validation diagnostics are hidden from CLI/public result because
  `public_result` removes the entire `report`;
- `.igapp/compilation_report.json` is written from `report_for_assembly`, which
  is captured before PROP-038 annotation, so current `.igapp` reports do not
  include the nested validation field.

### Proof-Local Wrapper Diagnostics

`prop038_strict_mode_refusal_trigger_proof` models wrapper evidence such as:

```text
compiler_profile_contract_refusal.contract_digest_mismatch
```

That wrapper is proof-local only. It is not a live `IgniterLang::Diagnostics`
entry, not a top-level report diagnostic, not public CLI/API output, and not a
`CompilerResult` field.

---

## Report Path / Sidecar Surface

Current sidecar report writes come only from `CompilerOrchestrator#refusal`:

```text
report_path = report_path_for(out_path)
write_json(report_path, report)
```

Current path rule:

```text
OUT.igapp -> OUT.compilation_report.json
OUT       -> OUT.compilation_report.json
```

Current public refusal result exposes:

```text
compilation_report_path
```

Therefore a future non-persisting strict-refusal path must prove at least:

- no sidecar report file is written;
- public result either omits `compilation_report_path` or uses a separately
  accepted non-persisting evidence shape;
- existing OOF/error/assembler/runtime-smoke refusal report behavior remains
  unchanged.

---

## Existing Proof-Anchor Matrix

| Proof / artifact | Current useful anchor | Reuse for future strict-refusal review |
| --- | --- | --- |
| `experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | Validator contract matrix; diagnostic namespace separation; `compile_refusal_authorized=false`. | Baseline contract-validator regression and no-loader/source diagnostic leakage. |
| `experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | Digest shape policy diagnostics; public result unchanged by referenced integration; no refusal report creation from proof. | Shape-policy regression before strict result work. |
| `experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb` | Recompute mismatch/unavailable diagnostics; public result unchanged; no refusal report creation. | Recompute-trigger regression and fail-open baseline. |
| `experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb` | `nested_diagnostics.only`, top-level diagnostics unchanged, `pass_result`/stages unchanged, public result unchanged, no refusal report written. | Strongest anchor for nested diagnostic isolation. |
| `experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | Live orchestrator report-only annotation; invalid contract still status ok; public result unchanged; assembler executes; no refusal report. | Main regression anchor for current live behavior. |
| `experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb` | Proof-local `would_refuse`, wrapper evidence, public result unchanged, top-level diagnostics unchanged, compile refusal false. | Trigger-model anchor before graduating any case to live `refused`. |
| `experiments/production_compiler_cli/production_compiler_cli_proof.rb` | CLI stdout key shape, OOF nonzero exit, report sidecar path, diagnostics category. | Public CLI/API shape and existing refusal report regression. |

Observed proof summary statuses:

```text
compiler_profile_contract_proof                         PASS / 13 cases / 30 checks
prop038_contract_digest_shape_policy_proof              PASS / 8 cases
prop038_contract_digest_recompute_match_proof           PASS / 14 cases
prop038_contract_digest_report_only_integration_proof   PASS / 12 cases
prop038_report_only_compiler_integration                PASS / 5 cases / 20 checks
prop038_strict_mode_refusal_trigger_proof               PASS / 12 cases / 15 checks
```

No proof was rerun for this survey; summaries were read as existing anchors.

---

## Future Assertion Checklist

These are non-authority assertion candidates for a later design/implementation
review.

### Public Key Set

- Existing success public key set remains unchanged.
- Existing OOF/refusal public key set remains unchanged.
- Future strict-refusal public key set is exact and approved.
- `report` remains absent from public results.
- `compiler_profile_contract_validation` remains absent from public results
  unless explicitly approved.
- `compilation_report_path` is absent for a non-persisting strict refusal unless
  a report policy explicitly authorizes it.
- New top-level strict-refusal evidence keys appear only if the design names
  them exactly.

### Nested Diagnostic Isolation

- Report-only invalid digest keeps diagnostics under
  `compiler_profile_contract_validation.diagnostics`.
- Top-level `report["diagnostics"]` remains unchanged for report-only invalid
  digest.
- `Diagnostics.errors` and `Diagnostics.warnings` do not consume nested
  validation diagnostics.
- Public `diagnostics` and `warnings` remain unchanged for report-only invalid
  digest.
- Wrapper evidence, if approved for strict refusal, cites nested diagnostic
  evidence without reusing `compiler_profile_source.*` or loader/report terms.

### Non-Persisting Strict Refusal

- Strict mismatch does not call existing `CompilerOrchestrator#refusal` unless a
  persisted report policy is accepted.
- Strict mismatch writes no `<out>.compilation_report.json` sidecar.
- Strict mismatch writes no `.igapp/`.
- Strict mismatch result does not expose `compilation_report_path` unless
  explicitly authorized.
- Existing OOF/error/assembler/runtime-smoke refusals still write their current
  reports.

### Assembly / Artifact Boundary

- Report-only invalid digest still assembles unchanged.
- Strict allow still assembles unchanged.
- Strict refusal skips `Assembler.assemble_artifacts`.
- `report_for_assembly` behavior remains protected.
- `.igapp` manifest, `compilation_report.json`, and diagnostics artifacts remain
  unchanged for report-only paths.

### CLI / API Shielding

- No new CLI flags or Ruby facade parameters unless explicitly authorized.
- CLI preflight errors remain stderr/no JSON result.
- Compiler non-ok result remains stdout JSON plus nonzero exit.
- Direct API/internal orchestration behavior is separately checked from public
  CLI behavior.

---

## Questions For C3-X / C4-A

[Q] Should future strict-refusal public result include `diagnostics`, a
dedicated wrapper field, both, or neither?

[Q] If the non-persisting path omits `compilation_report_path`, what replaces
the evidence pointer in public/internal result shape?

[Q] Should `program_id` for strict refusal be nil, `semantic_ir_ref`, report id,
or a strict-refusal evidence id?

[Q] Is `CompilerResult.strict_refusal(...)` the intended design shape, or should
future work reuse `CompilerResult.refusal(...)` with a no-write orchestrator
path?

[Q] Does malformed strict requirement become a public result status, a
configuration error, or a non-public/internal failure?

[Q] Should wrapper evidence remain proof-local until implementation, or should
the design now name its exact public/private placement?

[Q] Which proof owns the canonical public key-set assertion:
`prop038_report_only_compiler_integration`, `production_compiler_cli_proof`, or
a future strict-refusal proof?

---

## Command Matrix

| Command | Purpose | Result |
| --- | --- | --- |
| `rg "public_result|Diagnostics\\.errors|Diagnostics\\.warnings|diagnostics|compilation_report_path|report_path|CompilerResult\\.refusal|CompilerResult\\.ok|program_id" igniter-lang/lib igniter-lang/experiments igniter-lang/bin` | Discover public result, diagnostics, report path, and proof surfaces. | PASS |
| `find igniter-lang/experiments -maxdepth 2 -type f -path '*/prop038_*/*.rb' -print` | Identify PROP-038 proof scripts. | PASS |
| `find igniter-lang/experiments -maxdepth 3 -type f -path '*/prop038_*/*summary.json' -print` | Identify PROP-038 summary anchors. | PASS |
| targeted `sed` / `nl -ba` reads | Read-only source and proof surface survey. | PASS |

No proof suite was run because this card is a read-only surface survey and does
not change code or generated artifacts.

---

## Handoff

Card: S3-R80-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop038-public-result-and-diagnostics-proof-surface-survey-v0
Status: done

[D] Decisions

- Public result, diagnostics, refusal report, and proof-anchor surfaces were
  mapped as code/proof facts only.
- No implementation path, live refusal, public widening, `CompilerResult`
  mutation, or persisted report policy was authorized.

[S] Shipped / Signals

- Added this track document with public result key sets, nested diagnostics
  exposure map, sidecar report surface, proof-anchor matrix, and future
  assertion checklist.

[T] Tests / Proofs

- Read-only source/proof survey completed with `rg`, `find`, and targeted file
  reads.
- Existing summaries were read as anchors; proof suites were not rerun.

[R] Risks / Recommendations

- The future design must account for the fact that `public_result` is a deny-one
  filter, not a whitelist.
- The strongest current regression anchors are R67/R71/R77 for public result
  unchanged, nested diagnostics isolation, no refusal report written, and
  proof-local wrapper isolation.

[Next] Suggested next slice

- C3-X/C4-A should choose strict-refusal public/private result placement and
  decide which proof will own exact key-set assertions before implementation
  authorization is considered.
