# Experimental Loop Accumulator VM Regression Backlog v0

Status: backlog / pressure-only
Date: 2026-06-05

---

## Purpose

Record a concrete frontier loop execution gap for future agent tests.

This note does not authorize implementation, parser/typechecker/SemanticIR/VM
changes, `igc run` widening, `.igapp` or `.igbin` execution authority,
RuntimeSmoke productization, public runtime support, Reference Runtime support,
stable API, production, release, public performance claims, certification, or
portability guarantees.

---

## Case To Preserve

Source shape:

```igniter
module W1

contract LoopContract {
  input items: Array[Integer]

  compute total = 0

  loop Accumulate in items max_steps: 1000 {
    compute total = total + item
  }

  output total: Integer
}
```

Observed failure:

```text
VM execution error: Missing loop collection expr
```

Expected frontier intent:

```text
items is the loop collection expression
item is the current element binding
total is an accumulator initialized by compute total = 0
loop executes at most max_steps
output total returns accumulated sum
```

For example:

```text
items: [1, 2, 3] -> total: 6
items: [] -> total: 0
items longer than max_steps -> fail-closed fuel/budget diagnostic
```

---

## Required Future Tests

Future loop/recursion or VM hardening agents should include tests for:

```text
LACC-1 parser accepts loop Name in collection max_steps: IntLit
LACC-2 SemanticIR loop node preserves collection expr as expr/ref items
LACC-3 VM compiler accepts loop node with collection expr
LACC-4 VM compiler fails with a clear diagnostic when collection expr is absent
LACC-5 loop body can read item binding
LACC-6 loop body can update declared accumulator total
LACC-7 empty collection preserves accumulator initial value
LACC-8 max_steps exhaustion fails closed with fuel/budget diagnostic
LACC-9 accumulator semantics are documented as fold-like lowering, not generic mutation
LACC-10 generated .igapp evidence remains proof-local until explicitly accepted
```

---

## Routing Note

Recommended future route:

```text
experimental-loop-accumulator-vm-regression-proof-authorization-review-v0
```

The route should decide whether to authorize a bounded lab-only proof for loop
accumulator execution and SemanticIR/VM shape compatibility. It should not
authorize mainline implementation directly.

---

## Compact Backlog Summary

```text
BACKLOG: loop accumulator VM regression tests
CASE: loop Accumulate in items max_steps: 1000 { compute total = total + item }
ERROR: VM execution error: Missing loop collection expr
EXPECT: preserve collection expr, item binding, accumulator semantics, fuel guard
CLOSED: implementation, runtime authority, public/stable/release claims
```
