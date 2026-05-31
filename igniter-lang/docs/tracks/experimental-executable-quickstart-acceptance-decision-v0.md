# Experimental Executable Quickstart Acceptance Decision v0

Card: S3-R223-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-executable-quickstart-acceptance-decision-v0
Route: UPDATE
Status: accepted
Date: 2026-05-31

Depends on:
- S3-R223-C2-I
- S3-R223-C3-X

---

## Decision

Accept the experimental executable quickstart.

This is real executable evidence, not compile-only evidence:

```text
.ig source -> compile -> .igapp -> delegated experimental runtime -> sum = 42
```

Accepted status:

```text
S3-R223-C2-I: PASS
S3-R223-C3-X: PASS
Decision: accept unconditionally with one non-blocking note
```

Generated output may be called only:

```text
delegated experimental runtime evidence
non-canonical example-local runtime-learning evidence
```

It is not Reference Runtime support, public runtime support, production runtime
support, stable API, public demo readiness, Spark integration, or release
evidence.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-executable-quickstart-authorization-review-v0.md`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-v0.md`
- `igniter-lang/docs/discussions/experimental-executable-quickstart-pressure-v0.md`
- `igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb`
- `igniter-lang/examples/experimental_executable_quickstart_v0/add_quickstart.ig`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/quickstart_result.json`
- `igniter-lang/docs/tracks/stage3-round222-status-curation-v0.md`

Local verification was also run for the command matrix listed below.

---

## Exact Changed Files Accepted

From S3-R223-C2-I:

- `igniter-lang/docs/tracks/experimental-executable-quickstart-v0.md`
- `igniter-lang/examples/experimental_executable_quickstart_v0/add_quickstart.ig`
- `igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/classified_ast.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/
  compatibility_metadata.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/
  compilation_report.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/contracts/add.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/diagnostics.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/manifest.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/projections.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/requirements.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/
  semantic_ir_program.json`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/quickstart_result.json`

From S3-R223-C3-X:

- `igniter-lang/docs/discussions/experimental-executable-quickstart-pressure-v0.md`
- `igniter-lang/docs/discussions/README.md`

No `lib/**`, `bin/igc`, gemspec, README, RuntimeSmoke, CompilerResult, or
CompilationReport file is accepted as changed by this route.

---

## Command Matrix Result

Locally verified:

```text
ruby -c igniter-lang/examples/
  experimental_executable_quickstart_v0/quickstart.rb
=> Syntax OK

ruby igniter-lang/examples/
  experimental_executable_quickstart_v0/quickstart.rb
=> PASS experimental_executable_quickstart_v0
=> checks_total=14 checks_pass=14 checks_fail=0
=> Execution result: {"sum"=>42}

ruby -c igniter-lang/lib/igniter_lang/runtime_smoke.rb
=> Syntax OK

ruby -c igniter-lang/experiments/runtime_machine_memory_proof/
  compiled_program.rb
=> Syntax OK

ruby -rjson -e ... igniter-lang/examples/
  experimental_executable_quickstart_v0/out/quickstart_result.json
=> overall=PASS actual_sum=42
```

Result packet:

```text
igniter-lang/examples/experimental_executable_quickstart_v0/out/quickstart_result.json
sha256:666952db1cf6018396dd2595690956cdf9337c4ca5f3d333f950f5218756731a
```

Working tree after local verification:

```text
clean
```

---

## Accepted Evidence

Pipeline:

```text
source:           add_quickstart.ig
compile_status:   ok
igapp_exists:     true
load_status:      loaded
adapter_used:     false
execution_status: ok
actual_sum:       42
expected_sum:     42
output_matches:   true
overall:          PASS
checks:           14/14
```

The compiler-emitted `.igapp` loaded directly into the delegated experimental
runtime harness. No example-local adapter or normalizer was needed.

---

## EXQ Result Record

Accepted:

- EXQ-1: PASS. Source fixture exists and is narrowly labeled.
- EXQ-2: PASS. Compile produces `.igapp`.
- EXQ-3: PASS. Delegated experimental runtime executes selected fixture.
- EXQ-4: PASS. Output value matches expected result.
- EXQ-5: PASS. Output artifacts are confined to example-local output.
- EXQ-6: PASS. Adapter policy satisfied; no adapter needed.
- EXQ-7: PASS. Adapter mismatch record says none.
- EXQ-8: PASS. RuntimeSmoke source/result shape unchanged.
- EXQ-9: PASS. `lib/**`, `bin/igc`, gemspec, README, public docs unchanged.
- EXQ-10: PASS. CompilerResult / CompilationReport fields unchanged.
- EXQ-11: PASS. Forbidden phrase scan passes.
- EXQ-12: PASS. Pre-v1 / no-stable-API / non-production disclaimer present.
- EXQ-13: PASS. Release/public/Spark/API/production claims remain closed.
- EXQ-14: PASS with AN-1 below. Compile-only HOLD invariant is present.

