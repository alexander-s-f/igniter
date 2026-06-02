# Experimental igc run Design-Only Boundary Decision v0

Card: S3-R233-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-design-only-boundary-decision-v0
Route: UPDATE
Status: accepted / implementation-authorization-review-next
Date: 2026-06-02

Depends on:
- S3-R233-C1-D
- S3-R233-C2-P1
- S3-R233-C3-X

---

## Decision

Accept the experimental `igc run` design-only boundary.

Accepted inputs:

```text
S3-R233-C1-D: design-ready
S3-R233-C2-P1: facts-only / accepted as accurate basis
S3-R233-C3-X: PASS / no blockers / three acceptance notes
```

Open the next Main Line route as a bounded implementation-authorization
review, not implementation:

```text
S3-R234-C1-A
experimental-igc-run-slice0-implementation-authorization-review-v0
```

`igc run` implementation remains closed until S3-R234-C1-A explicitly
authorizes a C2-I implementation boundary.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-design-only-boundary-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-current-surface-and-lab-signals-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-igc-run-design-only-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round232-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md`

No code, compiler, CLI, runtime, package, public docs, release, or playground
source changes are authorized by this decision.

---

## Accepted Boundary

Accepted Slice 0 shape for the next authorization review:

```text
igc run ARTIFACT.igapp \
  --passport ARTIFACT.passport.json \
  --input INPUT.json \
  --runtime delegated-experimental:ivm-proof \
  --out RESULT.json \
  --experimental
```

Accepted Slice 0 constraints:

```text
.igapp only
explicit proof-local passport path required
explicit sample input JSON required
explicit delegated runtime selector required
mandatory --experimental flag
machine-readable experimental result packet
pre-v1 / no-stable-API wording
fail-closed passport/readiness checks
```

Held from Slice 0:

```text
.igbin execution
compiler passport emission
implicit runtime discovery/defaulting
RuntimeSmoke productization
Reference Runtime
Rust TBackend execution
benchmark/performance claims
Spark integration
release execution
stable API promises
```

---

## Status Record

| Surface | Decision status |
| --- | --- |
| `igc run` design boundary | accepted |
| implementation authorization | may open next as S3-R234-C1-A |
| `igc run` implementation now | closed |
| passport prerequisite | satisfied for design and narrow auth-review consideration |
| `.igapp` passport | accepted Slice 0 prerequisite |
| `.igbin` passport | held; deferred `output_contract` remains blocker for execution |
| compiler passport emission | closed |
| delegated runtime naming | accepted only as unstable pre-v1 selector label |
| RuntimeSmoke | closed; no productization and no run-path dependency |
| `igniter-tbackend` | backend/substrate lab signal only |
| benchmark-app | benchmark-consumer lab signal only |
| Reference Runtime / public runtime | closed |
| stable API / production / Spark / release / performance claims | closed |

---

## Accepted Facts and Pressure Notes

Accepted from C2-P1:

```text
Current CLI supports compile only.
No `run` command exists today.
Compiler emits .igapp artifacts.
RuntimeSmoke is proof-backed and not invoked by CLI today.
R232 generated four proof-local passport manifests with 16/16 PASS.
Add.igapp passport has non-deferred output_contract.
Accepted .igbin passports have deferred output_contract.
igniter-tbackend is temporal_backend / backend-substrate vocabulary.
benchmark-app measures TBackend TCP server, not igc run or language runtime.
```

Accepted from C3-X:

```text
PASS — accept design.
No blockers.
Carry AN-1, AN-2, AN-3 into S3-R234-C1-A.
```

Binding acceptance notes for S3-R234-C1-A:

```text
AN-1:
  RuntimeSmoke must remain closed in all igc run code paths.
  "production-compiler-cli" must be a forbidden string in run result output.

AN-2:
  TBackend README wording ("production-grade" / "SparkCRM") remains lab-only.
  Any future public reference to TBackend requires a separate wording audit.

