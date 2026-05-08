# Runtime Smoke Extraction v0

Card: S2-R12-C1-P
Role: `[Igniter-Lang Research Agent]`
Track: `runtime-smoke-extraction-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R11-C1-P`

## Goal

Move proof-local CLI runtime smoke toward a reusable
`IgniterLang::RuntimeSmoke` boundary while keeping smoke optional.

This slice is behavior-preserving. It does not expand production
RuntimeMachine behavior.

## Current Horizon

Before this slice, the production compiler CLI owned runtime smoke directly:

```text
ProductionCompilerCLI::RuntimeSmoke
```

That module loaded the assembled `.igapp`, evaluated Add with `19 + 23`, and
returned the `runtime_smoke` hash used in `CompilerResult`.

The packageable API already accepted an optional runtime smoke callback:

```ruby
IgniterLang.compile(..., runtime_smoke: callback)
```

but no reusable smoke callback existed outside the CLI experiment.

## New Boundary

New file:

```text
igniter-lang/lib/igniter_lang/runtime_smoke.rb
```

Public API:

```ruby
require "igniter_lang/runtime_smoke"

smoke = IgniterLang::RuntimeSmoke.run(
  out_path: "path/to/app.igapp",
  sample_input: { "a" => 2, "b" => 3 }
)

callback = IgniterLang::RuntimeSmoke.callback
```

Output shape is unchanged:

```text
load_status
contract_id
evaluate_status
outputs
compatibility_report_status
trusted
```

Blocked output remains:

```text
load_status: blocked
error
trusted: false
```

## Optional Smoke

`IgniterLang.compile` remains smoke-optional:

```ruby
IgniterLang.compile(source_path:, out_path:, runtime_smoke: nil)
```

The production CLI now passes:

```ruby
runtime_smoke: IgniterLang::RuntimeSmoke.callback
```

This keeps CLI behavior stable while allowing API consumers to compile without
loading proof-local RuntimeMachine code.

## Proof-Backed Status

`IgniterLang::RuntimeSmoke` still requires the proof-local runtime loader:

```text
experiments/runtime_machine_memory_proof/compiled_program.rb
```

That is intentional for this card. The boundary is reusable, but not yet a
production RuntimeMachine adapter. Production TBackend selection remains a
future package/runtime slice.

## Decisions

[D] Extracted CLI smoke into `IgniterLang::RuntimeSmoke`.

[D] Preserved the CLI `runtime_smoke` output shape exactly.

[D] Added `IgniterLang::RuntimeSmoke.callback` so the existing
`CompilerOrchestrator` / `IgniterLang.compile` callback contract remains
unchanged.

[D] Did not require `runtime_smoke` from top-level `igniter_lang.rb`; consumers
must opt in with `require "igniter_lang/runtime_smoke"`.

[D] Did not extract or alter `RuntimeMachineMemoryProof::CompiledProgram` or the
RuntimeMachine proof internals.

## Proof Output

Runtime smoke library check:

```text
true
2026-05-05T10:42:00Z
```

Production compiler CLI:

```text
PASS production_compiler_cli_proof
compile.add_exit_zero: ok
compile.add_writes_igapp: ok
compile.add_stdout_shape: ok
runtime.load_output_trusted: ok
runtime.evaluate_add_42: ok
compile.oof_exit_nonzero: ok
compile.oof_writes_report: ok
compile.oof_writes_no_igapp: ok
compile.oof_uses_igapp_path: ok
compile.oof_diagnostics_have_category: ok
compile.oof_stages_and_warnings: ok
package_boundary.direct_api_compile_ok: ok
package_boundary.cli_and_api_same_facade_shape: ok
package_boundary.lib_load_path_facade: ok
positive.sum: 42
direct_api.status: ok
load_path.stdout: compile=true
orchestrator=constant
negative.category: classifier_oof
```

Assembler proof:

```text
PASS igapp_assembler_proof
runtime.load_direct_prop0191: ok
runtime.evaluate_assembled_add: ok
runtime.evaluate_assembled_claim_evidence: ok
runtime.evaluate_assembled_evidence_linked_alert: ok
runtime.compatibility_report_trusted: ok
```

Stage 1 regression:

```text
PASS stage1_close_candidate
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
summary: igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.json
```

## Remaining Gaps

[R] Runtime smoke still depends on proof-local RuntimeMachine code.

[R] Smoke input policy is still synthetic/sample-input based. Generic compile
should stay smoke-free unless a caller supplies a runtime smoke callback.

[R] Production TBackend adapter selection is still not part of the compiler
package boundary.

## Next Delta

[Next] `compiler-package-boundary-v0`:

```text
require "igniter_lang"
IgniterLang.compile(...)
igniter-lang compile SOURCE --out OUT.igapp
```

Prove Ruby API and CLI entrypoint share the same facade/load-path expectations.

[Next] `runtime-smoke-production-adapter-plan-v0`:

```text
IgniterLang::RuntimeSmoke
  -> proof-backed now
  -> production RuntimeMachine/TBackend adapter later
```

Keep adapter selection separate from the compiler package facade.

## Neighbor Notes

[Q] Compiler/Grammar Expert: No parser/typechecker/SemanticIR behavior changed.

[Q] Bridge Agent: Runtime smoke is now reusable but still proof-backed. Bridge
integration should treat it as an opt-in check, not the production runtime
adapter.
