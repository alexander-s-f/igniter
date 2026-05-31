# Delegated Experimental Runtime Compiler To IVM Adapter Acceptance Decision v0

Card: S3-R225-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-compiler-to-ivm-adapter-acceptance-decision-v0
Route: UPDATE
Status: accepted / adapter-hardening-next
Date: 2026-05-31

Depends on:
- S3-R225-C2-I
- S3-R225-C3-X

---

## Decision

Accept the playground-only compiler-to-IVM adapter proof.

Accepted evidence class:

```text
adapter-fit evidence only
delegated experimental runtime evidence only
```

Not accepted:

```text
Reference Runtime support
public runtime support
production runtime support
stable API
public demo
Spark integration
release evidence
igc run
RuntimeSmoke productization
```

The proof is accepted with two non-blocking notes:

- AN-1: `source_igapp_sha256` currently records the
  `semantic_ir_program.json` digest, not a directory-level `.igapp` digest.
- AN-2: next-route sequencing must be explicit; FFI acceleration is deferred.

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-authorization-review-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-compiler-to-ivm-adapter-pressure-v0.md`
- `playgrounds/igniter-runtime/out/compiler_to_ivm_adapter_proof/summary.json`
- `igniter-lang/docs/tracks/stage3-round224-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-boundary-and-packaging-decision-v0.md`

Local verification also run:

```text
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb
=> PASS; AIP 12/12; output 42

rake spec
=> 686 examples, 0 failures

