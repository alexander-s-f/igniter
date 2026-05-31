# Delegated Experimental Runtime Current Surface Facts v0

Card: S3-R224-C2-P1
Skill: IDD Agent Protocol
Agent: Research Agent #1
Role: research-agent
Track: delegated-experimental-runtime-current-surface-facts-v0
Route: UPDATE
Status: facts-only
Date: 2026-05-31

Depends on:
- S3-R223-C5-S

---

## IDD Boundary

Smallest useful artifact: compact facts packet for the delegated experimental
runtime surface after R223.

This packet does not decide the route, authorize implementation, extract a
helper, package a runtime, design CLI `run`, create Reference Runtime support,
or promote example evidence into public/stable/production authority.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round223-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-v0.md`
- `igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb`
- `igniter-lang/examples/experimental_executable_quickstart_v0/add_quickstart.ig`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/quickstart_result.json`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/assembler.rb`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`
- `igniter-lang/lib/igniter_lang/compilation_report.rb`
- `igniter-lang/lib/igniter_lang.rb`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb`
- `igniter-lang/docs/current-status.md`

---

## Current Fixed Point

R223 accepted this executable path:

```text
.ig source -> compile -> .igapp -> delegated experimental runtime -> sum = 42
```

Accepted constraints remain binding:

- delegated experimental runtime evidence only;
- non-canonical example-local runtime-learning evidence only;
- no Reference Runtime support;
- no public runtime support;
- no production runtime support;
- no stable API, public demo, Spark, release, or v1 claim.

---

## Current Quickstart Runtime Call Path

The quickstart path is:

1. `quickstart.rb` requires the root compiler facade from
   `igniter-lang/lib/igniter_lang`.
2. `quickstart.rb` direct-requires
   `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program`.
3. `IgniterLang.compile(source_path:, out_path:)` compiles
   `add_quickstart.ig` to `out/Add.igapp`.
4. `RuntimeMachineMemoryProof::CompiledProgram.load_igapp(IGAPP_DIR)` loads the
   emitted `.igapp`.
5. `program.validate!` validates the proof RuntimeMachine artifact view.
6. `program.evaluate_contract("Add", { a: 19, b: 23 })` returns
   `{ "sum" => 42 }`.
7. `quickstart.rb` writes
   `out/quickstart_result.json`.

The quickstart does not pass `runtime_smoke:` into `IgniterLang.compile`.
`RuntimeSmoke` is read-only context here, not the accepted execution surface.

---

## Surface / Risk Table

| Surface | Current fact | Extraction risk | Packaging risk |
| --- | --- | --- | --- |
| `add_quickstart.ig` | CORE-only Add source fixture; explicitly not temporal/TBackend, counterfactual, profile-discovery, or public-demo pressure. | Low for examples; higher if generalized because it proves one monomorphic CORE path only. | Should not become all-grammar or runtime support evidence in package docs. |
| `quickstart.rb` | Example-local executable harness; owns compile, direct proof runtime load, eval, checks, and result packet. | High if lifted wholesale: mixes docs wording, checks, fallback adapter, output writing, and execution path. | Not included by gemspec; packaging would require explicit file inclusion and public wording review. |
| Root `IgniterLang.compile` facade | Stable callable compiler facade for compile path; accepts optional `runtime_smoke:` callback and `compiler_profile_source:`. | Helper extraction could safely reuse compile, but must not alter facade shape. | Package already exposes compile; runtime execution is not exposed by this facade. |
| `CompilerOrchestrator` | Parser -> classifier -> typechecker -> emit_typed -> assembler; optional runtime_smoke callback runs after assembly. | Extraction must avoid conflating delegated runtime with `runtime_smoke` callback or compile success. | Packaging a runtime helper through orchestrator would change public result/report expectations. |
| `Assembler` | Emits `.igapp` with `semantic_ir_program.json`, contract files, manifest, report, diagnostics, requirements, projections, compatibility metadata. | Helper may depend on assembler artifact shape; future assembler changes could break example runtime. | Packaging execution against `.igapp` would imply a runtime artifact contract not yet authorized. |
| Proof `CompiledProgram` | Experiment-owned loader/evaluator for `.igapp`; loads `semantic_ir_program.json` directly and evaluates Add. | Core dependency for current execution; extraction would need ownership, API, tests, and non-reference wording. | Not under `lib/`; not packaged by gemspec; packaging would promote experiment code unless explicitly redesigned. |
| Proof `RuntimeMachine` | Experiment-owned memory runtime, observations, MemoryTBackend, and evaluator behavior. | Large extraction risk: carries temporal, observation, backend, stdlib, and if_expr proof history. | Packaging would look like runtime support unless fenced very carefully. |
| `RuntimeSmoke` | Lib module is proof-backed and requires the proof RuntimeMachine; returns load/evaluate/checkpoint/resume smoke hash. | Reuse risks productizing proof-context smoke; R223 quickstart did not use it. | Already in `lib/`, but current accepted wording says not productized/public runtime support. |
| Example adapter/normalizer | Source-local fallback exists in `quickstart.rb`; accepted result says `adapter_used: false`. | Unproven fallback: the successful run did not exercise it, so extraction needs a dedicated negative/mismatch fixture first. | Packaging an unexercised normalizer would create hidden compatibility behavior. |
| `quickstart_result.json` | Example-local output; `kind`, `format_version`, card/track/authorization, `overall`, EXQ checks, disclaimer, pipeline, execution evidence, three-runtime distinction. | Good as facts/output model, not as stable schema. | Must not become package API, receipt, report, CompatibilityReport, or public runtime result. |
| Output home | `examples/experimental_executable_quickstart_v0/out/` contains `.igapp` and result JSON. | Helper extraction needs a new artifact-home decision. | Package smoke must use temp output, not mutate examples/goldens. |
| `CompilerResult` | Public result filters only `report`; success includes `runtime_smoke` when supplied. | Helper extraction should avoid adding delegated runtime data to compiler result. | Package/runtime exposure would need public key-set and diagnostics review. |
| `CompilationReport` | Runtime smoke failures can enrich diagnostics, but quickstart does not use this path. | Delegated runtime failures must not reuse report authority without a gate. | Packaging must avoid report sidecars or refusal semantics unless authorized. |
| CLI `igc compile` | Compile-only command; supports `--compiler-profile-source PATH.json`. No `run` command. | Helper extraction must not imply CLI run. | Future CLI `run` would require command design, output schema, exit codes, no-claim wording, and installed-package smoke. |
| Gem package | `igniter_lang.gemspec` includes `lib/**/*.rb`, `bin/igc`, README, release notes. Examples and experiments are not packaged. | Helper under examples/experiments remains non-package. Helper under lib would be a new package surface. | Packaging delegated runtime requires explicit inclusion and public/non-claim boundary. |

---

## What Can Be Reused

- Compile path: `IgniterLang.compile(source_path:, out_path:)`.
- CORE Add source shape as an example-local fixture.
- `.igapp` direct load fact through proof `CompiledProgram`.
- Result-packet disclaimer vocabulary as a non-claim pattern.
- R223 EXQ checks as a future regression checklist.

Reusable does not mean package-ready.

---

## Example-Local Only

- `quickstart.rb` orchestration.
- `out/Add.igapp`.
- `out/quickstart_result.json`.
- Direct require of `experiments/runtime_machine_memory_proof/compiled_program`.
- Example-local adapter/normalizer fallback.
- EXQ result schema and check matrix.

---

## Adapter / Normalizer Facts

Presence:

```text
present in quickstart.rb as example-local fallback
```

Accepted run:

```text
adapter_used: false
adapter_note: null
load_status: loaded
```

Fact:

```text
The emitted `.igapp` loaded directly. The adapter/normalizer branch is not
executed by the accepted R223 output and should not be treated as proven
reusable behavior.
```

---

## Result JSON Shape Facts

`quickstart_result.json` contains:

- `kind: experimental_executable_quickstart_v0_result`
- `format_version: 0.1.0`
- card / track / authorization metadata;
- `overall`, check counts, failed checks;
- `disclaimer` flags;
- `pipeline` fields for source, compile status, `.igapp` path, load status,
  adapter status, and execution status;
- `execution_evidence` with sample input, expected sum, actual sum, output
  match, and execution result;
- `three_runtime_distinction`;
- EXQ proof matrix and individual checks.

Important non-authority fact:

```text
This is an example result packet, not CompilerResult, CompilationReport,
CompatibilityReport, receipt, report sidecar, cache record, or public runtime
API.
```

---

## Helper Extraction Change Surface

A reusable helper extraction would have to name and test:

- helper home: `examples/`, `experiments/`, or `lib/`;
- direct require stance for proof RuntimeMachine;
- whether fallback adapter/normalizer is included or deleted;
- result packet schema ownership;
- output directory policy;
- failure/HOLD behavior;
- disclaimer/no-claim wording;
- regression anchors for `CompilerResult`, `CompilationReport`, `RuntimeSmoke`,
  CLI, gemspec, README, and examples.

Likely blockers:

- proof RuntimeMachine lives under `experiments/`;
- `RuntimeSmoke` already exists but is explicitly not the R223 quickstart
  execution surface;
- adapter fallback is not behaviorally proven by R223;
- no artifact-home decision for reusable outputs;
- no public result/report/receipt policy;
- no package inclusion policy.

---

## Package Extraction Change Surface

Packaging the delegated runtime would affect or require review of:

- `igniter-lang/igniter_lang.gemspec`;
- `igniter-lang/lib/igniter_lang.rb` root require posture;
- whether proof RuntimeMachine code may move under `lib/`;
- whether `RuntimeSmoke` is still proof-context only;
- public docs wording;
- installed-package smoke matrix;
- stable API/pre-v1 disclaimer placement;
- release non-claims.

Current package fact:

```text
Examples and experiments are not included by the gemspec.
```

---

## Future CLI `run` Change Surface

CLI `run` is not present today.

If a later card designs CLI `run`, it would need facts or decisions for:

- command shape;
- input artifact path policy;
- sample input format;
- output JSON schema;
- exit-code semantics;
- refusal versus HOLD versus runtime error vocabulary;
- temp output and mutation policy;
- whether to depend on proof RuntimeMachine, RuntimeSmoke, or a new helper;
- no-claim wording for installed package users;
- release readiness smoke scope.

This packet does not authorize that design.

---

## Current No-Claim Wording Coverage

Covered by R223 docs, quickstart comments, and result JSON:

- experimental;
- pre-v1;
- no stable API guarantee;
- subject to change;
- not production runtime;
- not Reference Runtime;
- not public demo;
- not Spark integration;
- delegated experimental runtime;
- non-canonical runtime harness.

Still risky if generalized:

- "runtime support";
- "public runtime";
- "Reference Runtime";
- "production-ready";
- "all grammar";
- "stable API";
- "release evidence".

---

## Exact Facts Handoff For C3-X / C4-A

- Current executable evidence is real, but its runtime half is example-local and
  proof-runtime-backed.
- The quickstart uses `IgniterLang.compile`; it does not use the
  `runtime_smoke:` callback.
- RuntimeSmoke remains a separate proof-backed lib surface and should not be
  treated as accepted quickstart runtime support.
- The proof RuntimeMachine dependency is the central extraction/package blocker.
- The adapter/normalizer exists but was not used; do not treat it as reusable
  until a later proof exercises it.
- Examples and experiments are not packaged by the current gemspec.
- A helper route needs artifact-home, output schema, fallback policy, and
  no-claim wording before implementation.
- A package route needs gemspec/root-require/public-docs/installed-smoke review.
- A CLI `run` route remains closed and would need its own command/result/error
  design.
- Reference Runtime, public runtime, production runtime, Spark, release, report
  sidecar, CompatibilityReport, cache, receipt, and stable API claims remain
  closed.

---

## Recommendation Posture

Facts support a next review that separates three possible moves:

1. keep the delegated runtime example-local;
2. design a reusable experimental helper boundary;
3. design package or CLI exposure later.

This packet does not choose among them.
