# PROP-038 Live Refusal Current Pipeline Surface Survey v0

Card: S3-R78-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop038-live-refusal-current-pipeline-surface-survey-v0
Route: UPDATE
Status: done
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-strict-mode-refusal-trigger-proof-local-acceptance-decision-v0.md`

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - future strict/refusal semantics and diagnostic vocabulary.
- [Igniter-Lang Bridge Agent] - future public CLI/API/report exposure pressure; no bridge implementation changed.

---

## Scope

Read-only survey of the current compiler/orchestrator, report, result,
assembler, facade, and CLI surfaces. The goal is to name the real touchpoints a
future live PROP-038 strict refusal design would need to mention, without
proposing implementation code or changing behavior.

Read:

- `docs/gates/prop038-strict-mode-refusal-trigger-proof-local-acceptance-decision-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/tracks/prop038-strict-mode-current-compiler-surface-survey-v0.md`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/compilation_report.rb`
- `lib/igniter_lang/compiler_result.rb`
- `lib/igniter_lang/cli.rb`
- `lib/igniter_lang.rb`
- `lib/igniter_lang/assembler.rb`
- `bin/igc`
- `rg "refusal\\(|pass_result|CompilerResult|compiler_profile_contract|compiler_profile_source|report_for_assembly|public_result" igniter-lang/lib igniter-lang/bin`

No code was edited. No live refusal, public widening, assembler mutation,
loader/report behavior, CompatibilityReport behavior, RuntimeMachine behavior,
or production behavior is authorized by this survey.

---

## Current Horizon

PROP-038 digest validation exists in the live internal validator. The compiler
integration remains report-only: validation is nested into the in-memory
CompilationReport and does not alter `pass_result`, stages, top-level
diagnostics, public result shape, CLI status, assembler input, or `.igapp`
artifacts.

The S3-R77 strict trigger proof is accepted only as proof-local vocabulary:

```text
not_evaluated / allow / would_refuse / configuration_error
```

It does not introduce a live `refused` status or a live compile refusal gate.

---

## Current Live Pipeline Surface Map

```text
IgniterLang.compile(...)
  -> CompilerOrchestrator#compile
     -> Parser / Classifier / TypeChecker / SemanticIREmitter
     -> CompilationReport.enrich(...)
     -> report_for_assembly = report
     -> compiler_profile_contract_provider call, only when pass_result == ok
     -> CompilationReport.with_compiler_profile_contract_validation(...)
     -> refusal(...) only when report["pass_result"] != "ok"
     -> Assembler.assemble_artifacts(report: report_for_assembly, ...)
     -> optional runtime_smoke
     -> CompilerResult.ok(...)
  -> CLI prints CompilerResult.public_result(...)
```

### Current Refusal Creation Points

| Surface | Current trigger | Result |
| --- | --- | --- |
| `CompilerOrchestrator#parse_failure` | parser emits parse errors | writes compilation report; returns status `error` |
| `CompilerOrchestrator#compile` main gate | `report["pass_result"] != "ok"` | writes compilation report; returns status `oof` by default |
| `CompilerOrchestrator#compile` runtime smoke | smoke exists and `trusted=false` | writes compilation report; returns status `runtime_smoke_failed` |
| `rescue AssemblyRefused` | assembler raises `AssemblyRefused` | writes compilation report; returns status `assembler_refused` |
| generic rescue | compiler/internal exception | writes compilation report; returns status `error` |
| `Assembler#assemble_case` / `#assemble_artifacts` | report pass result not ok, bad refs, bad source object, bad SemanticIR | raises `AssemblyRefused`; orchestrator may convert to refusal |

All compiler refusals currently pass through `CompilerOrchestrator#refusal`,
which writes:

```text
<out without .igapp>.compilation_report.json
```

and returns `CompilerResult.refusal(...)`.

### Current Report-Only Validation Insertion Point

`CompilerOrchestrator#compile` calls the provider only after typed emission and
report enrichment, and only when:

```text
report["pass_result"] == "ok"
```

The accepted provider shape remains internal:

```ruby
provider.call(
  source_path: source_path,
  out_path: out_path,
  parsed_program: parsed,
  compiler_profile_source: compiler_profile_source
)
```

Nil/non-Hash provider results and provider/validator exceptions produce no
validation field.

`CompilationReport.with_compiler_profile_contract_validation(...)` adds:

```json
{
  "compiler_profile_contract_validation": {
    "...": "...",
    "report_only": true
  }
}
```

It does not mutate:

- `pass_result`;
- `stages`;
- top-level `diagnostics`;
- `semantic_ir_ref`;
- assembler input;
- public CLI result.