AN-3:
  The selector "delegated-experimental:ivm-proof" must resolve to an explicit
  adapter path. The authorization review must not leave runtime selector
  resolution implicit.
```

---

## Passport Validation Stance

S3-R234-C1-A should require Slice 0 to fail closed unless the supplied
passport satisfies at least:

```text
passport_kind == artifact_passport
artifact_kind == igapp_dir
artifact_ref matches supplied .igapp
artifact_digest matches recomputed digest
surface_dimension == executable_runtime
runtime_target_kind == delegated_experimental_runtime
authority_status includes non-canonical / evidence-only
non_claims includes stable API / production / public runtime /
  Reference Runtime / Spark / release / performance non-claims
input_contract present
output_contract present and not deferred
failure_policy present
runtime_implementation_id present as evidence metadata only
```

Rejections that must be proven:

```text
missing passport
malformed passport
passport/artifact mismatch
artifact digest mismatch
unsupported artifact_kind
deferred output_contract
unsupported runtime selector
missing --experimental
```

Compiler passport emission remains closed. Slice 0 may consume explicitly
provided proof-local manifests only if S3-R234-C1-A authorizes that future
implementation boundary.

---

## Runtime / Backend / Benchmark Separation

Delegated runtime stance:

```text
delegated-experimental:ivm-proof may be named only as an unstable pre-v1
selector label.
```

The selector must not be:

```text
stable API
package identity
Reference Runtime identity
public runtime support
performance claim
```

`igniter-tbackend` stance:

```text
surface_dimension: temporal_backend
role: backend/substrate lab signal
not an igc run runtime
not public API authority
not Spark integration
not performance authority
```

benchmark-app stance:

```text
surface_dimension: benchmark_consumer
target: TBackend TCP server
not igc run performance
not .igapp runtime performance
not public performance evidence
```

---

## Proof / Regression Expectations for Next Route

S3-R234-C1-A should define a future C2-I proof matrix that covers:

```text
IGR-1: `igc run` rejects without --experimental.
IGR-2: `igc run` rejects missing passport.
IGR-3: `igc run` rejects malformed passport JSON.
IGR-4: `igc run` rejects passport/artifact ref mismatch.
IGR-5: `igc run` rejects artifact digest mismatch.
IGR-6: `igc run` rejects unsupported artifact_kind, including .igbin.
IGR-7: `igc run` rejects deferred output_contract.
IGR-8: `igc run` rejects unsupported runtime selector.
IGR-9: `igc run` executes Add.igapp through the explicit delegated runtime
  selector and returns sum=42.
IGR-10: result packet is local experimental output, not CompilerResult,
  CompilationReport, CompatibilityReport, receipt, release evidence, or
  public API response contract.
IGR-11: RuntimeSmoke is not invoked and "production-compiler-cli" is absent
  from run result output.
