# Delegated Experimental Runtime Compiler To IVM Adapter Authorization Review v0

Card: S3-R225-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-compiler-to-ivm-adapter-authorization-review-v0
Route: UPDATE
Status: authorized-bounded-playground-proof
Date: 2026-05-31

Depends on:
- S3-R224-C5-S

---

## Decision

Authorize a bounded playground-only compiler-to-IVM adapter proof.

Authorization:

```text
S3-R225-C2-I may begin in this round.
```

Allowed proof question:

```text
Can compiler-emitted `.igapp` / `semantic_ir_program.json` be mapped into the
playground IVM AST/bytecode path and executed through IVM, without changing
mainline runtime, API, CLI, package, public, Spark, production, or release
surfaces?
```

Authority boundary:

```text
This is adapter-fit evidence only.
It is not Reference Runtime support.
It is not public runtime support.
It is not production runtime support.
It does not authorize `igc run`.
```

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round224-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-boundary-and-packaging-decision-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-candidate-intake-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-current-surface-facts-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-acceptance-decision-v0.md`
- `igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/quickstart_result.json`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/assembler.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `playgrounds/igniter-runtime/docs/ivm-poc-prototype.md`
- `playgrounds/igniter-runtime/examples/demo.rb`
- `playgrounds/igniter-runtime/lib/ivm.rb`
- `playgrounds/igniter-runtime/lib/ivm/compiler.rb`
- `playgrounds/igniter-runtime/lib/ivm/vm.rb`
- `playgrounds/igniter-runtime/lib/ivm/instructions.rb`
- `playgrounds/igniter-runtime/lib/ivm/tbackend.rb`

Local read-only verification:

```text
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/demo.rb
=> PASS demo; 10 IVM instructions; Timeline A => 200; Timeline B => 1000.
```

Scope fact:

```text
Parent repo currently treats `playgrounds/igniter-runtime/` as ignored
scratch (`!! playgrounds/igniter-runtime/`). Therefore durable Main Line
evidence for C2-I must be recorded in the mainline track doc even if
playground files are changed.
```

---

## Rationale

R224 already accepted:

- R223 quickstart executable evidence remains accepted;
- IVM is sandbox/playground delegated experimental runtime candidate evidence;
- IVM sits beside, not inside, accepted R223 quickstart evidence;
- IVM does not yet execute compiler-emitted `.igapp`;
- the next runtime-productization question is adapter fit.

The proof is worth opening now because it tests the load-bearing bridge:

```text
compiler output -> adapter -> IVM bytecode -> IVM execution
```

It is safer and more valuable than helper extraction as the immediate next
route, because helper extraction improves developer ergonomics while adapter
proof tests whether the delegated bytecode runtime can consume the language's
actual artifact shape.

---

## Authorized C2-I Boundary

```text
Card: S3-R225-C2-I
Skill: IDD Agent Protocol
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0
Route: UPDATE
```

Allowed write scope:

```text
playgrounds/igniter-runtime/**
igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0.md
```

Read-only / closed unless explicitly authorized later:

```text
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
igniter-lang/examples/experimental_executable_quickstart_v0/**
```

Forbidden write scope:

```text
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/examples/experimental_executable_quickstart_v0/**
```

---

## Source `.igapp` Policy

C2-I may use compiler-emitted `.igapp` source evidence in either or both of
these ways:

1. Copy accepted read-only R223 `.igapp` artifacts into
   `playgrounds/igniter-runtime/out/**` before adapting them.
2. Generate fresh playground-local `.igapp` artifacts under
   `playgrounds/igniter-runtime/out/**` by invoking existing compiler surfaces
   as read-only dependencies.

Requirements:

- do not mutate accepted R223 quickstart files or outputs;
- record source artifact path, generation/copy method, and SHA256 digest;
- record `semantic_ir_program.json` path and SHA256 digest;
- keep all generated proof artifacts under `playgrounds/igniter-runtime/out/**`;
- if artifact shape blocks execution, return HOLD with exact adapter-gap facts.

The proof may create playground-local `.ig` fixtures only under
`playgrounds/igniter-runtime/**`.

---

## Adapter Shape

C2-I may choose either route:

```text
SemanticIR / .igapp -> IVM AST -> IVM bytecode
```

or:

```text
SemanticIR / .igapp -> IVM bytecode directly
```

The proof must record which route was used.

Preferred first route:

```text
SemanticIR / .igapp -> IVM AST -> IVM bytecode
```

Reason:

```text
The current IVM compiler already consumes a simplified expression AST. Mapping
to that AST first exposes the exact semantic gap before optimizing toward a
direct bytecode compiler.
```

---

## Supported Subset

Minimum expected support:

- compiler-emitted `.igapp` directory;
- `semantic_ir_program.json`;
- one contract artifact;
- integer literal or literal-like value;
- input/ref reads;
- monomorphic integer addition if present;
- selected output extraction sufficient for the Add-like path.

Optional support if artifact/fixture shape permits:

- `if_expr`;
- IVM `JMP_UNLESS` / `JMP` lazy branch execution;
- `stdlib.integer.gt`;
- `stdlib.integer.add` beyond the Add fixture;
- `tbackend_read` / temporal read mapped to IVM `temporal_read` /
  `OP_LOAD_AS_OF`.

Do not fake support. If a node/operator is not mapped, it must be listed as an
unsupported adapter gap.

---

## Unsupported Node Policy

Unsupported selected-path nodes must fail closed with a playground-local error.

Unsupported non-selected branch nodes:

- may be used only if a compatible branch fixture exists;
- must not fire when the branch is not selected;
- must be recorded as lazy-branch evidence only, not public runtime support.

If no compatible branch fixture can be created without crossing scope, record:

```text
lazy_branch_fixture_gap: true
```

and keep the proof focused on `.igapp -> IVM` adapter fit.

---

## Lazy Branch Policy

Lazy branch proof is valuable but not mandatory for C2-I acceptance if the
compiler-emitted artifact shape cannot produce a compatible branch fixture
inside the authorized scope.

If attempted, it must prove:

- condition evaluates before branch execution;
- IVM bytecode uses jump semantics;
- selected branch executes;
- non-selected branch does not execute;
- unknown/unsupported non-selected branch does not fire.

If not attempted, the proof must explicitly record why:

```text
not_attempted / fixture_gap / artifact_shape_gap / syntax_gap / other
```

---

## Trace And Wording Boundary

Allowed wording:

```text
valid-time trace
observation-shaped trace
playground-local observation envelope
adapter-fit evidence
delegated experimental runtime evidence
```

Forbidden overclaim wording:

```text
signed
tamper-evident
AT-10 compliant
fully bitemporal
canonical audit
security authority
Reference Runtime
public runtime support
production runtime support
stable API
production-ready
Spark-ready
release evidence
```

If existing playground demo output still prints stronger wording, C2-I may
leave the demo text unchanged, but the C2-I result packet and track doc must
not promote those claims as accepted evidence.

---

## Required Proof Matrix

- AIP-1: `.igapp` / `semantic_ir_program.json` source artifact identified and
  SHA256 recorded.
- AIP-2: adapter reads compiler-emitted artifact without mutating accepted
  quickstart artifacts.
- AIP-3: supported CORE Add or equivalent expression maps to IVM AST or direct
  bytecode.
- AIP-4: IVM compiler emits bytecode from adapter output, or direct adapter
  emits bytecode with equivalent instruction listing.
- AIP-5: IVM executes adapted bytecode and returns expected value.
- AIP-6: unsupported selected-path node fails closed with playground-local
  error only.
- AIP-7: unsupported non-selected branch does not fire if a compatible lazy
  branch fixture exists; otherwise records explicit fixture gap.
- AIP-8: `if_expr` / branch execution uses IVM jump semantics if fixture
  exists; otherwise records explicit fixture gap.
- AIP-9: result wording avoids signed/tamper-evident/AT-10/fully-bitemporal/
  public-runtime overclaim.
- AIP-10: accepted R223 evidence is not rewritten.
- AIP-11: no `igniter-lang/lib/**`, `bin/igc`, RuntimeSmoke,
  CompilerResult, CompilationReport, gemspec, README, public docs, Spark, or
  release surface is changed.
- AIP-12: generated output is labeled adapter-fit evidence only, not Reference
  Runtime, public runtime, production runtime, stable API, Spark, or release
  evidence.

PASS requires:

```text
AIP-1..AIP-6 and AIP-9..AIP-12 PASS.
```

AIP-7/AIP-8 may be:

```text
PASS or RECORDED_GAP
```

but must not be silently omitted.

---

## Command Matrix

Required:

```text
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/demo.rb
ruby -c playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb
git diff --check
git status --short
```

Required if playground nested git is used:

```text
git -C playgrounds/igniter-runtime status --short
```

Optional read-only regression:

```text
ruby -c igniter-lang/lib/igniter_lang/runtime_smoke.rb
ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
```

The proof may add more playground-local commands if needed.

---

## Result Packet Shape

C2-I should produce a compact track doc with:

```text
[D] Decisions
[S] Shipped / Signals
[T] Tests / Proofs
[R] Risks / Recommendations
[Next] Suggested next slice
```

It should also produce a machine-readable playground-local summary JSON if
practical, preferably under:

```text
playgrounds/igniter-runtime/out/compiler_to_ivm_adapter_proof/
```

Expected summary fields:

- `kind`;
- `card`;
- `track`;
- `overall`;
- `evidence_class`;
- `source_igapp_path`;
- `source_igapp_sha256`;
- `semantic_ir_program_sha256`;
- `adapter_route`;
- `supported_nodes`;
- `unsupported_nodes`;
- `bytecode_instruction_count`;
- `execution_status`;
- `expected_output`;
- `actual_output`;
- `lazy_branch_status`;
- `closed_surface_scan`;
- `non_claims`.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| May C2-I begin in this round? | Yes. |
| Are writes under `playgrounds/igniter-runtime/**` allowed? | Yes, as playground-only proof writes. |
| May the mainline track doc be written? | Yes, exactly `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0.md`. |
| Does `igniter-lang/lib/**` remain closed? | Yes. |
| Do `bin/igc`, gemspec, README, and public docs remain closed? | Yes. |
| Do RuntimeSmoke, CompilerResult, and CompilationReport remain closed? | Yes. |
| Does IVM remain non-canonical delegated experimental evidence only? | Yes. |
| May generated outputs be called adapter-fit evidence only? | Yes. They must not be called public/runtime/release evidence. |
| Does `igc run` remain closed? | Yes. |
| Does Reference Runtime remain closed? | Yes. |
| Do stable API, production, public demo, Spark, and release claims remain closed? | Yes. |

---

## Closed Surfaces

Remain closed:

- `igniter-lang/lib/**`;
- `igniter-lang/bin/igc`;
- `igniter-lang/igniter_lang.gemspec`;
- README/public docs/body spec;
- RuntimeSmoke source, behavior, callback behavior, result shape, and
  productization;
- CompilerResult / CompilationReport fields;
- report/result/receipt/cache authority;
- public API/CLI widening;
- `igc run`;
- Reference Runtime;
- Runtime Specification implementation;
- stable API / v1 compatibility claim;
- production readiness;
- public demo claim;
- Spark integration;
- release execution, publish/yank/tag/push/deploy.

---

## Compact Decision Packet

```text
[D]
- Authorize S3-R225-C2-I as playground-only compiler-to-IVM adapter proof.
- Keep IVM delegated experimental, non-canonical, and not Reference Runtime.
- Keep mainline runtime/API/CLI/package/public surfaces closed.

[S]
- R224 selected adapter fit as the next highest-leverage runtime question.
- IVM demo remains executable as sandbox candidate evidence.
- Parent repo ignores `playgrounds/igniter-runtime/`, so the mainline proof
  track doc is required for durable evidence.

[T]
- Local read-only IVM demo command PASS.
- No implementation performed by this card.

[R]
- Avoid signed/tamper-evident/AT-10/fully-bitemporal overclaims.
- If SemanticIR shape blocks adapter execution, return HOLD with exact gap
  matrix rather than widening scope.

[Next]
- Dispatch S3-R225-C2-I:
  delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0
```