### Current Assembly Boundary

The orchestrator captures:

```ruby
report_for_assembly = report
```

before the report-only validation field is attached. The assembler receives
`report_for_assembly`, not the annotated report.

Therefore the current contract-validation field is in-memory compiler evidence
only. It is not written into `.igapp` manifests, contract files, or assembler
diagnostics by the current path.

The assembler separately validates PROP-036 `compiler_profile_source` transport
and may refuse with `compiler_profile_source.*` reason text. That vocabulary is
not a PROP-038 contract-digest live refusal trigger.

### Current Public Result Shaping

`CompilerResult.ok(...)` and `CompilerResult.refusal(...)` include internal
`"report"` inside the result object returned to the Ruby caller.

`CompilerResult.public_result(result)` removes only:

```text
report
```

The CLI prints the public result. As a consequence, nested
`compiler_profile_contract_validation` is not part of current CLI stdout.

Current refusal public fields derive from top-level report diagnostics. Nested
contract-validation diagnostics do not flow into public refusal diagnostics
because they are not appended to `report["diagnostics"]`.

### Current CLI Exit / Output Behavior

Current CLI command shape:

```text
igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]
```

Current behavior:

- loads `--compiler-profile-source PATH.json` as JSON object when supplied;
- calls `IgniterLang.compile(..., compiler_profile_source: object)`;
- prints `CompilerResult.public_result(orchestration["result"])`;
- exits success only when `orchestration["status"] == "ok"`;
- has no strict-mode flag, compiler-profile-contract path, digest-policy flag,
  or live refusal opt-in.

`bin/igc` is a thin boolean wrapper:

```text
success = IgniterLang::CLI.run(ARGV)
exit(success ? 0 : 1)
```

### Current Ruby Facade

`IgniterLang.compile(...)` exposes:

```text
source_path
out_path
sample_input
sample_input_resolver
runtime_smoke
compiler_profile_source
orchestrator
```

It does not directly expose `compiler_profile_contract_provider`, strict mode,
digest policy, refusal authorization, or public report shaping. Advanced callers
can inject a custom orchestrator, but that is not a public strict-refusal API.

---

## Future Touchpoint Candidates

These are non-authority observations only. They identify likely files a later
implementation decision would need to name explicitly.

| Candidate surface | Why it matters for future live refusal | Current status |
| --- | --- | --- |
| `lib/igniter_lang/compiler_orchestrator.rb` | Central sequencing point: provider call, report annotation, refusal gate, assembler call, report writing. | Must remain report-only until implementation gate. |
| `lib/igniter_lang/compilation_report.rb` | Owns nested validation attachment and top-level report shape helpers. | Must not promote nested diagnostics to top-level without gate. |
| `lib/igniter_lang/compiler_result.rb` | Owns public/internal result shaping and refusal result fields. | Must not expose nested validation or new refusal status without gate. |
| `lib/igniter_lang/cli.rb` | Owns public CLI flags, JSON stdout, preflight failures, and boolean success. | No strict/refusal CLI widening authorized. |
| `bin/igc` | Owns process exit mapping from CLI boolean to shell status. | Thin wrapper; only relevant if CLI success semantics change. |
| `lib/igniter_lang.rb` | Ruby facade boundary for `IgniterLang.compile(...)`. | No strict/provider/digest-refusal facade argument authorized. |
| `lib/igniter_lang/assembler.rb` | Writes `.igapp` artifacts and separately validates `compiler_profile_source`. | Must not receive annotated contract-validation report or mutate artifacts without gate. |
| `lib/igniter_lang/compiler_profile_contract_validator.rb` | Emits live validation diagnostics, including digest diagnostics. | Already live internally; must not decide compile refusal by itself. |
| future proofs/specs | Need to pin strict source, refusal status, diagnostics, and persistence behavior. | New implementation authorization required. |

---

## Must Not Change Without Implementation Gate

- `CompilerOrchestrator#compile` refusal gate based on `report["pass_result"]`.
- `CompilerOrchestrator#refusal` report write path and status vocabulary.
- The position of `report_for_assembly = report`, unless `.igapp` mutation is
  explicitly authorized.
- `CompilationReport.with_compiler_profile_contract_validation` report-only
  nesting behavior.
- Top-level `report["diagnostics"]`, `report["stages"]`, and `pass_result`
  behavior for contract validation.
- `CompilerResult.ok`, `CompilerResult.refusal`, and
  `CompilerResult.public_result`.