git diff --check
=> PASS
```

Repository status verified:

```text
parent repo: clean
playgrounds/igniter-runtime nested repo: clean
```

---

## Exact Changed Files

Mainline tracked files accepted from C2-I / C3-X:

```text
igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0.md
igniter-lang/docs/discussions/delegated-experimental-runtime-compiler-to-ivm-adapter-pressure-v0.md
igniter-lang/docs/discussions/README.md
```

Playground nested repo accepted from C2-I:

```text
playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb
playgrounds/igniter-runtime/out/compiler_to_ivm_adapter_proof/summary.json
playgrounds/igniter-runtime/out/source_igapps/**
```

Playground nested commit:

```text
ebe83bf Add experimental proof stage for compiler-to-IVM adapter with full artifact tracking, lazy branch evaluation, and unsupported node handling
```

Scope note:

```text
The playground is ignored by the parent repo and has its own nested git state.
The durable Main Line record is the mainline track/discussion docs plus this
decision. Playground artifacts remain sandbox evidence only.
```

---

## Command Matrix Result

Accepted command results:

```text
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/demo.rb
=> PASS baseline IVM demo

ruby -c playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb
=> Syntax OK

ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb
=> PASS; 12/12 AIP; actual_output=42

rake spec
=> 686 examples, 0 failures

git diff --check
=> PASS

git status --short
=> clean

git -C playgrounds/igniter-runtime status --short
=> clean
```

---

## AIP Result Record

| Check | Result | Acceptance note |
| --- | --- | --- |
| AIP-1 source artifact identified and SHA recorded | PASS | Digest recorded for `semantic_ir_program.json`; see AN-1. |
| AIP-2 source artifacts not mutated | PASS | R223 Add artifact digest matches copied playground artifact. |
| AIP-3 CORE Add maps to IVM AST | PASS | `stdlib.integer.add` maps to IVM `binary_op +`. |
| AIP-4 IVM bytecode emitted | PASS | 4 opcodes: `LOAD_REF a`, `LOAD_REF b`, `ADD`, `RET`. |
| AIP-5 IVM executes adapted bytecode | PASS | Inputs `a=19`, `b=23`; output `42`. |
| AIP-6 unsupported selected node fails closed | PASS | `field_access` raises playground-local `UnsupportedNodeError`. |
| AIP-7 unsupported non-selected branch does not fire | PASS | Verified by playground branch fixture; see lazy branch note below. |
| AIP-8 branch uses IVM jump semantics | PASS | `OP_JMP_UNLESS` and `OP_JMP` verified. |
| AIP-9 safe wording discipline | PASS | No active accepted output promotes forbidden claims. |
| AIP-10 R223 evidence pristine | PASS | Quickstart result remains `overall: PASS`; parent git clean. |
| AIP-11 mainline files unmodified | PASS | External `git status` / `git diff --check` confirm. |
| AIP-12 delegated evidence only | PASS | `evidence_class` and non-claims present. |

Accepted proof status:

```text
12/12 PASS
```

---

## Artifact And Digest Status

Accepted source artifact:

```text
igniter-lang/examples/experimental_executable_quickstart_v0/out/Add.igapp/semantic_ir_program.json
```

Accepted digest:

```text
sha256:264b0b4043e294a52cc90e99eddd17098481d4e71d09390a357888ceef8aa62b
```

Digest clarification:

```text
`source_igapp_sha256` in the C2-I summary is accepted as the digest of the
key source file `semantic_ir_program.json`, not as a canonical digest of the
entire `.igapp` directory.
```

Future proofs should either:

- rename that field to `semantic_ir_program_sha256`; or
- add a distinct manifest/directory-level digest.

This is not a blocker for R225 acceptance.

---

## Adapter Support / Gap Matrix

Accepted supported subset:

- `literal`;
- `ref`;
- `stdlib.integer.add` mapped to IVM `binary_op +`;
- legacy `apply (stdlib.integer.add)` in playground branch fixtures;
- `if_expr` mapping in playground branch fixtures;
- IVM `OP_JMP_UNLESS` / `OP_JMP` branch lowering.

Accepted unsupported subset:

- `stdlib.integer.gt`;
- `field_access`;
- unsupported selected-path nodes fail closed with playground-local
  `UnsupportedNodeError`.

Required clarification:

```text
The Add path is proven from compiler-emitted `semantic_ir_program.json`.
The lazy branch proof is accepted as supplemental playground branch evidence,
using existing proof `.igapp` fixtures with `semantic_ir.json`, not as a fresh
compiler-emitted `semantic_ir_program.json` branch proof.
```

This is not a blocker. It defines the next route.

---

## IVM Bytecode / Execution Status

Accepted Add bytecode:

```text
0000 LOAD_REF "a"
0001 LOAD_REF "b"
0002 ADD
0003 RET
```

Accepted execution:

```text
input:  {"a" => 19, "b" => 23}
output: 42
status: ok
```

This is real executable evidence inside the delegated experimental IVM
playground.

It is not public runtime support.

---

## Lazy Branch Status

Accepted status:

```text
lazy_branch_status: verified
```

Qualifier:

```text
The lazy branch proof is supplemental playground evidence. It verifies IVM jump
semantics and non-selected branch silence using existing proof fixtures. It
does not yet prove a fresh compiler-emitted `semantic_ir_program.json` if_expr
fixture through the adapter.
```

Therefore the best next route is not FFI acceleration yet. The next route
should harden adapter coverage around compiler-emitted branch/comparison
artifacts.

---

## Wording / Non-Claims Status

Accepted wording:

```text
adapter-fit evidence only
delegated experimental runtime evidence only
sandbox-local valid-time observation-shaped traces
```

Rejected / closed wording:

```text
Reference Runtime support
public runtime support
production runtime support
stable API
public demo
Spark integration
release evidence
signed
tamper-evident
AT-10 compliant
fully bitemporal
canonical audit/security authority
```

---

## Accepted R223 Evidence Immutability

Accepted.

R223 quickstart evidence remains unchanged and valid:

```text
quickstart_result.json overall: PASS
Add `.igapp` source artifact read-only
parent git status clean
```

R225 does not supersede R223. It adds delegated runtime adapter-fit evidence.

---

## Closed-Surface Scan Status

Accepted.

Confirmed closed:

- `igniter-lang/lib/**`;
- `igniter-lang/bin/igc`;
- `igniter-lang/igniter_lang.gemspec`;
- README/public docs/body spec;
- RuntimeSmoke source/result/productization;
- CompilerResult / CompilationReport;
- report/result/receipt/cache authority;
- public API/CLI widening;
- `igc run`;
- Reference Runtime;
- stable API / production / public demo / Spark / release claims.

---

## Next Route Decision

Open next:

```text
Card: S3-R226-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-ivm-adapter-branch-coverage-authorization-review-v0
Route: UPDATE
```

Purpose:

```text
Decide whether a bounded playground-only adapter hardening proof may begin for
compiler-emitted branch/comparison coverage: fresh or copied
`semantic_ir_program.json` branch fixture, explicit `stdlib.integer.gt` stance,
unsupported selected/non-selected path behavior, and digest field cleanup.
```

Why this route:

- FFI/C acceleration is attractive but premature before branch/comparison
  adapter coverage is source-backed.
- Reusable helper remains valuable, but helper extraction should wait until the
  adapter's branch/comparison boundary is less ambiguous.
- Runtime Specification slice is valid later, after one more adapter-hardening
  proof clarifies the semantic subset.
- Reference Runtime remains too early.

Deferred routes:

- playground-only FFI/C/Rust acceleration research;
- reusable delegated runtime helper authorization review;
- Runtime Specification input slice;
- Reference Runtime boundary survey.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is the playground-only compiler-to-IVM adapter proof accepted? | Yes. |
| May generated output be called adapter-fit evidence only? | Yes. |
| Is this Reference Runtime support? | No. |
| Is this public runtime support? | No. |
| Does `igc run` remain closed? | Yes. |
| Does RuntimeSmoke productization remain closed? | Yes. |
| Do stable API, production, public demo, Spark, and release claims remain closed? | Yes. |
| What next route should open? | `delegated-experimental-runtime-ivm-adapter-branch-coverage-authorization-review-v0`. |

---

## Compact Decision Packet

```text
[D]
- Accept S3-R225-C2-I adapter proof.
- Accept 12/12 AIP PASS as adapter-fit evidence only.
- Defer FFI acceleration.
- Open adapter hardening / compiler-emitted branch coverage authorization
  review next.

[S]
- Add path: compiler-emitted semantic_ir_program.json -> IVM AST -> 4-opcode
  bytecode -> IVM execution -> 42.
- Lazy branch: verified as supplemental playground branch evidence via IVM
  jumps and non-selected branch silence.
- Unsupported selected-path nodes fail closed locally.

[T]
- Adapter proof command PASS.
- rake spec PASS: 686 examples, 0 failures.
- git diff --check PASS.
- parent and nested playground git status clean.

[R]
- Do not call this Reference Runtime or public runtime support.
- Clarify future digest fields.
- Prove compiler-emitted branch/comparison coverage before FFI acceleration or
  helper extraction.

[Next]
- S3-R226-C1-A:
  delegated-experimental-runtime-ivm-adapter-branch-coverage-authorization-review-v0
```
