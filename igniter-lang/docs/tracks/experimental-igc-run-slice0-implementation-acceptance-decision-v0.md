# Experimental igc run Slice 0 Implementation Acceptance Decision v0

Card: S3-R234-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice0-implementation-acceptance-decision-v0
Route: UPDATE
Status: accepted
Date: 2026-06-02

Depends on:
- S3-R234-C2-I
- S3-R234-C3-X

---

## Decision

Accept the experimental `igc run` Slice 0 implementation closure.

This is accepted as bounded pre-v1 delegated-runtime Slice 0 run evidence only.
It does not create public runtime support, Reference Runtime support, stable API
authority, production readiness, Spark integration, release evidence, compiler
passport emission, `.igbin` execution, RuntimeSmoke productization, or public
performance claims.

Immediate next route:

```text
S3-R234-C5-S
stage3-round234-status-curation-v0
```

Recommended next Main Line route after curation:

```text
Card: S3-R235-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice0-quickstart-docs-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R234-C5-S

Goal:
Decide whether a bounded pre-v1 quickstart/docs exposure route may begin for
the accepted experimental `igc run` Slice 0 command, without turning Slice 0
into public runtime support, Reference Runtime support, stable API,
production readiness, Spark integration, release evidence, public docs claims,
or public performance claims.
```

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-authorization-review-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md`
- `igniter-lang/docs/discussions/experimental-igc-run-slice0-implementation-pressure-v0.md`
- `igniter-lang/experiments/experimental_igc_run_v0/out/summary.json`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/lib/igniter_lang/experimental_igc_run.rb`
- `igniter-lang/docs/tracks/stage3-round233-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-design-only-boundary-decision-v0.md`

---

## Exact Changed Files

Accepted source changes:

```text
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
```

Accepted proof-local files:

```text
igniter-lang/experiments/experimental_igc_run_v0/inputs/add_19_23.json
igniter-lang/experiments/experimental_igc_run_v0/experimental_igc_run_slice0_proof_v0.rb
igniter-lang/experiments/experimental_igc_run_v0/out/**
```

Accepted track and review files:

```text
igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md
igniter-lang/docs/discussions/experimental-igc-run-slice0-implementation-pressure-v0.md
```

Confirmed unchanged:

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

---

## Command Matrix Result

Accepted command matrix:

```text
ruby -c igniter-lang/lib/igniter_lang/cli.rb
  PASS / Syntax OK

ruby -c igniter-lang/lib/igniter_lang/experimental_igc_run.rb
  PASS / Syntax OK

ruby -c igniter-lang/experiments/experimental_igc_run_v0/
  experimental_igc_run_slice0_proof_v0.rb
  PASS / Syntax OK

igc compile regression through existing compile path
  PASS / exit 0 / status ok / runtime_smoke null

igc run positive case
  PASS / exit 0 / outputs.sum == 42

proof runner
  PASS / 20 checks passed / 0 failed
```

The pressure verdict independently confirmed `PASS - accept unconditionally`.

---

## Proof Matrix Result

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
IGR-11 PASS  RuntimeSmoke not invoked; forbidden run label absent
IGR-12 PASS  compiler passport emission remains absent
IGR-13 PASS  compile behavior remains backward-compatible
IGR-14 PASS  README/gemspec/public docs remain unchanged
IGR-15 PASS  forbidden claim scan passes
```

Additional accepted negative-path coverage:

```text
IGR-16 PASS  rejects missing --input
IGR-17 PASS  rejects malformed input JSON
IGR-18 PASS  rejects non-object input JSON
IGR-19 PASS  rejects missing --out
IGR-20 PASS  rejects missing output_contract.contract_name
```

Summary packet:

```text
checks_total: 20
checks_pass: 20
checks_fail: 0
```

---

## Accepted Slice 0 Status

Command vocabulary:

```text
igc run ARTIFACT.igapp \
  --passport ARTIFACT.passport.json \
  --input INPUT.json \
  --runtime delegated-experimental:ivm-proof \
  --out RESULT.json \
  --experimental
```

Status:

```text
accepted as pre-v1 experimental Slice 0 command vocabulary
requires --experimental
requires explicit .igapp input
requires explicit proof-local passport
requires explicit input JSON object
requires explicit delegated runtime selector
requires explicit output path
```

Passport validation:

```text
accepted
fail-closed
artifact_ref checked
artifact_digest recomputed and checked
artifact_kind limited to igapp_dir
output_contract must be present and not deferred
output_contract.contract_name required
runtime_target_kind / authority_status / non_claims checked
```

Runtime selector resolution:

```text
accepted
delegated-experimental:ivm-proof resolves only to:
  igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
  RuntimeMachineMemoryProof::CompiledProgram.load_igapp(...)
  program.validate!
  program.evaluate_contract(...)