---

## Non-Blocking Acceptance Note

AN-1:

```text
EXQ-14 is a structural invariant declaration in this successful run, not a
behavioral HOLD-path test.
```

The pressure review confirms the HOLD branch is implemented in the quickstart
overall calculation. Because this run succeeded end-to-end, the HOLD branch was
not executed. This does not block acceptance.

Future iterations may add an explicit compile-only/HOLD negative fixture if
that path becomes part of productized delegated runtime behavior.

---

## Runtime Boundary Status

Three-runtime distinction remains binding:

```text
Runtime Specification:
  Canonical/normative target. Closed to implementation by R223.

Reference Runtime:
  Future canonical implementation candidate. Closed by R223.

Delegated Experimental Runtime:
  Non-canonical example-local harness. Accepted as runtime-learning evidence.
```

RuntimeSmoke status:

```text
unchanged / not productized / not the accepted runtime surface
```

Report/API status:

```text
CompilerResult and CompilationReport fields remain unchanged.
No report/result/receipt sidecar authority opens.
```

---

## Explicit Answers

Is the experimental executable quickstart accepted?

```text
Yes.
```

Is it real executable evidence or only compile evidence?

```text
Real executable evidence. The accepted path compiled `.ig` to `.igapp`, loaded
the artifact, executed `Add`, and produced `sum = 42`.
```

May generated output be called delegated experimental runtime evidence only?

```text
Yes. It may be called delegated experimental runtime evidence only.
```

Is this Reference Runtime support?

```text
No.
```

Is this public runtime support?

```text
No.
```

Do stable API, production, public demo, Spark, and release claims remain closed?

```text
Yes.
```

---

## Next Route Decision

Open a runtime-productization boundary route next:

```text
delegated-experimental-runtime-boundary-and-packaging-options-v0
```

Why this route:

- R223 proved execution, not just compilation.
- The delegated harness is still embedded in an example.
- The next market-use step is to decide whether delegated runtime should stay
  example-local, become an internal experimental runtime package, or remain
  proof-only.
- This should be a boundary/options route before any extraction or packaging
  implementation.

The next route must not open Reference Runtime implementation yet. It should
first define:

- artifact home;
- packaging stance;
- API/CLI exposure stance;
- allowed experimental wording;
- no-stable-API/pre-v1 disclaimers;
- proof matrix;
- closed surfaces.

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R224-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-boundary-and-packaging-options-v0

Route: UPDATE
Depends on:
- S3-R223-C4-A

Goal:
Review options for turning the accepted example-local delegated experimental
runtime quickstart into a bounded runtime-productization path, without creating
Reference Runtime, production runtime, public runtime, stable API, Spark, or
release authority.

Scope:
- Read:
  - igniter-lang/docs/tracks/
    experimental-executable-quickstart-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/experimental-executable-quickstart-v0.md
  - igniter-lang/docs/discussions/
    experimental-executable-quickstart-pressure-v0.md
  - igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb
  - igniter-lang/examples/experimental_executable_quickstart_v0/out/
    quickstart_result.json
  - igniter-lang/lib/igniter_lang/runtime_smoke.rb
  - igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
- Review options:
  - keep delegated runtime harness example-local only;
  - extract a reusable examples-local delegated runtime helper;
  - create an internal experimental runtime package under examples/ or
    experiments/;
  - design a pre-v1 experimental `igc run` boundary without implementation;
  - start Runtime Specification slice first;
  - start Reference Runtime boundary survey;
  - pause.
- Evaluate:
  - time-to-experimental-use impact;
  - implementation size;
  - API/CLI stability risk;
  - claim risk;
  - runtime debt reduction;
  - package/release implications;
  - proof burden.
- Explicitly answer:
  - whether delegated runtime should remain example-local for now;
  - whether any packaging or extraction route may open next;
  - whether CLI `run` remains closed;
  - whether Runtime Specification should open before more delegated runtime;
  - whether Reference Runtime remains closed;
  - whether stable API, production, public demo, Spark, and release claims
    remain closed.

Do not:
- implement code;
- authorize RuntimeSmoke productization;
- authorize Reference Runtime implementation;
- authorize public runtime support;
- authorize stable API, production, public demo, Spark, or release claims;
- execute release commands.

Deliver:
- Options/recommendation doc in `igniter-lang/docs/tracks/`
- Compact runtime-productization options matrix
- Exact C4-A recommendation
```
