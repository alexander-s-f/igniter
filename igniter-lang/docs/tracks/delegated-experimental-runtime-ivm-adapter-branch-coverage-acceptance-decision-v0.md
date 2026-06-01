# Delegated Experimental Runtime IVM Adapter Branch Coverage Acceptance Decision v0

Card: S3-R226-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-ivm-adapter-branch-coverage-acceptance-decision-v0
Route: UPDATE
Status: accepted / ffi-acceleration-authorization-next
Date: 2026-06-01

Depends on:
- S3-R226-C2-I
- S3-R226-C3-X

---

## Decision

Accept the playground-only IVM adapter branch/comparison hardening proof.

Accepted evidence class:

```text
branch/comparison adapter-hardening evidence only
delegated experimental runtime evidence only
playground-only non-canonical evidence
```

Not accepted:

```text
Reference Runtime support
public runtime support
production runtime support
stable API
igc run
RuntimeSmoke productization
mainline runtime/API/CLI/package changes
release evidence
```

Next route:

```text
S3-R227-C1-A
delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-authorization-review-v0
```

This is an authorization review only. It may decide whether a playground-only
FFI/C/Rust bytecode acceleration research pass may begin. It does not itself
authorize implementation.

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-authorization-review-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-ivm-adapter-branch-coverage-pressure-v0.md`
- `playgrounds/igniter-runtime/out/ivm_adapter_branch_coverage_proof/summary.json`
- `igniter-lang/docs/tracks/stage3-round225-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-acceptance-decision-v0.md`
- `playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb`
- `playgrounds/igniter-runtime/lib/ivm/instructions.rb`
- `playgrounds/igniter-runtime/lib/ivm/compiler.rb`
- `playgrounds/igniter-runtime/lib/ivm/vm.rb`

Local verification run during C4-A:

```text
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb
=> PASS; AIP 12/12

ruby -c playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb
=> Syntax OK

ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb
=> PASS; BCP 15/15

git diff --check
=> PASS

git status --short
=> clean

