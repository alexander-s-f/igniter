# Delegated Experimental Runtime IVM Adapter Branch Coverage Authorization Review v0

Card: S3-R226-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-ivm-adapter-branch-coverage-authorization-review-v0
Route: UPDATE
Status: authorized
Date: 2026-06-01

Depends on:
- S3-R225-C5-S

---

## Decision

Authorize a bounded playground-only IVM adapter branch/comparison hardening
proof.

Authorized evidence class:

```text
branch/comparison adapter-hardening evidence only
delegated experimental runtime evidence only
playground-only non-canonical evidence
```

This authorization opens C2-I only. It does not authorize mainline runtime,
CLI, package, RuntimeSmoke, Reference Runtime, FFI/C acceleration, reusable
helper extraction, public docs, or release work.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round225-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-compiler-to-ivm-adapter-pressure-v0.md`
- `playgrounds/igniter-runtime/out/compiler_to_ivm_adapter_proof/summary.json`
- `playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb`
- `playgrounds/igniter-runtime/lib/ivm/compiler.rb`
- `playgrounds/igniter-runtime/lib/ivm/vm.rb`
- `playgrounds/igniter-runtime/lib/ivm/instructions.rb`
- `igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/branch_conditional_if_expr_v0_implementation_proof.rb`
- `igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0/**`
- `igniter-lang/lib/igniter_lang/assembler.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/semanticir_emitter.rb`
- `igniter-lang/lib/igniter_lang/typechecker.rb`

Repository status before decision:

```text
parent repo: clean
playgrounds/igniter-runtime nested repo: clean
```

---

## Rationale

R225 accepted the Add path:

```text
compiler-emitted semantic_ir_program.json
  -> IVM AST
  -> 4-opcode IVM bytecode
  -> IVM execution
  -> 42
```

R225 also accepted lazy branch behavior as supplemental playground evidence,
not as a fresh compiler-emitted `semantic_ir_program.json` branch proof.

The next useful route is therefore not FFI/C acceleration and not helper
extraction. The next useful route is to harden the adapter boundary where the
evidence is still weakest:

- source-backed branch fixture provenance;
- selected vs non-selected branch behavior from compiler output;
- explicit `stdlib.integer.gt` stance;
- selected/non-selected unsupported node behavior;
- digest field cleanup.

---

## Authorized C2-I Boundary

```text
Card: S3-R226-C2-I
Skill: IDD Agent Protocol
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0
Route: UPDATE
Depends on:
- S3-R226-C1-A
```

Allowed write scope:

```text
playgrounds/igniter-runtime/**
igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0.md
```

Read-only / closed unless a later card explicitly opens them:

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

The proof may write generated source, `.igapp` copies, summaries, and proof
outputs under `playgrounds/igniter-runtime/out/**`.

---

## Source Fixture Policy

C2-I must prefer a fresh playground-local compile path:

```text
proof-local .ig source
  -> read-only compiler facade/orchestrator/assembler
  -> playground-local .igapp under playgrounds/igniter-runtime/out/**
  -> semantic_ir_program.json
  -> IVM adapter
```

If fresh compiler emission of a branch fixture is blocked, C2-I may use copied
existing artifacts only under these labels:

```text
copied compiler artifact
copied proof artifact
supplemental legacy semantic_ir.json branch fixture
```

Copied or legacy fixtures are allowed only if provenance is explicit. They may
not be called fresh compiler-emitted `semantic_ir_program.json` branch evidence.

Fresh compile failure is not automatically a card failure if the proof records
the exact blocker and still proves the remaining authorized matrix honestly.

---

## IVM / Adapter Support Policy

Playground-local IVM and adapter edits are allowed only for this proof.

Authorized playground-local edits may include:

- adding a new IVM comparison opcode or equivalent local comparison support for
  `>`;
- mapping compiler-emitted `call fn=stdlib.integer.gt` to that playground
  comparison support;
- extending the playground adapter to map compiler-emitted `if_expr`;
- adding proof-only fixture generation and result summaries.

Not authorized:

- moving IVM, adapter, helper, or runtime code into `igniter-lang/lib/**`;
- adding root require exposure;
- adding `igc run`;
- altering RuntimeSmoke;
- altering compiler/result/report public surfaces;
- claiming Reference Runtime or public runtime support.

`stdlib.integer.gt` stance must be explicit in the result:

```text
mapped
held_gap
rejected_for_scope
```

If mapped, C2-I must prove playground-local bytecode and VM behavior. If held
or rejected, the proof must record why, and must not silently omit comparison
coverage.

---

## Unsupported Node Policy

C2-I must distinguish selected and non-selected paths:

- unsupported selected-path nodes must fail closed with a playground-local
  error;
- unsupported non-selected-path nodes must not fire when the branch is not
  selected;
- malformed or unsupported fixtures must not be promoted to runtime support.

If a fixture cannot prove unsupported non-selected silence from
`semantic_ir_program.json`, that gap must be recorded separately from the
legacy/supplemental branch fixture status.

---

## Digest Cleanup Requirements

C2-I must not reuse ambiguous R225 digest naming.

Required fields:

```text
semantic_ir_program_sha256
source_igapp_path
source_igapp_manifest_sha256_or_null
digest_policy_note
```

If no manifest or directory digest is produced, the summary must explicitly set
the manifest digest to null and state that the file digest is for
`semantic_ir_program.json`.

---

## Required Proof Matrix

C2-I must report BCP-1..BCP-15:

| Check | Requirement |
| --- | --- |
| BCP-1 | Source-backed branch/comparison artifact identified with provenance. |
| BCP-2 | `semantic_ir_program.json` digest recorded separately from any `.igapp` bundle/manifest digest. |
| BCP-3 | Fresh compile attempted, or copied-artifact reason recorded. |
| BCP-4 | Branch `if_expr` maps to IVM AST or direct bytecode, or gap is explicit. |
| BCP-5 | IVM bytecode includes branch jump semantics for accepted branch fixture. |
| BCP-6 | Selected branch executes and returns expected value. |
| BCP-7 | Non-selected branch does not execute. |
| BCP-8 | Unsupported selected-path node fails closed locally. |
| BCP-9 | Unsupported non-selected-path node does not fire when unselected. |
| BCP-10 | `stdlib.integer.gt` stance is explicit: mapped / held_gap / rejected_for_scope. |
| BCP-11 | If `GT` is mapped, playground-local comparison behavior is tested; if held, hold is explicit and non-silent. |
| BCP-12 | R225 Add adapter proof still passes or is recorded as read-only regression. |
| BCP-13 | Accepted R223/R225 evidence is not rewritten. |
| BCP-14 | Closed surfaces remain unchanged. |
| BCP-15 | No public/runtime/stable/production/Reference Runtime claims. |

The result may be accepted as PASS with `stdlib.integer.gt: held_gap` only if
the hold is explicit, justified, and the rest of branch hardening remains
honest. A silent comparison omission is HOLD.

---

## Required Command Matrix

C2-I must run and report:

```text
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb
ruby -c playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_adapter_branch_coverage_proof.rb
git diff --check
git status --short
git -C playgrounds/igniter-runtime status --short
```

Optional regression:

```text
rake spec
ruby -c igniter-lang/lib/igniter_lang/runtime_smoke.rb
ruby -c igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb
```

If command names differ because the proof file chooses a more specific name,
the track doc must state the exact replacement.

---

## Result Packet Shape

C2-I must deliver:

- proof track doc in `igniter-lang/docs/tracks/`;
- playground proof script and outputs under `playgrounds/igniter-runtime/**`;
- summary/result JSON under playground `out/**`;
- compact `[D] [S] [T] [R] [Next]` packet;
- exact branch/comparison support/gap matrix;
- exact changed files;
- exact command matrix result.

Summary JSON should include at minimum:

```text
kind
card
track
overall
evidence_class
source_fixture_policy
source_igapp_path
semantic_ir_program_sha256
source_igapp_manifest_sha256_or_null
stdlib_integer_gt_stance
supported_nodes
unsupported_nodes
branch_status
selected_branch_status
non_selected_branch_status
closed_surface_scan
non_claims
checks
```

---

## Explicit Answers

Whether C2-I may begin in this round:

```text
Yes. C2-I may begin under the bounded playground-only authorization above.
```

Whether writes under `playgrounds/igniter-runtime/**` are allowed:

```text
Yes. Playground writes are allowed, including proof scripts, out artifacts, and
narrow playground-local IVM/adapter changes needed by the proof.
```

Whether the mainline proof track doc may be written:

```text
Yes. The C2-I proof track doc may be written at
igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0.md.
```

Whether any `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public docs,
RuntimeSmoke, CompilerResult, or CompilationReport edits are allowed:

```text
No. They remain closed.
```

Whether playground-local IVM comparison support may be added or must be held:

```text
It may be added only inside playgrounds/igniter-runtime/** for this proof.
If source evidence cannot reach stdlib.integer.gt inside scope, the stance may
be held_gap, but it must be explicit and non-silent.
```

Whether generated outputs may be called branch/comparison adapter-hardening
evidence only:

```text
Yes. That is the strongest allowed label.
```

Whether FFI/C acceleration remains closed:

```text
Yes. FFI/C/Rust acceleration remains closed and may not be implemented in C2-I.
```

Whether reusable helper extraction remains closed:

```text
Yes. Reusable helper extraction remains closed.
```

Whether `igc run`, Reference Runtime, stable API, production, public demo,
Spark, and release claims remain closed:

```text
Yes. All remain closed.
```

---

## Non-Claims

This authorization does not create or imply:

- Reference Runtime support;
- public runtime support;
- production runtime support;
- stable API or v1 compatibility;
- public demo support;
- Spark integration;
- package/gemspec surface;
- CLI `igc run`;
- RuntimeSmoke productization;
- report/result/receipt/cache authority;
- release evidence or release execution.

---

## C2-I Dispatch

```text
Card: S3-R226-C2-I
Skill: IDD Agent Protocol
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0

Route: UPDATE
Depends on:
- S3-R226-C1-A

Goal:
Run the authorized playground-only branch/comparison adapter hardening proof:
source-backed or provenance-explicit branch fixture, selected/non-selected
branch behavior, explicit stdlib.integer.gt stance, unsupported node behavior,
digest field cleanup, and closed-surface verification.

Allowed write scope:
- playgrounds/igniter-runtime/**
- igniter-lang/docs/tracks/
  delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0.md

Required command matrix:
- ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/
  compiler_to_ivm_adapter_proof.rb
- ruby -c playgrounds/igniter-runtime/examples/
  ivm_adapter_branch_coverage_proof.rb
- ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/
  ivm_adapter_branch_coverage_proof.rb
- git diff --check
- git status --short
- git -C playgrounds/igniter-runtime status --short

Deliver:
- proof track doc
- playground proof files and summary/result JSON
- BCP-1..BCP-15 result
- support/gap matrix
- compact [D] [S] [T] [R] [Next] packet
```
