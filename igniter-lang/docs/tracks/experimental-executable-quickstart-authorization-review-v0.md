# Experimental Executable Quickstart Authorization Review v0

Card: S3-R223-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-executable-quickstart-authorization-review-v0
Route: UPDATE
Status: authorized / bounded-executable-quickstart
Date: 2026-05-31

Depends on:
- S3-R222-C5-S

---

## Decision

Authorize bounded C2-I implementation:

```text
Card: S3-R223-C2-I
Track: experimental-executable-quickstart-v0
```

The implementation must produce a narrow executable quickstart, not only a
compile quickstart:

```text
.ig source -> compile -> .igapp -> delegated experimental runtime harness
```

Compile-only output is not accepted as success. If the compiler-emitted
`.igapp` cannot be executed because of an artifact-format mismatch, C2-I may
use an example-local adapter/normalizer only inside the authorized examples
directory. If that still cannot produce delegated runtime execution, C2-I must
return HOLD with an exact blocker.

No canonical runtime, production runtime, public runtime, stable API, release,
Spark, or Reference Runtime authority opens.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round222-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-use-productization-route-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-use-productization-route-options-v0.md`
- `igniter-lang/docs/tracks/experimental-use-current-surface-and-gap-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-use-productization-pressure-v0.md`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/lib/igniter_lang/assembler.rb`
- `igniter-lang/bin/igc`
- `igniter-lang/source/add.ig`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`

---

## Authorization Rationale

R222 already accepted the route and recorded the market-pressure change:
Igniter needs a first honest executable developer experience, not another
proof-only layer and not a compile-only artifact demo.

The current surface is enough to authorize a bounded implementation because:

- `igc compile SOURCE --out OUT.igapp` already exists;
- `IgniterLang.compile(...)` already writes `.igapp` artifacts through the
  assembler;
- `source/add.ig` is a bounded CORE success seed;
- proof RuntimeMachine can load `.igapp` directories through
  `RuntimeMachineMemoryProof::CompiledProgram.load_igapp`;
- there is no `examples/` directory, so an examples-first slice closes the
  highest-friction gap without changing public API;
- RuntimeSmoke remains proof-context only and does not need productization for
  this route.

The correct risk control is not to slow down into another broad survey. The
control is to keep all writes example-local and make execution proof mandatory.

---

## Allowed Write Scope

Authorized C2-I may write only:

- `igniter-lang/examples/experimental_executable_quickstart_v0/**`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-v0.md`

All generated quickstart output must stay under:

- `igniter-lang/examples/experimental_executable_quickstart_v0/out/**`

or a temp directory created by the quickstart and named in the result packet.

---

## Read-Only / Closed Surfaces

Read-only for C2-I:

- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/lib/igniter_lang/assembler.rb`
- `igniter-lang/bin/igc`
- `igniter-lang/source/add.ig`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb`

Closed unless a later card explicitly opens them:

- `igniter-lang/lib/**`
- `igniter-lang/bin/igc`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/ruby-api.md`
- public docs
- body spec chapters
- RuntimeSmoke source, behavior, callback behavior, and result shape
- CompilerResult and CompilationReport fields
- report/result/receipt sidecars
- public API/CLI widening
- profile discovery/defaulting/finalization
- release/tag/push/publish/sign/deploy
- Spark integration
- counterfactual report/API or Option D reopening

---

## Source Fixture Policy

Use a single bounded CORE source:

- preferred: copy or equivalent of `igniter-lang/source/add.ig`;
- must be labeled as compiler-accepted CORE, not all-grammar support;
- must not include parser-only, temporal/TBackend, counterfactual, Spark,
  profile discovery, or public-demo pressure semantics.

C2-I may include the fixture inside the example directory so the quickstart is
self-contained.

---

## `.igapp` Output Policy

C2-I must compile the quickstart source into an example-local `.igapp`
directory.

Required:

- use the existing compile surface;
- keep output under example-local `out/` or temp output;
- record compile status and public result shape in the proof doc;
- do not add CLI flags;
- do not change compiler, assembler, CompilerResult, or CompilationReport.

---

## Delegated Experimental Runtime Boundary

Authorized:

- an example-local delegated runtime harness;
- direct read-only use of proof RuntimeMachine / `CompiledProgram` loading;
- example-local result JSON or summary JSON;
- example-local adapter/normalizer if needed for artifact-format mismatch.

Not authorized:

- Reference Runtime implementation;
- Runtime Specification implementation;
- RuntimeSmoke productization;
- changing RuntimeSmoke;
- changing proof RuntimeMachine source;
- claiming public runtime support;
- claiming production runtime support.

The delegated runtime harness must be described as:

```text
non-canonical
experimental
delegated
frontier/runtime-learning evidence
not Reference Runtime
not production runtime
not public runtime support
```

---

## Adapter / Normalizer Policy

Example-local adapter/normalizer work is authorized if and only if the
compiler-emitted `.igapp` shape differs from proof RuntimeMachine expectations.

Allowed:

- adapter code inside
  `igniter-lang/examples/experimental_executable_quickstart_v0/**`;
- read-only inspection of the generated `.igapp`;
- explicit mismatch report;
- normalized copy under example-local output;
- proof that adapter output is non-canonical quickstart evidence only.

Forbidden:

- modifying compiler output format;
- modifying assembler;
- modifying RuntimeSmoke;
- modifying `CompiledProgram`;
- treating adapter output as canonical `.igapp`;
- hiding mismatch in docs or result packet.

If an adapter is used, C2-I must record:

- original artifact location;
- normalized artifact location;
- exact fields transformed or supplied;
- why the adapter is example-local only;
- why no runtime/API authority is created.

---

## Executable Success Criteria

C2-I PASS requires all of:

- source fixture exists and is bounded;
- compile command/facade produces `.igapp`;
- delegated runtime harness loads executable artifact or example-local
  normalized artifact;
- delegated runtime harness evaluates `Add`;
- expected output is produced for sample input;
- output is confined to example-local or temp output;
- result packet states non-canonical delegated runtime status;
- pre-v1 / no-stable-API / non-production wording is present at point of use;
- forbidden phrase scan passes;
- all closed surfaces remain unchanged.

Expected sample input:

```text
a: 19
b: 23
expected sum: 42
```

---

## Compile-Only HOLD Criteria

Compile-only is HOLD, not PASS.

C2-I should HOLD if:

- compile succeeds but delegated runtime execution cannot be completed;
- artifact-format mismatch cannot be resolved example-locally;
- execution requires `lib/**`, RuntimeSmoke, compiler, assembler, API/CLI, or
  report/result changes;
- the only successful evidence is `.igapp` creation.

The HOLD packet must name:

- exact command that passed;
- exact command or load step that blocked;
- exact artifact path;
- exact missing or incompatible fields;
- whether a future adapter, compiler-output, or runtime-boundary route is
  recommended.

---

## Three-Runtime Wording

C2-I must preserve this distinction:

```text
Runtime Specification:
  Canonical/normative target. Closed to implementation in this slice.

Reference Runtime:
  Future canonical implementation candidate. Closed in this slice.

Delegated Experimental Runtime:
  Non-canonical quickstart harness. Authorized only as example-local learning
  evidence.
```

---

## Required Wording

The quickstart must include point-of-use wording equivalent to:

```text
This is an experimental pre-v1 quickstart. It demonstrates a bounded executable
path through a non-canonical delegated runtime harness. It is not stable API,
not production runtime support, not Reference Runtime support, and not a public
demo or Spark integration claim.
```

Allowed wording:

```text
experimental
alpha
pre-v1
subject to change
delegated experimental runtime
non-canonical runtime harness
not production-ready
no stable API guarantee
```

Forbidden phrase scan set:

```text
stable API
production-ready
public demo-ready
Spark-ready
Reference Runtime support
runtime-ready
production runtime
all grammar support
v1 compatibility
```

Forbidden phrases may appear only in explicit negation / non-claim blocks.

---

## Proof Matrix

C2-I must report:

- EXQ-1: source fixture exists and is narrowly labeled.
- EXQ-2: compile command/facade produces `.igapp`.
- EXQ-3: delegated experimental runtime harness executes selected fixture.
- EXQ-4: output value matches expected result.
- EXQ-5: output artifacts are confined to example-local or temp output.
- EXQ-6: any adapter/normalizer is example-local and non-canonical.
- EXQ-7: adapter mismatch, if any, is explicitly recorded.
- EXQ-8: RuntimeSmoke source/result shape remains unchanged.
- EXQ-9: `lib/**`, `bin/igc`, gemspec, README, and public docs remain
  unchanged.
- EXQ-10: CompilerResult / CompilationReport fields remain unchanged.
- EXQ-11: forbidden phrase scan passes.
- EXQ-12: pre-v1 / no-stable-API / non-production disclaimer is present.
- EXQ-13: release/public/Spark/API/production claims remain closed.
- EXQ-14: compile-only outcome, if encountered, is classified as HOLD.

---

## Required Command Matrix

Required:

```text
ruby -c igniter-lang/examples/
  experimental_executable_quickstart_v0/quickstart.rb

ruby igniter-lang/examples/
  experimental_executable_quickstart_v0/quickstart.rb

ruby -c igniter-lang/lib/igniter_lang/runtime_smoke.rb

ruby -c igniter-lang/experiments/runtime_machine_memory_proof/
  compiled_program.rb
```

Recommended if quickstart creates a result JSON:

```text
ruby -rjson -e 'JSON.parse(File.read(ARGV.fetch(0)))' PATH_TO_RESULT_JSON
```

C2-I may add additional example-local verification commands if useful.

---

## Explicit Answers

May C2-I begin in this round?

```text
Yes. C2-I is authorized with the bounded write scope above.
```

Must the quickstart be executable, not compile-only?

```text
Yes. Compile-only is HOLD evidence only.
```

May delegated experimental runtime be used?

```text
Yes. It is authorized as non-canonical example-local learning evidence only.
```

May example-local adapter/normalizer work be used if the compiler `.igapp`
format differs from proof RuntimeMachine expectations?

```text
Yes, but only under the example directory, with explicit mismatch disclosure
and no canonical/runtime/API authority.
```

Does Runtime Specification remain design/normative only?

```text
Yes.
```

Does Reference Runtime remain closed?

```text
Yes.
```

Does RuntimeSmoke source/result shape remain closed?

```text
Yes. RuntimeSmoke may be syntax-checked/read as a boundary reference, but not
changed or productized.
```

Do `lib/**`, `bin/igc`, gemspec, README, and public docs remain closed?

```text
Yes.
```

Do stable API, production, public demo, Spark, and release claims remain closed?

```text
Yes.
```

---

## Exact C2-I Implementation Boundary

```text
Card: S3-R223-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-executable-quickstart-v0

Route: UPDATE
Depends on:
- S3-R223-C1-A

Goal:
Implement the bounded experimental executable quickstart: one curated source,
one compile path, one delegated experimental runtime execution path, and one
compact proof/result packet.

Allowed write scope:
- igniter-lang/examples/experimental_executable_quickstart_v0/**
- igniter-lang/docs/tracks/experimental-executable-quickstart-v0.md

Read-only / closed:
- igniter-lang/lib/**
- igniter-lang/bin/igc
- igniter-lang/igniter_lang.gemspec
- igniter-lang/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/ruby-api.md
- igniter-lang/lib/igniter_lang/runtime_smoke.rb
- igniter-lang/lib/igniter_lang/compiler_result.rb
- igniter-lang/lib/igniter_lang/compilation_report.rb
- igniter-lang/lib/igniter_lang/assembler.rb
- igniter-lang/experiments/runtime_machine_memory_proof/**

Required behavior:
- provide one bounded Add-like `.ig` source fixture;
- compile it to example-local `.igapp`;
- execute it through an example-local delegated experimental runtime harness;
- use example-local adapter/normalizer only if artifact-format mismatch
  requires it;
- produce expected output `sum = 42` for `a = 19`, `b = 23`;
- write proof/result JSON under example-local output if useful;
- include point-of-use alpha/pre-v1/no-stable-API/non-production wording;
- preserve all closed surfaces.

PASS requires executable evidence. Compile-only is HOLD.

Deliver:
- implementation/proof doc in `igniter-lang/docs/tracks/`
- quickstart files under the authorized example directory
- command matrix result
- result JSON if produced
- PASS / HOLD / FAIL with exact blocker if not executable
```