git -C playgrounds/igniter-runtime status --short
=> clean
```

---

## Exact Changed Files Accepted

Mainline tracked files accepted from R226:

```text
igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-authorization-review-v0.md
igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0.md
igniter-lang/docs/discussions/delegated-experimental-runtime-ivm-adapter-branch-coverage-pressure-v0.md
igniter-lang/docs/discussions/README.md
```

Playground nested repo accepted from C2-I:

```text
playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb
playgrounds/igniter-runtime/fixtures/minimal_gt.ig
playgrounds/igniter-runtime/fixtures/minimal_if_else.ig
playgrounds/igniter-runtime/lib/ivm/compiler.rb
playgrounds/igniter-runtime/lib/ivm/instructions.rb
playgrounds/igniter-runtime/lib/ivm/vm.rb
playgrounds/igniter-runtime/out/ivm_adapter_branch_coverage_proof/**
playgrounds/igniter-runtime/out/test_compile.igapp/**
playgrounds/igniter-runtime/out/test_gt_compile.igapp/**
```

Playground nested commit accepted:

```text
6e6f3a4 Add comparison (`>`) and conditional (`if/else`) operators in compiler and VM; add proof-of-concept contracts
```

Scope note:

```text
The playground nested repo remains sandbox evidence only. The durable Main
Line decision record is the mainline track/discussion docs and this decision.
```

---

## Command Matrix Result

Accepted command matrix:

```text
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb
=> PASS; 12/12 R225 adapter regression checks

ruby -c playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb
=> Syntax OK

ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb
=> PASS; 15/15 branch/comparison checks

git diff --check
=> PASS

git status --short
=> clean

git -C playgrounds/igniter-runtime status --short
=> clean
```

C2-I also recorded:

```text
rake spec
=> 686 examples, 0 failures
```

That full suite was accepted from the C2-I packet; it was not rerun in C4-A.

---

## BCP Result Record

| Check | Result | Acceptance note |
| --- | --- | --- |
| BCP-1 | PASS | Fresh source-backed branch/comparison artifacts identified. |
| BCP-2 | PASS | `semantic_ir_program_sha256` and manifest digest are separated. |
| BCP-3 | PASS | Fresh compile succeeded for `minimal_if_else.ig` and `minimal_gt.ig`. |
| BCP-4 | PASS | `if_expr` maps to IVM AST / bytecode route. |
| BCP-5 | PASS | IVM bytecode includes `OP_JMP_UNLESS` and `OP_JMP`. |
| BCP-6 | PASS | Selected branch executes and returns expected value. |
| BCP-7 | PASS | Non-selected branch remains silent and returns alternate value. |
| BCP-8 | PASS | Unsupported selected-path node fails closed with playground error. |
| BCP-9 | PASS | Unsupported non-selected-path node is jumped over. |
| BCP-10 | PASS | `stdlib.integer.gt` stance is explicit: `mapped`. |
| BCP-11 | PASS | `OP_GT` tested true and false in playground VM. |
| BCP-12 | PASS | R225 Add adapter proof still passes. |
| BCP-13 | PASS | R223/R225 accepted evidence remains pristine. |
| BCP-14 | PASS | Closed surfaces remain unchanged. |
| BCP-15 | PASS | Non-claims and wording discipline preserved. |

Accepted proof status:

```text
15/15 PASS
```

---

## Evidence Record

Source artifact status:

```text
fresh playground-local compile
minimal_if_else.ig -> fresh_if_else.igapp
minimal_gt.ig -> fresh_gt.igapp
```

Digest status:

```text
semantic_ir_program_sha256:
  1526337ba19eaa83671eeae434f77a6f401bb846177a2b6fa6cf39972c7938fa

source_igapp_manifest_sha256_or_null:
  29e65165bc4fe3a6844a09907ac0454e02218262679b73d886e636d82c8c1766
```

Digest cleanup status:

```text
accepted
R225 digest ambiguity resolved
file digest and manifest digest are distinct
```

`stdlib.integer.gt` stance:

```text
mapped
stdlib.integer.gt -> binary_op ">" -> OP_GT
```

Branch behavior status:

```text
selected_branch_status: verified_executes
non_selected_branch_status: verified_silent
branch bytecode: OP_JMP_UNLESS / OP_JMP / RET
```

Unsupported node status:

```text
selected unsupported path: fail-closed via OP_UNSUPPORTED / ExecutionError
non-selected unsupported path: jumped over; no failure
```

Closed-surface scan status:

```text
igniter-lang/lib/**: unchanged
bin/igc: unchanged
gemspec: unchanged
RuntimeSmoke: unchanged
CompilerResult / CompilationReport: unchanged
public docs / README: unchanged
```

---

## Explicit Answers

Whether branch/comparison hardening proof is accepted:

```text
Yes. Accepted.
```

Whether generated output may be called adapter-hardening evidence only:

```text
Yes. Generated output may be called branch/comparison adapter-hardening
evidence only, and delegated experimental runtime evidence only.
```

Whether this is Reference Runtime support:

```text
No. It is not Reference Runtime support.
```

Whether this is public runtime support:

```text
No. It is not public runtime support.
```

Whether `igc run` remains closed:

```text
Yes. `igc run` remains closed.
```

Whether RuntimeSmoke productization remains closed:

```text
Yes. RuntimeSmoke source, result shape, and productization remain closed.
```

Whether reusable helper extraction remains closed or opens next:

```text
Reusable helper extraction remains closed for the next card. It remains useful
for TTEU and examples ergonomics, but the next route prioritizes bytecode
runtime speed/shape evidence now that branch/comparison adapter hardening is
complete.
```

Whether FFI/C acceleration remains closed or opens next:

```text
FFI/C/Rust acceleration remains closed to implementation now, but an
authorization review opens next to decide whether a playground-only
acceleration research proof may begin.
```

Whether stable API, production, public demo, Spark, and release claims remain
closed:

```text
Yes. All remain closed.
```

What next route should open:

```text
S3-R227-C1-A
delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-authorization-review-v0
```

---

## Next Route Rationale

R226 closes the adapter-hardening blocker that kept FFI/C acceleration deferred
after R225:

- fresh compiler-emitted branch fixture now exists;
- digest ambiguity is resolved;
- `stdlib.integer.gt` is mapped and tested;
- selected/non-selected branch behavior is source-backed;
- unsupported selected/non-selected behavior is honest;
- R223/R225 evidence remains immutable.

Reusable helper extraction remains a good developer-ergonomics route, and a
Runtime Specification input slice remains important. But the runtime momentum
question is now sharper:

```text
Can the delegated IVM bytecode path escape Ruby-loop overhead without creating
mainline runtime authority?
```

That question belongs in a playground-only FFI/C/Rust acceleration
authorization review, not in direct implementation.

---

## Next Dispatch Recommendation

```text
Card: S3-R227-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-ivm-ffi-bytecode-acceleration-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R226-C5-S

Goal:
Decide whether a bounded playground-only IVM bytecode acceleration research
proof may begin, now that compiler-to-IVM adapter branch/comparison hardening
is accepted.

Scope:
- Read:
  - igniter-lang/docs/tracks/stage3-round226-status-curation-v0.md
  - igniter-lang/docs/tracks/
    delegated-experimental-runtime-ivm-adapter-branch-coverage-acceptance-decision-v0.md
  - igniter-lang/docs/tracks/
    delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0.md
  - igniter-lang/docs/discussions/
    delegated-experimental-runtime-ivm-adapter-branch-coverage-pressure-v0.md
  - playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb
  - playgrounds/igniter-runtime/out/ivm_adapter_branch_coverage_proof/
    summary.json
  - playgrounds/igniter-runtime/lib/ivm/**
- Decide:
  - authorize bounded playground-only FFI/C/Rust acceleration research proof;
  - authorize only design/prep;
  - hold pending bytecode ABI / toolchain clarification;
  - redirect to reusable helper extraction authorization review;
  - redirect to Runtime Specification input slice;
  - pause.
- If authorizing a proof, define exact:
  - allowed write scope;
  - native boundary policy;
  - bytecode ABI/input/output policy;
  - build/toolchain policy;
  - benchmark policy;
  - correctness parity matrix against Ruby IVM;
  - branch/lazy semantics matrix;
  - unsupported node behavior matrix;
  - no-authority wording;
  - closed surfaces.
- Must explicitly answer:
  - whether C2-I may begin in that round;
  - whether writes under `playgrounds/igniter-runtime/**` are enough;
  - whether native/C/Rust files may be added under playground only;
  - whether any `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public
    docs, RuntimeSmoke, CompilerResult, or CompilationReport edits are allowed;
  - whether accelerated execution remains delegated experimental evidence
    only;
  - whether Reference Runtime, public runtime support, `igc run`, stable API,
    production, Spark, and release claims remain closed.

Do not:
- implement acceleration in this card;
- authorize mainline runtime/API/CLI/package changes;
- authorize public runtime support;
- authorize Reference Runtime implementation;
- authorize RuntimeSmoke productization;
- authorize release execution or public claims.

Deliver:
- Authorization decision doc in `igniter-lang/docs/tracks/`
- Compact decision summary
- If authorized: exact proof boundary
- If held/redirected: blocker list
```

---

## Closed Surfaces

Remain closed after this decision:

- `igniter-lang/lib/**`;
- `igniter-lang/bin/igc`;
- `igniter-lang/igniter_lang.gemspec`;
- README/public docs/body spec edits;
- RuntimeSmoke productization;
- `CompilerResult` / `CompilationReport` / report / receipt / cache authority;
- public API/CLI widening;
- `igc run`;
- Reference Runtime implementation;
- Runtime Specification implementation;
- reusable helper extraction implementation;
- FFI/C/Rust acceleration implementation until a later card explicitly
  authorizes it;
- stable API or v1 compatibility claim;
- production readiness claim;
- public demo/support/all-grammar claim;
- Spark authority or integration;
- release execution, publish/yank/tag/push/deploy.