IGR-12: compiler passport emission remains absent.
IGR-13: `igc compile` behavior remains backward-compatible.
IGR-14: README/gemspec/public docs remain unchanged.
IGR-15: public/stable/production/Spark/release/performance claim scan passes.
```

Command matrix expectations:

```text
ruby -c igniter-lang/lib/igniter_lang/cli.rb
ruby -I igniter-lang/lib igniter-lang/bin/igc compile ...
ruby -I igniter-lang/lib igniter-lang/bin/igc run ... --experimental ...
ruby -I igniter-lang/lib igniter-lang/bin/igc run ... negative cases ...
```

Exact command matrix belongs to S3-R234-C1-A. This decision does not authorize
running or implementing those commands.

---

## Candidate Next Authorization Review Scope

S3-R234-C1-A may evaluate the following candidate future write scope:

```text
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/bin/igc if needed
igniter-lang/experiments/experimental_igc_run_v0/**
igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md
```

Default closed unless explicitly opened by S3-R234-C1-A:

```text
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
playgrounds/igniter-lab/**
release commands
public docs
```

---

## Explicit Answers

Is the experimental `igc run` design boundary accepted?

```text
Yes.
```

May implementation authorization open next?

```text
Yes. Open S3-R234-C1-A as a bounded implementation-authorization review.
```

Does `igc run` implementation remain closed now?

```text
Yes. C4-A does not authorize implementation.
```

Does compiler passport emission remain closed?

```text
Yes.
```

May delegated runtimes be named by an experimental CLI boundary?

```text
Yes, only as unstable pre-v1 non-canonical selector labels, with explicit
resolution in the next authorization review.
```

Do `igniter-tbackend` and benchmark-app remain lab evidence only?

```text
Yes.
```

Do Reference Runtime, public runtime, stable API, production, public demo,
Spark, RuntimeSmoke productization, release, and public performance claims
remain closed?

```text
Yes.
```

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R234-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice0-implementation-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R233-C5-S

Goal:
Decide whether a bounded pre-v1 experimental `igc run` Slice 0
implementation may begin, limited to `.igapp` input plus explicit proof-local
passport validation, explicit sample input, explicit delegated runtime
selector, and machine-readable experimental result output, without
authorizing compiler passport emission, `.igbin` execution, RuntimeSmoke
productization, Reference Runtime support, public runtime support, stable API,
production readiness, Spark integration, release evidence, or public
performance claims.

Scope:
- Read:
  - igniter-lang/docs/tracks/stage3-round233-status-curation-v0.md
  - igniter-lang/docs/tracks/
    experimental-igc-run-design-only-boundary-decision-v0.md
  - igniter-lang/docs/tracks/
    experimental-igc-run-design-only-boundary-v0.md
  - igniter-lang/docs/tracks/
    experimental-igc-run-current-surface-and-lab-signals-facts-v0.md
  - igniter-lang/docs/discussions/
    experimental-igc-run-design-only-boundary-pressure-v0.md
  - igniter-lang/docs/tracks/
    experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md
  - igniter-lang/experiments/
    experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json
  - igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/**
  - igniter-lang/examples/experimental_executable_quickstart_v0/out/
    quickstart_result.json
  - igniter-lang/lib/igniter_lang/cli.rb
  - igniter-lang/bin/igc
  - igniter-lang/lib/igniter_lang/runtime_smoke.rb
- Decide:
  - authorize bounded Slice 0 implementation;
  - authorize implementation prep only;
  - hold pending selector-resolution fix;
  - hold pending passport/output_contract hardening;
  - redirect to Runtime Specification input slice;
  - pause.
- If authorizing C2-I, define exact:
  - allowed write scope;
  - command vocabulary;
  - required flags;
  - runtime selector resolution;
  - delegated runtime adapter path;
  - passport validation requirements;
  - result packet shape;
  - proof matrix IGR-1..IGR-15 or stricter;
  - command matrix;
  - forbidden phrase scan, including `production-compiler-cli`;
  - closed surfaces.
- Must explicitly answer:
  - whether C2-I may begin;
  - whether `lib/igniter_lang/cli.rb` may be edited;
  - whether `bin/igc` may be edited;
  - whether `.igbin` remains excluded;
  - whether RuntimeSmoke remains closed in all run code paths;
  - what `delegated-experimental:ivm-proof` resolves to;
  - whether compiler passport emission remains closed;
  - whether README/gemspec/public docs remain closed;
  - whether stable API, production, public demo, Spark, release,
    Reference Runtime, public runtime, and performance claims remain closed.

Do not:
- implement code in this card;
- authorize `.igbin` execution;
- authorize compiler passport emission;
- authorize RuntimeSmoke productization;
- authorize Reference Runtime implementation;
- authorize public runtime support;
- authorize release execution or public claims.

Deliver:
- Authorization decision doc in `igniter-lang/docs/tracks/`
- Compact decision summary
- If authorized: exact C2-I implementation boundary
- If held/redirected: blocker list
```