- CLI flags, stdout JSON shape, stderr preflight behavior, and exit-code logic.
- Ruby facade parameters for `IgniterLang.compile(...)`.
- Assembler manifest/material/hash fields, contract files, and
  `compiler_profile_source.*` refusal vocabulary.
- Live validator flags such as `compiler_integrated=false` and
  `compile_refusal_authorized=false`.
- Loader/report, CompatibilityReport, RuntimeMachine, Gate 3, Ledger/TBackend,
  BiHistory, stream/OLAP, cache, production durable audit, signing, receipts,
  or dispatch migration surfaces.

---

## Risks And Questions For C3-X / C4-A

[Q] What is the authoritative strict source?

Candidate sources include an orchestrator option, a Ruby facade argument, a CLI
flag, a compiler profile contract field, or a gate-owned policy. The current
pipeline has no live strict source.

[Q] Where should a future refusal be evaluated?

The current report-only annotation happens before the existing `pass_result`
gate but does not alter `pass_result`. A future design must decide whether live
refusal becomes a new gate before assembly, a transformed report, a separate
result status, or a different output contract.

[Q] What is the live status vocabulary?

S3-R77 accepted `would_refuse` only as proof-local model vocabulary. A live
status such as `refused`, `oof`, `error`, or a new status requires an Architect
decision.

[Q] Are contract diagnostics public, nested, or wrapper-only?

Current contract-validation diagnostics remain nested and hidden from CLI
stdout. A future live refusal design must decide whether public results expose a
wrapper diagnostic, nested evidence reference, or top-level diagnostic entry.

[Q] Does a strict refusal write a compilation report?

All current compiler refusals write a `.compilation_report.json`. If PROP-038
strict refusal follows that path, persistence/report shape must be named
explicitly.

[Q] Does strict mode fail closed for provider nil/non-Hash/error?

Current report-only behavior fails open by producing no validation field. A live
strict mode may need different behavior, but it must not be inferred from the
current provider path.

[Q] Does `contract_digest_recompute_unavailable` stay fail-open?

The proof-local trigger accepts fail-open report-only behavior. Any live strict
change requires a separate decision.

[Q] Should assembly remain fed by pre-validation `report_for_assembly`?

Current behavior keeps `.igapp` output unchanged by report-only validation. If a
future strict refusal blocks before assembly, this may stay true. If future
artifacts need validation evidence, that is a separate assembler/artifact
authorization.

---

## Command Matrix

| Command | Purpose | Result |
| --- | --- | --- |
| `rg "refusal\\(|pass_result|CompilerResult|compiler_profile_contract|compiler_profile_source|report_for_assembly|public_result" igniter-lang/lib igniter-lang/bin` | Identify current live compiler/refusal/report/profile-source surfaces. | PASS |
| `sed` / `nl -ba` reads of named files | Read-only source survey. | PASS |

No proof suite was run because this card is a read-only surface survey and does
not change code or generated artifacts.

---

## Recommendation

[R] Future live-refusal work should start with an Architect implementation-gate
decision that names:

- strict source/input shape;
- exact refusal status and public diagnostic shape;
- whether refusal writes a compilation report;
- whether nested contract-validation diagnostics remain nested or gain a public
  wrapper;
- whether assembly is skipped before `.igapp` creation;
- exact allowed write scope across orchestrator/report/result/CLI/facade.

[R] Until that decision lands, current report-only behavior should be treated as
closed: digest diagnostics may exist in the internal nested report field, but
they do not imply live refusal, CLI/API exposure, assembler mutation, or
CompatibilityReport/runtime readiness.

---

## Handoff

Card: S3-R78-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop038-live-refusal-current-pipeline-surface-survey-v0
Status: done

[D] Decisions

- Current live pipeline surfaces were mapped read-only.
- No implementation path, live refusal behavior, or public surface widening was
  authorized.

[S] Shipped / Signals

- Added this track document with refusal creation points, report-only insertion,
  assembly boundary, public result shaping, CLI behavior, future touchpoints,
  and protected-surface list.

[T] Tests / Proofs

- Read-only source survey completed with `rg` and targeted file reads.
- No proof suite was run; no code or generated artifacts changed.

[R] Risks / Recommendations

- Future live refusal needs an explicit Architect gate naming strict source,
  status vocabulary, report persistence, diagnostic exposure, and write scope.
- Do not infer strict mode from nested `compiler_profile_contract_validation`,
  `valid=false`, digest diagnostics, provider presence, or CLI
  `--compiler-profile-source`.

[Next] Suggested next slice

- C3-X/C4-A should decide whether to authorize a design-only live-refusal
  implementation boundary, with exact write scope and non-authorizations.