```

RuntimeSmoke status:

```text
closed
not required
not invoked
not referenced by the Slice 0 run helper
runtime_smoke.rb unchanged
```

`.igbin` status:

```text
closed
rejected by artifact path policy
rejected by passport artifact_kind policy
no .igbin execution authority created
```

Result packet status:

```text
accepted as experimental_igc_run_v0_result
machine-readable
pre_v1: true
stable_api: false
runtime_authority: non-canonical / delegated experimental
not CompilerResult
not CompilationReport
not CompatibilityReport
not receipt sidecar
not release evidence
not public API response contract
```

Compile backward-compatibility status:

```text
accepted
compile regression passed
existing igc compile behavior remains intact
runtime_smoke remains null on compile regression
```

Compiler passport emission status:

```text
closed
no compiler emission introduced
proof-local passport remains external evidence metadata only
```

README/gemspec/public docs status:

```text
closed and unchanged
```

Public/stable/production/Spark/release/performance claim status:

```text
closed
no public runtime support
no Reference Runtime support
no stable API before v1
no production readiness
no public demo claim
no Spark integration
no release evidence
no public performance claim
```

---

## Carry-Forwards

Non-blocking carry-forward CF-1:

```text
The Slice 0 result packet carries the C1-A-required non_claims set. Future
result packet schema work may add:
- not certified alternative implementation
- not artifact portability guarantee

This is not required for acceptance because C1-A did not require those two
non_claims for Slice 0 result output.
```

Non-blocking carry-forward CF-2:

```text
RUN_USAGE in cli.rb now exposes the experimental run command vocabulary.
Future cli.rb edits must preserve the --experimental wording and delegated
selector requirement so the usage string does not imply general runtime
support.
```

---

## Explicit Answers

Whether experimental `igc run` Slice 0 implementation is accepted:

```text
Yes. Accepted unconditionally.
```

Whether generated output may be called experimental delegated-runtime Slice 0
run evidence only:

```text
Yes.
```

Whether this is public runtime support:

```text
No.
```

Whether this is Reference Runtime support:

```text
No.
```

Whether stable API remains unpromised before v1:

```text
Yes.
```

Whether RuntimeSmoke remains closed:

```text
Yes.
```

Whether `.igbin` remains closed:

```text
Yes.
```

Whether compiler passport emission remains closed:

```text
Yes.
```

What next route should open:

```text
Immediate:
  S3-R234-C5-S
  stage3-round234-status-curation-v0

Recommended after curation:
  S3-R235-C1-A
  experimental-igc-run-slice0-quickstart-docs-authorization-review-v0
```

---

## Next Dispatch Recommendation

```text
Card: S3-R235-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice0-quickstart-docs-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R234-C5-S

Goal:
Decide whether bounded pre-v1 quickstart/docs exposure may begin for the
accepted experimental `igc run` Slice 0 command, using only the accepted
R234 evidence and preserving no-stable-API-before-v1, no public runtime
support, no Reference Runtime support, no production readiness, no Spark
integration, no release evidence, no public performance claims, no compiler
passport emission, no `.igbin` execution, and no RuntimeSmoke productization.

Scope:
- Read:
  - igniter-lang/docs/tracks/stage3-round234-status-curation-v0.md
  - igniter-lang/docs/tracks/
    experimental-igc-run-slice0-implementation-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/
    experimental-igc-run-slice0-implementation-v0.md
  - igniter-lang/experiments/experimental_igc_run_v0/out/summary.json
  - igniter-lang/lib/igniter_lang/cli.rb
  - igniter-lang/lib/igniter_lang/experimental_igc_run.rb
- Decide:
  - authorize bounded internal quickstart/docs sync;
  - authorize only wording prep;
  - hold pending result packet wording/schema hardening;
  - redirect to Runtime Specification input slice;
  - redirect to `.igbin` output_contract design/proof;
  - pause.
- If authorizing, define exact:
  - allowed files;
  - forbidden files;
  - pre-v1 / no-stable-API wording;
  - experimental delegated-runtime wording;
  - no-public-runtime / no-Reference-Runtime wording;
  - command example policy;
  - evidence citation policy;
  - forbidden wording scan;
  - closed surfaces.
- Explicitly answer:
  - whether quickstart/docs exposure may begin;
  - whether README/public docs remain closed or may be narrowly touched;
  - whether generated docs may describe experimental delegated-runtime Slice 0
    evidence only;
  - whether public runtime, Reference Runtime, stable API, production, Spark,
    release, and public performance claims remain closed.

Do not:
- edit docs in this card;
- authorize runtime/API/package changes;
- authorize `.igbin` execution;
- authorize compiler passport emission;
- authorize RuntimeSmoke productization;
- authorize public runtime support, Reference Runtime support, stable API,
  production, Spark, release execution, public demo, or public performance
  claims.

Deliver:
- Authorization decision doc in `igniter-lang/docs/tracks/`
- Compact decision summary
- If authorized: exact docs-sync boundary
- If held/redirected: blocker list
```
