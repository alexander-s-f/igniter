# Stdlib Execution Kernel Stage 1 v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/stdlib-execution-kernel-stage1-v0`
Status: done
Date: 2026-05-06

## Goal

Start the Stage 1 RuntimeMachine stdlib execution proof with a compact,
deterministic kernel. This is a proof fixture, not production runtime code.

## Neighbor Awareness

- `[Igniter-Lang Compiler/Grammar Expert]`: operator/type boundary and final
  stdlib naming rules.
- `[Igniter-Lang Bridge Agent]`: later RuntimeMachine/package integration once
  the assembler and runtime hooks are approved.

## Decisions

[D] `stdlib.numeric.add` is pre-resolution only. A runtime evaluator must see a
monomorphic executable operator such as `stdlib.integer.add`,
`stdlib.float.add`, or `stdlib.decimal.add`.

[D] Stage 1 collection/option proof is limited to bounded, deterministic:
`fold`, `map`, `filter`, `count`, and `or_else`.

[D] Stage 2 primitives remain out of scope: no `History[T]`, no `stream T`, no
`OLAPPoint[T, Dims]`, no `fold_stream`.

[D] Decimal addition in the proof uses a tiny exact `DecimalValue` wrapper and
emits fixed-scale string output to avoid Float drift.

## Proof

Executable proof:

```bash
ruby igniter-lang/experiments/stdlib_execution_kernel_stage1/stdlib_execution_kernel_stage1.rb
```

Proof output:

```text
kernel.integer_add: ok
kernel.float_add: ok
kernel.decimal_add_exact: ok
kernel.integer_gt: ok
kernel.bool_and: ok
kernel.fold: ok
kernel.map: ok
kernel.filter: ok
kernel.count: ok
kernel.or_else_some: ok
kernel.or_else_none: ok
kernel.numeric_add_rejected: ok
kernel.legacy_add_rejected: ok
kernel.unknown_stdlib_operator_rejected: ok
runtime.add_igapp_style_integer_add: ok
runtime.add_igapp_style_rejects_numeric_add: ok
runtime.add_igapp_style_rejects_legacy_add: ok
runtime.rejects_unknown_stdlib_operator: ok
```

## What Is Proven

[S] A minimal stdlib operator table can execute the Stage 1 arithmetic and
bounded collection/option surface deterministically.

[S] An add.igapp-style `compute_nodes[].expression.kind == "apply"` path can
call `stdlib.integer.add` by canonical name and produce the expected output.

[S] The same runtime path rejects `stdlib.numeric.add`; checks are not weakened
to keep old overloaded operator names executable.

## Missing Runtime Hooks

[D] Follow-up track `canonical-stdlib-registry-runtime-v0` closed the
RuntimeMachine proof gap: `CompiledProgram#apply_operator` now routes stdlib
calls through a canonical registry and rejects `"add"`,
`"stdlib.numeric.add"`, and unknown `stdlib.*` operators.

[D] `fixtures/add.igapp/contracts/add.json` was migrated to
`stdlib.integer.add`.

[Q] PROP-019.1 SemanticIR emits `nodes[].expr.kind == "call"` with `fn`, while
the older RuntimeMachine proof evaluates `compute_nodes[].expression.kind ==
"apply"` with `operator`. The loader needs either an assembler normalization
step or evaluator support for the canonical envelope.

[Q] Decimal value representation is not yet standardized across `.igapp`,
SemanticIR, and RuntimeMachine.

[Q] `map`/`filter`/`fold` currently use proof-local bounded function specs. A
real runtime hook needs compiler-emitted lambda/function refs with typechecked
closures and deterministic termination evidence.

## Rejected

[X] No Stage 2 primitives were added.

[X] No generic `stdlib.numeric.add` runtime execution was preserved.

[X] No production Igniter package code was touched.

## Next

[Next] Update the real RuntimeMachine memory proof evaluator to route canonical
stdlib operators through a small registry and block `stdlib.numeric.add`.

[Next] After the `.igapp` assembler proof lands, produce an assembled add
fixture whose loadable contract already contains `stdlib.integer.add`.
