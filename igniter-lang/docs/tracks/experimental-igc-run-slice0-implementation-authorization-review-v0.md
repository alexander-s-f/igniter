# Experimental igc run Slice 0 Implementation Authorization Review v0

Card: S3-R234-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice0-implementation-authorization-review-v0
Route: UPDATE
Status: authorized / bounded-slice0-only
Date: 2026-06-02

Depends on:
- S3-R233-C5-S

---

## Decision

Authorize bounded pre-v1 experimental `igc run` Slice 0 implementation.

Authorized implementation may begin:

```text
Card: S3-R234-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice0-implementation-v0
```

Authorization is limited to `.igapp` input plus explicit proof-local passport
validation, explicit input JSON, explicit delegated runtime selector, and
machine-readable experimental result output.

This card does not authorize `.igbin` execution, compiler passport emission,
RuntimeSmoke productization, Reference Runtime support, public runtime support,
stable API, production readiness, Spark integration, release evidence, public
docs claims, or public performance claims.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round233-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-design-only-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-design-only-boundary-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-current-surface-and-lab-signals-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-igc-run-design-only-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/**`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/quickstart_result.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/bin/igc`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/experimental_runtime_artifact_passport_manifest_v0.rb`

---

## Authorization Summary

| Question | Decision |
| --- | --- |
| May C2-I begin? | Yes. |
| May `lib/igniter_lang/cli.rb` be edited? | Yes, narrowly. |
| May `bin/igc` be edited? | Default no; only if C2-I proves it is necessary for dispatch and records why. |
| May a helper file be created? | Yes: `lib/igniter_lang/experimental_igc_run.rb`. |
| Is `.igbin` excluded? | Yes, mandatory exclusion. |
| Is RuntimeSmoke closed? | Yes, all `igc run` code paths must avoid RuntimeSmoke. |
| What does `delegated-experimental:ivm-proof` resolve to? | Direct proof runtime loader path described below. |
| Is compiler passport emission closed? | Yes. |
| Are README/gemspec/public docs closed? | Yes. |
| Are stable API / production / public demo / Spark / release / Reference Runtime / public runtime / performance claims closed? | Yes. |

---

## Allowed Write Scope

Authorized write scope:

```text
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
igniter-lang/experiments/experimental_igc_run_v0/**
igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md
```

Conditional write scope:

```text
igniter-lang/bin/igc
```

`bin/igc` should remain unchanged unless implementation proves the existing
entrypoint cannot dispatch `run` through `IgniterLang::CLI.run(ARGV)`. If
edited, C2-I must record the exact reason and prove compile behavior remains
unchanged.

Closed write scope:

```text
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/lib/igniter_lang.rb
igniter-lang/experiments/runtime_machine_memory_proof/**
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/**
igniter-lang/examples/experimental_executable_quickstart_v0/**
playgrounds/igniter-lab/**
```

---

## Command Vocabulary

Authorized Slice 0 command:

```text
igc run ARTIFACT.igapp \
  --passport ARTIFACT.passport.json \
  --input INPUT.json \
  --runtime delegated-experimental:ivm-proof \
  --out RESULT.json \
  --experimental
```

Required:

```text
ARTIFACT.igapp positional path
--passport PATH.json
--input PATH.json
--runtime delegated-experimental:ivm-proof
--out PATH.json
--experimental
```

Rejected:

```text
igc run SOURCE.ig
igc run ARTIFACT.igbin
igc run without --experimental
igc run without --passport
igc run without --input
igc run without --runtime
igc run without --out
igc run --runtime reference
igc run --runtime official
igc run --runtime production
igc run --runtime stable
igc run --runtime tbackend
igc run --runtime benchmark
igc run --runtime spark
```

Existing compile command must remain:

```text
igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]
```

---

## Runtime Selector Resolution

`delegated-experimental:ivm-proof` resolves to:

```text
direct proof runtime loader:
  igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb

runtime class:
  RuntimeMachineMemoryProof::CompiledProgram

load path:
  RuntimeMachineMemoryProof::CompiledProgram.load_igapp(artifact_path)
  program.validate!
  program.evaluate_contract(contract_name, input_hash)
```

Contract name source:

```text
prefer passport.output_contract.contract_name when present;
otherwise fail closed for Slice 0.
```

Input mapping:

```text
JSON object input only.
Input keys may be strings; proof runtime accepts string or symbol keys.
No implicit sample_input defaults.
No RuntimeSmoke.eval_input_for fallback.
```

Adapter constraints:

```text
No RuntimeSmoke.
No resident supervisor.
No C AOT file loader.
No .igbin path.
No TBackend.
No benchmark harness.
No implicit runtime discovery.
```

The helper may direct-require `compiled_program.rb` lazily inside the run path.
It must not require RuntimeSmoke. It must not add root require exposure through
`igniter-lang/lib/igniter_lang.rb`.

---

## Passport Validation Requirements

C2-I must fail closed before runtime execution unless the supplied passport
satisfies:

```text
passport_kind == artifact_passport
artifact_kind == igapp_dir
artifact_ref matches supplied .igapp path or resolves to the same path
artifact_digest matches recomputed .igapp directory digest
surface_dimension == executable_runtime
runtime_target_kind == delegated_experimental_runtime
authority_status includes non-canonical / evidence-only
non_claims includes:
  not stable API
  not production ready
  not public runtime support
  not Reference Runtime support
  not Spark integration
  not release evidence
  not public performance claim
  not compiler passport emission
  not igc run implementation
input_contract is present
output_contract is present
output_contract is not deferred
output_contract.contract_name is present
failure_policy is present
runtime_implementation_id is present as evidence metadata only
```

Digest policy:

```text
Use the R232 proof-compatible directory digest:
  sort all files under .igapp recursively;
  hash each file with SHA256;
  join file digests with ":";
  SHA256 the joined string;
  prefix with "sha256:".
```

The implementation may copy this algorithm into the Slice 0 helper. It must
not edit or depend on the R232 proof script at runtime.

---

## Result Packet Shape

Every run path must write a JSON result packet to `--out`.

Required minimum result fields:

```json
{
  "kind": "experimental_igc_run_v0_result",
  "format_version": "0.1.0",
  "card": "S3-R234-C2-I",
  "track": "experimental-igc-run-slice0-implementation-v0",
  "status": "ok | blocked | error",
  "experimental": true,
  "pre_v1": true,
  "stable_api": false,
  "artifact_ref": "...",
  "passport_ref": "...",
  "runtime_selector": "delegated-experimental:ivm-proof",
  "runtime_authority": "non-canonical / delegated experimental",
  "outputs": {},
  "diagnostics": [],
  "non_claims": []
}
```

Result packet must not be:

```text
CompilerResult
CompilationReport
CompatibilityReport
receipt sidecar
release evidence
public API response contract
stable API contract
```

Blocked/negative cases must also emit a result packet when `--out` is
provided and should return non-zero exit status.

---

## Required Proof Matrix

C2-I must prove at least:

```text
IGR-1: `igc run` rejects without `--experimental`.
IGR-2: `igc run` rejects missing passport.
IGR-3: `igc run` rejects malformed passport JSON.
IGR-4: `igc run` rejects passport/artifact ref mismatch.
IGR-5: `igc run` rejects artifact digest mismatch.
IGR-6: `igc run` rejects unsupported `artifact_kind`, including `.igbin`.
IGR-7: `igc run` rejects deferred `output_contract`.
IGR-8: `igc run` rejects unsupported runtime selector.
IGR-9: `igc run` executes `Add.igapp` through the explicit delegated runtime
  selector and returns `sum=42`.
IGR-10: result packet is local experimental output only, not `CompilerResult`,
  `CompilationReport`, `CompatibilityReport`, receipt, release evidence, or
  public API response contract.
IGR-11: RuntimeSmoke is not invoked and `production-compiler-cli` is absent
  from run result output.
IGR-12: compiler passport emission remains absent.
IGR-13: `igc compile` behavior remains backward-compatible.
IGR-14: README/gemspec/public docs remain unchanged.
IGR-15: public/stable/production/Spark/release/performance claim scan passes.
```

Recommended additional checks:

```text
IGR-16: run rejects missing `--input`.
IGR-17: run rejects malformed input JSON.
IGR-18: run rejects non-object input JSON.
IGR-19: run rejects missing `--out`.
IGR-20: run rejects missing output_contract.contract_name.
```

---

## Required Command Matrix

Syntax:

```text
ruby -c igniter-lang/lib/igniter_lang/cli.rb
ruby -c igniter-lang/lib/igniter_lang/experimental_igc_run.rb
```

Compile regression:

```text
ruby -I igniter-lang/lib igniter-lang/bin/igc compile \
  igniter-lang/examples/experimental_executable_quickstart_v0/add_quickstart.ig \
  --out /tmp/igniter_lang_cli_run_slice0/Add.igapp
```

Positive run:

```text
ruby -I igniter-lang/lib igniter-lang/bin/igc run \
  igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp \
  --passport igniter-lang/experiments/
    experimental_runtime_artifact_passport_manifest_v0/out/
    Add.igapp.passport.json \
  --input igniter-lang/experiments/experimental_igc_run_v0/inputs/
    add_19_23.json \
  --runtime delegated-experimental:ivm-proof \
  --out /tmp/igniter_lang_cli_run_slice0/result.json \
  --experimental
```

Proof runner:

```text
ruby -c igniter-lang/experiments/experimental_igc_run_v0/
  experimental_igc_run_slice0_proof_v0.rb
ruby igniter-lang/experiments/experimental_igc_run_v0/
  experimental_igc_run_slice0_proof_v0.rb
```

The proof runner may create mutated passport/input fixtures under:

```text
igniter-lang/experiments/experimental_igc_run_v0/out/**
```

Negative cases for IGR-1..IGR-8 and recommended IGR-16..IGR-20 may be executed
through the proof runner rather than listed as individual shell commands.

---

## Forbidden Phrase Scan

C2-I must scan source changes, track doc, proof summary/result JSON, and run
result packets for forbidden phrases.

Forbidden in run result output:

```text
production-compiler-cli
stable run command
stable runtime API
production runtime support
Reference Runtime path
igniter-tbackend integration via igc run
benchmark results for igc run performance
SparkCRM
certified output
portable artifact verified by igc run
public performance claim
```

Allowed only as negated non-claims or explanatory closed-surface wording in
docs:

```text
not stable API
not production ready
not Reference Runtime support
not public runtime support
not Spark integration
not release evidence
not public performance claim
```

---

## Explicit Answers

May C2-I begin?

```text
Yes.
```

May `lib/igniter_lang/cli.rb` be edited?

```text
Yes, narrowly for `run` dispatch and preserving compile behavior.
```

May `bin/igc` be edited?

```text
Default no. It may be edited only if C2-I proves it is necessary for dispatch.
```

May a small internal CLI helper file be created?

```text
Yes: `igniter-lang/lib/igniter_lang/experimental_igc_run.rb`.
```

Does `.igbin` remain excluded?

```text
Yes.
```

Does RuntimeSmoke remain closed in all run code paths?

```text
Yes.
```

What does `delegated-experimental:ivm-proof` resolve to?

```text
It resolves to a lazy direct-require adapter over:
  RuntimeMachineMemoryProof::CompiledProgram.load_igapp(...).validate!
  RuntimeMachineMemoryProof::CompiledProgram#evaluate_contract(...)

The implementation must direct-require:
  igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb

It must not use RuntimeSmoke, resident supervisor, AOT bytecode loader,
TBackend, benchmark-app, or runtime discovery.
```

Does compiler passport emission remain closed?

```text
Yes.
```

Do README/gemspec/public docs remain closed?

```text
Yes.
```

Do stable API, production, public demo, Spark, release, Reference Runtime,
public runtime, and performance claims remain closed?

```text
Yes.
```

---

## Exact C2-I Boundary

```text
Card: S3-R234-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice0-implementation-v0

Route: UPDATE
Depends on:
- S3-R234-C1-A

Goal:
Implement and prove bounded pre-v1 experimental `igc run` Slice 0: `.igapp`
input, explicit proof-local passport, explicit input JSON, explicit
`delegated-experimental:ivm-proof` runtime selector, mandatory
`--experimental`, and machine-readable experimental result output.

Allowed write scope:
- igniter-lang/lib/igniter_lang/cli.rb
- igniter-lang/lib/igniter_lang/experimental_igc_run.rb
- igniter-lang/experiments/experimental_igc_run_v0/**
- igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md

Conditional write scope:
- igniter-lang/bin/igc only if necessary and justified

Required matrix:
- IGR-1..IGR-15 mandatory
- IGR-16..IGR-20 recommended

Required command matrix:
- syntax checks
- compile regression
- positive run returning sum=42
- proof runner covering negative cases

Closed:
- `.igbin`
- RuntimeSmoke
- compiler passport emission
- Reference Runtime
- public runtime support
- README/gemspec/public docs
- stable API / production / Spark / release / performance claims
```
