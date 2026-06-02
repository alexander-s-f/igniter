# Experimental igc run Slice 0 Implementation v0

Card: S3-R234-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-igc-run-slice0-implementation-v0
Route: UPDATE
Status: done / PASS
Date: 2026-06-02

Depends on:
- S3-R234-C1-A

---

## Summary

Bounded pre-v1 experimental `igc run` Slice 0 is implemented inside the C1-A
write scope.

Implemented command:

```text
igc run ARTIFACT.igapp \
  --passport ARTIFACT.passport.json \
  --input INPUT.json \
  --runtime delegated-experimental:ivm-proof \
  --out RESULT.json \
  --experimental
```

This Slice 0 path is `.igapp` only. It consumes an explicit proof-local
passport, validates the passport before execution, requires explicit input JSON,
requires the explicit delegated selector, and writes a machine-readable local
experimental result packet.

---

## Files Changed

Source:

```text
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
```

Proof-local experiment:

```text
igniter-lang/experiments/experimental_igc_run_v0/inputs/add_19_23.json
igniter-lang/experiments/experimental_igc_run_v0/experimental_igc_run_slice0_proof_v0.rb
igniter-lang/experiments/experimental_igc_run_v0/out/**
```

Track doc:

```text
igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md
```

`bin/igc` was not edited. The existing entrypoint already dispatches through
`IgniterLang::CLI.run(ARGV)`.

---

## Closed Surfaces Preserved

No edits were made to:

```text
igniter-lang/bin/igc
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

No `.igbin` execution, compiler passport emission, RuntimeSmoke path, Reference
Runtime support, public runtime support, release evidence, public docs claim,
Spark integration, or public performance evidence was introduced.

---

## Runtime Selector Resolution

`delegated-experimental:ivm-proof` resolves explicitly to:

```text
igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
RuntimeMachineMemoryProof::CompiledProgram.load_igapp(artifact_path)
program.validate!
program.evaluate_contract(contract_name, input_hash)
```

The helper lazy-loads that proof runtime only in the `igc run` path. It does not
require or invoke RuntimeSmoke.

Contract selection is fail-closed:

```text
passport.output_contract.contract_name
```

Input selection is explicit:

```text
--input PATH.json
```

No sample-input default or fallback is used.

---

## Passport Validation

The run helper fails closed before runtime execution unless the supplied
passport satisfies the C1-A Slice 0 requirements:

```text
passport_kind == artifact_passport
artifact_kind == igapp_dir
artifact_ref matches supplied .igapp
artifact_digest matches recomputed .igapp digest
surface_dimension == executable_runtime
runtime_target_kind == delegated_experimental_runtime
authority_status includes non-canonical / evidence-only
required non_claims are present
input_contract is present
output_contract is present and not deferred
output_contract.contract_name is present
failure_policy is present
runtime_implementation_id is present as evidence metadata only
```

Digest policy matches R232:

```text
sort all files under .igapp recursively
hash each file with SHA256
join file digests with ":"
SHA256 the joined string
prefix with "sha256:"
```

---

## Result Packet

Positive command result:

```text
/tmp/igniter_lang_cli_run_slice0/result.json
```

Observed key fields:

```json
{
  "kind": "experimental_igc_run_v0_result",
  "status": "ok",
  "experimental": true,
  "pre_v1": true,
  "stable_api": false,
  "runtime_selector": "delegated-experimental:ivm-proof",
  "outputs": {
    "sum": 42
  }
}
```

The packet includes machine-readable non-claims and markers that it is not a
CompilerResult, CompilationReport, CompatibilityReport, receipt sidecar,
release evidence, or public API response contract.

---

## Proof Matrix

Proof runner:

```text
igniter-lang/experiments/experimental_igc_run_v0/experimental_igc_run_slice0_proof_v0.rb
```

Proof summary:

```text
igniter-lang/experiments/experimental_igc_run_v0/out/summary.json
```

Result:

```text
overall: PASS
checks_total: 20
checks_pass: 20
checks_fail: 0
failed_checks: []
```

Required checks:

```text
IGR-1  PASS  rejects without --experimental
IGR-2  PASS  rejects missing passport
IGR-3  PASS  rejects malformed passport JSON
IGR-4  PASS  rejects passport/artifact ref mismatch
IGR-5  PASS  rejects artifact digest mismatch
IGR-6  PASS  rejects unsupported artifact_kind, including .igbin
IGR-7  PASS  rejects deferred output_contract
IGR-8  PASS  rejects unsupported runtime selector
IGR-9  PASS  executes Add.igapp and returns sum=42
IGR-10 PASS  result packet is local experimental output only
IGR-11 PASS  RuntimeSmoke not invoked; forbidden run label absent from output
IGR-12 PASS  compiler passport emission remains absent
IGR-13 PASS  compile behavior remains backward-compatible
IGR-14 PASS  README/gemspec/public docs remain unchanged
IGR-15 PASS  forbidden claim scan passes
```

Additional checks:

```text
IGR-16 PASS  rejects missing --input
IGR-17 PASS  rejects malformed input JSON
IGR-18 PASS  rejects non-object input JSON
IGR-19 PASS  rejects missing --out
IGR-20 PASS  rejects missing output_contract.contract_name
```

---

## Command Matrix

Syntax:

```text
ruby -c igniter-lang/lib/igniter_lang/cli.rb
Syntax OK

ruby -c igniter-lang/lib/igniter_lang/experimental_igc_run.rb
Syntax OK

ruby -c igniter-lang/experiments/experimental_igc_run_v0/experimental_igc_run_slice0_proof_v0.rb
Syntax OK
```

Compile regression:

```text
ruby -I igniter-lang/lib igniter-lang/bin/igc compile \
  igniter-lang/examples/experimental_executable_quickstart_v0/add_quickstart.ig \
  --out /tmp/igniter_lang_cli_run_slice0/Add.igapp

status: ok
kind: compiler_result
runtime_smoke: null
contracts: ["Add"]
```

Positive run:

```text
ruby -I igniter-lang/lib igniter-lang/bin/igc run \
  igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp \
  --passport igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json \
  --input igniter-lang/experiments/experimental_igc_run_v0/inputs/add_19_23.json \
  --runtime delegated-experimental:ivm-proof \
  --out /tmp/igniter_lang_cli_run_slice0/result.json \
  --experimental

exit: 0
outputs.sum: 42
```

Proof runner:

```text
ruby igniter-lang/experiments/experimental_igc_run_v0/experimental_igc_run_slice0_proof_v0.rb

PASS experimental_igc_run_slice0_proof_v0
checks_total=20
checks_pass=20
checks_fail=0
failed_checks=[]
```

Negative runs are recorded in:

```text
igniter-lang/experiments/experimental_igc_run_v0/out/summary.json
```

All negative commands returned non-zero and emitted blocked/error packets when
`--out` was available.

---

## Next Recommendation

Route:

```text
S3-R234-C4-A
experimental-igc-run-slice0-implementation-acceptance-decision-v0
```

Recommended decision:

```text
accept bounded Slice 0 implementation if C4-A confirms the write scope,
command matrix, result-packet wording, and closed-surface preservation.
```
